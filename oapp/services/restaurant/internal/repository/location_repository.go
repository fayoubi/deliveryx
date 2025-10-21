package repository

import (
	"database/sql"
	"fmt"

	"github.com/deliveryx/restaurant-service/internal/models"
	"github.com/google/uuid"
)

type LocationRepository struct {
	db *sql.DB
}

func NewLocationRepository(db *sql.DB) *LocationRepository {
	return &LocationRepository{db: db}
}

// Create creates a new location
func (r *LocationRepository) Create(storeID string, req *models.CreateLocationRequest) (*models.Location, error) {
	location := &models.Location{
		LocationID:      uuid.New().String(),
		StoreID:         storeID,
		Address:         req.Address,
		City:            req.City,
		PostalCode:      req.PostalCode,
		Phone:           req.Phone,
		LocationManager: req.LocationManager,
		Latitude:        req.Latitude,
		Longitude:       req.Longitude,
	}

	query := `
		INSERT INTO locations (location_id, store_id, address, city, postal_code, phone, location_manager, latitude, longitude)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
		RETURNING created_at, updated_at
	`

	err := r.db.QueryRow(
		query,
		location.LocationID,
		location.StoreID,
		location.Address,
		location.City,
		location.PostalCode,
		location.Phone,
		location.LocationManager,
		location.Latitude,
		location.Longitude,
	).Scan(&location.CreatedAt, &location.UpdatedAt)

	if err != nil {
		return nil, fmt.Errorf("failed to create location: %w", err)
	}

	return location, nil
}

// GetByID retrieves a location by ID
func (r *LocationRepository) GetByID(locationID string) (*models.Location, error) {
	location := &models.Location{}

	query := `
		SELECT location_id, store_id, address, city, postal_code, phone,
		       location_manager, latitude, longitude, created_at, updated_at
		FROM locations
		WHERE location_id = $1
	`

	err := r.db.QueryRow(query, locationID).Scan(
		&location.LocationID,
		&location.StoreID,
		&location.Address,
		&location.City,
		&location.PostalCode,
		&location.Phone,
		&location.LocationManager,
		&location.Latitude,
		&location.Longitude,
		&location.CreatedAt,
		&location.UpdatedAt,
	)

	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("location not found")
	}

	if err != nil {
		return nil, fmt.Errorf("failed to get location: %w", err)
	}

	return location, nil
}

// SetOperatingHours sets operating hours for a location (replaces all existing)
func (r *LocationRepository) SetOperatingHours(locationID string, hours []models.OperatingHourInput) error {
	tx, err := r.db.Begin()
	if err != nil {
		return fmt.Errorf("failed to begin transaction: %w", err)
	}
	defer tx.Rollback()

	// Delete existing operating hours
	_, err = tx.Exec("DELETE FROM operating_hours WHERE location_id = $1", locationID)
	if err != nil {
		return fmt.Errorf("failed to delete existing operating hours: %w", err)
	}

	// Insert new operating hours
	insertQuery := `
		INSERT INTO operating_hours (id, location_id, day_of_week, open_time, close_time, is_closed)
		VALUES ($1, $2, $3, $4, $5, $6)
	`

	for _, hour := range hours {
		_, err = tx.Exec(
			insertQuery,
			uuid.New().String(),
			locationID,
			hour.DayOfWeek,
			hour.OpenTime,
			hour.CloseTime,
			hour.IsClosed,
		)
		if err != nil {
			return fmt.Errorf("failed to insert operating hour: %w", err)
		}
	}

	if err = tx.Commit(); err != nil {
		return fmt.Errorf("failed to commit transaction: %w", err)
	}

	return nil
}

// GetOperatingHours retrieves operating hours for a location
func (r *LocationRepository) GetOperatingHours(locationID string) ([]models.OperatingHour, error) {
	query := `
		SELECT id, location_id, day_of_week, open_time, close_time, is_closed, created_at, updated_at
		FROM operating_hours
		WHERE location_id = $1
		ORDER BY
			CASE day_of_week
				WHEN 'MONDAY' THEN 1
				WHEN 'TUESDAY' THEN 2
				WHEN 'WEDNESDAY' THEN 3
				WHEN 'THURSDAY' THEN 4
				WHEN 'FRIDAY' THEN 5
				WHEN 'SATURDAY' THEN 6
				WHEN 'SUNDAY' THEN 7
			END
	`

	rows, err := r.db.Query(query, locationID)
	if err != nil {
		return nil, fmt.Errorf("failed to get operating hours: %w", err)
	}
	defer rows.Close()

	hours := []models.OperatingHour{}
	for rows.Next() {
		var hour models.OperatingHour
		err := rows.Scan(
			&hour.ID,
			&hour.LocationID,
			&hour.DayOfWeek,
			&hour.OpenTime,
			&hour.CloseTime,
			&hour.IsClosed,
			&hour.CreatedAt,
			&hour.UpdatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to scan operating hour: %w", err)
		}
		hours = append(hours, hour)
	}

	return hours, nil
}
