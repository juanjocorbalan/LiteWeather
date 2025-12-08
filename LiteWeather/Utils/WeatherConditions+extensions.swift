import SwiftUI
import Domain

// MARK: - WeatherConditionType SF Symbol Mapping

extension WeatherConditionType {
    /// Maps weather type to SF Symbols
    /// - Parameter timeOfDay: Whether it's day or night
    /// - Returns: The appropriate SF Symbol name
    func sfSymbol(timeOfDay: TimeOfDay) -> String {
        switch self {
        case .clearSky:
            return timeOfDay == .day ? "sun.max.fill" : "moon.stars.fill"
        case .fewClouds:
            return timeOfDay == .day ? "cloud.sun.fill" : "cloud.moon.fill"
        case .scatteredClouds:
            return "cloud.fill"
        case .brokenClouds:
            return "smoke.fill"
        case .showerRain:
            return "cloud.rain.fill"
        case .rain:
            return timeOfDay == .day ? "cloud.sun.rain.fill" : "cloud.moon.rain.fill"
        case .thunderstorm:
            return "cloud.bolt.rain.fill"
        case .snow:
            return "snowflake"
        case .mist:
            return "cloud.fog.fill"
        case .unknown:
            return "questionmark.circle"
        }
    }

    /// Returns contextual color for the weather symbol
    /// - Parameter timeOfDay: Whether it's day or night (affects clear sky color)
    /// - Returns: The appropriate color for the symbol
    func symbolColor(timeOfDay: TimeOfDay) -> Color {
        switch self {
        case .clearSky:
            return timeOfDay == .day ? .yellow : .indigo
        case .fewClouds, .scatteredClouds, .brokenClouds:
            return .gray
        case .rain, .showerRain:
            return .blue
        case .thunderstorm:
            return .purple
        case .snow:
            return .cyan
        case .mist:
            return .secondary
        case .unknown:
            return .primary
        }
    }
}

// MARK: - WeatherCondition Convenience

extension WeatherCondition {
    /// SF Symbol for the weather condition
    var sfSymbol: String {
        type.sfSymbol(timeOfDay: timeOfDay)
    }

    /// Color for the weather symbol
    var symbolColor: Color {
        type.symbolColor(timeOfDay: timeOfDay)
    }
}
