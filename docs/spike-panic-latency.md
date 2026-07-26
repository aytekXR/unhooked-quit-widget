# Spike: Panic-Latency Measurement (E0.3 / ADR-6 / Roadmap M0)

| Field | Value |
|---|---|
| Document | Spike record v0.1 — **VERDICT PENDING device run** |
| Created | 2026-07-07 (Session 02) |
| Owner | Operator (physical-device execution) + Architect (threshold decision) |
| Decides | Whether "<2s" ships as marketing copy or degrades to "fast" (feasibility §6 risk 6; roadmap Phase 0) |

## Question

Cold lock-to-intervention: widget/control tap → `OpenPanicIntent` → app launch →
panic placeholder first frame, on **iPhone 15-class hardware** (and ideally the
oldest iOS 26-capable iPhone, per MVP §7: "<2.0s cold on the oldest supported
device, 10/10 attempts").

## Harness (shipped in this repo)

1. **Signpost** — subsystem `com.beyondkaira.ballast` (`AppIdentifiers.loggingSubsystem`;
   the former placeholder `dev.placeholder.quitwidget` was retired at Gate G0, 2026-07-08,
   and was never registered — filtering Instruments by it finds nothing), category
   `PanicLaunch`, interval `PanicColdLaunch` (begins in `UnhookedApp.init` via
   `PanicLaunchTrace.begin()`, ends on `PanicPlaceholderView.onAppear`). Visible in
   Instruments' os_signpost lane.
2. **Automated proxy** — `PanicLatencyDeviceTests.test_panicColdLaunch_signpost_under2000ms`
   (UI-test target): 10 forced-panic cold launches, prints all samples + p90,
   asserts p90 < 2000ms. Skips on simulator by design (simulators lie about cold
   launch, test-suite §1.5). This measures the app-owned share of the budget
   (process launch → panic frame); it cannot drive the real lock screen.
3. **Manual lock-screen pass** — the authoritative end-to-end number, including the
   OS's intent→launch phase (architecture §11 budgets it ~500–800ms, OS-owned).

## Operator runbook

1. On a Mac with Xcode 26: `brew install xcodegen && xcodegen generate`.
2. Signing: select your Apple Developer team on the app + widget targets (Xcode
   automatic signing). The bundle/App Group IDs are now the registered
   `com.beyondkaira` identifiers (Gate G0 cleared 2026-07-08) — no longer the
   retired `dev.placeholder.quitwidget` throwaways. For a quick install on a
   *personal* team you may instead let Xcode auto-manage a bundle ID; the latency
   numbers are identity-independent either way.
3. Run to a physical iPhone 15-class device once so the app + widget install.
4. Add the panic control (Control Center / lock screen) and the accessoryRectangular
   "Streak" widget to the lock screen. Verify both render and the button exists
   (E0.3 acceptance: ControlWidget registration verified manually).
5. Automated pass: run `PanicLatencyDeviceTests` against the device
   (`xcodebuild test -project Unhooked.xcodeproj -scheme Unhooked -destination
   'platform=iOS,id=<UDID>' -only-testing:UnhookedUITests/PanicLatencyDeviceTests`).
   Transcribe the printed samples + p90 below.
6. Manual pass: lock the phone; cold-condition the app (reboot, or leave overnight);
   tap the lock-screen panic button; capture the `PanicColdLaunch` signpost interval
   in Instruments (or count frames on a screen recording). 10 attempts. Record below.
7. With notifications denied and a Focus mode on, repeat once — the panic path must
   not care (PRD §11).

## Results (fill in — device run pending)

| # | Surface | Device / iOS | Cold? | ms |
|---|---|---|---|---|
| 1–10 | lock-screen widget button | _pending_ | _pending_ | _pending_ (operator + Instruments — the authoritative pass) |
| 1–10 | automated proxy (p90) | iPhone 17 Pro Max / iOS 27, **Debug** | forced-panic relaunch | **2483** — but see below: ~2360 of it is harness, not app |
| 1–10 | **control: normal launch (S48, NEW)** | same device/build | plain relaunch, no `FORCE_PANIC_ROUTE` | **2379** |
| — | **⇒ panic route's app-owned cost** | same device/build | p90 delta | **≈ 104 ms** |

### S48 — the first real device run, and what it actually showed

**The harness had never run on a device at all.** `UnhookedUITests` carried no
`PRODUCT_BUNDLE_IDENTIFIER`; the simulator lanes (all of CI) do not need one, so the
gap stayed invisible for 47 sessions, while a device run failed the BUILD —
"UnhookedUITests doesn't have a bundle identifier" — before a single test executed.
So this item was carried as "the operator hasn't measured it" when it was closer to
"it could not be measured." Fixed in `project.yml` (S48); the id is
`com.beyondkaira.ballast.uitests` and the change is CI-neutral.

**The first number looked like a failure and was not one.** The panic run returned
p90 = 2505 ms against a 2000 ms bar. But nine of ten samples sat inside a 38 ms band
(2467–2505) with one first-launch outlier at 6609. Cold-launch work does not have
38 ms of spread; a hard floor with near-zero variance is the signature of a fixed
cost, and the fixed cost is INSIDE the measurement window —
`XCUIApplication.launch()` is not a bare process spawn, it also performs XCTest's
automation-session attach and the accessibility/quiescence handshake before it
returns.

**The control proves it.** A byte-identical run with `FORCE_PANIC_ROUTE` removed
(`test_normalColdLaunch_controlBaseline_forPanicDelta`) returned p90 = 2379 ms — the
same floor, on a launch that does no panic work at all. Subtracting cancels the
fixed term: **the panic route costs ≈ 104 ms (p90) / ≈ 121 ms (mean) of app-owned
work.** Not 2.5 seconds.

**What this does NOT answer.** Total lock-to-intervention is still unmeasured. This
harness cannot answer it: its floor swamps the very quantity in question, it cannot
tap a real lock-screen widget, and it never sees the OS's intent→launch phase
(architecture §11 budgets that at ~500–800 ms, OS-owned). The authoritative number
is still the manual Instruments pass in the runbook above. A Release-configuration
run was attempted and is impossible as the project stands — the unit/snapshot
targets use `@testable import Unhooked`, which needs `ENABLE_TESTABILITY`, off in
Release; measuring Release would mean building the UI-test target against a Release
app separately.

**⚠️ Binding consequence for E3.1.** The plan of record graduates this test into a
permanent CI gate on its raw p90. **It must not gate on the raw figure** — that
pins XCTest's launch overhead, not the product's latency, and it would fail at
2000 ms today for reasons that have nothing to do with the app. Gate on the
**delta** (panic − control, both measured in the same run, which is why the control
now ships beside it), or move the gate onto the `PanicColdLaunch` signpost, which
measures the app-owned span directly and is already emitted.

## Verdict (fill in)

Two bars exist in the canonical docs and both are recorded here — MVP §7 requires
"<2.0s cold …, 10/10 attempts" (stricter), while test-suite §1.5 test 37 gates on
"p90 < 2.0s" (the CI trend metric). **Drift note filed:** the operator should
reconcile the two in the canonical docs; until then the spike verdict uses the
stricter MVP §7 bar and the automated harness asserts the test-suite p90 bar.

- [ ] 10/10 manual attempts < 2000ms on iPhone 15-class → "<2s" is marketing copy;
      threshold for the permanent E3.1 CI gate = 2000ms (p90).
- [ ] Any attempt ≥ 2000ms → copy degrades to "fast" (architecture unchanged,
      ADR-6); record achieved numbers and set the E3.1 gate to measured p90 + 10%.

**Decision recorded:** _pending operator device run — blocks marketing copy only,
not Epic 1/2 code (roadmap §4)._
