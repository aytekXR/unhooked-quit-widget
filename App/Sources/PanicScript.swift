import Foundation

/// The bundled panic-flow copy (`App/Resources/Content/panicScript.json`) — the
/// SHIPPING content file, decoded as-is (test-suite §3.2: static-content fixtures are
/// the shipping files, never copies). Field names mirror the JSON exactly; the flow
/// renders these strings verbatim and substitutes only `{{motivations}}` per brandkit
/// §1.2 ("our copy frames, theirs stars").
struct PanicScript: Codable, Equatable, Sendable {
    struct Pacer: Codable, Equatable, Sendable {
        var inhaleSeconds: Double
        var holdSeconds: Double
        var exhaleSeconds: Double
        var cycles: Int
        var hapticGuided: Bool
    }

    struct Step: Codable, Equatable, Sendable {
        var step: PanicStep
        var title: String
        var instruction: String
        var pacer: Pacer?
        var hapticOnlyLabel: String?
        var subtext: String?
        var motivationsToken: String?
        var emptyFallback: String?
        var options: [RedirectOption]?
        var skipLabel: String
    }

    struct RedirectOption: Codable, Equatable, Sendable {
        var id: String
        var label: String
    }

    struct Exit: Codable, Equatable, Sendable {
        var id: String
        var label: String
        var labelDiscreet: String
        var confirmation: String?
        var routesTo: String?
    }

    var entryTitle: String
    var entryTitleDiscreet: String
    var steps: [Step]
    var exits: [Exit]

    func step(_ kind: PanicStep) -> Step? {
        steps.first { $0.step == kind }
    }

    func exit(_ id: String) -> Exit? {
        exits.first { $0.id == id }
    }

    /// Decodes the shipping file from the app bundle. `nil` when the resource is
    /// missing or undecodable — the caller degrades, never crashes the panic path.
    static func loadShipping(bundle: Bundle = .main) -> PanicScript? {
        nil // red skeleton — bundling + decode land with the green commit
    }
}
