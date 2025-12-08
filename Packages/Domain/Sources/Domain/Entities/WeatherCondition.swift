import Foundation

public enum TimeOfDay: String, Sendable, Equatable, CaseIterable {
    case day
    case night
}

public enum WeatherConditionType: String, Sendable, Equatable, CaseIterable {
    case clearSky
    case fewClouds
    case scatteredClouds
    case brokenClouds
    case showerRain
    case rain
    case thunderstorm
    case snow
    case mist
    case unknown
}

public struct WeatherCondition: Sendable, Equatable {
    public let type: WeatherConditionType
    public let timeOfDay: TimeOfDay
    public let description: String

    public init(type: WeatherConditionType, timeOfDay: TimeOfDay, description: String) {
        self.type = type
        self.timeOfDay = timeOfDay
        self.description = description
    }
}
