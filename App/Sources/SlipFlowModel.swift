import Foundation
import Observation
import StreakEngine

/// The route a slip flow runs on — the ONE structural difference E4.1's design record
/// allows between the two halves: WHERE the write lands. The cold panic route writes
/// the §9-rule-2 buffer (the store may never open there — spy-pinned); the normal
/// route writes the store synchronously through the repository (§9 rule 1).
enum SlipRoute {
    /// The panic flow's slipped exit (E3.2's `PanicSlipHandoff` seam). Store-free by
    /// contract: the card + buffer + witness store are everything the flow may touch.
    case cold(
        handoff: PanicSlipHandoff,
        card: QuitSnapshot?,
        buffer: PanicOutcomeBuffer?,
        witnessStore: LastKnownGoodStore?
    )
    /// The dashboard half: store-backed, synchronous `logSlip`, reflection note,
    /// engine-gated undo.
    case store(repository: QuitRepository, quitID: UUID)
}

/// The forgiveness screen's numbers, route-independent. On the cold route these come
/// from the pre-cache card's additive fields + pure engine math (momentum UNCHANGED
/// across a slip — ratified S04; best' = max(cached best, guarded ended)); on the
/// store route from the freshly persisted transition.
struct SlipFraming: Equatable, Sendable {
    /// The archived (just-ended) streak, guarded seconds.
    var endedStreakSeconds: Int
    /// Post-slip best — "Your best — X — is safe". 0 ⇒ the no-best copy variant.
    var bestStreakSeconds: Int
    /// Momentum %, unchanged in the same tick across the slip. `nil` = unknown
    /// (degraded pre-E4.1 cache) ⇒ the copy degrades, it never invents a number.
    var momentumPercent: Int?
    /// The user's first motivation, verbatim, for `motivationEcho`. Never generated.
    var motivation: String?
}

/// E4.1 — the two-tap slip flow (mvp feature #3: ≤2 taps, archive-to-best, momentum
/// preserved, optional reflection note, 10-minute undo, zero shame copy). One model
/// serves both routes; every behavior difference is the `SlipRoute` write target.
///
/// Red-commit surface: stages + API are final, behavior lands with the green commit.
@MainActor
@Observable
final class SlipFlowModel {
    enum Stage: Equatable {
        /// Tap 1 landed here; tap 2 ("Log it") is the write.
        case confirming
        /// The forgiveness screen: framing + calm undo banner.
        case logged
        /// The undo completed; the streak is right where it was.
        case undone
    }

    /// Keystroke-pause debounce for the reflection-note autosave (store route only).
    static let noteAutosaveDebounce: Duration = .milliseconds(800)

    let route: SlipRoute
    let copy: SlipCopy

    private let clock: any ClockProviding
    private let noteDebounceSleep: @Sendable (Duration) async -> Void
    private var pendingNoteSave: Task<Void, Never>?

    private(set) var stage: Stage = .confirming
    /// The forgiveness numbers; non-nil exactly from `.logged` on.
    private(set) var framing: SlipFraming?
    /// True after a failed durable write: the confirm stage stays, with the calm
    /// retry note — "Logged." is never claimed without durable bytes (§9 rule 1).
    private(set) var retryNoteVisible = false
    /// Store route: the persisted Slip row's id. Cold route: the buffered draft's id.
    private(set) var loggedSlipID: UUID?

    init(
        route: SlipRoute,
        copy: SlipCopy,
        clock: any ClockProviding,
        noteDebounceSleep: @escaping @Sendable (Duration) async -> Void = { try? await Task.sleep(for: $0) }
    ) {
        self.route = route
        self.copy = copy
        self.clock = clock
        self.noteDebounceSleep = noteDebounceSleep
    }

    /// Reflection notes exist ONLY where the store backs the flow (§10: notes never
    /// touch any App Group file — the cold route simply has no note field).
    var supportsReflectionNote: Bool {
        if case .store = route { return true }
        return false
    }

    /// Whether the quit is discreet (strings carry zero habit context).
    var discreet: Bool {
        if case .cold(_, let card, _, _) = route { return card?.discreet == true }
        return false
    }

    /// Tap 2 — the write. Durable-first: bytes land (buffer append + fsync on the
    /// cold route; synchronous store save on the normal route) BEFORE the stage
    /// advances to the forgiveness screen.
    func confirm() {
    }

    /// "Not now" — leaves without writing anything; the host dismisses on `true`.
    func cancel() -> Bool {
        stage == .confirming
    }

    /// The undo tap. Within the live window: cold = append a revocation record
    /// (the pair never reaches the store); store = engine-gated exact restore.
    /// Past the window: a calm no-op — the banner lied at most one render.
    func undo() {
    }

    /// The live banner gate (attack-verified: the persisted flag alone may lie when
    /// the app stays foregrounded past the window). Views feed TimelineView dates —
    /// production code never reads `Date()`.
    func undoAvailable(at date: Date) -> Bool {
        false
    }

    /// Reflection-note keystroke: schedules the debounced autosave (store route only).
    func noteChanged(_ text: String) {
    }

    /// Test hook: awaits the pending debounced note save, if any.
    func drainPendingNoteSave() async {
        await pendingNoteSave?.value
    }
}
