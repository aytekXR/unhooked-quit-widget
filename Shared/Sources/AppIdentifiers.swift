import Foundation

/// Single source of truth for identifier strings shared between the app target and
/// the widget-extension target.
///
/// ── Gate G0 (rename) — CLEARED 2026-07-08 ──
/// Values below are the real, registered identifiers for "Ballast" (org prefix
/// `com.beyondkaira`, derived from the owned domain beyondkaira.com). Registered in
/// the Apple Developer portal on 2026-07-08 (App ID, widget App ID, App Group, and
/// iCloud container `iCloud.com.beyondkaira.ballast`; Team ID UH7MXG7Z94). The former
/// placeholder `dev.placeholder.quitwidget` was never registered (feasibility §7
/// condition 1). If these ever change, sweep exactly: project.yml + this file.
enum AppIdentifiers {
    /// The App Group both targets read/write. Architecture §4: the SwiftData store,
    /// panic-snapshot.json, and the panic launch flag all live in this container.
    static let appGroupID = "group.com.beyondkaira.ballast.shared"

    /// os_log / signpost subsystem for both targets.
    static let loggingSubsystem = "com.beyondkaira.ballast"

    /// URL of the shared App Group container, identically derivable from either target.
    static var appGroupContainerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
    }
}
