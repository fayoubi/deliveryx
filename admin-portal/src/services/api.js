import axios from 'axios';

// Create axios instance with base configuration
const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost/api/v1',
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 10000, // 10 seconds
});

// Response interceptor for error handling
api.interceptors.response.use(
  (response) => response,
  (error) => {
    // Network error
    if (!error.response) {
      return Promise.reject({
        message: 'Unable to connect to server. Please check your connection and try again.',
        code: 'NETWORK_ERROR',
      });
    }

    // API error response
    const apiError = error.response.data || {};
    return Promise.reject({
      message: apiError.message || 'An unexpected error occurred',
      code: apiError.code || 'UNKNOWN_ERROR',
      details: apiError.details || null,
      status: error.response.status,
    });
  }
);

// ============================================
// STORES API
// ============================================

export const storesAPI = {
  // GET /api/v1/stores - List all stores
  list: async () => {
    const response = await api.get('/stores');
    return response.data;
  },

  // POST /api/v1/stores - Create store
  create: async (data) => {
    const response = await api.post('/stores', data);
    return response.data;
  },

  // GET /api/v1/stores/{store_id} - Get store details
  getById: async (storeId) => {
    const response = await api.get(`/stores/${storeId}`);
    return response.data;
  },

  // PUT /api/v1/stores/{store_id} - Update store
  update: async (storeId, data) => {
    const response = await api.put(`/stores/${storeId}`, data);
    return response.data;
  },

  // DELETE /api/v1/stores/{store_id} - Delete store
  delete: async (storeId) => {
    const response = await api.delete(`/stores/${storeId}`);
    return response.data;
  },
};

// ============================================
// LOCATIONS API
// ============================================

export const locationsAPI = {
  // GET /api/v1/stores/{store_id}/locations - List locations for store
  listByStore: async (storeId) => {
    const response = await api.get(`/stores/${storeId}/locations`);
    return response.data;
  },

  // POST /api/v1/stores/{store_id}/locations - Create location
  create: async (storeId, data) => {
    const response = await api.post(`/stores/${storeId}/locations`, data);
    return response.data;
  },

  // GET /api/v1/locations/{location_id} - Get location details
  getById: async (locationId) => {
    const response = await api.get(`/locations/${locationId}`);
    return response.data;
  },

  // PUT /api/v1/locations/{location_id} - Update location
  update: async (locationId, data) => {
    const response = await api.put(`/locations/${locationId}`, data);
    return response.data;
  },

  // DELETE /api/v1/locations/{location_id} - Delete location
  delete: async (locationId) => {
    const response = await api.delete(`/locations/${locationId}`);
    return response.data;
  },
};

// ============================================
// MENUS API
// ============================================

export const menusAPI = {
  // POST /api/v1/locations/{location_id}/menus - Create menu
  create: async (locationId) => {
    const response = await api.post(`/locations/${locationId}/menus`);
    return response.data;
  },

  // GET /api/v1/menus/{menu_id} - Get complete menu
  getComplete: async (menuId) => {
    const response = await api.get(`/menus/${menuId}`);
    return response.data;
  },
};

export default api;
