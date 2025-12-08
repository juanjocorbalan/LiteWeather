import Testing
import Foundation
import DataTestingUtils
@testable import Data

@Suite("WeatherDTO Decoding Tests")
struct WeatherDTOTests {

    // MARK: - Real API Response Tests

    @Test("Decode complete Madrid weather response from real API data")
    func decodeMadridWeatherResponse() throws {
        // Given
        let data = Bundle.data(from: "madrid.json")

        // When
        let weather = try JSONDecoder().decode(WeatherDTO.self, from: data)

        // Then
        // Coordinates
        #expect(weather.coord.lon == -3.7062)
        #expect(weather.coord.lat == 40.4241)

        // Weather conditions
        #expect(weather.weather.count == 1)
        #expect(weather.weather[0].id == 800)
        #expect(weather.weather[0].main == "Clear")
        #expect(weather.weather[0].description == "cielo claro")
        #expect(weather.weather[0].icon == "01d")

        // Temperature and atmospheric data
        #expect(weather.main.temp == 10.17)
        #expect(weather.main.feelsLike == 9.12)
        #expect(weather.main.tempMin == 8.47)
        #expect(weather.main.tempMax == 11.19)
        #expect(weather.main.pressure == 1020)
        #expect(weather.main.humidity == 72)

        // Wind
        #expect(weather.wind.speed == 1.54)
        #expect(weather.wind.deg == 350)
        #expect(weather.wind.gust == nil)

        // System info
        #expect(weather.sys.country == "ES")
        #expect(weather.sys.sunrise == 1763449477)
        #expect(weather.sys.sunset == 1763484942)

        // Location
        #expect(weather.name == "Madrid City Center")
        #expect(weather.timezone == 3600)
    }

    @Test("Decode complete Rome weather response from real API data")
    func decodeRomeWeatherResponse() throws {
        // Given
        let data = Bundle.data(from: "roma.json")

        // When
        let weather = try JSONDecoder().decode(WeatherDTO.self, from: data)

        // Then
        #expect(weather.coord.lon == 12.4802)
        #expect(weather.coord.lat == 41.8902)

        // Cloudy weather (different from Madrid's clear)
        #expect(weather.weather[0].id == 802)
        #expect(weather.weather[0].main == "Clouds")
        #expect(weather.weather[0].description == "nubes dispersas")

        #expect(weather.main.temp == 16.3)
        #expect(weather.clouds.all == 40)
        #expect(weather.sys.country == "IT")
        #expect(weather.name == "Rome")
    }

    // MARK: - Custom Decoding Logic Tests

    @Test("Snake_case API fields are correctly mapped to camelCase properties")
    func snakeCaseToCamelCaseMapping() throws {
        // Given - API returns snake_case but our model uses camelCase
        let json = """
        {
            "coord": {"lon": 0, "lat": 0},
            "weather": [],
            "main": {
                "temp": 20.5,
                "feels_like": 19.0,
                "temp_min": 18.0,
                "temp_max": 22.0,
                "pressure": 1013,
                "humidity": 65
            },
            "wind": {"speed": 5.0, "deg": 180},
            "clouds": {"all": 50},
            "dt": 1234567890,
            "sys": {"country": "US", "sunrise": 1234567890, "sunset": 1234567890},
            "name": "Test City"
        }
        """.data(using: .utf8)!

        // When
        let weather = try JSONDecoder().decode(WeatherDTO.self, from: json)

        // Then - Verify our custom CodingKeys work correctly
        #expect(weather.main.feelsLike == 19.0)
        #expect(weather.main.tempMin == 18.0)
        #expect(weather.main.tempMax == 22.0)
    }

    @Test("Optional fields can be missing without breaking decoding")
    func optionalFieldsHandling() throws {
        // Given - Minimal valid response without optional fields
        let json = """
        {
            "coord": {"lon": 0, "lat": 0},
            "weather": [],
            "main": {
                "temp": 20.5,
                "feels_like": 19.0,
                "temp_min": 18.0,
                "temp_max": 22.0,
                "pressure": 1013,
                "humidity": 65
            },
            "wind": {"speed": 5.0, "deg": 180},
            "clouds": {"all": 50},
            "dt": 1234567890,
            "sys": {"country": "US", "sunrise": 1234567890, "sunset": 1234567890},
            "name": "Test City"
        }
        """.data(using: .utf8)!

        // When
        let weather = try JSONDecoder().decode(WeatherDTO.self, from: json)

        // Then - Verify optional fields are nil but decoding succeeds
        #expect(weather.base == nil)
        #expect(weather.visibility == nil)
        #expect(weather.timezone == nil)
        #expect(weather.id == nil)
        #expect(weather.cod == nil)
        #expect(weather.sys.type == nil)
        #expect(weather.sys.id == nil)
        #expect(weather.wind.gust == nil)

        // And required fields are present
        #expect(weather.name == "Test City")
        #expect(weather.main.temp == 20.5)
    }

    @Test("Multiple weather conditions are handled as array")
    func multipleWeatherConditions() throws {
        // Given - Response with multiple simultaneous weather conditions
        let json = """
        {
            "coord": {"lon": 0, "lat": 0},
            "weather": [
                {
                    "id": 500,
                    "main": "Rain",
                    "description": "light rain",
                    "icon": "10d"
                },
                {
                    "id": 701,
                    "main": "Mist",
                    "description": "mist",
                    "icon": "50d"
                }
            ],
            "main": {
                "temp": 20.5,
                "feels_like": 19.0,
                "temp_min": 18.0,
                "temp_max": 22.0,
                "pressure": 1013,
                "humidity": 65
            },
            "wind": {"speed": 5.0, "deg": 180},
            "clouds": {"all": 50},
            "dt": 1234567890,
            "sys": {"country": "US", "sunrise": 1234567890, "sunset": 1234567890},
            "name": "Test City"
        }
        """.data(using: .utf8)!

        // When
        let weather = try JSONDecoder().decode(WeatherDTO.self, from: json)

        // Then
        #expect(weather.weather.count == 2)
        #expect(weather.weather[0].main == "Rain")
        #expect(weather.weather[0].description == "light rain")
        #expect(weather.weather[1].main == "Mist")
        #expect(weather.weather[1].description == "mist")
    }
}
