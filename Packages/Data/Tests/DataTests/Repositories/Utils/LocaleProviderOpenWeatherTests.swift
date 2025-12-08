import Testing
import DomainTestingUtils
@testable import Data

@Suite("LocaleProvider OpenWeather Extension Tests", .serialized)
struct LocaleProviderOpenWeatherTests {
    
    @Test func getOpenWeatherSupportedLanguageCode_returnsExpectedValue() {
        // Special cases: pt, zh, cs, ko, lv
        let specialCases: [(language: String, region: String, expected: String)] = [
            ("pt", "br", "pt_br"),
            ("pt", "pt", "pt"),
            ("zh", "tw", "zh_tw"),
            ("zh", "hk", "zh_tw"),
            ("zh", "cn", "zh_cn"),
            ("cs", "cz", "cz"),
            ("ko", "kr", "kr"),
            ("lv", "lv", "la")
        ]
        
        for testCase in specialCases {
            let provider = MockLocaleProvider(language: testCase.language, region: testCase.region)
            #expect(provider.getOpenWeatherSupportedLanguageCode() == testCase.expected)
        }
        
        // Normal cases
        let normalLanguages = [
            "sq", "af", "ar", "az", "eu", "be", "bg", "ca",
            "hr", "da", "nl", "en", "fi", "fr", "gl", "de", "el",
            "he", "hi", "hu", "is", "id", "it", "ja", "ku",
            "lt", "mk", "no", "fa", "pl", "ro", "ru", "sr",
            "sk", "sl", "es", "th", "tr", "uk", "vi", "zu",
            "sv"
        ]
        
        for language in normalLanguages {
            let provider = MockLocaleProvider(language: language, region: "US")
            #expect(provider.getOpenWeatherSupportedLanguageCode() == language)
        }
        
        // Fallback
        let fallbackLanguages = ["xx", "sw", ""]
        
        for language in fallbackLanguages {
            let provider = MockLocaleProvider(language: language, region: "XX")
            #expect(provider.getOpenWeatherSupportedLanguageCode() == "es")
        }
    }
}
