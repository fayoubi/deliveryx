# DeliveryX SQL Query Reference

This document provides SQL queries mapped to each Postman test scenario for validating data in the PostgreSQL databases.

---

## 📋 **Table of Contents**
1. [Restaurant Service - Stores](#restaurant-service---stores)
2. [Restaurant Service - Locations](#restaurant-service---locations)
3. [Restaurant Service - Operating Hours](#restaurant-service---operating-hours)
4. [Menu Service - Attribute Groups](#menu-service---attribute-groups)
5. [Menu Service - Menus](#menu-service---menus)
6. [Menu Service - Collections](#menu-service---collections)
7. [Menu Service - Products](#menu-service---products)
8. [Menu Service - Menu Composition](#menu-service---menu-composition)
9. [Menu Service - Workflow](#menu-service---workflow)
10. [Approval Service](#approval-service)
11. [Cross-Database Validation](#cross-database-validation)

---

## 🏪 **Restaurant Service - Stores**

### **Test 1: Create Store**

**Postman Request**: `POST /api/v1/stores`

**Before Query** (verify no store exists yet):
```sql
-- Connect to deliveryx_restaurant database
\c deliveryx_restaurant

-- Count total stores (should be 0 initially)
SELECT COUNT(*) FROM stores;
```

**After Query** (verify store was created):
```sql
-- View the newly created store
SELECT * FROM stores ORDER BY created_at DESC LIMIT 1;

-- Or query by specific store_id (from Postman response)
SELECT * FROM stores WHERE store_id = 'YOUR_STORE_ID_HERE';

-- Expected result:
-- store_id: UUID
-- name: "Pizza Paradise" (or your test value)
-- description: "Best pizzas in town"
-- is_active: true
-- created_at: timestamp
-- updated_at: timestamp
```

**Validation Checklist**:
- ✅ store_id is a valid UUID
- ✅ name matches the request body
- ✅ description matches the request body
- ✅ is_active is true by default
- ✅ created_at and updated_at are populated

---

## 📍 **Restaurant Service - Locations**

### **Test 2: Create Location**

**Postman Request**: `POST /api/v1/stores/{store_id}/locations`

**Before Query**:
```sql
\c deliveryx_restaurant

-- Count locations for this store (should be 0)
SELECT COUNT(*) FROM locations WHERE store_id = 'YOUR_STORE_ID_HERE';
```

**After Query**:
```sql
-- View the newly created location
SELECT * FROM locations
WHERE store_id = 'YOUR_STORE_ID_HERE'
ORDER BY created_at DESC LIMIT 1;

-- Or query by specific location_id
SELECT * FROM locations WHERE location_id = 'YOUR_LOCATION_ID_HERE';

-- View store with its locations (JOIN)
SELECT
    s.store_id,
    s.name AS store_name,
    l.location_id,
    l.city,
    l.address,
    l.postal_code,
    l.latitude,
    l.longitude,
    l.phone_number,
    l.is_active
FROM stores s
LEFT JOIN locations l ON s.store_id = l.store_id
WHERE s.store_id = 'YOUR_STORE_ID_HERE';
```

**Expected Result**:
```
location_id: UUID
store_id: matches request
city: "New York"
address: "123 Broadway St"
postal_code: "10001"
latitude: 40.7128
longitude: -74.0060
phone_number: "+1234567890"
is_active: true
```

**Validation Checklist**:
- ✅ location_id is a valid UUID
- ✅ store_id matches the parent store
- ✅ All address fields are populated correctly
- ✅ Coordinates are valid (latitude: -90 to 90, longitude: -180 to 180)
- ✅ is_active is true by default

---

## ⏰ **Restaurant Service - Operating Hours**

### **Test 3: Create Operating Hours**

**Postman Request**: `POST /api/v1/locations/{location_id}/operating-hours`

**Before Query**:
```sql
\c deliveryx_restaurant

-- Count operating hours for this location (should be 0)
SELECT COUNT(*) FROM operating_hours WHERE location_id = 'YOUR_LOCATION_ID_HERE';
```

**After Query**:
```sql
-- View all operating hours for this location (sorted by day of week)
SELECT
    id,
    location_id,
    day_of_week,
    open_time,
    close_time,
    is_closed,
    created_at
FROM operating_hours
WHERE location_id = 'YOUR_LOCATION_ID_HERE'
ORDER BY
    CASE day_of_week
        WHEN 'MONDAY' THEN 1
        WHEN 'TUESDAY' THEN 2
        WHEN 'WEDNESDAY' THEN 3
        WHEN 'THURSDAY' THEN 4
        WHEN 'FRIDAY' THEN 5
        WHEN 'SATURDAY' THEN 6
        WHEN 'SUNDAY' THEN 7
    END;

-- View location with operating hours (JOIN)
SELECT
    l.location_id,
    l.city,
    l.address,
    oh.day_of_week,
    oh.open_time,
    oh.close_time,
    oh.is_closed
FROM locations l
LEFT JOIN operating_hours oh ON l.location_id = oh.location_id
WHERE l.location_id = 'YOUR_LOCATION_ID_HERE'
ORDER BY
    CASE oh.day_of_week
        WHEN 'MONDAY' THEN 1
        WHEN 'TUESDAY' THEN 2
        WHEN 'WEDNESDAY' THEN 3
        WHEN 'THURSDAY' THEN 4
        WHEN 'FRIDAY' THEN 5
        WHEN 'SATURDAY' THEN 6
        WHEN 'SUNDAY' THEN 7
    END;

-- Count operating hours per location
SELECT
    l.city,
    COUNT(oh.id) AS num_operating_hours
FROM locations l
LEFT JOIN operating_hours oh ON l.location_id = oh.location_id
WHERE l.location_id = 'YOUR_LOCATION_ID_HERE'
GROUP BY l.location_id, l.city;
```

**Expected Result** (should have 7 rows, one per day):
```
MONDAY:    09:00:00 - 22:00:00 (is_closed: false)
TUESDAY:   09:00:00 - 22:00:00 (is_closed: false)
WEDNESDAY: 09:00:00 - 22:00:00 (is_closed: false)
THURSDAY:  09:00:00 - 22:00:00 (is_closed: false)
FRIDAY:    09:00:00 - 22:00:00 (is_closed: false)
SATURDAY:  10:00:00 - 23:00:00 (is_closed: false)
SUNDAY:    10:00:00 - 21:00:00 (is_closed: false)
```

**Validation Checklist**:
- ✅ Exactly 7 rows (one per day of week)
- ✅ All days are present (MONDAY through SUNDAY)
- ✅ Times are in HH:MM:SS format
- ✅ open_time is before close_time
- ✅ is_closed is false for open days

---

## 🎨 **Menu Service - Attribute Groups**

### **Test 4: Get Attribute Groups (Seeded Data)**

**Postman Request**: `GET /api/v1/attribute-groups`

**Validation Query**:
```sql
-- Connect to deliveryx_menu database
\c deliveryx_menu

-- View all attribute groups
SELECT * FROM attribute_groups ORDER BY name;

-- Expected: 4 attribute groups (Size, Toppings, Crust, Drinks)
SELECT COUNT(*) as total_attribute_groups FROM attribute_groups;

-- View attributes for each group
SELECT
    ag.id AS group_id,
    ag.name AS group_name,
    ag.min_selections,
    ag.max_selections,
    COUNT(a.id) AS num_attributes
FROM attribute_groups ag
LEFT JOIN attributes a ON ag.id = a.attribute_group_id
GROUP BY ag.id, ag.name, ag.min_selections, ag.max_selections
ORDER BY ag.name;

-- View detailed attributes for "Size" group
SELECT
    ag.name AS group_name,
    a.name AS attribute_name,
    a.price_impact,
    a.is_default
FROM attribute_groups ag
JOIN attributes a ON ag.id = a.attribute_group_id
WHERE ag.name = 'Size'
ORDER BY a.price_impact;

-- View all attributes with their groups
SELECT
    ag.name AS group_name,
    a.name AS attribute_name,
    a.price_impact,
    a.is_default
FROM attribute_groups ag
JOIN attributes a ON ag.id = a.attribute_group_id
ORDER BY ag.name, a.price_impact;
```

**Expected Attribute Groups**:
```
1. Size (min: 1, max: 1)
   - Small (price_impact: 0.00, is_default: true)
   - Medium (price_impact: 2.00)
   - Large (price_impact: 4.00)

2. Toppings (min: 0, max: 5)
   - Pepperoni (price_impact: 1.50)
   - Mushrooms (price_impact: 1.00)
   - Olives (price_impact: 1.00)
   - Extra Cheese (price_impact: 2.00)

3. Crust (min: 1, max: 1)
   - Regular (price_impact: 0.00, is_default: true)
   - Thin (price_impact: 0.00)
   - Thick (price_impact: 1.50)

4. Drinks (min: 0, max: 3)
   - Coke (price_impact: 2.50)
   - Sprite (price_impact: 2.50)
   - Water (price_impact: 1.00)
```

**Validation Checklist**:
- ✅ 4 attribute groups exist
- ✅ Each group has min/max selections
- ✅ Each group has multiple attributes
- ✅ Price impacts are reasonable
- ✅ Some attributes have is_default = true

---

## 📋 **Menu Service - Menus**

### **Test 5: Create Menu (Draft)**

**Postman Request**: `POST /api/v1/menus`

**Before Query**:
```sql
\c deliveryx_menu

-- Count menus for this location (should be 0)
SELECT COUNT(*) FROM menus WHERE location_id = 'YOUR_LOCATION_ID_HERE';
```

**After Query**:
```sql
-- View the newly created menu
SELECT * FROM menus
WHERE location_id = 'YOUR_LOCATION_ID_HERE'
ORDER BY created_at DESC LIMIT 1;

-- Or query by specific menu_id
SELECT
    menu_id,
    location_id,
    status,
    submitted_at,
    reviewed_at,
    rejection_reason,
    created_at,
    updated_at
FROM menus
WHERE menu_id = 'YOUR_MENU_ID_HERE';

-- Count menus by status
SELECT status, COUNT(*) as count
FROM menus
GROUP BY status;
```

**Expected Result**:
```
menu_id: UUID
location_id: matches request
status: "draft"
submitted_at: NULL
reviewed_at: NULL
rejection_reason: NULL
created_at: timestamp
updated_at: timestamp
```

**Validation Checklist**:
- ✅ menu_id is a valid UUID
- ✅ location_id matches the request
- ✅ status is "draft" (default)
- ✅ submitted_at is NULL (not yet submitted)
- ✅ reviewed_at is NULL (not yet reviewed)
- ✅ rejection_reason is NULL

---

## 🗂️ **Menu Service - Collections**

### **Test 6: Create Collection**

**Postman Request**: `POST /api/v1/menus/{menu_id}/collections`

**Before Query**:
```sql
\c deliveryx_menu

-- Count collections for this menu (should be 0)
SELECT COUNT(*) FROM collections WHERE menu_id = 'YOUR_MENU_ID_HERE';
```

**After Query**:
```sql
-- View all collections for this menu (ordered by position)
SELECT
    collection_id,
    menu_id,
    name,
    description,
    position,
    image_url,
    created_at
FROM collections
WHERE menu_id = 'YOUR_MENU_ID_HERE'
ORDER BY position;

-- View menu with its collections
SELECT
    m.menu_id,
    m.status AS menu_status,
    c.collection_id,
    c.name AS collection_name,
    c.position,
    c.image_url
FROM menus m
LEFT JOIN collections c ON m.menu_id = c.menu_id
WHERE m.menu_id = 'YOUR_MENU_ID_HERE'
ORDER BY c.position;

-- Count collections per menu
SELECT
    m.menu_id,
    m.status,
    COUNT(c.collection_id) AS num_collections
FROM menus m
LEFT JOIN collections c ON m.menu_id = c.menu_id
WHERE m.menu_id = 'YOUR_MENU_ID_HERE'
GROUP BY m.menu_id, m.status;
```

**Expected Result**:
```
collection_id: UUID
menu_id: matches request
name: "Pizzas" (or your test value)
description: "Our delicious pizzas"
position: 1
image_url: "https://example.com/pizzas.jpg"
```

**Validation Checklist**:
- ✅ collection_id is a valid UUID
- ✅ menu_id matches the parent menu
- ✅ name matches the request
- ✅ position starts at 1 for first collection
- ✅ image_url is a valid URL

---

## 🍕 **Menu Service - Products**

### **Test 7: Create Product**

**Postman Request**: `POST /api/v1/products`

**Before Query**:
```sql
\c deliveryx_menu

-- Count total products
SELECT COUNT(*) FROM products;
```

**After Query**:
```sql
-- View the newly created product
SELECT * FROM products ORDER BY created_at DESC LIMIT 1;

-- Or query by specific product_id
SELECT
    product_id,
    name,
    description,
    price,
    category,
    image_url,
    is_available,
    created_at,
    updated_at
FROM products
WHERE product_id = 'YOUR_PRODUCT_ID_HERE';

-- Count products by category
SELECT category, COUNT(*) as count
FROM products
GROUP BY category
ORDER BY count DESC;

-- Count available vs unavailable products
SELECT is_available, COUNT(*) as count
FROM products
GROUP BY is_available;
```

**Expected Result**:
```
product_id: UUID
name: "Margherita Pizza"
description: "Classic tomato and mozzarella"
price: 12.99
category: "pizza"
image_url: "https://example.com/margherita.jpg"
is_available: true
```

**Validation Checklist**:
- ✅ product_id is a valid UUID
- ✅ name matches the request
- ✅ price is a positive decimal (2 decimal places)
- ✅ category is populated
- ✅ is_available is true by default

---

## 🎯 **Menu Service - Menu Composition**

### **Test 8: Add Product to Collection**

**Postman Request**: `POST /api/v1/menus/{menu_id}/collections/{collection_id}/products/{product_id}`

**Before Query**:
```sql
\c deliveryx_menu

-- Count products in this collection (should be 0)
SELECT COUNT(*) FROM menu_products
WHERE menu_id = 'YOUR_MENU_ID_HERE'
AND collection_id = 'YOUR_COLLECTION_ID_HERE';
```

**After Query**:
```sql
-- View all products in this collection
SELECT
    mp.menu_id,
    mp.collection_id,
    mp.product_id,
    mp.position,
    p.name AS product_name,
    p.price,
    p.is_available
FROM menu_products mp
JOIN products p ON mp.product_id = p.product_id
WHERE mp.menu_id = 'YOUR_MENU_ID_HERE'
AND mp.collection_id = 'YOUR_COLLECTION_ID_HERE'
ORDER BY mp.position;

-- View complete menu composition (all collections and products)
SELECT
    m.menu_id,
    m.status AS menu_status,
    c.name AS collection_name,
    c.position AS collection_position,
    p.name AS product_name,
    p.price,
    p.is_available,
    mp.position AS product_position
FROM menus m
JOIN collections c ON m.menu_id = c.menu_id
JOIN menu_products mp ON m.menu_id = mp.menu_id AND c.collection_id = mp.collection_id
JOIN products p ON mp.product_id = p.product_id
WHERE m.menu_id = 'YOUR_MENU_ID_HERE'
ORDER BY c.position, mp.position;

-- Count products per collection
SELECT
    c.name AS collection_name,
    COUNT(mp.product_id) AS num_products
FROM collections c
LEFT JOIN menu_products mp ON c.collection_id = mp.collection_id AND c.menu_id = mp.menu_id
WHERE c.menu_id = 'YOUR_MENU_ID_HERE'
GROUP BY c.collection_id, c.name
ORDER BY c.position;
```

**Expected Result**:
```
menu_id: UUID
collection_id: UUID
product_id: UUID
position: 1 (or next available position)
```

**Validation Checklist**:
- ✅ Product exists in menu_products table
- ✅ menu_id, collection_id, product_id all match request
- ✅ position is sequential (1, 2, 3, etc.)
- ✅ Product can be joined to collections and menus

### **Test 9: Add Attribute Group to Product**

**Postman Request**: `POST /api/v1/products/{product_id}/attribute-groups/{attribute_group_id}`

**Before Query**:
```sql
\c deliveryx_menu

-- Count attribute groups for this product (should be 0)
SELECT COUNT(*) FROM product_attribute_groups
WHERE product_id = 'YOUR_PRODUCT_ID_HERE';
```

**After Query**:
```sql
-- View all attribute groups for this product
SELECT
    pag.product_id,
    pag.attribute_group_id,
    p.name AS product_name,
    ag.name AS attribute_group_name,
    ag.min_selections,
    ag.max_selections
FROM product_attribute_groups pag
JOIN products p ON pag.product_id = p.product_id
JOIN attribute_groups ag ON pag.attribute_group_id = ag.id
WHERE pag.product_id = 'YOUR_PRODUCT_ID_HERE';

-- View product with all its attribute groups and attributes
SELECT
    p.name AS product_name,
    ag.name AS attribute_group_name,
    ag.min_selections,
    ag.max_selections,
    a.name AS attribute_name,
    a.price_impact,
    a.is_default
FROM products p
JOIN product_attribute_groups pag ON p.product_id = pag.product_id
JOIN attribute_groups ag ON pag.attribute_group_id = ag.id
JOIN attributes a ON ag.id = a.attribute_group_id
WHERE p.product_id = 'YOUR_PRODUCT_ID_HERE'
ORDER BY ag.name, a.price_impact;

-- Count attribute groups per product
SELECT
    p.name AS product_name,
    COUNT(pag.attribute_group_id) AS num_attribute_groups
FROM products p
LEFT JOIN product_attribute_groups pag ON p.product_id = pag.product_id
WHERE p.product_id = 'YOUR_PRODUCT_ID_HERE'
GROUP BY p.product_id, p.name;
```

**Expected Result**:
```
product_id: UUID
attribute_group_id: UUID
(Link exists in product_attribute_groups table)
```

**Validation Checklist**:
- ✅ Link exists in product_attribute_groups table
- ✅ product_id and attribute_group_id match request
- ✅ Attribute group exists and can be joined
- ✅ All attributes for the group are accessible

---

## 🔄 **Menu Service - Workflow**

### **Test 10: Submit Menu for Review**

**Postman Request**: `POST /api/v1/menus/{menu_id}/submit`

**Before Query**:
```sql
\c deliveryx_menu

-- Verify menu is in draft status
SELECT menu_id, status, submitted_at
FROM menus
WHERE menu_id = 'YOUR_MENU_ID_HERE';
```

**After Query**:
```sql
-- Verify menu status changed to pending_review
SELECT
    menu_id,
    location_id,
    status,
    submitted_at,
    reviewed_at,
    rejection_reason,
    updated_at
FROM menus
WHERE menu_id = 'YOUR_MENU_ID_HERE';

-- Count menus by status (should see pending_review count increase)
SELECT status, COUNT(*) as count
FROM menus
GROUP BY status;
```

**Expected Result**:
```
menu_id: UUID
status: "pending_review" (changed from "draft")
submitted_at: timestamp (now populated)
reviewed_at: NULL (not yet reviewed)
rejection_reason: NULL
```

**Validation Checklist**:
- ✅ status changed from "draft" to "pending_review"
- ✅ submitted_at is now populated with timestamp
- ✅ reviewed_at is still NULL
- ✅ rejection_reason is still NULL

**RabbitMQ Validation**:
```sql
-- After submitting, check RabbitMQ consumer logs
-- You should see: "🎯 Processing menu-submitted event for menu_id: YOUR_MENU_ID"

-- Alternatively, check approval_logs table (if consumer processes it)
\c deliveryx_approval
SELECT * FROM approval_logs WHERE menu_id = 'YOUR_MENU_ID_HERE';
```

---

## ✅ **Approval Service**

### **Test 11: Approve Menu**

**Postman Request**: `POST /api/v1/approvals/menus/{menu_id}/approve`

**Before Query**:
```sql
-- Check menu status in Menu Service
\c deliveryx_menu
SELECT menu_id, status, reviewed_at FROM menus WHERE menu_id = 'YOUR_MENU_ID_HERE';

-- Check approval logs in Approval Service (should be empty or show only submission)
\c deliveryx_approval
SELECT * FROM approval_logs WHERE menu_id = 'YOUR_MENU_ID_HERE';
```

**After Query**:
```sql
-- Verify menu status changed to approved (in Menu Service)
\c deliveryx_menu
SELECT
    menu_id,
    location_id,
    status,
    submitted_at,
    reviewed_at,
    rejection_reason,
    updated_at
FROM menus
WHERE menu_id = 'YOUR_MENU_ID_HERE';

-- Verify approval was logged (in Approval Service)
\c deliveryx_approval
SELECT
    id,
    menu_id,
    action,
    admin_email,
    rejection_reason,
    created_at
FROM approval_logs
WHERE menu_id = 'YOUR_MENU_ID_HERE'
ORDER BY created_at DESC;
```

**Expected Result (Menu Service)**:
```
menu_id: UUID
status: "approved" (changed from "pending_review")
submitted_at: timestamp (unchanged)
reviewed_at: timestamp (now populated)
rejection_reason: NULL
```

**Expected Result (Approval Service)**:
```
id: serial ID
menu_id: UUID
action: "approved"
admin_email: "admin@deliveryx.com" (from X-Admin-Email header)
rejection_reason: NULL
created_at: timestamp
```

**Validation Checklist**:
- ✅ Menu status is "approved" in deliveryx_menu database
- ✅ reviewed_at is now populated
- ✅ Approval log exists in deliveryx_approval database
- ✅ action is "approved"
- ✅ admin_email matches request header

### **Test 12: Reject Menu**

**Postman Request**: `POST /api/v1/approvals/menus/{menu_id}/reject`

**Before Query**:
```sql
-- Verify menu is in pending_review status
\c deliveryx_menu
SELECT menu_id, status FROM menus WHERE menu_id = 'YOUR_MENU_ID_HERE';
```

**After Query**:
```sql
-- Verify menu status changed to rejected
\c deliveryx_menu
SELECT
    menu_id,
    status,
    submitted_at,
    reviewed_at,
    rejection_reason,
    updated_at
FROM menus
WHERE menu_id = 'YOUR_MENU_ID_HERE';

-- Verify rejection was logged
\c deliveryx_approval
SELECT
    id,
    menu_id,
    action,
    admin_email,
    rejection_reason,
    created_at
FROM approval_logs
WHERE menu_id = 'YOUR_MENU_ID_HERE'
ORDER BY created_at DESC LIMIT 1;
```

**Expected Result (Menu Service)**:
```
menu_id: UUID
status: "rejected" (changed from "pending_review")
submitted_at: timestamp (unchanged)
reviewed_at: timestamp (now populated)
rejection_reason: "Prices are too high" (from request body)
```

**Expected Result (Approval Service)**:
```
id: serial ID
menu_id: UUID
action: "rejected"
admin_email: "admin@deliveryx.com"
rejection_reason: "Prices are too high"
created_at: timestamp
```

**Validation Checklist**:
- ✅ Menu status is "rejected" in deliveryx_menu database
- ✅ rejection_reason is populated in menus table
- ✅ Rejection log exists in deliveryx_approval database
- ✅ action is "rejected"
- ✅ rejection_reason matches request body

### **Test 13: Get Approval History**

**Postman Request**: `GET /api/v1/approvals/menus/{menu_id}/history`

**Validation Query**:
```sql
\c deliveryx_approval

-- View all approval actions for this menu (chronological order)
SELECT
    id,
    menu_id,
    action,
    admin_email,
    rejection_reason,
    created_at
FROM approval_logs
WHERE menu_id = 'YOUR_MENU_ID_HERE'
ORDER BY created_at ASC;

-- Count actions for this menu
SELECT
    menu_id,
    COUNT(*) AS total_actions,
    COUNT(CASE WHEN action = 'approved' THEN 1 END) AS approvals,
    COUNT(CASE WHEN action = 'rejected' THEN 1 END) AS rejections
FROM approval_logs
WHERE menu_id = 'YOUR_MENU_ID_HERE'
GROUP BY menu_id;
```

**Expected Result**:
```
Multiple rows showing the audit trail:
1. action: "submitted" (if logged) - created_at: timestamp1
2. action: "rejected" - created_at: timestamp2
3. action: "approved" - created_at: timestamp3
```

**Validation Checklist**:
- ✅ All actions are present in chronological order
- ✅ Each action has admin_email (if applicable)
- ✅ Rejection actions have rejection_reason
- ✅ Timestamps are in ascending order

---

## 🔗 **Cross-Database Validation**

### **Complete Workflow Validation**

This validates data consistency across all three databases after running the complete workflow.

```sql
-- STEP 1: Verify Store and Location exist (Restaurant Service)
\c deliveryx_restaurant

SELECT
    s.store_id,
    s.name AS store_name,
    l.location_id,
    l.city,
    l.address
FROM stores s
JOIN locations l ON s.store_id = l.store_id
WHERE s.store_id = 'YOUR_STORE_ID_HERE';

-- Copy the location_id from the result

-- STEP 2: Verify Menu exists for this location (Menu Service)
\c deliveryx_menu

SELECT
    menu_id,
    location_id,
    status,
    submitted_at,
    reviewed_at,
    rejection_reason
FROM menus
WHERE location_id = 'YOUR_LOCATION_ID_HERE';

-- Copy the menu_id from the result

-- STEP 3: Verify Menu has Collections and Products (Menu Service)
SELECT
    m.menu_id,
    m.status,
    c.name AS collection_name,
    c.position AS collection_position,
    p.name AS product_name,
    p.price,
    mp.position AS product_position
FROM menus m
JOIN collections c ON m.menu_id = c.menu_id
JOIN menu_products mp ON m.menu_id = mp.menu_id AND c.collection_id = mp.collection_id
JOIN products p ON mp.product_id = p.product_id
WHERE m.menu_id = 'YOUR_MENU_ID_HERE'
ORDER BY c.position, mp.position;

-- STEP 4: Verify Approval History exists (Approval Service)
\c deliveryx_approval

SELECT
    menu_id,
    action,
    admin_email,
    rejection_reason,
    created_at
FROM approval_logs
WHERE menu_id = 'YOUR_MENU_ID_HERE'
ORDER BY created_at DESC;

-- STEP 5: Cross-reference all data
-- Run this multi-database query manually by switching databases

-- Restaurant DB: Get location details
\c deliveryx_restaurant
SELECT location_id, city FROM locations WHERE location_id = 'YOUR_LOCATION_ID_HERE';

-- Menu DB: Get menu details for this location
\c deliveryx_menu
SELECT menu_id, status, submitted_at FROM menus WHERE location_id = 'YOUR_LOCATION_ID_HERE';

-- Approval DB: Get approval history for this menu
\c deliveryx_approval
SELECT action, admin_email, created_at FROM approval_logs WHERE menu_id = 'YOUR_MENU_ID_HERE';
```

### **Data Consistency Checks**

```sql
-- Check for orphaned menus (menus with invalid location_id)
\c deliveryx_menu
SELECT m.menu_id, m.location_id
FROM menus m
WHERE NOT EXISTS (
    -- This would require a foreign database query
    -- Manually verify location_id exists in deliveryx_restaurant.locations
    SELECT 1 FROM pg_database WHERE false  -- Placeholder
);
-- Note: PostgreSQL doesn't support cross-database JOINs
-- Manually verify location_id exists in Restaurant Service database

-- Check for menus without collections
\c deliveryx_menu
SELECT m.menu_id, m.status, COUNT(c.collection_id) AS num_collections
FROM menus m
LEFT JOIN collections c ON m.menu_id = c.menu_id
GROUP BY m.menu_id, m.status
HAVING COUNT(c.collection_id) = 0;

-- Check for collections without products
\c deliveryx_menu
SELECT c.collection_id, c.name, COUNT(mp.product_id) AS num_products
FROM collections c
LEFT JOIN menu_products mp ON c.collection_id = mp.collection_id
GROUP BY c.collection_id, c.name
HAVING COUNT(mp.product_id) = 0;

-- Check for products without attribute groups
\c deliveryx_menu
SELECT p.product_id, p.name, COUNT(pag.attribute_group_id) AS num_attribute_groups
FROM products p
LEFT JOIN product_attribute_groups pag ON p.product_id = pag.product_id
GROUP BY p.product_id, p.name
HAVING COUNT(pag.attribute_group_id) = 0;

-- Check for menus with status inconsistencies
\c deliveryx_menu
-- Menus marked as approved but missing reviewed_at timestamp
SELECT menu_id, status, reviewed_at FROM menus WHERE status = 'approved' AND reviewed_at IS NULL;

-- Menus marked as draft but have submitted_at timestamp
SELECT menu_id, status, submitted_at FROM menus WHERE status = 'draft' AND submitted_at IS NOT NULL;

-- Check for approval logs without corresponding admin_email
\c deliveryx_approval
SELECT id, menu_id, action, admin_email
FROM approval_logs
WHERE action IN ('approved', 'rejected') AND admin_email IS NULL;
```

---

## 📊 **Aggregate Validation Queries**

### **Overall Statistics**

```sql
-- Restaurant Service Statistics
\c deliveryx_restaurant

SELECT
    (SELECT COUNT(*) FROM stores) AS total_stores,
    (SELECT COUNT(*) FROM locations) AS total_locations,
    (SELECT COUNT(*) FROM operating_hours) AS total_operating_hours;

SELECT
    s.name AS store_name,
    COUNT(l.location_id) AS num_locations
FROM stores s
LEFT JOIN locations l ON s.store_id = l.store_id
GROUP BY s.store_id, s.name
ORDER BY num_locations DESC;

-- Menu Service Statistics
\c deliveryx_menu

SELECT
    (SELECT COUNT(*) FROM menus) AS total_menus,
    (SELECT COUNT(*) FROM collections) AS total_collections,
    (SELECT COUNT(*) FROM products) AS total_products,
    (SELECT COUNT(*) FROM attribute_groups) AS total_attribute_groups;

SELECT
    status,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM menus), 2) AS percentage
FROM menus
GROUP BY status
ORDER BY count DESC;

-- Approval Service Statistics
\c deliveryx_approval

SELECT
    action,
    COUNT(*) AS count,
    COUNT(DISTINCT menu_id) AS unique_menus,
    COUNT(DISTINCT admin_email) AS unique_admins
FROM approval_logs
GROUP BY action
ORDER BY count DESC;

SELECT
    admin_email,
    COUNT(*) AS total_actions,
    COUNT(CASE WHEN action = 'approved' THEN 1 END) AS approvals,
    COUNT(CASE WHEN action = 'rejected' THEN 1 END) AS rejections
FROM approval_logs
WHERE admin_email IS NOT NULL
GROUP BY admin_email
ORDER BY total_actions DESC;
```

---

## 🛠️ **Troubleshooting Queries**

### **Finding Missing Data**

```sql
-- Find menus that were submitted but never reviewed
\c deliveryx_menu
SELECT menu_id, location_id, submitted_at, status
FROM menus
WHERE submitted_at IS NOT NULL AND reviewed_at IS NULL AND status = 'pending_review';

-- Find menus that were reviewed but have no approval logs
\c deliveryx_menu
SELECT menu_id, status, reviewed_at FROM menus WHERE reviewed_at IS NOT NULL;
-- Copy menu_id values

\c deliveryx_approval
SELECT menu_id FROM approval_logs WHERE menu_id IN ('menu_id1', 'menu_id2', ...);
-- Compare: menus with reviewed_at should have approval logs

-- Find products that aren't in any menu
\c deliveryx_menu
SELECT p.product_id, p.name
FROM products p
WHERE NOT EXISTS (
    SELECT 1 FROM menu_products mp WHERE mp.product_id = p.product_id
);

-- Find collections with duplicate positions
\c deliveryx_menu
SELECT menu_id, position, COUNT(*)
FROM collections
GROUP BY menu_id, position
HAVING COUNT(*) > 1;
```

---

## ✅ **Complete Test Validation Checklist**

After running the complete Postman collection, verify:

### **Restaurant Service**:
- ✅ At least 1 store exists
- ✅ At least 1 location exists for the store
- ✅ 7 operating hours exist for the location (one per day)
- ✅ Foreign key relationships are valid (location.store_id → stores.store_id)

### **Menu Service**:
- ✅ At least 1 menu exists for the location
- ✅ 4 seeded attribute groups exist
- ✅ At least 1 collection exists in the menu
- ✅ At least 1 product exists
- ✅ Product is linked to collection via menu_products
- ✅ Product is linked to attribute groups via product_attribute_groups
- ✅ Menu status changed from "draft" → "pending_review" after submission
- ✅ Menu status changed to "approved" or "rejected" after approval/rejection

### **Approval Service**:
- ✅ Approval log exists for approve or reject action
- ✅ admin_email is populated in approval logs
- ✅ rejection_reason is populated for rejected menus
- ✅ Timestamps are in chronological order

### **Cross-Database**:
- ✅ Menu.location_id matches a valid location in Restaurant Service
- ✅ Approval logs reference valid menu_id from Menu Service
- ✅ No orphaned records
- ✅ No data inconsistencies (e.g., approved menus without reviewed_at)

---

## 📚 **Additional Resources**

- **DATABASE-CONNECTION-GUIDE.md**: Instructions for connecting to PostgreSQL
- **POSTMAN-USAGE-GUIDE.md**: Step-by-step guide for running Postman tests
- **OpenAPI Docs**: http://localhost:8090 (interactive API documentation)

---

**Happy Testing! 🚀**
