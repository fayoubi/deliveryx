Epic 5: Menu Service - Menu Composition
US-5.1: Add Product to Menu Collection
As an owner
I want to add a product to a collection in my menu
So that customers can see and order this product
Acceptance Criteria:

Owner can POST to /api/v1/menus/{menu_id}/products
System accepts: product_id, collection_id, section_id (optional), position
System validates menu is in "draft" status
System validates product and collection exist
System validates product isn't already in menu (unique constraint)
System creates record in menu_products table
System returns 201 Created

Technical Notes:

Endpoint: POST /api/v1/menus/{menu_id}/products
Insert into menu_products junction table


US-5.2: Remove Product from Menu
As an owner
I want to remove a product from my menu
So that I can adjust my menu composition
Acceptance Criteria:

Owner can DELETE /api/v1/menus/{menu_id}/products/{product_id}
System validates menu is in "draft" status
System removes association from menu_products table
Product itself remains in products table (orphaned)
System returns 204 No Content
System returns 404 if association doesn't exist

Technical Notes:

Endpoint: DELETE /api/v1/menus/{menu_id}/products/{product_id}


US-5.3: Reorder Products in Collection
As an owner
I want to change product display order within a collection
So that customers see products in my preferred sequence
Acceptance Criteria:

Owner can PUT to /api/v1/collections/{collection_id}/products/reorder
System accepts array: [{product_id, position}, ...]
System updates position in menu_products table
System validates all products belong to collection
System returns 200 OK

Technical Notes:

Endpoint: PUT /api/v1/collections/{collection_id}/products/reorder
