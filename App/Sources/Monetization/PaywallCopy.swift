import Foundation

/// The bundled paywall copy (`App/Resources/Content/paywallCopy.json`) — the
/// ONE audited table for the bundled default paywall (R24.9; the
/// summaryCopy.json precedent: founder-owned DRAFT strings in the tone-review
/// queue, lexicon-scanned on every CI run). Field names mirror the JSON
/// exactly. Prices are NEVER stored here: the `…Fmt` fields carry `%@` slots
/// bound at compose time from `ProductCatalog`'s display constants (dormant/
/// offline) or live StoreKit prices (operator-keyed path) — a founder rewrite
/// can never drift the pricing (R24.5/R24.9).
struct PaywallCopy: Codable, Equatable, Sendable {
    var headline: String
    var subhead: String
    /// The audit-safe positioning register (R24.9, the S19 rule: promise only
    /// what the payload audit proves — the MVP §6 verbatim canon's "No
    /// server. Nothing to leak." is NOT placed on this RevenueCat-brokered
    /// surface; the deviation is the operator's §3 call).
    var positioning: String
    var positioningNotes: String
    var planMonthlyTitle: String
    var planAnnualTitle: String
    var trialBadge: String
    var priceMonthlyFmt: String
    var priceAnnualFmt: String
    var trialMechanicsLineFmt: String
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
    /// E7.2 (R25.8) — the teaser variant's escape affordance (the sanctioned
    /// escape R24.9 reserved; a §6.2 QuietButton below the CTA, teaser arm
    /// ONLY — the hard variant stays close-free). NON-OPTIONAL by ruling: an
    /// optional String? child dodges the Mirror lexicon walk (Brand's
    /// reproduced trap), so every teaser string stays inside the dual-lexicon
    /// gate like its 20 siblings.
    var teaserEscapeLabel: String
    /// The honest "what this does" line under the escape button — read
    /// BEFORE tapping (§1.1 no-dark-patterns). Its "Then this screen
    /// returns." promise is load-bearing: the escape is SINGLE-USE and the
    /// re-present renders close-free (R25.7).
    var teaserEscapeNote: String
    /// The zero-shame eyebrow above the headline on the teaser-expiry
    /// re-present: states the fact, reassures nothing was lost, applies no
    /// pressure — never a countdown, never loss framing (brandkit §6.8).
    var teaserExpiryEyebrow: String

    /// Decodes the shipping file from the app bundle. `nil` when missing or
    /// undecodable — the screen then renders `.degraded` (the guideline-3.1.1
    /// disclosures must survive a decode failure; the AgeGateCopy precedent).
    static func loadShipping(bundle: Bundle = .main) -> PaywallCopy? {
        guard let url = bundle.url(forResource: "paywallCopy", withExtension: "json"),
              let data = try? Data(contentsOf: url)
        else { return nil }
        return try? JSONDecoder().decode(PaywallCopy.self, from: data)
    }

    /// The §9 degraded fallback — plainer words, same disclosures, same
    /// lexicon gate (scanned alongside the shipping table).
    static let degraded = PaywallCopy(
        headline: "Keep your momentum.",
        subhead: "Your full plan — every widget, every panic tool.",
        positioning: "No account. No sign-up. Apple handles billing — cancel in one tap.",
        positioningNotes: "Your notes and journal never leave your device.",
        planMonthlyTitle: "Monthly",
        planAnnualTitle: "Yearly",
        trialBadge: "3-day free trial",
        priceMonthlyFmt: "%@ / month",
        priceAnnualFmt: "%@ / year",
        trialMechanicsLineFmt: "Free for 3 days, then %@ per year. Cancel anytime.",
        autoRenewDisclosure: "Payment is charged to your Apple Account when you confirm. Your subscription renews automatically unless you cancel at least 24 hours before the period ends. Manage or cancel anytime in your App Store account settings.",
        termsLabel: "Terms of Use",
        privacyLabel: "Privacy Policy",
        ctaTrial: "Start free trial",
        ctaMonthly: "Subscribe",
        restoreLabel: "Restore purchases",
        failureBanner: "That didn't go through. You can try again, or restore a previous purchase.",
        retryCta: "Try again",
        restoreEmpty: "No previous purchase found on this Apple Account.",
        restoreSuccess: "You're all set — your subscription is active.",
        teaserEscapeLabel: "Look around for a day",
        teaserEscapeNote: "One day of full access, then this screen returns.",
        teaserExpiryEyebrow: "Your free day is done. Everything you set up is still here."
    )
}
