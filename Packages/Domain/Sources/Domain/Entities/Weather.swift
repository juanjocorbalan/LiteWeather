import Foundation

public struct Weather: Sendable, Equatable {
    public let coordinates: Coordinates
    public let conditions: [WeatherCondition]
    public let temperature: Temperature
    public let windSpeed: Double
    public let location: Location
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
    public static func idFor(latitude: Double, longitude: Double) -> String {
        String(format: "%.6f-%.6f", latitude, longitude)
    }
    
    public var id: String {
        Self.idFor(latitude: coordinates.latitude, longitude: coordinates.longitude)
    }
}
