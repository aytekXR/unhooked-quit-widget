/// Package version marker, pinned to the annotated release tag (streakengine-v1.2.0).
/// The engine API lives in `StreakCalculator` (static core) and `StreakCalculating`
/// (injection seam): streak/money/momentum readouts, the clock-integrity guard with the
/// reboot sanity cap and its healing re-anchor, slip archiving with windowed undo, and
/// allowance adherence.
public enum StreakEngine {
    /// The released engine version a consumer depends on, readable at runtime.
    public static let version = "1.2.0"
}
