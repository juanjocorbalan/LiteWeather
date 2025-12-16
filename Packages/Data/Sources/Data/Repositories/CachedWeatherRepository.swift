import Foundation
import Domain

public final class CachedWeatherRepository: WeatherRepository {

    public enum CachePolicy: Sendable {
        case cacheFirst
        case networkFirst
        case networkOnly
    }

    private let remoteOnlyRepository: WeatherRepository
    private let persistenceClient: any PersistenceClient<Weather, WeatherQueryBuilder>
    private let cachePolicy: CachePolicy

    public init(
        remoteOnlyRepository: WeatherRepository,
        persistenceClient: any PersistenceClient<Weather, WeatherQueryBuilder>,
        cachePolicy: CachePolicy = .networkFirst
    ) {
        self.remoteOnlyRepository = remoteOnlyRepository
        self.persistenceClient = persistenceClient
        self.cachePolicy = cachePolicy
    }

    public func getCurrentWeather(latitude: Double, longitude: Double) async throws(DomainError) -> Weather {
        switch cachePolicy {
        case .cacheFirst:
            return try await getCacheFirstWeather(latitude: latitude, longitude: longitude)
        case .networkFirst:
            return try await getNetworkFirstWeather(latitude: latitude, longitude: longitude)
        case .networkOnly:
            return try await remoteOnlyRepository.getCurrentWeather(latitude: latitude, longitude: longitude)
        }
    }

    // MARK: - Private helpers

    private func getCacheFirstWeather(latitude: Double, longitude: Double) async throws(DomainError) -> Weather {
        let filter = WeatherFilter.byId(Weather.idFor(latitude: latitude, longitude: longitude))
        if let cached = try? await persistenceClient.fetch(byFilter: filter).first {
            Task.detached { [weak self] in
                try? await self?.fetchAndCache(latitude: latitude, longitude: longitude)
            }
            return cached
        }
        return try await fetchAndCache(latitude: latitude, longitude: longitude)
    }

    private func getNetworkFirstWeather(latitude: Double, longitude: Double) async throws(DomainError) -> Weather {
        do {
            return try await fetchAndCache(latitude: latitude, longitude: longitude)
        } catch {
            let filter = WeatherFilter.byId(Weather.idFor(latitude: latitude, longitude: longitude))
            if let cached = try? await persistenceClient.fetch(byFilter: filter).first {
                return cached
            } else if let cached = try? await persistenceClient.fetch(byFilter: WeatherFilter.latest).first {
                return cached
            }
            throw error
        }
    }

    private func fetchAndCache(latitude: Double, longitude: Double) async throws(DomainError) -> Weather {
        let weather = try await remoteOnlyRepository.getCurrentWeather(latitude: latitude, longitude: longitude)
        try? await persistenceClient.save(weather)
        return weather
    }
}
