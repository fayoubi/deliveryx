//
//  MediaService.swift
//  DeliveryXOApp
//
//  Created on 2025-10-21.
//

import Foundation
import UIKit

/// Response model for S3 upload URL generation
struct UploadURLResponse: Codable {
    let uploadUrl: String
    let fileUrl: String

    enum CodingKeys: String, CodingKey {
        case uploadUrl = "upload_url"
        case fileUrl = "file_url"
    }
}

/// Request model for generating upload URL
struct GenerateUploadURLRequest: Codable {
    let fileName: String
    let contentType: String
    let fileSize: Int64

    enum CodingKeys: String, CodingKey {
        case fileName = "file_name"
        case contentType = "content_type"
        case fileSize = "file_size"
    }
}

/// Service for handling media uploads (images) to S3
class MediaService {

    // MARK: - Singleton

    /// Shared instance for singleton access
    static let shared = MediaService()

    // MARK: - Properties

    /// API client for making requests
    private let apiClient: APIClient

    // MARK: - Initialization

    /// Initializes the media service
    /// - Parameter apiClient: The API client to use (defaults to APIClient.shared)
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    // MARK: - Upload URL Generation

    /// Generates a pre-signed S3 upload URL
    /// - Parameters:
    ///   - fileName: The name of the file to upload
    ///   - contentType: The MIME type of the file (e.g., "image/jpeg")
    ///   - fileSize: The size of the file in bytes
    ///   - completion: Completion handler with Result containing the UploadURLResponse or an error
    func generateUploadURL(
        fileName: String,
        contentType: String,
        fileSize: Int64,
        completion: @escaping (Result<UploadURLResponse, Error>) -> Void
    ) {
        let endpoint = "/media/generate-upload-url"
        let request = GenerateUploadURLRequest(
            fileName: fileName,
            contentType: contentType,
            fileSize: fileSize
        )
        apiClient.post(endpoint, body: request, completion: completion)
    }

    // MARK: - Upload Methods

    /// Uploads image data to a pre-signed S3 URL
    /// - Parameters:
    ///   - url: The pre-signed S3 upload URL
    ///   - imageData: The image data to upload
    ///   - contentType: The MIME type of the image
    ///   - completion: Completion handler with Result indicating success or error
    func uploadImage(
        to url: String,
        imageData: Data,
        contentType: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let uploadURL = URL(string: url) else {
            completion(.failure(APIError.invalidURL))
            return
        }

        apiClient.upload(
            to: uploadURL,
            data: imageData,
            contentType: contentType,
            completion: completion
        )
    }

    // MARK: - Convenience Methods

    /// Convenience method that combines URL generation and image upload
    /// - Parameters:
    ///   - imageData: The image data to upload
    ///   - fileName: The name of the file (without extension)
    ///   - completion: Completion handler with Result containing the final file URL or an error
    /// - Note: This method automatically determines content type and handles the entire upload process
    func uploadImageAndGetURL(
        imageData: Data,
        fileName: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        // Validate file size
        let fileSize = Int64(imageData.count)
        guard fileSize <= Constants.Media.maxImageSize else {
            completion(.failure(NSError(
                domain: "MediaService",
                code: 413,
                userInfo: [NSLocalizedDescriptionKey: "Image file size exceeds maximum allowed size"]
            )))
            return
        }

        // Determine content type from image data
        guard let contentType = contentType(for: imageData) else {
            completion(.failure(NSError(
                domain: "MediaService",
                code: 415,
                userInfo: [NSLocalizedDescriptionKey: "Unsupported image format"]
            )))
            return
        }

        // Add appropriate file extension
        let fileExtension = fileExtension(for: contentType)
        let fullFileName = "\(fileName).\(fileExtension)"

        // Step 1: Generate upload URL
        generateUploadURL(
            fileName: fullFileName,
            contentType: contentType,
            fileSize: fileSize
        ) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let urlResponse):
                // Step 2: Upload image to S3
                self.uploadImage(
                    to: urlResponse.uploadUrl,
                    imageData: imageData,
                    contentType: contentType
                ) { uploadResult in
                    switch uploadResult {
                    case .success:
                        // Return the final file URL
                        completion(.success(urlResponse.fileUrl))

                    case .failure(let error):
                        completion(.failure(error))
                    }
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// Convenience method to upload a UIImage
    /// - Parameters:
    ///   - image: The UIImage to upload
    ///   - fileName: The name of the file (without extension)
    ///   - compressionQuality: JPEG compression quality (0.0 to 1.0, defaults to 0.8)
    ///   - completion: Completion handler with Result containing the final file URL or an error
    func uploadImage(
        _ image: UIImage,
        fileName: String,
        compressionQuality: CGFloat = Constants.Media.imageCompressionQuality,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        // Convert UIImage to JPEG data
        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else {
            completion(.failure(NSError(
                domain: "MediaService",
                code: 500,
                userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to JPEG"]
            )))
            return
        }

        uploadImageAndGetURL(imageData: imageData, fileName: fileName, completion: completion)
    }

    // MARK: - Helper Methods

    /// Determines the content type of image data
    /// - Parameter data: The image data
    /// - Returns: The MIME type string, or nil if the format is not supported
    private func contentType(for data: Data) -> String? {
        guard data.count > 12 else { return nil }

        // Check for JPEG
        if data[0] == 0xFF && data[1] == 0xD8 && data[2] == 0xFF {
            return "image/jpeg"
        }

        // Check for PNG
        if data[0] == 0x89 && data[1] == 0x50 && data[2] == 0x4E && data[3] == 0x47 {
            return "image/png"
        }

        // Check for HEIC (simplified check)
        let heicHeader = Data([0x00, 0x00, 0x00])
        if data.prefix(3) == heicHeader {
            // Additional check for "ftyp" and "heic"
            if let range = data.range(of: "ftypheic".data(using: .ascii)!, in: 0..<min(32, data.count)) {
                if range.lowerBound < 32 {
                    return "image/heic"
                }
            }
        }

        return nil
    }

    /// Returns the file extension for a given content type
    /// - Parameter contentType: The MIME type
    /// - Returns: The file extension (without dot)
    private func fileExtension(for contentType: String) -> String {
        switch contentType {
        case "image/jpeg":
            return "jpg"
        case "image/png":
            return "png"
        case "image/heic":
            return "heic"
        default:
            return "jpg"
        }
    }
}
