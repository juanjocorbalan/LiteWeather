import Testing
import Foundation
@testable import Data

@Suite("RetryPolicy Tests")
struct RetryPolicyTests {

    @Test("Default policy retries network and server errors")
    func defaultPolicyRetriesNetworkAndServerErrors() {
        let policy = RetryPolicy.default

        // Should retry
        #expect(policy.shouldRetry(.timeout) == true)
        #expect(policy.shouldRetry(.noInternetConnection) == true)
        #expect(policy.shouldRetry(.networkError) == true)
        #expect(policy.shouldRetry(.serverError) == true)

        // Should NOT retry
        #expect(policy.shouldRetry(.badRequest) == false)
        #expect(policy.shouldRetry(.unauthorized) == false)
        #expect(policy.shouldRetry(.forbidden) == false)
        #expect(policy.shouldRetry(.notFound) == false)
        #expect(policy.shouldRetry(.decodingError) == false)
        #expect(policy.shouldRetry(.unknown) == false)
    }

    @Test("Default policy has correct configuration")
    func defaultPolicyHasCorrectConfiguration() {
        let policy = RetryPolicy.default

        #expect(policy.maxAttempts == 3)
        #expect(policy.baseDelay == 0.5)
        #expect(policy.maxDelay == 30.0)
    }

    @Test("NoRetry policy never retries")
    func noRetryPolicyNeverRetries() {
        let policy = RetryPolicy.noRetry

        #expect(policy.maxAttempts == 0)
        #expect(policy.shouldRetry(.timeout) == false)
        #expect(policy.shouldRetry(.serverError) == false)
    }

    @Test("Delay increases exponentially")
    func delayIncreasesExponentially() {
        let policy = RetryPolicy.default

        // Attempt 0: 0.5s * 2^0 = 0.5s
        let delay0 = policy.delay(for: 0)
        #expect(delay0 == 0.5)

        // Attempt 1: 0.5s * 2^1 = 1.0s
        let delay1 = policy.delay(for: 1)
        #expect(delay1 == 1.0)

        // Attempt 2: 0.5s * 2^2 = 2.0s
        let delay2 = policy.delay(for: 2)
        #expect(delay2 == 2.0)
    }

    @Test("Delay is capped at maxDelay")
    func delayIsCappedAtMaxDelay() {
        let policy = RetryPolicy(
            maxAttempts: 10,
            baseDelay: 1.0,
            maxDelay: 5.0,
            shouldRetry: { _ in true }
        )

        // Attempt 10: 1.0s * 2^10 = 1024s, but should be capped at 5s
        let delay = policy.delay(for: 10)
        #expect(delay == 5.0)
    }

    @Test("NoRetry policy returns zero delay")
    func noRetryPolicyReturnsZeroDelay() {
        let policy = RetryPolicy.noRetry

        #expect(policy.delay(for: 0) == 0)
        #expect(policy.delay(for: 1) == 0)
        #expect(policy.delay(for: 10) == 0)
    }

    @Test("Custom policy allows custom retry logic")
    func customPolicyAllowsCustomRetryLogic() {
        let policy = RetryPolicy(
            maxAttempts: 2,
            baseDelay: 0.1,
            maxDelay: 1.0,
            shouldRetry: { error in
                // Only retry timeout errors
                error == .timeout
            }
        )

        #expect(policy.shouldRetry(.timeout) == true)
        #expect(policy.shouldRetry(.serverError) == false)
        #expect(policy.maxAttempts == 2)
    }

    @Test("Delay calculation is deterministic")
    func delayCalculationIsDeterministic() {
        let policy = RetryPolicy.default

        // Same attempt should always give same delay (no jitter)
        let delay1 = policy.delay(for: 0)
        let delay2 = policy.delay(for: 0)
        let delay3 = policy.delay(for: 0)

        #expect(delay1 == delay2)
        #expect(delay2 == delay3)
        #expect(delay1 == 0.5)
    }
}
