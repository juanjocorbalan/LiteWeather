import Foundation

public struct Location: Sendable, Equatable {
    public let name: String
    public let country: String?
    public let sunrise: Date
    public let sunset: Date
    public let timezoneOffset: Int

    public init(name: String, country: String?, sunrise: Date, sunset: Date, timezoneOffset: Int) {
        self.name = name
        self.country = country
        self.sunrise = sunrise
        self.sunset = sunset
        self.timezoneOffset = timezoneOffset
    }
}
