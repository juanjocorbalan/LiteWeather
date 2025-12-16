import Domain

/// Maps infrastructure-level API errors to domain-level errors
struct RepositoryErrorMapper {
    /// Converts an APIError to its corresponding DomainError
    ///
    /// - Parameter apiError: The infrastructure-level error
    /// - Returns: Corresponding domain-level error
    static func mapToDomainError(_ apiError: APIError) -> DomainError {
        switch apiError {
        // Service availability issues
        case .networkError, .noInternetConnection, .timeout, .serverError:
            return .unavailable

        // Data quality issues
        case .decodingError, .notFound, .badRequest:
            return .invalidData

        // Authentication/authorization issues
        case .unauthorized, .forbidden:
            return .unauthorized

        // Unexpected errors
        case .unknown:
            return .unknown
        }
    }
}
