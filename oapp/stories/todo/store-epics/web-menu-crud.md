# Story: Menu CRUD Operations in Admin Portal

## User Story
**As an** admin user
**I want to** create, edit, and delete menus for my restaurant locations
**So that** I can manage the menu lifecycle without using API tools

## Context
- Each location can have **one menu** (1:1 relationship)
- Menus have lifecycle: draft → pending_review → approved/rejected → active
- Previous story (`web-menu-display1.md`) implemented read-only menu viewing
- This story adds create, edit, and delete operations
- Menu content (collections/products) management is **out of scope** for this story

## Current State
- Admin portal displays menus in read-only mode
- "+ Create Menu" button exists but needs implementation
- No edit or delete functionality for menus
- Menu Service API has `POST /locations/{location_id}/menus` endpoint
- **API GAPS IDENTIFIED** (see API Requirements section)

## Target URL
`http://localhost/admin/stores/{store_id}` - Store details page with locations and menus

---

## 🚨 CRITICAL QUESTIONS & GAPS TO RESOLVE

### API Gaps Identified

#### ❌ Gap 1: No DELETE Menu Endpoint
**Current State:** Menu Service OpenAPI spec has no `DELETE /menus/{menu_id}` endpoint

**Questions:**
- [ ] **Q1.1**: Should we add `DELETE /api/v1/menus/{menu_id}` to Menu Service?
- [ ] **Q1.2**: What should happen to menu_products and collections when menu is deleted?
  - Option A: CASCADE DELETE (already implemented in database)
  - Option B: Soft delete (set status to 'deleted')
  - Option C: Prevent deletion if menu has content
- [ ] **Q1.3**: Can we delete menus in any status, or only 'draft'?
  - Recommended: Only allow deletion of 'draft' and 'rejected' menus
- [ ] **Q1.4**: Should deletion cascade to products, or just unlink them?
  - Note: Products belong to locations, not menus
  - Menus reference products via menu_products junction table

**Decision Needed:** Add DELETE endpoint to Menu Service API

---

#### ❌ Gap 2: No UPDATE Menu Endpoint
**Current State:** Menu Service OpenAPI spec has no `PUT /PATCH /menus/{menu_id}` endpoint

**Questions:**
- [ ] **Q2.1**: What fields should be editable for a menu?
  - Menu entity currently only has: menu_id, location_id, status, timestamps, rejection_reason
  - There are no "name" or "description" fields on the menu itself
  - Is "edit menu" just for changing status, or should there be metadata fields?
- [ ] **Q2.2**: Should we add name/description fields to menus table?
  - Option A: Add `name` and `description` columns to menus table
  - Option B: Menu metadata comes from location (menu inherits location name)
  - Option C: No menu-level metadata, just status management
- [ ] **Q2.3**: Can status be directly updated via PUT, or only via workflow endpoints?
  - Existing: `POST /menus/{id}/submit`, `POST /menus/{id}/approve`, `POST /menus/{id}/reject`
  - Should we allow direct status changes, or enforce workflow?

**Decision Needed:** Define what "edit menu" means - is it metadata, status, or both?

---

### UX/Workflow Questions

#### 🤔 Question Set 3: Menu Creation Flow
- [ ] **Q3.1**: When creating a menu, what initial data is required?
  - Currently: Just location_id (menu is created empty)
  - Should we require: name? description? initial collections?
- [ ] **Q3.2**: After clicking "+ Create Menu", should we:
  - Option A: Immediately create empty draft menu (current behavior)
  - Option B: Open modal for menu name/description, then create
  - Option C: Create menu AND immediately open menu builder UI
- [ ] **Q3.3**: What happens if user clicks "+ Create Menu" twice rapidly?
  - Location can only have one menu (constraint exists)
  - Should button be disabled during creation?
  - How to handle 409 Conflict error gracefully?

**Recommendation:** Option A for simplicity, with disabled button during creation

---

#### 🤔 Question Set 4: Menu Deletion Flow
- [ ] **Q4.1**: Should delete be available for all menu statuses, or only drafts?
  - Recommended: Only 'draft' and 'rejected' (not approved/active)
- [ ] **Q4.2**: What confirmation message should we show?
  - Option A: Simple: "Delete this menu? This cannot be undone."
  - Option B: Detailed: "Delete menu with X collections and Y products?"
  - Option C: Scary: "This will permanently delete all collections and products!"
- [ ] **Q4.3**: If menu has collections/products, should we:
  - Option A: Prevent deletion, show error
  - Option B: Cascade delete everything (including products)
  - Option C: Cascade delete collections, but unlink products (keep products)

**Recommendation:** Option C - products are reusable, but collections are menu-specific

---

#### 🤔 Question Set 5: Menu Editing Flow
- [ ] **Q5.1**: What does "edit menu" mean in this context?
  - Option A: Edit menu metadata (name, description) - requires schema change
  - Option B: Edit menu status (draft → pending_review, etc.)
  - Option C: Edit menu content (collections/products) - different story
  - Option D: No edit needed, only create/delete/view
- [ ] **Q5.2**: Should editing be modal-based or in-line?
- [ ] **Q5.3**: Should edit be a pencil icon, or "Manage Menu" button?

**Decision Needed:** Define scope of "edit menu" - this story may just need create/delete

---

#### 🤔 Question Set 6: Menu Status Badge Behavior
- [ ] **Q6.1**: Should clicking the status badge do anything?
  - Option A: Opens status history/timeline modal
  - Option B: Opens edit status modal (if allowed)
  - Option C: No action, purely informational
- [ ] **Q6.2**: Should we show timestamps on hover?
  - Example: "Draft (created 2 days ago)" or "Approved by Admin on Jan 15"

**Recommendation:** Option C for now, status management in future story

---

### Data Model Questions

#### 🤔 Question Set 7: Menu Metadata
- [ ] **Q7.1**: Should menus have names separate from location?
  - Example: Location "Austin - Downtown" could have menus "Summer Menu 2025" vs "Winter Menu 2025"
  - Or: Always just "Menu for [Location Name]"?
- [ ] **Q7.2**: Should menus support versioning?
  - Scenario: Edit menu while active menu is live
  - Need: Draft new version, submit, approve, then swap
- [ ] **Q7.3**: Can locations have multiple menus (seasonal, special events)?
  - Current: One menu per location (constraint in place)
  - Future: Multiple menus with effective_date ranges?

**Decision Needed:** Clarify if menu naming/versioning is needed now or later

---

## Acceptance Criteria

### AC1: Create Menu Button (Enhancement)
**Status:** Partially implemented in `web-menu-display1.md`

- [ ] Location without menu shows "+ Create Menu" button in Actions column
- [ ] Button is **disabled** with loading spinner during creation
- [ ] On click:
  - Calls `POST /api/v1/locations/{location_id}/menus`
  - Shows loading state
  - On success:
    - Button changes to "View Menu"
    - Success toast: "Menu created successfully"
    - Menu section appears with "Draft" badge
  - On error:
    - Shows error toast with API message
    - Re-enables button
  - On 409 Conflict (menu already exists):
    - Show specific message: "This location already has a menu"
    - Button changes to "View Menu" (menu exists but wasn't loaded)

---

### AC2: Delete Menu Button
- [ ] Locations **with menus** show "Delete Menu" button in Actions column (trash icon or text)
- [ ] Clicking "Delete Menu" opens confirmation modal:
  - **Title:** "Delete Menu?"
  - **Message:** ⚠️ "Are you sure you want to delete this menu? This will remove all collections and menu items. This action cannot be undone."
  - **Buttons:** "Cancel" (secondary) | "Delete Menu" (danger/red)
- [ ] On confirm:
  - Calls `DELETE /api/v1/menus/{menu_id}` (**NEW ENDPOINT REQUIRED**)
  - Shows loading state on delete button
  - On success:
    - Closes modal
    - Success toast: "Menu deleted successfully"
    - "Delete Menu" button changes to "+ Create Menu"
    - Menu section disappears
  - On 400/403 error (status not allowed):
    - Error toast: "Cannot delete menu in [status] status"
  - On 409 error (has dependencies):
    - Error toast with specific message from API

---

### AC3: API Error Handling
- [ ] Handle all error scenarios gracefully:
  - **400 Bad Request:** Show validation error message
  - **404 Not Found:** "Menu not found" or "Location not found"
  - **409 Conflict:** Show specific conflict message (already exists, has dependencies, etc.)
  - **500 Server Error:** "Server error. Please try again later."
  - **Network Error:** "Unable to connect to server. Please check your connection."

---

### AC4: Optimistic Updates
- [ ] **Create Menu:** Optimistically add menu with "Draft" badge, rollback on error
- [ ] **Delete Menu:** Optimistically remove menu, rollback on error

---

### AC5: Button Visibility Logic
**Location Action Buttons:**
```
If menu exists:
  - [View Menu] (existing)
  - [Delete Menu] (new)

If no menu:
  - [+ Create Menu] (existing, now enhanced)
```

---

### AC6: Status-Based Deletion Rules
**Backend Requirement:**
- [ ] DELETE endpoint should validate menu status before deletion
- [ ] Only allow deletion of menus with status: `draft` or `rejected`
- [ ] Return 400 Bad Request for other statuses with message:
  ```json
  {
    "error": "Cannot delete menu in approved status. Only draft and rejected menus can be deleted."
  }
  ```

---

### AC7: Cascade Deletion Behavior
**Backend Requirement:**
- [ ] When menu is deleted:
  - **Cascade DELETE:** menu_products (junction table)
  - **Cascade DELETE:** collections (belong to menu)
  - **Do NOT delete:** products (belong to location, reusable)
  - **Do NOT delete:** attributes/attribute_groups (system-wide)

**Database Schema:** Already has `ON DELETE CASCADE` for menu_products and collections

---

## API Requirements

### 🆕 NEW Backend Endpoint Required

#### DELETE /api/v1/menus/{menu_id}
**Purpose:** Delete a menu and its collections

**Request:**
```http
DELETE /api/v1/menus/{menu_id}
```

**Success Response (204 No Content):**
```http
HTTP/1.1 204 No Content
```

**Error Responses:**

**400 Bad Request** - Invalid status for deletion
```json
{
  "error": "Cannot delete menu in approved status. Only draft and rejected menus can be deleted.",
  "code": "INVALID_STATUS_FOR_DELETION",
  "details": {
    "current_status": "approved",
    "allowed_statuses": ["draft", "rejected"]
  }
}
```

**404 Not Found** - Menu doesn't exist
```json
{
  "error": "Menu not found"
}
```

**409 Conflict** - Has dependencies (if we add business rule)
```json
{
  "error": "Cannot delete menu with active submissions",
  "code": "MENU_HAS_DEPENDENCIES"
}
```

---

### 🆕 OPTIONAL Backend Endpoint (If Editing Needed)

#### PUT /api/v1/menus/{menu_id}
**Purpose:** Update menu metadata (if we add name/description fields)

**Request:**
```http
PUT /api/v1/menus/{menu_id}
Content-Type: application/json

{
  "name": "Summer Menu 2025",
  "description": "Seasonal menu featuring fresh local ingredients"
}
```

**Response:**
```json
{
  "menu_id": "uuid",
  "location_id": "uuid",
  "name": "Summer Menu 2025",
  "description": "Seasonal menu featuring fresh local ingredients",
  "status": "draft",
  "created_at": "2025-01-15T10:00:00Z",
  "updated_at": "2025-01-15T14:30:00Z"
}
```

**Note:** This requires schema migration to add `name` and `description` columns to `menus` table.

**Questions to Answer:**
- [ ] Do we need menu-level metadata (name/description)?
- [ ] Or is menu just a container for collections, identified by location?

---

### ✅ Existing Endpoints (No Changes)

#### POST /api/v1/locations/{location_id}/menus
**Already exists** - Creates empty draft menu for location

#### GET /api/v1/menus/{menu_id}
**Already exists** - Retrieves full menu with collections and products

---

## Database Schema Changes

### Option A: No Schema Changes (Recommended for MVP)
- Use existing schema
- Menus identified by location: "Menu for [Location Name]"
- Only add DELETE endpoint to API

### Option B: Add Menu Metadata (Future Enhancement)
**Migration:** `000XXX_add_menu_metadata.up.sql`
```sql
ALTER TABLE menus ADD COLUMN name VARCHAR(255);
ALTER TABLE menus ADD COLUMN description TEXT;
ALTER TABLE menus ADD COLUMN is_active BOOLEAN DEFAULT false;
```

**Decision Needed:** Do we need this now or later?

---

## UI/UX Specifications

### Delete Menu Button Placement

**Desktop Table View:**
```
┌─────────────────────────────────────────────────────────────┐
│ Location: Austin, 101 Main St                               │
│ Phone: +1-512-123-4567                                      │
│ [Edit Location] [Delete Location] [View Menu ▼] [🗑️ Delete Menu] │
└─────────────────────────────────────────────────────────────┘
```

**Mobile Card View:**
```
┌─────────────────────────────────┐
│ Austin, 101 Main St             │
│ +1-512-123-4567                 │
│                                 │
│ [Edit] [Delete]                 │
│ [View Menu ▼] [🗑️ Delete Menu]  │
└─────────────────────────────────┘
```

---

### Delete Confirmation Modal

```
┌─────────────────────────────────────────────────┐
│  ⚠️  Delete Menu?                               │
├─────────────────────────────────────────────────┤
│                                                  │
│  Are you sure you want to delete this menu?     │
│                                                  │
│  This will remove:                               │
│  • All collections (e.g., Appetizers, Mains)    │
│  • All menu product links                       │
│                                                  │
│  Products will remain in your product library.  │
│                                                  │
│  ⚠️ This action cannot be undone.               │
│                                                  │
├─────────────────────────────────────────────────┤
│                     [Cancel] [Delete Menu]      │
└─────────────────────────────────────────────────┘
```

**Delete Button Styling:**
- Background: Red (danger)
- Loading state: Shows spinner, text "Deleting..."
- Disabled state while loading

---

## Edge Cases

### Edge Case 1: Menu Already Exists
**Scenario:** User clicks "+ Create Menu" but menu was just created by another session

**Expected Behavior:**
- API returns 409 Conflict or 400 Bad Request
- Show error toast: "This location already has a menu"
- Refresh location data to show existing menu
- Button changes to "View Menu"

---

### Edge Case 2: Menu Deleted While Viewing
**Scenario:** User has menu expanded, another admin deletes it

**Expected Behavior:**
- Menu display remains visible (no real-time updates)
- Next action (refresh, navigate away and back) shows menu as gone
- **Future:** Consider WebSocket/polling for real-time updates

---

### Edge Case 3: Network Failure During Create
**Scenario:** POST request sent but no response received (timeout/disconnect)

**Expected Behavior:**
- Show error toast: "Request timed out. Please refresh to check if menu was created."
- Do not optimistically create menu
- Re-enable "+ Create Menu" button

---

### Edge Case 4: Delete Approved Menu
**Scenario:** User tries to delete menu with status "approved" or "active"

**Expected Behavior:**
- Backend returns 400 Bad Request
- Show error toast: "Cannot delete approved menus. Only draft and rejected menus can be deleted."
- **Question:** Should we hide delete button for non-draft menus?
  - Option A: Hide button entirely for approved/active menus
  - Option B: Show button but disable it with tooltip
  - Option C: Show button, let backend reject

**Recommendation:** Option A - only show delete button for draft/rejected status

---

### Edge Case 5: Menu Has Collections/Products
**Scenario:** Menu has 5 collections with 30 products

**Expected Behavior:**
- Deletion proceeds (CASCADE DELETE handles it)
- Products remain in product library (not deleted)
- Collections are deleted (menu-specific)
- **Optional:** Show counts in confirmation modal:
  - "This menu has 5 collections and 30 products. Are you sure?"

---

## Testing Scenarios

### Scenario 1: Create Menu for New Location
1. Navigate to store details page
2. Find location without menu (shows "+ Create Menu")
3. Click "+ Create Menu"
4. Verify loading state (button disabled, spinner)
5. Verify success toast: "Menu created successfully"
6. Verify button changes to "View Menu"
7. Verify menu section appears with "Draft" badge

---

### Scenario 2: Delete Draft Menu
1. Navigate to location with draft menu
2. Click "Delete Menu" button
3. Verify confirmation modal appears
4. Click "Delete Menu" (red button)
5. Verify loading state on button
6. Verify success toast: "Menu deleted successfully"
7. Verify menu section disappears
8. Verify button changes to "+ Create Menu"

---

### Scenario 3: Attempt to Delete Approved Menu
1. Navigate to location with approved menu
2. Verify "Delete Menu" button is **hidden** or disabled
3. If shown: Click "Delete Menu"
4. Verify error toast: "Cannot delete approved menus"
5. Menu remains visible

---

### Scenario 4: Network Error During Creation
1. Disconnect network
2. Click "+ Create Menu"
3. Verify error toast after timeout
4. Verify button is re-enabled
5. Reconnect network
6. Click "+ Create Menu" again
7. Verify success

---

### Scenario 5: Rapid Double-Click Prevention
1. Click "+ Create Menu"
2. Immediately click again before response
3. Verify only one request is sent (button disabled)
4. Verify single menu created

---

## Out of Scope (Future Iterations)

The following are **NOT included** in this story:

- ❌ Edit menu content (add/remove collections, products)
- ❌ Reorder collections/products
- ❌ Menu versioning (draft new version while keeping active)
- ❌ Menu duplication/cloning
- ❌ Menu templates
- ❌ Bulk operations (delete multiple menus)
- ❌ Menu import/export
- ❌ Menu publish/unpublish workflow (covered in future approval story)
- ❌ Menu scheduling (effective dates, hours)
- ❌ Menu metadata (name, description) - **PENDING DECISION**

---

## Open Questions Summary

### 🔴 HIGH PRIORITY - BLOCKING
- [ ] **Q1.1**: Add `DELETE /api/v1/menus/{menu_id}` endpoint? ✅ YES
- [ ] **Q1.3**: Can we delete menus in any status? ❓ DRAFT + REJECTED ONLY
- [ ] **Q2.1**: What fields should be editable? ❓ NONE FOR NOW vs ADD NAME/DESC?
- [ ] **Q4.3**: What to delete on cascade? ❓ COLLECTIONS YES, PRODUCTS NO

### 🟡 MEDIUM PRIORITY - AFFECTS SCOPE
- [ ] **Q3.2**: Create menu flow - immediate vs modal? ❓ IMMEDIATE (SIMPLER)
- [ ] **Q5.1**: What does "edit menu" mean? ❓ OUT OF SCOPE vs ADD METADATA?
- [ ] **Q7.1**: Should menus have names? ❓ NOT NOW vs ADD COLUMN?

### 🟢 LOW PRIORITY - UX POLISH
- [ ] **Q4.2**: Confirmation message detail level? ❓ SIMPLE vs DETAILED
- [ ] **Q6.1**: Status badge clickable? ❓ NO FOR NOW

---

## Definition of Done

### Backend
- [ ] **MUST HAVE:** `DELETE /api/v1/menus/{menu_id}` endpoint implemented
- [ ] DELETE validates menu status (only draft/rejected)
- [ ] DELETE cascades to collections and menu_products
- [ ] DELETE does NOT delete products
- [ ] Error responses follow API error format
- [ ] OpenAPI spec updated with new endpoint
- [ ] Postman collection updated with DELETE request

### Frontend
- [ ] "+ Create Menu" button properly disables during creation
- [ ] "Delete Menu" button appears for locations with menus
- [ ] Delete confirmation modal implemented
- [ ] Delete button hidden for approved/active menus (status-based visibility)
- [ ] Success/error toasts for all operations
- [ ] Optimistic updates with rollback
- [ ] Loading states prevent double-submission
- [ ] Mobile responsive

### Testing
- [ ] Manual testing of all scenarios completed
- [ ] Error handling tested (400, 404, 409, 500, network errors)
- [ ] Rapid click prevention verified
- [ ] Status-based button visibility verified

### Documentation
- [ ] API documentation updated
- [ ] Postman collection includes new endpoints
- [ ] Frontend README updated if needed

---

## Dependencies

### Blocks
- This story blocks: Menu content management (collections/products CRUD)
- This story blocks: Menu submission workflow

### Blocked By
- None - can start immediately

### Related
- `web-menu-display1.md` - Menu viewing (completed)
- Future: Menu content editing story
- Future: Menu approval workflow story

---

## Estimated Effort

### Backend (Menu Service)
- Add DELETE endpoint: **2-3 hours**
- Status validation logic: **1 hour**
- Testing: **1-2 hours**
- **Total Backend: 4-6 hours**

### Frontend (Admin Portal)
- Delete button + modal: **2-3 hours**
- Create menu enhancement: **1-2 hours**
- Error handling + toasts: **1-2 hours**
- Testing: **2 hours**
- **Total Frontend: 6-9 hours**

### **Grand Total: 10-15 hours** (1.5-2 days)

---

## Next Steps for Product Owner

### 🚨 DECISIONS REQUIRED BEFORE IMPLEMENTATION

1. **Menu Deletion Endpoint**
   - ✅ Approve adding `DELETE /api/v1/menus/{menu_id}` to Menu Service?
   - ❓ Confirm cascade behavior (delete collections, keep products)?
   - ❓ Confirm status restriction (only draft/rejected)?

2. **Menu Editing Scope**
   - ❓ Should menus have name/description fields?
   - ❓ If yes: Add to this story or defer to future?
   - ❓ If no: Is "edit menu" even needed, or just create/delete/view?

3. **UX Preferences**
   - ❓ Delete button always visible, or hidden for approved menus?
   - ❓ Confirmation modal detail level (simple vs verbose)?

### 📋 TO COMPLETE THIS DOCUMENT

Please review and answer the questions marked with ❓ in the following sections:
- [Open Questions Summary](#open-questions-summary)
- All sections marked with **Decision Needed**

Once decisions are made, update this document and mark checkboxes as resolved.

---

**Document Version:** 1.0
**Created:** November 8, 2025
**Status:** ⚠️ AWAITING DECISIONS
**Assigned To:** [Product Owner / Tech Lead]
