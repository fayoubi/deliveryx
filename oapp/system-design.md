System Architecture
Microservices Overview
┌─────────────────┐
│   OApp (React   │
│     Native)     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  API Gateway    │
│   (Kong/NGINX)  │
└────────┬────────┘
         │
    ┌────┴────┬──────────────┬──────────────┬──────────────┐
    ▼         ▼              ▼              ▼              ▼
┌──────────┐ ┌─────────┐  ┌─────────┐  ┌──────────┐  ┌──────────┐
│Restaurant│ │  Menu   │  │  Media  │  │ Approval │  │  Order   │
│ Service  │ │ Service │  │ Service │  │ Service  │  │ Service  │
│(Store+   │ └─────────┘  └─────────┘  └──────────┘  └──────────┘
│Location) │
└────┬─────┘
     │
     ▼
┌─────────────┐
│ PostgreSQL  │
└─────────────┘
Service Responsibilities
ServiceResponsibilityDatabaseRestaurant ServiceManage stores and locations (CRUD operations, operating hours)PostgreSQLMenu ServiceManage menus, collections, sections, products, attributesPostgreSQLMedia ServiceHandle image uploads via pre-signed S3 URLsS3/CloudFlare R2Approval ServiceAdmin review workflow for menu submissionsPostgreSQLOrder ServiceHandle customer orders (future scope)PostgreSQL

Tech Stack
Backend Services

Language: Golang
Framework: Gin or Echo
API Gateway: Kong or Traefik
Message Queue: RabbitMQ or AWS SQS
Database: PostgreSQL (per service)
Storage: AWS S3 or CloudFlare R2
Container Orchestration: Docker + Kubernetes (or Docker Compose for MVP)

Mobile App (Future Phase)

Framework: React Native
State Management: Zustand or React Context
API Client: Axios
Authentication: JWT (deferred for MVP)

DevOps

CI/CD: GitHub Actions or GitLab CI
Monitoring: Prometheus + Grafana
Logging: ELK Stack or Loki


Data Models
Restaurant Service
Store
gotype Store struct {
    StoreID     string    `json:"store_id" db:"store_id"`
    OwnerID     string    `json:"owner_id" db:"owner_id"`
    Name        string    `json:"name" db:"name" binding:"required,max=255"`
    Description string    `json:"description" db:"description" binding:"max=1000"`
    LogoURL     string    `json:"logo_url" db:"logo_url"`
    Phone       string    `json:"phone" db:"phone" binding:"required"`
    CreatedAt   time.Time `json:"created_at" db:"created_at"`
    UpdatedAt   time.Time `json:"updated_at" db:"updated_at"`
}
Location
gotype Location struct {
    LocationID      string           `json:"location_id" db:"location_id"`
    StoreID         string           `json:"store_id" db:"store_id"`
    Address         string           `json:"address" db:"address" binding:"required"`
    City            string           `json:"city" db:"city" binding:"required"`
    PostalCode      string           `json:"postal_code" db:"postal_code"`
    Phone           string           `json:"phone" db:"phone" binding:"required"`
    LocationManager string           `json:"location_manager" db:"location_manager"`
    Latitude        float64          `json:"latitude" db:"latitude"`
    Longitude       float64          `json:"longitude" db:"longitude"`
    IsActive        bool             `json:"is_active" db:"is_active"`
    OperatingHours  []OperatingHours `json:"operating_hours"`
    CreatedAt       time.Time        `json:"created_at" db:"created_at"`
    UpdatedAt       time.Time        `json:"updated_at" db:"updated_at"`
}

type OperatingHours struct {
    ID         string    `json:"id" db:"id"`
    LocationID string    `json:"location_id" db:"location_id"`
    DayOfWeek  string    `json:"day_of_week" db:"day_of_week"` // MONDAY, TUESDAY, etc.
    OpenTime   string    `json:"open_time" db:"open_time"`     // HH:mm format
    CloseTime  string    `json:"close_time" db:"close_time"`   // HH:mm format
    IsClosed   bool      `json:"is_closed" db:"is_closed"`
}
Menu Service
Menu
gotype Menu struct {
    MenuID          string     `json:"menu_id" db:"menu_id"`
    LocationID      string     `json:"location_id" db:"location_id"`
    Status          string     `json:"status" db:"status"` // draft, pending_review, approved, rejected, active
    SubmittedAt     *time.Time `json:"submitted_at" db:"submitted_at"`
    ReviewedAt      *time.Time `json:"reviewed_at" db:"reviewed_at"`
    RejectionReason *string    `json:"rejection_reason" db:"rejection_reason"`
    CreatedAt       time.Time  `json:"created_at" db:"created_at"`
    UpdatedAt       time.Time  `json:"updated_at" db:"updated_at"`
}
Collection
gotype Collection struct {
    CollectionID string    `json:"collection_id" db:"collection_id"`
    MenuID       string    `json:"menu_id" db:"menu_id"`
    Name         string    `json:"name" db:"name" binding:"required,max=255"`
    Position     int       `json:"position" db:"position"`
    ImageURL     string    `json:"image_url" db:"image_url"`
    CreatedAt    time.Time `json:"created_at" db:"created_at"`
}
Section (Optional)
gotype Section struct {
    SectionID    string    `json:"section_id" db:"section_id"`
    CollectionID string    `json:"collection_id" db:"collection_id"`
    Name         string    `json:"name" db:"name" binding:"required,max=255"`
    Position     int       `json:"position" db:"position"`
    CreatedAt    time.Time `json:"created_at" db:"created_at"`
}
Product
gotype Product struct {
    ProductID     string    `json:"product_id" db:"product_id"`
    LocationID    string    `json:"location_id" db:"location_id"`
    Name          string    `json:"name" db:"name" binding:"required,max=255"`
    Description   string    `json:"description" db:"description" binding:"max=2000"`
    Price         float64   `json:"price" db:"price" binding:"required,gt=0"`
    Category      string    `json:"category" db:"category"`
    ImageURL      string    `json:"image_url" db:"image_url"`
    IsAvailable   bool      `json:"is_available" db:"is_available"`
    CreatedAt     time.Time `json:"created_at" db:"created_at"`
    UpdatedAt     time.Time `json:"updated_at" db:"updated_at"`
}

type ProductImage struct {
    ImageID   string `json:"image_id" db:"image_id"`
    ProductID string `json:"product_id" db:"product_id"`
    ImageURL  string `json:"image_url" db:"image_url"`
    Position  int    `json:"position" db:"position"`
}
MenuProduct (Junction Table)
gotype MenuProduct struct {
    MenuProductID string     `json:"menu_product_id" db:"menu_product_id"`
    MenuID        string     `json:"menu_id" db:"menu_id"`
    ProductID     string     `json:"product_id" db:"product_id"`
    CollectionID  string     `json:"collection_id" db:"collection_id"`
    SectionID     *string    `json:"section_id" db:"section_id"`
    Position      int        `json:"position" db:"position"`
    CreatedAt     time.Time  `json:"created_at" db:"created_at"`
}
AttributeGroup (Predefined)
gotype AttributeGroup struct {
    AttributeGroupID string    `json:"attribute_group_id" db:"attribute_group_id"`
    Name             string    `json:"name" db:"name"`
    MinSelections    int       `json:"min_selections" db:"min_selections"`
    MaxSelections    int       `json:"max_selections" db:"max_selections"`
    IsRequired       bool      `json:"is_required" db:"is_required"`
    SystemDefined    bool      `json:"system_defined" db:"system_defined"`
    CreatedAt        time.Time `json:"created_at" db:"created_at"`
}
Attribute (Predefined)
gotype Attribute struct {
    AttributeID      string    `json:"attribute_id" db:"attribute_id"`
    AttributeGroupID string    `json:"attribute_group_id" db:"attribute_group_id"`
    Name             string    `json:"name" db:"name"`
    PriceImpact      float64   `json:"price_impact" db:"price_impact"`
    IsDefault        bool      `json:"is_default" db:"is_default"`
    IsAvailable      bool      `json:"is_available" db:"is_available"`
    SystemDefined    bool      `json:"system_defined" db:"system_defined"`
    CreatedAt        time.Time `json:"created_at" db:"created_at"`
}
ProductAttributeGroup (Junction Table)
gotype ProductAttributeGroup struct {
    ProductID        string    `json:"product_id" db:"product_id"`
    AttributeGroupID string    `json:"attribute_group_id" db:"attribute_group_id"`
    CreatedAt        time.Time `json:"created_at" db:"created_at"`
}
```

---

## **API Endpoints**

### **Restaurant Service**
```
# Stores
POST   /api/v1/stores
GET    /api/v1/stores/{store_id}
PUT    /api/v1/stores/{store_id}

# Locations
POST   /api/v1/stores/{store_id}/locations
GET    /api/v1/stores/{store_id}/locations
GET    /api/v1/locations/{location_id}
PUT    /api/v1/locations/{location_id}
PUT    /api/v1/locations/{location_id}/operating-hours

# Convenience
GET    /api/v1/owners/{owner_id}/restaurants  # Returns store + all locations
```

### **Menu Service**
```
# Menu Management
POST   /api/v1/locations/{location_id}/menus          # Create draft menu
GET    /api/v1/menus/{menu_id}                        # Get menu with all data
POST   /api/v1/menus/{menu_id}/submit                 # Submit for review
GET    /api/v1/menus/{menu_id}/status                 # Check approval status

# Collection Management
POST   /api/v1/menus/{menu_id}/collections            # Add collection
DELETE /api/v1/collections/{collection_id}
PUT    /api/v1/menus/{menu_id}/collections/reorder    # Reorder collections

# Section Management
POST   /api/v1/collections/{collection_id}/sections   # Add section
DELETE /api/v1/sections/{section_id}

# Product Management
POST   /api/v1/locations/{location_id}/products       # Create product
GET    /api/v1/products/{product_id}
PUT    /api/v1/products/{product_id}
DELETE /api/v1/products/{product_id}
PATCH  /api/v1/products/{product_id}/availability     # Toggle active/inactive

# Menu-Product Association
POST   /api/v1/menus/{menu_id}/products               # Add product to collection
DELETE /api/v1/menus/{menu_id}/products/{product_id}  # Remove from menu
PUT    /api/v1/collections/{collection_id}/products/reorder  # Reorder

# Attribute Groups (Read-only for MVP)
GET    /api/v1/attribute-groups                       # List predefined groups
GET    /api/v1/attribute-groups/{id}/attributes       # Get attributes
```

### **Media Service**
```
POST   /api/v1/media/upload-url                       # Get pre-signed S3 URL
```

### **Approval Service**
```
POST   /api/v1/approvals/menus/{menu_id}/approve      # Admin only
POST   /api/v1/approvals/menus/{menu_id}/reject       # Admin only
```

---

## **Business Rules**

### **Store & Location**
1. Each owner can have **1 store only** (intentional MVP limitation)
2. One store can have **many locations**
3. A location belongs to **one store only**
4. Locations must have operating hours defined for all 7 days

### **Menu & Products**
1. A location has **one menu** at a time
2. A menu contains **one or more collections**
3. Collections organize products (e.g., "Pizzas", "Drinks")
4. Sections within collections are **optional**
5. Products can only be in **one menu** per location
6. Products cannot exist in a menu more than once (enforced by unique constraint)
7. Products remain **inactive** until added to a menu

### **Approval Workflow**
1. Owner submits **entire menu as atomic unit** for review
2. DeliveryX operators review and approve/reject
3. Once approved, menu is automatically **activated**
4. After activation, owners can only **toggle product availability** (instant, no re-approval)
5. Owners **cannot edit** product details post-approval (MVP limitation)

### **Attribute Groups (MVP)**
1. **Predefined only**: Size, Cuisson, Color
2. Owners select from predefined list or skip
3. Owners **cannot create custom** attribute groups in MVP

### **Predefined Data**

**Categories (Collections):**
- Pizzas, Burgers, Sides, Desserts, Drinks, Salads, Breakfast, Sandwiches, Pasta, Seafood

**Attribute Groups:**
- **Size**: S (+0 MAD), M (+20 MAD), L (+40 MAD), XL (+60 MAD)
- **Cuisson**: Cru, Bien cuit, Brûlé (all +0 MAD)
- **Color**: Blue, Red, Green, Black, White (all +0 MAD)

---

## **User Flow**

### **Onboarding Flow**
```
1. Welcome Screen
   └─> "Set up your restaurant"

2. Store Setup
   ├─ Store Name
   ├─ Description
   ├─ Logo Upload
   └─ Phone Number
   
3. Location Setup
   ├─ Address
   ├─ City / Postal Code
   ├─ Phone Number
   ├─ Location Manager (optional)
   └─ Operating Hours (7 days)

4. Menu Setup
   ├─ Create Collections (select from predefined list)
   │   ├─ "Pizzas"
   │   ├─ "Drinks"
   │   └─ ...
   │
   └─ For each Collection:
       └─ Add Products
           ├─ Product Name
           ├─ Description
           ├─ Price
           ├─ Photo Upload (optional)
           ├─ Select Attribute Groups (Size, Cuisson, Color)
           └─ Save

5. Review & Submit
   └─ Preview entire menu
   └─ Submit for approval

6. Approval Wait
   └─ "Your menu is under review"
   └─ Notification when approved/rejected

7. Go Live
   └─ Menu automatically activated
   └─ Redirect to Management Dashboard
```

### **Post-Onboarding Flow**
```
Dashboard
├─ Menu Status (Active/Inactive)
├─ Quick Stats (Total products, Active products)
└─ Quick Actions (Toggle product availability)

Manage Menu
├─ Collections List
│   ├─ Pizzas (12 products)
│   │   └─ Margherita - $12 [✓ Active] [Toggle]
│   │   └─ Pepperoni - $14 [✓ Active] [Toggle]
│   │   └─ Hawaiian - $13 [✗ Inactive] [Toggle]
│   │
│   └─ Drinks (5 products)
│       └─ ...
```

---

## **Mobile App Screens**

### **Screen 1: Store Setup**
```
┌─────────────────────────────┐
│   Set Up Your Restaurant    │
├─────────────────────────────┤
│                             │
│  [📷 Upload Logo]           │
│                             │
│  Store Name                 │
│  ┌─────────────────────┐   │
│  │ Pizza Palace         │   │
│  └─────────────────────┘   │
│                             │
│  Description                │
│  ┌─────────────────────┐   │
│  │ Best pizza in town   │   │
│  └─────────────────────┘   │
│                             │
│  Phone Number               │
│  ┌─────────────────────┐   │
│  │ +212 6XX XXX XXX     │   │
│  └─────────────────────┘   │
│                             │
│       [Continue →]          │
└─────────────────────────────┘
```

### **Screen 2: Location Setup**
```
┌─────────────────────────────┐
│    Add Location             │
├─────────────────────────────┤
│  Address                    │
│  ┌─────────────────────┐   │
│  │ 123 Main Street      │   │
│  └─────────────────────┘   │
│                             │
│  City                       │
│  ┌─────────────────────┐   │
│  │ Casablanca           │   │
│  └─────────────────────┘   │
│                             │
│  Phone                      │
│  ┌─────────────────────┐   │
│  │ +212 5XX XXX XXX     │   │
│  └─────────────────────┘   │
│                             │
│  Operating Hours            │
│  Monday    [09:00 - 22:00]  │
│  Tuesday   [09:00 - 22:00]  │
│  ...                        │
│                             │
│       [Continue →]          │
└─────────────────────────────┘
```

### **Screen 3: Add Collection**
```
┌─────────────────────────────┐
│    Choose Categories        │
├─────────────────────────────┤
│  Select menu categories:    │
│                             │
│  ☑ Pizzas                   │
│  ☑ Burgers                  │
│  ☐ Sides                    │
│  ☑ Desserts                 │
│  ☑ Drinks                   │
│  ☐ Salads                   │
│  ☐ Breakfast                │
│  ☐ Sandwiches               │
│  ☐ Pasta                    │
│  ☐ Seafood                  │
│                             │
│       [Continue →]          │
└─────────────────────────────┘
```

### **Screen 4: Add Product**
```
┌─────────────────────────────┐
│      Add Product            │
├─────────────────────────────┤
│  [📷 Upload Photo]          │
│                             │
│  Product Name               │
│  ┌─────────────────────┐   │
│  │ Margherita Pizza     │   │
│  └─────────────────────┘   │
│                             │
│  Description                │
│  ┌─────────────────────┐   │
│  │ Fresh mozzarella...  │   │
│  └─────────────────────┘   │
│                             │
│  Price (MAD)                │
│  ┌─────────────────────┐   │
│  │ 120.00               │   │
│  └─────────────────────┘   │
│                             │
│  Options (optional)         │
│  ☑ Size                     │
│  ☐ Cuisson                  │
│  ☐ Color                    │
│                             │
│  [Save Product]             │
└─────────────────────────────┘
```

### **Screen 5: Review & Submit**
```
┌─────────────────────────────┐
│      Review Menu            │
├─────────────────────────────┤
│  Pizza Palace               │
│  123 Main St, Casablanca    │
│                             │
│  📁 Pizzas (3 products)     │
│  📁 Drinks (2 products)     │
│  📁 Desserts (2 products)   │
│                             │
│  Total: 7 products          │
│                             │
│  Ready to submit for        │
│  approval?                  │
│                             │
│  [Edit Menu]                │
│  [Submit for Approval]      │
└─────────────────────────────┘
```

### **Screen 6: Manage Menu (Post-Approval)**
```
┌─────────────────────────────┐
│      My Menu                │
├─────────────────────────────┤
│  Status: 🟢 Active          │
│  12 products • 10 active    │
│                             │
│  Pizzas (8 products)        │
│  ├─ Margherita     $120.00  │
│  │  [🟢 Active]    [Toggle] │
│  ├─ Pepperoni      $140.00  │
│  │  [🟢 Active]    [Toggle] │
│  └─ Hawaiian       $130.00  │
│     [⚫ Inactive]  [Toggle] │
│                             │
│  Drinks (4 products)        │
│  ├─ Coca Cola      $10.00   │
│  │  [🟢 Active]    [Toggle] │
│  └─ ...                     │
│                             │
└─────────────────────────────┘

Database Schema
Restaurant Service Database
sql-- stores
CREATE TABLE stores (
  store_id UUID PRIMARY KEY,
  owner_id UUID NOT NULL,
  name VARCHAR(255) NOT NULL,
  description VARCHAR(1000),
  logo_url VARCHAR(512),
  phone VARCHAR(20),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- locations
CREATE TABLE locations (
  location_id UUID PRIMARY KEY,
  store_id UUID NOT NULL,
  address VARCHAR(500) NOT NULL,
  city VARCHAR(100) NOT NULL,
  postal_code VARCHAR(20),
  phone VARCHAR(20),
  location_manager VARCHAR(255),
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  CONSTRAINT fk_store FOREIGN KEY (store_id) REFERENCES stores(store_id) ON DELETE CASCADE
);

-- operating_hours
CREATE TABLE operating_hours (
  id UUID PRIMARY KEY,
  location_id UUID NOT NULL,
  day_of_week VARCHAR(10) NOT NULL,
  open_time TIME NOT NULL,
  close_time TIME NOT NULL,
  is_closed BOOLEAN DEFAULT false,
  CONSTRAINT fk_location FOREIGN KEY (location_id) REFERENCES locations(location_id) ON DELETE CASCADE
);
Menu Service Database
sql-- menus
CREATE TABLE menus (
  menu_id UUID PRIMARY KEY,
  location_id UUID NOT NULL,
  status VARCHAR(20) NOT NULL,
  submitted_at TIMESTAMP,
  reviewed_at TIMESTAMP,
  rejection_reason TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- collections
CREATE TABLE collections (
  collection_id UUID PRIMARY KEY,
  menu_id UUID NOT NULL,
  name VARCHAR(255) NOT NULL,
  position INTEGER NOT NULL,
  image_url VARCHAR(512),
  created_at TIMESTAMP DEFAULT NOW(),
  CONSTRAINT fk_menu FOREIGN KEY (menu_id) REFERENCES menus(menu_id) ON DELETE CASCADE
);

-- sections
CREATE TABLE sections (
  section_id UUID PRIMARY KEY,
  collection_id UUID NOT NULL,
  name VARCHAR(255) NOT NULL,
  position INTEGER NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  CONSTRAINT fk_collection FOREIGN KEY (collection_id) REFERENCES collections(collection_id) ON DELETE CASCADE
);

-- products
CREATE TABLE products (
  product_id UUID PRIMARY KEY,
  location_id UUID NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  category VARCHAR(100),
  image_url VARCHAR(512),
  is_available BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- product_images
CREATE TABLE product_images (
  image_id UUID PRIMARY KEY,
  product_id UUID NOT NULL,
  image_url VARCHAR(512) NOT NULL,
  position INTEGER,
  CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

-- menu_products
CREATE TABLE menu_products (
  menu_product_id UUID PRIMARY KEY,
  menu_id UUID NOT NULL,
  product_id UUID NOT NULL,
  collection_id UUID NOT NULL,
  section_id UUID,
  position INTEGER NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  CONSTRAINT fk_menu FOREIGN KEY (menu_id) REFERENCES menus(menu_id) ON DELETE CASCADE,
  CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
  CONSTRAINT fk_collection FOREIGN KEY (collection_id) REFERENCES collections(collection_id) ON DELETE CASCADE,
  UNIQUE(menu_id, product_id)
);

-- attribute_groups
CREATE TABLE attribute_groups (
  attribute_group_id UUID PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  min_selections INTEGER DEFAULT 0,
  max_selections INTEGER DEFAULT 1,
  is_required BOOLEAN DEFAULT false,
  system_defined BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- attributes
CREATE TABLE attributes (
  attribute_id UUID PRIMARY KEY,
  attribute_group_id UUID NOT NULL,
  name VARCHAR(100) NOT NULL,
  price_impact DECIMAL(10,2) DEFAULT 0.00,
  is_default BOOLEAN DEFAULT false,
  is_available BOOLEAN DEFAULT true,
  system_defined BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  CONSTRAINT fk_attribute_group FOREIGN KEY (attribute_group_id) REFERENCES attribute_groups(attribute_group_id)
);

-- product_attribute_groups
CREATE TABLE product_attribute_groups (
  product_id UUID NOT NULL,
  attribute_group_id UUID NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  PRIMARY KEY (product_id, attribute_group_id),
  CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
  CONSTRAINT fk_attr_group FOREIGN KEY (attribute_group_id) REFERENCES attribute_groups(attribute_group_id)
);
