Epic 9: Infrastructure & DevOps
US-9.1: Setup PostgreSQL Databases
As a DevOps engineer
I want separate PostgreSQL databases for each service
So that services are properly isolated
Acceptance Criteria:

Create database: deliveryx_restaurant
Create database: deliveryx_menu
Create database: deliveryx_approval
Run migration scripts to create all tables
Seed predefined data (attribute groups, attributes)

Technical Notes:

Use golang-migrate or similar tool
Store migrations in /migrations directory per service


US-9.2: Setup API Gateway
As a DevOps engineer
I want an API Gateway to route requests to services
So that mobile app has single entry point
Acceptance Criteria:

Configure Kong or Traefik gateway
Route /api/v1/stores/* → Restaurant Service
Route /api/v1/locations/* → Restaurant Service
Route /api/v1/menus/* → Menu Service
Route /api/v1/products/* → Menu Service
Route /api/v1/collections/* → Menu Service
Route /api/v1/attribute-groups/* → Menu Service
Route /api/v1/media/* → Media Service
Route /api/v1/approvals/* → Approval Service

Technical Notes:

Configure rate limiting
Setup CORS headers
Enable request logging


US-9.3: Setup Message Queue
As a DevOps engineer
I want RabbitMQ or SQS for async communication
So that services can communicate via events
Acceptance Criteria:

Install/configure RabbitMQ or AWS SQS
Create queue: menu-submitted (for approval workflow)
Configure retry and dead-letter queues
Menu Service publishes to queue on submit
Approval Service consumes from queue

Technical Notes:

Use appropriate Go library (amqp or AWS SDK)
