import Testing
import Foundation
import SwiftData
import Domain
import DomainTestingUtils
@testable import Data

@Suite("WeatherCacheModel Tests")
struct WeatherCacheModelTests {

    @Test("ID generation is consistent and deterministic for same coordinates")
    func idGenerationIsConsistentAndDeterministic() {
        // Given
        let coordinates = Coordinates(latitude: 40.4168, longitude: -3.7038)

        let weather1 = Weather(
            coordinates: coordinates,
            conditions: [WeatherCondition(type: .clearSky, timeOfDay: .day, description: "clear sky")],
            temperature: Temperature(current: 15.0, feelsLike: 14.0, minimum: 12.0, maximum: 18.0, pressure: 1013, humidity: 65),
            windSpeed: 3.5,
            location: Location(name: "First", country: "ES", sunrise: Date(), sunset: Date(), timezoneOffset: 3600),
            timestamp: Date()
        )

        let weather2 = Weather(
            coordinates: coordinates,
            conditions: [WeatherCondition(type: .fewClouds, timeOfDay: .day, description: "few clouds")],
            temperature: Temperature(current: 20.0, feelsLike: 19.0, minimum: 17.0, maximum: 23.0, pressure: 1015, humidity: 70),
            windSpeed: 4.0,
            location: Location(name: "Second", country: "ES", sunrise: Date(), sunset: Date(), timezoneOffset: 3600),
            timestamp: Date()
        )

        // When
        let cacheModel1 = WeatherCacheModel(from: weather1)
        let cacheModel2 = WeatherCacheModel(from: weather2)

        // Then - Same coordinates should generate same ID (critical for upsert)
        #expect(cacheModel1.id == cacheModel2.id)
        let expectedID = String(format: "%.6f-%.6f", coordinates.latitude, coordinates.longitude)
        #expect(cacheModel1.id == expectedID)
    }

    @Test("Domain round-trip preserves semantic data integrity")
    func domainRoundTripPreservesSemanticData() {
        // Given
        let originalWeather = Weather.madrid

        // When - Convert to cache model and back
        let cacheModel = WeatherCacheModel(from: originalWeather)
        let convertedWeather = cacheModel.toDomain()

        // Then - Verify identity and key business data
        #expect(convertedWeather.id == originalWeather.id)
        #expect(convertedWeather.location.name == originalWeather.location.name)
        #expect(convertedWeather.temperature.current == originalWeather.temperature.current)
        #expect(convertedWeather.conditions.count == originalWeather.conditions.count)

        // Verify condition conversion (semantic mapping)
        if let originalCondition = originalWeather.conditions.first,
           let convertedCondition = convertedWeather.conditions.first {
            #expect(convertedCondition.type == originalCondition.type)
            #expect(convertedCondition.timeOfDay == originalCondition.timeOfDay)
        }
    }

    @Test("Update method correctly replaces all mutable fields")
    func updateMethodReplacesAllMutableFields() {
        // Given - Start with initial weather
        let initialWeather = Weather(
            coordinates: Coordinates(latitude: 40.0, longitude: -3.0),
            conditions: [WeatherCondition(type: .clearSky, timeOfDay: .day, description: "clear sky")],
            temperature: Temperature(current: 15.0, feelsLike: 14.0, minimum: 12.0, maximum: 18.0, pressure: 1013, humidity: 65),
            windSpeed: 3.5,
            location: Location(name: "Initial", country: "ES", sunrise: Date(), sunset: Date(), timezoneOffset: 3600),
            timestamp: Date().addingTimeInterval(-3600)
        )

        let cacheModel = WeatherCacheModel(from: initialWeather)
        let originalId = cacheModel.id

        // When - Update with completely different data (same coordinates)
        let updatedWeather = Weather(
            coordinates: Coordinates(latitude: 40.0, longitude: -3.0),
            conditions: [
                WeatherCondition(type: .rain, timeOfDay: .night, description: "heavy rain"),
                WeatherCondition(type: .thunderstorm, timeOfDay: .night, description: "storm")
            ],
            temperature: Temperature(current: 5.0, feelsLike: 2.0, minimum: 3.0, maximum: 8.0, pressure: 990, humidity: 95),
            windSpeed: 25.0,
            location: Location(name: "Updated", country: "FR", sunrise: Date(), sunset: Date(), timezoneOffset: 7200),
            timestamp: Date()
        )

        cacheModel.update(from: updatedWeather)

        // Then - Verify all fields updated except ID
        #expect(cacheModel.id == originalId) // ID should not change
        #expect(cacheModel.locationName == "Updated")
        #expect(cacheModel.country == "FR")
        #expect(cacheModel.temperature == 5.0)
        #expect(cacheModel.windSpeed == 25.0)
        #expect(cacheModel.conditions.count == 2) // Conditions replaced
        #expect(cacheModel.conditions.first?.weatherType == "rain")
    }
}
