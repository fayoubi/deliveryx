package repository

import (
	"database/sql"
	"fmt"

	"github.com/deliveryx/menu-service/internal/models"
)

type AttributeRepository struct {
	db *sql.DB
}

func NewAttributeRepository(db *sql.DB) *AttributeRepository {
	return &AttributeRepository{db: db}
}

// GetAllAttributeGroups retrieves all attribute groups
func (r *AttributeRepository) GetAllAttributeGroups() ([]models.AttributeGroup, error) {
	query := `
		SELECT id, name, min_selections, max_selections, is_required, system_defined, created_at, updated_at
		FROM attribute_groups
		ORDER BY name
	`

	rows, err := r.db.Query(query)
	if err != nil {
		return nil, fmt.Errorf("failed to get attribute groups: %w", err)
	}
	defer rows.Close()

	groups := []models.AttributeGroup{}
	for rows.Next() {
		var group models.AttributeGroup
		err := rows.Scan(
			&group.ID,
			&group.Name,
			&group.MinSelections,
			&group.MaxSelections,
			&group.IsRequired,
			&group.SystemDefined,
			&group.CreatedAt,
			&group.UpdatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to scan attribute group: %w", err)
		}
		groups = append(groups, group)
	}

	return groups, nil
}

// GetAttributesByGroupID retrieves all attributes for a specific group
func (r *AttributeRepository) GetAttributesByGroupID(groupID string) ([]models.Attribute, error) {
	// First check if group exists
	var exists bool
	err := r.db.QueryRow("SELECT EXISTS(SELECT 1 FROM attribute_groups WHERE id = $1)", groupID).Scan(&exists)
	if err != nil {
		return nil, fmt.Errorf("failed to check group existence: %w", err)
	}
	if !exists {
		return nil, fmt.Errorf("attribute group not found")
	}

	query := `
		SELECT id, attribute_group_id, name, price_impact, is_default, created_at, updated_at
		FROM attributes
		WHERE attribute_group_id = $1
		ORDER BY name
	`

	rows, err := r.db.Query(query, groupID)
	if err != nil {
		return nil, fmt.Errorf("failed to get attributes: %w", err)
	}
	defer rows.Close()

	attributes := []models.Attribute{}
	for rows.Next() {
		var attr models.Attribute
		err := rows.Scan(
			&attr.ID,
			&attr.AttributeGroupID,
			&attr.Name,
			&attr.PriceImpact,
			&attr.IsDefault,
			&attr.CreatedAt,
			&attr.UpdatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to scan attribute: %w", err)
		}
		attributes = append(attributes, attr)
	}

	return attributes, nil
}
