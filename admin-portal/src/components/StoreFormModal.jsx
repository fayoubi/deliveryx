import { useForm } from 'react-hook-form';
import { useEffect } from 'react';
import Modal from './Modal';
import Button from './Button';
import { validatePhone, validateUrl } from '../utils/validation';

/**
 * Store Form Modal - handles both Create and Edit
 */
const StoreFormModal = ({ isOpen, onClose, onSubmit, store = null, loading = false }) => {
  const isEdit = !!store;

  const {
    register,
    handleSubmit,
    formState: { errors },
    reset,
  } = useForm({
    defaultValues: {
      name: '',
      description: '',
      logo_url: '',
      phone: '',
    },
  });

  // Populate form when editing - reset form with store data when modal opens
  useEffect(() => {
    if (isOpen && store) {
      // Populate form with store data for editing
      reset({
        name: store.name || '',
        description: store.description || '',
        logo_url: store.logo_url || '',
        phone: store.phone || '',
      });
    } else if (isOpen && !store) {
      // Reset to empty form for creating
      reset({
        name: '',
        description: '',
        logo_url: '',
        phone: '',
      });
    }
  }, [isOpen, store, reset]);

  // Reset form when modal opens/closes or store changes
  const handleClose = () => {
    reset();
    onClose();
  };

  const onFormSubmit = (data) => {
    // Remove logo_url if empty (optional field)
    if (!data.logo_url || data.logo_url.trim() === '') {
      delete data.logo_url;
    }
    onSubmit(data);
  };

  return (
    <Modal
      isOpen={isOpen}
      onClose={handleClose}
      title={isEdit ? 'Edit Store' : 'Create Store'}
      size="md"
    >
      <form onSubmit={handleSubmit(onFormSubmit)} className="space-y-4">
        {/* Name */}
        <div>
          <label htmlFor="name" className="block text-sm font-medium text-secondary-700 mb-1">
            Store Name <span className="text-danger-500">*</span>
          </label>
          <input
            id="name"
            type="text"
            {...register('name', { required: 'Store name is required' })}
            className={`w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent transition ${
              errors.name ? 'border-danger-500' : 'border-gray-300'
            }`}
            placeholder="Enter store name"
          />
          {errors.name && (
            <p className="mt-1 text-sm text-danger-600">{errors.name.message}</p>
          )}
        </div>

        {/* Description */}
        <div>
          <label htmlFor="description" className="block text-sm font-medium text-secondary-700 mb-1">
            Description <span className="text-danger-500">*</span>
          </label>
          <textarea
            id="description"
            {...register('description', { required: 'Description is required' })}
            rows={3}
            className={`w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent transition resize-none ${
              errors.description ? 'border-danger-500' : 'border-gray-300'
            }`}
            placeholder="Enter store description"
          />
          {errors.description && (
            <p className="mt-1 text-sm text-danger-600">{errors.description.message}</p>
          )}
        </div>

        {/* Logo URL */}
        <div>
          <label htmlFor="logo_url" className="block text-sm font-medium text-secondary-700 mb-1">
            Logo URL <span className="text-secondary-400">(optional)</span>
          </label>
          <input
            id="logo_url"
            type="text"
            {...register('logo_url', {
              validate: validateUrl,
            })}
            className={`w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent transition ${
              errors.logo_url ? 'border-danger-500' : 'border-gray-300'
            }`}
            placeholder="https://example.com/logo.png"
          />
          {errors.logo_url && (
            <p className="mt-1 text-sm text-danger-600">{errors.logo_url.message}</p>
          )}
          <p className="mt-1 text-xs text-secondary-500">
            Must start with http:// or https://
          </p>
        </div>

        {/* Phone */}
        <div>
          <label htmlFor="phone" className="block text-sm font-medium text-secondary-700 mb-1">
            Phone Number <span className="text-danger-500">*</span>
          </label>
          <input
            id="phone"
            type="text"
            {...register('phone', {
              validate: validatePhone,
            })}
            className={`w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent transition ${
              errors.phone ? 'border-danger-500' : 'border-gray-300'
            }`}
            placeholder="+1-555-123-4567"
          />
          {errors.phone && (
            <p className="mt-1 text-sm text-danger-600">{errors.phone.message}</p>
          )}
          <p className="mt-1 text-xs text-secondary-500">
            Allowed: digits, spaces, dashes, +, ( )
          </p>
        </div>

        {/* Actions */}
        <div className="flex gap-3 pt-4">
          <Button
            type="button"
            variant="secondary"
            onClick={handleClose}
            disabled={loading}
            className="flex-1"
          >
            Cancel
          </Button>
          <Button
            type="submit"
            variant="primary"
            loading={loading}
            className="flex-1"
          >
            {isEdit ? 'Update Store' : 'Create Store'}
          </Button>
        </div>
      </form>
    </Modal>
  );
};

export default StoreFormModal;
