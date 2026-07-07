import Foundation
import SnapshotTesting
import Testing

/// E0.1 snapshot lane — near-empty by design. This smoke test proves the
/// swift-snapshot-testing dependency resolves, records, and compares in CI.
/// Real widget snapshot matrices (family × light/dark/StandBy × discreet) are
/// Epic 6 work on the pinned simulator (test-suite §3.3).
@Suite("Epic 0 · snapshot lane smoke")
struct SnapshotSmokeTests {
    /// Deterministic, render-free snapshot: a Codable value via the .json strategy.
    /// The committed reference file is the lane's proof of round-tripping.
    @Test func snapshotLane_recordsAndComparesDeterministicValue() {
        struct LaneProbe: Codable {
            let epic: String
            let lane: String
            let ready: Bool
        }
        let probe = LaneProbe(epic: "E0.1", lane: "snapshot", ready: true)
        assertSnapshot(of: probe, as: .json)
    }
}
