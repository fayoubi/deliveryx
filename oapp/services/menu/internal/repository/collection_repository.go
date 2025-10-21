package repository

import (
	"database/sql"
	"fmt"

	"github.com/deliveryx/menu-service/internal/models"
	"github.com/google/uuid"
)

type CollectionRepository struct {
	db *sql.DB
}

func NewCollectionRepository(db *sql.DB) *CollectionRepository {
	return &CollectionRepository{db: db}
}

// Create creates a new collection
func (r *CollectionRepository) Create(menuID string, req *models.CreateCollectionRequest) (*models.Collection, error) {
	// Check if menu is in draft status
	var status string
	err := r.db.QueryRow("SELECT status FROM menus WHERE menu_id = $1", menuID).Scan(&status)
	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("menu not found")
	}
	if err != nil {
		return nil, fmt.Errorf("failed to check menu status: %w", err)
	}

	if status != "draft" {
		return nil, fmt.Errorf("menu is not in draft status")
	}

	collection := &models.Collection{
		CollectionID: uuid.New().String(),
		MenuID:       menuID,
		Name:         req.Name,
		Position:     req.Position,
		ImageURL:     req.ImageURL,
	}

	query := `
		INSERT INTO collections (collection_id, menu_id, name, position, image_url)
		VALUES ($1, $2, $3, $4, $5)
		RETURNING created_at, updated_at
	`

	err = r.db.QueryRow(query,
		collection.CollectionID,
		collection.MenuID,
		collection.Name,
		collection.Position,
		collection.ImageURL,
	).Scan(&collection.CreatedAt, &collection.UpdatedAt)

	if err != nil {
		return nil, fmt.Errorf("failed to create collection: %w", err)
	}

	return collection, nil
}

// Delete deletes a collection
func (r *CollectionRepository) Delete(collectionID string) error {
	// Check if menu is in draft status
	var status string
	err := r.db.QueryRow(`
		SELECT m.status FROM menus m
		INNER JOIN collections c ON m.menu_id = c.menu_id
		WHERE c.collection_id = $1
	`, collectionID).Scan(&status)

	if err == sql.ErrNoRows {
		return fmt.Errorf("collection not found")
	}
	if err != nil {
		return fmt.Errorf("failed to check menu status: %w", err)
	}

	if status != "draft" {
		return fmt.Errorf("menu is not in draft status")
	}

	result, err := r.db.Exec("DELETE FROM collections WHERE collection_id = $1", collectionID)
	if err != nil {
		return fmt.Errorf("failed to delete collection: %w", err)
	}

	rows, _ := result.RowsAffected()
	if rows == 0 {
		return fmt.Errorf("collection not found")
	}

	return nil
}

// Reorder reorders collections in a menu
func (r *CollectionRepository) Reorder(menuID string, positions []models.CollectionPosition) error {
	tx, err := r.db.Begin()
	if err != nil {
		return fmt.Errorf("failed to begin transaction: %w", err)
	}
	defer tx.Rollback()

	// Validate all collection IDs belong to this menu
	for _, pos := range positions {
		var belongsToMenu bool
		err := tx.QueryRow(
			"SELECT EXISTS(SELECT 1 FROM collections WHERE collection_id = $1 AND menu_id = $2)",
			pos.CollectionID, menuID,
		).Scan(&belongsToMenu)

		if err != nil {
			return fmt.Errorf("failed to validate collection: %w", err)
		}

		if !belongsToMenu {
			return fmt.Errorf("collection %s does not belong to menu", pos.CollectionID)
		}
	}

	// Update positions
	for _, pos := range positions {
		_, err := tx.Exec(
			"UPDATE collections SET position = $1 WHERE collection_id = $2",
			pos.Position, pos.CollectionID,
		)
		if err != nil {
			return fmt.Errorf("failed to update collection position: %w", err)
		}
	}

	if err = tx.Commit(); err != nil {
		return fmt.Errorf("failed to commit transaction: %w", err)
	}

	return nil
}

// GetByMenuID retrieves all collections for a menu
func (r *CollectionRepository) GetByMenuID(menuID string) ([]models.Collection, error) {
	query := `
		SELECT collection_id, menu_id, name, position, image_url, created_at, updated_at
		FROM collections
		WHERE menu_id = $1
		ORDER BY position
	`

	rows, err := r.db.Query(query, menuID)
	if err != nil {
		return nil, fmt.Errorf("failed to get collections: %w", err)
	}
	defer rows.Close()

	collections := []models.Collection{}
	for rows.Next() {
		var collection models.Collection
		err := rows.Scan(
			&collection.CollectionID,
			&collection.MenuID,
			&collection.Name,
			&collection.Position,
			&collection.ImageURL,
			&collection.CreatedAt,
			&collection.UpdatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to scan collection: %w", err)
		}
		collections = append(collections, collection)
	}

	return collections, nil
}
