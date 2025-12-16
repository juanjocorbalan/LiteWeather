import Foundation
import Domain
import SwiftData

extension WeatherCacheModel: DomainRepresentable {
    public func toDomain() -> Weather {
        Weather(
            coordinates: Coordinates(
                latitude: latitude,
                longitude: longitude
            ),
            conditions: conditions.map { $0.toDomain() },
            temperature: Temperature(
                current: temperature,
                feelsLike: feelsLike,
                minimum: tempMin,
                maximum: tempMax,
                pressure: pressure,
                humidity: humidity
            ),
            windSpeed: windSpeed,
            location: Location(
                name: locationName,
                country: country,
                sunrise: sunrise,
                sunset: sunset,
                timezoneOffset: timezoneOffset
            ),
            timestamp: weatherTimestamp
        )
    }
}

extension WeatherConditionModel: DomainRepresentable {
    public func toDomain() -> WeatherCondition {
        WeatherCondition(
            type: WeatherConditionType(rawValue: weatherType) ?? .unknown,
            timeOfDay: TimeOfDay(rawValue: timeOfDay) ?? .day,
            description: conditionDescription
        )
    }
}

extension WeatherCacheModel: SwiftDataModel {
    public func update(from entity: Weather) {
        self.latitude = entity.coordinates.latitude
        self.longitude = entity.coordinates.longitude
        self.locationName = entity.location.name
        self.country = entity.location.country
        self.temperature = entity.temperature.current
        self.feelsLike = entity.temperature.feelsLike
        self.tempMin = entity.temperature.minimum
        self.tempMax = entity.temperature.maximum
        self.pressure = entity.temperature.pressure
        self.humidity = entity.temperature.humidity
        self.windSpeed = entity.windSpeed
        self.timezoneOffset = entity.location.timezoneOffset
        self.sunrise = entity.location.sunrise
        self.sunset = entity.location.sunset
        self.weatherTimestamp = entity.timestamp
        self.conditions = entity.conditions.map { WeatherConditionModel(from: $0) }
    }
}
