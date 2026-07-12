// swift-tools-version: 6.0
import PackageDescription

// Portfolio package (architecture §14). E6.1 landed the timeline planner (local-midnight/DST
// day rollover, stale-grace, ticking windows); the InstantLaunch intent→flag→dedicated-launch
// pattern (E3.1) and the discreet-variant patterns (E6.3) arrive with their epics.
//
// FOUNDATION-ONLY, BY RULE — do not import WidgetKit or SwiftUI here (Session 20 ruling).
// This package's `package-units` CI lane runs in a Linux container at 1x; a WidgetKit import
// would force it onto the macOS runner, which bills at 10x on this private repo. WidgetKit is
// an ADAPTER concern: the `TimelineProvider` conformance and the SwiftUI templates live in the
// app's widget extension, which is exactly what the E6.1 acceptance criterion asks for
// ("rollover/stale logic lives in WidgetToolkit, only templates live in the app"). Calendar and
// TimeZone ARE Foundation and Linux carries the full tz database, so DST is testable for free.
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
