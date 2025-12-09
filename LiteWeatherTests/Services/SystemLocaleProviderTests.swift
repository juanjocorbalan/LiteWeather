import Testing
import Foundation
import Domain
@testable import LiteWeather

struct SystemLocaleProviderTests {

    // MARK: - Language Tests

    @Test func language_returnsCorrectLanguage() {
        let testCases: [(input: [String], expected: String)] = [
            (["es_ES"], "es"),
            (["en_US"], "en"),
            (["it_IT"], "it"),
            (["zh_CN"], "zh"),
            (["zh_TW"], "zh"),
            (["pt_BR"], "pt"),
            (["sv_SE"], "sv"),
            (["uk_UA"], "uk"),
            (["ca_ES"], "ca"),
        ]

        for testCase in testCases {
            let provider = SystemLocaleProvider(preferredLanguages: testCase.input)
            #expect(provider.language == testCase.expected)
        }
    }

    // MARK: - Fallback Tests

    @Test func language_withEmpty_returnsEs() {
        let provider = SystemLocaleProvider(preferredLanguages: [])
        #expect(provider.language == "es")
    }
}
