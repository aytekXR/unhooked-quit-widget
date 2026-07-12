/// PaywallKit 1.0.0 — first real content (E7.1, Session 23): the pure
/// entitlement state machine (never|trial|active|lapsed) over the
/// `EntitlementSource` seam, the in-memory `CachingEntitlementProvider`, and
/// the `EntitlementEvent` domain-event seam. The RevenueCat adapter and the
/// removable Superwall adapter (ADR-4) arrive with the app-wiring session and
/// E7.2 — this package stays Foundation-only on the free Linux CI lane.
public enum PaywallKit {
    /// Version marker, pinned by the package skeleton test AND the app-lane
    /// WalkingSkeletonTests — a bump moves all three literals in one commit
    /// (the S20 L9 lesson).
    public static let version = "1.0.0"
}
