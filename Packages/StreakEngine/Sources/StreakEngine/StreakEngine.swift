/// Walking-skeleton entry point (E0.2). The real API surface — `currentStreak`,
/// `sanityCheck`, `applySlip`/`undoSlip`, `adherence` per architecture §5.1 — is
/// Epic 1 and is written test-first. Nothing product-shaped lands here before its
/// failing tests exist (test-suite §7 working agreement).
public enum StreakEngine {
    /// Proves the package links and exposes an entry point (E0.2 acceptance).
    public static let version = "0.0.1-skeleton"
}
