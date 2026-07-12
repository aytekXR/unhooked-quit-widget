import SnapshotTesting
import StreakEngine
import SwiftUI
import Testing
import UIKit
import WidgetToolkit
@testable import Unhooked

// E6.2 — the streak widget's family snapshot matrix (step-0 R10). The FINAL
// `StreakWidgetView` is rendered over HAND-BUILT fixtures — the composer stub is NOT in
// play, so an entry (timing) + a `WidgetQuitState` DTO (money/momentum/milestone) seed
// each family directly, exactly the two inputs the extension adapter will hand it.
//
// Matrix (step-0 R7 + R10): rectangular · circular · inline · small · medium — NO
// StandBy (mvp §3-cut). Axes: light + dark for all five; AX5 (`.accessibilityExtra-
// ExtraExtraLarge`) ADDED for small + medium ONLY — WidgetKit clamps Dynamic Type on
// the accessory families (rectangular/circular/inline), so an AX5 accessory golden
// would pin fiction (panel-verified). Plus ONE `.unavailable` golden (rectangular,
// light): the calm "Ready when you are." line, no ticker, no fabricated "Day 0".
//
// Discreet matrix (E6.3 D1-D5, R22.9): the SAME five families re-rendered over a
// `discreet: true` fixture — identical field-for-field to `quit` bar the flag. D1
// rectangular · D2 circular · D3 inline (light + dark, 2 goldens each), D4 small ·
// D5 medium (light/dark + AX5, 4 goldens each) = 14 new goldens. Predicted renders:
// D1 DROPS the money line and swaps the panic glyph to `arrow.counterclockwise`
// (a11y label "Reset"); D5 DROPS money + "saved" and BARES the milestone bar (no
// "next milestone" label); D2/D3/D4 read no discreet flag and are expected
// byte-identical to their normal goldens (regression guards). Every non-discreet
// fixture keeps `discreet` nil, so the committed E6.2 goldens are untouched.
//
// Geometry: `.image(layout: .fixed(width:height:))` with TEST-OWNED canvas constants
// (below) that APPROXIMATE the WidgetKit canvases on the pinned 6.1" device class —
// they are documented approximations, NOT system truth (WidgetKit's real canvases are
// not vended to a host app). The render environment (idiom, size classes) and the
// render scale are pinned exactly the way the flow neighbors pin them: by merging
// `ViewImageConfig.iPhone13.traits` (scale stays device-native on the CI simulator, the
// technique PanicFlow/SlipFlow rely on) with the per-axis style + Dynamic Type overrides.
//
// Determinism (step-0 R10, binding): every fixture instant is in 2025, so the day-ring
// `ProgressView(timerInterval:)` window is FULLY ELAPSED at any future CI render (a
// deterministic full ring); `pauseDate` (a fixed 2025 instant) freezes every
// `Text(timerInterval:)`; momentum is a stored constant (82) and money renders from
// fixed banked + elapsed. No wall-clock read reaches any render.
//
// References are recorded ON CI (`record: .missing` fails-while-writing on the RED run;
// the Linux dev box cannot render), retrieved from the `test-outputs` artifact, and
// committed — the §3.3 re-record discipline applies from then on.

@MainActor
@Suite(.snapshots(record: .missing))
struct StreakWidgetSnapshotTests {

    // MARK: - Canvas constants (TEST-OWNED approximations of WidgetKit canvases on the
    // pinned 6.1" device class — NOT system truth; documented per step-0 R10)

    private enum Canvas {
        /// systemSmall ≈ 158×158 pt on a 390-pt-wide device.
        static let small = CGSize(width: 158, height: 158)
        /// systemMedium ≈ 338×158 pt on a 390-pt-wide device.
        static let medium = CGSize(width: 338, height: 158)
        /// accessoryRectangular lock-screen slot ≈ 172×76 pt.
        static let rectangular = CGSize(width: 172, height: 76)
        /// accessoryCircular lock-screen slot ≈ 76×76 pt.
        static let circular = CGSize(width: 76, height: 76)
        /// accessoryInline single line ≈ 200×26 pt (the system draws it as text only).
        static let inline = CGSize(width: 200, height: 26)
    }

    // MARK: - Fixtures (fixed 2025 instants — derived in a scratch harness, epoch-exact)

    private static let quitID = UUID(uuidString: "0E32C0DE-0000-4000-8000-0000000006E2")!
    /// 2025-06-11T18:30:00-04:00 America/New_York — the guard-corrected streak origin.
    private static let streakStart = Date(timeIntervalSince1970: 1_749_681_000)
    /// 2025-07-14T14:30:00-04:00 — the entry's render moment (Day 34, 1-based calendar).
    private static let entryDate = Date(timeIntervalSince1970: 1_752_517_800)
    /// 2025-07-14T00:00:00-04:00 — the entry's local-day start (NY).
    private static let dayStart = Date(timeIntervalSince1970: 1_752_465_600)
    /// 2025-07-15T00:00:00-04:00 — the entry's local-day end (a full 24h NY day).
    private static let dayEnd = Date(timeIntervalSince1970: 1_752_552_000)
    /// Freezes `Text(timerInterval:)` at the render moment (== entryDate).
    private static let pauseDate = entryDate

    /// The rich DTO the family templates read money/momentum/milestone from.
    private static let quit = WidgetQuitState(
        id: quitID,
        streakStart: streakStart,
        timeZoneIdentifier: "America/New_York",
        weeklySpend: "26.5",
        currencyCode: "USD",
        bankedCleanSeconds: 0,
        momentumPercent: 82,
        milestoneHours: [12, 24, 72, 168, 336, 720, 2160, 8760]
    )

    /// The discreet-mode DTO — `quit` field-for-field, plus the E6.3 `discreet: true`
    /// flag (R22.1, presence-only). Seeds the D1-D5 discreet render branches; every
    /// other fixture leaves `discreet` nil, so `isDiscreet` is false there and the
    /// committed E6.2 goldens render byte-identically.
    private static let discreetQuit = WidgetQuitState(
        id: quitID,
        streakStart: streakStart,
        timeZoneIdentifier: "America/New_York",
        weeklySpend: "26.5",
        currencyCode: "USD",
        bankedCleanSeconds: 0,
        momentumPercent: 82,
        milestoneHours: [12, 24, 72, 168, 336, 720, 2160, 8760],
        discreet: true
    )

    /// The streak entry: Day 34 sitting in the full 2025-07-14 NY local day.
    private static let streakEntry = StreakWidgetEntry(
        date: entryDate,
        kind: .streak,
        dayNumber: 34,
        tickWindow: dayStart...dayEnd,
        freshness: .fresh
    )

    /// The empty state: no number, no ticker — the planner's single `.unavailable` entry.
    private static let unavailableEntry = StreakWidgetEntry(
        date: entryDate,
        kind: .unavailable,
        dayNumber: nil,
        tickWindow: nil,
        freshness: .fresh
    )

    // MARK: - Axes

    private typealias Axis = (name: String, dark: Bool, ax5: Bool)

    /// Accessory families: WidgetKit clamps their Dynamic Type, so no AX5 golden.
    private static let lightDark: [Axis] = [
        ("light", false, false),
        ("dark", true, false),
    ]

    /// Home-screen families (small/medium): the full block, AX5 included.
    private static let lightDarkAX5: [Axis] = [
        ("light", false, false),
        ("dark", true, false),
        ("light-ax5", false, true),
        ("dark-ax5", true, true),
    ]

    /// Renders one family over its axis list on a fixed test-owned canvas.
    private func assertFamily(
        _ family: StreakWidgetFamily,
        canvas: CGSize,
        entry: StreakWidgetEntry,
        quit: WidgetQuitState?,
        axes: [Axis],
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        let view = StreakWidgetView(
            family: family,
            entry: entry,
            quit: quit,
            pauseDate: Self.pauseDate
        )
        for axis in axes {
            assertSnapshot(
                of: view,
                as: .image(
                    precision: 0.99,
                    perceptualPrecision: 0.98,
                    layout: .fixed(width: canvas.width, height: canvas.height),
                    // The axis overrides via the neighbors' exact closure-init form —
                    // `UITraitCollection(traitsFrom:)` is deprecated in iOS 17 and
                    // warnings are errors (this exact line burned billed run
                    // 29178893738; the flow neighbors never carried a traits merge:
                    // under `.fixed` the render scale is device-native on the pinned
                    // CI simulator, identical to the `.device(config:)` neighbors).
                    traits: UITraitCollection { traits in
                        traits.userInterfaceStyle = axis.dark ? .dark : .light
                        traits.preferredContentSizeCategory = axis.ax5
                            ? .accessibilityExtraExtraExtraLarge
                            : .large
                    }
                ),
                named: axis.name,
                fileID: fileID,
                file: filePath,
                testName: testName,
                line: line,
                column: column
            )
        }
    }

    // MARK: - Family matrix (F1–F5)

    @Test func snapshot_rectangularFamily() {
        // Lock-screen flagship: Day 34 + money saved + the interactive panic button.
        assertFamily(
            .rectangular, canvas: Canvas.rectangular,
            entry: Self.streakEntry, quit: Self.quit, axes: Self.lightDark
        )
    }

    @Test func snapshot_circularFamily() {
        // The day ring: center "34", ring fully elapsed (2025 window → deterministic).
        assertFamily(
            .circular, canvas: Canvas.circular,
            entry: Self.streakEntry, quit: Self.quit, axes: Self.lightDark
        )
    }

    @Test func snapshot_inlineFamily() {
        // One line of text: "Day 34".
        assertFamily(
            .inline, canvas: Canvas.inline,
            entry: Self.streakEntry, quit: Self.quit, axes: Self.lightDark
        )
    }

    @Test func snapshot_smallFamily() {
        // Home small: Day 34 + frozen ticking duration + the momentum ring (82%).
        assertFamily(
            .small, canvas: Canvas.small,
            entry: Self.streakEntry, quit: Self.quit, axes: Self.lightDarkAX5
        )
    }

    @Test func snapshot_mediumFamily() {
        // Home medium: the small content plus money and the milestone progress bar.
        assertFamily(
            .medium, canvas: Canvas.medium,
            entry: Self.streakEntry, quit: Self.quit, axes: Self.lightDarkAX5
        )
    }

    // MARK: - Unavailable state (step-0 R10: one golden, rectangular · light)

    @Test func snapshot_unavailableState() {
        // Fresh install / post-erase: the calm line, no ticker, no fabricated day.
        assertFamily(
            .rectangular, canvas: Canvas.rectangular,
            entry: Self.unavailableEntry, quit: nil, axes: [("light", false, false)]
        )
    }

    // MARK: - Discreet matrix (D1-D5) — Session 22

    @Test func snapshot_rectangularFamily_discreet() {
        // D1 — lock-screen flagship, discreet: Day 34 + the reset panic button
        // (`arrow.counterclockwise`, a11y "Reset"); the money line is DROPPED
        // (`showsMoney(for:)` is false under discreet).
        assertFamily(
            .rectangular, canvas: Canvas.rectangular,
            entry: Self.streakEntry, quit: Self.discreetQuit, axes: Self.lightDark
        )
    }

    @Test func snapshot_circularFamily_discreet() {
        // D2 — the day ring reads no discreet flag: expected VISUALLY IDENTICAL to the
        // normal circular golden (regression guard that discreet leaves it untouched).
        assertFamily(
            .circular, canvas: Canvas.circular,
            entry: Self.streakEntry, quit: Self.discreetQuit, axes: Self.lightDark
        )
    }

    @Test func snapshot_inlineFamily_discreet() {
        // D3 — one line "Day 34"; the inline body reads no discreet flag, so this is
        // expected IDENTICAL to the normal inline golden (regression guard).
        assertFamily(
            .inline, canvas: Canvas.inline,
            entry: Self.streakEntry, quit: Self.discreetQuit, axes: Self.lightDark
        )
    }

    @Test func snapshot_smallFamily_discreet() {
        // D4 — Day 34 + frozen ticker + momentum ring; the small body reads no discreet
        // flag, so this is expected IDENTICAL to the normal small golden (regression
        // guard). AX5 included: home-screen families do not clamp Dynamic Type.
        assertFamily(
            .small, canvas: Canvas.small,
            entry: Self.streakEntry, quit: Self.discreetQuit, axes: Self.lightDarkAX5
        )
    }

    @Test func snapshot_mediumFamily_discreet() {
        // D5 — home medium, discreet: money and "saved" ABSENT; the milestone bar is
        // present but BARE — its "next milestone" label is dropped
        // (`showsMilestoneLabel(for:)` is false under discreet).
        assertFamily(
            .medium, canvas: Canvas.medium,
            entry: Self.streakEntry, quit: Self.discreetQuit, axes: Self.lightDarkAX5
        )
    }
}
