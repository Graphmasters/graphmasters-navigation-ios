import Foundation

public final class StaticVehicleTypeProvider: VehicleTypeProvider {
    public let vehicleType: String

    public init(vehicleType: String) {
        self.vehicleType = vehicleType
    }
}
