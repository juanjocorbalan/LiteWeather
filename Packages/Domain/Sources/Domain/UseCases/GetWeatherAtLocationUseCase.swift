import Foundation

/// Use case for fetching weather data at the provided geographic coordinates
public protocol GetWeatherAtLocationUseCase: Sendable {
    /// Executes the use case to get weather at the provided location
    ///
    /// - Returns: Weather information at location
    /// - Throws: DomainError if the weather data cannot be retrieved
    func execute() async throws(DomainError) -> Weather
}

// MARK: - Use Case Implementation

public struct GetWeatherAtLocationUseCaseImpl: GetWeatherAtLocationUseCase {
    private let coordinatesProvider: CoordinatesProvider
    private let getCurrentWeather: GetCurrentWeatherUseCase

    public init(coordinatesProvider: CoordinatesProvider,
        getCurrentWeather: GetCurrentWeatherUseCase) {
        self.coordinatesProvider = coordinatesProvider
        self.getCurrentWeather = getCurrentWeather
    }

    public func execute() async throws(DomainError) -> Weather {
        do {
            let coordinates = try await coordinatesProvider.get()
            return try await getCurrentWeather.execute(coordinates: coordinates)
        } catch let error as DomainError {
            throw error
        } catch {
            // Map infrastructure errors to domain errors
            throw DomainError.unavailable
        }
    }
}
