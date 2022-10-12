import Foundation

public final class AggregatingSessionParamProvider: SessionClientParameterProvider {
    private var parameterProviders: [SessionClientParameterProvider]

    public init(parameterProviders: [SessionClientParameterProvider]) {
        self.parameterProviders = parameterProviders
    }

    public func add(parameterProvider: SessionClientParameterProvider) {
        parameterProviders.append(parameterProvider)
    }

    public func getAdditionalParams(sessionId: String) -> [String: String] {
        return parameterProviders
            .map { $0.getAdditionalParams(sessionId: sessionId) }
            .flattendUsingFirstEntry()
    }
}

extension Array where Element == [String: String] {
    func flattendUsingFirstEntry() -> [String: String] {
        return reduce(into: [String: String]()) { $0.merge($1) { $1 } }
    }
}
