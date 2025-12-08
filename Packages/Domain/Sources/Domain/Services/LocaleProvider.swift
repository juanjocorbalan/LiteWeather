import Foundation

/// Provides locale-specific configuration
public protocol LocaleProvider: Sendable {
    /// Returns the measurement system to use (metric or imperial)
    var measurementSystem: MeasurementSystem { get }
    
    /// Returns language code
    var language: String { get }
    
    /// Returns region code
    var region: String { get }
}

public enum MeasurementSystem: String, Sendable {
    case metric
    case imperial
}
