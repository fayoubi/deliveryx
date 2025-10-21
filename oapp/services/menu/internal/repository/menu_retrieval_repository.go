package repository

import (
	"database/sql"
	"fmt"

	"github.com/deliveryx/menu-service/internal/models"
)

type MenuRetrievalRepository struct {
	db *sql.DB
}

func NewMenuRetrievalRepository(db *sql.DB) *MenuRetrievalRepository {
	return &MenuRetrievalRepository{db: db}
}

// GetCompleteMenu retrieves the complete menu structure
func (r *MenuRetrievalRepository) GetCompleteMenu(menuID string) (*models.CompleteMenuResponse, error) {
	// Check if menu exists
	var exists bool
	err := r.db.QueryRow("SELECT EXISTS(SELECT 1 FROM menus WHERE menu_id = $1)", menuID).Scan(&exists)
	if err != nil {
		return nil, fmt.Errorf("failed to check menu existence: %w", err)
	}
	if !exists {
		return nil, fmt.Errorf("menu not found")
	}

	response := &models.CompleteMenuResponse{
		Supercollections: []interface{}{},
		Packs:            []interface{}{},
	}

	// Get all attributes
	attributes, err := r.getAllAttributes()
	if err != nil {
		return nil, err
	}
	response.Attributes = attributes

	// Get all attribute groups with their attribute IDs
	attributeGroups, err := r.getAllAttributeGroups()
	if err != nil {
		return nil, err
	}
	response.AttributeGroups = attributeGroups

	// Get all products in the menu
	products, err := r.getMenuProducts(menuID)
	if err != nil {
		return nil, err
	}
	response.Products = products

	// Get all collections with their products
	collections, err := r.getMenuCollections(menuID)
	if err != nil {
		return nil, err
	}
	response.Collections = collections

	return response, nil
}

func (r *MenuRetrievalRepository) getAllAttributes() ([]models.MenuAttribute, error) {
	query := `
		SELECT id, name, price_impact, is_default
		FROM attributes
		ORDER BY attribute_group_id, name
	`

	rows, err := r.db.Query(query)
	if err != nil {
		return nil, fmt.Errorf("failed to get attributes: %w", err)
	}
	defer rows.Close()

	var attributes []models.MenuAttribute
	for rows.Next() {
		var attr models.MenuAttribute
		err := rows.Scan(&attr.ID, &attr.Name, &attr.PriceImpact, &attr.SelectedByDefault)
		if err != nil {
			return nil, fmt.Errorf("failed to scan attribute: %w", err)
		}
		attr.Available = true // Default to true
		attributes = append(attributes, attr)
	}

	return attributes, nil
}

func (r *MenuRetrievalRepository) getAllAttributeGroups() ([]models.MenuAttributeGroup, error) {
	query := `
		SELECT id, name, min_selections, max_selections
		FROM attribute_groups
		ORDER BY name
	`

	rows, err := r.db.Query(query)
	if err != nil {
		return nil, fmt.Errorf("failed to get attribute groups: %w", err)
	}
	defer rows.Close()

	var groups []models.MenuAttributeGroup
	for rows.Next() {
		var group models.MenuAttributeGroup
		err := rows.Scan(&group.ID, &group.Name, &group.Min, &group.Max)
		if err != nil {
			return nil, fmt.Errorf("failed to scan attribute group: %w", err)
		}

		// Set collapse and multiple_selection based on max
		group.Collapse = false
		group.MultipleSelection = group.Max > 1

		// Get attribute IDs for this group
		attrQuery := `SELECT id FROM attributes WHERE attribute_group_id = $1 ORDER BY name`
		attrRows, err := r.db.Query(attrQuery, group.ID)
		if err != nil {
			return nil, fmt.Errorf("failed to get attributes for group: %w", err)
		}

		var attrIDs []string
		for attrRows.Next() {
			var attrID string
			if err := attrRows.Scan(&attrID); err != nil {
				attrRows.Close()
				return nil, fmt.Errorf("failed to scan attribute ID: %w", err)
			}
			attrIDs = append(attrIDs, attrID)
		}
		attrRows.Close()

		group.Attributes = attrIDs
		groups = append(groups, group)
	}

	return groups, nil
}

func (r *MenuRetrievalRepository) getMenuProducts(menuID string) ([]models.MenuProductItem, error) {
	query := `
		SELECT DISTINCT p.product_id, p.name, p.price, p.image_url, p.description, p.is_available
		FROM products p
		INNER JOIN menu_products mp ON p.product_id = mp.product_id
		WHERE mp.menu_id = $1
		ORDER BY p.name
	`

	rows, err := r.db.Query(query, menuID)
	if err != nil {
		return nil, fmt.Errorf("failed to get products: %w", err)
	}
	defer rows.Close()

	var products []models.MenuProductItem
	for rows.Next() {
		var product models.MenuProductItem
		err := rows.Scan(&product.ID, &product.Name, &product.Price, &product.ImageURL, &product.Description, &product.Available)
		if err != nil {
			return nil, fmt.Errorf("failed to scan product: %w", err)
		}

		// Get attribute group IDs for this product
		agQuery := `SELECT attribute_group_id FROM product_attribute_groups WHERE product_id = $1`
		agRows, err := r.db.Query(agQuery, product.ID)
		if err != nil {
			return nil, fmt.Errorf("failed to get product attribute groups: %w", err)
		}

		var groupIDs []string
		for agRows.Next() {
			var groupID string
			if err := agRows.Scan(&groupID); err != nil {
				agRows.Close()
				return nil, fmt.Errorf("failed to scan attribute group ID: %w", err)
			}
			groupIDs = append(groupIDs, groupID)
		}
		agRows.Close()

		product.AttributesGroups = groupIDs
		if product.AttributesGroups == nil {
			product.AttributesGroups = []string{} // Empty array instead of null
		}

		products = append(products, product)
	}

	return products, nil
}

func (r *MenuRetrievalRepository) getMenuCollections(menuID string) ([]models.MenuCollection, error) {
	query := `
		SELECT collection_id, name, position, image_url
		FROM collections
		WHERE menu_id = $1
		ORDER BY position
	`

	rows, err := r.db.Query(query, menuID)
	if err != nil {
		return nil, fmt.Errorf("failed to get collections: %w", err)
	}
	defer rows.Close()

	var collections []models.MenuCollection
	for rows.Next() {
		var collectionID string
		var collection models.MenuCollection
		err := rows.Scan(&collectionID, &collection.Name, &collection.Position, &collection.ImageURL)
		if err != nil {
			return nil, fmt.Errorf("failed to scan collection: %w", err)
		}

		// Get products for this collection
		// In Glovo format, we need at least one section per collection
		productsQuery := `
			SELECT product_id, position
			FROM menu_products
			WHERE menu_id = $1 AND collection_id = $2
			ORDER BY position
		`

		prodRows, err := r.db.Query(productsQuery, menuID, collectionID)
		if err != nil {
			return nil, fmt.Errorf("failed to get collection products: %w", err)
		}

		var productIDs []string
		for prodRows.Next() {
			var productID string
			var position int
			if err := prodRows.Scan(&productID, &position); err != nil {
				prodRows.Close()
				return nil, fmt.Errorf("failed to scan product ID: %w", err)
			}
			productIDs = append(productIDs, productID)
		}
		prodRows.Close()

		// Create a default section with all products
		if len(productIDs) > 0 {
			section := models.MenuSection{
				Name:     collection.Name, // Use collection name as section name
				Position: 0,
				Products: productIDs,
			}
			collection.Sections = []models.MenuSection{section}
		} else {
			collection.Sections = []models.MenuSection{}
		}

		collections = append(collections, collection)
	}

	return collections, nil
}
