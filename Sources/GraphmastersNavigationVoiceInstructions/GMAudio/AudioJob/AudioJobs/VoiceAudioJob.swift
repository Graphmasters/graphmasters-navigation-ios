import AVFoundation
import Foundation

public protocol VoiceAudioJobConfigProvider {
    var config: VoiceAudioJob.Config { get }
}

public final class VoiceAudioJob: NSObject, AudioJob {
    private let speechSynthesizer: AVSpeechSynthesizer
    private let sentence: String
    private let config: Config

    public weak var listener: AudioJobListener?

    // MARK: - Life Cycle

    public init(sentence: String, speechSynthesizer: AVSpeechSynthesizer, config: Config = .init()) {
        self.sentence = sentence
        self.speechSynthesizer = speechSynthesizer
        self.config = config
        super.init()
    }

    // MARK: - AudioJob

    public var isRunning: Bool {
        speechSynthesizer.delegate == nil
    }

    public func run() {
        speechSynthesizer.delegate = self
        speechSynthesizer.speakSentence(
            sentence: sentence,
            volume: config.volume,
            voice: config.voice,
            speedMultiplier: config.speedMultiplier,
            pitchMultiplier: config.pitchMultiplier
        )
    }

    public func cancel() {
        speechSynthesizer.stopSpeaking(at: .immediate)
    }
}

extension VoiceAudioJob: AVSpeechSynthesizerDelegate {
    public func speechSynthesizer(_: AVSpeechSynthesizer, didStart _: AVSpeechUtterance) {
        listener?.onStarted(self)
    }

    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel _: AVSpeechUtterance) {
        synthesizer.delegate = nil
        listener?.onEnded(self)
    }

    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish _: AVSpeechUtterance) {
        synthesizer.delegate = nil
        listener?.onEnded(self)
    }
}

public extension VoiceAudioJob {
    struct Config {
        public var volume: Float
        public var voice: AVSpeechSynthesisVoice?
        public var speedMultiplier: Float
        public var pitchMultiplier: Float

        public init(
            volume: Float = 1,
            voice: AVSpeechSynthesisVoice? = .default,
            speedMultiplier: Float = 1,
            pitchMultiplier: Float = 1
        ) {
            self.volume = volume
            self.voice = voice
            self.speedMultiplier = speedMultiplier
            self.pitchMultiplier = pitchMultiplier
        }
    }
}
