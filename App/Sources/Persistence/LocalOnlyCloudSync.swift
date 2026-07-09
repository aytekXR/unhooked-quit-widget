import Foundation

/// Production `CloudSyncControlling` stand-in until the §4.3 CloudKit flip. The store
/// is still `cloudKitDatabase: .none`, so there IS no mirror: `accountStatus` reports
/// `.unavailable`, which makes erase SKIP the purge (fully-local is first-class,
/// architecture §8 — skip, never fail) and leaves the purge path unreachable. The real
/// CKContainer conformance (accountStatus mapping + record-zone deletion) replaces
/// this type red-test-first when the §4.3 flip is deliberately taken, together with
/// the contract-tier erase checks (test-suite §4.3).
@MainActor
struct LocalOnlyCloudSync: CloudSyncControlling {
    func accountStatus() async -> CloudAccountStatus { .unavailable }

    /// Unreachable while `accountStatus` is `.unavailable` (erase checks first).
    func deleteAllPrivateZones() async throws {}
}
