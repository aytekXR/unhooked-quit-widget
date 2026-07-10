import Foundation
import StreakEngine
import SwiftData

// E2.1 — the single SwiftData store's model graph (architecture §3/§4). Every model
// obeys the CloudKit-mirroring checklist from day one, BEFORE any mirror exists
// (Gate G0 must clear before an iCloud container may even be registered):
//   - no @Attribute(.unique) anywhere — uniqueness is by UUID convention (§4; the
//     dedupe merge pass is E2.3),
//   - every attribute optional or defaulted (a bare init() must produce a valid row),
//   - every relationship optional, inverse declared on exactly one side.
// The checklist is enforced mechanically by PersistenceStoreTests, not by convention.
// No Date()/ProcessInfo reads here (banned in production code): "unset" dates default
// to .distantPast and are stamped by the E2.2 service layer at write time.
// §4 indexes: #Index<Quit>([\.isArchived, \.sortIndex]) landed with E2.2's activeQuits
// query; #Index<Slip>([\.isPendingUndo]) landed with E4.1's undo lifecycle (the
// finalize sweep + banner-source queries justify it). The remaining two stay DEFERRED
// to their justifying queries (green means minimal): #Index<Slip>([\.at]) with the
// first time-ordered slip query (E4/E6), #Index<UrgeEvent>([\.at]) with E12.4's
// on-device insights.

/// Habit category for a tracked goal. String-backed and Codable so SwiftData stores it
/// as a plain encoded value (CloudKit-safe).
enum HabitCategory: String, Codable, Sendable, CaseIterable {
    case vape, porn, alcohol, weed, doomscroll, custom
}

/// Quit vs Reduce goal mode (ADR-10: Reduce is a first-class mode, not a variant).
enum GoalMode: String, Codable, Sendable, CaseIterable {
    case quit, reduce
}

// PanicSource moved to Shared/Sources/PanicSource.swift in E3.3 (same module for app
// code; now visible to the widget target, which writes it via PanicLaunchFlag).

/// How a panic session ended.
enum UrgeOutcome: String, Codable, Sendable, CaseIterable {
    case averted, slipped, abandoned
}

/// Panic-flow steps a session reached (order recorded, not enforced here).
enum PanicStep: String, Codable, Sendable, CaseIterable {
    case breath, timer, reasons, redirect
}

/// One quiz answer — a Codable blob inside QuizProfile (answers never leave the device).
struct QuizAnswer: Codable, Sendable, Equatable {
    var stepID: String = ""
    var choiceIDs: [String] = []
    var freeText: String?
}

/// The central entity. Max 3 active at once — enforced by the E2.2 service layer,
/// never by schema (CloudKit has no server-side uniqueness/limits).
@Model
final class Quit {
    // Backs the repository's activeQuits() fetch (filter !isArchived, sort sortIndex).
    #Index<Quit>([\.isArchived, \.sortIndex])

    var id: UUID = UUID()
    var habitCategory: HabitCategory = HabitCategory.custom
    var customLabel: String?
    var goalMode: GoalMode = GoalMode.quit
    var weeklyAllowance: Int?
    var weeklySpend: Decimal = Decimal.zero
    var currencyCode: String = "USD"
    var startAt: Date = Date.distantPast
    var createdAt: Date = Date.distantPast
    /// Persisted clock-integrity anchor (the engine's Codable value; ADR-7).
    var monotonicAnchor: MonotonicAnchor?
    var bestStreakSeconds: Int = 0
    var totalCleanSeconds: Int = 0
    var avertedUrgeCount: Int = 0
    var triggers: [String] = []
    var motivations: [String] = []
    var discreetMode: Bool = false
    var isArchived: Bool = false
    var sortIndex: Int = 0
    @Relationship(deleteRule: .cascade, inverse: \Slip.quit)
    var slips: [Slip]?
    @Relationship(deleteRule: .cascade, inverse: \UrgeEvent.quit)
    var urgeEvents: [UrgeEvent]?

    init() {}
}

@Model
final class Slip {
    // Backs the E4.1 undo-lifecycle queries: the scene-phase finalize sweep and the
    // pendingUndoSlip banner source both filter on the flag (architecture §4).
    #Index<Slip>([\.isPendingUndo])

    var id: UUID = UUID()
    var at: Date = Date.distantPast
    /// Optional reflection note — NEVER leaves the device beyond the user's own iCloud.
    var note: String?
    var streakSecondsAtSlip: Int = 0
    var countsAgainstAllowance: Bool = false
    var isPendingUndo: Bool = false
    /// E4.1 — the persisted undo payload: the exact pre-slip values the engine's
    /// `PendingSlipUndo` recorded, kept on the row while the 10-minute window is open
    /// so `undoSlip` restores RECORDED values, never reconstructions (§9 rule 3 —
    /// prior best and the prior anchor are NOT derivable from the row alone). All
    /// optional (CloudKit checklist) and nil'd by the finalize sweep.
    var priorStartAt: Date?
    var priorCleanSeconds: Int?
    var priorBestStreakSeconds: Int?
    var priorMonotonicAnchor: MonotonicAnchor?
    var quit: Quit?

    init() {}
}

@Model
final class UrgeEvent {
    var id: UUID = UUID()
    var at: Date = Date.distantPast
    var source: PanicSource = PanicSource.inApp
    var outcome: UrgeOutcome = UrgeOutcome.abandoned
    var stepsReached: [PanicStep] = []
    var quit: Quit?

    init() {}
}

@Model
final class QuizProfile {
    var id: UUID = UUID()
    var completedAt: Date?
    var answers: [QuizAnswer] = []
    var projectedAnnualSavings: Decimal = Decimal.zero
    var predictedRiskWindow: String?
    var quit: Quit?

    init() {}
}

/// Singleton row (fetched-or-created by the E2.2 service layer).
@Model
final class AppSettings {
    /// Default FALSE until answered in the quiz — zero events before consent (ADR-8).
    var analyticsOptIn: Bool = false
    var discreetIconId: String?
    var hapticOnlyBreathPacer: Bool = false
    var onboardingVariant: String = ""
    var teaserExpiresAt: Date?

    init() {}
}
