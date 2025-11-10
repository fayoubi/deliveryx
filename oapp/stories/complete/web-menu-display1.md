# Story: Display Location Menus in Store Details View

## User Story
**As an** admin user
**I want to** view each location's menu in a user-friendly, hierarchical format
**So that** I can see menu content, structure, and approval status without leaving the store details page

## Context
- Each store can have multiple locations
- Each location can have one menu
- Menus contain collections (sections like "Appetizers", "Main Course")
- Collections contain products with names, prices, and attributes
- Menus have statuses: draft, pending_review, approved, rejected
- This is a **read-only view** for now (no editing, just visibility)

## Current State
- Store details page shows locations for a store
- No menu information is currently displayed
- Users have no visibility into menu content or status

## Target URL
`http://localhost/admin/stores/{store_id}` - Store details page with locations list

---

## Acceptance Criteria

### AC1: Menu Display Trigger
- [ ] Each location row/card has a "View Menu" expandable section in the Actions area
- [ ] Clicking "View Menu" expands the menu inline below the location
- [ ] Clicking again collapses the menu
- [ ] Menu data is lazy-loaded only when expanded (not pre-fetched for all locations)

### AC2: No Menu State
- [ ] Locations without menus show a "+ Create Menu" button in Actions (instead of "View Menu")
- [ ] Clicking "+ Create Menu" creates a menu via `POST /api/v1/locations/{location_id}/menus`
- [ ] After creation, the button changes to "View Menu"

### AC3: Menu Status Display
- [ ] Menu status is shown as a colored badge at the top of the menu view
- [ ] Status colors:
  - **Draft** → Gray badge
  - **Pending Review** → Yellow badge
  - **Approved** → Green badge
  - **Rejected** → Red badge

### AC4: Menu Hierarchy Display (Accordion Pattern)
The menu displays with the following structure:

```
📋 Menu (Draft)
  [▼] Appetizers (3 items)
      • Caesar Salad - $8.99
        - Attributes: Size (Small, Large), Dressing (Ranch, Caesar)
      • Garlic Bread - $4.99
        - Attributes: None
      • Wings - $12.99
        - Attributes: Flavor (BBQ, Buffalo, Plain)
  [▶] Main Course (5 items) [collapsed by default]
  [▶] Desserts (2 items) [collapsed by default]
```

**Requirements:**
- [ ] Collections are collapsible accordions
- [ ] First collection expanded by default, rest collapsed
- [ ] Collection header shows: name + item count (e.g., "Appetizers (3 items)")
- [ ] Products display: name, price, attributes (if any)
- [ ] Product attributes shown as list below product name

### AC5: Data to Display
**Menu Level:**
- [ ] Status badge

**Collection Level:**
- [ ] Collection name
- [ ] Item count

**Product Level:**
- [ ] Product name
- [ ] Product price (formatted as currency)
- [ ] Product attributes/customizations (if present)

**Not included in this iteration:**
- Product descriptions
- Product availability status
- Created/updated timestamps
- Edit/delete actions

### AC6: Responsive Design
- [ ] Desktop: Menu expands below location row in table
- [ ] Mobile: Menu expands below location card
- [ ] Accordion pattern works on both mobile and desktop

### AC7: Loading & Error States
- [ ] Show loading spinner while fetching menu
- [ ] Show error message if menu fetch fails
- [ ] Handle empty collections gracefully (show "No items in this section")

---

## API Requirements

### Backend Changes Required

#### 1. Modify Location List Response
**Endpoint:** `GET /api/v1/stores/{store_id}/locations`

**Current Response:**
```json
{
  "items": [
    {
      "location_id": "uuid",
      "store_id": "uuid",
      "address": "...",
      "city": "...",
      "phone": "...",
      "created_at": "..."
    }
  ]
}
```

**New Response (Add menu field):**
```json
{
  "items": [
    {
      "location_id": "uuid",
      "store_id": "uuid",
      "address": "...",
      "city": "...",
      "phone": "...",
      "created_at": "...",
      "menu": {
        "menu_id": "uuid",
        "status": "draft",
        "collections_count": 3,
        "products_count": 15
      }
    }
  ]
}
```

**If no menu exists:**
```json
{
  "location_id": "uuid",
  ...
  "menu": null
}
```

**Implementation Notes:**
- Restaurant Service should call Menu Service internal endpoint to get menu summary
- Use existing `GET /internal/locations/{location_id}/has-menus` or create new endpoint
- Add menu info to each location in the list response

#### 2. Menu Retrieval Endpoint (Already Exists)
**Endpoint:** `GET /api/v1/menus/{menu_id}`

**Response Structure:**
```json
{
  "menu_id": "uuid",
  "location_id": "uuid",
  "status": "draft",
  "collections": [
    {
      "collection_id": "uuid",
      "name": "Appetizers",
      "display_order": 1,
      "products": [
        {
          "product_id": "uuid",
          "name": "Caesar Salad",
          "description": "Fresh romaine...",
          "price": 8.99,
          "attributes": [
            {
              "group_name": "Size",
              "options": ["Small", "Medium", "Large"]
            },
            {
              "group_name": "Dressing",
              "options": ["Ranch", "Caesar", "Italian"]
            }
          ]
        }
      ]
    }
  ]
}
```

**No changes needed** - endpoint already exists

---

## UI/UX Specifications

### Menu Status Badge Colors
```css
Draft          → bg-gray-100 text-gray-700
Pending Review → bg-yellow-100 text-yellow-700
Approved       → bg-green-100 text-green-700
Rejected       → bg-red-100 text-red-700
```

### Menu View Layout (Expanded)
```
┌─────────────────────────────────────────────────────┐
│ Location: Austin, 101 Main St                       │
│ Phone: +1-512-123-4567                              │
│ [Edit] [Delete] [▼ View Menu]                       │
├─────────────────────────────────────────────────────┤
│ ┌─ Menu View (Expanded Below) ─────────────────┐   │
│ │ 📋 Menu Status: [Draft]                       │   │
│ │                                                │   │
│ │ [▼] Appetizers (3 items)                      │   │
│ │     • Caesar Salad - $8.99                    │   │
│ │       - Size: Small, Medium, Large            │   │
│ │       - Dressing: Ranch, Caesar, Italian      │   │
│ │     • Garlic Bread - $4.99                    │   │
│ │     • Wings - $12.99                          │   │
│ │       - Flavor: BBQ, Buffalo, Plain           │   │
│ │                                                │   │
│ │ [▶] Main Course (5 items)                     │   │
│ │                                                │   │
│ │ [▶] Desserts (2 items)                        │   │
│ └────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

### Collapsed State
```
┌─────────────────────────────────────────────────────┐
│ Location: Austin, 101 Main St                       │
│ Phone: +1-512-123-4567                              │
│ [Edit] [Delete] [▶ View Menu]                       │
└─────────────────────────────────────────────────────┘
```

### No Menu State
```
┌─────────────────────────────────────────────────────┐
│ Location: Dallas, 202 Elm St                        │
│ Phone: +1-214-555-1234                              │
│ [Edit] [Delete] [+ Create Menu]                     │
└─────────────────────────────────────────────────────┘
```

---

## Edge Cases

### Empty Menu
- [ ] Menu exists but has no collections → Show "No collections yet"
- [ ] Collection exists but has no products → Show "No items in this section"

### Multiple Locations
- [ ] Only one menu expanded at a time (collapsing others is optional)
- [ ] Expanding menu A while menu B is open → both can be open simultaneously

### API Failures
- [ ] Menu service unavailable → Show "Unable to load menu. Please try again."
- [ ] Menu fetch timeout → Show "Loading timed out. Please try again."

### Large Menus
- [ ] Menu with 10+ collections → All collapsed by default except first
- [ ] Collection with 50+ products → Consider pagination in future iteration (not required now)

---

## Testing Scenarios

### Scenario 1: Location with Approved Menu
1. Navigate to store details page
2. Locate a location with menu
3. Click "View Menu"
4. Verify menu expands with green "Approved" badge
5. Verify collections are listed with item counts
6. Click a collection to expand
7. Verify products are listed with prices and attributes

### Scenario 2: Location without Menu
1. Navigate to store details page
2. Locate a location without menu
3. Verify "+ Create Menu" button is shown
4. Click "+ Create Menu"
5. Verify menu is created (API call succeeds)
6. Verify button changes to "View Menu"

### Scenario 3: Collapsed/Expanded State
1. View a location with menu
2. Click "View Menu" to expand
3. Verify menu appears below location
4. Click "View Menu" again to collapse
5. Verify menu disappears

### Scenario 4: Multiple Collections
1. Expand a menu with 3+ collections
2. Verify first collection is expanded, rest collapsed
3. Click second collection to expand
4. Verify second collection expands
5. First collection remains expanded (both open)

---

## Out of Scope (Future Iterations)
- Edit menu content
- Delete menu
- Submit menu for approval
- Approve/reject menu
- Product availability toggle
- Product descriptions display
- Reorder collections/products
- Search/filter menu items
- Menu versioning/history

---

## Definition of Done
- [ ] Backend: Location list API returns menu summary
- [ ] Backend: Menu retrieval endpoint works correctly
- [ ] Frontend: "View Menu" button appears for locations with menus
- [ ] Frontend: "+ Create Menu" button appears for locations without menus
- [ ] Frontend: Menu expands/collapses inline below location
- [ ] Frontend: Menu status badge displays with correct colors
- [ ] Frontend: Collections display as collapsible accordions
- [ ] Frontend: Products display with names, prices, and attributes
- [ ] Frontend: Loading and error states handled gracefully
- [ ] Frontend: Responsive on mobile and desktop
- [ ] Manual testing completed for all scenarios
- [ ] No console errors when expanding/collapsing menus