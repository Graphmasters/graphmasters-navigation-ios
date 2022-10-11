import Foundation
import GraphmastersNavigationCore

final class FileRouteDtoProvider: RouteDtoProvider {
    private let fileName: String
    private let bundle: Bundle
    private let jsonDecoder: JSONDecoder
    private let routeResponseConverter: RouteResponseConverter

    init(
        fileName: String,
        bundle: Bundle,
        jsonDecoder: JSONDecoder = JSONDecoder(),
        routeResponseConverter: RouteResponseConverter
    ) {
        self.fileName = fileName
        self.bundle = bundle
        self.jsonDecoder = jsonDecoder
        self.routeResponseConverter = routeResponseConverter
    }

    func route(routeRequest _: RouteProviderRouteRequest, completion: @escaping (Result<RouteDto, Error>) -> Void) {
        let filePath = bundle.path(forResource: fileName, ofType: "json")
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath!))
            let routeResponse = try jsonDecoder.decode(RouteResponse.self, from: data)
            completion(.success(routeResponseConverter.convert(routeResponse)))
        } catch {
            completion(.failure(error))
        }
    }
}
