package models

// APIError represents a structured error response with machine-readable code and details
type APIError struct {
	Message string                 `json:"message"`
	Code    string                 `json:"code"`
	Details map[string]interface{} `json:"details,omitempty"`
}

// NewAPIError creates a new APIError with the given message and code
func NewAPIError(message, code string) *APIError {
	return &APIError{
		Message: message,
		Code:    code,
		Details: make(map[string]interface{}),
	}
}

// WithDetail adds a detail field to the error
func (e *APIError) WithDetail(key string, value interface{}) *APIError {
	if e.Details == nil {
		e.Details = make(map[string]interface{})
	}
	e.Details[key] = value
	return e
}

// Common error codes
const (
	ErrCodeValidation       = "VALIDATION_ERROR"
	ErrCodeNotFound         = "NOT_FOUND"
	ErrCodeStoreHasLocs     = "STORE_HAS_LOCATIONS"
	ErrCodeLocationHasMenus = "LOCATION_HAS_MENUS"
	ErrCodeInternalError    = "INTERNAL_ERROR"
	ErrCodeInvalidRequest   = "INVALID_REQUEST"
	ErrCodeServiceUnavail   = "SERVICE_UNAVAILABLE"
)

// PaginatedResponse represents a paginated list response envelope
type PaginatedResponse struct {
	Items    interface{} `json:"items"`
	Page     int         `json:"page"`
	PageSize int         `json:"page_size"`
	Total    int         `json:"total"`
	HasNext  bool        `json:"has_next"`
}

// NewPaginatedResponse creates a paginated response with calculated has_next
func NewPaginatedResponse(items interface{}, page, pageSize, total int) *PaginatedResponse {
	hasNext := (page * pageSize) < total
	return &PaginatedResponse{
		Items:    items,
		Page:     page,
		PageSize: pageSize,
		Total:    total,
		HasNext:  hasNext,
	}
}
