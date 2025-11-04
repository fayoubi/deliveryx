Epic: Admin PortalFrontend

# Story: Admin Portal – Restaurant Management UI (Stores & Locations CRUD)

**Epic:** Restaurant Service Frontend  
**Story Type:** Feature  
**Priority:** High

---

## User Story

As a restaurant administrator  
I want a web interface (admin portal) to manage stores and their locations  
So that I can easily add, edit, and remove restaurants without using Postman or API tools.

---

## Context & Background

The Restaurant Service API is fully functional and tested. We need a simple, user-friendly admin portal that allows administrators to perform CRUD operations on Stores and Locations. This is the first UI component of the DeliveryX platform and will serve as the foundation for future admin interfaces.

**Current State:**

- Restaurant Service API is accessible at `http://localhost:8081/api/v1`
- API Gateway (Traefik) routes requests at `http://localhost/api/v1`
- All CRUD endpoints are working and tested via Postman
- No admin portal UI currently exists

**Desired State:**

- Admin portal accessible at `http://localhost/admin`
- Full CRUD operations for Stores and Locations via intuitive UI
- Responsive design (mobile-first)
- Admin portal served as a Docker container via Traefik

---

## Technical Stack

### Admin Portal (Frontend)

- Framework: React 18+ with Vite
- Styling: Tailwind CSS
- Routing: React Router v6
- Forms: `react-hook-form`
- HTTP Client: `axios`
- Icons: Heroicons
- Notifications: `react-hot-toast` (or similar)

### Deployment

- Container: Docker with nginx serving static build
- Gateway: Served via Traefik at `http://localhost/admin`
- Environment: Development hot-reload with Vite dev server

---

## Acceptance Criteria

### AC1: Infrastructure Setup

- ✅ React + Vite project initialized in `/admin-portal` directory
- ✅ Tailwind CSS configured and working
- ✅ `axios` configured with base URL pointing to API Gateway (`http://localhost/api/v1`)
- ✅ React Router configured with routes for Stores and Store Details
- ✅ Dockerfile created to build and serve the app
- ✅ `docker-compose.yml` updated to include `admin-portal` service
- ✅ Traefik routes configured to serve admin portal at `http://localhost/admin`

---

### AC2: Stores List View (Master View)

- ✅ Display all stores in a responsive layout:
  - Desktop: Table with columns (Name, Description, Phone, Actions)
  - Mobile: Card layout with store details stacked
- ✅ Each store row/card has action buttons:
  - View/Edit (pencil icon) – opens edit modal
  - Delete (trash icon) – opens delete confirmation modal
- ✅ "Create Store" button at top of page opens create modal
- ✅ Clicking on a store name/card navigates to Store Details view
- ✅ Empty state when no stores exist:  
  `"No stores yet. Create your first store!"`
- ✅ Loading state while fetching stores (spinner or skeleton)

---

### AC3: Create Store Modal

- ✅ Modal overlay with form containing fields:
  - **Name** (required, text input)
  - **Description** (required, textarea)
  - **Logo URL** (optional, text input with URL validation)
  - **Phone** (required, text input with phone format validation)
- ✅ Client-side validation using `react-hook-form`:
  - Required fields show error message if empty
  - Logo URL validated as proper URL format
  - Phone validated for basic format (e.g., `+1-XXX-XXX-XXXX` or equivalent)
- ✅ "Cancel" button closes modal without saving
- ✅ "Create Store" button:
  - Submits form via `POST /api/v1/stores`
  - Shows loading state on button during submission
  - On success: closes modal, shows success toast, updates store list **optimistically**
  - On error: shows error toast with API error message and rolls back optimistic change if needed
- ✅ Modal closes on outside click or ESC key

---

### AC4: Edit Store Modal

- ✅ Modal pre-populated with existing store data
- ✅ Same form fields and validation rules as Create Store
- ✅ "Cancel" button closes modal without saving
- ✅ "Update Store" button:
  - Submits form via `PUT /api/v1/stores/{store_id}`
  - Shows loading state on button during submission
  - On success: closes modal, shows success toast, updates store in list **optimistically**
  - On error: shows error toast with API error message and rolls back optimistic change if needed

---

### AC5: Delete Store Confirmation

- ✅ Modal dialog with warning message:

  > "Are you sure you want to delete **[Store Name]**? This action cannot be undone."

- ✅ "Cancel" button closes dialog
- ✅ "Delete" button (red/danger style):
  - Submits `DELETE /api/v1/stores/{store_id}`
  - Shows loading state on button during submission
  - On success: closes dialog, shows success toast, removes store from list **optimistically**
  - On error: shows error toast with API error message and restores store in list if needed

---

### AC6: Store Details View (Detail View)

- ✅ Back button/link to return to Stores List
- ✅ Store information displayed at top:
  - Store Name (large heading)
  - Description
  - Phone
  - Logo (if `logo_url` exists, show image thumbnail)
- ✅ "Edit Store" button opens edit modal (same as AC4)
- ✅ Locations section below store info with heading:  
  `"Locations for [Store Name]"`

---

### AC7: Locations List (within Store Details)

- ✅ Display all locations for the selected store in responsive layout:
  - Desktop: Table with columns (City, Address, Phone, Manager, Actions)
  - Mobile: Card layout with location details stacked
- ✅ Each location row/card has action buttons:
  - Edit (pencil icon) – opens edit location modal
  - Delete (trash icon) – opens delete confirmation modal
- ✅ "Add Location" button at top of locations section opens create location modal
- ✅ Empty state when no locations exist:  
  `"No locations yet. Add the first location for this store!"`
- ✅ Loading state while fetching locations

---

### AC8: Create Location Modal (within Store Details)

- ✅ Modal overlay with form containing fields:
  - **Address** (required, text input)
  - **City** (required, text input)
  - **Postal Code** (required, text input)
  - **Phone** (required, text input with phone format validation)
  - **Location Manager** (required, text input)
  - **Latitude** (required, number input, -90 to 90)
  - **Longitude** (required, number input, -180 to 180)
- ✅ Store ID is automatically included from current context (not shown in form)
- ✅ Client-side validation using `react-hook-form`:
  - Required fields show error message if empty
  - Latitude/Longitude validated for proper ranges
  - Phone validated for basic pattern
- ✅ "Cancel" button closes modal
- ✅ "Create Location" button:
  - Submits form via `POST /api/v1/stores/{store_id}/locations`
  - Shows loading state on button
  - On success: closes modal, shows success toast, updates location list **optimistically**
  - On error: shows error toast with API error message and rolls back optimistic change if needed

---

### AC9: Edit Location Modal

- ✅ Modal pre-populated with existing location data
- ✅ Same form fields and validation as Create Location
- ✅ "Cancel" button closes modal
- ✅ "Update Location" button:
  - Submits form via `PUT /api/v1/locations/{location_id}`
  - Shows loading state on button
  - On success: closes modal, shows success toast, updates location in list **optimistically**
  - On error: shows error toast with API error message and rolls back optimistic change if needed

---

### AC10: Delete Location Confirmation

- ✅ Modal dialog with warning message:

  > "Are you sure you want to delete the location at **[City, Address]**? This action cannot be undone."

- ✅ "Cancel" button closes dialog
- ✅ "Delete" button (red/danger style):
  - Submits `DELETE /api/v1/locations/{location_id}`
  - Shows loading state on button during submission
  - On success: closes dialog, shows success toast, removes location from list **optimistically**
  - On error: shows error toast with API error message and restores location in list if needed

---

### AC11: Mobile Responsiveness

- ✅ All views are mobile-first and responsive
- ✅ Tables collapse to card layouts on mobile (breakpoint: `768px`)
- ✅ Modals are full-screen on mobile for better UX
- ✅ Buttons and touch targets are appropriately sized for mobile (min 44x44px)
- ✅ Navigation is accessible on mobile (hamburger menu or equivalent if needed)

---

### AC12: Error Handling & User Feedback

- ✅ Toast notifications for all operations:
  - Success: Green toast with checkmark icon
  - Error: Red toast with X icon, showing API error message
- ✅ Loading states prevent double-submission
- ✅ API errors display user-friendly messages (not raw error codes only)
- ✅ Form validation errors shown inline under each field
- ✅ Network errors handled gracefully, e.g.:

  > "Unable to connect to server. Please check your connection and try again."

---

## API Endpoints Used

### Stores

- `GET    /api/v1/stores`                    – List all stores  
- `POST   /api/v1/stores`                    – Create store  
- `GET    /api/v1/stores/{store_id}`         – Get store details  
- `PUT    /api/v1/stores/{store_id}`         – Update store  
- `DELETE /api/v1/stores/{store_id}`         – Delete store  

### Locations

- `GET    /api/v1/stores/{store_id}/locations` – List locations for store  
- `POST   /api/v1/stores/{store_id}/locations` – Create location  
- `GET    /api/v1/locations/{location_id}`     – Get location details  
- `PUT    /api/v1/locations/{location_id}`     – Update location  
- `DELETE /api/v1/locations/{location_id}`     – Delete location  

---

## Project Structure (Admin Portal)

```text
admin-portal/
├── src/
│   ├── components/
│   │   ├── StoreCard.jsx           # Store card for mobile
│   │   ├── StoreTable.jsx          # Store table for desktop
│   │   ├── LocationCard.jsx        # Location card for mobile
│   │   ├── LocationTable.jsx       # Location table for desktop
│   │   ├── Modal.jsx               # Reusable modal wrapper
│   │   ├── ConfirmDialog.jsx       # Delete confirmation dialog
│   │   ├── Button.jsx              # Reusable button component
│   │   └── Spinner.jsx             # Loading spinner
│   ├── pages/
│   │   ├── StoresList.jsx          # Master view – all stores
│   │   └── StoreDetails.jsx        # Detail view – store + locations
│   ├── services/
│   │   └── api.js                  # axios instance + API functions
│   ├── hooks/
│   │   └── useStores.js            # Custom hook for store operations (optional)
│   ├── utils/
│   │   └── validation.js           # Validation helpers
│   ├── App.jsx                     # Main app with routing
│   ├── main.jsx                    # Entry point
│   └── index.css                   # Tailwind imports
├── public/
├── Dockerfile
├── nginx.conf
├── vite.config.js
├── tailwind.config.js
├── package.json
└── README.md


Definition of Done

✅ Code merged to main branch

✅ Docker container builds successfully

✅ Admin portal accessible at http://localhost/admin

✅ All CRUD operations working for Stores

✅ All CRUD operations working for Locations

✅ Mobile responsive (tested on 320px, 768px, 1024px widths)

✅ Error handling working for all scenarios

✅ Optimistic updates working correctly (including rollback on failure)

✅ Manual testing completed (smoke test all CRUD operations)

✅ README.md updated with admin portal setup instructions