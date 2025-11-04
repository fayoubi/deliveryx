package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/deliveryx/menu-service/internal/models"
	"github.com/deliveryx/menu-service/internal/repository"
	"github.com/gorilla/mux"
)

type ApprovalHandler struct {
	approvalRepo *repository.ApprovalRepository
	menuRepo     *repository.MenuRepository
}

func NewApprovalHandler(approvalRepo *repository.ApprovalRepository, menuRepo *repository.MenuRepository) *ApprovalHandler {
	return &ApprovalHandler{
		approvalRepo: approvalRepo,
		menuRepo:     menuRepo,
	}
}

// ApproveMenu handles POST /api/v1/menus/{menu_id}/approve
func (h *ApprovalHandler) ApproveMenu(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	menuID := vars["menu_id"]

	// Extract admin email from header (in production, this would come from auth middleware)
	adminEmail := r.Header.Get("X-Admin-Email")
	var adminEmailPtr *string
	if adminEmail != "" {
		adminEmailPtr = &adminEmail
	}

	// Update menu status to approved
	if err := h.menuRepo.UpdateStatus(menuID, "approved", nil); err != nil {
		respondWithError(w, http.StatusInternalServerError, err.Error())
		return
	}

	// Log approval action
	if err := h.approvalRepo.LogApproval(menuID, adminEmailPtr); err != nil {
		respondWithError(w, http.StatusInternalServerError, err.Error())
		return
	}

	respondWithJSON(w, http.StatusOK, map[string]string{
		"message": "Menu approved successfully",
		"menu_id": menuID,
		"status":  "approved",
	})
}

// RejectMenu handles POST /api/v1/menus/{menu_id}/reject
func (h *ApprovalHandler) RejectMenu(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	menuID := vars["menu_id"]

	// Parse request body
	var req models.RejectMenuRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondWithError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	// Validate rejection reason
	if req.RejectionReason == "" {
		respondWithError(w, http.StatusBadRequest, "Rejection reason is required")
		return
	}

	// Extract admin email from header
	adminEmail := r.Header.Get("X-Admin-Email")
	var adminEmailPtr *string
	if adminEmail != "" {
		adminEmailPtr = &adminEmail
	}

	// Update menu status to rejected
	if err := h.menuRepo.UpdateStatus(menuID, "rejected", &req.RejectionReason); err != nil {
		respondWithError(w, http.StatusInternalServerError, err.Error())
		return
	}

	// Log rejection action
	if err := h.approvalRepo.LogRejection(menuID, req.RejectionReason, adminEmailPtr); err != nil {
		respondWithError(w, http.StatusInternalServerError, err.Error())
		return
	}

	respondWithJSON(w, http.StatusOK, map[string]string{
		"message":          "Menu rejected successfully",
		"menu_id":          menuID,
		"status":           "rejected",
		"rejection_reason": req.RejectionReason,
	})
}

// GetApprovalHistory handles GET /api/v1/menus/{menu_id}/history
func (h *ApprovalHandler) GetApprovalHistory(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	menuID := vars["menu_id"]

	logs, err := h.approvalRepo.GetApprovalHistory(menuID)
	if err != nil {
		respondWithError(w, http.StatusInternalServerError, err.Error())
		return
	}

	respondWithJSON(w, http.StatusOK, logs)
}
