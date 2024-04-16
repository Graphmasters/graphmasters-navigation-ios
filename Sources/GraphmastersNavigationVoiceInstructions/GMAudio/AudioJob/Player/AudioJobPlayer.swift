import Foundation

public protocol AudioJobPlayer {
    func execute(audioJob: AudioJob)

    func execute(audioJob: AudioJob, completion: (() -> Void)?)

    func cancelCurrentJob()

    func add(listener: AudioJobPlayerListener)

    func remove(listener: AudioJobPlayerListener)
}

public extension AudioJobPlayer {
    func execute(audioJob: AudioJob) {
        execute(audioJob: audioJob, completion: nil)
    }
}
