import Testing
import Foundation
import SwiftData
import Domain
import DomainTestingUtils
@testable import Data

@Suite("SwiftDataPersistenceClient Tests", .serialized)
class SwiftDataPersistenceClientTests {

    private let schema = Schema([WeatherCacheModel.self, WeatherConditionModel.self])
    private var modelContainer: ModelContainer!
    private var persistenceClient: SwiftDataPersistenceClient<WeatherCacheModel, WeatherQueryBuilder>!

    init() throws {
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [config])
        persistenceClient = SwiftDataPersistenceClient<WeatherCacheModel, WeatherQueryBuilder>(modelContainer: modelContainer)
    }

    // MARK: - Save and Fetch Tests

    @Test("Save and fetch by ID returns the same weather")
    func saveAndFetchByIdReturnsTheSameWeather() async throws {
        // Given
        let weather = Weather.madrid
        let weatherId = String(format: "%.6f-%.6f", weather.coordinates.latitude, weather.coordinates.longitude)

        // When
        try await persistenceClient.save(weather)
        let fetched = try await persistenceClient.fetch(byId: weatherId)

        // Then
        #expect(fetched != nil)
        #expect(fetched?.location.name == weather.location.name)
        #expect(fetched?.coordinates.latitude == weather.coordinates.latitude)
        #expect(fetched?.coordinates.longitude == weather.coordinates.longitude)
        #expect(fetched?.temperature.current == weather.temperature.current)
        #expect(fetched?.conditions.count == weather.conditions.count)
    }

    @Test("Fetch returns nil when weather not found")
    func fetchReturnsNilWhenNotFound() async throws {
        // Given
        let nonExistentId = "99.999900--99.999900"

        // When
        let fetched = try await persistenceClient.fetch(byId: nonExistentId)

        // Then
        #expect(fetched == nil)
    }

    @Test("Fetch by filter returns weather matching latest")
    func fetchByFilterReturnsLatest() async throws {
        // Given - Save three weather records with different timestamps
        let oldWeather = Weather(
            coordinates: Coordinates(latitude: 40.0, longitude: -3.0),
            conditions: [WeatherCondition(type: .clearSky, timeOfDay: .day, description: "clear sky")],
            temperature: Temperature(current: 15.0, feelsLike: 14.0, minimum: 12.0, maximum: 18.0, pressure: 1013, humidity: 65),
            windSpeed: 3.5,
            location: Location(name: "Old", country: "ES", sunrise: Date(), sunset: Date(), timezoneOffset: 3600),
            timestamp: Date().addingTimeInterval(-7200) // 2 hours ago
        )

        let middleWeather = Weather(
            coordinates: Coordinates(latitude: 41.0, longitude: -4.0),
            conditions: [WeatherCondition(type: .fewClouds, timeOfDay: .day, description: "few clouds")],
            temperature: Temperature(current: 16.0, feelsLike: 15.0, minimum: 13.0, maximum: 19.0, pressure: 1014, humidity: 70),
            windSpeed: 4.0,
            location: Location(name: "Middle", country: "ES", sunrise: Date(), sunset: Date(), timezoneOffset: 3600),
            timestamp: Date().addingTimeInterval(-3600) // 1 hour ago
        )

        let recentWeather = Weather(
            coordinates: Coordinates(latitude: 42.0, longitude: -5.0),
            conditions: [WeatherCondition(type: .scatteredClouds, timeOfDay: .day, description: "scattered clouds")],
            temperature: Temperature(current: 17.0, feelsLike: 16.0, minimum: 14.0, maximum: 20.0, pressure: 1015, humidity: 75),
            windSpeed: 4.5,
            location: Location(name: "Recent", country: "ES", sunrise: Date(), sunset: Date(), timezoneOffset: 3600),
            timestamp: Date() // Now
        )

        try await persistenceClient.save(oldWeather)
        try await persistenceClient.save(middleWeather)
        try await persistenceClient.save(recentWeather)

        // When - Fetch most recent using filter
        let results = try await persistenceClient.fetch(byFilter: .latest)
        let fetched = results.first

        // Then - Should return the most recent one
        #expect(fetched != nil)
        #expect(fetched?.location.name == "Recent")
        #expect(fetched?.timestamp == recentWeather.timestamp)
    }

    @Test("DeleteAll removes all weather records")
    func deleteAllRemovesAllRecords() async throws {
        // Given - Save multiple weather records
        try await persistenceClient.save(Weather.madrid)
        try await persistenceClient.save(Weather.london)
        try await persistenceClient.save(Weather.rome)

        // Verify they were saved
        let beforeDelete = try await persistenceClient.fetchAll()
        #expect(beforeDelete.count == 3)

        // When
        try await persistenceClient.deleteAll()

        // Then
        let afterDelete = try await persistenceClient.fetchAll()
        #expect(afterDelete.isEmpty)
    }

    @Test("Saving same ID updates existing record (upsert)")
    func savingSameIdUpdatesExisting() async throws {
        // Given
        let coordinates = Coordinates(latitude: 40.4168, longitude: -3.7038)
        let weatherId = String(format: "%.6f-%.6f", coordinates.latitude, coordinates.longitude)

        let firstWeather = Weather(
            coordinates: coordinates,
            conditions: [WeatherCondition(type: .clearSky, timeOfDay: .day, description: "clear sky")],
            temperature: Temperature(current: 15.0, feelsLike: 14.0, minimum: 12.0, maximum: 18.0, pressure: 1013, humidity: 65),
            windSpeed: 3.5,
            location: Location(name: "First", country: "ES", sunrise: Date(), sunset: Date(), timezoneOffset: 3600),
            timestamp: Date()
        )

        let secondWeather = Weather(
            coordinates: coordinates,
            conditions: [WeatherCondition(type: .fewClouds, timeOfDay: .day, description: "few clouds")],
            temperature: Temperature(current: 20.0, feelsLike: 19.0, minimum: 17.0, maximum: 23.0, pressure: 1015, humidity: 70),
            windSpeed: 4.0,
            location: Location(name: "Updated", country: "ES", sunrise: Date(), sunset: Date(), timezoneOffset: 3600),
            timestamp: Date()
        )

        // When
        try await persistenceClient.save(firstWeather)
        try await persistenceClient.save(secondWeather)

        // Then - Should only have one record (updated)
        let fetched = try await persistenceClient.fetch(byId: weatherId)
        #expect(fetched != nil)
        #expect(fetched?.location.name == "Updated")
        #expect(fetched?.temperature.current == 20.0)

        // Verify only one record exists in total
        let allRecords = try await persistenceClient.fetchAll()
        #expect(allRecords.count == 1)
    }

    @Test("Delete by ID removes only specified record")
    func deleteByIdRemovesOnlySpecified() async throws {
        // Given
        try await persistenceClient.save(Weather.madrid)
        try await persistenceClient.save(Weather.london)
        try await persistenceClient.save(Weather.rome)

        let allBefore = try await persistenceClient.fetchAll()
        #expect(allBefore.count == 3)

        // When
        let madridId = String(format: "%.6f-%.6f",
                             Weather.madrid.coordinates.latitude,
                             Weather.madrid.coordinates.longitude)
        try await persistenceClient.delete(byId: madridId)

        // Then
        let allAfter = try await persistenceClient.fetchAll()
        #expect(allAfter.count == 2)
        #expect(!allAfter.contains(where: { $0.location.name == "Madrid" }))
        #expect(allAfter.contains(where: { $0.location.name == "London" }))
        #expect(allAfter.contains(where: { $0.location.name == "Rome" }))
    }

    @Test("Deleting weather cascade deletes conditions")
    func deletingWeatherCascadeDeletesConditions() async throws {
        // Given
        let weather = Weather(
            coordinates: Coordinates(latitude: 40.0, longitude: -3.0),
            conditions: [
                WeatherCondition(type: .clearSky, timeOfDay: .day, description: "clear sky"),
                WeatherCondition(type: .fewClouds, timeOfDay: .day, description: "few clouds")
            ],
            temperature: Temperature(current: 15.0, feelsLike: 14.0, minimum: 12.0, maximum: 18.0, pressure: 1013, humidity: 65),
            windSpeed: 3.5,
            location: Location(name: "Test", country: "ES", sunrise: Date(), sunset: Date(), timezoneOffset: 3600),
            timestamp: Date()
        )

        try await persistenceClient.save(weather)

        // Verify conditions were saved
        let conditionsBeforeDelete = try await fetchAllConditionRecords()
        #expect(conditionsBeforeDelete.count == 2)

        // When - Delete all (which deletes the weather)
        try await persistenceClient.deleteAll()

        // Then - Conditions should also be deleted due to cascade
        let conditionsAfterDelete = try await fetchAllConditionRecords()
        #expect(conditionsAfterDelete.count == 0)
    }

    // MARK: - Helper Methods

    private func fetchAllConditionRecords() async throws -> [WeatherConditionModel] {
        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<WeatherConditionModel>()
        return try context.fetch(descriptor)
    }
}
