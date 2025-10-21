package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/deliveryx/approval-service/internal/client"
	"github.com/deliveryx/approval-service/internal/handlers"
	"github.com/deliveryx/approval-service/internal/middleware"
	"github.com/deliveryx/approval-service/internal/repository"
	"github.com/deliveryx/approval-service/pkg/database"
	"github.com/deliveryx/approval-service/pkg/queue"
	"github.com/gorilla/mux"
)

func main() {
	// Get environment variables
	port := getEnv("PORT", "8083")
	dbDSN := getEnv("DATABASE_URL", "postgres://deliveryx:deliveryx@postgres:5432/approval_db?sslmode=disable")
	menuServiceURL := getEnv("MENU_SERVICE_URL", "http://deliveryx-menu:8082")
	rabbitmqURL := getEnv("RABBITMQ_URL", "amqp://deliveryx:deliveryx_dev_pass@rabbitmq:5672/")

	// Connect to PostgreSQL
	db, err := database.NewPostgresConnection(dbDSN)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer db.Close()

	log.Println("✅ Connected to PostgreSQL database")

	// Initialize repositories
	approvalRepo := repository.NewApprovalRepository(db)

	// Initialize clients
	menuClient := client.NewMenuClient(menuServiceURL)

	// Initialize handlers
	approvalHandler := handlers.NewApprovalHandler(approvalRepo, menuClient)

	// Connect to RabbitMQ consumer
	consumer, err := queue.NewConsumer(rabbitmqURL)
	if err != nil {
		log.Fatalf("Failed to connect to RabbitMQ: %v", err)
	}
	defer consumer.Close()

	// Start consuming menu-submitted events in background
	consumerCtx, cancelConsumer := context.WithCancel(context.Background())
	defer cancelConsumer()

	go func() {
		handler := func(ctx context.Context, event queue.MenuSubmittedEvent) error {
			log.Printf("🎯 Processing menu-submitted event for menu_id: %s", event.MenuID)
			// Note: Events are informational - actual approval happens via REST API
			// This could be used for notifications, analytics, or automated workflows
			return nil
		}

		if err := consumer.ConsumeMenuSubmitted(consumerCtx, handler); err != nil {
			log.Printf("⚠️  Consumer stopped: %v", err)
		}
	}()

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
	api := r.PathPrefix("/api/v1/approvals").Subrouter()

	// Approval endpoints
	api.HandleFunc("/menus/{menu_id}/approve", approvalHandler.ApproveMenu).Methods("POST")
	api.HandleFunc("/menus/{menu_id}/reject", approvalHandler.RejectMenu).Methods("POST")
	api.HandleFunc("/menus/{menu_id}/history", approvalHandler.GetApprovalHistory).Methods("GET")

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
		log.Printf("Approval Service starting on port %s", port)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Server failed to start: %v", err)
		}
	}()

	// Graceful shutdown
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	log.Println("Shutting down server...")

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	if err := srv.Shutdown(ctx); err != nil {
		log.Fatalf("Server forced to shutdown: %v", err)
	}

	log.Println("Server exited")
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
