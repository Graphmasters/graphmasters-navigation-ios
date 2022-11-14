import AVFoundation
import Foundation
import Logging
import MediaPlayer
import UIKit

@available(iOS 13.0.0, *)
public class GMAudioController: NSObject {
    private let audioSessionConfigurationProvider: AudioSessionConfigurationProvider
    private let audioSessionInfoProvider: AudioSessionInfoProvider
    private let audioSession: AVAudioSession
    private let logger: Logger

    private var listeners = Listeners<AudioControllerListener>()

    public private(set) var isActive = false {
        willSet {
            guard newValue else {
                return
            }
            listeners.forEach { $0.willActivateAudio(self) }
        }
        didSet {
            guard oldValue != isActive, !isActive else {
                return
            }
            listeners.forEach { $0.didDeactivateAudio(self) }
        }
    }

    // MARK: - Attributes

    public init(
        audioSession: AVAudioSession,
        audioSessionInfoProvider: AudioSessionInfoProvider,
        audioSessionConfigurationProvider: AudioSessionConfigurationProvider,
        logger: Logging.Logger
    ) {
        self.audioSession = audioSession
        self.audioSessionConfigurationProvider = audioSessionConfigurationProvider
        self.logger = logger
        self.audioSessionInfoProvider = audioSessionInfoProvider

        super.init()
    }
}

// MARK: - AudioController implementation

@available(iOS 13.0.0, *)
extension GMAudioController: AudioController {
    public func activateAudio() async throws {
        guard !isActive else {
            try await deactivateAudio()
            try await activateAudio()
            return
        }

        let audioSessionConfig = audioSessionConfigurationProvider.config
        let additionalOptions = audioSessionConfigurationProvider.additionalOptions

        try audioSession.setPreferredOutputNumberOfChannels(audioSession.maximumOutputNumberOfChannels)
        try audioSession.set(config: audioSessionConfig, additionalOptions: additionalOptions)
        try audioSession.setActive(true)

        logger.trace("Successfully activated audio session", source: "GMAudio")

        do {
            try audioSession.setAudioPortOverride(config: audioSessionConfig)
            logger.trace("Successfully set audio port override", source: "GMAudio")
        } catch {
            logger.error("Can't set override", source: "GMAudio")
        }

        isActive = true
    }

    public func deactivateAudio() async throws {
        try await deactivateAudio(skipManualSteps: false)
        logger.trace("Successfully deactivated audio session", source: "GMAudio")
    }

    public func deactivateAudio(skipManualSteps _: Bool) async throws {
        do {
            try audioSession.overrideOutputAudioPort(.none)
        } catch {
            logger.error("Can't reset port override", source: "GMAudio")
        }

        try audioSession.setActive(false, options: [.notifyOthersOnDeactivation])

        isActive = false
    }

    // MARK: - Listeners

    public func add(listener: AudioControllerListener) {
        listeners.add(listener)
    }

    public func remove(listener: AudioControllerListener) {
        listeners.remove(listener)
    }
}

@available(iOS 13.0.0, *)
extension AudioJobPlayer {
    func executeAsync(audioJob: AudioJob) async {
        await withCheckedContinuation { continuation in
            self.execute(audioJob: audioJob) {
                continuation.resume()
            }
        }
    }
}
