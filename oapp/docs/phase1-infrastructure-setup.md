# Phase 1: Infrastructure Setup - Local Development

## TLDR

Phase 1 establishes the foundational infrastructure for DeliveryX running **locally** using Docker. The setup includes:
- 3 isolated PostgreSQL databases (restaurant, menu, approval services)
- RabbitMQ message broker for async communication
- Traefik API Gateway for request routing
- Complete database schemas with migrations
- Makefile for easy infrastructure management

## What Was Built

### 1. **Docker Compose Infrastructure** (`docker-compose.yml`)
- **PostgreSQL 16**: Single container hosting 3 separate databases
  - `deliveryx_restaurant`
  - `deliveryx_menu`
  - `deliveryx_approval`
- **RabbitMQ 3.12**: Message queue with management UI
- **Traefik 2.10**: API Gateway with dashboard

### 2. **Database Migrations**

#### Restaurant Service (`services/restaurant/migrations/`)
- `000001`: Stores table (name, description, logo, phone)
- `000002`: Locations table (address, city, coordinates, manager)
- `000003`: Operating hours table (day, open/close times, custom ENUM type)

#### Menu Service (`services/menu/migrations/`)
- `000001`: Menus table (status workflow: draft → pending_review → approved/rejected → active)
- `000002`: Attribute groups table (Size, Cuisson, Color)
- `000003`: Attributes table (S/M/L/XL with price impacts)
- `000004`: Products table (name, price, description, availability)
- `000005`: Product-attribute junction table (many-to-many)
- `000006`: Collections table (Pizzas, Burgers, etc. - predefined list)
- `000007`: Menu-products junction table (composition)
- `000008`: **Seed data** for 3 predefined attribute groups with values

#### Approval Service (`services/approval/migrations/`)
- `000001`: Approval logs table (audit trail for menu approvals/rejections)

### 3. **Developer Tooling**
- **Makefile**: Provides easy commands for infrastructure management
- **.env.example**: Template for environment variables
- **.gitignore**: Protects sensitive files and build artifacts

## Quick Start

```bash
# 1. Start infrastructure
make infra-up

# 2. Run database migrations
make db-migrate-up

# 3. Check migration status
make db-status

# 4. View logs
make infra-logs

# 5. Stop infrastructure
make infra-down
```

## Architecture Decisions

### Database Design
- **Separate databases per service**: Ensures loose coupling and independent scalability
- **UUID primary keys**: Globally unique identifiers, better for distributed systems
- **ENUM types**: Type-safe status fields (menu_status, day_of_week, approval_action)
- **Timestamps**: All tables track `created_at` and `updated_at` with auto-update triggers
- **Cascading deletes**: Maintains referential integrity (e.g., deleting store removes locations)

### Migration Strategy
- **golang-migrate compatible**: Numbered migrations with .up/.down pairs
- **Idempotent**: All migrations use `IF NOT EXISTS` / `IF EXISTS`
- **Seeded data with fixed UUIDs**: Predefined attribute groups use hardcoded UUIDs for consistency

### API Gateway
- **Traefik chosen over Kong**:
  - Lighter weight for local development
  - Native Docker integration
  - Easier configuration via labels (planned for Phase 2)
  - Built-in dashboard for debugging

### Message Queue
- **RabbitMQ over AWS SQS**:
  - Local development requirement
  - Management UI for debugging
  - Will abstract with interface for AWS migration later

## Assumptions

1. **Local-first approach**: All services run in Docker on localhost
2. **Single PostgreSQL instance**: Cost-effective for local dev; easily separable for production
3. **No authentication/authorization yet**: Focus on core business logic first
4. **HTTP only (no HTTPS)**: Local development; TLS in production
5. **golang-migrate tool installed**: Required for running migrations
6. **Docker & Docker Compose installed**: Prerequisite for all infrastructure

## Caveats & Limitations

### Current Limitations
1. **No service discovery**: Services will need hardcoded localhost addresses for now
2. **No health checks for services**: Only infrastructure has health checks
3. **No data persistence strategy**: Volumes will be lost on `docker-compose down -v`
4. **No backup/restore mechanism**: Manual database dumps required
5. **No monitoring/observability**: No Prometheus, Grafana, or tracing yet
6. **No rate limiting**: Configured in Traefik but not enforced
7. **No CORS configuration**: Will need to add when mobile app connects

### Security Notes (Local Only)
- **Hardcoded credentials**: `deliveryx_dev_pass` used everywhere (acceptable for local)
- **No secrets management**: `.env` file stores plaintext passwords
- **Insecure Traefik dashboard**: Accessible without auth at port 8080
- **No network isolation**: All containers on bridge network

### Migration Path to AWS
When moving to production, these changes will be needed:
1. **PostgreSQL**: Migrate to Amazon RDS (3 separate instances or schemas)
2. **RabbitMQ**: Replace with Amazon SQS + SNS
3. **Traefik**: Replace with AWS API Gateway or ALB
4. **S3**: Add for media storage (already planned in Epic 8)
5. **Secrets**: Use AWS Secrets Manager or Parameter Store
6. **TLS**: Use ACM certificates with ALB
7. **Networking**: Use VPC with private/public subnets

## File Structure

```
oapp/
├── docker-compose.yml           # Infrastructure orchestration
├── Makefile                     # Development commands
├── .env.example                 # Environment template
├── .gitignore                   # Git exclusions
├── infrastructure/
│   ├── init-db.sql             # PostgreSQL database creation
│   └── rabbitmq.conf           # RabbitMQ configuration
├── services/
│   ├── restaurant/
│   │   └── migrations/         # 3 migration pairs (stores, locations, hours)
│   ├── menu/
│   │   └── migrations/         # 8 migration pairs (menus, products, collections, etc.)
│   └── approval/
│       └── migrations/         # 1 migration pair (approval logs)
└── docs/
    └── phase1-infrastructure-setup.md  # This file
```

## Next Steps (Phase 2)

1. **Restaurant Service Implementation**
   - Golang service skeleton
   - REST API handlers for stores/locations
   - Database connection pooling
   - Error handling middleware

2. **Service Registration**
   - Add Traefik labels to service containers
   - Configure routing rules in docker-compose
   - Test end-to-end request flow

3. **Development Workflow**
   - Hot reload setup for Go services
   - Integration testing framework
   - API documentation with Swagger

## Troubleshooting

### PostgreSQL won't start
```bash
# Check if port 5432 is already in use
lsof -i :5432

# Reset volumes
make db-reset
```

### RabbitMQ management UI not accessible
```bash
# Check container status
docker-compose ps

# Check logs
docker-compose logs rabbitmq
```

### Migrations fail
```bash
# Install golang-migrate if missing
brew install golang-migrate  # macOS
# or
go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest

# Check database connectivity
psql postgresql://deliveryx:deliveryx_dev_pass@localhost:5432/deliveryx_restaurant
```

## Access Points

| Service              | URL                          | Credentials                    |
|---------------------|------------------------------|--------------------------------|
| PostgreSQL          | localhost:5432               | deliveryx / deliveryx_dev_pass |
| RabbitMQ AMQP       | localhost:5672               | deliveryx / deliveryx_dev_pass |
| RabbitMQ Management | http://localhost:15672       | deliveryx / deliveryx_dev_pass |
| Traefik Dashboard   | http://localhost:8080        | No auth                        |
| API Gateway         | http://localhost:80          | N/A (services not running yet) |

## Database Connection Strings

```bash
# Restaurant Service
postgresql://deliveryx:deliveryx_dev_pass@localhost:5432/deliveryx_restaurant?sslmode=disable

# Menu Service
postgresql://deliveryx:deliveryx_dev_pass@localhost:5432/deliveryx_menu?sslmode=disable

# Approval Service
postgresql://deliveryx:deliveryx_dev_pass@localhost:5432/deliveryx_approval?sslmode=disable
```

## Resources Used

- PostgreSQL: ~200MB RAM, 1 CPU
- RabbitMQ: ~150MB RAM, 1 CPU
- Traefik: ~50MB RAM, minimal CPU
- **Total**: ~400MB RAM for infrastructure

## Version Information

- PostgreSQL: 16-alpine
- RabbitMQ: 3.12-management-alpine
- Traefik: v2.10
- golang-migrate: v4 (external tool)
