import { PencilIcon, TrashIcon } from '@heroicons/react/24/outline';

/**
 * Store Card Component for Mobile View
 */
const StoreCard = ({ store, onEdit, onDelete, onClick }) => {
  return (
    <div
      className="bg-white rounded-xl shadow-card hover:shadow-card-hover transition-shadow p-4 cursor-pointer"
      onClick={onClick}
    >
      <div className="flex justify-between items-start mb-3">
        <h3 className="text-lg font-semibold text-secondary-900 flex-1">
          {store.name}
        </h3>
        <div className="flex gap-2 ml-2">
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
      </div>

      <p className="text-sm text-secondary-600 mb-2 line-clamp-2">
        {store.description}
      </p>

      <div className="flex items-center text-sm text-secondary-500">
        <svg
          className="h-4 w-4 mr-1"
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
  );
};

export default StoreCard;
