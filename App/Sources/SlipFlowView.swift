import SwiftUI

/// E4.1 — the two-tap slip flow's UI (mvp feature #3). One view renders a
/// `SlipFlowModel` on either route (`.cold` / `.store`); every behavior difference is
/// the model's write target, so the chrome here is route-independent. Brand hard rules
/// hold throughout: NO red anywhere, the slip motion is motion/standard 300ms spring
/// ("procedurally identical to any other log" — NEVER the panic 600ms calm), the undo
/// banner is NEUTRAL (secondary background, never amber/red), the slip glyph is
/// `arrow.uturn.backward.circle`, 56pt targets, the motivation echo is SF Pro (never
/// Rounded — it is the user's own word, not a hero stat). Identifiers land on REAL
/// elements (buttons, static texts — the `panic.flow.celebration.copy` precedent), never
/// on bare `.contain` containers (the Session 09 XCUITest lesson).
///
/// House-style mirror of `PanicFlowView`: `buttonStyle(.plain)`, teal-filled primary
/// action with dark-mode-aware contrast, identifiers on the text/buttons the UI-smoke
/// asserts on.
struct SlipFlowView: View {
    @State private var model: SlipFlowModel
    /// Phase-zero latch (the `BreathBloom.startedAt == nil` precedent): flips true only
    /// from `.task`, which does NOT run during a synchronous snapshot capture, so the
    /// undo banner renders deterministically (unconditionally live) at the frozen date
    /// while production still live-gates it once ticking begins.
    @State private var started = false
    @State private var noteText = ""
    /// E9.1 (R27.11) — the logged stage's one-tap support hand-off. An INTERNAL
    /// sheet, not a host callback: SlipFlowView has two hosts and the cold one
    /// (PanicFlowView) must stay thin — the resources screen is store-free by
    /// construction, so BOTH routes mount it unchanged.
    @State private var showsResources = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Injected only to anchor the undo banner's `TimelineView` schedule (the sanctioned
    /// view-side time source; production code never reads `Date()` directly). The gate
    /// itself is the model's `undoAvailable(at:)` over the timeline's dates.
    private let clock: any ClockProviding
    private let onDismiss: () -> Void

    @MainActor
    init(model: SlipFlowModel, clock: any ClockProviding, onDismiss: @escaping () -> Void = {}) {
        _model = State(initialValue: model)
        self.clock = clock
        self.onDismiss = onDismiss
    }

    var body: some View {
        content
            .themedScreenSurface() // UIR-0: surface/base behind every slip stage
            // Motion/standard 300ms spring — a slip is procedurally identical to any
            // other log; it never borrows the panic flow's 600ms calm fade.
            .animation(
                reduceMotion ? .easeInOut(duration: 0.2) : .spring(response: 0.3, dampingFraction: 0.85),
                value: model.stage
            )
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("slip.flow")
            .sheet(isPresented: $showsResources) {
                // Source `.slipFlow` (the closed-domain wire value). The service is
                // route-honest: the store route vends the repository's live gate;
                // the cold route constructs NO analytics (the panic-descended
                // surface stays fire-free — ADR-6 thinness, recorded R27.11) and
                // the screen degrades to the disabled no-op service.
                SafetyResourcesView(source: .slipFlow, analytics: slipRouteAnalytics)
            }
    }

    /// The slip-flow mount's analytics seam (R27.11): live on the store route,
    /// disabled on the cold route — the cold contract is card+buffer+witness ONLY.
    private var slipRouteAnalytics: AnalyticsService {
        if case let .store(repository, _) = model.route {
            return repository.analyticsService
        }
        return .disabled
    }

    @ViewBuilder
    private var content: some View {
        switch model.stage {
        case .confirming: confirmStage
        case .logged: loggedStage
        case .undone: undoneStage
        }
    }

    // MARK: - Slip glyph (shared)

    private var slipGlyph: some View {
        Image(systemName: "arrow.uturn.backward.circle")
            .font(.system(size: 56, weight: .light))
            .foregroundStyle(Theme.color.brandPrimary.color)
            .accessibilityHidden(true)
    }

    // MARK: - Stage 1 · confirm ("Log a slip?")

    private var confirmStage: some View {
        VStack(spacing: 24) {
            Spacer()
            slipGlyph
            VStack(spacing: 12) {
                Text(model.copy.confirm.title)
                    .font(.title.weight(.semibold))
                    .multilineTextAlignment(.center)
                Text(model.copy.confirm.body)
                    .font(.body)
                    .foregroundStyle(Theme.color.contentSecondary.color)
                    .multilineTextAlignment(.center)
            }
            // Shown ONLY after a failed durable write — calm, neutral, retryable
            // (§9 rule 1: "Logged." is never claimed without durable bytes). Never red.
            if model.retryNoteVisible, let retryNote = model.copy.confirm.retryNote {
                Text(retryNote)
                    .font(.footnote)
                    .foregroundStyle(Theme.color.contentSecondary.color)
                    .multilineTextAlignment(.center)
                    .accessibilityIdentifier("slip.flow.confirm.retryNote")
            }
            Spacer()
            VStack(spacing: 12) {
                Button {
                    model.confirm()
                } label: {
                    Text(model.copy.confirm.confirmLabel)
                        .font(.body.weight(.semibold))
                        // brand/onPrimary is scheme-aware by construction (the old
                        // manual dark-ternary retires; 6.0:1 L / 7.0:1 D, pinned).
                        .foregroundStyle(Theme.color.brandOnPrimary.color)
                        .frame(maxWidth: .infinity, minHeight: 56) // touch.panic
                        .background(Theme.color.brandPrimary.color, in: RoundedRectangle(cornerRadius: 16))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("slip.flow.confirm.log")

                Button {
                    if model.cancel() { onDismiss() }
                } label: {
                    Text(model.copy.confirm.cancelLabel)
                        .font(.body)
                        .foregroundStyle(Theme.color.contentSecondary.color)
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("slip.flow.confirm.cancel")
            }
        }
        .padding(24)
    }

    // MARK: - Stage 2 · logged (the forgiveness screen)

    private var loggedStage: some View {
        ScrollView {
            VStack(spacing: 20) {
                slipGlyph
                // Real text element (the celebration.copy precedent) — the UI-smoke's
                // "Logged." proof.
                Text(model.copy.logged.title)
                    .font(.title.weight(.semibold))
                    .multilineTextAlignment(.center)
                    // R28.13 (runs 29262073722+29265224603, the audit's ONE
                    // not-human-readable node both times): the terse word+period
                    // title ("Logged.") classifies as non-natural speech; VO
                    // speaks the same word without the typographic period —
                    // MECHANICALLY derived from the visible copy (never new
                    // authored copy; bare words pass the classifier empirically:
                    // "Undo", "Skip breathing"). Metadata only — pixels hold.
                    .accessibilityLabel(
                        model.copy.logged.title.trimmingCharacters(in: CharacterSet(charactersIn: ".!?"))
                    )
                    .accessibilityIdentifier("slip.flow.logged")

                Text(loggedBody)
                    .font(.body)
                    .foregroundStyle(Theme.color.contentSecondary.color)
                    .multilineTextAlignment(.center)

                // E9.1 (R27.11) — the calm post-log support offer (mvp feature 11:
                // resources one tap from every slip flow). Placed right after the
                // fact statement, never on the confirm prompt (Brand binding — an
                // offer at the point of confirming a slip could read as judgment).
                if let resources = model.copy.resources {
                    Button {
                        showsResources = true
                    } label: {
                        Label(resources.linkLabel, systemImage: "lifepreserver")
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(Theme.color.brandPrimary.color)
                            .frame(minHeight: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("slip.resources.link")
                }

                // The motivation echo — the user's OWN word, verbatim, in SF Pro (never
                // the Rounded hero face). Hidden entirely when there is no motivation.
                if let motivation = model.framing?.motivation, !motivation.isEmpty {
                    Text(motivationEcho(motivation))
                        .font(.system(.callout, design: .default))
                        .foregroundStyle(Theme.color.contentPrimary.color)
                        .multilineTextAlignment(.center)
                }

                if let encouragement = model.copy.encouragement.first {
                    Text(encouragement)
                        .font(.footnote)
                        .foregroundStyle(Theme.color.contentSecondary.color)
                        .multilineTextAlignment(.center)
                }

                // Reflection note lives ONLY where the store backs the flow (§10).
                if model.supportsReflectionNote {
                    reflectionField
                }

                undoBanner
            }
            .padding(24)
        }
    }

    /// The NEUTRAL undo banner, live-gated by the model's window check over the
    /// timeline's dates. Past the window the banner simply disappears (a calm no-op).
    /// At phase zero (`started == false`: the first production frame and every snapshot
    /// capture) it renders unconditionally — the window is definitionally open the
    /// instant a slip is logged, which is also what makes the golden deterministic.
    private var undoBanner: some View {
        TimelineView(.periodic(from: clock.now, by: 1)) { context in
            let live = started ? model.undoAvailable(at: context.date) : true
            if live {
                VStack(spacing: 12) {
                    // Identifier on a real text element (never the container) — the
                    // banner "hosts" the undo button as a sibling.
                    Text(model.copy.undo.banner)
                        .font(.subheadline.weight(.medium))
                        .multilineTextAlignment(.center)
                        .accessibilityIdentifier("slip.flow.undoBanner")

                    Button {
                        model.undo()
                    } label: {
                        Label(model.copy.undo.undoLabel, systemImage: "arrow.uturn.backward.circle")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Theme.color.brandPrimary.color)
                            .frame(maxWidth: .infinity, minHeight: 56) // touch.panic
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    // Undo is time-limited — voice the window as a HINT on focus (the
                    // Label text stays the a11y label); the note is the same one below.
                    .accessibilityHint(model.copy.undo.windowNote)
                    .accessibilityIdentifier("slip.flow.undo")

                    Text(model.copy.undo.windowNote)
                        .font(.footnote)
                        .foregroundStyle(Theme.color.contentSecondary.color)
                        .multilineTextAlignment(.center)
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                // NEUTRAL — sunken surface fill, never amber/red.
                .background(
                    Theme.color.surfaceSunken.color,
                    in: RoundedRectangle(cornerRadius: 16)
                )
            }
        }
        .task { started = true }
    }

    private var reflectionField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(model.copy.reflection.prompt)
                .font(.footnote)
                .foregroundStyle(Theme.color.contentSecondary.color)
            TextField(model.copy.reflection.placeholder, text: $noteText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...4)
                .onChange(of: noteText) { _, newValue in
                    model.noteChanged(newValue)
                }
                // The visible prompt above is the field's name for VoiceOver.
                .accessibilityLabel(model.copy.reflection.prompt)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Stage 3 · undone

    private var undoneStage: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(Theme.color.brandPrimary.color)
                .accessibilityHidden(true)
            Text(model.copy.undo.undoneConfirmation)
                .font(.title2.weight(.semibold))
                .multilineTextAlignment(.center)
                .accessibilityIdentifier("slip.flow.undone")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Copy substitution

    /// The forgiveness body: `logged.body` (with the archived best) or `logged.bodyNoBest`
    /// (best == 0). Substitutes only the sanctioned tokens through the sentence-drop
    /// composition (R28.13) — a nil momentum drops its whole sentence, never a dangling
    /// "momentum is still ." (the run-29262073722 audit's not-human-readable finding);
    /// the copy still never invents a number.
    private var loggedBody: String {
        guard let framing = model.framing else { return "" }
        let template = framing.bestStreakSeconds == 0 ? model.copy.logged.bodyNoBest : model.copy.logged.body
        return SlipLoggedComposition.composed(template, values: [
            "bestStreak": humanDuration(framing.bestStreakSeconds),
            "momentum": framing.momentumPercent.map { "\($0)%" },
        ])
    }

    private func motivationEcho(_ motivation: String) -> String {
        model.copy.motivationEcho.replacingOccurrences(of: "{{motivation}}", with: motivation)
    }

    /// A plain, locale-stable humanization of an archived streak for the `{{bestStreak}}`
    /// token (the dashboard's rich streak formatting arrives with its own epic). Pure —
    /// deterministic for the goldens.
    private func humanDuration(_ seconds: Int) -> String {
        let days = seconds / 86_400
        if days >= 1 { return "\(days) day\(days == 1 ? "" : "s")" }
        let hours = seconds / 3_600
        if hours >= 1 { return "\(hours) hour\(hours == 1 ? "" : "s")" }
        let minutes = seconds / 60
        if minutes >= 1 { return "\(minutes) minute\(minutes == 1 ? "" : "s")" }
        return "\(seconds) second\(seconds == 1 ? "" : "s")"
    }
}

/// The §9 honest-degrade fallback copy: the plainest functional labels only, used when
/// `slipCopy.json` is missing or undecodable (a slip is a zero-lost-data surface — the
/// flow still works, it just carries no crafted product copy). NEVER invented product
/// copy beyond these plainest labels.
extension SlipCopy {
    static let degraded = SlipCopy(
        confirm: .init(
            title: "Log a slip?",
            body: "",
            confirmLabel: "Log it",
            cancelLabel: "Not now",
            retryNote: "That didn't save yet — nothing's lost. Tap Log it to try again."
        ),
        logged: .init(title: "Logged.", body: "", bodyNoBest: ""),
        reflection: .init(prompt: "", placeholder: "", skipLabel: "Skip", saveLabel: "Save"),
        undo: .init(banner: "Undo?", undoLabel: "Undo", windowNote: "", undoneConfirmation: "Undone."),
        encouragement: [],
        motivationEcho: "",
        dashboard: .degraded,
        // No invented copy on the degraded path: the support link simply does not
        // render (the section is the decode-tolerant optional; E9.1/R27.11).
        resources: nil
    )
}

extension SlipCopy.Dashboard {
    /// The dashboard surface's honest-degrade labels (same discipline as above): the
    /// plainest functional strings, kept total so the pending-undo banner and the
    /// discreet row never render blank when the shipping table is missing its section.
    static let degraded = SlipCopy.Dashboard(
        pendingBanner: "Undo?",
        undoLabel: "Undo",
        discreetRowLabel: "Tracked goal"
    )
}

/// R28.13 — token substitution with the no-dangling-clause rule: a template
/// SENTENCE containing a token whose value is nil is dropped WHOLE (the copy
/// never invents a number AND never renders a dangling "…momentum is still ." —
/// the run-29262073722 audit's not-human-readable finding on the forgiveness
/// screen). Sentences keep their own leading whitespace, so a fully-filled
/// template reproduces the pre-R28.13 output BYTE-FOR-BYTE (harness-pinned —
/// every non-degraded golden holds); only a dropped first sentence needs the
/// final edge-trim. Pure Foundation — Linux-harness runnable over the exact
/// shipping templates.
enum SlipLoggedComposition {
    static func composed(_ template: String, values: [String: String?]) -> String {
        var sentences: [String] = []
        var current = ""
        for character in template {
            current.append(character)
            if character == "." || character == "!" || character == "?" {
                sentences.append(current)
                current = ""
            }
        }
        if !current.isEmpty { sentences.append(current) }

        var output = ""
        for sentence in sentences {
            let hasUnfilledToken = values.contains { key, value in
                value == nil && sentence.contains("{{\(key)}}")
            }
            if hasUnfilledToken { continue }
            var filled = sentence
            for (key, value) in values {
                if let value {
                    filled = filled.replacingOccurrences(of: "{{\(key)}}", with: value)
                }
            }
            output += filled
        }
        return output.trimmingCharacters(in: .whitespaces)
    }
}
