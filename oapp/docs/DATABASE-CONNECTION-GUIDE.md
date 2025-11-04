# DeliveryX Database Connection Guide

This guide explains how to connect to the PostgreSQL databases to validate data after running Postman tests.

---

## 📋 **Table of Contents**
1. [Connection Methods](#connection-methods)
2. [Database Information](#database-information)
3. [Connecting via Command Line (psql)](#connecting-via-command-line-psql)
4. [Connecting via GUI Tools](#connecting-via-gui-tools)
5. [Common Validation Queries](#common-validation-queries)

---

## 🔌 **Connection Methods**

You have three options to connect to the databases:

### **Option 1: Command Line (psql)** ✅ Recommended
- Fast and always available
- Best for quick queries
- No installation needed (uses Docker)

### **Option 2: GUI Tool (TablePlus, DBeaver, pgAdmin)**
- Visual interface
- Better for exploring schemas
- Requires separate installation

### **Option 3: VS Code Extension**
- Direct from your editor
- Good for developers
- Requires PostgreSQL extension

---

## 📊 **Database Information**

### **Connection Details**

All databases run in the same PostgreSQL instance:

```
Host:     localhost
Port:     5435
User:     deliveryx
Password: deliveryx_dev_pass
```

### **Available Databases**

| Database Name         | Service           | Purpose                                      |
|-----------------------|-------------------|----------------------------------------------|
| `deliveryx_restaurant`| Restaurant Service| Stores, locations, operating hours           |
| `deliveryx_menu`      | Menu Service      | Menus, products, collections, attribute groups|

---

## 🖥️ **Connecting via Command Line (psql)**

### **Method 1: Direct psql command**

```bash
# Connect to Restaurant Database
PGPASSWORD=deliveryx_dev_pass psql -h localhost -p 5435 -U deliveryx -d deliveryx_restaurant

# Connect to Menu Database
PGPASSWORD=deliveryx_dev_pass psql -h localhost -p 5435 -U deliveryx -d deliveryx_menu

# Connect to Approval Database
PGPASSWORD=deliveryx_dev_pass psql -h localhost -p 5435 -U deliveryx -d deliveryx_approval
```

### **Method 2: Using Docker exec** (if psql not installed locally)

```bash
# Access PostgreSQL container shell
docker exec -it deliveryx-postgres sh

# Then connect to any database
psql -U deliveryx -d deliveryx_restaurant
psql -U deliveryx -d deliveryx_menu
psql -U deliveryx -d deliveryx_approval
```

### **Method 3: One-liner queries**

```bash
# Run a single query without entering psql shell
PGPASSWORD=deliveryx_dev_pass psql -h localhost -p 5435 -U deliveryx -d deliveryx_restaurant -c "SELECT * FROM stores;"
```

### **Useful psql Commands**

Once connected to psql:

```sql
-- List all tables
\dt

-- Describe a table structure
\d stores
\d menus
\d products

-- List all databases
\l

-- Switch to another database
\c deliveryx_menu

-- Show current database
SELECT current_database();

-- Exit psql
\q
```

---

## 🎨 **Connecting via GUI Tools**

### **TablePlus** (Recommended - macOS/Windows)

1. Download from: https://tableplus.com
2. Click **New Connection** → **PostgreSQL**
3. Enter connection details:
   ```
   Name:     DeliveryX Local
   Host:     localhost
   Port:     5435
   User:     deliveryx
   Password: deliveryx_dev_pass
   Database: deliveryx_restaurant (or menu, approval)
   ```
4. Click **Test** → **Connect**

### **DBeaver** (Free, Cross-platform)

1. Download from: https://dbeaver.io
2. Click **New Database Connection** → **PostgreSQL**
3. Enter connection details:
   ```
   Host:     localhost
   Port:     5435
   Database: deliveryx_restaurant
   Username: deliveryx
   Password: deliveryx_dev_pass
   ```
4. Click **Test Connection** → **Finish**

### **pgAdmin 4** (Official PostgreSQL GUI)

1. Download from: https://www.pgadmin.org
2. Right-click **Servers** → **Register** → **Server**
3. General Tab:
   - Name: `DeliveryX Local`
4. Connection Tab:
   ```
   Host:     localhost
   Port:     5435
   Username: deliveryx
   Password: deliveryx_dev_pass
   ```
5. Click **Save**

### **VS Code PostgreSQL Extension**

1. Install extension: **PostgreSQL** by Chris Kolkman
2. Click PostgreSQL icon in sidebar
3. Add new connection:
   ```
   localhost:5435
   deliveryx
   deliveryx_dev_pass
   deliveryx_restaurant
   ```

---

## 🔍 **Common Validation Queries**

### **Restaurant Service Queries**

```sql
-- Connect to deliveryx_restaurant database first
\c deliveryx_restaurant

-- View all stores
SELECT * FROM stores;

-- View stores with their locations (JOIN)
SELECT
    s.store_id,
    s.name AS store_name,
    l.location_id,
    l.city,
    l.address
FROM stores s
LEFT JOIN locations l ON s.store_id = l.store_id;

-- View locations with operating hours
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
ORDER BY l.location_id,
    CASE oh.day_of_week
        WHEN 'MONDAY' THEN 1
        WHEN 'TUESDAY' THEN 2
        WHEN 'WEDNESDAY' THEN 3
        WHEN 'THURSDAY' THEN 4
        WHEN 'FRIDAY' THEN 5
        WHEN 'SATURDAY' THEN 6
        WHEN 'SUNDAY' THEN 7
    END;

-- Count stores
SELECT COUNT(*) as total_stores FROM stores;

-- Count locations per store
SELECT
    s.name AS store_name,
    COUNT(l.location_id) AS num_locations
FROM stores s
LEFT JOIN locations l ON s.store_id = l.store_id
GROUP BY s.store_id, s.name;
```

### **Menu Service Queries**

```sql
-- Connect to deliveryx_menu database first
\c deliveryx_menu

-- View all menus with their status
SELECT
    menu_id,
    location_id,
    status,
    submitted_at,
    reviewed_at,
    rejection_reason,
    created_at
FROM menus
ORDER BY created_at DESC;

-- View products
SELECT
    product_id,
    name,
    description,
    price,
    category,
    is_available,
    created_at
FROM products
ORDER BY created_at DESC;

-- View collections in a menu
SELECT
    c.collection_id,
    c.name,
    c.position,
    c.image_url,
    m.status AS menu_status
FROM collections c
JOIN menus m ON c.menu_id = m.menu_id
ORDER BY c.position;

-- View menu composition (products in collections)
SELECT
    m.menu_id,
    m.status AS menu_status,
    c.name AS collection_name,
    p.name AS product_name,
    p.price,
    p.is_available,
    mp.position
FROM menus m
JOIN collections c ON m.menu_id = c.menu_id
JOIN menu_products mp ON m.menu_id = mp.menu_id AND c.collection_id = mp.collection_id
JOIN products p ON mp.product_id = p.product_id
ORDER BY m.menu_id, c.position, mp.position;

-- View attribute groups (seeded data)
SELECT * FROM attribute_groups;

-- View attributes for a specific group
SELECT
    ag.name AS group_name,
    a.name AS attribute_name,
    a.price_impact,
    a.is_default
FROM attribute_groups ag
JOIN attributes a ON ag.id = a.attribute_group_id
ORDER BY ag.name, a.price_impact;

-- Count products per collection
SELECT
    c.name AS collection_name,
    COUNT(mp.product_id) AS num_products
FROM collections c
LEFT JOIN menu_products mp ON c.collection_id = mp.collection_id
GROUP BY c.collection_id, c.name;

-- Find menus by status
SELECT
    menu_id,
    location_id,
    status,
    submitted_at,
    reviewed_at
FROM menus
WHERE status = 'pending_review';  -- Change to: draft, approved, rejected, active
```

### **Approval Service Queries**

```sql
-- Connect to deliveryx_approval database first
\c deliveryx_approval

-- View all approval logs
SELECT
    id,
    menu_id,
    action,
    admin_email,
    rejection_reason,
    created_at
FROM approval_logs
ORDER BY created_at DESC;

-- View approval history for a specific menu
SELECT
    id,
    action,
    admin_email,
    rejection_reason,
    created_at
FROM approval_logs
WHERE menu_id = 'YOUR_MENU_ID_HERE'
ORDER BY created_at DESC;

-- Count approvals vs rejections
SELECT
    action,
    COUNT(*) AS count
FROM approval_logs
GROUP BY action;

-- View recent admin activity
SELECT
    admin_email,
    action,
    COUNT(*) AS actions_count
FROM approval_logs
WHERE admin_email IS NOT NULL
GROUP BY admin_email, action
ORDER BY actions_count DESC;

-- Find menus that were rejected
SELECT
    menu_id,
    rejection_reason,
    admin_email,
    created_at
FROM approval_logs
WHERE action = 'rejected'
ORDER BY created_at DESC;
```

### **Cross-Database Validation**

To validate data across services, you'll need to switch databases:

```sql
-- Start in restaurant database
\c deliveryx_restaurant
SELECT location_id, city FROM locations LIMIT 1;
-- Copy the location_id

-- Switch to menu database
\c deliveryx_menu
SELECT menu_id, status FROM menus WHERE location_id = 'PASTE_LOCATION_ID_HERE';
-- Copy the menu_id

-- Switch to approval database
\c deliveryx_approval
SELECT * FROM approval_logs WHERE menu_id = 'PASTE_MENU_ID_HERE';
```

---

## 📚 **Quick Reference: SQL Cheat Sheet**

```sql
-- SELECT all columns
SELECT * FROM table_name;

-- SELECT specific columns
SELECT column1, column2 FROM table_name;

-- WHERE clause (filter)
SELECT * FROM products WHERE price > 10.00;

-- ORDER BY (sort)
SELECT * FROM products ORDER BY price DESC;

-- COUNT rows
SELECT COUNT(*) FROM stores;

-- LIMIT results
SELECT * FROM menus LIMIT 10;

-- JOIN tables
SELECT a.*, b.*
FROM table_a a
JOIN table_b b ON a.id = b.foreign_id;

-- WHERE with multiple conditions
SELECT * FROM products
WHERE price > 5.00 AND is_available = true;

-- LIKE (pattern matching)
SELECT * FROM products WHERE name LIKE '%Burger%';

-- IN clause
SELECT * FROM menus WHERE status IN ('draft', 'pending_review');

-- BETWEEN
SELECT * FROM products WHERE price BETWEEN 5.00 AND 15.00;

-- GROUP BY with aggregation
SELECT category, COUNT(*), AVG(price)
FROM products
GROUP BY category;
```

---

## 🔥 **Troubleshooting**

### **Can't connect - Connection refused**

```bash
# Check if PostgreSQL container is running
docker ps | grep postgres

# If not running, start it
cd /Users/fahdayoubi/dev/deliveryx/oapp
docker-compose up -d postgres

# Check PostgreSQL logs
docker logs deliveryx-postgres
```

### **Authentication failed**

Make sure you're using:
- Password: `deliveryx_dev_pass` (not `deliveryx`)
- Port: `5435` (not the default 5432)

### **Database does not exist**

```bash
# Check if databases were created
docker exec deliveryx-postgres psql -U deliveryx -c "\l"

# If databases don't exist, run migrations
cd /Users/fahdayoubi/dev/deliveryx/oapp
make db-migrate-up
```

### **psql command not found**

Either:
1. Install PostgreSQL client: `brew install postgresql`
2. Or use Docker exec method (see Method 2 above)

---

## 📖 **Next Steps**

1. ✅ Connect to database using your preferred method
2. ✅ Run validation queries from `SQL-QUERY-REFERENCE.md`
3. ✅ Cross-reference with Postman test results
4. ✅ Report any data inconsistencies

For detailed query examples specific to each test scenario, see **SQL-QUERY-REFERENCE.md**.
