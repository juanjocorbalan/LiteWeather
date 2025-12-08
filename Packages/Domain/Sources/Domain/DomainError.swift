import Foundation

/// Domain-level errors representing business logic failures
public enum DomainError: Error, Equatable {
    /// The service is temporarily unavailable
    case unavailable

    /// The data received is invalid or cannot be processed
    case invalidData

    /// The request requires authentication or lacks proper authorization
    case unauthorized

    /// An unexpected error occurred
    case unknown
}
