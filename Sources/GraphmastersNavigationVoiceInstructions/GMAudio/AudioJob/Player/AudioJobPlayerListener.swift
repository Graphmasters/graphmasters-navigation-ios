import Foundation

public protocol AudioJobPlayerListener {
    func audioJobPlayer(_ audioJobPlayer: AudioJobPlayer, didStart audioJob: AudioJob)

    func audioJobPlayer(_ audioJobPlayer: AudioJobPlayer, didFinish audioJob: AudioJob)
}
