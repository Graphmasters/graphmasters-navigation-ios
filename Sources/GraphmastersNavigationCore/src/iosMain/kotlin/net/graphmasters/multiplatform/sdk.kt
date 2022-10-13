package net.graphmasters.multiplatform

import net.graphmasters.multiplatform.navigation.*
import net.graphmasters.multiplatform.core.OperationQueueExecutor
import net.graphmasters.multiplatform.navigation.ui.*
import net.graphmasters.multiplatform.navigation.ui.camera.*

fun BaseNavigationUISdk(
    navigationSdk: NavigationSdk,
    screenHeightProvider: ScreenHeightProvider
): BaseNavigationUISdk = BaseNavigationUISdk(
    navigationSdk,
    screenHeightProvider,
    OperationQueueExecutor()
)