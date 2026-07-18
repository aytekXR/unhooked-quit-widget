import SwiftUI

/// UIR-2 (Session 34) — the real per-quit streak card (brandkit §6#9), replacing the
/// `RootPlaceholderView` "walking skeleton". Streak-day hero + flame + momentum figure
/// + the momentum `StreakRing` + money saved + a next-milestone bar, on the `themedCard`
/// surface. Up to three render on the dashboard (one per active quit).
///
/// **Copy discipline (roadmap §2.5): UIR moves pixels, never words.** Every visible
/// string is audited (`DashboardCopy.savedLabel`, `DashboardCopy.milestoneLabel`) or
/// pure ADR-11 data (`"Day N"`, a currency figure, `"N%"`). The §3-blocked polish
/// strings (frozen tooltip, reduce framing) are empty-guarded — no empty `Text` renders.
///
/// **R33.12 / Dynamic-Type (obeyed verbatim):** every `Text` is sized by a TEXT STYLE,
/// never `.font(.system(size:))`; point sizes appear only on DECORATIVE `Image`s (the
/// flame, the frozen glyph); `ViewThatFits` is absent — the accessibility-size layout
/// pivot is read off `@Environment(\.dynamicTypeSize)`; every wrapping `Text` carries
/// `.fixedSize(horizontal: false, vertical: true)` so it wraps rather than clips; no
/// `.minimumScaleFactor`, no `.lineLimit(1)`, no `.buttonStyle(.plain)`. The card itself
/// is non-interactive; the pinned panic entry lives in `RootPlaceholderView`.
struct StreakDashboardCard: View {
    let model: StreakCardModel
    /// The XCUITest / VoiceOver anchor. Real rows pass `dashboard.card.<quit-uuid>`; the
    /// audit + snapshot fixtures pass a fixed id. Queried via
    /// `descendants(matching: .any)` — a `.contain` group can surface as `.other` (R33.13).
    var accessibilityID: String = "dashboard.card"
    /// UIR-5c motion: the live dashboard passes `true` to opt the `StreakRing` into its
    /// `motion/calm` appear animation. Snapshots + the audit mount keep the default `false`
    /// (settled ring) so the dashboard goldens stay byte-stable and the audit is unaffected.
    var animateRing: Bool = false

    @Environment(\.dynamicTypeSize) private var typeSize
    private var isAX: Bool { typeSize.isAccessibilitySize }
    /// The ring and the momentum figure both go neutral when discreet or frozen.
    private var neutralMomentum: Bool { model.isDiscreet || model.isFrozen }
    /// Rounded percent — matches the widget's `Int((momentum * 100).rounded())`.
    private var momentumPercent: Int { Int((model.momentumFraction * 100).rounded()) }

    var body: some View {
        cardContent
            .padding(Theme.space.s4)
            .frame(maxWidth: Theme.layout.contentMaxWidth) // brandkit §5 one-column measure
            .frame(maxWidth: .infinity)
            .themedCard() // surface/raised, radius/m, hairline
            // `.contain` (not `.ignore`): the composed VoiceOver sentence is §3-blocked
            // (DashboardCopy.composedLabel), so each Text carries its own natural
            // description. Upgrades to `.ignore` + composedLabel once §3 signs the framing.
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(accessibilityID)
    }

    // MARK: - Layout pivot (no ViewThatFits — R33.12)

    /// At accessibility sizes the text column takes the full width and the ring is
    /// OMITTED (pure decoration; the momentum figure is still spoken/shown, so no
    /// information is lost). Below that, the ring trails the data column.
    @ViewBuilder private var cardContent: some View {
        if isAX {
            dataStack
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            HStack(alignment: .top, spacing: Theme.space.s4) {
                dataStack
                Spacer(minLength: Theme.space.s4)
                StreakRing(
                    fraction: model.momentumFraction,
                    isDiscreet: model.isDiscreet,
                    isFrozen: model.isFrozen,
                    animateOnAppear: animateRing
                )
                .frame(width: 72, height: 72) // decorative Shape frame — R33.12 safe
            }
        }
    }

    // MARK: - Data column

    private var dataStack: some View {
        VStack(alignment: .leading, spacing: Theme.space.s3) {
            // Streak-day hero — ADR-11 data. "Day" is the same pattern as the audited
            // widget (StreakWidgetDisplay.dayText). TEXT STYLE, never a point size.
            Text("Day \(model.dayNumber)")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(Theme.color.contentPrimary.color)
                .fixedSize(horizontal: false, vertical: true)

            // Momentum figure — pure data. The flame is a DECORATIVE Image (point size
            // exempt, a11y-hidden). The percent is indigo when active, neutral gray when
            // discreet/frozen (content/secondary keeps it 4.5-clean at subheadline size).
            HStack(spacing: Theme.space.s2) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 20)) // decorative Image — R33.12 exempt
                    .foregroundStyle(Theme.color.accentFlame.color)
                    .accessibilityHidden(true)
                Text("\(momentumPercent)%")
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .monospacedDigit()
                    .foregroundStyle(
                        neutralMomentum
                            ? Theme.color.contentSecondary.color
                            : Theme.color.brandSecondary.color
                    )
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Money saved — hidden in discreet mode (a currency figure beside a day count
            // reads as an abstinence-savings tracker; the widget's showsMoney precedent).
            if !model.isDiscreet, let money = formattedMoney() {
                VStack(alignment: .leading, spacing: Theme.space.s1) {
                    Text(money) // ADR-11 data — NumberFormatter, zero fraction digits
                        .font(.system(.title2, design: .rounded, weight: .semibold))
                        .monospacedDigit()
                        .foregroundStyle(Theme.color.positive.color)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(DashboardCopy.savedLabel) // "saved" — AUDITED (Session-21)
                        .font(.subheadline)
                        .foregroundStyle(Theme.color.contentSecondary.color)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            // Next-milestone bar — omitted when there is no next rung (never fabricated).
            // Discreet drops the label (recovery vocabulary) but keeps the neutral bar.
            if let progress = model.milestoneProgress {
                VStack(alignment: .leading, spacing: Theme.space.s1) {
                    if !model.isDiscreet {
                        Text(DashboardCopy.milestoneLabel) // "next milestone" — AUDITED
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Theme.color.contentSecondary.color)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    ThemedProgressBar(fraction: progress)
                        .accessibilityHidden(true) // the card container owns semantics
                }
            }

            // Frozen tooltip — §3-blocked; the empty guard prevents an empty Text. Until
            // the founder pass, a frozen streak shows its (correct) numbers + neutral ring.
            if model.isFrozen, !DashboardCopy.frozenTooltip.isEmpty {
                Label {
                    Text(DashboardCopy.frozenTooltip)
                        .font(.footnote)
                        .foregroundStyle(Theme.color.contentSecondary.color)
                        .fixedSize(horizontal: false, vertical: true)
                } icon: {
                    Image(systemName: "clock.badge.exclamationmark") // decorative — R33.12 safe
                        .foregroundStyle(Theme.color.paused.color)
                }
                .font(.footnote)
            }

            // Reduce-mode adherence framing — §3-blocked; empty guard prevents empty Text.
            if model.isReduceMode, !DashboardCopy.reduceModeFraming.isEmpty {
                Text(DashboardCopy.reduceModeFraming)
                    .font(.footnote)
                    .foregroundStyle(Theme.color.contentSecondary.color)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    /// Realized savings formatted with the stored currency, zero fraction digits —
    /// mirrors `StreakWidgetDisplay.moneyText`. `nil` (section hidden) when spend is
    /// absent/zero, never "$0".
    private func formattedMoney() -> String? {
        guard model.moneySaved > 0 else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = model.currencyCode
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        return formatter.string(from: model.moneySaved as NSDecimalNumber)
    }
}
