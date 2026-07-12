// swift-tools-version: 6.0
import PackageDescription

// Portfolio package (architecture §14). E7.1 (Session 23) landed the entitlement
// state machine (trial|active|lapsed|never) over the EntitlementSource seam.
//
// FOUNDATION-ONLY, BY RULE (the Session 20 WidgetToolkit ruling, applied here by
// Session 23 R23.1): the RevenueCat SDK is Darwin-only (its Package.swift declares
// no Linux platform) and NEVER enters this package — the adapter lives app-side
// (ADR-4 removability; recorded exact pin for the wiring session:
// purchases-ios 5.80.3). That is what keeps this `package-units` CI lane on the
// free ubuntu runner. Pricing is config, not code — no SKU or price constants
// belong in this package (MVP §6: no lifetime, no weekly); `Product` is the
// monthly|annual TIER taxonomy only. The removable Superwall adapter is E7.2's.
let package = Package(
    name: "PaywallKit",
    platforms: [.iOS("26.0"), .macOS("15.0")],
    products: [
        .library(name: "PaywallKit", targets: ["PaywallKit"])
    ],
    targets: [
        .target(name: "PaywallKit"),
        .testTarget(name: "PaywallKitTests", dependencies: ["PaywallKit"]),
    ],
    swiftLanguageModes: [.v6]
)
