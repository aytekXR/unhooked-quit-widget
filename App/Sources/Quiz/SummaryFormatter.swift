import Foundation

/// E5.3 — pure display math for the summary card (Architect Q3: display
/// formatting is computed, NEVER stored — the persisted bytes are the exact
/// Decimal + the trigger token, and the formatted string never lands anywhere).
/// Foundation-only, Linux-harnessable.
///
/// Green contract (PM §3.1, Brand-endorsed): floor-to-TEN — Honest, a projection
/// shown to motivate must never overstate, a floored figure is always "this much
/// or better" — then "~" prefix (the spend was user-estimated), the quit's STORED
/// `currencyCode` (Architect S4 — never an ambient Locale read for the currency),
/// 0 fraction digits, "/year" suffix. Zero spend → nil: the savings-absent
/// variant renders instead of a fabricated "~$0/year" (AC4; MVP §7).
/// `locale` is injectable so tests pin an explicit locale for determinism;
/// production passes the device locale for digit grouping only.
enum SummaryFormatter {
    /// RED STUB — deliberately returns a fabricated figure for every input.
    static func savingsDisplay(
        _ savings: Decimal, currencyCode: String, locale: Locale = .current
    ) -> String? {
        "~$0/year"
    }
}
