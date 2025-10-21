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
- Creates store with name, description, logo_url, phone
- Validates required fields and max lengths
- Returns store_id for next steps

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
- POST /api/v1/stores/{store_id}/locations
- PUT /api/v1/locations/{location_id}/operating-hours
- Creates location with address, city, phone
- Sets operating hours for all 7 days

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
- POST /api/v1/locations/{location_id}/menus (creates draft menu)
- POST /api/v1/menus/{menu_id}/collections (creates selected collections)
- Validates collection names against predefined list

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
- POST /api/v1/locations/{location_id}/products
- GET /api/v1/attribute-groups (for options)
- Creates products with name, description, price, category
- Links products to attribute groups for customization options

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
- POST /api/v1/menus/{menu_id}/submit
- Validates menu has at least 1 collection with 1 product
- Changes menu status from "draft" to "submitted"

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
- GET /api/v1/menus/{menu_id}/status (check approval status)
- PATCH /api/v1/products/{product_id}/availability (toggle active/inactive)
- GET /api/v1/menus/{menu_id} (get complete menu for display)

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
