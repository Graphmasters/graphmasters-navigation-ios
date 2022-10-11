//
//  FeatureNavigationShared
//  Copyright © 2022, Graphmasters GmbH — All Rights Reserved
//
//  Unauthorized copying of this file, via any medium is strictly prohibited.
//  Proprietary and confidential.
//

import Foundation
import GraphmastersNavigationCore

class SystemInternetConnectionValidator: InternetConnectionValidator {
    private let internetConnectionStateProvider: InternetConnectionStateProvider

    /// device's current internet connection state
    var connected: Bool {
        switch internetConnectionStateProvider.connectionState {
        case .connected:
            return true
        case .disconnected:
            return false
        }
    }

    // MARK: - Life Cycle

    init(internetConnectionStateProvider: InternetConnectionStateProvider) {
        self.internetConnectionStateProvider = internetConnectionStateProvider
    }
}
