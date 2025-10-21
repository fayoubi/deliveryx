package repository

import (
	"database/sql"
	"fmt"

	"github.com/deliveryx/menu-service/internal/models"
)

type MenuProductRepository struct {
	db *sql.DB
}

func NewMenuProductRepository(db *sql.DB) *MenuProductRepository {
	return &MenuProductRepository{db: db}
}

// AddProduct adds a product to a menu
func (r *MenuProductRepository) AddProduct(menuID string, req *models.AddProductToMenuRequest) error {
	// Check if menu is in draft status
	var status string
	err := r.db.QueryRow("SELECT status FROM menus WHERE menu_id = $1", menuID).Scan(&status)
	if err == sql.ErrNoRows {
		return fmt.Errorf("menu not found")
	}
	if err != nil {
		return fmt.Errorf("failed to check menu status: %w", err)
	}

	if status != "draft" {
		return fmt.Errorf("menu is not in draft status")
	}

	// Validate product and collection exist
	var productExists, collectionExists bool
	r.db.QueryRow("SELECT EXISTS(SELECT 1 FROM products WHERE product_id = $1)", req.ProductID).Scan(&productExists)
	r.db.QueryRow("SELECT EXISTS(SELECT 1 FROM collections WHERE collection_id = $1)", req.CollectionID).Scan(&collectionExists)

	if !productExists {
		return fmt.Errorf("product not found")
	}
	if !collectionExists {
		return fmt.Errorf("collection not found")
	}

	// Check if product is already in menu
	var alreadyInMenu bool
	err = r.db.QueryRow(
		"SELECT EXISTS(SELECT 1 FROM menu_products WHERE menu_id = $1 AND product_id = $2)",
		menuID, req.ProductID,
	).Scan(&alreadyInMenu)

	if err != nil {
		return fmt.Errorf("failed to check if product already in menu: %w", err)
	}

	if alreadyInMenu {
		return fmt.Errorf("product already in menu")
	}

	query := `
		INSERT INTO menu_products (menu_id, product_id, collection_id, section_id, position)
		VALUES ($1, $2, $3, $4, $5)
	`

	_, err = r.db.Exec(query, menuID, req.ProductID, req.CollectionID, req.SectionID, req.Position)
	if err != nil {
		return fmt.Errorf("failed to add product to menu: %w", err)
	}

	return nil
}

// RemoveProduct removes a product from a menu
func (r *MenuProductRepository) RemoveProduct(menuID, productID string) error {
	// Check if menu is in draft status
	var status string
	err := r.db.QueryRow("SELECT status FROM menus WHERE menu_id = $1", menuID).Scan(&status)
	if err == sql.ErrNoRows {
		return fmt.Errorf("menu not found")
	}
	if err != nil {
		return fmt.Errorf("failed to check menu status: %w", err)
	}

	if status != "draft" {
		return fmt.Errorf("menu is not in draft status")
	}

	result, err := r.db.Exec(
		"DELETE FROM menu_products WHERE menu_id = $1 AND product_id = $2",
		menuID, productID,
	)

	if err != nil {
		return fmt.Errorf("failed to remove product from menu: %w", err)
	}

	rows, _ := result.RowsAffected()
	if rows == 0 {
		return fmt.Errorf("product not found in menu")
	}

	return nil
}

// ReorderProducts reorders products within a collection
func (r *MenuProductRepository) ReorderProducts(collectionID string, positions []models.ProductPosition) error {
	tx, err := r.db.Begin()
	if err != nil {
		return fmt.Errorf("failed to begin transaction: %w", err)
	}
	defer tx.Rollback()

	// Validate all product IDs belong to this collection
	for _, pos := range positions {
		var belongsToCollection bool
		err := tx.QueryRow(
			"SELECT EXISTS(SELECT 1 FROM menu_products WHERE product_id = $1 AND collection_id = $2)",
			pos.ProductID, collectionID,
		).Scan(&belongsToCollection)

		if err != nil {
			return fmt.Errorf("failed to validate product: %w", err)
		}

		if !belongsToCollection {
			return fmt.Errorf("product %s does not belong to collection", pos.ProductID)
		}
	}

	// Update positions
	for _, pos := range positions {
		_, err := tx.Exec(
			"UPDATE menu_products SET position = $1 WHERE product_id = $2 AND collection_id = $3",
			pos.Position, pos.ProductID, collectionID,
		)
		if err != nil {
			return fmt.Errorf("failed to update product position: %w", err)
		}
	}

	if err = tx.Commit(); err != nil {
		return fmt.Errorf("failed to commit transaction: %w", err)
	}

	return nil
}
