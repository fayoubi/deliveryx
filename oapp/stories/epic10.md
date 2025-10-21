Epic 10: Testing & Documentation
US-10.1: API Documentation
As a developer
I want OpenAPI/Swagger documentation
So that API contracts are clear
Acceptance Criteria:

Generate Swagger docs for each service
Document all endpoints with request/response examples
Include error responses
Host Swagger UI for each service

Technical Notes:

Use Swag or similar tool to generate from code annotations


US-10.2: Integration Tests
As a developer
I want integration tests for critical flows
So that I ensure system works end-to-end
Acceptance Criteria:

Test: Complete onboarding flow (store → location → menu → submit)
Test: Menu approval flow
Test: Product availability toggle
Tests run against test database
All tests pass before deployment

Technical Notes:

Use Go testing package
Setup test fixtures and teardown
