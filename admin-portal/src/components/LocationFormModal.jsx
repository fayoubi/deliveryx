import { useForm } from 'react-hook-form';
import { useEffect } from 'react';
import Modal from './Modal';
import Button from './Button';
import { validatePhone, validateLatitude, validateLongitude, validateLength } from '../utils/validation';

/**
 * Location Form Modal - handles both Create and Edit
 */
const LocationFormModal = ({ isOpen, onClose, onSubmit, location = null, loading = false }) => {
  const isEdit = !!location;

  const {
    register,
    handleSubmit,
    formState: { errors },
    reset,
  } = useForm({
    defaultValues: {
      address: '',
      city: '',
      postal_code: '',
      phone: '',
      location_manager: '',
      latitude: '',
      longitude: '',
    },
  });

  // Populate form when editing - reset form with location data when modal opens
  useEffect(() => {
    if (isOpen && location) {
      // Populate form with location data for editing
      reset({
        address: location.address || '',
        city: location.city || '',
        postal_code: location.postal_code || '',
        phone: location.phone || '',
        location_manager: location.location_manager || '',
        latitude: location.latitude || '',
        longitude: location.longitude || '',
      });
    } else if (isOpen && !location) {
      // Reset to empty form for creating
      reset({
        address: '',
        city: '',
        postal_code: '',
        phone: '',
        location_manager: '',
        latitude: '',
        longitude: '',
      });
    }
  }, [isOpen, location, reset]);

  // Reset form when modal opens/closes or location changes
  const handleClose = () => {
    reset();
    onClose();
  };

  const onFormSubmit = (data) => {
    // Clean up optional fields
    const cleanedData = { ...data };

    if (!cleanedData.postal_code || cleanedData.postal_code.trim() === '') {
      delete cleanedData.postal_code;
    }
    if (!cleanedData.location_manager || cleanedData.location_manager.trim() === '') {
      delete cleanedData.location_manager;
    }
    if (!cleanedData.latitude || cleanedData.latitude === '') {
      delete cleanedData.latitude;
    } else {
      cleanedData.latitude = parseFloat(cleanedData.latitude);
    }
    if (!cleanedData.longitude || cleanedData.longitude === '') {
      delete cleanedData.longitude;
    } else {
      cleanedData.longitude = parseFloat(cleanedData.longitude);
    }

    onSubmit(cleanedData);
  };

  return (
    <Modal
      isOpen={isOpen}
      onClose={handleClose}
      title={isEdit ? 'Edit Location' : 'Add Location'}
      size="lg"
    >
      <form onSubmit={handleSubmit(onFormSubmit)} className="space-y-4">
        {/* Address */}
        <div>
          <label htmlFor="address" className="block text-sm font-medium text-secondary-700 mb-1">
            Address <span className="text-danger-500">*</span>
          </label>
          <input
            id="address"
            type="text"
            {...register('address', { required: 'Address is required' })}
            className={`w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent transition ${
              errors.address ? 'border-danger-500' : 'border-gray-300'
            }`}
            placeholder="123 Main Street"
          />
          {errors.address && (
            <p className="mt-1 text-sm text-danger-600">{errors.address.message}</p>
          )}
        </div>

        {/* City & Postal Code (Row) */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label htmlFor="city" className="block text-sm font-medium text-secondary-700 mb-1">
              City <span className="text-danger-500">*</span>
            </label>
            <input
              id="city"
              type="text"
              {...register('city', {
                required: 'City is required',
                validate: (value) => validateLength(value, 100, 'City'),
              })}
              className={`w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent transition ${
                errors.city ? 'border-danger-500' : 'border-gray-300'
              }`}
              placeholder="San Francisco"
            />
            {errors.city && (
              <p className="mt-1 text-sm text-danger-600">{errors.city.message}</p>
            )}
          </div>

          <div>
            <label htmlFor="postal_code" className="block text-sm font-medium text-secondary-700 mb-1">
              Postal Code <span className="text-secondary-400">(optional)</span>
            </label>
            <input
              id="postal_code"
              type="text"
              {...register('postal_code', {
                validate: (value) => validateLength(value, 20, 'Postal code'),
              })}
              className={`w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent transition ${
                errors.postal_code ? 'border-danger-500' : 'border-gray-300'
              }`}
              placeholder="94102"
            />
            {errors.postal_code && (
              <p className="mt-1 text-sm text-danger-600">{errors.postal_code.message}</p>
            )}
          </div>
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
        </div>

        {/* Location Manager */}
        <div>
          <label htmlFor="location_manager" className="block text-sm font-medium text-secondary-700 mb-1">
            Location Manager <span className="text-secondary-400">(optional)</span>
          </label>
          <input
            id="location_manager"
            type="text"
            {...register('location_manager', {
              validate: (value) => validateLength(value, 255, 'Location manager'),
            })}
            className={`w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent transition ${
              errors.location_manager ? 'border-danger-500' : 'border-gray-300'
            }`}
            placeholder="John Doe"
          />
          {errors.location_manager && (
            <p className="mt-1 text-sm text-danger-600">{errors.location_manager.message}</p>
          )}
        </div>

        {/* Latitude & Longitude (Row) */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label htmlFor="latitude" className="block text-sm font-medium text-secondary-700 mb-1">
              Latitude <span className="text-secondary-400">(optional)</span>
            </label>
            <input
              id="latitude"
              type="number"
              step="any"
              {...register('latitude', {
                validate: validateLatitude,
              })}
              className={`w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent transition ${
                errors.latitude ? 'border-danger-500' : 'border-gray-300'
              }`}
              placeholder="37.7749"
            />
            {errors.latitude && (
              <p className="mt-1 text-sm text-danger-600">{errors.latitude.message}</p>
            )}
            <p className="mt-1 text-xs text-secondary-500">Range: -90 to 90</p>
          </div>

          <div>
            <label htmlFor="longitude" className="block text-sm font-medium text-secondary-700 mb-1">
              Longitude <span className="text-secondary-400">(optional)</span>
            </label>
            <input
              id="longitude"
              type="number"
              step="any"
              {...register('longitude', {
                validate: validateLongitude,
              })}
              className={`w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent transition ${
                errors.longitude ? 'border-danger-500' : 'border-gray-300'
              }`}
              placeholder="-122.4194"
            />
            {errors.longitude && (
              <p className="mt-1 text-sm text-danger-600">{errors.longitude.message}</p>
            )}
            <p className="mt-1 text-xs text-secondary-500">Range: -180 to 180</p>
          </div>
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
            {isEdit ? 'Update Location' : 'Create Location'}
          </Button>
        </div>
      </form>
    </Modal>
  );
};

export default LocationFormModal;
