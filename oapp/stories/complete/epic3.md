Epic 3: Menu Service - Collection Management
US-3.1: Add Collection to Menu
As an owner
I want to add a collection (category) to my menu
So that I can organize products into groups
Acceptance Criteria:

Owner can POST to /api/v1/menus/{menu_id}/collections
System accepts: name (from predefined list), position, image_url (optional)
System validates menu exists and is in "draft" status
System generates unique collection_id (UUID)
System returns 201 Created with collection details

Technical Notes:

Endpoint: POST /api/v1/menus/{menu_id}/collections
Validate name against predefined list: Pizzas, Burgers, Sides, Desserts, Drinks, Salads, Breakfast, Sandwiches, Pasta, Seafood


US-3.2: Delete Collection
As an owner
I want to remove a collection from my menu
So that I can reorganize my menu structure
Acceptance Criteria:

Owner can DELETE /api/v1/collections/{collection_id}
System validates menu is in "draft" status
System removes collection and cascades to sections/products associations
System returns 204 No Content
System returns 404 if collection doesn't exist
System returns 400 if menu is not in draft

Technical Notes:

Endpoint: DELETE /api/v1/collections/{collection_id}
Cascade delete handled by foreign key constraints


US-3.3: Reorder Collections
As an owner
I want to change the display order of collections
So that customers see categories in my preferred order
Acceptance Criteria:

Owner can PUT to /api/v1/menus/{menu_id}/collections/reorder
System accepts array: [{collection_id, position}, ...]
System updates position for each collection
System validates all collection_ids belong to menu
System returns 200 OK

Technical Notes:

Endpoint: PUT /api/v1/menus/{menu_id}/collections/reorder
