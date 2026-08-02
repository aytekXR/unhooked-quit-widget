import SwiftUI

/// E5.2 — the data-driven quiz (brandkit §6.4 QuizStepScreen): ONE question per
/// screen from the audited config, a thin progress bar (visible position — R9,
/// never the analytics slot), Back always available past the first step, and a
/// bottom-pinned Continue (one-hand rule). Every string renders verbatim from
/// `quizConfig.json` (DRAFT, founder-owned, lexicon-scanned).
///
/// UIR-1 (Session 33) — regenerated on the UIR-0 system, copy byte-identical:
/// - `OnboardingScaffold` owns the skeleton (progress pinned on top, question
///   scrolls, Continue pinned at the bottom on the brandkit §5 measure);
/// - the hand-rolled progress track becomes `ThemedProgressBar`, the hand-rolled
///   chips become `AnswerChipStyle` — which closes the KNOWN 14pt-vs-pill drift
///   (brandkit §6.5 says `radius/full`; the v1 chips rounded to 14) — and Back
///   becomes `QuietButtonStyle` (brandkit §6.2: the escape hatch is never a
///   `.plain` orphan);
/// - the free-text/spend/allowance controls leave the system's `.roundedBorder`
///   for the app's own sunken-well treatment, so the quiz has ONE input language;
/// - every text role is Dynamic-Type-bound and `.fixedSize`-guaranteed its natural
///   height; the Continue label keeps PADDING (never a height floor — a floor that
///   exceeds the label's accessibility-size height is what Apple's audit reads as
///   a clipped-text cap: the S28 redirect-row finding class).
struct QuizFlowView: View {
    @Bindable var model: QuizFlowModel

    /// ME-8: the field's advance is the only motion this screen owns, so Reduce
    /// Motion is honoured HERE rather than inside `WaterlineField` — the primitive
    /// is a pure function of `progress` and animates nothing by itself.
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// How far through the visible steps the user is, 0...1. The SAME source the
    /// progress bar reads, deliberately: the horizon and the bar must never
    /// disagree about how far along the user is (creative §4 calls the field "the
    /// emotional twin of the progress bar").
    private var progressFraction: Double {
        let position = model.progressPosition
        guard position.total > 0 else { return 0 }
        return Double(position.index) / Double(position.total)
    }

    /// Creative §4, steps 2 / 5: "field dims to 6% under keyboard" — on the two
    /// steps that raise a keyboard the typed value is the subject and the field
    /// yields to it. `allowance` is excluded on purpose: it is a Stepper on a
    /// sunken well, not a keyboard step, however its `kind` is spelled.
    private var isKeyboardStep: Bool {
        guard let step = model.currentStep else { return false }
        switch step.kind {
        case .freeText: return true
        case .decimalInput: return step.id != "allowance"
        default: return false
        }
    }

    var body: some View {
        // The step id is the SCROLL VIEW's identity, not the question's: on a step
        // change the scaffold rebuilds its scroll view, so the next question opens at
        // the top (v1 got this from `.id(step.id)` ON the ScrollView; a stable scroll
        // view would silently inherit the previous question's offset and could open a
        // step below the fold on a small screen or at accessibility sizes) and the
        // step's transient controls re-hydrate with it (Back re-creates the content
        // from the preserved answer — AC5). The progress bar and Continue keep stable
        // identity outside it, so the bar still animates its fill instead of jumping.
        // ME-8: the continuous Waterline field. `field:` is passed INSIDE the
        // parentheses, never as a trailing closure — with several trailing
        // closures in play, an unlabelled one binds by position, and `field` and
        // `header` are both Views, so the mistake would compile and silently swap
        // the progress bar with the backdrop.
        OnboardingScaffold(
            contentID: model.currentStep?.id,
            field: AnyView(
                WaterlineField(
                    progress: progressFraction,
                    maxOpacity: isKeyboardStep
                        ? WaterlineField.keyboardOpacity
                        : WaterlineField.standardOpacity
                )
                // The horizon advances with the step, at the same motion/standard
                // the step transition uses, and Reduce Motion opts out.
                //
                // Stated honestly: this tween is BEST-EFFORT. `AnyView` erases
                // structural identity, so SwiftUI may treat each step's field as a
                // new view and cut rather than interpolate. M13 narrows that gap:
                // the scaffold now pins explicit identity on the field slot
                // (`.id("scaffold.field")`), keying the view by id rather than
                // structure so the tween can interpolate. Still not load-bearing —
                // the SETTLED frame is the whole design, it is identical either
                // way, and a 300ms tween on a 6%-opacity backdrop is polish, not
                // meaning; whether it reads as a drift or a cut stays on the
                // operator's device-eyeball list.
                .animation(
                    reduceMotion ? nil : .easeInOut(duration: Theme.motion.standard),
                    value: progressFraction
                )
            )
        ) {
            progressBar
        } content: {
            if let step = model.currentStep {
                QuizStepContent(step: step, model: model)
            }
        } actions: {
            controls
        }
        .onAppear { model.onFirstScreenAppear() }
        // S29 (R29.3): the container's `.contain` grouping stays (real
        // VoiceOver structure); its old "quiz.flow" identifier is DELETED —
        // a nested-container id never surfaces to XCUITest (Session 09), it
        // trapped the S25 smoke (run 29205964725, artifact-proven), and
        // nothing queries it. Anchor on quiz.continue / quiz.progress.
        .accessibilityElement(children: .contain)
    }

    /// Thin visible-progress track (brand/secondary fill on the sunken track —
    /// momentum is indigo so streak and progress are never confused, brandkit §2.1).
    private var progressBar: some View {
        let position = model.progressPosition
        let fraction = position.total > 0
            ? Double(position.index) / Double(position.total) : 0
        return ThemedProgressBar(fraction: fraction)
            .animation(.easeOut(duration: Theme.motion.quick), value: position.index)
            // R28.13 (the run-29262073722 audit's hit-region finding): a 4pt-tall
            // accessibility element is an un-targetable sliver for assistive tech.
            // The VISUAL stays the 4pt capsule; the a11y element's frame grows to the
            // 44pt floor, and the element is explicitly non-interactive (it is an
            // announcement, not a control).
            .frame(minHeight: Theme.touch.minTarget)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(String(
                format: model.engine.config.controls.progressA11yFormat,
                position.index, position.total
            ))
            .accessibilityRespondsToUserInteraction(false)
            .accessibilityIdentifier("quiz.progress")
    }

    /// M3: the step-change crossfade — an entrance starts fast (ease-out,
    /// motion/standard); Reduce Motion keeps a 200ms opacity crossfade (the
    /// house RM idiom — opacity-only either way, so nothing translates).
    private var stepTransition: Animation {
        reduceMotion
            ? .easeInOut(duration: Theme.motion.quick)
            : .easeOut(duration: Theme.motion.standard)
    }

    private var controls: some View {
        VStack(spacing: Theme.space.s3) {
            // SHOULD-4: the calm completion-retry surface — shown only when the
            // durable save failed; the checkpoint survived, Continue retries. Amber
            // + icon + text, never color alone (brandkit §2.2); string from the
            // audited table.
            if model.completionFailed {
                HStack(spacing: Theme.space.s2) {
                    Image(systemName: "arrow.clockwise.circle")
                        .accessibilityHidden(true)
                    Text(model.engine.config.controls.retryNote)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .font(.subheadline)
                .foregroundStyle(Theme.color.caution.color)
                .accessibilityIdentifier("quiz.retryNote")
            }

            Button {
                // M3: the question CROSSFADES between steps instead of hard-cutting
                // (the flow's one unanimated element — the bar and the field already
                // animate). The scaffold's content carries the matching
                // `.transition(.opacity)`; opacity-only, no slide ("breath, not
                // bounce" + the keyboard steps both argue against translation).
                withAnimation(stepTransition) {
                    model.advance()
                }
            } label: {
                Text(model.engine.config.controls.continueLabel)
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.space.s4)
            }
            // The GHOST disabled treatment DELIVERED THROUGH the primitive
            // (R32.9, the run-29295414489 finding): `.buttonStyle(.plain)`
            // composites a disabled Button's whole label at ~50% opacity ON TOP
            // of any explicit foregroundStyle — the authored content2-on-sunken
            // (5.6:1) RENDERED at 2.14:1 and fired the restored `.contrast`
            // audit on this very frame (artifact-measured, element screenshot).
            // A custom ButtonStyle gets no automatic dimming: PrimaryButtonStyle
            // renders enabled = onPrimary-on-primary and disabled = the ghost
            // tokens EXACTLY as authored (both registry-pinned).
            .buttonStyle(PrimaryButtonStyle())
            .disabled(continueDisabled)
            .accessibilityIdentifier("quiz.continue")

            // Back is the quiet path (brandkit §6.2) — always visible past step 1,
            // never hidden or shrunk; fires nothing, preserves answers.
            if model.progressPosition.index > 1 {
                Button {
                    withAnimation(stepTransition) {
                        model.back()
                    }
                } label: {
                    Text(model.engine.config.controls.backLabel)
                }
                .buttonStyle(QuietButtonStyle())
                .accessibilityIdentifier("quiz.back")
            }
        }
    }

    /// Single-choice steps require an explicit pick (the quiz never nudges — the
    /// age-gate precedent); the consent step likewise requires a deliberate
    /// choice, gated off the model's TRANSIENT signal — never the stored value,
    /// whose `false` is ambiguous between "declined" and "never answered" (E8.2).
    /// Everything else may continue unanswered (multi-select and inputs are
    /// optional by design; empty motivations degrade to the panic script's
    /// generic encouragements). A failed completion re-enables Continue as the
    /// retry affordance (SHOULD-4 — never a dead end).
    private var continueDisabled: Bool {
        if model.completionFailed { return false }
        guard let step = model.currentStep else { return true }
        if step.kind == .singleChoice {
            return model.answer(for: step.id)?.choiceIDs.isEmpty != false
        }
        if step.kind == .consent {
            return model.consentChoice == nil
        }
        return false
    }
}

/// One question's content: title, optional helper, and the kind-specific control.
/// Records into the model IMMEDIATELY on interaction (so Back/relaunch lose
/// nothing); transient control state hydrates from the preserved answer.
private struct QuizStepContent: View {
    let step: QuizConfig.Step
    @Bindable var model: QuizFlowModel

    @State private var freeText: String = ""
    @State private var sliderValue: Double = 0.5
    @State private var allowanceValue: Int = 0

    var body: some View {
        VStack(spacing: Theme.space.s5) {
            if let title = step.title {
                Text(title)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Theme.color.contentPrimary.color)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let helper = step.helper {
                Text(helper)
                    .font(.subheadline)
                    .foregroundStyle(Theme.color.contentSecondary.color)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            control
                .padding(.top, Theme.space.s1)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("quiz.step.\(step.id)")
        .onAppear(perform: hydrate)
    }

    @ViewBuilder private var control: some View {
        switch step.kind {
        case .singleChoice, .multiChoice:
            choiceChips
        case .freeText:
            themedField(
                placeholder: step.placeholder ?? "",
                text: $freeText,
                // A placeholder is not a name once typing clears it — label the field
                // with the question already on screen (its title, else its helper).
                label: step.title ?? step.helper ?? "",
                identifier: "quiz.customNameField",
                submit: .done
            )
            .onChange(of: freeText) { _, text in
                model.record(QuizAnswer(stepID: step.id, choiceIDs: [], freeText: text))
            }
        case .decimalInput where step.id == "allowance":
            Stepper(value: $allowanceValue, in: 0...99) {
                Text(verbatim: "\(allowanceValue)")
                    .font(.title3.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(Theme.color.contentPrimary.color)
            }
            .padding(.horizontal, Theme.space.s4)
            .padding(.vertical, Theme.space.s3)
            .background(
                Theme.color.surfaceSunken.color,
                in: RoundedRectangle(cornerRadius: Theme.radius.s)
            )
            .onChange(of: allowanceValue) { _, value in
                model.record(QuizAnswer(stepID: step.id, choiceIDs: [], freeText: String(value)))
            }
            // A bare Stepper announces only the number — name it with the question
            // and echo the same value the label shows (both already on screen).
            .accessibilityLabel(step.title ?? "")
            .accessibilityValue("\(allowanceValue)")
            .accessibilityIdentifier("quiz.allowanceStepper")
        case .decimalInput:
            themedField(
                placeholder: step.placeholder ?? "0",
                text: $freeText,
                // Label with the question already on screen (its title, else its
                // helper) — the placeholder stops being the field's only name.
                label: step.title ?? step.helper ?? "",
                identifier: "quiz.spendField",
                // UNCHANGED BEHAVIOUR, moved one level in: the decimal pad is what
                // makes this the S47 locale surface (iOS draws its separator from
                // the user's Region), so it now sits ON the TextField rather than
                // on a container that has to forward it.
                keyboard: .decimalPad
            )
            .onChange(of: freeText) { _, text in
                model.record(QuizAnswer(stepID: step.id, choiceIDs: [], freeText: text))
            }
        case .slider:
            commitmentSlider
        case .consent:
            consentChoices
        case .seam:
            // Structurally unreachable: the engine never surfaces a seam step (R4);
            // rendering nothing keeps even a config mistake silent and calm.
            EmptyView()
        }
    }

    /// The app's ONE input well (UIR-1): a sunken field with a hairline edge — the
    /// same recessed language the unselected chips and the year wheel speak. The
    /// system `.roundedBorder` was the last un-themed control in onboarding.
    /// ME-8 warms this step: above the well sits a `.largeTitle` Rounded LIVE ECHO
    /// of what the user has typed, under a waterline hairline (blueprint §6.3, and
    /// creative §2's "hairline divider under hero numbers" — the motif's reuse at
    /// UI scale). The step stops being a bare keyboard and starts being designed.
    ///
    /// Three deliberate details:
    /// - **The echo is the RAW typed text, never a parse or a format.** The spend
    ///   step is the S47 defect surface — a comma-decimal user typing "12,50" had
    ///   it stored as 12, permanently, with no edit path. `DecimalInputParser`
    ///   owns that conversion and this view must not second-guess it. Echoing the
    ///   bytes back is the one display that cannot be wrong.
    /// - **`keyboardType` / `submitLabel` moved INTO this function**, onto the
    ///   `TextField` itself. They used to be chained on the call site's result;
    ///   now that the result is a container, leaving them there would rely on
    ///   those modifiers propagating down to a nested text input. They do — but
    ///   "they do" is unverifiable on this box and the failure mode is the wrong
    ///   keyboard on the money step, so the modifier stays welded to the field.
    /// - **The echo is `accessibilityHidden`.** VoiceOver already reads the
    ///   field's own value; announcing it twice is the exact duplication the
    ///   commitment slider's word echo avoids.
    @ViewBuilder
    private func themedField(
        placeholder: String,
        text: Binding<String>,
        label: String,
        identifier: String,
        keyboard: UIKeyboardType = .default,
        submit: SubmitLabel = .return
    ) -> some View {
        VStack(spacing: Theme.space.s3) {
            if !text.wrappedValue.isEmpty {
                VStack(spacing: Theme.space.s2) {
                    Text(text.wrappedValue)
                        // A TEXT STYLE with a design + weight — never a point size.
                        // R33.12: `.font(.system(size:))` reports "User will not be
                        // able to change the font size" to Apple's audit, and
                        // `@ScaledMetric` does not rescue it. `.largeTitle` scales.
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .foregroundStyle(Theme.color.contentPrimary.color)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    Rectangle()
                        .fill(Theme.color.borderHairline.color)
                        .frame(height: 1)
                        .frame(maxWidth: Theme.layout.contentMaxWidth)
                }
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)
            }

            TextField(placeholder, text: text)
                .textFieldStyle(.plain)
                .keyboardType(keyboard)
                .submitLabel(submit)
                .font(.body)
                .foregroundStyle(Theme.color.contentPrimary.color)
                // Label + id sit on the FIELD, before any chrome: the element XCUITest
                // queries and VoiceOver speaks must be the TextField itself, never the
                // decorated container around it.
                .accessibilityLabel(label)
                .accessibilityIdentifier(identifier)
                // The 44pt floor likewise sits on the FIELD, not on a wrapper: the
                // hit-region audit measures the element's own frame (brandkit §5 motor
                // floor). 44 stays BELOW the label's accessibility-size height, so it is
                // a floor the text grows past — never a cap it is trapped under.
                .frame(maxWidth: .infinity, minHeight: Theme.touch.minTarget)
                .padding(.horizontal, Theme.space.s4)
                .background(
                    Theme.color.surfaceSunken.color,
                    in: RoundedRectangle(cornerRadius: Theme.radius.s)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.radius.s)
                        .strokeBorder(Theme.color.borderHairline.color, lineWidth: 1)
                )
        }
    }

    /// E8.2 — the calm two-choice consent control: both choices are the SAME
    /// pill as every answer chip (equal peers — never a primary + quiet pair;
    /// the one primary on screen stays the shared Continue). Taps route through
    /// `recordConsent`, NEVER `toggle`/`record` — the choice is a device setting,
    /// not a QuizAnswer (ruling c). Selection reflects the model's transient
    /// pick: nothing pre-selected on a fresh mount or resume, the user's own
    /// choice re-hydrates on a within-session Back.
    private var consentChoices: some View {
        VStack(spacing: Theme.space.s3) {
            ForEach(step.choices ?? [], id: \.id) { choice in
                let optsIn = choice.id == "optIn"
                let selected = model.consentChoice == optsIn
                Button {
                    model.recordConsent(optsIn)
                } label: {
                    chipLabel(choice.label, selected: selected)
                }
                .buttonStyle(AnswerChipStyle(isSelected: selected))
                .accessibilityAddTraits(selected ? [.isSelected] : [])
                .accessibilityIdentifier("quiz.choice.\(choice.id)")
            }
        }
    }

    private var choiceChips: some View {
        VStack(spacing: Theme.space.s3) {
            ForEach(step.choices ?? [], id: \.id) { choice in
                let selected = selectedIDs.contains(choice.id)
                Button {
                    toggle(choice.id)
                } label: {
                    chipLabel(choice.label, selected: selected)
                }
                .buttonStyle(AnswerChipStyle(isSelected: selected))
                .accessibilityAddTraits(selected ? [.isSelected] : [])
                .accessibilityIdentifier("quiz.choice.\(choice.id)")
            }
        }
    }

    /// The chip's inner label. The style owns the pill, the fill, and the label
    /// colour; the CALLER owns the checkmark — selection is never colour alone
    /// (brandkit §8), and the glyph must survive any restyle.
    private func chipLabel(_ label: String, selected: Bool) -> some View {
        HStack(spacing: Theme.space.s2) {
            Text(label)
                .font(.body.weight(selected ? .semibold : .regular))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(
                    (selected ? Theme.color.brandOnPrimary : Theme.color.contentSecondary).color
                )
                .accessibilityHidden(true)
        }
    }

    private var commitmentSlider: some View {
        VStack(spacing: Theme.space.s3) {
            // The value echoes in WORDS beside the control, never a bare number
            // (brandkit §6.6); echoes come verbatim from the audited table.
            Text(currentEcho)
                .font(.title3.weight(.semibold))
                .foregroundStyle(Theme.color.brandPrimary.color)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                // The word echo is the Slider's own a11y VALUE below — hide this
                // sibling Text so VoiceOver reads the commitment once, not twice.
                .accessibilityHidden(true)
            Slider(value: $sliderValue, in: 0...1, step: detentStep)
                .tint(Theme.color.brandPrimary.color)
                // ME-8 — the spec'd haptic detents (blueprint §6.3). The tick fires
                // on the ECHO INDEX, not on `sliderValue`: the words are what the
                // detents exist to land on, so the feedback and the visible change
                // are the same event by construction.
                //
                // `.sensoryFeedback` deliberately, NOT the app's `LiveHapticsEngine`.
                // That engine exists to schedule a multi-event CoreHaptics pattern
                // across the 19-second 4-7-8 breath cycle; a detent is one discrete
                // tick. Reusing it would drag a `CHHapticEngine` lifecycle onto the
                // quiz path — and would mean touching `HapticsPlaying`, whose fake
                // is shared with the panic tests — to buy nothing. This modifier
                // renders no pixels, so it is golden-neutral.
                .sensoryFeedback(.selection, trigger: currentEchoIndex)
                .onChange(of: sliderValue) { _, value in
                    model.record(QuizAnswer(
                        stepID: step.id, choiceIDs: [],
                        freeText: String(format: "%.2f", value)
                    ))
                }
                // Value echoed in WORDS, never a bare "50 percent" (brandkit §6.6);
                // both the label and the value reuse the strings already on screen.
                .accessibilityLabel(step.title ?? "")
                .accessibilityValue(currentEcho)
                .accessibilityIdentifier("quiz.commitmentSlider")
        }
    }

    /// ME-8 — the detent spacing: one stop per echo, so every word the table
    /// carries is reachable and none is reachable twice.
    ///
    /// **The arithmetic is the whole point, because the obvious value is wrong.**
    /// With the shipped four echoes, `step: 0.25` looks right and is not: it places
    /// FIVE stops (0, .25, .5, .75, 1.0) for FOUR words, and `currentEcho`'s
    /// `Int(sliderValue * count)` maps both 0.75 and 1.0 onto index 3 — a detent the
    /// user can FEEL but not see, at the most meaningful end of the scale. The
    /// correct spacing is `1/(count-1)`: stops at 0, ⅓, ⅔, 1 map to 0, 1, 2, 3.
    /// (Checked at the boundary, including the float: `Int(0.666… * 4)` is 2, and
    /// 1.0 lands on 4 → clamped to 3 by the `min` below, which is exactly why that
    /// clamp is load-bearing and must not be "simplified" away.)
    private var detentStep: Double {
        let count = step.sliderEchoes?.count ?? 0
        guard count > 1 else { return 1 }
        return 1 / Double(count - 1)
    }

    /// Which echo the current value lands on. Extracted so the haptic tick and the
    /// visible word are driven by ONE derivation — they can never disagree.
    private var currentEchoIndex: Int {
        let echoes = step.sliderEchoes ?? []
        guard !echoes.isEmpty else { return 0 }
        return min(echoes.count - 1, Int(sliderValue * Double(echoes.count)))
    }

    private var currentEcho: String {
        let echoes = step.sliderEchoes ?? []
        guard !echoes.isEmpty else { return "" }
        return echoes[currentEchoIndex]
    }

    private var selectedIDs: [String] {
        model.answer(for: step.id)?.choiceIDs ?? []
    }

    private func toggle(_ choiceID: String) {
        var ids = selectedIDs
        if step.kind == .singleChoice {
            ids = [choiceID]
        } else if let existing = ids.firstIndex(of: choiceID) {
            ids.remove(at: existing)
        } else {
            ids.append(choiceID) // selection order preserved — the user's order stars
        }
        model.record(QuizAnswer(stepID: step.id, choiceIDs: ids))
    }

    /// Back/resume re-hydration: transient control state mirrors the preserved
    /// answer (AC5 — the model, not the view, owns the truth).
    private func hydrate() {
        guard let answer = model.answer(for: step.id) else { return }
        if let text = answer.freeText {
            switch step.kind {
            case .slider:
                sliderValue = Double(text) ?? 0.5
            case .decimalInput where step.id == "allowance":
                allowanceValue = Int(text) ?? 0
                freeText = text
            default:
                freeText = text
            }
        }
    }
}
