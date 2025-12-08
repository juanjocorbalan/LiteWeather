import Foundation

/// Repository for accessing weather data
public protocol WeatherRepository: Sendable {
    /// Fetches current weather data for the specified coordinates
    ///
    /// - Parameters:
    ///   - latitude: Latitude in decimal degrees
    ///   - longitude: Longitude in decimal degrees
    /// - Returns: Weather information for the specified location
    /// - Throws: `DomainError` if the weather data cannot be retrieved
    func getCurrentWeather(latitude: Double, longitude: Double) async throws(DomainError) -> Weather
}
