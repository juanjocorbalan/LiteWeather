import Foundation
import Data

public final class MockLocaleProvider: LocaleProvider, @unchecked Sendable {
    public let measurementSystem: MeasurementSystem
    public let language: String
    public let region: String

    public init(measurementSystem: MeasurementSystem = .metric,
                language: String = "en",
                region: String = "US") {
        self.measurementSystem = measurementSystem
        self.language = language
        self.region = region
    }
}
