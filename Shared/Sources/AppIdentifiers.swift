import Foundation

/// Single source of truth for identifier strings shared between the app target and
/// the widget-extension target.
///
/// ── Gate G0 (rename) ──
/// Every value here is a PLACEHOLDER derived from the never-to-be-registered bundle ID
/// `dev.placeholder.quitwidget` (see project.yml sweep list). None of these may be
/// registered with Apple before the rename clears (feasibility §7 condition 1;
/// architecture naming note). Rename sweep touches exactly: project.yml + this file.
enum AppIdentifiers {
    /// The App Group both targets read/write. Architecture §4: the SwiftData store,
    /// panic-snapshot.json, and the panic launch flag all live in this container.
    static let appGroupID = "group.dev.placeholder.quitwidget.shared"

    /// os_log / signpost subsystem for both targets.
    static let loggingSubsystem = "dev.placeholder.quitwidget"

    /// URL of the shared App Group container, identically derivable from either target.
    static var appGroupContainerURL: URL? {
        // E0.2 red state: not implemented yet — test_appGroup_containerURL_isSharedBetweenTargets
        // is expected to fail until the walking-skeleton implementation commit.
        nil
    }
}
