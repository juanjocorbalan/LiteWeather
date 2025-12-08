import Testing
import Foundation
@testable import Domain

@Suite("RandomCoordinatesProvider Tests")
struct RandomCoordinatesProviderTests {

    @Test("Generates coordinates within valid latitude bounds")
    func generatesValidLatitudes() async throws {
        // Given
        let provider = RandomCoordinatesProvider()

        // When - Generate multiple coordinates to test randomness
        for _ in 1...100 {
            let coordinates = try await provider.get()

            // Then
            #expect(coordinates.latitude >= -90.0)
            #expect(coordinates.latitude <= 90.0)
        }
    }

    @Test("Generates coordinates within valid longitude bounds")
    func generatesValidLongitudes() async throws {
        // Given
        let provider = RandomCoordinatesProvider()

        // When - Generate multiple coordinates to test randomness
        for _ in 1...100 {
            let coordinates = try await provider.get()

            // Then
            #expect(coordinates.longitude >= -180.0)
            #expect(coordinates.longitude <= 180.0)
        }
    }

    @Test("Generates different coordinates on multiple calls")
    func generatesDifferentCoordinates() async throws {
        // Given
        let provider = RandomCoordinatesProvider()

        // When - Generate multiple coordinates
        var coordinates: [Coordinates] = []
        for _ in 1...10 {
            coordinates.append(try await provider.get())
        }

        // Then - Some should be different
        let uniqueCoordinates = Set(coordinates.map { "\($0.latitude),\($0.longitude)" })
        #expect(uniqueCoordinates.count > 1)
    }
}
