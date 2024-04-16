import AVFoundation
import Combine
import Foundation
import Logging
import UIKit

@available(iOS 13.0, *)
public final class QueuingAudioJobPlayer: AudioJobPlayer {
    private let audioController: AudioController
    private let logger: Logging.Logger

    private let audioJobTimeoutSeconds: Int?

    private var jobQueue = Queue<AudioJob>()

    private var cancelJobItem: DispatchWorkItem?

    private var currentJob: AudioJob? {
        willSet {
            cancelJobItem?.cancel()
            cancelJobItem = nil
            currentJob?.listener = nil
            currentJob?.cancel()
        }
        didSet {
            currentJob?.listener = self
            guard let audioJob = currentJob else { return }

            audioJobTimeoutSeconds.map { timeout in
                let newJobItem = DispatchWorkItem {
                    self.currentJob = nil
                    self.logger.trace("Cancelled AudioJob after \(timeout) sec", source: "GMAudio")
                }
                DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + .seconds(timeout), execute: newJobItem)
                cancelJobItem = newJobItem
            }

            listeners.forEach { $0.audioJobPlayer(self, didStart: audioJob) }
        }
    }

    private var listeners = Listeners<AudioJobPlayerListener>()

    private var cancable: AnyCancellable?

    // MARK: - Life Cycle

    public init(
        audioController: AudioController,
        logger: Logging.Logger,
        audioJobTimeoutSeconds: Int? = nil
    ) {
        self.audioController = audioController
        self.logger = logger
        self.audioJobTimeoutSeconds = audioJobTimeoutSeconds
    }

    // MARK: - AudioJobPlayer

    public func cancelCurrentJob() {
        currentJob = nil
    }

    private var executionLock = NSLock()

    public func execute(audioJob: AudioJob, completion _: (() -> Void)?) {
        executionLock.lock()
        defer {
            executionLock.unlock()
        }
        guard !audioPipeLineBlocked() else {
            logger.trace("Enqueue new job \(audioJob)", source: "GMAudio")
            return jobQueue.enqueue(audioJob)
        }
        currentJob = audioJob

        audioController.activateAudio { result in
            switch result {
            case .success:
                audioJob.run()
            case let .failure(error):
                self.logger.error("Error activating audio: \(error.localizedDescription)",
                                  metadata: nil, source: "GMAudio")
                self.runNextJob()
            }
        }
    }

    private func audioPipeLineBlocked() -> Bool {
        return currentJob?.blocking == true
    }

    private func runNextJob() {
        jobQueue.dequeue().map { execute(audioJob: $0) }
    }

    // MARK: - Listeners

    public func add(listener: AudioJobPlayerListener) {
        listeners.add(listener)
    }

    public func remove(listener: AudioJobPlayerListener) {
        listeners.remove(listener)
    }
}

@available(iOS 13.0, *)
extension QueuingAudioJobPlayer: AudioJobListener {
    public func onEnded(_ audioJob: AudioJob) {
        executionLock.lock()
        defer {
            executionLock.unlock()
        }
        audioController.deactivateAudio { result in
            switch result {
            case .success:
                self.finish(audioJob: audioJob)
            case let .failure(error):
                self.logger.error("Error deactivating audio: \(error.localizedDescription)",
                                  metadata: nil, source: "GMAudio")
                self.finish(audioJob: audioJob)
            }
        }
    }

    private func finish(audioJob: AudioJob) {
        currentJob = nil
        runNextJob()
        listeners.forEach { $0.audioJobPlayer(self, didFinish: audioJob) }
    }
}
