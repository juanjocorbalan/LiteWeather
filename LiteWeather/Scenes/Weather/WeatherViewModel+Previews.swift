#if DEBUG
import Foundation
import Domain
import DataTestingUtils
import DomainTestingUtils

// MARK: - Preview Helpers

extension WeatherViewModel {
    /// Creates a WeatherViewModel for SwiftUI previews with Madrid weather
    static func preview(
        weatherType: WeatherType = .randomLocation,
        useCase: MockGetWeatherAtLocationUseCase = .madrid(),
        locale: MockLocaleProvider = MockLocaleProvider(),
        navigator: MainNavigator = MainNavigator()
    ) -> WeatherViewModel {
        WeatherViewModel(
            weatherType: weatherType,
            getWeatherUseCase: useCase,
            localeProvider: locale,
            navigator: navigator
        )
    }
}

// MARK: - Common Preview Scenarios

extension WeatherViewModel {
    /// Madrid weather preview
    static var previewMadrid: WeatherViewModel {
        .preview(useCase: .madrid())
    }

    /// London weather preview
    static var previewLondon: WeatherViewModel {
        .preview(useCase: .london())
    }

    /// New York weather preview
    static var previewNewYork: WeatherViewModel {
        .preview(useCase: .newYork())
    }

    /// Rome weather preview
    static var previewRome: WeatherViewModel {
        .preview(useCase: .rome())
    }

    /// Error - Unknown
    static var previewErrorUnknown: WeatherViewModel {
        .preview(useCase: .errorUnknown())
    }

    /// Error - Unavailable
    static var previewErrorUnavailable: WeatherViewModel {
        .preview(useCase: .errorUnavailable())
    }

    /// Error - Unauthorized
    static var previewErrorUnauthorized: WeatherViewModel {
        .preview(useCase: .errorUnauthorized())
    }

    /// Error - Invalid Data
    static var previewErrorInvalidData: WeatherViewModel {
        .preview(useCase: .errorInvalidData())
    }
}

#endif
