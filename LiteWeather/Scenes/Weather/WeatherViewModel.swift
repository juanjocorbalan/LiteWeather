import Foundation
import Observation
import Data
import Domain

// MARK: - Event Handler Protocol

/// Protocol for handling weather-related navigation events.
protocol WeatherEventHandler: AnyObject {
    func navigateToCurrentLocationWeather()
}

// MARK: - View State

enum WeatherViewState: Equatable {
    case loading
    case loaded(WeatherPresentationModel)
    case error(LocalizedError)

    static func == (lhs: WeatherViewState, rhs: WeatherViewState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.loaded(let lhsItems), .loaded(let rhsItems)):
            return lhsItems == rhsItems
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

@MainActor @Observable
final class WeatherViewModel {
    private let getWeatherUseCase: GetWeatherAtLocationUseCase
    private let localeProvider: LocaleProvider
    private let eventHandler: WeatherEventHandler

    // MARK: - Outputs

    private(set) var title: String
    private(set) var isReloading: Bool = false
    private(set) var state: WeatherViewState = .loading

    // MARK: - Init

    init(
        weatherType: WeatherType,
        getWeatherUseCase: GetWeatherAtLocationUseCase,
        localeProvider: LocaleProvider,
        eventHandler: WeatherEventHandler
    ) {
        self.title = String(localized: weatherType == .randomLocation ? "app_title" : "weather_at_location_title")
        self.getWeatherUseCase = getWeatherUseCase
        self.localeProvider = localeProvider
        self.eventHandler = eventHandler
    }

    // MARK: - Private utils

    private func updateState(with currentWeather: Weather) {
        let presentationModel = WeatherPresentationModel(
            weather: currentWeather,
            measurementSystem: localeProvider.measurementSystem
        )
        state = .loaded(presentationModel)
    }

    private func handleError(_ error: DomainError) {
        state = .error(error)
    }

    @concurrent private func getSimpleWeather() async throws(DomainError) -> Weather {
        try await getWeatherUseCase.execute()
    }

    // MARK: - UI Actions

    func reload() async {
        if case .loaded = state {
            isReloading = true
        } else {
            state = .loading
        }

        do {
            let currentWeather = try await getSimpleWeather()
            updateState(with: currentWeather)
        } catch {
            handleError(error)
        }

        isReloading = false
    }

    func currentLocationWeatherRequested() {
        eventHandler.navigateToCurrentLocationWeather()
    }
}
