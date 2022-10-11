//
//  FeatureNavigationShared
//  Copyright © 2022, Graphmasters GmbH — All Rights Reserved
//
//  Unauthorized copying of this file, via any medium is strictly prohibited.
//  Proprietary and confidential.
//

import Foundation
import SharedMultiplatform

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
