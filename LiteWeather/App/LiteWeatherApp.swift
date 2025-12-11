import SwiftUI

@main
struct LiteWeatherApp: App {
    let dependencies = DependencyContainer()
    @State var navigator = MainNavigator()

    var body: some Scene {
        WindowGroup {
            if dependencies.shouldSkipUI {
                Text("Running Tests -> No UI needed")
            } else {
                MainView(dependencies: dependencies, navigator: navigator)
            }
        }
    }
}
