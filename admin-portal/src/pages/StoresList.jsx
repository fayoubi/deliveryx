import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { PlusIcon } from '@heroicons/react/24/outline';
import toast from 'react-hot-toast';
import { storesAPI } from '../services/api';
import Button from '../components/Button';
import Spinner from '../components/Spinner';
import StoreTable from '../components/StoreTable';
import StoreCard from '../components/StoreCard';
import StoreFormModal from '../components/StoreFormModal';
import ConfirmDialog from '../components/ConfirmDialog';

const StoresList = () => {
  const navigate = useNavigate();

  // State
  const [stores, setStores] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showFormModal, setShowFormModal] = useState(false);
  const [showDeleteDialog, setShowDeleteDialog] = useState(false);
  const [selectedStore, setSelectedStore] = useState(null);
  const [formLoading, setFormLoading] = useState(false);
  const [deleteLoading, setDeleteLoading] = useState(false);

  // Fetch stores on mount
  useEffect(() => {
    fetchStores();
  }, []);

  const fetchStores = async () => {
    try {
      setLoading(true);
      const response = await storesAPI.list();
      setStores(response.items || []);
    } catch (error) {
      toast.error(error.message || 'Failed to load stores');
    } finally {
      setLoading(false);
    }
  };

  // Create store
  const handleCreate = async (data) => {
    try {
      setFormLoading(true);

      // Optimistic update - add placeholder
      const tempId = `temp-${Date.now()}`;
      const tempStore = { ...data, store_id: tempId, created_at: new Date().toISOString() };
      setStores((prev) => [tempStore, ...prev]);
      setShowFormModal(false);

      // API call
      const newStore = await storesAPI.create(data);

      // Replace temp with real data
      setStores((prev) => prev.map((s) => (s.store_id === tempId ? newStore : s)));
      toast.success('Store created successfully');
    } catch (error) {
      // Rollback optimistic update
      setStores((prev) => prev.filter((s) => !s.store_id.toString().startsWith('temp-')));
      toast.error(error.message || 'Failed to create store');
    } finally {
      setFormLoading(false);
    }
  };

  // Edit store
  const handleEdit = async (data) => {
    // Save original state for rollback (must be outside try block for catch access)
    const originalStore = stores.find((s) => s.store_id === selectedStore.store_id);

    try {
      setFormLoading(true);

      // Optimistic update
      setStores((prev) =>
        prev.map((s) => (s.store_id === selectedStore.store_id ? { ...s, ...data } : s))
      );
      setShowFormModal(false);

      // API call
      const updatedStore = await storesAPI.update(selectedStore.store_id, data);

      // Update with real data
      setStores((prev) =>
        prev.map((s) => (s.store_id === selectedStore.store_id ? updatedStore : s))
      );
      toast.success('Store updated successfully');
      setSelectedStore(null);
    } catch (error) {
      // Rollback optimistic update
      setStores((prev) =>
        prev.map((s) => (s.store_id === selectedStore.store_id ? originalStore : s))
      );
      toast.error(error.message || 'Failed to update store');
    } finally {
      setFormLoading(false);
    }
  };

  // Delete store
  const handleDelete = async () => {
    // Save original state for rollback (must be outside try block for catch access)
    const originalStores = [...stores];

    try {
      setDeleteLoading(true);

      // Optimistic update
      setStores((prev) => prev.filter((s) => s.store_id !== selectedStore.store_id));

      // API call
      await storesAPI.delete(selectedStore.store_id);

      // Close dialog only on success
      setShowDeleteDialog(false);
      toast.success('Store deleted successfully');
      setSelectedStore(null);
    } catch (error) {
      // Rollback on error
      setStores(originalStores);

      // Handle specific error cases
      if (error.status === 409) {
        toast.error(error.message || 'Cannot delete store while it has locations');
      } else {
        toast.error(error.message || 'Failed to delete store');
      }
      // Keep dialog open to show error context
    } finally {
      setDeleteLoading(false);
    }
  };

  // Open create modal
  const openCreateModal = () => {
    setSelectedStore(null);
    setShowFormModal(true);
  };

  // Open edit modal
  const openEditModal = (store) => {
    setSelectedStore(store);
    setShowFormModal(true);
  };

  // Open delete dialog
  const openDeleteDialog = (store) => {
    setSelectedStore(store);
    setShowDeleteDialog(true);
  };

  // Navigate to store details
  const handleStoreClick = (store) => {
    navigate(`/stores/${store.store_id}`);
  };

  return (
    <div className="container mx-auto px-4 py-8 max-w-7xl">
      {/* Header */}
      <div className="mb-6 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold text-secondary-900">Stores</h1>
          <p className="text-secondary-600 mt-1">Manage your restaurant stores</p>
        </div>
        <Button
          onClick={openCreateModal}
          className="flex items-center gap-2 w-full sm:w-auto"
        >
          <PlusIcon className="h-5 w-5" />
          Create Store
        </Button>
      </div>

      {/* Loading State */}
      {loading ? (
        <div className="flex justify-center items-center py-20">
          <Spinner size="lg" />
        </div>
      ) : stores.length === 0 ? (
        /* Empty State */
        <div className="bg-white rounded-xl shadow-card p-12 text-center">
          <div className="flex justify-center mb-4">
            <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center">
              <svg
                className="w-8 h-8 text-gray-400"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"
                />
              </svg>
            </div>
          </div>
          <h3 className="text-lg font-medium text-secondary-900 mb-2">
            No stores yet
          </h3>
          <p className="text-secondary-600 mb-6">
            Create your first store to get started!
          </p>
          <Button onClick={openCreateModal} className="inline-flex items-center gap-2">
            <PlusIcon className="h-5 w-5" />
            Create Store
          </Button>
        </div>
      ) : (
        <>
          {/* Desktop Table View */}
          <div className="hidden md:block">
            <StoreTable
              stores={stores}
              onEdit={openEditModal}
              onDelete={openDeleteDialog}
              onRowClick={handleStoreClick}
            />
          </div>

          {/* Mobile Card View */}
          <div className="md:hidden space-y-4">
            {stores.map((store) => (
              <StoreCard
                key={store.store_id}
                store={store}
                onEdit={openEditModal}
                onDelete={openDeleteDialog}
                onClick={() => handleStoreClick(store)}
              />
            ))}
          </div>
        </>
      )}

      {/* Form Modal */}
      <StoreFormModal
        isOpen={showFormModal}
        onClose={() => {
          setShowFormModal(false);
          setSelectedStore(null);
        }}
        onSubmit={selectedStore ? handleEdit : handleCreate}
        store={selectedStore}
        loading={formLoading}
      />

      {/* Delete Confirmation Dialog */}
      <ConfirmDialog
        isOpen={showDeleteDialog}
        onClose={() => {
          setShowDeleteDialog(false);
          setSelectedStore(null);
        }}
        onConfirm={handleDelete}
        title="Delete Store"
        message={
          <>
            Are you sure you want to delete <strong>{selectedStore?.name}</strong>?
            This action cannot be undone.
          </>
        }
        confirmText="Delete"
        loading={deleteLoading}
      />
    </div>
  );
};

export default StoresList;
