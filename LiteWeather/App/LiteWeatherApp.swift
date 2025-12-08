import SwiftUI

@main
struct LiteWeatherApp: App {
    let dependencies = DependencyContainer()
    @State var navigator = MainNavigator()

    var body: some Scene {
        WindowGroup {
            if dependencies.isRunningUnitTests {
                Text("Running Unit Tests -> No UI needed")
            } else {
                MainView(dependencies: dependencies, navigator: navigator)
            }
        }
    }
}
