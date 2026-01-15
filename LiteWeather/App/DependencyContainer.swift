import Foundation
import SwiftData
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

@MainActor
final class DependencyContainer {
    private let modelContainer: ModelContainer
    private let persistenceClient: any PersistenceClient<Weather, WeatherQueryBuilder>
    private let apiClient: APIClient
    private let localeProvider: LocaleProvider
    private let randomCoordinatesProvider: CoordinatesProvider
    private let userLocationProvider: CoordinatesProvider
    private let isUITesting: Bool

    let shouldSkipUI: Bool

    init() {
        #if DEBUG
        self.shouldSkipUI = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
        self.isUITesting = UITestingHelper.isUITesting
        #else
        self.shouldSkipUI = false
        self.isUITesting = false
        #endif

        self.apiClient = URLSessionAPIClient(
            configuration: .default,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 30,
            retryPolicy: .default
        )

        let schema = Schema([WeatherCacheModel.self, WeatherConditionModel.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: self.shouldSkipUI || self.isUITesting)
        do {
            self.modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }

        self.persistenceClient = SwiftDataPersistenceClient(modelContainer: modelContainer)
        self.localeProvider = SystemLocaleProvider()
        self.randomCoordinatesProvider = RandomCoordinatesProvider()
        self.userLocationProvider = CLLocationProvider()
    }

    func resolveWeatherViewModel(weatherType: WeatherType, eventHandler: WeatherEventHandler) -> WeatherViewModel {
        #if DEBUG
        if isUITesting {
            let scenario = UITestingHelper.currentScenario ?? .successMadrid
            let delay = UITestingHelper.delay
            return WeatherViewModel(
                weatherType: weatherType,
                getWeatherUseCase: resolve(for: scenario, delay: delay),
                localeProvider: MockLocaleProvider(),
                eventHandler: eventHandler
            )
        }
        #endif

        return WeatherViewModel(
            weatherType: weatherType,
            getWeatherUseCase: resolveWeatherUseCase(weatherType: weatherType),
            localeProvider: localeProvider,
            eventHandler: eventHandler
        )
    }
    
    func resolve() -> WeatherRepository {
        WeatherRepositoryImpl(apiClient: apiClient, localeProvider: localeProvider)
    }
    
    func resolve() -> GetCurrentWeatherUseCase {
        GetCurrentWeatherUseCaseImpl(weatherRepository: resolve())
    }
    
    func resolveWeatherUseCase(weatherType: WeatherType) -> GetWeatherAtLocationUseCase {
        let coordinatesProvider = weatherType == .currentLocation
        ? userLocationProvider
        : randomCoordinatesProvider
        return GetWeatherAtLocationUseCaseImpl(coordinatesProvider: coordinatesProvider,
                                               getCurrentWeather: resolve())
    }
}

#if DEBUG
extension DependencyContainer {
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
}
#endif
