// swift-tools-version: 6.0
import PackageDescription

// Portfolio package (architecture §14): streak math, monotonic clock integrity, slip
// archiving/undo, allowance adherence — built TDD-first with Unhooked as the anchor
// consumer defining the v1 API. Extraction to its own repo happens when a second
// consumer (Vigil/Vakit/Keeper) appears.
// Package rule: zero I/O, zero Apple-framework imports beyond Foundation.
let package = Package(
    name: "StreakEngine",
    // Portfolio floor, deliberately BELOW the anchor app's iOS 26: pure Foundation math
    // needs nothing newer than the Swift 6 stdlib (iOS 18 / macOS 15 — one release
    // train). Lowering further on first consumer need is non-breaking; raising is not.
    platforms: [.iOS("18.0"), .macOS("15.0")],
    products: [
        .library(name: "StreakEngine", targets: ["StreakEngine"])
    ],
    targets: [
        .target(name: "StreakEngine"),
        .testTarget(name: "StreakEngineTests", dependencies: ["StreakEngine"]),
    ],
    swiftLanguageModes: [.v6]
)
