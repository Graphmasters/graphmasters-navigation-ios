import AVFAudio
import CoreAudio
import Foundation
import Logging

@available(iOS 13.0.0, *)
final class AudioComponent {
    private lazy var logger: Logger = .init(label: "AudioComponent")

    private(set) lazy var voiceAudioJobProvider: VoiceAudioJobProvider = SynthesizingVoiceAudioJobProvider(
        speechSynthesizer: speechSynthesizer
    )

    private lazy var speechSynthesizer: AVSpeechSynthesizer = .init()

    private(set) lazy var audioJobPlayer: AudioJobPlayer = QueuingAudioJobPlayer(
        audioController: audioController,
        logger: logger
    )

    private lazy var audioController: AudioController = GMAudioController(
        audioSession: audioSession,
        audioSessionInfoProvider: audioSessionInfoProvider,
        audioSessionConfigurationProvider: audioSessionConfigurationProvider,
        logger: logger
    )

    private lazy var audioSession: AVAudioSession = .sharedInstance()

    private lazy var audioSessionInfoProvider: AudioSessionInfoProvider = AVAudioSessionInfoProvider(
        audioSession: audioSession
    )

    private lazy var audioSessionConfigurationProvider: AudioSessionConfigurationProvider
        = NavigationAudioSessionConfigProvider()
}
