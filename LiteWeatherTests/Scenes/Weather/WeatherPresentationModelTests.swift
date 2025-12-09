import Testing
import Foundation
import SwiftUI
import Data
import Domain
import DomainTestingUtils
@testable import LiteWeather

struct WeatherPresentationModelTests {
    
    // MARK: - Location Name Tests
    
    @Test func init_withLocationNameAndCountry_usesLocationName() {
        let weather = Weather.madrid
        
        let model = WeatherPresentationModel(weather: weather, measurementSystem: .metric)
        
        #expect(model.location == "Madrid, ES")
    }
    
    @Test func init_withEmptyLocationNameAndNilCountry_usesCoordinates() {
        let weather = Weather(
            coordinates: Coordinates(latitude: 40.4168, longitude: -3.7038),
            conditions: [],
            temperature: Temperature(current: 20.0, feelsLike: 19.0, minimum: 18.0, maximum: 22.0, pressure: 1013, humidity: 60),
            windSpeed: 5.0,
            location: Location(name: "", country: nil, sunrise: Date(), sunset: Date(), timezoneOffset: 0),
            timestamp: Date()
        )
        
        let model = WeatherPresentationModel(weather: weather, measurementSystem: .metric)
        
        #expect(model.location == "40.4168, -3.7038")
    }
    
    @Test func init_withOnlyCountry_usesOnlyCountry() {
        let weather = Weather(
            coordinates: Coordinates(latitude: 40.4168, longitude: -3.7038),
            conditions: [],
            temperature: Temperature(current: 20.0, feelsLike: 19.0, minimum: 18.0, maximum: 22.0, pressure: 1013, humidity: 60),
            windSpeed: 5.0,
            location: Location(name: "", country: "ES", sunrise: Date(), sunset: Date(), timezoneOffset: 0),
            timestamp: Date()
        )
        
        let model = WeatherPresentationModel(weather: weather, measurementSystem: .metric)
        
        #expect(model.location == "ES")
    }
    
    @Test func init_withOnlyName_usesOnlyName() {
        let weather = Weather(
            coordinates: Coordinates(latitude: 40.4168, longitude: -3.7038),
            conditions: [],
            temperature: Temperature(current: 20.0, feelsLike: 19.0, minimum: 18.0, maximum: 22.0, pressure: 1013, humidity: 60),
            windSpeed: 5.0,
            location: Location(name: "Madrid", country: nil, sunrise: Date(), sunset: Date(), timezoneOffset: 0),
            timestamp: Date()
        )

        let model = WeatherPresentationModel(weather: weather, measurementSystem: .metric)

        #expect(model.location == "Madrid")
    }

    // MARK: - Weather Conditions Tests

    @Test func init_withEmptyConditions_usesDefaultValues() {
        let weather = Weather(
            coordinates: Coordinates(latitude: 40.4168, longitude: -3.7038),
            conditions: [],
            temperature: Temperature(current: 20.0, feelsLike: 19.0, minimum: 18.0, maximum: 22.0, pressure: 1013, humidity: 60),
            windSpeed: 5.0,
            location: Location(name: "Madrid", country: "ES", sunrise: Date(), sunset: Date(), timezoneOffset: 0),
            timestamp: Date()
        )

        let model = WeatherPresentationModel(weather: weather, measurementSystem: .metric)

        #expect(model.weatherIcon == "questionmark.circle")
        #expect(model.weatherIconColor == Color.textPrimary)
        #expect(model.weatherDescription == "")
    }

    @Test func init_withConditions_usesFirstCondition() {
        let weather = Weather(
            coordinates: Coordinates(latitude: 40.4168, longitude: -3.7038),
            conditions: [
                WeatherCondition(type: .clearSky, timeOfDay: .day, description: "clear sky"),
                WeatherCondition(type: .fewClouds, timeOfDay: .day, description: "few clouds")
            ],
            temperature: Temperature(current: 20.0, feelsLike: 19.0, minimum: 18.0, maximum: 22.0, pressure: 1013, humidity: 60),
            windSpeed: 5.0,
            location: Location(name: "Madrid", country: "ES", sunrise: Date(), sunset: Date(), timezoneOffset: 0),
            timestamp: Date()
        )

        let model = WeatherPresentationModel(weather: weather, measurementSystem: .metric)

        #expect(model.weatherIcon == "sun.max.fill")
        #expect(model.weatherIconColor == .yellow)
    }
}
