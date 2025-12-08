import Foundation

/// Abstracts HTTP client implementation
public protocol APIClient: Sendable {
    /// Executes a network request and decodes the response
    ///
    /// - Parameter resource: The resource to fetch, including URL and parameters
    /// - Returns: Decoded response of type T
    /// - Throws: `APIError` if the request fails
    func execute<T: Decodable>(_ resource: Resource<T>) async throws -> T
}

public enum APIError: Error, Equatable {
    case decodingError
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case serverError
    case networkError
    case timeout
    case noInternetConnection
    case unknown
}

public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

/// API resource to be fetched
public struct Resource<T: Decodable>: Sendable {
    /// Base URL string
    public let url: String

    /// Optional query parameters (for GET requests)
    public let parameters: [String: String]?

    /// HTTP method (default: GET)
    public let method: HTTPMethod

    /// Optional request body (for POST/PUT requests)
    public let body: Data?

    /// Optional retry policy (overrides client's default if provided)
    public let retryPolicy: RetryPolicy?

    /// Creates a Resource with a valid URL string
    ///
    /// - Parameters:
    ///   - url: Must be a valid URL string. Invalid URLs will cause a precondition failure
    ///   - parameters: Optional query parameters (ignored for POST/PUT if body is provided)
    ///   - method: HTTP method (default: GET)
    ///   - body: Optional request body for POST/PUT requests
    ///   - retryPolicy: Optional retry policy (uses client's default if nil)
    public init(
        url: String,
        parameters: [String: String]? = nil,
        method: HTTPMethod = .get,
        body: Data? = nil,
        retryPolicy: RetryPolicy? = nil
    ) {
        precondition(URL(string: url) != nil, "Invalid URL string: \(url)")

        self.url = url
        self.parameters = parameters
        self.method = method
        self.body = body
        self.retryPolicy = retryPolicy
    }
}
