package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/deliveryx/menu-service/internal/models"
	"github.com/deliveryx/menu-service/internal/repository"
	"github.com/gorilla/mux"
)

type CollectionHandler struct {
	repo *repository.CollectionRepository
}

func NewCollectionHandler(repo *repository.CollectionRepository) *CollectionHandler {
	return &CollectionHandler{repo: repo}
}

// CreateCollection handles POST /api/v1/menus/{menu_id}/collections
func (h *CollectionHandler) CreateCollection(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	menuID := vars["menu_id"]

	var req models.CreateCollectionRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondWithError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	collection, err := h.repo.Create(menuID, &req)
	if err != nil {
		if err.Error() == "menu not found" {
			respondWithError(w, http.StatusNotFound, "Menu not found")
			return
		}
		if err.Error() == "menu is not in draft status" {
			respondWithError(w, http.StatusBadRequest, err.Error())
			return
		}
		respondWithError(w, http.StatusInternalServerError, "Failed to create collection")
		return
	}

	respondWithJSON(w, http.StatusCreated, collection)
}

// DeleteCollection handles DELETE /api/v1/collections/{collection_id}
func (h *CollectionHandler) DeleteCollection(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	collectionID := vars["collection_id"]

	err := h.repo.Delete(collectionID)
	if err != nil {
		if err.Error() == "collection not found" {
			respondWithError(w, http.StatusNotFound, "Collection not found")
			return
		}
		if err.Error() == "menu is not in draft status" {
			respondWithError(w, http.StatusBadRequest, err.Error())
			return
		}
		respondWithError(w, http.StatusInternalServerError, "Failed to delete collection")
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

// ReorderCollections handles PUT /api/v1/menus/{menu_id}/collections/reorder
func (h *CollectionHandler) ReorderCollections(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	menuID := vars["menu_id"]

	var req models.ReorderCollectionsRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondWithError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	err := h.repo.Reorder(menuID, req.Collections)
	if err != nil {
		respondWithError(w, http.StatusBadRequest, err.Error())
		return
	}

	respondWithJSON(w, http.StatusOK, map[string]string{"message": "Collections reordered successfully"})
}
