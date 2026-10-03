import SwiftUI

// MARK: - What is this file?
// Every card in this app (a habit row, an activity row, a preset tile) shares
// the exact same chrome: white/dark surface, 16pt radius, 16pt padding, and
// one soft shadow. Before this file existed, each of those views wrote that
// out by hand — which is precisely how a design drifts out of spec: one card
// ends up with a 14pt radius, another forgets the shadow, and the screen
// starts to look subtly "off" without anyone being able to say why.
//
// A ViewModifier lets us describe that chrome ONCE and apply it with a single
// `.cardStyle()` call. Change the radius here and every card in the app moves
// together.

struct CardStyle: ViewModifier {
    /// Cards on Home use the full padding; smaller chips pass a tighter value.
    var padding: CGFloat = AppTheme.Spacing.lg
    var cornerRadius: CGFloat = AppTheme.Radius.card

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(AppTheme.cardBackground)
            // `.clipShape` rather than the deprecated `.cornerRadius(_:)`.
            // It also states the intent more honestly: we are clipping the
            // view to a shape, not setting a "corner radius property".
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            // `.continuous` gives the squircle Apple uses throughout iOS.
            // The default (`.circular`) corner is visibly rounder/tighter and
            // is one of the most common giveaways that a UI wasn't built to spec.
            .shadow(
                color: AppTheme.Elevation.color,
                radius: AppTheme.Elevation.radius,
                x: 0,
                y: AppTheme.Elevation.y
            )
    }
}

extension View {
    /// Applies the app's standard card chrome (surface, radius, padding, shadow).
    func cardStyle(
        padding: CGFloat = AppTheme.Spacing.lg,
        cornerRadius: CGFloat = AppTheme.Radius.card
    ) -> some View {
        modifier(CardStyle(padding: padding, cornerRadius: cornerRadius))
    }
}
