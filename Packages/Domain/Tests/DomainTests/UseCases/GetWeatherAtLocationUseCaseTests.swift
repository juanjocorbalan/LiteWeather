import Testing
import Foundation
import DomainTestingUtils
@testable import Domain

@Suite("GetWeatherAtLocationUseCase Tests")
struct GetWeatherAtLocationUseCaseTests {

    // MARK: - Success Path

    @Test("Fetches user location and retrieves weather data")
    func fetchesLocationAndWeather() async throws {
        // Given
        let mockCoordinatesProvider = MockCoordinatesProvider()
        mockCoordinatesProvider.stubbedResult = .success(.madrid)

        let mockGetCurrentWeather = MockGetCurrentWeatherUseCase()
        mockGetCurrentWeather.stubbedResult = .success(.madrid)

        let useCase = GetWeatherAtLocationUseCaseImpl(
            coordinatesProvider: mockCoordinatesProvider,
            getCurrentWeather: mockGetCurrentWeather
        )

        // When
        let result = try await useCase.execute()

        // Then
        #expect(mockCoordinatesProvider.callCount == 1)
        #expect(mockGetCurrentWeather.capturedLatitude == 40.4168)
        #expect(mockGetCurrentWeather.capturedLongitude == -3.7038)
        #expect(result == .madrid)
    }

    // MARK: - LocationProvider Error Handling

    @Test("Maps infrastructure errors to DomainError.unavailable")
    func mapsInfrastructureErrorsToUnavailable() async {
        // Given
        let mockCoordinatesProvider = MockCoordinatesProvider()
        mockCoordinatesProvider.stubbedResult = .failure(NSError(domain: "test", code: -1))

        let mockGetCurrentWeather = MockGetCurrentWeatherUseCase()

        let useCase = GetWeatherAtLocationUseCaseImpl(
            coordinatesProvider: mockCoordinatesProvider,
            getCurrentWeather: mockGetCurrentWeather
        )

        // When/Then - Infrastructure errors map to unavailable
        await #expect(throws: DomainError.unavailable) {
            try await useCase.execute()
        }

        // Verify weather use case was never called
        #expect(mockGetCurrentWeather.capturedLatitude == nil)
    }

    // MARK: - GetCurrentWeatherUseCase Error Handling

    @Test("Propagates domain errors from GetCurrentWeatherUseCase")
    func propagatesDomainErrors() async {
        // Given
        let mockCoordinatesProvider = MockCoordinatesProvider()
        mockCoordinatesProvider.stubbedResult = .success(.london)

        let mockGetCurrentWeather = MockGetCurrentWeatherUseCase()
        mockGetCurrentWeather.stubbedResult = .failure(.unavailable)

        let useCase = GetWeatherAtLocationUseCaseImpl(
            coordinatesProvider: mockCoordinatesProvider,
            getCurrentWeather: mockGetCurrentWeather
        )

        // When/Then - Domain errors are propagated without mapping
        await #expect(throws: DomainError.unavailable) {
            try await useCase.execute()
        }
    }
}
