import AVFoundation
import CallKit
import Foundation

public class NavigationAudioSessionConfigProvider: AudioSessionConfigurationProvider {
    public var config: AVAudioSession.Config {
        AVAudioSession.Config(
            category: category,
            mode: mode,
            categoryOptions: [.duckOthers, .interruptSpokenAudioAndMixWithOthers],
            audioPortOveride: .none,
            supportsInAppVolume: false
        )
    }

    public init() {}

    private var category: AVAudioSession.Category {
        if #available(iOS 12.0, *) {
            return .playback
        } else {
            return .ambient
        }
    }

    private var mode: AVAudioSession.Mode {
        if #available(iOS 12.0, *) {
            return .voicePrompt
        } else {
            return .spokenAudio
        }
    }
}
