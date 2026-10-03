//
//  AACGridView.swift
//  bspeak
//
//  Created by Student on 21/08/26.
//

import SwiftUI

struct AACGridView: View {

    // The sentence being built up
    @State private var sentence: [String] = []

    // Which cell is currently highlighted by scanner
    @State private var highlightedIndex = 0

    // Whether scanning is active
    @State private var isScanning = false

    // Controls the dwell ring animation
    @State private var dwellProgress = 0.0

    // Scanner timer
    @State private var scanTimer: Timer?

    // Dwell time in seconds — will come from settings later
    let dwellTime = 2.5

    // The phrase grid
    let phrases: [AACPhrase] = [
        AACPhrase(emoji: "🆘", label: "HELP",     text: "I need help"),
        AACPhrase(emoji: "💧", label: "WATER",    text: "I need water"),
        AACPhrase(emoji: "😣", label: "PAIN",     text: "I am in pain"),
        AACPhrase(emoji: "✅", label: "YES",      text: "Yes"),
        AACPhrase(emoji: "❌", label: "NO",       text: "No"),
        AACPhrase(emoji: "🙏", label: "PLEASE",   text: "Please"),
        AACPhrase(emoji: "🚽", label: "BATHROOM", text: "I need to go the bathroom"),
        AACPhrase(emoji: "😴", label: "TIRED",    text: "I am tired"),
        AACPhrase(emoji: "😊", label: "HAPPY",    text: "I'm happy!"),
        AACPhrase(emoji: "😋", label: "HUNGRY",   text: "Feed me"),
        AACPhrase(emoji: "😡", label: "ANGRY",    text: "Leave me alone"),
        AACPhrase(emoji: "💊", label: "MED TIME", text: "It's time for my meds"),
        AACPhrase(emoji: "😪", label: "SLEEP",    text: "I need to sleep"),
        AACPhrase(emoji: "🚗", label:  "GO OUT",   text: "I want to go out "),
        AACPhrase(emoji: "➕", label: "MORE",     text: "I want more")
    ]

    let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

    var body: some View {
        ZStack {
            Color.bsBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                sentenceBar
                phraseGrid
                bottomHint
            }
        }
        .onAppear {
            startScanning()
        }
        .onDisappear {
            stopScanning()
        }
    }

    // ── TOP BAR ──────────────────────────────────────────────
    var topBar: some View {
        HStack {
            Text("AAC Grid")
                .font(.custom("AvenirNext-Heavy", size: 17))
                .tracking(2)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.bsLavender, Color.bsPrimary],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Spacer()

            // Scanning indicator
            HStack(spacing: 6) {
                Circle()
                    .fill(isScanning ? Color.bsSuccess : Color.bsTextDim)
                    .frame(width: 7, height: 7)
                    .shadow(color: isScanning ? .bsSuccess : .clear, radius: 4)

                Text(isScanning ? "SCANNING" : "PAUSED")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(2)
                    .foregroundColor(isScanning ? .bsSuccess : .bsTextDim)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.bsSurface)
                    .overlay(Capsule().stroke(Color.bsBorder, lineWidth: 1))
            )
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
    }

    // ── SENTENCE BAR ─────────────────────────────────────────
    var sentenceBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PHRASE")
                .font(.system(size: 9, weight: .bold))
                .tracking(2.5)
                .foregroundColor(.bsTextDim)

            HStack(spacing: 0) {
                if sentence.isEmpty {
                    Text("Blink to select words...")
                        .font(.system(size: 15))
                        .foregroundColor(.bsTextDim)
                        .italic()
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(Array(sentence.enumerated()), id: \.offset) { _, word in
                                Text(word)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.bsLavender)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(
                                        Capsule()
                                            .fill(Color.bsPrimary.opacity(0.15))
                                            .overlay(
                                                Capsule()
                                                    .stroke(Color.bsPrimary.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                            }
                        }
                    }
                }

                Spacer()

                // Blinking cursor
                Rectangle()
                    .fill(Color.bsPrimary)
                    .frame(width: 2, height: 18)
                    .opacity(0.8)
            }

            // Action buttons
            HStack(spacing: 8) {
                actionButton(label: "🔊 SPEAK",  color: .bsPrimary) {
                    speakSentence()
                }
                actionButton(label: "⌫ CLEAR",   color: .bsAlert) {
                    withAnimation { sentence.removeAll() }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.bsSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.bsBorder, lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 14)
    }

    func actionButton(
        label: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .tracking(1.5)
                .foregroundColor(color)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(color.opacity(0.3), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }

    // ── PHRASE GRID ───────────────────────────────────────────
    var phraseGrid: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(Array(phrases.enumerated()), id: \.offset) { index, phrase in
                AACCellView(
                    phrase: phrase,
                    isHighlighted: highlightedIndex == index,
                    dwellProgress: highlightedIndex == index ? dwellProgress : 0
                )
                .onTapGesture {
                    // Also allow tap for caregivers testing
                    selectPhrase(at: index)
                }
            }
        }
        .padding(.horizontal, 16)
    }

    // ── BOTTOM HINT ───────────────────────────────────────────
    var bottomHint: some View {
        Text("SINGLE BLINK to select · LONG BLINK to speak")
            .font(.system(size: 9, weight: .semibold))
            .tracking(1.5)
            .foregroundColor(.bsTextDim)
            .padding(.top, 14)
            .padding(.bottom, 8)
    }

    // ── SCANNING LOGIC ────────────────────────────────────────
    func startScanning() {
        isScanning = true
        dwellProgress = 0

        scanTimer = Timer.scheduledTimer(
            withTimeInterval: dwellTime,
            repeats: true
        ) { _ in
            withAnimation(.easeInOut(duration: 0.2)) {
                highlightedIndex = (highlightedIndex + 1) % phrases.count
                dwellProgress = 0
            }
            // Animate dwell progress filling up
            withAnimation(.linear(duration: dwellTime)) {
                dwellProgress = 1.0
            }
        }

        // Start first dwell animation immediately
        withAnimation(.linear(duration: dwellTime)) {
            dwellProgress = 1.0
        }
    }

    func stopScanning() {
        isScanning = false
        scanTimer?.invalidate()
        scanTimer = nil
    }

    func selectPhrase(at index: Int) {
        let phrase = phrases[index]

        withAnimation(.spring(duration: 0.3)) {
            sentence.append(phrase.text)
        }

        // Haptic
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }

    func speakSentence() {
        guard !sentence.isEmpty else { return }
        let full = sentence.joined(separator: " ")
        SpeechManager.shared.speak(full)

        // Haptic
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
    }
}

// ── AAC CELL VIEW ─────────────────────────────────────────────
struct AACCellView: View {

    let phrase: AACPhrase
    let isHighlighted: Bool
    let dwellProgress: Double

    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    isHighlighted
                    ? Color.bsPrimary.opacity(0.18)
                    : Color.bsSurface
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isHighlighted
                            ? Color.bsPrimary.opacity(0.6)
                            : Color.bsBorder,
                            lineWidth: isHighlighted ? 1.5 : 1
                        )
                )

            // Content
            VStack(spacing: 8) {
                Text(phrase.emoji)
                    .font(.system(size: 28))

                Text(phrase.label)
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.5)
                    .foregroundColor(
                        isHighlighted ? Color.bsLilac : Color.bsTextMuted
                    )
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 16)

            // Dwell progress arc around the cell
            if isHighlighted {
                RoundedRectangle(cornerRadius: 12)
                    .trim(from: 0, to: dwellProgress)
                    .stroke(
                        Color.bsPrimary,
                        style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                    )
                    .animation(.linear(duration: 0.1), value: dwellProgress)
            }
        }
        .scaleEffect(isHighlighted ? 1.04 : 1.0)
        .shadow(
            color: isHighlighted ? Color.bsPrimary.opacity(0.3) : .clear,
            radius: 12
        )
        .animation(.spring(duration: 0.3), value: isHighlighted)
    }
}

// ── MODEL ─────────────────────────────────────────────────────
struct AACPhrase {
    let emoji: String
    let label: String
    let text: String
}

#Preview {
    AACGridView()
}
