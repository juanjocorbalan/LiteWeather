import Foundation

public enum StubResponse {
    case success(Data)
    case successWithFile(String)
    case failure(statusCode: Int, data: Data? = nil)
    case error(Error)
    case networkTimeout
    case noInternet
}

// URLProtocol stub for intercepting network requests in tests
// Supports FIFO (First-In-First-Out) for multiple stubs per URL
public final class URLProtocolStub: URLProtocol {
    private nonisolated(unsafe) static var stubsByID: [String: [URL: [(URLRequest) throws -> (HTTPURLResponse, Data?)]]] = [:]
    private static let queue = DispatchQueue(label: "URLProtocolStub.queue")

    // MARK: - Stub registration
    public static func stub(id: String, url: URL, response: StubResponse) {
        queue.sync {
            var handlers = stubsByID[id, default: [:]][url, default: []]
            let handler: (URLRequest) throws -> (HTTPURLResponse, Data?) = { _ in
                switch response {
                case .success(let data):
                    let httpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
                    return (httpResponse, data)
                case .successWithFile(let file):
                    let data = Bundle.module.data(from: file)
                    let httpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
                    return (httpResponse, data)
                case .failure(let statusCode, let data):
                    let httpResponse = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
                    return (httpResponse, data)
                case .error(let error):
                    throw error
                case .networkTimeout:
                    throw URLError(.timedOut)
                case .noInternet:
                    throw URLError(.notConnectedToInternet)
                }
            }
            handlers.append(handler)
            stubsByID[id, default: [:]][url] = handlers
        }
    }

    public static func reset(id: String) {
        queue.sync { stubsByID[id] = nil }
    }

    private static func getHandler(for request: URLRequest) -> ((URLRequest) throws -> (HTTPURLResponse, Data?))? {
        queue.sync {
            guard
                let url = request.url,
                let stubID = request.value(forHTTPHeaderField: "StubGroupID"),
                var handlers = stubsByID[stubID]?[url],
                !handlers.isEmpty
            else { return nil }

            let handler = handlers.removeFirst()

            // Clean up if no more handlers for this URL
            if handlers.isEmpty {
                stubsByID[stubID]?[url] = nil
            } else {
                stubsByID[stubID]?[url] = handlers
            }

            return handler
        }
    }

    // MARK: - URLProtocol
    public override class func canInit(with request: URLRequest) -> Bool { true }
    public override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    public override func startLoading() {
        guard let handler = URLProtocolStub.getHandler(for: request) else {
            let error = NSError(domain: "URLProtocolStub", code: -1,
                                userInfo: [
                                NSLocalizedDescriptionKey: "No stub found for URL \(request.url?.absoluteString ?? "nil")"
                                ])
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let data = data { client?.urlProtocol(self, didLoad: data) }
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    public override func stopLoading() {}
}
