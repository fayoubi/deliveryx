import { useState } from 'react';
import { PencilIcon, TrashIcon, ChevronDownIcon, ChevronRightIcon, PlusIcon } from '@heroicons/react/24/outline';
import { menusAPI } from '../services/api';
import toast from 'react-hot-toast';
import MenuView from './MenuView';

/**
 * Location Table Component for Desktop View
 */
const LocationTable = ({ locations, onEdit, onDelete, onLocationUpdated }) => {
  const [expandedMenus, setExpandedMenus] = useState(new Set());
  const [loadingMenus, setLoadingMenus] = useState(new Map());
  const [menus, setMenus] = useState(new Map());
  const [menuErrors, setMenuErrors] = useState(new Map());
  const [creatingMenu, setCreatingMenu] = useState(null);

  const toggleMenu = async (locationId, menuId) => {
    const newExpanded = new Set(expandedMenus);

    if (newExpanded.has(locationId)) {
      // Collapse
      newExpanded.delete(locationId);
      setExpandedMenus(newExpanded);
      return;
    }

    // Expand
    newExpanded.add(locationId);
    setExpandedMenus(newExpanded);

    // Fetch menu if not already loaded
    if (!menus.has(menuId)) {
      const newLoadingMenus = new Map(loadingMenus);
      newLoadingMenus.set(menuId, true);
      setLoadingMenus(newLoadingMenus);

      const newMenuErrors = new Map(menuErrors);
      newMenuErrors.delete(menuId);
      setMenuErrors(newMenuErrors);

      try {
        const menuData = await menusAPI.getComplete(menuId);
        const newMenus = new Map(menus);
        newMenus.set(menuId, menuData);
        setMenus(newMenus);
      } catch (error) {
        const newMenuErrors = new Map(menuErrors);
        newMenuErrors.set(menuId, error.message || 'Failed to load menu');
        setMenuErrors(newMenuErrors);
      } finally {
        const newLoadingMenus = new Map(loadingMenus);
        newLoadingMenus.delete(menuId);
        setLoadingMenus(newLoadingMenus);
      }
    }
  };

  const handleCreateMenu = async (location, e) => {
    e.stopPropagation();
    setCreatingMenu(location.location_id);

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
      setCreatingMenu(null);
    }
  };

  return (
    <div className="bg-white rounded-xl shadow-card overflow-hidden">
      <div className="overflow-x-auto">
        <table className="w-full">
          <thead className="bg-gray-50 border-b border-gray-200">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-secondary-500 uppercase tracking-wider">
                City
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-secondary-500 uppercase tracking-wider">
                Address
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-secondary-500 uppercase tracking-wider">
                Phone
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-secondary-500 uppercase tracking-wider">
                Manager
              </th>
              <th className="px-6 py-3 text-right text-xs font-medium text-secondary-500 uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {locations.map((location) => {
              const hasMenu = location.menu && location.menu.menu_id;
              const isExpanded = expandedMenus.has(location.location_id);
              const menuLoading = loadingMenus.get(location.menu?.menu_id);
              const menuError = menuErrors.get(location.menu?.menu_id);
              const menuData = menus.get(location.menu?.menu_id);

              return (
                <>
                  <tr
                    key={location.location_id}
                    className="hover:bg-gray-50 transition-colors"
                  >
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm font-medium text-secondary-900">
                        {location.city}
                      </div>
                      {location.postal_code && (
                        <div className="text-xs text-secondary-500">
                          {location.postal_code}
                        </div>
                      )}
                    </td>
                    <td className="px-6 py-4">
                      <div className="text-sm text-secondary-600 max-w-xs">
                        {location.address}
                      </div>
                      {(location.latitude || location.longitude) && (
                        <div className="text-xs text-secondary-400 mt-1">
                          {location.latitude?.toFixed(4)}, {location.longitude?.toFixed(4)}
                        </div>
                      )}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm text-secondary-600">{location.phone}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm text-secondary-600">
                        {location.location_manager || '—'}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                      <div className="flex justify-end gap-2">
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
                        {hasMenu ? (
                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              toggleMenu(location.location_id, location.menu.menu_id);
                            }}
                            className="p-2 text-secondary-600 hover:bg-secondary-50 rounded-lg transition-colors flex items-center gap-1"
                            aria-label={`${isExpanded ? 'Hide' : 'View'} menu for ${location.city}`}
                          >
                            {isExpanded ? (
                              <ChevronDownIcon className="h-5 w-5" />
                            ) : (
                              <ChevronRightIcon className="h-5 w-5" />
                            )}
                            <span className="text-sm">Menu</span>
                          </button>
                        ) : (
                          <button
                            onClick={(e) => handleCreateMenu(location, e)}
                            disabled={creatingMenu === location.location_id}
                            className="p-2 text-primary-600 hover:bg-primary-50 rounded-lg transition-colors flex items-center gap-1 disabled:opacity-50"
                            aria-label={`Create menu for ${location.city}`}
                          >
                            <PlusIcon className="h-5 w-5" />
                            <span className="text-sm">
                              {creatingMenu === location.location_id ? 'Creating...' : 'Create Menu'}
                            </span>
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                  {isExpanded && hasMenu && (
                    <tr key={`menu-${location.location_id}`}>
                      <td colSpan="5" className="px-6 py-4 bg-gray-50">
                        <MenuView
                          menu={menuData}
                          loading={menuLoading}
                          error={menuError}
                        />
                      </td>
                    </tr>
                  )}
                </>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default LocationTable;
