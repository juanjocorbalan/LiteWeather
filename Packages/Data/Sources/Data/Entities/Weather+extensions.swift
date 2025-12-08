import Foundation
import Domain

extension WeatherDTO: DomainRepresentable {
    public func toDomain() -> Weather {
        Weather(
            coordinates: coord.toDomain(),
            conditions: weather.toDomain(),
            temperature: main.toDomain(),
            windSpeed: wind.speed,
            location: sys.toDomain(name: name, timezoneOffset: timezone ?? 0),
            timestamp: Date(timeIntervalSince1970: TimeInterval(dt))
        )
    }
}

extension WeatherDTO.CoordDTO: DomainRepresentable {
    public func toDomain() -> Coordinates {
        Coordinates(latitude: lat, longitude: lon)
    }
}

extension WeatherDTO.WeatherConditionDTO: DomainRepresentable {
    /// Maps OpenWeatherMap weather conditions code to WeatherConditionType
    /// - Parameter weatherID: OpenWeatherMap weather condition code
    /// - Returns: WeatherConditionType
    static func map(weatherID id: Int) -> WeatherConditionType {
        switch id {
        // Thunderstorm group (200-232)
        case 200...232:
            return .thunderstorm

        // Drizzle group (300-321)
        case 300...321:
            return .showerRain

        // Rain group (500-531)
        case 500...531:
            return .rain

        // Snow group (600-622)
        case 600...622:
            return .snow

        // Atmosphere group (701-781): mist, smoke, haze, dust, fog, sand, ash, squall, tornado
        case 701...781:
            return .mist

        // Clear (800)
        case 800:
            return .clearSky

        // Clouds group (801-804)
        case 801:
            return .fewClouds
        case 802:
            return .scatteredClouds
        case 803, 804:
            return .brokenClouds

        default:
            return .unknown
        }
    }

    /// Maps OpenWeatherMap icon code to TimeOfDay
    /// - Parameter iconCode: OpenWeatherMap icon code (e.g., "01d", "02n")
    /// - Returns: TimeOfDay (day or night)
    static func map(iconCode: String) -> TimeOfDay {
        iconCode.hasSuffix("d") ? .day : .night
    }

    public func toDomain() -> WeatherCondition {
        WeatherCondition(
            type: Self.map(weatherID: id),
            timeOfDay: Self.map(iconCode: icon),
            description: description
        )
    }
}

extension WeatherDTO.MainDTO: DomainRepresentable {
    public func toDomain() -> Temperature {
        Temperature(
            current: temp,
            feelsLike: feelsLike,
            minimum: tempMin,
            maximum: tempMax,
            pressure: pressure,
            humidity: humidity
        )
    }
}

extension WeatherDTO.SysDTO {
    public func toDomain(name: String, timezoneOffset: Int) -> Location {
        Location(
            name: name,
            country: country,
            sunrise: Date(timeIntervalSince1970: TimeInterval(sunrise)),
            sunset: Date(timeIntervalSince1970: TimeInterval(sunset)),
            timezoneOffset: timezoneOffset
        )
    }
}
