import Foundation

/// Centralized accessibility identifiers for UI testing
enum AccessibilityIdentifiers {
    // MARK: - Weather View States
    enum WeatherView {
        static let loadingView = "weather.loading"
        static let errorView = "weather.error"
        static let contentView = "weather.content"
    }

    // MARK: - Weather Content
    enum WeatherContent {
        static let locationName = "weather.location.name"
        static let locationTimestamp = "weather.location.timestamp"
        static let weatherIcon = "weather.icon"
        static let weatherDescription = "weather.description"
        static let currentTemperature = "weather.temperature.current"
        static let feelsLike = "weather.temperature.feelsLike"
        static let minTemperature = "weather.temperature.min"
        static let maxTemperature = "weather.temperature.max"
        static let windSpeed = "weather.wind.speed"
        static let humidity = "weather.humidity"
        static let sunrise = "weather.sunrise"
        static let sunset = "weather.sunset"
    }

    // MARK: - Actions
    enum Actions {
        static let reloadButton = "action.reload"
        static let currentLocationButton = "action.currentLocation"
    }

    // MARK: - Error View
    enum Error {
        static let title = "error.title"
        static let message = "error.message"
    }
}
