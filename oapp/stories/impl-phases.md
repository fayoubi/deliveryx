Backend Implementation Plan

  Phase 1: Foundation & Infrastructure (Epic 9)

  1. Database Setup
    - Create 3 PostgreSQL databases: deliveryx_restaurant, deliveryx_menu,
  deliveryx_approval
    - Setup migration framework (golang-migrate)
    - Create all table schemas
  2. Message Queue
    - Setup RabbitMQ/AWS SQS
    - Configure queues: menu-submitted with DLQ
  3. API Gateway
    - Deploy Kong/Traefik
    - Configure routing rules, CORS, rate limiting

  Phase 2: Core Services Development

  A. Restaurant Service (Epic 1)

  - Database Schema: stores, locations, operating_hours
  - Endpoints:
    - POST/GET/PUT /api/v1/stores
    - POST/GET /api/v1/stores/{id}/locations
    - PUT/GET /api/v1/locations/{id}/operating-hours

  B. Menu Service (Epics 2-7)

  - Database Schema: menus, products, collections, sections, attribute_groups, attributes,
  product_attribute_groups, menu_products
  - Epic 2: Menu initialization & attribute groups seeding
  - Epic 3: Collection management (add/delete/reorder)
  - Epic 4: Product CRUD + availability toggle
  - Epic 5: Menu composition (add products to collections, reordering)
  - Epic 6: Menu submission & status tracking
  - Epic 7: Complete menu retrieval (transform to Glovo JSON format)

  C. Approval Service (Epic 6)

  - Database Schema: Track approval workflow state
  - Queue Consumer: Listen to menu-submitted events
  - Endpoints:
    - POST /api/v1/approvals/menus/{id}/approve
    - POST /api/v1/approvals/menus/{id}/reject

  D. Media Service (Epic 8)

  - AWS S3 Integration
  - Endpoint: POST /api/v1/media/upload-url (pre-signed URLs)

  Phase 3: Integration & Testing (Epic 10)

  1. OpenAPI/Swagger documentation for all services
  2. Integration tests for critical flows
  3. End-to-end testing

  Implementation Order

  1. Infrastructure (databases, queue, gateway)
  2. Restaurant Service (stores & locations)
  3. Menu Service core (products, collections)
  4. Menu Service workflow (submission)
  5. Approval Service
  6. Media Service
  7. Testing & Documentation

  Key Technical Decisions

  - Language: Golang for all services
  - Database: PostgreSQL (3 separate databases for isolation)
  - Messaging: RabbitMQ or AWS SQS
  - Storage: AWS S3 for media
  - API Gateway: Kong or Traefik
  - Documentation: Swagger/OpenAPI
