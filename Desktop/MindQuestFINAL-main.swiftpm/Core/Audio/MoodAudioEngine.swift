import SwiftUI
import AVFoundation

@MainActor
class MoodAudioEngine: ObservableObject {
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    @Published var isPlaying = false
    @Published var activeMood: String? = nil
    
    enum MoodSound {
        case calm, focused, energetic, relaxed, happy
        
        var frequency: Double {
            switch self {
            case .calm: return 174.0 // Root/Healing
            case .focused: return 528.0 // Miracle/Clarity
            case .energetic: return 741.0 // Expression/Energy
            case .relaxed: return 396.0 // Relief
            case .happy: return 639.0 // Harmony
            }
        }
    }
    
    func play(mood: MoodSound) {
        stop()
        
        activeMood = "\(mood)"
        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        engine.attach(player)
        
        let sampleRate = 44100.0
        let bufferDuration = 2.0
        let frameCount = AVAudioFrameCount(sampleRate * bufferDuration)
        
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        
        buffer.frameLength = frameCount
        let leftChannel = buffer.floatChannelData![0]
        let rightChannel = buffer.floatChannelData![1]
        
        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            
            // Synthesize sound based on mood
            var value: Double = 0
            
            switch mood {
            case .calm:
                // Deep sine wave + slow modulation
                value = sin(2.0 * .pi * mood.frequency * t) * (0.8 + 0.2 * sin(2.0 * .pi * 0.1 * t))
            case .focused:
                // Binaural-style pulses
                value = sin(2.0 * .pi * mood.frequency * t) * (sin(2.0 * .pi * 10.0 * t) > 0 ? 1 : 0.5)
            case .energetic:
                // Sharp rhythmic pulses
                value = sin(2.0 * .pi * mood.frequency * t) * (abs(sin(2.0 * .pi * 2.0 * t)) > 0.8 ? 1 : 0.1)
            case .relaxed:
                // Soft sine with noise-like texture
                value = sin(2.0 * .pi * mood.frequency * t) * 0.7 + (Double.random(in: -1...1) * 0.05)
            case .happy:
                // Arpeggiating-like frequency sweep
                let sweep = mood.frequency + (100.0 * sin(2.0 * .pi * 0.5 * t))
                value = sin(2.0 * .pi * sweep * t)
            }
            
            let amplitude: Float = 0.2
            let fadeFrames = Int(sampleRate * 0.1)
            let window: Float
            if i < fadeFrames {
                window = Float(i) / Float(fadeFrames)
            } else if i > Int(frameCount) - fadeFrames {
                window = Float(Int(frameCount) - i) / Float(fadeFrames)
            } else {
                window = 1.0
            }
            
            leftChannel[i] = Float(value) * amplitude * window
            rightChannel[i] = Float(value) * amplitude * window
        }
        
        engine.connect(player, to: engine.mainMixerNode, format: format)
        
        do {
            try engine.start()
            player.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
            player.volume = 0
            player.play()
            
            Task {
                for i in 1...20 {
                    try? await Task.sleep(nanoseconds: 50_000_000)
                    player.volume = Float(i) / 20.0
                }
            }
            
            isPlaying = true
            audioEngine = engine
            playerNode = player
        } catch {
            print("Audio engine failure: \(error)")
        }
    }
    
    func stop() {
        guard let player = playerNode else { return }
        
        let currentActiveMood = activeMood
        activeMood = nil
        
        Task {
            let currentVol = player.volume
            for i in stride(from: 10, through: 0, by: -1) {
                try? await Task.sleep(nanoseconds: 30_000_000)
                player.volume = (Float(i) / 10.0) * currentVol
            }
            
            player.stop()
            self.audioEngine?.stop()
            self.audioEngine = nil
            self.playerNode = nil
            self.isPlaying = false
        }
    }
}
