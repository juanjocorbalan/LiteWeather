import Foundation

/// Configuration for OpenWeatherMap API
public struct APIConfig {
    /// Base URL for the OpenWeatherMap API
    public static let baseURL = "https://api.openweathermap.org/data/2.5"

    /// API path components
    public enum Path {
        public static let weather = "weather"
    }

    /// Complete API endpoints
    public enum Endpoint {
        public static let currentWeather = baseURL + "/" + Path.weather
    }

    /// Query parameter keys used by the API
    public enum Parameter: String, CaseIterable {
        case lat
        case lon
        case appid
        case units
        case lang
    }

    /// API key for authentication
    public static let apiKey: String = "6ea1a2732a79ba4fc9ae9a3778395f34"
}
