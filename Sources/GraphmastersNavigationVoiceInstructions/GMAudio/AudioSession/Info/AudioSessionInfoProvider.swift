import Foundation

public protocol AudioSessionInfoProvider {
    var isCarPlayAudioActive: Bool { get }
    var isBluetoothConnected: Bool { get }
    var isHFPAvailable: Bool { get }
    var isOtherAudioPlaying: Bool { get }
}

public extension AudioSessionInfoProvider {
    var probablyUsingInCarRadio: Bool {
        return isBluetoothConnected && !isOtherAudioPlaying
    }
}
