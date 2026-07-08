/// Package version marker, pinned to the annotated release tag (streakengine-v1.0.0).
/// The engine API lives in `StreakCalculator` (static core) and `StreakCalculating`
/// (injection seam): streak/money/momentum readouts, the clock-integrity guard,
/// slip archiving with windowed undo, and allowance adherence.
public enum StreakEngine {
    /// The released engine version a consumer depends on, readable at runtime.
    public static let version = "1.0.0"
}
