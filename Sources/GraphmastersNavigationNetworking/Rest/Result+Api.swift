import Foundation
import os

public typealias ApiResult<Value> = Result<(value: Value, response: HTTPURLResponse), Error>

public typealias ApiResultHandler<Value> = (ApiResult<Value>) -> Void

extension Result where Success == (value: Data, response: HTTPURLResponse), Failure == Error {
    /// Creates a new result based on the result of an HTTP request with its response, data, and error.
    init(data: Data?, response: HTTPURLResponse?, error: Error?) {
        if error == nil, let response = response, 200 ..< 300 ~= response.statusCode, let data = data {
            self = .success((data, response))
            return
        }
        self = .failure(error ?? NSError(domain: "Unknown", code: -1))
    }

    /// Returns the API result decoded from its JSON representation. If the data is not valid, the return value will be a
    /// `.failure`.
    ///
    /// - Parameters:
    ///     - type: Expected object type.
    ///     - jsonDecoder: JSON decoder to use for decoding.
    func decoded<Value: Decodable>(_ type: Value.Type, jsonDecoder: JSONDecoder = JSONDecoder()) -> ApiResult<Value> {
        return map {
            do {
                let decoded = try jsonDecoder.decode(type, from: $0.value)
                return (decoded, $0.response)
            } catch {
                let decoded = try jsonDecoder.decode(type, from: $0.value)
                return (decoded, $0.response)
            }
        }
    }

    /// Applies a transform to a result value if it is a `success`.
    ///
    /// - Parameter transform: Transform to apply to `value`.
    /// - Returns: `.failure` if this result is a failure or `transform` throws. Otherwise, a result with the transformed value
    ///            is returned.
    public func map<NewValue>(_ transform: (Success) throws -> NewValue) -> Result<NewValue, Failure> {
        switch self {
        case let .success(value):
            do {
                return .success(try transform(value))
            } catch {
                return .failure(error)
            }
        case let .failure(error):
            return .failure(error)
        }
    }
}
