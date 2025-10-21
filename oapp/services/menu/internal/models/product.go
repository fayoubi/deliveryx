package models

import "time"

// Product represents a menu product
type Product struct {
	ProductID   string   `json:"product_id" db:"product_id"`
	LocationID  string   `json:"location_id" db:"location_id"`
	Name        string   `json:"name" db:"name"`
	Description *string  `json:"description,omitempty" db:"description"`
	Price       float64  `json:"price" db:"price"`
	Category    *string  `json:"category,omitempty" db:"category"`
	ImageURL    *string  `json:"image_url,omitempty" db:"image_url"`
	IsAvailable bool     `json:"is_available" db:"is_available"`
	CreatedAt   time.Time `json:"created_at" db:"created_at"`
	UpdatedAt   time.Time `json:"updated_at" db:"updated_at"`
}

// ProductWithAttributes represents a product with its attribute groups
type ProductWithAttributes struct {
	Product
	AttributeGroupIDs []string `json:"attribute_group_ids,omitempty"`
}

// CreateProductRequest represents the request to create a product
type CreateProductRequest struct {
	Name              string   `json:"name" validate:"required,max=255"`
	Description       *string  `json:"description,omitempty"`
	Price             float64  `json:"price" validate:"required,gt=0"`
	Category          *string  `json:"category,omitempty" validate:"omitempty,max=100"`
	ImageURL          *string  `json:"image_url,omitempty"`
	AttributeGroupIDs []string `json:"attribute_group_ids,omitempty"`
}

// UpdateProductRequest represents the request to update a product
type UpdateProductRequest struct {
	Name              *string  `json:"name,omitempty" validate:"omitempty,max=255"`
	Description       *string  `json:"description,omitempty"`
	Price             *float64 `json:"price,omitempty" validate:"omitempty,gt=0"`
	Category          *string  `json:"category,omitempty" validate:"omitempty,max=100"`
	ImageURL          *string  `json:"image_url,omitempty"`
	AttributeGroupIDs []string `json:"attribute_group_ids,omitempty"`
}

// ToggleAvailabilityRequest represents the request to toggle product availability
type ToggleAvailabilityRequest struct {
	IsAvailable bool `json:"is_available"`
}
