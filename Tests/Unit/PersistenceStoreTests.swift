import Foundation
import SwiftData
import Testing
@testable import Unhooked

/// E2.1 unit lane. Test names are the doc-canonical ones from implementation-plan.md
/// E2.1 — keep them verbatim. Deliberately NOT here, with reasons: the CloudKit-option
/// instantiation test (test-suite §4.3) needs a real registered container (blocked on
/// Gate G0); the protection-class check is device-tier (the simulator lies about file
/// protection); test_companionTranscriptStore_hasNoCloudKitConfiguration is E12-gated
/// by the plan's own text (the non-mirrored CompanionMessage store exists only then).
@Suite("E2.1 · single SwiftData store in the App Group")
struct PersistenceStoreTests {

    private static let expectedEntityNames: Set<String> = [
        "Quit", "Slip", "UrgeEvent", "QuizProfile", "AppSettings",
    ]

    /// The one store carries exactly the architecture §4 model set — nothing missing,
    /// nothing extra (the v1.2 companion transcript store is separate BY DESIGN and
    /// must never appear here).
    @Test func test_store_mirrorsExpectedModels() {
        let names = Set(PersistentStore.schema.entities.map(\.name))
        #expect(names == Self.expectedEntityNames)
    }

    /// The CloudKit-mirroring checklist, enforced mechanically (architecture §4): a
    /// bare init() row of EVERY model must insert and save (all attributes defaulted
    /// or optional), no attribute may be unique, every relationship must be optional.
    /// This is the test that catches "an agent added @Attribute(.unique)" at commit
    /// time instead of at future sync-activation time.
    @Test func test_allMirroredModelProperties_haveDefaultsOrOptionals() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: PersistentStore.schema, configurations: [config])
        let context = ModelContext(container)
        context.insert(Quit())
        context.insert(Slip())
        context.insert(UrgeEvent())
        context.insert(QuizProfile())
        context.insert(AppSettings())
        try context.save() // empty rows must be valid — CloudKit records start empty

        for entity in PersistentStore.schema.entities {
            for attribute in entity.attributes {
                #expect(
                    !attribute.isUnique,
                    "\(entity.name).\(attribute.name) must not be unique (CloudKit checklist)"
                )
            }
            for relationship in entity.relationships {
                #expect(
                    relationship.isOptional,
                    "\(entity.name).\(relationship.name) must be optional (CloudKit checklist)"
                )
            }
        }
    }

    /// The store file lives inside the App Group container at the architecture §4 path,
    /// and a real on-disk container opens there — that shared location is what lets the
    /// widget extension open the same store.
    @Test func test_storeLivesInAppGroupContainer() throws {
        let groupURL = try #require(
            AppIdentifiers.appGroupContainerURL,
            "App Group container must resolve (proven possible by the E0.2 test)"
        )
        let storeURL = try PersistentStore.storeURL()
        #expect(
            storeURL.path.hasPrefix(groupURL.path),
            "store must live in the App Group so the widget extension can reach it"
        )
        #expect(storeURL.lastPathComponent == "unhooked.store")

        let container = try PersistentStore.makeContainer()
        // Symlink-resolved comparison: the simulator serves /var/... and /private/var/...
        // spellings of the same container path interchangeably.
        #expect(
            container.configurations.first?.url.resolvingSymlinksInPath()
                == storeURL.resolvingSymlinksInPath()
        )
        #expect(FileManager.default.fileExists(atPath: storeURL.path))
    }

    /// E6.2 rule-9 sweep (A5): the ADR-11 `startTimeZoneIdentifier` is a DEFAULTED,
    /// MIRRORED Quit column — it round-trips through the store keeping its "" default
    /// for a bare (pre-E6.2) row and a stamped value for a real one, and stays
    /// CloudKit-safe (non-unique). Extends the schema/round-trip pins so the field can
    /// never silently become unique or lose its default. Green from the red commit
    /// (the field ships in the red-commit persistence model).
    @Test func test_quitStartTimeZoneIdentifier_isDefaultedMirroredField_roundTrips() throws {
        let container = try ModelContainer(
            for: PersistentStore.schema,
            configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
        )
        let context = ModelContext(container)

        // A bare row keeps the "" default (a pre-E6.2 row awaiting its launch backfill).
        let bare = Quit()
        context.insert(bare)
        // A stamped row carries a real zone identifier.
        let stamped = Quit()
        stamped.startTimeZoneIdentifier = "America/New_York"
        context.insert(stamped)
        try context.save()

        // A FRESH context proves the field is durable, not an in-memory echo.
        let fresh = ModelContext(container)
        let bareID = bare.id
        let stampedID = stamped.id
        let reloadedBare = try #require(
            try fresh.fetch(FetchDescriptor<Quit>(predicate: #Predicate { $0.id == bareID })).first
        )
        let reloadedStamped = try #require(
            try fresh.fetch(FetchDescriptor<Quit>(predicate: #Predicate { $0.id == stampedID })).first
        )
        #expect(
            reloadedBare.startTimeZoneIdentifier == "",
            "the defaulted field round-trips as \"\" — the CloudKit-safe default for a pre-E6.2 row awaiting backfill"
        )
        #expect(
            reloadedStamped.startTimeZoneIdentifier == "America/New_York",
            "a stamped zone identifier round-trips through the mirrored store"
        )

        // Schema half: the field must be a mirrored, NON-unique attribute (the CloudKit
        // checklist the sibling test enforces across all attributes, pinned by name here).
        let quitEntity = try #require(
            PersistentStore.schema.entities.first { $0.name == "Quit" }
        )
        let attribute = try #require(
            quitEntity.attributes.first { $0.name == "startTimeZoneIdentifier" },
            "startTimeZoneIdentifier must be a mirrored Quit attribute"
        )
        #expect(!attribute.isUnique, "startTimeZoneIdentifier must not be unique (CloudKit checklist)")
    }
}
