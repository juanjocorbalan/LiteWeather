import Foundation

// MARK: - Event Protocol

/// Base protocol for application events.
protocol AppEvent {}

// MARK: - Event Handler Protocol

/// Protocol for handling application events in a chain of responsibility pattern.
///
/// ## Event Flow (Default: Local → Up)
/// 1. Event is sent via `handle(event)`
/// 2. Tries to handle locally via `handleLocally()`
/// 3. If not handled (returns `false`), propagates up via `sendUp()`
/// 4. Optionally broadcast down to children via `sendDown()`
protocol EventHandler: AnyObject {
    /// Parent handler in the chain (events flow upward by default)
    var parent: (any EventHandler)? { get set }

    /// Child handlers in the chain (for broadcasting downward)
    var children: [any EventHandler] { get set }

    /// Handle an event locally.
    /// - Returns: `true` if event was consumed (stops propagation), `false` otherwise
    func handleLocally(_ event: AppEvent) -> Bool

    /// Send event up to parent handler.
    /// - Returns: `true` if event was handled by parent or ancestor, `false` otherwise
    func sendUp(_ event: AppEvent) -> Bool

    /// Send event down to child handlers.
    /// - Returns: `true` if event was handled by any child, `false` otherwise
    func sendDown(_ event: AppEvent) -> Bool

    /// Primary entry point for handling events.
    /// - Returns: `true` if event was handled anywhere in the chain, `false` otherwise
    @discardableResult
    func handle(_ event: AppEvent) -> Bool
}

// MARK: - Default Implementations

extension EventHandler {
    /// Default implementation: try local handling, then propagate up
    @discardableResult
    func handle(_ event: AppEvent) -> Bool {
        if handleLocally(event) { return true }
        return sendUp(event)
    }

    /// Default implementation: no parent to send to
    func sendUp(_ event: AppEvent) -> Bool {
        return parent?.handle(event) ?? false
    }

    /// Default implementation: broadcast to all children until one handles it
    func sendDown(_ event: AppEvent) -> Bool {
        for child in children {
            if child.handle(event) {
                return true
            }
        }
        return false
    }

    /// Add a child handler and establish parent relationship
    func addChild(_ child: any EventHandler) {
        guard !children.contains(where: { $0 === child }) else { return }
        children.append(child)
        child.parent = self
    }

    /// Remove a child handler and clear parent relationship
    func removeChild(_ child: any EventHandler) {
        children.removeAll { $0 === child }
        child.parent = nil
    }
}

// MARK: - Navigator

/// Type-safe navigation container using SwiftUI's NavigationStack
@Observable
class BaseNavigator<Route: Hashable>: EventHandler {
    var path: [Route] = []

    // MARK: - Event Handler Chain

    weak var parent: (any EventHandler)?
    var children: [any EventHandler] = []

    /// Override this method in subclasses to handle specific events locally.
    /// - Returns: `true` if event was handled, `false` to propagate up
    func handleLocally(_ event: AppEvent) -> Bool {
        false
    }

    // MARK: - Navigation API

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
final class MainNavigator: BaseNavigator<MainNavigator.Route> {
    enum Route: Hashable {
        case currentLocationWeather
    }

    // MARK: - Event Handling

    override func handleLocally(_ event: AppEvent) -> Bool {
        if let coreEvent = event as? CoreAppEvent {
            switch coreEvent {
            case .showCurrentLocationWeather:
                navigateToCurrentWeather()
                return true
                
            case .deeplink(let deeplink):
                return handleDeeplink(deeplink)

            // Let parent handle these
            case .restart:
                popToRoot()
                return true
            }
        }

        return false
    }

    // MARK: - Navigation

    func navigateToCurrentWeather() {
        push(.currentLocationWeather)
    }
    
    private func handleDeeplink(_ deeplink: Deeplink) -> Bool {
        switch deeplink {
        case .currentLocationWeather:
            navigateToCurrentWeather()
            return true
        }
    }
}

// MARK: - WeatherEventHandler

extension MainNavigator: WeatherEventHandler {
    func navigateToCurrentLocationWeather() {
        handle(CoreAppEvent.showCurrentLocationWeather)
    }
}

