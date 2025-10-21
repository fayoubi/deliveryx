//
//  APIClient.swift
//  DeliveryXOApp
//
//  Created on 2025-10-21.
//

import Foundation
import Alamofire

/// Custom errors for API operations
enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case encodingFailed
    case serverError(statusCode: Int, message: String?)
    case unknownError

    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .encodingFailed:
            return "Failed to encode request body"
        case .serverError(let statusCode, let message):
            return "Server error (\(statusCode)): \(message ?? "Unknown error")"
        case .unknownError:
            return "Unknown error occurred"
        }
    }
}

/// Generic HTTP client for making API requests
class APIClient {

    // MARK: - Singleton

    /// Shared instance for singleton access
    static let shared = APIClient()

    // MARK: - Properties

    /// Base URL for all API requests
    let baseURL: String

    /// Alamofire session manager
    private let session: Session

    /// JSON decoder with ISO8601 date decoding strategy
    private let decoder: JSONDecoder

    /// JSON encoder with ISO8601 date encoding strategy
    private let encoder: JSONEncoder

    // MARK: - Initialization

    /// Initializes the API client with default configuration
    /// - Parameter baseURL: The base URL for API requests (defaults to Constants.API.baseURL)
    init(baseURL: String = Constants.API.baseURL) {
        self.baseURL = baseURL

        // Configure session
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = Constants.API.timeoutInterval
        configuration.timeoutIntervalForResource = Constants.API.timeoutInterval
        self.session = Session(configuration: configuration)

        // Configure decoder with ISO8601 date strategy
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601

        // Configure encoder with ISO8601 date strategy
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
    }

    // MARK: - Request Methods

    /// Performs a GET request
    /// - Parameters:
    ///   - endpoint: The API endpoint path
    ///   - parameters: Optional query parameters
    ///   - completion: Completion handler with Result containing decoded response or error
    func get<T: Decodable>(
        _ endpoint: String,
        parameters: Parameters? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        request(
            endpoint,
            method: .get,
            parameters: parameters,
            encoding: URLEncoding.default,
            completion: completion
        )
    }

    /// Performs a POST request
    /// - Parameters:
    ///   - endpoint: The API endpoint path
    ///   - body: Optional request body (will be JSON encoded)
    ///   - completion: Completion handler with Result containing decoded response or error
    func post<T: Decodable, B: Encodable>(
        _ endpoint: String,
        body: B? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        request(
            endpoint,
            method: .post,
            body: body,
            completion: completion
        )
    }

    /// Performs a PUT request
    /// - Parameters:
    ///   - endpoint: The API endpoint path
    ///   - body: Optional request body (will be JSON encoded)
    ///   - completion: Completion handler with Result containing decoded response or error
    func put<T: Decodable, B: Encodable>(
        _ endpoint: String,
        body: B,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        requestWithBody(
            endpoint,
            method: .put,
            body: body,
            completion: completion
        )
    }

    /// Performs a DELETE request
    /// - Parameters:
    ///   - endpoint: The API endpoint path
    ///   - parameters: Optional query parameters
    ///   - completion: Completion handler with Result containing decoded response or error
    func delete<T: Decodable>(
        _ endpoint: String,
        parameters: Parameters? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        requestWithoutBody(
            endpoint,
            method: .delete,
            parameters: parameters,
            encoding: URLEncoding.default,
            completion: completion
        )
    }

    // MARK: - Private Methods

    /// Generic request method for requests WITH body
    /// - Parameters:
    ///   - endpoint: The API endpoint path
    ///   - method: HTTP method
    ///   - body: Request body (will be JSON encoded)
    ///   - completion: Completion handler with Result
    private func requestWithBody<T: Decodable, B: Encodable>(
        _ endpoint: String,
        method: HTTPMethod,
        body: B,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        // Construct full URL
        let urlString = "\(baseURL)\(endpoint)"

        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }

        // Encode body to JSON
        guard let bodyData = try? encoder.encode(body),
              let bodyDict = try? JSONSerialization.jsonObject(with: bodyData) as? [String: Any] else {
            completion(.failure(APIError.encodingFailed))
            return
        }

        // Make request
        AF.request(
            url,
            method: method,
            parameters: bodyDict,
            encoding: JSONEncoding.default,
            headers: nil
        )
        .validate()
        .responseDecodable(of: T.self, decoder: decoder) { response in
            switch response.result {
            case .success(let value):
                completion(.success(value))
            case .failure(let error):
                completion(.failure(self.mapAFError(error)))
            }
        }
    }

    /// Generic request method for requests WITHOUT body
    /// - Parameters:
    ///   - endpoint: The API endpoint path
    ///   - method: HTTP method
    ///   - parameters: Optional query parameters
    ///   - encoding: Parameter encoding strategy
    ///   - completion: Completion handler with Result
    private func requestWithoutBody<T: Decodable>(
        _ endpoint: String,
        method: HTTPMethod,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = JSONEncoding.default,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        // Construct full URL
        let urlString = "\(baseURL)\(endpoint)"

        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }

        // Make request
        AF.request(
            url,
            method: method,
            parameters: parameters,
            encoding: encoding,
            headers: nil
        )
        .validate()
        .responseDecodable(of: T.self, decoder: decoder) { response in
            switch response.result {
            case .success(let value):
                completion(.success(value))
            case .failure(let error):
                completion(.failure(self.mapAFError(error)))
            }
        }
    }

    /// Uploads data to a URL using PUT
    /// - Parameters:
    ///   - url: The upload URL
    ///   - data: The data to upload
    ///   - contentType: The content type of the data
    ///   - completion: Completion handler with Result
    func upload(
        to url: URL,
        data: Data,
        contentType: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        var request = URLRequest(url: url)
        request.method = .put
        request.headers = HTTPHeaders([
            "Content-Type": contentType,
            "Content-Length": "\(data.count)"
        ])

        session.upload(data, with: request)
            .validate()
            .response { response in
                switch response.result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    if let statusCode = response.response?.statusCode {
                        completion(.failure(APIError.serverError(statusCode: statusCode, message: error.localizedDescription)))
                    } else {
                        completion(.failure(APIError.networkError(error)))
                    }
                }
            }
    }

    /// Maps Alamofire errors to APIError
    private func mapAFError(_ error: AFError) -> APIError {
        if let statusCode = error.responseCode {
            return .serverError(statusCode: statusCode, message: error.localizedDescription)
        } else {
            return .networkError(error)
        }
    }
}
