import SwiftUI

struct MainView: View {
    let dependencies: DependencyContainer
    @Bindable var navigator: MainNavigator
    @State private var rootViewModel: WeatherViewModel

    init(dependencies: DependencyContainer, navigator: MainNavigator) {
        self.dependencies = dependencies
        self.navigator = navigator
        self._rootViewModel = State(initialValue: dependencies.resolve(navigator: navigator,
                                                                       weatherType: .randomLocation))
    }

    var body: some View {
        NavigationStack(path: $navigator.path) {
            WeatherView(viewModel: rootViewModel)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            rootViewModel.goToCurrentLocationWeather()
                        } label: {
                            Image(systemName: "location.circle")
                        }
                        .accessibilityIdentifier(AccessibilityIdentifiers.Actions.currentLocationButton)
                    }
                }
                .navigationDestination(for: MainNavigator.Route.self) { route in
                    switch route {
                    case .currentLocationWeather:
                        WeatherView(viewModel: dependencies.resolve(
                            navigator: navigator,
                            weatherType: .currentLocation
                        ))
                    }
                }
        }
    }
}
