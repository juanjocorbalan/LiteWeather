import Foundation

/// Policy for handling request retries with exponential backoff
public struct RetryPolicy: Sendable {
    public let maxAttempts: Int
    public let baseDelay: TimeInterval
    public let maxDelay: TimeInterval
    public let shouldRetry: @Sendable (APIError) -> Bool

    /// Creates a custom retry policy
    ///
    /// - Parameters:
    ///   - maxAttempts: Maximum number of retry attempts (0 = no retries)
    ///   - baseDelay: Initial delay in seconds before first retry
    ///   - maxDelay: Maximum delay in seconds (caps exponential backoff)
    ///   - shouldRetry: Closure to determine if an error is retriable
    public init(
        maxAttempts: Int,
        baseDelay: TimeInterval,
        maxDelay: TimeInterval,
        shouldRetry: @escaping @Sendable (APIError) -> Bool
    ) {
        self.maxAttempts = maxAttempts
        self.baseDelay = baseDelay
        self.maxDelay = maxDelay
        self.shouldRetry = shouldRetry
    }

    /// Default retry policy: 3 attempts, exponential backoff, retries network/server errors
    public static let `default` = RetryPolicy(
        maxAttempts: 3,
        baseDelay: 0.5,
        maxDelay: 30.0,
        shouldRetry: { error in
            switch error {
            case .timeout, .noInternetConnection, .networkError, .serverError:
                return true
            case .badRequest, .unauthorized, .forbidden, .notFound, .decodingError, .unknown:
                return false
            }
        }
    )

    /// No retry policy: fails immediately on first error
    public static let noRetry = RetryPolicy(
        maxAttempts: 0,
        baseDelay: 0,
        maxDelay: 0,
        shouldRetry: { _ in false }
    )

    /// Calculates delay for a given attempt using exponential backoff
    ///
    /// - Parameter attempt: Current attempt number (0-indexed)
    /// - Returns: Delay in seconds
    public func delay(for attempt: Int) -> TimeInterval {
        guard maxAttempts > 0 else { return 0 }

        // Exponential backoff: baseDelay * 2^attempt
        let exponentialDelay = baseDelay * pow(2.0, Double(attempt))

        // Cap at maxDelay
        return min(exponentialDelay, maxDelay)
    }
}
