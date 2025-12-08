import Domain

public final class MockGetWeatherAtLocationUseCase: GetWeatherAtLocationUseCase {
    nonisolated(unsafe) public var stubbedResult: Result<Weather, DomainError>?
    nonisolated(unsafe) public var callCount: Int = 0

    public init() {}

    public func execute() async throws(DomainError) -> Weather {
        callCount += 1

        guard let result = stubbedResult else {
            fatalError("MockGetWeatherAtLocationUseCase not configured")
        }

        switch result {
        case .success(let weather):
            return weather
        case .failure(let error):
            throw error
        }
    }
}
