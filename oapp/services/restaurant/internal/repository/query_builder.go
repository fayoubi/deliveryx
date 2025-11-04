package repository

import (
	"fmt"
	"strings"
)

// PaginationParams holds pagination parameters
type PaginationParams struct {
	Page     int
	PageSize int
}

// FilterParams holds filtering parameters
type FilterParams struct {
	Query  string // q parameter for substring search
	Phone  string
	City   string
}

// SortParams holds sorting parameters
type SortParams struct {
	Field     string
	Descending bool
}

// ParsePaginationParams parses and validates pagination parameters
func ParsePaginationParams(page, pageSize int) PaginationParams {
	if page < 1 {
		page = 1
	}
	if pageSize < 1 {
		pageSize = 20
	}
	if pageSize > 100 {
		pageSize = 100
	}
	return PaginationParams{
		Page:     page,
		PageSize: pageSize,
	}
}

// ParseSortParam parses sort parameter (e.g., "name", "-created_at")
func ParseSortParam(sort string, allowedFields []string, defaultField string) SortParams {
	if sort == "" {
		return SortParams{Field: defaultField, Descending: false}
	}

	descending := false
	field := sort

	if strings.HasPrefix(sort, "-") {
		descending = true
		field = strings.TrimPrefix(sort, "-")
	}

	// Validate field is allowed
	allowed := false
	for _, f := range allowedFields {
		if f == field {
			allowed = true
			break
		}
	}

	if !allowed {
		return SortParams{Field: defaultField, Descending: false}
	}

	return SortParams{Field: field, Descending: descending}
}

// BuildWhereClause builds WHERE clause for stores
func BuildWhereClauseStores(filters FilterParams, args *[]interface{}) string {
	var conditions []string
	argIndex := 1

	if filters.Query != "" {
		conditions = append(conditions, fmt.Sprintf("name ILIKE $%d", argIndex))
		*args = append(*args, "%"+filters.Query+"%")
		argIndex++
	}

	if filters.Phone != "" {
		conditions = append(conditions, fmt.Sprintf("phone = $%d", argIndex))
		*args = append(*args, filters.Phone)
		argIndex++
	}

	if len(conditions) == 0 {
		return ""
	}

	return " WHERE " + strings.Join(conditions, " AND ")
}

// BuildWhereClauseLocations builds WHERE clause for locations
func BuildWhereClauseLocations(storeID string, filters FilterParams, args *[]interface{}) string {
	var conditions []string

	// Always filter by store_id
	conditions = append(conditions, fmt.Sprintf("store_id = $%d", len(*args)+1))
	*args = append(*args, storeID)

	if filters.City != "" {
		conditions = append(conditions, fmt.Sprintf("city = $%d", len(*args)+1))
		*args = append(*args, filters.City)
	}

	if filters.Query != "" {
		conditions = append(conditions, fmt.Sprintf("address ILIKE $%d", len(*args)+1))
		*args = append(*args, "%"+filters.Query+"%")
	}

	return " WHERE " + strings.Join(conditions, " AND ")
}

// BuildOrderByClause builds ORDER BY clause
func BuildOrderByClause(sortParams SortParams, tieBreaker string) string {
	direction := "ASC"
	if sortParams.Descending {
		direction = "DESC"
	}

	orderBy := fmt.Sprintf(" ORDER BY %s %s", sortParams.Field, direction)

	// Add tie-breaker if provided and different from sort field
	if tieBreaker != "" && tieBreaker != sortParams.Field {
		orderBy += fmt.Sprintf(", %s ASC", tieBreaker)
	}

	return orderBy
}

// BuildPaginationClause builds LIMIT and OFFSET
func BuildPaginationClause(params PaginationParams) string {
	offset := (params.Page - 1) * params.PageSize
	return fmt.Sprintf(" LIMIT %d OFFSET %d", params.PageSize, offset)
}
