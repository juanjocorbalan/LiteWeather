import Foundation
import Domain

public extension Weather {
    static let madrid = Weather(
        coordinates: Coordinates(latitude: 40.4168, longitude: -3.7038),
        conditions: [
            WeatherCondition(type: .clearSky, timeOfDay: .day, description: "clear sky")
        ],
        temperature: Temperature(
            current: 20.5,
            feelsLike: 19.2,
            minimum: 18.0,
            maximum: 23.0,
            pressure: 1013,
            humidity: 60
        ),
        windSpeed: 5.0,
        location: Location(
            name: "Madrid",
            country: "ES",
            sunrise: Date(timeIntervalSince1970: 1700035200),
            sunset: Date(timeIntervalSince1970: 1700070000),
            timezoneOffset: 3600
        ),
        timestamp: Date(timeIntervalSince1970: 1700050000)
    )

    static let rome = Weather(
        coordinates: Coordinates(latitude: 41.9028, longitude: 12.4964),
        conditions: [
            WeatherCondition(type: .fewClouds, timeOfDay: .day, description: "few clouds")
        ],
        temperature: Temperature(
            current: 25.0,
            feelsLike: 24.0,
            minimum: 22.0,
            maximum: 28.0,
            pressure: 1015,
            humidity: 55
        ),
        windSpeed: 3.5,
        location: Location(
            name: "Rome",
            country: "IT",
            sunrise: Date(timeIntervalSince1970: 1700034000),
            sunset: Date(timeIntervalSince1970: 1700068800),
            timezoneOffset: 3600
        ),
        timestamp: Date(timeIntervalSince1970: 1700050000)
    )

    static let london = Weather(
        coordinates: Coordinates(latitude: 51.5074, longitude: -0.1278),
        conditions: [
            WeatherCondition(type: .rain, timeOfDay: .day, description: "light rain")
        ],
        temperature: Temperature(
            current: 12.0,
            feelsLike: 10.5,
            minimum: 10.0,
            maximum: 14.0,
            pressure: 1010,
            humidity: 80
        ),
        windSpeed: 8.0,
        location: Location(
            name: "London",
            country: "GB",
            sunrise: Date(timeIntervalSince1970: 1700037600),
            sunset: Date(timeIntervalSince1970: 1700065200),
            timezoneOffset: 0
        ),
        timestamp: Date(timeIntervalSince1970: 1700050000)
    )

    static let newYork = Weather(
        coordinates: Coordinates(latitude: 40.7128, longitude: -74.0060),
        conditions: [
            WeatherCondition(type: .snow, timeOfDay: .day, description: "light snow")
        ],
        temperature: Temperature(
            current: -2.0,
            feelsLike: -5.0,
            minimum: -4.0,
            maximum: 0.0,
            pressure: 1020,
            humidity: 70
        ),
        windSpeed: 10.0,
        location: Location(
            name: "New York",
            country: "US",
            sunrise: Date(timeIntervalSince1970: 1700049600),
            sunset: Date(timeIntervalSince1970: 1700083200),
            timezoneOffset: -18000 // UTC-5
        ),
        timestamp: Date(timeIntervalSince1970: 1700050000)
    )
    
    static let minimal = Weather(
        coordinates: Coordinates(latitude: 0.0, longitude: 0.0),
        conditions: [],
        temperature: Temperature(
            current: 20.0,
            feelsLike: 20.0,
            minimum: 20.0,
            maximum: 20.0,
            pressure: 1013,
            humidity: 50
        ),
        windSpeed: 0.0,
        location: Location(
            name: "Unknown",
            country: "XX",
            sunrise: Date(),
            sunset: Date(),
            timezoneOffset: 0
        ),
        timestamp: Date()
    )
}

public extension Coordinates {
    static let madrid = Coordinates(latitude: 40.4168, longitude: -3.7038)
    static let rome = Coordinates(latitude: 41.9028, longitude: 12.4964)
    static let london = Coordinates(latitude: 51.5074, longitude: -0.1278)
    static let newYork = Coordinates(latitude: 40.7128, longitude: -74.0060)
    static let zero = Coordinates(latitude: 0.0, longitude: 0.0)
}

public extension Temperature {
    static let warm = Temperature(
        current: 20.0,
        feelsLike: 20.0,
        minimum: 20.0,
        maximum: 20.0,
        pressure: 1013,
        humidity: 50
    )
    
    static let cold = Temperature(
        current: -2.0,
        feelsLike: -5.0,
        minimum: -4.0,
        maximum: -10.0,
        pressure: 820,
        humidity: 100
    )
    
    static let zero = Temperature(
        current: 0.0,
        feelsLike: 0.0,
        minimum: 0.0,
        maximum: 0.0,
        pressure: 0,
        humidity: 0
    )
}
