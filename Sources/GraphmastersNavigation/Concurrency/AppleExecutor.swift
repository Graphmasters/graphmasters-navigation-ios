import Foundation
import GraphmastersNavigationCore

public class AppleExecutor: Executor {
    public init() {}

    private var timerSourceFutures = [GMTimerSourceFuture]()

    private let mainOperationQueue = OperationQueue.main

    private let defaultOperationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.underlyingQueue = .main
        return queue
    }()

    @discardableResult
    public func schedule(updateRate: Duration, block: @escaping () -> Void) -> ExecutorFuture {
        timerSourceFutures = timerSourceFutures.filter { !$0.isFinished }
        let timerSource = DispatchSource.makeTimerSource(queue: .global(qos: .utility))
        timerSource.schedule(deadline: .now(), repeating: TimeInterval(Double(updateRate.milliseconds()) / 1000.0))
        timerSource.setEventHandler {
            self.defaultOperationQueue.addOperation(block)
        }
        timerSource.resume()
        let future = GMTimerSourceFuture(timerSource: timerSource)
        timerSourceFutures.append(future)
        return future
    }

    @discardableResult
    public func executeDelayed(delay: Duration, block: @escaping () -> Void) -> ExecutorFuture {
        let operation = BlockOperation(block: block)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(delay.milliseconds()))) {
            self.defaultOperationQueue.addOperation(operation)
        }
        return operation
    }

    public func runOnUiThread(block: @escaping () -> Void) {
        mainOperationQueue.addOperation(block)
    }

    public func execute(block: @escaping () -> Void) {
        defaultOperationQueue.addOperation(block)
    }
}
