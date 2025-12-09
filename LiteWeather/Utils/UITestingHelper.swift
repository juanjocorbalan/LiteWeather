#if DEBUG
import Foundation
import Domain

/// Helper for UI Testing scenarios
///
/// This enum is used **ONLY for UI tests** to configure the app behavior via launch arguments.
/// It is integrated with `DependencyContainer` to inject mocks during UI testing.
///
/// ```swift
/// app.launchArguments = ["--uitesting", "--scenario=success-madrid"]
/// ```
enum UITestingHelper {
    /// Testing scenarios
    enum Scenario: String {
        case successMadrid = "success-madrid"
        case successLondon = "success-london"
        case successNewYork = "success-newyork"
        case errorUnknown = "error-unknown"
        case errorUnauthorized = "error-unauthorized"
        case errorInvalidData = "error-invaliddata"
        case errorUnavailable = "error-unavailable"

        var launchArgument: String {
            "--scenario=\(rawValue)"
        }
    }

    /// Detect UI testing mode
    static var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("--uitesting")
    }

    /// Get the active scenario from launch arguments
    static var currentScenario: Scenario? {
        guard isUITesting else { return nil }

        let scenarioArg = ProcessInfo.processInfo
            .arguments
            .first { $0.hasPrefix("--scenario=") }

        guard let arg = scenarioArg else { return .successMadrid }

        let scenarioValue = arg.replacingOccurrences(of: "--scenario=", with: "")
        return Scenario(rawValue: scenarioValue)
    }

    /// Delay for testing (nanoseconds)
    static var delay: UInt64? {
        let delayArg = ProcessInfo.processInfo.arguments.first { $0.hasPrefix("--delay=") }

        guard let arg = delayArg else { return nil }

        let delayValue = arg.replacingOccurrences(of: "--delay=", with: "")
        guard let seconds = Double(delayValue) else { return nil }
        return UInt64(seconds * 1_000_000_000)
    }
}
#endif
