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
/// ME-4 (Session 54) — the payoff redesign (UX blueprint §6.5, creative §4's
/// Summary row). Composition, not point sizes: a full-bleed `WaterlineField` at
/// `progress: 1` behind a 24pt-radius card; the numeral in Moss with "/year"
/// promoted to `.title2`; the `WaterlineRule` horizon directly beneath it; 32pt
/// clearspace bracketing the stage; motivations at `.title2` Semibold; and the
/// `motion/calm` reveal moved OFF the root ONTO the figure, which is both what
/// §6.5 asks and what shrinks the screen's blank-golden trap to one element.
/// TWO deliberate departures from the spec, each argued where it is made:
/// `windowBlock` refuses §6.5's 24-hour band (four of the six risk tokens carry no
/// clock meaning, so shading an hour for them fabricates a finding), and
/// `WaterlineRule` refuses creative §2's white Foam on a card that is `#FFFFFF` in
/// light mode.
///
/// House rules honored: no red anywhere (teal, indigo, and Moss on the one money
/// figure), the hero numeral is the single hero (motivation words get dignified
/// weight but never rival it), motion is one `motion/calm` fade-up on the figure
/// (Reduce Motion → opacity only, no translation; NO count-up — a slot-machine
/// money tick reads as hype), 44pt+ targets, `summary.*` a11y ids
/// for the E2E lane. quiz_completed fires from `model.onSummaryAppear()` in
/// `.onAppear` — once per completion, guarded in the model (NOT in this view's body).
struct QuizSummaryView: View {
    let model: QuizFlowModel
    let data: SummaryViewData
    /// AC8 — the NAMED forward seam. E7 (the paywall owner) remaps this seam to
    /// PaywallView; this session it dismisses to the placeholder dashboard.
    let onContinue: () -> Void
    /// S46 (operator §3) — the alcohol withdrawal notice, when this completer
    /// is due one. Non-nil renders the Brand-signed inline caution card ABOVE
    /// the CTA, so the notice lands BEFORE the paywall: a hard-wall
    /// non-converter never reaches the dashboard, which used to be the notice's
    /// only mount. Defaulted so no existing call site changes, and nil for
    /// every non-alcohol completer (`AlcoholNoticePolicy` decides upstream).
    var alcoholNotice: AlcoholNoticeSlot? = nil
    /// The `StreakDetailView.animateHeader` seam, inverted for the default: live
    /// mounts keep the one `motion/calm` reveal (`true`, every existing call
    /// site), while a snapshot capture passes `false` so the card renders
    /// revealed on frame zero — the goldens must never depend on whether
    /// `.onAppear` runs inside the offscreen renderer.
    var animateReveal: Bool = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// brandkit §8's stacked-at-accessibility-sizes rule, read from the environment
    /// rather than measured (R33.12 — see `heroFigure`).
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var revealed = false

    var body: some View {
        // ME-4: the full-bleed Waterline backdrop, and summary is the primitive's
        // SECOND consumer — which is what turns "reusable" from a claim into a fact.
        //
        // `progress: 1` is not a placeholder: creative §4 defines the field's state
        // machine as day→night across the funnel and puts the summary at its end —
        // "the crest, absent at the start, is fully surfaced at the summary". So the
        // one scalar the primitive takes is already the right number here.
        //
        // `field:` is passed INSIDE the parentheses, never as a trailing closure.
        // `field` and `content` are both View-producing slots, so an unlabelled
        // trailing closure binds by POSITION — the mistake compiles and silently
        // renders the card as the backdrop.
        //
        // The field weight stays the primitive's `standardOpacity`. Do NOT raise it:
        // measured on the shipping tokens, this screen's own alcohol-notice mount is
        // the binding constraint, and the field's 0.08 ceiling would put light
        // `brand/primary` on that notice's tint at 4.442 against a 4.5 floor. The
        // opaque backing added to `AlcoholNoticeCard` is what makes even that safe.
        OnboardingScaffold(field: AnyView(WaterlineField(progress: 1))) {
            VStack(spacing: Theme.space.s6) {
                summaryCard
                if let alcoholNotice {
                    AlcoholNoticeCard(slot: alcoholNotice)
                }
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
        .onAppear {
            model.onSummaryAppear()
            guard animateReveal else { return }
            withAnimation(.easeInOut(
                duration: reduceMotion ? Theme.motion.quick : Theme.motion.calm
            )) {
                revealed = true
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("summary.card")
    }

    // MARK: - The reveal (UX blueprint §6.5: "the savings figure settles with a
    // calm 600ms fade-up on first appearance only; Reduce Motion → opacity-only")

    /// ME-4 moves the reveal OFF the root and onto the savings figure alone, which
    /// is what §6.5 actually specifies — and, usefully, makes the screen's oldest
    /// trap smaller rather than larger. The root used to carry
    /// `.opacity(animateReveal && !revealed ? 0 : 1)`, so a snapshot that missed the
    /// seam recorded a BLANK PNG of the entire card. Now everything except the
    /// numeral renders unconditionally: the same seam still governs, but the blast
    /// radius of getting it wrong is one element instead of the screen.
    ///
    /// `animateReveal: false` (what `QuizSummarySnapshotTests` passes) forces BOTH
    /// components settled, so the golden never depends on whether `.onAppear` runs
    /// inside the offscreen renderer.
    private var heroRevealOpacity: Double {
        animateReveal && !revealed ? 0 : 1
    }

    /// The "up" half of the fade-up. Reduce Motion drops the translation and keeps
    /// the opacity change — §6.5's "opacity-only", read literally. `.offset` is
    /// deliberate over padding: it moves the drawn figure without touching layout,
    /// so nothing below it shifts while the number settles.
    private var heroRevealOffset: CGFloat {
        animateReveal && !revealed && !reduceMotion ? Theme.space.s3 : 0
    }

    /// brandkit §6.7's QuitSummaryCard: the hero figure, the risk-window line, and
    /// the user's own motivations — one raised card, one rhythm, each block dropping
    /// out cleanly when its data is absent.
    private var summaryCard: some View {
        VStack(spacing: Theme.space.s6) {
            savingsBlock

            windowBlock

            motivationBlock

            // Copy doc §6.5 — the quiet signature under the horizon rule: the
            // tagline's ONE in-app appearance. A hairline, then a footnote in
            // tertiary ink; the card ends on it, nothing competes with it.
            //
            // This 48pt rule stays a PLAIN `border/hairline` and must not be
            // "upgraded" to `WaterlineRule`. Creative §2 rations the luminous
            // waterline to exactly three places app-wide — under the summary hero
            // (spent above), under the dashboard's Day N hero, and above the panic
            // exit actions — and says why in as many words: "ration it or it
            // becomes wallpaper". Two waterlines on one card is the failure mode
            // the ration exists to prevent.
            VStack(spacing: Theme.space.s3) {
                Rectangle()
                    .fill(Theme.color.borderHairline.color)
                    .frame(width: 48, height: 1)
                    .accessibilityHidden(true)
                Text(data.footer)
                    .font(.footnote.weight(.medium))
                    // Secondary, not tertiary, ink: the tertiary pair on the
                    // raised card is a "nearly passed" in Apple's contrast
                    // audit at footnote size (CI run 30184...), and the a11y
                    // contract outranks the quieter grey. Footnote weight
                    // keeps the signature quiet.
                    .foregroundStyle(Theme.color.contentSecondary.color)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .accessibilityIdentifier("summary.footer")
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.space.s8)
        .padding(.horizontal, Theme.space.s5)
        // §6.5 asks the payoff card — and only it — for 24pt. The parameter is
        // defaulted at `radius/m`, so the app's other twelve cards do not move.
        .themedCard(cornerRadius: Theme.radius.l)
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

            heroStage
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(savingsA11yLabel)
        // The id rides the COLLAPSED element (green critic SHOULD-A) so the hero
        // is XCUITest-addressable — and says which variant rendered.
        .accessibilityIdentifier(heroParts != nil ? "summary.savings" : "summary.savingsAbsent")
    }

    /// §6.5's "full-width stage": the figure, the horizon rule directly beneath it,
    /// and the caption — bracketed by the spec's generous 32pt clearspace.
    ///
    /// The clearspace is PADDING, never a height floor. That distinction is the S28
    /// finding restated: a `minHeight` that sits below a string's accessibility-size
    /// height is what Apple's audit reads as clipped text, whereas padding simply
    /// grows with its content. The card's own `.padding(.vertical, s8)` has always
    /// worked this way; this is the same mechanism one level in.
    @ViewBuilder private var heroStage: some View {
        VStack(spacing: Theme.space.s3) {
            if let parts = heroParts {
                heroFigure(parts)
                    .opacity(heroRevealOpacity)
                    .offset(y: heroRevealOffset)
            } else {
                Text(data.savingsAbsent)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(Theme.color.contentPrimary.color)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // The card's horizon — creative §2's reusable signature, rationed to
            // three places app-wide and spent here on the first.
            WaterlineRule()

            if heroParts != nil {
                Text(data.savingsCaption)
                    .font(.subheadline)
                    .foregroundStyle(Theme.color.contentSecondary.color)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.space.s8)
    }

    /// §6.5's risk-window element — and the ONE place this session deliberately
    /// departs from the blueprint's own words. Read the reason before restoring it.
    ///
    /// §6.5 asks for "a 24-hour horizontal band with the user's likely hard window
    /// (e.g. evenings) rendered as a deeper indigo segment". That shape cannot be
    /// built honestly over this derivation, for two independent reasons:
    ///
    /// 1. **Four of the six tokens carry no clock meaning.**
    ///    `SummaryDerivation.precedence` is evenings / afterWork / social / alone /
    ///    boredom / stress, and the shipping phrases for the last four are "around
    ///    social plans", "in quiet moments alone", "when things get idle", "when
    ///    stress spikes". Shading a segment of a 24-hour axis for those asserts a
    ///    time-of-day finding the derivation never made — a fabricated statistic,
    ///    which `mvp.md` §7 forbids outright and which `SummaryDerivation`'s own
    ///    contract already refuses ("insufficient data shows nothing, not guesses").
    ///    Even for "evenings", no range exists to source: an 18:00–23:00 bracket
    ///    would be invented precision on a screen whose copy is carefully hedged to
    ///    "likely".
    /// 2. **There is no copy for it.** The copy deck's summary table lists the six
    ///    window lines as "Keep. Same six" and introduces no new strings; a clock
    ///    axis needs labels that do not exist, and copy is founder-owned.
    ///
    /// So the window becomes a DESIGNED element without becoming a scale: its own
    /// sunken well with an indigo marker — unmistakably emphasis, not a meter, so it
    /// implies no quantity and no hour. The 24-hour arc is recorded as an open item
    /// for the operator, since it needs both a founder copy round and a decision
    /// about the four non-temporal tokens.
    ///
    /// Contrast is precedent, not invention: `brand/secondary` on `surface/sunken` is
    /// the registered progress-bar pair (4.64 L / 7.82 D against a 3.0 UI floor), and
    /// the body text is the registered `content/primary` on `surface/sunken`. The
    /// track-vs-card boundary is deliberately NOT registered — `ThemedProgressBar`
    /// sets that precedent (it pins fill-vs-track only), and `border/hairline` is
    /// declared 1.4.11-exempt for the same reason.
    @ViewBuilder private var windowBlock: some View {
        if let windowLine = data.windowLine {
            Text(windowLine)
                .font(.body)
                .foregroundStyle(Theme.color.contentPrimary.color)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                // Padding INSIDE the stretch, never outside it: padding applied to
                // an already-`.infinity`-wide view adds to a width that is already
                // the whole container, so the well would overhang the card. Pad the
                // text, then stretch the padded result, then paint behind it.
                .padding(.vertical, Theme.space.s4)
                .padding(.leading, Theme.space.s5)
                .padding(.trailing, Theme.space.s4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    Theme.color.surfaceSunken.color,
                    in: RoundedRectangle(cornerRadius: Theme.radius.s)
                )
                .overlay(alignment: .leading) {
                    // Sized by the overlay, so it always spans the well's height —
                    // no guess about how a Shape resolves inside an HStack.
                    Capsule()
                        .fill(Theme.color.brandSecondary.color)
                        .frame(width: 3)
                        .padding(.vertical, Theme.space.s3)
                        .padding(.leading, Theme.space.s3)
                        .accessibilityHidden(true)
                }
                .accessibilityIdentifier("summary.window")
        }
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
            // ME-4: Moss. §6.5 recovers the drama "through composition, color, and
            // the motif, never point sizes" — the numeral is the one place the
            // money colour is spent (creative §4 reserves it for exactly this: "Moss
            // is reserved for the summary payoff, not here" on the spend step).
            // `semantic/positive` on `surface/raised` is already a registered pair
            // and passes with room: 5.46 light, 8.62 dark, against a 4.5 floor.
            .foregroundStyle(Theme.color.positive.color)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func heroSuffix(_ suffix: String) -> some View {
        Text(suffix)
            // §6.5: "'/year' set as a separate .title2 element" — it was .title3.
            // Kept on secondary ink so the suffix reads as a unit of the figure
            // rather than a second figure.
            .font(.title2.weight(.medium))
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
                        // §6.5: motivations echoed at .title2 Semibold — "the
                        // user's words visually out-ranking ours". Still below the
                        // .largeTitle hero, so the single-hero rule holds.
                        .font(.title2.weight(.semibold))
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
