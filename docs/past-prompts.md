# Past Prompts: Unhooked — Session Log

Append-only ledger of build/design sessions. Newest entries at the bottom. Never edit a past entry after the fact — append corrections as new lines.

---

## 2026-07-07 · Session 01 · Portfolio-architect mission — design package authored & QA-reconciled

**Prompted.** Produce (and then release-QA) the full analysis/design documentation package for `unhooked-quit-widget`: a native iOS "quit-anything" app whose wedge is an **interactive lock-screen panic button** (AppIntents) landing the user in a <2s full-screen urge intervention, with forgiveness mechanics, multi-vice tracking, and privacy-absolutist (no-account, local-first) architecture. Analysis/design phase only — Markdown docs, no production code.

**Produced.** The 11-document package: `prd.md`, `feasibility-report.md`, `mvp.md`, `architecture.md`, `roadmap.md`, `implementation-plan.md`, `test-suite.md`, `frontend-brandkit.md`, `agent-workflows.md`, plus this log and `resume-prompt.md`. `feasibility-report.md`, `mvp.md`, and `architecture.md` were regenerated later than the planning docs; a QA pass reconciled the planning docs to the current architecture (see "Reconciliation" below).

### Key decisions

- **Feasibility verdict: GO WITH CAUTION.** Demand, willingness-to-pay (comparables charge $45–$100/yr vs the PRD's $29.99), technical foundation (iOS 26 interactive AppIntents), and portfolio fit all clear. Caution drivers: (1) the name "Unhooked" is burned by 5+ live in-category products (incl. a nicotine panic-button app) → **rename is a hard pre-build gate**; (2) the concept wedge is partly shipped (Quit All has ~70% of it at zero traction) → the winner is decided by funnel/brand/content, not features; (3) growth is founder-content-driven and the PRD commits to no content plan.
- **Stack.** Swift 6 + SwiftUI; WidgetKit + AppIntents + ActivityKit (P1); **single SwiftData store** in an App Group, CloudKit-mirrored (fully local when iCloud off); StoreKit 2 via **RevenueCat** + **Superwall** (paywall A/B is the business); **TelemetryDeck** opt-in via an app-local `AnalyticsService`; MetricKit crashes. P1 AI urge-companion = **one Cloudflare Worker** → **Claude Haiku-class**, authenticated by **App Attest** with **KV** per-device rate caps; transcripts on-device only. No first-party backend at v1 (portfolio cluster A2).
- **MVP scope.** Included: 12–14-step quiz funnel → hard-ish paywall; streak engine with slip-forgiveness + Momentum score + 10-min undo; Quit **and Reduce** goal modes (Reduce promoted to headline per research); up to 3 concurrent quits; full widget suite (lock-screen interactive rectangular + circular + inline, home small/medium) + discreet mode + alternate icons; interactive panic launch (<2s cold); ~90s panic flow; money-saved counter; safety layer (helplines, alcohol withdrawal notice); no-account privacy + one-tap erase; streak time integrity; opt-in category-only analytics. Excluded: community/social, content blocker, medical claims, Android, gambling module, shame mechanics, AI companion (P1), Live Activity (P1), share cards/insights/Health (P1), Screen Time API, lifetime SKU, non-EN localization, StandBy (v1.1).
- **Monetization.** $6.99/mo; annual **A/B $29.99 vs $39.99** (per feasibility, the PRD under-prices the category); **3-day** free trial on annual; **50%-off** win-back 7 days post-lapse; no lifetime SKU.
- **Success metrics.** Quiz completion ≥70%; completers→trial/paid ≥8%; trial→paid ≥35%; panic widget added by D1 ≥40%; panic uses/WAU ≥1.0; post-slip D7 retention ≥50%; D30 sub retention ≥65% (honest bar; PRD's 75% is the stretch); rating ≥4.7.

### Architectural choices (ADRs, current numbering)

ADR-1 native Swift 6/SwiftUI · ADR-2 no backend / no accounts · ADR-3 SwiftData + CloudKit mirroring · ADR-4 RevenueCat + Superwall · ADR-5 Claude Haiku behind one Cloudflare Worker (App Attest + KV) · ADR-6 snapshot-driven thin panic launch (<2s) · ADR-7 monotonic-anchor streak integrity · ADR-8 TelemetryDeck opt-in + MetricKit only · ADR-9 static content in-bundle (no CDN) · ADR-10 Reduce mode as a first-class engine mode.

Data models: `Quit`, `Slip`, `UrgeEvent`, `QuizProfile`, `AppSettings` (+ `PanicSnapshot` JSON for the thin panic/widget read path; static `MilestoneTable`/`HelplineDirectory`). Reduce mode uses `Quit.weeklyAllowance` + `Slip.countsAgainstAllowance` — no separate allowance entity.

### Reconciliation (QA pass — planning docs aligned to the regenerated architecture/MVP)

Edited `roadmap.md`, `implementation-plan.md`, `test-suite.md`, `agent-workflows.md`, `frontend-brandkit.md` to remove drift from the older planning docs:
- **AI backend:** Supabase Edge Function / Sonnet / Postgres+pg_cron → **Cloudflare Worker / Claude Haiku-class / KV counters** (ADR-5).
- **Shared-package name:** dropped the non-existent **`TelemetryKit`** package; analytics is the app-local `AnalyticsService` wrapping TelemetryDeck (architecture §14 lists no analytics package). Added SupaKit (pattern only) where the Worker template was mis-attributed.
- **Persistence:** **split `Synced.store`/`LocalOnly.store`** → **single CloudKit-mirrored store** (architecture §4); v1.2 companion transcripts held in a separate non-mirrored store.
- **Data-model names:** `QuizResponse` → `QuizProfile`; removed `AllowanceDay`.
- **Pricing/trial:** fixed `$39.99` / `7-day` / `$24.99` → **A/B $29.99 vs $39.99 / 3-day / 50%-off** (MVP §6).
- **ADR renumbering:** planning-doc citations corrected to current numbers (panic thin-launch → ADR-6; Superwall removability → ADR-4; Worker/prompt-eval/App Attest → ADR-5; static-content-in-bundle → ADR-9).

### Pending items (carried into the build phase)

- **Gate G0 — rename** (BLOCKING for App Store Connect / ASO / marketing; not for code). Clear against App Store search + USPTO + domains.
- **Content plan** (feasibility condition #2): cadence + 10 lock-screen-demo formats + 2-week pre-launch bank.
- **Panic-latency spike** on a physical iPhone 15-class device (Epic 0 / ADR-6) → sets the "<2s" vs "fast" copy decision.
- Create bundle ID / App Group ID / CloudKit container ID **after** the rename.

### Gate status

Design docs: complete and consistent. Feasibility: GO WITH CAUTION. No code, no CI, no TestFlight build yet. MVP §7 release criteria: 0 checked (pre-build).

### Next session

Enter build at **Epic 0 (walking skeleton + spike)** per `implementation-plan.md`, TDD-first — see `resume-prompt.md` for the exact resume prompt.

---

## 2026-07-07/08 · Session 02 · Epic 0 — walking skeleton, CI red→green

**Prompted.** Execute the resume prompt: Epic 0 (E0.1 repo+CI, E0.2 targets+App Group+package wiring, E0.3 panic-latency spike harness), TDD-first, honoring all locked canonical facts.

**Produced.**
- **E0.1:** XcodeGen-defined project (`project.yml`; `.xcodeproj` generated, never committed); GitHub Actions CI (`.github/workflows/ci.yml`): package `swift test` lanes on Linux (official `swift:6.1` container, 1x minutes), app build + unit + snapshot + UI-smoke lanes on `macos-26`, secrets-gated **dormant TestFlight lane** (fastlane `beta` in `fastlane/Fastfile`; build number auto-increments from run number; broken tests block upload via `needs`). Placeholder unit test `test_ci_runsSwiftTesting` + XCUITest `test_walkingSkeleton_appLaunches` (root view `root.placeholder`).
- **E0.2:** app + widget-extension targets, iOS 26.0, Swift 6 language mode, `SWIFT_STRICT_CONCURRENCY=complete`, warnings-as-errors — compiled clean on first CI build. App Group container + shared `AppIdentifiers`/`PanicLaunchFlag`/`LaunchRouter` sources in both targets. Local stub SPM packages `Packages/{StreakEngine,WidgetToolkit,PaywallKit}` + inert app-local `AnalyticsService` with **uninhabited** `AnalyticsEvent` enum (cases land in E8.1 from MVP §5 only).
- **E0.3 (harness; measurement operator-pending):** `OpenPanicIntent` (AppIntents, `openAppWhenRun`, sets App Group flag) wired to an interactive accessoryRectangular panic button + `PanicControlWidget` (Control Center/lock screen/Action button); thin scene routing (`LaunchRouter` → bare `PanicPlaceholderView`, id `root.panicPlaceholder`); `PanicColdLaunch` os_signpost interval; device-only `test_panicColdLaunch_signpost_under2000ms` (XCTSkips on simulator); `docs/spike-panic-latency.md` operator runbook with PENDING verdict.
- **Docs:** `docs/session-rules.md` (permanent session rules incl. Linux-environment consequences), spike doc, this entry, refreshed `resume-prompt.md`.

### Red (TDD §7.1 evidence — CI run 28900862981 on commit 22acc72)

```
✘ test_appGroup_containerURL_isSharedBetweenTargets — AppIdentifiers.appGroupContainerURL → nil
✘ test_panicIntent_setsLaunchFlag_inAppGroupDefaults — Expectation failed: PanicLaunchFlag.isSet()
✘ test_sceneRoot_whenPanicFlagSet_buildsPanicPlaceholderNotTabs — resolveRoot → .placeholderTabs
✘ snapshotLane_recordsAndComparesDeterministicValue — No reference was found on disk
✘ test_walkingSkeleton_appLaunches — no root.placeholder accessibility id
✘ test_panicRoute_landsOnPanicPlaceholder — no root.panicPlaceholder accessibility id
⊘ test_panicColdLaunch_signpost_under2000ms — skipped on simulator (device-only, by design)
✔ package lanes ×3, test_ci_runsSwiftTesting, test_packages_linkAndExposeEntryPoints
```

Green: commit 05845b7 (minimal implementation + snapshot reference recorded by the red run's CI artifact) + commit f968731 (CI fix below).

### Key decisions

- **No portfolio repos exist** (checked `aytekXR/*`): StreakEngine/WidgetToolkit/PaywallKit live in-repo as local SPM stub packages; extraction deferred until a second consumer appears. ci-templates likewise: the workflow is authored in-repo as the future template seed.
- **Placeholder identifiers, never registered:** `dev.placeholder.quitwidget[.widgets]`, App Group `group.dev.placeholder.quitwidget.shared`. Gate-G0 sweep list at the top of `project.yml` (bundle IDs, entitlements, `CFBundleDisplayName`s, `AppIdentifiers.swift`).
- **AnalyticsService stub without the TelemetryDeck SDK** — E0.2 only requires it to compile; SDK + consent gate + enum cases are E8.1. Uninhabited enum = zero events representable (strongest ADR-8 posture).
- **Package tests on Linux CI** (1x minutes vs 10x macOS) while stubs are Foundation-only; lanes move to macOS when Apple-framework imports land (noted in each Package.swift).
- **Dev machine is Linux:** local Swift 6.1.2 toolchain installed for package TDD; app-target red→green driven through CI (documented in `session-rules.md`).
- **Widget scope held to accessoryRectangular only** (satisfies E0.2 render + E0.3 panic surface); other families are Epic 6.

### CI fix log

- `CODE_SIGNING_ALLOWED=NO` skipped entitlement embedding → iOS 26 simulator returned nil for the App Group container (run 28901564178, one red test). Fixed with ad-hoc simulator signing `CODE_SIGN_IDENTITY=-` (f968731). No test assertion was weakened.
- Ad-hoc signing then required Info.plists on the three test-bundle targets (run 28902502008, build failure). Fixed with `GENERATE_INFOPLIST_FILE=YES` on the test targets (2f3cea4).
- **Final green: run 28902758841 on 2f3cea4** — packages ×3, build, unit 5/5, snapshot 1/1, UI smoke 2/2 + 1 device-only skip; TestFlight gate dormant, upload skipped.
- Post-green: `paths-ignore` for `docs/**`/`*.md` added so docs-only pushes don't consume macOS minutes.

### Known limitations / operator-owned items (unchanged blockers)

1. **Gate G0 rename** — blocks TestFlight/App Store Connect/ASO; not code. TestFlight lane activates by provisioning secrets `ASC_API_KEY_P8_BASE64/ASC_KEY_ID/ASC_ISSUER_ID/MATCH_GIT_URL/MATCH_PASSWORD` post-rename.
2. **E0.3 on-device measurement** — harness shipped; physical iPhone 15-class run + verdict recording per `docs/spike-panic-latency.md` is operator work. Blocks marketing copy only.
3. **Content plan** (feasibility condition #2) — untouched, operator-owned.
4. **Drift note filed:** MVP §7 "<2s, 10/10 attempts" vs test-suite §1.5 "p90 < 2s" — spike doc records both; canonical reconciliation is an operator decision.
5. E0.2's "widget renders on device" acceptance and ControlWidget registration are folded into the operator's spike-day checklist.

### Gate status

CI green on `main` (packages ×3, build, unit, snapshot, UI smoke; TestFlight gate reports dormant). Epic 0 DoD met except the two operator-owned items above. MVP §7: still 0 checked (release criteria are release-time gates).

---

## 2026-07-08 · Session 03 · Epic 1 — E1.1 streak computation + E1.2 clock-integrity guard, red→green×2

**Prompted.** Execute the resume prompt: E1.1 (streak computation from anchors) in `Packages/StreakEngine`, strictly TDD-first; continue into E1.2 (clock-integrity guard) only if E1.1 fully green with the coverage bar met. Ultracode session: design, expectation-verification, and diff review ran as multi-agent workflows (3-designer judge panel → synthesized API; 3-lens red-test verification; 4-dimension review with 28 adversarial verifiers).

**Produced.**
- **E1.1 (commits 264e9b1 red → 7281c6a green):** time seam `MonotonicAnchor`/`MonotonicNow`/`ClockSanity` (Clock.swift), domain-neutral `QuitSnapshot` + `Milestone`/`MilestoneTable` (Snapshot.swift), derived-only `StreakValue` (computed `days`/`hours`/`momentumPercent` over stored `elapsedSeconds`; deliberately not Codable), pure static core `StreakCalculator` (the single 100%-branch-coverage file), DI seam `StreakCalculating` + thin forwarders in a separate file. The five named tests plus a guard-branch edge suite; seam-agreement test (instance == static).
- **E1.2 (commits 1801010 red → 4ea5b36 green):** `sanityCheck(anchor:now:monotonic:tolerance:)` → `normal | clockRolledBack | timezoneShift` and `conservativeElapsedSeconds(...)` over one shared `evaluate()`; within a boot the monotonic uptime delta is ground truth whenever wall disagrees beyond tolerance (60s) — jumps in EITHER direction can neither inflate nor reset; quarter-hour-multiple jumps ≤14h classify `.timezoneShift`; reboot (bootID mismatch) falls back to wall clock floored at 0. `currentStreak` signature unchanged — guard activates only when both anchor and reading are present. Five named tests + `test_property_streakMonotonicUnderClockNoise` (SplitMix64, pinned seed, 300 steps, property |display − truth| ≤ tolerance).
- **Review fixes (commits 890f8a7 red → 657b99b green → 92174c1 hardening):** see CI-fix-log analogue below.
- Final state: 29/29 package tests green locally; llvm-cov 100% regions/functions/lines on StreakCalculator.swift AND the whole package (§2 floor 98% exceeded).

### Red (TDD §7.1 evidence — local `swift test`, Linux toolchain, per session-rules environment note)

E1.1 red run (pre-implementation, commit 264e9b1): all 14 new tests failed, 36 issues; only the E0 skeleton test passed.
```
✘ Suite "E1.1 streak computation from anchors" failed with 23 issues.
✘ Suite "E1.1 computation guard branches" failed with 13 issues.
  e.g. (value.elapsedSeconds → 1) == 0 · (saved → -1) == 4562.5 ·
       (next?.afterHours → -1) == 72 · (value.momentumPercent → 0.0) == 75.0
✘ Test run with 15 tests failed after 0.017 seconds with 36 issues.
```
E1.2 red run (commit 1801010): 8 of 9 new tests failed, 329 issues (the ninth — anchored-quit-without-reading — passes by design: it PINS existing E1.1 wall-clock behavior through the guard change).
```
✘ "a rolled-back wall clock freezes the streak…" — sanityCheck → .timezoneShift (stub) == .clockRolledBack failed
✘ "under any seeded wall-clock noise…" — (abs(display - truth) → 27378) <= 60 failed
✘ Test run with 25 tests failed after 0.035 seconds with 329 issues.
```
Review-fix red run (commit 890f8a7): `(rolledBack.momentum → 0.9090…) == (honest.momentum → 0.6666…)` failed — the executable form of the review finding.

### Key decisions

- **API surface (judge-panel synthesis):** architecture §5.1's sketch refined — `nextMilestone(elapsedSeconds:in:)` primitive (the `for quit:table:` shape can be added non-breakingly if a consumer needs it); `now: Date` + optional `MonotonicNow` (no wall clock inside `MonotonicNow` — `now` IS the wall clock); `momentum` primitive returns the §5.1 fraction 0...1, `StreakValue.momentumPercent` is the percent view; money exact/unrounded `Decimal`, multiply-before-divide (divide-first drifts: 4562.4999… vs exact 4562.5), rounding is a presentation/currency concern.
- **Naming mapping (docs ↔ code):** the docs' informal "TimeAnchor/ClockProvider seam" ships as `MonotonicAnchor` (persisted, matches architecture §3's field) + `MonotonicNow` (read-time evidence). `ClockProvider` is deliberately NOT a package type — it is the app/test-side protocol that PRODUCES readings; the pure core only consumes values.
- **Ratified semantics** (previously unstated anywhere authoritative): zero-tracked momentum = 1.0 (no-shame: nothing tracked ⇒ nothing wasted); milestone "reached" is boundary-inclusive (at exactly `afterHours` the milestone is earned, next pointer advances); money/momentum numerators use CUMULATIVE clean (priorCleanSeconds + guarded elapsed); non-positive inputs clamp to safe values, never error; `days` = elapsed 24h blocks (TZ-invariant absolute time per ADR-7).
- **Consumer contract for uptime:** readings must come from a sleep-inclusive monotonic clock (mach_continuous_time / CLOCK_BOOTTIME derived), else device sleep reads as a forward wall jump. Documented on `conservativeElapsedSeconds`.
- **Forward wall jumps are guarded too** (beyond tolerance, non-TZ-shaped ⇒ `.clockRolledBack` verdict naming an integrity failure, conservative monotonic value displayed) — inflation via clock-forward is blocked within a boot.
- **Red-commit mechanics:** sentinel-stub bodies (compile-and-fail) matching the E0 precedent; sentinels chosen so no test passes from birth (verified adversarially before commit A).

### Review (ultracode adversarial pass over the full E1 diff)

4 reviewers (correctness / spec-DoD / API-Swift6 / test-quality) → 28 findings → 28 independent refutation-first verifiers → **15 confirmed (net 10 distinct), 13 refuted**. Fixed:
- **MAJOR (real bug, fixed 890f8a7→657b99b):** momentum's denominator `tracked` came from the raw `now` while the numerator was clock-guarded — a 40-day rollback on a 100-day history inflated momentum 66.7%→90.9%. Latent (needs E1.3-populated fields) but reachable via the public init. Fix: `tracked = guarded elapsed + fixed (startAt − trackedSince) offset`.
- Hardening (92174c1): overflow-safe milestone predicate; deterministic property-test draws (author-owned SplitMix64 modulo — `Int.random(in:using:)` sequence is not guaranteed stable across toolchains); TZ-shape boundaries pinned exactly (960/961, 840/839, 50460/51300); rewound-uptime ⇒ conservative zero; reading-without-anchor ⇒ guard off; tautological assertion removed; `anchor.wallClock == startAt` expectation documented.

### Known limitations / carried items

1. **Reboot high-side sanity cap deferred (ADR-7 gap, deliberate):** across a reboot the wall delta is trusted uncapped upward — a reboot + forward-set clock can inflate. The principled cap needs a persisted last-known-good wall reading, which arrives with the Epic 2 repository. Carried at the top of resume-prompt.md; the property test covers within-boot noise only.
2. `StreakCalculating` protocol does not yet expose `sanityCheck`/`conservativeElapsedSeconds` (deferred to first consumer need, will ship with protocol-extension defaults to stay non-breaking).
3. Epic-1 DoD items that wait for E1.3/E1.4: package v1.0.0 tag, edge-case suite as a named CI release gate, Vigil/Vakit API review.
4. Operator-owned blockers unchanged from Session 02 (Gate G0 rename; E0.3 device measurement; content plan; MVP §7 vs test-suite §1.5 latency-drift decision).

### Gate status

Local: 29/29 green, package coverage 100%. CI: pushed after close-out docs; package lane is the binding lane for this session's work (see resume-prompt for the verified run).

---

## 2026-07-08 · Session 04 · Epic 1 — E1.3 slip archiving + undo, E1.4 Reduce adherence, red→green×2 (+2 review cycles)

**Prompted.** Execute the resume prompt with workflows: E1.3 (slip archiving, momentum
preservation, 10-minute undo) in `Packages/StreakEngine`, strictly TDD-first; continue
into E1.4 (Reduce-mode adherence) only if E1.3 fully green with the coverage bar met.
Multi-agent workflows ran at three gates: 3-lens red-test verification before commit A,
then a 4-dimension adversarial review of the E1.3 diff (14 agents) and a 3-dimension
review of the E1.4 diff (10 agents), every finding refutation-first verified.

**Produced.**
- **E1.3 (e31b7b2 red → e029149 green → e0702b5 refactor):** `QuitSnapshot` gained
  trailing-defaulted `bestStreakSeconds` + `pendingUndo` (init order preserved — the
  portfolio non-breaking rule); new `PendingSlipUndo` records exactly the overwritten
  fields. `applySlip(to:at:monotonic:)` banks the GUARDED elapsed into
  `priorCleanSeconds` (negative banks heal to 0), archives `max` into best, restarts the
  counter, re-anchors from the reading (clears a stale anchor without one).
  `undoSlip(on:at:monotonic:)` restores the exact prior state within a
  boundary-inclusive 600s window measured on the guarded timeline (rollback can't
  stretch it, forward-set can't burn it, reboot falls back to floored wall); nil after,
  nil with nothing pending; a newer slip finalizes the older undo. Append-only
  invariant: pure `appendOnlyViolations` detector asserted (message-less `assert` —
  probed llvm-cov first: a message autoclosure costs a region, message-less is clean).
- **E1.3 review fix (f071664 red → 25907ea green):** see review section — MAJOR.
- **E1.4 (ff08443 red → 624b0e2 green):** `Adherence` readout (adherent/evaluated days)
  + `adherence(for:in:allowancePerDay:timezone:)` in AdherenceCalculator.swift — the
  package's first timezone-aware math, kept out of the absolute-time core, own 100%
  bar. Whole-day evaluation (the window selects days; end-at-midnight exclusive;
  zero-duration windows evaluate their single day), at-or-under inclusive, negative
  allowance clamps to 0, fixed Gregorian calendar over an injected `TimeZone`.
- **E1.4 review fix (6ca7318 red → 6b1b009 green) + hardening (079ebb7):** see below.
- Final state: 63/63 package tests green locally; llvm-cov 100% regions/functions/lines
  on the whole package. Zero app-target/SwiftData/UI changes (scope guards held).

### Red (TDD §7.1 evidence — local `swift test`, Linux toolchain)

E1.3 red run (pre-implementation, commit e31b7b2): all 21 new tests failed (204 issues),
29/29 pre-existing green; sentinels verified pass-from-birth-proof (an early empty-list
detector sentinel let one test pass from birth — flipped to a cries-wolf sentinel before
committing):
```
✘ Suite "E1.3 append-only invariant detector" failed after 0.026 seconds with 6 issues.
✘ Suite "E1.3 slip and undo boundaries" failed after 0.026 seconds with 22 issues.
✘ Suite "E1.3 slip archiving and 10-minute undo" failed after 0.045 seconds with 182 issues.
✘ Test run with 50 tests failed after 0.046 seconds with 210 issues.
```
E1.3 review-fix red (f071664): `(atTick.momentum → 1.0) == (before.momentum → 0.9565…)`
and `(corrected.clockSanity → .clockRolledBack) == .normal` — the executable finding.
E1.4 red run (ff08443): all 9 new tests failed against the (-1,-1) sentinel
(`✘ Test run with 60 tests failed after 0.026 seconds with 14 issues.`), 51/51 prior green.
E1.4 review-fix red (6ca7318): `(value → Adherence(adherentDays: 3, evaluatedDays: 4))
== Adherence(adherentDays: 4, evaluatedDays: 4)` — the Santiago drift, reproduced.

### Key decisions (ratified this session)

- **Slip semantics:** the slip instant is `quit.startAt + guardedElapsed` — the quit's
  own guarded timeline, never the raw wall `now` (never moves the start backward); the
  new anchor's `wallClock` rides the same instant (preserves `anchor.wallClock ==
  startAt`). Momentum is UNCHANGED in the same tick across a slip (the ended streak
  banks whole; "partial credit" = the partial value survives, it is not reset).
- **Undo semantics:** boundary-inclusive 600s (`undoWindowSeconds`), measured on the
  guarded timeline; one reversible slip at a time — a newer slip finalizes the older
  undo, so a post-undo state never chains restorations; without monotonic evidence a
  wall clock behind the slip reads zero elapsed (window stays open — freeze-not-inflate
  favors the user; accepted asymmetry). Undo is the ONE sanctioned decrease of
  best/priorClean (§9 rule 3); the append-only assert is applySlip-scoped by design and
  a test pins that the detector WOULD flag undo (the exemption is load-bearing).
- **Adherence semantics:** day-based primitive `adherence(for:in:allowancePerDay:timezone:)`
  (implementation-plan naming) — architecture §5.1's weekly `adherence(slipsThisWeek:
  allowance:)` sketch maps consumer-side, addable non-breakingly at first need, same
  policy as the deferred `StreakCalculating` exposure of sanityCheck/applySlip/undoSlip.
  Whole-day evaluation; half-open day membership; day boundaries re-anchor to
  `startOfDay` every step (midnight DST transitions).
- **Docs reconciled:** test-suite §1.1 item 7 rewritten — the "slips/undos" monotonicity
  property was unpinnable as written (undo lowers stored fields by design); its
  invariant citation now points at architecture §8's sync rule, with §9 rule 3 named as
  the undo exemption. StreakCalculator's momentum comment no longer promises a
  slip-caused gap.

### Review (workflow gates; every finding refutation-first verified)

- **Red verification (3 lenses, pre-commit-A):** red-mechanics PASS; 6 minor findings →
  2 verifier-suggested edge tests folded into the red commit (undo across reboot,
  negative-bank healing), sanctioned-undo exemption pinned, citation fixed.
- **E1.3 diff review (4 dims → 9 findings → 14 agents): 2 confirmed (1 distinct MAJOR),
  7 refuted.** MAJOR (3 dimensions converged; fixed f071664 → 25907ea): `applySlip`
  stamped `startAt = now` (raw wall) while banking guarded elapsed — a slip under a
  rolled-back clock collapsed the momentum denominator's span (`startAt − trackedSince`
  46d → 16d), momentum clamped to 1.0 permanently, and the mispinned anchor kept the
  verdict at `.clockRolledBack` after the clock healed. Session 03's inflation class,
  reintroduced at the slip boundary.
- **E1.4 diff review (3 dims → 7 findings → 10 agents): 4 confirmed, 3 refuted.**
  MAJOR (fixed 6ca7318 → 6b1b009): chaining `byAdding .day` without re-anchoring
  drifted every day boundary to 01:00 after a spring-forward AT local midnight
  (America/Santiago) — verified by probe, adherence read 3/4 for 4 clean days. Plus two
  confirmed mutant-survival gaps (whole-day evaluation vs window-clamped counting;
  half-open midnight membership) — killed by hardening tests (079ebb7).

### Known limitations / carried items

1. **Reboot high-side sanity cap still deferred (ADR-7 gap, Session 03):** unchanged;
   lands with the Epic 2 repository (red test first). `undoSlip` inherits it knowingly:
   across a reboot the undo window is floored-wall-measured (test pins the asymmetry).
2. `StreakCalculating` still exposes neither the E1.2 guard nor applySlip/undoSlip/
   adherence — deferred to first consumer need with protocol-extension defaults.
3. `QuitSnapshot`'s synthesized Codable now requires the `bestStreakSeconds` key —
   irrelevant until something persists (Epic 2); revisit with the repository's
   migration story (review finding, refuted as premature but worth carrying).
4. Epic-1 close-out items NOT done here by scope guard ("one session, one objective"):
   package v1.0.0 tag, edge-case suite as named CI release gate, Vigil/Vakit API
   review — they are the next session's objective.
5. Operator-owned blockers unchanged (Gate G0 rename; E0.3 device measurement; content
   plan; MVP §7 vs test-suite §1.5 latency-drift decision).

### Gate status

Local: 63/63 green, package coverage 100% (all seven source files individually 100%).
CI: pushed after close-out docs; package lane binding (see resume-prompt).

---

## 2026-07-08 · Session 05 · Epic 1 close-out (CI gate + portfolio API review + v1.0.0 tag) → E2.1 red→green; CI billing outage at the finish line

**Prompted.** Execute the resume prompt with workflows: Epic 1 close-out — (1) StreakEngine
edge-case suite as a named merge-blocking CI release gate with a mechanical ≥98% coverage
floor, (2) adversarial portfolio API review (architecture §14), (3) tag
`streakengine-v1.0.0` — then, all three green and CI-verified, enter E2.1.

**Produced.**
- **Close-out 1 — CI release gate (commits A 7b729de + fix af5b969):** new named job
  `Release gate · StreakEngine edge-case suite` (Linux `swift:6.1-noble`, every push/PR);
  TestFlight lane `needs` it, so a red gate structurally blocks release. Mechanical floors
  per test-suite §2: line ≥98% package-wide, region ≥95% on StreakCalculator.swift +
  SlipTransition.swift (Swift emits regions; regions are the branch bar). Fails closed on
  missing TOTAL row or renamed files. StreakEngine left the generic package matrix (no
  double spend); macOS lanes untouched. Verified before push inside the real container
  image (GATE_PASS + 4 synthetic trip cases). One CI fix: the container's step shell is
  dash — `set -o pipefail` died; `shell: bash` pinned (the gate failed CLOSED, and the
  red-gate run proved the merge-block: TestFlight lane reported `skipped`). Branch
  protection is off (direct-push workflow); registering the job name as a required check
  is recorded in the job comment as an operator option.
- **Close-out 2 — portfolio API review (ultracode workflow: 5 lenses → 17 raw → 9 merged
  → 3-verifier refutation-first panels → 6 confirmed, 3 refuted + completeness critic;
  2 verdicts lost to API errors were re-run):** landed as commits B–F —
  - red→green **version marker** (B 929f64a red: `(version → "0.0.1-skeleton") ==
    "1.0.0"` failed; C 73cb3ca green): `StreakEngine.version == "1.0.0"`, enum doc
    rewritten present-tense; app-side pin updated in the same change.
  - **platform floor** (D 6b706e5): `.iOS("26.0")/.macOS("15.0")` → `.iOS("18.0")/
    .macOS("15.0")` — one release train, Swift 6 stdlib pair; a Foundation-only math
    package must sit below its consumers; lowering later is the non-breaking direction.
  - **`QuitSnapshot` → `StreakSnapshot`** (E 994f33a, refactor-on-green, upheld 3/3 —
    code-truth/policy/consumer-impact): the one public identifier carrying the
    quit-a-habit domain noun through every headline signature, on a surface whose DoD
    literally gates "no Unhooked-specific types leak" — a prayer-streak consumer (Vakit)
    cannot sensibly construct a "QuitSnapshot". Renamed in the sanctioned pre-tag window
    (zero external consumers; zero app call sites, grep-verified). Internal param names
    `quit`→`snapshot` rode along (declaration-only); architecture §5.1 sketch reconciled.
    The app-side `PanicSnapshot.quits` DTO (§3) keeps its name — the rename disambiguates.
  - **doc sweep** (F d725a5a): two stale public claims fixed (applySlip "restarts the
    counter at `now`" → guarded slip instant; ClockSanity "Always .normal until the guard
    lands" → present-tense trigger condition) and the public `///` surface made
    self-contained (E1.x/ADR-n/§-refs/Session-N/MVP-feature-n citations stripped or
    restated; breadcrumbs live on in non-doc `//` comments).
  - Refuted (not applied, by design): 'clean' vocabulary as recovery-framing;
    adherence-as-ceiling inversion for Vakit; Adherence "Reduce mode" doc framing.
- **Close-out 3 — tag:** annotated `streakengine-v1.0.0` on af5b969, pushed, after CI run
  28975058859 went fully green (gate floors measured in CI: 100/100/100).
- **E2.1 (commits G 09b3a90 red → H ae4d34f green):** full architecture §3 model graph
  (Quit/Slip/UrgeEvent/QuizProfile/AppSettings + typed enums + `QuizAnswer` blob;
  `monotonicAnchor` persisted as the engine's Codable type), `PersistentStore` factory
  (schema, `<App Group>/Library/Application Support/unhooked.store`, explicit
  `cloudKitDatabase: .none` until Gate G0 — `.automatic` would silently mirror the moment
  an entitlement appears; flip is red-test-first per test-suite §4.3), three
  doc-canonical simulator-honest tests. A 3-lens pre-red verification workflow (10
  findings) caught a would-be pass-from-birth sentinel BEFORE commit: omitting
  relationship-reachable UrgeEvent from the type list can never leave the derived schema
  (SwiftData builds the reachability closure) — replaced with an injected sixth
  RedSentinelModel; the red run then empirically confirmed the closure (all six entities
  appeared). Also from that panel: symlink-resolved URL comparison (simulator
  /var vs /private/var), §4-indexes deferral note, E12/§4.3/device-tier deferral notes.

### Red (TDD §7.1 evidence)

Version red (local `swift test`, commit B): `✘ Expectation failed: (StreakEngine.version →
"0.0.1-skeleton") == "1.0.0" · ✘ Test run with 63 tests failed … with 1 issue.`
E2.1 red (CI run 28975932867 unit lane on commit G, per session-rules app-lane mechanics):
```
✘ test_store_mirrorsExpectedModels — (names → [… "RedSentinelModel" …6]) == (5 expected)
✘ test_allMirroredModelProperties_haveDefaultsOrOptionals —
  (attribute … name: id, options: [unique] …).isUnique → true
✘ test_storeLivesInAppGroupContainer — ….../tmp/unhooked.store fails hasPrefix(App Group)
✘ Test run with 8 tests in 2 suites failed after 1.019 seconds with 3 issues.
```
(All pre-existing tests green in the same run; snapshot + UI lanes green.)

### Key decisions (ratified this session)

- **The engine's input type is `StreakSnapshot`** — the package surface carries no
  consumer-domain nouns; the anchor app's richer DTOs keep their own names app-side.
- **`StreakEngine.version` is pinned to the release tag** by tests on both sides of the
  package boundary; WidgetToolkit/PaywallKit stay `0.0.1-skeleton` (not graduated).
- **Package platform floors sit below the anchor app** (Swift 6 stdlib pair iOS 18 /
  macOS 15); raising is breaking, lowering is not.
- **Package `///` doc comments are consumer-self-contained** (no repo-internal
  citations); planning breadcrumbs belong in `//` comments.
- **E2.1 store:** no `@Attribute(.unique)` anywhere (§4 CloudKit checklist overrides the
  §3 sketch's `.unique` on `id`; uniqueness is UUID convention, dedupe is E2.3); the
  mirrors test asserts on the derived `schema.entities` (reachability closure), so a
  relationship-smuggled entity fails the same test as a listed one; §4 indexes deferred
  to the E2.2 queries that justify them; `PanicSource` is a deliberate §3-superset
  (E3.3 entry-point matrix).

### Known limitations / carried items

1. **CI BILLING OUTAGE (new, operator-owned, blocks next session's first step):** commit
   H (E2.1 green) is pushed but UNVERIFIED — run 28976762483 (both attempts) never
   started: "The job was not started because recent account payments have failed or your
   spending limit needs to be increased." Green-risk is low (the red run empirically
   proved the introspection APIs, App Group resolution, and on-disk container open) but
   verification is mandatory before E2.2 work.
2. E2.1 acceptance items still open, by design: protection-class
   complete-until-first-unlock (device tier), CloudKit-option schema-validation
   instantiation (§4.3, blocked on Gate G0), widget-extension read-only open (device/E6);
   the companion-store test is E12-gated.
3. Reboot high-side sanity cap (ADR-7 gap, Sessions 03–04): unchanged; the persisted
   last-known-good wall reading arrives with the **E2.2 repository — red test first**.
4. `StreakCalculating` still exposes neither the guard nor applySlip/undoSlip/adherence
   (deferred to first consumer need, protocol-extension defaults).
5. `StreakSnapshot`'s synthesized Codable requires the `bestStreakSeconds` key — revisit
   with the repository/migration story (was carried as `QuitSnapshot`).
6. Operator-owned blockers unchanged: Gate G0 rename; E0.3 device measurement; content
   plan; MVP §7 vs test-suite §1.5 latency-drift decision.

### Gate status

Epic 1: CLOSED — gate green in CI (floors measured 100/100/100), API review landed, tag
`streakengine-v1.0.0` on af5b969. Epic 2 entered: E2.1 red CI-verified (28975932867);
E2.1 green pushed (ae4d34f) awaiting CI once billing clears. Local package state:
63/63 green, 100% coverage held through all six review commits.

---

## 2026-07-09 · Interlude (operator + agent, not a coding session) · billing cleared, E2.1 CI-verified, TestFlight bootstrap chain

**Operator:** fixed GitHub Actions billing; completed operator-checklist Phases 0–2+4
(Gate G0 → **Ballast** / `com.beyondkaira`, IDs registered, placeholder sweep committed
1d21da3; ASC app + API key; 5 CI secrets; content drafts); later fixed the match PAT's
repository grant (fine-grained, Contents read/write on the certs repo).

**Agent verification + fixes:**
- **E2.1 VERIFIED:** billing-blocked run 28979808466 rerun (attempt 3) — ALL test lanes
  green on HEAD 1d21da3: commit H's three store tests, the Ballast sweep on the Apple
  toolchain, the release gate (floors measured 100/100/100). Step 0 closed; E2.1 DONE.
- **TestFlight bootstrap chain (upload lane only, three distinct failures):**
  (1) certs repo had been created as `aytekXR-ballast-match-certs` while the secret/docs
  said `ballast-match-certs` → clone 404 → agent renamed the repo (GitHub redirects).
  (2) match PAT had NO grant on the repo (API probe: 404 with valid token) → operator
  re-granted (verified 200 + push:true).
  (3) attempt 6: match cloned fine and MINTED the distribution cert ("creating one for
  you now"), but **gym archive failed**: `No profiles for 'com.beyondkaira.ballast'
  were found … Automatic signing is disabled and unable to generate a profile` — the
  Fastfile never maps the `match AppStore` profiles onto the two targets for the
  archive (project.yml is CODE_SIGN_STYLE: Automatic; CI has no Xcode-managed account).
  Carried to Session 06 per operator instruction.
- `MATCH_BOOTSTRAP=true` set (stays until the first green upload).

**Caveats recorded for Session 06:**
1. Match's cert push never landed in the certs repo (sole commit predates the runs) —
   the portal now likely holds a distribution cert whose private key died with the
   runner. Next bootstrap either mints a second cert (Apple allows two) or the stale
   one needs revoking from the portal.
2. **Hygiene (operator call):** the certs repo contains the RAW ASC API key
   (`AuthKey_QL8L4UKHW5.p8`, committed manually). It already lives base64 in the GitHub
   secret and in the operator's local mirror — recommend deleting it from the repo
   (and its history) so the match repo holds only match-encrypted material.
3. Resume prompt updated v1.6 → v1.7 in this interlude; secret.yml (repo root) is
   operator-local and correctly gitignored (verified with check-ignore).

---

## 2026-07-09 · Session 06 · TestFlight signing fix + E2.2 QuitRepository + ADR-7 reboot cap, red→green×2 (+1 review cycle) — engine v1.1.0

**Prompted.** Execute resume prompt v1.7 with workflows; NEW standing instruction from
the operator: adopt CodeGraph in every session (query-first, sync before session end)
and carry the rule into all future prompts.

**Produced.**
- **CodeGraph adoption (operator ask):** permanent rules added to `session-rules.md`
  (§CodeGraph: `codegraph_explore` before grep/read, blast-radius check before edits,
  `codegraph sync` as a mandatory session-end step) + session-end checklist extended;
  the resume prompt now carries the rule forward. Used throughout this session by the
  main agent and all workflow agents.
- **TestFlight signing fix (cd986f9, CI-verified run 28984577954):** Fastfile now
  forces manual signing per target after match (`update_code_signing_settings` ×2:
  Apple Distribution, team UH7MXG7Z94, profile from `sigh_*_appstore_profile-name`)
  + gym `export_options.provisioningProfiles` mapping. **gym exported a signed IPA**
  (54 s) — the Session-05 signing blocker is closed. The lane now fails one step
  later: `pilot` — **no App Store Connect app record exists** for
  `com.beyondkaira.ballast` (diagnosed READ-ONLY via the ASC API with the operator's
  key: bundle IDs + the single distribution cert visible, `/v1/apps` empty — the
  portal App IDs were mistaken for an app record in the interlude). Operator-owned;
  see blockers. Cert hygiene resolved itself: exactly one distribution cert exists
  and match served it from the repo in 2 s (no second mint).
- **Slack notify commit secret-ified:** an operator-local commit (316ef70) hardcoding
  a live Slack webhook URL was blocked by GitHub push protection; rewritten as
  abd60e9 (authorship preserved) reading `secrets.SLACK_WEBHOOK_URL`, secret
  provisioned via `gh secret set`. Note: the webhook value sat in local history —
  rotating it is a cheap operator hygiene option.
- **E2.2 (commits A 55014d9 red → B 83c2f2c green → C fa956bd review-red → D b9080ab
  review-green):**
  - **Engine (StreakEngine → 1.1.0, tagged streakengine-v1.1.0):** the ADR-7 reboot
    high-side sanity cap, carried since Session 03, is CLOSED. One trailing defaulted
    param `lastKnownGood: MonotonicAnchor? = nil` on sanityCheck /
    conservativeElapsedSeconds / currentStreak / applySlip / undoSlip (+ public
    `defaultRebootGapCap = 14d`); `StreakCalculating` protocol untouched; nil
    reproduces the old bytes exactly (pinned). Reboot branch with a reading: same-boot
    capture BRIDGES (re-enters the within-boot guard, verdict inherited, remainder
    uptime-verified, uncapped); otherwise baseline = max(anchor, reading) wall,
    rollback freezes at the verified span (not zero), gap > cap freezes at
    verified+cap flagged `.clockRolledBack`, in-window gap credits fully as `.normal`.
    14 engine tests incl. a pinned-seed never-inflates property; 77/77 green,
    llvm-cov 100% regions/functions/lines held (gate measured it in CI).
  - **Repository (App/Sources/Persistence/QuitRepository.swift, @MainActor, sole
    SwiftData importer):** activeQuits (justifies the landed
    `#Index<Quit>([\.isArchived,\.sortIndex])` — the other three §4 indexes stay
    deferred to their justifying queries), createQuit (max-3 → `.activeQuitLimitReached`,
    anchor minted wallClock==startAt, sortIndex=max+1), synchronous logSlip (save()
    before return; `Slip.at` = guarded slip instant; banks BANKED-only
    `totalCleanSeconds` == engine `priorCleanSeconds`; `isPendingUndo` stays false —
    the whole undo lifecycle defers to E4.1 as one unit), logUrgeEvent, streakValue
    (engine + LKG end-to-end). Seams: `ClockProviding` + `WidgetRefreshing`
    (@MainActor protocols; production conformances land with first app wiring, E3.1),
    `LastKnownGoodStore` (JSON blob in App Group defaults — device-local BY DESIGN,
    never the CloudKit-mirrored store). Debounced widget reload: trailing 500 ms
    cancel-prior Task with injected sleep — tests drive the real cancellation path in
    zero wall time. New merge-blocking CI job `E2.2 lint · repository is the sole
    SwiftData importer` (grep allowlist: App/Sources/Persistence/ + Tests/);
    TestFlight lane `needs` it.
  - The five implementation-plan names landed verbatim + reboot-cap/LKG repo tests.

### Red (TDD §7.1 evidence)

E2.2 red (commit A): local `swift test` — 76 tests, 10 failed, 327 issues (4 documented
pass-by-design pins); CI run 28986772423: release gate red on the engine cap tests,
unit lane red on all nine repository tests, each on its designed assertion, e.g.:
```
✘ test_logSlip_persistsBeforeReturning — (storedSlip.count → 0) == 1
✘ test_streakValue_rebootForwardJump_beyondCap_freezesNotInflates —
  (value.clockSanity → .normal) == .clockRolledBack · (value.elapsedSeconds → 86400000) == 1641600
✘ versionMatchesReleasedTag — (StreakEngine.version → "1.0.0") == "1.1.0"
```
Review-fix red (commit C, CI run 28988559874):
```
✘ test_lastKnownGood_freshAnchorCannotBlessTheWall_siblingQuitStaysCapped —
  (lkgStore.load()?.wallClock → 2029-04-02) == (epoch + 100d → 2026-10-15)
  · (value.clockSanity → .normal) == .clockRolledBack · (86400000) == 9849600
```
Green: B CI run 28987307905 (ALL test lanes green incl. the new lint job; only the
operator-blocked TestFlight upload red at pilot), D CI run (see gate status).

### Key decisions (ratified this session — 3-designer/3-judge panel + review)

- **Reboot-cap semantics** as shipped (above). The per-reboot ≤ cap unverifiable
  credit is a documented, accepted ADR-7 limitation; threat model is self-cheating
  (no external reward), persona is widget-primary (weeks between app opens), hence
  14d over 72h/7d.
- **The bridge must inherit the within-boot verdict** (never hardcode `.normal`) and
  **the trusted reading advances only on `.normal` — now ALSO gated on continuity
  with the previous reading** (review MAJOR: a freshly-minted anchor agrees with the
  reading it was minted from for ANY wall value, so anchor-verdict gating alone lets a
  fresh quit launder a forward-set wall into the device-global baseline; the
  continuity gate re-runs the old reading through the guard as its own anchor+baseline,
  which refuses the jump within-boot via uptime and bounds it by the cap across
  reboot). createQuit never refreshes the reading (self-blessing).
- **`Quit.totalCleanSeconds` is pinned BANKED-only** (== engine `priorCleanSeconds`,
  excludes the live streak — added at read time; anything else double-counts momentum).
- **Engine version 1.1.0** (semver-minor: additive public API), pinned by tests on
  both sides; annotated tag `streakengine-v1.1.0`.
- **Undo lifecycle defers WHOLE to E4.1** (flag=true + finalize sweep + undoSlip +
  isPendingUndo index) — no partial stored state; `logSlip` writes `isPendingUndo=false`.
- **ADR-7's "re-anchor" healing half → E2.3's `recomputeDerivedState()`** (a write
  during a read is a sync hazard; freeze-not-inflate now, freeze-then-resume there).

### Review (ultracode workflows at three gates)

Design: 3 designers (clock-purist / API-minimalist / product-honesty) × 3 judges —
synthesis caught D1's LKG-poison-via-hardcoded-bridge-verdict before any code existed.
Pre-red verification: 3 lenses (red mechanics / spec fidelity / compile risk), PASS ×3
zero findings — the app lane then compiled first try under strict concurrency.
Diff review: 4 dimensions → 10 deduped findings → 30 refutation-first verifiers →
**7 confirmed (1 major bug + 1 major test gap + 3 minor + 2 notes), 3 refuted.** The
major (fresh-anchor LKG poison) became commit C red → commit D fix; the test gaps
became pins in D (tz-shift no-refresh, quitNotFound, logUrgeEvent behavior, sortIndex
max+1 after archive, bridge equal-wall boundary); the doc note became the §5.1
annotation in architecture.md.

### Known limitations / carried items

1. **ADR-7 reboot cap: CLOSED** (was item 1 since Session 03). What remains of it:
   the **healing re-anchor** (freeze-then-resume for the innocent long-power-off user)
   lands with **E2.3 `recomputeDerivedState()`**; until then a >14d unverifiable gap
   stays frozen at verified+cap, flagged — deliberate, documented.
2. **E4.1 owns the whole undo lifecycle** as one unit: Slip.isPendingUndo=true,
   finalize-prior-slip, `undoSlip(slipID:)`, `finalizePendingSlips(now:)`, and the
   `#Index<Slip>([\.isPendingUndo])`. `#Index<Slip>([\.at])` → first time-ordered slip
   query (E4/E6); `#Index<UrgeEvent>([\.at])` → E12.4.
3. `ClockProviding`/`WidgetRefreshing` production conformances (mach_continuous_time +
   kern boot-session UUID; WidgetCenter) + app-launch repository wiring land with the
   first consumer (E3.1 pre-cache hook / dashboard) — no test forces them yet.
4. `StreakCalculating` still exposes neither the guard nor applySlip/undoSlip/adherence
   (deferred to first consumer need, protocol-extension defaults).
5. `StreakSnapshot`'s synthesized Codable requires the `bestStreakSeconds` key —
   revisit with the repository/migration story when snapshots persist (E3.1/E2.3).
6. E2.1 acceptance items open by design: protection-class (device tier), §4.3
   CloudKit-option instantiation (now unblocked, red-test-first when taken), widget
   read-only open (device/E6).

### Operator-owned blockers

1. **NEW — App Store Connect app record** for `com.beyondkaira.ballast` does not
   exist (pilot: "Couldn't find app"; ASC API confirms zero apps visible). Create it
   in ASC (My Apps → ＋ → New App: iOS, name **Ballast**, bundle
   `com.beyondkaira.ballast`, SKU e.g. `ballast-ios`), then rerun the TestFlight lane
   (`gh run rerun <id> --job <testflight>` or next push). **After the first green
   upload, DELETE the `MATCH_BOOTSTRAP` repo variable.** Signing itself is proven.
2. Slack webhook hygiene (optional): rotate the webhook that sat in local git history;
   the workflow now reads `secrets.SLACK_WEBHOOK_URL`.
3. E0.3 device measurement; content sign-off items; MVP §7 vs test-suite §1.5 drift —
   unchanged.

### Operator additions during the session

- `brandkit/` (commit a075b9b): Ballast brand guidelines (summary + full),
  `tokens.json` design tokens, and the complete AppIcon set (light/dark/tinted, all
  sizes). Recorded as a standing pointer in resume-prompt v1.8 — read before any
  UI/copy/icon work; icons wire into the asset catalog at the first UI epic.
- Slack CI notifications (rewritten as abd60e9, see above).

### Addendum (same session, after close-out): FIRST TESTFLIGHT BUILD UPLOADED ✅

Operator created the ASC app record ("Ballast - Quit" / `com.beyondkaira.ballast` /
SKU `ballast-ios` — verified via ASC API). The rerun then surfaced two walking-skeleton
bundle-validation errors, fixed agent-side:
1. **90023 (no app icon):** new `App/Resources/Assets.xcassets/AppIcon.appiconset`
   wired from the operator's brandkit — single-size 1024 light/dark/tinted (actool
   generates all slots incl. the iPad-compat 152/167); the light 1024's alpha channel
   stripped losslessly (all-255 alpha verified pixel-exact; the marketing icon must be
   opaque). Only the xcassets path is bundled — `Content/` stays inert. (69ddf88)
2. **90474 (iPad multitasking orientations):** `UIRequiresFullScreen: true` — the
   sanctioned opt-out for a deliberately portrait-only app. (0e772f4)

**Run 28990551123: FULLY GREEN — "Successfully uploaded package to App Store
Connect", build number 20 (run-number monotonic, E0.1 acceptance).** The one-shot
`MATCH_BOOTSTRAP` variable was deleted immediately after (CI signing is read-only from
now on). E0.1's last open acceptance — signed TestFlight build on merge to main — is
now REAL. Remaining TestFlight operator steps are ASC-side only (export-compliance
answer if prompted, add internal testers).

### Gate status

E2.2 DONE: red 28986772423 → green 28987307905 (all test lanes + new lint job) →
review-red 28988559874 → review-green 28989112856 (all test lanes green;
only the operator-blocked upload red). **TestFlight lane LIVE: run 28990551123 fully
green end-to-end, build 20 uploaded, MATCH_BOOTSTRAP deleted.** Engine tagged
streakengine-v1.1.0; package 77/77, coverage 100/100/100 measured by the CI gate.
TestFlight: signing green end-to-end, upload blocked only on the missing ASC app
record (operator). CodeGraph index synced at session end.
