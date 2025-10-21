//
//  MenuService.swift
//  DeliveryXOApp
//
//  Created on 2025-10-21.
//

import Foundation

/// Service for managing menus, collections, and products
class MenuService {

    // MARK: - Singleton

    /// Shared instance for singleton access
    static let shared = MenuService()

    // MARK: - Properties

    /// API client for making requests
    private let apiClient: APIClient

    // MARK: - Initialization

    /// Initializes the menu service
    /// - Parameter apiClient: The API client to use (defaults to APIClient.shared)
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    // MARK: - Menu Methods

    /// Creates a new draft menu for a location
    /// - Parameters:
    ///   - locationID: The ID of the location to create the menu for
    ///   - completion: Completion handler with Result containing the created Menu or an error
    func createDraftMenu(
        locationID: String,
        completion: @escaping (Result<Menu, Error>) -> Void
    ) {
        let endpoint = "/locations/\(locationID)/menus"
        apiClient.post(endpoint, completion: completion)
    }

    /// Retrieves a complete menu with all collections and products
    /// - Parameters:
    ///   - menuID: The ID of the menu to retrieve
    ///   - completion: Completion handler with Result containing the CompleteMenu or an error
    func getMenu(
        menuID: String,
        completion: @escaping (Result<CompleteMenu, Error>) -> Void
    ) {
        let endpoint = "/menus/\(menuID)"
        apiClient.get(endpoint, completion: completion)
    }

    /// Retrieves the status of a menu
    /// - Parameters:
    ///   - menuID: The ID of the menu
    ///   - completion: Completion handler with Result containing the MenuStatusResponse or an error
    func getMenuStatus(
        menuID: String,
        completion: @escaping (Result<MenuStatusResponse, Error>) -> Void
    ) {
        let endpoint = "/menus/\(menuID)/status"
        apiClient.get(endpoint, completion: completion)
    }

    /// Submits a menu for publishing
    /// - Parameters:
    ///   - menuID: The ID of the menu to submit
    ///   - completion: Completion handler with Result containing a MessageResponse or an error
    func submitMenu(
        menuID: String,
        completion: @escaping (Result<MessageResponse, Error>) -> Void
    ) {
        let endpoint = "/menus/\(menuID)/submit"
        apiClient.post(endpoint, completion: completion)
    }

    // MARK: - Collection Methods

    /// Creates a new collection in a menu
    /// - Parameters:
    ///   - menuID: The ID of the menu to add the collection to
    ///   - request: The collection creation request containing collection details
    ///   - completion: Completion handler with Result containing the created Collection or an error
    func createCollection(
        menuID: String,
        request: CreateCollectionRequest,
        completion: @escaping (Result<Collection, Error>) -> Void
    ) {
        let endpoint = "/menus/\(menuID)/collections"
        apiClient.post(endpoint, body: request, completion: completion)
    }

    // MARK: - Product Methods

    /// Creates a new product in a location's catalog
    /// - Parameters:
    ///   - locationID: The ID of the location (used to get the store ID)
    ///   - request: The product creation request containing product details
    ///   - completion: Completion handler with Result containing the created Product or an error
    /// - Note: This requires the store ID. In a real app, you might want to fetch the location
    ///         first to get the store ID, or pass the store ID directly.
    func createProduct(
        locationID: String,
        request: CreateProductRequest,
        completion: @escaping (Result<Product, Error>) -> Void
    ) {
        // First, get the location to obtain the store ID
        RestaurantService.shared.getLocation(locationID: locationID) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let location):
                let endpoint = "/stores/\(location.storeId)/products"
                self.apiClient.post(endpoint, body: request, completion: completion)

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// Retrieves a product by ID
    /// - Parameters:
    ///   - productID: The ID of the product to retrieve
    ///   - completion: Completion handler with Result containing the Product or an error
    func getProduct(
        productID: String,
        completion: @escaping (Result<Product, Error>) -> Void
    ) {
        let endpoint = "/products/\(productID)"
        apiClient.get(endpoint, completion: completion)
    }

    /// Adds a product to a menu collection
    /// - Parameters:
    ///   - menuID: The ID of the menu
    ///   - collectionID: The ID of the collection to add the product to
    ///   - request: The request containing product and display information
    ///   - completion: Completion handler with Result containing a MessageResponse or an error
    func addProductToMenu(
        menuID: String,
        collectionID: String,
        request: AddProductToMenuRequest,
        completion: @escaping (Result<MessageResponse, Error>) -> Void
    ) {
        let endpoint = "/menus/\(menuID)/collections/\(collectionID)/products"
        apiClient.post(endpoint, body: request, completion: completion)
    }

    /// Toggles the availability of a product in a menu
    /// - Parameters:
    ///   - productID: The ID of the menu product to toggle
    ///   - isAvailable: Whether the product should be available
    ///   - completion: Completion handler with Result containing a MessageResponse or an error
    func toggleProductAvailability(
        productID: String,
        isAvailable: Bool,
        completion: @escaping (Result<MessageResponse, Error>) -> Void
    ) {
        let endpoint = "/menu-products/\(productID)/toggle-availability"
        let request = ToggleAvailabilityRequest(isAvailable: isAvailable)
        apiClient.put(endpoint, body: request, completion: completion)
    }
}
