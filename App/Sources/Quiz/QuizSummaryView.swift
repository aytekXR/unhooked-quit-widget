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
///   than shrinking"). Now: `@ScaledMetric` grows it with the user's type size,
///   `Theme.type.heroCap` caps it, and `ViewThatFits` changes the LAYOUT (inline →
///   stacked → one type step down) when the figure runs out of width. Nothing is
///   squeezed; the glyph keeps its designed weight;
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
    /// `type/streakHero`, Dynamic-Type-bound (brandkit §3) — the fixed 56pt is gone.
    @ScaledMetric(relativeTo: .largeTitle) private var heroSize: CGFloat = Theme.type.heroBase
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

    /// The figure itself. `ViewThatFits` picks the first layout that actually fits
    /// the width it is given: the designed inline baseline pair, else the stacked
    /// form (brandkit §8's answer to accessibility sizes), else the stacked form one
    /// type step down. The NUMERAL is never squeezed to fit — the LAYOUT gives way.
    private func heroFigure(_ parts: (amount: String, suffix: String)) -> some View {
        let point = min(heroSize, Theme.type.heroCap)
        return ViewThatFits(in: .horizontal) {
            heroInline(parts, point: point)
            heroStacked(parts, point: point)
            heroStacked(parts, point: point * Self.heroStepDown)
        }
    }

    private func heroInline(
        _ parts: (amount: String, suffix: String), point: CGFloat
    ) -> some View {
        HStack(alignment: .lastTextBaseline, spacing: Theme.space.s1 / 2) {
            heroAmount(parts.amount, point: point)
            if !parts.suffix.isEmpty {
                heroSuffix(parts.suffix)
            }
        }
    }

    private func heroStacked(
        _ parts: (amount: String, suffix: String), point: CGFloat
    ) -> some View {
        VStack(spacing: 0) {
            heroAmount(parts.amount, point: point)
            if !parts.suffix.isEmpty {
                heroSuffix(parts.suffix)
            }
        }
    }

    private func heroAmount(_ amount: String, point: CGFloat) -> some View {
        Text(amount)
            // SF Pro Rounded, monospaced digits (brandkit §3 `type/streakHero`):
            // rounded for warmth without whimsy, monospaced so a live figure never
            // jitters. The SIZE is Dynamic-Type-derived, never a literal.
            .font(.system(size: point, weight: .bold, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(Theme.color.contentPrimary.color)
    }

    private func heroSuffix(_ suffix: String) -> some View {
        Text(suffix)
            .font(.title3.weight(.medium))
            .foregroundStyle(Theme.color.contentSecondary.color)
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

    /// The single type step the hero may drop when even the stacked form overflows
    /// (a very large figure on a very narrow screen). A LAYOUT decision, not a
    /// glyph squeeze — `minimumScaleFactor` is what brandkit §8 rules out.
    private static let heroStepDown: CGFloat = 0.72
}
