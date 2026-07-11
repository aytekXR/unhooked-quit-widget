import SwiftUI

/// E5.2 — the data-driven quiz (brandkit §6.4 QuizStepScreen): ONE question per
/// screen from the audited config, a thin progress bar (visible position — R9,
/// never the analytics slot), Back always available past the first step, and a
/// bottom-pinned Continue (one-hand rule). Every string renders verbatim from
/// `quizConfig.json` (DRAFT, founder-owned, lexicon-scanned); house style: teal
/// accents, indigo progress (brand/secondary), SF Symbols only, no red anywhere,
/// selected chips carry a checkmark (never color alone), `.background(_:in:)`
/// form only (Session 16 micro-rule).
struct QuizFlowView: View {
    @Bindable var model: QuizFlowModel

    var body: some View {
        VStack(spacing: 24) {
            progressBar

            if let step = model.currentStep {
                ScrollView {
                    QuizStepContent(step: step, model: model)
                        .padding(.top, 8)
                }
                .scrollBounceBehavior(.basedOnSize)
                // Re-hydrate the step's transient controls whenever the step changes
                // (Back re-creates the content from the preserved answer — AC5).
                .id(step.id)
            }

            Spacer(minLength: 0)
            controls
        }
        .padding(20)
        .onAppear { model.onFirstScreenAppear() }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("quiz.flow")
    }

    /// Thin visible-progress track (brand/secondary fill on the sunken track).
    private var progressBar: some View {
        let position = model.progressPosition
        let fraction = position.total > 0
            ? Double(position.index) / Double(position.total) : 0
        return GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.systemGray5))
                Capsule()
                    .fill(.indigo)
                    .frame(width: max(8, proxy.size.width * fraction))
                    .animation(.easeOut(duration: 0.2), value: position.index)
            }
        }
        .frame(height: 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(
            format: model.engine.config.controls.progressA11yFormat,
            position.index, position.total
        ))
        .accessibilityIdentifier("quiz.progress")
    }

    private var controls: some View {
        VStack(spacing: 12) {
            // SHOULD-4: the calm completion-retry surface — shown only when the
            // durable save failed; the checkpoint survived, Continue retries. Amber
            // + icon + text, never color alone (brandkit §2.2); string from the
            // audited table.
            if model.completionFailed {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise.circle")
                        .accessibilityHidden(true)
                    Text(model.engine.config.controls.retryNote)
                        .multilineTextAlignment(.center)
                }
                .font(.subheadline)
                .foregroundStyle(.orange)
                .accessibilityIdentifier("quiz.retryNote")
            }

            Button {
                model.advance()
            } label: {
                Text(model.engine.config.controls.continueLabel)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        continueDisabled ? Color.teal.opacity(0.35) : Color.teal,
                        in: Capsule()
                    )
            }
            .buttonStyle(.plain)
            .disabled(continueDisabled)
            .accessibilityIdentifier("quiz.continue")

            // Back is the quiet path (brandkit §6.2) — always visible past step 1,
            // never hidden or shrunk; fires nothing, preserves answers.
            if model.progressPosition.index > 1 {
                Button {
                    model.back()
                } label: {
                    Text(model.engine.config.controls.backLabel)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        // Quiet visual, full 44pt hit target (brandkit §5 floor).
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
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
        VStack(spacing: 16) {
            if let title = step.title {
                Text(title)
                    .font(.title2.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            if let helper = step.helper {
                Text(helper)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            control
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
            TextField(step.placeholder ?? "", text: $freeText)
                .textFieldStyle(.roundedBorder)
                .submitLabel(.done)
                .onChange(of: freeText) { _, text in
                    model.record(QuizAnswer(stepID: step.id, choiceIDs: [], freeText: text))
                }
                .accessibilityIdentifier("quiz.customNameField")
        case .decimalInput where step.id == "allowance":
            Stepper(value: $allowanceValue, in: 0...99) {
                Text(verbatim: "\(allowanceValue)")
                    .font(.title3.weight(.semibold))
                    .monospacedDigit()
            }
            .onChange(of: allowanceValue) { _, value in
                model.record(QuizAnswer(stepID: step.id, choiceIDs: [], freeText: String(value)))
            }
            .accessibilityIdentifier("quiz.allowanceStepper")
        case .decimalInput:
            TextField(step.placeholder ?? "0", text: $freeText)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
                .onChange(of: freeText) { _, text in
                    model.record(QuizAnswer(stepID: step.id, choiceIDs: [], freeText: text))
                }
                .accessibilityIdentifier("quiz.spendField")
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

    /// E8.2 — the calm two-choice consent control: both choices are the SAME
    /// pill as every answer chip (equal peers — never a primary + quiet pair;
    /// the one primary on screen stays the shared Continue). Taps route through
    /// `recordConsent`, NEVER `toggle`/`record` — the choice is a device setting,
    /// not a QuizAnswer (ruling c). Selection reflects the model's transient
    /// pick: nothing pre-selected on a fresh mount or resume, the user's own
    /// choice re-hydrates on a within-session Back.
    private var consentChoices: some View {
        VStack(spacing: 10) {
            ForEach(step.choices ?? [], id: \.id) { choice in
                let optsIn = choice.id == "optIn"
                let selected = model.consentChoice == optsIn
                Button {
                    model.recordConsent(optsIn)
                } label: {
                    HStack(spacing: 8) {
                        Text(choice.label)
                            .font(.body.weight(selected ? .semibold : .regular))
                        Spacer(minLength: 0)
                        // Selection carries a glyph, never color alone (brandkit §8).
                        Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(selected ? Color.white : Color.secondary)
                            .accessibilityHidden(true)
                    }
                    .foregroundStyle(selected ? Color.white : Color.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
                    .frame(maxWidth: .infinity)
                    .background(
                        selected ? Color.teal : Color(.systemGray6),
                        in: RoundedRectangle(cornerRadius: 14)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selected ? [.isSelected] : [])
                .accessibilityIdentifier("quiz.choice.\(choice.id)")
            }
        }
    }

    private var choiceChips: some View {
        VStack(spacing: 10) {
            ForEach(step.choices ?? [], id: \.id) { choice in
                let selected = selectedIDs.contains(choice.id)
                Button {
                    toggle(choice.id)
                } label: {
                    HStack(spacing: 8) {
                        Text(choice.label)
                            .font(.body.weight(selected ? .semibold : .regular))
                        Spacer(minLength: 0)
                        // Selection carries a glyph, never color alone (brandkit §8).
                        Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(selected ? Color.white : Color.secondary)
                            .accessibilityHidden(true)
                    }
                    .foregroundStyle(selected ? Color.white : Color.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
                    .frame(maxWidth: .infinity)
                    .background(
                        selected ? Color.teal : Color(.systemGray6),
                        in: RoundedRectangle(cornerRadius: 14)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selected ? [.isSelected] : [])
                .accessibilityIdentifier("quiz.choice.\(choice.id)")
            }
        }
    }

    private var commitmentSlider: some View {
        VStack(spacing: 12) {
            // The value echoes in WORDS beside the control, never a bare number
            // (brandkit §6.6); echoes come verbatim from the audited table.
            Text(currentEcho)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.teal)
            Slider(value: $sliderValue, in: 0...1)
                .tint(.teal)
                .onChange(of: sliderValue) { _, value in
                    model.record(QuizAnswer(
                        stepID: step.id, choiceIDs: [],
                        freeText: String(format: "%.2f", value)
                    ))
                }
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
