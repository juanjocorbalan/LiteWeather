import CoreLocation
import Domain

enum LocationProviderError: Error {
    case timeout
    case unavailable
}

/// Provides geographic coordinates using CoreLocation with timeout protection
struct CLLocationProvider: CoordinatesProvider {
    private let timeout: UInt64

    /// Creates a location provider with configurable timeout
    /// - Parameter timeout: Maximum time to wait for location in nanoseconds (default: 5 seconds)
    init(timeout: UInt64 = 5_000_000_000) {
        self.timeout = timeout
    }

    /// Uses a TaskGroup to race between:
    /// - CoreLocation live updates stream
    /// - Timeout task
    ///
    /// The first task to complete wins. Remaining tasks are cancelled.
    ///
    /// - Returns: Device geographic coordinates
    /// - Throws: `LocationProviderError.timeout` if timeout expires, or `.unavailable` if location cannot be determined
    @concurrent
    public func get() async throws -> Coordinates {
        try await withThrowingTaskGroup(of: Coordinates.self) { @concurrent group in
            group.addTask { @concurrent in
                let updates = CLLocationUpdate.liveUpdates()
                for try await update in updates {
                    if let location = update.location {
                        return Coordinates(latitude: location.coordinate.latitude,
                                           longitude: location.coordinate.longitude)
                    }
                }
                throw LocationProviderError.unavailable
            }
            group.addTask { @concurrent in
                try await Task.sleep(nanoseconds: timeout)
                throw LocationProviderError.timeout
            }
            guard let result = try await group.next() else {
                throw LocationProviderError.unavailable
            }
            group.cancelAll()
            return result
        }
    }
}
