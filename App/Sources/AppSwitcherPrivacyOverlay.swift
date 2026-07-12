import SwiftUI

/// E6.3 (R22.5) — the shield's content: a full-bleed, theme-aware `surface/base`
/// fill and NOTHING else. No crest, no wordmark, no glyph, no brand color — the user
/// chose a discreet ALTERNATE ICON precisely so the switcher chrome shows a
/// calendar/timer; any brand content in the card snapshot would out the app past the
/// disguise (Brand ruling: a theme-matched blank card reads as an ordinary empty app
/// and draws no eye; a fixed single neutral in the wrong theme would). Zero copy by
/// design — golden-able now, no founder-pass dependency (O2, light + dark).
struct AppSwitcherPrivacyOverlay: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        // brandkit surface/base: light #F7F6F3 / dark #121417 (tokens.json; the
        // app-background token, not surface/raised — "an app sitting on an empty
        // screen", per the Brand panel ruling).
        (colorScheme == .dark
            ? Color(red: 0x12 / 255, green: 0x14 / 255, blue: 0x17 / 255)
            : Color(red: 0xF7 / 255, green: 0xF6 / 255, blue: 0xF3 / 255))
            .ignoresSafeArea()
    }
}
