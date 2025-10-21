package models

import "time"

// MenuProduct represents the association between a menu and a product
type MenuProduct struct {
	MenuID       string    `json:"menu_id" db:"menu_id"`
	ProductID    string    `json:"product_id" db:"product_id"`
	CollectionID string    `json:"collection_id" db:"collection_id"`
	SectionID    *string   `json:"section_id,omitempty" db:"section_id"`
	Position     int       `json:"position" db:"position"`
	CreatedAt    time.Time `json:"created_at" db:"created_at"`
}

// AddProductToMenuRequest represents the request to add a product to a menu
type AddProductToMenuRequest struct {
	ProductID    string  `json:"product_id" validate:"required"`
	CollectionID string  `json:"collection_id" validate:"required"`
	SectionID    *string `json:"section_id,omitempty"`
	Position     int     `json:"position" validate:"min=0"`
}

// ReorderProductsRequest represents the request to reorder products in a collection
type ReorderProductsRequest struct {
	Products []ProductPosition `json:"products" validate:"required,dive"`
}

// ProductPosition represents a product ID and its new position
type ProductPosition struct {
	ProductID string `json:"product_id" validate:"required"`
	Position  int    `json:"position" validate:"min=0"`
}
