# DeliveryX Admin Portal

Restaurant management interface for the DeliveryX platform. Manage stores, locations, and operations through an intuitive web interface.

## Features

- **Store Management**: Create, edit, and delete restaurant stores
- **Location Management**: Manage multiple locations per store
- **Responsive Design**: Mobile-first design that works on all devices
- **Real-time Feedback**: Toast notifications for all operations
- **Optimistic Updates**: Instant UI updates with automatic rollback on errors
- **Form Validation**: Client-side validation matching backend rules

## Tech Stack

- **Frontend**: React 18 + Vite 7
- **Styling**: Tailwind CSS (v4) with UberEats-inspired design
- **Routing**: React Router v6
- **Forms**: React Hook Form
- **HTTP Client**: Axios
- **Icons**: Heroicons
- **Notifications**: React Hot Toast
- **Deployment**: Docker + Nginx

## Getting Started

### Prerequisites

- Node.js 20+ (for local development)
- Docker & Docker Compose (for production deployment)
- Restaurant Service API running at `http://localhost/api/v1`

### Local Development

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Configure environment variables:**

   Create a `.env.development` file (or use the existing one):
   ```env
   VITE_API_BASE_URL=http://localhost/api/v1
   ```

3. **Start development server:**
   ```bash
   npm run dev
   ```

4. **Access the app:**

   Open [http://localhost:5173](http://localhost:5173) in your browser.

   Note: In development, the app runs on port 5173. Routes are:
   - `/` - Redirects to stores list
   - `/stores` - All stores
   - `/stores/:id` - Store details with locations

### Production Deployment

The admin portal is deployed via Docker and served through Traefik at `http://localhost/admin`.

1. **Build the Docker image:**
   ```bash
   cd /path/to/oapp
   docker-compose build admin-portal
   ```

2. **Start the service:**
   ```bash
   docker-compose up -d admin-portal
   ```

3. **Access the app:**

   Open [http://localhost/admin](http://localhost/admin) in your browser.

4. **Check service status:**
   ```bash
   docker ps | grep admin-portal
   ```

5. **View logs:**
   ```bash
   docker logs deliveryx-admin-portal
   ```

## Project Structure

```
admin-portal/
├── src/
│   ├── components/          # Reusable UI components
│   │   ├── Button.jsx
│   │   ├── Spinner.jsx
│   │   ├── Modal.jsx
│   │   ├── ConfirmDialog.jsx
│   │   ├── StoreCard.jsx
│   │   ├── StoreTable.jsx
│   │   ├── StoreFormModal.jsx
│   │   ├── LocationCard.jsx
│   │   ├── LocationTable.jsx
│   │   └── LocationFormModal.jsx
│   ├── pages/               # Page components
│   │   ├── StoresList.jsx
│   │   └── StoreDetails.jsx
│   ├── services/            # API layer
│   │   └── api.js
│   ├── utils/               # Utility functions
│   │   └── validation.js
│   ├── App.jsx              # Main app with routing
│   ├── main.jsx             # Entry point
│   └── index.css            # Global styles + Tailwind
├── public/
├── Dockerfile
├── nginx.conf
├── tailwind.config.js
├── postcss.config.js
├── vite.config.js
└── package.json
```

## API Integration

The app communicates with the Restaurant Service API:

### Stores API
- `GET /api/v1/stores` - List all stores
- `POST /api/v1/stores` - Create store
- `GET /api/v1/stores/{id}` - Get store details
- `PUT /api/v1/stores/{id}` - Update store
- `DELETE /api/v1/stores/{id}` - Delete store

### Locations API
- `GET /api/v1/stores/{id}/locations` - List locations for store
- `POST /api/v1/stores/{id}/locations` - Create location
- `GET /api/v1/locations/{id}` - Get location details
- `PUT /api/v1/locations/{id}` - Update location
- `DELETE /api/v1/locations/{id}` - Delete location

## Troubleshooting

### Docker build fails
- Ensure Node.js 20+ base image is used
- Clear Docker cache: `docker builder prune`

### Container won't start
```bash
# Check container logs
docker logs deliveryx-admin-portal

# Restart container
docker-compose restart admin-portal
```

## Testing

Manual testing checklist in `web-ui-story1.md` - ensure all CRUD operations work correctly.

## Support

For issues or questions, contact the development team.
