package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/deliveryx/media-service/internal/handlers"
	"github.com/deliveryx/media-service/internal/middleware"
	"github.com/deliveryx/media-service/pkg/s3"
	"github.com/gorilla/mux"
)

func main() {
	// Get environment variables
	port := getEnv("PORT", "8084")

	// S3/MinIO configuration
	s3Region := getEnv("S3_REGION", "us-east-1")
	s3Bucket := getEnv("S3_BUCKET", "deliveryx-media")
	s3Endpoint := getEnv("S3_ENDPOINT", "") // Empty for AWS, set for MinIO/LocalStack
	s3AccessKey := getEnv("S3_ACCESS_KEY", "")
	s3SecretKey := getEnv("S3_SECRET_KEY", "")
	s3UsePathStyle := getEnv("S3_USE_PATH_STYLE", "false") == "true"

	// Initialize S3 client
	s3Client, err := s3.NewS3Client(s3Region, s3Bucket, s3Endpoint, s3AccessKey, s3SecretKey, s3UsePathStyle)
	if err != nil {
		log.Fatalf("Failed to create S3 client: %v", err)
	}

	log.Println("✅ S3 client initialized")

	// Initialize handlers
	mediaHandler := handlers.NewMediaHandler(s3Client)

	// Setup router
	r := mux.NewRouter()

	// Apply global middleware
	r.Use(middleware.LoggingMiddleware)
	r.Use(middleware.CORSMiddleware)
	r.Use(middleware.JSONContentTypeMiddleware)

	// Health check
	r.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"status":"healthy"}`))
	}).Methods("GET")

	// API routes
	api := r.PathPrefix("/api/v1/media").Subrouter()

	// Media endpoints
	api.HandleFunc("/upload-url", mediaHandler.GenerateUploadURL).Methods("POST")

	// Create server
	srv := &http.Server{
		Addr:         ":" + port,
		Handler:      r,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// Start server in a goroutine
	go func() {
		log.Printf("🚀 Media Service starting on port %s", port)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Server failed to start: %v", err)
		}
	}()

	// Graceful shutdown
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	log.Println("🛑 Shutting down server...")

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	if err := srv.Shutdown(ctx); err != nil {
		log.Fatalf("Server forced to shutdown: %v", err)
	}

	log.Println("✅ Server stopped gracefully")
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
