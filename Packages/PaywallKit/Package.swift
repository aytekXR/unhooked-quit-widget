// swift-tools-version: 6.0
import PackageDescription

// Portfolio package stub (architecture §14). The entitlement state machine
// (trial|active|lapsed|never), RevenueCat wrapper, and the removable Superwall
// adapter (ADR-4) arrive in E7.1/E7.2, test-first. Pricing is config, not code —
// no SKU constants belong in this package (MVP §6: no lifetime, no weekly).
// NOTE: Foundation-only until the RevenueCat dependency lands (E7.1); the package
// tests on Linux CI until then.
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
