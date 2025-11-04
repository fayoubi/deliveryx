package handlers

import (
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/deliveryx/restaurant-service/internal/models"
	"github.com/deliveryx/restaurant-service/internal/repository"
	"github.com/deliveryx/restaurant-service/internal/utils"
	"github.com/gorilla/mux"
)

type StoreHandler struct {
	repo *repository.StoreRepository
}

func NewStoreHandler(repo *repository.StoreRepository) *StoreHandler {
	return &StoreHandler{repo: repo}
}

// ListStores handles GET /api/v1/stores
func (h *StoreHandler) ListStores(w http.ResponseWriter, r *http.Request) {
	// Parse query parameters
	query := r.URL.Query()

	// Pagination
	page, _ := strconv.Atoi(query.Get("page"))
	pageSize, _ := strconv.Atoi(query.Get("page_size"))
	pagination := repository.ParsePaginationParams(page, pageSize)

	// Filtering
	filters := repository.FilterParams{
		Query: query.Get("q"),
		Phone: query.Get("phone"),
	}

	// Sorting (allowed: name, created_at; default: name asc)
	sortParam := query.Get("sort")
	sort := repository.ParseSortParam(sortParam, []string{"name", "created_at"}, "name")

	// Fetch stores
	stores, total, err := h.repo.List(filters, pagination, sort)
	if err != nil {
		respondWithSimpleError(w, http.StatusInternalServerError, "Failed to list stores", models.ErrCodeInternalError)
		return
	}

	// Build paginated response
	response := models.NewPaginatedResponse(stores, pagination.Page, pagination.PageSize, total)
	respondWithJSON(w, http.StatusOK, response)
}

// CreateStore handles POST /api/v1/stores
func (h *StoreHandler) CreateStore(w http.ResponseWriter, r *http.Request) {
	var req models.CreateStoreRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondWithSimpleError(w, http.StatusBadRequest, "Invalid request body", models.ErrCodeInvalidRequest)
		return
	}

	// Validate required fields
	if req.Name == "" || req.Phone == "" {
		respondWithSimpleError(w, http.StatusBadRequest, "Name and phone are required", models.ErrCodeValidation)
		return
	}

	// Validate field lengths
	if len(req.Name) > 255 {
		respondWithSimpleError(w, http.StatusBadRequest, "Name must not exceed 255 characters", models.ErrCodeValidation)
		return
	}

	if req.Description != nil && len(*req.Description) > 1000 {
		respondWithSimpleError(w, http.StatusBadRequest, "Description must not exceed 1000 characters", models.ErrCodeValidation)
		return
	}

	// Validate phone pattern
	if err := utils.ValidatePhone(req.Phone); err != nil {
		respondWithSimpleError(w, http.StatusBadRequest, err.Error(), models.ErrCodeValidation)
		return
	}

	store, err := h.repo.Create(&req)
	if err != nil {
		respondWithSimpleError(w, http.StatusInternalServerError, "Failed to create store", models.ErrCodeInternalError)
		return
	}

	respondWithJSON(w, http.StatusCreated, store)
}

// GetStore handles GET /api/v1/stores/{store_id}
func (h *StoreHandler) GetStore(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	storeID := vars["store_id"]

	// Validate UUID format
	if !utils.IsValidUUID(storeID) {
		respondWithSimpleError(w, http.StatusNotFound, "Store not found", models.ErrCodeNotFound)
		return
	}

	store, err := h.repo.GetByID(storeID)
	if err != nil {
		if err.Error() == "store not found" {
			respondWithSimpleError(w, http.StatusNotFound, "Store not found", models.ErrCodeNotFound)
			return
		}
		respondWithSimpleError(w, http.StatusInternalServerError, "Failed to get store", models.ErrCodeInternalError)
		return
	}

	respondWithJSON(w, http.StatusOK, store)
}

// UpdateStore handles PUT /api/v1/stores/{store_id}
func (h *StoreHandler) UpdateStore(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	storeID := vars["store_id"]

	// Validate UUID format
	if !utils.IsValidUUID(storeID) {
		respondWithSimpleError(w, http.StatusNotFound, "Store not found", models.ErrCodeNotFound)
		return
	}

	var req models.UpdateStoreRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondWithSimpleError(w, http.StatusBadRequest, "Invalid request body", models.ErrCodeInvalidRequest)
		return
	}

	// Validate field lengths
	if req.Name != nil && len(*req.Name) > 255 {
		respondWithSimpleError(w, http.StatusBadRequest, "Name must not exceed 255 characters", models.ErrCodeValidation)
		return
	}

	if req.Description != nil && len(*req.Description) > 1000 {
		respondWithSimpleError(w, http.StatusBadRequest, "Description must not exceed 1000 characters", models.ErrCodeValidation)
		return
	}

	// Validate phone pattern if provided
	if req.Phone != nil {
		if err := utils.ValidatePhone(*req.Phone); err != nil {
			respondWithSimpleError(w, http.StatusBadRequest, err.Error(), models.ErrCodeValidation)
			return
		}
	}

	store, err := h.repo.Update(storeID, &req)
	if err != nil {
		if err.Error() == "store not found" {
			respondWithSimpleError(w, http.StatusNotFound, "Store not found", models.ErrCodeNotFound)
			return
		}
		respondWithSimpleError(w, http.StatusInternalServerError, "Failed to update store", models.ErrCodeInternalError)
		return
	}

	respondWithJSON(w, http.StatusOK, store)
}

// DeleteStore handles DELETE /api/v1/stores/{store_id}
func (h *StoreHandler) DeleteStore(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	storeID := vars["store_id"]

	// Validate UUID format
	if !utils.IsValidUUID(storeID) {
		respondWithSimpleError(w, http.StatusNotFound, "Store not found", models.ErrCodeNotFound)
		return
	}

	// Check if store exists
	_, err := h.repo.GetByID(storeID)
	if err != nil {
		if err.Error() == "store not found" {
			respondWithSimpleError(w, http.StatusNotFound, "Store not found", models.ErrCodeNotFound)
			return
		}
		respondWithSimpleError(w, http.StatusInternalServerError, "Failed to check store", models.ErrCodeInternalError)
		return
	}

	// Check if store has locations
	locationsCount, err := h.repo.CountLocations(storeID)
	if err != nil {
		respondWithSimpleError(w, http.StatusInternalServerError, "Failed to check for locations", models.ErrCodeInternalError)
		return
	}

	if locationsCount > 0 {
		apiErr := models.NewAPIError(
			"Store cannot be deleted while it has locations",
			models.ErrCodeStoreHasLocs,
		).WithDetail("locations_count", locationsCount)
		respondWithError(w, http.StatusConflict, apiErr)
		return
	}

	// Delete store
	err = h.repo.Delete(storeID)
	if err != nil {
		respondWithSimpleError(w, http.StatusInternalServerError, "Failed to delete store", models.ErrCodeInternalError)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}
