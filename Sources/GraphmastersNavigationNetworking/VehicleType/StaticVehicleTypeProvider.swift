//
//  FeatureNavigationShared
//  Copyright © 2022, Graphmasters GmbH — All Rights Reserved
//
//  Unauthorized copying of this file, via any medium is strictly prohibited.
//  Proprietary and confidential.
//

import Foundation

public final class StaticVehicleTypeProvider: VehicleTypeProvider {
    public let vehicleType: String

    public init(vehicleType: String) {
        self.vehicleType = vehicleType
    }
}
