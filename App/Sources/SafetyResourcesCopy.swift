import Foundation

/// The bundled safety framing copy (`App/Resources/Content/safetyCopy.json`) — the
/// SHIPPING content file decoded as-is (test-suite §3.2: fixtures are the shipping
/// files, never copies; the SlipCopy/PanicScript precedent). E5.1 is its first
/// consuming epic: the age gate's blocked surface renders `resourcesScreen`'s
/// framing verbatim. Undeclared JSON sections (the alcohol notice, `_meta`) stay
/// undecoded until their consuming epics arrive.
struct SafetyCopy: Codable, Equatable, Sendable {
    struct ResourcesScreen: Codable, Equatable, Sendable {
        var title: String
        var intro: String
        var footerDisclaimer: String
        var regionPickerLabel: String
    }

    var resourcesScreen: ResourcesScreen
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
