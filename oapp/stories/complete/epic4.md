Epic 4: Menu Service - Product Management
US-4.1: Create Product
As an owner
I want to create a product for my location
So that I can add items to sell
Acceptance Criteria:

Owner can POST to /api/v1/locations/{location_id}/products
System accepts: name, description, price, category, image_url, attribute_group_ids[]
System validates required fields (name, price)
System validates price > 0
System generates unique product_id (UUID)
System creates associations in product_attribute_groups table
System returns 201 Created with product details
Product is created with is_available: true by default

Technical Notes:

Endpoint: POST /api/v1/locations/{location_id}/products
Insert into products table + product_attribute_groups junction table


US-4.2: Get Product Details
As an owner
I want to view product information
So that I can review product details
Acceptance Criteria:

Owner can GET /api/v1/products/{product_id}
System returns 200 OK with product details
Response includes associated attribute_group_ids
System returns 404 if product doesn't exist

Technical Notes:

Endpoint: GET /api/v1/products/{product_id}
Join with product_attribute_groups


US-4.3: Update Product
As an owner
I want to edit product details
So that I can correct information or change attributes
Acceptance Criteria:

Owner can PUT to /api/v1/products/{product_id}
System allows updates only if product's menu is in "draft" status
System validates field constraints
System updates updated_at timestamp
System returns 200 OK with updated product
System returns 400 if menu is not in draft

Technical Notes:

Endpoint: PUT /api/v1/products/{product_id}
Check menu status before allowing update


US-4.4: Delete Product
As an owner
I want to delete a product
So that I can remove items I no longer offer
Acceptance Criteria:

Owner can DELETE /api/v1/products/{product_id}
System validates product's menu is in "draft" status
System removes product and all associations
System returns 204 No Content
System returns 404 if product doesn't exist
System returns 400 if menu is not in draft

Technical Notes:

Endpoint: DELETE /api/v1/products/{product_id}


US-4.5: Toggle Product Availability
As an owner
I want to activate or deactivate a product
So that I can control what's visible to customers
Acceptance Criteria:

Owner can PATCH to /api/v1/products/{product_id}/availability
System accepts: {is_available: boolean}
System updates product's is_available field
System allows toggle even if menu is "active"
Change is immediate (no approval needed)
System returns 200 OK with updated product
System returns 404 if product doesn't exist

Technical Notes:

Endpoint: PATCH /api/v1/products/{product_id}/availability
This is the ONLY product modification allowed post-approval
