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
