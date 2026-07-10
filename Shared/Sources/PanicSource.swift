/// Where a panic session was launched from. Deliberate superset of the architecture §3
/// sketch's three cases: E3.3's entry-point matrix names all four widget/system sources
/// (lock screen, Control Center, Action button) plus in-app.
///
/// Moved into Shared/Sources in E3.3 (from App/Sources/Persistence/PersistenceModels.swift):
/// source-level sharing keeps it in the SAME module for app code (zero import changes)
/// while making it visible to the widget target, whose intents now write it through
/// `PanicLaunchFlag`. NOT a SwiftData type — pure Codable/CaseIterable, so it lives
/// outside App/Sources/Persistence without tripping the swiftdata-importer lint.
enum PanicSource: String, Codable, Sendable, CaseIterable {
    case lockscreenWidget, homeWidget, controlCenter, actionButton, inApp
}
