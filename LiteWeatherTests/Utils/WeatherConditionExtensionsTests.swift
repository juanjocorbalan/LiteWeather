import Testing
import SwiftUI
import Domain
@testable import LiteWeather

struct WeatherConditionExtensionsTests {

    // MARK: - SF Symbol Mapping Tests

    @Test func sfSymbol_clearSkyDay_returnsSunMaxFill() {
        let condition = WeatherCondition(type: .clearSky, timeOfDay: .day, description: "clear sky")

        #expect(condition.sfSymbol == "sun.max.fill")
    }

    @Test func sfSymbol_clearSkyNight_returnsMoonStarsFill() {
        let condition = WeatherCondition(type: .clearSky, timeOfDay: .night, description: "clear sky")

        #expect(condition.sfSymbol == "moon.stars.fill")
    }

    @Test func sfSymbol_fewCloudsDay_returnsCloudSunFill() {
        let condition = WeatherCondition(type: .fewClouds, timeOfDay: .day, description: "few clouds")

        #expect(condition.sfSymbol == "cloud.sun.fill")
    }

    @Test func sfSymbol_fewCloudsNight_returnsCloudMoonFill() {
        let condition = WeatherCondition(type: .fewClouds, timeOfDay: .night, description: "few clouds")

        #expect(condition.sfSymbol == "cloud.moon.fill")
    }

    @Test func sfSymbol_scatteredClouds_returnsCloudFill() {
        let condition = WeatherCondition(type: .scatteredClouds, timeOfDay: .day, description: "scattered clouds")

        #expect(condition.sfSymbol == "cloud.fill")
    }

    @Test func sfSymbol_brokenClouds_returnsSmokeFill() {
        let condition = WeatherCondition(type: .brokenClouds, timeOfDay: .day, description: "broken clouds")

        #expect(condition.sfSymbol == "smoke.fill")
    }

    @Test func sfSymbol_showerRain_returnsCloudRainFill() {
        let condition = WeatherCondition(type: .showerRain, timeOfDay: .day, description: "shower rain")

        #expect(condition.sfSymbol == "cloud.rain.fill")
    }

    @Test func sfSymbol_rainDay_returnsCloudSunRainFill() {
        let condition = WeatherCondition(type: .rain, timeOfDay: .day, description: "rain")

        #expect(condition.sfSymbol == "cloud.sun.rain.fill")
    }

    @Test func sfSymbol_rainNight_returnsCloudMoonRainFill() {
        let condition = WeatherCondition(type: .rain, timeOfDay: .night, description: "rain")

        #expect(condition.sfSymbol == "cloud.moon.rain.fill")
    }

    @Test func sfSymbol_thunderstorm_returnsCloudBoltRainFill() {
        let condition = WeatherCondition(type: .thunderstorm, timeOfDay: .day, description: "thunderstorm")

        #expect(condition.sfSymbol == "cloud.bolt.rain.fill")
    }

    @Test func sfSymbol_snow_returnsSnowflake() {
        let condition = WeatherCondition(type: .snow, timeOfDay: .day, description: "snow")

        #expect(condition.sfSymbol == "snowflake")
    }

    @Test func sfSymbol_mist_returnsCloudFogFill() {
        let condition = WeatherCondition(type: .mist, timeOfDay: .day, description: "mist")

        #expect(condition.sfSymbol == "cloud.fog.fill")
    }

    @Test func sfSymbol_unknownCode_returnsQuestionmarkCircle() {
        let condition = WeatherCondition(type: .unknown, timeOfDay: .day, description: "unknown")

        #expect(condition.sfSymbol == "questionmark.circle")
    }

    // MARK: - Symbol Color Tests

    @Test func symbolColor_clearSkyDay_returnsYellow() {
        let condition = WeatherCondition(type: .clearSky, timeOfDay: .day, description: "clear sky")

        #expect(condition.symbolColor == .yellow)
    }

    @Test func symbolColor_clearSkyNight_returnsIndigo() {
        let condition = WeatherCondition(type: .clearSky, timeOfDay: .night, description: "clear sky")

        #expect(condition.symbolColor == .indigo)
    }

    @Test func symbolColor_clouds_returnsGray() {
        let condition = WeatherCondition(type: .scatteredClouds, timeOfDay: .day, description: "scattered clouds")

        #expect(condition.symbolColor == .gray)
    }

    @Test func symbolColor_rain_returnsBlue() {
        let condition = WeatherCondition(type: .rain, timeOfDay: .day, description: "rain")

        #expect(condition.symbolColor == .blue)
    }

    @Test func symbolColor_thunderstorm_returnsPurple() {
        let condition = WeatherCondition(type: .thunderstorm, timeOfDay: .day, description: "thunderstorm")

        #expect(condition.symbolColor == .purple)
    }

    @Test func symbolColor_snow_returnsCyan() {
        let condition = WeatherCondition(type: .snow, timeOfDay: .day, description: "snow")

        #expect(condition.symbolColor == .cyan)
    }

    @Test func symbolColor_mist_returnsSecondary() {
        let condition = WeatherCondition(type: .mist, timeOfDay: .day, description: "mist")

        #expect(condition.symbolColor == .secondary)
    }

    @Test func symbolColor_unknownCode_returnsPrimary() {
        let condition = WeatherCondition(type: .unknown, timeOfDay: .day, description: "unknown")

        #expect(condition.symbolColor == .primary)
    }
}
