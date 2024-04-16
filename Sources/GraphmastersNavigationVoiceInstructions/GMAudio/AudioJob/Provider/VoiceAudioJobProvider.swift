import Foundation

public protocol VoiceAudioJobProvider {
    func audioJob(for sentence: String) -> AudioJob
}
