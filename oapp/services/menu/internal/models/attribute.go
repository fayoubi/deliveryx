package models

import "time"

// AttributeGroup represents a group of attributes
type AttributeGroup struct {
	ID            string    `json:"id" db:"id"`
	Name          string    `json:"name" db:"name"`
	MinSelections int       `json:"min_selections" db:"min_selections"`
	MaxSelections int       `json:"max_selections" db:"max_selections"`
	IsRequired    bool      `json:"is_required" db:"is_required"`
	SystemDefined bool      `json:"system_defined" db:"system_defined"`
	CreatedAt     time.Time `json:"created_at" db:"created_at"`
	UpdatedAt     time.Time `json:"updated_at" db:"updated_at"`
}

// Attribute represents an attribute option within a group
type Attribute struct {
	ID               string    `json:"id" db:"id"`
	AttributeGroupID string    `json:"attribute_group_id" db:"attribute_group_id"`
	Name             string    `json:"name" db:"name"`
	PriceImpact      float64   `json:"price_impact" db:"price_impact"`
	IsDefault        bool      `json:"is_default" db:"is_default"`
	CreatedAt        time.Time `json:"created_at" db:"created_at"`
	UpdatedAt        time.Time `json:"updated_at" db:"updated_at"`
}
