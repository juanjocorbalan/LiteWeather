import Foundation
import Domain

/// Protocol for DTOs that can be converted to domain entities
public protocol DomainRepresentable {
    /// The domain entity type this DTO represents
    associatedtype DomainEntity: Sendable

    /// Converts this DTO to its corresponding domain entity
    ///
    /// - Returns: A domain entity with mapped values from this DTO
    func toDomain() -> DomainEntity
}
