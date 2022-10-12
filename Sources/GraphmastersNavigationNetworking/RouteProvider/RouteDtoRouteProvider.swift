import Foundation
import GraphmastersNavigationCore

public final class RouteDtoRouteProvider: RouteProvider {
    private let routeDtoProvider: RouteDtoProvider
    private let routeConverter: RouteDtoConverter

    // MARK: - Life Cycle

    public init(routeDtoProvider: RouteDtoProvider, routeConverter: RouteDtoConverter) {
        self.routeDtoProvider = routeDtoProvider
        self.routeConverter = routeConverter
    }

    // MARK: - Route Provider

    public func requestRoute(routeRequest request: RouteProviderRouteRequest, callback: RouteProviderCallback) {
        routeDtoProvider.route(routeRequest: request) { result in
            switch result {
            case let .success(response):
                self.convert(request: request, routeDto: response, callback: callback)
            case let .failure(error):
                callback.onFailed(exception: KotlinException(message: error.localizedDescription))
            }
        }
    }

    private func convert(request: RouteProviderRouteRequest, routeDto: RouteDto, callback: RouteProviderCallback) {
        do {
            let route = try routeConverter.convert(
                routeDto: routeDto,
                previousRoute: request.previousRoute,
                origin: request.origin.latLng,
                destination: request.destination.routable
            )
            callback.onSuccess(route: route)
        } catch {
            callback.onFailed(exception: RouteDtoConverterRouteConversionExceptions(
                message: error.localizedDescription, throwable: nil
            ))
        }
    }

    public func requestRoute(routeRequest _: RouteProviderRouteRequest) throws -> Route {
        fatalError("Missing implementation")
    }

    public func requestRouteData(origin _: LatLng, destination _: LatLng) throws -> RouteProviderRouteData {
        fatalError("Missing implementation")
    }
}
