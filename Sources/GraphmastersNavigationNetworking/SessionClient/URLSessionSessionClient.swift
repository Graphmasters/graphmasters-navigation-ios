import Foundation
import GraphmastersNavigationCore

public final class URLSessionSessionClient: SessionClient {
    public func stopSession(sessionId: String, callback: SessionClientCallback?) {
        routingApi.request(
            ApiSessionRequest(
                sessionId: sessionId,
                parameters: sessionClientParameterProvider
                    .getAdditionalParams(sessionId: sessionId)
                    .map { URLQueryItem(name: $0.key, value: $0.value) }
            )
        ) { result in
            switch result {
            case .success:
                GMLog().i(tag: String(describing: self), msg: "Successfully stopped session with id: \(sessionId)")
                callback?.onSuccess()
            case let .failure(error):
                callback?.onFailed(e: KotlinException(
                    message: "Error stopping session",
                    cause: KotlinThrowable(message: error.localizedDescription)
                ))
                GMLog().e(tag: String(describing: self), msg: "Error stopping session with id: \(sessionId)")
            }
        }
    }

    private let routingApi: Api

    private let sessionClientParameterProvider: SessionClientParameterProvider

    public init(
        routingApi: Api,
        sessionClientParameterProvider: SessionClientParameterProvider
    ) {
        self.routingApi = routingApi
        self.sessionClientParameterProvider = sessionClientParameterProvider
    }

    private struct ApiSessionRequest: ApiRoutes {
        private let sessionId: String
        public let parameters: [URLQueryItem]

        init(sessionId: String, parameters: [URLQueryItem]) {
            self.sessionId = sessionId
            self.parameters = parameters
        }

        var path: String {
            return "v2/routing/sessions/\(sessionId)"
        }

        let method: HttpMethods = .delete
    }
}
