import Foundation
import SwiftData

/// E2.1 — the single SwiftData store in the App Group container (architecture §4).
/// One store for all product data; the widget extension shares the container path.
/// CloudKit mirroring is configured EXPLICITLY off until Gate G0 clears: a placeholder
/// container ID must never be registered, and `.automatic` would silently start
/// mirroring the moment an iCloud entitlement appears. When the rename lands, this is
/// the one line that flips to `.private("iCloud.<newname>")` — red test first
/// (the schema-validation instantiation test from test-suite §4.3).
enum PersistentStore {
    /// Every model the mirrored store holds (architecture §4 schema table).
    /// All five real models are listed even at red: UrgeEvent is relationship-reachable
    /// from Quit, so omitting it could never leave the derived schema (SwiftData builds
    /// the reachability closure) — an omission sentinel would pass from birth.
    static let mirroredModelTypes: [any PersistentModel.Type] = [
        Quit.self, Slip.self, UrgeEvent.self, QuizProfile.self, AppSettings.self,
        RedSentinelModel.self, // E2.1 red sentinel — the green commit deletes this model
    ]

    /// The store schema, built from `mirroredModelTypes`.
    static var schema: Schema { Schema(mirroredModelTypes) }

    /// Store file location: `<App Group>/Library/Application Support/unhooked.store`.
    /// The App Group container is what lets the widget extension open the same store.
    static func storeURL() throws -> URL {
        // E2.1 red sentinel — the green commit derives this from
        // AppIdentifiers.appGroupContainerURL, not the process temp directory.
        FileManager.default.temporaryDirectory
            .appendingPathComponent("unhooked.store", isDirectory: false)
    }

    /// The production configuration: on-disk in the App Group, CloudKit mirror off
    /// until Gate G0 provides a real container (see type comment).
    static func makeConfiguration() throws -> ModelConfiguration {
        ModelConfiguration(schema: schema, url: try storeURL(), cloudKitDatabase: .none)
    }

    /// Opens the single store. The app calls this once at launch (deferred past the
    /// panic path's first frame per ADR-6); tests call it directly.
    static func makeContainer() throws -> ModelContainer {
        try ModelContainer(for: schema, configurations: [makeConfiguration()])
    }
}

/// Failures the store factory can surface before SwiftData is even reached.
enum PersistentStoreError: Error {
    /// The App Group container did not resolve — entitlements are missing or broken.
    case appGroupUnavailable
}

// E2.1 red sentinel — a sixth entity no architecture §4 store may carry, injected so
// test_store_mirrorsExpectedModels fails deterministically regardless of SwiftData's
// relationship-discovery behavior (an EXTRA entity always shows; an omitted reachable
// one may not). Deleted whole by the green commit.
@Model
final class RedSentinelModel {
    var id: UUID = UUID()
    init() {}
}
