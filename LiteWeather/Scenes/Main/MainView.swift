import SwiftUI

struct MainView: View {
    let dependencies: DependencyContainer
    @Bindable var navigator: MainNavigator
    
    var body: some View {
        NavigationStack(path: $navigator.path) {
            WeatherView(viewModel:
                            dependencies.resolveWeatherViewModel(weatherType: .randomLocation,
                                                                 eventHandler: navigator)
            )
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        navigator.handle(CoreAppEvent.showCurrentLocationWeather)
                    } label: {
                        Image(systemName: "location.circle")
                    }
                    .accessibilityIdentifier(AccessibilityIdentifiers.Actions.currentLocationButton)
                }
            }
            .navigationDestination(for: MainNavigator.Route.self) { route in
                switch route {
                case .currentLocationWeather:
                    WeatherView(viewModel:
                                    dependencies.resolveWeatherViewModel(weatherType: .currentLocation,
                                                                         eventHandler: navigator)
                    )
                }
            }
        }
    }
}
