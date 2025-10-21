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

	"github.com/deliveryx/menu-service/internal/handlers"
	"github.com/deliveryx/menu-service/internal/middleware"
	"github.com/deliveryx/menu-service/internal/repository"
	"github.com/deliveryx/menu-service/pkg/database"
	"github.com/deliveryx/menu-service/pkg/queue"
	"github.com/gorilla/mux"
)

func main() {
	// Load configuration from environment
	dbHost := getEnv("DB_HOST", "postgres")
	dbPort := getEnv("DB_PORT", "5432")
	dbUser := getEnv("DB_USER", "deliveryx")
	dbPass := getEnv("DB_PASSWORD", "deliveryx_dev_pass")
	dbName := getEnv("DB_NAME", "deliveryx_menu")
	serverPort := getEnv("SERVER_PORT", "8082")
	rabbitmqURL := getEnv("RABBITMQ_URL", "amqp://deliveryx:deliveryx_dev_pass@rabbitmq:5672/")

	// Connect to database
	dsn := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		dbHost, dbPort, dbUser, dbPass, dbName)

	db, err := database.NewPostgresConnection(dsn)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer db.Close()

	log.Println("✅ Connected to PostgreSQL database")

	// Connect to RabbitMQ
	queueClient, err := queue.NewRabbitMQClient(rabbitmqURL)
	if err != nil {
		log.Fatalf("Failed to connect to RabbitMQ: %v", err)
	}
	defer queueClient.Close()

	// Initialize repositories
	menuRepo := repository.NewMenuRepository(db)
	menuRetrievalRepo := repository.NewMenuRetrievalRepository(db)
	attributeRepo := repository.NewAttributeRepository(db)
	productRepo := repository.NewProductRepository(db)
	collectionRepo := repository.NewCollectionRepository(db)
	menuProductRepo := repository.NewMenuProductRepository(db)

	// Initialize handlers
	menuHandler := handlers.NewMenuHandler(menuRepo, menuRetrievalRepo, queueClient)
	attributeHandler := handlers.NewAttributeHandler(attributeRepo)
	productHandler := handlers.NewProductHandler(productRepo)
	collectionHandler := handlers.NewCollectionHandler(collectionRepo)
	menuProductHandler := handlers.NewMenuProductHandler(menuProductRepo)

	// Setup router
	router := mux.NewRouter()

	// Middleware
	router.Use(middleware.LoggingMiddleware)
	router.Use(middleware.CORSMiddleware)
	router.Use(middleware.JSONContentTypeMiddleware)

	// API v1 routes
	api := router.PathPrefix("/api/v1").Subrouter()

	// Epic 2: Menu initialization & attribute groups
	api.HandleFunc("/locations/{location_id}/menus", menuHandler.CreateMenu).Methods("POST")
	api.HandleFunc("/attribute-groups", attributeHandler.GetAttributeGroups).Methods("GET")
	api.HandleFunc("/attribute-groups/{id}/attributes", attributeHandler.GetAttributes).Methods("GET")

	// Epic 3: Collection management
	api.HandleFunc("/menus/{menu_id}/collections", collectionHandler.CreateCollection).Methods("POST")
	api.HandleFunc("/collections/{collection_id}", collectionHandler.DeleteCollection).Methods("DELETE")
	api.HandleFunc("/menus/{menu_id}/collections/reorder", collectionHandler.ReorderCollections).Methods("PUT")

	// Epic 4: Product CRUD + availability toggle
	api.HandleFunc("/locations/{location_id}/products", productHandler.CreateProduct).Methods("POST")
	api.HandleFunc("/products/{product_id}", productHandler.GetProduct).Methods("GET")
	api.HandleFunc("/products/{product_id}", productHandler.UpdateProduct).Methods("PUT")
	api.HandleFunc("/products/{product_id}", productHandler.DeleteProduct).Methods("DELETE")
	api.HandleFunc("/products/{product_id}/availability", productHandler.ToggleAvailability).Methods("PATCH")

	// Epic 5: Menu composition
	api.HandleFunc("/menus/{menu_id}/products", menuProductHandler.AddProductToMenu).Methods("POST")
	api.HandleFunc("/menus/{menu_id}/products/{product_id}", menuProductHandler.RemoveProductFromMenu).Methods("DELETE")
	api.HandleFunc("/collections/{collection_id}/products/reorder", menuProductHandler.ReorderProducts).Methods("PUT")

	// Epic 6: Menu submission & status tracking
	api.HandleFunc("/menus/{menu_id}/submit", menuHandler.SubmitMenu).Methods("POST")
	api.HandleFunc("/menus/{menu_id}/status", menuHandler.GetMenuStatus).Methods("GET")

	// Epic 7: Complete menu retrieval
	api.HandleFunc("/menus/{menu_id}", menuHandler.GetCompleteMenu).Methods("GET")

	// Internal routes (for service-to-service communication)
	internal := router.PathPrefix("/internal").Subrouter()
	internal.HandleFunc("/menus/{menu_id}/status", menuHandler.UpdateMenuStatus).Methods("PUT")

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
		log.Printf("🚀 Menu Service starting on port %s", serverPort)
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
