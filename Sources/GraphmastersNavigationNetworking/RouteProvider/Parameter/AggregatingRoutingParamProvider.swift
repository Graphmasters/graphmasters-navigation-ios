import Foundation
import GraphmastersNavigationCore

public final class AggregatingRoutingParamProvider: RoutingParamProvider {
    private var parameterProviders: [RoutingParamProvider]

    public init(parameterProviders: [RoutingParamProvider]) {
        self.parameterProviders = parameterProviders
    }

    public func add(parameterProvider: RoutingParamProvider) {
        parameterProviders.append(parameterProvider)
    }

    public func add(parameterProviders: [RoutingParamProvider]) {
        self.parameterProviders.append(contentsOf: parameterProviders)
    }

    public func getRoutingParameters(request: RouteProviderRouteRequest) -> [String: String] {
        return parameterProviders
            .map { $0.getRoutingParameters(request: request) }
            .flattendUsingFirstEntry()
    }
}
