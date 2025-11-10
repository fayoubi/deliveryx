


## Missing API Endpoints (Spec)

### Cross-cutting
- **IDs**: UUIDv4 strings. Timestamps: ISO-8601 UTC.
- **Content**: Requests/Responses use `application/json; charset=utf-8`.
- **Errors**: Shape `{ "message": "Human-readable message", "code": "MACHINE_CODE", "details": { ... } }`.
  - 400 validation error, 404 not found, 409 conflict (relational constraints), 500 server error.
- **Pagination (list endpoints)**: `page` (default 1), `page_size` (default 20, max 100), `sort`.
- **Sorting**:
  - Allowed fields:
    - Stores: `name`, `created_at` (prefix with `-` for descending)
    - Locations: `city`, `created_at`
  - Defaults: Stores sort by `name` asc; Locations sort by `city` asc, then `address` asc for ties.
- **Filtering**:
  - Stores: `q` (search in name), `phone`.
  - Locations: `city`, `q` (address substring).
- **List Response Envelope**: `{ "items": [], "page": 1, "page_size": 20, "total": 0, "has_next": false }`.
- **Paging guarantees**: Stable, deterministic sorting across pages; response includes `total` and `has_next`.
- **Error Response Format Migration**
    Current error format: {"error": "message"} (see utils.go:9-11)
    Story requires: {"message": "...", "code": "MACHINE_CODE", "details": {...}}
    Update all error responses for consistency. Since this is internal dev,
    breaking changes are acceptable now.
- **Implementation Decisions**:
  - **CASCADE behavior**: Keep ON DELETE CASCADE in database schema as safety net; add application-level 409 check (defense in depth approach).
  - **Sorting tie-breaking**: Accept unindexed address field for location sort tie-breaking (TEXT field indexing is expensive).
  - **Search implementation**: Use case-insensitive ILIKE for `q` parameter searches (better UX).
  - **Empty update validation**: Reject empty PUT request bodies with 400 error (require at least one field to update).
  - **Pagination total**: Compute exact COUNT(*) for MVP; optimize later if performance issues arise.
  - **Phone validation**: Use regex pattern `^[\d\s\-\+\(\)]+$` to accept international formats while preventing invalid data.

### Data Contracts (responses)
- **Store**: `store_id`, `name`, `description?`, `logo_url?`, `phone`, `created_at`, `updated_at`.
- **Location**: `location_id`, `store_id`, `address`, `city`, `postal_code`, `phone`, `location_manager`, `latitude`, `longitude`, `created_at`, `updated_at`.

### Validation (request fields)
- **Store (delete rule)**: Cannot delete if store has locations.
- **Store (create/update)**: `name` required ≤255, `description` ≤1000, `logo_url` valid URL if provided, `phone` basic pattern required.
- **Location update**: Partial update; allowed fields: `address`, `city`, `postal_code`, `phone`, `location_manager`, `latitude` [-90,90], `longitude` [-180,180].
- **Location (delete rule)**: Cannot delete if location has menus; Add internal endpoint in Menu Service: GET /internal/locations/{id}/has-menus returns boolean
- **Location (create reference)**: For completeness, create requires `address`, `city`, `postal_code`, `phone`, `location_manager`, valid `latitude`/`longitude`.

---

## Stores

### GET /api/v1/stores — list all stores
- Query params: `page`, `page_size`, `sort`, `q`, `phone`.
- 200: List envelope with `items` of Store.
- 400: Invalid pagination/sort/filter.
- 500: Server error.

### DELETE /api/v1/stores/{store_id} — delete store
- 204: Successful deletion (no body).
- 404: Store not found.
- 409: Store has locations.
  - Example Message: `{ "message": "Store cannot be deleted while it has locations", "code": "STORE_HAS_LOCATIONS", "details": { "locations_count": 3 } }`.
- Notes:
  - Stores that have a location should NOT be allowed to be deleted.
  - Constraint enforcement: Application returns 409 if locations exist (prevents deletion at API level).
  - Database CASCADE remains in schema as safety net (defense in depth).

---

## Locations

### GET /api/v1/stores/{store_id}/locations — list all locations for a store
- Query params: `page`, `page_size`, `sort`, `city`, `q`.
- 200: List envelope with `items` of Location.
- 404: Store not found.
- 400: Invalid pagination/sort/filter.

### PUT /api/v1/locations/{location_id} — update location details
- Request: Partial update (all fields optional): `address`, `city`, `postal_code`, `phone`, `location_manager`, `latitude`, `longitude`.
- 200: Updated Location.
- 404: Location not found.
- 400: Validation errors (e.g., lat/lng range, phone format).

### DELETE /api/v1/locations/{location_id} — delete location
- 204: Successful deletion (no body).
- 404: Location not found.
- 409: Location has menus.
  - Example error: `{ "message": "Location cannot be deleted while it has menus", "code": "LOCATION_HAS_MENUS", "details": { "menus_count": 2 } }`.
- Notes:
  - Locations that have a Menu associated with them should NOT be allowed to be deleted.
  - The API should return a conflict (409) when a location cannot be deleted due to existing menus.
  - Constraint enforcement: service validates via Menu Service (or equivalent repository check) before delete.
  - Cross-Service Menu Validation for Location Delete: follows microservice patterns, avoids cross-database coupling, and you already have /internal/ endpoints precedent from Menu Service.

---

## Acceptance Criteria
- OpenAPI spec updated to include all endpoints, params, and example payloads.
- List endpoints support pagination, sorting (allowed/default fields defined), filtering; response includes `total` and `has_next`.
- Delete endpoints enforce relational constraints and return 409 with machine-readable `code` and `details`.
- All responses use consistent error shape and content type.
- Listing locations for a non-existent store returns 404.
- Update endpoints return full resource payloads used by the UI.
- Update the collection under tests to ensure the new endpoints are included in the testing collection.
