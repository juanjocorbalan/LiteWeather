import XCTest

@MainActor
final class WeatherViewUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    private func configureApp(with scenarios: [String] = []) {
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"] + scenarios
    }

    // MARK: - Success Scenarios

    func testSuccessScenario_Madrid_DisplaysWeatherData() {
        let arguments = ["--scenario=success-madrid"]
        configureApp(with: arguments)
        app.launch()

        // Wait for location name to appear (indicates content is loaded)
        let locationName = app.staticTexts["weather.location.name"]
        XCTAssertTrue(locationName.waitForExistence(timeout: 2))
        XCTAssertEqual(locationName.label, "Madrid, ES")

        // Verify weather data is displayed
        XCTAssertTrue(app.staticTexts["weather.temperature.current"].exists)
        XCTAssertTrue(app.staticTexts["weather.wind.speed"].exists)
        XCTAssertTrue(app.staticTexts["weather.humidity"].exists)
    }

    // MARK: - Error Scenarios

    func testErrorScenario_DisplaysErrorView() {
        let arguments = [
            "--scenario=error-unknown"
        ]
        configureApp(with: arguments)
        app.launch()

        // Verify reload button appears
        let reloadButton = app.buttons["action.reload"]
        XCTAssertTrue(reloadButton.waitForExistence(timeout: 2))

        // Verify location name does NOT exist (not loaded)
        XCTAssertFalse(app.staticTexts["weather.location.name"].exists)
    }

    // MARK: - Loading Scenarios

    func testSlowLoadingScenario_WithCustomDelay_ShowsLoadingIndicator() {
        let arguments = [
            "--scenario=success-madrid",
            "--delay=2.0"
        ]
        configureApp(with: arguments)
        app.launch()

        // Content should not appear immediately (within first second)
        let locationName = app.staticTexts["weather.location.name"]
        XCTAssertFalse(locationName.waitForExistence(timeout: 0.5))

        // But should appear after the full delay (give it 2.5s more to be safe)
        XCTAssertTrue(locationName.waitForExistence(timeout: 2.5))
    }

    // MARK: - Navigation to Current Location

    func testNavigationToCurrentLocation_ButtonExists() {
        let arguments = ["--scenario=success-madrid"]
        configureApp(with: arguments)
        app.launch()

        // Wait for initial view to load
        let locationName = app.staticTexts["weather.location.name"]
        XCTAssertTrue(locationName.waitForExistence(timeout: 2))

        // Verify current location button exists in toolbar
        let currentLocationButton = app.buttons["action.currentLocation"]
        XCTAssertTrue(currentLocationButton.exists)
    }
}
