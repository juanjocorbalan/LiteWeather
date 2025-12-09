import Foundation

/// Complete weather information for a specific location and time
public struct Weather: Sendable, Equatable {
    /// Geographic coordinates of the weather data
    public let coordinates: Coordinates

    /// Weather conditions (e.g., clear sky, rain, clouds)
    public let conditions: [WeatherCondition]

    /// Temperature measurements (current, min, max, feels like, humidity, pressure)
    public let temperature: Temperature

    /// Wind speed in meters per second
    public let windSpeed: Double

    /// Location information (name, country, sunrise/sunset times)
    public let location: Location

    /// Timestamp when the weather data was recorded
    public let timestamp: Date

    public init(
        coordinates: Coordinates,
        conditions: [WeatherCondition],
        temperature: Temperature,
        windSpeed: Double,
        location: Location,
        timestamp: Date
    ) {
        self.coordinates = coordinates
        self.conditions = conditions
        self.temperature = temperature
        self.windSpeed = windSpeed
        self.location = location
        self.timestamp = timestamp
    }
}

extension Weather: Identifiable {
    /// Generates a unique identifier based on coordinates
    public static func idFor(latitude: Double, longitude: Double) -> String {
        String(format: "%.6f-%.6f", latitude, longitude)
    }

    /// Unique identifier for this weather instance based on its coordinates
    public var id: String {
        Self.idFor(latitude: coordinates.latitude, longitude: coordinates.longitude)
    }
}
