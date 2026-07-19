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
| 1–10 | lock-screen widget button | _pending_ | _pending_ | _pending_ |
| 1–10 | automated proxy (p90) | _pending_ | forced-panic relaunch | _pending_ |

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
