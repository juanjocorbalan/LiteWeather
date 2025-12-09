import Foundation
import Data
import Domain

// MARK: - Date Formatting Helpers

/// Formats a date with date and time components
private func formatDateTime(_ date: Date) -> String {
    let style = Date.FormatStyle(date: .abbreviated, time: .shortened)
    return date.formatted(style)
}

/// Formats a date as time only (HH:mm) in the specified timezone
private func formatTime(_ date: Date, in timeZone: TimeZone) -> String {
    var style = Date.FormatStyle()
    style.timeZone = timeZone
    return date.formatted(style.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits))
}

// MARK: - Coordinates Formatting

extension Weather {
    /// Formatted timestamp
    var timestampFormatted: String {
        formatDateTime(timestamp)
    }
    
    /// Formatted wind speed with unit (e.g., "15 km/h" or "9 mph")
    func windSpeedFormatted(measurementSystem: MeasurementSystem) -> String {
        let measurement: Measurement<UnitSpeed>
        if measurementSystem == .metric {
            measurement = Measurement(value: windSpeed, unit: .metersPerSecond).converted(to: .kilometersPerHour)
        } else {
            measurement = Measurement(value: windSpeed, unit: .milesPerHour)
        }

        return measurement.formatted(
            .measurement(
                width: .abbreviated,
                usage: .asProvided,
                numberFormatStyle: .number.precision(.fractionLength(0))
            )
        )
    }
}

extension Coordinates {
    /// Formatted coordinates (e.g., "40.4168, -3.7038")
    var formatted: String {
        String(format: "%.4f, %.4f", latitude, longitude)
    }
}

// MARK: - Location Formatting

extension Location {
    /// Formatted location name (e.g., "Madrid, Spain")
    var displayName: String {
        [ name.isEmpty ? nil : name, country]
            .compactMap { $0 }
            .joined(separator: ", ")
    }

    /// TimeZone for this location based on the offset from UTC
    var timeZone: TimeZone {
        TimeZone(secondsFromGMT: timezoneOffset) ?? .current
    }

    /// Formatted sunrise time in the location's timezone (e.g., "06:45")
    var sunriseFormatted: String {
        formatTime(sunrise, in: timeZone)
    }

    /// Formatted sunset time in the location's timezone (e.g., "18:30")
    var sunsetFormatted: String {
        formatTime(sunset, in: timeZone)
    }
}

// MARK: - Temperature Formatting

extension Temperature {
    private func formatted(_ value: Double, for system: MeasurementSystem) -> String {
        let unit: UnitTemperature = system == .metric ? .celsius : .fahrenheit
        let measurement = Measurement(value: value, unit: unit)
        return measurement.formatted(.measurement(width: .abbreviated,
                                                  usage: .asProvided,
                                                  numberFormatStyle: .number.precision(.fractionLength(0))))
    }
    
    /// Formatted current temperature with unit (e.g., "22°C" or "72°F")
    func currentFormatted(measurementSystem: MeasurementSystem) -> String {
        formatted(current, for: measurementSystem)
    }
    
    func feelsLikeFormatted(measurementSystem: MeasurementSystem) -> String {
        let formattedTemp = formatted(feelsLike, for: measurementSystem)
        return String(localized: "feels_like \(formattedTemp)")
    }
    
    func minFormatted(measurementSystem: MeasurementSystem) -> String {
        formatted(minimum, for: measurementSystem)
    }
    
    func maxFormatted(measurementSystem: MeasurementSystem) -> String {
        formatted(maximum, for: measurementSystem)
    }
    
    /// Formatted humidity (e.g., "65%")
    var humidityFormatted: String {
        "\(humidity)%"
    }
}
