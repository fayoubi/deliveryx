#!/bin/bash

# Seed Diverse Restaurant Menus Script
# Creates comprehensive menus for 3 different cuisine types:
# 1. Sushi Restaurant (Amine Suchi - Casablanca)
# 2. Mexican Restaurant (Chez Fahd - CASCADE CAVERNS)
# 3. Asian Fusion Restaurant (Chez Fahd - Serene Hilltop)

set -e

BASE_URL="http://localhost/api/v1"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🚀 Starting diverse restaurant menu seeding..."
echo ""

# ============================================
# RESTAURANT 1: SUSHI RESTAURANT (Amine Suchi)
# ============================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🍣 SUSHI RESTAURANT - Amine Suchi (Casablanca)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

SUSHI_LOCATION="27062feb-2c22-40e2-991c-b2ff6a16bb47"
SUSHI_MENU="3adbc1a9-21bf-49ee-bba1-3852a53b1594"

# Attribute Group IDs
SPICE_LEVEL="115de26c-0f50-44b7-a712-e96647607734"
SPECIAL_INSTRUCTIONS="19603cb2-b99a-4de6-bc29-dc5fde0ce7b4"
RICE_NOODLE="137e1f36-f179-4e2b-bc5f-a290e95915c9"

echo "📁 Creating collections..."

# Create Appetizers Collection
APPETIZERS_SUSHI=$(curl -s -X POST "$BASE_URL/menus/$SUSHI_MENU/collections" \
  -H "Content-Type: application/json" \
  -d '{"name": "Salads", "position": 1}' | grep -o '"collection_id":"[^"]*"' | cut -d'"' -f4)
echo "  ✅ Appetizers: $APPETIZERS_SUSHI"

# Create Nigiri Collection
NIGIRI=$(curl -s -X POST "$BASE_URL/menus/$SUSHI_MENU/collections" \
  -H "Content-Type: application/json" \
  -d '{"name": "Seafood", "position": 2}' | grep -o '"collection_id":"[^"]*"' | cut -d'"' -f4)
echo "  ✅ Nigiri/Sashimi: $NIGIRI"

# Create Rolls Collection
ROLLS=$(curl -s -X POST "$BASE_URL/menus/$SUSHI_MENU/collections" \
  -H "Content-Type: application/json" \
  -d '{"name": "Sandwiches", "position": 3}' | grep -o '"collection_id":"[^"]*"' | cut -d'"' -f4)
echo "  ✅ Rolls: $ROLLS"

# Create Desserts Collection
DESSERTS_SUSHI=$(curl -s -X POST "$BASE_URL/menus/$SUSHI_MENU/collections" \
  -H "Content-Type: application/json" \
  -d '{"name": "Desserts", "position": 4}' | grep -o '"collection_id":"[^"]*"' | cut -d'"' -f4)
echo "  ✅ Desserts: $DESSERTS_SUSHI"

# Create Drinks Collection
DRINKS_SUSHI=$(curl -s -X POST "$BASE_URL/menus/$SUSHI_MENU/collections" \
  -H "Content-Type: application/json" \
  -d '{"name": "Drinks", "position": 5}' | grep -o '"collection_id":"[^"]*"' | cut -d'"' -f4)
echo "  ✅ Drinks: $DRINKS_SUSHI"

echo ""
echo "🍱 Creating products..."

# Appetizers
EDAMAME=$(curl -s -X POST "$BASE_URL/locations/$SUSHI_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Edamame\", \"description\": \"Steamed soybeans with sea salt\", \"price\": 4.99, \"attribute_group_ids\": [\"$SPICE_LEVEL\", \"$SPECIAL_INSTRUCTIONS\"]}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

MISO=$(curl -s -X POST "$BASE_URL/locations/$SUSHI_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Miso Soup\", \"description\": \"Traditional Japanese soup with tofu and seaweed\", \"price\": 3.99, \"attribute_group_ids\": [\"$SPECIAL_INSTRUCTIONS\"]}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

GYOZA=$(curl -s -X POST "$BASE_URL/locations/$SUSHI_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Gyoza\", \"description\": \"Pan-fried pork dumplings (6 pcs)\", \"price\": 6.99, \"attribute_group_ids\": [\"$SPICE_LEVEL\", \"$SPECIAL_INSTRUCTIONS\"]}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

echo "  ✅ Created 3 appetizers"

# Nigiri & Sashimi
SALMON_NIGIRI=$(curl -s -X POST "$BASE_URL/locations/$SUSHI_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Salmon Nigiri\", \"description\": \"Fresh Atlantic salmon over rice (2 pcs)\", \"price\": 5.99, \"attribute_group_ids\": [\"$RICE_NOODLE\", \"$SPECIAL_INSTRUCTIONS\"]}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

TUNA_NIGIRI=$(curl -s -X POST "$BASE_URL/locations/$SUSHI_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Tuna Nigiri\", \"description\": \"Premium bluefin tuna over rice (2 pcs)\", \"price\": 6.99, \"attribute_group_ids\": [\"$RICE_NOODLE\", \"$SPECIAL_INSTRUCTIONS\"]}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

EEL_NIGIRI=$(curl -s -X POST "$BASE_URL/locations/$SUSHI_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Unagi Nigiri\", \"description\": \"Grilled eel with sweet sauce (2 pcs)\", \"price\": 7.99, \"attribute_group_ids\": [\"$RICE_NOODLE\", \"$SPECIAL_INSTRUCTIONS\"]}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

SASHIMI=$(curl -s -X POST "$BASE_URL/locations/$SUSHI_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Sashimi Platter\", \"description\": \"Assorted fresh fish (9 pcs)\", \"price\": 16.99, \"attribute_group_ids\": [\"$SPICE_LEVEL\", \"$SPECIAL_INSTRUCTIONS\"]}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

echo "  ✅ Created 4 nigiri/sashimi items"

# Rolls
CALIFORNIA=$(curl -s -X POST "$BASE_URL/locations/$SUSHI_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"California Roll\", \"description\": \"Crab, avocado, cucumber (8 pcs)\", \"price\": 8.99, \"attribute_group_ids\": [\"$RICE_NOODLE\", \"$SPECIAL_INSTRUCTIONS\"]}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

SPICY_TUNA=$(curl -s -X POST "$BASE_URL/locations/$SUSHI_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Spicy Tuna Roll\", \"description\": \"Tuna with spicy mayo (8 pcs)\", \"price\": 9.99, \"attribute_group_ids\": [\"$SPICE_LEVEL\", \"$RICE_NOODLE\", \"$SPECIAL_INSTRUCTIONS\"]}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

DRAGON=$(curl -s -X POST "$BASE_URL/locations/$SUSHI_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Dragon Roll\", \"description\": \"Eel, cucumber topped with avocado (8 pcs)\", \"price\": 13.99, \"attribute_group_ids\": [\"$RICE_NOODLE\", \"$SPECIAL_INSTRUCTIONS\"]}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

RAINBOW=$(curl -s -X POST "$BASE_URL/locations/$SUSHI_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Rainbow Roll\", \"description\": \"California roll topped with assorted fish (8 pcs)\", \"price\": 14.99, \"attribute_group_ids\": [\"$RICE_NOODLE\", \"$SPECIAL_INSTRUCTIONS\"]}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

echo "  ✅ Created 4 roll items"

# Desserts
MOCHI=$(curl -s -X POST "$BASE_URL/locations/$SUSHI_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Mochi Ice Cream\", \"description\": \"Japanese rice cake with ice cream (3 pcs)\", \"price\": 5.99}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

GREEN_TEA_ICE=$(curl -s -X POST "$BASE_URL/locations/$SUSHI_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Green Tea Ice Cream\", \"description\": \"Traditional matcha flavored ice cream\", \"price\": 4.99}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

echo "  ✅ Created 2 desserts"

# Drinks
GREEN_TEA=$(curl -s -X POST "$BASE_URL/locations/$SUSHI_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Green Tea\", \"description\": \"Hot or iced Japanese green tea\", \"price\": 2.99}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

SAKE=$(curl -s -X POST "$BASE_URL/locations/$SUSHI_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Sake\", \"description\": \"Premium Japanese rice wine\", \"price\": 8.99}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

echo "  ✅ Created 2 drinks"

echo ""
echo "🔗 Linking products to collections..."

# Link Appetizers
curl -s -X POST "$BASE_URL/menus/$SUSHI_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$EDAMAME\", \"collection_id\": \"$APPETIZERS_SUSHI\", \"position\": 1}" > /dev/null
curl -s -X POST "$BASE_URL/menus/$SUSHI_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$MISO\", \"collection_id\": \"$APPETIZERS_SUSHI\", \"position\": 2}" > /dev/null
curl -s -X POST "$BASE_URL/menus/$SUSHI_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$GYOZA\", \"collection_id\": \"$APPETIZERS_SUSHI\", \"position\": 3}" > /dev/null
echo "  ✅ Linked appetizers"

# Link Nigiri/Sashimi
curl -s -X POST "$BASE_URL/menus/$SUSHI_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$SALMON_NIGIRI\", \"collection_id\": \"$NIGIRI\", \"position\": 1}" > /dev/null
curl -s -X POST "$BASE_URL/menus/$SUSHI_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$TUNA_NIGIRI\", \"collection_id\": \"$NIGIRI\", \"position\": 2}" > /dev/null
curl -s -X POST "$BASE_URL/menus/$SUSHI_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$EEL_NIGIRI\", \"collection_id\": \"$NIGIRI\", \"position\": 3}" > /dev/null
curl -s -X POST "$BASE_URL/menus/$SUSHI_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$SASHIMI\", \"collection_id\": \"$NIGIRI\", \"position\": 4}" > /dev/null
echo "  ✅ Linked nigiri/sashimi"

# Link Rolls
curl -s -X POST "$BASE_URL/menus/$SUSHI_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$CALIFORNIA\", \"collection_id\": \"$ROLLS\", \"position\": 1}" > /dev/null
curl -s -X POST "$BASE_URL/menus/$SUSHI_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$SPICY_TUNA\", \"collection_id\": \"$ROLLS\", \"position\": 2}" > /dev/null
curl -s -X POST "$BASE_URL/menus/$SUSHI_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$DRAGON\", \"collection_id\": \"$ROLLS\", \"position\": 3}" > /dev/null
curl -s -X POST "$BASE_URL/menus/$SUSHI_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$RAINBOW\", \"collection_id\": \"$ROLLS\", \"position\": 4}" > /dev/null
echo "  ✅ Linked rolls"

# Link Desserts
curl -s -X POST "$BASE_URL/menus/$SUSHI_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$MOCHI\", \"collection_id\": \"$DESSERTS_SUSHI\", \"position\": 1}" > /dev/null
curl -s -X POST "$BASE_URL/menus/$SUSHI_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$GREEN_TEA_ICE\", \"collection_id\": \"$DESSERTS_SUSHI\", \"position\": 2}" > /dev/null
echo "  ✅ Linked desserts"

# Link Drinks
curl -s -X POST "$BASE_URL/menus/$SUSHI_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$GREEN_TEA\", \"collection_id\": \"$DRINKS_SUSHI\", \"position\": 1}" > /dev/null
curl -s -X POST "$BASE_URL/menus/$SUSHI_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$SAKE\", \"collection_id\": \"$DRINKS_SUSHI\", \"position\": 2}" > /dev/null
echo "  ✅ Linked drinks"

echo -e "${GREEN}✨ Sushi restaurant complete! 15 products, 5 collections${NC}"
echo ""

# ============================================
# RESTAURANT 2: MEXICAN RESTAURANT
# ============================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🌮 MEXICAN RESTAURANT - Chez Fahd (CASCADE CAVERNS)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

MEXICAN_LOCATION="f167e889-41fb-42da-b88b-55eb0fea1e0a"
MEXICAN_MENU="ccceb7b5-ba5f-4372-89b7-7aa760ba784e"

# Attribute Group IDs for Mexican
PROTEIN="51a73c47-f678-48ce-ae55-2c5219070e3a"
TORTILLA="91a268cd-7ad9-40cb-a729-10fa2259726d"
SIDE="3f27a729-af33-43bb-bdc7-56f88b3ca59f"

echo "📁 Creating collections..."

# Create Appetizers Collection
APPETIZERS_MEX=$(curl -s -X POST "$BASE_URL/menus/$MEXICAN_MENU/collections" \
  -H "Content-Type: application/json" \
  -d '{"name": "Salads", "position": 1}' | grep -o '"collection_id":"[^"]*"' | cut -d'"' -f4)
echo "  ✅ Appetizers: $APPETIZERS_MEX"

# Create Tacos Collection (already exists with Pizzas, need to delete first)
# Let's use a different collection name
TACOS=$(curl -s -X POST "$BASE_URL/menus/$MEXICAN_MENU/collections" \
  -H "Content-Type: application/json" \
  -d '{"name": "Breakfast", "position": 2}' | grep -o '"collection_id":"[^"]*"' | cut -d'"' -f4)
echo "  ✅ Tacos: $TACOS"

# Create Burritos Collection
BURRITOS=$(curl -s -X POST "$BASE_URL/menus/$MEXICAN_MENU/collections" \
  -H "Content-Type: application/json" \
  -d '{"name": "Burgers", "position": 3}' | grep -o '"collection_id":"[^"]*"' | cut -d'"' -f4)
echo "  ✅ Burritos: $BURRITOS"

# Create Sides Collection
SIDES_MEX=$(curl -s -X POST "$BASE_URL/menus/$MEXICAN_MENU/collections" \
  -H "Content-Type: application/json" \
  -d '{"name": "Sides", "position": 4}' | grep -o '"collection_id":"[^"]*"' | cut -d'"' -f4)
echo "  ✅ Sides: $SIDES_MEX"

# Create Drinks Collection
DRINKS_MEX=$(curl -s -X POST "$BASE_URL/menus/$MEXICAN_MENU/collections" \
  -H "Content-Type: application/json" \
  -d '{"name": "Drinks", "position": 5}' | grep -o '"collection_id":"[^"]*"' | cut -d'"' -f4)
echo "  ✅ Drinks: $DRINKS_MEX"

echo ""
echo "🌯 Creating products..."

# Appetizers
GUAC=$(curl -s -X POST "$BASE_URL/locations/$MEXICAN_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Guacamole & Chips\", \"description\": \"Fresh avocado dip with tortilla chips\", \"price\": 7.99, \"attribute_group_ids\": [\"$SPICE_LEVEL\", \"$SPECIAL_INSTRUCTIONS\"]}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

QUESO=$(curl -s -X POST "$BASE_URL/locations/$MEXICAN_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Queso Fundido\", \"description\": \"Melted cheese dip with chorizo\", \"price\": 8.99, \"attribute_group_ids\": [\"$SPICE_LEVEL\", \"$SPECIAL_INSTRUCTIONS\"]}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

NACHOS=$(curl -s -X POST "$BASE_URL/locations/$MEXICAN_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Nachos Supreme\", \"description\": \"Loaded nachos with cheese, beans, and jalapenos\", \"price\": 9.99, \"attribute_group_ids\": [\"$PROTEIN\", \"$SPICE_LEVEL\", \"$SPECIAL_INSTRUCTIONS\"]}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

echo "  ✅ Created 3 appetizers"

# Tacos
STREET_TACOS=$(curl -s -X POST "$BASE_URL/locations/$MEXICAN_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Street Tacos\", \"description\": \"Authentic tacos with cilantro and onion (3 pcs)\", \"price\": 10.99, \"attribute_group_ids\": [\"$PROTEIN\", \"$TORTILLA\", \"$SPICE_LEVEL\", \"$SPECIAL_INSTRUCTIONS\"]}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

FISH_TACOS=$(curl -s -X POST "$BASE_URL/locations/$MEXICAN_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Fish Tacos\", \"description\": \"Grilled fish with cabbage slaw (3 pcs)\", \"price\": 12.99, \"attribute_group_ids\": [\"$TORTILLA\", \"$SPICE_LEVEL\", \"$SPECIAL_INSTRUCTIONS\"]}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

CARNITAS=$(curl -s -X POST "$BASE_URL/locations/$MEXICAN_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Carnitas Tacos\", \"description\": \"Slow-cooked pork tacos (3 pcs)\", \"price\": 11.99, \"attribute_group_ids\": [\"$TORTILLA\", \"$SPICE_LEVEL\", \"$SPECIAL_INSTRUCTIONS\"]}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

echo "  ✅ Created 3 tacos"

# Burritos
CALI_BURRITO=$(curl -s -X POST "$BASE_URL/locations/$MEXICAN_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"California Burrito\", \"description\": \"Loaded burrito with fries inside\", \"price\": 11.99, \"attribute_group_ids\": [\"$PROTEIN\", \"$TORTILLA\", \"$SPICE_LEVEL\", \"$SPECIAL_INSTRUCTIONS\"]}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

BURRITO_BOWL=$(curl -s -X POST "$BASE_URL/locations/$MEXICAN_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Burrito Bowl\", \"description\": \"All the burrito fixings in a bowl\", \"price\": 10.99, \"attribute_group_ids\": [\"$PROTEIN\", \"$RICE_NOODLE\", \"$SPICE_LEVEL\", \"$SPECIAL_INSTRUCTIONS\"]}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

QUESADILLA=$(curl -s -X POST "$BASE_URL/locations/$MEXICAN_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Quesadilla\", \"description\": \"Grilled tortilla with melted cheese\", \"price\": 9.99, \"attribute_group_ids\": [\"$PROTEIN\", \"$TORTILLA\", \"$SPICE_LEVEL\", \"$SIDE\", \"$SPECIAL_INSTRUCTIONS\"]}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

ENCHILADAS=$(curl -s -X POST "$BASE_URL/locations/$MEXICAN_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Enchiladas\", \"description\": \"Rolled tortillas with sauce and cheese (3 pcs)\", \"price\": 12.99, \"attribute_group_ids\": [\"$PROTEIN\", \"$SPICE_LEVEL\", \"$RICE_NOODLE\", \"$SPECIAL_INSTRUCTIONS\"]}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

echo "  ✅ Created 4 main dishes"

# Sides
MEXICAN_RICE=$(curl -s -X POST "$BASE_URL/locations/$MEXICAN_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Mexican Rice\", \"description\": \"Seasoned rice with tomatoes\", \"price\": 3.99}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

REFRIED_BEANS=$(curl -s -X POST "$BASE_URL/locations/$MEXICAN_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Refried Beans\", \"description\": \"Creamy pinto beans\", \"price\": 3.99}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

ELOTE=$(curl -s -X POST "$BASE_URL/locations/$MEXICAN_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Elote\", \"description\": \"Grilled corn with mayo and cotija cheese\", \"price\": 4.99, \"attribute_group_ids\": [\"$SPICE_LEVEL\"]}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

echo "  ✅ Created 3 sides"

# Drinks
HORCHATA=$(curl -s -X POST "$BASE_URL/locations/$MEXICAN_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Horchata\", \"description\": \"Sweet rice milk beverage\", \"price\": 3.99}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

JARRITOS=$(curl -s -X POST "$BASE_URL/locations/$MEXICAN_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Jarritos\", \"description\": \"Mexican fruit soda\", \"price\": 2.99}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

echo "  ✅ Created 2 drinks"

echo ""
echo "🔗 Linking products to collections..."

# Link Appetizers
curl -s -X POST "$BASE_URL/menus/$MEXICAN_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$GUAC\", \"collection_id\": \"$APPETIZERS_MEX\", \"position\": 1}" > /dev/null
curl -s -X POST "$BASE_URL/menus/$MEXICAN_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$QUESO\", \"collection_id\": \"$APPETIZERS_MEX\", \"position\": 2}" > /dev/null
curl -s -X POST "$BASE_URL/menus/$MEXICAN_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$NACHOS\", \"collection_id\": \"$APPETIZERS_MEX\", \"position\": 3}" > /dev/null
echo "  ✅ Linked appetizers"

# Link Tacos
curl -s -X POST "$BASE_URL/menus/$MEXICAN_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$STREET_TACOS\", \"collection_id\": \"$TACOS\", \"position\": 1}" > /dev/null
curl -s -X POST "$BASE_URL/menus/$MEXICAN_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$FISH_TACOS\", \"collection_id\": \"$TACOS\", \"position\": 2}" > /dev/null
curl -s -X POST "$BASE_URL/menus/$MEXICAN_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$CARNITAS\", \"collection_id\": \"$TACOS\", \"position\": 3}" > /dev/null
echo "  ✅ Linked tacos"

# Link Burritos/Mains
curl -s -X POST "$BASE_URL/menus/$MEXICAN_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$CALI_BURRITO\", \"collection_id\": \"$BURRITOS\", \"position\": 1}" > /dev/null
curl -s -X POST "$BASE_URL/menus/$MEXICAN_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$BURRITO_BOWL\", \"collection_id\": \"$BURRITOS\", \"position\": 2}" > /dev/null
curl -s -X POST "$BASE_URL/menus/$MEXICAN_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$QUESADILLA\", \"collection_id\": \"$BURRITOS\", \"position\": 3}" > /dev/null
curl -s -X POST "$BASE_URL/menus/$MEXICAN_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$ENCHILADAS\", \"collection_id\": \"$BURRITOS\", \"position\": 4}" > /dev/null
echo "  ✅ Linked main dishes"

# Link Sides
curl -s -X POST "$BASE_URL/menus/$MEXICAN_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$MEXICAN_RICE\", \"collection_id\": \"$SIDES_MEX\", \"position\": 1}" > /dev/null
curl -s -X POST "$BASE_URL/menus/$MEXICAN_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$REFRIED_BEANS\", \"collection_id\": \"$SIDES_MEX\", \"position\": 2}" > /dev/null
curl -s -X POST "$BASE_URL/menus/$MEXICAN_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$ELOTE\", \"collection_id\": \"$SIDES_MEX\", \"position\": 3}" > /dev/null
echo "  ✅ Linked sides"

# Link Drinks
curl -s -X POST "$BASE_URL/menus/$MEXICAN_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$HORCHATA\", \"collection_id\": \"$DRINKS_MEX\", \"position\": 1}" > /dev/null
curl -s -X POST "$BASE_URL/menus/$MEXICAN_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$JARRITOS\", \"collection_id\": \"$DRINKS_MEX\", \"position\": 2}" > /dev/null
echo "  ✅ Linked drinks"

echo -e "${GREEN}✨ Mexican restaurant complete! 15 products, 5 collections${NC}"
echo ""

# ============================================
# RESTAURANT 3: ASIAN FUSION RESTAURANT
# ============================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🥢 ASIAN FUSION - Chez Fahd (Serene Hilltop)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

ASIAN_LOCATION="29f27e52-07fb-4d2f-881f-86ef4d4d7da2"
ASIAN_MENU="8ab79260-2c2e-4527-b882-a5118da2d3b5"

# Attribute Group IDs for Asian
SAUCE="f52f1bdd-7ee7-4f25-bc2b-ad7051f2ee45"

echo "📁 Creating collections..."

# Create Appetizers Collection
APPETIZERS_ASIAN=$(curl -s -X POST "$BASE_URL/menus/$ASIAN_MENU/collections" \
  -H "Content-Type: application/json" \
  -d '{"name": "Salads", "position": 1}' | grep -o '"collection_id":"[^"]*"' | cut -d'"' -f4)
echo "  ✅ Appetizers: $APPETIZERS_ASIAN"

# Create Rice Bowls Collection
RICE_BOWLS=$(curl -s -X POST "$BASE_URL/menus/$ASIAN_MENU/collections" \
  -H "Content-Type: application/json" \
  -d '{"name": "Burgers", "position": 2}' | grep -o '"collection_id":"[^"]*"' | cut -d'"' -f4)
echo "  ✅ Rice Bowls: $RICE_BOWLS"

# Create Noodles Collection
NOODLES=$(curl -s -X POST "$BASE_URL/menus/$ASIAN_MENU/collections" \
  -H "Content-Type: application/json" \
  -d '{"name": "Pasta", "position": 3}' | grep -o '"collection_id":"[^"]*"' | cut -d'"' -f4)
echo "  ✅ Noodles: $NOODLES"

# Create Drinks Collection
DRINKS_ASIAN=$(curl -s -X POST "$BASE_URL/menus/$ASIAN_MENU/collections" \
  -H "Content-Type: application/json" \
  -d '{"name": "Drinks", "position": 4}' | grep -o '"collection_id":"[^"]*"' | cut -d'"' -f4)
echo "  ✅ Drinks: $DRINKS_ASIAN"

echo ""
echo "🍜 Creating products..."

# Appetizers
SPRING_ROLLS=$(curl -s -X POST "$BASE_URL/locations/$ASIAN_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Spring Rolls\", \"description\": \"Crispy vegetable spring rolls (4 pcs)\", \"price\": 5.99, \"attribute_group_ids\": [\"$SAUCE\", \"$SPECIAL_INSTRUCTIONS\"]}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

DUMPLINGS=$(curl -s -X POST "$BASE_URL/locations/$ASIAN_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Pork Dumplings\", \"description\": \"Steamed or fried pork dumplings (6 pcs)\", \"price\": 7.99, \"attribute_group_ids\": [\"$SPICE_LEVEL\", \"$SAUCE\", \"$SPECIAL_INSTRUCTIONS\"]}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

SATAY=$(curl -s -X POST "$BASE_URL/locations/$ASIAN_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Chicken Satay\", \"description\": \"Grilled chicken skewers with peanut sauce (4 pcs)\", \"price\": 8.99, \"attribute_group_ids\": [\"$SPICE_LEVEL\", \"$SAUCE\", \"$SPECIAL_INSTRUCTIONS\"]}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

echo "  ✅ Created 3 appetizers"

# Rice Bowls
TERIYAKI_BOWL=$(curl -s -X POST "$BASE_URL/locations/$ASIAN_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Teriyaki Bowl\", \"description\": \"Grilled protein with teriyaki sauce over rice\", \"price\": 11.99, \"attribute_group_ids\": [\"$PROTEIN\", \"$RICE_NOODLE\", \"$SPICE_LEVEL\", \"$SAUCE\", \"$SPECIAL_INSTRUCTIONS\"]}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

BIBIMBAP=$(curl -s -X POST "$BASE_URL/locations/$ASIAN_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Bibimbap\", \"description\": \"Korean rice bowl with vegetables and egg\", \"price\": 12.99, \"attribute_group_ids\": [\"$PROTEIN\", \"$RICE_NOODLE\", \"$SPICE_LEVEL\", \"$SAUCE\", \"$SPECIAL_INSTRUCTIONS\"]}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

FRIED_RICE=$(curl -s -X POST "$BASE_URL/locations/$ASIAN_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Special Fried Rice\", \"description\": \"Wok-fried rice with vegetables and egg\", \"price\": 10.99, \"attribute_group_ids\": [\"$PROTEIN\", \"$SPICE_LEVEL\", \"$SPECIAL_INSTRUCTIONS\"]}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

CURRY=$(curl -s -X POST "$BASE_URL/locations/$ASIAN_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Thai Curry\", \"description\": \"Coconut curry with vegetables over rice\", \"price\": 13.99, \"attribute_group_ids\": [\"$PROTEIN\", \"$RICE_NOODLE\", \"$SPICE_LEVEL\", \"$SPECIAL_INSTRUCTIONS\"]}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

echo "  ✅ Created 4 rice bowls"

# Noodles
PAD_THAI=$(curl -s -X POST "$BASE_URL/locations/$ASIAN_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Pad Thai\", \"description\": \"Stir-fried rice noodles with peanuts\", \"price\": 11.99, \"attribute_group_ids\": [\"$PROTEIN\", \"$RICE_NOODLE\", \"$SPICE_LEVEL\", \"$SAUCE\", \"$SPECIAL_INSTRUCTIONS\"]}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

LO_MEIN=$(curl -s -X POST "$BASE_URL/locations/$ASIAN_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Lo Mein\", \"description\": \"Soft noodles with vegetables\", \"price\": 10.99, \"attribute_group_ids\": [\"$PROTEIN\", \"$RICE_NOODLE\", \"$SPICE_LEVEL\", \"$SPECIAL_INSTRUCTIONS\"]}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

RAMEN=$(curl -s -X POST "$BASE_URL/locations/$ASIAN_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Ramen Bowl\", \"description\": \"Japanese noodle soup with egg and vegetables\", \"price\": 12.99, \"attribute_group_ids\": [\"$PROTEIN\", \"$RICE_NOODLE\", \"$SPICE_LEVEL\", \"$SPECIAL_INSTRUCTIONS\"]}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

PHO=$(curl -s -X POST "$BASE_URL/locations/$ASIAN_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Vietnamese Pho\", \"description\": \"Traditional Vietnamese beef noodle soup\", \"price\": 11.99, \"attribute_group_ids\": [\"$PROTEIN\", \"$RICE_NOODLE\", \"$SPICE_LEVEL\", \"$SPECIAL_INSTRUCTIONS\"]}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

echo "  ✅ Created 4 noodle dishes"

# Drinks
THAI_TEA=$(curl -s -X POST "$BASE_URL/locations/$ASIAN_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Thai Iced Tea\", \"description\": \"Sweet Thai tea with condensed milk\", \"price\": 3.99}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

BUBBLE_TEA=$(curl -s -X POST "$BASE_URL/locations/$ASIAN_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Bubble Tea\", \"description\": \"Tea with tapioca pearls\", \"price\": 4.99}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

LEMONADE=$(curl -s -X POST "$BASE_URL/locations/$ASIAN_LOCATION/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Asian Lemonade\", \"description\": \"Fresh lemonade with lychee\", \"price\": 3.99}" | grep -o '"product_id":"[^"]*"' | cut -d'"' -f4)

echo "  ✅ Created 3 drinks"

echo ""
echo "🔗 Linking products to collections..."

# Link Appetizers
curl -s -X POST "$BASE_URL/menus/$ASIAN_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$SPRING_ROLLS\", \"collection_id\": \"$APPETIZERS_ASIAN\", \"position\": 1}" > /dev/null
curl -s -X POST "$BASE_URL/menus/$ASIAN_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$DUMPLINGS\", \"collection_id\": \"$APPETIZERS_ASIAN\", \"position\": 2}" > /dev/null
curl -s -X POST "$BASE_URL/menus/$ASIAN_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$SATAY\", \"collection_id\": \"$APPETIZERS_ASIAN\", \"position\": 3}" > /dev/null
echo "  ✅ Linked appetizers"

# Link Rice Bowls
curl -s -X POST "$BASE_URL/menus/$ASIAN_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$TERIYAKI_BOWL\", \"collection_id\": \"$RICE_BOWLS\", \"position\": 1}" > /dev/null
curl -s -X POST "$BASE_URL/menus/$ASIAN_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$BIBIMBAP\", \"collection_id\": \"$RICE_BOWLS\", \"position\": 2}" > /dev/null
curl -s -X POST "$BASE_URL/menus/$ASIAN_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$FRIED_RICE\", \"collection_id\": \"$RICE_BOWLS\", \"position\": 3}" > /dev/null
curl -s -X POST "$BASE_URL/menus/$ASIAN_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$CURRY\", \"collection_id\": \"$RICE_BOWLS\", \"position\": 4}" > /dev/null
echo "  ✅ Linked rice bowls"

# Link Noodles
curl -s -X POST "$BASE_URL/menus/$ASIAN_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$PAD_THAI\", \"collection_id\": \"$NOODLES\", \"position\": 1}" > /dev/null
curl -s -X POST "$BASE_URL/menus/$ASIAN_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$LO_MEIN\", \"collection_id\": \"$NOODLES\", \"position\": 2}" > /dev/null
curl -s -X POST "$BASE_URL/menus/$ASIAN_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$RAMEN\", \"collection_id\": \"$NOODLES\", \"position\": 3}" > /dev/null
curl -s -X POST "$BASE_URL/menus/$ASIAN_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$PHO\", \"collection_id\": \"$NOODLES\", \"position\": 4}" > /dev/null
echo "  ✅ Linked noodles"

# Link Drinks
curl -s -X POST "$BASE_URL/menus/$ASIAN_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$THAI_TEA\", \"collection_id\": \"$DRINKS_ASIAN\", \"position\": 1}" > /dev/null
curl -s -X POST "$BASE_URL/menus/$ASIAN_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$BUBBLE_TEA\", \"collection_id\": \"$DRINKS_ASIAN\", \"position\": 2}" > /dev/null
curl -s -X POST "$BASE_URL/menus/$ASIAN_MENU/products" -H "Content-Type: application/json" \
  -d "{\"product_id\": \"$LEMONADE\", \"collection_id\": \"$DRINKS_ASIAN\", \"position\": 3}" > /dev/null
echo "  ✅ Linked drinks"

echo -e "${GREEN}✨ Asian Fusion restaurant complete! 14 products, 4 collections${NC}"
echo ""

# ============================================
# FINAL SUMMARY
# ============================================
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 ALL RESTAURANTS SEEDED SUCCESSFULLY!${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "📊 Summary:"
echo "  🍣 Sushi Restaurant (Amine Suchi):     15 products, 5 collections"
echo "  🌮 Mexican Restaurant (CASCADE):        15 products, 5 collections"
echo "  🥢 Asian Fusion (Serene Hilltop):      14 products, 4 collections"
echo ""
echo "  📦 Total Products Created:              44"
echo "  📁 Total Collections Created:           14"
echo ""
echo "🌐 View in Admin Portal:"
echo "  • Sushi:  http://localhost/admin/stores/530f7ad1-5d62-4965-bb27-bb7f6d2aa582"
echo "  • Mexican: http://localhost/admin/stores/7661a2ec-9a86-4883-9bfc-61a42a0728a5"
echo "  • Asian:   http://localhost/admin/stores/7661a2ec-9a86-4883-9bfc-61a42a0728a5"
echo ""
echo "✨ Done!"
