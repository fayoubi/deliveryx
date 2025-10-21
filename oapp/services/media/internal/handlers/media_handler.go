package handlers

import (
	"encoding/json"
	"fmt"
	"net/http"
	"path/filepath"
	"time"

	"github.com/deliveryx/media-service/internal/models"
	"github.com/deliveryx/media-service/pkg/s3"
	"github.com/google/uuid"
)

type MediaHandler struct {
	s3Client *s3.S3Client
}

func NewMediaHandler(s3Client *s3.S3Client) *MediaHandler {
	return &MediaHandler{
		s3Client: s3Client,
	}
}

// GenerateUploadURL handles POST /api/v1/media/upload-url
func (h *MediaHandler) GenerateUploadURL(w http.ResponseWriter, r *http.Request) {
	var req models.UploadURLRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondWithError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	// Validate request
	if req.FileName == "" || req.ContentType == "" || req.FileSize == 0 {
		respondWithError(w, http.StatusBadRequest, "file_name, content_type, and file_size are required")
		return
	}

	// Validate file size (max 10MB for now)
	if req.FileSize > 10*1024*1024 {
		respondWithError(w, http.StatusBadRequest, "File size exceeds maximum allowed (10MB)")
		return
	}

	// Validate content type (images only for now)
	allowedTypes := map[string]bool{
		"image/jpeg": true,
		"image/jpg":  true,
		"image/png":  true,
		"image/gif":  true,
		"image/webp": true,
	}
	if !allowedTypes[req.ContentType] {
		respondWithError(w, http.StatusBadRequest, "Only image files are allowed")
		return
	}

	// Generate unique file name with timestamp and UUID
	ext := filepath.Ext(req.FileName)
	uniqueFileName := fmt.Sprintf("%s-%s%s", time.Now().Format("20060102-150405"), uuid.New().String()[:8], ext)

	// Organize by date
	datePath := time.Now().Format("2006/01/02")
	s3Key := fmt.Sprintf("%s/%s", datePath, uniqueFileName)

	// Generate pre-signed URL (valid for 15 minutes)
	uploadURL, err := h.s3Client.GeneratePresignedUploadURL(s3Key, req.ContentType, 15)
	if err != nil {
		respondWithError(w, http.StatusInternalServerError, "Failed to generate upload URL")
		return
	}

	// Get the final file URL
	fileURL := h.s3Client.GetFileURL(s3Key)

	response := models.UploadURLResponse{
		UploadURL: uploadURL,
		FileURL:   fileURL,
		ExpiresIn: 900, // 15 minutes in seconds
	}

	respondWithJSON(w, http.StatusOK, response)
}

// Helper functions
func respondWithError(w http.ResponseWriter, code int, message string) {
	respondWithJSON(w, code, map[string]string{"error": message})
}

func respondWithJSON(w http.ResponseWriter, code int, payload interface{}) {
	response, err := json.Marshal(payload)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte(`{"error":"Failed to encode response"}`))
		return
	}

	w.WriteHeader(code)
	w.Write(response)
}
