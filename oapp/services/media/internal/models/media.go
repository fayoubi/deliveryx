package models

// UploadURLRequest represents the request to generate a pre-signed upload URL
type UploadURLRequest struct {
	FileName    string `json:"file_name" validate:"required"`
	ContentType string `json:"content_type" validate:"required"`
	FileSize    int64  `json:"file_size" validate:"required"`
}

// UploadURLResponse represents the response with pre-signed URL
type UploadURLResponse struct {
	UploadURL string `json:"upload_url"`
	FileURL   string `json:"file_url"`
	ExpiresIn int    `json:"expires_in"` // seconds
}
