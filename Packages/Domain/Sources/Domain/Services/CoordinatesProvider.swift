import Foundation

/// Service responsible for providing valid coordinates
public protocol CoordinatesProvider: Sendable {
    func get() async throws -> Coordinates
}

// MARK: - Default Implementation

/// Default implementation that generates random coordinates
public struct RandomCoordinatesProvider: CoordinatesProvider {

    public init() {}

    /// Provides coordinates within valid geographic bounds
    ///
    /// - Returns: A Coordinates object with latitude in [-90, 90] and longitude in [-180, 180]
    public func get() -> Coordinates {
        let latitude = Double.random(in: -90...90)
        let longitude = Double.random(in: -180...180)

        return Coordinates(latitude: latitude, longitude: longitude)
    }
}
