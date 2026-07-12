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
/// Foundation-only, Linux-harnessable). The `%@` templates bind the catalog's
/// static CONTROL-arm display prices (architecture §8: the bundled fallback
/// renders offline/dormant); the live operator-keyed path may later upgrade
/// the lines to localized StoreKit display prices — never the other way.
enum PaywallPresentation {
    static func make(copy: PaywallCopy) -> PaywallViewData {
        PaywallViewData(
            headline: copy.headline,
            subhead: copy.subhead,
            positioning: copy.positioning,
            positioningNotes: copy.positioningNotes,
            planMonthlyTitle: copy.planMonthlyTitle,
            planAnnualTitle: copy.planAnnualTitle,
            trialBadge: copy.trialBadge,
            priceMonthlyLine: bind(copy.priceMonthlyFmt, ProductCatalog.monthlyDisplayPrice),
            priceAnnualLine: bind(copy.priceAnnualFmt, ProductCatalog.annualControlDisplayPrice),
            trialMechanicsLine: bind(copy.trialMechanicsLineFmt, ProductCatalog.annualControlDisplayPrice),
            autoRenewDisclosure: copy.autoRenewDisclosure,
            termsLabel: copy.termsLabel,
            privacyLabel: copy.privacyLabel,
            ctaTrial: copy.ctaTrial,
            ctaMonthly: copy.ctaMonthly,
            restoreLabel: copy.restoreLabel,
            failureBanner: copy.failureBanner,
            retryCta: copy.retryCta,
            restoreEmpty: copy.restoreEmpty,
            restoreSuccess: copy.restoreSuccess
        )
    }

    /// One `%@` slot, bound without a locale pass — the display price is a
    /// catalog CONSTANT (already a rendered string), not a number to format.
    private static func bind(_ template: String, _ price: String) -> String {
        template.replacingOccurrences(of: "%@", with: price)
    }
}
