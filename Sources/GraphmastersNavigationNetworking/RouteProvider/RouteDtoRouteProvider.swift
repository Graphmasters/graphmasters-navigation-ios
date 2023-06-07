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

    private func convert(request: RouteProviderRouteRequest, routeDto: RouteDto) throws -> Route {
        return try routeConverter.convert(
            routeRequest: request,
            routeDto: routeDto,
            previousRoute: request.previousRoute,
            origin: request.origin.latLng,
            destination: request.destination.routable
        )
    }

    public func requestRoute(routeRequest request: RouteProviderRouteRequest) throws -> Route {
        let group = DispatchGroup()
        group.enter()

        var route: Route?
        var errorResponse: Error?

        routeDtoProvider.route(routeRequest: request) { result in
            switch result {
            case let .success(response):
                do {
                    route = try self.convert(request: request, routeDto: response)
                } catch {
                    errorResponse = errorResponse
                }
            case let .failure(error):
                errorResponse = error
            }
            group.leave()
        }

        group.wait()

        guard let route = route else {
            throw errorResponse ?? NSError(domain: "Unknown", code: -1)
        }

        return route
    }

    public func requestRouteData(origin: LatLng, destination: LatLng, vehicleConfig: VehicleConfig) throws -> RouteData {
        do {
            let route = try requestRoute(
                routeRequest: RouteProviderRouteRequest(
                    origin: Location(
                        provider: "Unknown",
                        timestamp: Int64(Date().timeIntervalSince1970) * 1000,
                        latLng: origin,
                        altitude: nil,
                        heading: nil,
                        speed: nil,
                        accuracy: nil,
                        level: nil
                    ),
                    forceRoute: true,
                    type: .light,
                    verifyOffRoute: false,
                    sessionId: nil,
                    destination: RouteProviderRouteRequest.Destination(
                        routable: RoutableFactory.shared.create(latLng: destination),
                        approachHeading: nil,
                        streetName: nil,
                        parkingLocation: nil
                    ),
                    previousRoute: nil,
                    vehicleConfig: vehicleConfig,
                    locationTrail: []
                )
            )
            return RouteData(duration: route.remainingTravelTime, distance: route.distance)
        } catch {
            throw error
        }
    }
}
