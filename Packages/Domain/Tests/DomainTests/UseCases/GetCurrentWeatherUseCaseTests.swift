import Testing
import Foundation
import DomainTestingUtils
@testable import Domain

@Suite("GetCurrentWeatherUseCase Tests")
struct GetCurrentWeatherUseCaseTests {

    @Test("Use case gets coordinates from repository")
    func getsCoordinatesFromRepository() async throws {
        // Given
        let mockRepository = MockWeatherRepository()
        mockRepository.stubbedResult = .success(.madrid)

        let useCase = GetCurrentWeatherUseCaseImpl(weatherRepository: mockRepository)

        // When
        let result = try await useCase.execute(coordinates: .madrid)

        // Then
        #expect(mockRepository.capturedLatitude == 40.4168)
        #expect(mockRepository.capturedLongitude == -3.7038)
        #expect(result == .madrid)
    }

    @Test("Use case propagates repository errors")
    func propagatesRepositoryErrors() async {
        // Given
        let mockRepository = MockWeatherRepository()
        mockRepository.stubbedResult = .failure(.unavailable)

        let useCase = GetCurrentWeatherUseCaseImpl(weatherRepository: mockRepository)

        // When/Then
        await #expect(throws: DomainError.unavailable) {
            try await useCase.execute(coordinates: .zero)
        }
    }
}
