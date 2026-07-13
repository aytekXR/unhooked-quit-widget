import Foundation

/// The bundled slip-flow copy (`App/Resources/Content/slipCopy.json`) — the SHIPPING
/// content file, decoded as-is (test-suite §3.2: static-content fixtures are the
/// shipping files, never copies; the panicScript precedent). Field names mirror the
/// JSON exactly; the flow renders these strings verbatim and substitutes only
/// `{{bestStreak}}`, `{{momentum}}`, and `{{motivation}}` (brandkit §1.2 — a single
/// user word echoed back, never generated).
struct SlipCopy: Codable, Equatable, Sendable {
    struct Confirm: Codable, Equatable, Sendable {
        var title: String
        var body: String
        var confirmLabel: String
        var cancelLabel: String
        /// Shown only when the durable write failed (the §9-rule-1 class: "Logged."
        /// is never claimed without durable bytes). Calm, zero-shame, retryable.
        var retryNote: String?
    }

    struct Logged: Codable, Equatable, Sendable {
        var title: String
        var body: String
        var bodyNoBest: String
    }

    struct Reflection: Codable, Equatable, Sendable {
        var prompt: String
        var placeholder: String
        var skipLabel: String
        var saveLabel: String
    }

    struct Undo: Codable, Equatable, Sendable {
        var banner: String
        var undoLabel: String
        var windowNote: String
        var undoneConfirmation: String
    }

    /// E4.2 — the root dashboard surface's slip strings (the pending-undo banner and
    /// the slip-entry rows), so EVERY slip-rendered string comes from this one audited
    /// table (implementation-plan §E4.2) instead of view-inline literals. Optional for
    /// decode tolerance (the `retryNote` precedent): an older file still decodes and
    /// the surface degrades to the plain fallback, never to a decode failure.
    struct Dashboard: Codable, Equatable, Sendable {
        var pendingBanner: String
        var undoLabel: String
        /// The discreet slip row's title — carries ZERO habit context (brandkit §1.2).
        var discreetRowLabel: String
    }

    /// E9.1 (R27.11) — the logged stage's one-tap support hand-off (mvp feature 11:
    /// resources "one tap from … every slip flow"). Optional SECTION for decode
    /// tolerance (the `dashboard` precedent — an older file still decodes); the
    /// label INSIDE is a stored NON-OPTIONAL String by standing rule (a bare
    /// `String?` would dodge the Mirror lexicon walk), so once the section ships it
    /// joins the reflection corpus automatically.
    struct ResourcesLink: Codable, Equatable, Sendable {
        var linkLabel: String
    }

    var confirm: Confirm
    var logged: Logged
    var reflection: Reflection
    var undo: Undo
    var encouragement: [String]
    var motivationEcho: String
    var dashboard: Dashboard?
    var resources: ResourcesLink?

    /// Decodes the shipping file from the app bundle. `nil` when the resource is
    /// missing or undecodable — the slip flow is a zero-lost-data surface, so callers
    /// fall back to nothing fancier than plain labels; they never invent copy.
    static func loadShipping(bundle: Bundle = .main) -> SlipCopy? {
        guard let url = bundle.url(forResource: "slipCopy", withExtension: "json"),
              let data = try? Data(contentsOf: url)
        else { return nil }
        return try? JSONDecoder().decode(SlipCopy.self, from: data)
    }
}
