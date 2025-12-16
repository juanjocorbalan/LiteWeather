import Testing
import Foundation
import SwiftData
import Domain
import DomainTestingUtils
@testable import Data

@Suite("CachedWeatherRepository Tests", .serialized)
struct CachedWeatherRepositoryTests {

    // MARK: - NetworkFirst Policy Tests

    @Test("NetworkFirst returns network data and caches it")
    func networkFirstReturnsNetworkDataAndCachesIt() async throws {
        // Given
        let mockRemote = MockWeatherRepository()
        let mockPersistence = MockPersistenceClient()
        let repository = CachedWeatherRepository(
            remoteOnlyRepository: mockRemote,
            persistenceClient: mockPersistence,
            cachePolicy: .networkFirst
        )

        let expectedWeather = Weather.madrid
        mockRemote.weatherToReturn = expectedWeather

        // When
        let weather = try await repository.getCurrentWeather(
            latitude: expectedWeather.coordinates.latitude,
            longitude: expectedWeather.coordinates.longitude
        )

        // Then
        #expect(weather.location.name == expectedWeather.location.name)
        #expect(mockRemote.getCurrentWeatherCallCount == 1)
        #expect(mockPersistence.saveCallCount == 1)
        #expect(mockPersistence.lastSavedWeather?.location.name == expectedWeather.location.name)
    }

    @Test("NetworkFirst falls back to cache on network error")
    func networkFirstFallsBackToCacheOnNetworkError() async throws {
        // Given
        let mockRemote = MockWeatherRepository()
        let mockPersistence = MockPersistenceClient()
        let repository = CachedWeatherRepository(
            remoteOnlyRepository: mockRemote,
            persistenceClient: mockPersistence,
            cachePolicy: .networkFirst
        )

        let cachedWeather = Weather.london
        mockRemote.errorToThrow = .unavailable
        mockPersistence.weatherToReturn = cachedWeather

        // When
        let weather = try await repository.getCurrentWeather(
            latitude: cachedWeather.coordinates.latitude,
            longitude: cachedWeather.coordinates.longitude
        )

        // Then
        #expect(weather.location.name == cachedWeather.location.name)
        #expect(mockRemote.getCurrentWeatherCallCount == 1)
    }

    @Test("NetworkFirst falls back to last cached when no coordinate match")
    func networkFirstFallsBackToLastCachedWhenNoCoordinateMatch() async throws {
        // Given
        let mockRemote = MockWeatherRepository()
        let mockPersistence = MockPersistenceClient()
        let repository = CachedWeatherRepository(
            remoteOnlyRepository: mockRemote,
            persistenceClient: mockPersistence,
            cachePolicy: .networkFirst
        )

        let lastCachedWeather = Weather.rome
        mockRemote.errorToThrow = .unavailable
        mockPersistence.weatherToReturn = nil // No match for coordinates
        mockPersistence.allWeatherToReturn = [lastCachedWeather]

        // When
        let weather = try await repository.getCurrentWeather(latitude: 40.0, longitude: -3.0)

        // Then
        #expect(weather.location.name == lastCachedWeather.location.name)
        #expect(mockRemote.getCurrentWeatherCallCount == 1)
    }

    @Test("NetworkFirst throws when both network and cache fail")
    func networkFirstThrowsWhenBothNetworkAndCacheFail() async throws {
        // Given
        let mockRemote = MockWeatherRepository()
        let mockPersistence = MockPersistenceClient()
        let repository = CachedWeatherRepository(
            remoteOnlyRepository: mockRemote,
            persistenceClient: mockPersistence,
            cachePolicy: .networkFirst
        )

        mockRemote.errorToThrow = .unavailable
        mockPersistence.weatherToReturn = nil
        mockPersistence.allWeatherToReturn = []

        // When/Then
        await #expect(throws: DomainError.unavailable) {
            try await repository.getCurrentWeather(latitude: 40.0, longitude: -3.0)
        }

        #expect(mockRemote.getCurrentWeatherCallCount == 1)
    }

    // MARK: - CacheFirst Policy Tests

    @Test("CacheFirst returns cached data immediately")
    func cacheFirstReturnsCachedDataImmediately() async throws {
        // Given
        let mockRemote = MockWeatherRepository()
        let mockPersistence = MockPersistenceClient()
        let repository = CachedWeatherRepository(
            remoteOnlyRepository: mockRemote,
            persistenceClient: mockPersistence,
            cachePolicy: .cacheFirst
        )

        let cachedWeather = Weather.newYork
        mockPersistence.weatherToReturn = cachedWeather
        mockRemote.weatherToReturn = Weather.madrid // Different data from network

        // When
        let weather = try await repository.getCurrentWeather(
            latitude: cachedWeather.coordinates.latitude,
            longitude: cachedWeather.coordinates.longitude
        )

        // Then - Should return cached data, not network data
        #expect(weather.location.name == cachedWeather.location.name)
    }

    @Test("CacheFirst fetches from network on cache miss")
    func cacheFirstFetchesFromNetworkOnCacheMiss() async throws {
        // Given
        let mockRemote = MockWeatherRepository()
        let mockPersistence = MockPersistenceClient()
        let repository = CachedWeatherRepository(
            remoteOnlyRepository: mockRemote,
            persistenceClient: mockPersistence,
            cachePolicy: .cacheFirst
        )

        let networkWeather = Weather.madrid
        mockPersistence.weatherToReturn = nil // Cache miss
        mockRemote.weatherToReturn = networkWeather

        // When
        let weather = try await repository.getCurrentWeather(
            latitude: networkWeather.coordinates.latitude,
            longitude: networkWeather.coordinates.longitude
        )

        // Then
        #expect(weather.location.name == networkWeather.location.name)
        #expect(mockRemote.getCurrentWeatherCallCount == 1)
        #expect(mockPersistence.saveCallCount == 1)
    }

    // MARK: - NetworkOnly Policy Tests

    @Test("NetworkOnly never uses cache")
    func networkOnlyNeverUsesCache() async throws {
        // Given
        let mockRemote = MockWeatherRepository()
        let mockPersistence = MockPersistenceClient()
        let repository = CachedWeatherRepository(
            remoteOnlyRepository: mockRemote,
            persistenceClient: mockPersistence,
            cachePolicy: .networkOnly
        )

        let networkWeather = Weather.london
        mockRemote.weatherToReturn = networkWeather
        mockPersistence.weatherToReturn = Weather.madrid // Should be ignored

        // When
        let weather = try await repository.getCurrentWeather(
            latitude: networkWeather.coordinates.latitude,
            longitude: networkWeather.coordinates.longitude
        )

        // Then
        #expect(weather.location.name == networkWeather.location.name)
        #expect(mockRemote.getCurrentWeatherCallCount == 1)
        #expect(mockPersistence.fetchCallCount == 0) // Never checks cache
        #expect(mockPersistence.saveCallCount == 0) // Never saves to cache
    }

    @Test("NetworkOnly delegates directly to remote repository")
    func networkOnlyDelegatesToRemoteRepository() async throws {
        // Given
        let mockRemote = MockWeatherRepository()
        let mockPersistence = MockPersistenceClient()
        let repository = CachedWeatherRepository(
            remoteOnlyRepository: mockRemote,
            persistenceClient: mockPersistence,
            cachePolicy: .networkOnly
        )

        mockRemote.errorToThrow = .unauthorized

        // When/Then - Should throw the same error as remote
        await #expect(throws: DomainError.unauthorized) {
            try await repository.getCurrentWeather(latitude: 40.0, longitude: -3.0)
        }

        #expect(mockRemote.getCurrentWeatherCallCount == 1)
        #expect(mockPersistence.fetchCallCount == 0)
    }
}

// MARK: - Mock Implementations

final class MockWeatherRepository: WeatherRepository {
    nonisolated(unsafe) var weatherToReturn: Weather?
    nonisolated(unsafe) var errorToThrow: DomainError?
    nonisolated(unsafe) var getCurrentWeatherCallCount = 0

    func getCurrentWeather(latitude: Double, longitude: Double) async throws(DomainError) -> Weather {
        getCurrentWeatherCallCount += 1

        if let error = errorToThrow {
            throw error
        }

        guard let weather = weatherToReturn else {
            throw DomainError.unknown
        }

        return weather
    }
}

final class MockPersistenceClient: PersistenceClient {
    typealias Entity = Weather
    typealias Builder = WeatherQueryBuilder
    typealias Filter = WeatherFilter
    typealias Query = FetchDescriptor<WeatherCacheModel>

    nonisolated(unsafe) var weatherToReturn: Weather?
    nonisolated(unsafe) var allWeatherToReturn: [Weather] = []
    nonisolated(unsafe) var lastSavedWeather: Weather?
    nonisolated(unsafe) var saveCallCount = 0
    nonisolated(unsafe) var fetchCallCount = 0
    nonisolated(unsafe) var fetchWhereCallCount = 0
    nonisolated(unsafe) var fetchAllCallCount = 0
    nonisolated(unsafe) var deleteCallCount = 0
    nonisolated(unsafe) var clearAllCallCount = 0

    func save(_ weather: Weather) async throws {
        saveCallCount += 1
        lastSavedWeather = weather
    }

    func fetch(byId id: String) async throws -> Weather? {
        fetchCallCount += 1
        return weatherToReturn
    }

    func fetch(byFilter filter: WeatherFilter) async throws -> [Weather] {
        switch filter {
        case .byId:
            // Return weatherToReturn wrapped in array if it exists
            return weatherToReturn.map { [$0] } ?? []
        case .latest:
            // Return allWeatherToReturn for latest query
            return allWeatherToReturn
        }
    }

    func fetch(where query: FetchDescriptor<WeatherCacheModel>) async throws -> [Weather] {
        fetchWhereCallCount += 1
        return allWeatherToReturn
    }

    func fetchAll() async throws -> [Weather] {
        fetchAllCallCount += 1
        return allWeatherToReturn
    }

    func delete(byId id: String) async throws {
        deleteCallCount += 1
    }

    func delete(byFilter filter: WeatherFilter) async throws {
        deleteCallCount += 1
    }

    func deleteAll() async throws {
        clearAllCallCount += 1
    }
}
