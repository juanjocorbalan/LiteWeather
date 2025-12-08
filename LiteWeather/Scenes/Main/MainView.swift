import SwiftUI

struct MainView: View {
    let dependencies: DependencyContainer
    @Bindable var navigator: MainNavigator
    
    var body: some View {
        NavigationStack(path: $navigator.path) {
            let viewModel = dependencies.resolve(navigator: navigator, weatherType: .randomLocation)
            WeatherView(viewModel: viewModel)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            viewModel.goToCurrentLocationWeather()
                        } label: {
                            Image(systemName: "location.circle")
                        }
                        .accessibilityIdentifier(AccessibilityIdentifiers.Actions.currentLocationButton)
                    }
                }
                .navigationDestination(for: MainNavigator.Route.self) { route in
                    switch route {
                    case .currentLocationWeather:
                        WeatherView(viewModel: dependencies.resolve(navigator: navigator,
                                                                    weatherType: .currentLocation))
                    }
                }
        }
    }
}
