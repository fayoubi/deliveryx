package models

import "time"

// Store represents a restaurant store
type Store struct {
	StoreID     string    `json:"store_id" db:"store_id"`
	Name        string    `json:"name" db:"name"`
	Description *string   `json:"description,omitempty" db:"description"`
	LogoURL     *string   `json:"logo_url,omitempty" db:"logo_url"`
	Phone       string    `json:"phone" db:"phone"`
	CreatedAt   time.Time `json:"created_at" db:"created_at"`
	UpdatedAt   time.Time `json:"updated_at" db:"updated_at"`
}

// CreateStoreRequest represents the request body for creating a store
type CreateStoreRequest struct {
	Name        string  `json:"name" validate:"required,max=255"`
	Description *string `json:"description,omitempty" validate:"omitempty,max=1000"`
	LogoURL     *string `json:"logo_url,omitempty"`
	Phone       string  `json:"phone" validate:"required,max=20"`
}

// UpdateStoreRequest represents the request body for updating a store
type UpdateStoreRequest struct {
	Name        *string `json:"name,omitempty" validate:"omitempty,max=255"`
	Description *string `json:"description,omitempty" validate:"omitempty,max=1000"`
	LogoURL     *string `json:"logo_url,omitempty"`
	Phone       *string `json:"phone,omitempty" validate:"omitempty,max=20"`
}
