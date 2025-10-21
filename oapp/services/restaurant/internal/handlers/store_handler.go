package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/deliveryx/restaurant-service/internal/models"
	"github.com/deliveryx/restaurant-service/internal/repository"
	"github.com/gorilla/mux"
)

type StoreHandler struct {
	repo *repository.StoreRepository
}

func NewStoreHandler(repo *repository.StoreRepository) *StoreHandler {
	return &StoreHandler{repo: repo}
}

// CreateStore handles POST /api/v1/stores
func (h *StoreHandler) CreateStore(w http.ResponseWriter, r *http.Request) {
	var req models.CreateStoreRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondWithError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	// Validate required fields
	if req.Name == "" || req.Phone == "" {
		respondWithError(w, http.StatusBadRequest, "Name and phone are required")
		return
	}

	// Validate field lengths
	if len(req.Name) > 255 {
		respondWithError(w, http.StatusBadRequest, "Name must not exceed 255 characters")
		return
	}

	if req.Description != nil && len(*req.Description) > 1000 {
		respondWithError(w, http.StatusBadRequest, "Description must not exceed 1000 characters")
		return
	}

	store, err := h.repo.Create(&req)
	if err != nil {
		respondWithError(w, http.StatusInternalServerError, "Failed to create store")
		return
	}

	respondWithJSON(w, http.StatusCreated, store)
}

// GetStore handles GET /api/v1/stores/{store_id}
func (h *StoreHandler) GetStore(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	storeID := vars["store_id"]

	store, err := h.repo.GetByID(storeID)
	if err != nil {
		if err.Error() == "store not found" {
			respondWithError(w, http.StatusNotFound, "Store not found")
			return
		}
		respondWithError(w, http.StatusInternalServerError, "Failed to get store")
		return
	}

	respondWithJSON(w, http.StatusOK, store)
}

// UpdateStore handles PUT /api/v1/stores/{store_id}
func (h *StoreHandler) UpdateStore(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	storeID := vars["store_id"]

	var req models.UpdateStoreRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondWithError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	// Validate field lengths
	if req.Name != nil && len(*req.Name) > 255 {
		respondWithError(w, http.StatusBadRequest, "Name must not exceed 255 characters")
		return
	}

	if req.Description != nil && len(*req.Description) > 1000 {
		respondWithError(w, http.StatusBadRequest, "Description must not exceed 1000 characters")
		return
	}

	store, err := h.repo.Update(storeID, &req)
	if err != nil {
		if err.Error() == "store not found" {
			respondWithError(w, http.StatusNotFound, "Store not found")
			return
		}
		respondWithError(w, http.StatusInternalServerError, "Failed to update store")
		return
	}

	respondWithJSON(w, http.StatusOK, store)
}
