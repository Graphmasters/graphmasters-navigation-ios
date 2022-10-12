import Foundation
import GraphmastersNavigationCore

public class SystemInternetConnectionValidator: InternetConnectionValidator {
    private let internetConnectionStateProvider: InternetConnectionStateProvider

    /// device's current internet connection state
    public var connected: Bool {
        switch internetConnectionStateProvider.connectionState {
        case .connected:
            return true
        case .disconnected:
            return false
        }
    }

    // MARK: - Life Cycle

    public init(internetConnectionStateProvider: InternetConnectionStateProvider) {
        self.internetConnectionStateProvider = internetConnectionStateProvider
    }
}
