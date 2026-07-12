/// The pure heart of E7.1: one snapshot in, one state out. No clock, no
/// Calendar, no TimeZone, no I/O — timezone-invariance is structural, and the
/// offline grace policy (architecture §8: "when in doubt, honor the
/// entitlement") is honored by construction because nothing here can expire a
/// state locally; a lapse only ever arrives as the source's next snapshot.
public enum EntitlementStateMapper {
    /// `nil` ⇒ `.never` (no entitlement was ever granted);
    /// present + inactive ⇒ `.lapsed`; active splits on `periodType == .trial`.
    /// `willRenew` is deliberately ignored (cancelled trials stay entitled
    /// until the source says otherwise — never a mid-trial lapse).
    public static func state(from snapshot: EntitlementSnapshot?) -> EntitlementState {
        .never // inert seam — red commit (E7.1)
    }
}
