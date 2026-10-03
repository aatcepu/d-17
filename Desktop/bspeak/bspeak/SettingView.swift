//
//  SettingView.swift
//  bspeak
//
//  Created by Student on 21/08/26.
//

import SwiftUI

struct SettingsView: View {

    // All settings saved automatically to device storage
    @AppStorage("dwellTime")       private var dwellTime       = 1.5
    @AppStorage("blinkThreshold")  private var blinkThreshold  = 0.15
    @AppStorage("speechRate")      private var speechRate      = 0.48
    @AppStorage("hapticEnabled")   private var hapticEnabled   = true
    @AppStorage("largeCells")      private var largeCells      = false
    @AppStorage("hasOnboarded")    private var hasOnboarded    = true

    var body: some View {
        ZStack {
            Color.bsBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    topBar
                    profileCard
                    detectionSection
                    voiceSection
                    displaySection
                    aboutSection
                }
                .padding(.bottom, 32)
            }
        }
    }

    // ── TOP BAR ──────────────────────────────────────────────
    var topBar: some View {
        HStack {
            Text("Settings")
                .font(.custom("AvenirNext-Heavy", size: 22))
                .tracking(1)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.bsLavender, Color.bsPrimary],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
    }

    // ── PROFILE CARD ─────────────────────────────────────────
    var profileCard: some View {
        HStack(spacing: 14) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.bsPrimary, Color.bsDeep],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)
                Image(systemName: "eye.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.bsLavender)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("BlinkSpeak User")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.bsTextPrimary)
                Text("Eye detection active")
                    .font(.system(size: 12))
                    .foregroundColor(.bsTextMuted)
            }
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.bsSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.bsBorder, lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
    }

    // ── DETECTION SETTINGS ────────────────────────────────────
    var detectionSection: some View {
        settingsSection(title: "DETECTION") {
            sliderRow(
                label: "Dwell Time",
                value: $dwellTime,
                range: 0.8...3.0,
                unit: "s",
                hint: "How long before a cell auto-selects"
            )
            sliderRow(
                label: "Blink Sensitivity",
                value: $blinkThreshold,
                range: 0.08...0.25,
                unit: "",
                hint: "Lower = more sensitive to blinks"
            )
            buttonRow(label: "Recalibrate Blink") {
                // Will trigger calibration flow
            }
        }
    }

    // ── VOICE SETTINGS ────────────────────────────────────────
    var voiceSection: some View {
        settingsSection(title: "VOICE") {
            sliderRow(
                label: "Speech Rate",
                value: $speechRate,
                range: 0.2...0.7,
                unit: "",
                hint: "How fast the app speaks"
            )
            valueRow(label: "Language", value: "English (US)")
            valueRow(label: "Voice",    value: "Default")
        }
    }

    // ── DISPLAY SETTINGS ──────────────────────────────────────
    var displaySection: some View {
        settingsSection(title: "DISPLAY") {
            toggleRow(label: "Haptic Feedback",
                      hint: "Vibrate when blink detected",
                      value: $hapticEnabled)
            toggleRow(label: "Large AAC Cells",
                      hint: "Bigger cells for easier viewing",
                      value: $largeCells)
        }
    }

    // ── ABOUT ─────────────────────────────────────────────────
    var aboutSection: some View {
        settingsSection(title: "ABOUT") {
            valueRow(label: "Version",    value: "1.0.0")
            valueRow(label: "Built with", value: "Vision · AVFoundation · SwiftUI")
            valueRow(label: "Challenge",  value: "Swift Student Challenge 2026")
        }
    }

    // ── REUSABLE SECTION WRAPPER ──────────────────────────────
    func settingsSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .tracking(2.5)
                .foregroundColor(.bsTextDim)
                .padding(.horizontal, 20)
                .padding(.bottom, 8)

            VStack(spacing: 1) {
                content()
            }
            .background(Color.bsSurface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.bsBorder, lineWidth: 1)
            )
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 24)
    }

    // ── ROW TYPES ─────────────────────────────────────────────
    func valueRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.bsTextPrimary)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.bsLilac)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    func toggleRow(
        label: String,
        hint: String,
        value: Binding<Bool>
    ) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(.system(size: 13))
                    .foregroundColor(.bsTextPrimary)
                Text(hint)
                    .font(.system(size: 11))
                    .foregroundColor(.bsTextDim)
            }
            Spacer()
            Toggle("", isOn: value)
                .tint(Color.bsPrimary)
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    func sliderRow(
        label: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        unit: String,
        hint: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.system(size: 13))
                    .foregroundColor(.bsTextPrimary)
                Spacer()
                Text(String(format: "%.2f\(unit)", value.wrappedValue))
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.bsPrimary)
            }
            Slider(value: value, in: range)
                .tint(Color.bsPrimary)
            Text(hint)
                .font(.system(size: 11))
                .foregroundColor(.bsTextDim)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    func buttonRow(label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.bsPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.bsTextDim)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsView()
}
