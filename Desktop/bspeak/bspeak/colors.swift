//
//  colors.swift
//  bspeak
//
//  Created by Student on 21/08/26.
//

import SwiftUI

extension Color {

    // ── BACKGROUNDS ──────────────────────────────────────────
    // Warm cream white — main app background
    // Feels calm and clean, not harsh white
    static let bsBackground = Color(
        red: 0.980, green: 0.980, blue: 0.961
    )

    // Slightly off-white — cards and surfaces
    static let bsSurface = Color(
        red: 0.961, green: 0.961, blue: 0.925
    )

    // Slightly deeper surface — elevated cards
    static let bsSurface2 = Color(
        red: 0.945, green: 0.945, blue: 0.906
    )

    // Pale warm border — dividers and outlines
    static let bsBorder = Color(
        red: 0.878, green: 0.878, blue: 0.835
    )

    // ── BRAND BLUES ───────────────────────────────────────────
    // Main sky blue — buttons, active states, iris
    static let bsPrimary = Color(
        red: 0.357, green: 0.643, blue: 0.812
    )

    // Softer cornflower — icons, secondary elements
    static let bsLilac = Color(
        red: 0.537, green: 0.769, blue: 0.882
    )

    // Palest sky — highlights, headings
    static let bsLavender = Color(
        red: 0.773, green: 0.898, blue: 0.949
    )

    // Deep navy — pressed states, dark accents
    static let bsDeep = Color(
        red: 0.102, green: 0.231, blue: 0.369
    )

    // ── BRAND YELLOWS ─────────────────────────────────────────
    // Sunshine yellow — accent, highlights, eye glow
    static let bsYellow = Color(
        red: 0.961, green: 0.784, blue: 0.259
    )

    // Pale lemon — soft backgrounds, pill fills
    static let bsYellowSoft = Color(
        red: 1.000, green: 0.953, blue: 0.690
    )

    // Deep golden — pressed yellow states
    static let bsYellowDeep = Color(
        red: 0.847, green: 0.635, blue: 0.118
    )

    // ── TEXT ──────────────────────────────────────────────────
    // Deep navy — primary readable text on light bg
    static let bsTextPrimary = Color(
        red: 0.102, green: 0.169, blue: 0.235
    )

    // Slate blue — secondary text, captions
    static let bsTextMuted = Color(
        red: 0.420, green: 0.498, blue: 0.557
    )

    // Pale blue grey — dim labels, hints
    static let bsTextDim = Color(
        red: 0.659, green: 0.722, blue: 0.769
    )

    // ── SEMANTIC ──────────────────────────────────────────────
    // Soft teal — blink confirmed, eye detected
    static let bsSuccess = Color(
        red: 0.302, green: 0.741, blue: 0.702
    )

    // Warm amber — warnings, caution states
    static let bsAlert = Color(
        red: 0.961, green: 0.651, blue: 0.137
    )

    // Pressed — darker blue for tap states
    static let bsPressed = Color(
        red: 0.220, green: 0.459, blue: 0.620
    )
}

// ── GRADIENTS ─────────────────────────────────────────────────
extension LinearGradient {

    // App name — pale sky to deep blue
    static let bsWordmark = LinearGradient(
        colors: [
            Color.bsLavender,
            Color.bsPrimary,
            Color.bsDeep
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    // Main button — blue to deep navy
    static let bsButton = LinearGradient(
        colors: [Color.bsPrimary, Color.bsDeep],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Blink confirmed — teal to blue
    static let bsConfirm = LinearGradient(
        colors: [Color.bsSuccess, Color.bsPrimary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Yellow accent gradient — lemon to gold
    static let bsYellowGrad = LinearGradient(
        colors: [Color.bsYellowSoft, Color.bsYellow],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Hero gradient — blue to yellow
    // Used on splash and onboarding hero sections
    static let bsHero = LinearGradient(
        colors: [Color.bsPrimary, Color.bsYellow],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension RadialGradient {

    // Splash background — soft yellow glow on cream
    static let bsAura = RadialGradient(
        gradient: Gradient(colors: [
            Color(red: 1.000, green: 0.965, blue: 0.800),
            Color.bsBackground
        ]),
        center: .init(x: 0.5, y: 0.35),
        startRadius: 0,
        endRadius: 420
    )

    // Eye iris — deep blue centre to sky rim
    static let bsIris = RadialGradient(
        gradient: Gradient(colors: [
            Color(red: 0.063, green: 0.157, blue: 0.310),
            Color(red: 0.161, green: 0.345, blue: 0.533),
            Color(red: 0.282, green: 0.557, blue: 0.737),
            Color(red: 0.537, green: 0.769, blue: 0.882),
            Color(red: 0.773, green: 0.898, blue: 0.949)
        ]),
        center: .init(x: 0.5, y: 0.38),
        startRadius: 0,
        endRadius: 60
    )
}
