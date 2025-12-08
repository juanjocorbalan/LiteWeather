import SwiftUI

struct MainView: View {
    let dependencies: DependencyContainer
    @Bindable var navigator: MainNavigator
    
    var body: some View {
        NavigationStack(path: $navigator.path) {
            EmptyView()
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            // call action to navigate
                        } label: {
                            Image(systemName: "location.circle")
                        }
                    }
                }
                .navigationDestination(for: MainNavigator.Route.self) { route in
                    switch route {
                    case .currentLocationWeather:
                        EmptyView()
                    }
                }
        }
    }
}
