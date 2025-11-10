import { useState } from 'react';
import { PencilIcon, TrashIcon, MapPinIcon, PhoneIcon, UserIcon, ChevronDownIcon, ChevronRightIcon, PlusIcon } from '@heroicons/react/24/outline';
import { menusAPI } from '../services/api';
import toast from 'react-hot-toast';
import MenuView from './MenuView';

/**
 * Location Card Component for Mobile View
 */
const LocationCard = ({ location, onEdit, onDelete, onLocationUpdated }) => {
  const [isMenuExpanded, setIsMenuExpanded] = useState(false);
  const [menuData, setMenuData] = useState(null);
  const [menuLoading, setMenuLoading] = useState(false);
  const [menuError, setMenuError] = useState(null);
  const [creatingMenu, setCreatingMenu] = useState(false);

  const hasMenu = location.menu && location.menu.menu_id;

  const toggleMenu = async () => {
    if (!hasMenu) return;

    if (isMenuExpanded) {
      setIsMenuExpanded(false);
      return;
    }

    setIsMenuExpanded(true);

    // Fetch menu if not already loaded
    if (!menuData) {
      setMenuLoading(true);
      setMenuError(null);

      try {
        const data = await menusAPI.getComplete(location.menu.menu_id);
        setMenuData(data);
      } catch (error) {
        setMenuError(error.message || 'Failed to load menu');
      } finally {
        setMenuLoading(false);
      }
    }
  };

  const handleCreateMenu = async () => {
    setCreatingMenu(true);

    try {
      const newMenu = await menusAPI.create(location.location_id);
      toast.success('Menu created successfully');

      // Notify parent to refresh locations
      if (onLocationUpdated) {
        onLocationUpdated();
      }
    } catch (error) {
      toast.error(error.message || 'Failed to create menu');
    } finally {
      setCreatingMenu(false);
    }
  };

  return (
    <div className="bg-white rounded-xl shadow-card hover:shadow-card-hover transition-shadow p-4">
      <div className="flex justify-between items-start mb-3">
        <div className="flex-1">
          <h3 className="text-lg font-semibold text-secondary-900 flex items-center gap-2">
            <MapPinIcon className="h-5 w-5 text-primary-500" />
            {location.city}
          </h3>
        </div>
        <div className="flex gap-2 ml-2">
          <button
            onClick={() => onEdit(location)}
            className="p-2 text-primary-600 hover:bg-primary-50 rounded-lg transition-colors"
            aria-label={`Edit location in ${location.city}`}
          >
            <PencilIcon className="h-5 w-5" />
          </button>
          <button
            onClick={() => onDelete(location)}
            className="p-2 text-danger-600 hover:bg-danger-50 rounded-lg transition-colors"
            aria-label={`Delete location in ${location.city}`}
          >
            <TrashIcon className="h-5 w-5" />
          </button>
        </div>
      </div>

      <div className="space-y-2">
        <p className="text-sm text-secondary-700">{location.address}</p>

        {location.postal_code && (
          <p className="text-sm text-secondary-600">Postal Code: {location.postal_code}</p>
        )}

        <div className="flex items-center text-sm text-secondary-600">
          <PhoneIcon className="h-4 w-4 mr-1" />
          {location.phone}
        </div>

        {location.location_manager && (
          <div className="flex items-center text-sm text-secondary-600">
            <UserIcon className="h-4 w-4 mr-1" />
            {location.location_manager}
          </div>
        )}

        {(location.latitude || location.longitude) && (
          <p className="text-xs text-secondary-500">
            Coordinates: {location.latitude?.toFixed(6)}, {location.longitude?.toFixed(6)}
          </p>
        )}
      </div>

      {/* Menu Actions */}
      <div className="mt-4 pt-3 border-t border-gray-200">
        {hasMenu ? (
          <button
            onClick={toggleMenu}
            className="w-full px-4 py-2 text-secondary-700 hover:bg-secondary-50 rounded-lg transition-colors flex items-center justify-center gap-2"
          >
            {isMenuExpanded ? (
              <ChevronDownIcon className="h-5 w-5" />
            ) : (
              <ChevronRightIcon className="h-5 w-5" />
            )}
            <span className="font-medium">{isMenuExpanded ? 'Hide Menu' : 'View Menu'}</span>
          </button>
        ) : (
          <button
            onClick={handleCreateMenu}
            disabled={creatingMenu}
            className="w-full px-4 py-2 text-primary-600 hover:bg-primary-50 rounded-lg transition-colors flex items-center justify-center gap-2 disabled:opacity-50"
          >
            <PlusIcon className="h-5 w-5" />
            <span className="font-medium">{creatingMenu ? 'Creating...' : 'Create Menu'}</span>
          </button>
        )}
      </div>

      {/* Expanded Menu View */}
      {isMenuExpanded && hasMenu && (
        <div className="mt-4">
          <MenuView
            menu={menuData}
            loading={menuLoading}
            error={menuError}
          />
        </div>
      )}
    </div>
  );
};

export default LocationCard;
