import Foundation

// MARK: - Core App Events (Enum for Exhaustiveness)

/// Core application events that flow through the navigation hierarchy.
enum CoreAppEvent: AppEvent {
    /// Navigate to current device location weather
    case showCurrentLocationWeather

    /// Deep link received from URL or push notification
    case deeplink(Deeplink)

    /// Restart the app flow
    case restart
}

// MARK: - Deeplink Destinations

/// Deeplink destinations for universal links or programmatic navigation
enum Deeplink {
    case currentLocationWeather
}
