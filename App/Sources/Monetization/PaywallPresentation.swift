import Foundation

/// E7.2 (R25.7/R25.8) — the teaser variant's escape affordance, as DATA:
/// present ⇒ the teaser arm's first impression renders the QuietButton escape
/// below the CTA; nil ⇒ the hard variant OR the single-use re-present (the
/// escape never returns — "Then this screen returns." must stay true).
struct TeaserEscapeData: Equatable, Sendable {
    var label: String
    var note: String
}

/// E7.3 (R26.9) — the win-back offer block, as DATA: non-nil ⇒ the paywall
/// renders the offer line, the two-price mechanics line (discounted AND
/// renewal — the 3.1.2(c)-grade disclosure), the reassurance, and the
/// dismiss affordance (R26.6: an OFFER is dismissible; the walls stay
/// close-free). Composed ONLY on `source == .winback`.
struct WinbackOfferData: Equatable, Sendable {
    var offerLine: String
    var mechanicsLine: String
    var reassurance: String
    var dismissLabel: String
}

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
    /// Non-nil ONLY on the teaser arm's FIRST impression (R25.7 single-use;
    /// the hard variant and every re-present are close-free — R24.9 carried).
    var teaserEscape: TeaserEscapeData?
    /// Non-nil ONLY on the teaser-expiry re-present (source `.teaserExpiry`):
    /// the zero-shame acknowledgment eyebrow above the headline.
    var expiryEyebrow: String?
    /// E7.3 (R26.9): non-nil ONLY on the win-back surface (source
    /// `.winback`) — unreachable dormant (no keys ⇒ no lapse ⇒ never
    /// composed, R26.10). The teaser escape never co-composes with it
    /// (fork isolation).
    var winbackOffer: WinbackOfferData?
}

/// Pure copy+catalog → view data assembly (the SummaryPresentation twin —
/// Foundation-only, Linux-harnessable). The `%@` templates bind the catalog's
/// static CONTROL-arm display prices (architecture §8: the bundled fallback
/// renders offline/dormant); the live operator-keyed path may later upgrade
/// the lines to localized StoreKit display prices — never the other way.
enum PaywallPresentation {
    /// E7.2 (R25.8): `variant`/`source` drive the teaser fork — defaults keep
    /// every E7.1 call site (and its pins) byte-compatible: `.hard` +
    /// `.onboarding` compose exactly the S24 screen. The teaser arm's first
    /// impression adds the escape; the `.teaserExpiry` re-present adds the
    /// eyebrow and NEVER the escape (single-use, R25.7 — "Then this screen
    /// returns." must stay true); the hard variant composes neither
    /// (close-free, R24.9 carried).
    static func make(
        copy: PaywallCopy,
        variant: PaywallVariant = .hard,
        source: PaywallSource = .onboarding
    ) -> PaywallViewData {
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
            restoreSuccess: copy.restoreSuccess,
            // E7.3 (R26.9) fork isolation: the winback surface never
            // co-composes the teaser escape — one surface, one affordance
            // set (the offer's dismiss is the winback arm's affordance).
            teaserEscape: variant == .teaser && source != .teaserExpiry && source != .winback
                ? TeaserEscapeData(label: copy.teaserEscapeLabel, note: copy.teaserEscapeNote)
                : nil,
            expiryEyebrow: source == .teaserExpiry ? copy.teaserExpiryEyebrow : nil,
            winbackOffer: source == .winback
                ? WinbackOfferData(
                    offerLine: copy.winbackOfferLine,
                    mechanicsLine: bind(
                        copy.winbackMechanicsLineFmt,
                        ProductCatalog.annualWinbackDisplayPrice,
                        ProductCatalog.annualControlDisplayPrice
                    ),
                    reassurance: copy.winbackReassurance,
                    dismissLabel: copy.winbackDismissLabel
                )
                : nil
        )
    }

    /// One `%@` slot, bound without a locale pass — the display price is a
    /// catalog CONSTANT (already a rendered string), not a number to format.
    private static func bind(_ template: String, _ price: String) -> String {
        template.replacingOccurrences(of: "%@", with: price)
    }

    /// TWO `%@` slots in order — the discounted first-year price, then the
    /// renewal price (the winback mechanics line's 3.1.2(c)-grade pair,
    /// R26.9). Positional replacement: prices are catalog constants and
    /// never themselves contain a slot.
    private static func bind(_ template: String, _ first: String, _ second: String) -> String {
        var bound = template
        if let slot = bound.range(of: "%@") { bound.replaceSubrange(slot, with: first) }
        if let slot = bound.range(of: "%@") { bound.replaceSubrange(slot, with: second) }
        return bound
    }
}
