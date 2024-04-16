import AVFoundation
import Foundation

public protocol AudioSessionConfigurationProvider {
    var config: AVAudioSession.Config { get }

    var additionalOptions: AVAudioSession.CategoryOptions { get }
}

public extension AudioSessionConfigurationProvider {
    var additionalOptions: AVAudioSession.CategoryOptions { [] }
}
