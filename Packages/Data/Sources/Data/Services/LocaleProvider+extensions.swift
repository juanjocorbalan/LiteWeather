import Domain
import Foundation

/// OpenWeatherMap API-specific extensions for LocaleProvider
extension LocaleProvider {
    /// Maps the locale's language code to the corresponding OpenWeatherMap API language parameter
    ///
    /// Special cases:
    /// - Portuguese: Uses `pt_br` for Brazilian Portuguese, `pt` for European Portuguese
    /// - Chinese: Uses `zh_cn` for Simplified Chinese, `zh_tw` for Traditional Chinese (Taiwan/Hong Kong)
    /// - Czech: Uses `cz` instead of `cs`
    /// - Korean: Uses `kr` instead of `ko`
    /// - Latvian: Uses `la` instead of `lv`
    ///
    /// - Returns: The OpenWeatherMap-compatible language code. Defaults to `es` for unsupported languages.
    func getOpenWeatherSupportedLanguageCode() -> String {
        switch language {
        case "pt":
            if region == "br" { return "pt_br" }
            return "pt"
            
        case "zh":
            if region == "tw" { return "zh_tw" }
            if region == "hk" { return "zh_tw" }
            return "zh_cn"
            
        case "cs":
            return "cz"
            
        case "ko":
            return "kr"
            
        case "lv":
            return "la"
            
        case "sv":
            return "sv"
            
        case "sq", "af", "ar", "az", "eu", "be", "bg", "ca",
            "hr", "da", "nl", "en", "fi", "fr", "gl", "de", "el",
            "he", "hi", "hu", "is", "id", "it", "ja", "ku",
            "lt", "mk", "no", "fa", "pl", "ro", "ru", "sr",
            "sk", "sl", "es", "th", "tr", "uk", "vi", "zu":
            return language
            
        default:
            return "es"
        }
    }
}
