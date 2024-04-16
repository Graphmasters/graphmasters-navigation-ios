import Foundation

public protocol AudioJobListener: AnyObject {
    func onStarted(_ audioJob: AudioJob)

    func onEnded(_ audioJob: AudioJob)
}

public extension AudioJobListener {
    func onStarted(_: AudioJob) {}
}
