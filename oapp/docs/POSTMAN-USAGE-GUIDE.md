# DeliveryX Postman Testing Guide

This guide provides step-by-step instructions for importing and using the DeliveryX Postman collection to test all API endpoints.

---

## 📋 **Table of Contents**
1. [Prerequisites](#prerequisites)
2. [Import Collection and Environment](#import-collection-and-environment)
3. [Running the Tests](#running-the-tests)
4. [Understanding the Collection Structure](#understanding-the-collection-structure)
5. [Automated Testing with Test Scripts](#automated-testing-with-test-scripts)
6. [Validating Data in PostgreSQL](#validating-data-in-postgresql)
7. [Troubleshooting](#troubleshooting)
8. [Advanced Usage](#advanced-usage)

---

## ✅ **Prerequisites**

Before you begin, ensure you have:

1. **Postman Installed**
   - Download from: https://www.postman.com/downloads/
   - OR use Postman Web (https://web.postman.com/)

2. **DeliveryX Services Running**
   ```bash
   # Navigate to project root
   cd /Users/fahdayoubi/dev/deliveryx/oapp

   # Start all services
   docker-compose up -d

   # Verify all services are running
   docker-compose ps

   # Expected output: All services should be "Up" (not "Exited")
   ```

3. **Verify Service Health**
   ```bash
   # Restaurant Service
   curl http://localhost:8081/health

   # Menu Service
   curl http://localhost:8082/health

   # Approval Service
   curl http://localhost:8083/health

   # Media Service
   curl http://localhost:8084/health
   ```

---

## 📥 **Import Collection and Environment**

### **Step 1: Import the Collection**

1. Open Postman
2. Click **Import** button (top left)
3. Select **File** tab
4. Navigate to `/Users/fahdayoubi/dev/deliveryx/oapp/docs/`
5. Select **DeliveryX-API-Collection.postman_collection.json**
6. Click **Import**

✅ **Success**: You should see **"DeliveryX API Collection"** in your Collections sidebar

### **Step 2: Import the Environment**

1. Click **Import** button again
2. Select **File** tab
3. Navigate to `/Users/fahdayoubi/dev/deliveryx/oapp/docs/`
4. Select **DeliveryX-Environment.postman_environment.json**
5. Click **Import**

✅ **Success**: You should see **"DeliveryX - Local Development"** in the environment dropdown (top right)

### **Step 3: Activate the Environment**

1. Click the environment dropdown (top right)
2. Select **"DeliveryX - Local Development"**
3. Verify the environment is active (should show a checkmark)

---

## 🚀 **Running the Tests**

### **Option 1: Run Entire Collection (Recommended for First Test)**

This will run all requests in sequence and populate all variables automatically.

1. Click on **"DeliveryX API Collection"** in the sidebar
2. Click the **"Run"** button (top right of collection view)
3. In Collection Runner:
   - Ensure **"DeliveryX - Local Development"** environment is selected
   - Keep **"Save responses"** checked (for debugging)
   - Click **"Run DeliveryX API Collection"**

4. **Watch the tests run** (30+ requests)
   - ✅ Green = Passed
   - ❌ Red = Failed (see error details)

5. **Review Results**
   - Total requests: ~30
   - Passed tests: Should be 100% if all services are healthy
   - Failed tests: Click to see error details

### **Option 2: Run Individual Requests (For Specific Testing)**

Follow this sequence for manual testing:

#### **Phase 1: Restaurant Service Setup**

1. **Create Store**
   - Folder: `1. Restaurant Service`
   - Request: `Create Store`
   - Click **Send**
   - ✅ Status: `201 Created`
   - 📝 Note: `store_id` is automatically saved to environment

2. **Create Location**
   - Request: `Create Location`
   - Click **Send**
   - ✅ Status: `201 Created`
   - 📝 Note: `location_id` is automatically saved

3. **Create Operating Hours**
   - Request: `Create Operating Hours`
   - Click **Send**
   - ✅ Status: `201 Created`
   - 📝 Note: Creates 7 operating hours (one per day)

#### **Phase 2: Menu Service Setup**

4. **Get Attribute Groups** (Seeded Data)
   - Folder: `2. Menu Service`
   - Request: `Get Attribute Groups`
   - Click **Send**
   - ✅ Status: `200 OK`
   - 📝 Note: `attribute_group_id` is automatically saved (for "Size" group)

5. **Create Menu (Draft)**
   - Request: `Create Menu (Draft)`
   - Click **Send**
   - ✅ Status: `201 Created`
   - 📝 Note: `menu_id` is automatically saved

6. **Create Collection**
   - Request: `Create Collection`
   - Click **Send**
   - ✅ Status: `201 Created`
   - 📝 Note: `collection_id` is automatically saved

7. **Create Product**
   - Request: `Create Product`
   - Click **Send**
   - ✅ Status: `201 Created`
   - 📝 Note: `product_id` is automatically saved

8. **Add Product to Collection**
   - Request: `Add Product to Collection`
   - Click **Send**
   - ✅ Status: `201 Created`

9. **Add Attribute Group to Product**
   - Request: `Add Attribute Group to Product`
   - Click **Send**
   - ✅ Status: `200 OK`

10. **Submit Menu for Review**
    - Request: `Submit Menu for Review`
    - Click **Send**
    - ✅ Status: `200 OK`
    - 📝 Note: Menu status changes from "draft" to "pending_review"

#### **Phase 3: Approval Service Workflow**

11. **Approve Menu**
    - Folder: `3. Approval Service`
    - Request: `Approve Menu`
    - Click **Send**
    - ✅ Status: `200 OK`
    - 📝 Note: Menu status changes to "approved"

    **OR**

    **Reject Menu**
    - Request: `Reject Menu`
    - Edit body to provide rejection reason
    - Click **Send**
    - ✅ Status: `200 OK`
    - 📝 Note: Menu status changes to "rejected"

12. **Get Approval History**
    - Request: `Get Approval History`
    - Click **Send**
    - ✅ Status: `200 OK`
    - 📝 Note: Shows all approval/rejection actions for the menu

#### **Phase 4: Media Service (Optional)**

13. **Generate Upload URL**
    - Folder: `4. Media Service`
    - Request: `Generate Upload URL for Product Image`
    - Click **Send**
    - ✅ Status: `200 OK`
    - 📝 Note: Returns pre-signed S3 URL

---

## 📁 **Understanding the Collection Structure**

The collection is organized into 4 main folders:

### **1. Restaurant Service**
- **Create Store**: Creates a new restaurant store
- **Create Location**: Creates a location for the store
- **Create Operating Hours**: Creates operating hours for all 7 days

### **2. Menu Service**

**Attribute Groups (Seeded Data)**:
- **Get Attribute Groups**: Retrieves seeded attribute groups (Size, Toppings, Crust, Drinks)
- **Get Attributes for Group**: Retrieves attributes for a specific group

**Menu Management**:
- **Create Menu (Draft)**: Creates a new menu in draft status
- **Get Menu**: Retrieves menu details

**Collections**:
- **Create Collection**: Creates a collection (category) in the menu
- **Get Collections**: Lists all collections in a menu

**Products**:
- **Create Product**: Creates a new product
- **Get Product**: Retrieves product details

**Menu Composition**:
- **Add Product to Collection**: Links a product to a collection
- **Add Attribute Group to Product**: Links attribute group to product

**Menu Workflow**:
- **Submit Menu for Review**: Changes menu status to "pending_review"
- **Get Complete Menu**: Retrieves full menu with all collections and products

### **3. Approval Service**
- **Approve Menu**: Approves a pending menu
- **Reject Menu**: Rejects a pending menu with reason
- **Get Approval History**: Retrieves approval audit trail

### **4. Media Service**
- **Generate Upload URL for Product Image**: Creates pre-signed S3 upload URL
- **Generate Upload URL for Collection Image**: Creates pre-signed S3 upload URL
- **Generate Upload URL - Invalid File Type**: Tests validation (should fail)

---

## 🧪 **Automated Testing with Test Scripts**

Each request includes **automated test scripts** that run after the response is received.

### **How to View Test Results**

1. Click on any request
2. Click **Send**
3. Click the **"Test Results"** tab (below the response)
4. Review:
   - ✅ **PASS**: Test passed
   - ❌ **FAIL**: Test failed (with error message)

### **Example Test Scripts**

**Create Store Request** tests for:
```javascript
✅ Status code is 201
✅ Response has store_id
✅ Response has name
✅ Store is active by default
```

**Submit Menu Request** tests for:
```javascript
✅ Status code is 200
✅ Menu status is pending_review
✅ submitted_at is populated
```

**Approve Menu Request** tests for:
```javascript
✅ Status code is 200
✅ Menu status is approved
✅ reviewed_at is populated
```

### **Variables Auto-Saved**

The test scripts automatically save important IDs to the environment:

- `store_id` - From Create Store response
- `location_id` - From Create Location response
- `menu_id` - From Create Menu response
- `product_id` - From Create Product response
- `collection_id` - From Create Collection response
- `attribute_group_id` - From Get Attribute Groups response

**To view saved variables**:
1. Click the **Environment** icon (top right, looks like an eye 👁️)
2. Select **"DeliveryX - Local Development"**
3. View **Current Value** column

---

## 🗄️ **Validating Data in PostgreSQL**

After running Postman tests, validate the data was stored correctly in PostgreSQL.

### **Quick Validation**

```bash
# Connect to Restaurant database
PGPASSWORD=deliveryx_dev_pass psql -h localhost -p 5435 -U deliveryx -d deliveryx_restaurant

# View stores
SELECT * FROM stores;

# View locations
SELECT * FROM locations;

# Exit
\q

# Connect to Menu database
PGPASSWORD=deliveryx_dev_pass psql -h localhost -p 5435 -U deliveryx -d deliveryx_menu

# View menus
SELECT * FROM menus;

# Exit
\q

# Connect to Approval database
PGPASSWORD=deliveryx_dev_pass psql -h localhost -p 5435 -U deliveryx -d deliveryx_approval

# View approval logs
SELECT * FROM approval_logs;

# Exit
\q
```

### **Detailed Validation**

Refer to the comprehensive validation queries in:
- **SQL-QUERY-REFERENCE.md** - Detailed queries for each test scenario
- **DATABASE-CONNECTION-GUIDE.md** - Connection methods and common queries

---

## 🛠️ **Troubleshooting**

### **Problem: Request fails with "Could not send request"**

**Solution**:
```bash
# Check if services are running
docker-compose ps

# If any service is down, restart it
docker-compose restart restaurant-service
docker-compose restart menu-service
docker-compose restart approval-service
docker-compose restart media-service

# Check logs for errors
docker-compose logs restaurant-service
docker-compose logs menu-service
docker-compose logs approval-service
```

### **Problem: 404 Not Found**

**Possible causes**:
1. Wrong URL in environment
2. Service not running
3. Traefik routing issue

**Solution**:
```bash
# Test service directly (bypass Traefik)
curl http://localhost:8081/health  # Restaurant
curl http://localhost:8082/health  # Menu
curl http://localhost:8083/health  # Approval
curl http://localhost:8084/health  # Media

# Test via Traefik
curl http://localhost/api/v1/stores  # Should work after creating a store
```

### **Problem: Variables not being saved**

**Solution**:
1. Ensure environment is selected (top right dropdown)
2. Verify test scripts are enabled:
   - Click request → **Tests** tab
   - Scripts should be present
3. Run Collection Runner instead of individual requests
4. Manually set variables:
   - Click Environment icon (👁️)
   - Select "DeliveryX - Local Development"
   - Click **Edit**
   - Set **Current Value** for required variables

### **Problem: Tests failing with "expected 201 to equal 500"**

**Solution**:
1. Check the **Response** body for error message
2. Common causes:
   - Database not initialized: Run `make db-migrate-up`
   - Missing dependencies: Run previous requests first
   - Invalid data: Check request body
3. View service logs:
   ```bash
   docker-compose logs menu-service | tail -50
   ```

### **Problem: "menu_id" not found when running Approve Menu**

**Solution**:
- Ensure you ran **"Submit Menu for Review"** first
- Or manually set `menu_id` in environment:
  1. Run **"Get Menu"** or **"Create Menu"**
  2. Copy `menu_id` from response
  3. Click Environment icon → Edit
  4. Paste into `menu_id` Current Value

### **Problem: PostgreSQL connection refused**

**Solution**:
```bash
# Check if PostgreSQL container is running
docker ps | grep postgres

# If not running, start it
docker-compose up -d postgres

# Wait 10 seconds for it to initialize
sleep 10

# Test connection
PGPASSWORD=deliveryx_dev_pass psql -h localhost -p 5435 -U deliveryx -d deliveryx_restaurant -c "SELECT 1"
```

---

## 🚀 **Advanced Usage**

### **Running Tests in Sequence with Delays**

If services are slow, add delays between requests:

1. Click **Collection Runner**
2. Set **Delay** to `500ms` (between requests)
3. Click **Run**

### **Running Specific Folders Only**

To test only one service:

1. Expand **"DeliveryX API Collection"**
2. Click on a specific folder (e.g., "2. Menu Service")
3. Click **Run**
4. Only requests in that folder will run

### **Exporting Test Results**

After running Collection Runner:

1. Click **Export Results** button
2. Choose format: JSON or CSV
3. Save for reporting

### **Using Newman (CLI Runner)**

Run Postman tests from command line:

```bash
# Install Newman
npm install -g newman

# Run collection
newman run docs/DeliveryX-API-Collection.postman_collection.json \
  -e docs/DeliveryX-Environment.postman_environment.json \
  --reporters cli,json

# Run with HTML report
newman run docs/DeliveryX-API-Collection.postman_collection.json \
  -e docs/DeliveryX-Environment.postman_environment.json \
  --reporters cli,htmlextra \
  --reporter-htmlextra-export newman-report.html
```

### **Using Pre-request Scripts**

Some requests have **Pre-request Scripts** that run before the request:

**Example**: Generate random data for testing
```javascript
// Pre-request script for "Create Store"
pm.environment.set("random_store_name", "Store " + Math.floor(Math.random() * 1000));
```

To view:
1. Click request → **Pre-request Script** tab
2. Modify if needed

### **Customizing Request Bodies**

To modify test data:

1. Click on a request (e.g., "Create Store")
2. Click **Body** tab
3. Edit JSON:
   ```json
   {
     "name": "My Custom Store Name",
     "description": "My custom description"
   }
   ```
4. Click **Send**

### **Testing Error Scenarios**

To test validation:

1. **Create Store with Missing Name**:
   - Edit body to remove `"name"` field
   - Expected: `400 Bad Request`

2. **Submit Menu in Wrong Status**:
   - Try to submit a menu that's already approved
   - Expected: `400 Bad Request` with error message

3. **Approve Non-existent Menu**:
   - Manually set `menu_id` to invalid UUID
   - Expected: `404 Not Found` or `500 Internal Server Error`

---

## 📊 **Test Coverage Summary**

The collection tests the following:

### **Restaurant Service** (3 endpoints)
- ✅ Create Store
- ✅ Create Location
- ✅ Create Operating Hours

### **Menu Service** (13 endpoints)
- ✅ Get Attribute Groups (seeded data)
- ✅ Get Attributes for Group
- ✅ Create Menu
- ✅ Get Menu
- ✅ Create Collection
- ✅ Get Collections
- ✅ Create Product
- ✅ Get Product
- ✅ Add Product to Collection
- ✅ Add Attribute Group to Product
- ✅ Submit Menu for Review
- ✅ Get Complete Menu

### **Approval Service** (3 endpoints)
- ✅ Approve Menu
- ✅ Reject Menu
- ✅ Get Approval History

### **Media Service** (3 endpoints)
- ✅ Generate Upload URL for Product Image
- ✅ Generate Upload URL for Collection Image
- ✅ Test validation for invalid file types

**Total**: ~30 requests with automated test scripts

---

## ✅ **Best Practices**

1. **Always run in sequence** (using Collection Runner) for first-time testing
2. **Check environment variables** after each request to ensure they're saved
3. **Validate data in PostgreSQL** after running tests (see SQL-QUERY-REFERENCE.md)
4. **Review test results** in Collection Runner to identify failures
5. **Check service logs** if tests fail unexpectedly
6. **Keep environment file** in sync (don't manually change URLs unless needed)

---

## 📚 **Additional Resources**

- **SQL-QUERY-REFERENCE.md**: Detailed PostgreSQL validation queries for each test
- **DATABASE-CONNECTION-GUIDE.md**: Complete guide for connecting to PostgreSQL
- **OpenAPI Documentation**: http://localhost:8090 (Swagger UI with all endpoints)
- **Postman Learning Center**: https://learning.postman.com/

---

## 🎯 **Recommended Testing Workflow**

1. ✅ **Start all services**: `docker-compose up -d`
2. ✅ **Import collection and environment** into Postman
3. ✅ **Run entire collection** using Collection Runner
4. ✅ **Review test results** (should be 100% passing)
5. ✅ **Connect to PostgreSQL** and run validation queries
6. ✅ **Cross-reference data** across all 3 databases
7. ✅ **Test error scenarios** (optional)
8. ✅ **Generate test report** (optional, using Newman)

---

**Happy Testing! 🚀**

For issues or questions, refer to:
- **Troubleshooting section** above
- **Service logs**: `docker-compose logs <service-name>`
- **OpenAPI docs**: http://localhost:8090
