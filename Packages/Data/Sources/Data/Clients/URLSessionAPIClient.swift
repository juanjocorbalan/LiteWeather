import Foundation

public final class URLSessionAPIClient: APIClient {
    private let session: URLSession
    private let timeoutInterval: TimeInterval
    private let cachePolicy: NSURLRequest.CachePolicy
    private let defaultRetryPolicy: RetryPolicy

    public init(
        configuration: URLSessionConfiguration = .default,
        cachePolicy: NSURLRequest.CachePolicy = .reloadIgnoringLocalCacheData,
        timeoutInterval: TimeInterval = 30,
        retryPolicy: RetryPolicy = .default
    ) {
        self.session = URLSession(configuration: configuration)
        self.timeoutInterval = timeoutInterval
        self.cachePolicy = cachePolicy
        self.defaultRetryPolicy = retryPolicy
    }

    public func execute<T: Decodable>(_ resource: Resource<T>) async throws -> T {
        do {
            let data = try await requestWithRetry(resource, attempt: 0)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            if error is DecodingError {
                throw APIError.decodingError
            } else {
                throw error as? APIError ?? APIError.unknown
            }
        }
    }

    // MARK: - Private Methods

    /// Executes a request with retry logic based on the retry policy
    ///
    /// - Parameters:
    ///   - resource: The resource to fetch
    ///   - attempt: Current retry attempt (0-indexed)
    /// - Returns: Response data
    /// - Throws: APIError if request fails after all retries
    private func requestWithRetry<T: Decodable>(_ resource: Resource<T>, attempt: Int) async throws -> Data {
        do {
            return try await request(resource, retryOnUnauthorized: true)
        } catch let error as APIError {
            // Use resource's policy if provided, otherwise use client's default
            let policy = resource.retryPolicy ?? defaultRetryPolicy
            let shouldRetry = policy.shouldRetry(error)
            let canRetry = attempt < policy.maxAttempts

            if shouldRetry && canRetry {
                // Calculate delay with exponential backoff
                let delay = policy.delay(for: attempt)
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))

                // Recursive retry with incremented attempt
                return try await requestWithRetry(resource, attempt: attempt + 1)
            }

            throw error
        }
    }

    private func request<T: Decodable>(_ resource: Resource<T>, retryOnUnauthorized: Bool) async throws -> Data {
        // Build URL (with query params only if no body is provided)
        let url: URL
        if resource.body != nil || resource.method != .get {
            // For POST/PUT/DELETE, use base URL without query params
            url = resource.baseURL
        } else {
            // For GET, include query params
            url = resource.completeURL
        }

        var urlRequest = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        urlRequest.httpMethod = resource.method.rawValue
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add request body if provided
        if let body = resource.body {
            urlRequest.httpBody = body
        }

        do {
            let (data, response) = try await session.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknown
            }

            switch httpResponse.statusCode {
            case 200...299:
                return data
            case 400:
                throw APIError.badRequest
            case 401:
                throw APIError.unauthorized
            case 403:
                throw APIError.forbidden
            case 404:
                throw APIError.notFound
            case 500..<600:
                throw APIError.serverError
            default:
                throw APIError.unknown
            }
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost:
                throw APIError.noInternetConnection
            case .timedOut:
                throw APIError.timeout
            default:
                throw APIError.networkError
            }
        } catch let apiError as APIError {
            throw apiError
        } catch {
            throw APIError.unknown
        }
    }
}
