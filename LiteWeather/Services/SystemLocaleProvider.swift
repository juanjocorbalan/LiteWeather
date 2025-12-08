import Foundation
import Domain

/// Provides locale configuration based on the system's current locale
final class SystemLocaleProvider: LocaleProvider {
    private let locale: Locale
    private let preferredLanguages: [String]

    init(locale: Locale = .current, preferredLanguages: [String]? = nil) {
        self.locale = locale
        self.preferredLanguages = preferredLanguages ?? Locale.preferredLanguages
    }

    var measurementSystem: MeasurementSystem {
        locale.measurementSystem == .metric ? .metric : .imperial
    }

    var language: String {
        let preferredLanguage = preferredLanguages.first ?? "es"
        let preferredLocale = Locale(identifier: preferredLanguage)
        return preferredLocale.language.languageCode?.identifier.lowercased() ?? "es"
    }

    var region: String {
        locale.region?.identifier.lowercased() ?? ""
    }
}
