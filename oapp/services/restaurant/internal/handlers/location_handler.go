package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/deliveryx/restaurant-service/internal/models"
	"github.com/deliveryx/restaurant-service/internal/repository"
	"github.com/gorilla/mux"
)

type LocationHandler struct {
	locationRepo *repository.LocationRepository
	storeRepo    *repository.StoreRepository
}

func NewLocationHandler(locationRepo *repository.LocationRepository, storeRepo *repository.StoreRepository) *LocationHandler {
	return &LocationHandler{
		locationRepo: locationRepo,
		storeRepo:    storeRepo,
	}
}

// CreateLocation handles POST /api/v1/stores/{store_id}/locations
func (h *LocationHandler) CreateLocation(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	storeID := vars["store_id"]

	// Verify store exists
	_, err := h.storeRepo.GetByID(storeID)
	if err != nil {
		if err.Error() == "store not found" {
			respondWithError(w, http.StatusNotFound, "Store not found")
			return
		}
		respondWithError(w, http.StatusInternalServerError, "Failed to verify store")
		return
	}

	var req models.CreateLocationRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondWithError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	// Validate required fields
	if req.Address == "" || req.City == "" || req.Phone == "" {
		respondWithError(w, http.StatusBadRequest, "Address, city, and phone are required")
		return
	}

	location, err := h.locationRepo.Create(storeID, &req)
	if err != nil {
		respondWithError(w, http.StatusInternalServerError, "Failed to create location")
		return
	}

	respondWithJSON(w, http.StatusCreated, location)
}

// GetLocation handles GET /api/v1/locations/{location_id}
func (h *LocationHandler) GetLocation(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	locationID := vars["location_id"]

	location, err := h.locationRepo.GetByID(locationID)
	if err != nil {
		if err.Error() == "location not found" {
			respondWithError(w, http.StatusNotFound, "Location not found")
			return
		}
		respondWithError(w, http.StatusInternalServerError, "Failed to get location")
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
			respondWithError(w, http.StatusNotFound, "Location not found")
			return
		}
		respondWithError(w, http.StatusInternalServerError, "Failed to verify location")
		return
	}

	var hours []models.OperatingHourInput

	if err := json.NewDecoder(r.Body).Decode(&hours); err != nil {
		respondWithError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	// Validate we have exactly 7 days
	if len(hours) != 7 {
		respondWithError(w, http.StatusBadRequest, "Must provide operating hours for all 7 days")
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
			respondWithError(w, http.StatusBadRequest, "Invalid day_of_week value")
			return
		}
		if seenDays[hour.DayOfWeek] {
			respondWithError(w, http.StatusBadRequest, "Duplicate day_of_week value")
			return
		}
		seenDays[hour.DayOfWeek] = true

		// Validate times if not closed
		if !hour.IsClosed && (hour.OpenTime == "" || hour.CloseTime == "") {
			respondWithError(w, http.StatusBadRequest, "Open and close times required when not closed")
			return
		}
	}

	err = h.locationRepo.SetOperatingHours(locationID, hours)
	if err != nil {
		respondWithError(w, http.StatusInternalServerError, "Failed to set operating hours")
		return
	}

	// Get updated hours
	updatedHours, err := h.locationRepo.GetOperatingHours(locationID)
	if err != nil {
		respondWithError(w, http.StatusInternalServerError, "Failed to get updated operating hours")
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
			respondWithError(w, http.StatusNotFound, "Location not found")
			return
		}
		respondWithError(w, http.StatusInternalServerError, "Failed to verify location")
		return
	}

	hours, err := h.locationRepo.GetOperatingHours(locationID)
	if err != nil {
		respondWithError(w, http.StatusInternalServerError, "Failed to get operating hours")
		return
	}

	respondWithJSON(w, http.StatusOK, map[string]interface{}{
		"hours": hours,
	})
}
