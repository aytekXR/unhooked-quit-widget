import Foundation

/// One helpline row on the blocked surface — name + verbatim number, nothing else
/// (no habit category exists pre-gate, so none is shown).
struct HelplineRow: Equatable, Sendable {
    var name: String
    var descr: String
    var phoneDisplay: String
    var dialString: String
}

/// The blocked-state resources surface's data: the screen a blocked user LANDS on —
/// zero taps to support, stronger than MVP §7's one-tap bar (PM spec §1).
struct AgeGateBlocked: Equatable, Sendable {
    var emergencyNote: String
    var rows: [HelplineRow]
}

enum AgeGateResources {
    /// Device-region resolution with the US fallback (PM open-question 1 default:
    /// no region picker in E5.1 — the picker ships with the full resources epic).
    /// Locale is injected for determinism; unmapped regions read US.
    static func region(for locale: Locale, in directory: HelplineDirectory) -> String {
        guard let id = locale.region?.identifier, directory.regions[id] != nil else { return "US" }
        return id
    }

    /// The selection predicate (Architect MUST-FIX #1, hardened by the directory's
    /// own `_meta` ruling; operator-vetoable, Session 16): category-agnostic
    /// (`appliesTo` contains "all") AND `verified == true` — an unverified number
    /// never renders to a blocked minor. A row joins this surface the moment the
    /// operator verifies it and flips its flag (today: US → 988; TR → 112, with
    /// ALO 182 pending the operator's official-source check).
    static func blocked(region: String, directory: HelplineDirectory) -> AgeGateBlocked {
        guard let regionEntry = directory.regions[region] else {
            return AgeGateBlocked(emergencyNote: "", rows: [])
        }
        let rows = regionEntry.resources
            .filter { $0.appliesTo.contains("all") && $0.verified == true }
            .map { HelplineRow(name: $0.name, descr: $0.descr, phoneDisplay: $0.phoneDisplay, dialString: $0.dialString) }
        return AgeGateBlocked(emergencyNote: regionEntry.emergencyNote, rows: rows)
    }

    /// Bundle convenience over the shipping directory; a missing/undecodable file
    /// degrades to an empty surface (the calm copy still renders) — never a crash.
    static func blocked(region: String, bundle: Bundle = .main) -> AgeGateBlocked {
        guard let directory = HelplineDirectory.loadShipping(bundle: bundle) else {
            return AgeGateBlocked(emergencyNote: "", rows: [])
        }
        return blocked(region: region, directory: directory)
    }
}
