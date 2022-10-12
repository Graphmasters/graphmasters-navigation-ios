//
//  GMNetworking
//  Copyright © 2022, Graphmasters GmbH — All Rights Reserved
//
//  Unauthorized copying of this file, via any medium is strictly prohibited.
//  Proprietary and confidential.
//

import CoreTelephony
import Foundation
import SystemConfiguration
import UIKit

public final class InternetConnectionStateProvider {
    enum Error: Swift.Error {
        case creatingReachabilityFailed
        case registerCallbackFailed
        case setReachabilityDispatchQueueFailed
    }

    private lazy var cellularData = CTCellularData()

    private let reachability: SCNetworkReachability

    // MARK: - Life Cycle

    public init(host: String = "apple.com") throws {
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, host) else {
            throw Error.creatingReachabilityFailed
        }
        self.reachability = reachability

        updateReachabilityFlags()
    }

    deinit {
        deactivate()
    }

    public func initialize() {
        autoUpdating = true
    }

    // MARK: - Connection State

    /// Connection state according to Apple's Reachability class
    /// https://developer.apple.com/library/archive/samplecode/Reachability/Introduction/Intro.html
    public var connectionState: InternetConnectionState {
        if !autoUpdating {
            updateReachabilityFlags()
        }

        return getConnectionState(for: currentFlags)
    }

    private func getConnectionState(for flags: SCNetworkReachabilityFlags) -> InternetConnectionState {
        guard flags.contains(.reachable) else {
            return .disconnected(getCurrentError())
        }
        if !flags.contains(.connectionRequired) {
            return .connected(.wifi)
        }
        if flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic),
           !flags.contains(.interventionRequired) {
            return .connected(.wifi)
        }
        if flags.contains(.isWWAN) {
            return .connected(.mobileData)
        }
        return .disconnected(getCurrentError())
    }

    private func getCurrentError() -> InternetConnectionError {
        guard cellularData.restrictedState != CTCellularDataRestrictedState.restricted else {
            return .mobileDataRestricted
        }
        return .unknown
    }

    // MARK: - Retrieving and Watching Reachability

    private var currentFlags: SCNetworkReachabilityFlags = []

    public var autoUpdating: Bool = false {
        didSet {
            guard autoUpdating != oldValue else { return }
            if autoUpdating {
                activate()
            } else {
                deactivate()
            }
        }
    }

    private func updateReachabilityFlags() {
        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(reachability, &flags)
        currentFlags = flags
    }

    private func activate() {
        do {
            try setupReachabilityCallback()
        } catch {
            print(error)
        }
        updateReachabilityFlags()
    }

    private func setupReachabilityCallback() throws {
        let selfReference = UnsafeMutableRawPointer(Unmanaged<InternetConnectionStateProvider>.passUnretained(self).toOpaque())
        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        context.info = selfReference

        let reachabilityCallback: SCNetworkReachabilityCallBack? = { _, flags, info in
            guard let info = info else { return }
            let detector = Unmanaged<InternetConnectionStateProvider>.fromOpaque(info).takeUnretainedValue()
            detector.currentFlags = flags
        }

        if !SCNetworkReachabilitySetCallback(reachability, reachabilityCallback, &context) {
            throw Error.registerCallbackFailed
        }
        if !SCNetworkReachabilitySetDispatchQueue(reachability, .main) {
            throw Error.setReachabilityDispatchQueueFailed
        }
    }

    private func deactivate() {
        SCNetworkReachabilitySetCallback(reachability, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(reachability, nil)
    }
}
