import Foundation
import StreakEngine

/// P2 (redesign §6.17) — the plain-value inputs `StreakDetailView` renders.
/// A value type (never the SwiftData `@Model` `Quit`) so the screen is
/// trivially fixture-able in the snapshot lane without a store — the
/// `StreakCardModel` discipline, extended to Level 2 of the IA.
struct StreakDetailModel: Equatable, Sendable {
    /// Screen title: the quit's display label ("Tracked goal" when discreet —
    /// the caller resolves through `StreakDetailCopy`).
    let title: String
    /// ADR-11 calendar day (the card's exact same derivation — the two
    /// surfaces can never disagree).
    let dayNumber: Int
    let moneySaved: Decimal
    let currencyCode: String
    let momentumFraction: Double
    /// Total averted urges for this quit (`Quit.avertedUrgeCount`); the stat
    /// line hides below 1.
    let avertedUrgeCount: Int
    let isDiscreet: Bool
    let isFrozen: Bool
    let isReduceMode: Bool
    /// The full milestone ladder, every state explicit — no missed states
    /// exist by construction.
    let milestones: [MilestoneRowModel]
    /// Slip reflections, newest first (empty = section hidden). Discreet
    /// renders none (numbers-only posture — §6.17).
    let notes: [ReflectionNote]
}

/// One rung of the milestone timeline.
struct MilestoneRowModel: Equatable, Sendable, Identifiable {
    enum State: Equatable, Sendable {
        case unlocked
        /// The single next rung, with progress toward it (0...1).
        case next(progress: Double)
        case locked
    }

    /// `afterHours` is unique per ladder (ascending), so it is the identity.
    var id: Int { afterHours }
    let afterHours: Int
    let title: String
    let body: String
    let state: State
}

/// One private reflection note (slip note, on-device only — §10).
struct ReflectionNote: Equatable, Sendable, Identifiable {
    let id: UUID
    let at: Date
    let text: String
}

/// Pure display derivations for Streak Detail — separated from the view so the
/// unit lane can pin them (the `DashboardCardComposer` discipline). Nothing
/// reads an ambient clock or a store.
enum StreakDetailComposer {
    /// The full ladder as explicit row states. Boundary-inclusive unlock
    /// (a rung you are exactly AT is earned — StreakEngine ratified
    /// semantics); exactly one `.next` rung (the first not-yet-earned), with
    /// progress measured the way the dashboard bar measures it; everything
    /// beyond is `.locked`. Never a "missed" state — the concept is
    /// unrepresentable.
    static func milestoneRows(
        elapsedSeconds: Int,
        milestones: [Milestone]
    ) -> [MilestoneRowModel] {
        let ordered = milestones.sorted { $0.afterHours < $1.afterHours }
        let elapsed = max(0, elapsedSeconds)
        var sawNext = false
        return ordered.map { milestone in
            let boundary = milestone.afterHours * 3_600
            let state: MilestoneRowModel.State
            if elapsed >= boundary {
                state = .unlocked
            } else if !sawNext {
                sawNext = true
                state = .next(
                    progress: boundary > 0
                        ? min(1.0, Double(elapsed) / Double(boundary))
                        : 1.0
                )
            } else {
                state = .locked
            }
            return MilestoneRowModel(
                afterHours: milestone.afterHours,
                title: milestone.title,
                body: milestone.body,
                state: state
            )
        }
    }

    /// ME-3 (S51) — the unlock MOMENT's derivation, over `milestoneRows` above so
    /// boundary arithmetic lives in exactly one place.
    ///
    /// Returns the **highest** rung that is both `.unlocked` and unseen, plus every
    /// unlocked rung's `afterHours` for the caller to stamp. Highest, not lowest, and
    /// the reason is a real first-run shape rather than a preference: the quiz asks
    /// when the user stopped, so "I quit five days ago" backdates `startAt` and lands
    /// them past several rungs at once. Lowest-first would greet that user with "First
    /// stretch done" — twelve hours, days behind where they are — and then hand them
    /// one stale card per visit until the backlog drained. Highest-with-catch-up shows
    /// the rung they are standing on and retires the rest silently.
    ///
    /// `nil` means nothing to celebrate: no rung crossed, or every crossed rung
    /// already shown. The common steady-state case (one rung crossed since the last
    /// visit) makes highest and lowest identical, so this costs nothing there.
    static func newlyUnlockedMilestone(
        elapsedSeconds: Int,
        milestones: [Milestone],
        seenHours: [Int]
    ) -> (row: MilestoneRowModel, hoursToStamp: [Int])? {
        let seen = Set(seenHours)
        let unlocked = milestoneRows(elapsedSeconds: elapsedSeconds, milestones: milestones)
            .filter { $0.state == .unlocked }
        // `milestoneRows` returns ascending order, so `last` IS the highest rung.
        guard let highestUnseen = unlocked.last(where: { !seen.contains($0.afterHours) })
        else { return nil }
        return (highestUnseen, unlocked.map(\.afterHours))
    }

    /// A rung's boundary as a locale-formatted duration — DATA, not copy
    /// ("2 weeks", "12 hours"); composed after the DRAFT "Unlocks at" prefix.
    /// One unit, full style: anticipation reads calm, never clinical.
    static func durationText(afterHours: Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.year, .month, .weekOfMonth, .day, .hour]
        formatter.maximumUnitCount = 1
        return formatter.string(from: TimeInterval(afterHours) * 3_600)
            ?? "\(afterHours) h"
    }
}
