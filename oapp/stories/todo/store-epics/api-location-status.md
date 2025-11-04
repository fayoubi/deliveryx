### NEED GROOMING.

  1. Database Migration Strategy

  - My Recommendation: Create a new migration 000004_add_in_service_to_locations to maintain migration
  history and allow rollback if needed.

  2. Existing Locations - Backfill Strategy

  - My Recommendation: Option A (default true) - matches the story requirement and is least disruptive.

  3. Update Location Endpoint - Does it Exist?

  - Observation: I don't see a PUT /api/v1/locations/{location_id} endpoint in the current code (only
  operating hours can be updated).
  - Question: Should we add this endpoint as part of this story to allow updating the in_service status?
  - Options:
    - A) Add full UpdateLocation endpoint (can update address, city, phone, AND in_service)
    - B) Add dedicated PATCH /api/v1/locations/{location_id}/status endpoint (only toggles in_service)
    - C) Just add the field to the model/DB and wait for a future story for the update endpoint
  - My Recommendation: Option A - Add full UpdateLocation endpoint since it's a common CRUD operation
  that's currently missing.

  4. Response Behavior

  - My Recommendation: Yes - include it in all responses for consistency (even though it's optional in
  POST/PUT payloads).

  5. Filtering by Status

  - My Recommendation: No for this story (keep scope focused), but easy to add later if needed.

  6. Validation Rules

  - My Recommendation: No validation for MVP - allow any location to toggle status freely.

  7. Is_Active vs In_Service

  - Observation: There's already an is_active field in the stores table. Should locations also have an
  is_active field, or is in_service meant to replace that concept?
  - Question: What's the semantic difference?
    - is_active = location exists in system (soft delete)?
    - in_service = location is currently operational/accepting orders?
  - My Recommendation: Clarify the distinction to avoid confusion. My assumption is in_service is the
  operational status (can customers order from here now?).

  8. Postman Tests - New Endpoints

  The story says "update all locations endpoints" - currently we have:
  - ✅ POST /stores/{store_id}/locations (create)
  - ✅ GET /locations/{location_id} (read)
  - ❌ PUT /locations/{location_id} (update - DOESN'T EXIST)
  - ❌ DELETE /locations/{location_id} (delete - DOESN'T EXIST)

  Question: Should we add Update and Delete endpoints as part of "all locations endpoints"?
  - My Recommendation: Add Update (PUT) for this story since we need to modify in_service. Skip Delete
  unless you want it.

  ---
  Summary of My Assumptions (if you want me to proceed)

  Unless you tell me otherwise, I'll assume:

  1. ✅ New migration file: 000004_add_in_service_to_locations.up.sql
  2. ✅ Default value: true (existing locations stay active)
  3. ✅ Add PUT /api/v1/locations/{location_id} endpoint to update location (including in_service)
  4. ✅ Return in_service in all location responses
  5. ❌ No filtering by status (future enhancement)
  6. ❌ No validation rules (allow free toggling)
  7. ✅ in_service = operational status (different from soft delete)
  8. ✅ Add Update endpoint, skip Delete endpoint

  Does this align with your expectations, or would you like me to adjust any of these assumptions?



Given a location can be created using the POST /stores/{store_id}/locations endpoint.
Given a Location can be online (in service) or offline (not in service).
Given the current request body looks as follows:
{
  "address": "string",
  "city": "string",
  "postal_code": "string",
  "phone": "string",
  "location_manager": "string",
  "latitude": 0,
  "longitude": 0
}
when now then expect the following;
- Update the deliveryx_restaurant.locations table to add an attribute in_service {true, false}
- online = in_service:true; offline = in_service:false.
- default in_service:true.
- update all locations endpoints to ensure we account for the new attribute.
- Payload should not require the attribute (optional; since default is true).
- Update the collection under tests to ensure the new endpoints are included in the testing collection.