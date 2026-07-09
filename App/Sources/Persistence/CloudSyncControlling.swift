import Foundation

/// Domain status of the user's iCloud account, as the sync/erase layer consumes it.
/// Deliberately two-valued: every CKAccountStatus case that is not `.available` means
/// the private database cannot be reached right now, and the app treats them all the
/// same way — fully-local mode is first-class, never an error (architecture §8).
enum CloudAccountStatus: Equatable, Sendable {
    case available
    case unavailable
}

/// Seam for the CloudKit private-database side of sync + erase (test-suite §3.1
/// discipline: mock at protocol seams, never stub CKContainer internals — "that path
/// lies"). Main-actor bound like its only consumer (the repository).
///
/// Production conformance (CKContainer `accountStatus()` mapped into
/// `CloudAccountStatus`, and deletion of the mirror's record zones) lands with the
/// §4.3 CloudKit flip: today the store is `cloudKitDatabase: .none`, so there is no
/// mirror to purge and the real zone deletion is contract/device-tier
/// (test-suite §4.3 "erase contract").
@MainActor
protocol CloudSyncControlling {
    /// Whether the user's iCloud account can host the mirror right now.
    func accountStatus() async -> CloudAccountStatus

    /// Requests deletion of every private-database zone the mirror writes —
    /// the "purge CloudKit zone" step of one-tap erase (architecture §10).
    func deleteAllPrivateZones() async throws
}
