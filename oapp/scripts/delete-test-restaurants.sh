#!/bin/bash
set -e

BASE_URL="http://localhost/api/v1"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  🗑️  Delete Test Restaurants Script                       ║${NC}"
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo ""

# Counter variables
DELETED_MENUS=0
DELETED_LOCATIONS=0
DELETED_STORES=0

# Step 1: Get all stores with name "Test Restaurant"
echo -e "${YELLOW}📋 Step 1: Finding stores named 'Test Restaurant'...${NC}"
STORES_RESPONSE=$(curl -s "$BASE_URL/stores?q=Test%20Restaurant&page_size=100")

# Extract store IDs and names using grep and cut
STORE_IDS=$(echo "$STORES_RESPONSE" | grep -o '"store_id":"[^"]*"' | cut -d'"' -f4)

if [ -z "$STORE_IDS" ]; then
    echo -e "${GREEN}✓ No 'Test Restaurant' stores found. Nothing to delete.${NC}"
    exit 0
fi

# Count stores
STORE_COUNT=$(echo "$STORE_IDS" | wc -l | tr -d ' ')
echo -e "${BLUE}   Found ${STORE_COUNT} store(s) to delete${NC}"
echo ""

# Step 2: For each store, get locations and delete them
for STORE_ID in $STORE_IDS; do
    echo -e "${YELLOW}🏪 Processing store: ${STORE_ID}${NC}"

    # Get store name for display
    STORE_NAME=$(echo "$STORES_RESPONSE" | grep -A 5 "\"store_id\":\"$STORE_ID\"" | grep -o '"name":"[^"]*"' | cut -d'"' -f4 | head -1)
    echo -e "${BLUE}   Store Name: ${STORE_NAME}${NC}"

    # Get all locations for this store
    LOCATIONS_RESPONSE=$(curl -s "$BASE_URL/stores/$STORE_ID/locations?page_size=100")
    LOCATION_IDS=$(echo "$LOCATIONS_RESPONSE" | grep -o '"location_id":"[^"]*"' | cut -d'"' -f4)

    if [ -z "$LOCATION_IDS" ]; then
        echo -e "${BLUE}   No locations found for this store${NC}"
    else
        LOCATION_COUNT=$(echo "$LOCATION_IDS" | wc -l | tr -d ' ')
        echo -e "${BLUE}   Found ${LOCATION_COUNT} location(s)${NC}"

        # Step 3: For each location, find and delete menus, then delete location
        for LOCATION_ID in $LOCATION_IDS; do
            echo -e "${YELLOW}   📍 Processing location: ${LOCATION_ID}${NC}"

            # Get menu_id from database (no API endpoint available)
            MENU_ID=$(docker-compose exec -T postgres psql -U deliveryx -d deliveryx_menu -t -c \
                "SELECT menu_id FROM menus WHERE location_id = '$LOCATION_ID';" 2>/dev/null | tr -d ' \r' | grep -v '^$' | head -1 || true)

            if [ ! -z "$MENU_ID" ]; then
                echo -e "${YELLOW}      🗑️  Deleting menu: ${MENU_ID}${NC}"

                # Delete menu (CASCADE will handle menu_products and collections automatically)
                # No DELETE API endpoint exists for menus
                docker-compose exec -T postgres psql -U deliveryx -d deliveryx_menu -c \
                    "DELETE FROM menus WHERE menu_id = '$MENU_ID';" >/dev/null 2>&1

                DELETED_MENUS=$((DELETED_MENUS + 1))
                echo -e "${GREEN}      ✓ Menu deleted${NC}"
            fi

            # Delete location via API
            echo -e "${YELLOW}      🗑️  Deleting location: ${LOCATION_ID}${NC}"
            HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "$BASE_URL/locations/$LOCATION_ID")

            if [ "$HTTP_CODE" = "204" ]; then
                DELETED_LOCATIONS=$((DELETED_LOCATIONS + 1))
                echo -e "${GREEN}      ✓ Location deleted${NC}"
            elif [ "$HTTP_CODE" = "404" ]; then
                echo -e "${YELLOW}      ⚠ Location not found (may have been deleted)${NC}"
            elif [ "$HTTP_CODE" = "409" ]; then
                echo -e "${RED}      ✗ Location cannot be deleted - has menus (conflict)${NC}"
            else
                echo -e "${RED}      ✗ Failed to delete location (HTTP $HTTP_CODE)${NC}"
            fi
        done
    fi

    # Step 4: Delete the store via API
    echo -e "${YELLOW}   🗑️  Deleting store: ${STORE_ID}${NC}"
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "$BASE_URL/stores/$STORE_ID")

    if [ "$HTTP_CODE" = "204" ]; then
        DELETED_STORES=$((DELETED_STORES + 1))
        echo -e "${GREEN}   ✓ Store deleted successfully${NC}"
    elif [ "$HTTP_CODE" = "404" ]; then
        echo -e "${YELLOW}   ⚠ Store not found (may have been deleted)${NC}"
    elif [ "$HTTP_CODE" = "409" ]; then
        echo -e "${RED}   ✗ Store cannot be deleted - still has locations (conflict)${NC}"
    else
        echo -e "${RED}   ✗ Failed to delete store (HTTP $HTTP_CODE)${NC}"
    fi

    echo ""
done

# Summary
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  📊 Deletion Summary                                       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}✓ Menus Deleted:     ${DELETED_MENUS}${NC}"
echo -e "${GREEN}✓ Locations Deleted: ${DELETED_LOCATIONS}${NC}"
echo -e "${GREEN}✓ Stores Deleted:    ${DELETED_STORES}${NC}"
echo ""

if [ $DELETED_STORES -eq $STORE_COUNT ]; then
    echo -e "${GREEN}🎉 ALL TEST RESTAURANTS DELETED SUCCESSFULLY!${NC}"
else
    echo -e "${YELLOW}⚠️  Some stores may not have been deleted. Check output above.${NC}"
fi
echo ""
