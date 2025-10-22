//
//  RestaurantService.swift
//  DeliveryXOApp
//
//  Created on 2025-10-21.
//

import Foundation

/// Service for managing stores and locations
class RestaurantService {

    // MARK: - Singleton

    /// Shared instance for singleton access
    static let shared = RestaurantService()

    // MARK: - Properties

    /// API client for making requests
    private let apiClient: APIClient

    // MARK: - Initialization

    /// Initializes the restaurant service
    /// - Parameter apiClient: The API client to use (defaults to APIClient.shared)
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    // MARK: - Store Methods

    /// Creates a new store
    /// - Parameters:
    ///   - request: The store creation request containing store details
    ///   - completion: Completion handler with Result containing the created Store or an error
    func createStore(
        request: CreateStoreRequest,
        completion: @escaping (Result<Store, Error>) -> Void
    ) {
        print("🔵 DEBUG: RestaurantService.createStore() called")
        print("  Request: name=\(request.name), email=\(request.email)")
        print("  API URL: \(apiClient.baseURL)/stores")
        apiClient.post("/stores", body: request, completion: completion)
    }

    // MARK: - Location Methods

    /// Creates a new location for a store
    /// - Parameters:
    ///   - storeID: The ID of the store to create the location for
    ///   - request: The location creation request containing location details
    ///   - completion: Completion handler with Result containing the created Location or an error
    func createLocation(
        storeID: String,
        request: CreateLocationRequest,
        completion: @escaping (Result<Location, Error>) -> Void
    ) {
        let endpoint = "/stores/\(storeID)/locations"
        apiClient.post(endpoint, body: request, completion: completion)
    }

    /// Retrieves a location with its operating hours
    /// - Parameters:
    ///   - locationID: The ID of the location to retrieve
    ///   - completion: Completion handler with Result containing the LocationWithHours or an error
    func getLocation(
        locationID: String,
        completion: @escaping (Result<LocationWithHours, Error>) -> Void
    ) {
        let endpoint = "/locations/\(locationID)"
        apiClient.get(endpoint, completion: completion)
    }

    // MARK: - Operating Hours Methods

    /// Sets the operating hours for a location
    /// - Parameters:
    ///   - locationID: The ID of the location
    ///   - hours: Array of operating hour inputs for each day
    ///   - completion: Completion handler with Result containing the created OperatingHours or an error
    func setOperatingHours(
        locationID: String,
        hours: [OperatingHourInput],
        completion: @escaping (Result<[OperatingHour], Error>) -> Void
    ) {
        let endpoint = "/locations/\(locationID)/operating-hours"

        struct OperatingHoursRequest: Codable {
            let operatingHours: [OperatingHourInput]

            enum CodingKeys: String, CodingKey {
                case operatingHours = "operating_hours"
            }
        }

        let request = OperatingHoursRequest(operatingHours: hours)
        apiClient.post(endpoint, body: request, completion: completion)
    }
}
