import Foundation

/// Represents an API route, usually being an enumeration.
public protocol ApiRoutes {
    /// Path that will be appended to a base URL.
    var path: String { get }

    /// HTTP headers. Defaults to being empty.
    var headers: [String: String] { get }

    /// HTTP method. Defaults to `.get`.
    var method: HttpMethods { get }

    /// URL query parameters. Defaults to being empty.
    var parameters: [URLQueryItem] { get }

    /// HTTP body. Defaults `nil`.
    var body: Data? { get }

    /// If the route's return value conforms to `Decodable` the type can be specified here. This adds support for
    /// `API.requestDecoded`, which returns the server's response as a decoded object. Defaults to `nil`.
    var responseType: Decodable.Type? { get }

    /// Returns the full URL for this route.
    ///
    /// - Parameter baseUrl: Base URL to append route to.
    /// - Returns: Full URL for this route.
    func url(for baseUrl: URL) -> URL

    /// Returns a ready-to-use `URLRequest` to use for this route.
    ///
    /// - Parameter baseUrl: Base URL to append route to.
    /// - Returns: Request for this route.
    func request(for baseUrl: URL) -> URLRequest
}

// MARK: - Default Implementation

public extension ApiRoutes {
    var headers: [String: String] { [:] }

    var method: HttpMethods { .get }

    var parameters: [URLQueryItem] { [] }

    var body: Data? { nil }

    var responseType: Decodable.Type? { nil }

    func url(for baseUrl: URL) -> URL {
        let url = baseUrl.appendingPathComponent(path)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = parameters
        return components?.url ?? url
    }

    func request(for baseUrl: URL) -> URLRequest {
        var request = URLRequest(url: url(for: baseUrl))
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        return request
    }
}
