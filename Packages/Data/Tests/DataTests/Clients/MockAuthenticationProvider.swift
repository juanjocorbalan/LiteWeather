import Testing
import Foundation
import DataTestingUtils
@testable import Data

@Suite("URLSessionAPIClient Tests", .serialized)
class URLSessionAPIClientTests {

    private static let stubID = UUID().uuidString

    // MARK: - Test Configuration

    private func makeAPIClient(retryPolicy: RetryPolicy = .default) -> URLSessionAPIClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        configuration.httpAdditionalHeaders = ["StubGroupID": Self.stubID]
        return URLSessionAPIClient(configuration: configuration, retryPolicy: retryPolicy)
    }

    private func makeResource<T: Decodable>(
        url: String = APIConfig.Endpoint.currentWeather,
        parameters: [String: String]? = nil
    ) -> Resource<T> {
        Resource(url: url, parameters: parameters, method: .get)
    }

    // MARK: - Success Tests

    @Test("Client successfully decodes valid weather response")
    func successfullyDecodesValidResponse() async throws {
        // Given
        let apiClient = makeAPIClient()
        let parameters = [
            APIConfig.Parameter.lat.rawValue: "40.4241",
            APIConfig.Parameter.lon.rawValue: "-3.7062",
        ]

        let resource: Resource<WeatherDTO> = makeResource(parameters: parameters)
        URLProtocolStub.stub(id: Self.stubID, url: resource.completeURL, response: .successWithFile("madrid.json"))

        // When
        let result = try await apiClient.execute(resource)

        // Then - Verify client correctly decoded the response
        #expect(result.name == "Madrid City Center")
        #expect(result.coord.lat == 40.4241)
        #expect(result.coord.lon == -3.7062)
        #expect(result.sys.country == "ES")
    }

    // MARK: - Error Mapping Tests

    @Test("Client maps invalid JSON to decodingError")
    func mapsInvalidJSONToDecodingError() async throws {
        // Given
        let apiClient = makeAPIClient()
        let invalidData = Data("{ invalid json }".utf8)

        let resource: Resource<WeatherDTO> = makeResource()
        URLProtocolStub.stub(id: Self.stubID, url: resource.completeURL, response: .success(invalidData))

        // When/Then - Verify client maps decoding failure to APIError.decodingError
        await #expect(throws: APIError.decodingError) {
            try await apiClient.execute(resource)
        }
    }

    @Test("Client maps HTTP 4xx errors to appropriate APIErrors")
    func mapsClientErrorsCorrectly() async throws {
        // Given
        let apiClient = makeAPIClient()
        let testCases: [(statusCode: Int, expectedError: APIError)] = [
            (400, .badRequest),
            (401, .unauthorized),
            (403, .forbidden),
            (404, .notFound)
        ]

        // When/Then - Verify client error mapping logic
        for testCase in testCases {
            let resource: Resource<WeatherDTO> = makeResource()
            URLProtocolStub.stub(id: Self.stubID, url: resource.completeURL, response: .failure(statusCode: testCase.statusCode))

            await #expect(throws: testCase.expectedError) {
                try await apiClient.execute(resource)
            }
        }
    }

    @Test("Client maps HTTP 5xx errors to serverError")
    func mapsServerErrorsCorrectly() async throws {
        // Given - Disable retry to test error mapping directly
        let apiClient = makeAPIClient(retryPolicy: .noRetry)
        let serverErrorCodes = [500, 502, 503]

        // When/Then - Verify all 5xx errors map to same error type
        for statusCode in serverErrorCodes {
            let resource: Resource<WeatherDTO> = makeResource()
            URLProtocolStub.stub(id: Self.stubID, url: resource.completeURL, response: .failure(statusCode: statusCode))

            await #expect(throws: APIError.serverError) {
                try await apiClient.execute(resource)
            }
        }
    }

    @Test("Client maps network connectivity errors to specific APIErrors")
    func mapsNetworkErrorsCorrectly() async throws {
        // Given - Disable retry to test error mapping directly
        let apiClient = makeAPIClient(retryPolicy: .noRetry)
        let testCases: [(stubResponse: StubResponse, expectedError: APIError)] = [
            (.noInternet, .noInternetConnection),
            (.error(URLError(.networkConnectionLost)), .noInternetConnection),
            (.networkTimeout, .timeout),
            (.error(URLError(.cannotFindHost)), .networkError)
        ]

        // When/Then - Verify client maps URLErrors to APIErrors
        for testCase in testCases {
            let resource: Resource<WeatherDTO> = makeResource()
            URLProtocolStub.stub(id: Self.stubID, url: resource.completeURL, response: testCase.stubResponse)

            await #expect(throws: testCase.expectedError) {
                try await apiClient.execute(resource)
            }
        }
    }

    // MARK: - Retry Policy Tests

    @Test("Client retries on timeout with default retry policy")
    func retriesOnTimeoutWithDefaultRetryPolicy() async throws {
        // Given
        let apiClient = makeAPIClient() // Uses default retry policy (3 attempts)

        let resource: Resource<WeatherDTO> = makeResource()

        // First 2 attempts timeout, third succeeds
        URLProtocolStub.stub(id: Self.stubID, url: resource.completeURL, response: .networkTimeout)
        URLProtocolStub.stub(id: Self.stubID, url: resource.completeURL, response: .networkTimeout)
        URLProtocolStub.stub(id: Self.stubID, url: resource.completeURL, response: .successWithFile("madrid.json"))

        // When
        let result = try await apiClient.execute(resource)

        // Then
        #expect(result.name == "Madrid City Center")
    }

    @Test("Client retries on server error with default retry policy")
    func retriesOnServerErrorWithDefaultRetryPolicy() async throws {
        // Given
        let apiClient = makeAPIClient()

        let resource: Resource<WeatherDTO> = makeResource()

        // First attempt 500, second succeeds
        URLProtocolStub.stub(id: Self.stubID, url: resource.completeURL, response: .failure(statusCode: 500))
        URLProtocolStub.stub(id: Self.stubID, url: resource.completeURL, response: .successWithFile("madrid.json"))

        // When
        let result = try await apiClient.execute(resource)

        // Then
        #expect(result.name == "Madrid City Center")
    }

    @Test("Client does not retry on client errors (4xx)")
    func doesNotRetryOnClientErrors() async throws {
        // Given
        let apiClient = makeAPIClient()

        let resource: Resource<WeatherDTO> = makeResource()

        // 400 Bad Request - should NOT retry
        URLProtocolStub.stub(id: Self.stubID, url: resource.completeURL, response: .failure(statusCode: 400))

        // When/Then - Should fail immediately without retrying
        await #expect(throws: APIError.badRequest) {
            try await apiClient.execute(resource)
        }
    }

    @Test("Client respects noRetry policy")
    func respectsNoRetryPolicy() async throws {
        // Given
        let apiClient = URLSessionAPIClient(
            configuration: URLSessionConfiguration.ephemeral.with(stubID: Self.stubID),
            retryPolicy: .noRetry
        )

        let resource: Resource<WeatherDTO> = makeResource()

        // First attempt fails with timeout
        URLProtocolStub.stub(id: Self.stubID, url: resource.completeURL, response: .networkTimeout)

        // When/Then - Should fail immediately without retrying
        await #expect(throws: APIError.timeout) {
            try await apiClient.execute(resource)
        }
    }

    @Test("Client uses resource-specific retry policy over default")
    func usesResourceSpecificRetryPolicy() async throws {
        // Given - Client with default policy (3 retries)
        let apiClient = makeAPIClient()

        // Resource with noRetry policy (overrides client default)
        let resource = Resource<WeatherDTO>(
            url: APIConfig.Endpoint.currentWeather,
            parameters: [
                APIConfig.Parameter.lat.rawValue: "40.4241",
                APIConfig.Parameter.lon.rawValue: "-3.7062",
            ],
            retryPolicy: .noRetry
        )

        // Mock timeout
        URLProtocolStub.stub(id: Self.stubID, url: resource.completeURL, response: .networkTimeout)

        // When/Then - Should NOT retry (uses resource's noRetry policy)
        await #expect(throws: APIError.timeout) {
            try await apiClient.execute(resource)
        }
    }

    @Test("Client exhausts all retry attempts before failing")
    func exhaustsAllRetryAttemptsBeforeFailing() async throws {
        // Given - Policy with 3 retries
        let apiClient = makeAPIClient()

        let resource: Resource<WeatherDTO> = makeResource()

        // All 4 attempts (initial + 3 retries) fail with 500
        URLProtocolStub.stub(id: Self.stubID, url: resource.completeURL, response: .failure(statusCode: 500))
        URLProtocolStub.stub(id: Self.stubID, url: resource.completeURL, response: .failure(statusCode: 500))
        URLProtocolStub.stub(id: Self.stubID, url: resource.completeURL, response: .failure(statusCode: 500))
        URLProtocolStub.stub(id: Self.stubID, url: resource.completeURL, response: .failure(statusCode: 500))

        // When/Then - Should fail after 4 attempts
        await #expect(throws: APIError.serverError) {
            try await apiClient.execute(resource)
        }
    }

    deinit {
        URLProtocolStub.reset(id: Self.stubID)
    }
}

// MARK: - Helper Extensions

extension URLSessionConfiguration {
    func with(stubID: String) -> URLSessionConfiguration {
        self.protocolClasses = [URLProtocolStub.self]
        self.httpAdditionalHeaders = ["StubGroupID": stubID]
        return self
    }
}
