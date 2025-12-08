import Foundation
import Domain

public final class MockWeatherRepository: WeatherRepository {
    nonisolated(unsafe) public var stubbedResult: Result<Weather, DomainError>?
    nonisolated(unsafe) public var capturedLatitude: Double?
    nonisolated(unsafe) public var capturedLongitude: Double?
    
    public init() {}
    
    public func getCurrentWeather(latitude: Double, longitude: Double) async throws(DomainError) -> Weather {
        capturedLatitude = latitude
        capturedLongitude = longitude
        
        guard let result = stubbedResult else {
            fatalError("MockWeatherRepository not configured")
        }
        
        switch result {
        case .success(let weather):
            return weather
        case .failure(let error):
            throw error
        }
    }
}
