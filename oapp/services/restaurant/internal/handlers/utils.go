package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/deliveryx/restaurant-service/internal/models"
)

// respondWithError sends a structured error response with message, code, and optional details
func respondWithError(w http.ResponseWriter, statusCode int, apiError *models.APIError) {
	respondWithJSON(w, statusCode, apiError)
}

// respondWithSimpleError sends a structured error response with just message and code
func respondWithSimpleError(w http.ResponseWriter, statusCode int, message, code string) {
	respondWithJSON(w, statusCode, models.NewAPIError(message, code))
}

// respondWithJSON sends a JSON response
func respondWithJSON(w http.ResponseWriter, code int, payload interface{}) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(code)
	if err := json.NewEncoder(w).Encode(payload); err != nil {
		// Fallback error if JSON encoding fails
		http.Error(w, `{"message":"Failed to encode response","code":"ENCODING_ERROR"}`, http.StatusInternalServerError)
	}
}
