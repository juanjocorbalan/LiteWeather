import Foundation
import Data
import Domain
import SwiftData

enum WeatherType {
    case currentLocation
    case randomLocation
}

final class DependencyContainer {
    let isRunningUnitTests: Bool
    let apiClient: APIClient
    let localeProvider: LocaleProvider
    let randomCoordinatesProvider: CoordinatesProvider
    let userLocationProvider: CoordinatesProvider

    init() {
        self.isRunningUnitTests = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil

        self.apiClient = URLSessionAPIClient(
            configuration: .default,
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: 30,
            retryPolicy: .default
        )

        self.localeProvider = SystemLocaleProvider()
        self.randomCoordinatesProvider = RandomCoordinatesProvider()
        self.userLocationProvider = CLLocationProvider()
    }
    
    func resolve() -> WeatherRepository {
        WeatherRepositoryImpl(apiClient: apiClient, localeProvider: localeProvider)
    }
    
    func resolve() -> GetCurrentWeatherUseCase {
        GetCurrentWeatherUseCaseImpl(weatherRepository: resolve())
    }

    func resolve(weatherType: WeatherType) -> GetWeatherAtLocationUseCase {
        let coordinatesProvider = weatherType == .currentLocation
        ? userLocationProvider
        : randomCoordinatesProvider
        return GetWeatherAtLocationUseCaseImpl(coordinatesProvider: coordinatesProvider,
                                               getCurrentWeather: resolve())
    }
}
