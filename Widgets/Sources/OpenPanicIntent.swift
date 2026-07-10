import AppIntents

/// The product's headline interaction (architecture §5.1): the lock-screen WIDGET
/// button intent that opens the app straight into the panic route. The intent's only
/// job is to set the App Group launch instruction before the app opens — the app's
/// thin scene routing does the rest (ADR-6).
///
/// E3.3: attributes `.lockscreenWidget` (the one surface this intent serves — the
/// control family rides `OpenPanicControlIntent`) and gains the per-quit `@Parameter`,
/// resolved by `PanicQuitQuery` over the pre-cache. E6.2's per-widget selector feeds
/// it; until then the widget button passes nil and the app's resolver picks.
struct OpenPanicIntent: AppIntent {
    static let title: LocalizedStringResource = "Panic"
    static let description = IntentDescription("Opens a full-screen reset, instantly.")
    static let openAppWhenRun: Bool = true

    @Parameter(title: "Quit")
    var quit: PanicQuitEntity?

    init() {}

    init(quit: PanicQuitEntity?) {
        self.quit = quit
    }

    func perform() async throws -> some IntentResult {
        PanicLaunchFlag.set(source: .lockscreenWidget, quitID: quit?.id)
        return .result()
    }
}
