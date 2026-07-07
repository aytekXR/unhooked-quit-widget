import AppIntents

/// The product's headline interaction (architecture §5.1): an interactive widget /
/// Control Center / Action-button intent that opens the app straight into the panic
/// route. The intent's only job is to set the App Group launch flag before the app
/// opens — the app's thin scene routing does the rest (ADR-6).
///
/// The per-quit `quitID` parameter arrives in E3.3; the skeleton intent is parameterless.
struct OpenPanicIntent: AppIntent {
    static let title: LocalizedStringResource = "Panic"
    static let description = IntentDescription("Opens a full-screen reset, instantly.")
    static let openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        PanicLaunchFlag.set()
        return .result()
    }
}
