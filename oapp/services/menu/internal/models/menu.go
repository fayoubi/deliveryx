package models

import "time"

// Menu represents a menu
type Menu struct {
	MenuID         string     `json:"menu_id" db:"menu_id"`
	LocationID     string     `json:"location_id" db:"location_id"`
	Status         string     `json:"status" db:"status"`
	SubmittedAt    *time.Time `json:"submitted_at,omitempty" db:"submitted_at"`
	ReviewedAt     *time.Time `json:"reviewed_at,omitempty" db:"reviewed_at"`
	RejectionReason *string   `json:"rejection_reason,omitempty" db:"rejection_reason"`
	CreatedAt      time.Time  `json:"created_at" db:"created_at"`
	UpdatedAt      time.Time  `json:"updated_at" db:"updated_at"`
}

// CreateMenuRequest represents the request to create a menu
type CreateMenuRequest struct {
	LocationID string `json:"location_id" validate:"required"`
}

// MenuStatusResponse represents menu status information
type MenuStatusResponse struct {
	Status          string     `json:"status"`
	SubmittedAt     *time.Time `json:"submitted_at,omitempty"`
	ReviewedAt      *time.Time `json:"reviewed_at,omitempty"`
	RejectionReason *string    `json:"rejection_reason,omitempty"`
}

// UpdateStatusRequest represents the request to update menu status (internal use)
type UpdateStatusRequest struct {
	Status          string  `json:"status" validate:"required"`
	RejectionReason *string `json:"rejection_reason,omitempty"`
}
