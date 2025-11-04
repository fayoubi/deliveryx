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

// List retrieves a paginated, filtered, and sorted list of locations for a store
func (r *LocationRepository) List(storeID string, filters FilterParams, pagination PaginationParams, sort SortParams) ([]models.Location, int, error) {
	// Build query arguments
	args := []interface{}{}

	// Build WHERE clause (includes store_id filter)
	whereClause := BuildWhereClauseLocations(storeID, filters, &args)

	// Count total for pagination
	countQuery := "SELECT COUNT(*) FROM locations" + whereClause
	var total int
	err := r.db.QueryRow(countQuery, args...).Scan(&total)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to count locations: %w", err)
	}

	// Build ORDER BY clause with tie-breaker
	orderByClause := BuildOrderByClause(sort, "address")

	// Build pagination clause
	paginationClause := BuildPaginationClause(pagination)

	// Build full query
	query := `
		SELECT location_id, store_id, address, city, postal_code, phone,
		       location_manager, latitude, longitude, created_at, updated_at
		FROM locations
	` + whereClause + orderByClause + paginationClause

	rows, err := r.db.Query(query, args...)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to list locations: %w", err)
	}
	defer rows.Close()

	locations := []models.Location{}
	for rows.Next() {
		var location models.Location
		err := rows.Scan(
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
		if err != nil {
			return nil, 0, fmt.Errorf("failed to scan location: %w", err)
		}
		locations = append(locations, location)
	}

	return locations, total, nil
}

// Update updates a location (partial update)
func (r *LocationRepository) Update(locationID string, req *models.UpdateLocationRequest) (*models.Location, error) {
	// First check if location exists
	location, err := r.GetByID(locationID)
	if err != nil {
		return nil, err
	}

	// Build dynamic update query
	query := `UPDATE locations SET `
	args := []interface{}{}
	argCount := 1

	if req.Address != nil {
		query += fmt.Sprintf("address = $%d, ", argCount)
		args = append(args, *req.Address)
		argCount++
	}

	if req.City != nil {
		query += fmt.Sprintf("city = $%d, ", argCount)
		args = append(args, *req.City)
		argCount++
	}

	if req.PostalCode != nil {
		query += fmt.Sprintf("postal_code = $%d, ", argCount)
		args = append(args, *req.PostalCode)
		argCount++
	}

	if req.Phone != nil {
		query += fmt.Sprintf("phone = $%d, ", argCount)
		args = append(args, *req.Phone)
		argCount++
	}

	if req.LocationManager != nil {
		query += fmt.Sprintf("location_manager = $%d, ", argCount)
		args = append(args, *req.LocationManager)
		argCount++
	}

	if req.Latitude != nil {
		query += fmt.Sprintf("latitude = $%d, ", argCount)
		args = append(args, *req.Latitude)
		argCount++
	}

	if req.Longitude != nil {
		query += fmt.Sprintf("longitude = $%d, ", argCount)
		args = append(args, *req.Longitude)
		argCount++
	}

	// Remove trailing comma and space, add WHERE clause
	query = query[:len(query)-2] + fmt.Sprintf(" WHERE location_id = $%d RETURNING address, city, postal_code, phone, location_manager, latitude, longitude, created_at, updated_at", argCount)
	args = append(args, locationID)

	err = r.db.QueryRow(query, args...).Scan(
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

	if err != nil {
		return nil, fmt.Errorf("failed to update location: %w", err)
	}

	return location, nil
}

// Delete deletes a location (should be called after checking for menus via menu service)
func (r *LocationRepository) Delete(locationID string) error {
	query := "DELETE FROM locations WHERE location_id = $1"
	result, err := r.db.Exec(query, locationID)
	if err != nil {
		return fmt.Errorf("failed to delete location: %w", err)
	}

	rows, _ := result.RowsAffected()
	if rows == 0 {
		return fmt.Errorf("location not found")
	}

	return nil
}
