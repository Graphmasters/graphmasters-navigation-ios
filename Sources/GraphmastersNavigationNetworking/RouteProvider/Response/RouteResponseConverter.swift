import Foundation
import GraphmastersNavigationCore

public protocol RouteResponseConverter {
    func convert(_ response: RouteResponse) -> RouteDto
}

public final class PlainRouteResponseConverter: RouteResponseConverter {
    public init() {}

    public func convert(_ response: RouteResponse) -> RouteDto {
        RouteDto(
            hash: response.hash,
            vehicleType: response.vehicleType,
            destinationInfo: response.destinationInfo?.map(convert(_:)),
            duration: response.duration,
            length: response.length,
            nextRefreshInterval: response.nextRefreshInterval,
            routeLegs: response.routeLegs?.map(convert(_:)),
            trafficVolume: response.trafficVolume,
            localizedInfo: nil,
            offRoute: response.offRoute.map { KotlinBoolean(bool: $0) },
            offRouteLikelyDisplacementMetres: response.offRouteLikelyDisplacementMetres.map { KotlinDouble(double: $0) }
        )
    }

    private func convert(_ response: RouteResponse.DestinationInfoResponse) -> RouteDto.DestinationInfo {
        RouteDto.DestinationInfo(
            location: convert(response.location),
            tag: response.tag,
            tags: response.tags?.convertToMap ?? [:]
        )
    }

    private func convert(_ response: RouteResponse.GeoLocationResponse) -> RouteDto.GeoPoint {
        RouteDto.GeoPoint(
            latitude: response.latitude,
            longitude: response.longitude
        )
    }

    private func convert(_ response: RouteResponse.RouteLegResponse) -> RouteDto.RouteLeg {
        RouteDto.RouteLeg(
            destinationRoadOffset: response.destinationRoadOffset,
            steps: response.steps.map(convert(_:)),
            fuelStations: response.fuelStations?.map(convert(_:)) ?? []
        )
    }

    private func convert(_ response: RouteResponse.RouteStepResponse) -> RouteDto.RouteLegStep {
        RouteDto.RouteLegStep(
            anticipatedSpeed: response.anticipatedSpeed,
            geoPoints: response.geoPoints?.map(convert(_:)) ?? [],
            enforcements: response.enforcements?.map(convert(_:)),
            expectedGpsQuality: response.expectedGpsQuality ?? "",
            lanes: response.lanes?.map(convert(_:)),
            laneAssistDisplayDistance: response.laneAssistDisplayDistance.map(KotlinDouble.init),
            roadClass: response.roadClass ?? "",
            speedLimit: response.speedLimit.map(KotlinInt.init),
            turnInfo: convert(response.turnInfo),
            level: response.level.map(KotlinInt.init)
        )
    }

    private func convert(_ response: RouteResponse.EnforcementResponse) -> RouteDto.Enforcement {
        RouteDto.Enforcement(
            location: convert(response.location),
            type: response.type
        )
    }

    private func convert(_ response: RouteResponse.LaneResponse) -> RouteDto.RouteLegStepLane {
        RouteDto.RouteLegStepLane(
            laneTurns: response.laneTurns ?? [],
            shouldUse: response.shouldUse ?? false
        )
    }

    private func convert(_ response: RouteResponse.TurnInfoResponse) -> RouteDto.RouteLegStepTurnInfo {
        RouteDto.RouteLegStepTurnInfo(
            isEndOfStreet: response.isEndOfStreet,
            shouldSuppressTurnCommand: response.shouldSuppressTurnCommand,
            directionNames: response.directionNames ?? [],
            directionReferenceNames: response.directionReferenceNames ?? [],
            turnCommand: response.turnCommand,
            leadsToRoadClass: response.leadsToRoadClass,
            leadsToStreetName: response.leadsToStreetName,
            leadsToLevel: response.leadsToLevel.map { KotlinInt(value: Int32($0)) }
        )
    }

    private func convert(_ response: RouteResponse.FuelStationResponse) -> RouteDto.RouteLegFuelStation {
        RouteDto.RouteLegFuelStation(
            location: RouteDto.GeoPoint(latitude: response.location.latitude,
                                        longitude: response.location.longitude),
            distance: response.distance,
            name: response.name, types: response.types
        )
    }
}
