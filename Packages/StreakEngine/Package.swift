// swift-tools-version: 6.0
import PackageDescription

// Portfolio package stub (architecture §14). Unhooked is the anchor consumer that
// defines the v1 API; the real engine (streak math, monotonic clock integrity, slip
// archiving/undo, Reduce adherence) is Epic 1, strictly TDD-first. Extraction to its
// own repo happens when a second consumer (Vigil/Vakit/Keeper) appears.
// Package rule: zero I/O, zero Apple-framework imports beyond Foundation.
let package = Package(
    name: "StreakEngine",
    platforms: [.iOS("26.0"), .macOS("15.0")],
    products: [
        .library(name: "StreakEngine", targets: ["StreakEngine"])
    ],
    targets: [
        .target(name: "StreakEngine"),
        .testTarget(name: "StreakEngineTests", dependencies: ["StreakEngine"]),
    ],
    swiftLanguageModes: [.v6]
)
