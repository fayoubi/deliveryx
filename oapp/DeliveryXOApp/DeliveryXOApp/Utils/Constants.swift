//
//  Constants.swift
//  DeliveryXOApp
//
//  Created on 2025-10-21.
//

import Foundation

/// Application-wide constants
struct Constants {

    // MARK: - API Configuration

    struct API {
        /// Base URL for the API server (Traefik gateway on port 80)
        static let baseURL = "http://localhost/api/v1"

        /// Default request timeout in seconds
        static let timeoutInterval: TimeInterval = 30

        /// Maximum number of retry attempts
        static let maxRetries = 3
    }

    // MARK: - Validation

    struct Validation {
        /// Minimum name length
        static let minNameLength = 2

        /// Maximum name length
        static let maxNameLength = 100

        /// Maximum description length
        static let maxDescriptionLength = 500

        /// Email validation regex pattern
        static let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        /// Phone validation regex pattern (basic international format)
        static let phonePattern = "^[+]?[0-9]{10,15}$"

        /// Time format for operating hours (HH:mm)
        static let timeFormat = "HH:mm"

        /// Minimum price value
        static let minPrice: Double = 0.01

        /// Maximum price value
        static let maxPrice: Double = 999999.99
    }

    // MARK: - Media

    struct Media {
        /// Supported image content types
        static let supportedImageTypes = ["image/jpeg", "image/png", "image/heic"]

        /// Maximum image file size in bytes (5MB)
        static let maxImageSize: Int64 = 5 * 1024 * 1024

        /// Default image compression quality
        static let imageCompressionQuality: CGFloat = 0.8
    }

    // MARK: - UI

    struct UI {
        /// Default animation duration
        static let animationDuration: TimeInterval = 0.3

        /// Default corner radius
        static let cornerRadius: CGFloat = 8.0

        /// Default spacing
        static let defaultSpacing: CGFloat = 16.0
    }
}
