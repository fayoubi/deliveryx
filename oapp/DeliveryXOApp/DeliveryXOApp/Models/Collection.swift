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
    let position: Int?
    let imageUrl: String?
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id = "collection_id"
        case menuId = "menu_id"
        case name
        case position
        case imageUrl = "image_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/// Collection with its products included
struct CollectionWithProducts: Codable, Identifiable {
    let id: String
    let menuId: String
    let name: CollectionName
    let position: Int?
    let imageUrl: String?
    let createdAt: Date
    let updatedAt: Date
    let products: [ProductInMenu]

    enum CodingKeys: String, CodingKey {
        case id = "collection_id"
        case menuId = "menu_id"
        case name
        case position
        case imageUrl = "image_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case products
    }
}

/// Request model for creating a new collection
struct CreateCollectionRequest: Codable {
    let name: CollectionName
    let position: Int?
    let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case name
        case position
        case imageUrl = "image_url"
    }
}
