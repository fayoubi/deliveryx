package models

import "time"

// ApprovalLog represents an approval/rejection log entry
type ApprovalLog struct {
	ID              string    `json:"id" db:"id"`
	MenuID          string    `json:"menu_id" db:"menu_id"`
	Action          string    `json:"action" db:"action"`
	AdminID         *string   `json:"admin_id,omitempty" db:"admin_id"`
	AdminEmail      *string   `json:"admin_email,omitempty" db:"admin_email"`
	RejectionReason *string   `json:"rejection_reason,omitempty" db:"rejection_reason"`
	CreatedAt       time.Time `json:"created_at" db:"created_at"`
}

// ApproveMenuRequest represents the request to approve a menu
type ApproveMenuRequest struct {
	Notes string `json:"notes,omitempty"`
}

// RejectMenuRequest represents the request to reject a menu
type RejectMenuRequest struct {
	RejectionReason string `json:"rejection_reason" validate:"required"`
	Notes           string `json:"notes,omitempty"`
}
