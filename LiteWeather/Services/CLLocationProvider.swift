import Foundation
import CoreLocation
import Domain

enum LocationProviderError: Error {
    case timeout
    case unavailable
}

struct CLLocationProvider: CoordinatesProvider {
    let timeout: UInt64

    init(timeout: UInt64 = 5_000_000_000) {
        self.timeout = timeout
    }

    public func get() async throws -> Coordinates {
        return try await withThrowingTaskGroup(of: Coordinates.self) { group in
            group.addTask {
                let updates = CLLocationUpdate.liveUpdates()
                for try await update in updates {
                    if let location = update.location {
                        return Coordinates(latitude: location.coordinate.latitude,
                                           longitude: location.coordinate.longitude)
                    }
                }
                throw LocationProviderError.unavailable
            }
            group.addTask {
                try await Task.sleep(nanoseconds: timeout)
                throw LocationProviderError.timeout
            }
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
}
