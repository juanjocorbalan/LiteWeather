import Foundation

/// Use case for fetching weather data for the provided geographic coordinates
public protocol GetCurrentWeatherUseCase: Sendable {
    /// Executes the use case to get weather for the given coordinates
    ///
    /// - Returns: Weather information for the given location
    /// - Throws: DomainError if the weather data cannot be retrieved
    func execute(coordinates: Coordinates) async throws(DomainError) -> Weather
}

// MARK: - Use Case Implementation

public struct GetCurrentWeatherUseCaseImpl: GetCurrentWeatherUseCase {
    private let weatherRepository: WeatherRepository
    
    public init(weatherRepository: WeatherRepository) {
        self.weatherRepository = weatherRepository
    }
    
    public func execute(coordinates: Coordinates) async throws(DomainError) -> Weather {
        try await weatherRepository.getCurrentWeather(latitude: coordinates.latitude,
                                                      longitude: coordinates.longitude)
    }
}
