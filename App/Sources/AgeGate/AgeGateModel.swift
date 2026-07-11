import Foundation
import Observation

/// E5.1 — the age gate's flow state. Holds the transient birth-year selection (the
/// ONLY place it ever lives — discarded with this object, never persisted; Architect
/// MUST-FIX #5) and the screen phase. Deliberately holds an `AnalyticsService` even
/// though it never fires: the zero-fire guard (`test_ageGate_firesNoAnalyticsEvents`,
/// the Session 16 step-0 re-spec) only has teeth if a future regression that wires
/// an event here flips a live spy — an absent seam would make the test vacuous.
@MainActor
@Observable
final class AgeGateModel {
    enum Phase: Equatable {
        case entry
        case blocked
        case passed
    }

    private(set) var phase: Phase = .entry
    /// The picker selection. Transient by design: no writer beyond the picker
    /// binding exists, and `submit` reads it once for the boundary calc.
    var selectedBirthYear: Int?

    private let analytics: AnalyticsService
    private let currentYear: Int
    private let persistPass: () -> Void

    /// `currentYear` is a plain Int derived from the injected ClockProviding seam at
    /// the composition root (LiveClock in production — never Date() here; Architect
    /// MUST-FIX #4). `persistPass` is the one bridge to the repository's
    /// `markAgeGatePassed()`; the model itself never touches storage.
    init(
        analytics: AnalyticsService = .disabled,
        currentYear: Int,
        persistPass: @escaping () -> Void = {}
    ) {
        self.analytics = analytics
        self.currentYear = currentYear
        self.persistPass = persistPass
    }

    /// The picker's selectable range (PM §4): no future years, a 120-year floor,
    /// and no pre-selected passing year (the CTA stays disabled until an explicit
    /// choice — the gate never nudges).
    static func selectableYears(currentYear: Int) -> ClosedRange<Int> {
        (currentYear - 120)...currentYear
    }

    /// The instance range over this model's injected year (what the wheel renders).
    var selectableYears: ClosedRange<Int> {
        Self.selectableYears(currentYear: currentYear)
    }

    /// The CTA action: evaluate the conservative boundary, advance the phase, and —
    /// on pass only — persist the single boolean. Fires no analytics on EITHER
    /// branch (E5.1 AC4: the whole surface is zero-fire; a blocked minor is never
    /// marked, a passer emits nothing — `onboarding_started` belongs to E5.2's
    /// first quiz screen, not the gate).
    @discardableResult
    func submit(birthYear: Int) -> AgeGateDecision {
        let decision = AgeGate.evaluate(birthYear: birthYear, currentYear: currentYear)
        switch decision {
        case .pass:
            persistPass()
            phase = .passed
        case .blocked:
            phase = .blocked
        }
        return decision
    }

    /// The blocked screen's calm exit (PM §4: misentry recovery, never a dead end) —
    /// back to year entry only, never into app content.
    func goBackToEntry() {
        phase = .entry
    }
}
