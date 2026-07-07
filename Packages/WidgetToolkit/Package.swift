// swift-tools-version: 6.0
import PackageDescription

// Portfolio package stub (architecture §14). Real contents arrive with their epics:
// timeline-at-midnight / stale-grace / timer-text helpers (E6.1), the InstantLaunch
// intent→flag→dedicated-launch pattern (E3.1), discreet-variant patterns (E6.3).
// NOTE: the stub is Foundation-only so it tests on Linux CI; once WidgetKit imports
// land (E6.1), the package-units CI lane for this package moves to the macOS runner.
let package = Package(
    name: "WidgetToolkit",
    platforms: [.iOS("26.0"), .macOS("15.0")],
    products: [
        .library(name: "WidgetToolkit", targets: ["WidgetToolkit"])
    ],
    targets: [
        .target(name: "WidgetToolkit"),
        .testTarget(name: "WidgetToolkitTests", dependencies: ["WidgetToolkit"]),
    ],
    swiftLanguageModes: [.v6]
)
