import { PencilIcon, TrashIcon } from '@heroicons/react/24/outline';

/**
 * Store Table Component for Desktop View
 */
const StoreTable = ({ stores, onEdit, onDelete, onRowClick }) => {
  return (
    <div className="bg-white rounded-xl shadow-card overflow-hidden">
      <div className="overflow-x-auto">
        <table className="w-full">
          <thead className="bg-gray-50 border-b border-gray-200">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-secondary-500 uppercase tracking-wider">
                Name
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-secondary-500 uppercase tracking-wider">
                Description
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-secondary-500 uppercase tracking-wider">
                Phone
              </th>
              <th className="px-6 py-3 text-right text-xs font-medium text-secondary-500 uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {stores.map((store) => (
              <tr
                key={store.store_id}
                className="hover:bg-gray-50 transition-colors cursor-pointer"
                onClick={() => onRowClick(store)}
              >
                <td className="px-6 py-4 whitespace-nowrap">
                  <div className="text-sm font-medium text-secondary-900">
                    {store.name}
                  </div>
                </td>
                <td className="px-6 py-4">
                  <div className="text-sm text-secondary-600 line-clamp-2 max-w-md">
                    {store.description}
                  </div>
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <div className="text-sm text-secondary-600">{store.phone}</div>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                  <div className="flex justify-end gap-2">
                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        onEdit(store);
                      }}
                      className="p-2 text-primary-600 hover:bg-primary-50 rounded-lg transition-colors"
                      aria-label={`Edit ${store.name}`}
                    >
                      <PencilIcon className="h-5 w-5" />
                    </button>
                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        onDelete(store);
                      }}
                      className="p-2 text-danger-600 hover:bg-danger-50 rounded-lg transition-colors"
                      aria-label={`Delete ${store.name}`}
                    >
                      <TrashIcon className="h-5 w-5" />
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default StoreTable;
