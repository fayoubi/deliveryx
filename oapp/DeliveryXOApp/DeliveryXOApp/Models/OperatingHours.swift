//
//  OperatingHours.swift
//  DeliveryXOApp
//
//  Created on 2025-10-21.
//

import Foundation

/// Represents days of the week for operating hours
enum DayOfWeek: String, Codable, CaseIterable {
    case monday = "MONDAY"
    case tuesday = "TUESDAY"
    case wednesday = "WEDNESDAY"
    case thursday = "THURSDAY"
    case friday = "FRIDAY"
    case saturday = "SATURDAY"
    case sunday = "SUNDAY"
}

/// Represents operating hours for a specific day
struct OperatingHour: Codable, Identifiable {
    let id: String
    let locationId: String
    let dayOfWeek: DayOfWeek
    let openTime: String  // Format: "HH:mm"
    let closeTime: String // Format: "HH:mm"
    let isClosed: Bool
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id = "operating_hour_id"
        case locationId = "location_id"
        case dayOfWeek = "day_of_week"
        case openTime = "open_time"
        case closeTime = "close_time"
        case isClosed = "is_closed"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/// Input model for creating or updating operating hours
struct OperatingHourInput: Codable {
    let dayOfWeek: DayOfWeek
    let openTime: String?  // Format: "HH:mm", optional if isClosed is true
    let closeTime: String? // Format: "HH:mm", optional if isClosed is true
    let isClosed: Bool

    enum CodingKeys: String, CodingKey {
        case dayOfWeek = "day_of_week"
        case openTime = "open_time"
        case closeTime = "close_time"
        case isClosed = "is_closed"
    }
}
