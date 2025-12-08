import Testing
import Foundation
import Domain
import DomainTestingUtils
import DataTestingUtils
@testable import Data

@Suite("WeatherRepository Tests", .serialized)
class WeatherRepositoryTests {

    private static let stubID = UUID().uuidString

    // MARK: - Test Configuration

    private func makeRepository(retryPolicy: RetryPolicy = .default) -> WeatherRepositoryImpl {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        configuration.httpAdditionalHeaders = ["StubGroupID": Self.stubID]
        let apiClient = URLSessionAPIClient(configuration: configuration, retryPolicy: retryPolicy)
        return WeatherRepositoryImpl(apiClient: apiClient, localeProvider: MockLocaleProvider())
    }

    private func stubWeatherRequest(
        latitude: Double,
        longitude: Double,
        response: StubResponse,
        localeProvider: LocaleProvider = MockLocaleProvider()
    ) {
        let parameters = [
            APIConfig.Parameter.lat.rawValue: String(latitude),
            APIConfig.Parameter.lon.rawValue: String(longitude),
            APIConfig.Parameter.appid.rawValue: APIConfig.apiKey,
            APIConfig.Parameter.units.rawValue: localeProvider.measurementSystem.rawValue,
            APIConfig.Parameter.lang.rawValue: localeProvider.getOpenWeatherSupportedLanguageCode()
        ]

        let resource = Resource<WeatherDTO>(
            url: APIConfig.Endpoint.currentWeather,
            parameters: parameters
        )
        URLProtocolStub.stub(id: Self.stubID, url: resource.completeURL, response: response)
    }
    
    // MARK: - Success Tests
    
    @Test("Repository successfully fetches and maps weather data to domain entity")
    func successfullyFetchesAndMapsWeatherData() async throws {
        // Given
        let repository = makeRepository()
        let latitude = 40.4241
        let longitude = -3.7062
        stubWeatherRequest(latitude: latitude, longitude: longitude, response: .successWithFile("madrid.json"))
        
        // When
        let weather = try await repository.getCurrentWeather(latitude: latitude, longitude: longitude)
        
        // Then - Verify domain entity is correctly mapped
        #expect(weather.coordinates.latitude == 40.4241)
        #expect(weather.coordinates.longitude == -3.7062)
        #expect(weather.location.name == "Madrid City Center")
        #expect(weather.location.country == "ES")
        #expect(weather.temperature.current == 10.17)
        #expect(weather.temperature.feelsLike == 9.12)
        #expect(weather.conditions.count == 1)
        #expect(weather.conditions[0].type == .clearSky)
        #expect(weather.conditions[0].description == "cielo claro")
    }
    
    @Test("Repository converts Unix timestamps to Date objects")
    func convertsTimestampsToDateObjects() async throws {
        // Given
        let repository = makeRepository()
        stubWeatherRequest(latitude: 41, longitude: -4, response: .successWithFile("madrid.json"))

        // When
        let weather = try await repository.getCurrentWeather(latitude: 41, longitude: -4)
        
        // Then - Verify Date conversions
        #expect(weather.location.sunrise == Date(timeIntervalSince1970: 1763449477))
        #expect(weather.location.sunset == Date(timeIntervalSince1970: 1763484942))
    }
    
    // MARK: - Error Mapping Tests
    
    @Test("Repository maps decoding error to DomainError.invalidData")
    func mapsDecodingErrorToInvalidData() async throws {
        // Given
        let repository = makeRepository()
        let invalidData = Data("{ invalid json }".utf8)
        stubWeatherRequest(latitude: 42, longitude: -5, response: .success(invalidData))

        // When/Then
        await #expect(throws: DomainError.invalidData) {
            try await repository.getCurrentWeather(latitude: 42, longitude: -5)
        }
    }
    
    @Test("Repository maps server error to DomainError.unavailable")
    func shouldPropagateAPIErrorCorrectly() async {
        // Given - Disable retry to test error mapping directly
        let repository = makeRepository(retryPolicy: .noRetry)
        stubWeatherRequest(latitude: 43, longitude: -6, response: .failure(statusCode: 500, data: nil))

        // When/Then
        await #expect(throws: DomainError.unavailable) {
            try await repository.getCurrentWeather(latitude: 43, longitude: -6)
        }
    }
    
    @Test("Repository maps authorization error to DomainError.unauthorized")
    func shouldHandleAuthorizationErrorsCorrectly() async {
        // Given
        let repository = makeRepository()
        stubWeatherRequest(latitude: 44, longitude: -7, response: .failure(statusCode: 401, data: nil))

        // When/Then
        await #expect(throws: DomainError.unauthorized) {
            try await repository.getCurrentWeather(latitude: 44, longitude: -7)
        }
    }
    
    
    @Test("Repository maps timeout error to DomainError.unavailable")
    func shouldHandleNetworkTimeoutCorrectly() async {
        // Given - Disable retry to test error mapping directly
        let repository = makeRepository(retryPolicy: .noRetry)
        stubWeatherRequest(latitude: 45, longitude: -8, response: .networkTimeout)

        // When/Then
        await #expect(throws: DomainError.unavailable) {
            try await repository.getCurrentWeather(latitude: 45, longitude: -8)
        }
    }
    
    deinit {
        URLProtocolStub.reset(id: Self.stubID)
    }
}
