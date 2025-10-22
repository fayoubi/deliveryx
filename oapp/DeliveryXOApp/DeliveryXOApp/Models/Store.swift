//
//  Store.swift
//  DeliveryXOApp
//
//  Created on 2025-10-21.
//

import Foundation

/// Represents a store/restaurant in the system
struct Store: Codable, Identifiable {
    let id: String
    let name: String
    let email: String?
    let phone: String?
    let description: String?
    let logoUrl: String?
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id = "store_id"
        case name
        case email
        case phone
        case description
        case logoUrl = "logo_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/// Request model for creating a new store
struct CreateStoreRequest: Codable {
    let name: String
    let email: String
    let phone: String?
    let description: String?
    let logoUrl: String?

    enum CodingKeys: String, CodingKey {
        case name
        case email
        case phone
        case description
        case logoUrl = "logo_url"
    }
}
