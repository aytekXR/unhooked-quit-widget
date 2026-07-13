import Foundation

/// E9.1 (R27.2) — the post-gate resources screen's pure selection: region resolution
/// with the GLOBAL fallback + the verified-rows read. A SIBLING of `AgeGateResources`
/// BY RULING, never a promotion: the E5.1 blocked-minor surface keeps its own funcs,
/// its "all"-only filter, its unmapped→US fallback, and its S16 pins byte-frozen —
/// the two surfaces serve different audiences under different contracts (a blocked
/// minor gets the operator-verified US floor; a consented adult gets the honest
/// GLOBAL bucket). The verified-only predicate is deliberately REIMPLEMENTED here
/// (rule #12: an unverified number never renders on ANY user surface) rather than
/// shared — promotion would drag the AgeGateTests pins into every future edit.
///
/// Pure Foundation — Linux-harnessed ×3 host timezones (standing rule #4).
enum SafetyResourcesSelection {
    /// The E9.1 region fallback (R27.7): a device region with no directory entry
    /// reads the number-free GLOBAL bucket — never US numbers dressed as local
    /// resources. Locale injected for determinism.
    static func region(for locale: Locale, in directory: HelplineDirectory) -> String {
        guard let id = locale.region?.identifier, directory.regions[id] != nil else { return "GLOBAL" }
        return id
    }

    /// Every VERIFIED row for the region, "all"-scoped rows first (R27.8: safety =
    /// availability — no active-quit filtering, crisis rows always present). An
    /// unverified row never renders (rule #12; the S16 duty-of-care twin); a row
    /// joins the moment the operator verifies it and flips its flag.
    static func rows(region: String, in directory: HelplineDirectory) -> [HelplineRow] {
        guard let entry = directory.regions[region] else { return [] }
        let verified = entry.resources.filter { $0.verified == true }
        let crisis = verified.filter { $0.appliesTo.contains("all") }
        let scoped = verified.filter { !$0.appliesTo.contains("all") }
        return (crisis + scoped).map {
            HelplineRow(name: $0.name, descr: $0.descr, phoneDisplay: $0.phoneDisplay, dialString: $0.dialString)
        }
    }
}
