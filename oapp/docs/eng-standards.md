
---

## 2. Standards file – `/docs/engineering-standards.md`

Below is a single MD file with sections for Frontend, Backend, plus cross-cutting standards. This encodes the “tenets” we’ve established in this session and fills in some obvious gaps for consistency across DeliveryX.

```markdown
# DeliveryX Engineering Standards

This document defines project-wide engineering standards and tenets for the DeliveryX platform.

- Stories MUST live under `/stories/...` (e.g. `/stories/todo/admin-portal.md`).
- Standards and reference architecture documents MUST live under `/docs/...` as Markdown.
- All services and apps SHOULD use consistent naming, versioning, and deployment conventions defined below.

---

## 1. Cross-Cutting Tenets

1. **APIs via Gateway**
   - All frontend/admin clients talk to services through the API gateway (Traefik) when available.
   - Direct service calls (e.g., `http://localhost:8081`) are for local debugging only, not for UI configuration.

2. **Versioned APIs**
   - Public APIs MUST be versioned with a prefix: `/api/v1/...`.
   - New breaking changes MUST go under `/api/v2/...` (no breaking changes in-place).

3. **Consistency Over Cleverness**
   - Prefer simple, boring solutions (e.g. basic tables instead of heavy data-grid libraries) unless there is clear, documented need.

4. **Documentation as a First-Class Output**
   - Every non-trivial feature MUST:
     - Have a story file in `/stories/todo` or `/stories/doing` or `/stories/done`.
     - Update relevant docs in `/docs` when standards or architecture are impacted.

5. **Containers Everywhere**
   - All deployable services (backend & frontend/admin) MUST be containerized.
   - Containers are wired through a shared Docker network (e.g. `deliveryx-network`) and exposed via Traefik.

6. **Environment Configuration**
   - Credentials, secrets, and environment-specific values MUST be configured via environment variables or external secrets, not hard-coded.
   - Base URLs (API gateway, service endpoints) come from env vars in production; local defaults are allowed for `vite`/dev-time config.

---

## 2. Frontend Standards (Admin Portals & UIs)

These standards apply to the DeliveryX admin portal and any future frontend apps unless explicitly overridden.

### 2.1 Stack & Tooling

- **Framework:** React 18+.
- **Bundler/Dev Server:** Vite.
- **Language:** JavaScript (ESNext) for now. TypeScript adoption can be done via a separate story and must be consistent across the app.
- **Styling:** Tailwind CSS as the primary styling mechanism.
- **Routing:** React Router v6.
- **HTTP Client:** `axios` with a shared instance.
  - Base URL SHOULD point to the gateway (e.g. `http://localhost/api/v1` in local dev).
- **Forms:** `react-hook-form` for form state and validation.
- **Icons:** Heroicons.
- **Notifications/Toasts:** `react-hot-toast` (or equivalent), used consistently.
- **State Management:**
  - Prefer local state + custom hooks over global state until a clear, shared cross-page state emerges.
  - When global state is needed, a separate standards update MUST be introduced.

### 2.2 UX & Interaction Tenets

- **Mobile-First:**
  - Layout and components are designed mobile-first then enhanced for tablet/desktop.
  - Breakpoint at `768px` (Tailwind `md`) is the standard for table-to-card transitions.

- **Tables vs Cards:**
  - Desktop: use simple `<table>` based layouts for tabular data (no heavy grid library by default).
  - Mobile: collapse tables into card layouts (stacked rows with labels).

- **Modals & Dialogs:**
  - Create/Update forms SHOULD use modal overlays.
  - Delete operations MUST use a confirmation dialog/modal with:
    - Clear warning message.
    - Primary destructive button styled as danger (e.g., red).
  - Modals SHOULD support:
    - Close on ESC.
    - Close on outside-click (unless unsafe for the user).

- **Optimistic Updates:**
  - CRUD operations SHOULD use optimistic updates when the UX benefits:
    - Immediately update UI on create/update/delete.
    - On error, show a toast and revert the local change or refetch from server.
  - For complex flows where rollback is difficult, prefer server-authoritative refetch.

- **Forms & Validation:**
  - `react-hook-form` MUST be used for non-trivial forms.
  - Client-side validation rules:
    - Required fields MUST show inline errors.
    - URL fields (e.g. logo_url) MUST perform basic URL format validation.
    - Phone fields MUST have at least a basic pattern and not be empty.
    - Numeric ranges (e.g. lat/long) MUST be enforced via validation rules.
  - Submit buttons MUST:
    - Show a loading/disabled state during submission.
    - Prevent double submissions.

- **Notifications & Errors:**
  - Every create/update/delete operation MUST:
    - Show a success toast on 2xx.
    - Show an error toast on failure with user-friendly messaging.
  - Network errors MUST show a generic, friendly message and not raw stack traces.
  - Validation errors MUST appear inline near fields (not only as toasts).

### 2.3 Layout & Components

- **Component Structure:**
  - Reusable primitives live under `src/components` (Button, Modal, ConfirmDialog, Spinner, etc.).
  - Route-level components/pages live under `src/pages`.

- **Admin Portal Naming & Structure:**
  - Admin portals MUST live in top-level folders named by app, e.g.:
    - `admin-portal/`
  - Example structure (as used for the Restaurant Management UI):

    ```text
    admin-portal/
    ├── src/
    │   ├── components/
    │   ├── pages/
    │   ├── services/
    │   ├── hooks/
    │   ├── utils/
    │   ├── App.jsx
    │   ├── main.jsx
    │   └── index.css
    ├── public/
    ├── Dockerfile
    ├── nginx.conf
    ├── vite.config.js
    ├── tailwind.config.js
    ├── package.json
    └── README.md
    ```

- **Routing Paths:**
  - Admin portals SHOULD be mounted under a prefix path on the gateway:
    - e.g. `/admin` for this Restaurant Management UI.
  - React Router MUST be configured to work with that base path (SPA routing fallback via nginx).

---

## 3. Backend Standards (APIs & Services)

These standards reflect how the Restaurant Service and similar services are expected to behave.

### 3.1 API Design

- **Style:** RESTful JSON APIs.
- **Base Path:** All public endpoints MUST be under `/api/v{N}/...`.
- **Resource Naming:**
  - Plural snake or kebab-case for collections (e.g. `/stores`, `/locations`).
  - Path parameters for specific resources (e.g. `/stores/{store_id}`, `/locations/{location_id}`).
- **Nested Resources:**
  - When a resource belongs to a parent (e.g. locations belonging to store) use nested paths:
    - `GET /stores/{store_id}/locations`
    - `POST /stores/{store_id}/locations`

### 3.2 HTTP Semantics

- Standard HTTP verbs MUST be used consistently:
  - `GET` – Fetch resources (no side effects).
  - `POST` – Create resources.
  - `PUT` – Full updates.
  - `DELETE` – Remove resources.
- Status codes:
  - 2xx for success (200, 201, 204).
    - 204 for deletes with no body.
  - 4xx for client errors (400, 404, 422, etc.).
    - 400 for validation errors
    - 404 when resource not found
    - 409 for constraint/conflict (e.g., cannot delete due to relations)
  - 5xx for server errors.
- Error payloads SHOULD follow a consistent structure, e.g.:

  ```json
  {
    "message": "Human-readable error",
    "code": "ERROR_CODE",
    "details": {
      "...": "..."
    }
  }

## 4. Extras and Misc
(Not implemented)
- IDs are UUIDv4 strings.
- Timestamps returned in ISO‑8601 UTC.
- Prices should be in money cents at all time.