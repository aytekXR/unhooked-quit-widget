import AppIntents

/// The control-family panic intent: Control Center, the lock-screen control slots, and
/// the Action button all run the control the user placed there — ONE registration
/// serves all three, and iOS exposes no launch-surface API (docs-checked, WWDC24 10157
/// + WidgetKit), so every control launch attributes `.controlCenter`. That is the E3.3
/// recorded adjustment (platform ceiling, not drift): `.actionButton` stays reserved in
/// `PanicSource` until the platform can tell surfaces apart.
///
/// NOT Shortcuts-discoverable: the discreet "Reset" control rides this same intent, and
/// a Shortcuts gallery action titled "Panic" would leak what that control hides (§10).
struct OpenPanicControlIntent: AppIntent {
    static let title: LocalizedStringResource = "Panic"
    static let description = IntentDescription("Opens a full-screen reset, instantly.")
    static let openAppWhenRun: Bool = true
    static let isDiscoverable: Bool = false

    @Parameter(title: "Quit")
    var quit: PanicQuitEntity?

    init() {}

    init(quit: PanicQuitEntity?) {
        self.quit = quit
    }

    func perform() async throws -> some IntentResult {
        PanicLaunchFlag.set(source: .controlCenter, quitID: quit?.id)
        return .result()
    }
}
