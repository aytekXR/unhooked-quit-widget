# Implementation Plan: Unhooked — TDD Work Breakdown

| Field | Value |
|---|---|
| Document | Implementation Plan v1.0 |
| Date | 2026-07-07 |
| Inputs | PRD v1.0, Feasibility Report v1.0, MVP v1.0, Architecture v1.0, Roadmap v1.0 |
| Method | TDD-first: every task names the failing test(s) written before implementation |
| Test stack | Swift Testing (units), widget snapshot tests, thin XCUITest smoke, signposted on-device latency test |

Conventions: tasks are ordered within epics and epics are roughly ordered; `Deps:` lists blocking tasks. Test names are illustrative-but-concrete Swift Testing function names. Tasks tagged **[PKG:X]** belong to shared portfolio package `X`, not this app's repo (see §Portfolio Packages at the end). Pure-copy/config work has "tests" in the form of checklists or CI gates where a unit test is meaningless — stated explicitly per task.

---

## Delivery status (added Session 08 close, 2026-07-09; maintained at every session close)

The plan below is UNCHANGED as the definition of the work; this table is the running
truth of what landed, with every deliberate scope deferral named (details in the
matching `past-prompts.md` session entries — deviations are recorded there, never
silent). Epic/task text stays as originally planned unless a session ledger says a
semantic was corrected (so far only one: E2.4's erase ORDER — architecture §10 now
specifies local-first, cloud purge last; Session 08 ruling).

| Task | Status | Evidence / deferrals (all deliberate, tracked) |
|---|---|---|
| E0.1 CI pipeline → TestFlight | ✅ DONE | Session 02; upload lane truly live Session 06; per-run bundle versioning fixed Session 07 |
| E0.2 targets + App Group + packages | ✅ DONE | Session 02 |
| E0.3 panic-latency spike | ◐ scaffolded | Harness + docs shipped; the DEVICE MEASUREMENT is operator-owned and now load-bearing (sets E3.1's permanent gate threshold) |
| E1.1–E1.4 StreakEngine | ✅ DONE | Sessions 03–05; engine v1.0.0 → 1.2.0 (heal, Session 07); 100/100/100 coverage behind a merge-blocking CI gate |
| E2.1 single store (App Group) | ✅ DONE | Session 05 (+interlude verify); protection-class → device tier; CloudKit-option instantiation → §4.3 flip; companion store → E12 |
| E2.2 QuitRepository | ✅ DONE | Session 06; undo lifecycle WHOLE → E4.1; production Clock/Widget conformances → E3.1; sole-importer CI lint live |
| E2.3 dedupe merge + recompute | ✅ DONE | Session 07; launch/remote-change wiring → E3.1/§4.3; real-CloudKit dedupe → contract tier; LKG witness discipline ratified |
| E2.4 one-tap erase | ✅ DONE | Session 08; LOCAL-FIRST order (the one plan correction — §10 updated); CloudKit purge behind `CloudSyncControlling` (real purge → §4.3/contract); RevenueCat clear → E7 seam; `erase_all_completed` → E8 seam; panic-snapshot FILES join the sweep in E3.1 (review-pinned carry) |
| E3.1 panic productionizing | ✅ DONE | Session 09; pre-cache = panic-snapshot.json FILE (§4/ADR-6 outrank the plan's "defaults" phrasing — recorded adjustment, not drift) + erase coverage in the same session; production Clock/Widget conformances + RepositoryProvider post-frame wiring; panic route provably store-free; quitID channel landed (intent parameter → E3.3); **latency gate still unwired — operator E0.3 measurement pending**; InstantLaunch package extraction → second consumer |
| E3.2 panic flow UI | ✅ DONE | Session 10; §9-rule-2 write buffer (`panic-outcomes.ndjson`, erase-covered same-session, idempotent timestamp-preserving flush in `startIfNeeded`); 4-7-8 pacer behind the `HapticsPlaying` seam (§5.1); reasons VERBATIM at 40pt with vertical paging; slipped exit = ROUTING SEAM ONLY (`PanicSlipHandoff` — E4.1 owns the slip flow + its writes as one unit); `panicScript.json` now BUNDLED (its consuming epic arrived; tone review gates TestFlight-visible copy); first 40 snapshot goldens (light/dark × default/AX5 — AX5 supersedes the plan's "XXL" wording, stricter); deferrals: haptics-only production channel → E5+ settings writer; `panic_step_reached` → E8.1; VoiceOver audit + Live Activity → device tier / P1 |
| E4.1 slip flow + undo | ✅ DONE | Sessions 11–12; design = the BINDING Session 11 decision record, shipped exactly in Session 12 (red evidence run 29090095270 → green 14bee2a → refs 8cf1461, all-green): logSlip opens the undo window (flag + persisted `PendingSlipUndo` payload; newer finalizes older), engine-gated `undoSlip` exact restore + row DELETE, `finalizePendingSlips` scene-phase sweep + `#Index<Slip>([\.isPendingUndo])`, two-pass flush applying deferred cold slips from the SLIP-TIME evidence tuple (R-WIT equivalence pinned), pre-cache additive streak fields, SlipFlowModel/SlipFlowView on both routes (placeholder dead end deleted), `slipCopy.json` bundled (+agent-drafted retryNote, operator tone review flagged), 24 goldens (repo total 64). Deferrals: dashboard-half XCUITest → fixture-seeding session; store-route framing momentum/motivation → dashboard epic; `slip_logged`/`slip_undone` → E8.1; undone-slip CloudKit tombstoning → §4.3 flip |
| E3.3 panic entry-point matrix | ✅ DONE | Session 13 (red evidence run 29117701445 — build green, exactly the 19 designed issues → green same session); per-quit intent `@Parameter` (PanicQuitEntity/Query over the pre-cache, ADR-6 readers only); TRUE per-source attribution via the `panic.launch.source` App Group channel threaded pre-frame → PanicFlowModel (the `.lockscreenWidget` hardcode is dead); discreet **"Reset"** control (own kind `PanicControlDiscreet`, `arrow.counterclockwise`, neutral gallery strings unit-pinned via Shared `PanicControlStyle`); in-app entry = the fourth source (placeholder-grade root button → pre-cache composition, `.inApp`); **RECORDED ADJUSTMENT** (platform ceiling, docs-checked WWDC24 10157): iOS exposes NO control launch-surface API and one control kind serves CC / lock-screen slot / Action button, so control-family launches attribute `.controlCenter` and `.actionButton` stays reserved in the schema; device matrix → operator (`docs/operator-expected.md` §7); E6.2 feeds the quit parameter a selector UI |
| E4.2 zero-shame copy gate | ✅ DONE | Session 14 (red evidence run 29122473990 — 146 tests, EXACTLY the 2 designed issues → green 29123195424 same session, zero burned): `SlipLexiconTests.test_slipStrings_containNoForbiddenLexicon()` is the PERMANENT unit-lane gate (37-token lexicon — casefold+diacritic-fold+whitespace-collapse, word-boundary `sin`/`cure`; only-grows foundation-floor pin; reflection-driven corpus over decoded `SlipCopy` + degraded fallback + panicScript slipped exit); copy centralized: `slipCopy.json` = THE audited table (+`dashboard` section, byte-identical to shipped literals), `SlipCopy.Dashboard` decode-tolerant, `RootPlaceholderView` table-driven (zero inline slip literals). NO golden changes. Human half (MVP §7 checklist signature) → operator-expected §3. Epic 4 DoD: copy gate in CI ✓; slip→undo→re-slip fuzz vs engine invariants shipped E4.1 (SlipUndoLifecycleTests); post-slip momentum+best shipped E4.1 |
| E8.1 typed `AnalyticsEvent` + `AnalyticsService` | ✅ DONE | Session 15 (red `b43b03d` burned run 29130610823 — test-file import miss, gate added → red evidence 29130875659: 157 tests, EXACTLY the 23 designed failing cases → green 29131380401 same session + TestFlight): closed enum = 19 MVP §5 cases byte-pinned (model-enum reuse, `custom` the wire ceiling; snake_case `panic_opened` source map — Architect MUST-FIX; no Date/float representable, Mirror-pinned); `AnalyticsService` @MainActor facade, `fire()` = THE consent gate (default OFF, hardwired until E8.2); `AnalyticsSink` seam + SpyAnalyticsSink; TelemetryDeck **2.14.1 exact-pinned** (app target only), lazy post-frame init, SDK SignalCache = the on-device queue, DORMANT behind the operator app ID (operator-expected §8) — the ADR-8 double gate; fire-points LIVE red-first: `urge_averted` (warm+cold arms) + `slip_undone`; deferred by name: `slip_logged` four-arm (Architect-spec'd), `panic_opened` (Mac-tree guard), `panic_step_reached` (ADR-6 warm-up), `erase_all_completed` (consent-wipe ordering) |
| E5.1 age gate | ✅ DONE | Session 16 (red evidence run 29135328846 — EXACTLY the 7 designed cases / 30 issues, Linux-harness-predicted issue-for-issue → green 29136061287 same session + TestFlight, 2 runs zero burned): the gate is the app's FIRST screen — `AgeGateContainerView` = the normal-route root ABOVE `RootPlaceholderView` (E5.2 mounts inside, inherits the gate), fail-closed through the store-open gap, `root.placeholder` anchor rides the container in every state; conservative boundary (pass iff `currentYear − birthYear ≥ 18`, operator-vetoable); blocked = calm VERIFIED-helplines surface (`appliesTo:"all" AND verified:true` — US 988, TR 112 until the operator verifies ALO 182; unverified-never-renders test-pinned); ONLY `AppSettings.ageGatePassed` persists (schema-walk pin; no App Group mirror); **step-0 RECORDED ADJUSTMENT:** the third named test became `test_ageGate_firesNoAnalyticsEvents()` — `age_gate_blocked` is structurally unfireable (consent lives POST-gate) and privacy-adverse; no mvp.md edit, no enum case (PM+Architect ruling, ledger Session 16); `ageGateCopy.json` = the audited table (lexicon-scanned); safetyCopy/helplines BUNDLED (consuming epic arrived — operator §3); panic route untouched (pre-gate empty pre-cache is the structural guarantee); goldens deferred to the E5.2 batch; Epic-5-DoD navigation XCUITest rides E5.2 (scenario 29) |
| E5.2 quiz engine + 12–14 screens | ✅ DONE | Session 17 (red evidence run 29151832001 — build green, EXACTLY the 25 designed cases / 55 issues, Linux-harness-predicted issue-for-issue on the pure lane → green 29152486541 all-green same session + TestFlight; 2 runs zero burned): data-driven quiz from bundled `quizConfig.json` (ADR-9 — the config IS the ONE audited copy table; every string DRAFT/founder-owned, operator-expected §3; lexicon-scanned incl. the degraded fallback; Brand SIGNED-WITH-CHANGES); pure `QuizFlowEngine` + @Observable `QuizFlowModel` (FIXED canonical `step_number` — hidden conditionals/seam emit nothing, UI progress shows the visible position: two honest numbers; back preserves answers; app-standard-defaults resume checkpoint, erase-swept); `createQuit(from profile:)` via a private save-free `insertQuit` core (ONE save/rebuild/reload; motivations VERBATIM user order → pre-cache through the existing rebuild hook; custom-only label, reduce-only allowance; profile inserted + linked + stamped in the same save; Architect privacy pre-approval honored, 10/10 MUST-FIX); `PostGateRootView` mounts quiz-or-placeholder inside the gate container (Epic-5-DoD un-bypassability at the unit tier via `QuizGateRouting`); fire-points LIVE red-first: `onboarding_started` (once, checkpoint-resume-suppressed) + `quiz_step_completed` (post-checkpoint-write, beside the write); **RECORDED ADJUSTMENTS (step-0 class, operator-vetoable, ledger Session 17):** `quiz_completed` NOT fired here — deferred to E5.3's summary render per its canonical MVP §5 trigger ("Personalized summary shown"; a named handoff seam carries habitCategory+goalMode); consent = reserved unrendered slot-3 seam (E8.2's); `quit_created` fire-point assigned to the repository create path, wiring deferred; scenario-29 XCUITest completes at E5.3+ (needs summary/paywall); Epic-5 goldens batch moved post-founder-copy |
| E5.3 personalized summary + social proof | ✅ DONE | Session 18 (red evidence run 29156626484 — build green, EXACTLY the 31 designed issues / 210 tests, Linux-harness-predicted label-for-label on TWO lanes (pure + spy) → burned run 29157369825 (build failure, no evidence: the new XCUITest class missed @MainActor — gate now in standing rule #2) → run 29157616479 verified the implementation whole (unit 210/210 + snapshot) while the NEW scenario-29 smoke flaked its first drive → the ruling-(e) valve fired (smoke → E7; removal 3b091d9) → final green 29158183470 + TestFlight; 4 runs): pure `SummaryDerivation` (savings = weeklySpend × 52 Decimal-exact into the EXISTING `QuizProfile.projectedAnnualSavings`; risk window = highest-precedence selected trigger TOKEN into `predictedRiskWindow` — evenings > afterWork > social > alone > boredom > stress, frequency reserved-unused v1, no triggers → nil, NEVER a guess; both filled in `createQuit(from:)` BEFORE the ONE save, deliberately NOT in recompute) + pure `SummaryFormatter` (floor-to-TEN + "~" + stored-currencyCode + "/year"; 0 → nil, never "~$0/year") + `SummaryPresentation` (absence = nil at the data tier); `QuizSummaryView` = the brandkit §6.7 QuitSummaryCard at `PostGateRootView`'s completion seam (three-way router mirroring `QuizGateRouting.postGateScreen(hasActiveQuit:quizComplete:)` — completion-first `.summary`, P0-1 pinned at the pure tier; CTA dismiss `model = nil` = summary-once rebuild-proof, no persisted flag; the CTA closure is E7's NAMED paywall seam); **`quiz_completed` fires — once per completion, on summary render, via `QuizFlowModel.onSummaryAppear()`** (durable guard, payload exactly {habit_category, goal_mode}, production `.disabled` until E8.2); `summaryCopy.json`/`SummaryCopy` = the summary's OWN audited table (Architect ruling: never a quizConfig steps[] entry — the engine-renders-steps hazard eliminated by construction; DRAFT/founder-owned, Brand SIGNED zero replacements, lexicon-scanned shipping+degraded with per-token completeness pins); **RECORDED ADJUSTMENTS (step-0 class, operator-vetoable, ledger Session 18):** the social-proof SCREEN deferred post-TestFlight-feedback (no real quotes exist; fabricated banned; the Brand-verified trust-frame fallback table lives in the ledger for a veto); scenario-29 was BUILT (self-isolated by the new `UITEST_RESET` hook — which stays), flaked its first CI drive, and DEFERS to E7 per its pre-recorded QA valve; `quit_created` deferred to the E8 batch WITH the QuizCompletionTests guard widening. Epic 5 DoD: quiz funnel instrumented per-step ✓ (visibility in a TelemetryDeck dashboard rides E8.2 + the operator §8 app ID); XCUITest quiz→summary path → E7 (the valve; un-bypassability stays unit-pinned); age gate un-bypassable ✓ |
| E6.1–E10.2 (rest) | ☐ not started | Per plan; no scope changes. Next: E8.2 (Session 19 — consent screen at the reserved quiz slot-3 seam + `docs/payload-audit.md`; retires the hardwired `isOptedIn: { false }`; step-0: does the rendered consent step emit `quiz_step_completed(3)`?) |

**Completion ratio (v1.0 scope, E0–E10 = 32 tasks):** 19 done + 1 half-scaffolded
(E0.3: harness shipped, device measurement operator-owned) = **59%** of build
tasks (delivery counter: 20/32 = 62% counting the half); milestones: M0 ✅,
**M1's build half is COMPLETE** (engine + persistence + the full panic flow +
slip/undo/copy-gate + the entry-point matrix + the age gate + the quiz + THE
SUMMARY PAYOFF — "complete quiz → create quit → see streak → panic → slip →
undo" all works on device; M1's formal exit is the operator's physical-device
walk, operator-expected §2), M2 not started.
**Calendar:** roadmap targets store-approval by week 5–6 with a mid-December 2026
hard window; Sessions 02–13 ran 2026-07-07 → 07-10, so the build is comfortably
inside the window (≈4 months of slack — per roadmap discipline, slack goes to
distribution content, not scope creep). Remaining build tasks: 14 → at the observed
~1–1.5 tasks/session pace, roughly **9–11 sessions** to the full v1.0 scope.

**Production-readiness level:** onboarding-capable (pre-alpha). The product's spine
is now real from first launch to the soul path: age gate → the data-driven quiz →
quit creation with the user's own motivations → lock-screen-class panic launch →
the ~90s flow rendering those motivations verbatim → either exit — averted (quiet
celebration) or slipped (the two-tap zero-shame slip flow with the live 10-minute
undo, on both the store-free cold route and the store route). Shipping-quality
mechanics: CI gates (engine floors, sole-importer lint, 64 snapshot goldens, UI
smokes, two permanent lexicon gates), signed TestFlight uploads on every green
merge, clock-integrity + erase + write-buffer + slip/undo semantics adversarially
reviewed and pinned; per-source panic attribution live at the platform's ceiling
(E3.3); the personalization payoff is LIVE (E5.3: the summary's savings hero +
risk-window hint + verbatim motivation echo; four permanent lexicon gates now: slip, age gate, quiz, summary).
Not yet product: no widget suite beyond the skeleton + the two panic controls, no
paywall (E7), no consent step or analytics transport (E8.2 + operator app ID) —
E6–E9 are the remaining distance to the MVP §7 release gates.

---

## Epic 0 — Walking Skeleton & De-risk Spike (Week 0)

Goal: an empty app that boots, builds, tests, and ships to TestFlight automatically — plus the measured verdict on the product's headline claim. Nothing else starts until E0.1–E0.3 are green.

### E0.1 Repo + CI pipeline (build → test → TestFlight)
- **Goal:** `main` produces a signed internal TestFlight build on every merge; unit + snapshot + UI-smoke lanes exist (even if near-empty).
- **Failing tests first:** `test_walkingSkeleton_appLaunches()` (XCUITest: app reaches a root view with accessibility id `root.placeholder`); a placeholder unit test `test_ci_runsSwiftTesting()` — both committed red before the workflow exists, so the first green CI run proves the whole pipeline.
- **Acceptance:** GitHub Actions (from `ci-templates`) runs unit → snapshot → UI-smoke → fastlane match sign → TestFlight upload; a broken test blocks upload; build number auto-increments.
- **Deps:** none. **[PKG:ci-templates]** for any reusable-workflow gaps found.

### E0.2 App targets + App Group + shared-package wiring
- **Goal:** app target, widget-extension target, App Group container, and SPM dependencies on StreakEngine/WidgetToolkit/PaywallKit (stub versions acceptable) plus the app-local `AnalyticsService` (TelemetryDeck wrapper) all compile under Swift 6 strict concurrency.
- **Failing tests first:** `test_appGroup_containerURL_isSharedBetweenTargets()` (writes a sentinel file from app-side test, asserts path derivation matches extension's), `test_packages_linkAndExposeEntryPoints()`.
- **Acceptance:** both targets build in CI; widget extension renders a static placeholder widget on device; strict concurrency = complete, zero warnings-as-errors exceptions.
- **Deps:** E0.1.

### E0.3 Panic-latency spike (measurement harness, throwaway UI)
- **Goal:** a lock-screen interactive AppIntent that opens a bare full-screen view, with a signposted measurement of lock-to-visible cold time on iPhone 15-class hardware. Produces the go/degrade copy decision (roadmap M0).
- **Failing tests first:** `test_panicIntent_setsLaunchFlag_inAppGroupDefaults()`, `test_sceneRoot_whenPanicFlagSet_buildsPanicPlaceholderNotTabs()`; on-device signpost assertion `test_panicColdLaunch_signpost_under2000ms()` (allowed to fail initially — it IS the spike question; it graduates to a permanent CI gate in E3).
- **Acceptance:** measured number recorded in `docs/spike-panic-latency.md` with device/OS matrix; decision (2s claim vs "fast") recorded; ControlWidget registration (Control Center + Action button) verified manually on device.
- **Deps:** E0.2.

**Epic 0 Definition of Done:** empty app on TestFlight via CI; all three tasks' tests green (or E0.3's latency gate consciously re-thresholded per spike verdict); spike doc + rename-gate status recorded; no product code beyond the panic placeholder.

---

## Epic 1 — StreakEngine (pure logic, portfolio package) **[PKG:StreakEngine]**

Goal: the highest-test-density code in the product — all streak/momentum/clock/undo/adherence math as a pure, I/O-free package. Unhooked is the anchor consumer defining the v1 API (architecture §14). This epic has no UI and can run fully parallel to E2's scaffolding.

### E1.1 Streak computation from anchors
- **Goal:** `currentStreak(for:now:)` returning days/hours, money saved, momentum %, next milestone — all derived, never stored.
- **Failing tests first:** `test_streak_daysAndHours_fromStartAnchor()`, `test_moneySaved_weeklySpendProRata()`, `test_momentum_cleanOverTotal_asPercent()`, `test_nextMilestone_selectsFirstUnreached()`, `test_streak_zeroSecondsAfterFreshStart()`.
- **Acceptance:** pure function, `Sendable`, no `Date()` calls inside (time injected via `TimeAnchor`); 100% branch coverage on this file.
- **Deps:** none (package repo).

### E1.2 Clock-integrity guard (monotonic anchor)
- **Goal:** `sanityCheck(anchor:now:)` → `normal | clockRolledBack | timezoneShift`; freeze-not-inflate semantics.
- **Failing tests first:** `test_clockSetBackward_streakFreezes_neverInflates()`, `test_clockSetBackward_thenRecovers_streakResumesFromAnchor()`, `test_timezoneTravel_westward_doesNotAddADay()`, `test_timezoneTravel_eastward_doesNotLoseADay()`, `test_rebootChangesBootID_fallsBackToWallClockSanity()`.
- **Acceptance:** the PRD §6.2 "streak never inflates" property holds under a property-based test sweeping random clock perturbations (`test_property_streakMonotonicUnderClockNoise()`).
- **Deps:** E1.1.

### E1.3 Slip archiving, momentum preservation, 10-minute undo
- **Goal:** `applySlip` archives current→best, restarts counter, preserves cumulative totals; `undoSlip` restores within window, nil after.
- **Failing tests first:** `test_slip_archivesToBest_whenCurrentExceedsBest()`, `test_slip_preservesTotalCleanSeconds()`, `test_momentum_survivesSlip_partialCredit()`, `test_undo_within10Minutes_restoresExactPriorState()`, `test_undo_at10MinutesPlus1Second_returnsNil()`, `test_bestStreak_neverDecreases_afterAnySlipSequence()`.
- **Acceptance:** append-only invariants asserted (best/totalClean monotonic non-decreasing) incl. a debug assertion path test.
- **Deps:** E1.1, E1.2.

### E1.4 Reduce-mode adherence
- **Goal:** `adherence(for:in:)` counting allowance-adherent days for the alcohol persona.
- **Failing tests first:** `test_reduceMode_dayUnderAllowance_isAdherent()`, `test_reduceMode_dayAtAllowance_isAdherent_overIsNot()`, `test_reduceMode_dayCloseUsesQuitTimezone()`, `test_reduceMode_streakCountsAdherentDaysNotAbstinence()`.
- **Acceptance:** day boundaries computed in the quit's timezone; DST-transition day handled (`test_reduceMode_dstTransitionDay_countsOnce()`).
- **Deps:** E1.1.

**Epic 1 Definition of Done:** package tagged v1.0.0; edge-case suite (all above) is a named CI release gate for the app; API reviewed against Vigil/Vakit/Keeper needs (no Unhooked-specific types leak into the package surface); zero I/O, zero Apple-framework imports beyond Foundation.

---

## Epic 2 — Persistence, Repository & Erase (Weeks 1–2)

### E2.1 Single SwiftData store in the App Group (CloudKit-mirrored)
- **Goal:** one SwiftData store (CloudKit-mirrored: Quit, Slip, UrgeEvent, QuizProfile, AppSettings) in the App Group container, per architecture §4. The v1.2 companion transcript store (`CompanionMessage`) is a *separate non-mirrored local store* so transcripts never sync (architecture §5.3) — added in Epic 12, not here.
- **Failing tests first:** `test_store_mirrorsExpectedModels()`, `test_companionTranscriptStore_hasNoCloudKitConfiguration()` (inspects ModelConfiguration — the auditable privacy promise; store added in E12), `test_allMirroredModelProperties_haveDefaultsOrOptionals()` (CloudKit constraint), `test_storeLivesInAppGroupContainer()`.
- **Acceptance:** widget extension opens the same store read-only; file protection classes set per §10 (`test_store_protectionClass_completeUntilFirstUnlock()`).
- **Deps:** E0.2.

### E2.2 QuitRepository
- **Goal:** the only component touching SwiftData contexts; synchronous-fast `logSlip`, `logUrgeEvent`, `activeQuits`, max-3 enforcement.
- **Failing tests first:** `test_logSlip_isSynchronous_noAwaitNoNetwork()` (type-level + timing assertion), `test_logSlip_persistsBeforeReturning()`, `test_activeQuits_excludesArchived()`, `test_createQuit_fourthActiveQuit_throwsLimitError()`, `test_repositoryWrite_triggersDebouncedWidgetReload()` (spy on `WidgetRefreshing`, asserts single reload for a 3-write burst within 500ms).
- **Acceptance:** zero-lost-data rule #1 holds: slip write precedes any UI transition; repository is the sole SwiftData importer outside trivial `@Query` lists (enforced by a lint/grep CI check).
- **Deps:** E2.1, E1.3.

### E2.3 CloudKit dedupe merge pass
- **Goal:** launch-time merge deduping `Quit` by `id`, keeping max per monotonic field (last-writer-wins can never shrink history).
- **Failing tests first:** `test_mergeDuplicateQuits_keepsMaxTotalTrackedSeconds()`, `test_merge_takesFieldwiseMax_bestStreak_totalClean()`, `test_merge_unionsSlipsWithoutDuplicates()`, `test_merge_noDuplicates_isNoOp()`.
- **Acceptance:** property test: any merge order yields identical result (`test_property_mergeIsCommutativeAndIdempotent()`).
- **Deps:** E2.1.

### E2.4 One-tap erase (local + CloudKit + caches)
- **Goal:** `eraseEverything()` deletes both stores, purges the CloudKit private zone, clears RevenueCat cache and app-group pre-caches, fires final analytics event if opted in.
- **Failing tests first:** `test_erase_deletesBothStoreFiles()`, `test_erase_requestsCloudKitZoneDeletion()` (mock CKContainer), `test_erase_clearsPanicPreCacheDefaults()`, `test_erase_appRelaunch_startsAtOnboarding()` (UI smoke).
- **Acceptance:** MVP §7 erase release-gate scriptable on device; fully-local mode (iCloud off) verified as first-class (`test_iCloudUnavailable_appFunctionsFullyLocal()` via mocked account status).
- **Deps:** E2.1, E2.2.

**Epic 2 Definition of Done:** all stores/repositories tested against mocked contexts and one on-device smoke; privacy-by-configuration tests (E2.1) run as part of the release gate; no view code touches SwiftData directly.

---

## Epic 3 — Panic Path (Weeks 1–2; the product's soul)

### E3.1 PanicIntent + first-class launch mode (productionizing the spike) **[PKG:WidgetToolkit — `InstantLaunch` module]**
- **Goal:** intent sets app-group flag; scene builds `PanicView` as root when flagged; SDK init deferred post-frame; motivations pre-cached to app-group defaults on every write.
- **Failing tests first:** `test_panicLaunch_skipsSDKInitBeforeFirstFrame()` (init-order spy), `test_motivationsPreCache_updatedOnEveryQuitWrite()`, `test_panicLaunch_withQuitID_selectsThatQuit()`, `test_panicLaunch_noQuitSelected_showsQuitPicker()`, permanent CI gate `test_panicColdLaunch_signpost_underBudget()` (threshold from E0.3 verdict).
- **Acceptance:** works from lock-screen widget, Control Center, and Action button with notifications off and Focus on (manual device checklist + XCUITest for in-app source); first frame performs zero store queries and zero network.
- **Deps:** E0.3, E2.2 (pre-cache write hook).

### E3.2 Panic flow UI (breath → timer → reasons → redirect → exits)
- **Goal:** the ~90s skippable sequence per PRD §6.4, haptic-guided 4-7-8 pacer, both exit states routing correctly.
- **Failing tests first:** `test_panicFlow_everyStepSkippable()`, `test_breathPacer_pattern_478_threeRounds()` (pattern model unit test), `test_reasonsStep_rendersVerbatimMotivations_fromPreCache()`, `test_exitUrgePassed_logsUrgeEventAverted()`, `test_exitSlipped_routesToSlipFlow()`, `test_panicFlow_recordsStepsReached()`, snapshot tests per step incl. Dynamic Type XXL.
- **Acceptance:** end-to-end completable with VoiceOver (XCUITest with accessibility audit) and haptics-only mode; quiet celebration on averted (no confetti-grade dopamine); `panic_step_reached` fires per step.
- **Deps:** E3.1, E2.2; motivations content requires E5.2 (stub motivations until then).

### E3.3 Panic entry-point matrix
- **Goal:** ControlWidget registration (Control Center, Action button, lock-screen control) + per-widget quit parameter; discreet variant titled "Reset".
- **Failing tests first:** `test_panicIntent_parameter_quitEntity_resolvesActiveQuits()`, `test_controlWidget_discreetMode_usesNeutralTitleAndSymbol()`.
- **Acceptance:** all four `panic_opened` sources reachable and correctly attributed; manual device matrix (lock screen / CC / Action button × Focus on/off) documented and green.
- **Deps:** E3.1.
- **Shipped Session 13 with one RECORDED ADJUSTMENT (platform ceiling, not drift — the E3.1 "pre-cache = FILE" precedent):** iOS exposes no launch-surface API for controls and one control registration serves Control Center, the lock-screen slots, AND the Action button with user-assigned placement (docs-checked: WWDC24 10157, WidgetKit docs). "Correctly attributed" therefore lands at entry-point-KIND granularity — lock-screen widget `.lockscreenWidget`, control family `.controlCenter`, in-app `.inApp` — and `.actionButton` stays reserved in `PanicSource` (never fabricated; the rejected alternative, a dedicated Action-button App Shortcut, also runs from Siri and pins the wrong meaning). Attribution is store-persisted only (`UrgeEvent.source`); `panic_opened` analytics remain E8.1.

**Epic 3 Definition of Done:** panic-latency CI gate permanent; entry-point device matrix green; flow accessible (VoiceOver + haptics-only + Dynamic Type); zero network dependency proven by airplane-mode manual test.

---

## Epic 4 — Slip Flow & Forgiveness (Week 2)

### E4.1 Slip logging UI (≤2 taps) + undo
- **Goal:** two-tap slip from dashboard or panic exit; archive + momentum framing; optional reflection note (autosaved on keystroke pause); 10-minute undo affordance.
- **Failing tests first:** `test_slipFlow_completesInTwoTaps_fromDashboard()` (XCUITest), `test_reflectionNote_autosavesOnPause()`, `test_undoBanner_visibleFor10Minutes_thenGone()`, `test_slipUndo_firesSlipUndoneEvent_andRestoresStreak()`, `test_slipLogged_afterUndoWindow_firesAnalyticsOnce()` (event fires post-window, not at tap — matches MVP §5 trigger).
- **Acceptance:** recovery framing shows archived best + momentum %; rate-limited celebrations but never rate-limited help (repeat slips always get resources link).
- **Deps:** E1.3, E2.2, E3.2 (routing).

### E4.2 Zero-shame copy enforcement
- **Goal:** every slip/relapse string passes the no-shame checklist; copy centralized in one audited strings table.
- **Failing tests first:** `test_slipStrings_containNoForbiddenLexicon()` (unit test scanning the strings table against a banned-word/phrase list: "failed", "ruined", "back to day 1", etc.); checklist review is the human half.
- **Acceptance:** copy audit checklist (MVP §7) signed; forbidden-lexicon test is a permanent CI gate.
- **Deps:** E4.1.
- **Shipped Session 14 exactly as planned** (no adjustments): the audited table is `slipCopy.json` decoded as `SlipCopy` (+ the new decode-tolerant `dashboard` section absorbing the last view-inline slip literals); the gate additionally scans the in-code degraded fallback and panicScript's slipped-exit labels, reflection-driven so future table fields can't dodge it; the banned list is superset-pinned against a frozen foundation floor ("only grows"). Checklist signature tracked in operator-expected §3.

**Epic 4 Definition of Done:** slip → undo → re-slip sequences fuzz-tested against StreakEngine invariants; post-slip screen shows momentum + best; copy gate in CI.

---

## Epic 5 — Onboarding Quiz, Age Gate & Summary (Week 2)

### E5.1 Age gate (first screen)
- **Goal:** birth-year entry; under-17 blocked to resources; only a boolean stored.
- **Failing tests first:** `test_ageGate_under17_blocksAndShowsResources()`, `test_ageGate_birthYearNeverPersisted()` (asserts AppSettings has only `ageGatePassed`), `test_ageGate_firesNoAnalyticsEvents()` *(Session 16 step-0 re-spec of the original `test_ageGate_firesAgeGateBlocked_withNoAgeProperty()` — `age_gate_blocked` is not an MVP §5 row, is structurally unfireable (consent lives post-gate), and would mark a blocked minor; the replacement pins the STRONGER claim: the whole surface fires nothing on either branch, opted-IN spy. PM decision + Architect co-sign under the safety-content gate; ledger Session 16)*.
- **Acceptance:** feasibility condition #6 met; no habit content reachable pre-gate.
- **Deps:** E2.1, E8.1 (event enum).

### E5.2 Quiz engine + 12–14 screens
- **Goal:** data-driven quiz (screens from a config array, one question each, progress bar) capturing habit/frequency/spend/triggers/motivations/goal; answers → `QuizProfile` + quit creation.
- **Failing tests first:** `test_quiz_everyStepAdvance_firesQuizStepCompleted(step:)`, `test_quiz_answersPersistLocallyOnly()`, `test_quiz_backNavigation_preservesAnswers()`, `test_quizCompletion_createsQuitWithMotivationsAndSpend()`, `test_quizCompletion_writesMotivationsPreCache()`.
- **Acceptance:** median completion ≤120s across 5 test users (beta checklist); screens scaffolded by agents, copy owned by founder; custom habit name never leaves device.
- **Deps:** E5.1, E2.2.

### E5.3 Personalized summary + social proof screen
- **Goal:** projected yearly savings + risk-window hint derived on-device; social-proof screen; hands off to paywall.
- **Failing tests first:** `test_summary_projectedSavings_matchesSpendMath()`, `test_riskWindowHint_derivedFromTriggerAnswers()`, `test_summary_shownBeforeAnyPaywall()` (navigation-order test), snapshot tests.
- **Acceptance:** PRD P0 story 1 satisfied: summary before paywall, always.
- **Deps:** E5.2.

**Epic 5 Definition of Done:** quiz funnel instrumented per-step and visible in a TelemetryDeck test dashboard; XCUITest runs the full quiz→summary path; age gate is un-bypassable (navigation test).

---

## Epic 6 — Widget Suite & Discreet Mode (Week 3)

### E6.1 Timeline provider + WidgetToolkit integration **[PKG:WidgetToolkit]**
- **Goal:** stateless provider reading shared store → StreakEngine → entries; midnight/DST rollover; stale-grace; `Text(timerInterval:)` ticking counters.
- **Failing tests first:** `test_timeline_entriesCrossMidnight_incrementDay()`, `test_timeline_dstSpringForward_dayBoundaryCorrect()`, `test_staleGraceEntry_showsLastKnownStreak_ticking()`, `test_provider_readsStoreReadOnly()`.
- **Acceptance:** rollover/stale logic lives in WidgetToolkit (portfolio-shared), only templates live in the app.
- **Deps:** E1.1, E2.1.

### E6.2 Widget families (accessoryRectangular/Circular/Inline, systemSmall/Medium, StandBy)
- **Goal:** all six surfaces per PRD §6.3, incl. rectangular's interactive Panic button and per-widget quit selector.
- **Failing tests first:** snapshot tests `test_snapshot_<family>_<lightDarkStandBy>()` (matrix), `test_rectangularWidget_panicButton_invokesPanicIntentWithQuitID()`, `test_widgetConfiguration_quitSelector_listsActiveQuitsOnly()`, `test_standby_eveningState_showsMadeItThroughCopy()`.
- **Acceptance:** every family updates ≤60s after a logged event (E2.2's debounced reload + manual device check); extension memory <30MB in Instruments.
- **Deps:** E6.1, E3.1.

### E6.3 Discreet mode + alternate icons + privacy overlay
- **Goal:** numbers-only/neutral variant for every family; "Calendar-ish"/"Timer" alt icons; app-switcher privacy overlay when discreet.
- **Failing tests first:** snapshot matrix `test_snapshot_<family>_discreet()` asserting no habit-identifying strings/symbols (string-scan on rendered accessibility labels: `test_discreetWidgets_accessibilityLabels_containNoHabitTerms()`), `test_altIcon_switch_appliesAndPersists()`, `test_appSwitcherOverlay_activeWhenDiscreet()`.
- **Acceptance:** MVP AC #10: no widget or icon in discreet mode names a habit; `discreet_mode_enabled` fires.
- **Deps:** E6.2.

**Epic 6 Definition of Done:** full snapshot matrix (6 families × light/dark/StandBy × normal/discreet) green in CI; 60s-staleness and timezone manual QA checklist done on device; widget-family reporting (`widget_active`) wired.

---

## Epic 7 — Monetization (Week 3–4)

### E7.1 PaywallKit + RevenueCat products **[PKG:PaywallKit]**
- **Goal:** entitlement state machine (`trial|active|lapsed|never`), products $6.99/mo + annual A/B $29.99 vs $39.99 with 3-day trial, restore, reinstall survival.
- **Failing tests first:** `test_entitlementState_mapsRevenueCatCustomerInfo()` (all four states, mocked), `test_trialStart_firesTrialStartedEvent()`, `test_restore_recoversEntitlement_withoutAccount()`, `test_entitlementCheck_offline_usesCachedState()`.
- **Acceptance:** sandbox + TestFlight verification per MVP §7 (trial start, conversion, monthly, restore, reinstall); pricing is config, not code.
- **Deps:** E0.2; app wiring needs E5.3.

### E7.2 Superwall variant adapter (teaser vs hard A/B)
- **Goal:** Superwall behind PaywallKit's interface (removable per ADR-4); variant assignment logged; teaser mode = 1-day local timer then re-present.
- **Failing tests first:** `test_paywallViewed_carriesVariantAndSource()`, `test_teaserMode_expiresAfter1Day_representsPaywall()`, `test_teaserExpiry_paywallSource_isTeaserExpiry()`, `test_superwallRemoved_paywallKitFallbackRendersHardVariant()` (the de-integration insurance test).
- **Acceptance:** variant flips remotely without app release (manual verification); both variants pass 3.1.1 copy review checklist.
- **Deps:** E7.1, E5.3.

### E7.3 Win-back offer (config)
- **Goal:** 50%-off annual win-back offered 7 days post trial-lapse via RevenueCat offer, no push dependency.
- **Failing tests first:** `test_winback_eligibility_trialLapsedPlus7Days()`, `test_winback_notShownToActiveOrNeverTrialed()`, `test_winbackPurchase_firesPurchaseWinbackAnnual()`.
- **Acceptance:** eligibility verified in sandbox time-travel; surfaced in-app (settings/paywall source), never via notification.
- **Deps:** E7.1.

**Epic 7 Definition of Done:** full sandbox purchase matrix documented and green; paywall never traps a user (failure paths always offer retry + restore); Superwall isolated behind PaywallKit; guideline-3.1.1 checklist signed.

---

## Epic 8 — Analytics & Privacy Enforcement (starts Week 1, closes Week 4)

### E8.1 Typed `AnalyticsEvent` enum + `AnalyticsService` (TelemetryDeck wrapper)
- **Goal:** the §5.1 architecture enum wrapped by the app-local `AnalyticsService` over the TelemetryDeck SDK — forbidden properties are unrepresentable; opt-in default OFF; on-device queue. (This is app code, not a shared portfolio package — architecture §14 lists no analytics package.)
- **Failing tests first:** `test_analyticsFacade_hasNoGenericTrackMethod()` (API-shape assertion), `test_slipLogged_payload_hasNoTimestampProperty()`, `test_everyEventCase_serializesOnlyWhitelistedKeys()` (exhaustive over `CaseIterable` fixtures), `test_optOut_sendsNothing()` (network spy).
- **Acceptance:** all MVP §5 events implemented; enum lands week 1 so every feature instruments against it from day one.
- **Deps:** E0.2.

### E8.2 Consent screen + payload audit harness
- **Goal:** quiz-adjacent opt-in (default off) + a repeatable MITM audit script for the release gate.
- **Failing tests first:** `test_consentDefaultsToOff()`, `test_analyticsEventsBlockedBeforeConsent()`; the audit itself is a documented manual/scripted gate (`docs/payload-audit.md`) run against a TestFlight build.
- **Acceptance:** intercepted traffic contains only §5 events/properties — no journal content, no slip timestamps, no custom names; audit checklist in release criteria.
- **Deps:** E8.1, E5.2.

**Epic 8 Definition of Done:** every analytics call site type-checks against the enum; payload audit executed and archived; App Privacy label drafted from the audit result.

---

## Epic 9 — Safety, Compliance & Accessibility (Week 4)

### E9.1 Resources screen + helplines + alcohol notice
- **Goal:** region-aware `helplines.json`, one tap from Settings and every slip flow; fixed alcohol withdrawal-danger notice shown once, calmly.
- **Failing tests first:** `test_resources_reachableFromSettingsAndSlipFlow_oneTap()` (navigation tests), `test_helplines_regionFallbackToGlobal()`, `test_alcoholNotice_shownOnceOnAlcoholQuitCreation()`, `test_resourcesViewed_firesWithSource()`.
- **Acceptance:** MVP AC #14; helpline data validated against a schema test (`test_helplinesJSON_matchesSchema()`).
- **Deps:** E2.2, E4.1.

### E9.2 Content-table audit (milestones)
- **Goal:** `milestones.json` per category, all "commonly reported" phrasing, no medical claims.
- **Failing tests first:** `test_milestonesJSON_matchesSchema()`, `test_milestoneCopy_containsNoMedicalClaimLexicon()` (banned-phrase scan: "cures", "reverses", "your lungs heal", etc.); human audit checklist for nuance.
- **Acceptance:** audit signed; file is bundled (ADR-9 — no hot updates).
- **Deps:** none (content task, parallelizable).

### E9.3 Accessibility pass
- **Goal:** VoiceOver through quiz/panic/slip; haptics-only pacer; Dynamic Type max without truncation.
- **Failing tests first:** `test_a11yAudit_quizPanicSlip_noViolations()` (XCUITest `performAccessibilityAudit`), `test_hapticsOnlyPacer_runsWithoutVisualDependency()`, snapshot tests at `.accessibility5` asserting no truncation on streak + paywall copy.
- **Acceptance:** MVP §7 accessibility gate green.
- **Deps:** E3.2, E4.1, E5.2, E7.2.

**Epic 9 Definition of Done:** all compliance release-gate items in MVP §7 "Safety & compliance" checkable; banned-lexicon tests permanent in CI; 17+ rating + clinical metadata drafted.

---

## Epic 10 — Beta, Review & Launch Hardening (Weeks 4–6)

### E10.1 External beta program
- **Goal:** ≥15 testers across the three personas; feedback loop; crash-free ≥99.5% via MetricKit.
- **Tests:** no new unit tests — the "test" is the beta checklist: quiz ≤120s median across 5 users, panic-latency field confirmation, widget staleness/timezone QA, discreet-mode real-phone check.
- **Acceptance:** MVP §7 crash-free + funnel-instrumentation-trust gates met; dashboards (quiz funnel by variant, panic source mix, RevenueCat cohorts) live.
- **Deps:** Epics 1–9 substantially complete (M2).

### E10.2 Submission package
- **Goal:** review notes (quiz-gated onboarding, PanicIntent, 17+ context, no accounts), App Privacy label, ASO assets under the **cleared name** (Gate G0), screenshots leading with lock-screen widget + privacy positioning.
- **Tests:** checklist-gated (MVP §7 "Submission package"); `test_release_bundleContainsNoExplicitTermsInMetadata()`-style lint on metadata files where automatable.
- **Acceptance:** submitted; 1–2 review rounds absorbed within roadmap weeks 5–6; month-3 kill/pivot checkpoint calendared.
- **Deps:** E10.1, Gate G0 (rename).

**Epic 10 Definition of Done:** v1.0 approved and live; launch dashboards trusted; incident/rollback plan (phased release at 1–2%/day initially) documented.

---

## Epic 11 — v1.1 Fast-Follow (post-launch weeks 1–2)

### E11.1 Live Activity urge timer **[partially PKG:WidgetToolkit]**
- **Goal:** 15-minute Dynamic Island countdown started from panic step 2.
- **Failing tests first:** `test_urgeTimer_liveActivityStartsFromPanicFlow()`, `test_liveActivity_endsAtTimerCompletion_orUrgeResolution()`, `test_liveActivity_discreetMode_neutralPresentation()`.
- **Acceptance:** works with Focus on; no notification dependency; degrades silently if Live Activities disabled.
- **Deps:** E3.2, launch stability.

### E11.2 Milestone share cards
- **Goal:** rendered-image share cards (no links, no server), anonymous-safe designs incl. discreet variant.
- **Failing tests first:** snapshot tests per card design, `test_shareCard_containsNoCustomHabitName()`.
- **Acceptance:** share sheet only; nothing transmitted by the app itself.
- **Deps:** E1.1.

### E11.3 Funnel iteration #1
- **Goal:** retire losing paywall variant; ASO keyword iteration; win-back cohort check with real lapse data.
- **Tests:** dashboard-driven; `test_paywallKit_frozenVariantRendersWithoutSuperwall()` when/if de-integration executes.
- **Deps:** 2+ weeks of launch data.

**Epic 11 Definition of Done:** v1.1 approved; Live Activity + share cards in field; A/B decision recorded with data.

---

## Epic 12 — v1.2 AI Urge Companion + Insights (gated; post-launch weeks 3–5)

Gate: v1.0 crash-free ≥99.5% and funnel showing signs of life (roadmap Phase-5 gate). If the kill/pivot trend is negative, this epic is cancelled.

### E12.1 Companion Cloudflare Worker **[PKG: SupaKit edge-fn AI-proxy pattern — ported to the Worker; App Attest rate limiter]**
- **Goal:** one stateless Cloudflare Worker (per ADR-5): App Attest verify → KV rate limit (10 msgs/day, 3 sessions/day per device) → keyword + Haiku-class safety screen → Claude Haiku-class coaching (max_tokens 300, prompt-cached system prompt) → strict JSON `{kind, text, remainingToday}`; fixed versioned crisis template.
- **Failing tests first (Worker test suite):** `test_missingOrInvalidAttest_rejected()`, `test_rateLimit_11thMessageOfDay_returnsRateLimited()`, `test_crisisKeyword_shortCircuits_toFixedTemplate_neverCallsCoachingModel()`, `test_postResponseSafetyCheck_flagsAndReplacesWithTemplate()`, `test_response_isStrictJSON_kindDiscriminated()`, `test_requestPayload_rejectsOversizeOrExtraFields()`, `test_kvRateCounters_olderThan7Days_expire()`.
- **Acceptance:** no content stored server-side; Worker logging metadata-only (counts + status codes); Claude key in the Worker secret store only; cost alarm configured (> $5/day pre-1k users).
- **Deps:** launch stability gate.

### E12.2 EvalHarness golden sets **[PKG:EvalHarness]**
- **Goal:** coaching-tone acceptance set + crisis-detection recall set gating every prompt/model change in CI (ADR-5).
- **Failing tests first:** the golden sets ARE the tests: `eval_crisisRecall_atLeast_targetOnGoldenSet()`, `eval_coachingTone_noMedicalAdvice_noMoralizing_onGoldenSet()` — committed red against an empty prompt, green once the v1 prompt passes.
- **Acceptance:** CI blocks any change to prompt/model files unless evals pass; crisis template content clinically reviewed (human gate).
- **Deps:** E12.1 (runs in parallel with prompt authoring).

### E12.3 Client chat UI + local-only transcripts
- **Goal:** opt-in labeled chat inside the panic redirect menu; `CompanionMessage` in a separate non-mirrored local store (never CloudKit-synced); offline fail-soft to bundled scripts.
- **Failing tests first:** `test_companionMessages_liveInNonMirroredStore()`, `test_request_carriesOnlyHabitCategory_noMotivationsNoNames()`, `test_offlineOrError_showsStaticUrgeScripts_neverDeadEnds()`, `test_rateLimitedResponse_showsStaticContent_neverUpsell()`, `test_crisisResponse_endsCoachingSession()`, `test_consentDisclosure_shownBeforeFirstUse()`.
- **Acceptance:** PRD §6.6 guardrails demonstrably enforced client-side and server-side; transcripts excluded from CloudKit (store-config test) and from erase-surviving caches.
- **Deps:** E12.1, E2.1.

### E12.4 On-device pattern insights + Health mindful minutes
- **Goal:** risk-window insight ("Sun 10pm–1am") computed on-device from `UrgeEvent`/`Slip` timestamps; opt-in HealthKit mindful-minutes write from breath pacer.
- **Failing tests first:** `test_riskWindow_computedFromLocalEventsOnly()`, `test_riskWindow_insufficientData_showsNothingNotGuesses()`, `test_mindfulMinutes_writtenOnlyWithHealthAuthorization()`.
- **Acceptance:** zero network involvement in insights (no new analytics properties); Health write opt-in via standard sheet.
- **Deps:** weeks of field data; E3.2.

**Epic 12 Definition of Done:** eval gates permanent in CI; cost dashboard + alarm live; safety review of crisis paths signed; consent copy shipped; ADR-2's no-second-backend rule (one Cloudflare Worker total, ADR-5) still holds.

---

## Portfolio Packages: Consumed vs Contributed (per architecture §14)

**Consumed by this app (work happens in the package repos, not here):**

| Package | Tasks that live there | This app's role |
|---|---|---|
| **StreakEngine** | ALL of Epic 1 (E1.1–E1.4) | Anchor consumer; Unhooked's requirements define the v1 API for Vigil/Vakit/Keeper |
| **WidgetToolkit** | E6.1 (rollover, stale-grace, timer-text helpers); E3.1's `InstantLaunch` module (intent→flag→dedicated launch pattern); E11.1 Live Activity helpers; discreet-variant pattern docs (E6.3) | Consumer + contributor of the panic-launch and discreet patterns |
| **PaywallKit** | E7.1 core entitlement machine; E7.2's Superwall adapter as an *optional removable module* | Consumer; contributes the Superwall adapter |
| **EvalHarness** | E12.2 harness plumbing (golden-set runner, CI gate action) | Consumer; golden-set *content* is app-specific and stays in this repo |
| **ci-templates** | E0.1 reusable workflows; new on-device panic-latency signpost job contributed back | Consumer + contributor |
| **SupaKit (pattern only)** | E12.1's edge-fn AI-proxy template (strict output contract, caps, key hiding) ported to the Cloudflare Worker; the App Attest anonymous rate-limit Worker contributed back as a template | Consumer of the pattern + contributor |
| **L10nPipeline** | Not consumed in v1 (EN only); TR fast-follow post-launch | Deferred |

**Stays in this app's repo:** all UI/flows (quiz, panic, slip, dashboard, paywall screens), widget templates, content JSONs (milestones/helplines/panicScript), the app's `AnalyticsEvent` enum, review/ASO/compliance materials, golden-set content, and the companion client UI.

**Sequencing rule for package work:** package tasks are scheduled inside their consuming epics (E1 alongside week 1, etc.) but merged to the package repos with their own CI, versioned tags, and no Unhooked-specific types in public APIs — the definition of "shared" is that Vigil/Vakit could consume the same tag unchanged.
