Epic 2: Menu Service - Menu Initialization
US-2.1: Create Draft Menu
As an owner
I want to create a draft menu for my location
So that I can start building my product catalog
Acceptance Criteria:

Owner can POST to /api/v1/locations/{location_id}/menus
System creates menu with status "draft"
System generates unique menu_id (UUID)
System validates location exists
System returns 201 Created with menu_id and status
System enforces one menu per location

Technical Notes:

Endpoint: POST /api/v1/locations/{location_id}/menus
Check for existing menu per location


US-2.2: Seed Predefined Attribute Groups
As a system administrator
I want predefined attribute groups seeded in the database
So that owners can select from standard options
Acceptance Criteria:

Database contains 3 attribute groups: Size, Cuisson, Color
Size group has attributes: S (+0), M (+20), L (+40), XL (+60)
Cuisson group has attributes: Cru, Bien cuit, Brûlé (all +0)
Color group has attributes: Blue, Red, Green, Black, White (all +0)
All marked as system_defined: true

Technical Notes:

Migration script or seed data
Run once during initial deployment


US-2.3: List Attribute Groups
As an owner
I want to view available attribute groups
So that I can select options for my products
Acceptance Criteria:

Owner can GET /api/v1/attribute-groups
System returns list of all attribute groups
Each group includes: id, name, min_selections, max_selections, is_required
System returns 200 OK

Technical Notes:

Endpoint: GET /api/v1/attribute-groups
Read-only for MVP


US-2.4: Get Attributes for Group
As an owner
I want to view attributes within a group
So that I know what options are available
Acceptance Criteria:

Owner can GET /api/v1/attribute-groups/{id}/attributes
System returns list of attributes: id, name, price_impact, is_default
System returns 200 OK
System returns 404 if group doesn't exist

Technical Notes:

Endpoint: GET /api/v1/attribute-groups/{id}/attributes
