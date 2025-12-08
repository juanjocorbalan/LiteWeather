import Foundation
import Domain

public final class MockCoordinatesProvider: CoordinatesProvider {
    nonisolated(unsafe) public var stubbedResult: Result<Coordinates, Error>?
    nonisolated(unsafe) public var callCount: Int = 0

    public init() {}

    public func get() async throws -> Coordinates {
        callCount += 1

        guard let result = stubbedResult else {
            fatalError("MockLocationProvider not configured")
        }

        switch result {
        case .success(let coordinates):
            return coordinates
        case .failure(let error):
            throw error
        }
    }
}
