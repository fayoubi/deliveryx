#!/bin/bash

# Menu Seeding Script
# This script creates a sample menu with collections and products for testing
# Usage: ./seed-menu-example.sh <location_id>

set -e

BASE_URL="http://localhost/api/v1"
LOCATION_ID="${1}"

if [ -z "$LOCATION_ID" ]; then
  echo "❌ Error: location_id is required"
  echo "Usage: $0 <location_id>"
  echo ""
  echo "Example: $0 f167e889-41fb-42da-b88b-55eb0fea1e0a"
  exit 1
fi

echo "🚀 Starting menu seeding for location: $LOCATION_ID"
echo ""

# Step 1: Create Menu
echo "📋 Step 1: Creating menu..."
MENU_RESPONSE=$(curl -s -X POST "$BASE_URL/locations/$LOCATION_ID/menus" \
  -H "Content-Type: application/json")

MENU_ID=$(echo $MENU_RESPONSE | grep -o '"menu_id":"[^"]*"' | cut -d'"' -f4)

if [ -z "$MENU_ID" ]; then
  echo "⚠️  Menu might already exist. Checking for existing menu..."
  # Try to get menu via location list endpoint
  LOCATION_RESPONSE=$(curl -s "$BASE_URL/locations/$LOCATION_ID")
  # This will need the store_id to work properly, but for now we'll just show the error
  echo "$MENU_RESPONSE"
  echo ""
  echo "If menu already exists, please use the existing menu_id and skip Step 1"
  exit 1
fi

echo "✅ Menu created: $MENU_ID"
echo ""

# Step 2: Create Collections
echo "📁 Step 2: Creating collections..."

# Pizzas Collection
PIZZAS_RESPONSE=$(curl -s -X POST "$BASE_URL/menus/$MENU_ID/collections" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Pizzas",
    "position": 1,
    "image_url": "https://images.unsplash.com/photo-1513104890138-7c749659a591"
  }')
PIZZAS_COLLECTION_ID=$(echo $PIZZAS_RESPONSE | grep -o '"collection_id":"[^"]*"' | cut -d'"' -f4)
echo "  ✅ Pizzas collection: $PIZZAS_COLLECTION_ID"

# Sides Collection
SIDES_RESPONSE=$(curl -s -X POST "$BASE_URL/menus/$MENU_ID/collections" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Sides",
    "position": 2,
    "image_url": "https://images.unsplash.com/photo-1534422298391-e4f8c172dddb"
  }')
SIDES_COLLECTION_ID=$(echo $SIDES_RESPONSE | grep -o '"collection_id":"[^"]*"' | cut -d'"' -f4)
echo "  ✅ Sides collection: $SIDES_COLLECTION_ID"

# Desserts Collection
DESSERTS_RESPONSE=$(curl -s -X POST "$BASE_URL/menus/$MENU_ID/collections" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Desserts",
    "position": 3,
    "image_url": "https://images.unsplash.com/photo-1488477181946-6428a0291777"
  }')
DESSERTS_COLLECTION_ID=$(echo $DESSERTS_RESPONSE | grep -o '"collection_id":"[^"]*"' | cut -d'"' -f4)
echo "  ✅ Desserts collection: $DESSERTS_COLLECTION_ID"

# Drinks Collection
DRINKS_RESPONSE=$(curl -s -X POST "$BASE_URL/menus/$MENU_ID/collections" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Drinks",
    "position": 4,
    "image_url": "https://images.unsplash.com/photo-1437418747212-8d9709afab22"
  }')
DRINKS_COLLECTION_ID=$(echo $DRINKS_RESPONSE | grep -o '"collection_id":"[^"]*"' | cut -d'"' -f4)
echo "  ✅ Drinks collection: $DRINKS_COLLECTION_ID"

echo ""

# Step 3: Create Products
echo "🍕 Step 3: Creating products..."

# Pizza Products
MARGHERITA_RESPONSE=$(curl -s -X POST "$BASE_URL/locations/$LOCATION_ID/products" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Margherita Pizza",
    "description": "Classic pizza with tomato sauce, fresh mozzarella, and basil",
    "price": 12.99,
    "category": "Pizza",
    "image_url": "https://images.unsplash.com/photo-1574071318508-1cdbab80d002"
  }')
MARGHERITA_ID=$(echo $MARGHERITA_RESPONSE | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)
echo "  ✅ Margherita Pizza: $MARGHERITA_ID"

PEPPERONI_RESPONSE=$(curl -s -X POST "$BASE_URL/locations/$LOCATION_ID/products" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Pepperoni Pizza",
    "description": "Tomato sauce, mozzarella, and pepperoni",
    "price": 14.99,
    "category": "Pizza",
    "image_url": "https://images.unsplash.com/photo-1628840042765-356cda07504e"
  }')
PEPPERONI_ID=$(echo $PEPPERONI_RESPONSE | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)
echo "  ✅ Pepperoni Pizza: $PEPPERONI_ID"

QUATTRO_RESPONSE=$(curl -s -X POST "$BASE_URL/locations/$LOCATION_ID/products" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Quattro Formaggi",
    "description": "Four cheese pizza: mozzarella, gorgonzola, parmesan, and ricotta",
    "price": 16.99,
    "category": "Pizza"
  }')
QUATTRO_ID=$(echo $QUATTRO_RESPONSE | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)
echo "  ✅ Quattro Formaggi: $QUATTRO_ID"

# Sides Products
GARLIC_BREAD_RESPONSE=$(curl -s -X POST "$BASE_URL/locations/$LOCATION_ID/products" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Garlic Bread",
    "description": "Toasted bread with garlic butter and herbs",
    "price": 4.99,
    "category": "Side"
  }')
GARLIC_BREAD_ID=$(echo $GARLIC_BREAD_RESPONSE | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)
echo "  ✅ Garlic Bread: $GARLIC_BREAD_ID"

CAESAR_SALAD_RESPONSE=$(curl -s -X POST "$BASE_URL/locations/$LOCATION_ID/products" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Caesar Salad",
    "description": "Romaine lettuce, parmesan, croutons, and Caesar dressing",
    "price": 8.99,
    "category": "Side"
  }')
CAESAR_SALAD_ID=$(echo $CAESAR_SALAD_RESPONSE | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)
echo "  ✅ Caesar Salad: $CAESAR_SALAD_ID"

# Dessert Products
TIRAMISU_RESPONSE=$(curl -s -X POST "$BASE_URL/locations/$LOCATION_ID/products" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Tiramisu",
    "description": "Classic Italian coffee-flavored dessert with mascarpone",
    "price": 6.99,
    "category": "Dessert"
  }')
TIRAMISU_ID=$(echo $TIRAMISU_RESPONSE | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)
echo "  ✅ Tiramisu: $TIRAMISU_ID"

PANNA_COTTA_RESPONSE=$(curl -s -X POST "$BASE_URL/locations/$LOCATION_ID/products" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Panna Cotta",
    "description": "Creamy Italian dessert with berry compote",
    "price": 5.99,
    "category": "Dessert"
  }')
PANNA_COTTA_ID=$(echo $PANNA_COTTA_RESPONSE | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)
echo "  ✅ Panna Cotta: $PANNA_COTTA_ID"

# Drink Products
COKE_RESPONSE=$(curl -s -X POST "$BASE_URL/locations/$LOCATION_ID/products" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Coca-Cola",
    "description": "Classic Coca-Cola soft drink",
    "price": 2.99,
    "category": "Drink"
  }')
COKE_ID=$(echo $COKE_RESPONSE | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)
echo "  ✅ Coca-Cola: $COKE_ID"

WATER_RESPONSE=$(curl -s -X POST "$BASE_URL/locations/$LOCATION_ID/products" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Sparkling Water",
    "description": "San Pellegrino sparkling mineral water",
    "price": 3.99,
    "category": "Drink"
  }')
WATER_ID=$(echo $WATER_RESPONSE | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)
echo "  ✅ Sparkling Water: $WATER_ID"

echo ""

# Step 4: Add Products to Menu Collections
echo "🔗 Step 4: Adding products to collections..."

# Add Pizzas to Pizzas Collection
curl -s -X POST "$BASE_URL/menus/$MENU_ID/products" \
  -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$MARGHERITA_ID\", \"collection_id\": \"$PIZZAS_COLLECTION_ID\", \"position\": 1}" > /dev/null
echo "  ✅ Added Margherita to Pizzas"

curl -s -X POST "$BASE_URL/menus/$MENU_ID/products" \
  -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$PEPPERONI_ID\", \"collection_id\": \"$PIZZAS_COLLECTION_ID\", \"position\": 2}" > /dev/null
echo "  ✅ Added Pepperoni to Pizzas"

curl -s -X POST "$BASE_URL/menus/$MENU_ID/products" \
  -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$QUATTRO_ID\", \"collection_id\": \"$PIZZAS_COLLECTION_ID\", \"position\": 3}" > /dev/null
echo "  ✅ Added Quattro Formaggi to Pizzas"

# Add Sides to Sides Collection
curl -s -X POST "$BASE_URL/menus/$MENU_ID/products" \
  -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$GARLIC_BREAD_ID\", \"collection_id\": \"$SIDES_COLLECTION_ID\", \"position\": 1}" > /dev/null
echo "  ✅ Added Garlic Bread to Sides"

curl -s -X POST "$BASE_URL/menus/$MENU_ID/products" \
  -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$CAESAR_SALAD_ID\", \"collection_id\": \"$SIDES_COLLECTION_ID\", \"position\": 2}" > /dev/null
echo "  ✅ Added Caesar Salad to Sides"

# Add Desserts to Desserts Collection
curl -s -X POST "$BASE_URL/menus/$MENU_ID/products" \
  -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$TIRAMISU_ID\", \"collection_id\": \"$DESSERTS_COLLECTION_ID\", \"position\": 1}" > /dev/null
echo "  ✅ Added Tiramisu to Desserts"

curl -s -X POST "$BASE_URL/menus/$MENU_ID/products" \
  -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$PANNA_COTTA_ID\", \"collection_id\": \"$DESSERTS_COLLECTION_ID\", \"position\": 2}" > /dev/null
echo "  ✅ Added Panna Cotta to Desserts"

# Add Drinks to Drinks Collection
curl -s -X POST "$BASE_URL/menus/$MENU_ID/products" \
  -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$COKE_ID\", \"collection_id\": \"$DRINKS_COLLECTION_ID\", \"position\": 1}" > /dev/null
echo "  ✅ Added Coca-Cola to Drinks"

curl -s -X POST "$BASE_URL/menus/$MENU_ID/products" \
  -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$WATER_ID\", \"collection_id\": \"$DRINKS_COLLECTION_ID\", \"position\": 2}" > /dev/null
echo "  ✅ Added Sparkling Water to Drinks"

echo ""
echo "✨ Menu seeding complete!"
echo ""
echo "📊 Summary:"
echo "  Menu ID: $MENU_ID"
echo "  Collections: 4 (Pizzas, Sides, Desserts, Drinks)"
echo "  Products: 10 total"
echo ""
echo "🔍 View complete menu:"
echo "  curl http://localhost/api/v1/menus/$MENU_ID | jq"
echo ""
echo "🌐 View in admin portal:"
echo "  1. Navigate to: http://localhost/admin/stores"
echo "  2. Find the store containing this location"
echo "  3. Click 'View Menu' for this location"
echo ""
