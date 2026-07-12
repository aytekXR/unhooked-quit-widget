/// The four-state entitlement machine the plan names (trial|active|lapsed|never),
/// with the associated product tier test-suite §4.3 requires
/// (`.active(product: .annual)`). No associated dates BY RULING (Session 23
/// privacy MUST-FIX: a Date payload here would tempt the app to transmit a
/// wall-clock purchase instant; trial-expiry UI is a named future decision for
/// the wiring session, additive then if earned).
public enum EntitlementState: Sendable, Equatable {
    /// No entitlement has ever existed for this user.
    case never
    /// Entitled via the free trial (annual-only per MVP §6).
    case trial(product: Product)
    /// Entitled via a paid period.
    case active(product: Product)
    /// An entitlement existed and is no longer active.
    case lapsed(product: Product)

    /// The ONE boolean consumers gate on — and the future source of the
    /// app-side PanicSnapshot mirror bit (architecture §3; that mirror is a
    /// §10 field-set change owned by the wiring session, never this package).
    public var isEntitled: Bool {
        false // inert seam — red commit (E7.1); green makes trial/active true
    }
}
