import Testing
import Foundation
import Domain
import DomainTestingUtils
@testable import LiteWeather

class WeatherViewModelTests {
    private let mockGetWeatherAtLocationUseCase = MockGetWeatherAtLocationUseCase()
    private let mockNavigator = MainNavigator()
    private let mockLocaleProvider = MockLocaleProvider()

    private func createViewModel(weatherType: WeatherType = .randomLocation) -> WeatherViewModel {
        return WeatherViewModel(weatherType: weatherType,
                                getWeatherUseCase: mockGetWeatherAtLocationUseCase,
                                localeProvider: mockLocaleProvider,
                                navigator: mockNavigator)
    }

    // MARK: - Initial State Tests

    @Test func initialState_isLoading() {
        let viewModel = createViewModel()

        #expect(viewModel.state == .loading)
        #expect(viewModel.title == String(localized: "app_title"))
    }

    @Test func initialState_randomLocation_hasCorrectTitle() {
        let viewModel = createViewModel(weatherType: .randomLocation)

        #expect(viewModel.title == String(localized: "app_title"))
    }

    @Test func initialState_currentLocation_hasCorrectTitle() {
        let viewModel = createViewModel(weatherType: .currentLocation)

        #expect(viewModel.title == String(localized: "weather_at_location_title"))
    }

    // MARK: - Reload Tests

    @Test func reload_onSuccess_setsLoadedState() async throws {
        let viewModel = createViewModel()
        mockGetWeatherAtLocationUseCase.stubbedResult = .success(Weather.london)
        let expectedResult = WeatherPresentationModel(weather: Weather.london, measurementSystem: .metric)

        await viewModel.reload()
        
        #expect(viewModel.state == .loaded(expectedResult))
    }

    @Test func reload_onFailure_setsErrorState() async throws {
        let viewModel = createViewModel()
        let expectedError = DomainError.unavailable
        mockGetWeatherAtLocationUseCase.stubbedResult = .failure(expectedError)

        await viewModel.reload()

        if case .error(let error) = viewModel.state {
            #expect(error.localizedDescription == expectedError.localizedDescription)
        } else {
            Issue.record("Expected error state")
        }
    }

    @Test func reload_setsReloadingFlagDuringExecution() async throws {
        let viewModel = createViewModel()

        mockGetWeatherAtLocationUseCase.stubbedResult = .success(Weather.london)
        await viewModel.reload()
        mockGetWeatherAtLocationUseCase.stubbedResult = .success(Weather.rome)

        var reloadingFlagWasSet = false

        await confirmation { confirmation in
            _ = withObservationTracking {
                viewModel.isReloading
            } onChange: {
                Task { @MainActor in
                    if viewModel.isReloading {
                        reloadingFlagWasSet = true
                    }
                }
                confirmation()
            }

            await viewModel.reload()
        }

        #expect(reloadingFlagWasSet == true)
        #expect(viewModel.isReloading == false)
    }

    @Test func reload_multipleConsecutiveCalls_handlesCorrectly() async throws {
        let viewModel = createViewModel()
        mockGetWeatherAtLocationUseCase.stubbedResult = .success(Weather.london)

        await viewModel.reload()
        let firstState = viewModel.state

        mockGetWeatherAtLocationUseCase.stubbedResult = .success(Weather.rome)
        await viewModel.reload()
        let secondState = viewModel.state
        let expectedResult = WeatherPresentationModel(weather: Weather.rome, measurementSystem: .metric)

        #expect(firstState != secondState)
        #expect(viewModel.state == .loaded(expectedResult))
    }

    @Test func reload_usesCorrectMeasurementSystem() async throws {
        let imperialLocaleProvider = MockLocaleProvider(measurementSystem: .imperial)
        let viewModel = WeatherViewModel(
            weatherType: .randomLocation,
            getWeatherUseCase: mockGetWeatherAtLocationUseCase,
            localeProvider: imperialLocaleProvider,
            navigator: mockNavigator
        )
        mockGetWeatherAtLocationUseCase.stubbedResult = .success(Weather.london)

        await viewModel.reload()

        if case .loaded(let model) = viewModel.state {
            #expect(model.currentTemperature.contains("°F"))
        } else {
            Issue.record("Expected loaded state")
        }
    }

    @Test func reload_mapsAllDomainErrorsCorrectly() async throws {
        let errors: [DomainError] = [.unauthorized, .invalidData, .unavailable, .unknown]

        for error in errors {
            let viewModel = createViewModel()
            mockGetWeatherAtLocationUseCase.stubbedResult = .failure(error)

            await viewModel.reload()

            if case .error(let stateError) = viewModel.state {
                #expect(stateError.localizedDescription == error.localizedDescription)
            } else {
                Issue.record("Expected error state for error: \(error)")
            }
        }
    }

    @Test func reload_recoversFromErrorToSuccess() async throws {
        let viewModel = createViewModel()
        mockGetWeatherAtLocationUseCase.stubbedResult = .failure(.unavailable)

        await viewModel.reload()

        if case .error(let error) = viewModel.state {
            #expect(error.localizedDescription == DomainError.unavailable.localizedDescription)
        } else {
            Issue.record("Expected error state")
        }

        mockGetWeatherAtLocationUseCase.stubbedResult = .success(Weather.london)
        await viewModel.reload()

        if case .loaded = viewModel.state {
            // Recovered from error
        } else {
            Issue.record("Expected loaded state after recovery")
        }
    }

    // MARK: - Navigation Tests

    @Test func goToCurrentLocationWeather_addsRouteToNavigator() {
        let viewModel = createViewModel()

        viewModel.goToCurrentLocationWeather()

        #expect(mockNavigator.path.count == 1)
        #expect(mockNavigator.path.first == .currentLocationWeather)
    }

    @Test func navigation_doesNotAffectCurrentState() async throws {
        let viewModel = createViewModel()
        mockGetWeatherAtLocationUseCase.stubbedResult = .success(Weather.madrid)
        await viewModel.reload()

        let stateBefore = viewModel.state

        viewModel.goToCurrentLocationWeather()

        #expect(viewModel.state == stateBefore)
    }
}
