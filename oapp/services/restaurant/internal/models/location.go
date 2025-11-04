package models

import "time"

// Location represents a physical location for a store
type Location struct {
	LocationID      string   `json:"location_id" db:"location_id"`
	StoreID         string   `json:"store_id" db:"store_id"`
	Address         string   `json:"address" db:"address"`
	City            string   `json:"city" db:"city"`
	PostalCode      *string  `json:"postal_code,omitempty" db:"postal_code"`
	Phone           string   `json:"phone" db:"phone"`
	LocationManager *string  `json:"location_manager,omitempty" db:"location_manager"`
	Latitude        *float64 `json:"latitude,omitempty" db:"latitude"`
	Longitude       *float64 `json:"longitude,omitempty" db:"longitude"`
	CreatedAt       time.Time `json:"created_at" db:"created_at"`
	UpdatedAt       time.Time `json:"updated_at" db:"updated_at"`
}

// LocationWithHours represents a location with its operating hours
type LocationWithHours struct {
	Location
	OperatingHours []OperatingHour `json:"operating_hours"`
}

// CreateLocationRequest represents the request body for creating a location
type CreateLocationRequest struct {
	Address         string   `json:"address" validate:"required"`
	City            string   `json:"city" validate:"required,max=100"`
	PostalCode      *string  `json:"postal_code,omitempty" validate:"omitempty,max=20"`
	Phone           string   `json:"phone" validate:"required,max=20"`
	LocationManager *string  `json:"location_manager,omitempty" validate:"omitempty,max=255"`
	Latitude        *float64 `json:"latitude,omitempty"`
	Longitude       *float64 `json:"longitude,omitempty"`
}

// UpdateLocationRequest represents the request body for updating a location (partial update)
type UpdateLocationRequest struct {
	Address         *string  `json:"address,omitempty"`
	City            *string  `json:"city,omitempty" validate:"omitempty,max=100"`
	PostalCode      *string  `json:"postal_code,omitempty" validate:"omitempty,max=20"`
	Phone           *string  `json:"phone,omitempty" validate:"omitempty,max=20"`
	LocationManager *string  `json:"location_manager,omitempty" validate:"omitempty,max=255"`
	Latitude        *float64 `json:"latitude,omitempty"`
	Longitude       *float64 `json:"longitude,omitempty"`
}

// OperatingHour represents operating hours for a specific day
type OperatingHour struct {
	ID         string    `json:"id,omitempty" db:"id"`
	LocationID string    `json:"location_id" db:"location_id"`
	DayOfWeek  string    `json:"day_of_week" db:"day_of_week"`
	OpenTime   string    `json:"open_time" db:"open_time"`
	CloseTime  string    `json:"close_time" db:"close_time"`
	IsClosed   bool      `json:"is_closed" db:"is_closed"`
	CreatedAt  time.Time `json:"created_at,omitempty" db:"created_at"`
	UpdatedAt  time.Time `json:"updated_at,omitempty" db:"updated_at"`
}

// SetOperatingHoursRequest represents the request body for setting operating hours
type SetOperatingHoursRequest struct {
	Hours []OperatingHourInput `json:"hours" validate:"required,len=7,dive"`
}

// OperatingHourInput represents a single day's operating hours input
type OperatingHourInput struct {
	DayOfWeek string `json:"day_of_week" validate:"required,oneof=MONDAY TUESDAY WEDNESDAY THURSDAY FRIDAY SATURDAY SUNDAY"`
	OpenTime  string `json:"open_time" validate:"required_if=IsClosed false"`
	CloseTime string `json:"close_time" validate:"required_if=IsClosed false"`
	IsClosed  bool   `json:"is_closed"`
}
