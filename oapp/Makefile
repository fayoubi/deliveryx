.PHONY: help infra-up infra-down infra-restart infra-logs db-migrate-up db-migrate-down db-reset db-status

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

infra-up: ## Start all infrastructure services (PostgreSQL, RabbitMQ, Traefik)
	@echo "🚀 Starting DeliveryX infrastructure..."
	docker-compose up -d
	@echo "✅ Infrastructure started!"
	@echo ""
	@echo "Services available at:"
	@echo "  - PostgreSQL:        localhost:5432"
	@echo "  - RabbitMQ:          localhost:5672"
	@echo "  - RabbitMQ UI:       http://localhost:15672 (user: deliveryx, pass: deliveryx_dev_pass)"
	@echo "  - Traefik Dashboard: http://localhost:8080"
	@echo "  - API Gateway:       http://localhost:80"

infra-down: ## Stop all infrastructure services
	@echo "🛑 Stopping DeliveryX infrastructure..."
	docker-compose down
	@echo "✅ Infrastructure stopped!"

infra-restart: ## Restart all infrastructure services
	@echo "🔄 Restarting DeliveryX infrastructure..."
	docker-compose restart
	@echo "✅ Infrastructure restarted!"

infra-logs: ## Show logs from all infrastructure services
	docker-compose logs -f

db-migrate-up: ## Run all database migrations (up)
	@echo "📦 Running migrations for Restaurant Service..."
	migrate -path ./services/restaurant/migrations -database "postgresql://deliveryx:deliveryx_dev_pass@localhost:5435/deliveryx_restaurant?sslmode=disable" up
	@echo "📦 Running migrations for Menu Service..."
	migrate -path ./services/menu/migrations -database "postgresql://deliveryx:deliveryx_dev_pass@localhost:5435/deliveryx_menu?sslmode=disable" up
	@echo "📦 Running migrations for Approval Service..."
	migrate -path ./services/approval/migrations -database "postgresql://deliveryx:deliveryx_dev_pass@localhost:5435/deliveryx_approval?sslmode=disable" up
	@echo "✅ All migrations completed!"

db-migrate-down: ## Rollback all database migrations (down)
	@echo "⚠️  Rolling back migrations for Restaurant Service..."
	migrate -path ./services/restaurant/migrations -database "postgresql://deliveryx:deliveryx_dev_pass@localhost:5432/deliveryx_restaurant?sslmode=disable" down
	@echo "⚠️  Rolling back migrations for Menu Service..."
	migrate -path ./services/menu/migrations -database "postgresql://deliveryx:deliveryx_dev_pass@localhost:5432/deliveryx_menu?sslmode=disable" down
	@echo "⚠️  Rolling back migrations for Approval Service..."
	migrate -path ./services/approval/migrations -database "postgresql://deliveryx:deliveryx_dev_pass@localhost:5432/deliveryx_approval?sslmode=disable" down
	@echo "✅ All migrations rolled back!"

db-reset: infra-down ## Reset entire database (WARNING: destroys all data)
	@echo "⚠️  WARNING: This will destroy all data!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker volume rm oapp_postgres_data || true; \
		docker volume rm oapp_rabbitmq_data || true; \
		echo "✅ Volumes deleted!"; \
		$(MAKE) infra-up; \
		sleep 5; \
		$(MAKE) db-migrate-up; \
	fi

db-status: ## Check migration status for all databases
	@echo "📊 Restaurant Service migration status:"
	migrate -path ./services/restaurant/migrations -database "postgresql://deliveryx:deliveryx_dev_pass@localhost:5432/deliveryx_restaurant?sslmode=disable" version
	@echo ""
	@echo "📊 Menu Service migration status:"
	migrate -path ./services/menu/migrations -database "postgresql://deliveryx:deliveryx_dev_pass@localhost:5432/deliveryx_menu?sslmode=disable" version
	@echo ""
	@echo "📊 Approval Service migration status:"
	migrate -path ./services/approval/migrations -database "postgresql://deliveryx:deliveryx_dev_pass@localhost:5432/deliveryx_approval?sslmode=disable" version
