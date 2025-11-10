package handlers

import (
	"database/sql"
	"net/http"

	"github.com/deliveryx/menu-service/internal/repository"
	"github.com/gorilla/mux"
)

type InternalHandler struct {
	menuRepo *repository.MenuRepository
}

func NewInternalHandler(menuRepo *repository.MenuRepository) *InternalHandler {
	return &InternalHandler{menuRepo: menuRepo}
}

// LocationMenuCheckResponse represents the response for has-menus check
type LocationMenuCheckResponse struct {
	HasMenus   bool `json:"has_menus"`
	MenusCount int  `json:"menus_count"`
}

// CheckLocationHasMenus handles GET /internal/locations/{location_id}/has-menus
// Returns whether a location has any menus (for deletion validation)
func (h *InternalHandler) CheckLocationHasMenus(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	locationID := vars["location_id"]

	// Count menus for this location using the repository's CountByLocation method
	count, err := h.menuRepo.CountByLocation(locationID)
	if err != nil && err != sql.ErrNoRows {
		respondWithError(w, http.StatusInternalServerError, "Failed to check menus")
		return
	}

	response := LocationMenuCheckResponse{
		HasMenus:   count > 0,
		MenusCount: count,
	}

	respondWithJSON(w, http.StatusOK, response)
}

// GetMenuSummary handles GET /internal/locations/{location_id}/menu-summary
// Returns menu summary information for a location (for admin portal display)
func (h *InternalHandler) GetMenuSummary(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	locationID := vars["location_id"]

	summary, err := h.menuRepo.GetSummaryByLocation(locationID)
	if err != nil {
		respondWithError(w, http.StatusInternalServerError, "Failed to get menu summary")
		return
	}

	// If no menu exists, return null
	if summary == nil {
		respondWithJSON(w, http.StatusOK, nil)
		return
	}

	respondWithJSON(w, http.StatusOK, summary)
}
