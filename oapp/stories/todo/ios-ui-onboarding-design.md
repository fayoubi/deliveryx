# DeliveryX Owner iOS App - Visual Design Screenshots

Based on the existing API contracts and wireframes, here are the visual designs for the restaurant owner mobile app:

## Screen 1: Store Setup
```
┌─────────────────────────────────────────┐
│  ← Set Up Your Restaurant                │
├─────────────────────────────────────────┤
│                                         │
│  Let's get your restaurant ready for    │
│  DeliveryX                              │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │                                 │   │
│  │        📷 Upload Logo           │   │
│  │                                 │   │
│  └─────────────────────────────────┘   │
│                                         │
│  Restaurant Name                         │
│  ┌─────────────────────────────────┐   │
│  │ Pizza Palace                    │   │
│  └─────────────────────────────────┘   │
│                                         │
│  Description                            │
│  ┌─────────────────────────────────┐   │
│  │ Best pizza in town with fresh   │   │
│  │ ingredients and authentic       │   │
│  │ Italian recipes                 │   │
│  └─────────────────────────────────┘   │
│                                         │
│  Phone Number                           │
│  ┌─────────────────────────────────┐   │
│  │ +212 6XX XXX XXX                │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │         Continue →              │   │
│  └─────────────────────────────────┘   │
│                                         │
│  Step 1 of 5                           │
└─────────────────────────────────────────┘
```

**API Integration**: POST /api/v1/stores

**Request Body**:
```json
{
  "name": "Pizza Palace",                    // required, max 255 chars
  "description": "Best pizza in town...",    // optional, max 1000 chars
  "logo_url": "https://...",                 // optional
  "phone": "+212 6XX XXX XXX"                // required, max 20 chars
}
```

**Response** (201 Created):
```json
{
  "store_id": "uuid",
  "name": "Pizza Palace",
  "description": "Best pizza in town...",
  "logo_url": "https://...",
  "phone": "+212 6XX XXX XXX",
  "created_at": "2025-10-21T10:00:00Z",
  "updated_at": "2025-10-21T10:00:00Z"
}
```

**Validation**:
- `name`: required, max 255 characters
- `description`: optional, max 1000 characters
- `phone`: required, max 20 characters
- `logo_url`: optional, can be generated via Media Service first

---

## Screen 2: Location Setup
```
┌─────────────────────────────────────────┐
│  ← Add Location                         │
├─────────────────────────────────────────┤
│                                         │
│  Set up your restaurant's physical      │
│  location                               │
│                                         │
│  Location Details                       │
│                                         │
│  Address                                │
│  ┌─────────────────────────────────┐   │
│  │ 123 Main Street, Downtown       │   │
│  └─────────────────────────────────┘   │
│                                         │
│  City                                   │
│  ┌─────────────────────────────────┐   │
│  │ Casablanca                       │   │
│  └─────────────────────────────────┘   │
│                                         │
│  Phone                                  │
│  ┌─────────────────────────────────┐   │
│  │ +212 5XX XXX XXX                │   │
│  └─────────────────────────────────┘   │
│                                         │
│  Operating Hours                        │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ Monday    09:00 - 22:00    ☑    │   │
│  │ Tuesday   09:00 - 22:00    ☑    │   │
│  │ Wednesday 09:00 - 22:00    ☑    │   │
│  │ Thursday  09:00 - 22:00    ☑    │   │
│  │ Friday    09:00 - 22:00    ☑    │   │
│  │ Saturday  09:00 - 22:00    ☑    │   │
│  │ Sunday    09:00 - 22:00    ☑    │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │         Continue →              │   │
│  └─────────────────────────────────┘   │
│                                         │
│  Step 2 of 5                           │
└─────────────────────────────────────────┘
```

**API Integration**:

**Step 1 - Create Location**: POST /api/v1/stores/{store_id}/locations

**Request Body**:
```json
{
  "address": "123 Main Street, Downtown",   // required
  "city": "Casablanca",                      // required, max 100 chars
  "postal_code": "20000",                    // optional, max 20 chars
  "phone": "+212 5XX XXX XXX",               // required, max 20 chars
  "location_manager": "John Doe",            // optional, max 255 chars
  "latitude": 33.5731,                       // optional
  "longitude": -7.5898                       // optional
}
```

**Response** (201 Created):
```json
{
  "location_id": "uuid",
  "store_id": "uuid",
  "address": "123 Main Street, Downtown",
  "city": "Casablanca",
  "postal_code": "20000",
  "phone": "+212 5XX XXX XXX",
  "location_manager": "John Doe",
  "latitude": 33.5731,
  "longitude": -7.5898,
  "created_at": "2025-10-21T10:00:00Z",
  "updated_at": "2025-10-21T10:00:00Z"
}
```

**Step 2 - Set Operating Hours**: PUT /api/v1/locations/{location_id}/operating-hours

**Request Body** (array of 7 days):
```json
[
  {
    "day_of_week": "MONDAY",      // required: MONDAY|TUESDAY|WEDNESDAY|THURSDAY|FRIDAY|SATURDAY|SUNDAY
    "open_time": "09:00",         // required if is_closed=false, format: HH:MM
    "close_time": "22:00",        // required if is_closed=false, format: HH:MM
    "is_closed": false            // required
  },
  {
    "day_of_week": "TUESDAY",
    "open_time": "09:00",
    "close_time": "22:00",
    "is_closed": false
  },
  // ... 5 more days
]
```

**Response** (200 OK):
```json
[
  {
    "id": "uuid",
    "location_id": "uuid",
    "day_of_week": "MONDAY",
    "open_time": "09:00",
    "close_time": "22:00",
    "is_closed": false,
    "created_at": "2025-10-21T10:00:00Z",
    "updated_at": "2025-10-21T10:00:00Z"
  },
  // ... 6 more days
]
```

**Validation**:
- Must provide exactly 7 days
- No duplicate days allowed
- `day_of_week` must be valid enum value
- `open_time` and `close_time` required when `is_closed` is false

---

## Screen 3: Collection Selection
```
┌─────────────────────────────────────────┐
│  ← Choose Categories                    │
├─────────────────────────────────────────┤
│                                         │
│  Select menu categories for your        │
│  restaurant                             │
│                                         │
│  Select menu categories:                │
│                                         │
│  ┌─────────────┐ ┌─────────────┐       │
│  │     🍕      │ │     🍔      │       │
│  │   Pizzas    │ │   Burgers   │       │
│  │    ☑        │ │    ☑        │       │
│  └─────────────┘ └─────────────┘       │
│                                         │
│  ┌─────────────┐ ┌─────────────┐       │
│  │     🍟      │ │     🍰      │       │
│  │    Sides    │ │  Desserts   │       │
│  │    ☐        │ │    ☑        │       │
│  └─────────────┘ └─────────────┘       │
│                                         │
│  ┌─────────────┐ ┌─────────────┐       │
│  │     🥤      │ │     🥗      │       │
│  │   Drinks    │ │   Salads    │       │
│  │    ☑        │ │    ☐        │       │
│  └─────────────┘ └─────────────┘       │
│                                         │
│  ┌─────────────┐ ┌─────────────┐       │
│  │     🥞      │ │     🥪      │       │
│  │ Breakfast   │ │ Sandwiches  │       │
│  │    ☐        │ │    ☐        │       │
│  └─────────────┘ └─────────────┘       │
│                                         │
│  ┌─────────────┐ ┌─────────────┐       │
│  │     🍝      │ │     🦐      │       │
│  │    Pasta    │ │   Seafood   │       │
│  │    ☐        │ │    ☐        │       │
│  └─────────────┘ └─────────────┘       │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │         Continue →              │   │
│  └─────────────────────────────────┘   │
│                                         │
│  Step 3 of 5                           │
└─────────────────────────────────────────┘
```

**API Integration**:

**Step 1 - Create Draft Menu**: POST /api/v1/locations/{location_id}/menus

**Request Body**: `{}` (empty - menu created in draft status)

**Response** (201 Created):
```json
{
  "menu_id": "uuid",
  "location_id": "uuid",
  "status": "draft",
  "submitted_at": null,
  "reviewed_at": null,
  "rejection_reason": null,
  "created_at": "2025-10-21T10:00:00Z",
  "updated_at": "2025-10-21T10:00:00Z"
}
```

**Step 2 - Add Collections**: POST /api/v1/menus/{menu_id}/collections (call for each selected category)

**Request Body**:
```json
{
  "name": "Pizzas",              // required: Pizzas|Burgers|Sides|Desserts|Drinks|Salads|Breakfast|Sandwiches|Pasta|Seafood
  "position": 1,                 // required, min 0
  "image_url": "https://..."     // optional
}
```

**Response** (201 Created):
```json
{
  "collection_id": "uuid",
  "menu_id": "uuid",
  "name": "Pizzas",
  "position": 1,
  "image_url": "https://...",
  "created_at": "2025-10-21T10:00:00Z",
  "updated_at": "2025-10-21T10:00:00Z"
}
```

**Validation**:
- Only one draft menu per location allowed
- Collection `name` must be one of the 10 predefined categories
- Collection names enforced by database CHECK constraint
- Position must be >= 0

**Available Collections**:
1. Pizzas 🍕
2. Burgers 🍔
3. Sides 🍟
4. Desserts 🍰
5. Drinks 🥤
6. Salads 🥗
7. Breakfast 🥞
8. Sandwiches 🥪
9. Pasta 🍝
10. Seafood 🦐

---

## Screen 4: Product Creation
```
┌─────────────────────────────────────────┐
│  ← Add Product                          │
├─────────────────────────────────────────┤
│                                         │
│  Add products to your menu              │
│                                         │
│  Product Photo                          │
│  ┌─────────────────────────────────┐   │
│  │                                 │   │
│  │        📷 Upload Photo         │   │
│  │                                 │   │
│  └─────────────────────────────────┘   │
│                                         │
│  Product Name                           │
│  ┌─────────────────────────────────┐   │
│  │ Margherita Pizza                │   │
│  └─────────────────────────────────┘   │
│                                         │
│  Description                            │
│  ┌─────────────────────────────────┐   │
│  │ Fresh mozzarella, tomato sauce │   │
│  │ and basil on thin crust         │   │
│  └─────────────────────────────────┘   │
│                                         │
│  Price (MAD)                           │
│  ┌─────────────────────────────────┐   │
│  │ 120.00                          │   │
│  └─────────────────────────────────┘   │
│                                         │
│  Category                               │
│  ┌─────────────────────────────────┐   │
│  │ 🍕 Pizzas                ▼     │   │
│  └─────────────────────────────────┘   │
│                                         │
│  Options (optional)                     │
│  ┌─────────────────────────────────┐   │
│  │ Select Options            →    │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────┐ ┌─────────────────┐   │
│  │ Add Sample  │ │ Save Product    │   │
│  └─────────────┘ └─────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │   Finish Adding Products       │   │
│  └─────────────────────────────────┘   │
│                                         │
│  Step 4 of 5                           │
└─────────────────────────────────────────┘
```

**API Integration**:

**Step 1 - Get Attribute Groups** (for options/customizations): GET /api/v1/attribute-groups

**Response** (200 OK):
```json
[
  {
    "id": "uuid",
    "name": "Size",
    "created_at": "2025-10-21T10:00:00Z",
    "updated_at": "2025-10-21T10:00:00Z"
  },
  {
    "id": "uuid",
    "name": "Toppings",
    "created_at": "2025-10-21T10:00:00Z",
    "updated_at": "2025-10-21T10:00:00Z"
  }
]
```

**Step 2 - Create Product**: POST /api/v1/locations/{location_id}/products

**Request Body**:
```json
{
  "name": "Margherita Pizza",                // required, max 255 chars
  "description": "Fresh mozzarella...",      // optional
  "price": 120.00,                           // required, must be > 0
  "category": "Pizzas",                      // optional, max 100 chars
  "image_url": "https://...",                // optional
  "attribute_group_ids": ["uuid1", "uuid2"]  // optional array of attribute group IDs
}
```

**Response** (201 Created):
```json
{
  "product_id": "uuid",
  "location_id": "uuid",
  "name": "Margherita Pizza",
  "description": "Fresh mozzarella...",
  "price": 120.00,
  "category": "Pizzas",
  "image_url": "https://...",
  "is_available": true,
  "attribute_group_ids": ["uuid1", "uuid2"],
  "created_at": "2025-10-21T10:00:00Z",
  "updated_at": "2025-10-21T10:00:00Z"
}
```

**Step 3 - Add Product to Menu**: POST /api/v1/menus/{menu_id}/products

**Request Body**:
```json
{
  "product_id": "uuid",           // required - from Step 2 response
  "collection_id": "uuid",        // required - from collection creation
  "section_id": null,             // optional
  "position": 1                   // required, min 0
}
```

**Response** (201 Created):
```json
{
  "message": "Product added to menu successfully"
}
```

**Validation**:
- Product `price` must be greater than 0
- Product `name` is required and max 255 characters
- Cannot add same product to menu twice
- Product and collection must exist
- Menu must be in `draft` status to add products

---

## Screen 5: Review & Submit
```
┌─────────────────────────────────────────┐
│  ← Review Menu                          │
├─────────────────────────────────────────┤
│                                         │
│  Review your menu before submitting     │
│  for approval                           │
│                                         │
│  Restaurant Summary                     │
│  ┌─────────────────────────────────┐   │
│  │ Restaurant: Pizza Palace       │   │
│  │ Description: Best pizza in town │   │
│  │ Phone: +212 6XX XXX XXX         │   │
│  │ Address: 123 Main St, Casablanca│   │
│  │ Location Phone: +212 5XX XXX XXX│   │
│  └─────────────────────────────────┘   │
│                                         │
│  Menu Summary                           │
│  ┌─────────────────────────────────┐   │
│  │ 🍕 Pizzas (3 products)          │   │
│  │ 🥤 Drinks (2 products)          │   │
│  │ 🍰 Desserts (2 products)        │   │
│  │ ─────────────────────────────── │   │
│  │ Total Products: 7               │   │
│  └─────────────────────────────────┘   │
│                                         │
│  Products                               │
│  ┌─────────────────────────────────┐   │
│  │ [📷] Margherita Pizza           │   │
│  │      Fresh mozzarella...        │   │
│  │      120.00 MAD        🟢 Active│   │
│  └─────────────────────────────────┘   │
│  ┌─────────────────────────────────┐   │
│  │ [📷] Pepperoni Pizza            │   │
│  │      Pepperoni, mozzarella...   │   │
│  │      140.00 MAD        🟢 Active│   │
│  └─────────────────────────────────┘   │
│  ┌─────────────────────────────────┐   │
│  │ [📷] Coca Cola                  │   │
│  │      Refreshing cola drink      │   │
│  │      10.00 MAD         🟢 Active│   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │     Submit for Approval         │   │
│  └─────────────────────────────────┘   │
│                                         │
│  Step 5 of 5                           │
└─────────────────────────────────────────┘
```

**API Integration**:

**Get Complete Menu** (for review): GET /api/v1/menus/{menu_id}

**Response** (200 OK):
```json
{
  "menu_id": "uuid",
  "location_id": "uuid",
  "status": "draft",
  "collections": [
    {
      "collection_id": "uuid",
      "name": "Pizzas",
      "position": 1,
      "image_url": "https://...",
      "products": [
        {
          "product_id": "uuid",
          "name": "Margherita Pizza",
          "description": "Fresh mozzarella...",
          "price": 120.00,
          "category": "Pizzas",
          "image_url": "https://...",
          "is_available": true,
          "position": 1
        }
      ]
    }
  ],
  "created_at": "2025-10-21T10:00:00Z",
  "updated_at": "2025-10-21T10:00:00Z"
}
```

**Submit Menu**: POST /api/v1/menus/{menu_id}/submit

**Request Body**: `{}` (empty)

**Response** (200 OK):
```json
{
  "message": "Menu submitted successfully"
}
```

**Validation**:
- Menu must have at least 1 collection with at least 1 product
- Menu status must be `draft` before submission
- After submission, status changes to `pending_review`
- Cannot modify menu after submission (until approved/rejected)

**Menu Status Flow**:
1. `draft` - Initial creation, can add/edit products and collections
2. `pending_review` - Submitted for approval, no modifications allowed
3. `approved` - Approved by admin, live on platform
4. `rejected` - Rejected with reason, can be edited and resubmitted

---

## Screen 6: Menu Management (Post-Approval)
```
┌─────────────────────────────────────────┐
│  My Menu                                 │
├─────────────────────────────────────────┤
│                                         │
│  Status: 🟢 Active                     │
│                                         │
│  Menu Statistics                        │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐   │
│  │   12    │ │   10    │ │    3    │   │
│  │Products │ │ Active  │ │Categories│   │
│  └─────────┘ └─────────┘ └─────────┘   │
│                                         │
│  Products by Category                   │
│                                         │
│  🍕 Pizzas (8 products)                │
│  ┌─────────────────────────────────┐   │
│  │ [📷] Margherita Pizza           │   │
│  │      120.00 MAD                 │   │
│  │      🟢 Active    [Deactivate]  │   │
│  └─────────────────────────────────┘   │
│  ┌─────────────────────────────────┐   │
│  │ [📷] Pepperoni Pizza            │   │
│  │      140.00 MAD                 │   │
│  │      🟢 Active    [Deactivate]  │   │
│  └─────────────────────────────────┘   │
│  ┌─────────────────────────────────┐   │
│  │ [📷] Hawaiian Pizza             │   │
│  │      130.00 MAD                 │   │
│  │      ⚫ Inactive   [Activate]   │   │
│  └─────────────────────────────────┘   │
│                                         │
│  🥤 Drinks (4 products)                │
│  ┌─────────────────────────────────┐   │
│  │ [📷] Coca Cola                  │   │
│  │      10.00 MAD                  │   │
│  │      🟢 Active    [Deactivate]  │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │   Start New Restaurant          │   │
│  └─────────────────────────────────┘   │
│                                         │
│  Menu Management                       │
└─────────────────────────────────────────┘
```

**API Integration**:

**Check Menu Status**: GET /api/v1/menus/{menu_id}/status

**Response** (200 OK):
```json
{
  "menu_id": "uuid",
  "status": "approved",              // draft|pending_review|approved|rejected
  "submitted_at": "2025-10-21T10:00:00Z",
  "reviewed_at": "2025-10-21T11:00:00Z",
  "rejection_reason": null
}
```

**Get Complete Menu**: GET /api/v1/menus/{menu_id}

**Response** (200 OK): (same as Screen 5)

**Toggle Product Availability**: PUT /api/v1/products/{product_id}/availability

**Request Body**:
```json
{
  "is_available": false          // true to activate, false to deactivate
}
```

**Response** (200 OK):
```json
{
  "message": "Product availability updated successfully"
}
```

**Notes**:
- Product availability can be toggled even when menu status is `approved`
- This allows restaurant owners to temporarily disable products without menu re-approval
- Updating product details (name, price, description) requires menu to be in `draft` status
- Creating new products for approved menus requires creating a new draft menu

---

## Media Upload Integration

**Generate Upload URL**: POST /api/v1/media/upload-url

**Request Body**:
```json
{
  "file_name": "margherita-pizza.jpg",     // required
  "content_type": "image/jpeg",            // required: image/jpeg|image/png|image/webp
  "file_size": 2048576                     // required, max 5MB (5242880 bytes)
}
```

**Response** (200 OK):
```json
{
  "upload_url": "https://s3.../presigned-url",
  "file_url": "https://cdn.../margherita-pizza.jpg",
  "expires_in": 3600
}
```

**Upload Flow**:
1. Call Media Service to get presigned upload URL
2. Upload image file directly to S3 using presigned URL (PUT request)
3. Use returned `file_url` in product/store creation requests

**Validation**:
- `content_type` must be: `image/jpeg`, `image/png`, or `image/webp`
- `file_size` must be <= 5MB (5,242,880 bytes)
- Upload URL expires in 1 hour

---

## Design System & Visual Guidelines

### Color Palette
- **Primary Blue**: #007AFF (iOS system blue for buttons and active states)
- **Success Green**: #34C759 (for active/approved products)
- **Warning Orange**: #FF9500 (for pending states)
- **Error Red**: #FF3B30 (for inactive/rejected products)
- **Background Gray**: #F2F2F7 (iOS system background)
- **Card White**: #FFFFFF (for content cards)

### Typography
- **Large Title**: 34pt, Bold (screen headers)
- **Headline**: 17pt, Semibold (section headers)
- **Body**: 17pt, Regular (form labels and content)
- **Subheadline**: 15pt, Regular (secondary text)
- **Caption**: 12pt, Regular (helper text and steps)

### UI Components
- **Rounded corners**: 12pt radius for cards and buttons
- **Shadows**: Subtle drop shadows on cards
- **Touch targets**: Minimum 44pt height for interactive elements
- **Spacing**: 16pt margins, 8pt internal spacing
- **Progress indicators**: Step counter at bottom of each screen

### Navigation Flow
1. **Linear progression** through setup screens
2. **Back navigation** with chevron left arrows
3. **Continue buttons** disabled until form validation passes
4. **Success states** with confirmation alerts
5. **Error handling** with inline error messages

This design demonstrates a complete restaurant owner onboarding experience that integrates seamlessly with your existing API contracts while providing an intuitive, modern iOS user experience.

---

## Technical Implementation Notes

### API Base URL
```swift
let baseURL = "http://localhost/api/v1"  // Development
// let baseURL = "https://api.deliveryx.com/api/v1"  // Production
```

### Key Backend Changes from Original Design

1. **Operating Hours API** (Screen 2)
   - Request body changed from wrapped object to direct array
   - Must send exactly 7 days with valid enum values
   - `day_of_week` uses uppercase strings: `MONDAY`, not `Monday` or `0`

2. **Collection Names** (Screen 3)
   - Enforced by database CHECK constraint
   - Only 10 predefined categories allowed
   - Case-sensitive: Must use exact capitalization (e.g., "Pizzas" not "pizzas")

3. **Product API** (Screen 4)
   - Field is `price` (not `base_price`)
   - Product availability (`is_available`) separate from product updates
   - Cannot update products after menu leaves `draft` status

4. **Menu Submission** (Screen 5)
   - Requires at least 1 collection with at least 1 product
   - Enforced at database level in submit endpoint
   - Status transitions: `draft` → `pending_review` → `approved`/`rejected`

5. **Error Handling**
   - All 404 errors now properly mapped (product/collection not found)
   - Validation errors return 400 with descriptive messages
   - 500 errors only for actual server issues

### State Management Requirements

1. **Persistent IDs Throughout Flow**:
   ```swift
   var storeID: String?
   var locationID: String?
   var menuID: String?
   var collectionIDs: [String: String] = [:]  // ["Pizzas": "uuid", ...]
   var productIDs: [String] = []
   ```

2. **Form Validation**:
   - Client-side validation should match backend constraints
   - Max lengths, required fields, enum values
   - Price validation: > 0

3. **Image Upload**:
   - Call Media Service first to get presigned URL
   - Upload to S3 asynchronously
   - Store `file_url` for API calls
   - Handle upload failures gracefully

### Recommended iOS Dependencies

```ruby
# Podfile
platform :ios, '15.0'

target 'OAppMobile' do
  use_frameworks!

  # Networking
  pod 'Alamofire', '~> 5.8'

  # JSON Parsing
  pod 'SwiftyJSON', '~> 5.0'

  # Image Loading & Caching
  pod 'SDWebImage', '~> 5.18'

  # Auto Layout
  pod 'SnapKit', '~> 5.6'

  # Progress HUD
  pod 'SVProgressHUD', '~> 2.3'

  # Image Picker
  pod 'YPImagePicker', '~> 5.3'
end
```

### Suggested Project Structure

```
OAppMobile/
├── App/
│   ├── AppDelegate.swift
│   └── SceneDelegate.swift
├── Models/
│   ├── Store.swift
│   ├── Location.swift
│   ├── OperatingHours.swift
│   ├── Menu.swift
│   ├── Collection.swift
│   └── Product.swift
├── Services/
│   ├── APIClient.swift
│   ├── RestaurantService.swift
│   ├── MenuService.swift
│   └── MediaService.swift
├── ViewControllers/
│   ├── Onboarding/
│   │   ├── StoreSetupViewController.swift
│   │   ├── LocationSetupViewController.swift
│   │   ├── CollectionSelectionViewController.swift
│   │   ├── ProductCreationViewController.swift
│   │   └── ReviewSubmitViewController.swift
│   └── Management/
│       └── MenuManagementViewController.swift
├── Views/
│   ├── CustomTextField.swift
│   ├── CustomButton.swift
│   ├── ProductCardView.swift
│   └── CollectionCardView.swift
└── Resources/
    ├── Assets.xcassets
    └── Info.plist
```

### API Client Example

```swift
import Alamofire

class APIClient {
    static let shared = APIClient()
    private let baseURL = "http://localhost/api/v1"

    func request<T: Decodable>(
        _ endpoint: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        let url = "\(baseURL)\(endpoint)"

        AF.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let value):
                    completion(.success(value))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
```
