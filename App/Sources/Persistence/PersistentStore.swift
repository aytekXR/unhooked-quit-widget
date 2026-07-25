import Foundation
import SwiftData

/// E2.1 — the single SwiftData store in the App Group container (architecture §4).
/// One store for all product data; the widget extension shares the container path.
/// CloudKit mirroring is configured EXPLICITLY off, and **v1 ships local-only BY
/// DESIGN** — this is a settled decision, NOT a pending to-do. The entitlements
/// declare App Groups only (no iCloud container), the sync seam is
/// `LocalOnlyCloudSync`, and the shipped positioning copy promises "No server.
/// Nothing to leak." / data that never leaves the device. `.automatic` would
/// silently start mirroring the moment an iCloud entitlement appeared, which is
/// why the value is pinned rather than defaulted.
///
/// Gate G0's technical half cleared 2026-07-08 (`AppIdentifiers.swift`) and this line
/// deliberately did NOT flip. Enabling CloudKit is a POST-v1 product decision that
/// re-derives the App Privacy label AND both privacy manifests — never a cleanup
/// task. (S46/R46.6: the previous wording read as "the one line that flips when the
/// rename lands", which invited a future session to "finish" it and silently break
/// the privacy promise.)
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
