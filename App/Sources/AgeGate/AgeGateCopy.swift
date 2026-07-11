import Foundation

/// The bundled age-gate copy (`App/Resources/Content/ageGateCopy.json`) — the ONE
/// audited table for both gate screens (test-suite §3.2: the SHIPPING file is the
/// fixture; the SlipCopy precedent). Field names mirror the JSON exactly; both
/// screens render these strings verbatim. The whole table is scanned against the
/// forbidden lexicon on every CI run (SlipLexiconTests — QA change #4, Session 16).
struct AgeGateCopy: Codable, Equatable, Sendable {
    struct Gate: Codable, Equatable, Sendable {
        var title: String
        var body: String
        var yearLabel: String
        var continueLabel: String
        var footer: String
    }

    struct Blocked: Codable, Equatable, Sendable {
        var title: String
        var body: String
        var goBackLabel: String
    }

    var gate: Gate
    var blocked: Blocked

    /// Decodes the shipping file from the app bundle. `nil` when missing or
    /// undecodable — the gate then renders `.degraded` (the gate itself NEVER
    /// disappears on a decode failure: fail-closed means the check still stands,
    /// just with plainer words).
    static func loadShipping(bundle: Bundle = .main) -> AgeGateCopy? {
        guard let url = bundle.url(forResource: "ageGateCopy", withExtension: "json"),
              let data = try? Data(contentsOf: url)
        else { return nil }
        return try? JSONDecoder().decode(AgeGateCopy.self, from: data)
    }

    /// The §9 degraded fallback — plain, still zero-shame, still scanned by the
    /// lexicon gate alongside the shipping table.
    static let degraded = AgeGateCopy(
        gate: Gate(
            title: "Age check",
            body: "Ballast is rated 17+. Choose the year you were born to continue. Only a yes-or-no answer is kept.",
            yearLabel: "Year of birth",
            continueLabel: "Continue",
            footer: "This stays on your device."
        ),
        blocked: Blocked(
            title: "Support is here for you",
            body: "Because Ballast is rated 17+, we can't open the full app for you yet. Free, confidential support lines are below.",
            goBackLabel: "Go back"
        )
    )
}
