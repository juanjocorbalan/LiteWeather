import Testing
import Foundation
import Domain
import DomainTestingUtils
@testable import LiteWeather

@MainActor
struct FormattingExtensionsTests {

    // MARK: - Coordinates Formatting Tests

    @Test func coordinates_formatted_returnsCorrectFormat() {
        let formatted = Coordinates.madrid.formatted

        #expect(formatted == "40.4168, -3.7038")
    }

    @Test func coordinates_formatted_withNegativeLatitude_returnsCorrectFormat() {
        let coordinates = Coordinates(latitude: -33.8688, longitude: 151.2093)

        let formatted = coordinates.formatted

        #expect(formatted == "-33.8688, 151.2093")
    }

    @Test func coordinates_formatted_withZeroCoordinates_returnsCorrectFormat() {
        let formatted = Coordinates.zero.formatted

        #expect(formatted == "0.0000, 0.0000")
    }

    @Test func coordinates_formatted_roundsToFourDecimals() {
        let coordinates = Coordinates(latitude: 40.416789123, longitude: -3.703845678)

        let formatted = coordinates.formatted

        #expect(formatted == "40.4168, -3.7038")
    }

    // MARK: - Location Display Name Tests

    @Test func location_displayName_withNameAndCountry_returnsCombined() {
        let location = Location(
            name: "Madrid",
            country: "ES",
            sunrise: Date(),
            sunset: Date(),
            timezoneOffset: 3600
        )

        #expect(location.displayName == "Madrid, ES")
    }

    @Test func location_displayName_withEmptyName_returnsOnlyCountry() {
        let location = Location(
            name: "",
            country: "ES",
            sunrise: Date(),
            sunset: Date(),
            timezoneOffset: 3600
        )

        #expect(location.displayName == "ES")
    }

    @Test func location_displayName_withOnlyCountry_returnsCountry() {
        let location = Location(
            name: "",
            country: "US",
            sunrise: Date(),
            sunset: Date(),
            timezoneOffset: -18000
        )

        #expect(location.displayName == "US")
    }

    // MARK: - Location Time Formatting Tests

    @Test func location_sunriseFormatted_appliesCorrectTimezone() {
        // Unix timestamp: 1700035200 = 2023-11-15 08:00:00 UTC
        let sunriseUTC = Date(timeIntervalSince1970: 1700035200)

        // Madrid timezone: UTC+1 (3600 seconds)
        let madridLocation = Location(
            name: "Madrid",
            country: "ES",
            sunrise: sunriseUTC,
            sunset: Date(),
            timezoneOffset: 3600
        )

        let formattedMadrid = madridLocation.sunriseFormatted
        // 08:00 UTC = 09:00 in Madrid (UTC+1)
        #expect(formattedMadrid == "09:00")
    }

    @Test func location_sunsetFormatted_appliesCorrectTimezone() {
        // Unix timestamp: 1700070000 = 2023-11-15 17:40:00 UTC
        let sunsetUTC = Date(timeIntervalSince1970: 1700070000)

        // Madrid timezone: UTC+1 (3600 seconds)
        let madridLocation = Location(
            name: "Madrid",
            country: "ES",
            sunrise: Date(),
            sunset: sunsetUTC,
            timezoneOffset: 3600
        )

        let formattedMadrid = madridLocation.sunsetFormatted
        // 17:40 UTC = 18:40 in Madrid (UTC+1)
        #expect(formattedMadrid == "18:40")
    }

    // MARK: - Wind Speed Formatting Tests

    @Test func wind_speedFormatted_withMetric_convertsToKmh() {
        let formatted = Weather.madrid.windSpeedFormatted(measurementSystem: .metric)

        #expect(formatted.contains("18"))
        #expect(formatted.contains("km/h"))
    }
}
