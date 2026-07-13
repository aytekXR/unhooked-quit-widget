import SwiftUI

/// The real ~90s panic flow UI (E3.2) — breath pacer → urge timer → reasons →
/// redirect → exits, every step skippable, rendered purely from the flow model
/// (store-free by contract, ADR-6). Mounts inside the panic root's content-stable
/// `root.panicPlaceholder` anchor so every route-level smoke keeps discriminating on
/// the ROUTE, not this epic's content. Brandkit hard rules hold throughout: no red
/// anywhere, teal primary, 56pt panic targets, SF Pro (no Rounded — the streak hero
/// is a dashboard element and the panic hero is the user's WORDS), zero decorative
/// animation on entry, stage transitions at motion/calm 600ms fades.
struct PanicFlowView: View {
    @State var model: PanicFlowModel
    /// The cold-route slip flow, built EXACTLY ONCE when the slipped-exit handoff
    /// appears (never per render) and then model-state-driven from there. Nil = the
    /// panic steps show; non-nil = the real slip flow is mounted over them.
    @State private var slipModel: SlipFlowModel?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(model: PanicFlowModel) {
        _model = State(initialValue: model)
    }

    /// Production wiring for the cold panic route. E3.3: the launch's TRUE origin
    /// threads in from the pre-frame capture (UnhookedApp → PanicPlaceholderView) or the
    /// in-app entry — the `.lockscreenWidget` hardcode is dead. E9.3 (R28.2):
    /// `hapticsOnlyPacer` is the persisted preference read off the pre-cache ENVELOPE
    /// by the mount (the store stays off-limits on this path — the settings writer
    /// stamps the envelope so this route never opens SwiftData). E4.1 attaches the
    /// REAL slip flow: the mount is driven off `model.slipHandoff` (set by
    /// `exitSlipped`) through the view's `onChange` seam below, so `onSlipRoute` is a
    /// required-by-initializer no-op — the routing lives in state.
    init(quit: QuitSnapshot?, script: PanicScript, source: PanicSource, hapticsOnlyPacer: Bool = false) {
        _model = State(initialValue: PanicFlowModel(
            quit: quit,
            script: script,
            source: source,
            hapticsOnlyPacer: hapticsOnlyPacer,
            clock: LiveClock(),
            haptics: LiveHapticsEngine(),
            buffer: PanicOutcomeBuffer.appGroup(),
            onSlipRoute: { _ in }
        ))
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.easeInOut(duration: reduceMotion ? 0.2 : 0.6), value: model.stage)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("panic.flow")
            // The slipped-exit seam (E4.1): the handoff drives the mount. `exitSlipped`
            // sets `model.slipHandoff` on the panic scene; here it builds the cold-route
            // `SlipFlowModel` ONCE and parks it in state. The store never opens on this
            // path — the flow touches only the card + the §9-rule-2 buffer + the witness.
            .onChange(of: model.slipHandoff != nil) { _, handedOff in
                if handedOff, slipModel == nil, let handoff = model.slipHandoff {
                    slipModel = Self.makeColdSlipModel(handoff: handoff, card: model.quit)
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        if let slipModel {
            SlipFlowView(model: slipModel, clock: LiveClock(), onDismiss: { self.slipModel = nil })
        } else {
            switch model.stage {
            case .breath: BreathStepView(model: model, reduceMotion: reduceMotion)
            case .timer: TimerStepView(model: model)
            case .reasons: ReasonsStepView(model: model)
            case .redirect: RedirectStepView(model: model)
            case .exits: ExitsView(model: model)
            case .celebration: CelebrationView(model: model)
            }
        }
    }

    /// Cold-route composition (architecture §9 rule 2): the card out of the pre-cache,
    /// the App Group outcome buffer as the ONE write target, and the App Group witness
    /// store — everything the store-free slip flow may touch. `loadShipping()` degrades
    /// to the plain-label fallback (§9) when the bundled copy is unreadable.
    @MainActor
    private static func makeColdSlipModel(handoff: PanicSlipHandoff, card: QuitSnapshot?) -> SlipFlowModel {
        SlipFlowModel(
            route: .cold(
                handoff: handoff,
                card: card,
                buffer: PanicOutcomeBuffer.appGroup(),
                witnessStore: UserDefaults(suiteName: AppIdentifiers.appGroupID)
                    .map(LastKnownGoodStore.init(defaults:))
            ),
            copy: SlipCopy.loadShipping() ?? .degraded,
            clock: LiveClock()
        )
    }
}

// MARK: - Shared step chrome

/// Common step layout: title + instruction up top, the step's content in the middle,
/// skip pinned to the lower reach zone (one-hand rule; 56pt panic target).
private struct StepScaffold<Content: View>: View {
    let identifier: String
    let title: String
    let instruction: String
    /// E9.3 (R28.4/R28.8) — a taps-anchored VoiceOver override for the instruction
    /// line where the VISIBLE copy misdirects a non-visual user (bloom mode's "Follow
    /// the circle"). METADATA ONLY: nil ⇒ VO reads the visible instruction (the
    /// default), non-nil ⇒ VO reads this instead — the label never reflows, so the
    /// goldens hold (the raster sees layers, never a11y metadata).
    var instructionAccessibilityLabel: String? = nil
    var subtext: String?
    let skipLabel: String
    let onSkip: () -> Void
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 10) {
                Text(title)
                    .font(.title.weight(.semibold))
                    .multilineTextAlignment(.center)
                    // On the TEXT, not just the container: XCUITest reliably exposes
                    // real elements' identifiers, while nested `.contain` container
                    // ids may never surface (the Session 09 UI-smoke lesson, relearned
                    // once more in Session 10 on this very screen).
                    .accessibilityIdentifier("\(identifier).title")
                Text(instruction)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    // nil override ⇒ the visible instruction is its own label (the
                    // default reading); every step but bloom-mode breath passes nil.
                    .accessibilityLabel(instructionAccessibilityLabel ?? instruction)
            }
            .padding(.top, 28)
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            if let subtext {
                Text(subtext)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            SkipButton(label: skipLabel, action: onSkip)
        }
        .padding(20)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(identifier)
    }
}

/// The quiet skip affordance: content-secondary, never below type/body, full 56pt
/// target ("help is never disabled" — every step is leavable).
private struct SkipButton: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, minHeight: 56)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("panic.flow.skip")
    }
}

// MARK: - Step 1 · breath pacer

private struct BreathStepView: View {
    let model: PanicFlowModel
    let reduceMotion: Bool

    var body: some View {
        let step = model.script.step(.breath)
        StepScaffold(
            identifier: "panic.flow.step.breath",
            title: model.entryTitle,
            // E9.3 (R28.4): in haptics-only mode "Follow the circle" is a literal
            // falsehood (no circle is drawn) — the taps-anchored line renders
            // instead, falling back to the visual instruction for a script that
            // predates the field (decode-tolerant optional).
            instruction: model.hapticsOnlyPacer
                ? (step?.instructionNonVisual ?? step?.instruction ?? "")
                : (step?.instruction ?? ""),
            // Bloom mode: VO hears the taps-anchored line instead of the visible
            // "Follow the circle" (R28.4). Haptics-only mode passes nil — its VISIBLE
            // instruction already IS the non-visual line, so it needs no override.
            instructionAccessibilityLabel: model.hapticsOnlyPacer
                ? nil
                : (step?.instructionNonVisual ?? step?.instruction ?? ""),
            skipLabel: step?.skipLabel ?? "",
            onSkip: { model.skip() }
        ) {
            pacer
        }
        .task { model.markPacerStarted() }
    }

    @ViewBuilder
    private var pacer: some View {
        if model.hapticsOnlyPacer {
            // Haptics-only mode: static instruction + progress ticks — the rhythm
            // lives entirely in CoreHaptics (brandkit §6.10, eyes-free regulation).
            VStack(spacing: 16) {
                Image(systemName: "hand.tap")
                    .font(.system(size: 44))
                    .foregroundStyle(.teal)
                    .accessibilityHidden(true)
                Text(model.script.step(.breath)?.hapticOnlyLabel ?? "")
                    .font(.title3.weight(.medium))
                    .multilineTextAlignment(.center)
                if let pattern = model.pacerPattern, pattern.rounds > 0 {
                    HStack(spacing: 10) {
                        ForEach(1...pattern.rounds, id: \.self) { _ in
                            Circle()
                                .fill(.teal.opacity(0.35))
                                .frame(width: 12, height: 12)
                        }
                    }
                    .accessibilityHidden(true)
                }
            }
        } else if let pattern = model.pacerPattern {
            BreathBloomView(
                pattern: pattern,
                startedAt: model.pacerStartedAt,
                reduceMotion: reduceMotion
            )
        } else {
            Image(systemName: "wind")
                .font(.system(size: 56))
                .foregroundStyle(.teal)
                .accessibilityHidden(true)
        }
    }
}

/// The bloom, driven frame-by-frame from the pure pattern model so the screen and
/// the haptic rhythm share one timing source. Reduce Motion swaps scale for opacity
/// pulsing at the SAME rhythm — the rhythm is the therapeutic content, the motion is
/// what's dropped (brandkit §7). The initial render (startedAt == nil) is always
/// phase zero, which also makes the snapshot goldens deterministic.
private struct BreathBloomView: View {
    let pattern: BreathPacerPattern
    let startedAt: Date?
    let reduceMotion: Bool

    var body: some View {
        TimelineView(.animation(paused: startedAt == nil)) { context in
            let elapsed = startedAt.map { context.date.timeIntervalSince($0) } ?? 0
            let progress = pattern.phaseProgress(at: elapsed)
            ZStack {
                Circle()
                    .stroke(.teal.opacity(0.25), lineWidth: 2)
                Circle()
                    .fill(.teal.opacity(reduceMotion ? pulseOpacity(progress) : 0.28))
                    .scaleEffect(reduceMotion ? 1 : bloomScale(progress))
            }
            .frame(width: 220, height: 220)
        }
        .accessibilityHidden(true) // the instruction line + haptics carry the rhythm
    }

    private func bloomScale(_ progress: (phase: BreathPacerPattern.Phase, fraction: Double)?) -> Double {
        switch progress?.phase.kind {
        case .inhale: 0.6 + 0.4 * smoothstep(progress?.fraction ?? 0)
        case .hold: 1.0
        case .exhale: 1.0 - 0.4 * smoothstep(progress?.fraction ?? 0)
        case nil: 0.6 // pattern complete — resting; skip (or one more round) carries on
        }
    }

    private func pulseOpacity(_ progress: (phase: BreathPacerPattern.Phase, fraction: Double)?) -> Double {
        switch progress?.phase.kind {
        case .inhale: 0.15 + 0.25 * smoothstep(progress?.fraction ?? 0)
        case .hold: 0.4
        case .exhale: 0.4 - 0.25 * smoothstep(progress?.fraction ?? 0)
        case nil: 0.15
        }
    }

    /// The brandkit's "sinusoidal, mirroring exhalation" easing, as pure math.
    private func smoothstep(_ x: Double) -> Double {
        let clamped = min(max(x, 0), 1)
        return clamped * clamped * (3 - 2 * clamped)
    }
}

// MARK: - Step 2 · urge timer

private struct TimerStepView: View {
    let model: PanicFlowModel

    var body: some View {
        let step = model.script.step(.timer)
        StepScaffold(
            identifier: "panic.flow.step.timer",
            title: step?.title ?? "",
            instruction: step?.instruction ?? "",
            subtext: step?.subtext,
            skipLabel: step?.skipLabel ?? "",
            onSkip: { model.skip() }
        ) {
            Image(systemName: "timer")
                .font(.system(size: 56, weight: .light))
                .foregroundStyle(.teal)
                .accessibilityHidden(true)
        }
    }
}

// MARK: - Step 3 · reasons (the user's words, the largest text in the app)

private struct ReasonsStepView: View {
    let model: PanicFlowModel
    /// type/panicReason: 40pt Semibold, scales with .largeTitle (brandkit §3).
    @ScaledMetric(relativeTo: .largeTitle) private var reasonSize: CGFloat = 40

    var body: some View {
        let step = model.script.step(.reasons)
        StepScaffold(
            identifier: "panic.flow.step.reasons",
            title: step?.title ?? "",
            instruction: step?.instruction ?? "",
            skipLabel: step?.skipLabel ?? "",
            onSkip: { model.skip() }
        ) {
            if model.reasons.isEmpty {
                // Never blank: the script's fallback line stands in.
                reasonText(step?.emptyFallback ?? "")
            } else {
                // One motivation per page, vertical paging (brandkit §6.11) — each
                // of the user's reasons gets the whole screen's attention.
                ScrollView(.vertical) {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(model.reasons.enumerated()), id: \.offset) { _, reason in
                            reasonText(reason) // VERBATIM — their words star, ours frame
                                .containerRelativeFrame(.vertical)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.paging)
            }
        }
    }

    private func reasonText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: reasonSize, weight: .semibold))
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.5)
            .frame(maxWidth: .infinity)
    }
}

// MARK: - Step 4 · redirect menu

private struct RedirectStepView: View {
    let model: PanicFlowModel

    var body: some View {
        let step = model.script.step(.redirect)
        StepScaffold(
            identifier: "panic.flow.step.redirect",
            title: step?.title ?? "",
            instruction: step?.instruction ?? "",
            skipLabel: step?.skipLabel ?? "",
            onSkip: { model.skip() }
        ) {
            VStack(spacing: 12) {
                ForEach(step?.options ?? [], id: \.id) { option in
                    Button {
                        model.selectRedirect(option.id)
                    } label: {
                        HStack {
                            Text(option.label)
                                .font(.body.weight(.medium))
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity, minHeight: 56) // touch.panic
                        .background(.teal.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("panic.flow.redirect.option.\(option.id)")
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Step 5 · exit states

private struct ExitsView: View {
    let model: PanicFlowModel
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "wind")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(.teal)
                .accessibilityHidden(true)
            Spacer()
            Button {
                model.exitUrgePassed()
            } label: {
                Text(model.exitLabel("averted") ?? "")
                    .font(.body.weight(.semibold))
                    // Dark mode's lighter teal needs dark text for contrast.
                    .foregroundStyle(colorScheme == .dark ? Color.black.opacity(0.85) : .white)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(.teal, in: RoundedRectangle(cornerRadius: 16))
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("panic.flow.exit.averted")
            Button {
                model.exitSlipped()
            } label: {
                Text(model.exitLabel("slipped") ?? "")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("panic.flow.exit.slipped")
        }
        .padding(20)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("panic.flow.step.exits")
    }
}

/// The quiet celebration: the averted confirmation copy and one soft haptic already
/// played by the model — a stat's worth of acknowledgment, never confetti.
private struct CelebrationView: View {
    let model: PanicFlowModel

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(.teal)
                .accessibilityHidden(true)
            Text(model.script.exit("averted")?.confirmation ?? "")
                .font(.title2.weight(.semibold))
                .multilineTextAlignment(.center)
                .accessibilityIdentifier("panic.flow.celebration.copy") // real element for the smoke
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("panic.flow.celebration")
    }
}

