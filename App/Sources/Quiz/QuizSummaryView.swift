import SwiftUI

/// E5.3 — the personalized summary (brandkit §6.7 QuitSummaryCard: "the most
/// designed single screen in the app"; its visual quality carries the
/// conversion). A THIN renderer over `SummaryViewData`: absence arrived as nil
/// (Architect S2), so a missing block is simply omitted and the rhythm closes up
/// — the card reads as intentional in every degraded permutation, never broken.
///
/// House rules honored: no red anywhere (teal/indigo only), the hero numeral is
/// the single hero (motivation words get dignified weight but never rival it),
/// motion is one `motion/calm` fade (600ms easeInOut; Reduce Motion → quick
/// crossfade; NO count-up — a slot-machine money tick reads as hype),
/// `.background(_:in:)` form only, 44pt+ targets, `summary.*` a11y ids for the
/// E2E lane. quiz_completed fires from `model.onSummaryAppear()` in `.onAppear`
/// — once per completion, guarded in the model (NOT in this view's body).
struct QuizSummaryView: View {
    let model: QuizFlowModel
    let data: SummaryViewData
    /// AC8 — the NAMED forward seam. E7 (the paywall owner) remaps this seam to
    /// PaywallView; this session it dismisses to the placeholder dashboard.
    let onContinue: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var revealed = false

    var body: some View {
        VStack(spacing: 24) {
            ScrollView {
                VStack(spacing: 28) {
                    savingsBlock
                    if let windowLine = data.windowLine {
                        Text(windowLine)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .accessibilityIdentifier("summary.window")
                    }
                    motivationBlock
                }
                .padding(.top, 32)
                .frame(maxWidth: .infinity)
            }
            .scrollBounceBehavior(.basedOnSize)

            Spacer(minLength: 0)

            Button(action: onContinue) {
                Text(data.cta)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.teal, in: Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("summary.cta")
        }
        .padding(20)
        .opacity(revealed ? 1 : 0)
        .onAppear {
            model.onSummaryAppear()
            withAnimation(.easeInOut(duration: reduceMotion ? 0.2 : 0.6)) {
                revealed = true
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("summary.card")
    }

    /// The hero zone: eyebrow + the savings figure (or the non-monetary reframe
    /// at a calmer weight — no empty crater where 64pt used to be).
    private var savingsBlock: some View {
        VStack(spacing: 8) {
            Text(data.eyebrow)
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)

            if let parts = heroParts {
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(parts.amount)
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    if !parts.suffix.isEmpty {
                        Text(parts.suffix)
                            .font(.title3.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                }
                Text(data.savingsCaption)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Text(data.savingsAbsent)
                    .font(.title3.weight(.medium))
                    .multilineTextAlignment(.center)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(savingsA11yLabel)
        // The id rides the COLLAPSED element (green critic SHOULD-A) so the hero
        // is XCUITest-addressable — and says which variant rendered.
        .accessibilityIdentifier(heroParts != nil ? "summary.savings" : "summary.savingsAbsent")
    }

    /// The user's own words, verbatim, in their order — dignified weight, but
    /// never rivaling the hero (the 40pt panicReason treatment is ReasonsView's).
    @ViewBuilder private var motivationBlock: some View {
        if !data.motivations.isEmpty {
            VStack(spacing: 8) {
                Text(data.motivationIntro)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                ForEach(data.motivations, id: \.self) { word in
                    Text(word)
                        .font(.title3.weight(.semibold))
                }
            }
            .accessibilityIdentifier("summary.motivations")
        }
    }

    /// Splits the formatter's display string ("~$1,350/year") so the numeral is
    /// the hero and "/year" sits subordinate on the same baseline — both parts
    /// come FROM the tested display string; the view invents no copy.
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
