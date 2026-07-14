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

    var body: some View {
        // The step id is the SCROLL VIEW's identity, not the question's: on a step
        // change the scaffold rebuilds its scroll view, so the next question opens at
        // the top (v1 got this from `.id(step.id)` ON the ScrollView; a stable scroll
        // view would silently inherit the previous question's offset and could open a
        // step below the fold on a small screen or at accessibility sizes) and the
        // step's transient controls re-hydrate with it (Back re-creates the content
        // from the preserved answer — AC5). The progress bar and Continue keep stable
        // identity outside it, so the bar still animates its fill instead of jumping.
        OnboardingScaffold(contentID: model.currentStep?.id) {
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
                model.advance()
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
                    model.back()
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
                identifier: "quiz.customNameField"
            )
            .submitLabel(.done)
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
                identifier: "quiz.spendField"
            )
            .keyboardType(.decimalPad)
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
    private func themedField(
        placeholder: String,
        text: Binding<String>,
        label: String,
        identifier: String
    ) -> some View {
        TextField(placeholder, text: text)
            .textFieldStyle(.plain)
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
            Slider(value: $sliderValue, in: 0...1)
                .tint(Theme.color.brandPrimary.color)
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

    private var currentEcho: String {
        let echoes = step.sliderEchoes ?? []
        guard !echoes.isEmpty else { return "" }
        let index = min(echoes.count - 1, Int(sliderValue * Double(echoes.count)))
        return echoes[index]
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
