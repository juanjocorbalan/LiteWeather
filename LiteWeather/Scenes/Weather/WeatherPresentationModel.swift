import Foundation
import SwiftUI
import Data
import Domain

/// Presentation model containing pre-formatted weather data ready for display
struct WeatherPresentationModel: Equatable {
    let location: String
    let weatherIcon: String
    let weatherIconColor: Color
    let weatherDescription: String
    let currentTemperature: String
    let feelsLike: String
    let minTemperature: String
    let maxTemperature: String
    let windSpeed: String
    let humidity: String
    let sunrise: String
    let sunset: String
    let timestamp: String

    init(weather: Weather, measurementSystem: MeasurementSystem) {
        // Location
        let displayName = weather.location.displayName
        self.location = displayName.isEmpty ? weather.coordinates.formatted : displayName

        // Main weather
        if let condition = weather.conditions.first {
            self.weatherIcon = condition.sfSymbol
            self.weatherIconColor = condition.symbolColor
            self.weatherDescription = condition.description.capitalized
        } else {
            self.weatherIcon = "questionmark.circle"
            self.weatherIconColor = Color.textPrimary
            self.weatherDescription = ""
        }

        // Temperature
        self.currentTemperature = weather.temperature.currentFormatted(measurementSystem: measurementSystem)
        self.feelsLike = weather.temperature.feelsLikeFormatted(measurementSystem: measurementSystem)
        self.minTemperature = weather.temperature.minFormatted(measurementSystem: measurementSystem)
        self.maxTemperature = weather.temperature.maxFormatted(measurementSystem: measurementSystem)

        // Other details
        self.windSpeed = weather.windSpeedFormatted(measurementSystem: measurementSystem)
        self.humidity = weather.temperature.humidityFormatted
        self.sunrise = weather.location.sunriseFormatted
        self.sunset = weather.location.sunsetFormatted
        self.timestamp = weather.timestampFormatted
    }
}
