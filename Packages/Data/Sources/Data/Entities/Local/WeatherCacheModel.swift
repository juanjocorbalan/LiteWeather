import Foundation
import SwiftData
import Domain

@Model
public final class WeatherCacheModel {
    @Attribute(.unique) public var id: String
    public var latitude: Double
    public var longitude: Double
    public var locationName: String
    public var country: String?
    public var temperature: Double
    public var feelsLike: Double
    public var tempMin: Double
    public var tempMax: Double
    public var pressure: Int
    public var humidity: Int
    public var windSpeed: Double
    @Relationship(deleteRule: .cascade) public var conditions: [WeatherConditionModel]
    public var timezoneOffset: Int
    public var sunrise: Date
    public var sunset: Date
    public var weatherTimestamp: Date

    public init(from weather: Weather) {
        self.id = weather.id
        self.latitude = weather.coordinates.latitude
        self.longitude = weather.coordinates.longitude
        self.locationName = weather.location.name
        self.country = weather.location.country
        self.temperature = weather.temperature.current
        self.feelsLike = weather.temperature.feelsLike
        self.tempMin = weather.temperature.minimum
        self.tempMax = weather.temperature.maximum
        self.pressure = weather.temperature.pressure
        self.humidity = weather.temperature.humidity
        self.windSpeed = weather.windSpeed
        self.conditions = weather.conditions.map { WeatherConditionModel(from: $0) }
        self.timezoneOffset = weather.location.timezoneOffset
        self.sunrise = weather.location.sunrise
        self.sunset = weather.location.sunset
        self.weatherTimestamp = weather.timestamp
    }
}

@Model
public final class WeatherConditionModel {
    public var weatherType: String
    public var timeOfDay: String
    public var conditionDescription: String

    public init(from condition: WeatherCondition) {
        self.weatherType = condition.type.rawValue
        self.timeOfDay = condition.timeOfDay.rawValue
        self.conditionDescription = condition.description
    }
}
