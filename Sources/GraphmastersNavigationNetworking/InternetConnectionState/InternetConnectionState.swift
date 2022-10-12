//
//  GMNetworking
//  Copyright © 2022, Graphmasters GmbH — All Rights Reserved
//
//  Unauthorized copying of this file, via any medium is strictly prohibited.
//  Proprietary and confidential.
//

import Foundation

public enum InternetConnectionError: Error {
    case mobileDataRestricted
    case unknown
}

public enum InternetConnectionState {
    public enum ConnectionType {
        case mobileData
        case wifi
    }

    case connected(ConnectionType)
    case disconnected(InternetConnectionError)
}
