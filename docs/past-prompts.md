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

---

## 2026-07-09 · Session 07 · E2.3 — CloudKit dedupe merge + recomputeDerivedState + ADR-7 healing re-anchor + LKG witness, red→green×2 (+1 review cycle) — engine v1.2.0; TestFlight bundle-version fix

**Prompted.** Execute resume prompt v1.8 with workflows (ultracode): E2.3 — the
CloudKit dedupe merge pass + `recomputeDerivedState()` including the carried ADR-7
re-anchor healing (freeze-then-resume), strictly test-first. Workflows ran at four
gates: 3-designer/3-judge design panel; 3-adversary red team over the synthesized
spec (with EXECUTABLE probes against the real engine in a disposable worktree);
3-lens pre-red verification; 4-dimension adversarial diff review (34 agents:
10 findings → 30 refutation-first verifiers → 7 confirmed, 3 refuted).

**Produced.**
- **Engine (StreakEngine → 1.2.0, tagged streakengine-v1.2.0):**
  `healFrozenStreak(on:at:monotonic:lastKnownGood:) -> StreakSnapshot?` — the ADR-7
  healing half deferred from Session 06. Heals EXACTLY the across-reboot over-cap
  freeze (the one state that never recovers on its own); every other arm returns nil.
  Mint ("option iii"): `startAt' = now − frozen`, anchor re-based onto the current
  boot `(reading.bootID, reading.uptime − frozen, wallClock == startAt')`;
  trackedSince/banked fields/undo pass through untouched — no new append-only
  exemption, `createdAt` "never resets" stays literally true. In-function tripwire
  re-evaluates the minted anchor to `(.normal, frozen)`. The private `evaluate()`
  gained a `healable` arm tag (single arm inventory preserved; the two public faces
  byte-identical, `currentStreak` destructure widened). 84/84 local, llvm-cov
  100/100/100 package-wide held.
- **Repository — `recomputeDerivedState()` (QuitRepository.swift; the red-commit
  sentinel file folded in for private-member access):** capture (now, reading,
  witness) once → **dedupe merge** per same-id group → **heal pass** → **witness
  restart** (once per BOOT — see review fix) → single gated save + debounced reload;
  the no-op pass touches nothing (`didMutate` Bool returned). Launch/remote-change
  wiring deliberately defers to E3.1.
- **Merge semantics (ratified):** fold over the record multiset, survivor-independent:
  `createdAt` min (= max total tracked span, the named test-1 meaning);
  `startAt` max (latest slip-terminated) with its anchor taken AS A COHERENT TUPLE
  from the same record (anchor.wallClock == startAt; guard measures from the anchor,
  so a grafted older anchor would inflate unflagged — pinned) with a deterministic
  content tie-break (anchored beats nil, then min by (wallClock, uptime, bootID));
  `best`/`totalClean` fieldwise max; `avertedUrgeCount` = max(stored counters,
  recount of .averted over the UNIONED events) — plain max undercounts when devices
  hold different averted events; scalar fields by value-symmetric reductions (spend
  max, category/goal min-by-rawValue, label prefer-non-nil-min, currency min,
  allowance non-nil-max); triggers/motivations = order-preserving GLOBAL union
  (candidates ordered count-desc then ASCENDING element-wise lexicographic — the
  direction is contractual; base list's user order survives — motivations render
  verbatim in the panic flow); `discreetMode` OR and `isArchived` OR (both fail
  toward privacy; a stale un-synced copy can neither un-hide nor resurrect a quit,
  and the max-3 invariant cannot be broken by a merge); `sortIndex` min with a new
  deterministic id tiebreak in `activeQuits()` (widget order stays total).
  Children union by id, re-parented BEFORE loser deletes with an interim save
  (.cascade belt-and-suspenders); same-id child rows dedupe to one; QuizProfile
  (no inverse ⇒ dangle risk) re-pointed to the survivor, never deleted.
- **LKG → conservative WITNESS (the discipline EXTENSION, ratified):** the
  device-local reading is redefined from "last trusted wall reading" to a provable
  lower bound on elapsed real time. Three advance paths, priority order:
  (1) the Session-06 two-gate real-wall advance — UNCHANGED and preferred;
  (2) heal-time restart `+= min(gap, cap)`, ONCE PER BOOT (bootID-gated);
  (3) same-boot uptime accrual (pure monotonic arithmetic — no wall claim is ever
  consulted, so a lying wall cannot launder in). Paths 2+3 never write a raw wall;
  per-reboot unverifiable optimism stays ≤ cap, CUMULATIVE across reboots — exactly
  the rate, verdict character, and cumulativity of the already-ratified in-window
  channel (gap ≤ cap ⇒ .normal ⇒ two-gate advance onto the claimed wall, pinned
  since Session 06). This EXTENDS the gates; it does not weaken them.
- **Why the witness exists (main-agent correction of the judge panel):** all three
  judges ruled "never advance the LKG on heal" and called the cost a "rare
  double-power-off shrink" — WRONG. Traced and then probe-CONFIRMED (red-team P1):
  with a dead chain, EVERY subsequent normal reboot re-caps all streaks from the
  healed anchor's wall (verified = 0), so a 54-day streak surviving a 5-minute iOS
  update reboot would display 14d, flagged, forever — heal without chain restoration
  is not freeze-then-RESUME. The witness restores the chain conservatively and
  SELF-CONVERGES: the lag decays by (cap − true gap) per reboot cycle until the
  ordinary two-gate advance re-certifies the REAL wall (probe P5 + repo-level
  `test_lastKnownGood_chainReconverges…` pin the full numeric script).
- **TestFlight bundle-version fix (2a46abc, run 28997716868 FULLY green):** XcodeGen
  hardcodes `CFBundleVersion "1"` in generated Info.plists, silently swallowing
  gym's `CURRENT_PROJECT_VERSION` xcargs — **correction to the Session 06 record:
  "build 20" actually uploaded as bundle version '1'** (first upload, nothing to
  collide with), and this session's upload failed DUPLICATE against it. Both
  targets now route `CFBundleVersion`/`CFBundleShortVersionString` through
  `$(CURRENT_PROJECT_VERSION)`/`$(MARKETING_VERSION)`; **build 23 (0.1.0) uploaded —
  ASC accepting it proves the routing** ("build number auto-increments" is now true
  bundle-side, closing that E0.1 acceptance for real).

### Red (TDD §7.1 evidence)

E2.3 red (commit A 6e4ee61): local `swift test` — 84 tests, 7 new heal tests + the
1.2.0 version pin failed on designed assertions (cries-wolf sentinel: corrupted
non-nil snapshot), 76 pre-existing green:
```
✘ (healed?.startAt → 0000-12-30) == (now - TimeInterval(frozen) → 2026-07-23)
✘ (atHeal.momentum → 1.0) == (Double(frozen) / Double(35 * day) → 0.5428…)
✘ Test run with 84 tests failed after 0.103 seconds with 646 issues.
```
CI run 28996554955: release gate red on the same; unit lane red on ALL 14 new app
tests, each on its designed assertion, e.g.:
```
✘ test_mergeDuplicateQuits_keepsMaxTotalTrackedSeconds — (rows.count → 2) == 1
✘ test_recompute_witnessRestart… — (witness?.wallClock → 2026-07-12) == (… 2026-07-26)
✘ test_activeQuits_ordersDeterministically… — map(\.id) == [low, high]  (SQLite tie
  order follows insertion — the one riskily-red test, confirmed genuinely red)
```
Review-fix red (commit C 51569df, CI run 28999392466, sole failure = the designed
assertion): `(h.lkgStore.load()?.wallClock → 2026-08-09) == (afterFirst → 2026-07-26)`
— a second same-boot pass stacked another cap.

### Review (ultracode workflows at four gates)

- **Design panel** (3 designers × 3 judges): unanimous winner sync-determinism;
  judges killed both losers' advance-LKG-to-raw-wall heal (bridge-arm poison for
  foreign anchors — verified against `evaluate()`), and judges 1+2 killed the
  winner's anchor-only mint (post-slip permanent false-flag). Main agent then
  corrected the judges' never-advance ruling (see witness above) — the red team
  probe-confirmed both the correction and the mint ruling.
- **Red team** (3 adversaries, executable probes): confirmed the ratchet (P1),
  option-A flag (P2), convergence numbers (P5), momentum continuity (P7); found the
  witness-stacking bound had been MIS-STATED in the spec (fixed: the honest claim is
  cap-per-reboot cumulative = in-window channel parity, and a pin test asserts that
  exact bound); constraint audit found the createdAt "never resets" conflict →
  option (iii) adopted (also sync-stable: min-createdAt merge would have reverted
  option C's move on the first stale duplicate); determinism attack broke the
  original joined-string union tie-break (not injective over free text) → structural
  element-wise order, and flipped isArchived AND → OR.
- **Pre-red verification** (3 lenses): caught 1 blocker before commit A — the
  cascade test passed from birth (same-id loser makes re-parenting unobservable
  without the fold-to-one assertion) — plus the union tie-break direction ambiguity.
  Zero compile findings; the app lane compiled first try under strict concurrency.
- **Diff review** (4 dims → 10 findings → 30 verifiers): **7 confirmed, 3 refuted.**
  The one behavior fix: witness restart granted per heal-CALL, not per boot
  (probe: 5 same-boot passes → 5 grants) → red C → green D (`previous.bootID !=
  reading.bootID` gate). Five mutant-survival pins landed in D: averted recount,
  discreet OR, absolute scalar oracle, accrual bootID veto, anchor tie-break.
  Documented-not-fixed (2/3): the gated re-certification can carry ≤ tolerance
  (60 s) past the cap in the heal reboot — the guard's designed ±60 s noise
  envelope, bounded per reboot, deliberately not special-cased.

### Known limitations / carried items

1. **Witness tolerance slop (documented, deliberate):** ≤ 60 s/reboot of extra
   credit when a reboot gap lands in (cap, cap+tolerance] — noise-envelope grade
   vs the sanctioned 14d/reboot channel; revisit only if tolerance semantics change.
2. **Merge property test has no absolute oracle** — by design it proves
   order-invariance; the absolute rules are pinned by the named tests + the five
   review pins. Extending DupSpec (discreet/scalar divergence) is optional hardening.
3. **recomputeDerivedState wiring** (app launch; remote-change notification) → E3.1
   / the §4.3 CloudKit flip respectively. Real-CloudKit dedupe (test-suite item 21's
   `_streakHistoryNeverShrinks` integration variant) stays contract-tier/nightly.
4. Undo lifecycle whole in E4.1; `ClockProviding`/`WidgetRefreshing` production
   conformances with E3.1; `StreakCalculating` still not exposing the guard/heal
   (first-consumer-need policy); §4.3 flip red-test-first when deliberately taken.
5. Operator-owned blockers unchanged (E0.3 device measurement; content sign-off;
   MVP §7 vs test-suite §1.5 drift; optional Slack webhook rotation). ASC-side:
   TestFlight now shows 0.1.0 build 23 — export-compliance/internal testers as before.

### Gate status

E2.3 DONE: red 28996554955 → green 28997109088 (ALL test lanes; coverage
100/100/100 measured by the gate) → bundle-version fix 28997716868 (FULLY green,
build 23 uploaded) → review-red 28999392466 → review-green 29000350889 (FULLY
green end-to-end incl. the TestFlight upload — build 24). Engine tagged
streakengine-v1.2.0 on aaf36fe. CodeGraph synced at session end.

---

## 2026-07-09 · Session 08 · E2.4 — one-tap erase (local-first) + CloudSyncControlling seam, red→green (+1 review-pins commit); TestFlight runner-acquisition incident

**Prompted.** Execute resume prompt v1.9 with workflows (ultracode): E2.4 — one-tap
erase (local + CloudKit seam + caches), strictly test-first, scope-adjusted per the
prompt (companion store is E12; RevenueCat/analytics clears are E7/E8 seams). Also:
update the operator's personal TODO file with anything operator-owned and notify at
session end. Workflows ran at three gates: 3-adversary spec review (17 findings →
refutation-first verifiers → 3 confirmed, 14 refuted); 3-lens pre-red verification
(PASS ×3, zero findings); 4-dimension adversarial diff review with 3-verifier
majority panels per finding (37 agents: 11 findings → 6 confirmed, 5 refuted).

**Produced.**
- **`QuitRepository.eraseEverything() async throws` (green dc3ba97):** LOCAL-FIRST
  sequence — fetch-and-delete all five entity types (children first, no batch-delete
  API, no cascade reliance; explicit per-type deletes also catch ORPHANED rows a
  future sync/merge can deliver) + one save → witness clear (`LastKnownGoodStore.
  clear()`, infallible, before anything that can throw) → App Group defaults key
  sweep + store file-set removal (`eraseLocalArtifacts`, static, shared verbatim
  with the launch smoke hook; file set = base + `-shm`/`-wal`/`-journal` sidecars +
  hidden support artifacts, scoped to the SET, never the directory) → debounced
  widget reload → **CloudKit private-zone purge LAST** through the new
  `CloudSyncControlling` seam (account unavailable ⇒ skip, never fail — fully-local
  is first-class; available + throw ⇒ PROPAGATE after local completion, erase is
  re-runnable). E7 (RevenueCat reset) and E8 (`erase_all_completed`) are named TODO
  seams, deliberately code-free.
- **`CloudSyncControlling` + `CloudAccountStatus`** (new seam file; added to
  architecture §5.1 in the same change per test-suite §7.8). Production conformance
  (CKContainer) deliberately deferred to the §4.3 flip.
- **UI-smoke launch hook** (`UITEST_SEED_PANIC_THEN_ERASE` in `UnhookedApp.init`,
  FORCE_PANIC_ROUTE-precedent scaffolding): seeds a panic flag, runs the REAL
  `eraseLocalArtifacts`, and the route resolution right after is the observable.
- **Tests:** the five plan names verbatim (`test_erase_deletesBothStoreFiles` — the
  single product store's whole on-disk file set, companion store is E12;
  `test_erase_requestsCloudKitZoneDeletion` — mock seam, one request per erase;
  `test_erase_clearsPanicPreCacheDefaults` — defaults sweep + the WITNESS pinned
  through its own store; `test_erase_appRelaunch_startsAtOnboarding` — UI smoke,
  launch A is the SOLE route-level discriminator (comment-pinned), launch B is a
  durability sanity check; `test_iCloudUnavailable_appFunctionsFullyLocal` — full
  repo surface + COMPLETE local erase with zero cloud calls) + pins: fresh-context
  empty store across all five entities, cloud-failure-surfaces-then-retry (with
  local-complete + reload-despite-failure asserts), debounced reload (no repository
  write may precede the awaited erase — spec-review-confirmed pass-from-birth trap),
  orphan-row erase, unrelated-sibling survives the file sweep.

### Red (TDD §7.1 evidence)

Commit 8ec0608 FAILED THE BUILD (backslash line-continuations inside single-line
string literals — Swift has none; run 29015343681 is NOT red evidence). Lesson made
mechanical: `swiftc -parse` on every touched Swift file is now a pre-push gate
(session-rules Environment note). The corrected red is b55a974, run **29016220253**:
all 7 new unit tests failed on their DESIGNED assertions (19 issues in the E2.4
suite; all pre-existing unit/merge/witness tests green in the same run), e.g.:
```
✘ test_erase_deletesBothStoreFiles — (h.storeFileSet() → ["unhooked.store",
  "unhooked.store-shm", "unhooked.store-wal"]) == []
✘ test_erase_requestsCloudKitZoneDeletion — (h.cloud.zoneDeletionRequests → 0) == 1
✘ test_erase_clearsPanicPreCacheDefaults — (h.lkgStore.load() → MonotonicAnchor(…)) == nil
```
UI lane: `test_erase_appRelaunch_startsAtOnboarding` failed exactly on the designed
launch-A assertion ("Erased state must land on the fresh-install root…");
WalkingSkeleton smokes green, PanicLatency skipped (simulator).

### Key decisions (ratified this session)

- **LOCAL-FIRST erase order** (spec-review confirmed-major, 3/3): architecture §10's
  cloud-purge-before-local sketch was BACKWARDS for this product — every local step
  is cloud-independent and the on-device copy (verbatim motivations pre-cache,
  witness, store file, readable by a person holding the phone) is the more sensitive
  one; a transient CK error must never strand it. §10 corrected in the same change;
  the one fallible remote step goes last and its failure surfaces for retry.
- **Cloud policy:** `accountStatus() == .unavailable` ⇒ skip the purge entirely
  (zero cloud calls, pinned); available + failure ⇒ throw AFTER local completion.
- **The witness is erased state** (extends Session 07): cleared through
  `LastKnownGoodStore.clear()`, before the fallible steps; a fresh install has no
  witness and the chain re-establishes through the ordinary advance paths.
- **Defaults clearing is a KEY SWEEP** over `dictionaryRepresentation()` on the
  injected App Group suite (no key registry to rot; global-domain keys no-op);
  **file clearing is an allowlist-shaped FILE-SET sweep** (review-pinned: a
  directory nuke would eat unrelated App Group files under the real container).
- **Erase lives on QuitRepository** (architecture §5.1 QuitServiceProtocol), init
  grows `cloud:` + `appGroupDefaults:`; post-erase the repository/container are
  dead by design (relaunch = fresh install; verified acceptable, 0/3 on the
  zombie-repository finding).

### Review (ultracode workflows at three gates)

- Spec review (3 adversaries × refutation-first verifiers): confirmed the ordering
  major (above), the reload-test pass-from-birth trap (fixed pre-red: no repository
  write before the awaited erase), and the launch-B-non-discriminating note
  (comment-pinned). Killed 14 findings incl. unlink-while-open, isStoredInMemoryOnly
  doubts, and a §4.3 two-device-claim overreach.
- Pre-red 3-lens: PASS ×3 — but see the string-literal build failure the lens
  missed; the parse gate now backstops it mechanically.
- Diff review (4 dims → 11 findings → 3-verifier majority): **6 confirmed (1 major
  test gap + 2 minor pins + 1 comment over-claim + 2 notes), 5 refuted.** All three
  mutants killed in 669eb1b (orphan rows / reload-despite-cloud-failure / file-set
  scoping); the over-claiming eraseLocalArtifacts comment now states its exact scope
  with the E3.1 seam named.

### Known limitations / carried items

1. **Panic-snapshot files are OUTSIDE today's erase sweep (latent, 3/3-confirmed,
   by design):** `eraseLocalArtifacts` covers defaults keys + the store file set;
   architecture §4's `panic-snapshot.json`/`widget-state.json` are FILES and no
   writer exists yet (grep-verified). **E3.1's DoD MUST add their file names to the
   sweep + a file-shaped sentinel erase test** — carried at the top of the resume
   prompt.
2. Real CloudKit zone purge + production `CloudSyncControlling` conformance →
   the §4.3 flip / contract tier (test-suite §4.3 erase contract); two-device erase
   propagation stays the manual release checklist.
3. RevenueCat reset (E7) and `erase_all_completed` (E8) are named TODO seams in
   `eraseEverything` — wire there, not elsewhere.
4. UI smoke launch B is a durability sanity check, not an erase pin (documented
   in-file; unit tests are the real pins).
5. recomputeDerivedState launch/remote-change wiring → E3.1/§4.3; undo lifecycle
   whole in E4.1; `StreakCalculating` exposure policy unchanged.
6. **CI incident (infra, watch it):** dc3ba97's TestFlight upload was cancelled by
   GitHub — "The job was not acquired by Runner of type hosted even after multiple
   attempts" — after all test gates were green. Not billing-shaped (test lanes got
   macOS runners in the same run). The 669eb1b run re-exercises the lane.

### Gate status

E2.4 DONE: red 29016220253 (b55a974; 8ec0608's build-failure run 29015343681
disqualified and replaced) → green 29017223500 (dc3ba97; ALL test lanes + gate
floors green; upload lane lost to the runner-acquisition incident) → review pins
669eb1b, run 29019440970 **FULLY GREEN end-to-end incl. the TestFlight upload**
(the runner incident did not recur; a fresh build shipped on this run).
No engine changes (StreakEngine stays 1.2.0). OPERATOR-TODO.md restored to
untracked (was accidentally committed as 5eba607) + gitignored. CodeGraph synced
at session end.

## 2026-07-09 · Session 09 · E3.1 — panic path productionizing (pre-cache, launch wiring, production seams, panic route), red→green (+1 pins/harden commit); one wasted run on an SDK deprecation

**Prompted.** Execute resume prompt v2.0 with workflows (ultracode): E3.1 — panic
path productionizing, strictly test-first; log operator-expected items to chat AND
the operator's personal file at session start (done: OPERATOR-TODO.md top section).
Workflows ran at four gates: 3-designer/3-judge design panel (6 agents); 3-lens
pre-red verification (PASS ×3, zero blockers — the compile-risk lens empirically
compiled the risky Swift 6 constructs before the billed run); 4-dimension adversarial
diff review with 3-verifier refutation-first majority panels (22 agents: 6 findings →
2 confirmed 3/3, 4 refuted 0/3).

**Produced.**
- **`panic-snapshot.json` pre-cache (the ratified shape):** `PanicSnapshot`/
  `QuitSnapshot` value types + `PanicSnapshotStore` (Shared/Sources — compiled into
  both targets for the E6 widget reader; injected-location per the LastKnownGoodStore
  precedent, no new protocol). Content MINIMIZED per §10: id + (non-discreet) label +
  discreet flag + VERBATIM motivations under `schemaVersion` (streak/anchor/money
  fields join additively with E3.2/E6). Discreet quits ship `label = nil`; slip notes
  physically absent (raw-bytes pin). Rebuilt best-effort (`try?`, synchronous, after
  save) at the tail of createQuit/logSlip/logUrgeEvent/recomputeDerivedState-when-
  mutating; `refreshPanicSnapshot()` at launch heals failed writes / prunes residue.
  NEVER rebuilt by eraseEverything.
- **Erase carry item PAID (Session 08's 3/3-confirmed):** `eraseLocalArtifacts` gained
  an owned `appGroupFileURLs` set ([panic-snapshot.json]; never a directory);
  both callers pass it (eraseEverything + the UITEST_SEED_PANIC_THEN_ERASE hook);
  file-shaped sentinel tests: owned-file-removed + unowned-sibling-survives +
  not-resurrected-by-erase (post-drain).
- **`RepositoryProvider`** (App/Sources/Persistence, @MainActor @Observable): zero-work
  init; ROUTE-AWARE idempotent `startIfNeeded(for:)` — normal route opens the store
  once POST-first-frame (`.task` on the normal branch only, belt-and-braces with the
  route guard), runs `recomputeDerivedState()` + the pre-cache refresh, publishes the
  repository (environment-injected for E3.2/E4.1); the PANIC route opens NOTHING,
  pre- or post-frame (the scope-adjusted plan pin `test_panicLaunch_skipsStoreWork
  BeforeFirstFrame`). `RootKind.loadsPersistentGraph` is the pure gate; RootKind cases
  and `resolveRoot` signature UNTOUCHED (design-panel fatal on the alternative).
- **Production seams:** `LiveClock` (mach_continuous_time × timebase = sleep-INCLUSIVE
  uptime; `kern.bootsessionuuid` sysctl cached per instance, sysctl failure degrades
  to a fresh UUID = foreign-boot = conservative cap path; `Date()` as the one
  sanctioned wall read), `LiveWidgetRefresher` (WidgetCenter passthrough,
  coverage-exempt), `LocalOnlyCloudSync` (.unavailable until the §4.3 flip).
  Composition root = `RepositoryProvider.liveRepository` (production witness suite =
  App Group defaults).
- **Panic route selection:** `PanicLaunchFlag` gained the `panic.launch.quitID` App
  Group key (`set(quitID:)`/`selectedQuitID()`; `clear()` drops BOTH keys) — the
  widget intent stays parameterless until E3.3, which writes this same key. Pure
  `PanicRouteResolver`: empty→bare breathe; selected-match→that quit; single quit→no
  picker; several+no/unknown selection→picker (unknown id degrades like no selection —
  never a dead end, §9). `UnhookedApp` resolves the presentation pre-frame on the
  panic branch only (synchronous few-KB JSON read, §11 budget); placeholder-grade
  brandkit-compliant `PanicQuitPickerView` (no red, coach copy, SF Symbols, neutral
  title for discreet) under the CONTENT-STABLE `root.panicPlaceholder` container id,
  so every route-level smoke keeps discriminating on the route.
- **Latency gate:** untouched and unwired — the E0.3 device measurement is still
  `_pending_` in docs/spike-panic-latency.md (operator-owned, now the only blocker on
  wiring the permanent gate).
- **Docs in the same change:** architecture §5.1 annotated (RepositoryProvider, live
  seams, the landed SnapshotServiceProtocol subset + content-minimization note).

### Red (TDD §7.1 evidence)

Red commit f47cbce, run **29026946526**: all 13 new unit tests failed on their
DESIGNED assertions (23 issues in the E3.1 suite; all 54 pre-existing tests green in
the same run), e.g.:
```
✘ test_motivationsPreCache_updatedOnEveryQuitWrite — (…panicSnapshotStore).read() → nil
✘ test_panicLaunch_withQuitID_selectsThatQuit — (resolve(…) → .picker([])) == .breathe(second)
✘ test_panicLaunch_skipsStoreWorkBeforeFirstFrame — (spy.opens → 1) == 0 · (spy.opens → 2) == 0
✘ test_liveClock_readingsAreUsableGuardEvidence — (a.uptime → -1.0) > 0 · bootID mismatch
```
UI lane: `test_panicRoute_seededSnapshot_showsQuitPicker` failed exactly on the
designed picker assertion; all pre-existing smokes green; PanicLatency skipped (sim).

### Key decisions (ratified this session — design panel + judges + main-agent synthesis)

- **The pre-cache is a FILE** (`panic-snapshot.json`): architecture §4/§10/§11/ADR-6
  are explicit and repeated; the implementation-plan's "app-group defaults" phrasing
  loses. Consequence accepted and paid in-session: the file joins the erase sweep.
- **Winner api-minimalist** over latency-purist (fatal: RootKind evolution breaks
  committed WalkingSkeleton assertions) and privacy-absolutist (speculative deep-link
  parser). Grafts: route-aware start + panic-opens-nothing spy (judge 2 /
  privacy-absolutist), hardened eager-open red skeleton (pass-from-birth discipline),
  drop `generatedAt` (no consumer; no clock read on the write path), keep
  `schemaVersion` (named consumers).
- **Pre-cache write failures are silent-recover** (§9): `try?`, never fails logSlip,
  never async; the launch refresh is the healing channel (now pinned by the
  non-mutating-launch test after the review caught it mutant-survivable).
- **Session 06 carried note resolved N/A:** E3.1 persists `QuitSnapshot` cards, not
  the engine's `StreakSnapshot` — its Codable key concern never materialized.

### Review (ultracode workflows at three gates) + CI incident

- Pre-red 3-lens: PASS ×3, zero blockers; two documented notes (LiveWidgetRefresher
  is green-step scaffolding — no unit-observable behavior; snapshot omits streak
  fields by design).
- Diff review (4 dims → 6 findings → 3-verifier majority): **2 confirmed 3/3, 4
  refuted 0/3.** Confirmed both test-quality mutant gaps, landed in 4bd7902:
  (1) MAJOR — the launch refresh call was deletable with all tests green (the
  duplicate-seeded launch test was masked by recompute's own didMutate rebuild) →
  `test_launch_nonMutatingLaunch_refreshesStalePreCacheFromStoreTruth`;
  (2) minor — all six `displayLabel` arms unpinned → parameterized brand-noun pins.
  Refuted (0/3 each): picker ForEach id-collision, erase-ordering privacy regression,
  erase-abort-on-file-throw, PanicLaunchTrace normal-route leak (pre-existing design).
- **CI cost incident (new failure class, record it):** green commit feee1ab's run
  29027702023 FAILED THE BUILD on `String(cString:)` — deprecated in the current SDK,
  promoted to an error by warnings-as-errors. The `swiftc -parse` gate CANNOT catch
  semantic deprecations (needs full type-checking, impossible for iOS targets on the
  Linux box) — one billed macOS run wasted; fix 4591dc7 (String(decoding:as:) over the
  NUL-truncated buffer). Mitigation for future agents: treat NEW Darwin/Foundation
  API calls as deprecation-risk; prefer the modern replacement API from the start.
- **UI-smoke integration lesson:** the picker smoke initially queried the NESTED
  accessibility container id and failed against the live app while all logic was
  unit-green (run 29028256271's sole red); hardened in 4bd7902 to query the picker's
  ROW BUTTONS by identifier prefix (real elements, stronger assertion: both seeded
  rows must exist) + a route-sanity assert; a new unit pin round-trips the REAL App
  Group store in the app process, and `PanicSnapshotStore.write` self-heals its
  parent directory (PersistentStore precedent).

### Known limitations / carried items

1. **Latency gate still unwired** — blocked ONLY on the operator's E0.3 device
   measurement (spike doc `_pending_`); harness untouched; wire threshold + settle
   the MVP §7 vs test-suite §1.5 wording drift when numbers land.
2. **E3.2 MUST build the §9-rule-2 panic write buffer:** the panic route provably
   never opens the store (pinned this session), so the flow's UrgeEvent/Slip writes
   need the append-only App Group buffer + flush-on-repository-start — AND the buffer
   file must JOIN `eraseLocalArtifacts` + a sentinel test in the same session (the
   Session 08→09 carry pattern, now a template).
3. **Pre-cache streak fields:** if E3.2's flow shows the streak, extend QuitSnapshot
   additively + bump `schemaVersion` (read() treats foreign versions as absent).
4. Picker is placeholder-grade (selection is in-memory @State → breathe); the real
   flow, haptics, and exits are E3.2; per-widget quitID parameter + entry-point
   matrix are E3.3 (they write the already-landed `panic.launch.quitID` key).
5. `LocalOnlyCloudSync` reports .unavailable BY DESIGN until the §4.3 flip — the
   erase cloud-purge path is unreachable in production until then (mock-pinned).
6. WidgetToolkit "InstantLaunch" extraction (plan tag) stays deferred until a second
   consumer exists (portfolio sequencing rule).

### Gate status

E3.1 DONE: red 29026946526 (f47cbce) → green-attempt 29027702023 (feee1ab)
DISQUALIFIED as evidence (build failure, deprecation-as-error) → green 29028256271
(4591dc7; build + ALL unit (67) + snapshot lanes green; sole red = the E3.1 picker
UI smoke, hardened in the pins commit) → pins/harden 4bd7902, run **29029650205 —
FULLY GREEN end-to-end incl. the TestFlight upload** (release gate, package units,
sole-importer lint, app build/unit/snapshot/UI-smoke incl. the hardened picker smoke
and both review pins; a fresh build shipped on this run). Billed macOS runs this session: 4 (one
wasted — see CI incident). No engine changes (StreakEngine stays 1.2.0).
OPERATOR-TODO.md updated at session start AND close. CodeGraph synced at session end.

## 2026-07-09 · Session 10 · E3.2 — panic flow UI + §9-rule-2 write buffer, red→green (+1 wasted run on a Darwin-only symbol) + refs/pins commit; first real snapshot goldens

**Objective (resume-prompt v2.1): DONE.** The ~90s skippable panic flow is real UI,
its outcomes ride the §9-rule-2 append-only write buffer, and the snapshot lane has
its first true image matrix. StreakEngine stays 1.2.0 (no engine change).

### What landed

- **`PanicOutcomeBuffer`** (App/Sources, SwiftData-free by placement): append-only
  NDJSON `panic-outcomes.ndjson` in the App Group root, derived by the repository
  from the pre-cache's directory (zero init ripple — tests land in the same temp
  dir, production in the container). Append = one JSON line + fsync at EXIT time
  (off the §11 budget), file born with `.completeUntilFirstUserAuthentication`
  (app-only reader — stricter than the pre-unlock snapshot posture). Reader
  tolerates a torn tail line (crash mid-append loses at most the newest outcome,
  never the file). Erase coverage in the SAME session (the standing rule): the file
  joins `eraseLocalArtifacts` in BOTH call sites + file-shaped sentinel +
  not-resurrected tests.
- **`QuitRepository.flushPanicOutcomes()`** — the "flushed as soon as the context is
  ready" half, wired into `startIfNeeded` between `recomputeDerivedState()` and the
  pre-cache refresh. NON-throwing silent-recover (design-panel ruling: a flush
  failure must never strand the launch or skip the repository publish; rollback on
  save failure, buffer intact for the next launch). Idempotent under replay: the
  `UrgeEvent` ADOPTS the draft id (crash between save and clear re-runs as a no-op)
  AND the dedupe set extends per insert (two same-id lines in one file — the append
  retry's signature — land once; review pin). `at` preserves the TRUE exit instant.
  Erased-quit drafts DROP (not-resurrected discipline); nil-quit drafts land
  unattributed (no counter bump). Witness untouched by flush — recompute owns the
  launch's witness work; replaying history earns no fresh wall trust.
- **`BreathPacerPattern`** — the 4-7-8×3 pure model, built from the SHIPPING
  script's pacer spec (never hardcoded): `phases()` / `totalDuration` (57s) /
  `phase(at:)` (boundary belongs to the phase it starts; negative clamps to first;
  end → nil) / `phaseProgress(at:)` — the bloom and the haptic curve share one
  timing source.
- **`HapticsPlaying` seam** (architecture §5.1, test-suite §3.1): `FakeHapticsEngine`
  records pattern-play calls in tests; `LiveHapticsEngine` = CoreHaptics behind a
  Task hop (engine work deferred past the first frame; simulator/no-hardware →
  silent no-op). The one-soft-haptic rule scopes to the celebration; the pacer
  carries the full rhythm.
- **`PanicFlowModel`** (@MainActor @Observable, store-free): stages breath → timer →
  reasons → redirect → exits → celebration; `stepsReached` records ON ENTRY, in
  order, no duplicates; redirect option ids are the script contract ("breathe"
  re-enters the pacer fresh, others land on the exits); `exitUrgePassed()` buffers
  the averted draft (one retry) + ONE soft haptic + celebration — the celebration
  confirms the URGE passed, not the disk (documented ruling; `outcomeRecorded`
  keeps the truth testable); `exitSlipped()` emits `PanicSlipHandoff{quitID, source,
  stepsReached}` through the named closure seam and writes NOTHING (E4.1 owns the
  slip flow + its writes as one unit; the model's `slipHandoff` state drives the
  placeholder destination E4.1 replaces).
- **`PanicFlowView`** under the content-stable `root.panicPlaceholder` anchor:
  bloom pacer (TimelineView paused until `.task` marks the start via the injected
  clock — the initial frame is always phase zero, which is also what makes the
  goldens deterministic; Reduce Motion → opacity pulse at the SAME rhythm),
  haptics-only state (static `hapticOnlyLabel` + round ticks, full haptic rhythm
  still plays), urge timer, reasons at 40pt semibold `@ScaledMetric(.largeTitle)`
  with one-motivation-per-page vertical paging (verbatim, user order) +
  `emptyFallback`, redirect menu (56pt rows), exits (teal prominent averted /
  quiet slipped, discreet labels "Done"/"Log it"), celebration renders the
  averted `confirmation` copy. Zero invented user-facing strings — every visible
  string is script- or model-sourced. a11y ids: `panic.flow.*` namespace.
- **`panicScript.json` is BUNDLED** (project.yml resource): E3.2 is its named
  consuming epic; the flow renders the shipping file, never copies (§3.2). The
  rest of Content/ stays unbundled; REVIEW.md updated — the panic script's tone
  review now gates TestFlight-visible copy (operator queue bumped).
- **Snapshot lane made real:** 10 suites × light/dark × default/AX5 (AX5 supersedes
  the plan's looser "XXL" — never weaken) incl. discreet, haptics-only, and
  empty-fallback variants, `.snapshots(record: .missing)` trait,
  `.image(perceptualPrecision: 0.98, layout: .device(config: .iPhone13))` — layout
  pinned in-test so the booted simulator only supplies the runtime. SnapshotTesting
  pinned `exactVersion: 1.19.3` (no committed Package.resolved; the 1.18→1.19
  `.snapshots` trait cliff). References recorded ON CI (Linux box can't render),
  committed from the `test-outputs` artifact. ci.yml simulator pick made
  deterministic (newest runtime + preferred-device order, choice echoed in the log);
  full xctestplan pinning + the `snapshots-rerecorded` label gate stay Epic 6 work.

### Red (TDD §7.1 evidence)

Red commit 3f890f8, run **29041600595**: build SUCCEEDED; all 9 pre-existing suites
green in the same run (incl. the E3.1 zero-store spy pin); 48 designed issues in the
new "E3.2 · panic flow + write buffer" suite; snapshot suite 10/10 red on the clean
`#require(loadShipping)`; the new flow smoke red on the designed breath-step
assertion. Examples:
```
✘ test_breathPacer_pattern_478_threeRounds — (phases.count → 0) == 9 · (totalDuration → 0.0) == 57
✘ test_exitUrgePassed_logsUrgeEventAverted — (model.stage → .breath) == .celebration · (haptics.celebrationTaps → 0) == 1
✘ test_exitSlipped_routesToSlipFlow — (f.recorder.handoffs → []) == [PanicSlipHandoff(…)]
✘ test_erase_removesPanicOutcomeBuffer_unownedSiblingSurvives — !fileExists(…panic-outcomes.ndjson) → true
✘ UI: "choosing a quit must open the real E3.2 flow at the breath step"
```
`test_flush_emptyBuffer_isNoOp` passed at red as a DECLARED green-from-birth guard
(a no-op assertion cannot discriminate against a no-op skeleton — documented in the
test and the red commit message).

### Green + refs/pins

Green e451dae run **29043154280** DISQUALIFIED (build failure — one token:
`FileProtectionType.completeUntilFirstUnlock` does not exist; the correct member is
`.completeUntilFirstUserAuthentication`). Green fix fdc8966 run **29043512846**:
build + ALL 89 unit tests green (the whole new suite incl. the plan-named six);
snapshot lane failed-while-recording the first 40 reference images by design
(`record: .missing`, 10 suites × 4 axes); the NEW flow smoke red on its OWN
container-id assertions — the flow mounted and worked (skip/averted BUTTONS found
and tapped), but nested `.contain` container ids never surface to XCUITest: the
Session 09 lesson recurred on new code and is now hardened at the source (step
titles + celebration copy carry identifiers on the TEXT elements; the smoke asserts
real elements only). Refs + pins commit 84c64fa run **29044978442**: FULLY GREEN
end to end incl. TestFlight upload.

### Key decisions (ratified this session — design panel + 3-verifier review)

- **No PanicSnapshot schema change:** the haptics-only channel to a cold panic
  launch is DEFERRED until a settings writer exists (E5+) — AppSettings has no
  fetch-or-create consumer yet, so a snapshot field would be dead plumbing and the
  1→2 bump would blank every existing cache at the flagship moment (panel: the
  "additive + bump" pattern is decode-broken for non-optional fields — a v1 file
  throws keyNotFound before the version gate; when the field DOES land, make it
  decode-tolerant and do NOT bump). The flow honors an injected `hapticsOnlyPacer`
  today; the seam is documented in the model.
- **Flush placement + error policy:** inside the startIfNeeded do-block a thrown
  flush would have been caught by the §9 BLOCKING catch and stranded the launch —
  panel-caught; flushPanicOutcomes is therefore non-throwing silent-recover, and
  runs between recompute and refresh so flushed outcomes fold into the final cache.
- **Erased-quit drafts DROP; nil-quit drafts land unattributed** (panel split the
  original insert-with-nil policy: resurrection vs honest zero-quit data).
- **Cold source attribution = `.lockscreenWidget`** until E3.3 (no home widget
  exists; `.homeWidget` would have been fabricated data — panel catch).
- **Slip seam carries source + stepsReached** (panel: quitID alone was lossy for
  E4.1's eventual UrgeEvent(.slipped)); still zero writes from the panic scene per
  the resume-prompt scope ruling — the §9 wording's "Slip writes buffer" half is
  E4.1's to close WITH the slip flow as one unit.
- **Redirect content = the shipping JSON** (4 options; no journal row): the
  brandkit's "journal one line" belongs to the slip/journal epics; recorded as the
  ratified override rather than inventing copy.
- **entryTitle renders on the breath step** (discreet → `entryTitleDiscreet`);
  later step titles are already habit-neutral.
- **Review (4 lenses → dedupe → 3-verifier majority, 25 agents): 7 confirmed /
  0 refuted.** Three were the SAME flush hole (two same-id lines in one buffer —
  the exit-time append retry's signature when fsync errors after the bytes land —
  double-inserted and inflated `avertedUrgeCount`; fixed by extending the dedupe
  set per insert, pinned by `test_flush_duplicateDraftIdsInOneBuffer_landOnce`);
  one was the FileProtectionType incident (already fixed). Three test-gap pins
  landed: the flush's stepsReached/source/at field mapping (end-to-end asserts in
  `test_exitUrgePassed_logsUrgeEventAverted`), the fresh pacer run on the shipping
  "breathe" redirect re-entry (`test_redirectBreatheOption_restartsThePacerRun`),
  and the landing-flush widget reload (isolated in the otherwise-non-mutating
  launch fixture).

### Cost lesson (the Session 09 class, REPEATED — now a named rule)

A Darwin-only symbol (`FileProtectionType` member name) cannot be type-checked on
the Linux box; both preflight verifiers "reasoned" over it instead of demanding a
compile and it burned run 29043154280. Rule going forward: any bare-SDK ENUM/CONST
MEMBER name a session introduces (not just APIs — member spellings) gets verified
against Apple docs/headers, not memory. Billed macOS runs this session: 4
(red 29041600595, wasted 29043154280, green 29043512846, final 29044978442).

### Known limitations / carried forward

- The slipped exit parks on `panic.flow.slipPlaceholder` — a TestFlight user who
  taps "I slipped" reaches a labeled dead end until E4.1.
- VoiceOver pacer phase announcements + the accessibility audit are device-tier
  (E3.2 acceptance's XCUITest-audit half deferred with it); haptics-only inline
  offer + settings UI are E5+.
- The E0.3 latency gate stays unwired (operator measurement still pending).
- Snapshot goldens are runtime-coupled: a macos-26 runner-image runtime bump will
  churn them — re-record deliberately (§3.3), the deterministic picker logs the
  runtime per run.

---

## 2026-07-10 · Session 11 · E4.1 slip flow + undo — design RATIFIED + red WIP (1/2); markdown audit done

**Objective (resume-prompt v2.2):** E4.1 — slip flow + 10-minute undo as ONE unit.
**Outcome: PARTIAL by external limit** — the subagent session limit tripped mid-red
(two of five test authors died; resets 12:50am Berlin). The session pivoted to a
clean close on operator instruction: design fully settled and recorded, API surface
+ 5/6 red test files committed `[skip ci]` (af00116 — deliberately NOT the red
commit; no CI evidence claimed), the one-time markdown audit executed, ZERO billed
macOS runs consumed. Session 12 completes E4.1 with the full 3–4-run budget intact.

### THE DECISION RECORD — cold-route slip design (settled FIRST, per objective)

Process: 3-option judge panel (advocates per option → three lenses: ratified-
semantics / privacy+pins / product-brand) + a max-effort adversarial verify pass on
the winner. **Winner, unanimous: option (a) — the §9-rule-2 outcome buffer grows
slip support** (option (b) defer-to-next-launch self-disqualified on the immediacy
constraint — the forgiveness screen IS the product at the moment of vulnerability;
option (c) open-the-store-outside-the-panic-route disqualified on the privacy-pins
lens). This is the canonical reading of architecture §7/§9r2 ("the panic flow
buffers its resulting UrgeEvent/Slip writes") — E4.1 completes the sentence E3.2
half-wrote.

**Mechanism (binding for Session 12's green):**
1. COLD route (store never opens; repository never instantiated): tap 1 "I slipped"
   → confirm stage (slipCopy.confirm, zero writes). Tap 2 "Log it" → THE one cold
   write boundary: append a `.slipped` `PanicOutcomeDraft` + fsync, ONLY THEN the
   forgiveness screen. Append failure (after the E3.2-style one retry) keeps the
   confirm stage + calm `confirm.retryNote` — a slip is §9-rule-1 zero-lost-data
   class; "Logged." is never claimed without durable bytes.
2. The draft carries the SLIP-TIME evidence tuple (additive optional fields, raw
   scalars): `capturedUptime/capturedBootID` (monotonic reading) +
   `capturedWitnessBootID/Uptime/WallClock` (LKG witness at slip time) +
   `revokesDraftID` (non-nil = revocation record). NO note field, ever (§10).
   **[R-WIT — adversarial-verify CORRECTION of a judge amendment]** feeding the
   FLUSH-time witness can select a future baseline in the reboot-cap arm and bank a
   39-day best that never existed (attack H1); the slip-time tuple makes deferred
   flush == live logSlip byte-for-byte, pinned by an equivalence property test.
3. Forgiveness framing on the cold route = pure engine math over the pre-cache
   card's NEW additive fields (`startAt/anchorBootID/anchorUptime/bestStreakSeconds/
   momentumPercent` — §3-sketch-sanctioned, schemaVersion stays 1, populated by
   `rebuildPanicSnapshot` from store truth): ended = guarded elapsed; best' =
   max(card best, ended); momentum UNCHANGED (ratified S04); degraded (nil) fields
   → `logged.bodyNoBest`-class copy, numbers never invented. Earlier unrevoked
   `.slipped` drafts for the quit FOLD IN-MEMORY into the framing first.
4. In-session cold undo (live-gated ≤600s): append revocation + fsync → "Undone."
   The revoked pair never reaches the store (§9r3 governs STORE rows; none exists).
5. FLUSH (`flushPanicOutcomes`, unchanged position after `recomputeDerivedState`):
   two-pass — collect `revokedIDs` first **[R-REVOKE]**; then APPEND order, never
   wall-sorted (**[R-ORDER — second verify CORRECTION]**: a rolled-back wall between
   two cold slips inverts causality under sorting); the dedupe set gates the
   UrgeEvent insert AND the streak transition (crash-replay + fsync-retry-duplicate
   safe); erased-quit drafts DROP; nil-quit `.slipped` lands as unattributed
   UrgeEvent ONLY **[R-NILQUIT]**; transition = `applySlip(to: before, at: draft.at,
   monotonic: captured, lastKnownGood: capturedWitness)`; Slip row gets the
   persisted undo payload + `isPendingUndo = (engine undoSlip(on: next, at: now,
   monotonic: reading, lastKnownGood: nil) != nil)`; earlier same-quit rows forced
   non-pending **[R-NEWEST]**; witness NEVER advanced by flush; save-before-clear
   unchanged. Same-launch heal collision banks toward 0, never inflates (engine
   floor clamps — accepted + pinned **[R-HEAL]**).
6. STORE route (dashboard half): `logSlip` finalizes prior pending rows, persists
   the engine `PendingSlipUndo` into 4 new optional Slip fields (`priorStartAt/
   priorCleanSeconds/priorBestStreakSeconds/priorMonotonicAnchor`), sets
   `isPendingUndo=true`. NEW `undoSlip(slipID:) -> Bool` (engine-gated exact
   restore, THE sanctioned decrease, then DELETES the undone row — see decisions),
   `finalizePendingSlips()` (scene-phase sweep; justifies the
   `#Index<Slip>([\.isPendingUndo])`, which lands with green), `updateSlipNote`,
   `pendingUndoSlip()` (root banner source). No witness refresh from undo or flush.
7. UI: `SlipFlowModel` (route enum `.cold/.store`) + `SlipFlowView`; motion/standard
   300ms spring (NEVER the panic 600ms calm — "procedurally identical to any other
   log"); undo banner NEUTRAL (never amber); glyph `arrow.uturn.backward.circle`
   (the placeholder's `.forward` was a bug); banner visibility LIVE-GATED
   **[R-LIVEGATE]** via TimelineView dates (persisted flag alone lies when
   foregrounded past the window; past-window tap = calm no-op). Production
   `PanicFlowView` attaches the real `onSlipRoute` (placeholder + `{ _ in }` die).
   RootPlaceholderView gains a minimal store-backed slip entry + pending-undo
   banner host. slipCopy.json gets BUNDLED (panicScript precedent: bundle only the
   consumed file, update REVIEW.md, flag operator) + gains agent-drafted
   `confirm.retryNote` (needs operator tone review).

**Ratified decisions (Session 11 Key decisions):**
- **Slip drafts carry the slip-time evidence tuple; deferred application must equal
  live application** (the R-WIT equivalence property is the load-bearing pin).
- **Window measurements pass `lastKnownGood: nil`** — everywhere (flush pending
  check, live banner gate, repository undoSlip): the ratified E1.3 undo semantics
  predate the witness param ("reboot falls back to floored wall"; S06 pinned "nil
  reproduces the old bytes exactly"), and an ahead-witness must not burn the window
  (attack H11). The TRANSITION still receives the captured witness — two different
  measurements, two clocks, deliberately.
- **NO cold pre-cache rewrite** (panel's R-RMW rule deliberately DROPPED): no widget
  consumes streak data until E6, and a second non-store-truth writer to the
  repository-owned atomic file is the ADR-6 dual-representation hazard (attack H9
  existed only because of it). In-memory draft-fold gives repeat-cold-slip display
  honesty; the pre-cache stays single-writer (pinned:
  `test_coldRoute_writesOnlyTheBufferFile`).
- **No undo banner on a cold→cold relaunch** (panel rule scoped down): a fresh
  panic launch is a crisis moment and never opens with undo UI. The window is
  honored in-session (live gate) and at flush on the next normal launch.
- **A completed store undo DELETES the Slip row**: an undone slip must not count
  against Reduce allowance or future insights; the flag-based engine restore is the
  §9r3 mechanism, row removal after it is bookkeeping. NOTE for the §4.3 CloudKit
  flip: undone-slip rows will need sync tombstoning (union-merge would resurrect
  them) — carry this into the flip's design.
- **The panic-session UrgeEvent(.slipped) SURVIVES an undo** (the session happened;
  its exit outcome was slipped) — only the streak-affecting Slip row is undone.
- **Dashboard-half XCUITest deferred**: no quit-creation UI exists, so
  `test_slipFlow_completesInTwoTaps_fromDashboard` waits for the fixture-seeding
  (-uiTestScenario) session; the store route is pinned at unit tier meanwhile.

### What landed on disk (af00116, `[skip ci]`, NOT the red commit)

- Inert API surface: Slip payload fields; draft captured*/revokesDraftID;
  QuitSnapshot additive streak fields; repository undoSlip/finalizePendingSlips/
  updateSlipNote/pendingUndoSlip stubs; SlipFlowModel/SlipRoute/SlipFraming;
  SlipCopy loader (json NOT yet bundled — red for SlipCopyTests by design).
- Red tests, parse-gated, designed failures traced per test: SlipUndoLifecycleTests
  (11; store lifecycle incl. the sanctioned-decrease restore, 600/601 boundary,
  guarded-window sweep), SlipFlowModelTests (16; cold captured-tuple append-before-
  UI, framing max/unchanged/degraded/fold, revocation, single-writer pin, store
  route + note autosave), SlipCopyTests (3; bundling + shame-lexicon/medical scan +
  token integrity + calm undo copy), PanicPathTests +2 (pre-cache streak fields +
  §10 note-exclusion guard), EraseEverythingTests +1 (sentinel extended to
  slipped/revocation shapes — green-from-birth, declared), SlipFlowUITests (the
  slot-32 cold two-tap smoke; placeholder-gone assertion).
- **MISSING (Session 12's first job): Tests/Unit/SlipFlushTests.swift** — the ~15
  deferred-application pins (equivalence property, R-ORDER/R-REVOKE/R-NILQUIT/
  R-NEWEST, replay/duplicate idempotency, witness-unchanged, window-at-flush,
  heal-collision bounds). The named test list is in the delivery-table row's
  decision record above and in resume-prompt v2.3.

### Markdown audit (one-time close-out task — DONE)

Deleted (byte-identical duplicates, cmp-verified; git history preserves them):
`brandkit/uploads/{prd,frontend-brandkit,spike-panic-latency}.md`,
`brandkit/branding-assets/brand-guidelines-full.md`. Deleted
`docs/operator-checklist.md` (4/5 phases closed — name/IDs/secrets/content-decision
done, TestFlight live; its one live item, the E0.3 device run, already lives in
`docs/operator-expected.md` §1). Updated references: `BRAND-GUIDELINES.md` now
points at `docs/frontend-brandkit.md`; README refreshed (Ballast name decided,
TestFlight lane LIVE, [skip ci] discipline noted). Root `OPERATOR-TODO.md` stays as
the gitignored pointer. Every remaining tracked .md is live and required.

### Cost / process notes

- **Billed macOS runs this session: 0.** The WIP commit carries `[skip ci]`
  deliberately: pushing a knowingly-incomplete red suite would burn a run without
  producing usable evidence; the ONE red-evidence run belongs to the completed
  suite (Session 12, runs budget 3–4 intact).
- The subagent session limit is a new planning constraint: front-load test
  authoring earlier in a session, and prefer fewer/larger authors over many
  parallel ones when the account is near its window.
- CAUTION for the operator until Session 12 lands the flush suite + red run: any
  code push to main will run CI and show the 30 DESIGNED failures from af00116's
  suites — that red is expected, not a regression.

### Known limitations / carried forward

- `panic.flow.slipPlaceholder` dead end still stands until Session 12's green.
- E0.3 latency gate still unwired (operator measurement pending, §1 of
  operator-expected.md).
- Undone-slip CloudKit tombstoning → §4.3 flip design (new, this session).
- VoiceOver audit device-tier items, haptics-only settings channel (E5+),
  `panic_step_reached`/`slip_logged`/`slip_undone` events (E8) — unchanged.

## 2026-07-10 · Session 12 · E4.1 COMPLETE — slip flow + 10-minute undo, red→green→refs, all-green

**Objective (resume-prompt v2.3):** complete E4.1 — write SlipFlushTests, push the
red-evidence run, implement green per the Session 11 decision record, land snapshots
+ refs. **Outcome: DONE.** E4.1 ships whole: both slip routes, the undo lifecycle,
the deferred cold application, the forgiveness UI, bundled copy, 24 new goldens.
Delivery table moves to 14/32 (~44%); the `panic.flow.slipPlaceholder` dead end is
gone and TestFlight builds now carry the full panic→slip→undo loop.

### Commits / billed runs (4 used — the budget's top end; one was burned)

1. `2f98127` red push #1 — **BURNED RUN** (build failure, no evidence): ONE semantic
   diagnostic, `Tests/Unit/SlipFlushTests.swift:178` "method must be declared
   fileprivate because its parameter uses a private type" — the parameterized
   equivalence test's argument enum was file-`private` while `@Test` methods are
   internal. The `swiftc -parse` gate is SYNTAX-only and cannot see access levels;
   the pre-push 3-agent verify also missed it (it checked the enum's Sendability,
   not its access exposure). **New permanent gate** (applied for the rest of the
   session): a repo-wide scan for private types named in non-private signatures +
   local `swiftc -typecheck` harnesses for every API-shape assumption (the harness
   pattern separately caught a `StreakSnapshot.totalCleanSeconds` misnomer before
   it ever reached CI — empirical typecheck > declaration cross-check).
2. `7712617` red fix → **run 29090095270 = THE red evidence**: build green; unit
   lane 136 tests / 13 suites with 92 designed issues confined to exactly the five
   designed-red suites (SlipFlush/SlipUndoLifecycle/SlipFlowModel/SlipCopy +
   PanicPath's one new test); snapshot lane green (40 goldens intact); UI lane red
   ONLY on the E4.1 smoke; every pre-existing suite green.
3. `14bee2a` green → **run 29091690154**: unit lane GREEN (whole E4.1 suite passes,
   zero regressions), UI smoke GREEN (the real two-tap cold flow end-to-end),
   snapshot lane red by design — SlipFlowSnapshotTests recorded its 24 references
   (`record: .missing` fails-while-recording, the Session 10 precedent).
4. `8cf1461` refs (24 goldens from the test-outputs artifact, visually reviewed
   before committing) → the all-green verification run + the TestFlight upload that
   puts the slip flow in testers' hands.

### What landed (mechanism = the Session 11 decision record, followed exactly)

- **Tests/Unit/SlipFlushTests.swift** (the missing 6th red file): 13 tests /
  ~15 runtime cases — the R-WIT equivalence property (deferred slip == live
  `logSlip` byte-for-byte; parameterized same-boot / reboot-between /
  rolled-back-wall), slip-time-span banking (2d, never the 10d flush span),
  duplicate-id + replay idempotency gating the TRANSITION, R-REVOKE (revoked pair
  drops whole; a revocation is never an UrgeEvent; slip→undo→slip lands exactly
  one), R-NILQUIT, erased-quit drop, R-ORDER (append order — wall-sorting would
  bank a phantom 2d+300 best), R-NEWEST, witness-never-advanced, window-closed-at-
  flush lands finalized, R-HEAL heal-collision bounded (banks 0; startAt keeps the
  healed re-base). Pre-push: 3-agent adversarial verify incl. a scratch SPM
  executable running the REAL engine over every expected value.
- **QuitRepository green**: `logSlip` opens the window (flag + the engine's
  recorded `PendingSlipUndo` persisted into the four `prior*` fields;
  finalize-prior first); `undoSlip` = engine-gated exact restore (`lastKnownGood:
  nil`) + row DELETE; `finalizePendingSlips` idempotent scene-phase sweep;
  `updateSlipNote`; `pendingUndoSlip`; `#Index<Slip>([\.isPendingUndo])` landed
  with its justifying queries. `flushPanicOutcomes` two-pass: revocation ids
  collected first, append order, `applyDeferredSlip` runs `applySlip` on the
  CAPTURED tuple (reading + witness) with only the undo-window gate measured at
  flush time; the id-dedupe set gates the transition as well as the insert; the
  witness is never advanced. `rebuildPanicSnapshot` populates the additive card
  fields (startAt/anchor scalars/best/momentum% via the guarded read).
- **SlipFlowModel green**: durable-first confirm (one append retry → calm
  retryNote, stays confirming); cold forgiveness framing = pure engine math over
  the card with the in-memory fold of earlier unrevoked drafts (single-writer pin
  holds — the cold route writes ONLY the buffer file); in-session cold undo =
  appended revocation; live window gate from the slip-instant anchor
  (`conservativeElapsedSeconds`, `lastKnownGood: nil`); store route through
  `logSlip`/`undoSlip`/`updateSlipNote` with the debounced note autosave.
- **UI**: new `SlipFlowView` (300ms spring — never the panic 600ms calm; NEUTRAL
  secondary-fill undo banner live-gated via TimelineView with a phase-zero latch
  for snapshot determinism; `arrow.uturn.backward.circle`; 56pt targets; SF Pro
  motivation echo; identifiers on REAL elements: `slip.flow.confirm.log`,
  `slip.flow.undo`, `slip.flow.logged`, `slip.flow.undoBanner`). `PanicFlowView`
  mounts the real cold flow off the handoff (`SlipRoutePlaceholderView` deleted);
  `RootPlaceholderView` gains the placeholder-grade store slip entry +
  pending-undo banner + scene-phase finalize (skeleton anchor kept byte-for-byte).
- **Content**: `slipCopy.json` BUNDLED (project.yml; the panicScript precedent) +
  the ONE agent-drafted `confirm.retryNote` line ("That didn't save just yet —
  nothing's lost. Tap Log it to try again whenever you're ready.") — REVIEW.md
  item 3 flags it for operator tone review.
- **Goldens**: 24 new (6 slip states × light/dark × default/AX5, .iPhone13);
  repo total 64.

### Process notes (ultracode session)

- Verification workflows carried their weight: the pre-red pass proved every
  expected value by EXECUTING the engine; the pre-green pass (3 reviewers:
  48-test simulation, strict-concurrency compile-risk with empirical local
  typechecks, regression/record conformance) returned zero findings and the green
  run confirmed it — no billed run was spent on a logic error.
- The one burned run was an ACCESS-LEVEL semantic the syntax parse gate cannot
  catch; its scan + typecheck-harness replacements are recorded above and in the
  resume prompt as a standing gate.
- Subagent session limits: no trips this session (3+3+3 agents, front-loaded).

### Known limitations / carried forward

- **Store-route framing passes momentum nil** (renders as an empty token
  substitution in `logged.body`) — deliberately unpinned and practically
  unreachable (no quit-creation UI); the dashboard epic that makes the store route
  reachable should feed the real momentum from a `streakValue` read. Same epic
  should revisit `SlipFraming.motivation` on the store route (also nil — the quit
  model HAS motivations).
- Dashboard-half XCUITest (`test_slipFlow_completesInTwoTaps_fromDashboard`) still
  deferred to the fixture-seeding session (unchanged Session 11 ruling).
- `slip_logged`/`slip_undone` events → E8.1 (the finalize sweep and undo remain
  their attach points); undone-slip CloudKit tombstoning → §4.3 flip; E0.3 device
  measurement still the only blocker on the permanent latency gate.
- Cold panic launches remain attributed `.lockscreenWidget` until E3.3 (next
  session) lands true per-source attribution.

---

## Session 13 — 2026-07-10 — E3.3 panic entry-point matrix (COMPLETE)

### Objective & outcome

Resume prompt v2.4: E3.3 — ControlWidget registration + per-widget quit parameter +
per-source attribution + discreet "Reset" control. **DONE in 2 billed runs, zero
burned:** red evidence run `29117701445` (build GREEN, the new suite failed with
EXACTLY the 19 designed issues — 143 tests, only the 7 new pins red) → green run
`29118390046` same session. Both plan-named tests live in
`Tests/Unit/PanicEntryPointTests.swift` alongside the attribution pins.

### What shipped

- **Per-quit intent parameter:** `PanicQuitEntity` + `PanicQuitQuery`
  (Shared/Sources/PanicQuitEntity.swift) — an AppEntity/EntityQuery designed over
  the PRE-CACHE (`PanicSnapshotStore.read()`, ADR-6 readers-only; a discreet card
  surfaces as the neutral "Your goal"). Both intents carry
  `@Parameter(title: "Quit") var quit: PanicQuitEntity?` (optional → nil keeps
  today's resolver behavior; E6.2's selector will feed it).
- **True per-source attribution:** `PanicSource` MOVED to Shared/Sources (same
  module for app code — zero app-side changes; now widget-visible).
  `PanicLaunchFlag` gained `sourceKey` / `set(source:quitID:)` / `launchSource()`;
  `clear()` sweeps all three keys. `UnhookedApp` captures the source PRE-FRAME
  (the placeholder's onAppear consumes the flag) and threads it
  → `PanicPlaceholderView(presentation:source:)` → `PanicFlowView(quit:script:source:)`
  → `PanicFlowModel.source` → draft → `UrgeEvent.source`. **The
  `.lockscreenWidget` hardcode at PanicFlowView.swift:36 is dead**; a flag with no
  source (legacy widget binary / FORCE_PANIC_ROUTE hook) keeps the historic
  lock-screen default, documented in code.
- **Intent split (behavior follows KIND):** `OpenPanicIntent` = the lock-screen
  WIDGET button (→ `.lockscreenWidget`; stays Shortcuts-discoverable — a
  Shortcuts run attributes exactly what the old hardcode did). NEW
  `OpenPanicControlIntent` = the control family (→ `.controlCenter`,
  `isDiscoverable = false` so the discreet control never surfaces as a "Panic"
  Shortcuts row).
- **Discreet "Reset" control:** NEW `PanicResetControlWidget`, own kind
  `PanicControlDiscreet`, `Label("Reset", systemImage: "arrow.counterclockwise")`,
  neutral gallery description ("Opens a quick reset.") — all strings from Shared
  `PanicControlStyle` (single source of truth, unit-pinned incl. a leak-lexicon
  scan; the flagship control is unchanged and now style-driven). Registered in
  `UnhookedWidgetBundle`.
- **In-app entry (the fourth source):** placeholder-grade "Panic" button on
  `RootPlaceholderView` → `InAppPanicEntry` (pure, unit-pinned: `.inApp` + the
  pre-cache composition — one panic composition path even when the store is warm)
  → sheet-presented `PanicPlaceholderView`. Pre-store by design; degrades to the
  bare breathe frame with no cache (§9 no-dead-ends).

### The RECORDED ADJUSTMENT (platform ceiling, not drift)

iOS exposes NO launch-surface API for controls, and ONE control registration
serves Control Center + lock-screen slots + Action button with USER-assigned
placement (docs-checked with citations: WWDC24 10157, WidgetKit docs — the
Session-13 docs-check phase). "All four sources correctly attributed" therefore
lands at entry-point-KIND granularity: `.lockscreenWidget` / `.controlCenter`
(the whole control family) / `.inApp`; `.actionButton` stays RESERVED in the
schema — never fabricated (S10 panel rule). Rejected alternative: a dedicated
Action-button App Shortcut (also runs from Siri → pins the wrong meaning; adds
AppShortcutsProvider surface no test names). Amended in the implementation-plan
E3.3 row; operator veto path noted in operator-expected §7 + FYI list.

### Process notes (ultracode session)

- Workflow-driven: 8-reader understand fan-out → 3-researcher Apple-docs check
  (the burned-run class killer: every AppIntents/SF-Symbol spelling verified with
  citations BEFORE any code) → adversarial design panel (fact-verifier + critic +
  red-test author drafting against a local parse gate). The critic caught a
  must-fix: my draft counted PanicFlowTests fixture DEFAULTS (:187/:246) as red
  pins — they are shared E3.2 fixtures feeding real assertions (:510,
  QuitRepositoryTests:213); the red commit left ALL existing tests untouched.
- Red-stub discipline (S11/S12 pattern, refined): stubs land the full API surface
  so the 7 pins COMPILE and fail on BEHAVIOR — the flag writer real but reader
  nil, so the round-trip pin fails on read-back and the clear-sweep pin asserts
  the RAW key (non-vacuous red for both halves).
- Structured-output caps killed 3 subagents (readers with big payloads) —
  re-runs with hard size caps or Write-to-scratchpad outputs fixed it; the
  repo-facts verifier was replaced by direct CodeGraph queries. No session-limit
  trips.
- Gates that made zero-burn possible: swiftc -parse ×13, the access-level scan,
  a Linux `swiftc -typecheck -warnings-as-errors` harness over the ENTIRE
  pure-Foundation surface incl. a usage-exercise file, and docs-verification of
  every Darwin-only spelling (`isDiscoverable`, `TypeDisplayRepresentation`,
  `DisplayRepresentation(title:)` interpolation, `arrow.counterclockwise`,
  EntityQuery's `init()`/`entities(for:)`).

### Known limitations / carried forward

- **`.actionButton` unattributable** until Apple ships a launch-surface API
  (recorded adjustment above) — revisit if a WWDC changes the ceiling.
- **In-app entry is placeholder-grade** (sheet-presented, swipe-dismiss; the
  real dashboard PanicEntryButton chrome + discreet app-level variant is E5+
  dashboard work). No new XCUITest: the wiring is unit-pinned
  (`InAppPanicEntry`), the E2E cap (≤12) untouched, the surface is in the
  operator device matrix (operator-expected §7).
- **Widget-copy coverage:** the Shared logic types compile into BOTH targets;
  tests exercise the app-module copies. The widget coverage floor is
  documentation-level until Epic 6 wires mechanical enforcement (ci.yml has
  none today — verified).
- Store-route framing momentum/motivation nil; dashboard-half XCUITest →
  fixture-seeding session; `slip_logged`/`slip_undone`/`panic_opened` → E8.1;
  undone-slip CloudKit tombstoning → §4.3 flip; E0.3 device measurement still
  the only blocker on the permanent latency gate (all unchanged).

## Session 14 — 2026-07-10 — E4.2 zero-shame copy enforcement (COMPLETE)

### Objective & outcome

Resume prompt v2.5: E4.2 — every slip/relapse string passes the no-shame checklist;
copy centralized in one audited strings table. **DONE in 2 billed runs, zero burned:**
red evidence run `29122473990` (146 tests / 15 suites, EXACTLY the 2 designed
issues — both `#require(copy.dashboard)` on the not-yet-extended table) → green run
`29123195424` same session. The plan-named test lives in
`Tests/Unit/SlipLexiconTests.swift` and is a PERMANENT unit-lane gate (Tests/Unit
globs into UnhookedTests — zero ci.yml changes).

### What shipped

- **The named gate** `test_slipStrings_containNoForbiddenLexicon()`: a 37-token
  forbidden lexicon (35 substring tokens + 2 word-boundary tokens `sin`/`cure`,
  which would false-positive on "single"/"secure" as substrings), derived from
  brandkit §1.1/§1.2/§9.3 + MVP §3/§7 + the slipCopy `_meta` monotonic note.
  Matching: casefold + diacritic-fold (the TR-fast-follow posture) + whitespace
  collapse; substring matching deliberately catches inflections ("shame"→"ashamed",
  "guilt"→"guilty", "recover"→"recovery"). Sanctioned terms documented in-file:
  `slip`/`slipped` is THE clinical noun; bare `lost`/`over`/`clean`/`start`/
  `reset`/`sober` excluded with reasons ("nothing's lost" ships; "clean days over
  total days" ships; "Reset" is the discreet control; "sober" is an ASO keyword);
  "addiction" deferred to E9's milestone medical-claim gate.
- **Reflection-driven corpus:** `Mirror`-walked strings of the DECODED `SlipCopy`
  (a field added to the table joins the scan automatically — the table-completeness
  mechanism) + the in-code `SlipCopy.degraded` fallback (it renders too) + the
  panic script's slipped-exit (decode-first scope: `_meta`/`note`/`analytics`
  fields quoting banned phrases are outside `Codable`, the SlipCopyTests
  precedent). Non-vacuity floor: ≥20 reflected strings.
- **The audited table extended:** `SlipCopy.Dashboard` (pendingBanner / undoLabel /
  discreetRowLabel), decode-tolerant optional (the `retryNote` precedent — old
  files still decode; the red state depends on it: nil ⇒ the two designed
  failures). `slipCopy.json` gained the section BYTE-IDENTICAL to the E4.1-shipped
  view literals; `RootPlaceholderView` now renders banner/undo/discreet-row from
  the table — the last view-inline slip literals are dead. NO golden changed by
  construction (RootPlaceholderView has none; SlipFlowView values untouched).
- **Pins:** dashboard strings byte-exact ("Slip logged. Undo?" / "Undo" /
  "Tracked goal"); discreet-row leak scan (the PanicControlStyle precedent);
  degraded totality (`SlipCopy.Dashboard.degraded`, plainest labels);
  `test_forbiddenLexicon_onlyGrows_fromFoundationFloor()` — the live lists are
  pinned as a superset of a frozen foundation set, so removing a token is a
  deliberate two-place edit; matcher behavior pins (catches the plan's seed
  tokens verbatim, never trips on sanctioned copy).

### Process notes (ultracode session)

- Workflow-driven: 3-agent audit fan-out (test-infra recon + banned-lexicon
  derivation with per-token false-positive checks) → adversarial 2-critic panel
  over the uncommitted red diff (red-design auditor + house-style critic; both
  verdicts SHIP, zero must-fix; the auditor independently confirmed the app
  target has NO coverage floor — only StreakEngine does — and control-tested the
  Swift 6 memberwise-optional-default semantics).
- **StructuredOutput retry-cap deaths persist** (Session 13 class): the string
  sweep + BOTH critics died at the cap with complete, valid-looking payloads —
  salvaged verbatim from the workflow transcripts (`agent-*.jsonl`). Next session:
  have critic-style agents Write findings to a scratchpad file and return a
  one-line pointer instead of large structured outputs.
- Zero-burn gates, extended this session with EMPIRICAL local harnesses (run,
  not just typechecked, on the Linux toolchain): memberwise-optional default,
  decode tolerance both ways, the EXACT matcher over the EXACT shipping corpus
  (clean + catches all must-catch), red/green reflected-string counts (20/23),
  and the green-state byte-exact decode — before any billed run.
- `swiftc -parse` ×4; access-level scan; docs-check n/a (zero new Darwin-only
  spellings — Foundation `folding`/`range(of:options:)` + house Testing macros).

### Known limitations / carried forward

- The copy-audit checklist's HUMAN half (MVP §7 sign-off) is operator work —
  flagged in `docs/operator-expected.md` §3 (the dashboard strings are byte-moves,
  no new drafting to review).
- The gate covers slip/relapse strings; panic non-slip copy keeps its E3.2 pins;
  milestones/safety copy gates arrive with their consuming epics (E9).
- E5.1 remains blocked on E8.1's `AnalyticsEvent` enum (its third named test);
  store-route framing momentum/motivation nil → dashboard epic; dashboard-half
  slip XCUITest → fixture-seeding session; E0.3 device measurement still the only
  blocker on the permanent latency gate (all unchanged).

## Session 15 — 2026-07-11 — E8.1 typed `AnalyticsEvent` enum + `AnalyticsService` (COMPLETE; ledger opened early on operator request, closed same session)

### Session-open operator-action record (logged before build work, per operator ask)

Operator reported the Control Center "Panic" control dead on device. A Mac-side
debug session root-caused it (`OpenPanicControlIntent`/`OpenPanicIntent` compiled
ONLY into the widget extension — iOS silently no-ops a control whose
`openAppWhenRun` intent isn't registered in the app target; plus a latent warm
bug: the launch flag was consumed only in `UnhookedApp.init`) and FIXED it
(intents → `Shared/Sources`; new `WarmPanicEntry` warm gate; new
`PanicWarmLaunchTests`; 151/151 unit + 17/17 snapshot on the Mac) — but the fix
is **uncommitted in the Mac's working tree**. This build machine and
`origin/main` (`9f69f2b`) do not have it; no remote branch carries it.

**Operator actions required — recorded in `operator-expected.md` §0:**
1. Commit & push the fix from the Mac (2 moved, 3 edited, 2 new files).
2. Device-verify both paths (cold CC tap → panic flow; warm CC tap → sheet over
   dashboard) — the debug session's explicit ask.
3. Decide the warm-mount presentation (swipe-dismissible sheet vs full-screen
   cover; sheet shipped because the celebration screen has no dismiss button).

**Session 15 consequence:** `panic_opened` seam wiring is DEFERRED this session —
its consumption sites (`UnhookedApp` / `WarmPanicEntry` / `RootPlaceholderView`)
are exactly the files hot in the operator's uncommitted Mac tree; keeping E8.1's
file set disjoint keeps the operator's push conflict-free. All other E8.1 work
proceeds autonomously. `git log`/fetch checked before every push in case the Mac
fix lands mid-session (the standing operator-commits-mid-session pattern).

### Objective & outcome (session close)

Resume prompt v2.6: E8.1 — typed `AnalyticsEvent` enum + `AnalyticsService`.
**DONE in 3 billed runs, 1 burned** (the zero-burn streak ends at three): red commit
`b43b03d` burned run `29130610823` — TEST BUILD FAILED, `AnalyticsWiringTests` was
missing `import StreakEngine` (ManualClock's `MonotonicNow`), zero red evidence —
→ one-line fix `78eb84c` → **red evidence `29130875659`** (157 tests / 17 suites:
EXACTLY the 23 designed failing cases / 33 issues — 17 whitelist kinds + slipLogged
payload + optOut 19-leak + panicOpened wire pin + 3 spy-empty wiring — zero
collateral, every other suite green) → **green `2cc3e1d` run `29131380401`**
all-green same session (157/157 unit, 17/17 snapshot) + TestFlight upload.

### What shipped

- **The closed enum**: 19 cases == the MVP §5 rows byte-exact (wire names pinned as
  a set in-test); associated values REUSE the model enums (HabitCategory / GoalMode /
  PanicStep / PanicSource — one source of truth; `custom` is the wire ceiling,
  `Quit.customLabel` unreachable by type); new String-raw value enums for the rest
  (ColdStartBucket under_1s/1s_to_2s/over_2s, PaywallSource, PriceTestVariant,
  SubscriptionPeriod, WidgetKind, DiscreetComponent, ResourcesSource). No Date and
  no float is representable in ANY associated value (Mirror-walk pinned). NOTE:
  `panic_opened` source serializes an EXPLICIT snake_case map, never
  `PanicSource.rawValue` (camelCase) — Architect MUST-FIX #2, pinned by test.
- **`AnalyticsService`** (@MainActor facade — the deliberate migration from the
  E0.2 non-isolated stub, Architect Q1): `fire()` is the ONE consent gate (opt-in
  default OFF, `isOptedIn` injected); `AnalyticsSink` @MainActor transport seam
  (test-suite §3.1's `SpyAnalyticsSink` shape in both test files); `NoopAnalyticsSink`
  + `.disabled` as the universal injection default.
- **TelemetryDeck 2.14.1 exact-pinned** (project.yml, app target ONLY), spellings
  verified against BOTH official docs and the cloned pinned-tag source;
  `TelemetryDeckSink` lazy-inits the SDK on first receive — never in UnhookedApp.init
  (ADR-6: nothing pre-frame on the panic path; the SDK asserts on pre-init signals
  in DEBUG); the SDK's on-disk SignalCache (10k, retry/backoff) IS the plan's
  on-device queue. **The ADR-8 double gate**: consent hardwired false until E8.2's
  consent step ships the stored opt-in, AND the transport is DORMANT behind the
  empty operator-owned app ID (`AnalyticsConfiguration.telemetryDeckAppID`,
  operator-expected §8) — zero events before consent, by construction, twice over.
- **Wired seams, red-first** (phasing amendment ACKed by the Architect: the wiring
  tests rode the red commit with a compile-surface-only `analytics:` param — the
  debounceSleep additive precedent, ~8 construction sites untouched): `urge_averted`
  warm arm (logUrgeEvent, post-save) + cold arm (flushPanicOutcomes post-commit
  collect-and-fire; quit-guarded — R-NILQUIT rows fire nothing; rollback forfeits
  rows AND events together); `slip_undone` (undoSlip true arm, post-save; the two
  calm no-op arms fire nothing).
- **Docs (§7 rules 8+9, same commit)**: architecture §5.1 gains the AnalyticsSink
  landed note (code names authoritative over the sketch's
  AnalyticsServiceProtocol/FunnelEvent — Architect-confirmed, no ADR addendum);
  test-suite §4.5 pinned to the 19 wire names + in-process test cross-refs +
  `erase_all_completed` spelling drift fixed (was "confirmed").

### Process notes (ultracode session)

- **The privacy-surface pre-approval gate was exercised for real** (agent-workflows
  §2.2): Architect agent APPROVED-WITH-CHANGES before any code. MUST-FIX #1 killed
  the planned `finalizeRow` slip_logged shortcut by reading the actual bodies — it
  runs PRE-save inside logSlip/flushPanicOutcomes (invariant-3 breach), fires on
  quit-less orphans, and misses the cold lands-finalized arm; the verdict specifies
  the correct four-arm post-save placement verbatim for the future wiring session.
  The mid-session phasing amendment went back to the SAME Architect agent
  (SendMessage continuation) and got a reasoned ACK.
- **Critic findings now go to files** (the Session 13/14 structured-output death
  class): zero retry-cap deaths this session. But: **a read-only critic's "compiles
  clean" claim is NOT compile evidence** — critic A asserted the wiring tests
  compile; the burned run proved otherwise.
- **THE BURNED RUN + the new gate**: `swiftc -parse` is IMPORT-BLIND (syntax-only)
  and the Linux harness compiles the APP file's bytes, not test files — a missing
  `import StreakEngine` sailed through both. New rule for every NEW test file:
  copy the import block from the closest proven neighbor (SlipFlushTests for
  repository harnesses) and run an import-coverage check (grep the file's
  non-Foundation types against its imports) before push.
- Empirical Linux harness ran the EXACT shipping AnalyticsService.swift bytes in
  BOTH modes (red: 17/19 whitelist asymmetry + 19-leak + pins, EXACT MATCH; green:
  clean, EXACT MATCH) — the billed runs matched both predictions test-for-test.
- TelemetryDeck reserved-parameter-key list checked against all 15 payload keys —
  no collision (`type` is reserved; we don't use it).

### Known limitations / carried forward

- **Deferred fire-points, each with a named reason**: `slip_logged` (four-arm
  post-save spec sits verbatim in the Architect verdict — its own focused session);
  `panic_opened` (call sites are hot in the operator's uncommitted Mac panic-fix
  tree — operator-expected §0); `panic_step_reached` (ADR-6 warm-up tension: once
  consent can be ON, the first receive could be pre-frame `.breath` during
  PanicFlowModel construction — needs an init-warm-up design); `erase_all_completed`
  (fires-after-consent-wipe ordering inside eraseEverything needs its own small
  design; the named TODO comment stands).
- **E8.2 owns**: the consent screen writing `AppSettings.analyticsOptIn` + the
  device-local mirror + replacing the hardwired `isOptedIn: { false }` in
  RepositoryProvider; the payload-audit doc; dashboards.
- **E5.1 is unblocked BUT carries a schema tension**: its third named test
  (`test_ageGate_firesAgeGateBlocked_withNoAgeProperty`) fires an `age_gate_blocked`
  event that is NOT an MVP §5 row — adding a case is Architect-gated and needs the
  MVP table amended deliberately (or the test re-specced) BEFORE the red run.
- Operator-expected: §0 (Mac panic-fix push + device verify + sheet decision) still
  open; NEW §8 (TelemetryDeck app ID, no urgency); §4 updated (Session 15 used 3
  runs, 1 burned).

### Post-close addendum (2026-07-11, same day)

The operator pushed the Mac panic fix as **`8a0c469`** ("fix: control-family
panic launch — intents gain app-target membership + warm-launch consumption"),
rebased cleanly onto the session's commits (the disjoint-file-set plan held), plus
a `[skip ci]` gitignore chore (`5a39b07`). CI run **`29132554144`**: all-green —
162/162 unit (Session 15's 157 + the fix's 5 `PanicWarmLaunchTests`), 17/17
snapshot, TestFlight uploaded. Operator device-verified BOTH paths working (cold
CC tap → panic flow; warm CC tap → sheet over dashboard); the sheet-vs-cover
ruling stands unvetoed. `operator-expected.md` §0 is CLOSED (only the optional
gstack FYI remains); resume-prompt standing note 6 (Mac-tree conflict guard) is
RETIRED — `panic_opened` wiring is unblocked, with `WarmPanicEntry` now a third
consumption site to instrument when it lands. One operator-support note: the
Actions list's two same-evening ✗ runs (`29130610823` burned, `29130875659` the
designed red) read as "CI fails" at a glance — both are documented above; every
run since is green.
