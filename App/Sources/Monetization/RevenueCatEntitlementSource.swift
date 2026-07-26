import Foundation
import OSLog
import PaywallKit
import RevenueCat

// E7.1 app half (Session 24) — THE one RevenueCat-importing file in the whole
// app (R24.3/R24.11; the AppIconComposition/UIKit sole-importer precedent —
// the free-lane `monetization-importer-lint` enforces it). Every SDK member
// below was verified VERBATIM against the purchases-ios 5.80.3 source at tag
// commit e616eb4 (the Session 24 docs-verifier table; standing S22/S23 rule:
// a spelling the source does not confirm does not exist).
//
// DORMANT discipline (R24.2): nothing in this file runs unless the operator's
// key is present — `configure` alone fires network (CustomerInfo + Offerings
// from api.revenuecat.com) and persists a $RCAnonymousID to NSUserDefaults,
// so the key-absent branch in `RepositoryProvider.startIfNeeded` never
// references these symbols at runtime.

/// The ~20-line adapter filling PaywallKit's `EntitlementSource` seam (ADR-4
/// removability). Stateless: `Purchases.shared` is resolved inline per call —
/// never stored, never captured in a @Sendable closure (the reproduced
/// strict-concurrency trap).
struct RevenueCatEntitlementSource: EntitlementSource {
    /// The ONE configure call (composition-injected so the dormant-gate tests
    /// count it without importing RC). `automaticDeviceIdentifierCollection`
    /// is switched OFF (its Builder default is true — 5.80.3
    /// Configuration.swift:158): a no-account app collects no device
    /// identifier it doesn't need, and the SDK's own privacy manifest
    /// declares none (docs-verifier D-8).
    static func configure(apiKey: String) {
        Purchases.configure(
            with: Configuration.Builder(withAPIKey: apiKey)
                .with(automaticDeviceIdentifierCollectionEnabled: false)
                .build()
        )
    }

    func currentSnapshot() async throws -> EntitlementSnapshot? {
        RevenueCatEntitlementMapper.snapshot(
            from: Self.entitlementView(of: try await Purchases.shared.customerInfo())
        )
    }

    func restore() async throws -> EntitlementSnapshot? {
        // async restorePurchases returns NON-optional CustomerInfo (5.80.3
        // PurchasesType.swift:488); "nothing restored" surfaces as an absent
        // entitlement, mapping to nil → `.never`.
        RevenueCatEntitlementMapper.snapshot(
            from: Self.entitlementView(of: try await Purchases.shared.restorePurchases())
        )
    }

    func reset() async throws {
        // v5.80.3 exposes NO public anonymous-ID reset (`logOut()` throws
        // ErrorCode 22 for anonymous users — our only user type). The honest
        // SDK-side clear is the customer-info cache invalidation; entitlements
        // are Apple-account-level and survive erase by design (a wipe is not
        // a cancellation — see the eraseEverything() step-5 note).
        Purchases.shared.invalidateCustomerInfoCache()
    }

    /// The EntitlementInfo → neutral-view extraction: reads `.all` (NOT
    /// `.active` — a present-but-inactive entitlement must surface
    /// `isActive: false`, never vanish into nil; the twice-documented S23
    /// seam nuance, contract-pinned in Contract_RevenueCat).
    static func entitlementView(of customerInfo: CustomerInfo) -> CustomerEntitlementView? {
        guard let info = customerInfo.entitlements.all[ProductCatalog.entitlementKey] else {
            return nil
        }
        return CustomerEntitlementView(
            productIdentifier: info.productIdentifier,
            periodType: periodType(from: info.periodType),
            isActive: info.isActive,
            willRenew: info.willRenew
        )
    }

    /// RC PeriodType → PaywallKit's mirror (value sets identical at 5.80.3:
    /// normal|intro|trial|prepaid). `@unknown default` maps ACTIVE-safe
    /// `.normal` — consistent with the S23 ruling that only `.trial` gates
    /// trial-ness and doubt honors the entitlement. Return type via the
    /// alias — `PaywallKit.PeriodType` resolves to the version-marker ENUM,
    /// not the module (the run-3 burn; see CustomerEntitlementView).
    static func periodType(from rcPeriodType: RevenueCat.PeriodType) -> EntitlementPeriodType {
        switch rcPeriodType {
        case .normal: .normal
        case .intro: .intro
        case .trial: .trial
        case .prepaid: .prepaid
        @unknown default: .normal
        }
    }
}

/// The bundled paywall's live purchase/restore actions (R24.10) — same file
/// BY RULE (the sole-RC-importer discipline). Only ever constructed on the
/// operator-keyed path; the DEBUG render override injects inert actions.
enum RevenueCatPurchaser {
    /// S48 — the diagnostic seam. Every failure arm below used to `return
    /// .failed` with no trace, so "Apple has not propagated the products yet",
    /// "the RC dashboard offering is not Current", "our SKU is missing from the
    /// offering" and "the purchase itself was rejected" were INDISTINGUISHABLE
    /// — from the user's banner and from the operator's side alike. The S48
    /// sandbox session burned an hour on exactly that ambiguity.
    ///
    /// Failure paths only: a healthy purchase logs nothing. This carries no
    /// user content — SKUs, offering identifiers and error codes are the whole
    /// payload, none of it habit-shaped, so the discreet rule is unaffected and
    /// this is safe in release (where it is also most useful: a shipped
    /// purchase failure is otherwise invisible forever).
    private static let log = Logger(
        subsystem: AppIdentifiers.loggingSubsystem, category: "Purchase"
    )

    /// S48 — the live, LOCALIZED display prices for the paywall's `%@` slots.
    ///
    /// `localizedPriceString` (5.80.3 StoreProduct.swift:90, and
    /// StoreProductDiscount.swift:76 for the win-back arm) is Apple's own
    /// rendered price for the CURRENT STOREFRONT — correct currency, correct
    /// symbol placement, correct locale grouping. Binding it is the whole fix
    /// for the operator's device finding: the paywall used to claim "$29.99"
    /// worldwide while Apple's purchase sheet charged the real local price.
    ///
    /// Fails SOFT and per-field: anything not fetched keeps the catalog
    /// constant. A price that cannot be read is never a reason to block the
    /// screen — the wall must still render, and the disclosure lines must still
    /// carry SOMETHING. (It also means a dormant/offline build is unchanged.)
    /// The one thing this must never do is show a price from the WRONG
    /// product, so each field is keyed to its own SKU.
    static func displayPrices() async -> PaywallDisplayPrices {
        var prices = PaywallDisplayPrices.catalogFallback
        do {
            let packages = try await Purchases.shared.offerings().current?.availablePackages ?? []
            func product(_ sku: String) -> StoreProduct? {
                packages.first { $0.storeProduct.productIdentifier == sku }?.storeProduct
            }
            if let monthly = product(ProductCatalog.monthlySKU) {
                prices.monthly = monthly.localizedPriceString
            }
            if let annual = product(ProductCatalog.annualSKU) {
                prices.annual = annual.localizedPriceString
                // The win-back's first-year price lives on the SAME SKU as a
                // discount (R26.2), so it is only readable once ASC carries the
                // promotional offer; absent, the constant stands.
                if let discount = annual.discounts
                    .first(where: { $0.offerIdentifier == ProductCatalog.winbackOfferID }) {
                    prices.winbackFirstYear = discount.localizedPriceString
                }
            }
        } catch {
            let ns = error as NSError
            log.error(
                "displayPrices: threw, falling back to catalog constants — domain=\(ns.domain, privacy: .public) code=\(ns.code, privacy: .public)"
            )
        }
        return prices
    }

    /// The bundled fallback offers monthly + the CONTROL annual only
    /// (architecture §8) — the $39.99 arm is Superwall's to assign (E7.2).
    static func purchase(plan: PaywallModel.Plan) async -> PurchaseOutcome {
        let sku = switch plan {
        case .monthly: ProductCatalog.monthlySKU
        case .annual: ProductCatalog.annualSKU
        }
        do {
            let offerings = try await Purchases.shared.offerings()
            guard let package = (offerings.current?.availablePackages ?? [])
                .first(where: { $0.storeProduct.productIdentifier == sku })
            else {
                // Offerings reachable but our SKU absent (dashboard drift):
                // the never-trap failure surface — retry + restore both live.
                //
                // S48: the two sub-causes look identical from here and are
                // fixed in completely different places, so name them both.
                // `current == nil` means the RC dashboard has no offering
                // marked Current; a non-empty list without our SKU means the
                // offering exists but does not carry it (or Apple has not
                // served the product yet, which drops it from the list).
                let offering = offerings.current?.identifier ?? "<nil>"
                let available = (offerings.current?.availablePackages ?? [])
                    .map { $0.storeProduct.productIdentifier }
                    .joined(separator: ",")
                log.error(
                    "purchase: SKU absent from current offering — sku=\(sku, privacy: .public) currentOffering=\(offering, privacy: .public) available=[\(available, privacy: .public)]"
                )
                return .failed
            }
            let result = try await Purchases.shared.purchase(package: package)
            if result.userCancelled { return .cancelled }
            return .completed(
                EntitlementStateMapper.state(
                    from: RevenueCatEntitlementMapper.snapshot(
                        from: RevenueCatEntitlementSource.entitlementView(of: result.customerInfo)
                    )
                )
            )
        } catch {
            // S48: the RC `ErrorCode` integer is the actual answer here — e.g.
            // 23 `configurationError` ("none of the products could be fetched
            // from App Store Connect"), which is what an unpropagated or
            // misconfigured catalog produces, versus a genuine store/payment
            // rejection. Without it every cause reads as "try again".
            let ns = error as NSError
            log.error(
                "purchase: threw — sku=\(sku, privacy: .public) domain=\(ns.domain, privacy: .public) code=\(ns.code, privacy: .public) desc=\(ns.localizedDescription, privacy: .public)"
            )
            return .failed
        }
    }

    static func restore() async -> PurchaseOutcome {
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            return .completed(
                EntitlementStateMapper.state(
                    from: RevenueCatEntitlementMapper.snapshot(
                        from: RevenueCatEntitlementSource.entitlementView(of: customerInfo)
                    )
                )
            )
        } catch {
            let ns = error as NSError
            log.error(
                "restore: threw — domain=\(ns.domain, privacy: .public) code=\(ns.code, privacy: .public) desc=\(ns.localizedDescription, privacy: .public)"
            )
            return .failed
        }
    }

    /// S29 (R29.6) — E7.3's named deferral, closed app-side: the SIGNED
    /// win-back purchase. The ASC promotional offer (`winback_annual`,
    /// pay-up-front $14.99/1yr on the SAME control annual SKU — R26.2) is
    /// RC-signed SERVER-side: `promotionalOffer(forProductDiscount:product:)`
    /// POSTs to RC's /offers endpoint and needs the operator's In-App
    /// Purchase Key on the RC dashboard (5.80.3
    /// PurchasesOrchestrator.swift:2111, source-verified; there is no
    /// offline/local signing path in the SDK — the live authorization stays
    /// key-gated, §8). Keyless builds never reach here (the live paywall
    /// path never composes; the DEBUG render injects inert actions).
    ///
    /// A missing discount on the fetched product (ASC/dashboard drift) fails
    /// HONESTLY: after "half price" copy, silently charging full price would
    /// betray the screen — `.failed` keeps the never-trap surface (retry +
    /// restore both reachable) instead. Vetoable ruling, recorded S29.
    static func purchaseWinback() async -> PurchaseOutcome {
        do {
            let offerings = try await Purchases.shared.offerings()
            guard let package = (offerings.current?.availablePackages ?? [])
                .first(where: { $0.storeProduct.productIdentifier == ProductCatalog.annualSKU })
            else {
                let offering = offerings.current?.identifier ?? "<nil>"
                log.error(
                    "winback: annual SKU absent from current offering — currentOffering=\(offering, privacy: .public)"
                )
                return .failed
            }
            guard let discount = package.storeProduct.discounts
                .first(where: { $0.offerIdentifier == ProductCatalog.winbackOfferID })
            else {
                // S48: this is the "ASC promotional offer missing or renamed"
                // arm — the one the §8 runbook's exact-string warning exists
                // for. Naming the offers we DID find turns a silent failure
                // into a one-glance answer.
                let found = package.storeProduct.discounts
                    .map { $0.offerIdentifier ?? "<nil>" }
                    .joined(separator: ",")
                log.error(
                    "winback: offer '\(ProductCatalog.winbackOfferID, privacy: .public)' not on the product — discounts=[\(found, privacy: .public)]"
                )
                return .failed
            }
            let signed = try await Purchases.shared.promotionalOffer(
                forProductDiscount: discount,
                product: package.storeProduct
            )
            let result = try await Purchases.shared.purchase(
                package: package,
                promotionalOffer: signed
            )
            if result.userCancelled { return .cancelled }
            return .completed(
                EntitlementStateMapper.state(
                    from: RevenueCatEntitlementMapper.snapshot(
                        from: RevenueCatEntitlementSource.entitlementView(of: result.customerInfo)
                    )
                )
            )
        } catch {
            let ns = error as NSError
            log.error(
                "winback: threw — domain=\(ns.domain, privacy: .public) code=\(ns.code, privacy: .public) desc=\(ns.localizedDescription, privacy: .public)"
            )
            return .failed
        }
    }
}
