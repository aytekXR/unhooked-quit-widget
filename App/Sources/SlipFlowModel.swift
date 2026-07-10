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

    /// The slip-instant clock anchor, captured at `confirm` (the flow clock's reading at
    /// the moment the write landed). The live undo gate measures elapsed-since-slip from
    /// THIS — never the persisted flag alone, which can lie when the app stays
    /// foregrounded past the window. `nil` until a durable slip lands (no slip ⇒ no undo).
    private var slipAnchor: MonotonicAnchor?

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
        guard stage == .confirming else { return }
        let now = clock.now
        let reading = clock.monotonicNow

        switch route {
        case let .cold(handoff, card, buffer, witnessStore):
            // Forgiveness framing FIRST, from the pre-cache card's additive fields via pure
            // engine math (momentum UNCHANGED across a slip — ratified S04). It is computed
            // but held back: "Logged." is never claimed without durable bytes (§9 rule 1),
            // so nothing is published until the ONE cold write succeeds.
            let framed = coldFraming(
                card: card, buffer: buffer, quitID: handoff.quitID, now: now, reading: reading
            )
            // THE ONE COLD WRITE: the slip-time evidence tuple rides the draft — the live
            // monotonic reading AND the App Group witness AT SLIP TIME [R-WIT], read
            // store-free (a nil witness captures nil, matching a live `logSlip` with
            // lastKnownGood nil — no invented baseline). No panic-snapshot rewrite: the
            // cold slip flow writes ONLY the buffer file (single-writer pin; the ADR-6
            // dual-writer hazard removed).
            let witness = witnessStore?.load()
            let draft = PanicOutcomeDraft(
                quitID: handoff.quitID,
                source: handoff.source,
                outcome: .slipped,
                stepsReached: handoff.stepsReached,
                at: now,
                capturedUptime: reading.uptime,
                capturedBootID: reading.bootID,
                capturedWitnessBootID: witness?.bootID,
                capturedWitnessUptime: witness?.uptime,
                capturedWitnessWallClock: witness?.wallClock,
                revokesDraftID: nil
            )
            guard appendWithRetry(draft, to: buffer) else {
                // A failed durable append keeps the confirm stage with the calm retry note
                // (§9 rule 1) — no framing, no stage advance, no undo anchor.
                retryNoteVisible = true
                return
            }
            loggedSlipID = draft.id
            slipAnchor = MonotonicAnchor(bootID: reading.bootID, uptime: reading.uptime, wallClock: now)
            framing = framed
            stage = .logged

        case let .store(repository, quitID):
            // Synchronous local slip log: the row is persisted BEFORE the stage advances
            // (§9 rule 1). A throw keeps the confirm stage with the calm retry note.
            guard let slip = try? repository.logSlip(quitID: quitID, note: nil) else {
                retryNoteVisible = true
                return
            }
            loggedSlipID = slip.id
            // Framing from the freshly persisted transition: the archived streak and the
            // quit's post-slip best, read honestly off the slip's own relationship.
            framing = SlipFraming(
                endedStreakSeconds: slip.streakSecondsAtSlip,
                bestStreakSeconds: slip.quit?.bestStreakSeconds ?? slip.streakSecondsAtSlip,
                momentumPercent: nil,
                motivation: nil
            )
            slipAnchor = MonotonicAnchor(bootID: reading.bootID, uptime: reading.uptime, wallClock: now)
            stage = .logged
        }
    }

    /// "Not now" — leaves without writing anything; the host dismisses on `true`.
    func cancel() -> Bool {
        stage == .confirming
    }

    /// The undo tap. Within the live window: cold = append a revocation record
    /// (the pair never reaches the store); store = engine-gated exact restore.
    /// Past the window: a calm no-op — the banner lied at most one render.
    func undo() {
        // The live gate, not the persisted flag: past the window undo is a calm no-op
        // (stage STAYS .logged, zero writes) — never an error.
        guard undoAvailable(at: clock.now), let loggedSlipID else { return }
        let now = clock.now
        let reading = clock.monotonicNow

        switch route {
        case let .cold(handoff, _, buffer, witnessStore):
            // A REVOCATION draft — same Codable type as an ordinary slip (the torn-tail
            // reader would drop a sibling type), naming the just-logged draft. The revoked
            // pair never reaches the store (§9 rule 3 governs store rows; none exists yet).
            let witness = witnessStore?.load()
            let revocation = PanicOutcomeDraft(
                quitID: handoff.quitID,
                source: handoff.source,
                outcome: .slipped,
                stepsReached: handoff.stepsReached,
                at: now,
                capturedUptime: reading.uptime,
                capturedBootID: reading.bootID,
                capturedWitnessBootID: witness?.bootID,
                capturedWitnessUptime: witness?.uptime,
                capturedWitnessWallClock: witness?.wallClock,
                revokesDraftID: loggedSlipID
            )
            if appendWithRetry(revocation, to: buffer) {
                stage = .undone
            }

        case let .store(repository, _):
            // Engine-gated exact restore: a completed undo DELETES the Slip row (it must
            // not count against a Reduce allowance or future insights). `false` = the tap
            // raced the finalize sweep — a calm no-op, never an error.
            if (try? repository.undoSlip(slipID: loggedSlipID)) == true {
                stage = .undone
            }
        }
    }

    /// The live banner gate (attack-verified: the persisted flag alone may lie when
    /// the app stays foregrounded past the window). Views feed TimelineView dates —
    /// production code never reads `Date()`.
    func undoAvailable(at date: Date) -> Bool {
        // No slip yet ⇒ nothing to undo. Otherwise: guarded elapsed since the slip-instant
        // anchor, measured with the clock's CURRENT monotonic reading and lastKnownGood
        // nil (window measurements pass nil everywhere — a rolled-back wall cannot re-open
        // a closed window; H11 killed). Boundary-inclusive at `undoWindowSeconds`.
        guard let slipAnchor else { return false }
        let elapsed = StreakCalculator.conservativeElapsedSeconds(
            anchor: slipAnchor, now: date, monotonic: clock.monotonicNow, lastKnownGood: nil
        )
        return elapsed <= StreakCalculator.undoWindowSeconds
    }

    /// Reflection-note keystroke: schedules the debounced autosave (store route only).
    func noteChanged(_ text: String) {
        // §10: notes live ONLY in the store — no-op on the cold route (which has no note
        // field) and before a slip is logged (nothing to attach to).
        guard case let .store(repository, _) = route, let slipID = loggedSlipID else { return }
        // Cancel any prior scheduled save, then schedule this keystroke's: only the quiet
        // tail after the keystroke pause reaches the repository (test-suite §7.7 — the
        // drain, not a wall clock, gates the save).
        pendingNoteSave?.cancel()
        let debounce = noteDebounceSleep
        pendingNoteSave = Task { @MainActor in
            await debounce(Self.noteAutosaveDebounce)
            guard !Task.isCancelled else { return }
            try? repository.updateSlipNote(slipID: slipID, note: text)
        }
    }

    /// Test hook: awaits the pending debounced note save, if any.
    func drainPendingNoteSave() async {
        await pendingNoteSave?.value
    }

    // MARK: - Cold-route helpers

    /// One retry on a durable append — a transient file-system hiccup must not cost the
    /// slip (the `PanicFlowModel.record` precedent). A `nil`/absent buffer or a double
    /// failure returns false: the caller keeps the confirm stage with the retry note.
    private func appendWithRetry(_ draft: PanicOutcomeDraft, to buffer: PanicOutcomeBuffer?) -> Bool {
        guard let buffer else { return false }
        if (try? buffer.append(draft)) != nil { return true }
        return (try? buffer.append(draft)) != nil
    }

    /// The forgiveness numbers on the cold route, from the pre-cache card's additive
    /// fields via pure engine math. `ended` = guarded elapsed from the card anchor at the
    /// flow clock; `best' = max(card best, ended)`; momentum is the card's value UNCHANGED
    /// (ratified S04); the motivation echo is the user's FIRST motivation, verbatim.
    ///
    /// DELIBERATE DEVIATION R-RMW: repeat cold slips are NOT rewritten to
    /// panic-snapshot.json (no second store-truth writer). Display honesty for repeat cold
    /// slips comes instead from FOLDING earlier unrevoked `.slipped` drafts already in the
    /// buffer for the same quit, in memory, in append order — chaining `applySlip` over the
    /// card-derived snapshot before framing the current slip.
    ///
    /// A degraded pre-E4.1 card (nil startAt/anchor/best) frames to zeros + nil momentum —
    /// it never invents a stale number.
    private func coldFraming(
        card: QuitSnapshot?,
        buffer: PanicOutcomeBuffer?,
        quitID: UUID?,
        now: Date,
        reading: MonotonicNow
    ) -> SlipFraming {
        let motivation = card?.motivations.first
        let momentum = card?.momentumPercent

        guard let card,
              let startAt = card.startAt,
              let bootID = card.anchorBootID,
              let uptime = card.anchorUptime
        else {
            // No honest anchor/start → no elapsed can be computed, and no card best → 0
            // (the no-best copy variant). Numbers are degraded, never fabricated.
            return SlipFraming(
                endedStreakSeconds: 0,
                bestStreakSeconds: card?.bestStreakSeconds ?? 0,
                momentumPercent: momentum,
                motivation: motivation
            )
        }

        // The card-derived snapshot (anchor.wallClock == startAt, the engine's invariant).
        var snapshot = StreakSnapshot(
            startAt: startAt,
            priorCleanSeconds: 0,
            monotonicAnchor: MonotonicAnchor(bootID: bootID, uptime: uptime, wallClock: startAt),
            bestStreakSeconds: card.bestStreakSeconds ?? 0
        )

        // Fold each earlier unrevoked slip with the evidence ITS instant carried.
        for draft in earlierUnrevokedSlips(in: buffer, quitID: quitID) {
            snapshot = StreakCalculator.applySlip(
                to: snapshot,
                at: draft.at,
                monotonic: monotonicReading(of: draft),
                lastKnownGood: witnessAnchor(of: draft)
            )
        }

        // The current slip: one more archive at the flow clock (lastKnownGood nil is fine
        // here — this is display math). `ended` is the bank delta; `best'` the archived max.
        let prior = snapshot
        let final = StreakCalculator.applySlip(to: snapshot, at: now, monotonic: reading, lastKnownGood: nil)
        return SlipFraming(
            endedStreakSeconds: final.priorCleanSeconds - max(0, prior.priorCleanSeconds),
            bestStreakSeconds: final.bestStreakSeconds,
            momentumPercent: momentum,
            motivation: motivation
        )
    }

    /// Earlier `.slipped` drafts for this quit that no later revocation record cancels, in
    /// append order — the fold input for repeat-cold-slip framing.
    private func earlierUnrevokedSlips(in buffer: PanicOutcomeBuffer?, quitID: UUID?) -> [PanicOutcomeDraft] {
        let all = buffer?.drafts() ?? []
        let revoked = Set(all.compactMap { $0.revokesDraftID })
        return all.filter {
            $0.outcome == .slipped
                && $0.revokesDraftID == nil
                && $0.quitID == quitID
                && !revoked.contains($0.id)
        }
    }

    /// The monotonic reading a draft captured AT SLIP TIME, or `nil` when it carried none.
    private func monotonicReading(of draft: PanicOutcomeDraft) -> MonotonicNow? {
        guard let bootID = draft.capturedBootID, let uptime = draft.capturedUptime else { return nil }
        return MonotonicNow(bootID: bootID, uptime: uptime)
    }

    /// The clock witness a draft captured AT SLIP TIME, or `nil` when it carried none.
    private func witnessAnchor(of draft: PanicOutcomeDraft) -> MonotonicAnchor? {
        guard let bootID = draft.capturedWitnessBootID,
              let uptime = draft.capturedWitnessUptime,
              let wallClock = draft.capturedWitnessWallClock
        else { return nil }
        return MonotonicAnchor(bootID: bootID, uptime: uptime, wallClock: wallClock)
    }
}
