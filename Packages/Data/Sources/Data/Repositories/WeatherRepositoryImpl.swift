import Foundation
import Domain

public final class WeatherRepositoryImpl: WeatherRepository {
    private let apiClient: APIClient
    private let localeProvider: LocaleProvider
    
    public init(apiClient: APIClient, localeProvider: LocaleProvider) {
        self.apiClient = apiClient
        self.localeProvider = localeProvider
    }
    
    public func getCurrentWeather(latitude: Double, longitude: Double) async throws(DomainError) -> Weather {
        let url = APIConfig.Endpoint.currentWeather
        let parameters: [String: String] = [
            APIConfig.Parameter.lat.rawValue: String(latitude),
            APIConfig.Parameter.lon.rawValue: String(longitude),
            APIConfig.Parameter.appid.rawValue: APIConfig.apiKey,
            APIConfig.Parameter.units.rawValue: localeProvider.measurementSystem.rawValue,
            APIConfig.Parameter.lang.rawValue: localeProvider.getOpenWeatherSupportedLanguageCode()
        ]
        
        let resource = Resource<WeatherDTO>(url: url, parameters: parameters)
        
        do {
            return try await apiClient.execute(resource).toDomain()
        } catch let apiError as APIError {
            throw RepositoryErrorMapper.mapToDomainError(apiError)
        } catch {
            throw DomainError.unknown
        }
    }
}
