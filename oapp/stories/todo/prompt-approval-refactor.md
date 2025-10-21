# Story Name: Migrate Approval Service (And Deprecate) to Menu Service

## TLDR

Phase 1 established the foundational infrastructure for DeliveryX running **locally** using Docker. The setup includes:
- 3 isolated PostgreSQL databases (restaurant, menu, approval services)
- RabbitMQ message broker for async communication
- Traefik API Gateway for request routing
- Complete database schemas with migrations
- Makefile for easy infrastructure management

## Specific Context:
Key Benefits of This Architecture
Decoupling: Menu submission doesn't block on approval processing
Reliability: Messages are durable and can be retried
Scalability: Multiple approval service instances can process events
Fault Tolerance: Dead letter queue handles failed messages
Observability: Management UI provides queue monitoring
The RabbitMQ integration is specifically designed for the menu approval workflow, making it a critical component for the restaurant onboarding process where menus need to be reviewed before going live on the platform.


## Scope / Goal:
In the scope of the Approval Service There are 3 endpoints and 1 table (isolated database).
We would like to consolidate this service into the Menu Service (Only Menus are approved today, nothing else).

## Acceptance Criteria
AC1: We need to preserve the Benefits of the Queues but refactor the code to ensure we preserve the Functionality end to end. 

AC2: Infrastructure or naming changes to be applied on resources to preserve standards given the approval service is deprecated but the relevant functionality is now present in the Menu Service.

AC3: We need to move the endpoints and routes to the Menu Service and Deprecate the Approval Service.

AC4: http://localhost:8090/#/ should be updated to reflect the new scheme.

AC5: Last Step: After all the tests have passed, delete all the resources and infrastructure that points to the approval Service entirely. We need to update all the documenation under the /tests  directory to ensure Postman and all the Read me Files in the /docs dir are now using the new endpoints / routes in the menu Service.

