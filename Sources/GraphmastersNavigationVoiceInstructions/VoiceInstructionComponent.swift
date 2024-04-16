import Foundation
import GraphmastersNavigationCore

@available(iOS 13.0.0, *)
public final class VoiceInstructionComponent {
    private let navigationSdk: NavigationSdk
    private let locale: Locale

    public init(
        navigationSdk: NavigationSdk,
        locale: Locale = .autoupdatingCurrent
    ) {
        self.navigationSdk = navigationSdk
        self.locale = locale
    }

    public var enabled: Bool {
        get {
            voiceInstructionHandler.enabled
        }
        set {
            voiceInstructionHandler.enabled = newValue
        }
    }

    private lazy var voiceInstructionStringGenerator: VoiceInstructionStringGenerator = LocaleVoiceInstructionStringGenerator(
        localeProvider: FoundationLanguageProvider()
    )

    private lazy var voiceInstructionDispatcher: VoiceInstructionDispatcher = AudioPlayerVoiceInstructionDispatcher(
        audioJobPlayer: audioComponent.audioJobPlayer,
        voiceAudioJobProvider: audioComponent.voiceAudioJobProvider
    )

    private lazy var voiceInstructionHandler: VoiceInstructionHandler = NavigationVoiceInstructionHandler(
        navigationSdk: navigationSdk,
        voiceInstructionStringGenerator: voiceInstructionStringGenerator,
        voiceInstructionDispatcher: voiceInstructionDispatcher
    )

    private lazy var audioComponent = AudioComponent()
}
