public struct RouteResponse: Codable {
    struct DestinationInfoTagResponse: Codable {
        var finalStop: Bool?
        var destinationReachedDistanceMeters: Int?
        var label: String?
        var message: String?
        var type: String?

        var convertToMap: [String: Any] {
            var map = [String: Any]()
            if let finalStop = finalStop {
                map["finalStop"] = finalStop
            }
            if let destinationReachedDistanceMeters = destinationReachedDistanceMeters {
                map["destinationReachedDistanceMeters"] = destinationReachedDistanceMeters
            }
            if let label = label {
                map["label"] = label
            }
            if let message = message {
                map["message"] = message
            }
            if let type = type {
                map["type"] = type
            }
            return map
        }
    }

    struct FuelStationResponse: Codable {
        var location: GeoLocationResponse
        var distance: Double
        var name: String?
        var types: [String]?
    }

    struct DestinationInfoResponse: Codable {
        var location: GeoLocationResponse
        var tag: String
        var tags: DestinationInfoTagResponse?
    }

    struct GeoLocationResponse: Codable {
        var latitude: Double
        var longitude: Double
    }

    struct RouteLegResponse: Codable {
        var destinationRoadOffset: Double
        var steps: [RouteStepResponse]
        var fuelStations: [FuelStationResponse]?
    }

    struct RouteStepResponse: Codable {
        var anticipatedSpeed: Double
        var geoPoints: [GeoLocationResponse]?
        var enforcements: [EnforcementResponse]?
        var expectedGpsQuality: String?
        var lanes: [LaneResponse]?
        var laneAssistDisplayDistance: Double?
        var roadClass: String?
        var speedLimit: Int?
        var turnInfo: TurnInfoResponse
        var level: Int?
    }

    struct EnforcementResponse: Codable {
        var location: GeoLocationResponse
        var type: String
    }

    struct LaneResponse: Codable {
        var laneTurns: [String]?
        var directionNames: [String]?
        var directionReferenceNames: [String]?
        var shouldUse: Bool? = false
    }

    struct TurnInfoResponse: Codable {
        var isEndOfStreet: Bool
        var shouldSuppressTurnCommand: Bool
        var directionNames: [String]?
        var directionReferenceNames: [String]?
        var turnCommand: String
        var leadsToRoadClass: String?
        var leadsToStreetName: String?
        var leadsToLevel: Int?
    }

    var hash: String
    var vehicleType: String?
    var destinationInfo: [DestinationInfoResponse]?
    var duration: String?
    var length: Double
    var nextRefreshInterval: String
    var routeLegs: [RouteLegResponse]?
    var trafficVolume: String?
    var localizedInfo: String?
    var offRoute: Bool?
    var offRouteLikelyDisplacementMetres: Double?
}
