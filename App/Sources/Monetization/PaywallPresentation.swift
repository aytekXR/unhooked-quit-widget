import Foundation

/// What the bundled default paywall actually renders (the SummaryViewData
/// precedent: the view is a thin renderer over composed data). The
/// guideline-3.1.1/3.1.2(c) disclosures — plan titles, billing period +
/// price, trial length + what follows it, the auto-renewal statement, the
/// Terms/Privacy links, the restore mechanism — are all COMPOSED fields here,
/// so their presence is a pure string assertion (test-suite §4.4), never a
/// pixel hunt.
struct PaywallViewData: Equatable, Sendable {
    var headline: String
    var subhead: String
    var positioning: String
    var positioningNotes: String
    var planMonthlyTitle: String
    var planAnnualTitle: String
    var trialBadge: String
    /// "$6.99 / month" — the `%@` template bound to the catalog constant
    /// (dormant) or the live StoreKit display price (operator-keyed path).
    var priceMonthlyLine: String
    /// "$29.99 / year" — the CONTROL arm only (architecture §8: the bundled
    /// fallback never shows the $39.99 Superwall arm).
    var priceAnnualLine: String
    /// "Free for 3 days, then $29.99 per year. Cancel anytime."
    var trialMechanicsLine: String
    var autoRenewDisclosure: String
    var termsLabel: String
    var privacyLabel: String
    var ctaTrial: String
    var ctaMonthly: String
    var restoreLabel: String
    var failureBanner: String
    var retryCta: String
    var restoreEmpty: String
    var restoreSuccess: String
}

/// Pure copy+catalog → view data assembly (the SummaryPresentation twin —
/// Foundation-only, Linux-harnessable).
///
/// RED (Session 24): inert — vends empty strings, so the guideline-3.1.1
/// presence pins in `PaywallCopyTests` fail by design until green.
enum PaywallPresentation {
    static func make(copy: PaywallCopy) -> PaywallViewData {
        PaywallViewData(
            headline: "", subhead: "", positioning: "", positioningNotes: "",
            planMonthlyTitle: "", planAnnualTitle: "", trialBadge: "",
            priceMonthlyLine: "", priceAnnualLine: "", trialMechanicsLine: "",
            autoRenewDisclosure: "", termsLabel: "", privacyLabel: "",
            ctaTrial: "", ctaMonthly: "", restoreLabel: "", failureBanner: "",
            retryCta: "", restoreEmpty: "", restoreSuccess: ""
        )
    }
}
