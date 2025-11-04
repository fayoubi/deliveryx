package repository

import (
	"database/sql"
	"fmt"
	"time"

	"github.com/deliveryx/menu-service/internal/models"
	"github.com/google/uuid"
)

type MenuRepository struct {
	db *sql.DB
}

func NewMenuRepository(db *sql.DB) *MenuRepository {
	return &MenuRepository{db: db}
}

// Create creates a new draft menu
func (r *MenuRepository) Create(locationID string) (*models.Menu, error) {
	// Check if menu already exists for this location
	var exists bool
	err := r.db.QueryRow("SELECT EXISTS(SELECT 1 FROM menus WHERE location_id = $1)", locationID).Scan(&exists)
	if err != nil {
		return nil, fmt.Errorf("failed to check existing menu: %w", err)
	}
	if exists {
		return nil, fmt.Errorf("menu already exists for this location")
	}

	menu := &models.Menu{
		MenuID:     uuid.New().String(),
		LocationID: locationID,
		Status:     "draft",
	}

	query := `
		INSERT INTO menus (menu_id, location_id, status)
		VALUES ($1, $2, $3)
		RETURNING created_at, updated_at
	`

	err = r.db.QueryRow(query, menu.MenuID, menu.LocationID, menu.Status).
		Scan(&menu.CreatedAt, &menu.UpdatedAt)

	if err != nil {
		return nil, fmt.Errorf("failed to create menu: %w", err)
	}

	return menu, nil
}

// GetByID retrieves a menu by ID
func (r *MenuRepository) GetByID(menuID string) (*models.Menu, error) {
	menu := &models.Menu{}

	query := `
		SELECT menu_id, location_id, status, submitted_at, reviewed_at, rejection_reason, created_at, updated_at
		FROM menus
		WHERE menu_id = $1
	`

	err := r.db.QueryRow(query, menuID).Scan(
		&menu.MenuID,
		&menu.LocationID,
		&menu.Status,
		&menu.SubmittedAt,
		&menu.ReviewedAt,
		&menu.RejectionReason,
		&menu.CreatedAt,
		&menu.UpdatedAt,
	)

	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("menu not found")
	}

	if err != nil {
		return nil, fmt.Errorf("failed to get menu: %w", err)
	}

	return menu, nil
}

// Submit submits a menu for review
func (r *MenuRepository) Submit(menuID string) error {
	// Check if menu has at least 1 collection with at least 1 product
	var hasProducts bool
	err := r.db.QueryRow(`
		SELECT EXISTS(
			SELECT 1 FROM collections c
			INNER JOIN menu_products mp ON c.collection_id = mp.collection_id
			WHERE c.menu_id = $1
		)
	`, menuID).Scan(&hasProducts)

	if err != nil {
		return fmt.Errorf("failed to validate menu: %w", err)
	}

	if !hasProducts {
		return fmt.Errorf("menu must have at least 1 collection with at least 1 product")
	}

	now := time.Now()
	query := `
		UPDATE menus
		SET status = 'pending_review', submitted_at = $1
		WHERE menu_id = $2 AND status = 'draft'
	`

	result, err := r.db.Exec(query, now, menuID)
	if err != nil {
		return fmt.Errorf("failed to submit menu: %w", err)
	}

	rows, _ := result.RowsAffected()
	if rows == 0 {
		return fmt.Errorf("menu not found or not in draft status")
	}

	// TODO: Publish event to message queue for Approval Service

	return nil
}

// UpdateStatus updates menu status (for approval service)
func (r *MenuRepository) UpdateStatus(menuID, status string, rejectionReason *string) error {
	now := time.Now()

	// For internal use, allow any status transition
	// For approval/rejection, typically called from approval service
	query := `
		UPDATE menus
		SET status = $1, reviewed_at = $2, rejection_reason = $3
		WHERE menu_id = $4
	`

	result, err := r.db.Exec(query, status, now, rejectionReason, menuID)
	if err != nil {
		return fmt.Errorf("failed to update menu status: %w", err)
	}

	rows, _ := result.RowsAffected()
	if rows == 0 {
		return fmt.Errorf("menu not found")
	}

	return nil
}

// CountByLocation counts the number of menus for a given location
func (r *MenuRepository) CountByLocation(locationID string) (int, error) {
	var count int
	query := `SELECT COUNT(*) FROM menus WHERE location_id = $1`
	err := r.db.QueryRow(query, locationID).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("failed to count menus: %w", err)
	}
	return count, nil
}
