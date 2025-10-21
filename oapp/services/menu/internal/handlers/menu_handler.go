package handlers

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"time"

	"github.com/deliveryx/menu-service/internal/models"
	"github.com/deliveryx/menu-service/internal/repository"
	"github.com/deliveryx/menu-service/pkg/queue"
	"github.com/gorilla/mux"
)

type MenuHandler struct {
	menuRepo          *repository.MenuRepository
	menuRetrievalRepo *repository.MenuRetrievalRepository
	queueClient       *queue.RabbitMQClient
}

func NewMenuHandler(menuRepo *repository.MenuRepository, menuRetrievalRepo *repository.MenuRetrievalRepository, queueClient *queue.RabbitMQClient) *MenuHandler {
	return &MenuHandler{
		menuRepo:          menuRepo,
		menuRetrievalRepo: menuRetrievalRepo,
		queueClient:       queueClient,
	}
}

// CreateMenu handles POST /api/v1/locations/{location_id}/menus
func (h *MenuHandler) CreateMenu(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	locationID := vars["location_id"]

	menu, err := h.menuRepo.Create(locationID)
	if err != nil {
		if err.Error() == "menu already exists for this location" {
			respondWithError(w, http.StatusBadRequest, err.Error())
			return
		}
		respondWithError(w, http.StatusInternalServerError, "Failed to create menu")
		return
	}

	respondWithJSON(w, http.StatusCreated, menu)
}

// GetMenuStatus handles GET /api/v1/menus/{menu_id}/status
func (h *MenuHandler) GetMenuStatus(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	menuID := vars["menu_id"]

	menu, err := h.menuRepo.GetByID(menuID)
	if err != nil {
		if err.Error() == "menu not found" {
			respondWithError(w, http.StatusNotFound, "Menu not found")
			return
		}
		respondWithError(w, http.StatusInternalServerError, "Failed to get menu")
		return
	}

	response := models.MenuStatusResponse{
		Status:          menu.Status,
		SubmittedAt:     menu.SubmittedAt,
		ReviewedAt:      menu.ReviewedAt,
		RejectionReason: menu.RejectionReason,
	}

	respondWithJSON(w, http.StatusOK, response)
}

// SubmitMenu handles POST /api/v1/menus/{menu_id}/submit
func (h *MenuHandler) SubmitMenu(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	menuID := vars["menu_id"]

	err := h.menuRepo.Submit(menuID)
	if err != nil {
		if err.Error() == "menu must have at least 1 collection with at least 1 product" {
			respondWithError(w, http.StatusBadRequest, err.Error())
			return
		}
		if err.Error() == "menu not found or not in draft status" {
			respondWithError(w, http.StatusBadRequest, err.Error())
			return
		}
		respondWithError(w, http.StatusInternalServerError, "Failed to submit menu")
		return
	}

	menu, _ := h.menuRepo.GetByID(menuID)

	// Publish menu-submitted event to RabbitMQ
	ctx, cancel := context.WithTimeout(r.Context(), 5*time.Second)
	defer cancel()

	event := queue.MenuSubmittedEvent{
		MenuID:      menu.MenuID,
		LocationID:  menu.LocationID,
		SubmittedAt: *menu.SubmittedAt,
	}

	if err := h.queueClient.PublishMenuSubmitted(ctx, event); err != nil {
		log.Printf("⚠️  Failed to publish menu-submitted event: %v", err)
		// Don't fail the request - the menu is already submitted in the database
	}

	respondWithJSON(w, http.StatusOK, menu)
}

// GetCompleteMenu handles GET /api/v1/menus/{menu_id}
func (h *MenuHandler) GetCompleteMenu(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	menuID := vars["menu_id"]

	completeMenu, err := h.menuRetrievalRepo.GetCompleteMenu(menuID)
	if err != nil {
		if err.Error() == "menu not found" {
			respondWithError(w, http.StatusNotFound, "Menu not found")
			return
		}
		respondWithError(w, http.StatusInternalServerError, "Failed to get complete menu")
		return
	}

	respondWithJSON(w, http.StatusOK, completeMenu)
}

// UpdateMenuStatus handles PUT /internal/menus/{menu_id}/status (internal endpoint)
func (h *MenuHandler) UpdateMenuStatus(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	menuID := vars["menu_id"]

	var req models.UpdateStatusRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondWithError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	// Validate status
	validStatuses := map[string]bool{
		"draft":          true,
		"pending_review": true,
		"approved":       true,
		"rejected":       true,
		"active":         true,
	}
	if !validStatuses[req.Status] {
		respondWithError(w, http.StatusBadRequest, "Invalid status value")
		return
	}

	err := h.menuRepo.UpdateStatus(menuID, req.Status, req.RejectionReason)
	if err != nil {
		respondWithError(w, http.StatusInternalServerError, "Failed to update menu status")
		return
	}

	respondWithJSON(w, http.StatusOK, map[string]string{
		"message": "Menu status updated successfully",
		"status":  req.Status,
	})
}
