import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { ArrowLeftIcon, PencilIcon, PlusIcon, BuildingStorefrontIcon } from '@heroicons/react/24/outline';
import toast from 'react-hot-toast';
import { storesAPI, locationsAPI } from '../services/api';
import Button from '../components/Button';
import Spinner from '../components/Spinner';
import LocationTable from '../components/LocationTable';
import LocationCard from '../components/LocationCard';
import LocationFormModal from '../components/LocationFormModal';
import StoreFormModal from '../components/StoreFormModal';
import ConfirmDialog from '../components/ConfirmDialog';
import { getStoreInitials } from '../utils/validation';

const StoreDetails = () => {
  const { storeId } = useParams();
  const navigate = useNavigate();

  // State
  const [store, setStore] = useState(null);
  const [locations, setLocations] = useState([]);
  const [loading, setLoading] = useState(true);
  const [locationsLoading, setLocationsLoading] = useState(true);
  const [showStoreModal, setShowStoreModal] = useState(false);
  const [showLocationModal, setShowLocationModal] = useState(false);
  const [showDeleteDialog, setShowDeleteDialog] = useState(false);
  const [selectedLocation, setSelectedLocation] = useState(null);
  const [storeFormLoading, setStoreFormLoading] = useState(false);
  const [locationFormLoading, setLocationFormLoading] = useState(false);
  const [deleteLoading, setDeleteLoading] = useState(false);
  const [logoError, setLogoError] = useState(false);

  // Fetch store and locations on mount
  useEffect(() => {
    fetchStore();
    fetchLocations();
  }, [storeId]);

  const fetchStore = async () => {
    try {
      setLoading(true);
      const storeData = await storesAPI.getById(storeId);
      setStore(storeData);
    } catch (error) {
      toast.error(error.message || 'Failed to load store');
      // Navigate back if store not found
      if (error.status === 404) {
        navigate('/stores');
      }
    } finally {
      setLoading(false);
    }
  };

  const fetchLocations = async () => {
    try {
      setLocationsLoading(true);
      const response = await locationsAPI.listByStore(storeId);
      setLocations(response.items || []);
    } catch (error) {
      toast.error(error.message || 'Failed to load locations');
    } finally {
      setLocationsLoading(false);
    }
  };

  // Update store
  const handleUpdateStore = async (data) => {
    // Save original state for rollback (must be outside try block for catch access)
    const originalStore = { ...store };

    try {
      setStoreFormLoading(true);

      // Optimistic update
      setStore((prev) => ({ ...prev, ...data }));
      setShowStoreModal(false);

      // API call
      const updatedStore = await storesAPI.update(storeId, data);
      setStore(updatedStore);
      toast.success('Store updated successfully');
    } catch (error) {
      // Rollback
      setStore(originalStore);
      toast.error(error.message || 'Failed to update store');
    } finally {
      setStoreFormLoading(false);
    }
  };

  // Create location
  const handleCreateLocation = async (data) => {
    try {
      setLocationFormLoading(true);

      // Optimistic update
      const tempId = `temp-${Date.now()}`;
      const tempLocation = { ...data, location_id: tempId, store_id: storeId, created_at: new Date().toISOString() };
      setLocations((prev) => [tempLocation, ...prev]);
      setShowLocationModal(false);

      // API call
      const newLocation = await locationsAPI.create(storeId, data);

      // Replace temp with real data
      setLocations((prev) => prev.map((l) => (l.location_id === tempId ? newLocation : l)));
      toast.success('Location created successfully');
    } catch (error) {
      // Rollback
      setLocations((prev) => prev.filter((l) => !l.location_id.toString().startsWith('temp-')));
      toast.error(error.message || 'Failed to create location');
    } finally {
      setLocationFormLoading(false);
    }
  };

  // Edit location
  const handleEditLocation = async (data) => {
    // Save original state for rollback (must be outside try block for catch access)
    const originalLocation = locations.find((l) => l.location_id === selectedLocation.location_id);

    try {
      setLocationFormLoading(true);

      // Optimistic update
      setLocations((prev) =>
        prev.map((l) => (l.location_id === selectedLocation.location_id ? { ...l, ...data } : l))
      );
      setShowLocationModal(false);

      // API call
      const updatedLocation = await locationsAPI.update(selectedLocation.location_id, data);

      // Update with real data
      setLocations((prev) =>
        prev.map((l) => (l.location_id === selectedLocation.location_id ? updatedLocation : l))
      );
      toast.success('Location updated successfully');
      setSelectedLocation(null);
    } catch (error) {
      // Rollback
      setLocations((prev) =>
        prev.map((l) => (l.location_id === selectedLocation.location_id ? originalLocation : l))
      );
      toast.error(error.message || 'Failed to update location');
    } finally {
      setLocationFormLoading(false);
    }
  };

  // Delete location
  const handleDeleteLocation = async () => {
    // Save original state for rollback (must be outside try block for catch access)
    const originalLocations = [...locations];

    try {
      setDeleteLoading(true);

      // Optimistic update
      setLocations((prev) => prev.filter((l) => l.location_id !== selectedLocation.location_id));

      // API call
      await locationsAPI.delete(selectedLocation.location_id);

      // Close dialog only on success
      setShowDeleteDialog(false);
      toast.success('Location deleted successfully');
      setSelectedLocation(null);
    } catch (error) {
      // Rollback
      setLocations(originalLocations);

      // Handle specific error cases
      if (error.status === 409) {
        toast.error(error.message || 'Cannot delete location while it has menus');
      } else {
        toast.error(error.message || 'Failed to delete location');
      }
      // Keep dialog open to show error context
    } finally {
      setDeleteLoading(false);
    }
  };

  // Modal handlers
  const openCreateLocationModal = () => {
    setSelectedLocation(null);
    setShowLocationModal(true);
  };

  const openEditLocationModal = (location) => {
    setSelectedLocation(location);
    setShowLocationModal(true);
  };

  const openDeleteDialog = (location) => {
    setSelectedLocation(location);
    setShowDeleteDialog(true);
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center min-h-screen">
        <Spinner size="lg" />
      </div>
    );
  }

  if (!store) {
    return null;
  }

  return (
    <div className="container mx-auto px-4 py-8 max-w-7xl">
      {/* Back Button */}
      <button
        onClick={() => navigate('/stores')}
        className="flex items-center gap-2 text-secondary-600 hover:text-secondary-900 mb-6 transition-colors"
      >
        <ArrowLeftIcon className="h-5 w-5" />
        Back to Stores
      </button>

      {/* Store Info Card */}
      <div className="bg-white rounded-xl shadow-card p-6 mb-8">
        <div className="flex flex-col md:flex-row md:items-start gap-6">
          {/* Logo */}
          <div className="flex-shrink-0">
            {store.logo_url && !logoError ? (
              <img
                src={store.logo_url}
                alt={`${store.name} logo`}
                className="w-24 h-24 rounded-xl object-cover"
                onError={() => setLogoError(true)}
              />
            ) : (
              <div className="w-24 h-24 rounded-xl bg-primary-100 flex items-center justify-center">
                <span className="text-3xl font-bold text-primary-600">
                  {getStoreInitials(store.name)}
                </span>
              </div>
            )}
          </div>

          {/* Store Details */}
          <div className="flex-1">
            <div className="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-4 mb-4">
              <div>
                <h1 className="text-3xl font-bold text-secondary-900 mb-2">{store.name}</h1>
                <p className="text-secondary-600">{store.description}</p>
              </div>
              <Button
                onClick={() => setShowStoreModal(true)}
                variant="outline"
                className="flex items-center gap-2 whitespace-nowrap"
              >
                <PencilIcon className="h-5 w-5" />
                Edit Store
              </Button>
            </div>

            <div className="flex items-center text-secondary-600">
              <svg
                className="h-5 w-5 mr-2"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z"
                />
              </svg>
              {store.phone}
            </div>
          </div>
        </div>
      </div>

      {/* Locations Section */}
      <div className="mb-6 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h2 className="text-2xl font-bold text-secondary-900">Locations for {store.name}</h2>
          <p className="text-secondary-600 mt-1">Manage store locations and branches</p>
        </div>
        <Button
          onClick={openCreateLocationModal}
          className="flex items-center gap-2 w-full sm:w-auto"
        >
          <PlusIcon className="h-5 w-5" />
          Add Location
        </Button>
      </div>

      {/* Locations List */}
      {locationsLoading ? (
        <div className="flex justify-center items-center py-20">
          <Spinner size="lg" />
        </div>
      ) : locations.length === 0 ? (
        /* Empty State */
        <div className="bg-white rounded-xl shadow-card p-12 text-center">
          <div className="flex justify-center mb-4">
            <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center">
              <BuildingStorefrontIcon className="w-8 h-8 text-gray-400" />
            </div>
          </div>
          <h3 className="text-lg font-medium text-secondary-900 mb-2">
            No locations yet
          </h3>
          <p className="text-secondary-600 mb-6">
            Add the first location for this store!
          </p>
          <Button onClick={openCreateLocationModal} className="inline-flex items-center gap-2">
            <PlusIcon className="h-5 w-5" />
            Add Location
          </Button>
        </div>
      ) : (
        <>
          {/* Desktop Table View */}
          <div className="hidden md:block">
            <LocationTable
              locations={locations}
              onEdit={openEditLocationModal}
              onDelete={openDeleteDialog}
              onLocationUpdated={fetchLocations}
            />
          </div>

          {/* Mobile Card View */}
          <div className="md:hidden space-y-4">
            {locations.map((location) => (
              <LocationCard
                key={location.location_id}
                location={location}
                onEdit={openEditLocationModal}
                onDelete={openDeleteDialog}
                onLocationUpdated={fetchLocations}
              />
            ))}
          </div>
        </>
      )}

      {/* Store Edit Modal */}
      <StoreFormModal
        isOpen={showStoreModal}
        onClose={() => setShowStoreModal(false)}
        onSubmit={handleUpdateStore}
        store={store}
        loading={storeFormLoading}
      />

      {/* Location Form Modal */}
      <LocationFormModal
        isOpen={showLocationModal}
        onClose={() => {
          setShowLocationModal(false);
          setSelectedLocation(null);
        }}
        onSubmit={selectedLocation ? handleEditLocation : handleCreateLocation}
        location={selectedLocation}
        loading={locationFormLoading}
      />

      {/* Delete Confirmation Dialog */}
      <ConfirmDialog
        isOpen={showDeleteDialog}
        onClose={() => {
          setShowDeleteDialog(false);
          setSelectedLocation(null);
        }}
        onConfirm={handleDeleteLocation}
        title="Delete Location"
        message={
          <>
            Are you sure you want to delete the location at{' '}
            <strong>{selectedLocation?.city}, {selectedLocation?.address}</strong>?
            This action cannot be undone.
          </>
        }
        confirmText="Delete"
        loading={deleteLoading}
      />
    </div>
  );
};

export default StoreDetails;
