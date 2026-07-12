import Foundation

/// E7.2 (R25.11) — the ONE config home for Superwall placement ids and the
/// dashboard variant-id mapping (the ProductCatalog SKU-constant precedent:
/// operator-console constants live in code as pinned value-domains, never
/// inline literals). E7.2 defines ONLY the post-summary placement; `winback`
/// is E7.3's row.
enum SuperwallPlacement {
    /// The post-summary trigger (architecture §5.2's `register(placement:)`
    /// vocabulary). Deliberately its OWN symbol — never reuse
    /// `AnalyticsEventKind.quizCompleted`: a Superwall dashboard trigger id
    /// and a TelemetryDeck wire name are different namespaces, and a rename
    /// of one must not silently drift the other. The operator's dashboard
    /// must carry a matching trigger (operator-expected §8).
    static let postSummary = "quiz_completed"

    /// The operator-owned dashboard mapping: Superwall's opaque
    /// `experiment.variant.id` → our semantic `{teaser, hard}` wire labels
    /// (R25.3). EMPTY until the operator builds the experiment; filled
    /// alongside the key (operator-expected §8).
    static let variantMapping: [String: PaywallVariant] = [:]

    /// The live adapter's extraction (docs-verified keypath:
    /// `PaywallInfo.experiment?.variant.id` — never `experiment.id`, never
    /// `paywallId`): an unmapped or absent id resolves to `.hard` — the
    /// control arm, the §8 when-in-doubt grace direction applied to config
    /// gaps (the unknown-SKU precedent, R24.3).
    ///
    /// RED (Session 25): inert — always `.hard`; the known-id mapping pin
    /// fails by design until green.
    static func variant(
        forSuperwallVariantID id: String?,
        mapping: [String: PaywallVariant] = variantMapping
    ) -> PaywallVariant {
        .hard
    }
}
