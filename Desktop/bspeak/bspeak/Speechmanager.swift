//
//  Speechmanager.swift
//  bspeak
//
//  Created by Student on 21/08/26.
//

import AVFoundation
import SwiftUI
import Combine

class SpeechManager: NSObject, ObservableObject {

    static let shared = SpeechManager()

    private let synthesizer = AVSpeechSynthesizer()
    private var cancellables = Set<AnyCancellable>()

    var isSpeaking = false

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.48
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0

        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}

extension SpeechManager: AVSpeechSynthesizerDelegate {

    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didStart utterance: AVSpeechUtterance
    ) {
        DispatchQueue.main.async {
            self.isSpeaking = true
        }
    }

    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance
    ) {
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }
}
