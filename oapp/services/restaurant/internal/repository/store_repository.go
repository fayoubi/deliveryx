package repository

import (
	"database/sql"
	"fmt"

	"github.com/deliveryx/restaurant-service/internal/models"
	"github.com/google/uuid"
)

type StoreRepository struct {
	db *sql.DB
}

func NewStoreRepository(db *sql.DB) *StoreRepository {
	return &StoreRepository{db: db}
}

// Create creates a new store
func (r *StoreRepository) Create(req *models.CreateStoreRequest) (*models.Store, error) {
	store := &models.Store{
		StoreID:     uuid.New().String(),
		Name:        req.Name,
		Description: req.Description,
		LogoURL:     req.LogoURL,
		Phone:       req.Phone,
	}

	query := `
		INSERT INTO stores (store_id, name, description, logo_url, phone)
		VALUES ($1, $2, $3, $4, $5)
		RETURNING created_at, updated_at
	`

	err := r.db.QueryRow(
		query,
		store.StoreID,
		store.Name,
		store.Description,
		store.LogoURL,
		store.Phone,
	).Scan(&store.CreatedAt, &store.UpdatedAt)

	if err != nil {
		return nil, fmt.Errorf("failed to create store: %w", err)
	}

	return store, nil
}

// GetByID retrieves a store by ID
func (r *StoreRepository) GetByID(storeID string) (*models.Store, error) {
	store := &models.Store{}

	query := `
		SELECT store_id, name, description, logo_url, phone, created_at, updated_at
		FROM stores
		WHERE store_id = $1
	`

	err := r.db.QueryRow(query, storeID).Scan(
		&store.StoreID,
		&store.Name,
		&store.Description,
		&store.LogoURL,
		&store.Phone,
		&store.CreatedAt,
		&store.UpdatedAt,
	)

	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("store not found")
	}

	if err != nil {
		return nil, fmt.Errorf("failed to get store: %w", err)
	}

	return store, nil
}

// Update updates a store
func (r *StoreRepository) Update(storeID string, req *models.UpdateStoreRequest) (*models.Store, error) {
	// First check if store exists
	store, err := r.GetByID(storeID)
	if err != nil {
		return nil, err
	}

	// Build dynamic update query
	query := `UPDATE stores SET `
	args := []interface{}{}
	argCount := 1

	if req.Name != nil {
		query += fmt.Sprintf("name = $%d, ", argCount)
		args = append(args, *req.Name)
		argCount++
	}

	if req.Description != nil {
		query += fmt.Sprintf("description = $%d, ", argCount)
		args = append(args, *req.Description)
		argCount++
	}

	if req.LogoURL != nil {
		query += fmt.Sprintf("logo_url = $%d, ", argCount)
		args = append(args, *req.LogoURL)
		argCount++
	}

	if req.Phone != nil {
		query += fmt.Sprintf("phone = $%d, ", argCount)
		args = append(args, *req.Phone)
		argCount++
	}

	// Remove trailing comma and space, add WHERE clause
	query = query[:len(query)-2] + fmt.Sprintf(" WHERE store_id = $%d RETURNING name, description, logo_url, phone, created_at, updated_at", argCount)
	args = append(args, storeID)

	err = r.db.QueryRow(query, args...).Scan(
		&store.Name,
		&store.Description,
		&store.LogoURL,
		&store.Phone,
		&store.CreatedAt,
		&store.UpdatedAt,
	)

	if err != nil {
		return nil, fmt.Errorf("failed to update store: %w", err)
	}

	return store, nil
}
