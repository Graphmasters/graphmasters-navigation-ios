import Foundation
import GraphmastersNavigationCore
import GraphmastersNavigationNetworking
import GraphmastersNavigationUtility
import UIKit

public class IosNavigationSdk: BaseNavigationSdk {
    private let instanceId: String
    private let apiKey: String

    private let vehicleTypeProvider: VehicleTypeProvider
    private let routingParamProviders: [RoutingParamProvider]
    private let sessionClientParameterProviders: [SessionClientParameterProvider]

    public init(
        instanceId: String = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString,
        serviceUrl: String,
        apiKey: String,
        vehicleTypeProvider: VehicleTypeProvider = StaticVehicleTypeProvider(vehicleType: "car"),
        routingParamProviders: [RoutingParamProvider] = [],
        sessionClientParameterProviders: [SessionClientParameterProvider] = []
    ) {
        self.instanceId = instanceId
        self.apiKey = apiKey

        self.vehicleTypeProvider = vehicleTypeProvider
        self.routingParamProviders = routingParamProviders
        self.sessionClientParameterProviders = sessionClientParameterProviders

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss ZZZZZ"
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)

        let configuration = URLSessionConfiguration.default
        configuration.shouldUseExtendedBackgroundIdleMode = true
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 20
        configuration.httpAdditionalHeaders = [
            "Instance-Id": instanceId,
            "Application-Id": App.bundleIdentifier,
            "Version-Code": App.buildNumber,
            "Version-Name": App.version,
            "Content-Type": "application/json",
            "Authorization": "api-key \(apiKey)",
            "Timeout-Ms": "\(configuration.timeoutIntervalForRequest * 1000)",
        ]
        let urlSession = URLSession(configuration: configuration)

        let routingApi: Api = .init(
            baseUrl: URL(string: serviceUrl)!,
            session: urlSession,
            jsonDecoder: jsonDecoder
        )

        let sessionClient: URLSessionSessionClient = .init(
            routingApi: routingApi,
            sessionClientParameterProvider: AggregatingSessionParamProvider(
                parameterProviders: sessionClientParameterProviders
            )
        )

        let routeProvider: RouteProvider = RouteDtoRouteProvider(
            routeDtoProvider: URLSessionRouteDtoProvider(
                routingApi: routingApi,
                routingParamProvider: AggregatingRoutingParamProvider(
                    parameterProviders: [
                        RouteRequestParamProviderV3(
                            deviceId: instanceId,
                            vehicleTypeProvider: vehicleTypeProvider
                        ),
                    ] + self.routingParamProviders
                ),
                routeResponseConverter: PlainRouteResponseConverter()
            ),
            routeConverter: MergingRouteDtoConverter(
                timeProvider: FoundationTimeProvider(),
                dateTimeFormatter: FoundationDateTimeFormatter(),
                geodesy: GeodesyPlus()
            )
        )

        super.init(
            executor: OperationQueueExecutor(),
            timeProvider: FoundationTimeProvider(),
            sessionClient: sessionClient,
            routeProvider: routeProvider,
            destinationReachedValidator: nil,
            leavingDestinationValidator: nil,
            internetConnectionValidator: nil,
            updateRateProvider: nil,
            destinationRepository: MultiStopDestinationRepository(),
            vehicleConfig: CarConfig(),
            serviceUrl: serviceUrl
        )
    }
}
