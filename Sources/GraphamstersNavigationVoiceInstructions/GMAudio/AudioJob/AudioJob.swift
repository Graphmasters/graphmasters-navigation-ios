import Foundation

public protocol AudioJob {
    var listener: AudioJobListener? { get set }

    var blocking: Bool { get }

    var isRunning: Bool { get }

    func run()

    func cancel()
}

public extension AudioJob {
    var blocking: Bool { true }
}
