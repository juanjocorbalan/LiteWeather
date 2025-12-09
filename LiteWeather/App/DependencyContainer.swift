import Foundation
import Data
import Domain
#if DEBUG
import DataTestingUtils
import DomainTestingUtils
#endif

enum WeatherType {
    case currentLocation
    case randomLocation
}

final class DependencyContainer {
    let apiClient: APIClient
    let localeProvider: LocaleProvider
    let randomCoordinatesProvider: CoordinatesProvider
    let userLocationProvider: CoordinatesProvider
    let isRunningUnitTests: Bool

    #if DEBUG
    let isUITesting: Bool
    #endif

    init() {
        self.isRunningUnitTests = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
        #if DEBUG
        self.isUITesting = UITestingHelper.isUITesting
        #endif

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

    func resolve(navigator: MainNavigator, weatherType: WeatherType) -> WeatherViewModel {
        #if DEBUG
        if isUITesting {
            let scenario = UITestingHelper.currentScenario ?? .successMadrid
            let delay = UITestingHelper.delay
            return WeatherViewModel(
                weatherType: weatherType,
                getWeatherUseCase: resolve(for: scenario, delay: delay),
                localeProvider: MockLocaleProvider(),
                navigator: navigator
            )
        }
        #endif

        return WeatherViewModel(
            weatherType: weatherType,
            getWeatherUseCase: resolve(weatherType: weatherType),
            localeProvider: localeProvider,
            navigator: navigator
        )
    }

    #if DEBUG
    private func resolve(for scenario: UITestingHelper.Scenario,
                         delay: UInt64?) -> MockGetWeatherAtLocationUseCase {
        switch scenario {
        case .successMadrid:
            return .madrid(delay: delay)
        case .successLondon:
            return .london(delay: delay)
        case .successNewYork:
            return .newYork(delay: delay)
        case .errorUnknown:
            return .errorUnknown(delay: delay)
        case .errorUnavailable:
            return .errorUnavailable(delay: delay)
        case .errorUnauthorized:
            return .errorUnauthorized(delay: delay)
        case .errorInvalidData:
            return .errorInvalidData(delay: delay)
        }
    }
    #endif

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
