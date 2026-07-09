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
        // red skeleton: entering .breath neither records the step nor starts the pacer
    }

    /// The pacer pattern from the shipping script (4-7-8 × 3).
    var pacerPattern: BreathPacerPattern? {
        script.step(.breath)?.pacer.map(BreathPacerPattern.init(pacer:))
    }

    /// The reasons step's render source: the user's own words, VERBATIM, user order.
    var reasons: [String] {
        ["red-skeleton"] // red skeleton — must be the quit card's motivations, unedited
    }

    /// Advances one stage (every step is skippable, PRD §6.4).
    func skip() {
        // red skeleton
    }

    /// A redirect-menu choice: "breathe" re-enters the pacer, everything else has
    /// served its purpose and lands on the exits.
    func selectRedirect(_ optionID: String) {
        // red skeleton
    }

    /// "Urge passed" — buffers the averted outcome (§9 rule 2) and celebrates quietly.
    func exitUrgePassed() {
        // red skeleton
    }

    /// "I slipped" — the named routing seam. Zero writes from the panic scene.
    func exitSlipped() {
        // red skeleton
    }
}
