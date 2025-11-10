# Menu Service - Simplified ERD

## Quick Visual Reference

```
┌─────────────────────────────────────────────────────────────────┐
│                         MENU SERVICE                            │
│                    (deliveryx_menu database)                    │
└─────────────────────────────────────────────────────────────────┘

┌────────────────┐
│     MENUS      │
├────────────────┤
│ menu_id    PK  │──┐
│ location_id UK │  │
│ status         │  │ 1:N
└────────────────┘  │
                    │
        ┌───────────┴─────────────┬────────────────────────┐
        │                         │                        │
        ↓                         ↓                        │
┌───────────────┐         ┌──────────────┐                │
│  COLLECTIONS  │         │   PRODUCTS   │                │
├───────────────┤         ├──────────────┤                │
│collection_id PK│──┐      │ product_id PK│──┐             │
│ menu_id     FK │  │      │ location_id  │  │             │
│ name          │  │      │ name         │  │             │
│ position      │  │      │ price        │  │             │
└───────────────┘  │      │ description  │  │             │
                   │      └──────────────┘  │             │
                   │                        │             │
        1:N        │           1:N          │             │
                   │                        │             │
                   ↓                        ↓             ↓
          ┌──────────────────────────────────────────────────┐
          │            MENU_PRODUCTS (Junction)              │
          ├──────────────────────────────────────────────────┤
          │ menu_id       PK, FK ────────────────────────────┘
          │ product_id    PK, FK ────────────────────────────┐
          │ collection_id FK ────────────────────────────────┘
          │ position                                          │
          └──────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────┐
│                    PRODUCT CUSTOMIZATION                        │
└─────────────────────────────────────────────────────────────────┘

┌────────────────────┐
│ ATTRIBUTE_GROUPS   │
├────────────────────┤
│ id             PK  │──┐
│ name               │  │ 1:N
│ min_selections     │  │
│ max_selections     │  │
└────────────────────┘  │
                        │
                ┌───────┴─────────┬──────────────────┐
                │                 │                  │
                ↓                 │                  │
        ┌───────────────┐         │                  │
        │  ATTRIBUTES   │         │                  │
        ├───────────────┤         │                  │
        │ id         PK │         │                  │
        │ attr_grp_id FK│─────────┘                  │
        │ name          │                            │ 1:N
        │ price_impact  │                            │
        └───────────────┘                            ↓
                                    ┌──────────────────────────────┐
                                    │ PRODUCT_ATTRIBUTE_GROUPS     │
                                    │         (Junction)            │
                                    ├──────────────────────────────┤
        ┌───────────────────────────│ product_id         PK, FK    │
        │                           │ attribute_group_id PK, FK ───┘
        │                           └──────────────────────────────┘
        │
        │
┌───────┴────────┐
│   PRODUCTS     │
├────────────────┤
│ product_id  PK │
│ location_id    │
│ name           │
│ price          │
└────────────────┘
```

## Data Flow Example

### Creating a Complete Menu

```
Step 1: Create Menu
POST /locations/{location_id}/menus
→ Creates: menus row (status: draft)

Step 2: Add Collections
POST /menus/{menu_id}/collections
→ Creates: collections rows (Pizzas, Desserts, Drinks)

Step 3: Create Products
POST /locations/{location_id}/products
→ Creates: products rows (Margherita, Tiramisu, Coke)

Step 4: Link Attribute Groups to Products (Optional)
→ Inserts: product_attribute_groups rows
   Example: Margherita Pizza → Size group, Toppings group

Step 5: Add Products to Menu
POST /menus/{menu_id}/products
→ Creates: menu_products rows
   Links: (menu_id + product_id + collection_id + position)
   Example: Margherita → Pizzas collection, position 1
```

## Key Relationships

### 1. Menu → Collections (1:N)
- A menu has many collections
- Collections are deleted when menu is deleted (CASCADE)

### 2. Menu → Products (M:N via menu_products)
- A menu contains many products
- A product can be in multiple menus (across different locations/times)
- Junction table controls: which collection, what position

### 3. Collection → Products (M:N via menu_products)
- A collection organizes many products
- A product can only appear once per menu
- Position determines display order

### 4. Product → Attribute Groups (M:N via product_attribute_groups)
- A product can have multiple attribute groups
- An attribute group can be used by multiple products
- Example: Size group used by all Pizza products

### 5. Attribute Group → Attributes (1:N)
- An attribute group contains many attributes
- Example: Size group contains: Small, Medium, Large, XL

## Common Patterns

### Pattern 1: Reusable Products
```
Location A: "Downtown"
  ├─ Product: "Margherita" (created once)
  └─ Menus:
       ├─ Menu v1 (draft)    → includes Margherita
       ├─ Menu v2 (approved) → includes Margherita
       └─ Menu v3 (draft)    → includes Margherita
```

### Pattern 2: Shared Attribute Groups
```
Attribute Group: "Size"
  ├─ Small, Medium, Large, XL
  └─ Used by:
       ├─ Pizza products
       ├─ Pasta products
       └─ Salad products
```

### Pattern 3: Multi-Collection Products
```
Product: "Coca-Cola"
  └─ In Menu A:
       ├─ Drinks collection (position 1)
       └─ Cannot also be in Desserts collection (1 per menu constraint)
```

## Constraints Summary

| Constraint | Description |
|------------|-------------|
| menus.location_id | UNIQUE - one menu per location |
| menu_products (menu_id, product_id) | PRIMARY KEY - product once per menu |
| collections.name | CHECK - only 10 allowed values |
| products.price | CHECK - must be > 0 |
| All FKs | ON DELETE CASCADE - cleanup automatic |

## Denormalization Note

**Sections are NOT stored in database!**

They are dynamically generated when building the complete menu response:
- Each collection gets 1 default section
- Section name = Collection name
- Section position = 0
- Section products = All products in that collection (ordered by position)

This keeps the schema simple while providing flexibility for future multi-section support.
