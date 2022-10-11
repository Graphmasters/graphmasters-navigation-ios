//
//  FeatureNavigationShared
//  Copyright © 2022, Graphmasters GmbH — All Rights Reserved
//
//  Unauthorized copying of this file, via any medium is strictly prohibited.
//  Proprietary and confidential.
//

import Foundation
import SharedMultiplatform

public final class RetryingRouteProvider: RouteProvider {
    private let routeProvider: RouteProvider
    private var routeRequests = [RouteProviderRouteRequest: Int]()

    public init(routeProvider: RouteProvider) {
        self.routeProvider = routeProvider
    }

    public func requestRoute(routeRequest _: RouteProviderRouteRequest) throws -> Route {
        fatalError("Missing implementation")
    }

    public func requestRoute(routeRequest: RouteProviderRouteRequest, callback: RouteProviderCallback) {
        routeRequests[routeRequest] = (routeRequests[routeRequest] ?? 0) + 1
        routeProvider.requestRoute(
            routeRequest: routeRequest,
            callback: SimpleRouteRequestCallBack(
                onSuccessClosure: { route in
                    callback.onSuccess(route: route)
                    self.routeRequests[routeRequest] = nil
                },
                onFailedClosure: { exception in
                    guard (self.routeRequests[routeRequest] ?? 0) < 3 else {
                        self.routeRequests[routeRequest] = nil
                        return callback.onFailed(exception: exception)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                        self.requestRoute(routeRequest: routeRequest, callback: callback)
                    }
                }
            )
        )
    }

    public func requestRouteData(origin _: LatLng, destination _: LatLng) throws -> RouteProviderRouteData {
        fatalError("Missing implementation")
    }
}
