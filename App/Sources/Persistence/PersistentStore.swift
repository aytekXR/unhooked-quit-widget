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
    /// Every model the mirrored store holds (architecture §4 schema table). Note the
    /// derived schema is the reachability closure over relationships, so the mirrors
    /// test asserts on `schema.entities`, not this list — an extra entity sneaking in
    /// through a new relationship fails the same test as an extra list entry.
    static let mirroredModelTypes: [any PersistentModel.Type] = [
        Quit.self, Slip.self, UrgeEvent.self, QuizProfile.self, AppSettings.self,
    ]

    /// The store schema, built from `mirroredModelTypes`.
    static var schema: Schema { Schema(mirroredModelTypes) }

    /// Store file location: `<App Group>/Library/Application Support/unhooked.store`.
    /// The App Group container is what lets the widget extension open the same store.
    /// Creates the parent directory when missing — SwiftData does not create custom
    /// store-URL directories itself.
    static func storeURL() throws -> URL {
        guard let group = AppIdentifiers.appGroupContainerURL else {
            throw PersistentStoreError.appGroupUnavailable
        }
        let directory = group.appendingPathComponent(
            "Library/Application Support", isDirectory: true
        )
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appendingPathComponent("unhooked.store", isDirectory: false)
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
