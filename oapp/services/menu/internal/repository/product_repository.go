package repository

import (
	"database/sql"
	"fmt"

	"github.com/deliveryx/menu-service/internal/models"
	"github.com/google/uuid"
)

type ProductRepository struct {
	db *sql.DB
}

func NewProductRepository(db *sql.DB) *ProductRepository {
	return &ProductRepository{db: db}
}

// Create creates a new product
func (r *ProductRepository) Create(locationID string, req *models.CreateProductRequest) (*models.ProductWithAttributes, error) {
	tx, err := r.db.Begin()
	if err != nil {
		return nil, fmt.Errorf("failed to begin transaction: %w", err)
	}
	defer tx.Rollback()

	productID := uuid.New().String()

	// Insert product
	query := `
		INSERT INTO products (product_id, location_id, name, description, price, category, image_url, is_available)
		VALUES ($1, $2, $3, $4, $5, $6, $7, true)
		RETURNING created_at, updated_at
	`

	product := &models.ProductWithAttributes{
		Product: models.Product{
			ProductID:   productID,
			LocationID:  locationID,
			Name:        req.Name,
			Description: req.Description,
			Price:       req.Price,
			Category:    req.Category,
			ImageURL:    req.ImageURL,
			IsAvailable: true,
		},
		AttributeGroupIDs: req.AttributeGroupIDs,
	}

	err = tx.QueryRow(query,
		productID, locationID, req.Name, req.Description, req.Price, req.Category, req.ImageURL,
	).Scan(&product.CreatedAt, &product.UpdatedAt)

	if err != nil {
		return nil, fmt.Errorf("failed to create product: %w", err)
	}

	// Insert product-attribute associations
	if len(req.AttributeGroupIDs) > 0 {
		for _, groupID := range req.AttributeGroupIDs {
			_, err = tx.Exec(
				"INSERT INTO product_attribute_groups (product_id, attribute_group_id) VALUES ($1, $2)",
				productID, groupID,
			)
			if err != nil {
				return nil, fmt.Errorf("failed to create product-attribute association: %w", err)
			}
		}
	}

	if err = tx.Commit(); err != nil {
		return nil, fmt.Errorf("failed to commit transaction: %w", err)
	}

	return product, nil
}

// GetByID retrieves a product by ID with its attribute groups
func (r *ProductRepository) GetByID(productID string) (*models.ProductWithAttributes, error) {
	product := &models.ProductWithAttributes{}

	query := `
		SELECT product_id, location_id, name, description, price, category, image_url, is_available, created_at, updated_at
		FROM products
		WHERE product_id = $1
	`

	err := r.db.QueryRow(query, productID).Scan(
		&product.ProductID,
		&product.LocationID,
		&product.Name,
		&product.Description,
		&product.Price,
		&product.Category,
		&product.ImageURL,
		&product.IsAvailable,
		&product.CreatedAt,
		&product.UpdatedAt,
	)

	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("product not found")
	}

	if err != nil {
		return nil, fmt.Errorf("failed to get product: %w", err)
	}

	// Get attribute groups
	rows, err := r.db.Query("SELECT attribute_group_id FROM product_attribute_groups WHERE product_id = $1", productID)
	if err != nil {
		return nil, fmt.Errorf("failed to get attribute groups: %w", err)
	}
	defer rows.Close()

	for rows.Next() {
		var groupID string
		if err := rows.Scan(&groupID); err != nil {
			return nil, fmt.Errorf("failed to scan attribute group: %w", err)
		}
		product.AttributeGroupIDs = append(product.AttributeGroupIDs, groupID)
	}

	return product, nil
}

// Update updates a product (only if not in any non-draft menus)
func (r *ProductRepository) Update(productID string, req *models.UpdateProductRequest) (*models.ProductWithAttributes, error) {
	// Check if product is in any non-draft menus (which would prevent updates)
	var hasNonDraftMenu bool
	err := r.db.QueryRow(`
		SELECT EXISTS(
			SELECT 1 FROM menu_products mp
			INNER JOIN menus m ON mp.menu_id = m.menu_id
			WHERE mp.product_id = $1 AND m.status != 'draft'
		)
	`, productID).Scan(&hasNonDraftMenu)

	if err != nil {
		return nil, fmt.Errorf("failed to check menu status: %w", err)
	}

	if hasNonDraftMenu {
		return nil, fmt.Errorf("product cannot be updated: menu is not in draft status")
	}

	tx, err := r.db.Begin()
	if err != nil {
		return nil, fmt.Errorf("failed to begin transaction: %w", err)
	}
	defer tx.Rollback()

	// Build dynamic update query
	query := "UPDATE products SET "
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

	if req.Price != nil {
		query += fmt.Sprintf("price = $%d, ", argCount)
		args = append(args, *req.Price)
		argCount++
	}

	if req.Category != nil {
		query += fmt.Sprintf("category = $%d, ", argCount)
		args = append(args, *req.Category)
		argCount++
	}

	if req.ImageURL != nil {
		query += fmt.Sprintf("image_url = $%d, ", argCount)
		args = append(args, *req.ImageURL)
		argCount++
	}

	// Remove trailing comma and space, add WHERE clause
	query = query[:len(query)-2] + fmt.Sprintf(" WHERE product_id = $%d", argCount)
	args = append(args, productID)

	_, err = tx.Exec(query, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to update product: %w", err)
	}

	// Update attribute groups if provided
	if req.AttributeGroupIDs != nil {
		// Delete existing associations
		_, err = tx.Exec("DELETE FROM product_attribute_groups WHERE product_id = $1", productID)
		if err != nil {
			return nil, fmt.Errorf("failed to delete attribute groups: %w", err)
		}

		// Insert new associations
		for _, groupID := range req.AttributeGroupIDs {
			_, err = tx.Exec(
				"INSERT INTO product_attribute_groups (product_id, attribute_group_id) VALUES ($1, $2)",
				productID, groupID,
			)
			if err != nil {
				return nil, fmt.Errorf("failed to create product-attribute association: %w", err)
			}
		}
	}

	if err = tx.Commit(); err != nil {
		return nil, fmt.Errorf("failed to commit transaction: %w", err)
	}

	return r.GetByID(productID)
}

// Delete deletes a product (only if menu is in draft status)
func (r *ProductRepository) Delete(productID string) error {
	// Check if product's menu is in draft status
	var isDraft bool
	err := r.db.QueryRow(`
		SELECT EXISTS(
			SELECT 1 FROM menu_products mp
			INNER JOIN menus m ON mp.menu_id = m.menu_id
			WHERE mp.product_id = $1 AND m.status = 'draft'
		)
	`, productID).Scan(&isDraft)

	if err != nil {
		return fmt.Errorf("failed to check menu status: %w", err)
	}

	if !isDraft {
		return fmt.Errorf("product cannot be deleted: menu is not in draft status")
	}

	result, err := r.db.Exec("DELETE FROM products WHERE product_id = $1", productID)
	if err != nil {
		return fmt.Errorf("failed to delete product: %w", err)
	}

	rows, _ := result.RowsAffected()
	if rows == 0 {
		return fmt.Errorf("product not found")
	}

	return nil
}

// ToggleAvailability toggles product availability (allowed even if menu is active)
func (r *ProductRepository) ToggleAvailability(productID string, isAvailable bool) error {
	result, err := r.db.Exec(
		"UPDATE products SET is_available = $1 WHERE product_id = $2",
		isAvailable, productID,
	)

	if err != nil {
		return fmt.Errorf("failed to toggle availability: %w", err)
	}

	rows, _ := result.RowsAffected()
	if rows == 0 {
		return fmt.Errorf("product not found")
	}

	return nil
}
