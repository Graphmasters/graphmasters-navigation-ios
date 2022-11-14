import AVFoundation

public extension AVSpeechSynthesisVoice {
    static var availableSynthesizerVoices: [AVSpeechSynthesisVoice] = AVSpeechSynthesisVoice.speechVoices()
        .filter { $0.language == Locale.autoupdatingCurrent.languageCode }
        .sorted { $0.identifier < $1.identifier }

    static var `default`: AVSpeechSynthesisVoice? = availableSynthesizerSiriVoices.first
        ?? availableEnhancedVoices.first
        ?? availableSynthesizerVoices.first

    static var availableEnhancedVoices: [AVSpeechSynthesisVoice] = availableSynthesizerVoices.filter { $0.quality == .enhanced }

    static var availableSynthesizerSiriVoices: [AVSpeechSynthesisVoice] = availableSynthesizerVoices.filter { $0.isSiriVoice }
}

public extension AVSpeechSynthesisVoice {
    var isSiriVoice: Bool {
        return identifier.lowercased().contains("siri")
    }
}
