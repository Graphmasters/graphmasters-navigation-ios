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

    public func dispatch(voiceInstruction: [String], onDone: @escaping (String) -> Void) {
        voiceInstruction.forEach { instruction in
            self.audioJobPlayer.execute(audioJob: self.voiceAudioJobProvider.audioJob(for: instruction), completion: {
                onDone(instruction)
            })
        }
    }
}
