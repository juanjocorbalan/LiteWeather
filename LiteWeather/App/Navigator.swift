import Foundation

/// Type-safe navigation container using SwiftUI's NavigationStack
@Observable
class Navigator<Route: Hashable> {
    var path: [Route] = []

    // MARK: - Public API

    func push(_ route: Route) {
        path.append(route)
    }

    func navigateBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeAll()
    }
}

/// Primary app navigation
@Observable
final class MainNavigator: Navigator<MainNavigator.Route> {
    enum Route: Hashable {
        case currentLocationWeather
    }

    // MARK: - Navigation

    func navigateToCurrentWeather() {
        push(.currentLocationWeather)
    }
}
