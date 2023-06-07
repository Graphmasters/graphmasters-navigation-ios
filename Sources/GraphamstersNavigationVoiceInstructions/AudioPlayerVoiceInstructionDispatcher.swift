import Foundation
import GraphmastersNavigationCore

public final class AudioPlayerVoiceInstructionDispatcher: VoiceInstructionDispatcher {
    private let audioJobPlayer: AudioJobPlayer
    private let voiceAudioJobProvider: VoiceAudioJobProvider

    public init(
        audioJobPlayer: AudioJobPlayer,
        voiceAudioJobProvider: VoiceAudioJobProvider
    ) {
        self.audioJobPlayer = audioJobPlayer
        self.voiceAudioJobProvider = voiceAudioJobProvider
    }

    public func dispatch(
        voiceInstructionContext _: VoiceInstructionContext,
        voiceInstructionText: String,
        balance _: Float,
        onDone: @escaping (String) -> Void
    ) {
        audioJobPlayer.execute(audioJob: voiceAudioJobProvider.audioJob(for: voiceInstructionText), completion: {
            onDone(voiceInstructionText)
        })
    }
}
