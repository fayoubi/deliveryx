Epic 1: Restaurant Service - Store & Location Management
US-1.1: Create Store
As an owner
I want to create my restaurant store with basic information
So that I can start setting up my presence on DeliveryX
Acceptance Criteria:

Owner can POST to /api/v1/stores with name, description, logo_url, phone
System generates unique store_id (UUID)
System validates required fields (name, phone)
System enforces max lengths (name: 255 chars, description: 1000 chars)
System returns 201 Created with store details
System returns 400 Bad Request for validation errors

Technical Notes:

Service: Restaurant Service (Golang)
Database: PostgreSQL
Endpoint: POST /api/v1/stores


US-1.2: Get Store Details
As an owner
I want to retrieve my store information
So that I can view or edit my store details
Acceptance Criteria:

Owner can GET /api/v1/stores/{store_id}
System returns 200 OK with store details
System returns 404 Not Found if store doesn't exist
Response includes all store fields (store_id, name, description, logo_url, phone, timestamps)

Technical Notes:

Endpoint: GET /api/v1/stores/{store_id}


US-1.3: Update Store
As an owner
I want to update my store information
So that I can keep my restaurant details current
Acceptance Criteria:

Owner can PUT to /api/v1/stores/{store_id} with updated fields
System validates field constraints
System updates updated_at timestamp
System returns 200 OK with updated store
System returns 404 if store doesn't exist

Technical Notes:

Endpoint: PUT /api/v1/stores/{store_id}


US-1.4: Create Location
As an owner
I want to add a physical location for my store
So that customers can find and order from this location
Acceptance Criteria:

Owner can POST to /api/v1/stores/{store_id}/locations
System accepts: address, city, postal_code, phone, location_manager, latitude, longitude
System validates required fields (address, city, phone)
System generates unique location_id (UUID)
System returns 201 Created with location details
System returns 404 if store doesn't exist

Technical Notes:

Endpoint: POST /api/v1/stores/{store_id}/locations
Foreign key: location.store_id references stores.store_id


US-1.5: Set Operating Hours
As an owner
I want to define operating hours for my location
So that customers know when I'm open
Acceptance Criteria:

Owner can PUT to /api/v1/locations/{location_id}/operating-hours
System accepts array of 7 day objects (day_of_week, open_time, close_time, is_closed)
System validates time format (HH:mm)
System validates day_of_week enum (MONDAY-SUNDAY)
System replaces all existing hours with new set
System returns 200 OK with updated hours

Technical Notes:

Endpoint: PUT /api/v1/locations/{location_id}/operating-hours
Delete existing hours and insert new ones in transaction


US-1.6: Get Location Details
As an owner
I want to retrieve location information including operating hours
So that I can review my location setup
Acceptance Criteria:

Owner can GET /api/v1/locations/{location_id}
System returns 200 OK with location details
Response includes nested operating_hours array
System returns 404 if location doesn't exist

Technical Notes:

Endpoint: GET /api/v1/locations/{location_id}
Join query to fetch operating_hours
