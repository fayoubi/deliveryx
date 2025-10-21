//
//  Collection.swift
//  DeliveryXOApp
//
//  Created on 2025-10-21.
//

import Foundation

/// Predefined collection names/categories
enum CollectionName: String, Codable, CaseIterable {
    case pizzas = "Pizzas"
    case burgers = "Burgers"
    case sides = "Sides"
    case desserts = "Desserts"
    case drinks = "Drinks"
    case salads = "Salads"
    case breakfast = "Breakfast"
    case sandwiches = "Sandwiches"
    case pasta = "Pasta"
    case seafood = "Seafood"
}

/// Represents a collection/category in a menu
struct Collection: Codable, Identifiable {
    let id: String
    let menuId: String
    let name: CollectionName
    let description: String?
    let displayOrder: Int
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case menuId = "menu_id"
        case name
        case description
        case displayOrder = "display_order"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/// Collection with its products included
struct CollectionWithProducts: Codable, Identifiable {
    let id: String
    let menuId: String
    let name: CollectionName
    let description: String?
    let displayOrder: Int
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    let products: [ProductInMenu]

    enum CodingKeys: String, CodingKey {
        case id
        case menuId = "menu_id"
        case name
        case description
        case displayOrder = "display_order"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case products
    }
}

/// Request model for creating a new collection
struct CreateCollectionRequest: Codable {
    let name: CollectionName
    let description: String?
    let displayOrder: Int?
    let isActive: Bool?

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case displayOrder = "display_order"
        case isActive = "is_active"
    }
}
