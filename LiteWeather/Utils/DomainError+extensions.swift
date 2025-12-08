import Foundation
import Domain

// MARK: - DomainError Helpers

extension DomainError: @retroactive LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unavailable:
            return String(localized: "error_network_unavailable")

        case .unauthorized:
            return String(localized: "error_unauthorized")

        case .invalidData:
            return String(localized: "error_invalid_data")

        case .unknown:
            return String(localized: "error_unknown")
        }
    }
}
