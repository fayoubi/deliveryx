package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/deliveryx/restaurant-service/internal/client"
	"github.com/deliveryx/restaurant-service/internal/handlers"
	"github.com/deliveryx/restaurant-service/internal/middleware"
	"github.com/deliveryx/restaurant-service/internal/repository"
	"github.com/deliveryx/restaurant-service/pkg/database"
	"github.com/gorilla/mux"
)

func main() {
	// Load configuration from environment
	dbHost := getEnv("DB_HOST", "postgres")
	dbPort := getEnv("DB_PORT", "5432")
	dbUser := getEnv("DB_USER", "deliveryx")
	dbPass := getEnv("DB_PASSWORD", "deliveryx_dev_pass")
	dbName := getEnv("DB_NAME", "deliveryx_restaurant")
	serverPort := getEnv("SERVER_PORT", "8081")
	menuServiceURL := getEnv("MENU_SERVICE_URL", "http://menu-service:8082")

	// Connect to database
	dsn := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		dbHost, dbPort, dbUser, dbPass, dbName)

	db, err := database.NewPostgresConnection(dsn)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer db.Close()

	log.Println("✅ Connected to PostgreSQL database")

	// Initialize repositories
	storeRepo := repository.NewStoreRepository(db)
	locationRepo := repository.NewLocationRepository(db)

	// Initialize external clients
	menuClient := client.NewMenuServiceClient(menuServiceURL)

	// Initialize handlers
	storeHandler := handlers.NewStoreHandler(storeRepo)
	locationHandler := handlers.NewLocationHandler(locationRepo, storeRepo, menuClient)

	// Setup router
	router := mux.NewRouter()

	// Middleware
	router.Use(middleware.LoggingMiddleware)
	router.Use(middleware.CORSMiddleware)
	router.Use(middleware.JSONContentTypeMiddleware)

	// API v1 routes
	api := router.PathPrefix("/api/v1").Subrouter()

	// Store routes
	api.HandleFunc("/stores", storeHandler.ListStores).Methods("GET")
	api.HandleFunc("/stores", storeHandler.CreateStore).Methods("POST")
	api.HandleFunc("/stores/{store_id}", storeHandler.GetStore).Methods("GET")
	api.HandleFunc("/stores/{store_id}", storeHandler.UpdateStore).Methods("PUT")
	api.HandleFunc("/stores/{store_id}", storeHandler.DeleteStore).Methods("DELETE")

	// Location routes
	api.HandleFunc("/stores/{store_id}/locations", locationHandler.ListLocations).Methods("GET")
	api.HandleFunc("/stores/{store_id}/locations", locationHandler.CreateLocation).Methods("POST")
	api.HandleFunc("/locations/{location_id}", locationHandler.GetLocation).Methods("GET")
	api.HandleFunc("/locations/{location_id}", locationHandler.UpdateLocation).Methods("PUT")
	api.HandleFunc("/locations/{location_id}", locationHandler.DeleteLocation).Methods("DELETE")

	// Operating hours routes
	api.HandleFunc("/locations/{location_id}/operating-hours", locationHandler.SetOperatingHours).Methods("PUT")
	api.HandleFunc("/locations/{location_id}/operating-hours", locationHandler.GetOperatingHours).Methods("GET")

	// Health check
	router.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"status":"healthy"}`))
	}).Methods("GET")

	// Create server
	srv := &http.Server{
		Addr:         ":" + serverPort,
		Handler:      router,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// Start server in goroutine
	go func() {
		log.Printf("🚀 Restaurant Service starting on port %s", serverPort)
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
