import Foundation

@available(iOS 13.0.0, *)
public protocol AudioControllerListener {
    func willActivateAudio(_ controller: AudioController)
    func didDeactivateAudio(_ controller: AudioController)
}

@available(iOS 13.0.0, *)
public protocol AudioController {
    func activateAudio() async throws
    func deactivateAudio() async throws

    var isActive: Bool { get }

    func add(listener: AudioControllerListener)
    func remove(listener: AudioControllerListener)
}

@available(iOS 13.0.0, *)
public extension AudioController {
    func activateAudio(completion: @escaping (Result<Void, Error>) -> Void) {
        Task(priority: .background) {
            do {
                try await activateAudio()
                completion(.success({}()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func deactivateAudio(completion: @escaping (Result<Void, Error>) -> Void) {
        Task(priority: .background) {
            do {
                try await deactivateAudio()
                completion(.success({}()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
