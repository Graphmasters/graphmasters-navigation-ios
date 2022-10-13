package net.graphmasters.multiplatform.core

import net.graphmasters.multiplatform.core.Executor
import net.graphmasters.multiplatform.core.units.Duration
import net.graphmasters.multiplatform.core.units.timeinterval
import platform.Foundation.*
import platform.darwin.*

class TestExecutor : Executor {
    private val mainOperationQueue: NSOperationQueue = NSOperationQueue.mainQueue

    private var defaultOperationQueue: NSOperationQueue

    init {
        val queue = NSOperationQueue()
        queue.underlyingQueue = dispatch_get_main_queue()
        defaultOperationQueue = queue
    }

    override fun execute(block: () -> Unit) {
        defaultOperationQueue.addOperationWithBlock(block)
    }

    override fun executeDelayed(delay: Duration, block: () -> Unit): Executor.Future {
        val operation = NSBlockOperation()
        operation.addExecutionBlock(block)
        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW, delay.milliseconds() * NSEC_PER_MSEC.toLong()),
            dispatch_get_main_queue()
        ) {
            if (!operation.cancelled) {
                this.defaultOperationQueue.addOperation(operation)
            }
        }
        return OperationExecutorFuture(operation)
    }

    override fun runOnUiThread(block: () -> Unit) {
        mainOperationQueue.addOperationWithBlock(block)
    }

    private var timers: MutableList<NSTimerExecutorFuture> = mutableListOf()

    override fun schedule(updateRate: Duration, block: () -> Unit): Executor.Future {
        timers = timers.filter { it.timer?.valid == true }.toMutableList()

        val timer = NSTimer(NSDate(), 1.0, true) {
            if (it?.valid == true) {
                this.defaultOperationQueue.addOperationWithBlock(block)
            }
        }
        val future = NSTimerExecutorFuture(timer)
        timers.add(future)
        return future
    }

    private class OperationExecutorFuture(private val operation: NSOperation) : Executor.Future {
        override fun cancel() {
            operation.cancel()
        }
    }

    private class NSTimerExecutorFuture(var timer: NSTimer?) : Executor.Future {
        override fun cancel() {
            timer?.invalidate()
            timer = null
        }
    }
}