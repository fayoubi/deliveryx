# Menu Seeding Guide

This guide shows you how to populate menus with collections and products for testing the admin portal menu display feature.

## Overview

The Menu Service uses this hierarchy:
```
Location
  └─ Menu (draft/pending_review/approved/rejected)
       ├─ Collections (categories like "Pizzas", "Desserts", etc.)
       │    └─ Sections (default section auto-created per collection)
       │         └─ Products (positioned within section)
       └─ Products (created at location level, then added to menus)
```

## Prerequisites

1. You need a **location_id** for which to create menu items
2. Menu must be in **draft** status to add/modify collections and products
3. Base URL: `http://localhost/api/v1`

## Step-by-Step Process

### Step 1: Create a Menu for a Location

If the location doesn't already have a menu, create one:

```bash
curl -X POST http://localhost/api/v1/locations/{location_id}/menus \
  -H "Content-Type: application/json"
```

**Response:**
```json
{
  "menu_id": "uuid-here",
  "location_id": "uuid-here",
  "status": "draft",
  "created_at": "2024-11-07T10:00:00Z"
}
```

Save the `menu_id` for subsequent steps.

### Step 2: Create Collections (Categories)

Collections organize products into categories. Allowed values: `Pizzas`, `Burgers`, `Sides`, `Desserts`, `Drinks`, `Salads`, `Breakfast`, `Sandwiches`, `Pasta`, `Seafood`

```bash
# Create "Pizzas" collection
curl -X POST http://localhost/api/v1/menus/{menu_id}/collections \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Pizzas",
    "position": 1,
    "image_url": "https://example.com/pizzas.jpg"
  }'

# Create "Desserts" collection
curl -X POST http://localhost/api/v1/menus/{menu_id}/collections \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Desserts",
    "position": 2,
    "image_url": "https://example.com/desserts.jpg"
  }'

# Create "Drinks" collection
curl -X POST http://localhost/api/v1/menus/{menu_id}/collections \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Drinks",
    "position": 3
  }'
```

**Response:**
```json
{
  "collection_id": "uuid-here",
  "name": "Pizzas",
  "position": 1,
  "image_url": "https://example.com/pizzas.jpg"
}
```

Save the `collection_id` for each collection.

### Step 3: Create Products

Products are created at the **location level** (not menu level), so they can be reused across multiple menus.

```bash
# Create Margherita Pizza
curl -X POST http://localhost/api/v1/locations/{location_id}/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Margherita Pizza",
    "description": "Classic pizza with tomato sauce, mozzarella, and fresh basil",
    "price": 12.99,
    "category": "Pizza",
    "image_url": "https://example.com/margherita.jpg"
  }'

# Create Pepperoni Pizza
curl -X POST http://localhost/api/v1/locations/{location_id}/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Pepperoni Pizza",
    "description": "Pepperoni, mozzarella cheese, and tomato sauce",
    "price": 14.99,
    "category": "Pizza",
    "image_url": "https://example.com/pepperoni.jpg"
  }'

# Create Tiramisu
curl -X POST http://localhost/api/v1/locations/{location_id}/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Tiramisu",
    "description": "Classic Italian coffee-flavored dessert",
    "price": 6.99,
    "category": "Dessert"
  }'

# Create Coca-Cola
curl -X POST http://localhost/api/v1/locations/{location_id}/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Coca-Cola",
    "description": "Classic soft drink",
    "price": 2.99,
    "category": "Drink"
  }'
```

**Response:**
```json
{
  "product_id": "uuid-here",
  "location_id": "uuid-here",
  "name": "Margherita Pizza",
  "description": "Classic pizza with tomato sauce, mozzarella, and fresh basil",
  "price": 12.99,
  "category": "Pizza",
  "image_url": "https://example.com/margherita.jpg",
  "available": true,
  "created_at": "2024-11-07T10:00:00Z"
}
```

Save each `product_id`.

### Step 4: Add Products to Menu Collections

Now link products to specific collections within the menu:

```bash
# Add Margherita to Pizzas collection (position 1)
curl -X POST http://localhost/api/v1/menus/{menu_id}/products \
  -H "Content-Type: application/json" \
  -d '{
    "product_id": "{margherita_product_id}",
    "collection_id": "{pizzas_collection_id}",
    "position": 1
  }'

# Add Pepperoni to Pizzas collection (position 2)
curl -X POST http://localhost/api/v1/menus/{menu_id}/products \
  -H "Content-Type: application/json" \
  -d '{
    "product_id": "{pepperoni_product_id}",
    "collection_id": "{pizzas_collection_id}",
    "position": 2
  }'

# Add Tiramisu to Desserts collection (position 1)
curl -X POST http://localhost/api/v1/menus/{menu_id}/products \
  -H "Content-Type: application/json" \
  -d '{
    "product_id": "{tiramisu_product_id}",
    "collection_id": "{desserts_collection_id}",
    "position": 1
  }'

# Add Coca-Cola to Drinks collection (position 1)
curl -X POST http://localhost/api/v1/menus/{menu_id}/products \
  -H "Content-Type: application/json" \
  -d '{
    "product_id": "{cocacola_product_id}",
    "collection_id": "{drinks_collection_id}",
    "position": 1
  }'
```

### Step 5: Verify Complete Menu

```bash
curl http://localhost/api/v1/menus/{menu_id}
```

You should see a response with:
- `collections`: Array of collections with nested sections and product IDs
- `products`: Array of all product objects
- `status`: "draft"
- `attributes` and `attribute_groups`: Empty or populated if you've added them

## Complete Example Script

See `scripts/seed-menu-example.sh` for a complete bash script that seeds a sample menu with multiple collections and products.

## Quick Test with Existing Data

If you want to test with an existing location that already has a menu:

1. **Pizza Palace (New York)**: Already has 4 collections with 7 products
   - Store ID: `c04c3696-ed10-442d-9ed3-a26c6b28d4d4`
   - Location: New York (456 Broadway)
   - URL: http://localhost/admin/stores/c04c3696-ed10-442d-9ed3-a26c6b28d4d4

2. **View in Admin Portal**: Navigate to store details and click "View Menu" on any location

## Troubleshooting

### "Menu already exists for this location"
- Each location can only have one menu. Use the existing menu_id.

### "Menu not in draft status"
- You can only modify menus in draft status
- Check status: `curl http://localhost/api/v1/menus/{menu_id}/status`

### "Collection name not in allowed enum"
- Collections must be one of: Pizzas, Burgers, Sides, Desserts, Drinks, Salads, Breakfast, Sandwiches, Pasta, Seafood

### Spinner Stuck on Loading
- Fixed in latest deployment
- Clear browser cache and refresh
- Check browser console for errors

### Empty Menu Shows "No collections yet"
- This is expected behavior for menus with no collections
- Add collections using Step 2

## API Reference

Full API documentation: http://localhost/docs

Key endpoints:
- `POST /api/v1/locations/{location_id}/menus` - Create menu
- `POST /api/v1/menus/{menu_id}/collections` - Add collection
- `POST /api/v1/locations/{location_id}/products` - Create product
- `POST /api/v1/menus/{menu_id}/products` - Add product to menu
- `GET /api/v1/menus/{menu_id}` - Get complete menu
- `POST /api/v1/menus/{menu_id}/submit` - Submit for approval
