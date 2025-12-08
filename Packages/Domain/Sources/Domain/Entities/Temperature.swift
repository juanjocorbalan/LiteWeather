import Foundation

public struct Temperature: Sendable, Equatable {
    public let current: Double
    public let feelsLike: Double
    public let minimum: Double
    public let maximum: Double
    public let pressure: Int
    public let humidity: Int

    public init(
        current: Double,
        feelsLike: Double,
        minimum: Double,
        maximum: Double,
        pressure: Int,
        humidity: Int
    ) {
        self.current = current
        self.feelsLike = feelsLike
        self.minimum = minimum
        self.maximum = maximum
        self.pressure = pressure
        self.humidity = humidity
    }
}
