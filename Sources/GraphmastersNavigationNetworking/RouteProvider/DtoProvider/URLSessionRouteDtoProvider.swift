import Foundation
import GraphmastersNavigationCore

public final class URLSessionRouteDtoProvider: RouteDtoProvider {
    private let routingApi: Api
    private let routingParamProvider: RoutingParamProvider
    private let routeResponseConverter: RouteResponseConverter

    // MARK: - Life Cycle

    public init(routingApi: Api,
                routingParamProvider: RoutingParamProvider,
                routeResponseConverter: RouteResponseConverter)
    {
        self.routingApi = routingApi
        self.routingParamProvider = routingParamProvider
        self.routeResponseConverter = routeResponseConverter
    }

    // MARK: - Route Networking

    public func route(routeRequest request: RouteProviderRouteRequest, completion: @escaping (Result<RouteDto, Error>) -> Void) {
        routingApi.request(apiRoute(from: request)) { (result: ApiResult<RouteResponse>) in
            switch result {
            case let .success(response):
                completion(.success(self.routeResponseConverter.convert(response.value)))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    private func apiRoute(from routeRequest: RouteProviderRouteRequest) -> RouteApiRoute {
        return RouteApiRoute(
            parameters: routingParamProvider.getRoutingParameters(request: routeRequest),
            locations: routeRequest.locationTrail
        )
    }

    private func convert(_ routeRequestType: RouteProviderType) -> String {
        switch routeRequestType {
        case .light:
            return "light"
        default:
            return "full"
        }
    }

    private struct RouteApiRoute: ApiRoutes {
        let parameters: [URLQueryItem]

        let body: Data?

        let path: String = "v2/routing/route"

        let method: HttpMethods = .post

        let responseType: Decodable.Type? = RouteResponse.self

        init(
            parameters: [String: String] = [:],
            locations: [Location],
            jsonEncoder: JSONEncoder = JSONEncoder()
        ) {
            self.parameters = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
            body = try? jsonEncoder.encode(ProbeBody(probes: locations.map {
                ProbeTrailDto(
                    latitude: $0.latLng.latitude,
                    longitude: $0.latLng.longitude,
                    speedMps: $0.speed?.ms(),
                    heading: $0.heading?.doubleValue,
                    timestampUnixMs: $0.timestamp
                )
            }))
        }
    }

    private struct ProbeBody: Encodable {
        let probes: [ProbeTrailDto]
    }

    private struct ProbeTrailDto: Encodable {
        var latitude: Double
        var longitude: Double
        var speedMps: Double?
        var heading: Double?
        var timestampUnixMs: Int64
    }
}
