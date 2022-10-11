import Foundation
import GraphmastersNavigationCore

public protocol RouteDtoProvider {
    func route(routeRequest request: RouteProviderRouteRequest, completion: @escaping (Result<RouteDto, Error>) -> Void)
}
