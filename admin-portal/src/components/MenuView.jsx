import { useState } from 'react';
import { ChevronDownIcon, ChevronRightIcon } from '@heroicons/react/24/outline';
import Spinner from './Spinner';

/**
 * MenuView Component
 * Displays menu with collections and products in accordion pattern
 */
const MenuView = ({ menu, loading = false, error = null }) => {
  // Track which collections are expanded (by index)
  const [expandedCollections, setExpandedCollections] = useState(new Set([0])); // First collection expanded by default

  const toggleCollection = (index) => {
    const newExpanded = new Set(expandedCollections);
    if (newExpanded.has(index)) {
      newExpanded.delete(index);
    } else {
      newExpanded.add(index);
    }
    setExpandedCollections(newExpanded);
  };

  // Transform backend data structure:
  // Backend returns collections->sections->product_ids and products as separate array
  // We need to merge them into collections with embedded products
  const transformCollections = (collections, products) => {
    if (!collections || !products) return [];

    // Create a map of product IDs to product objects for quick lookup
    const productMap = new Map();
    products.forEach(product => {
      productMap.set(product.id, product);
    });

    // Transform collections to have embedded products
    return collections.map(collection => {
      // Gather all product IDs from all sections in this collection
      const productIds = [];
      if (collection.sections) {
        collection.sections.forEach(section => {
          if (section.products) {
            productIds.push(...section.products);
          }
        });
      }

      // Map product IDs to actual product objects
      const productsForCollection = productIds
        .map(id => productMap.get(id))
        .filter(p => p != null); // Filter out any missing products

      return {
        ...collection,
        products: productsForCollection
      };
    });
  };

  // Status badge colors
  const statusColors = {
    draft: 'bg-gray-100 text-gray-700',
    pending_review: 'bg-yellow-100 text-yellow-700',
    approved: 'bg-green-100 text-green-700',
    rejected: 'bg-red-100 text-red-700',
  };

  const statusLabels = {
    draft: 'Draft',
    pending_review: 'Pending Review',
    approved: 'Approved',
    rejected: 'Rejected',
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center py-8">
        <Spinner size="md" />
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-red-50 text-red-700 px-4 py-3 rounded-lg text-sm">
        {error}
      </div>
    );
  }

  if (!menu) {
    return (
      <div className="text-secondary-600 text-sm py-4">
        No menu data available.
      </div>
    );
  }

  // Transform collections to include embedded products
  const transformedCollections = transformCollections(menu.collections, menu.products);
  const hasCollections = transformedCollections && transformedCollections.length > 0;

  return (
    <div className="bg-gray-50 rounded-lg p-4 space-y-4">
      {/* Menu Status Badge */}
      <div className="flex items-center gap-2">
        <span className="text-sm font-medium text-secondary-700">Status:</span>
        <span className={`px-3 py-1 rounded-full text-xs font-medium ${statusColors[menu.status] || 'bg-gray-100 text-gray-700'}`}>
          {statusLabels[menu.status] || menu.status}
        </span>
      </div>

      {/* Collections */}
      {!hasCollections ? (
        <div className="text-secondary-500 text-sm">
          No collections yet. Add collections to organize your menu items.
        </div>
      ) : (
        <div className="space-y-2">
          {transformedCollections.map((collection, index) => {
            const isExpanded = expandedCollections.has(index);
            const productsCount = collection.products?.length || 0;

            return (
              <div key={collection.name || index} className="bg-white rounded-lg border border-gray-200 overflow-hidden">
                {/* Collection Header */}
                <button
                  onClick={() => toggleCollection(index)}
                  className="w-full px-4 py-3 flex items-center justify-between hover:bg-gray-50 transition-colors"
                >
                  <div className="flex items-center gap-2">
                    {isExpanded ? (
                      <ChevronDownIcon className="h-5 w-5 text-secondary-600" />
                    ) : (
                      <ChevronRightIcon className="h-5 w-5 text-secondary-600" />
                    )}
                    <span className="font-medium text-secondary-900">
                      {collection.name}
                    </span>
                    <span className="text-sm text-secondary-500">
                      ({productsCount} {productsCount === 1 ? 'item' : 'items'})
                    </span>
                  </div>
                </button>

                {/* Collection Products */}
                {isExpanded && (
                  <div className="px-4 pb-4 space-y-3">
                    {productsCount === 0 ? (
                      <div className="text-secondary-500 text-sm pt-2">
                        No items in this section.
                      </div>
                    ) : (
                      collection.products.map((product) => (
                        <div key={product.id} className="border-l-2 border-primary-200 pl-4 py-2">
                          {/* Product Name and Price */}
                          <div className="flex items-start justify-between gap-2">
                            <div className="flex-1">
                              <span className="text-secondary-900 font-medium block">
                                {product.name}
                              </span>
                              {product.description && (
                                <span className="text-xs text-secondary-500 block mt-1">
                                  {product.description}
                                </span>
                              )}
                            </div>
                            <span className="text-primary-600 font-semibold whitespace-nowrap">
                              ${product.price.toFixed(2)}
                            </span>
                          </div>

                          {/* Product Availability */}
                          {!product.available && (
                            <div className="mt-2">
                              <span className="text-xs px-2 py-1 bg-red-100 text-red-700 rounded">
                                Unavailable
                              </span>
                            </div>
                          )}
                        </div>
                      ))
                    )}
                  </div>
                )}
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
};

export default MenuView;
