package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/deliveryx/approval-service/internal/client"
	"github.com/deliveryx/approval-service/internal/models"
	"github.com/deliveryx/approval-service/internal/repository"
	"github.com/gorilla/mux"
)

type ApprovalHandler struct {
	approvalRepo *repository.ApprovalRepository
	menuClient   *client.MenuClient
}

func NewApprovalHandler(approvalRepo *repository.ApprovalRepository, menuClient *client.MenuClient) *ApprovalHandler {
	return &ApprovalHandler{
		approvalRepo: approvalRepo,
		menuClient:   menuClient,
	}
}

// ApproveMenu handles menu approval
func (h *ApprovalHandler) ApproveMenu(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	menuID := vars["menu_id"]

	// Extract admin email from header (in production, this would come from auth middleware)
	adminEmail := r.Header.Get("X-Admin-Email")
	var adminEmailPtr *string
	if adminEmail != "" {
		adminEmailPtr = &adminEmail
	}

	// Update menu status in Menu Service
	if err := h.menuClient.UpdateMenuStatus(menuID, "approved", nil); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	// Log approval action
	if err := h.approvalRepo.LogApproval(menuID, adminEmailPtr); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{
		"message": "Menu approved successfully",
		"menu_id": menuID,
		"status":  "approved",
	})
}

// RejectMenu handles menu rejection
func (h *ApprovalHandler) RejectMenu(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	menuID := vars["menu_id"]

	// Parse request body
	var req models.RejectMenuRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// Validate rejection reason
	if req.RejectionReason == "" {
		http.Error(w, "Rejection reason is required", http.StatusBadRequest)
		return
	}

	// Extract admin email from header
	adminEmail := r.Header.Get("X-Admin-Email")
	var adminEmailPtr *string
	if adminEmail != "" {
		adminEmailPtr = &adminEmail
	}

	// Update menu status in Menu Service
	if err := h.menuClient.UpdateMenuStatus(menuID, "rejected", &req.RejectionReason); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	// Log rejection action
	if err := h.approvalRepo.LogRejection(menuID, req.RejectionReason, adminEmailPtr); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{
		"message":          "Menu rejected successfully",
		"menu_id":          menuID,
		"status":           "rejected",
		"rejection_reason": req.RejectionReason,
	})
}

// GetApprovalHistory returns approval history for a menu
func (h *ApprovalHandler) GetApprovalHistory(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	menuID := vars["menu_id"]

	logs, err := h.approvalRepo.GetApprovalHistory(menuID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(logs)
}
