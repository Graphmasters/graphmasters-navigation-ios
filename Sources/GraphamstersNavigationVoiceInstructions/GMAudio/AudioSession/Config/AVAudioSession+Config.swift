import AVFoundation
import Foundation

public extension AVAudioSession {
    struct Config: Equatable {
        public let category: AVAudioSession.Category
        public let mode: AVAudioSession.Mode
        public let categoryOptions: AVAudioSession.CategoryOptions
        public let audioPortOveride: AVAudioSession.PortOverride
        public let supportsInAppVolume: Bool

        public init(category: AVAudioSession.Category,
                    mode: AVAudioSession.Mode,
                    categoryOptions: AVAudioSession.CategoryOptions,
                    audioPortOveride: AVAudioSession.PortOverride,
                    supportsInAppVolume: Bool)
        {
            self.category = category
            self.mode = mode
            self.categoryOptions = categoryOptions
            self.audioPortOveride = audioPortOveride
            self.supportsInAppVolume = supportsInAppVolume
        }
    }
}

public extension AVAudioSession {
    func set(config: Config, additionalOptions: AVAudioSession.CategoryOptions = []) throws {
        try setCategory(config.category, mode: config.mode, options: config.categoryOptions.union(additionalOptions))
    }

    func setAudioPortOverride(config: Config) throws {
        try overrideOutputAudioPort(config.audioPortOveride)
    }
}
