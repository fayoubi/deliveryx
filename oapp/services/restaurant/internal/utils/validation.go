package utils

import (
	"fmt"
	"reflect"
	"regexp"

	"github.com/google/uuid"
)

var (
	// PhoneRegex validates phone numbers with international format support
	PhoneRegex = regexp.MustCompile(`^[\d\s\-\+\(\)]+$`)
)

// ValidatePhone checks if a phone number matches the basic pattern
func ValidatePhone(phone string) error {
	if phone == "" {
		return fmt.Errorf("phone number is required")
	}
	if !PhoneRegex.MatchString(phone) {
		return fmt.Errorf("phone number contains invalid characters")
	}
	return nil
}

// ValidateLatitude checks if latitude is within valid range [-90, 90]
func ValidateLatitude(lat float64) error {
	if lat < -90 || lat > 90 {
		return fmt.Errorf("latitude must be between -90 and 90")
	}
	return nil
}

// ValidateLongitude checks if longitude is within valid range [-180, 180]
func ValidateLongitude(lng float64) error {
	if lng < -180 || lng > 180 {
		return fmt.Errorf("longitude must be between -180 and 180")
	}
	return nil
}

// IsEmptyUpdateRequest checks if all pointer fields in an update request are nil
// Returns true if the request would be a no-op (all fields nil)
func IsEmptyUpdateRequest(fields ...*string) bool {
	for _, field := range fields {
		if field != nil {
			return false
		}
	}
	return true
}

// HasAtLeastOneField checks if at least one field is non-nil
// Uses reflection to check the actual pointer value, not the interface
func HasAtLeastOneField(fields ...interface{}) bool {
	for _, field := range fields {
		if field == nil {
			continue
		}
		// Use reflection to check if the pointer is non-nil
		v := reflect.ValueOf(field)
		if v.Kind() == reflect.Ptr && !v.IsNil() {
			return true
		}
		// For non-pointer types, if field != nil, it has a value
		if v.Kind() != reflect.Ptr {
			return true
		}
	}
	return false
}

// IsValidUUID checks if a string is a valid UUID
func IsValidUUID(id string) bool {
	_, err := uuid.Parse(id)
	return err == nil
}
