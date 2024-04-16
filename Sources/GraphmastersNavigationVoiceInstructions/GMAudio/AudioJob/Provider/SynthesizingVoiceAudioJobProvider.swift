import AVFoundation
import Foundation

public final class SynthesizingVoiceAudioJobProvider {
    private let speechSynthesizer: AVSpeechSynthesizer

    public init(
        speechSynthesizer: AVSpeechSynthesizer
    ) {
        self.speechSynthesizer = speechSynthesizer
    }
}

extension SynthesizingVoiceAudioJobProvider: VoiceAudioJobProvider {
    public func audioJob(for sentence: String) -> AudioJob {
        return VoiceAudioJob(
            sentence: sentence,
            speechSynthesizer: speechSynthesizer
        )
    }
}
