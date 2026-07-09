import Foundation
import Observation

/// Everything the panic scene knows at the moment of a slipped exit — the E3.2
/// ROUTING SEAM (resume-prompt §objective 4): E4.1 owns the slip flow and its writes
/// as one unit, so this handoff carries the full context (source + steps) that only
/// the panic flow knows, and the panic scene itself writes NOTHING for a slip.
struct PanicSlipHandoff: Equatable, Sendable {
    var quitID: UUID?
    var source: PanicSource
    var stepsReached: [PanicStep]
}

/// The ~90s skippable panic flow (PRD §6.4), store-free by contract (ADR-6): boots
/// from a `QuitSnapshot` card out of the pre-cache + the bundled script, and records
/// its outcome through the §9-rule-2 write buffer — never the repository. Ephemeral
/// step state is in-memory only (architecture §7).
@MainActor
@Observable
final class PanicFlowModel {
    /// The flow's position. Steps mirror `PanicStep`; `exits` is PRD step 5 (both
    /// exit states), `celebration` the quiet averted confirmation.
    enum Stage: Equatable {
        case breath, timer, reasons, redirect, exits, celebration
    }

    let quit: QuitSnapshot?
    let script: PanicScript
    let source: PanicSource
    /// Haptics-only pacer mode (brandkit §8: first-class eyes-free mode). The
    /// production channel from `AppSettings.hapticOnlyBreathPacer` to a cold panic
    /// launch stays `false` until a settings writer exists (E5+ seam — the store is
    /// off-limits on this path and no writer exists yet, Session 10 design panel).
    let hapticsOnlyPacer: Bool

    private let clock: any ClockProviding
    private let haptics: any HapticsPlaying
    private let buffer: PanicOutcomeBuffer?
    private let onSlipRoute: @MainActor (PanicSlipHandoff) -> Void

    private(set) var stage: Stage = .breath
    /// Steps ENTERED, in order, no duplicates ("order recorded, not enforced" —
    /// the model comment on `PanicStep`); skipped-through steps still count as reached.
    private(set) var stepsReached: [PanicStep] = []
    /// Whether the averted outcome landed durably in the write buffer. The
    /// celebration renders regardless (it confirms the URGE passed — true whatever
    /// the disk did; §9 silent-recover class, same as a pre-cache write failure).
    private(set) var outcomeRecorded = false
    /// The slipped exit's handoff, surfaced as state so the scene can show the
    /// placeholder destination (E4.1 replaces that placeholder, not this seam).
    private(set) var slipHandoff: PanicSlipHandoff?
    /// When the pacer's current run began (the flow clock's domain) — the view's
    /// TimelineView measures elapsed time against this; nil until the first frame's
    /// `.task` marks it, so the initial render is always phase zero.
    private(set) var pacerStartedAt: Date?

    init(
        quit: QuitSnapshot?,
        script: PanicScript,
        source: PanicSource,
        hapticsOnlyPacer: Bool = false,
        clock: any ClockProviding,
        haptics: any HapticsPlaying,
        buffer: PanicOutcomeBuffer?,
        onSlipRoute: @escaping @MainActor (PanicSlipHandoff) -> Void
    ) {
        self.quit = quit
        self.script = script
        self.source = source
        self.hapticsOnlyPacer = hapticsOnlyPacer
        self.clock = clock
        self.haptics = haptics
        self.buffer = buffer
        self.onSlipRoute = onSlipRoute
        enterStep(.breath)
    }

    /// The pacer pattern from the shipping script (4-7-8 × 3).
    var pacerPattern: BreathPacerPattern? {
        script.step(.breath)?.pacer.map(BreathPacerPattern.init(pacer:))
    }

    /// The reasons step's render source: the user's own words, VERBATIM, user order.
    var reasons: [String] {
        quit?.motivations ?? []
    }

    /// The flow's opening title: the discreet variant carries zero habit context.
    var entryTitle: String {
        quit?.discreet == true ? script.entryTitleDiscreet : script.entryTitle
    }

    /// An exit's button label, discreet-aware ("Done" / "Log it").
    func exitLabel(_ id: String) -> String? {
        guard let exit = script.exit(id) else { return nil }
        return quit?.discreet == true ? exit.labelDiscreet : exit.label
    }

    /// Advances one stage (every step is skippable, PRD §6.4).
    func skip() {
        switch stage {
        case .breath: enterStep(.timer)
        case .timer: enterStep(.reasons)
        case .reasons: enterStep(.redirect)
        case .redirect: stage = .exits
        case .exits, .celebration: break
        }
    }

    /// A redirect-menu choice (option ids are the shipping script's contract):
    /// "breathe" re-enters the pacer; everything else has served its purpose —
    /// the user committed to a small physical redirect — and lands on the exits.
    func selectRedirect(_ optionID: String) {
        guard stage == .redirect else { return }
        if optionID == "breathe" {
            enterStep(.breath)
        } else {
            stage = .exits
        }
    }

    /// The pacer run begins when its first frame is actually on screen (the view's
    /// `.task`), so elapsed-time math never counts pre-frame construction time.
    func markPacerStarted() {
        guard pacerStartedAt == nil else { return }
        pacerStartedAt = clock.now
    }

    /// "Urge passed" — buffers the averted outcome (§9 rule 2) and celebrates quietly.
    func exitUrgePassed() {
        guard stage != .celebration else { return }
        let draft = PanicOutcomeDraft(
            quitID: quit?.id,
            source: source,
            outcome: .averted,
            stepsReached: stepsReached,
            at: clock.now
        )
        outcomeRecorded = record(draft)
        haptics.playCelebrationTap()
        stage = .celebration
    }

    /// "I slipped" — the named routing seam. Zero writes from the panic scene:
    /// E4.1 owns the slip flow and its writes (undo lifecycle included) as one unit.
    func exitSlipped() {
        guard stage != .celebration else { return }
        let handoff = PanicSlipHandoff(
            quitID: quit?.id, source: source, stepsReached: stepsReached
        )
        slipHandoff = handoff
        onSlipRoute(handoff)
    }

    // MARK: - Private

    private func enterStep(_ step: PanicStep) {
        if !stepsReached.contains(step) {
            stepsReached.append(step)
        }
        switch step {
        case .breath:
            stage = .breath
            pacerStartedAt = nil // a (re-)entered pacer starts its run fresh
            if let pattern = pacerPattern, script.step(.breath)?.pacer?.hapticGuided == true {
                haptics.playBreathPattern(pattern)
            }
        case .timer: stage = .timer
        case .reasons: stage = .reasons
        case .redirect: stage = .redirect
        }
    }

    /// One retry: a transient file-system hiccup must not cost the outcome. A miss
    /// is the §9 silent-recover class — the celebration still renders (it confirms
    /// the urge passed, not the disk), and `outcomeRecorded` keeps the truth testable.
    private func record(_ draft: PanicOutcomeDraft) -> Bool {
        guard let buffer else { return false }
        if (try? buffer.append(draft)) != nil { return true }
        return (try? buffer.append(draft)) != nil
    }
}
