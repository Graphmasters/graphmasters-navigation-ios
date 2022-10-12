import Foundation

public protocol SessionClientParameterProvider {
    func getAdditionalParams(sessionId: String) -> [String: String]
}
