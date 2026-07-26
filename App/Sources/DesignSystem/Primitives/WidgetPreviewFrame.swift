import SwiftUI
import WidgetToolkit

/// ME-1 (redesign §6.15 / §9.4) — `WidgetPreviewFrame`: the device-mock frame
/// that renders the TRUE widget feed into a stylized lock screen. The one place
/// marketing-style composition enters the product: the Horizon Gradient lives
/// behind the mock lock screen ONLY (illustration doctrine §9.6 — never in app
/// chrome, never in widgets themselves).
///
/// Honesty contract: the slot renders the REAL `StreakWidgetView` over the REAL
/// composed entry — the preview obeys every lexicon rule because it renders the
/// true feed (discreet quits show the discreet variant automatically; an empty
/// feed shows the calm "Ready when you are." unavailable state, never a
/// fabricated Day 0).
///
/// Contrast: the gradient never sits behind text — the widget content rides a
/// scrim panel at the pinned 55% floor (`Theme.alpha.scrim`, the light-mode
/// white-on-scrim 4.5:1 floor; the composite under it here is darker than that
/// floor's worst case). Lives in DesignSystem because the mock's lock-screen
/// monochromes are composition constants of THIS frame, not app-palette tokens.
struct WidgetPreviewFrame: View {
    /// The composed entry at "now" (`StreakWidgetComposer` output — timing).
    let entry: StreakWidgetEntry
    /// The selected quit's rich DTO (money/discreet); nil = unavailable state.
    let quit: WidgetQuitState?

    var body: some View {
        ZStack {
            // The Horizon Gradient — Harbor Teal sky into Dusk Indigo water
            // (§9.1: illustration backdrops only; this mock is that tier).
            LinearGradient(
                colors: [
                    Theme.color.brandPrimary.color,
                    Theme.color.brandSecondary.color,
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // The widget slot: the real rectangular family, frozen at the
            // entry's own instant, on the lock screen's scrim-dark backing.
            StreakWidgetView(
                family: .rectangular,
                entry: entry,
                quit: quit,
                pauseDate: entry.date
            )
            // Lock-screen accessory rendering is luminance-only monochrome —
            // the mock reproduces it (meaning lives in glyph + text, never hue).
            .foregroundStyle(.white)
            .environment(\.colorScheme, .dark)
            .padding(.horizontal, Theme.space.s4)
            .padding(.vertical, Theme.space.s3)
            .frame(width: 200, height: 84)
            .background(
                Color.black.opacity(Theme.alpha.scrim),
                in: RoundedRectangle(cornerRadius: Theme.radius.l)
            )
            // A PREVIEW, never a control: the real widget button carries a live
            // panic intent, and a preview tap must not open the panic flow.
            .allowsHitTesting(false)
        }
        .frame(height: 200)
        .frame(maxWidth: Theme.layout.contentMaxWidth)
        .clipShape(RoundedRectangle(cornerRadius: Theme.radius.l))
        // Decorative composition — the caller carries the described a11y label
        // (redesign §8: "the widget-adoption preview is described").
        .accessibilityHidden(true)
    }
}
