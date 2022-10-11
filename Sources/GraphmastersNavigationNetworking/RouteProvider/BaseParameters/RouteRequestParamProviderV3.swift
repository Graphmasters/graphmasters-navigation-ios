import Foundation
import GraphmastersNavigationCore

public final class RouteRequestParamProviderV3: RoutingParamProvider {
    private enum Parameters: String {
        case deviceId
        case vehicleType
        case sessionId
        case origin
        case destination
        case forceGetRoute
        case heading
        case originAltitudeMeters
        case locationProvider
        case type
        case verifyOffRoute
        case hash
        case version
    }

    private let deviceId: String
    private let vehicleTypeProvider: VehicleTypeProvider

    public init(deviceId: String, vehicleTypeProvider: VehicleTypeProvider) {
        self.deviceId = deviceId
        self.vehicleTypeProvider = vehicleTypeProvider
    }

    public func getRoutingParameters(request: RouteProviderRouteRequest) -> [String: String] {
        var params: [String: String] = [
            Parameters.origin.rawValue: originParameter(request: request),
            Parameters.destination.rawValue: destinationParameter(request: request),
            Parameters.forceGetRoute.rawValue: request.forceRoute.description,
            Parameters.locationProvider.rawValue: request.origin.provider,
            Parameters.verifyOffRoute.rawValue: request.verifyOffRoute.description,
            Parameters.type.rawValue: requestTypeParameter(request: request),
            Parameters.deviceId.rawValue: deviceId,
            Parameters.vehicleType.rawValue: vehicleTypeProvider.vehicleType,
            Parameters.version.rawValue: "3",
        ]

        if let heading = request.origin.heading {
            params[Parameters.heading.rawValue] = "\(heading)"
        }

        if let altitude = request.origin.altitude?.meters() {
            params[Parameters.originAltitudeMeters.rawValue] = "\(altitude)"
        }

        if let unwrappedSessionId = request.sessionId {
            params[Parameters.sessionId.rawValue] = unwrappedSessionId
        }

        if let previousRoute = request.previousRoute {
            params[Parameters.hash.rawValue] = previousRoute.hash
        }

        return params.filter { (key: String, value: String) -> Bool in
            !key.isEmpty && !value.isEmpty
        }
    }

    private func originParameter(request: RouteProviderRouteRequest) -> String {
        let currentLatitude = request.origin.latLng.latitude
        let currentLongitude = request.origin.latLng.longitude
        return "\(currentLatitude),\(currentLongitude)"
    }

    private func destinationParameter(request: RouteProviderRouteRequest) -> String {
        let destinationLatitude = request.destination.routable.latLng.latitude
        let destinationLongitude = request.destination.routable.latLng.longitude
        return "\(destinationLatitude),\(destinationLongitude)"
    }

    private func requestTypeParameter(request: RouteProviderRouteRequest) -> String {
        switch request.type {
        case .light:
            return "light"
        default:
            return "full"
        }
    }
}
