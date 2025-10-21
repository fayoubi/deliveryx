Epic 7: Menu Service - Menu Retrieval
US-7.1: Get Complete Menu
As an owner or system
I want to retrieve the full menu structure
So that I can display it in the app
Acceptance Criteria:

System can GET /api/v1/menus/{menu_id}
Query params: include_products=true, include_categories=true, include_options=true
System returns menu with nested collections, sections, products, attributes
Response follows Glovo JSON schema format
System returns 200 OK
System returns 404 if menu doesn't exist

Technical Notes:

Endpoint: GET /api/v1/menus/{menu_id}
Complex join query across multiple tables
Transform relational data to Glovo JSON format
