import Foundation
import GraphmastersNavigationCore
import GraphmastersNavigationNetworking
import GraphmastersNavigationUtility
import UIKit

public class IosNavigationSdk: BaseNavigationSdk {
    private enum Constants {
        static let defaultServiceUrl = "https://navigation-sandbox.nunav.net"
    }

    private let instanceId: String = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString

    private let apiKey: String

    private let vehicleTypeProvider: VehicleTypeProvider = StaticVehicleTypeProvider(vehicleType: "car")
    private let routingParamProviders: [RoutingParamProvider] = []
    private let sessionClientParameterProviders: [SessionClientParameterProvider] = []

    public init(
        apiKey: String,
        serviceUrl: String? = nil
    ) {
        self.apiKey = apiKey
        let serviceUrl = serviceUrl ?? Constants.defaultServiceUrl

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
                    ] + routingParamProviders
                ),
                routeResponseConverter: PlainRouteResponseConverter()
            ),
            routeConverter: MergingRouteDtoConverter(
                timeProvider: FoundationTimeProvider(),
                dateTimeFormatter: FoundationDateTimeFormatter() as! DateTimeFormatter,
                geodesy: GeodesyPlus()
            )
        )

        super.init(
            executor: OperationQueueExecutor(),
            sessionClient: sessionClient as! SessionClient,
            routeProvider: routeProvider,
            destinationReachedValidator: nil,
            leavingDestinationValidator: nil,
            internetConnectionValidator: nil,
            updateRateProvider: nil,
            destinationRepository: MultiStopDestinationRepository(),
            vehicleConfig: CarConfig()
        )
    }
}
