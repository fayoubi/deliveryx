# DeliveryX - Restaurant Management Platform

A microservices-based food delivery platform built with Go, PostgreSQL, and RabbitMQ.

## Quick Start

### Prerequisites
- Docker & Docker Compose
- [golang-migrate](https://github.com/golang-migrate/migrate) CLI tool
- Make (optional, but recommended)

### Install golang-migrate

```bash
# macOS
brew install golang-migrate

# Linux
curl -L https://github.com/golang-migrate/migrate/releases/download/v4.17.0/migrate.linux-amd64.tar.gz | tar xvz
sudo mv migrate /usr/local/bin/

# Or via Go
go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest
```

### Start Infrastructure

```bash
# Start all infrastructure services (PostgreSQL, RabbitMQ, Traefik)
make infra-up

# Run database migrations
make db-migrate-up

# Verify setup
make db-status
```

That's it! Your local DeliveryX infrastructure is now running.

## Available Commands

```bash
make help              # Show all available commands
make infra-up          # Start infrastructure
make infra-down        # Stop infrastructure
make infra-restart     # Restart infrastructure
make infra-logs        # View logs
make db-migrate-up     # Run migrations
make db-migrate-down   # Rollback migrations
make db-status         # Check migration status
make db-reset          # Reset database (WARNING: destroys data)
```

## Architecture

DeliveryX follows a microservices architecture with the following services:

### Services
1. **Restaurant Service** - Store and location management
2. **Menu Service** - Product catalog and menu composition
3. **Approval Service** - Menu review workflow
4. **Media Service** - Image upload and storage (planned)

### Infrastructure
- **PostgreSQL** - 3 separate databases for service isolation
- **RabbitMQ** - Message broker for async communication
- **Traefik** - API Gateway and reverse proxy

## Service Endpoints (Planned)

| Route                    | Service            |
|-------------------------|-------------------|
| `/api/v1/stores/*`      | Restaurant        |
| `/api/v1/locations/*`   | Restaurant        |
| `/api/v1/menus/*`       | Menu              |
| `/api/v1/products/*`    | Menu              |
| `/api/v1/collections/*` | Menu              |
| `/api/v1/approvals/*`   | Approval          |
| `/api/v1/media/*`       | Media (planned)   |

## Access Points

| Service              | URL                          | Credentials                    |
|---------------------|------------------------------|--------------------------------|
| PostgreSQL          | localhost:5432               | deliveryx / deliveryx_dev_pass |
| RabbitMQ AMQP       | localhost:5672               | deliveryx / deliveryx_dev_pass |
| RabbitMQ Management | http://localhost:15672       | deliveryx / deliveryx_dev_pass |
| Traefik Dashboard   | http://localhost:8080        | No auth                        |
| API Gateway         | http://localhost:80          | Coming soon                    |

## Project Status

### ✅ Phase 1: Infrastructure & Foundation (Completed)
- [x] Docker Compose setup
- [x] PostgreSQL databases (3)
- [x] RabbitMQ message queue
- [x] Traefik API Gateway
- [x] Database migrations (all services)
- [x] Seed data (attribute groups)
- [x] Developer tooling (Makefile, env templates)

### 🚧 Phase 2: Service Implementation (In Progress)
- [ ] Restaurant Service (Go)
- [ ] Menu Service (Go)
- [ ] Approval Service (Go)
- [ ] Media Service (Go)
- [ ] API Gateway routing configuration

### 📋 Phase 3: Testing & Documentation (Planned)
- [ ] Integration tests
- [ ] API documentation (Swagger)
- [ ] End-to-end testing

### 📱 Phase 4: Mobile App (Planned)
- [ ] iOS app implementation

## Documentation

- [Phase 1: Infrastructure Setup](docs/phase1-infrastructure-setup.md) - Detailed documentation of local development setup
- [System Design](system-design.md) - High-level architecture overview
- [Epic Stories](stories/) - User stories and acceptance criteria

## Environment Variables

Copy `.env.example` to `.env` and customize if needed:

```bash
cp .env.example .env
```

Default values are suitable for local development.

## Database Migrations

Migrations are managed using [golang-migrate](https://github.com/golang-migrate/migrate).

### Location
- Restaurant Service: `services/restaurant/migrations/`
- Menu Service: `services/menu/migrations/`
- Approval Service: `services/approval/migrations/`

### Manual Migration Commands

```bash
# Restaurant Service
migrate -path ./services/restaurant/migrations \
  -database "postgresql://deliveryx:deliveryx_dev_pass@localhost:5432/deliveryx_restaurant?sslmode=disable" \
  up

# Menu Service
migrate -path ./services/menu/migrations \
  -database "postgresql://deliveryx:deliveryx_dev_pass@localhost:5432/deliveryx_menu?sslmode=disable" \
  up

# Approval Service
migrate -path ./services/approval/migrations \
  -database "postgresql://deliveryx:deliveryx_dev_pass@localhost:5432/deliveryx_approval?sslmode=disable" \
  up
```

## Troubleshooting

### Port conflicts
If ports 5432, 5672, 15672, 80, or 8080 are already in use:

```bash
# Find process using port
lsof -i :5432

# Kill process or change ports in docker-compose.yml
```

### Database issues

```bash
# Reset everything (destroys data)
make db-reset

# Or manually
docker-compose down -v
docker-compose up -d
make db-migrate-up
```

### Migration errors

```bash
# Check if golang-migrate is installed
migrate -version

# Force migration version (use with caution)
migrate -path ./services/menu/migrations \
  -database "postgresql://deliveryx:deliveryx_dev_pass@localhost:5432/deliveryx_menu?sslmode=disable" \
  force 8
```

## Development Workflow

1. Start infrastructure: `make infra-up`
2. Run migrations: `make db-migrate-up`
3. Develop service code
4. Test changes
5. Stop infrastructure: `make infra-down`

## Contributing

This is a private project. See epic stories in `stories/` for implementation requirements.

## License

Proprietary - All rights reserved
