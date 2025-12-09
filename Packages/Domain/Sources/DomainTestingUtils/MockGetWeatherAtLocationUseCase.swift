import Domain

public final class MockGetWeatherAtLocationUseCase: GetWeatherAtLocationUseCase {
    nonisolated(unsafe) public var stubbedResult: Result<Weather, DomainError>?
    nonisolated(unsafe) public var callCount: Int = 0
    private let delay: UInt64?

    public init(result: Result<Weather, DomainError>? = nil, delay: UInt64? = nil) {
        self.stubbedResult = result
        self.delay = delay
    }

    public func execute() async throws(DomainError) -> Weather {
        callCount += 1

        if let delay = delay {
            try? await Task.sleep(nanoseconds: delay)
        }

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

// MARK: - Convenience Factory Methods

public extension MockGetWeatherAtLocationUseCase {
    /// Creates a mock that returns Madrid weather
    static func madrid(delay: UInt64? = nil) -> MockGetWeatherAtLocationUseCase {
        MockGetWeatherAtLocationUseCase(result: .success(.madrid), delay: delay)
    }

    /// Creates a mock that returns London weather
    static func london(delay: UInt64? = nil) -> MockGetWeatherAtLocationUseCase {
        MockGetWeatherAtLocationUseCase(result: .success(.london), delay: delay)
    }

    /// Creates a mock that returns New York weather
    static func newYork(delay: UInt64? = nil) -> MockGetWeatherAtLocationUseCase {
        MockGetWeatherAtLocationUseCase(result: .success(.newYork), delay: delay)
    }

    /// Creates a mock that returns Rome weather
    static func rome(delay: UInt64? = nil) -> MockGetWeatherAtLocationUseCase {
        MockGetWeatherAtLocationUseCase(result: .success(.rome), delay: delay)
    }

    /// Creates a mock that returns custom weather
    static func success(_ weather: Weather, delay: UInt64? = nil) -> MockGetWeatherAtLocationUseCase {
        MockGetWeatherAtLocationUseCase(result: .success(weather), delay: delay)
    }

    /// Creates a mock that throws an unknown error
    static func errorUnknown(delay: UInt64? = nil) -> MockGetWeatherAtLocationUseCase {
        MockGetWeatherAtLocationUseCase(result: .failure(.unknown), delay: delay)
    }

    /// Creates a mock that throws an unavailable error
    static func errorUnavailable(delay: UInt64? = nil) -> MockGetWeatherAtLocationUseCase {
        MockGetWeatherAtLocationUseCase(result: .failure(.unavailable), delay: delay)
    }

    /// Creates a mock that throws an unauthorized error
    static func errorUnauthorized(delay: UInt64? = nil) -> MockGetWeatherAtLocationUseCase {
        MockGetWeatherAtLocationUseCase(result: .failure(.unauthorized), delay: delay)
    }

    /// Creates a mock that throws an invalid data error
    static func errorInvalidData(delay: UInt64? = nil) -> MockGetWeatherAtLocationUseCase {
        MockGetWeatherAtLocationUseCase(result: .failure(.invalidData), delay: delay)
    }

    /// Creates a mock with custom error
    static func error(_ error: DomainError, delay: UInt64? = nil) -> MockGetWeatherAtLocationUseCase {
        MockGetWeatherAtLocationUseCase(result: .failure(error), delay: delay)
    }
}
