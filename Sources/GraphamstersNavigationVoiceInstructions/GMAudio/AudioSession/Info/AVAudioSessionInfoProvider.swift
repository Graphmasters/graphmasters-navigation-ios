import AVFoundation
import Foundation

public final class AVAudioSessionInfoProvider: AudioSessionInfoProvider {
    private let audioSession: AVAudioSession

    public init(audioSession: AVAudioSession) {
        self.audioSession = audioSession
    }

    public var isCarPlayAudioActive: Bool {
        audioSession.currentRoute.outputs.contains(where: { $0.portType == .carAudio })
    }

    public var isBluetoothConnected: Bool {
        let currentRoute = audioSession.currentRoute
        let connectedPorts = currentRoute.outputs.map(\.portType) + currentRoute.inputs.map(\.portType)
        return connectedPorts.contains(.bluetoothLE)
            || connectedPorts.contains(.bluetoothA2DP)
            || connectedPorts.contains(.bluetoothHFP)
    }

    public var isHFPAvailable: Bool {
        let currentRoute = audioSession.currentRoute
        for port in currentRoute.outputs + (audioSession.availableInputs ?? []) where port.portType == .bluetoothHFP {
            return true
        }
        return false
    }

    public var isOtherAudioPlaying: Bool {
        audioSession.isOtherAudioPlaying
    }
}
