import Foundation

/// Wrapper around `URLSession` that allows simple and easy access to an API.
///
/// To use it, just create your own type, peferably an enumeration, implementing `ApiRoutes` and initialize an instance of this
/// class with your routes and a base `URL`.
///
/// You can use this class to make API requests, decode them automatically, and download files.
///
/// Depending on the `URLSession` given on initialization, this class uses the default `URLCredentialStorage`.
///
/// - Remark: This class is not marked `final` in order to allow subclassing for mock implementations. Usually, you will not
///           need to subclass it.
public class Api {
    private let session: URLSession
    private let jsonDecoder: JSONDecoder

    // MARK: - Life Cycle

    /// Base `URL` of all requests this instance issues. Any route paths will be appended to it.
    private let baseUrl: URL

    /// Creates a new API wrapper at `baseUrl`.
    ///
    /// - Parameters:
    ///   - baseUrl: Base `URL` of all requests this instance issues. Any route paths will be appended to it.
    ///   - session: URL Session, which defaults to the shared session.
    ///   - jsonDecoder: JSON decoder to use for decoding responses.
    public init(baseUrl: URL, session: URLSession, jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.baseUrl = baseUrl
        self.session = session
        self.jsonDecoder = jsonDecoder
    }

    // MARK: - Performing Data Requests

    /// Requests data from this API.
    ///
    /// - Parameters:
    ///   - route: Route to request data from.
    ///   - completion: Completion handler receiving a result with the received response and data or an error.
    /// - Returns: URL task in its resumed state or `nil` if building the request failed.
    @discardableResult
    public func request<Routes: ApiRoutes>(_ route: Routes, completion: @escaping ApiResultHandler<Data>) -> URLSessionTask {
        let task = session.dataTask(with: route.request(for: baseUrl)) { data, response, error in
            let result = Result(data: data, response: response as? HTTPURLResponse, error: error)
            completion(result)
        }
        task.resume()
        return task
    }

    /// Requests data from this API and decodes as the type defined by the route.
    ///
    /// - Parameters:
    ///   - route: Route to request data from.
    ///   - completion: Completion handler receiving a result with the response and decoded object or an error.
    /// - Returns: URL task in its resumed state or `nil` if building the request failed.
    /// - Precondition: `route`'s type must not be `nil`.
    /// - Remark: At the moment, this method supports JSON decoding only.
    @discardableResult
    public func request<Result: Decodable, Routes: ApiRoutes>(_ route: Routes,
                                                              completion: @escaping ApiResultHandler<Result>) -> URLSessionTask
    {
        guard let type = route.responseType as? Result.Type else {
            fatalError("Trying to decode response from untyped API route '\(route)'.")
        }
        return request(route) { result in
            completion(result.decoded(type, jsonDecoder: self.jsonDecoder))
        }
    }
}
