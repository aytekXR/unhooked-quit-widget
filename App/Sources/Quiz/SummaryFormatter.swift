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
    /// "~" + floor-to-ten + locale-formatted currency + "/year"; zero (or a
    /// negative, defensively) → nil so the absent variant renders. The floor is
    /// the Honest arm: the figure is always "this much or better".
    static func savingsDisplay(
        _ savings: Decimal, currencyCode: String, locale: Locale = .current
    ) -> String? {
        guard savings > 0 else { return nil }
        var value = savings
        var floored = Decimal()
        // Scale -1 = the tens place; .down = floor (never overstate a projection).
        NSDecimalRound(&floored, &value, -1, .down)

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        guard let money = formatter.string(from: floored as NSDecimalNumber) else { return nil }
        return "~\(money)/year"
    }
}
