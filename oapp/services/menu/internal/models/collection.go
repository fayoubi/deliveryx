package models

import "time"

// Collection represents a menu collection (category)
type Collection struct {
	CollectionID string    `json:"collection_id" db:"collection_id"`
	MenuID       string    `json:"menu_id" db:"menu_id"`
	Name         string    `json:"name" db:"name"`
	Position     int       `json:"position" db:"position"`
	ImageURL     *string   `json:"image_url,omitempty" db:"image_url"`
	CreatedAt    time.Time `json:"created_at" db:"created_at"`
	UpdatedAt    time.Time `json:"updated_at" db:"updated_at"`
}

// CreateCollectionRequest represents the request to create a collection
type CreateCollectionRequest struct {
	Name     string  `json:"name" validate:"required,oneof=Pizzas Burgers Sides Desserts Drinks Salads Breakfast Sandwiches Pasta Seafood"`
	Position int     `json:"position" validate:"min=0"`
	ImageURL *string `json:"image_url,omitempty"`
}

// ReorderCollectionsRequest represents the request to reorder collections
type ReorderCollectionsRequest struct {
	Collections []CollectionPosition `json:"collections" validate:"required,dive"`
}

// CollectionPosition represents a collection ID and its new position
type CollectionPosition struct {
	CollectionID string `json:"collection_id" validate:"required"`
	Position     int    `json:"position" validate:"min=0"`
}
