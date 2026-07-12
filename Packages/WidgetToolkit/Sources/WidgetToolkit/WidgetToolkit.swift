/// Portfolio package (architecture §14): widget timeline patterns, shared across consumers.
/// E6.1 lands the first real API — `StreakTimelinePlanner` (local-midnight/DST day rollover,
/// stale-grace, ticking windows). The InstantLaunch module (E3.1) and the discreet-variant
/// patterns (E6.3) still arrive with their epics, test-first.
public enum WidgetToolkit {
    /// The released package version a consumer depends on, readable at runtime (the StreakEngine
    /// convention). 1.0.0 = E6.1's timeline planner; tagged widgettoolkit-v1.0.0.
    public static let version = "1.0.0"
}
