import Foundation

/// The bundled safety framing copy (`App/Resources/Content/safetyCopy.json`) — the
/// SHIPPING content file decoded as-is (test-suite §3.2: fixtures are the shipping
/// files, never copies; the SlipCopy/PanicScript precedent). E5.1 was its first
/// consuming epic (the age gate's blocked surface renders `resourcesScreen`'s
/// framing verbatim); E9.1 decodes the alcohol withdrawal notice. `_meta` stays
/// undecoded — the audit note quotes what it forbids.
struct SafetyCopy: Codable, Equatable, Sendable {
    struct ResourcesScreen: Codable, Equatable, Sendable {
        var title: String
        var intro: String
        var footerDisclaimer: String
        var regionPickerLabel: String
    }

    /// E9.1 (R27.6) — the ONE calm caution the copy posture allows (safetyCopy
    /// `_meta`: shown once, never repeated; it points to help, it never advises HOW
    /// to withdraw). OPTIONAL SECTION for decode tolerance (the SlipCopy `dashboard`
    /// precedent — burn-reproduced: a non-optional section makes a section-absent
    /// bundle nil the WHOLE table and takes E5.1's resourcesScreen down with it);
    /// the fields INSIDE are stored non-optional Strings so the section joins the
    /// lexicon walk whenever present. The JSON's `shownOnce`/`context` keys are
    /// authoring metadata and deliberately undecoded (once-ness is enforced by the
    /// AppSettings stamp, not by copy).
    struct AlcoholNotice: Codable, Equatable, Sendable {
        var title: String
        var body: String
        var primaryActionLabel: String
        var dismissLabel: String

        /// The §9 fail-safe fallback (Architect SHOULD, R27.6): a decode failure of
        /// the withdrawal-danger message is a SAFETY miss, so the card still renders
        /// a plain calm caution — never silently nothing, never an invented claim.
        /// Lexicon-scanned beside the shipping table.
        static let degraded = AlcoholNotice(
            title: "One thing worth knowing",
            body: "For heavy or daily drinking, stopping suddenly can be physically risky. A doctor or a helpline can help you find the safest way to cut down. This app isn't medical care.",
            primaryActionLabel: "See resources",
            dismissLabel: "Got it"
        )
    }

    var resourcesScreen: ResourcesScreen
    var alcoholWithdrawalNotice: AlcoholNotice?
    var notMedicalCareDisclaimer: String?

    /// Decodes the shipping file from the app bundle. `nil` when missing or
    /// undecodable — callers degrade to plain fallbacks, never invented copy.
    static func loadShipping(bundle: Bundle = .main) -> SafetyCopy? {
        guard let url = bundle.url(forResource: "safetyCopy", withExtension: "json"),
              let data = try? Data(contentsOf: url)
        else { return nil }
        return try? JSONDecoder().decode(SafetyCopy.self, from: data)
    }
}

/// The bundled region-aware helpline directory (`App/Resources/Content/helplines.json`),
/// decoded as-is. Numbers render verbatim from `dialString`/`phoneDisplay` — NEVER
/// re-typed, never invented (the directory's own `_meta` audit rule). E5.1 consumes
/// the category-agnostic verified rows on the age gate's blocked surface.
struct HelplineDirectory: Codable, Equatable, Sendable {
    struct Region: Codable, Equatable, Sendable {
        var displayName: String
        var emergencyNote: String
        var resources: [Helpline]
    }

    struct Helpline: Codable, Equatable, Sendable {
        var id: String
        var appliesTo: [String]
        var name: String
        var descr: String
        var phoneDisplay: String
        var dialString: String
        var altPhoneDisplay: String?
        var altDialString: String?
        var hours: String?
        var url: String?
        /// Only rows verified against an official source render on user surfaces —
        /// the directory's `_meta` posture (it deliberately EXCLUDED an unverified
        /// US line rather than ship it). Absent reads as not verified.
        var verified: Bool?
    }

    var regions: [String: Region]

    /// Decodes the shipping file from the app bundle. `nil` when missing or
    /// undecodable — the blocked surface degrades to its calm copy with the
    /// region's emergency guidance absent, never a crash or an invented number.
    static func loadShipping(bundle: Bundle = .main) -> HelplineDirectory? {
        guard let url = bundle.url(forResource: "helplines", withExtension: "json"),
              let data = try? Data(contentsOf: url)
        else { return nil }
        return try? JSONDecoder().decode(HelplineDirectory.self, from: data)
    }
}
