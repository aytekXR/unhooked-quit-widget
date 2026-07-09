import Foundation
import StreakEngine
import SwiftData

// E2.3 — the launch-time recompute pass (architecture §8): the CloudKit dedupe merge
// (duplicates by Quit.id resolve to one record that can never shrink history) plus the
// ADR-7 healing re-anchor (freeze-then-resume) and the conservative witness restart.
// Repository-layer work: this file rides the sole-SwiftData-importer allowlist.
extension QuitRepository {

    /// Runs the deterministic derived-state pass: dedupe-merge, heal, witness restart.
    /// Idempotent and safe at every launch; returns whether anything mutated.
    @discardableResult
    func recomputeDerivedState() throws -> Bool {
        // E2.3 red sentinel: no merge, no heal, no witness restart — every red test
        // fails on its designed assertion. Green replaces this body.
        false
    }
}
