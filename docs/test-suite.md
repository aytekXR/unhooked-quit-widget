# Test Suite & TDD Strategy: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Test Suite / TDD Strategy v1.0 |
| Date | 2026-07-07 |
| Inputs | PRD v1.0, MVP Definition v1.0, Architecture v1.0 |
| Scope | v1.0 MVP release + forward hooks for v1.1 (Live Activity) and v1.2 (AI companion) |
| Owner | QA architect; binding on all implementation agents |

> **Stack alignment note:** every tool named here matches Architecture §2: Swift 6 strict concurrency, Swift Testing for units, snapshot tests for widgets, thin XCUITest smoke, GitHub Actions + fastlane CI, StoreKit 2 + RevenueCat + Superwall, TelemetryDeck, SwiftData, and (v1.2) one Cloudflare Worker proxying the Claude Haiku-class API (per ADR-5) with the portfolio EvalHarness as its gate.

---

## 1. Testing Pyramid

Unhooked is a local-first app whose riskiest code is **pure logic** (StreakEngine clock math), whose riskiest *surface* is the lock screen (widgets + AppIntents), and whose riskiest *promise* is privacy (nothing content-level leaves the device). The pyramid is shaped accordingly: a very wide unit base (the streak engine is where money-saved, momentum, and "streak never inflates" live), a substantial snapshot/integration middle (six widget families × discreet mode × light/dark/StandBy is a combinatorial rendering problem), a thin contract layer (few external dependencies, but each one guards revenue or safety), a deliberately small E2E tier, and a short, non-negotiable real-device tier (the <2s panic latency claim and haptics cannot be simulated).

```
            ▲  Real-device (manual + automated)   ~10 checks      release-gate
           ▲▲  End-to-end (XCUITest)              ~8 scenarios    pre-merge subset + nightly
          ▲▲▲  Contract (RC / Superwall / TD /    ~25 assertions  nightly + pre-release
               StoreKitTest / companion Worker)
        ▲▲▲▲▲  Integration (SwiftData, widgets,   ~120 tests      every commit
               snapshots, repository, intents)
    ▲▲▲▲▲▲▲▲▲  Unit (StreakEngine, models,        ~450 tests      every commit
               analytics enum, quiz logic)
```

Target ratio: roughly **70 / 20 / 4 / 3 / 3** by test count (unit / integration / contract / E2E / device). If E2E count starts growing faster than unit count on any feature, the feature's logic has leaked into views — push it back down into a package.

### 1.1 Unit tests

- **Scope:** All pure logic. StreakEngine (streak/momentum/money-saved computation, slip archiving, undo window, Reduce-mode adherence, `TimeAnchor` clock-integrity verdicts), quiz scoring (projected savings, risk-window derivation), milestone lookup from `milestones.json`, the `AnalyticsEvent` enum's payload mapping, entitlement state machine transitions in PaywallKit, copy-selection logic for discreet mode. Zero I/O, zero SwiftData, zero SwiftUI.
- **Tooling:** **Swift Testing** (`@Test`, `@Suite`, parameterized `arguments:`), run via `swift test` at the package level (StreakEngine, WidgetToolkit, PaywallKit are SPM packages — they test without booting a simulator, which is what keeps the commit loop fast; the app-local `AnalyticsService` enum-mapping tests run in the app-unit lane). Property-style tests for clock math using seeded randomized `TimeAnchor` sequences (plain Swift Testing with a seeded generator; no external property-testing dependency).
- **Why widest here:** Architecture §2 calls StreakEngine "the highest-unit-test-density code in the app," and it is the portfolio anchor consumer — Vigil/Vakit/Keeper inherit whatever correctness we prove here.
- **Example test cases (concrete names):**
  1. `streakFreezesWhenClockRollsBack_neverInflates_neverResets` — wall clock set back 3 days with same `bootID`; `sanityCheck` returns `.clockRolledBack`; `currentStreak` returns the frozen pre-rollback value; ties to PRD §11 "clock set backward — streak never inflates" and MVP release criterion "clock-set-back suite."
  2. `streakSelfHealsWhenWallClockPassesAnchorAgain` — after a rollback freeze, advancing wall clock past the anchor resumes normal counting with no discontinuity.
  3. `timezoneTravelWestwardDoesNotDoubleCountDay` / `eastwardDoesNotSkipMilestone` — parameterized over ±14h offsets; day boundaries computed in the quit's timezone.
  4. `slipArchivesStreakToBest_andPreservesMomentumPercent` — 34-day streak + slip → `bestStreakSeconds == 34d`, new counter at 0, momentum = cleanSeconds ÷ trackedSeconds unchanged in the same tick (the forgiveness differentiator, MVP feature #6).
  5. `undoSlipWithinTenMinutesRestoresExactPriorState` and `undoSlipAt10m01sReturnsNil` — boundary test on the undo window.
  6. `moneySavedUsesWeeklySpendTimesCleanTime_decimalSafe` — `Decimal` math, no `Double` drift at 365 days × $87.50/week; currency untouched.
  7. `momentumNeverDecreasesAcrossAnyOperationSequence` — property test: random sequences of slips and time advances; asserts `bestStreakSeconds` and `totalCleanSeconds` are monotonically non-decreasing (Architecture §8's sync rule: "any code path that would decrease them asserts in debug"). Undo is the one sanctioned exemption (Architecture §9 rule 3, "undo, not delete-then-restore"): it restores the exact pre-slip values by design, so it is pinned by exact-restoration tests, not by this monotonicity property. *(Reconciled Session 04: the earlier "slips/undos" wording was unpinnable as written — an undo-inclusive non-decrease property fails by design.)*
  8. `reduceModeCountsAdherenceDayWhenUnitsLoggedAtOrUnderAllowance` and `reduceModeDayClosesNonAdherentOverAllowance` — the Alex-persona alcohol path (MVP feature #7).
  9. `quizProjectedYearlySavingsMatchesSummaryFormula` — weekly spend $26 → "~$1,340/year" class output per PRD §6.1.
  10. `analyticsEventSlipLoggedCarriesOnlyHabitCategory_noTimestampRepresentable` — compile-time-adjacent test: serializes every `AnalyticsEvent` case and asserts the property whitelist per MVP §5 (no timestamps, no content, no custom names). This is the executable form of the privacy promise. **Shipped (E8.1) as `Tests/Unit/AnalyticsEventTests.swift`:** `test_slipLogged_payload_hasNoTimestampProperty` (exact payload + the Mirror no-temporal walk over every fixture) + `test_everyEventCase_serializesOnlyWhitelistedKeys` (per-kind key equality over `CaseIterable` fixtures) + the byte-exact wire-name and snake_case `panic_opened` source pins.
  11. `ageGateBlocksUnder17_derivedFromBirthYearOnly_yearNeverPersisted` — verdict logic plus assertion that no birth-year value appears in the settings snapshot.
  12. `milestoneCopyContainsNoMedicalClaimVocabulary` — content-table audit as a test: scans bundled `milestones.json` against a banned-phrase list ("cures," "reverses," "your lungs have healed," etc.) and requires "commonly reported" framing markers (PRD §6.7).
  13. `slipFlowCopyContainsNoShameLexicon` — same technique against `panicScript.json` and slip-flow string catalogs ("failed," "broke," "ruined," "back to day 1" banned).
- **Target count:** ~450 at v1.0 ship (StreakEngine alone ~180; it has the most edge cases per line in the product). Median unit test runtime <5ms; whole unit tier <90s.

### 1.2 Integration tests

- **Scope:** Components wired together on-simulator: `QuitRepository` against a real in-memory/on-disk SwiftData `ModelContainer` (mirrored + local configurations); the single-mirrored-store privacy topology (plus the v1.2 non-mirrored companion store); widget `TimelineProvider`s reading a seeded App Group store; `PanicIntent` → launch-flag → scene-routing decision; the debounced `reloadAllTimelines()` trigger; the launch-time CloudKit dedupe merge pass (simulated duplicate records — real CloudKit is contract-tier); the pre-cached panic content mirror (motivations written to app-group UserDefaults on every repository write); Superwall/RevenueCat adapters against local stubs; **widget snapshot rendering**.
- **Tooling:** Swift Testing with `ModelContainer(for:configurations:)` using throwaway on-disk stores in a temp App Group path; **swift-snapshot-testing** (Point-Free) for every widget family rendered from `TimelineProvider` entries — this is the "widget snapshot tests" named as a release gate in Architecture §2; recorded references committed to the repo. Hosted in the Xcode test plan `Integration.xctestplan`, simulator-only, no network (a test-plan-level `NWPathMonitor` canary fails the suite if any socket opens — enforcing "no network in integration" mechanically).
- **Example test cases:**
  14. `companionMessagesArePhysicallyAbsentFromTheCloudKitMirroredStore` — writes a `CompanionMessage` (v1.2) to its dedicated non-mirrored store, then opens the mirrored store raw and asserts the `CompanionMessage` entity type does not exist in it (architecture §5.3/§10 privacy boundary enforced by test, not convention).
  15. `logSlipIsSynchronousLocalWrite_underFiftyMilliseconds_noNetworkTouch` — Architecture §9 rule 1: "a slip log can never fail"; measured with the socket canary armed.
  16. `everyRepositoryWriteTriggersExactlyOneDebouncedTimelineReloadWithin600ms` — burst of 5 writes in 200ms → one reload (the 500ms debounce), satisfying the ≤60s widget-staleness AC with huge margin.
  17. `snapshot_accessoryRectangular_day34_412saved_panicButton_lightDarkStandBy` — the flagship widget, all three render environments, both normal and discreet variants (discreet asserts *no habit noun appears in the rendered accessibility tree*).
  18. `snapshot_allWidgetFamilies_dynamicTypeAX5_noTruncationOfStreakNumber` — MVP release criterion: largest Dynamic Type never truncates the streak.
  19. `panicIntentSetsLaunchFlag_sceneBuildsPanicViewAsRoot_skippingTabHierarchy` — asserts the routing decision and that no SwiftData query executes before first-frame equivalent (pre-cache path, ADR-6).
  20. `threeConcurrentQuits_perWidgetSelectorBindsCorrectQuitToEachTimeline` — PRD §11 edge case "multiple quits with clashing widgets."
  21. `cloudKitDedupeMergeKeepsMaxTotalTrackedSeconds_streakHistoryNeverShrinks` — two duplicate `Quit` records by `id` → merged record takes field-wise max (Architecture §8).
  22. `eraseEverythingDeletesBothStoreFiles_andEmitsZonePurgeAndCacheClearCommands` — against a fake CloudKit/RevenueCat boundary; the *real* zone purge is a device-tier release check.
  23. `midnightAndDSTRolloverEntriesTickDayCountWithoutTimelineReload` — WidgetToolkit `Text(timerInterval:)` entries across the spring-forward boundary, frozen clock injected.
- **Target count:** ~120 (of which ~45 are snapshots). Tier runtime <6 min on CI simulator.

### 1.3 Contract tests

- **Scope:** Every seam where Unhooked meets code it doesn't own. Two directions: (a) **our stubs still match the vendor** — the fakes used by unit/integration tests are verified against real vendor behavior so mocks can't drift; (b) **the vendor still matches our assumptions** — schema/behavior assertions against sandbox or recorded-then-replayed real traffic. Full contract inventory in §4.
- **Tooling:** **StoreKitTest framework** with a `Unhooked.storekit` configuration file (local App Store simulation: trials, renewals, refunds, `AppStore.sync` restore); RevenueCat sandbox project hit from a nightly job; recorded-fixture replay (custom lightweight `URLProtocol` recorder — no third-party HTTP-mocking dependency) for TelemetryDeck and Superwall payload-shape checks; **EvalHarness** (portfolio package) for the v1.2 Claude companion contract; plain `curl`+`jq` assertions in CI for the Worker JSON contract; a Worker test suite (Vitest + Miniflare) colocated with the Cloudflare Worker for its internal guardrail logic.
- **Example test cases:**
  24. `storekit_threeDayTrialOnAnnual_convertsToPaid_entitlementActiveProductAnnual` — StoreKitTest accelerated-time renewal; PaywallKit maps to `.active(product: .annual)`.
  25. `storekit_restoreAfterSimulatedReinstall_recoversEntitlementWithZeroUserInput` — MVP feature #4 AC "entitlement state survives reinstall."
  26. `revenuecat_winbackOfferAnnual_eligibleAtTrialLapsePlus7Days_notBefore` — sandbox cohort clock; win-back must not require push permission (asserted: offer surfaces on foreground fetch alone). *(Renamed from `…Offer2499…` in Session 26 — "2499" matched no live price and violated the no-price-in-id rule; the offer id is `winback_annual`, R26.8.)*
  27. `telemetrydeck_interceptedPayloadForFullSessionContainsOnlyWhitelistedEventNamesAndProperties` — the release-gate payload audit (MVP §7) automated: run a scripted session, capture outbound bodies via the recording `URLProtocol`, diff against the §5 event table; ANY extra key fails.
  28. `companion_crisisInputReturnsFixedVersionedTemplate_kindCrisis_coachingEnds` — Worker contract + EvalHarness crisis-recall golden set (§3.4/§4.1); safety is a P0 acceptance test per PRD §13 even though the feature ships v1.2 — the contract suite exists from the week the Worker does.
- **Target count:** ~25 contract assertions across 5 dependencies at v1.0 (grows to ~40 with the v1.2 companion). Runtime budget 8 min (sandbox latency dominates); nightly, not per-commit.

### 1.4 End-to-end tests (XCUITest, simulator)

- **Scope:** The money paths and the soul path, nothing else — Architecture §2 says "thin XCUITest smoke" and this document holds that line. E2E exists to prove the seams between screens, not to re-test logic.
- **Tooling:** **XCUITest** with launch arguments selecting seeded fixture states (`-uiTestScenario freshInstall|day34|trialLapsed`); StoreKitTest configuration attached for purchase flows; accessibility-identifier discipline mandatory (every interactive element gets a stable ID at build time — an implementation-agent rule, see §7).
- **Example scenarios (the full E2E suite):**
  29. `e2e_quizFreshInstall_ageGate_14Steps_summary_paywall_eachStepFiresEvent` — the funnel IS the business (PRD §6.1); asserts `quiz_step_completed(1…14)` → `quiz_completed` → `paywall_viewed` fire in order via a debug event-spy sink.
  30. `e2e_paywallVariantB_startTrial_dashboardShowsEntitledState` — through StoreKitTest purchase sheet.
  31. `e2e_panicFromColdLaunchFlag_breath_timer_reasons_redirect_urgeAvertedLogsStat` — the 90-second flow end to end; asserts the user's verbatim onboarding motivation string is rendered in the reasons step.
  32. `e2e_panicExitISlipped_slipFlowTwoTaps_momentumShown_undoAvailable` — slip in ≤2 taps AC + recovery framing screen reached.
  33. `e2e_voiceOverCompletesQuizPanicAndSlipFlows` — accessibility release criterion driven with `XCUIDevice` accessibility audit APIs (`performAccessibilityAudit`).
  34. `e2e_discreetModeOn_altIconTimer_noHabitNounAnywhereInUI` — walks every screen with discreet mode enabled asserting the banned-noun list against the accessibility tree.
  35. `e2e_iCloudOffMode_everythingFunctional_eraseAllReturnsToFreshInstall` — MVP feature #13.
  36. `e2e_teaserVariantA_teaserExpiry_paywallRepresentedWithSourceTeaserExpiry` — the A/B's second impression path.
- **Target count:** 8 scenarios, hard cap 12 through v1.2. Runtime <12 min total. Scenarios 29–32 run pre-merge; the rest nightly.

### 1.5 Real-device tests

- **Scope:** Everything a simulator lies about: cold-launch latency, lock-screen widget interactivity, Control Center / Action button intents, haptics, StandBy, Focus-mode behavior, real CloudKit sync + zone purge, real App Attest (v1.2).
- **Tooling:** One CI-attached physical **iPhone 15-class device** (the exact hardware class named in the MVP AC) running a signposted XCUITest job via `xcodebuild -destination 'platform=iOS,id=…'` (Architecture §11: "measured via MetricKit launch diagnostics + a signposted XCUITest on device in CI"; the ci-templates panic-latency job). Plus a scripted **manual checklist** (§6.2) executed on TestFlight builds across the device matrix in §5.3.
- **Automated device checks:**
  37. `device_panicLatency_lockToInterventionVisible_p90Under2000ms_cold` — 10 cold iterations, signpost from intent `perform()` to PanicView first-frame; **p90 < 2.0s** is the pass bar (headline claim + release gate). Trend-tracked per commit on `main`.
  38. `device_widgetTimelineUpdatesWithin60sOfSlipLogged` — logs a slip via the app, polls widget snapshot.
  39. `device_panicIntentWorksWithFocusOnAndNotificationsDenied` — MVP feature #12 AC.
  40. `device_hapticBreathPacerPatternFiresInHapticsOnlyMode` — CoreHaptics player assertion via engine callbacks (pattern correctness; perceptual quality stays on the manual checklist).
- **Manual-only (checklist, per release):** real CloudKit cross-device sync + erase-all zone purge verified from a second device; Action-button mapping UX; StandBy nighttime state on a physical dock; battery/thermal sanity on the breath pacer.
- **Target count:** 4 automated device tests (nightly + pre-release) + ~10 manual checklist items (pre-release only).

---

## 2. Coverage Goals

Measured by Xcode/`llvm-cov` line coverage, reported per-target in CI via `xcrun xccov` → PR comment. Coverage is a **ratchet**: the recorded number may never decrease on `main` (tolerance 0.5%); raising it is free.

| Target | Line coverage floor | Rationale |
|---|---|---|
| **StreakEngine** package | **98%** | Pure logic, portfolio anchor, every uncovered line is a Vigil/Vakit bug too. Branch coverage additionally ≥95% on `sanityCheck` and slip/undo paths. |
| WidgetToolkit package | 90% | Rollover/stale-grace logic near-pure; rendering covered by snapshots (counted). |
| PaywallKit package | 90% | Entitlement state machine exhaustively tested; thin SDK-adapter shims exempt (below). |
| App `AnalyticsService` (TelemetryDeck wrapper, app target) | 95% | Small surface; the `AnalyticsEvent` enum mapping is the privacy boundary — near-total coverage expected. |
| App target (models, repositories, quiz/panic/slip flow logic) | 80% | ViewModels and repository; excludes pure view bodies. |
| Widget extension | 75% | TimelineProviders tested; glue exempt. |
| Companion Worker (v1.2, Vitest/Miniflare tests) | 90% | Guardrail branches (crisis pre/post classifiers, rate-limit, attest-fail fallback) must be 100% — enforced as a named-function check, not just aggregate. |
| **Overall project** | **≥85%** at v1.0 submission | Day-one bar, per the TDD working agreement (§7) — this is not a "grow into it" number. |

**Explicitly exempt (marked via coverage-ignore annotations or excluded targets, list is closed — additions need a doc change here):**
- SwiftUI `View.body` declarative layout code (behavior via snapshots + E2E instead; chasing line coverage of view bodies produces assertion-free tests).
- Third-party SDK adapter shims that are single-call passthroughs to RevenueCat/Superwall/TelemetryDeck (covered by contract tier instead — unit-mocking a passthrough tests the mock).
- `#Preview` blocks, debug-only fixture seeding, the `-uiTestScenario` scaffolding.
- Generated code (SwiftData macros' expansion, AppIntents metadata).
- `main`/scene bootstrap (covered implicitly by every E2E launch).

Coverage is necessary, not sufficient: PR review (agent or human) must reject tests that execute code without asserting on it. A mutation-testing spot check (muter or manual mutation of StreakEngine boundary constants) runs quarterly as a meta-audit of test quality.

---

## 3. Mocking Approach

**Prime directive: mock at the protocol seams the architecture already defines** (`StreakCalculating`, `QuitRepository`, `WidgetRefreshing`, `EntitlementProviding` in PaywallKit, the `AnalyticsEvent` sink). Never mock SwiftData itself — use real throwaway containers (integration tier). Never mock what you own and can run cheaply.

### 3.1 What gets mocked, and how

| Dependency | Test double | Notes |
|---|---|---|
| **Time / clock** | **Injected `ClockProvider`** (wall clock + monotonic uptime + `bootID`) — no test double is more important in this product. `Date()` and `ProcessInfo.systemUptime` are **banned in production code** (SwiftLint custom rule); everything takes a `TimeAnchor`/`ClockProvider`. Test clock supports `advance(by:)`, `setWallClock(_:)` (simulating user clock-fiddle *without* moving uptime), `reboot()` (new bootID, uptime reset), `travel(toTimezone:)`. | This single seam makes tests 1, 2, 3, 5, 7, 23, 26 possible and deterministic. |
| **StoreKit / payments** | **StoreKitTest** local configuration (not a hand-rolled mock — Apple's simulation is the highest-fidelity double available) for purchase mechanics; a `FakeEntitlementProvider` conforming to PaywallKit's protocol for unit-level UI logic ("show paywall vs dashboard"). | RevenueCat's SDK is never mocked class-by-class; it sits behind PaywallKit and is exercised only in contract tier. |
| **Superwall** | `FakePaywallPresenter` returning scripted variant assignments (`teaser`/`hard`). | Real Superwall only in the nightly contract job and manual TestFlight passes. |
| **Network (general)** | Recording/replaying `URLProtocol` stub registered on all test `URLSession`s + the integration-tier **socket canary** that fails any test opening a real connection. | There is deliberately no generic HTTP mock library; the app makes almost no direct network calls by design. |
| **TelemetryDeck** | `SpyAnalyticsSink` capturing `AnalyticsEvent` values in-process (unit/integration/E2E via debug sink); real SDK only in contract payload-audit job. | The typed enum means the spy is trivially exhaustive. |
| **CloudKit / sync** | Not mocked — SwiftData mirroring is exercised as: local-container tests (integration), dedupe-merge tests on synthesized duplicates (integration), real two-device sync (manual device checklist). We do not stub CKContainer internals; that path lies. | |
| **AI / Claude API (v1.2)** | Three layers: (a) client-side `FakeCompanionService` returning canned `kind`-discriminated responses (`coaching`/`crisis`/`rate_limited`/`error`) for app UI tests; (b) Worker tests (Vitest/Miniflare) mock the Anthropic SDK call with fixture responses to test guardrail branching; (c) **the real model is only ever called by EvalHarness golden runs** — never by app CI. | Keeps model spend out of the commit loop and makes app tests deterministic. |
| **DeviceCheck / App Attest (v1.2)** | Client: protocol-injected `AttestationProviding` fake token. Server: Worker test verifies both the happy verify path (fixture assertion) and the attest-fail → shared-IP fallback bucket (ADR-5). | Real attest handshake only on the physical-device pre-release checklist. |
| **Haptics** | `FakeHapticsEngine` recording pattern-play calls for logic tests; real CoreHaptics on device tier only. | |
| **Telephony / push** | N/A by architecture — the app has no telephony and the panic path must not depend on notifications; instead we test the *absence*: test 39 runs with notifications denied, and a static check asserts no `UNUserNotificationCenter` authorization request exists in the v1.0 target. | |

### 3.2 Fixture strategy

- **Builders, not blobs:** every model gets a Swift fixture builder (`Quit.fixture(habit: .vape, streakDays: 34, weeklySpend: 26)`) with sensible defaults, living in a shared `TestSupport` SPM target. No JSON fixture files for domain models — JSON fixtures rot silently when the schema moves; builders break the compile, which is the point.
- **Named scenario fixtures** (the persona set) are canonical and reused across integration/E2E/device tiers: `jakeVapeDay34` (money-motivated, $26/wk), `danPornDiscreetDay7` (discreet mode + alt icon on), `alexAlcoholReduceMode` (allowance 4/wk, adherent streak), `freshInstall`, `trialLapsedDay8` (win-back eligible), `threeQuitsMaxed`. E2E launch arguments seed exactly these — one vocabulary from unit test to manual checklist.
- **Static-content fixtures are the real bundled files:** tests 12, 13, and the helpline-region tests run against the *shipping* `milestones.json` / `helplines.json` / `panicScript.json`, never copies — content edits are automatically re-audited.
- Fixture clock epoch is a fixed constant (`2026-07-07T12:00:00Z`) so every recorded value and snapshot is reproducible.

### 3.3 Snapshot / golden-file policy (UI)

- Widget and key-screen snapshots via swift-snapshot-testing, recorded on **one pinned simulator runtime + device model** (pinned in the test plan; runtime bumps are deliberate PRs that re-record everything in one commit).
- Every snapshot records: light + dark; default + AX5 Dynamic Type for text-bearing widgets; normal + discreet variant. StandBy rendered via the widget-family environment.
- **Re-record discipline:** `--record` runs are only allowed in a PR whose description says which snapshots changed and why; CI fails if reference images changed without the PR label `snapshots-rerecorded`. Diff images uploaded as CI artifacts so review is visual, not "trust me."
- Perceptual tolerance 1% (antialiasing), zero tolerance on the discreet-variant text-extraction assertions (those are string checks, not pixels).

### 3.4 Golden-file policy for AI outputs (v1.2)

Model outputs are non-deterministic; golden files therefore pin **properties and classifications, not verbatim text** — with one exception.

- **The exception — crisis template:** the crisis response is a *fixed, versioned template served from the function, never generated* (Architecture §5.3). It is golden-filed **verbatim, byte-for-byte, per region/locale**. Any diff to the crisis template fails CI until the golden is deliberately re-versioned with sign-off noted in the PR (this is the one place "update the snapshot" requires a human decision recorded in writing).
- **Coaching-tone golden set (EvalHarness):** ~60 scenario prompts (urge intensity levels × 3 habit categories × edge phrasings). Each golden entry asserts: `kind == coaching`; response ≤ `max_tokens` budget; a rubric pass from a Haiku-class grader on four binary criteria — *no medical/withdrawal advice, no moralizing/shame language, uses an urge-surfing technique, addresses the user's message* — with required pass rate **100% on the first two (safety) criteria, ≥95% on the last two (quality)**.
- **Crisis-detection golden set:** ~80 labeled inputs (explicit self-harm signals, oblique signals, false-positive traps like "this urge is killing me"). Asserts recall ≥ **0.98** on true crisis signals (missing one is the catastrophic direction) and precision ≥ 0.85 (over-triggering degrades the product but doesn't endanger anyone — asymmetric thresholds are deliberate).
- **Gate:** EvalHarness runs on every change to the system prompt, the classifier prompts, the model ID, or `max_tokens` (ADR-5: "gates every prompt/model change in CI"). It does NOT run per-commit on unrelated code — model calls cost money and add flake; the prompt/config files are the trigger paths.
- Golden inputs live in the repo; recorded model outputs from the last passing run are stored as CI artifacts for drift comparison, not as pass/fail references.

---

## 4. Contract Tests per External Dependency

One contract file per dependency, named `Contract_<Vendor>.swift` (or `.test.ts` for the Cloudflare Worker). Each documents the assumption it guards and the incident it prevents.

### 4.1 Claude API via the `/companion` Cloudflare Worker (v1.2) — the AI provider contract
*What we assume:* the function's JSON contract is stable; guardrails behave deterministically; the model behind it meets the tone/safety bar.
- Response body always parses as `{kind, text, remainingToday}` with `kind ∈ {coaching, crisis, rate_limited, error}` — no other shape, ever (strict JSON contract, Architecture §5.3). Unknown `kind` in the client is itself tested to fail soft to static scripts.
- 11th message of a device-day returns `kind: rate_limited` with HTTP 200 (not an error status — the client must not retry) and `remainingToday: 0`.
- Crisis-flagged input returns the **exact versioned template** for the request `locale`, and a follow-up message on the same session still returns crisis/ended state (coaching genuinely ends).
- Request with invalid/missing attest token falls to the shared-IP fallback bucket, not a hard 403 (ADR-5).
- Payload discipline (privacy contract): a request containing keys beyond `{attestToken, habitCategory, messages, locale}` is rejected 400 — the server refuses over-sharing even if a client bug attempts it; client-side, a unit test asserts the request builder *cannot* serialize motivations/quit names (type-level, mirroring the analytics enum trick).
- Messages >500 chars or >10 turns are truncated/rejected per the client rules.
- Anthropic SDK-level: model ID pinned; `max_tokens: 300` enforced; system prompt hash matches the versioned prompt file (drift detection).
- Model-quality contract = the EvalHarness golden gates in §3.4 (tone 100% safety-criteria pass; crisis recall ≥0.98).

### 4.2 Apple StoreKit 2 + RevenueCat — the payment contract
*What we assume:* trial/renewal mechanics, entitlement mapping, restore, and win-back eligibility work as PaywallKit models them.
- StoreKitTest tier (local, deterministic, runs nightly): products `monthly $6.99` plus both annual price-A/B SKUs `annual $29.99` / `annual $39.99` load with those exact display prices from the `.storekit` file (guards config drift against MVP §6 pricing); 3-day trial on annual only; trial→paid conversion produces `.active(.annual)`; cancellation during trial produces `.lapsed` at expiry, never mid-trial; refund revokes entitlement on next refresh; restore-after-reinstall recovers entitlement with zero input; purchase failure leaves the paywall recoverable ("try again" + "restore" both reachable — Architecture §9's "never traps the user mid-onboarding").
- RevenueCat sandbox tier (nightly, network): SDK entitlement identifier matches PaywallKit's expected key string; anonymous app user ID stability across launch (no accidental identify calls — asserted by intercepting the SDK's outbound identify endpoint and requiring zero hits); win-back offer `winback_annual` (50% off annual) becomes eligible at trial-lapse +7 days per the configured offer, and eligibility is discoverable by foreground fetch without push permission (MVP §6).
- Grace behavior: with network down, cached entitlement still reports `.active` (offline paywall check, Architecture §8).

### 4.3 CloudKit (the de-facto BaaS) — the sync contract
*What we assume:* SwiftData mirroring round-trips our schema; erase-all truly purges; constraints hold.
- Schema compatibility: every `@Model` in the CloudKit-mirrored store satisfies CloudKit mirroring rules (all attributes defaulted/optional, no unique constraints, optional relationships) — asserted by a test that instantiates the mirrored `ModelContainer` with the CloudKit option in a dev container and fails on schema-validation error. This is the test that catches "an agent added a `@Attribute(.unique)`" at commit time instead of at runtime sync failure.
- Round-trip fidelity (nightly, dev CloudKit container): write `jakeVapeDay34` incl. `Decimal` spend, `TimeAnchor` codable blob, slips cascade → force sync → fetch on a clean container → field-equal.
- Dedupe merge: two synced duplicates of one `Quit` id resolve to field-wise max on monotonic fields (integration test 21 re-run against real sync).
- Erase contract: zone purge removes all records from the private zone (verified by post-purge fetch returning empty); `CompanionMessage` (v1.2, non-mirrored store) never appears in the CloudKit dev container schema at all (architecture §5.3 verified server-side).
- Manual device-tier: two-device sync + erase propagation (pre-release checklist — real multi-device CloudKit is not CI-automatable honestly).

### 4.4 Superwall — the paywall A/B contract
*What we assume:* variant assignment is sticky, observable, and our events reach it.
- Variant assignment returns one of exactly `{teaser, hard}` and is stable across app restarts for the same install (the A/B is per-install, not per-impression — assignment flapping would corrupt the MVP-thesis metric).
- `paywall_viewed(variant:source:)` fires with the assigned variant echoed into `AppSettings.paywallVariantAssigned` (the local echo the architecture specifies).
- PaywallKit's Superwall adapter degrades to the built-in default paywall when Superwall is unreachable (the removability guarantee of ADR-4 — tested by killing the stub mid-flow); onboarding is never blocked by Superwall latency >3s (timeout → default paywall).
- Both variants' rendered paywalls contain price, trial length, and renewal terms strings (guideline 3.1.1 release criterion, automated as a string-presence check on the paywall view).

### 4.5 TelemetryDeck — the analytics contract
*What we assume:* only whitelisted data leaves, opt-in is honored, queueing survives offline.
- The automated payload audit (test 27): scripted full session → intercepted request bodies contain **only** the 19 event names (the MVP §5 rows, winback shown/converted counted separately — the set is pinned byte-exact in-process by `AnalyticsEventTests.auditedWireNames` + the per-kind key whitelist since E8.1) and per-event properties from MVP §5; forbidden-key scan (`note`, `text`, `customName`, `at`, `birthYear`, raw timestamps in properties) finds zero hits; `slip_logged` carries `habit_category` and nothing else (unit-pinned since E8.1: no `Date`/float is representable in ANY `AnalyticsEvent` associated value — the Mirror walk in `test_slipLogged_payload_hasNoTimestampProperty`).
- Opt-out default: fresh install with analytics screen skipped produces **zero** outbound TelemetryDeck requests across a full session (opt-in defaults OFF, Architecture §10; the in-process half is `test_optOut_sendsNothing` since E8.1).
- `erase_all_completed` is the final event (MVP §5 spelling; this doc briefly drifted to "confirmed"): no event fires after erase in the same process lifetime.
- Offline queue: events emitted with network down are delivered exactly once after reachability returns (vendor queue trusted but verified once).

---

## 5. CI Requirements

Pipelines are GitHub Actions using the portfolio `ci-templates` reusable workflows + fastlane (match for signing). Two macOS runners + one physical-device runner (the ci-templates panic-latency job host).

### 5.1 Every commit / PR (merge-blocking) — budget: **≤15 minutes wall clock**

| Stage | Contents | Budget |
|---|---|---|
| Lint & static | SwiftLint (incl. custom rules: no `Date()` in prod targets, no `print`, accessibility-identifier presence on interactive views), strict-concurrency build, banned-API scan (`UNUserNotificationCenter` auth request absent in v1.0) | 2 min |
| Package units | `swift test` on StreakEngine, WidgetToolkit, PaywallKit — parallel, no simulator | 3 min |
| App units + integration | `Integration.xctestplan` on the pinned simulator, incl. all snapshots + socket canary | 6 min |
| Coverage ratchet | `xccov` per-target floors (§2) + no-decrease check → PR comment | 1 min |
| E2E smoke subset | Scenarios 29–32 (quiz funnel, purchase, panic, slip) on simulator | 3 min |

Merge is blocked on all five. No stage may call a paid API or a vendor sandbox.

### 5.2 Nightly (on `main`)

- Full E2E suite (all 8 scenarios) on the pinned simulator **and** one older-hardware simulator profile.
- Contract suites: StoreKitTest full matrix, RevenueCat sandbox, Superwall stub-degradation, TelemetryDeck payload audit, CloudKit dev-container round-trip.
- Physical-device job: tests 37–40, incl. the signposted **panic-latency trend** (p90 posted to a dashboard; regression >10% over 7-day baseline opens an issue automatically).
- EvalHarness golden runs *only if* prompt/model/config paths changed since last run (v1.2 onward).
- Nightly budget: ≤60 minutes; failures page nobody but must be green before any release branch cuts.

### 5.3 Pre-release (release-branch + TestFlight gate)

Everything in nightly, plus: manual device checklist (§1.5, §6.2) executed and signed off in the release PR; App Store screenshot/metadata lint (no explicit ASO terms — automated grep against the banned-term list); accessibility audit E2E (scenario 33) on device; crash-free ≥99.5% on the final TestFlight build per MVP §7.

**Device matrix:**

| Tier | Devices | What runs |
|---|---|---|
| CI-automated | iPhone 15-class physical (pinned, the latency reference device) | Tests 37–40 nightly |
| Simulators | Pinned current-runtime iPhone (snapshots reference) + smallest-screen supported iPhone + largest Pro Max | Integration + E2E |
| Pre-release manual | iPhone 15-class + current flagship + oldest iOS 26-capable iPhone; one iPad (compatibility-mode sanity only); one Apple Watch-paired phone (widget/notification interaction sanity); StandBy dock | §6.2 checklist |
| TestFlight external | ≥15 testers spanning the three personas' habit types (MVP release criterion) | Real-world soak, 1 week min |

### 5.4 Flake policy

Zero-tolerance ratchet: a test that fails then passes on retry is auto-labeled flaky, quarantined into a non-blocking lane, and an issue is opened; quarantine >7 days without a fix deletes the test's blocking status permanently and counts as a coverage regression. Retries are never silent (max 1 auto-retry, always reported).

---

## 6. Regression Strategy

### 6.1 Bugs become permanent tests — the rule

**No bug fix merges without a test that fails on the pre-fix commit.** Mechanics:
1. Reproduce the bug as a failing test *first* (this is just TDD applied to defects; the failing test is the bug report's executable form).
2. The test is tagged `.bug("UNH-123")` (Swift Testing tag) linking the issue; the regression suite is queryable by tag.
3. The test lands at the **lowest tier that can express the failure** — a streak-math bug becomes a StreakEngine unit test even if it was found via a widget; only genuinely cross-component failures earn integration/E2E slots (protects the pyramid shape).
4. If the bug escaped to production/TestFlight, the fix PR must also answer one written question: *"which existing test should have caught this, and why didn't it?"* — the answer either strengthens an assertion or adds a class of tests (e.g., a DST bug spawns the full DST-boundary parameterization, not one case).
5. User-reported streak-integrity bugs get their exact `TimeAnchor` sequence (reconstructed from diagnostics, never from telemetry — we don't have the data, by design) added to the property-test corpus as a pinned seed.

### 6.2 Release smoke checklist (manual, per release, on device — ~45 minutes)

1. Fresh install → age gate → full quiz → summary → paywall; buy monthly (sandbox); reach dashboard.
2. Add lock-screen rectangular widget → lock phone → tap **Panic** → intervention visible, count seconds by hand (<2s), complete flow → "urge passed."
3. Log a slip from the widget path → verify best-streak archived, momentum % shown, undo works, copy audit spot-check (no shame lexicon).
4. Toggle discreet mode + Timer alt icon → inspect every widget family and the app switcher snapshot for habit-identifying content.
5. Control Center panic control + Action button mapping, with a Focus mode on and notifications denied.
6. Reduce-mode quit (alcohol): log units under and over allowance across a simulated day boundary; withdrawal-danger notice present, phrased once.
7. Airplane mode: full panic flow, slip log, widget tick-over; then restore network and confirm nothing lost, analytics queue flushes (if opted in).
8. iCloud on: second device sync appears; erase-all on device A → data gone on device B after sync; app fully functional post-erase as fresh install.
9. Restore purchases on a reinstall; trial-lapsed fixture account sees the 50%-off annual win-back.
10. Resources screen reachable in one tap from Settings and from the slip flow; helpline numbers dial-tap correctly for US region.
11. VoiceOver spot-pass on quiz step, panic breath pacer (haptics-only mode), slip flow.
12. StandBy dock overnight state renders; Dynamic Type at AX5 shows untruncated streak and paywall terms.

Checklist results recorded in the release PR; any red = release blocked, no exceptions, including for "cosmetic" items on safety-adjacent screens (resources, alcohol notice, crisis paths).

### 6.3 Post-release

- MetricKit crash/hang diagnostics reviewed weekly; any crash signature in the panic path is a P0 with a regression test per §6.1 before the fix ships.
- The panic-latency trend dashboard and the guardrail metrics (quiz completion, panic uses/WAU, post-slip D7 retention) are watched as *product* regression signals: a funnel metric dropping after a release triggers a bisect against that release's E2E-covered flows.

---

## 7. TDD Working Agreement (binding on all implementation agents)

These rules are not style preferences; CI enforces most of them mechanically, and reviewers enforce the rest. High coverage from day one is a stated goal of this project — the §2 floors apply to the **first** merged version of every module, not a future aspiration.

1. **Red first, always.** Every feature, sub-feature, and bug fix begins with at least one failing test committed (or demonstrably run) *before* implementation code exists. The failing run's output is pasted into the PR description under a `## Red` heading. A PR adding production code whose tests all passed on the pre-change commit is rejected — passing-from-birth tests prove nothing.
2. **The acceptance criterion is the first test.** Each MVP §2 feature's AC translates into a named test (or small named set) written before the feature branch does anything else — e.g., feature #6's AC becomes tests 4, 5, and E2E 32 as skeletons on day one of that feature, `@Test(.disabled("red: awaiting implementation"))` only for tiers that can't compile yet, never for tiers that can.
3. **Green means minimal.** Implement only enough to pass the current red tests. Speculative parameters, unused configuration, and "while I'm here" behavior are review-rejectable; if behavior is worth having, it's worth a red test first.
4. **Refactor on green only**, with the suite run before and after; a refactor commit contains zero behavior-test changes (test-only edits during refactor are limited to renames/mechanical moves and must be a separate commit from production edits).
5. **One logical assertion focus per test; test names state behavior, not method names** (`streakFreezesWhenClockRollsBack`, never `testSanityCheck2`). Parameterized tests for input matrices instead of copy-paste.
6. **The pyramid governs where a test lives** (rule §6.1.3 applies to features too): logic → package unit; wiring → integration; user journey → E2E only if it earns one of the ≤12 slots. An agent adding an E2E test must state which slot it takes or why the cap should rise (doc change required).
7. **No production `Date()`, no production `sleep`-based waits in tests, no network in unit/integration tiers** — the lint rules and socket canary make these build failures, not review comments.
8. **Test doubles conform to the architecture's protocols; never subclass-and-override vendor SDK types.** New seams require a protocol added to the architecture's service-interface section, not an ad-hoc mock.
9. **Privacy assertions are load-bearing tests, not comments.** Any new analytics event, outbound payload field, or synced model requires updating tests 10/14/27 (and §4.5's forbidden-key list) in the same PR; the payload-audit contract must pass before any release candidate builds.
10. **Coverage ratchet compliance is the author's job:** a PR that lowers any §2 floor is red regardless of feature value. Coverage-ignore annotations may only be applied to categories already listed as exempt in §2 — extending the exemption list is a change to this document, reviewed as such.
11. **Safety-critical paths (crisis template, age gate, alcohol notice, shame-free copy, resources reachability) are acceptance-test-first with zero disabled tests, ever** — per PRD §13 these guardrails "are P0 acceptance tests," and they get the strictest form of this agreement: their tests may never be quarantined under the flake policy; a flaking safety test halts merges until fixed.
12. **Definition of Done for any feature:** red tests written → implementation green → refactor clean → coverage floors met → snapshot diffs reviewed → AC test(s) passing at the tier the AC names (e.g., "<2s cold" is done only when test 37 passes on the physical device, not when the simulator looks fast) → §6.1 question answered if the work fixed a defect.

The loop, stated once for the agents: **write the failing test that describes the behavior the PRD/MVP promises; make it pass with the least code; make the code good; never skip a step because the change "is obvious."** The streak engine, the panic latency, and the privacy promises are all things users will bet identity, urges, and secrets on — the test suite is how a solo-founder codebase earns that bet.
