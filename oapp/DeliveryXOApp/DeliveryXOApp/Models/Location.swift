//
//  Location.swift
//  DeliveryXOApp
//
//  Created on 2025-10-21.
//

import Foundation

/// Represents a physical location/branch of a store
struct Location: Codable, Identifiable {
    let id: String
    let storeId: String
    let name: String?
    let address: String
    let city: String
    let state: String?
    let postalCode: String?
    let country: String?
    let latitude: Double?
    let longitude: Double?
    let phone: String?
    let isActive: Bool?
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id = "location_id"
        case storeId = "store_id"
        case name
        case address
        case city
        case state
        case postalCode = "postal_code"
        case country
        case latitude
        case longitude
        case phone
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/// Request model for creating a new location
struct CreateLocationRequest: Codable {
    let name: String
    let address: String
    let city: String
    let state: String?
    let postalCode: String?
    let country: String
    let latitude: Double?
    let longitude: Double?
    let phone: String?
    let isActive: Bool?
    let operatingHours: [OperatingHourInput]?

    enum CodingKeys: String, CodingKey {
        case name
        case address
        case city
        case state
        case postalCode = "postal_code"
        case country
        case latitude
        case longitude
        case phone
        case isActive = "is_active"
        case operatingHours = "operating_hours"
    }
}

/// Location with operating hours included
struct LocationWithHours: Codable, Identifiable {
    let id: String
    let storeId: String
    let name: String?
    let address: String
    let city: String
    let state: String?
    let postalCode: String?
    let country: String?
    let latitude: Double?
    let longitude: Double?
    let phone: String?
    let isActive: Bool?
    let createdAt: Date
    let updatedAt: Date
    let operatingHours: [OperatingHour]

    enum CodingKeys: String, CodingKey {
        case id = "location_id"
        case storeId = "store_id"
        case name
        case address
        case city
        case state
        case postalCode = "postal_code"
        case country
        case latitude
        case longitude
        case phone
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case operatingHours = "operating_hours"
    }
}
