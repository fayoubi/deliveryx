//
//  Menu.swift
//  DeliveryXOApp
//
//  Created on 2025-10-21.
//

import Foundation

/// Represents the status of a menu (draft or published)
enum MenuStatus: String, Codable {
    case draft = "DRAFT"
    case published = "PUBLISHED"
}

/// Represents a menu for a location
struct Menu: Codable, Identifiable {
    let id: String
    let locationId: String
    let name: String
    let description: String?
    let status: MenuStatus
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id = "menu_id"
        case locationId = "location_id"
        case name
        case description
        case status
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/// Response model for menu status update
struct MenuStatusResponse: Codable {
    let id: String
    let status: MenuStatus
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case status
        case updatedAt = "updated_at"
    }
}

/// Complete menu with all collections and products
struct CompleteMenu: Codable, Identifiable {
    let id: String
    let locationId: String
    let name: String
    let description: String?
    let status: MenuStatus
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    let collections: [CollectionWithProducts]

    enum CodingKeys: String, CodingKey {
        case id = "menu_id"
        case locationId = "location_id"
        case name
        case description
        case status
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case collections
    }
}

/// Generic message response
struct MessageResponse: Codable {
    let message: String
}
