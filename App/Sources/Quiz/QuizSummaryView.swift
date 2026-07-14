import SwiftUI

/// E5.3 — the personalized summary (brandkit §6.7 QuitSummaryCard: "the most
/// designed single screen in the app"; its visual quality carries the
/// conversion). A THIN renderer over `SummaryViewData`: absence arrived as nil
/// (Architect S2), so a missing block is simply omitted and the rhythm closes up
/// — the card reads as intentional in every degraded permutation, never broken.
///
/// UIR-1 (Session 33) — regenerated on the UIR-0 system, copy byte-identical:
/// - the payoff is now an actual CARD (`themedCard()` — `surface/raised` + hairline
///   over the base surface), which is what brandkit §6.7 always specified;
/// - **the hero numeral finally scales.** It was `.font(.system(size: 56))` — a
///   FIXED point size, which does not respond to Dynamic Type AT ALL — rescued at
///   large sizes by `.lineLimit(1)` + `.minimumScaleFactor(0.5)`, i.e. by SHRINKING
///   the one number the screen exists to show. brandkit §8 forbids exactly that
///   ("caps its scaling at accessibility-XL and switches to a stacked layout rather
///   than shrinking"). Now it is the `.largeTitle` TEXT STYLE (which carries the type
///   metrics the audit demands), and the LAYOUT — not the glyph — gives way at
///   accessibility sizes: the figure and its suffix stack. See `heroFigure` for why
///   the `ViewThatFits` ladder this session first shipped had to be RETIRED (R33.12);
///   it is the one thing here that a billed run, not reasoning, settled;
/// - the CTA rides `PrimaryButtonStyle` (was a hand-rolled Capsule + `.plain`).
///
/// House rules honored: no red anywhere (teal/indigo only), the hero numeral is
/// the single hero (motivation words get dignified weight but never rival it),
/// motion is one `motion/calm` fade (Reduce Motion → quick crossfade; NO count-up
/// — a slot-machine money tick reads as hype), 44pt+ targets, `summary.*` a11y ids
/// for the E2E lane. quiz_completed fires from `model.onSummaryAppear()` in
/// `.onAppear` — once per completion, guarded in the model (NOT in this view's body).
struct QuizSummaryView: View {
    let model: QuizFlowModel
    let data: SummaryViewData
    /// AC8 — the NAMED forward seam. E7 (the paywall owner) remaps this seam to
    /// PaywallView; this session it dismisses to the placeholder dashboard.
    let onContinue: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// brandkit §8's stacked-at-accessibility-sizes rule, read from the environment
    /// rather than measured (R33.12 — see `heroFigure`).
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var revealed = false

    var body: some View {
        OnboardingScaffold {
            VStack(spacing: Theme.space.s6) {
                summaryCard
            }
        } actions: {
            Button(action: onContinue) {
                Text(data.cta)
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.space.s4)
            }
            .buttonStyle(PrimaryButtonStyle())
            .accessibilityIdentifier("summary.cta")
        }
        .opacity(revealed ? 1 : 0)
        .onAppear {
            model.onSummaryAppear()
            withAnimation(.easeInOut(
                duration: reduceMotion ? Theme.motion.quick : Theme.motion.calm
            )) {
                revealed = true
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("summary.card")
    }

    /// brandkit §6.7's QuitSummaryCard: the hero figure, the risk-window line, and
    /// the user's own motivations — one raised card, one rhythm, each block dropping
    /// out cleanly when its data is absent.
    private var summaryCard: some View {
        VStack(spacing: Theme.space.s6) {
            savingsBlock

            if let windowLine = data.windowLine {
                Text(windowLine)
                    .font(.body)
                    .foregroundStyle(Theme.color.contentPrimary.color)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("summary.window")
            }

            motivationBlock
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.space.s8)
        .padding(.horizontal, Theme.space.s5)
        .themedCard()
    }

    /// The hero zone: eyebrow + the savings figure (or the non-monetary reframe
    /// at a calmer weight — no empty crater where the numeral used to be).
    private var savingsBlock: some View {
        VStack(spacing: Theme.space.s2) {
            Text(data.eyebrow)
                .font(.footnote.weight(.medium))
                .foregroundStyle(Theme.color.contentSecondary.color)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            if let parts = heroParts {
                heroFigure(parts)

                Text(data.savingsCaption)
                    .font(.subheadline)
                    .foregroundStyle(Theme.color.contentSecondary.color)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text(data.savingsAbsent)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(Theme.color.contentPrimary.color)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(savingsA11yLabel)
        // The id rides the COLLAPSED element (green critic SHOULD-A) so the hero
        // is XCUITest-addressable — and says which variant rendered.
        .accessibilityIdentifier(heroParts != nil ? "summary.savings" : "summary.savingsAbsent")
    }

    /// The figure itself. brandkit §8's rule — "switches to a stacked layout rather
    /// than shrinking" — is read off the ENVIRONMENT (`dynamicTypeSize`), not measured
    /// by a `ViewThatFits` ladder. R33.12, artifact-forced: `ViewThatFits` sizes its
    /// candidates at a FIXED ideal and Apple's `.dynamicType` audit then reports every
    /// Text inside it as *"User will not be able to change the font size"* — it fired
    /// on BOTH hero Texts in run 29303961082, including the suffix, which carries a
    /// plain `.title3` TEXT STYLE. The container, not the font, was the defect.
    @ViewBuilder private func heroFigure(_ parts: (amount: String, suffix: String)) -> some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(spacing: 0) {
                heroAmount(parts.amount)
                if !parts.suffix.isEmpty { heroSuffix(parts.suffix) }
            }
        } else {
            HStack(alignment: .lastTextBaseline, spacing: Theme.space.s1 / 2) {
                heroAmount(parts.amount)
                if !parts.suffix.isEmpty { heroSuffix(parts.suffix) }
            }
        }
    }

    private func heroAmount(_ amount: String) -> some View {
        Text(amount)
            // SF Pro Rounded, monospaced digits (brandkit §3 `type/streakHero`):
            // rounded for warmth without whimsy, monospaced so a live figure never
            // jitters. The size is the `.largeTitle` TEXT STYLE — the only form the
            // audit accepts (a `.system(size:)` point size carries no type metrics,
            // even when a `@ScaledMetric` drives the number), and the only one that
            // still FITS the card at accessibility sizes: the 56→96pt figure this
            // replaces overflowed the card's width and was reported clipped.
            .font(.system(.largeTitle, design: .rounded, weight: .bold))
            .monospacedDigit()
            .foregroundStyle(Theme.color.contentPrimary.color)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func heroSuffix(_ suffix: String) -> some View {
        Text(suffix)
            .font(.title3.weight(.medium))
            .foregroundStyle(Theme.color.contentSecondary.color)
            .fixedSize(horizontal: false, vertical: true)
    }

    /// The user's own words, verbatim, in their order — dignified weight, but
    /// never rivaling the hero (the 40pt panicReason treatment is ReasonsView's).
    @ViewBuilder private var motivationBlock: some View {
        if !data.motivations.isEmpty {
            VStack(spacing: Theme.space.s3) {
                // A hairline rule, drawn from the token (never the system Divider,
                // whose colour lives outside the Theme layer).
                Rectangle()
                    .fill(Theme.color.borderHairline.color)
                    .frame(height: 1)
                    .padding(.bottom, Theme.space.s1)
                    .accessibilityHidden(true)

                Text(data.motivationIntro)
                    .font(.subheadline)
                    .foregroundStyle(Theme.color.contentSecondary.color)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                ForEach(data.motivations, id: \.self) { word in
                    Text(word)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Theme.color.contentPrimary.color)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .accessibilityIdentifier("summary.motivations")
        }
    }

    /// Splits the formatter's display string ("~$1,350/year") so the numeral is
    /// the hero and "/year" sits subordinate — both parts come FROM the tested
    /// display string; the view invents no copy.
    private var heroParts: (amount: String, suffix: String)? {
        guard let line = data.savingsLine else { return nil }
        guard line.hasSuffix("/year") else { return (line, "") }
        return (String(line.dropLast("/year".count)), "/year")
    }

    /// One combined label ("about $1,350 saved in a year, if you stay on track.")
    /// — VoiceOver never reads the "~" glyph as "tilde".
    private var savingsA11yLabel: String {
        guard let parts = heroParts else { return data.savingsAbsent }
        let amount = parts.amount.hasPrefix("~") ? String(parts.amount.dropFirst()) : parts.amount
        return "about \(amount) \(data.savingsCaption)"
    }
}
