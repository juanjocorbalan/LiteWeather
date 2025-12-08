import Foundation
import Domain

public final class MockGetCurrentWeatherUseCase: GetCurrentWeatherUseCase {
    nonisolated(unsafe) public var stubbedResult: Result<Weather, DomainError>?
    nonisolated(unsafe) public var capturedLatitude: Double?
    nonisolated(unsafe) public var capturedLongitude: Double?
    
    public init() {}
    
    public func execute(coordinates: Coordinates) async throws(DomainError) -> Weather {
        capturedLatitude = coordinates.latitude
        capturedLongitude = coordinates.longitude
        
        guard let result = stubbedResult else {
            fatalError("MockGetCurrentWeatherUseCase not configured")
        }
        
        switch result {
        case .success(let weather):
            return weather
        case .failure(let error):
            throw error
        }
    }
}
