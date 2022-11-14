import AVFoundation
import Foundation

public extension AVSpeechSynthesizer {
    func speakSentence(
        sentence: String,
        volume: Float = 1,
        voice: AVSpeechSynthesisVoice? = nil,
        speedMultiplier: Float = 1,
        pitchMultiplier: Float = 1
    ) {
        let utterance = AVSpeechUtterance(string: sentence)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * speedMultiplier
        utterance.volume = volume
        utterance.pitchMultiplier = pitchMultiplier
        utterance.voice = voice
        speak(utterance)
    }
}
