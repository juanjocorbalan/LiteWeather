import Foundation

public extension Resource {

    var baseURL: URL {
        guard let url = URL(string: url) else {
            preconditionFailure("Invalid URL in Resource: \(url). Resource must be initialized with a valid URL string.")
        }
        return url
    }

    var completeURL: URL {
        guard let parameters, !parameters.isEmpty else {
            return baseURL
        }

        guard var components = URLComponents(string: url) else {
            preconditionFailure("Invalid URL in Resource: \(url). Resource must be initialized with a valid URL string.")
        }

        // Sort parameters to ensure consistent URL generation
        components.queryItems = parameters
            .sorted(by: { $0.key < $1.key })
            .map { URLQueryItem(name: $0.key, value: $0.value) }

        guard let completeURL = components.url else {
            preconditionFailure("Failed to construct URL with query parameters for Resource: \(url)")
        }

        return completeURL
    }
}
