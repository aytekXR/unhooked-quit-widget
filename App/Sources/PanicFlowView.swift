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
    /// Freezes the wave timer's ticking text + crest for deterministic
    /// snapshot goldens (the `StreakWidgetView.pauseDate` precedent);
    /// production always passes nil.
    var pauseDate: Date?
    /// The cold-route slip flow, built EXACTLY ONCE when the slipped-exit handoff
    /// appears (never per render) and then model-state-driven from there. Nil = the
    /// panic steps show; non-nil = the real slip flow is mounted over them.
    @State private var slipModel: SlipFlowModel?
    /// QW-10 (redesign §5.2) — the in-flow resources sheet: a person mid-crisis
    /// gets a path to a helpline WITHOUT exiting the flow. Mounted from the
    /// post-pacer support affordances only; the entry frame never carries it.
    @State private var showsResources = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(model: PanicFlowModel, pauseDate: Date? = nil) {
        _model = State(initialValue: model)
        self.pauseDate = pauseDate
    }

    /// Production wiring for the cold panic route. E3.3: the launch's TRUE origin
    /// threads in from the pre-frame capture (BallastApp → PanicPlaceholderView) or the
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
            .themedScreenSurface() // UIR-0: surface/base behind every panic frame
            // Stage crossfade at motion/calm (motion/quick under Reduce Motion) —
            // token-for-literal only (M10/D5): the durations are byte-identical.
            .animation(.easeInOut(duration: reduceMotion ? Theme.motion.quick : Theme.motion.calm), value: model.stage)
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
            // QW-10 — the resources sheet INSIDE the flow. `SafetyResourcesView`
            // is store-free by construction (bundled JSON only — R27.11), so the
            // cold route's store-free contract holds. Source nil: an in-crisis
            // open is honest-by-omission (R27.4's closed analytics domain keeps
            // its shape; safety surfaces are exempt from performance judgment).
            .sheet(isPresented: $showsResources) {
                SafetyResourcesView(source: nil, analytics: .disabled)
            }
    }

    @ViewBuilder
    private var content: some View {
        if let slipModel {
            SlipFlowView(model: slipModel, clock: LiveClock(), onDismiss: { self.slipModel = nil })
        } else {
            switch model.stage {
            case .breath: BreathStepView(model: model, reduceMotion: reduceMotion)
            case .timer: TimerStepView(model: model, pauseDate: pauseDate, onMoreSupport: { showsResources = true })
            case .reasons: ReasonsStepView(model: model, onMoreSupport: { showsResources = true })
            case .redirect: RedirectStepView(model: model, onMoreSupport: { showsResources = true })
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
    /// UIR-3 (R33.5): the header+content SCROLL and the skip is PINNED below. The
    /// reasons step manages its OWN paging scroll, so it passes `false` to avoid a
    /// gesture-fighting nested scroll (its content fills the frame instead).
    var scrollsContent: Bool = true
    /// QW-10 — the quiet in-flow support affordance (copy doc §7): footnote-weight,
    /// bottom-trailing, PINNED beside the skip so help never scrolls away. nil (the
    /// default, and always the pacer step) renders nothing — the entry frame stays
    /// byte-identical.
    var supportLabel: String? = nil
    var onSupport: (() -> Void)? = nil
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            if scrollsContent {
                ScrollView { scaffoldBody }
                    .scrollBounceBehavior(.basedOnSize)
            } else {
                scaffoldBody
            }
            // QW-10: the quiet support link sits bottom-trailing, ABOVE the skip —
            // a deliberate door to a helpline from inside the flow (crisis-safety
            // surfaces only ever become MORE reachable).
            if let supportLabel, let onSupport {
                HStack {
                    Spacer()
                    Button(action: onSupport) {
                        Text(supportLabel)
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(Theme.color.contentSecondary.color)
                            // 44pt-class target via PADDING (R33.5 — never a
                            // height floor near the label's AX height).
                            .padding(.vertical, Theme.space.s4)
                            .padding(.horizontal, Theme.space.s2)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("panic.flow.moreSupport")
                }
                .padding(.horizontal, Theme.space.s5)
            }
            // R33.5 one-hand rule: skip is PINNED below the scroll, never scrolls off.
            SkipButton(label: skipLabel, action: onSkip)
                .padding(.horizontal, Theme.space.s5)
                .padding(.bottom, Theme.space.s5)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(identifier)
    }

    private var scaffoldBody: some View {
        VStack(spacing: Theme.space.s5) {
            // D18: 10 and 28 were off the 4pt scale — settled onto s3/s6.
            VStack(spacing: Theme.space.s3) {
                Text(title)
                    .font(.title.weight(.semibold))
                    // D11: the app's one warm ink (content/primary), never the raw
                    // system label — sibling text on this screen already rides it.
                    .foregroundStyle(Theme.color.contentPrimary.color)
                    .multilineTextAlignment(.center)
                    // On the TEXT, not just the container: XCUITest reliably exposes
                    // real elements' identifiers, while nested `.contain` container
                    // ids may never surface (the Session 09 UI-smoke lesson, relearned
                    // once more in Session 10 on this very screen).
                    .accessibilityIdentifier("\(identifier).title")
                Text(instruction)
                    .font(.body)
                    .foregroundStyle(Theme.color.contentPrimary.color)
                    .multilineTextAlignment(.center)
                    // nil override ⇒ the visible instruction is its own label (the
                    // default reading); every step but bloom-mode breath passes nil.
                    .accessibilityLabel(instructionAccessibilityLabel ?? instruction)
            }
            .padding(.top, Theme.space.s6)
            content()
                // Scrolling steps take natural height; the paging reasons step fills.
                .frame(maxWidth: .infinity, maxHeight: scrollsContent ? nil : .infinity)
            if let subtext {
                Text(subtext)
                    .font(.footnote)
                    .foregroundStyle(Theme.color.contentSecondary.color)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, Theme.space.s5)
        .padding(.bottom, Theme.space.s5)
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
                .foregroundStyle(Theme.color.contentSecondary.color)
                // R33.5: the 56pt panic target rides PADDING, never a minHeight floor —
                // 20 + ~17pt(.body) + 20 = 57pt at default, growing with the text at
                // accessibility sizes (never a cap above the label's AX height).
                .padding(.vertical, Theme.space.s5)
                .frame(maxWidth: .infinity)
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

    /// D13: decorative glyphs scale with Dynamic Type (the AgeGateView pattern;
    /// brandkit §8: everything scales), capped so a mark never crowds the content
    /// it decorates. Bases keep the shipped sizes, so default-size frames hold.
    @ScaledMetric(relativeTo: .largeTitle) private var tapGlyphSize: CGFloat = Theme.type.screenGlyphBase
    @ScaledMetric(relativeTo: .largeTitle) private var restingGlyphSize: CGFloat = 56

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
            VStack(spacing: Theme.space.s4) {
                Image(systemName: "hand.tap")
                    .font(.system(size: min(tapGlyphSize, Theme.type.screenGlyphCap)))
                    .foregroundStyle(Theme.color.brandPrimary.color)
                    .accessibilityHidden(true)
                Text(model.script.step(.breath)?.hapticOnlyLabel ?? "")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(Theme.color.contentPrimary.color)
                    .multilineTextAlignment(.center)
                if let pattern = model.pacerPattern, pattern.rounds > 0 {
                    HStack(spacing: 10) {
                        ForEach(1...pattern.rounds, id: \.self) { _ in
                            Circle()
                                .fill(Theme.color.brandPrimary.color.opacity(Theme.alpha.bloomTick))
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
                .font(.system(size: min(restingGlyphSize, Theme.type.screenGlyphCap)))
                .foregroundStyle(Theme.color.brandPrimary.color)
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
                    .stroke(Theme.color.brandPrimary.color.opacity(Theme.alpha.bloomRing), lineWidth: 2)
                Circle()
                    .fill(Theme.color.brandPrimary.color.opacity(
                        reduceMotion ? pulseOpacity(progress) : Theme.alpha.bloomFill
                    ))
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

// MARK: - QW-10 · the in-flow support copy (safety-panel-gated table)

/// Loaded on first access — a Swift static initializes lazily, and the first
/// access is a POST-pacer step's render, so the panic entry frame never pays
/// for the read (the affordance is banned from the pacer frame outright).
@MainActor
private enum PanicSupportAffordance {
    static let copy = SafetyCopy.loadShipping()?.panicSupport ?? .degraded
}

// MARK: - Step 2 · urge timer (the live wave — P2, redesign §6.8)

private struct TimerStepView: View {
    let model: PanicFlowModel
    /// Snapshot freeze (nil in production — see `PanicFlowView.pauseDate`).
    let pauseDate: Date?
    let onMoreSupport: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let step = model.script.step(.timer)
        StepScaffold(
            identifier: "panic.flow.step.timer",
            title: step?.title ?? "",
            instruction: step?.instruction ?? "",
            subtext: step?.subtext,
            skipLabel: step?.skipLabel ?? "",
            onSkip: { model.skip() },
            supportLabel: PanicSupportAffordance.copy.moreSupportLabel,
            onSupport: onMoreSupport
        ) {
            VStack(spacing: Theme.space.s5) {
                // The wave is decorative and OMITTED at AX sizes (the
                // StreakRing precedent — words and the count carry meaning).
                // Reduce Motion → static crest with a slow opacity breath.
                if !dynamicTypeSize.isAccessibilitySize {
                    WaveTimerView(
                        startedAt: model.timerStartedAt,
                        reduceMotion: reduceMotion,
                        pauseDate: pauseDate
                    )
                }
                elapsedLine(label: step?.elapsedLabel)
            }
        }
        // The ride clock starts when the step's first frame is ON SCREEN —
        // never at flow construction (the pacer's exact discipline). Zero
        // entry-frame cost: this runs on the timer step only, post-pacer.
        .task { model.markTimerStarted() }
    }

    /// Elapsed ride time, counting UP in monospaced digits ("2:31" + the
    /// DRAFT "riding it" label). System-ticking `Text(timerInterval:)` —
    /// `countsDown: false` is load-bearing, and VoiceOver reads it on focus
    /// only (never an automatic announcement — §8: nothing counts against the
    /// user, in audio either). Before the ride starts (initial frame) the
    /// figure renders frozen at zero.
    private func elapsedLine(label: String?) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: Theme.space.s2) {
            if let start = model.timerStartedAt {
                // A generous fixed span is the system ticker's ceiling — the
                // figure only ever counts UP inside it. `pauseTime` freezes it
                // for the goldens only (production passes nil).
                Text(
                    timerInterval: start...start.addingTimeInterval(12 * 3_600),
                    pauseTime: pauseDate,
                    countsDown: false,
                    showsHours: false
                )
                .font(.title3.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(Theme.color.brandPrimary.color)
            } else {
                // Pre-start frame (and the goldens): the ride at zero — a
                // literal zero FIGURE (data, not copy), byte-stable.
                Text(verbatim: "0:00")
                    .font(.title3.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(Theme.color.brandPrimary.color)
            }
            if let label, !label.isEmpty {
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(Theme.color.contentSecondary.color)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("panic.flow.timer.elapsed")
    }
}

// MARK: - Step 3 · reasons (the user's words, the largest text in the app)

private struct ReasonsStepView: View {
    let model: PanicFlowModel
    let onMoreSupport: () -> Void
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let step = model.script.step(.reasons)
        // R35.6 — at ANY accessibility size (AX1–AX5) the full-viewport paging layout below
        // leaves the NON-scrolling scaffold no room to wrap a grown `.title`, so the title
        // truncates. At those sizes the scaffold scrolls instead (`scrollsContent: isAX`) and
        // the reasons flow at natural height — the title wraps freely and each large reason
        // scrolls into view. At normal sizes the per-reason PAGING is unchanged (brandkit
        // §6.11: each reason gets the whole screen; that per-reason focus is traded for
        // readability at accessibility sizes, where a single `.largeTitle` reason overruns a
        // page anyway). The Skip stays PINNED either way (it lives outside the scaffold scroll).
        // Pure layout — no copy/register change; the panic audit runs at default size (isAX ==
        // false there) so this is a no-op for the rule-11 leg, and the reasons frame is not
        // itself audited today (a tracked follow-up, not this change's scope).
        let isAX = dynamicTypeSize.isAccessibilitySize
        StepScaffold(
            identifier: "panic.flow.step.reasons",
            title: step?.title ?? "",
            instruction: step?.instruction ?? "",
            skipLabel: step?.skipLabel ?? "",
            onSkip: { model.skip() },
            scrollsContent: isAX,
            supportLabel: PanicSupportAffordance.copy.moreSupportLabel,
            onSupport: onMoreSupport
        ) {
            if model.reasons.isEmpty {
                // Never blank: the script's fallback line stands in.
                reasonText(step?.emptyFallback ?? "")
            } else if isAX {
                // Accessibility sizes: the reasons flow at natural height inside the scaffold's
                // own scroll (the title above can grow; each huge reason scrolls into view).
                VStack(spacing: Theme.space.s8) {
                    ForEach(Array(model.reasons.enumerated()), id: \.offset) { _, reason in
                        reasonText(reason) // VERBATIM — their words star, ours frame
                    }
                }
            } else {
                // Normal sizes: one motivation per page, vertical paging (brandkit §6.11) —
                // each of the user's reasons gets the whole screen's attention.
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
        // R33.12: the user's words ride a TEXT STYLE (`.largeTitle`), never a
        // `@ScaledMetric`-driven point size — a point size on Text is un-scalable to
        // Apple's audit however it is driven. `.minimumScaleFactor` (shrink-to-fit) is
        // dropped with it: the layout gives way, never the glyph (brandkit §8).
        Text(text)
            .font(.largeTitle.weight(.semibold))
            .foregroundStyle(Theme.color.contentPrimary.color) // D11: one warm ink
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }
}

// MARK: - Step 4 · redirect menu

private struct RedirectStepView: View {
    let model: PanicFlowModel
    let onMoreSupport: () -> Void

    var body: some View {
        let step = model.script.step(.redirect)
        StepScaffold(
            identifier: "panic.flow.step.redirect",
            title: step?.title ?? "",
            instruction: step?.instruction ?? "",
            skipLabel: step?.skipLabel ?? "",
            onSkip: { model.skip() }
        ) {
            VStack(spacing: Theme.space.s3) {
                ForEach(step?.options ?? [], id: \.id) { option in
                    Button {
                        model.selectRedirect(option.id)
                    } label: {
                        HStack {
                            Text(option.label)
                                .font(.body.weight(.medium))
                            Spacer()
                        }
                        // R33.5: the 56pt panic target rides PADDING (16h + 20v), so the
                        // tinted pill grows with the label at accessibility sizes instead
                        // of a minHeight floor that reads as a cap (the S28 defect).
                        .padding(.horizontal, Theme.space.s4)
                        .padding(.vertical, Theme.space.s5)
                        .frame(maxWidth: .infinity)
                        .themedSelectionTint()
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("panic.flow.redirect.option.\(option.id)")
                }
                // QW-10 (copy doc §7) — the full-sentence support footer: NOT a
                // fifth tile — help sits BELOW the choices, always present, never
                // alarming. Same door as "More support", given room to be a
                // sentence where the redirect step has room.
                Button {
                    onMoreSupport()
                } label: {
                    Text(PanicSupportAffordance.copy.redirectFooterLabel)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Theme.color.brandPrimary.color)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        // 44pt-class target via PADDING (R33.5).
                        .padding(.vertical, Theme.space.s4)
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("panic.flow.redirect.support")
                .padding(.top, Theme.space.s2)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Step 5 · exit states

private struct ExitsView: View {
    let model: PanicFlowModel

    /// D13: the decorative exit glyph scales with Dynamic Type (AgeGateView pattern).
    @ScaledMetric(relativeTo: .largeTitle) private var glyphSize: CGFloat = Theme.type.screenGlyphBase

    var body: some View {
        VStack(spacing: Theme.space.s4) {
            Spacer()
            Image(systemName: "wind")
                .font(.system(size: min(glyphSize, Theme.type.screenGlyphCap), weight: .light))
                .foregroundStyle(Theme.color.brandPrimary.color)
                .accessibilityHidden(true)
            Spacer()
            Button {
                model.exitUrgePassed()
            } label: {
                Text(model.exitLabel("averted") ?? "")
                    .font(.body.weight(.semibold))
                    // R33.5: 56pt target via padding, so the filled pill grows with text.
                    .padding(.vertical, Theme.space.s5)
                    .frame(maxWidth: .infinity)
            }
            // D2: the brandkit §6.1 primary pill via the primitive — the style owns
            // the capsule, fill, ink, and pressed feedback (press feedback only;
            // no added decoration or delay on the panic path).
            .buttonStyle(PrimaryButtonStyle())
            .accessibilityIdentifier("panic.flow.exit.averted")
            Button {
                model.exitSlipped()
            } label: {
                Text(model.exitLabel("slipped") ?? "")
                    .font(.body)
                    .foregroundStyle(Theme.color.contentSecondary.color)
                    // R33.5: 56pt target via padding, never a minHeight floor.
                    .padding(.vertical, Theme.space.s5)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("panic.flow.exit.slipped")
        }
        .padding(Theme.space.s5)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("panic.flow.step.exits")
    }
}

/// The quiet celebration: the averted confirmation copy and one soft haptic already
/// played by the model — a stat's worth of acknowledgment, never confetti.
private struct CelebrationView: View {
    let model: PanicFlowModel

    /// D13: scales with Dynamic Type; base keeps the shipped 64pt, same 72pt cap.
    @ScaledMetric(relativeTo: .largeTitle) private var glyphSize: CGFloat = 64

    var body: some View {
        VStack(spacing: Theme.space.s5) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: min(glyphSize, Theme.type.screenGlyphCap), weight: .light))
                .foregroundStyle(Theme.color.brandPrimary.color)
                .accessibilityHidden(true)
            Text(model.script.exit("averted")?.confirmation ?? "")
                .font(.title2.weight(.semibold))
                .foregroundStyle(Theme.color.contentPrimary.color) // D11
                .multilineTextAlignment(.center)
                .accessibilityIdentifier("panic.flow.celebration.copy") // real element for the smoke
        }
        .padding(Theme.space.s6)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("panic.flow.celebration")
    }
}

