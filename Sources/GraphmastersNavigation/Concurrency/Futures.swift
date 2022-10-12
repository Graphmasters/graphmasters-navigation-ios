//
//  SharedCore
//  Copyright © 2022, Graphmasters GmbH — All Rights Reserved
//
//  Unauthorized copying of this file, via any medium is strictly prohibited.
//  Proprietary and confidential.
//

import Foundation
import GraphmastersNavigationCore

class GMTimerSourceFuture: ExecutorFuture {
    private let timerSource: DispatchSourceTimer

    init(timerSource: DispatchSourceTimer) {
        self.timerSource = timerSource
    }

    func cancel() {
        timerSource.cancel()
    }

    var isFinished: Bool {
        timerSource.isCancelled
    }
}

extension Operation: ExecutorFuture {}

class GMWorkItemFuture: ExecutorFuture {
    private let workItem: DispatchWorkItem

    init(workItem: DispatchWorkItem) {
        self.workItem = workItem
    }

    func cancel() {
        workItem.cancel()
    }

    var isFinished: Bool {
        workItem.isCancelled
    }
}
