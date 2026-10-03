import SwiftUI
import AVFoundation

// MARK: - Advanced Tone Generator (Calibrated)
@MainActor
class ToneGenerator: ObservableObject {
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    @Published var isPlaying = false
    
    func playTone(frequency: Double, duration: Double = 60.0) {
        stop()
        
        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        engine.attach(player)
        
        let sampleRate = 44100.0
        // We'll use a 2-second looping buffer for memory efficiency
        let bufferDuration = 2.0
        let frameCount = AVAudioFrameCount(sampleRate * bufferDuration)
        
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        
        buffer.frameLength = frameCount
        let leftChannel = buffer.floatChannelData![0]
        let rightChannel = buffer.floatChannelData![1]
        
        // Generate a smooth sine wave with windowing to avoid clicks
        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            // Main Frequency
            let value = sin(2.0 * .pi * frequency * t)
            
            // Apply slight psychoacoustic normalization (0.25 amplitude)
            let amplitude: Float = 0.25
            
            // Cross-fade window at buffer boundaries to ensure seamless loop
            let window: Float
            let fadeFrames = Int(sampleRate * 0.1) // 100ms fade
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
            // Schedule the buffer to loop
            player.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
            
            // Set initial volume to 0 for fade-in
            player.volume = 0
            player.play()
            
            // Fade-in: 1.0 second
            Task {
                for i in 1...20 {
                    try? await Task.sleep(nanoseconds: 50_000_000) // 50ms
                    player.volume = Float(i) / 20.0
                }
            }
            
            isPlaying = true
            audioEngine = engine
            playerNode = player
            
        } catch {
            print("Audio engine error: \(error)")
        }
    }
    
    func stop() {
        guard let player = playerNode else { return }
        
        // Fade-out: 0.5 second
        Task {
            let currentVol = player.volume
            for i in stride(from: 10, through: 0, by: -1) {
                try? await Task.sleep(nanoseconds: 50_000_000) // 50ms
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

// MARK: - Soundscape View
struct SoundscapeView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var toneGen = ToneGenerator()
    @State private var activeTrack: SoundTrack? = nil
    @State private var animateWaves = false
    var initialTrackName: String? = nil
    
    var body: some View {
        ZStack {
            Theme.navyGradient.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                AppHeader(
                    title: "Healing Sounds",
                    subtitle: "Solfeggio Frequencies",
                    showBackButton: true,
                    backAction: {
                        toneGen.stop()
                        dismiss()
                    }
                )
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Now playing visualizer
                        ZStack {
                            Circle()
                                .fill(activeTrack?.color.opacity(0.1) ?? Color.white.opacity(0.02))
                                .frame(width: 240, height: 240)
                                .blur(radius: 40)
                            
                            VStack(spacing: 20) {
                                if let track = activeTrack {
                                    Text(track.emoji)
                                        .font(.system(size: 80))
                                        .shadow(color: track.color.opacity(0.5), radius: 20)
                                        .transition(.scale.combined(with: .opacity))
                                    
                                    VStack(spacing: 4) {
                                        Text(track.name)
                                            .font(.system(.title2, design: .rounded))
                                            .fontWeight(.bold)
                                            .foregroundColor(Theme.textPrimary)
                                        
                                        Text("\(Int(track.frequency)) Hz")
                                            .font(.system(.subheadline, design: .rounded))
                                            .fontWeight(.semibold)
                                            .foregroundColor(track.color)
                                    }
                                    
                                    // Smooth Wave visualizer
                                    HStack(spacing: 4) {
                                        ForEach(0..<15, id: \.self) { i in
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(track.color.opacity(0.6))
                                                .frame(width: 4, height: animateWaves ? CGFloat.random(in: 10...50) : 6)
                                                .animation(
                                                    .easeInOut(duration: Double.random(in: 0.4...0.9))
                                                    .repeatForever(autoreverses: true)
                                                    .delay(Double(i) * 0.05),
                                                    value: animateWaves
                                                )
                                        }
                                    }
                                    .frame(height: 50)
                                    
                                    Text(track.description)
                                        .font(.system(.body, design: .rounded))
                                        .foregroundColor(Theme.textSecondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 40)
                                        .transition(.opacity)
                                } else {
                                    VStack(spacing: 16) {
                                        Image(systemName: "waveform")
                                            .font(.system(size: 60))
                                            .foregroundColor(.white.opacity(0.1))
                                        
                                        Text("Select a frequency to begin")
                                            .font(.system(.headline, design: .rounded))
                                            .foregroundColor(Theme.textSecondary.opacity(0.4))
                                    }
                                }
                            }
                        }
                        .frame(height: 320)
                        
                        // Sound tracks grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(SoundTrack.all) { track in
                                SoundTrackCard(
                                    track: track,
                                    isActive: activeTrack?.id == track.id,
                                    action: {
                                        withAnimation(.spring()) {
                                            if activeTrack?.id == track.id {
                                                HapticAgent.shared.playImpact(.soft)
                                                toneGen.stop()
                                                activeTrack = nil
                                                animateWaves = false
                                                EngagementAgent.shared.logMusicSession()
                                            } else {
                                                HapticAgent.shared.playImpact(.rigid)
                                                activeTrack = track
                                                toneGen.playTone(frequency: track.frequency)
                                                animateWaves = true
                                            }
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            if let targetName = initialTrackName?.lowercased() {
                // ── Direct name match ──
                if let track = SoundTrack.all.first(where: { track in
                    targetName.contains(track.name.lowercased()) || 
                    track.name.lowercased().contains(targetName)
                }) {
                    activeTrack = track
                } 
                // ── Music Activity → Distinct Track Mapping ──
                // Euphoric mood
                else if targetName.contains("upbeat") || targetName.contains("playlist") {
                    activeTrack = SoundTrack.all[4] // Miracle (528Hz)
                } else if targetName.contains("sing") {
                    activeTrack = SoundTrack.all[6] // Awareness (741Hz)
                }
                // Happy mood
                else if targetName.contains("feel-good") || targetName.contains("feel good") || targetName.contains("hits") {
                    activeTrack = SoundTrack.all[5] // Harmony (639Hz)
                } else if targetName.contains("rhythm") || targetName.contains("clap") {
                    activeTrack = SoundTrack.all[3] // Change (417Hz)
                }
                // Calm mood
                else if targetName.contains("lo-fi") || targetName.contains("chill") || targetName.contains("lofi") {
                    activeTrack = SoundTrack.all[7] // Spirit (852Hz)
                } else if targetName.contains("nature") || targetName.contains("rain") || targetName.contains("ocean") {
                    activeTrack = SoundTrack.all[3] // Change (417Hz)
                }
                // Confused mood
                else if targetName.contains("acoustic") || targetName.contains("guitar") {
                    activeTrack = SoundTrack.all[2] // Relief (396Hz)
                } else if targetName.contains("humming") || targetName.contains("hum") {
                    activeTrack = SoundTrack.all[0] // Root (174Hz)
                }
                // Sad mood
                else if targetName.contains("ambient") {
                    activeTrack = SoundTrack.all[1] // Sacral (285Hz)
                } else if targetName.contains("sound bath") || targetName.contains("bath") || targetName.contains("healing") || targetName.contains("frequency") {
                    activeTrack = SoundTrack.all[5] // Harmony (639Hz)
                }
                // Default mood
                else if targetName.contains("calm wave") || targetName.contains("calm") {
                    activeTrack = SoundTrack.all[0] // Root (174Hz)
                } else if targetName.contains("focused") || targetName.contains("pulse") || targetName.contains("focus") {
                    activeTrack = SoundTrack.all[4] // Miracle (528Hz)
                } else if targetName.contains("energetic") || targetName.contains("flow") || targetName.contains("energy") {
                    activeTrack = SoundTrack.all[6] // Awareness (741Hz)
                } else if targetName.contains("mood music") || targetName.contains("mood") {
                    activeTrack = SoundTrack.all[2] // Relief (396Hz)
                }
                // New activities
                else if targetName.contains("victory") || targetName.contains("anthem") {
                    activeTrack = SoundTrack.all[6] // Awareness (741Hz)
                } else if targetName.contains("sunshine") || targetName.contains("melody") {
                    activeTrack = SoundTrack.all[5] // Harmony (639Hz)
                } else if targetName.contains("zen") || targetName.contains("drone") {
                    activeTrack = SoundTrack.all[7] // Spirit (852Hz)
                } else if targetName.contains("comfort") || targetName.contains("tone") {
                    activeTrack = SoundTrack.all[0] // Root (174Hz)
                } else if targetName.contains("gentle rain") || targetName.contains("rain") {
                    activeTrack = SoundTrack.all[1] // Sacral (285Hz)
                }
                // ── Ultimate Fallback ──
                else {
                    let index = abs(targetName.hashValue % SoundTrack.all.count)
                    activeTrack = SoundTrack.all[index]
                }
                
                if let track = activeTrack {
                    toneGen.playTone(frequency: track.frequency)
                    animateWaves = true
                }
            }
        }
        .onDisappear { toneGen.stop() }
    }
}

// MARK: - Precise Solfeggio Models
struct SoundTrack: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let description: String
    let frequency: Double
    let color: Color
    
    static let all: [SoundTrack] = [
        SoundTrack(name: "Root", emoji: "🔴", description: "Relief of pain & tension", frequency: 174.0, color: Color(red: 0.9, green: 0.2, blue: 0.2)),
        SoundTrack(name: "Sacral", emoji: "🟠", description: "Internal organ healing", frequency: 285.0, color: Color(red: 1.0, green: 0.5, blue: 0.2)),
        SoundTrack(name: "Relief", emoji: "🟡", description: "Liberating guilt & fear", frequency: 396.0, color: Color(red: 1.0, green: 0.8, blue: 0.2)),
        SoundTrack(name: "Change", emoji: "🟢", description: "Undoing situations & change", frequency: 417.0, color: Color(red: 0.2, green: 0.8, blue: 0.4)),
        SoundTrack(name: "Miracle", emoji: "🔵", description: "Transformation & DNA repair", frequency: 528.0, color: Color(red: 0.2, green: 0.5, blue: 1.0)),
        SoundTrack(name: "Harmony", emoji: "🟣", description: "Connecting & relationships", frequency: 639.0, color: Color(red: 0.6, green: 0.3, blue: 0.9)),
        SoundTrack(name: "Awareness", emoji: "💎", description: "Expression & solutions", frequency: 741.0, color: Color(red: 0.3, green: 0.8, blue: 0.9)),
        SoundTrack(name: "Spirit", emoji: "⚪️", description: "Returning to spiritual order", frequency: 852.0, color: .white),
    ]
}

struct SoundTrackCard: View {
    let track: SoundTrack
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text(track.emoji)
                    .font(.system(size: 32))
                
                VStack(spacing: 2) {
                    Text(track.name)
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(Theme.textPrimary)
                    
                    Text("\(Int(track.frequency))Hz")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(track.color)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(
                ZStack {
                    isActive ? track.color.opacity(0.15) : Color.white.opacity(0.04)
                    if isActive {
                        track.color.opacity(0.1).blur(radius: 10)
                    }
                }
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isActive ? track.color.opacity(0.6) : Color.white.opacity(0.1), lineWidth: isActive ? 2 : 0.5)
            )
            .shadow(color: isActive ? track.color.opacity(0.3) : .clear, radius: 10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
