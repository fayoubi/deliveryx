//
//  Product.swift
//  DeliveryXOApp
//
//  Created on 2025-10-21.
//

import Foundation

/// Represents a product in the store's catalog
struct Product: Codable, Identifiable {
    let id: String
    let storeId: String
    let name: String
    let description: String?
    let basePrice: Double
    let imageUrl: String?
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case storeId = "store_id"
        case name
        case description
        case basePrice = "base_price"
        case imageUrl = "image_url"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/// Represents a product as it appears in a menu with collection info
struct ProductInMenu: Codable, Identifiable {
    let id: String
    let storeId: String
    let name: String
    let description: String?
    let basePrice: Double
    let imageUrl: String?
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    let menuProductId: String
    let collectionId: String
    let displayOrder: Int
    let isAvailable: Bool
    let menuProductCreatedAt: Date
    let menuProductUpdatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case storeId = "store_id"
        case name
        case description
        case basePrice = "base_price"
        case imageUrl = "image_url"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case menuProductId = "menu_product_id"
        case collectionId = "collection_id"
        case displayOrder = "display_order"
        case isAvailable = "is_available"
        case menuProductCreatedAt = "menu_product_created_at"
        case menuProductUpdatedAt = "menu_product_updated_at"
    }
}

/// Request model for creating a new product
struct CreateProductRequest: Codable {
    let name: String
    let description: String?
    let basePrice: Double
    let imageUrl: String?
    let isActive: Bool?

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case basePrice = "base_price"
        case imageUrl = "image_url"
        case isActive = "is_active"
    }
}

/// Request model for adding a product to a menu collection
struct AddProductToMenuRequest: Codable {
    let productId: String
    let displayOrder: Int?
    let isAvailable: Bool?

    enum CodingKeys: String, CodingKey {
        case productId = "product_id"
        case displayOrder = "display_order"
        case isAvailable = "is_available"
    }
}

/// Request model for toggling product availability in menu
struct ToggleAvailabilityRequest: Codable {
    let isAvailable: Bool

    enum CodingKeys: String, CodingKey {
        case isAvailable = "is_available"
    }
}
