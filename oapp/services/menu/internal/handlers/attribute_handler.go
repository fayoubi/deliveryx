package handlers

import (
	"net/http"

	"github.com/deliveryx/menu-service/internal/repository"
	"github.com/gorilla/mux"
)

type AttributeHandler struct {
	repo *repository.AttributeRepository
}

func NewAttributeHandler(repo *repository.AttributeRepository) *AttributeHandler {
	return &AttributeHandler{repo: repo}
}

// GetAttributeGroups handles GET /api/v1/attribute-groups
func (h *AttributeHandler) GetAttributeGroups(w http.ResponseWriter, r *http.Request) {
	groups, err := h.repo.GetAllAttributeGroups()
	if err != nil {
		respondWithError(w, http.StatusInternalServerError, "Failed to get attribute groups")
		return
	}

	respondWithJSON(w, http.StatusOK, groups)
}

// GetAttributes handles GET /api/v1/attribute-groups/{id}/attributes
func (h *AttributeHandler) GetAttributes(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	groupID := vars["id"]

	attributes, err := h.repo.GetAttributesByGroupID(groupID)
	if err != nil {
		if err.Error() == "attribute group not found" {
			respondWithError(w, http.StatusNotFound, "Attribute group not found")
			return
		}
		respondWithError(w, http.StatusInternalServerError, "Failed to get attributes")
		return
	}

	respondWithJSON(w, http.StatusOK, attributes)
}
