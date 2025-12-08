import Foundation

public extension Resource {
    
    var baseURL: URL {
        // This is safe because Resource validates the URL in init
        URL(string: url)!
    }
    
    var completeURL: URL {
        guard let parameters, !parameters.isEmpty else {
            return baseURL
        }

        // This is safe because Resource validates the URL in init
        var components = URLComponents(string: url)!
        // Sort parameters to ensure consistent URL generation
        components.queryItems = parameters
            .sorted(by: { $0.key < $1.key })
            .map { URLQueryItem(name: $0.key, value: $0.value) }
        // This is safe because adding query items to valid URL always succeeds
        return components.url!
    }
}
