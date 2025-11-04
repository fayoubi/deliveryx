package handlers

import (
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/deliveryx/restaurant-service/internal/client"
	"github.com/deliveryx/restaurant-service/internal/models"
	"github.com/deliveryx/restaurant-service/internal/repository"
	"github.com/deliveryx/restaurant-service/internal/utils"
	"github.com/gorilla/mux"
)

type LocationHandler struct {
	locationRepo *repository.LocationRepository
	storeRepo    *repository.StoreRepository
	menuClient   *client.MenuServiceClient
}

func NewLocationHandler(locationRepo *repository.LocationRepository, storeRepo *repository.StoreRepository, menuClient *client.MenuServiceClient) *LocationHandler {
	return &LocationHandler{
		locationRepo: locationRepo,
		storeRepo:    storeRepo,
		menuClient:   menuClient,
	}
}

// CreateLocation handles POST /api/v1/stores/{store_id}/locations
func (h *LocationHandler) CreateLocation(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	storeID := vars["store_id"]

	// Validate UUID format
	if !utils.IsValidUUID(storeID) {
		respondWithSimpleError(w, http.StatusNotFound, "Store not found", models.ErrCodeNotFound)
		return
	}

	// Verify store exists
	_, err := h.storeRepo.GetByID(storeID)
	if err != nil {
		if err.Error() == "store not found" {
			respondWithSimpleError(w, http.StatusNotFound, "Store not found", models.ErrCodeNotFound)
			return
		}
		respondWithSimpleError(w, http.StatusInternalServerError, "Failed to verify store", models.ErrCodeInternalError)
		return
	}

	var req models.CreateLocationRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondWithSimpleError(w, http.StatusBadRequest, "Invalid request body", models.ErrCodeInvalidRequest)
		return
	}

	// Validate required fields
	if req.Address == "" || req.City == "" || req.Phone == "" {
		respondWithSimpleError(w, http.StatusBadRequest, "Address, city, and phone are required", models.ErrCodeValidation)
		return
	}

	// Validate phone pattern
	if err := utils.ValidatePhone(req.Phone); err != nil {
		respondWithSimpleError(w, http.StatusBadRequest, err.Error(), models.ErrCodeValidation)
		return
	}

	// Validate lat/lng if provided
	if req.Latitude != nil {
		if err := utils.ValidateLatitude(*req.Latitude); err != nil {
			respondWithSimpleError(w, http.StatusBadRequest, err.Error(), models.ErrCodeValidation)
			return
		}
	}
	if req.Longitude != nil {
		if err := utils.ValidateLongitude(*req.Longitude); err != nil {
			respondWithSimpleError(w, http.StatusBadRequest, err.Error(), models.ErrCodeValidation)
			return
		}
	}

	location, err := h.locationRepo.Create(storeID, &req)
	if err != nil {
		respondWithSimpleError(w, http.StatusInternalServerError, "Failed to create location", models.ErrCodeInternalError)
		return
	}

	respondWithJSON(w, http.StatusCreated, location)
}

// GetLocation handles GET /api/v1/locations/{location_id}
func (h *LocationHandler) GetLocation(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	locationID := vars["location_id"]

	// Validate UUID format
	if !utils.IsValidUUID(locationID) {
		respondWithSimpleError(w, http.StatusNotFound, "Location not found", models.ErrCodeNotFound)
		return
	}

	location, err := h.locationRepo.GetByID(locationID)
	if err != nil {
		if err.Error() == "location not found" {
			respondWithSimpleError(w, http.StatusNotFound, "Location not found", models.ErrCodeNotFound)
			return
		}
		respondWithSimpleError(w, http.StatusInternalServerError, "Failed to get location", models.ErrCodeInternalError)
		return
	}

	// Get operating hours (may be empty if not set yet)
	hours, err := h.locationRepo.GetOperatingHours(locationID)
	if err != nil {
		// If error getting hours, return location with empty hours array
		hours = []models.OperatingHour{}
	}

	// Combine into response
	response := models.LocationWithHours{
		Location:       *location,
		OperatingHours: hours,
	}

	respondWithJSON(w, http.StatusOK, response)
}

// SetOperatingHours handles PUT /api/v1/locations/{location_id}/operating-hours
func (h *LocationHandler) SetOperatingHours(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	locationID := vars["location_id"]

	// Verify location exists
	_, err := h.locationRepo.GetByID(locationID)
	if err != nil {
		if err.Error() == "location not found" {
			respondWithSimpleError(w, http.StatusNotFound, "Location not found", models.ErrCodeNotFound)
			return
		}
		respondWithSimpleError(w, http.StatusInternalServerError, "Failed to verify location", models.ErrCodeInternalError)
		return
	}

	var hours []models.OperatingHourInput

	if err := json.NewDecoder(r.Body).Decode(&hours); err != nil {
		respondWithSimpleError(w, http.StatusBadRequest, "Invalid request body", models.ErrCodeInvalidRequest)
		return
	}

	// Validate we have exactly 7 days
	if len(hours) != 7 {
		respondWithSimpleError(w, http.StatusBadRequest, "Must provide operating hours for all 7 days", models.ErrCodeValidation)
		return
	}

	// Validate day_of_week values
	validDays := map[string]bool{
		"MONDAY": true, "TUESDAY": true, "WEDNESDAY": true, "THURSDAY": true,
		"FRIDAY": true, "SATURDAY": true, "SUNDAY": true,
	}
	seenDays := make(map[string]bool)

	for _, hour := range hours {
		if !validDays[hour.DayOfWeek] {
			respondWithSimpleError(w, http.StatusBadRequest, "Invalid day_of_week value", models.ErrCodeValidation)
			return
		}
		if seenDays[hour.DayOfWeek] {
			respondWithSimpleError(w, http.StatusBadRequest, "Duplicate day_of_week value", models.ErrCodeValidation)
			return
		}
		seenDays[hour.DayOfWeek] = true

		// Validate times if not closed
		if !hour.IsClosed && (hour.OpenTime == "" || hour.CloseTime == "") {
			respondWithSimpleError(w, http.StatusBadRequest, "Open and close times required when not closed", models.ErrCodeValidation)
			return
		}
	}

	err = h.locationRepo.SetOperatingHours(locationID, hours)
	if err != nil {
		respondWithSimpleError(w, http.StatusInternalServerError, "Failed to set operating hours", models.ErrCodeInternalError)
		return
	}

	// Get updated hours
	updatedHours, err := h.locationRepo.GetOperatingHours(locationID)
	if err != nil {
		respondWithSimpleError(w, http.StatusInternalServerError, "Failed to get updated operating hours", models.ErrCodeInternalError)
		return
	}

	respondWithJSON(w, http.StatusOK, updatedHours)
}

// GetOperatingHours handles GET /api/v1/locations/{location_id}/operating-hours
func (h *LocationHandler) GetOperatingHours(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	locationID := vars["location_id"]

	// Verify location exists
	_, err := h.locationRepo.GetByID(locationID)
	if err != nil {
		if err.Error() == "location not found" {
			respondWithSimpleError(w, http.StatusNotFound, "Location not found", models.ErrCodeNotFound)
			return
		}
		respondWithSimpleError(w, http.StatusInternalServerError, "Failed to verify location", models.ErrCodeInternalError)
		return
	}

	hours, err := h.locationRepo.GetOperatingHours(locationID)
	if err != nil {
		respondWithSimpleError(w, http.StatusInternalServerError, "Failed to get operating hours", models.ErrCodeInternalError)
		return
	}

	respondWithJSON(w, http.StatusOK, map[string]interface{}{
		"hours": hours,
	})
}

// ListLocations handles GET /api/v1/stores/{store_id}/locations
func (h *LocationHandler) ListLocations(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	storeID := vars["store_id"]

	// Validate UUID format
	if !utils.IsValidUUID(storeID) {
		respondWithSimpleError(w, http.StatusNotFound, "Store not found", models.ErrCodeNotFound)
		return
	}

	// Verify store exists
	_, err := h.storeRepo.GetByID(storeID)
	if err != nil {
		if err.Error() == "store not found" {
			respondWithSimpleError(w, http.StatusNotFound, "Store not found", models.ErrCodeNotFound)
			return
		}
		respondWithSimpleError(w, http.StatusInternalServerError, "Failed to verify store", models.ErrCodeInternalError)
		return
	}

	// Parse query parameters
	query := r.URL.Query()

	// Pagination
	page, _ := strconv.Atoi(query.Get("page"))
	pageSize, _ := strconv.Atoi(query.Get("page_size"))
	pagination := repository.ParsePaginationParams(page, pageSize)

	// Filtering
	filters := repository.FilterParams{
		Query: query.Get("q"),
		City:  query.Get("city"),
	}

	// Sorting (allowed: city, created_at; default: city asc, then address asc)
	sortParam := query.Get("sort")
	sort := repository.ParseSortParam(sortParam, []string{"city", "created_at"}, "city")

	// Fetch locations
	locations, total, err := h.locationRepo.List(storeID, filters, pagination, sort)
	if err != nil {
		respondWithSimpleError(w, http.StatusInternalServerError, "Failed to list locations", models.ErrCodeInternalError)
		return
	}

	// Build paginated response
	response := models.NewPaginatedResponse(locations, pagination.Page, pagination.PageSize, total)
	respondWithJSON(w, http.StatusOK, response)
}

// UpdateLocation handles PUT /api/v1/locations/{location_id}
func (h *LocationHandler) UpdateLocation(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	locationID := vars["location_id"]

	// Validate UUID format
	if !utils.IsValidUUID(locationID) {
		respondWithSimpleError(w, http.StatusNotFound, "Location not found", models.ErrCodeNotFound)
		return
	}

	var req models.UpdateLocationRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondWithSimpleError(w, http.StatusBadRequest, "Invalid request body", models.ErrCodeInvalidRequest)
		return
	}

	// Check if at least one field is provided
	hasFields := utils.HasAtLeastOneField(req.Address, req.City, req.PostalCode, req.Phone, req.LocationManager, req.Latitude, req.Longitude)
	if !hasFields {
		apiErr := models.NewAPIError(
			"At least one field must be provided for update",
			models.ErrCodeValidation,
		).WithDetail("allowed_fields", []string{"address", "city", "postal_code", "phone", "location_manager", "latitude", "longitude"})
		respondWithError(w, http.StatusBadRequest, apiErr)
		return
	}

	// Validate field lengths
	if req.City != nil && len(*req.City) > 100 {
		respondWithSimpleError(w, http.StatusBadRequest, "City must not exceed 100 characters", models.ErrCodeValidation)
		return
	}

	if req.PostalCode != nil && len(*req.PostalCode) > 20 {
		respondWithSimpleError(w, http.StatusBadRequest, "Postal code must not exceed 20 characters", models.ErrCodeValidation)
		return
	}

	// Validate phone pattern if provided
	if req.Phone != nil {
		if err := utils.ValidatePhone(*req.Phone); err != nil {
			respondWithSimpleError(w, http.StatusBadRequest, err.Error(), models.ErrCodeValidation)
			return
		}
	}

	// Validate latitude range if provided
	if req.Latitude != nil {
		if err := utils.ValidateLatitude(*req.Latitude); err != nil {
			respondWithSimpleError(w, http.StatusBadRequest, err.Error(), models.ErrCodeValidation)
			return
		}
	}

	// Validate longitude range if provided
	if req.Longitude != nil {
		if err := utils.ValidateLongitude(*req.Longitude); err != nil {
			respondWithSimpleError(w, http.StatusBadRequest, err.Error(), models.ErrCodeValidation)
			return
		}
	}

	location, err := h.locationRepo.Update(locationID, &req)
	if err != nil {
		if err.Error() == "location not found" {
			respondWithSimpleError(w, http.StatusNotFound, "Location not found", models.ErrCodeNotFound)
			return
		}
		respondWithSimpleError(w, http.StatusInternalServerError, "Failed to update location", models.ErrCodeInternalError)
		return
	}

	respondWithJSON(w, http.StatusOK, location)
}

// DeleteLocation handles DELETE /api/v1/locations/{location_id}
func (h *LocationHandler) DeleteLocation(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	locationID := vars["location_id"]

	// Validate UUID format
	if !utils.IsValidUUID(locationID) {
		respondWithSimpleError(w, http.StatusNotFound, "Location not found", models.ErrCodeNotFound)
		return
	}

	// Check if location exists
	_, err := h.locationRepo.GetByID(locationID)
	if err != nil {
		if err.Error() == "location not found" {
			respondWithSimpleError(w, http.StatusNotFound, "Location not found", models.ErrCodeNotFound)
			return
		}
		respondWithSimpleError(w, http.StatusInternalServerError, "Failed to check location", models.ErrCodeInternalError)
		return
	}

	// Check if location has menus via Menu Service
	menuCheck, err := h.menuClient.CheckLocationHasMenus(locationID)
	if err != nil {
		respondWithSimpleError(w, http.StatusServiceUnavailable, "Failed to check for menus", models.ErrCodeServiceUnavail)
		return
	}

	if menuCheck.HasMenus {
		apiErr := models.NewAPIError(
			"Location cannot be deleted while it has menus",
			models.ErrCodeLocationHasMenus,
		).WithDetail("menus_count", menuCheck.MenusCount)
		respondWithError(w, http.StatusConflict, apiErr)
		return
	}

	// Delete location
	err = h.locationRepo.Delete(locationID)
	if err != nil {
		respondWithSimpleError(w, http.StatusInternalServerError, "Failed to delete location", models.ErrCodeInternalError)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}
