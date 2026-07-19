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

## Session 16 — 2026-07-11 — E5.1 age gate (COMPLETE, 2 billed runs, zero burned) + TestFlight tester guide (operator request)

### Objective & outcome

Resume prompt v2.7: E5.1 age gate, with the step-0 `age_gate_blocked` schema
tension resolved BEFORE red. **DONE in exactly the 2 planned billed runs, zero
burned**: red evidence `29135328846` (172 tests / 19 suites — EXACTLY the 7
designed failing cases / 30 issues, predicted issue-for-issue by the Linux
harness; snapshot 17/17 and UI smoke green — zero collateral) → green `0054cea`
run `29136061287` all-green (172/172 unit, 17/17 snapshot, TestFlight uploaded).
Session-open operator request delivered first: `docs/testflight-tester-guide.md`
(`bab473a`) — internal groups, external groups/public link, expire-stray-build +
export-compliance answers; operator-expected §5 points at it.

### Step-0 ruling (PM + Architect, binding; operator-vetoable)

**The third plan test was RE-SPECCED to `test_ageGate_firesNoAnalyticsEvents()`
(both branches, opted-IN spy). No `age_gate_blocked` case, no mvp.md §5 edit, no
enum change.** Grounds, each independently verified: (1) structurally unfireable —
`AnalyticsService.fire` is consent-gated, consent is hardwired false until E8.2,
and the ONLY consent writer (the quiz consent step) is POST-gate, so a blocked
user can never be opted in; (2) privacy-adverse — the event would mark a device
as a blocked minor, exactly the vulnerable-user data this posture refuses to
hold; (3) the add-path is operator-only twice over (canonical mvp.md edit +
Architect-gated closed enum whose completeness tests fail by design). Block-rate
stays recoverable at the aggregate as `installs − onboarding_started`. The
implementation-plan E5.1 row rename is the sanctioned living-doc edit (Architect
co-signed under the safety-content gate; landed with this session's close).

### What shipped

- **The conservative boundary (operator-vetoable):** PASS iff `currentYear −
  birthYear ≥ 18`; a difference of exactly 17 could still be a 16-year-old
  (birthday pending) and BLOCKS. Pure `AgeGate.evaluate` (LaunchRouter
  precedent); `currentYear` derives from LiveClock at the composition root —
  no `Date()` in production code.
- **Fail-closed routing:** pure `AgeGateRouting.firstScreen`;
  `AgeGateContainerView` is the NORMAL-ROUTE ROOT above `RootPlaceholderView`
  (E5.2's replacement inherits the gate for free): neutral non-habit frame while
  the store opens → gate until store-truth `ageGatePassed` → content. The
  route-level `root.placeholder` anchor moved UP to the container (present in
  every state; the skeleton's byte-pinned anchor untouched; every smoke
  assertion holds — the panic-side ones are AssertFalse and the container never
  mounts on that route).
- **Storage: ONE defaulted boolean.** `AppSettings.ageGatePassed` (CloudKit
  checklist green); repository `isAgeGatePassed()` fail-closed read +
  `markAgeGatePassed()` via fetch-FIRST `fetchOrCreateAppSettings()` (E8.2's
  consent step shares the helper). NO App Group mirror (Architect MUST-FIX #3);
  the birth year exists only as a transient model input — the schema-walk pin
  (`PersistentStore.schema`, not Mirror — a `@Model` reflects `_$backingData`,
  QA catch) asserts the exact 6-attribute set. Post-erase the gate returns =
  fresh-install state, by design.
- **Blocked surface = a calm resources screen (zero taps to support):**
  verbatim `helplines.json` rows via the predicate `appliesTo:"all" AND
  verified:true` — session hardening of Architect MUST-FIX #1 grounded in the
  directory's own `_meta` ruling (it deliberately EXCLUDED an unverified US
  line); US → 988, TR → 112 until the operator verifies ALO 182 (flag flip =
  automatic inclusion; `test_ageGate_blockedSurface_neverShowsUnverifiedNumbers`
  pins it). Emergency note renders as CALM text (Brand binding: zero red;
  SF Symbols only — calendar/lifepreserver/phone.fill). "Go back" +
  relaunch-re-ask = never a permanent lockout (nothing persisted on block).
- **Content:** NEW audited `ageGateCopy.json` (8 strings, panel-signed, Brand a2
  polish adopted, Flag-2 resolved: no intro subheader — the body keeps its full
  reassurance line) + `AgeGateCopy` loader with lexicon-clean `.degraded`;
  `SlipLexiconTests` gained the reflection-driven age-gate scan (the joint
  sign-off is CI-pinned). **`safetyCopy.json` + `helplines.json` are BUNDLED for
  the first time** (E5.1 is their consuming epic) — operator §3 review moved up.
- **Zero analytics from the entire surface** (blocked AND passed; spy-pinned
  opted-IN). `onboarding_started` stays E5.2's event.

### Process notes (ultracode session)

- **The stricter-loop gates ran as designed and were unanimous:** PM spec →
  parallel Architect (privacy pre-approval + step-0 ruling + technical plan,
  7 MUST-FIX all honored) + Brand (per-string sign-off; caught the spec's
  NAMI/SAMHSA `appliesTo:"all"` misread — so did QA and the Architect,
  independently) + QA (4 mechanic fixes incl. the Mirror→schema-walk correction
  and the opted-IN spy polarity; AC2 persist pin lives in QuitRepositoryTests
  because AgeGateTests deliberately carries NO StreakEngine import).
- **The Linux harness predicted the CI red issue-for-issue (30/30)** and ran the
  green bodies 27/27 BEFORE they shipped — the billed runs held zero surprises.
- **Critics paid for themselves twice:** red critics 3/3 PASS (the compile
  critic isolated-compiled the labeled-tuple `@Test(arguments:)` pattern under
  strict concurrency + warnings-as-errors rather than assert it); the green
  SwiftUI critic caught TWO bare `.background(<composed View>)` sites — the
  soft-deprecated positional overload, a warnings-as-errors burn risk — fixed
  pre-push to the house `.background(_:in:)` form. **New micro-rule: SwiftUI
  backgrounds use `.background(_:in:)`, never the bare positional View
  overload.**
- **Tooling incident (lesson):** a `git stash push` during a mid-session docs
  commit briefly reverted the uncommitted red-commit edits from the working
  tree; popped immediately, verified intact. Rule going forward: NEVER stash
  mid-session — commit docs-only changes via pathspec (`git add <file>`) with
  the code left dirty.
- E5.1 snapshot goldens deliberately NOT recorded this session (no golden
  infrastructure for the two new screens yet) — batch with E5.2's screens in
  one deliberate CI-artifact re-record.
- Doc-drift FYI (canonical docs untouched, operator's call): roadmap says "age
  gate = feasibility condition #6" but feasibility §7's condition 6 is the
  Quit-All tracking item — numbering drift only; the substance (age gate as the
  minors/App-Review mitigation) is unambiguous.

### Operator-action record (the session-open check the operator asked for)

**Nothing blocked the session** — the step-0 path was chosen specifically so no
canonical-doc edit was needed. Recorded during the session (all in
`operator-expected.md`): §5 TestFlight tester guide (timely — and the NEWEST
build now shows the AGE GATE as first screen, not the bare skeleton); §3 NEW —
safetyCopy/helplines now TestFlight-visible + the ALO 182 verify-and-flip task;
§4 Session 16 used 2/2 planned runs, zero burned; five vetoable rulings on
record (boundary, zero-fire re-spec, verified-only helplines, no permanent
lockout, no discreet variant).

### Known limitations / carried forward

- Epic-5 DoD navigation XCUITest (gate un-bypassable end-to-end) rides E5.2's
  quiz (scenario 29) — the pre-gate half is unit-pinned this session.
- Deferred fire-points unchanged: `slip_logged` (four-arm Architect spec),
  `panic_opened` (cold_start_ms waits on E0.3), `panic_step_reached` (ADR-6
  warm-up design), `erase_all_completed` (consent-wipe ordering).
- E8.2 still owns: consent screen + stored opt-in + retiring the hardwired
  `isOptedIn: { false }` + payload-audit doc.
- Warm-panic listeners are dormant while the gate shows (harmless pre-gate — no
  quits exist, cold panic resolves pre-frame; revisit only if a gated-but-quit
  state ever becomes possible, which today it cannot).

## Session 17 — 2026-07-11 — E5.2 quiz engine + 12–14 screens (COMPLETE, 2 billed runs, zero burned)

### Objective & outcome

Resume prompt v2.8: E5.2 — data-driven quiz + `createQuit(from profile:)`, red
first with the five plan-named tests. **DONE in exactly the 2 planned billed
runs, zero burned** (the fourth zero-burn TDD session): red commit `596cb52` →
**red evidence `29151832001`** (190 tests / 21 suites — EXACTLY the 25 designed
failing cases / 55 issues; the Linux harness predicted the pure lane
issue-for-issue at 37/37 BEFORE the push and the SwiftData lane was
hand-enumerated to the issue; build green, snapshot 17/17, UI smoke green — zero
collateral) → green `4e69dd0` → **run `29152486541` all-green** (190/190 unit,
17/17 snapshot, UI smoke, TestFlight uploaded). Mid-session operator status
check answered with a `[skip ci]` docs commit (`95ab733`) — the Session 16
precedent.

### Step-0 rulings (PM + Architect, binding; all operator-vetoable, recorded in operator-expected)

1. **`quiz_completed` is NOT E5.2's** — its canonical MVP §5 trigger is
   "Personalized summary shown" (an E5.3 surface); firing at quiz completion
   would inflate the ≥70% start→summary metric and corrupt the ≥8% conversion
   denominator. E5.2 exposes `QuizFlowModel.completion` — a named handoff
   carrying `(habitCategory, goalMode)` — and E5.3 fires the event on summary
   render. mvp.md untouched.
2. **Fixed canonical `step_number` (R1)**: habit=1 … commitment=13, summary=14
   (E5.3). Hidden conditionals (customName iff custom; allowance iff reduce) and
   the reserved consent seam emit NOTHING for their slots — numbers never
   renumber per user. The UI progress bar shows the visible-sequence position
   (R9): two different numbers, both honest.
3. **Consent = a reserved, unrendered, stringless seam at slot 3** (`kind:
   "seam"`, `owner: "E8.2"`) — E8.2 drops the real consent UI in without
   renumbering; E5.2 never touches `analyticsOptIn` (test-pinned).
4. **The resume checkpoint lives in app-STANDARD UserDefaults** (`quiz.progress.v1`,
   architecture §7) — NEVER the App Group suite (§10 pre-unlock readability; the
   checkpoint may hold the custom habit name). The ONE sanctioned home for
   in-progress free text; cleared on completion; swept by `eraseEverything`
   (both test-pinned).
5. **Goldens: zero for Epic 5; batch point MOVED to post-founder-copy** — the
   whole table is DRAFT, so recording now guarantees a paid re-record. One
   deliberate CI-artifact re-record batches E5.1+E5.2+E5.3 after the founder
   copy pass (refines Session 16's "batch with E5.2" note).
6. **Scenario-29 XCUITest defers** (as specified it needs summary+paywall);
   Epic-5-DoD un-bypassability lands at the unit tier NOW
   (`QuizGateRouting.postGateScreen` + the standing AgeGateRouting pins:
   content is reachable only through gate → quiz → quit).
7. **Motivation choiceIDs ARE the display words** (id == label — Architect
   MUST-FIX: Back re-hydration needs id-match, the panic ReasonsView needs the
   words, and the repository must stay config-free; habit/goal keep
   id == rawValue, triggers keep short never-echoed IDs).

### What shipped

- **`quizConfig.json` = the quiz definition AND its ONE audited copy table**
  (ADR-9; bundled at red like ageGateCopy was): 14-slot map, 13 E5.2 slots, 11
  always-on + 2 conditional + the consent seam; every string DRAFT/founder-owned
  (operator-expected §3), lexicon-scanned (SlipLexiconTests reflection walk over
  the decoded config + `.degraded`; `_meta` decodes only `version` so review
  notes stay out of the corpus). Brand SIGNED-WITH-CHANGES applied: effects
  title → "Noticed any of these lately?" (coherence), lowest slider echo →
  "Taking it slow" ("One day at a time" rejected as AA-coded).
- **Pure `QuizFlowEngine`** (Foundation-only, Linux-harnessed): visibility
  filter, slot-firing advance, answer-preserving back, checkpoint codec, resume.
  **`QuizFlowModel`** (@Observable, NO clock, NO SwiftData): checkpoint-then-fire
  advance (§1.2 invariant 3 — "post-save" for a step = post-checkpoint-write),
  `onboarding_started` once + checkpoint-resume-suppressed, completion clears
  the checkpoint on success only + calm retry surface (Architect SHOULD-4; the
  slipCopy retryNote precedent).
- **`createQuit(from profile:)`** via a NEW private save-free `insertQuit` core
  (Architect MUST-FIX 1): the primitive was rebuilt on it byte-behavior-identical
  (its 9 consuming suites = the refactor safety net, all green); the quiz form
  maps answers through pure `QuizProfileMapping` (Linux-verified), ONE save for
  quit + linked/stamped profile, pre-cache rebuilt with motivations already on
  the quit (test 5's mechanism), `Locale` currency, max-3 reused. `quit_created`
  seam comment at the save (fire-point ASSIGNED to the repository create path;
  wiring deferred, red-first later). `onboardingVariant()` read-only helper.
  `eraseEverything` sweeps the checkpoint in the infallible block.
- **UI:** `QuizFlowView` + `QuizStepContent` (one question/screen, indigo
  visible-progress bar, checkmark chips in selection order, bottom-pinned
  Continue, quiet 44pt Back, slider echoes in words, `quiz.*` a11y ids for
  E5.3's XCUITest) + `PostGateRootView` (quiz-or-placeholder router) mounted at
  BOTH gate-container seams — the gate inherits, its logic untouched, the
  route-level `root.placeholder` anchor rides the container in every state
  (smoke lane provably safe).

### Process notes (ultracode session)

- **Workflows end to end:** spec+approvals (PM → parallel Architect/Brand/QA,
  4 agents), 3 red critics, 3 green critics — 10 agents, zero deaths, all
  findings to scratchpad files (the standing rule). Architect
  APPROVED-WITH-CHANGES (10 MUST-FIX, all honored); QA's 24-case red design
  grew to 25 by promoting the erase pin red-first (Architect MUST-FIX 3 +
  TDD rule 1 outrank the "note for green" shortcut).
- **The Linux harness discipline held for the fourth session:** red profile
  37/37 pure-lane failures label-for-label, green profile 68/68, over the EXACT
  shipping bytes (engine/model/mapping/config/checkpoint/routing + the real
  AnalyticsService). The billed runs held zero surprises: 55 issues predicted,
  55 observed; per-test issue counts matched (9/4/4/3/2/2/2/2 + 7×1 + 10×2).
- **Structural-over-substring pin:** QA's draft asserted the pre-cache blob
  contains no "26" — a random UUID hex could false-positive; replaced with a
  field-name walk over the snapshot card (no spend/trigger/answer-shaped field
  can exist). Deterministic beats clever.
- **Green critics earned their keep again:** both SHOULDs applied pre-push
  (44pt Back target; the completionFailed retry surface actually rendered —
  the Architect-required affordance was silently missing from the first green).
- Two SwiftUI files were the only bytes no harness compiled — the compile
  critic symbol-traced every modifier against the current SDK instead of
  asserting "looks fine" (the Session 15 lesson).

### Operator-action record (the session-open check, per the operator's standing ask)

**Nothing blocked the session** — operator-expected.md's own header said so and
it held: zero operator input needed from open to close. Recorded during the
session (all in operator-expected.md): §3 NEW — the FOUNDER quiz-copy pass
(whole table DRAFT by design) + the effects-step medical read + the
motivation-elaboration decision; §4 — Session 17 used exactly its 2 planned
runs, zero burned; the seven vetoable rulings; §2 — the newest TestFlight build
now walks gate → QUIZ → dashboard placeholder (first build where creating a
quit from the UI works). The standing §4 billing-headroom glance stays open
(non-blocking, ~2 min).

### Known limitations / carried forward

- **E5.3 owns:** the summary + social-proof screens, `quiz_completed` on summary
  render (the handoff waits on `QuizFlowModel.completion`), projected-savings +
  risk-window math into the existing QuizProfile fields, the quiz→summary
  navigation. **Step-0 question for Session 18: social-proof content** — PRD
  says "real review quotes" and none exist pre-launch; fabricated ones violate
  MVP §7 + the Honest personality. Resolve BEFORE red.
- Post-completion the app shows the placeholder dashboard (honest: no summary
  exists); PostGateRootView's completion branch is E5.3's mount seam.
- Deferred fire-points unchanged: `slip_logged` (Architect four-arm spec),
  `panic_opened` (E0.3 latency), `panic_step_reached` (ADR-6 warm-up),
  `erase_all_completed` (consent-wipe ordering) — PLUS `quit_created`
  (assigned to the repository create path, this session).
- E8.2 still owns: consent screen (the reserved slot-3 seam), stored opt-in,
  retiring the hardwired `isOptedIn: { false }`, payload-audit doc.
- Quiz copy is DRAFT until the founder pass (§3); goldens wait on it.
- The commitment slider ships without haptic detents (the haptics-only settings
  channel is later Epic-5+ work; the seam exists in HapticsPlaying).

## Session 18 — 2026-07-11 — E5.3 personalized summary + social proof (COMPLETE, 4 billed runs: 1 burned + 1 spent triggering the smoke's sanctioned deferral valve)

### Objective & outcome

Resume prompt v2.9: E5.3 — personalized summary + social proof, step-0 FIRST
(the social-proof content question), red-first with the three plan-named tests
+ the quiz_completed summary-render fire pin. **DONE in 4 billed runs** — one
burned (the gate lesson below) and one spent proving the new smoke flaky, which
triggered its own pre-recorded deferral valve: red commit `50f6ed8` → **red
evidence `29156626484`** (210 tests / 24 suites — EXACTLY the 31 designed
issues in exactly the 3 new suites: pure 21, spy 4, SwiftData 6, lexicon 0; the
Linux harness predicted the pure+spy lanes label-for-label BEFORE the push —
build green, snapshot green, UI smoke green, zero collateral) → green
`4e0c1ff` → **run `29157369825` BURNED** (Build for testing failed: the NEW
`QuizSummaryUITests` class was missing the `@MainActor` annotation every
UITest neighbor carries — XCUIApplication is MainActor-isolated under Swift 6;
a build failure produces NO evidence) → one-line fix `e49c13a` → **run
`29157616479`: the E5.3 IMPLEMENTATION fully verified** (build green, unit
210/210 incl. all 25 new cases, snapshot green) **but the new scenario-29
smoke itself failed its first CI execution** (the gate-continue tap did not
hand off to the quiz within 10s — the unproven wheel-adjust interaction QA had
named as the exact risk) → **the ruling-(e) valve fired as designed**: the
smoke defers to E7, removal commit `3b091d9` → **final green `29158183470`**
+ TestFlight. The session-open operator check (the operator's explicit ask
this session) found NOTHING blocking and it held end to end.

**GATE LESSON (closes this failure class — standing rule #2 extended):** the
copy-the-neighbor discipline on every NEW test file must copy the neighbor's
CLASS DECLARATION LINE (attributes included — `@MainActor` on every UITest
class) exactly as it copies the import block. The parse gate is
isolation-blind the same way it is import-blind (Session 15's lesson, one
tier up); the green compile critic traced XCUITest API idioms but not the
class annotation — the critic prompt now names class-level attributes
explicitly.

### Step-0 ruling + the panel rulings (all operator-vetoable, recorded in operator-expected)

1. **SOCIAL PROOF: (a) DEFERRED post-TestFlight-feedback — summary-only ships;
   the summary CTA is the reserved NAMED seam E7 remaps.** PRD §6.1 wants "real
   review quotes"; none exist pre-launch and fabricated ones are banned (MVP §7
   + Honest). PM recommended, Architect co-signed (no analytics event brackets
   the screen — an interstitial would add unmeasured friction to the exact
   summary→paywall hop the instrument measures), Brand concurred with a third
   reason: the privacy line ("No account. No server. Nothing to leak.") is E7
   PAYWALL copy (MVP §6) — it lands hardest beside the price; spending it one
   screen early dilutes it back-to-back. **Veto = tell Session 19 to build (b);
   the trust-frame fallback is FULLY DRAFTED + architecturally verified — table
   below, no new panel round needed.**
2. **Savings display floors to the TEN** (`NSDecimalRound(-1, .down)`): a
   projection shown to motivate never overstates — "this much or better"
   (Honest; Brand-endorsed). $26/wk → stored Decimal 1352 exact → "~$1,350/year"
   (the PRD's "~$1,340" is illustrative class, not the rule). Veto = plain
   nearest-10; one pure edit + two test literals.
3. **Risk-window precedence** = evenings > afterWork > social > alone > boredom
   > stress (clock/rhythm windows beat mood states; "FIRST hard window" is
   singular so multi-select collapses to the primary). `frequency` is accepted-
   but-unused v1 (a reserved cadence input — the narrow signature proves
   "derived ONLY from frequency+triggers" by construction). No triggers → nil →
   NO line ("insufficient data shows nothing, not guesses").
4. **`predictedRiskWindow` stores the trigger TOKEN ("evenings"), never the
   phrase** — DRAFT copy stays out of persistence/CloudKit; a copy rewrite
   never migrates rows; the phrase maps at render from summaryCopy.json.
5. **Summary-once, in-memory** (Architect Q2): the CTA dismiss is `model = nil`
   — rebuild-proof by construction (a quit now exists so `makeModelIfNeeded`
   never rebuilds); a relaunch during the summary seconds lands on the
   dashboard WITHOUT re-showing or re-firing — a conservative funnel undercount
   (safe direction for the ≥70% metric). NO persisted flag, NO new field. Veto
   = summary-persisted needs a schema decision.
6. **Scenario-29 was BUILT, flaked once, and its pre-recorded valve FIRED —
   it now defers to E7.** The minimal-path smoke (gate wheel → 5 forced picks →
   optional steps unanswered → summary-before-any-paywall → CTA → dashboard)
   shipped with the green commit, self-isolated via the NEW `UITEST_RESET`
   fresh-install hook (green critic F1: unguarded shared-simulator state was a
   landmine for the imminent E6/E7 smokes). On its FIRST CI execution the
   gate-continue tap failed to hand off within 10s (the wheel-adjust
   interaction — this repo's first gate-driving UITest; every other smoke
   seeds around the gate) while every other suite stayed green — exactly the
   non-determinism QA's valve anticipated: "it DEFERS to the E7 session where
   the full quiz→summary→paywall E2E lands together." Removed in `3b091d9`;
   the `UITEST_RESET` hook STAYS (inert without the env var; it is the
   recorded prerequisite for ANY state-mutating UITest and E7's smoke needs
   it). The Epic-5 DoD's XCUITest clause rides E7 with the drive
   diagnostics it needs (isEnabled preconditions, screenshot attachments);
   un-bypassability stays pinned at the unit tier meanwhile. Veto = tell
   Session 19 to re-land the smoke and spend runs debugging the wheel drive.
7. **`quit_created` DEFERRED again** (QA ruling f): the advertised "one pin +
   one fire line" is false — firing at the assigned seam flips
   QuizCompletionTests' green guard-4 assertion (its opted-IN spy would receive
   .quitCreated), and the honest surface needs quitIndex ordinal pins + a
   multi-quit fixture. It rides the E8 wiring batch, where the E5.2 guard is
   intentionally widened in the same commit.

### The (b) trust-frame fallback (ships ONLY on operator veto of ruling 1; Brand-verified TRUE, register-clean)

| Key | String (DRAFT) |
|---|---|
| trust.title | "Built to keep your business yours." |
| trust.line1 | "No account." |
| trust.line2 | "No server. Nothing to leak." (Brand cadence fix of "No server that can leak.") |
| trust.line3 | "Everything lives on your device — and your own iCloud, only if you turn it on." |
| trust.line4 | "Erase all of it in one tap, anytime." |
| trust.cta | "Continue" |

(Deliberately omits "Apple handles billing…" — that is E7 paywall copy. No
quote marks, no stars, no attribution — it cannot cosplay as testimonials.)

### What shipped

- **`SummaryDerivation`** (pure, Linux-harnessed): savings = weeklySpend × 52
  Decimal-exact; `riskWindowToken(frequency:triggers:)` narrow-signature
  precedence pick; `derive(from:)` reads ONLY spend/frequency/triggers (the
  QuizQuitDraft field set deliberately untouched). **`SummaryFormatter`**
  (pure): floor-to-ten + "~" + stored-`currencyCode` formatting (locale = digit
  grouping ONLY — the Architect MF6 split) + "/year"; 0 → nil (AC4: never
  "~$0/year"). **`SummaryPresentation`/`SummaryViewData`**: absence modeled at
  the data tier (S2 — nil line = omitted block).
- **`createQuit(from:)` fills both EXISTING QuizProfile fields before the ONE
  save** (MF1; exact-set pinned — no new field, CloudKit checklist);
  `latestSummaryInputs()` read-only helper feeds the view from persisted truth.
  Deliberately NOT wired into `recomputeDerivedState()` (MF2: quiz-time
  projections of immutable answers, not live-derived state — the Architect
  reconciled this with the computed-never-stored invariant explicitly).
- **`QuizFlowModel.onSummaryAppear()`** — the guarded once-per-completion
  `quiz_completed` fire (the `onFirstScreenAppear` didFire precedent; payload
  exactly {habit_category, goal_mode} from the CompletionHandoff; re-render
  fires nothing; pre-completion fires nothing; opted-out silent). The R2 header
  comment amended per MF4. Production analytics stays `.disabled` (E8.2's
  double gate).
- **`QuizGateRouting.postGateScreen(hasActiveQuit:quizComplete:)`** —
  completion-first → `.summary` (P0 story 1 pinned at the pure tier;
  `.summary` case + CaseIterable added; the defaulted param kept every E5.2
  call site byte-identical). **`PostGateRootView`** three-way mounts
  **`QuizSummaryView`** at the completion seam: brandkit §6.7 hierarchy — hero
  numeral split from the TESTED display string ("~$1,350" + subordinate
  "/year", both derived, no invented copy), motivation echo verbatim in
  selection order, degraded permutations render a dignified card (absent blocks
  omitted, rhythm closes up), motion/calm one-shot fade (Reduce Motion 0.2s),
  no red, VoiceOver combined label (the "~" never reads as "tilde"),
  `summary.*` anchors (the hero id rides the collapsed a11y element and names
  the rendered variant — green critic SHOULD-A).
- **`summaryCopy.json` + `SummaryCopy`** — the summary's ONE audited copy
  table, its OWN file/type by Architect ruling Q1 (the `steps[]` hazard —
  anything in quizConfig.steps becomes an engine-rendered screen — eliminated
  by construction); bundled AT RED (the ageGateCopy/quizConfig precedent);
  lexicon-scanned shipping + degraded via the new
  `test_summaryStrings_containNoForbiddenLexicon` (+ per-token completeness +
  unknown-token-renders-nothing pins); every string DRAFT/founder-owned; Brand
  SIGNED (zero required replacements — a first).

### Process notes (ultracode session)

- **Workflows end to end:** spec+approvals (PM → parallel Architect/Brand/QA,
  4 agents), 3 red critics, 3 green critics — 10 agents, zero deaths, all
  findings to scratchpad files. Architect APPROVED-WITH-CHANGES (10 MUST-FIX,
  all honored); Brand SIGNED both copy passes; QA READY-FOR-RED.
- **Two sanctioned lead-agent amendments to the QA design (both held):**
  (i) the fire tests target `QuizFlowModel.onSummaryAppear()` per the
  Architect's Q4 interface ruling (QA drafted a new `QuizSummaryModel`; the
  Architect had pre-named it acceptable-but-not-chosen; QA's spy mechanics
  survived unchanged — same 5 cases / 4 issues); (ii) `summaryCopy.json`
  bundled AT RED per the house precedent (avoids green-side project.yml churn),
  so the LEX case passes at red and the prediction moved 32 → 31 issues —
  the billed run then reported EXACTLY 31.
- **The Linux harness discipline held for the fifth session, now TWO lanes
  deep:** red profile 25/25 designed failures + 7/7 pass-guards (pure AND spy —
  QuizFlowModel + the real AnalyticsService compile on the Linux toolchain);
  green profile 32/32 over the exact shipping bytes; `derive(from:)`
  spot-checked over all four SD fixtures; the lexicon matcher + JSON decode
  run empirically over the real strings pre-push. The SD/LEX lanes were
  hand-enumerated to the issue — and matched.
- **Green critics earned their keep AGAIN — and missed one:** F1 (the UITest
  shared-simulator landmine — fixed pre-push with UITEST_RESET) and SHOULD-A
  (hero a11y addressability — fixed pre-push) were real catches; but the
  compile critic symbol-traced the XCUITest API idioms and missed the MISSING
  `@MainActor` class annotation — the burned run. SHOULD-B (hero
  stacks-vs-shrinks at extreme AX sizes) and the summaryData()-per-body-pass
  tidy-up were RULED deferrable to the post-founder-copy design-polish/golden
  batch.
- **A PM-spec internal inconsistency was caught and reconciled at build time:**
  PM §3.1 defines the display string "~$1,350/year" (QA pinned it) while PM
  §4.1's copy table shows hero "~$1,350" with the caption carrying "in a year"
  — the view splits the TESTED string (numeral hero + subordinate suffix), so
  every tested byte renders and no copy was invented. The residual
  "…/year" + "saved in a year…" double-read is a DRAFT copy nit — flagged to
  the founder pass (operator-expected §3).

### Operator-action record (the session-open check, per the operator's standing ask)

**Nothing blocked the session** — operator-expected.md's header said so, this
session's open verified it explicitly (§3 founder pass unchecked → only
consequence: goldens stay deferred, already the plan; §4 headroom: S17 used
exactly 2; all other items carried non-blocking), and it held: zero operator
input needed open to close. NEW for the operator (all in operator-expected.md):
§3 gains the summaryCopy.json rows in the founder pass (11 strings incl. the
caption double-"year" nit + Brand's optional alternative); §2/§5 note the
newest TestFlight build completes the M1 loop (gate → quiz → SUMMARY PAYOFF →
dashboard; panic with your words); §4 run count (4 used: 1 burned + 1 valve
trigger — the zero-burn streak ended at two sessions; the gates that close
both classes are recorded above); the eight vetoable rulings above.

### Known limitations / carried forward

- **E7 owns:** the paywall behind the summary CTA seam (`onContinue` in
  PostGateRootView — remap the dismiss), `paywall_viewed`, the teaser A/B, and
  the scenario-29 paywall tail.
- **E8.2 still owns:** consent screen (the reserved slot-3 seam), stored
  opt-in, retiring `isOptedIn: { false }`, the payload-audit doc — and now the
  E5.3 funnel events become REAL the moment consent + the §8 app ID land.
- **Deferred fire-points unchanged:** slip_logged, panic_opened (E0.3),
  panic_step_reached, erase_all_completed, quit_created (ruling 7 — the E8
  wiring batch, with the QuizCompletionTests guard widened in the same commit).
- The dashboard is still `RootPlaceholderView` — the summary hands off to it;
  the real StreakDashboardCard is E6-era work ("see streak" M1 criterion is
  satisfied by the placeholder's streak surface).
- Summary copy is DRAFT until the founder pass; Epic-5 goldens (now incl. the
  summary screen) wait on it; SHOULD-B (hero stacking at extreme AX) rides that
  same polish batch.
- `latestSummaryInputs()` is an unindexed fetch — fine at the ≤3-profile scale
  (critic-noted; a sortBy+fetchLimit descriptor is the drop-in if it ever grows).

## Session 19 — 2026-07-11 — E8.2 consent screen + payload-audit doc (COMPLETE, 2 billed runs, zero burned — the streak restarts)

### Objective & outcome

Resume prompt v3.0: E8.2 — the consent screen at the reserved quizConfig slot-3
seam + `docs/payload-audit.md`, step-0 rulings (a)–(e) FIRST, red-first with the
two plan-named tests + the render/live-gate/decline/checkpoint-free/resume/erase
pins. **DONE in exactly the 2 planned billed runs, zero burned:** red commit
`7bf9595` → **red evidence `29164705316`** (225 tests / 26 suites — EXACTLY the
39 designed issues across exactly the 14 designed failing tests; the two-lane
prediction matched issue-for-issue: the pure lane's 34 issues were predicted
EMPIRICALLY by the Linux harness — the sixth consecutive harness-predicted red —
and the SwiftData lane's 5 were hand-enumerated; build green, snapshot green, UI
smoke green, zero collateral) → green commit `b17ce0f` → **final green
`29165381934`** all-green + TestFlight, same session. The session-open operator
check (the operator's explicit ask) found NOTHING blocking and it held end to
end: zero operator input needed open to close.

### Step-0 rulings + the panel rulings (all operator-vetoable, recorded in operator-expected)

1. **(a) The rendered consent step EMITS `quiz_step_completed(3)`** — post-choice
   (the tap writes durably BEFORE Continue advances), through the generic gate
   with ZERO special-casing: the live `fire()` gate itself drops it for decliners
   and passes it for opted-in users. It is the cleanest opt-in-numerator proxy
   (the first transmittable event = "reached consent AND opted in") and keeps the
   consenting funnel contiguous 3→4→…→14. Veto = suppress (a documented one-line
   fork in ConsentGateTests flips test #3 to its inverse).
2. **(a-consequence, recorded LIMITATION) The opt-in RATE has no event-based
   denominator:** `onboarding_started` and slots 1–2 fire pre-consent and are
   gate-dropped for EVERYONE (MVP §5's "fire nothing before the choice", enforced
   at the one gate) — the measurable funnel BEGINS at slot 3. Numerator ≈
   `quiz_step_completed(3)` volume; denominator must come from App Store Connect
   units. No code, a reporting note — the honest reading of ADR-8 once a consent
   event is forbidden (none may be added; MVP §5 is operator-only).
3. **(b) BOTH hardwired-off sites retired into ONE live service (Architect
   Amendment B):** the composition root constructs the single production
   `AnalyticsService` (real sink + live closure), the repository VENDS it, and
   `PostGateRootView` consumes the vended service — views never construct sinks
   or consent reads. The self-reference (closure needs the repository; the
   service is a repository constructor arg) broke with a 2-line late-bound
   `ConsentReader` (fail-closed default, weak back-reference — cycle-free). The
   rejected alternative (raw `mainContext` read in the closure) would have forked
   the read authority for a privacy-critical field. `AgeGateContainerView` keeps
   `.disabled` — the age-gate surface stays zero-fire, belt-and-braces.
4. **(c) The consent choice persists to `AppSettings.analyticsOptIn` AT THE TAP,
   and can never be a QuizAnswer or checkpoint byte BY TYPE (Architect Amendment
   A):** slot 3 renders via a NEW `StepKind.consent` — NOT `singleChoice` (whose
   generic chip toggle records QuizAnswers into the checkpoint) and NOT a
   seam+owner exception (which would re-open the `visibleSteps` predicate that
   scope-guard e forbids touching; it stayed byte-identical). The render path
   calls the new `QuizFlowModel.recordConsent(_:)` ONLY: transient
   `consentChoice` for Continue-gating (stored `false` is ambiguous between
   declined/unanswered — never read back), `persistConsent` injected (the
   onComplete/persistPass precedents; `try?` = fail-closed). Writer =
   `setAnalyticsOptIn` sharing `fetchOrCreateAppSettings` (Session-16 MUST-FIX
   #6 honored verbatim); reader = `isAnalyticsOptedIn()` fetch-only `?? false`.
5. **(d) Resume around slot 3 holds WITHOUT the checkpoint carrying consent:**
   past-consent resumes past (the choice lives in AppSettings — never re-asked);
   killed-ON-consent resumes ON it with a fresh deliberate pick required
   (`consentChoice` nil on every construction — never a pre-selection). The
   chose-then-killed-before-advance edge is PROVABLY harmless: no event can
   transmit in the re-decide window (onboarding_started is resume-suppressed AND
   gate-dropped; slot 3 fires only on the deliberate re-Continue, reading the
   re-pick). Post-erase: the AppSettings row deletion rebirths default-false —
   consent resets OFF with ZERO new erase code (test-pinned).
6. **(e) The consent copy lives IN quizConfig.json slot 3 (in place)** — consent
   IS an engine-rendered step, so the steps[] hazard cut the OTHER way here.
   PM+Brand+QA joint sign-off (safety-content gate) BEFORE code; **Brand
   SIGNED-WITH-CHANGES: "anonymous" STRUCK from title + opt-in label** as the one
   word the payload audit cannot verify (a legal characterization, not an
   observable; an asymmetric reassurance riding only the accept button; a
   "usage"-collision with the helper) → ship copy "Share app usage data?" /
   "Share usage data" / "No thanks", with the STRONGER audit-backed "never tied
   to you" folded into the tightened helper ("…never your answers, notes, or the
   times you log…"). All four strings DRAFT/founder-owned (§3 pass), verified
   lexicon-clean empirically pre-push, auto-scanned by the reflection corpus.
7. **The degraded config stays consent-free (Architect Q4, QA-pinned):** a
   decode-emergency user simply never opts in — fail-closed default-off is the
   privacy-safe divergence from "prompt in early steps"; an unmeasured emergency
   path defaulting to no-collection is the right direction. Pinned by
   `test_degradedConfig_hasNoConsentStep_soDegradedUsersStayOptedOut`.
8. **`quit_created` DEFERRED AGAIN (QA ruling, scope-guard c exercised):** E8.2
   is the consent+audit slice of Epic 8, not the event-wiring batch; guard-4 was
   deliberately left UN-widened because it is PROTECTIVE exactly while consent
   churns the completion seam; the honest wiring needs its own session (post-save
   fire, quitIndex 1–3 ordinal pins, multi-quit fixture, the throwing-4th case).
9. **No new UITest (QA §5):** everything is unit-coverable; goldens stay deferred
   (founder pass); the one thing a UITest uniquely proves (rendered control →
   real wire) is exactly the payload audit's job on a REAL device with real TLS.
   The a11y-id build obligation shipped (`quiz.step.consent`,
   `quiz.choice.optIn`/`quiz.choice.decline`) so E7's smoke can drive the step.
10. **No Settings opt-out surface yet (PM recorded candidate):** the copy is
    correctly SILENT on reversibility (promise nothing unbuilt — Brand commended
    and flagged "do NOT let it creep back at the founder pass"). A real Settings
    analytics toggle is the GDPR/revocability fast-follow; roadmap item, not
    this session.

### What shipped

- **`QuitRepository`:** `isAnalyticsOptedIn()` (fetch-only, fail-closed, the ONE
  read authority), `setAnalyticsOptIn(_:)` (shared singleton helper + sync save),
  `analyticsService` (the vend). **`RepositoryProvider.liveRepository`:** the
  `ConsentReader` late-bound live closure (weak, cycle-free) replaces
  `isOptedIn: { false }`. **`PostGateRootView`:** vended service + `persistConsent`
  wiring replaces `analytics: .disabled`.
- **`QuizFlowModel`:** transient `consentChoice`, defaulted `persistConsent`
  param, `recordConsent(_:)` (write-at-tap). **`QuizConfig.StepKind.consent`** +
  the flipped slot-3 JSON entry (signed strings; `_meta` notes updated).
  **`QuizFlowView`:** the `.consent` control — two EQUAL pill rows (the sibling
  chip shape exactly; glyph-carried selection; no red; no pre-selection;
  opt-in first, decline an equal second) + the `.consent` Continue-gating branch.
- **Tests:** `ConsentGateTests` (10, pure/Linux-harnessable) +
  `ConsentPersistenceTests` (5, SwiftData; the two PLAN-NAMED tests live here) +
  the six E5.2-era R4 pins reversed in the red commit. 225 total, 26 suites.
- **`docs/payload-audit.md`:** the standing operator MITM gate — release-criteria
  mapping table, mitmproxy setup, ingest-host allowlist (`nom.telemetrydeck.com`,
  verify-on-first-run note), the 4-path procedure (fresh / zero-before-consent /
  decliner / opted-in), the code-derived allow-list + HARD-NEVER absence set, a
  worked FAIL example, the archive checklist producing App-Privacy-label inputs,
  §7 re-run triggers. §1 states the sequencing precondition prominently: the
  property half CANNOT run until the operator's §8 app ID ships in a build.

### Process notes (ultracode session)

- **Workflows end to end:** spec+approvals (PM → parallel Architect/Brand/QA, 4
  agents), 3 green critics — 7 agents, zero deaths, all findings to scratchpad
  files. Architect PRE-APPROVED-WITH-AMENDMENTS (3 amendments, all honored);
  Brand SIGNED-WITH-CHANGES (the "anonymous" strike); QA READY (15 tests, the
  DEFER-quit_created ruling, the no-UITest ruling, the 11-point audit checklist).
- **THREE lead-agent catches beyond the panel (recorded amendments, Session-18
  precedent):** (i) the Architect's reversal list named three E5.2 pins but the
  model-tier trace found SIX — `test_quiz_everyStepAdvance` (the fired-slot
  array + its parameterized argument list), `test_quiz_backNavigation` (back
  from frequency now lands on consent), and the resume-checkpoint hop test all
  flip too; all six rode the red commit and the harness proved them. (ii) The
  reversed AC10 pin was written ID-BASED (`kind != .seam` + strings-present),
  NOT `.consent`-kind-based — naming the new enum case at red would have dragged
  `StepKind.consent` + the exhaustive-switch arm into the red commit (an
  isolation-blind-class hazard). (iii) QA's stub naming (`analyticsOptIn()`)
  yielded to the Architect's interface contract (`isAnalyticsOptedIn()`) — the
  privacy gate owns interface names; QA's mechanics survived unchanged.
- **The two-lane harness discipline held for the sixth session:** red profile
  11 failing / 34 issues EMPIRICAL on Linux (the mirrored suite = verbatim
  shipping bytes of the whole pure lane + byte-identical Codable extracts);
  green profile 25/25 over the exact shipping bytes INCLUDING an in-harness
  mirror of the lexicon matcher run over the four new consent strings; the
  billed red run reported EXACTLY the predicted 39 (34 + 5 hand-enumerated).
- **Green critics earned their keep as burn-insurance:** the compile critic
  REPRODUCED the two riskiest Swift-6 constructs under
  `-strict-concurrency=complete -warnings-as-errors` (the ConsentReader
  non-Sendable-closure isolation inheritance; the `try?`-in-Void-closure
  persistConsent) rather than reasoning about them — both EXIT 0. The one
  cross-critic note (hardcoded `Color.white` on the selected chip vs a
  brand/onPrimary token that does not exist in-repo) matches the shipping
  sibling chips byte-for-byte and rides the post-founder-copy polish/golden
  batch (the Session-18 SHOULD-B class).

### Operator-action record (the session-open check, per the operator's standing ask)

**Nothing blocked the session** — operator-expected.md's header said so and the
open verified it explicitly: §3 founder pass unchecked → only consequence:
goldens stay deferred (already scope-guard d); §8 app ID absent → the transport
stays dormant BY DESIGN (the audit doc's §1 precondition records it); §1/§2/§5/
§6/§7 carried non-blocking; zero new operator commits on origin/main; the root
OPERATOR-TODO.md still the pointer. **It held: zero operator input needed open
to close.** NEW for the operator (all in operator-expected.md): §3 gains the 4
consent DRAFT strings (one Brand style-fork noted); §8 is now the LAST gate on
real funnel data and gains the run-the-audit follow-up; §4 the honest 2-run
count; the ten vetoable rulings above.

### Known limitations / carried forward

- **The payload audit's EXECUTION is operator-owned** and sequenced behind §8:
  zero-before-consent verifiable now; the property half needs the app ID build.
- **E7 owns:** the paywall behind the summary CTA seam, `paywall_viewed`, the
  teaser A/B, scenario-29 re-landed WITH drive diagnostics (UITEST_RESET still
  has no consumer, stays inert), and driving the consent step in that smoke.
- **Deferred fire-points unchanged:** `slip_logged`, `panic_opened` (E0.3),
  `panic_step_reached`, `erase_all_completed`, `quit_created` (ruling 8 — its
  own wiring session WITH the guard-4 widening).
- **Settings analytics opt-out** — recorded roadmap candidate (ruling 10).
- Consent strings DRAFT until the founder pass; Epic-5 goldens (+ the consent
  step screen now) wait on it; the Color.white/onPrimary polish rides that batch.
- The dashboard is still `RootPlaceholderView`; E6 owns the widget suite and the
  real streak surface (`widget-state.json` writer seam ready in
  `rebuildSnapshots()`).

---

## Session 20 — 2026-07-12 — E6.1 WidgetToolkit timeline provider (COMPLETE, 1 billed run, zero burned)

### Objective & outcome

Resume prompt v3.1: E6.1 — the WidgetToolkit timeline provider (midnight/DST
rollover, stale-grace, `Text(timerInterval:)` ticking counters), step-0 rulings
(a)–(d) FIRST, red-first with the four plan-named tests. **DONE in exactly 1
billed run.** Red evidence is the LOCAL package lane (`swift test` on Linux —
the sanctioned package-tier form, session-rules.md:84-85): **9 failing tests /
27 issues, zero crashes, zero build errors** → green **15/15**, 98.68% lines
against the now-CI-enforced 90% floor. Red commit `7058634` + green commit
`47e56a5` were pushed TOGETHER so GitHub Actions fired once at HEAD
(`29174800786`).

The session-open operator check found **nothing blocking**, and it held end to
end: **zero operator input needed, open to close.**

### The step-0 panel (31 agents: 3 specs + 28 adversaries, zero deaths)

Every panel ruling was adversarially refuted-or-confirmed before any code. The
adversaries broke **7 of 15** rulings — including two the lead had to arbitrate.

1. **(a) THE FEED — snapshot, not store (L2).** The E6.1 plan row said "reading
   shared store → StreakEngine → entries". Both halves were WRONG, and the docs
   that contradict it are the authoritative ones: ADR-6 ("Widgets read only
   snapshots, never the database"), §7 ("widgets are pure functions of
   widget-state.json"), §5.1 ("the widget extension gets read-only snapshot
   access"). The plan's "store" means the App Group *location*. Plan row corrected.
2. **(L1) THE DAY RULE — the one genuine head-on conflict.** The Architect ruled
   `dayNumber = elapsedSeconds / 86_400` (the engine's tz-invariant
   `StreakValue.days`); QA ruled a CALENDAR day incrementing at local midnight.
   **Both survived their adversaries** — both are internally coherent — so the
   lead arbitrated. **CALENDAR DAY WINS**, in the quit's FIXED start timezone.
   Four doc citations force it (the plan's own test name
   `entriesCrossMidnight_incrementDay`; §11's "entries only at midnight
   boundaries"; test-suite scenario 23; test-suite §1.1's "day boundaries
   computed in the quit's timezone"), and under elapsed semantics the plan-named
   DST test would have **no subject at all** (DST cannot perturb elapsed seconds).
   It does not contradict ADR-7: `StreakValue.days` has **zero display consumers**
   — it is a DURATION readout feeding milestone math. E6.1 is the first surface to
   define "Day N", so it is being defined, not contradicted. **Recorded as ADR-11**
   (architecture §13) because it is now binding on the dashboard, StandBy and Live
   Activity — two surfaces rendering different "Day N" for one quit is the biggest
   latent inconsistency this session could have left behind.
3. **(c) SCOPE — the PACKAGE HALF ONLY (L3).** The Architect wanted the full
   vertical (writer + DTO + erase + template); QA wanted package-only. QA's ruling
   survived intact and three facts decided it: the row is tagged `[PKG:WidgetToolkit]`
   and its acceptance criterion is *exactly* "rollover/stale logic lives in
   WidgetToolkit, only templates live in the app" (E7.1 is the house precedent for
   a `[PKG:]` row deferring app wiring); the app vertical costs 2 billed runs
   (app-lane red evidence cannot be produced on this Linux box), consuming the
   budget *including* the contingency; and it would drag in a `Quit` SwiftData
   schema change (the quit's start timezone) that deserves its own privacy-gated
   step-0. The E3.1 erase rule is NOT tripped — no App Group artifact lands.
4. **(L4) Foundation-only, BY RULE.** No WidgetKit, no SwiftUI, no StreakEngine.
   That is what keeps `package-units` on the free ubuntu runner. `Calendar`/
   `TimeZone` ARE Foundation and Linux carries the full tz database (verified
   empirically). The package header's prophecy — "once WidgetKit imports land, the
   lane moves to the macOS runner" — is CANCELLED and rewritten as a prohibition.
5. **(L10) THE BUDGET CORRECTION.** Session 19's "possibly ZERO billed runs" was
   **structurally unreachable and is struck**: `ci.yml` has no per-job path filter
   (`paths-ignore` is only `docs/**`, `**.md`), so ANY `Packages/**` push runs the
   macos-26 `app` job, and a green main push additionally runs the macos-26
   `testflight` job. **There is no such thing as a zero-billed-run CODE session.**
   Free *lanes* exist; free *runs* do not. The honest lever is pushing red+green
   together (1 run instead of 2), which is what this session did.
6. **(L6) UNAVAILABLE emits ONE entry, never `[]`** — an adversary's catch, and it
   is load-bearing: WidgetKit does not fall back to `placeholder(in:)` on an empty
   timeline, it keeps the last rendered pixels. An empty array after an erase would
   strand the erased streak on the lock screen, **still ticking**.
7. **(L9) TWO version pins flip, not one** — an adversary caught that
   `Tests/Unit/WalkingSkeletonTests.swift:47` pins `WidgetToolkit.version` in the
   **billed macOS lane**. Missing it would have burned the run on an undesigned red.

### The green critics: FIVE defects REPRODUCED, not reasoned about

The standing practice (repro, don't reason) paid for itself five times. Each is
now pinned by a test that fails on the old code.

1. **THE DAY COUNT STALLED IN NO-MIDNIGHT ZONES — the serious one.**
   America/Santiago and America/Havana spring forward **at** midnight, so local
   00:00 **does not exist** and `startOfDay()` returns 01:00. A user who quit on
   such a day was measured from a 01:00 origin, fell one hour short of every
   subsequent boundary, and would have read **one day low FOREVER**. Fixed by
   anchoring the count at **local NOON** (noon exists in every zone on every date
   — no DST shift is near 12h). Verified across New York, Santiago, Havana, Lord
   Howe (30-min shift), Istanbul (no DST), Kiritimati (UTC+14), Chatham (UTC+12:45)
   and Apia (the **deleted** 2011-12-30 date-line day): 400 consecutive boundaries
   each, **zero breaks**. An `ordinality(of:.day,in:.era)` fix was tried FIRST and
   **REJECTED** — it is off by one on exact-midnight instants under Linux
   Foundation, which is *every boundary entry*. (The lead's own first harness
   missed this because it probed at noon, not at the boundary — the failing test
   caught it.)
2. **"Day 0" / "Day -399".** The widget's `now` is the raw device clock and the
   widget runs no clock guard by design (ADR-6 — the guard runs app-side and
   corrects `streakStart`, not `now`), so a Settings date rollback rendered a zero
   or negative day: the exact fabrication `Kind.unavailable` exists to prevent.
   Floored at Day 1.
3. **STALE-GRACE WAS DEAD** for every entry after the first: freshness was judged
   once at plan time and stamped onto entries that render days later — so the flag
   stayed `.fresh` in precisely the scenario it exists to detect (the write path
   died and nothing is refreshing the state). Now judged at each entry's own render
   time.
4. **`refreshAfter` could equal `now`** (zero horizon), which tells WidgetKit
   "reload immediately" — a hot loop against the §11 refresh budget. It is now the
   last real BOUNDARY, falling back to the next rollover.
5. **`TimeZone.autoupdatingCurrent` SURVIVES Codable.** State whose bytes said
   `"America/New_York"` decoded to Istanbul **on an Istanbul device**, silently
   defeating the travel-immunity the fixed-zone anchor exists for. Pinned to a
   fixed zone at the door; the encoded JSON no longer carries the autoupdating flag.
   (This one would have detonated in E6.2, inside the writer, far from its cause.)

The compile critic returned SAFE_TO_PUSH having REPRODUCED the two riskiest
constructs under `-strict-concurrency=complete -warnings-as-errors` (both exit 0),
and docs-checked every Foundation/WidgetKit signature against Apple's docs JSON
(`Text(timerInterval:pauseTime:countsDown:showsHours:)` is iOS 16+ and
`countsDown` defaults to **true** — a count-UP streak must pass `false`; recorded
for E6.2's template).

### CI

The WidgetToolkit **90% coverage floor lands now** (test-suite §2 binds floors to
a module's FIRST merged version) on the free ubuntu lane. It needed a **pollution
guard** as well as a TOTAL-row guard, which the docs critic reproduced: `llvm-cov`
does **not** emit an empty report when its path filter misses — it warns on stderr,
then reports `Tests/**` and `.build/**` with a valid TOTAL row and **exit 0**. Test
files are ~100% covered by construction, so a polluted TOTAL would drift above the
floor while the source coverage it claims to measure rots unseen. Verified failing
closed (exit 2) on a missed filter. **The StreakEngine gate survives this only via
its extra `seenFiles != 2` check — worth remembering if that gate is ever edited.**

### What shipped

- **`Packages/WidgetToolkit`** (its first real content; version `0.0.1-skeleton` →
  `1.0.0`, both pins moved): `StreakWidgetState` (streakStart / timeZone /
  generatedAt — domain-neutral, minimized, `TimeZone` Codable round-trip verified)
  + `StreakWidgetStateReading` (read-only BY TYPE — no write member exists to call)
  + `StreakWidgetEntry` (kind / dayNumber? / tickWindow: `ClosedRange<Date>`? /
  freshness — string-free: E6.1 ships logic, templates are E6.2's) +
  `StreakWidgetTimelinePlan` + `StreakTimelinePlanner`.
- **15 tests**, all four plan-named ones verbatim, plus the eleven the panel and
  critics forced. Every fixture instant was computed empirically before being
  written down — the harness caught two wrong literals in the first draft (a bad
  spring-forward epoch, and a travel fixture with no actual divergence).
- **`docs/architecture.md`:** ADR-11 (the day rule) + §11 rewritten to separate the
  FRESHNESS path (push reload) from the ROLLOVER path (timeline entries).
- **`.github/workflows/ci.yml`:** `--enable-code-coverage` on the package-units
  step + the fail-closed WidgetToolkit floor.

### Known limitations / carried forward (E6.2 inherits a real list)

- **The app half of the widget feed is E6.2's**, and it is a prerequisite for any
  family rendering real data: the `widget-state.json` WRITER (`rebuildSnapshots()`
  writes only `panic-snapshot.json` today, from 7 post-commit sites + the launch
  refresh); its **privacy field-set table** (§10 — App Group files are
  pre-unlock-readable; the ABSENCE set is the point); **erase membership in THREE
  enumeration sites** (`QuitRepository.swift:647` + both `eraseLocalArtifacts` hooks
  in `UnhookedApp.swift`) per the E3.1 standing rule; and **`project.yml`: the
  `UnhookedWidgets` target has NO package dependencies at all** — it must gain
  `- package: WidgetToolkit` before the extension imports the module, or the iOS
  build fails with "no such module" (a burned run).
- **Milestone-crossing timeline entries are OWED** (architecture §11). Milestones
  are `afterHours`-keyed, so a crossing almost never lands on a local midnight —
  the systemMedium milestone bar would otherwise render up to ~24h stale.
- **The widget gallery still shows dev jargon:** `SkeletonWidget` ships
  `.description("Walking-skeleton placeholder widget.")` to every TestFlight
  tester. Real strings need the founder copy pass + a Shared home (the
  `PanicControlStyle` precedent) so the lexicon gate can see them.
- **ADR-11 is binding on the dashboard.** Whatever renders "Day N" there must use
  the widget's rule, or the two surfaces disagree by up to a day for the same quit.
- Deferred fire-points unchanged (`widget_added` included — the extension
  structurally CANNOT transmit: no TelemetryDeck dep, and consent lives in SwiftData
  behind ADR-6; its fire-point needs its own step-0). Goldens still wait on the
  founder copy pass.

## Session 21 — 2026-07-12 — E6.2 widget families + the app half of the widget feed (COMPLETE, 4 billed runs: 1 burned + red evidence + green-with-one-stale-pin + final green)

### Objective & outcome

Resume prompt v3.2: E6.2 — the widget-state.json writer + privacy field set +
Quit start-timezone + erase membership (3 sites) + the five family templates +
project.yml deps + milestone-crossing entries + gallery strings; step-0 rulings
(a)–(e) FIRST. **DONE. Billed runs: 4 — the planned 2 + the contingency + ONE
over** (honest accounting: `29178893738` BURNED — a deprecation-as-error in the
new snapshot test file, `UITraitCollection(traitsFrom:)` deprecated iOS 17,
fatal under warnings-as-errors, while the app + extension targets compiled
clean; red evidence `29179114316` matched the manifest NAME-FOR-NAME — 12
designed unit failures + 6 recording snapshot tests + 7 born-green pins + build
green, the seventh consecutive harness-predicted red, and recorded the 15
goldens in its own artifact per the step-0 R10 flow; green `29179524777` came
back **243/244** — snapshot lane compared all 15 goldens clean, UI smoke green,
package lane 21/21 + the 90% floor, ONE existing E3.1 fixture stale under the
new schema; final green `29179855734` after the 4-line fixture stamp).
Session-open operator check: nothing blocking, held end to end.

### The step-0 panel (16 agents: 4 specs + 12 adversaries, zero deaths) + lead arbitration R1–R12

Adversaries BROKE or WEAKENED rulings in every domain; the lead's arbitration
(R1–R12) resolved every break:

1. **R1 THE FIELD SET** — the QA-vs-Architect "3-key state vs money/momentum/
   milestone" collision dissolved by layering: the app DTO
   `WidgetFeed{schemaVersion, generatedAt, quits:[WidgetQuitState{id,
   streakStart, timeZoneIdentifier:String, weeklySpend:String(decimal, MAJOR
   units — adversary rename from "weeklySpendMinor"), currencyCode,
   bankedCleanSeconds, momentumPercent, milestoneHours:[Int]}]}` is the
   §10-gated pre-unlock surface (ABSENCE set: no label, category, motivations,
   slip data, discreet flag, anchors); the domain-neutral 3-field
   `StreakWidgetState` is the PLANNER's input only; the templates read
   money/momentum/milestone from the DTO at entry.date. The milestone-ladder
   single-bit vape signal (the only 12h rung) accepted + recorded. The String
   identifier structurally closes the Codable decode hole.
2. **R2 startTimeZoneIdentifier** — `String = ""` (CloudKit-defaulted), stamped
   in the ONE creator funnel (BOTH public creators pinned — the adversary's
   createQuit(from:) catch), one-time launch backfill in recomputeDerivedState
   BEFORE the snapshot refresh; the writer's residual fallback is
   TimeZone.current NEVER GMT; two-device backfill race = recorded limitation.
3. **R3 writer** — `rebuildSnapshots()` (architecture §5.1's own name) writes
   BOTH files in one guarded pass; zero active quits ⇒ the widget file is
   REMOVED, never present-empty (the planner's nil-read ⇒ ONE .unavailable
   entry is what clears an erased streak off the lock screen — test-pinned
   divergence from the panic pre-cache); sub-second amendment: a .normal read
   writes the STORE's startAt byte-for-byte (the adversary's reproduced
   sub-second-pre-midnight forever-under-count).
4. **R4 planner 1.1.0** — `milestones: [Date]` crossings interleave, FUSE on
   equal instants, and extend refreshAfter (max boundary); THREE pins flip in
   lockstep — the package constant + WidgetToolkitTests:13 +
   WalkingSkeletonTests:51 ("two pins" was wrong and ":47" a stale cite,
   grep-verified by three adversaries independently).
5. **R5 multi-quit** — bind by quit UUID never position (the config intent
   reuses PanicQuitEntity/PanicQuitQuery over the panic pre-cache, where the
   brand-safe label lives — the widget feed stays label-free); vanished id ⇒
   .unavailable (no cross-contamination); nil config ⇒ deterministic first;
   the composer lives in SHARED as the provider's unit-tested core (the
   extension links into no test bundle); the stale ":241 bind by position"
   comment fixed.
6. **R6 families** — Rect: Day N + money + the carried panic button; Circular:
   the DAY RING (center Day N, ring = ProgressView(timerInterval: tickWindow,
   countsDown: false) — zero extra fields, no lock-screen milestone consumer,
   no ladder leak); Inline "Day 34"; Small: Day N + ticking duration + the
   MOMENTUM ring (rules brandkit §11 Q3); Medium: + money + the milestone bar
   (computed in-template from the DTO). BOTH ticking initializers default
   `countsDown` to TRUE — both pass false.
7. **R7 StandBy DEFERRED to v1.1** (mvp §3's cut is canonical; the plan-named
   standby test re-specced out via the Session-16 age_gate_blocked precedent;
   the safety-gated "made it through" copy defers with it; TINTED verification
   is not host-snapshottable and routes to the operator §7 device matrix;
   goldens = light/dark ×5 + AX5 for home families ONLY — WidgetKit CLAMPS
   accessory Dynamic Type, so an AX5 accessory golden would pin fiction).
   OPERATOR-VETOABLE.
8. **R8 widget_added DEFERRED to E6.3, mechanism RULED** (extension breadcrumb
   {kind, discreet, firstRenderAt} → the app fires once behind consent; the
   enum case and mvp §5 row already exist; the Epic-6 DoD's "widget_active"
   confirmed a typo by three adversaries). OPERATOR-VETOABLE.
9. **R9 gallery strings** — `StreakWidgetStyle` is a STRUCT with STORED
   properties: the panel REPRODUCED that Mirror yields NOTHING over
   computed-property enums, so a PanicControlStyle-shaped table would make the
   lexicon walk vacuously green forever. Dual-lexicon gate (shame + habit-leak)
   with a non-vacuity floor (G1, permanent). All strings DRAFT → operator §3.
10. **R10 goldens in-budget** — Run 1 = red + record with the views FINAL at
    red; artifact → goldens committed with green; green run compares. Worked
    exactly as designed (after the burn).
11. **R11 erase** — widget-state.json joined ALL THREE enumeration sites in the
    SAME commit + the zero-quits-refresh-DELETES pin.
12. **R12 wiring** — the extension gains WidgetToolkit AND StreakEngine (a
    deliberate, recorded deviation from inherited-item-4's WidgetToolkit-only
    minimum: money renders through the ONE engine formula on every surface);
    UnhookedSnapshotTests' WidgetToolkit dep MANDATORY; the family views live
    in Shared with an EXPLICIT family parameter (the widgetFamily environment
    key is get-only — REPRODUCED: injection does not compile);
    SkeletonWidget RETIRED for the new kind "StreakWidget" (OPERATOR-VETOABLE:
    testers re-add once; the panic button carried into the rectangular family).

### The critics: four reproduced catches, one burned-run lesson, one escaped pin

1. **The cross-import overlay catch (red compile critic — would have burned a
   run):** `Button(intent:)` lives in the SwiftUI↔AppIntents cross-import
   overlay, which is FILE-granular (reproduced: a sibling's import does not
   rescue a file); the views file imported neither AppIntents nor WidgetKit ⇒
   every target would have failed to build. `swiftc -parse` is structurally
   blind to this class (no import resolution).
2. **The decode-repin inversion (green diff critic — would have burned the
   LAST budgeted run):** the first `init(from:)` decoded `TimeZone.self`;
   autoupdating bytes materialize `.autoupdatingCurrent` whose `.identifier`
   is already the READING host's zone, so the "re-pin" silently bound to the
   wrong zone and P5 passed only on a Berlin-zone host (REPRODUCED under
   TZ=UTC: 20/1 vs 21/21). Fixed by decoding the identifier STRING; the suite
   verified under Berlin/UTC/Kiritimati hosts.
3. **The boundary battery (green boundary critic):** 14 planner probes + 15
   composer probes + 28 catalog probes + the A1 key-set assertions run verbatim
   over the real bytes — zero defects.
4. **THE BURN (run 29178893738) and its gate:** the snapshot writer's manifest
   CLAIMED neighbor-mirroring while deviating (a `UITraitCollection(traitsFrom:)`
   merge no neighbor carries — deprecated iOS 17 = a build failure under
   warnings-as-errors). **NEW STANDING GATE: any API form in a new test file
   that no neighbor uses is a docs-check item, and the docs check must read the
   DEPRECATION metadata (metadata.platforms deprecated/deprecatedAt), not just
   existence.**
5. **THE ESCAPED PIN (run 29179524777, 243/244):** the E3.1
   non-mutating-launch fixture inserts `Quit()` directly — a bare row now
   carries the pre-E6.2 "" zone the backfill legitimately heals, so the
   `recomputeDerivedState() == false` pin flipped. Fixture repaired ("clean"
   now includes a stamped zone; the pin's mutant-killing meaning unchanged).
   **LESSON: a new mutation source in a shared pass must sweep the FUNCTION's
   return-value pins, not just the changed field's schema pins.**
   Also: one critic died mid-run on an API error and was re-run as a single
   agent (its replacement reproduced every born-green claim + fixture literal).

### What shipped

- Shared: WidgetFeed/WidgetQuitState/WidgetStateStore (+remove()),
  StreakWidgetStyle (the signed DRAFT string table), StreakWidgetViews (five
  families, explicit-family param, pauseDate golden seam), StreakWidgetComposer,
  PanicQuitEntity.init(id:title:).
- App: the rebuildSnapshots() dual writer, tz stamp + launch backfill, erase in
  3 sites, MilestoneCatalog (+ milestones.json BUNDLED — its DRAFT copy is now
  TestFlight-shipping → operator §3), the stale-comment fix.
- WidgetToolkit 1.1.0: the milestones param + the decode-door re-pin (21 tests,
  90% floor held).
- Extension: StreakWidget (per-widget quit selector via AppIntentConfiguration;
  the provider is a shim over the Shared composer); SkeletonWidget retired.
- Tests: +31 (6 package / 19 unit / 6 snapshot) + 15 goldens recorded via the
  red run's own artifact; existing goldens byte-identical (verified no drift).

### Known limitations / carried forward (E6.3 inherits)

- The discreet flag joins WidgetQuitState ADDITIVELY in E6.3 (nothing renders
  habit-differently yet — every family is label-free by construction, so E6.3
  is additive: drop the wind glyph where needed + neutral gallery variants).
- widget_added: the R8 breadcrumb mechanism is ruled and waiting (needs its own
  privacy field-set look + a FOURTH erase site).
- Milestone crossings surface only within the provider's 2-day horizon + 1-day
  cap — later rungs appear at later refills (by design; refreshAfter renews).
- ProgressView(timerInterval:) has NO pauseTime — the circular goldens pin the
  fully-elapsed ring (2025 fixtures); mid-fill state is device-matrix QA (§7).
- Tinted rendering mode is not host-snapshottable → operator §7 row.
- Home-family bars/rings render the system accent (no brand tokens exist
  in-repo); the token pass rides the post-founder-copy polish/golden batch.
- The two-device backfill race (R2) and the vape-ladder single bit (R1):
  accepted, recorded.

---

## Session 22 — E6.3: discreet mode + alternate icons + app-switcher privacy overlay (2026-07-12)

**Objective (resume prompt v3.4):** E6.3 complete — the discreet flag through
writer→composer→views as render-time branches; two DRAFT alternate icons +
switcher; the app-switcher shield; `discreet_mode_enabled` live.
**Outcome: DONE in 2 billed runs, zero burned, zero contingency** — red evidence
`29183485997` matched the manifest NAME-FOR-NAME (the 8th consecutive
harness-predicted red; its artifact recorded the 16 goldens) → green
`29184196211` all-green + TestFlight. Delivery 24/32 = 75%.

### The step-0 panel (6 agents + lead arbitration → rulings R22.1–R22.10)

Panel: Architect, PM, Brand, QA + two adversarial critics (burn-risk, privacy).
Full findings in the session scratchpad; rulings binding:

- **R22.1 — the discreet feed flag (Architect §10 pre-approval GRANTED).**
  `WidgetQuitState.discreet: Bool?` as the LAST stored property, schemaVersion
  STAYS 1 (bumping would blank every widget until rewrite); writer maps
  `quit.discreetMode ? true : nil` — PRESENCE-ONLY (encodeIfPresent omits nil:
  a non-discreet card keeps the exact E6.2 key set; always-emitting
  `discreet:false` would fingerprint "declined the feature"). Empirically
  harness-verified over the shipping bytes under TZ=UTC/Berlin/Kiritimati.
  A1/A2 pins stayed BYTE-UNTOUCHED — the QA panelist's key catch: they are
  born-green minimization guards over non-discreet fixtures, and keeping
  "discreet" in A2's forbidden list is what kills the always-emit mutant. The
  new A6 pin carries presence/absence with key-SET semantics — NEVER
  byte-equality (burn critic REPRODUCED JSONEncoder's hash-randomized key
  order; the proposal's "byte-identical" claim was struck as factually false).
- **R22.2 — per-family discreet render (Brand-signed + one privacy amendment).**
  rect: Day N + panic button, money DROPPED, wind→arrow.counterclockwise, a11y
  "Reset" (all three REUSES of the E3.3-signed PanicControlStyle.discreet
  vocabulary — mirrored as STORED props on the scanned StreakWidgetStyle table,
  R9). medium: Day N + ticker + BARE milestone bar — the "next milestone"
  micro-label drops in discreet (lead adopted the privacy critic's argument
  over Brand's keep: "milestone" is recovery-culture vocabulary that
  strengthens the tracker gestalt; the bar alone is neutral). circular/inline/
  small content-unchanged, goldens recorded anyway as regression guards. The
  circular `:150` wind fallback STAYS — Brand corrected the lead's rationale
  (NO golden exercises it; the real ground is that quit==nil carries no
  discreet flag, so it is unreachable-while-discreet) — and the
  unavailable-state wind glyphs (rect + circular) are RECORDED as a
  deliberate future polish-batch candidate (operator-vetoable).
- **R22.3 — DRAFT alternate icons, agent-generated (operator-vetoable).**
  Pure-Python stdlib generator (committed:
  brandkit/branding-assets/generate-alt-icons.py) renders AppIconCalendar +
  AppIconTimer 1024² opaque per brandkit §4.3 + the Brand panel's exact
  geometry; today-dot ruled #3D6C9E over the prose's "system blue" (decisive:
  a static PNG cannot honestly bake a DYNAMIC color; #3D6C9E is the
  semantic/info token — non-brand, non-red; mockup fidelity). Explicit
  ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES list (never INCLUDE_ALL).
  **The burn critic's rank-1 catch: AppIconSwitcher + every UIApplication
  reference is App-target-only — UIApplication.shared in extension-compiled
  Shared/Sources is a HARD compile error (the S21 file-granular class),
  reproduced before a line was written.**
- **R22.4 — erase × OS icon state (privacy MUST-FIX adopted).** The OS-level
  alternate icon SURVIVES the store wipe; EraseFlow now runs the data erase to
  completion FIRST, then best-effort applyIcon(nil); PLUS launch
  reconciliation in the composition root, RESET-ONLY direction (an OS icon
  that outlived its persisted selection heals to primary; a selection is
  NEVER re-applied — no unprompted system alert). Pinned (I2, I6).
- **R22.5 — the shield is a WINDOW, not an overlay (privacy MUST-FIX #1 —
  the session's most important catch).** A SwiftUI WindowGroup-content
  overlay does NOT cover `.sheet` layers — and the warm-panic sheet renders
  VERBATIM MOTIVATIONS; the proposal as written would have shipped "green
  tests, leaks in the switcher." Shipped: a dedicated UIWindow above .alert
  hosting the zero-content theme-aware surface/base overlay, driven by the
  ONE top-level scenePhase observer through the pure PrivacyOverlayPolicy.
  MUST-FIX #2: the policy is tri-state FAIL-CLOSED — cover iff phase !=
  .active AND discreetAny != false (indeterminate ⇒ covered; the naive
  "any-quit-discreet" boolean fails toward EXPOSURE when the store has not
  opened). Panic branch seeds the tri-state from the SAME single pre-cache
  read (zero new IO; the cold first frame is always .active ⇒ ADR-6
  untouched). RECORDED: the privacy critic recommends a UNIVERSAL overlay
  (the plan's when-discreet gate leaves non-discreet users' panic/slip sheets
  exposed in the switcher) — operator-vetoable product question, one-line
  policy change if taken.
- **R22.6 — analytics.** `discreet_mode_enabled` LIVE: `.widget` on the
  per-quit toggle's OFF→ON edge (repository setter), `.icon` on non-nil icon
  selection (switcher) — enable-only; consent-gated by construction; the
  enum case pre-existed so no Architect vocabulary change. **The R8
  widget_added breadcrumb: DEFERRED to E8 — UNANIMOUS 6/6** (Architect: the
  single highest-risk item buys nothing user-facing, extension write breaks
  §7 purity, concurrent-family TOCTOU; PM: the sink is Noop so the funnel
  loses ZERO data; QA/burn/privacy concur). Field set pre-approved for E8
  with privacy amendments recorded: drop `discreet` from the file
  ({kind, firstRenderAt}; the app supplies the bool at fire time),
  write only on real-content timelines, delete-before-fire idempotency,
  joins all THREE erase enumeration sites. OPERATOR-VETOABLE.
- **R22.7 — the settings surface.** DiscreetSettingsView sheeted off
  RootPlaceholderView = an honest reading of mvp feature 9's "one settings
  screen" (the E4.1 graft precedent); scope EXACTLY per-quit discreet toggles
  + the 3-row icon picker. Discreet quits' rows reuse the neutral
  discreetRowLabel EVEN INSIDE settings (privacy amendment). setDiscreetMode
  is the FULL mutating-write pattern (save → rebuildSnapshots →
  scheduleWidgetReload) — Architect MUST: the flag feeds BOTH caches, unlike
  setAnalyticsOptIn which feeds none. No settings goldens until the founder
  copy pass (S17-R5 batch point).
- **R22.8 — copy.** 10-row PM table, Brand pre-signed, QA lexicon-pinned (S1);
  a11y label exactly "Reset" (brandkit literal; descriptive-parity option
  flagged to the operator). All settings strings DRAFT → operator §3.
- **R22.9 — the QA manifest** (adopted verbatim; matched name-for-name).
  Notable: the plan-named a11y test ships as a discreet-STRING-TABLE scan —
  QA REJECTED the UIHostingController accessibility-tree walk (flaky,
  unprecedented API surface, zero added power: every a11y string IS a table
  string) — with an expanded discreet-render lexicon (+panic, milestone,
  streak, urge, quit, habit + category synonyms) scoped so the gallery's
  legitimate "Streak" is structurally excluded. No UITest (S18 restraint;
  scenePhase is not XCUITest-drivable).
- **R22.10 — store-marketing contradiction (escalated to operator).**
  brandkit §9.1 ("NEVER use the discreet alternates in store marketing") vs
  §9.2 screenshot frame 3 ("Calendar-style icon on a home screen") are
  mutually exclusive — one public store exposure makes the alternate icon
  reverse-image-linkable to Ballast FOREVER, defeating its purpose. Panel
  resolves toward §9.1; the ASO decision is the operator's (operator-expected
  §3 note). ALSO RECORDED: the app name "Ballast" renders under ANY icon —
  "a discreet icon is not a discreet app" (iOS limitation; the honest limit
  of icon discretion; noted for the tester guide).

### What the critics caught (the practice keeps earning its keep)

- The sheet-coverage hole (R22.5) — would have shipped a cosmetic overlay that
  leaks motivations in the app switcher. Caught at step-0 by the privacy
  critic reading RootPlaceholderView's presentation layers.
- The fail-open indeterminate window (R22.5 MUST-FIX #2).
- UIApplication-in-Shared (rank-1 burn, reproduced pre-code).
- JSONEncoder key-order randomization (would have made the new pins flake
  per-run had they been written as byte-equality).
- The A1/A2 edit the lead proposed would have (a) broken A1 forever (its
  fixture is non-discreet ⇒ 8 keys) and (b) destroyed A2's mutant-killing
  power — QA kept both byte-untouched and added A6 instead.
- Post-green: the `UIWindow.Level.alert + 1` operator folklore (docs JSON
  does not confirm it) — replaced with the documented init(rawValue:) before
  the green push rather than risking the run.

### Run accounting

- **Billed run 1 — red evidence `29183485997`** (commit `8d7fd22`): matched
  name-for-name — exactly 6 designed unit failures (A6, I1, I2, I3, I4, O1)
  + 6 recording snapshot fns (D1–D5 = 14 goldens; O2 = 2); every born-green
  pin (A1, A2, G1→floor 12, G2, W1, I5, I6, O1 twins, S1), all 15 E6.2
  goldens, UI smoke, and every package lane GREEN. The 16 goldens recorded in
  its own artifact (the R10 flow, second consecutive session it worked).
- **Billed run 2 — green `29184196211`** (commit `2d31b3a`): all 8 jobs green + TestFlight upload (the first discreet-capable build); 6 designed reds flipped, born-green set held, 31 widget+overlay goldens compared clean.
- Contingency: UNUSED. Zero burned.

### Known limitations / carried

- The shield covers per the plan's when-discreet spec; non-discreet users'
  panic/slip sheets remain uncovered in the switcher (universal overlay =
  recorded vetoable question). Actual switcher-snapshot obscuring is
  device-QA (operator §7 row) — the O1 policy pin + O2 goldens prove the
  policy and the view, not iOS's snapshot timing.
- Mid-session erase leaves discreetAnyActive stale-true until relaunch —
  fail-safe direction (covers), recorded.
- The feed's money fields (weeklySpend etc.) remain in the pre-unlock file
  for discreet quits — the render-strip is a shoulder-surfer defense, the
  field set is the separately-ruled R1 surface (privacy critic NOTE).
- iOS shows its own system alert on programmatic icon changes (platform
  behavior; not suppressible).
- widget_added → E8 (R22.6). Epic-6 DoD now closes MINUS StandBy (R7, v1.1)
  and MINUS widget_added (E8), with the device matrix operator-owned.

## Session 23 — E7.1: PaywallKit + the entitlement state machine, PACKAGE HALF (2026-07-12)

**Objective (resume prompt v3.5):** E7.1 [PKG:PaywallKit] — step-0 rulings
(a)–(e) (the Linux-lane protocol seam load-bearing), red with the four
plan-named tests via the FREE local package lane, green = state machine +
cached-entitlement store + the protocol seam. Budget: 1 billed run + 1
contingency.
**Outcome: DONE in exactly the 1 planned billed run, zero burned, contingency
unused — the zero-burn streak continues.** Red evidence = the LOCAL package
lane per session-rules.md:84-85 (**11 designed-failing tests / 17 issues,
manifest-matched issue-for-issue — the 9th consecutive harness-predicted red;
zero crashes, zero build errors**) → green 16/16 local, **98.21% lines vs the
new CI-enforced 90% floor**, TZ-invariant under UTC/Berlin/Kiritimati,
strict-concurrency+warnings-as-errors clean. Red `14b1593` + green `098d087`
pushed TOGETHER (the S20 lever) → CI run `29192612869` at HEAD.
**Session-open operator check: NOTHING required (operator-expected.md's own
header pre-cleared E7.1's package half — neither the RevenueCat account nor
App Store Connect products), and it held open-to-close.** Delivery 25/32 = 78%.

### The step-0 panel (6 agents + lead arbitration → rulings R23.1–R23.9)

Panel: Architect, PM, QA + adversarial privacy critic, adversarial burn-risk
critic (REPRODUCE-not-reason), and a NEW docs-verifier role (the S22
UIWindow.Level anti-folklore lesson institutionalized — RevenueCat semantics
verified against purchases-ios 5.80.3 source/docs with URLs, no tutorials).
Full findings in the session scratchpad; rulings binding:

- **R23.1 — the seam (a).** Two protocols + a pure mapper + one concrete
  actor, all Foundation-free (ZERO imports in Sources — the package needs
  nothing, not even Foundation): `EntitlementProviding` (the test-suite §3.1
  consumer seam, honored verbatim: currentState/refresh/restore/reset, all
  vending `EntitlementState`) + `EntitlementSource` (the seam the ~20-line
  Darwin-only RevenueCat adapter fills app-side, ADR-4) +
  `EntitlementStateMapper.state(from: EntitlementSnapshot?)` (pure) +
  `CachingEntitlementProvider` (actor). The DTO is the package's OWN minimal
  CustomerInfo mirror: {product tier, periodType, isActive, willRenew} —
  nil ⇒ never; present+inactive ⇒ lapsed; `periodType == .trial` splits
  trial from active (docs-verified: RC PeriodType = normal|intro|trial|
  prepaid; `.trial` is the ONLY trial gate — whether $0 paid-intros report
  `.intro` is docs-UNCONFIRMED, so `.intro` deliberately maps ACTIVE).
  FORBIDDEN in the DTO by privacy ruling: RC anonymous IDs, receipts,
  purchase history, management URLs, prices, currencies — and ALL Dates.
  The docs-verifier killed one folklore member pre-code:
  `CustomerInfo.allExpirationDates` does not exist in v5.
- **R23.2 — the session's head-on arbitration: NO CLOCK in the mapper.**
  QA proposed time-injected expiry math (offline expired cache ⇒ lapsed,
  boundary probes at the expiry instant); the Architect proposed trusting
  RC's `isActive` verdict with no Date anywhere. **Architect won on canon:**
  architecture §8 + test-suite §4.3 both fix the grace policy — "with
  network down, cached entitlement still reports .active … never lock a
  paying user out" (the anti-Quittr principle). Locally expiring a cached
  entitlement is exactly the forbidden failure mode. "Lapsed at expiry,
  never mid-trial" is honored STRUCTURALLY: the mapper ignores `willRenew`
  (pinned — a cancelled trial stays trial until the source says otherwise)
  and a lapse only ever arrives as RC's next snapshot. Consequences: zero
  Date/Calendar/TimeZone in the package (TZ-invariance is structural, still
  proven empirically by running the shipping suite under three host zones),
  and QA's expiry-boundary reds were STRUCK as contradicting canon.
- **R23.3 — the "cached-entitlement store" is IN-MEMORY ONLY (privacy
  MUST-FIX #1).** The resume prompt's phrase resolves to the provider
  actor's `lastKnown` — the package persists ZERO bytes (no file, no App
  Group, no UserDefaults, and no Codable conformance anywhere as the
  structural pin). Architecture §3+§7 double-bind it ("entitlement state is
  never persisted by us"); durable/reinstall caching is the RC SDK's
  documented job app-side ("CustomerInfo will be returned while offline");
  the pre-unlock mirror stays the app-side PanicSnapshot BOOLEAN (a future
  widget-feed entitlement bit is a §10 field-set change needing Architect
  pre-approval — guard recorded so E7.x/E9 cannot slide it in). Erase adds
  NOTHING this session; E2.4's "RevenueCat clear → E7 seam" now exists by
  name: `EntitlementProviding.reset()` — local clear FIRST, the fallible
  source step last, its error propagating for retry (the E2.4 order,
  test-pinned incl. the throwing-source arm).
- **R23.4 — trial_started (c).** The package emits the DOMAIN event
  `EntitlementEvent.trialStarted(product:)` via its own
  `EntitlementEventSink` seam — EDGE-triggered on the transition into
  `.trial` (RC's customerInfoStream replays state every cold start; only a
  diff is honest). Payload = product TIER only (no price, no currency, no
  Date — privacy MUST-FIX: the API must not tempt the app with a wall-clock
  instant). The app maps it to the PRE-EXISTING closed
  `AnalyticsEventKind.trialStarted` behind the ONE consent gate at the
  wiring session, and OWNS cross-launch at-most-once dedup (the package
  diffs per-process only). All four plan-named tests kept their LITERAL
  `test_` names — PM refuted the "packages drop the prefix" claim against
  the actual neighbor files, so no recorded adjustment was needed; the
  "Event" in `test_trialStart_firesTrialStartedEvent` is the domain event.
- **R23.5 — SDK pinning (b).** RevenueCat does NOT enter project.yml this
  session (Darwin-only — docs-grounded: purchases-ios Package.swift declares
  no Linux platform; a linked-but-unconfigured network SDK is also a
  supply-chain surface with no consent wiring). The exact pin is RECORDED
  for the wiring session: **purchases-ios 5.80.3** (released 2026-07-08;
  the docs-verifier refuted a WebFetch-hallucinated "2024" date against the
  GitHub releases API). Requirements (Xcode 15+/iOS 13+) conflict with
  nothing.
- **R23.6 — pricing is config (d).** The package carries ZERO SKU/price
  constants; `Product` is the {monthly, annual} TIER taxonomy (set-pinned),
  and both annual A/B arms map to `.annual` — the $29.99-vs-$39.99 arm
  rides `paywall_viewed.price_test` app-side (vocabularies disjoint; the
  state machine has zero price knowledge). Future config home recorded:
  `App/Resources/Ballast.storekit` (display prices, 3-day annual trial —
  the test-suite §4.3 StoreKitTest tier) + `App/Sources/Monetization/
  ProductCatalog.swift` (SKU↔tier + the entitlement key), wiring session.
- **R23.7 — version.** PaywallKit `0.0.1-skeleton` → **1.0.0** (first real
  content; the WidgetToolkit precedent). THREE literals moved in the green
  commit — source constant + the package skeleton test + `Tests/Unit/
  WalkingSkeletonTests.swift` on the BILLED macOS lane (the S20 L9 class,
  burn-critic rank-1, reproduced pre-code).
- **R23.8 — the coverage floor lands NOW.** test-suite §2 fixes PaywallKit
  at 90% lines and §7's preamble binds floors to the FIRST merged version
  (the E6.1 precedent). ci.yml gains the PaywallKit gate as a byte-identical
  copy of the WidgetToolkit shape (pollution guard + TOTAL fail-closed both
  kept — the burn critic diffed the blocks mechanically: zero delta beyond
  the module token) — reproduced locally BEFORE push: 98.21%, exit 0. The
  "thin SDK-adapter shims exempt" clause is moot (the adapter is app-side;
  the package is 100% pure logic).
- **R23.9 — budget (e).** Package red is free and local; red+green pushed
  together = ONE billed run at HEAD (ci.yml has no per-job path filter and
  cancel-in-progress is false on main — two pushes would be two full runs;
  the red commit alone never becomes a push HEAD).

### What the critics caught / reproduced (the practice keeps earning its keep)

- Pre-code: the 3-literal version blast radius (a missed WalkingSkeletonTests
  literal = a burned 10x run); the free-lane/macOS-lane WARNINGS gap
  (`swift test` on the free lane does NOT run warnings-as-errors — the
  pre-push gate `swift build --build-tests -Xswiftc -strict-concurrency=complete
  -Xswiftc -warnings-as-errors` closes it, now used); `.iso8601` JSON dates
  flagged MUST-AVOID (Linux/Darwin fractional-second divergence) — mooted by
  the zero-Codable design; the `@MainActor` implicit-init nonisolated nuance
  (recorded, unused).
- The docs-verifier killed TWO folklore claims before code: `allExpirationDates`
  (does not exist in v5) and "Promotional" as a periodType (it is a Store
  value). Both would have shipped a dishonest DTO.
- Post-green (both critics SAFE_TO_PUSH with reproduced evidence): the FULL
  4×4 transition matrix of the trialStarted edge audited (fires only into
  `.trial` from non-trial; `trial→active` conversion correctly silent;
  `active/lapsed→trial` fire — RC-unreachable, defensible); actor-reentrancy
  double-fire probed 200×8 concurrent refreshes against a slow sink —
  exactly one fire always (adopt's synchronous prefix decides before the
  await); restore-throw leaves lastKnown untouched (reproduced); THREE
  mutants (mapper trial→active, reset order swap, edge→level) all KILLED by
  the shipped tests — no tautologies; every CI lane reproduced at HEAD
  (PaywallKit 16/16, WidgetToolkit 21/21, StreakEngine 84/84, the coverage
  gate verbatim exit 0).

### Run accounting

- **Billed run 1 — `29192612869`** (HEAD `098d087`, red `14b1593` riding
  under it): the ONE planned run — **ALL 8 JOBS GREEN + TestFlight upload**
  (the new PaywallKit coverage gate green in 41s on the free lane; app lanes
  11m46s; the WalkingSkeleton 1.0.0 pin held on the billed lane exactly as
  swept). Red evidence was local and free
  (11 designed-failing / 17 issues, predicted issue-for-issue; the two
  flagged coincidental-pass safety pins — offline-no-prior and
  no-events-without-transition — behaved exactly as designed and are pins,
  not red evidence).
- Contingency: UNUSED. Zero burned.

### Known limitations / carried (the wiring session inherits a named list)

- **The app half of E7.1 is deliberately deferred** (the E6.1→E6.2 [PKG:]
  precedent): the RevenueCat adapter conforming to `EntitlementSource`
  (~20 lines over Purchases, exact-pin 5.80.3 into project.yml), the
  `EntitlementEventSink` conformer mapping to `AnalyticsEventKind.trialStarted`
  behind consent + cross-launch dedup, `ProductCatalog` + `Ballast.storekit`,
  the app-wide entitlement model, erase wiring to `reset()`, and the
  summary-CTA paywall handoff. The build half proceeds DORMANT behind the
  operator's RC key (the TelemetryDeck precedent); sandbox verification is
  operator-owned later.
- `EntitlementState.trial` carries NO expiry BY RULING — trial-countdown UI
  is a named future decision (additive, with its own privacy look).
- The seam contract nuance is doc-bound, not type-bound: an adapter mapping
  lapsed→nil (instead of present+inactive) would silently read as `.never` —
  documented twice (EntitlementSource + EntitlementSnapshot); the adapter
  session should pin it against the real SDK mapping.
- Non-blocking critic notes recorded: concurrent reset+refresh race
  (erase is terminal — unexercised); a pre-existing tracked
  `coverage-report.txt` at repo root (committed in E6.1, unrelated to this
  session) is a future hygiene cleanup.
- `purchase`/`paywall_viewed` fire-points, Superwall (E7.2), win-back (E7.3):
  untouched, per scope guards (verified by grep: no Superwall/RevenueCat/
  trial_started/price tokens in Sources — comment mentions only).

## Session 24 — E7.1: RevenueCat wiring (DORMANT) + the bundled default paywall, APP HALF (2026-07-12)

**Objective (resume prompt v3.6):** E7.1 APP HALF — step-0 rulings (a)–(f)
(scope: is the paywall SCREEN in?), red (app-lane manifest per panel), green =
the RC adapter DORMANT behind the operator key (purchases-ios 5.80.3 exact) +
ProductCatalog + Ballast.storekit + EntitlementModel + the trial_started wire +
erase wiring + the bundled default paywall at the summary CTA seam. Budget:
2 billed runs + 1 contingency.
**Outcome: DONE in 4 billed runs — the planned 2 + the contingency + ONE over,
with TWO burned (honest §4 accounting below; the S18/S21 shape — the zero-burn
streak ends at two sessions and BOTH burn classes are now permanent gates).**
Red evidence = CI run `29197338715` on `2ac4893`: **28 designed-failing / 47
issues, manifest-matched NAME-FOR-NAME and issue-for-issue — the 10th
consecutive harness-predicted red** (the pure 18-test/35-issue subset was
verified on the FREE local Linux harness first, TZ-invariant under
UTC/Berlin/Kiritimati ×3 full runs; the issue model summed to the observed
counts exactly on both the harness AND CI). Green = `88b32a6` + the shadowing
fix `966f067` (run `29198309877`). **Session-open operator check: NOTHING required
(operator-expected's own header pre-cleared the app half — neither the RC
account nor ASC products; held open-to-close; the RC-key §8 item lands at THIS
close as scheduled).** Delivery 26/32 = 81%.

### The step-0 panel (6 seats + lead arbitration → rulings R24.1–R24.12)

Panel: Architect, PM, QA, Brand, adversarial burn-risk critic
(REPRODUCE-not-reason), docs-verifier (the S23 seat, kept for every SDK-facing
session). Full findings + the binding arbitration in the session scratchpad
(RULINGS-R24.md); the rulings:

- **R24.1 — scope (a).** The paywall SCREEN is IN (PM: it is the objective's
  named payoff; Brand's copy sign-off completed in-panel; a further split =
  three sessions). TWO PM riders overruled on cross-seat evidence: NO
  snapshot goldens (S17 R5's DRAFT-copy batch point extends to the paywall;
  the post-founder-copy batch now = age gate + quiz + summary + paywall) and
  scenario-29 DEFERS to E7.2 on three independent grounds — (i) its
  `…→ paywall_viewed` analytics tail is E7.2's by R24.4, so the smoke's own
  assertion set cannot pass this session; (ii) its purchase leg cannot run on
  CI (xcodebuild never engages a scheme's StoreKit configuration — RC docs
  ground truth; xcodegen's storeKitConfiguration is run-action-only); (iii)
  a flaky wheel-drive on a 1-contingency session is the largest avoidable
  burn (QA). The S18 valve debt carries BY NAME. A DEBUG-only
  `UITEST_PAYWALL=1` render override substitutes as the operator review path.
- **R24.2 — the DORMANT gate (b).** `RevenueCatConfiguration.revenueCatAPIKey
  = ""` (the AnalyticsConfiguration mirror). The live branch lives INSIDE
  `startIfNeeded`'s success block: configure-once (Builder, device-ID
  collection OFF) → adapter → `CachingEntitlementProvider`(+sink) →
  `EntitlementModel`, published as `RepositoryProvider.entitlementModel:
  EntitlementModel?`. DORMANT constructs NOTHING — nil model IS the CTA
  fall-through; the `Purchases` symbol is never referenced at runtime
  (docs-verified: configure alone fetches CustomerInfo+Offerings from
  api.revenuecat.com and persists `$RCAnonymousID` — dormancy is a privacy
  requirement, not hygiene). Pull-based refresh v1 (construction +
  post-purchase/restore; NO customerInfoStream subscription — green-minimal).
  Panic purity explicitly pinned: the init-order spy now also asserts
  `entitlementModel == nil` on the panic route.
- **R24.3 — the adapter seam (QA × docs-verifier synthesis).** A plain struct
  DTO `CustomerEntitlementView` (NOT a protocol — RC's own `periodType`
  member name would collide) + the pure `RevenueCatEntitlementMapper`. RED
  pinned the mapper RC-free/Linux-harnessable; GREEN added
  `Contract_RevenueCat.swift` on REAL SDK values via the public "unit
  testing" inits — the docs-verifier KILLED QA's "not test-constructible"
  premise against 5.80.3 source (folklore list #1) and the S23 carried
  "pin the adapter against the real SDK mapping" item is PAID. The extraction
  reads `entitlements.all` (never `.active`): present-but-inactive ⇒
  `isActive:false` NEVER nil ⇒ `.lapsed`, contract-pinned. An unknown SKU
  still honors an active entitlement (defaults `.annual` — the §8
  when-in-doubt grace applied to config gaps; lead-added red pin).
- **R24.4 — paywall_viewed DEFERRED to E7.2** (PM: MVP §5 fixes `variant` as
  "(Superwall id)" — a bundled-fallback constant does not fit the
  operator-only row's vocabulary ⇒ fit-or-defer; A/B denominators stay
  pristine; dormant routing has no honest live impression anyway). The
  `purchase` analytics fire-point also NOT wired (not in the S24 manifest;
  E7.2 carries it with its own ruling — renewals are not client-honest). No
  `AppSettings.paywallVariantAssigned` (Superwall's field, E7.2, §7-gated).
- **R24.5 — pricing config (d).** SKUs `com.beyondkaira.ballast.monthly` /
  `.annual` (CONTROL $29.99 + the bundled arm) / `.annual.hi` ($39.99,
  Superwall-only) — no price in ids (ASC ids are immutable; PM's naming beat
  the Architect's price-suffixed sketch). Entitlement key `"premium"`.
  **G0 correction (PM's material catch): the rename gate CLEARED 2026-07-08**
  (AppIdentifiers.swift's dated header; real registered com.beyondkaira
  identity) — the resume-prompt's "placeholder bundle IDs" fact was STALE;
  project.yml's G0 comment block corrected in green. Ballast.storekit is a
  **UnhookedTests resource** (a dev/test artifact never ships in the app
  bundle), hand-authored on Linux to the docs-verifier's minimal structure
  with an "open it once in Xcode 26" operator rider; parse-pinned (key-SET)
  against MVP §6 AND against ProductCatalog (two config homes, one drift
  pin). Static display prices live in the CATALOG; the copy table carries
  `%@` templates only (Brand's data-bound rule reconciled with §8's static
  fallback mandate).
- **R24.6 — the trial_started wire (e).** Wire values = the catalog's
  canonical ids `ballast.monthly`/`ballast.annual` (reconciling the
  ALREADY-committed E8.1 fixture — the enum's owed value-domain pin landed).
  Dedup = a bare Bool in app-STANDARD UserDefaults (never App Group, never
  synced, no Date/product/price), **marked ONLY on a consented actual send**
  (QA's rule over the Architect's mark-on-observe: a decliner persists ZERO
  bytes, and a later opt-in while still trialing counts exactly once — RC
  replays state every cold start, so the next consented replay fires).
  Erase sweeps the marker via an explicit step-2 clear — **the App Group
  sweep can NEVER reach an app-standard key (the Architect's load-bearing
  catch)**. The resume-prompt's "seed from RC's cached state" mechanism was
  RETIRED as redundant (the durable bit swallows the replay entirely);
  reinstall-during-trial may double-fire — recorded accepted limitation.
- **R24.7 — erase wiring (f).** `resetEntitlement` = a defaulted-closure init
  param + the ONE post-init late-bind (`bindEntitlementReset`, the
  ConsentReader precedent — the sink needs the repository's analytics, so the
  entitlement stack builds after it). Runs INSIDE `eraseEverything` as the
  NEW step 5 — after `scheduleWidgetReload` (widgets drop regardless of both
  remote steps), BEFORE the CloudKit purge (§10 order) — throws SURFACE for
  retry. QA's EraseFlow-level placement REJECTED (would sequence after the
  cloud purge). The L665 TODO's "anonymous-ID reset" promise SOFTENED per the
  docs-verifier: **v5.80.3 has NO public anonymous-ID reset** (`logOut()`
  throws code 22 for anonymous users — our only kind); honest `reset()` =
  `invalidateCustomerInfoCache()`; entitlements are Apple-account-level and
  survive erase BY DESIGN (a wipe is not a cancellation).
- **R24.8 — SPM dep placement: GREEN, never red.** Red stayed RC-free so red
  evidence could not be burned by dep resolution; the burn critic REPRODUCED
  the full pin graph locally (`swift package resolve`: RC 5.80.3 +
  SnapshotTesting 1.19.3 + TelemetryDeck 2.14.1 → exit 0; our pins win; RC's
  test-only deps pruned; no binary targets; link product "RevenueCat" only).
  5.80.3 re-confirmed latest at session open by THREE seats independently.
  Now a standing rule.
- **R24.9 — the copy.** `paywallCopy.json` → `PaywallCopy` struct (stored
  properties, `.degraded` disclosure-complete fallback; the summaryCopy
  audited-lane precedent beat Brand's in-code lean). Brand's 23-string DRAFT
  table adopted with the S19-class register fix: the paywall ships
  **"No account. No sign-up. Apple handles billing — cancel in one tap."** +
  the provable "Your notes and journal never leave your device." — the MVP §6
  verbatim canon ("No server. Nothing to leak … refund in one tap") is NOT
  placed on this RevenueCat-brokered surface ("No server" one tap before an
  RC-mediated purchase is unprovable there; Apple refunds are requested,
  never one-tap — the brandkit's own caption precedent). mvp.md UNTOUCHED;
  the deviation is the operator's §3 decision. **NO close affordance** (MVP
  §6 hard-ish canon; the sanctioned escape is E7.2's teaser; Brand's
  App-Review soft-wall caution recorded for the operator). PM+Brand+QA joint
  safety-content sign-off recorded at step-0 close; strings stay
  DRAFT/founder-owned.
- **R24.10 — screen architecture.** `PaywallPresentation.make(copy:)` (the
  SummaryPresentation twin — pure, composes every 3.1.1/3.1.2(c) disclosure)
  + `PaywallModel` phases (working/failed/restoredEmpty/unlocked; cancel is
  NOT a failure — userCancelled returns to idle wordlessly) + `PaywallView`
  (teal CTA, checkmark selection never color-alone, amber+symbol never-trap
  failure with retry, restore + legal as quiet text, no red/countdowns/fake
  discounts; annual pre-selected). Live purchase/restore =
  `RevenueCatPurchaser` in the SAME sole RC-importing file (offerings →
  match by catalog SKU → purchase(package:); the bundled fallback offers
  monthly + CONTROL annual ONLY — never the $39.99 arm).
- **R24.11 — CI guard.** New FREE-lane `monetization-importer-lint`
  (swiftdata-lint byte-shape): `^import RevenueCat|Purchases` allowed in
  exactly {the adapter file, Contract_RevenueCat}; `^import Superwall`
  banned outright (the E7.2 scope guard). The regex ANCHORS `^import` — the
  unanchored draft matched a comment during local reproduction (now a
  standing lint rule).
- **R24.12 — budget shape.** As run (accounting below).

### What the critics caught / reproduced (the practice keeps earning its keep)

- Pre-push (green): the composed-but-NEVER-RENDERED auto-renew disclosure —
  the 3.1.2(c) statement was string-presence-pinned in DATA while invisible
  on the SCREEN (false confidence); FIXED in green (`paywall.renewalTerms`
  renders, caption floor, no truncation). The missing explicit panic-route
  entitlement pin — ADDED (additive strengthening of the init-order spy).
  The RC-spelling verifier re-verified EVERY SDK member in both RC files
  against freshly-fetched 5.80.3 raw source (zero mismatches; the
  `@unknown default` warning question MECHANICALLY reproduced clean via a
  two-package mockup; the EntitlementInfo test-init argument ORDER validated
  as a legal defaulted-params subset). The green-diff critic mechanically
  reproduced: the M8 storekit assertions in python (pass), the dual-lexicon
  scan over all 20 rendered copy fields (0 violations), the erase ordering,
  all 28 red→green flips side-by-side, YAML validity, both lint greps, the
  §10 field-set non-touch, and Tests/ byte-untouched beyond the additions.
- Pre-red: the Linux harness predicted the pure subset 18/35 issue-for-issue
  (validated twice — harness AND CI summed identically); the
  strict-concurrency gate reproduced the green shapes (the @MainActor sink
  conformance, the stored reset closure) BEFORE they shipped.
- The docs-verifier's green-relevant kills: `logOut()`-resets-anonymous-users
  folklore (throws code 22 — the erase TODO overpromised),
  `customerInfo(fetchPolicy: .fromCacheOnly)`-returns-nil folklore (it
  THROWS; `cachedCustomerInfo` is the nil-safe peek), RC-synthesizes-offerings
  -from-.storekit folklore (dashboard products required), and
  StoreKit-config-under-xcodebuild (Xcode-run only — this ground truth
  re-scoped scenario-29's deferral).

### Run accounting (§4-honest)

- **Run 1 — `29196899754` (`1fe5828`): BURNED.** Test-target build failure,
  no red evidence: ONE spurious `await` on a same-actor synchronous call in
  the NEW erase-wiring test file (a non-Sendable closure literal inherits
  the enclosing @MainActor isolation → the marked call is sync → warning →
  error under warnings-as-errors). Not catchable by `swiftc -parse`
  (semantic) nor the harness (SwiftData files aren't harnessable). The app
  TARGET compiled clean — strong green signal. **Closing gate (standing
  rule): the spurious-await class is permanently shape-pinned in the Linux
  strict gate (ClosureIsolationShapeChecks), and new closure-into-seam
  shapes in non-harnessable files get mockup-typechecked under strict flags.**
- **Run 2 — `29197338715` (`2ac4893`): the red-evidence run.** App job unit
  lane: 291 tests, **28 designed failures / 47 issues — manifest-matched
  name-for-name and issue-for-issue** (the 10th consecutive predicted red);
  build-for-testing clean; 7 born-green safety pins + all existing tests
  passed; snapshot + UI-smoke lanes green; every free lane green.
- **Run 3 — `29197958414` (`88b32a6`): BURNED.** The green push's app-target
  build failed on ONE error in the Darwin-only adapter: `PaywallKit.PeriodType`
  — the PaywallKit MODULE exports an enum ALSO named `PaywallKit` (the S23
  version marker), so the module-qualified name resolved to the ENUM
  ("'PeriodType' is not a member type of enum 'PaywallKit.PaywallKit'"). The
  adapter HAD to qualify (it imports both SDKs; the bare name is ambiguous
  against `RevenueCat.PeriodType`), and as the one file that only compiles on
  Darwin, its first compile was CI. **Post-hoc Linux reproduction: the
  identical error reproduces on the free toolchain WITHOUT RevenueCat** — a
  one-file PaywallKit-importing probe fails byte-identically, so this burn
  was locally catchable. **Closing gate (standing): a Darwin-only file's
  NON-SDK qualified type references get Linux-probed before push; both-SDK
  files use an alias declared where the bare name is exact
  (`EntitlementPeriodType`), never the module-qualified form.** The dreaded
  dep-resolution class did NOT fire (SPM resolved 5.80.3 clean, exactly as
  the local reproduction predicted); the designed risk point burned on OUR
  module quirk instead. The new `monetization-importer-lint` went green on
  its first run here.
- **Run 4 — `29198309877` (`966f067`): the green run.** The three-line alias
  fix, reproduced clean under strict flags on Linux BOTH ways (failing form =
  the CI error verbatim; fixed form = exit 0) before the push.
  Total: **4 = the 2 planned + 1 contingency + 1 over** (the S18/S21
  precedent shape), two burned, none unaccounted. The critics' pre-push
  catches (the unanchored lint regex, the unrendered 3.1.2(c) disclosure,
  the missing panic pin) and the two local reproductions (the full pin-graph
  resolve; 26/26 harness ×3 TZ) kept it from being worse.

### Known limitations / carried (E7.2 inherits a named list)

- **paywall_viewed + purchase fire-points, variant assignment,
  `AppSettings.paywallVariantAssigned`, scenario-29 (with the S18-owed drive
  diagnostics + its analytics tail), 3.1.1 both-variant copy review** — all
  E7.2's by name (R24.1/R24.4).
- The paywall goldens ride the post-founder-copy batch (S17 R5 extended);
  the screen's only render proofs today are the composed-string pins + the
  DEBUG override. PaywallView hand-rolls the brandkit button idioms (visual
  pass rides the golden batch/E7.2).
- Terms of Use / Privacy Policy render as pre-link LABELS (operator/legal
  owns the URLs + the auto-renew boilerplate wording check against current
  Apple terminology) — MUST become functional links before submission
  (Schedule 2); recorded in §3/§8.
- `Ballast.storekit` is hand-authored (Apple publishes no formal schema);
  the "open once in Xcode 26" validation is an operator rider. The runtime
  SKTestSession display-price tier stays deferred to the named
  StoreKitTest/RC-sandbox contract session (V-K split: the config-drift
  purpose is fully served by the parse pins).
- Reinstall-during-trial may double-fire trial_started (both caches wiped;
  no server-side dedup exists by design). A trial started while consent is
  off fires on the next consented replay observation — the fire is honest
  but late; both recorded.
- `EntitlementModel` foreground refresh is deferred (pull-based v1:
  construction + post-purchase/restore); the `customerInfoStream`
  subscription is a named future enhancement.
- `restoreSuccess` copy is composed but unrendered (the unlocked path
  dismisses); founder-table completeness kept.

## Session 25 — E7.2: Superwall variant adapter (teaser-vs-hard A/B) + the S24 deferrals BY NAME (2026-07-12)

**Objective (resume prompt v3.7):** E7.2 — Superwall behind PaywallKit's
interface (removable per ADR-4); variant assignment logged; teaser = 1-day
local timer then re-present; the four plan-named tests VERBATIM; carrying
paywall_viewed + purchase fire-points, `AppSettings.paywallVariantAssigned`,
scenario-29 (+S18 diagnostics), 3.1.1 both-variant review. Budget: 2 billed
runs + 1 contingency.
**Outcome: DONE in 3 billed runs — the 2 planned + the contingency spent
on scenario-29's pre-worded VALVE (fired as designed on the smoke's single
run; ZERO burned — every run produced its evidence).** Red evidence = CI run
`29204803764` on `5ce52f0`: **16 designed-failing / 22 issues,
manifest-matched NAME-FOR-NAME and issue-for-issue — the 11th consecutive
harness-predicted red** (the pure 14-test/20-issue subset verified on the
FREE Linux harness first, TZ-invariant under UTC/Berlin/Kiritimati ×3 full
runs, built under -strict-concurrency=complete -warnings-as-errors). Green =
`acd2783` — all 16 flips verified green in run `29205964725`, whose ONLY
red was the new scenario-29 smoke (the valve fired; see the run accounting)
— finalized by the valve commit `e281621` (run `29206650207`,
ALL-9-JOBS green + TestFlight). **Session-open operator check: NOTHING
required (operator-expected's own header pre-cleared Session 25 — the
Superwall SDK lands DORMANT behind its own operator key, the RC/TelemetryDeck
pattern; recorded in the session log at open, held open-to-close; the
Superwall-key §8 item lands at THIS close as scheduled).** Delivery 27/32 =
84%.

### The step-0 panel (6 seats + lead arbitration → rulings R25.1–R25.14)

Panel: Architect, PM, QA, Brand, adversarial burn-risk critic
(REPRODUCE-not-reason), docs-verifier (kept for every SDK-facing session).
Full findings + the binding arbitration in the session scratchpad
(RULINGS-R25.md); the rulings:

- **R25.1 — APP-SIDE placement.** SuperwallKit is UIKit-required in practice
  (85 unconditional `import UIKit` files at 4.16.1; the manifest's
  macOS/watchOS platforms OVERSTATE) and `import SuperwallKit` fails to
  BUILD on Linux (exit 13 — the transitive Rust `libcel` binary has no Linux
  slice; burn-critic reproduction). Seam + adapter + composition all in
  App/Sources/Monetization; PaywallKit sources UNTOUCHED (Foundation-only
  free lane preserved); implementation-plan §14's "PaywallKit contributes
  the Superwall adapter" recorded as a portfolio ASPIRATION for a future
  dedicated package session.
- **R25.2 — the DORMANT gate.** `SuperwallConfiguration.superwallAPIKey=""`
  (the RC twin) + `PaywallPresentationComposition.makeAssigner` (the
  makeEntitlementSource twin): key absent ⇒ BundledVariantAssigner and
  configure NEVER invoked. Docs-verified: `Superwall.configure` ALONE
  fetches remote config from api.superwall.me, mints/persists an anonymous
  identity, and posts IDFA/fingerprint install-attribution to
  mmp.superwall.com unless event tracking is restricted (4.16.1
  Superwall.swift:456-534) — dormancy is a privacy requirement. The live
  configure sets `eventTrackingBehavior = .superwallOnly`. The assigner is
  constructed only INSIDE the RC-key live branch: the monetization vertical
  wakes as a unit. **NO `Superwall.reset()` in the erase order** (named
  deferral): it ASSERTS on an unconfigured instance and even live it tracks
  a network Reset event + re-fetches the AdServices token — wiring it is a
  live-key §8 decision for E7.3+.
- **R25.3 — variant value-domain {teaser, hard}.** test-suite §4.4's exact
  domain; the bundled/dormant/removed fallback reports `"hard"` — a
  first-class assignment value, NEVER a third "bundled" sentinel (refines
  R24.4; A/B denominators stay pristine; QA's sentinel lean rejected).
  `price_test` fallback = 29_99. The live keypath is
  `PaywallInfo.experiment?.variant.id` ONLY (docs-verified; never
  experiment.id, never paywallId), mapped through the operator-owned
  `SuperwallPlacement.variantMapping` (EMPTY until the dashboard exists;
  unmapped ⇒ .hard — the unknown-SKU grace shape). MVP §5's "(Superwall id)"
  literal reading deviates → operator ratification item.
- **R25.4 — `PaywallSource.teaserExpiry` ("teaser_expiry") ADDED.** PM veto
  of the defer: two canonical docs name it (the plan test verbatim +
  test-suite sc.36); the teaser A/B is un-analyzable without the
  second-impression split; the S16 age_gate_blocked re-spec rationale
  INVERTS on all three limbs (it IS a test-suite scenario, honestly
  fireable, privacy-neutral); Superwall supplies NO source vocabulary so no
  SDK contract is touched (docs-verifier). mvp.md UNTOUCHED — the §5
  source-row addition is the operator's §3/§8 ratification (R24.9 shape).
- **R25.5 — paywall_viewed at the presentation seam + the §7 field.**
  `PaywallPresenter.makeFirePaywallViewed` (assign → echo → fire; once per
  presentation via the model's didFire guard — the onSummaryAppear
  precedent; NEVER in View.body); BOTH mount paths (live gate + the DEBUG
  UITEST_PAYWALL render) route through it, so the smoke's event chain is
  true for release builds. `AppSettings.paywallVariantAssigned: String=""`
  §7-APPROVED (the onboardingVariant twin); written ONLY on a live Superwall
  assignment — dormant/bundled paths never write (pinned both ways); the
  AgeGateTests exact-set pin EXPANDED same-commit (never softened to ⊇);
  CloudKit-mirror reinstall edge ACCEPTED + flagged vetoable (echo is
  attribution-only; Superwall's server owns stickiness).
- **R25.6 — purchase = user-initiated PAID completion only.** A defaulted
  `onPurchaseCompleted` closure on PaywallModel (M24a–e byte-untouched),
  invoked ONLY from `purchaseSelectedPlan()`'s adopt; the conformer fires
  ONLY on `.active` (paid). `.trial` completions fire NOTHING (trial_started
  rides the S24 provider edge — the mutual exclusion protects MVP §4's ≥8%
  "trial OR purchase" denominator; without this fire every MONTHLY
  conversion was funnel-invisible — the concrete gap closed). Never on
  restore/cancel/failed/restoredEmpty; NO dedupe marker (structurally
  at-most-once; a marker would suppress honest re-subscribes). Product =
  wireProductID {ballast.monthly, ballast.annual} (both annual arms →
  ballast.annual; the price arm rides price_test).
- **R25.7 — teaser semantics.** 24h WALL-CLOCK DURATION (now+86_400s) —
  deliberately NOT ADR-11 calendar anchoring (that rule is scoped to
  displayed Day-N; noon-anchoring a 23:00 teaser would expire it in an
  hour). Pure `TeaserPolicy` + `PaywallRouting.reentryDestination`
  (entitled WINS first ⇒ unexpired grants dashboard ⇒ expired re-presents
  with source .teaserExpiry; nil teaser never re-presents). Repository
  `enterTeaser()` stamps via the injected clock; erase step-1 row sweep
  wipes grant + echo (born-green strengthen pin); no explicit clear on
  purchase (entitled-wins ordering). Re-present surface = the post-gate
  root's dashboard branch on task/foreground, LIVE-model builds only —
  E9's real dashboard INHERITS the rule (binding-on-future-surfaces).
  **SINGLE-USE escape** (Brand veto): the re-present renders the HARD form
  + the expiry eyebrow, no escape — "Then this screen returns." must stay
  true. The grant stamp is consent-INDEPENDENT (the gate swallows events,
  never product behavior). §10 hard boundary: teaser state lives ONLY in
  AppSettings — never in any pre-unlock artifact; the panic route never
  reads it.
- **R25.8 — copy: exactly THREE new non-optional fields.**
  `teaserEscapeLabel` / `teaserEscapeNote` / `teaserExpiryEyebrow`
  (DRAFT/founder-owned; PM+Brand+QA joint sign-off in-panel;
  empirically lexicon-CLEAN both lexicons; founder alternatives recorded:
  escape-label alt "See it for a day first", eyebrow alt "Your free day
  wrapped up. Your streak's still going." — the latter only if a quit is
  guaranteed by expiry). NON-OPTIONAL by reproduction: a nil String? child
  DODGES the Mirror lexicon walk (Brand's mirror-probe). Escape = a §6.2
  QuietButton below the CTA, teaser arm only; hard stays close-free (R24.9
  carried); NO countdown/urgency surface anywhere (hard veto — expiry is
  SILENT); the disclosures render on BOTH variants (escape is additive).
  Copy data (struct + JSON + degraded + pass-through) landed in the RED
  commit as inert data so S24's M22a/M22b never flipped as unpredicted reds.
- **R25.9 — scenario-29 re-landed GREEN with a NON-FATAL wheel.** The
  arbitration of QA (full drive + diagnostics) vs the burn-critic's veto
  (zero wheel-drive precedent; the S18 diagnostics are post-mortem-only):
  the wheel leg runs FIRST with the full S18-owed diagnostics
  (`wheel.value` post-adjust verification + ONE re-adjust retry, bounded
  sleep-free isEnabled wait, stage-boundary screenshots .deleteOnSuccess)
  but is NON-FATAL — on failure the test relaunches with
  `UITEST_SEED_AGE_VERIFIED=1` (a NEW DEBUG-only store-truth seed; the
  gate's un-bypassability stays unit-pinned) and an attachment records the
  path. BLOCKING legs: quiz drive (MUST tap `quiz.choice.optIn` at slot 3 —
  the E8.2 consent step the S18 file predated; QA's load-bearing catch —
  the old drive would HANG there) → summary-before-any-paywall → CTA →
  paywall MOUNT under UITEST_PAYWALL=1 (Tail-B). **The event-spy tail
  (§1.4's "eachStepFiresEvent") is DEFERRED BY NAME** with the recorded
  design (a consent-honest DebugEventSpySink decorator inside the
  AnalyticsService composition + an a11y read bridge — Architect P6) to the
  named StoreKit-config/contract session: unproven XCUITest read-path tech
  on a 2+1 budget; every fire + order is unit-pinned this session. Valve v2
  pre-worded in the file header (fires without a re-vote). `UITEST_PAYWALL`
  gained the `teaser` value — the operator's both-variant eyeball path.
  Scenario-30's purchase leg stays contract-tier (xcodebuild never engages
  a scheme StoreKit config — S24 ground truth).
- **R25.10 — SuperwallKit `.exact("4.16.1")`, app target ONLY, GREEN
  commit.** 4.16.1 IS the Xcode-26.4 build fix (CHANGELOG) — pinning back
  to 4.15.3 "for stability" would reintroduce the exact break on macos-26
  (docs-verifier; the churn-folklore kill). Pin graph reproduced
  conflict-free locally (our four exact pins win; Superwall's only
  transitive = superscript-ios-next 1.0.14 → the checksummed
  `libcel.xcframework` ~95MB Apple-only binary — first post-dep CI run eats
  a cold SPM download; recorded). NOT linked to UnhookedTests (no
  SDK-value contract test — the seam pins ride the house fake) and NEVER
  the widget extension. The importer-lint's outright Superwall ban became
  the sole-importer allow-list (SuperwallVariantAssigner.swift) + a
  never-dual-import guard (RC+SW share StoreKit-shaped names —
  StoreProduct/CustomerInfo/SubscriptionPeriod — FORM-A ambiguity,
  reproduced).
- **R25.11 — one placement.** `SuperwallPlacement.postSummary =
  "quiz_completed"` (its own symbol — never reuse
  AnalyticsEventKind.quizCompleted; different namespace); winback is
  E7.3's. + `priceTest(forProductIDs:)` — the honest live price-arm signal
  (only the B-arm paywall carries annual.hi).
- **R25.12 — panic purity extension.** The init-order spy additionally pins
  `paywallAssigner == nil` on the panic route (additive).
- **R25.13 — red/green split.** Red = inert data + inert seams +
  designed-reds, Superwall-FREE (rule #9); green = behaviors + SDK dep +
  lint + smoke. As run.
- **R25.14 — operator asks.** §3: the 3 teaser DRAFT strings + the
  remote-B-arm 3.1.1 checklist rider + the hard-wall review-build rider
  (carried). §8 NEW: the Superwall key wake-switch + dashboard config
  (placement, two paywalls, price experiment, the variant-id→{teaser,hard}
  mapping) + privacy recording (SW PrivacyInfo: PurchaseHistory
  not-linked/not-tracking + FileTimestamp C617.1; the libcel binary
  surface). MVP §5 ratifications: source gains "teaser_expiry"; variant =
  semantic {teaser,hard} labels.

### What the critics caught / reproduced (the practice keeps earning its keep)

- **Probe-3b caught a WOULD-BE BURNED RUN pre-push (green):** the
  as-committed adapter FAILED strict concurrency — `[Assignment]` is
  non-Sendable and `confirmAllAssignments()` is nonisolated async, so its
  result cannot hop into the @MainActor conformance (`error: non-sendable
  result type '[Assignment]' cannot be sent from nonisolated context`) —
  the S24 run-3 class, caught on the FREE box this time (the standing 3b
  gate did exactly what it was created to do). Fix:
  `@preconcurrency import SuperwallKit`, Linux-verified exit 0 both forms.
- **The lint-vacuity second-order catch (lead):** `@preconcurrency import`
  no longer matches `^import Superwall` — the sole-importer gate would have
  gone silently VACUOUS. The regex now admits attribute-prefixed imports
  (`^(@[A-Za-z_]+ )*import …`) — a new standing lint shape.
- **Green-critic F1:** the seeded-gate fallback wrote store truth with no
  observable re-render trigger (the container would idle on the spinner) —
  fixed with a @State token flip. Every smoke a11y id grep-verified; the
  11-visible-step count recounted from the shipping config (consent choices
  are optIn/**decline** — not optOut).
- The docs-verifier's folklore kills:
  `SuperwallOptions.automaticDeviceIdentifierCollection` NONEXISTENT (the
  briefing's assumed analog; real knob = eventTrackingBehavior);
  "Superwall supplies the paywall source" FALSE (100% app-side);
  "the fallback can report a Superwall variant id" IMPOSSIBLE dormant;
  "reset() is a clean local wipe" FALSE (network event + AdServices
  re-fetch + asserts unconfigured); "configure can warm caches keylessly"
  FALSE. `handleSuperwallPlacement` is DEPRECATED (renamed
  handleSuperwallEvent) — the register API says `placement:`, the delegate
  hook says Event, mixed by design. Graveyard `@objc` register overloads
  identified as the deprecation trap.
- The burn-critic's reproductions: the full pin graph (exit 0, four exact
  pins win); the Linux import failure; FORM-A/B/C collision probes (bare
  `Product`/`PeriodType` ambiguous in dual-import files; `PaywallKit.<T>`
  hits the version-marker enum; typealias = the only fix); the
  `@MainActor SuperwallDelegate` conformance is NOT a burn (witness
  isolation — folklore killed); the importer-lint allow-list + planted
  violations; the project.yml entry shape.

### Run accounting (§4-honest)

- **Run 1 — `29204803764` (`5ce52f0`): the red-evidence run.** App unit
  lane: 16 designed failures / 22 issues — manifest-matched name-for-name
  and issue-for-issue (the 11th consecutive predicted red); all free lanes
  + snapshot + UI smoke green.
- **Run 2 — `29205964725` (`acd2783`): the 16-flip verification + the
  scenario-29 VALVE run.** All 16 reds flipped green, snapshot lane green,
  every free lane green, SuperwallKit 4.16.1 resolved (cold ~95MB libcel
  download) — and the NEW smoke failed its single-run budget, firing the
  pre-worded valve. **The diagnostics PAID FOR THEMSELVES: the S18 "adjust
  didn't take" hypothesis is now DISPROVEN with evidence** — the wheel was
  VERIFIED at 1990 (no re-adjust needed), `ageGate.continue` existed +
  passed the bounded isEnabled wait + the tap synthesized cleanly, and
  `quiz.flow` still never appeared in 10s; the seeded-fallback leg ALSO
  failed, stalled with a ZERO-BUTTON accessibility tree (the pre-onward
  spinner shape). Gate→quiz on CI is now 0-for-2 across S18+S25 with two
  DIFFERENT mechanisms — this smells DETERMINISTIC-on-CI, not a wheel
  flake, and needs the failed run's `test-outputs` artifact (the
  stage-boundary screenshots + gate-handoff-timed-out attachments survive
  BECAUSE the run failed) plus a dedicated diagnosis session. Valve invoked
  exactly as pre-worded: the smoke file removed in the contingency commit;
  the app-side hooks (`UITEST_SEED_AGE_VERIFIED`, `UITEST_PAYWALL=teaser`)
  STAY inert as the next attempt's tooling; every DoD obligation remains
  unit-pinned.
- **Run 3 — `29206650207` (`e281621`): the contingency/green run.** The
  valve commit — smoke removed, nothing else changed — ALL 9 JOBS green
  incl. TestFlight upload.
  Total: **3 = the 2 planned + the contingency, ZERO burned** (the valve
  run is spent, not burned — it verified all 16 flips AND produced the
  evidence that retires the wheel hypothesis; the S18/R24.1 accounting
  shape).

### Known limitations / carried (E7.3 inherits a named list)

- **Scenario-29 itself — VALVE-DEFERRED with hard evidence.** The wheel
  hypothesis is retired (verified-1990 + enabled + tapped, still no
  hand-off); gate→quiz on CI is 0-for-2 across S18+S25 by two different
  mechanisms (the seeded leg stalled pre-onward, zero-button tree). The
  deferral session diagnoses from run `29205964725`'s `test-outputs`
  artifact (screenshots survive on failure) — candidate suspects for it:
  the gate-pass → PostGateRootView mount seam under the UITest env, the
  store-truth re-read timing, the a11y-tree shape post-transition. The
  app-side hooks (`UITEST_SEED_AGE_VERIFIED`, `UITEST_PAYWALL=1|teaser`)
  are LANDED and inert, ready for the re-land.
- **The event-spy sink (scenario-29's Tail-A / §1.4 "eachStepFiresEvent")**
  — deferred BY NAME with the recorded decorator design (R25.9); lands with
  the named StoreKit-config/contract session.
- **`Superwall.reset()` in the erase order** — deliberately NOT wired
  (asserts unconfigured; phones home live). A live-key erase design item,
  E7.3+ with §8 pre-approval (R25.2).
- The live Superwall presentation path (register-driven remote paywalls,
  the PaywallPresentationHandler callbacks, the >3s timeout fallback of
  test-suite §4.4) lands with the live-key/contract session — this session
  ships the assignment seam + the dormant adapter; the timeout wrapper is a
  composition design note (Architect P10).
- The B-arm ($39.99) renders only in the operator's remote Superwall
  paywall — no display constant exists in code BY RULING (PM P5); its
  3.1.1 review is an operator §3 rider.
- Variant goldens still ride the post-founder-copy batch (S17 R5 → R24.1 →
  unchanged); the teaser variant's render proofs are the composed-data pins
  + `UITEST_PAYWALL=teaser`.
- `paywallVariantAssigned` CloudKit-mirrors; a same-iCloud reinstall can
  restore a pre-erase echo while Superwall re-assigns (accepted,
  attribution-only; operator-vetoable — R25.5).
- Reinstall/erase re-grants the teaser (AppSettings wiped ⇒ a re-onboarded
  user can take a fresh teaser day) — fresh-install semantics, accepted.

## Session 26 — E7.3: win-back offer (config) — Epic 7's build half CLOSED (2026-07-12)

**Objective (resume prompt v3.8):** E7.3 — 50%-off annual win-back 7 days post trial-lapse
via RevenueCat offer, no push dependency; the three plan-named tests VERBATIM; step-0 rulings
(a)–(f). Budget: 2 billed runs + 1 contingency.
**Outcome: DONE in 2 billed runs, ZERO burned, contingency unused.** Red evidence = CI run
`29209285506` on `b146774`: 11 designed-failing / 13 issues, manifest-matched NAME-FOR-NAME —
the 12th consecutive harness-predicted red (the pure 10-test/11-issue subset verified on the
FREE Linux harness first, TZ-invariant under UTC/Berlin/Kiritimati ×3 full runs, built under
-strict-concurrency=complete -warnings-as-errors). Green = `2ba3a35` — all 11 flips verified
in run `29209801255` (ALL-9-JOBS green + TestFlight).
**Session-open operator check: NOTHING required** (operator-expected's own header pre-cleared
Session 26; recorded at open, held open-to-close). **The operator's session-open bug report
(lock-screen day counter) was TRIAGED, not coded:** the 2-days-ago binary (07-10, `7905db0`
E3.3-era) predates E6.2's real widget — its SkeletonWidget renders a HARDCODED static "Day 0"
by design, and the S21 kind retirement means the placed widget must be RE-ADDED once on the
newest build (documented S21 R12). Operator steps + the escalation path recorded in §7. No
code change warranted; zero billed runs spent on it. Delivery 28/32 = 87.5%.

### The step-0 panel (6 seats + lead arbitration → rulings R26.1–R26.15)

Panel: Architect, PM, QA, Brand, adversarial burn-risk critic (REPRODUCE-not-reason),
docs-verifier. Full findings in the session scratchpad (RULINGS-R26.md + SEAT-*.md); the rulings:

- **R26.1 — the lapse clock is an APP-SIDE observed-lapse stamp.** The docs-verifier KILLED
  the server-side primary with primary sources: Apple win-back offers are months-granular
  (ASC "Time Since Last Subscribed" minimum = 1 MONTH) AND require prior PAID duration — a
  7-day TRIAL-lapse cohort fails both; RC Targeting has no subscription/lapse-cohort condition
  (custom attrs/country/app/version/platform only); and QA independently showed a pure
  server-side oracle is incompatible with the plan's failing-unit-test-first mandate. NEW
  `AppSettings.lapseObservedAt: Date?` (§7-approved in-panel): ONE writer
  `recordLapseObserved()` (nil→set only, injected clock), fed by the live branch's
  refresh-adoption edge (dormant-safe by construction); CloudKit-mirrors (reinstall edge
  flagged vetoable, R25.5 shape); erase-swept; AgeGateTests exact-set expanded SAME-COMMIT;
  §10-excluded. Observed-lapse is fail-SAFE (late-only).
- **R26.2 — the offer MECHANISM is an ASC promotional offer, NOT an Apple win-back offer.**
  Pay-up-front, 1 year, $14.99 on the SAME `ballast.annual` SKU, id `winback_annual`,
  RC-signed (the operator uploads the In-App Purchase Key to RC — NEW §8 item). purchases-ios
  5.80.3 exact spellings recorded (eligibleWinBackOffers is iOS 18+ AND months-gated — rejected;
  promotionalOffer(forProductDiscount:product:) → purchase(package:promotionalOffer:) is the
  live path). The LIVE signed-purchase call is DEFERRED BY NAME to the StoreKit-config/contract
  session. WinBackOffer/PromotionalOffer are Sendable at 5.80.3 — no @preconcurrency needed.
- **R26.3 — 7-day window = wall-clock DURATION (604,800s), INCLUSIVE boundary.** ADR-11 is
  scoped to displayed Day-N; the teaser R25.7 duration reasoning applies; TZ-invariant by
  construction, ×3-zone-proven.
- **R26.4 — ANY `.lapsed` tier is eligible (vetoable).** The machine deliberately has no
  trial-vs-paid history (S23), so "post trial-lapse" is honestly implementable only as "post
  lapse"; lapsed-monthly meets the annual offer as an upsell. Restricting to .annual is a
  one-line operator veto.
- **R26.5 — v1 win-back is IN-APP ONLY; the notification is a NAMED future add.** The plan's
  acceptance wins the C1 conflict: a landed test-suite §7 static check asserts NO
  UNUserNotificationCenter authorization request in the v1.0 target (verified zero on disk);
  plan + test-suite (3 places) already read mvp §6 as "no push permission". mvp.md UNTOUCHED;
  the §6 "local notification" deviation rides the R24.9 ratification shape (§3). Honest cost
  recorded: eligible→shown is NOT measurable in-app-only — the operator's data argument for
  the future notification session.
- **R26.6 — surfaces: reentry auto-present (once per process, DISMISSIBLE) + settings row.**
  Precedence entitled > winback (lapsed-only) > teaser-expiry via a defaulted
  `winbackEligible` param on the pure `reentryDestination` (E7.2 call sites byte-compatible);
  the shim renamed `teaserReentry` → `paywallReentry`. THE TRAP CATCH: a lapsed user reaches
  the dashboard today, so an unclosable re-present would TRAP them (Epic 7 DoD) — the winback
  presentation is an OFFER with a "Not now" dismiss (no event fires — dismissal is not funnel
  vocabulary); the hard onboarding wall and the teaser re-present stay close-free (R24.9
  untouched). Auto-present cadence = once per process, in-memory (vetoable); the settings row
  (visible only when eligible, view-gated) is the persistent path back.
- **R26.7 — the fire-set.** SHOWN: `winback_shown(offer)` then `paywall_viewed(source:
  .winback)` co-fire once per presentation (the model's didFire guard) — intentional
  dual-funnel, honest only under strict source segmentation (recorded). CONVERTED:
  `winback_converted(offer)` then `purchase(ballast.annual, annual)` — BOTH (different
  funnels; no dedupe); NEVER trial_started (the .active guard keeps R25.6's exclusion for
  free). Order pinned: surface-scoped → universal.
- **R26.8 — value-domains.** offer = {`winback_annual`} closed single-member (S15); the landed
  `winback_50` fixture drift REALIGNED same-commit (keys-only whitelist = free); `…2499` forms
  rejected (no-price-in-id, R24.5) — test-suite §3.2 sc.26 renamed at close.
  `ProductCatalog.winbackOfferID` + `annualWinbackDisplayPrice ("$14.99")`;
  `SuperwallPlacement.winback = "winback"` (own constant, namespace discipline).
- **R26.9 — copy: exactly FIVE new non-optional fields (DRAFT/founder-owned, §3).**
  PaywallCopy: winbackOfferLine / winbackMechanicsLineFmt (TWO %@ slots — discounted AND
  renewal price, 3.1.2(c)-grade) / winbackReassurance / winbackDismissLabel;
  DiscreetSettingsCopy: winbackRowLabel. Lexicon-verified CLEAN (dual lexicon, actually run);
  "Reactivate"/"Come back" REJECTED (fact-wrong for trial-lapse + we-miss-you register);
  the REAL discount makes "half price" §6.8-honest; floors bumped 20→27 and 8→9. The OPTIONAL
  is the composition (`PaywallViewData.winbackOffer`, nil unless source == .winback); the
  teaser escape never co-composes with winback (fork isolation, pinned).
- **R26.10 — dormancy pinned two ways.** Pure negative (nil stamp / false eligibility can
  never surface .winback) + composition (the lapse edge lives ONLY on the live RC-key branch;
  EntitlementModel is constructed only there). No keys ⇒ no winback events, ever.
- **R26.11 — PaywallKit UNTOUCHED; panic route untouched; no §10 change.** No new
  RepositoryProvider surface ⇒ the panic init-order spy needed NO edit.
- **R26.12 — burn-gate follow-through.** The pure-policy path reproduced burn-free (probe
  exit 0 under strict flags); the RC importer-lint anchor upgraded to the attr-prefix form
  (the #3d latent gap the burn-critic REPRODUCED — a bare `^import` anchor was vacuous on
  `@preconcurrency import RevenueCat`; planted-violation-tested) — rides the green commit.
- **R26.13 — red/green split (R25.13 shape), as run.**
- **R26.14 — deferred BY NAME:** the live promotional-offer application (fetch + signed
  purchase, spellings recorded); the sandbox win-back matrix (§4.2/sc.26/§6-row-9 — operator
  tier, Epic 7 DoD's operator half); winback goldens (post-founder-copy batch); the
  local-notification channel (own permission-surface session, operator-vetoable).
- **R26.15 — operator asks:** §3 (5 DRAFT strings + the mvp §6 ratification + the any-lapse
  flag + the 3.1.1 winback disclosure rider); §8 (ASC promotional offer + In-App Purchase Key
  upload to RC); §7 (the lock-screen day-counter row).

### Epic 7 DoD check at close (honest split)
BUILD-TIER (done): PaywallKit seam + machine (S23); RC adapter + paywall + catalog (S24);
Superwall variant brain (S25); win-back eligibility/surfacing/fires (S26). Superwall isolated
behind the seam ✓; paywall never traps ✓ (winback dismiss + retry/restore pins).
OPERATOR-TIER (carried, sequenced in §8): the sandbox purchase matrix incl. win-back
time-travel (needs RC+SW keys, ASC products, the promotional offer + IAP key); the 3.1.1
checklist signature (§3, incl. the winback disclosure row + the remote-B-arm rider).
Epic 7 is BUILD-COMPLETE; its DoD closes at the operator's sandbox pass.

### Run accounting (§4-honest)
- Run 1 — `29209285506` (`b146774`): red evidence. App unit lane: 11 designed failures /
  13 issues — manifest-matched name-for-name (the 12th consecutive predicted red); all other
  lanes green.
- Run 2 — `29209801255` (`2ba3a35`): all 11 flips verified green; ALL-9-JOBS green +
  TestFlight upload.
Total: exactly the 2 planned, ZERO burned, contingency UNUSED.

### Known limitations / carried
- The live promotional-offer purchase call (R26.14) — the winback CTA currently rides the
  standard purchase path; applying the SIGNED discount is the StoreKit-config/contract
  session's, unexercisable dormant (no keys ⇒ unreachable; recorded, not a gap).
- The lapse edge fires at the LAUNCH refresh only (the one wired refresh site) — a
  foreground-refresh lapse observation lands whenever the foreground refresh itself does
  (the E7.2-inherited pull-based cadence).
- Scenario-29 diagnosis + event-spy sink + goldens: unchanged carries (S25).
- Winback auto-present cadence (once per process) + any-lapse eligibility + the CloudKit
  lapse-stamp mirror: operator-vetoable (R26.4/R26.6/R26.1).

## Session 27 — E9.1 safety layer + E9.2 content audit (2026-07-13)

**Objective (resume prompt v3.9):** E9.1 — resources screen + region-aware helplines +
alcohol withdrawal notice, one tap from Settings and every slip flow (+E9.2 content-table
audit, batchable at step-0's discretion); step-0 rulings (a)–(f) with the safety-content
gate as the core. Budget: 2 billed runs + 1 contingency.
**Outcome: BOTH DONE in exactly 2 billed runs, ZERO burned, contingency UNUSED.** Red
evidence = CI run `29245297054` on `bef2f80`: 4 designed-failing unit tests / EXACTLY 8
issues, manifest-matched NAME-FOR-NAME with each failure's predicted reason verbatim —
the 13th consecutive harness-predicted red — PLUS the 2 designed logged-stage golden
shifts / 6 image issues, inside the pre-worded 4–8 fold-variance valve (the AX5 axes of
`bestAndMomentum` clipped the new link below the fold and passed; all 4 axes of
`degradedNoBest` diffed). 354 tests / 53 suites otherwise green — the E9.2 gates landed
born-green exactly as scratch-predicted, zero collateral. Green = `cf75ba6`, run
`29246823045` ALL-9-JOBS green + TestFlight. Delivery 30/32 = 93.75%.
**Session-open operator check (the standing user ask): NOTHING was required** — three-way
confirmed at open: operator-expected's own header pre-cleared Session 27 ("the one gate
that session owns is the PM+Brand+QA safety-content sign-off, which is agent-panel work,
not yours"); git clean and local == origin at `4ebf1ff` (no operator commits); the E4.2/
E5.1/E8.2 precedent line confirms the rule-#8 joint sign-off is executed IN-PANEL with
strings shipping DRAFT/founder-owned into the operator's §3 queue. Recorded at open, held
open-to-close.

### The step-0 panel (6 seats + lead arbitration → rulings R27.1–R27.14)

Panel: PM, Architect, QA, Brand, adversarial burn-risk critic (REPRODUCE-not-reason),
docs-verifier — 6 parallel workflow seats Writing findings to scratchpad files (the S14
retry-cap lesson held: one-line pointers back, zero deaths). Full seat findings in the
session scratchpad (SEAT-*.md + RULINGS-R27.md); the rulings:

- **R27.1 — the safety-content gate was satisfied IN-PANEL; no operator action.** Signed
  AS-IS: the alcoholWithdrawalNotice 4 strings + the resourcesScreen 4 (re-read
  post-gate). SIGN-WITH-CHANGES: `notMedicalCareDisclaimer` "treatment"→"care" (the
  substring matcher can't tell an honest negation from a claim; the reword keeps the
  whole authored table walk-clean — Brand, burn-reproduced). NEW DRAFT: "Support &
  resources" (ONE canonical label, byte-identical at both entry points). All → §3;
  clinician+counsel stays the pre-SHIP operator gate.
- **R27.2 — SIBLING surface + SIBLING pure selection; E5.1 byte-frozen.** New
  `SafetyResourcesView` (store-free BY CONSTRUCTION — bundled JSON + injected analytics
  only, which is what lets the cold slip route mount it) + pure
  `SafetyResourcesSelection`. The verified-only filter REIMPLEMENTED, never promoted —
  AgeGateResources/AgeGateBlockedView untouched, every S16 pin held with zero collateral.
- **R27.3 — the fire canon.** `resources_viewed(source)` — case + closed
  `ResourcesSource {settings, slip_flow}` already existed (E8.1); NO enum change, NO mvp
  §5 edit. Fire = the `onSummaryAppear` precedent: model-held didFire guard, once per
  PRESENTATION (a genuine reopen is a genuine second view — deliberately NOT the winback
  once-per-process guard); source injected by the mount; consent-gated by construction.
  The S16 reconciliation is STRUCTURAL: the age-gate surface has no analytics seam at
  all; its zero-fire pin is untouched and an inverse-guard assertion documents the split.
- **R27.4 — the notice's "See resources" opens the screen and fires NOTHING (vetoable,
  unanimous).** nil source → skipped fire; the event's scope is documented as
  {settings, slip_flow}-only so nobody misreads an undercount. Veto path = an
  `alcohol_notice` source value, which is an mvp §5 ratification FIRST (R24.9 shape).
- **R27.5 — `AppSettings.alcoholNoticeShownAt: Date?` (§7-approved in-panel, R26.1
  shape).** The lapseObservedAt twin verbatim: nil=never; ONE writer
  `recordAlcoholNoticeShown()` (nil→set, injected clock, in the sole SwiftData
  importer); fetch-only reader. LANDED GREEN (QA: the plan-named red test pins the PURE
  policy, so no red bytes referenced the field and the AgeGateTests exact-set edit
  (8→9) rode the same green commit — rule #6 satisfied with zero unpredicted red).
  Erase = row sweep (born-green) + the WinbackLapseStampTests-shape strengthen pins.
- **R27.6 — the notice mounts on the DASHBOARD (RootPlaceholderView), once EVER
  app-wide, both goal modes.** Architect over PM's summary-primary: both creation paths
  converge at the dashboard; PostGateRootView/paywall seam untouched ⇒ no CTA collision
  structurally. Presented as an INLINE amber card (Brand-signed; zero sheet contention
  with the panic mounts), "Got it" ≥ prominence, stamp at display, once-per-process
  @State latch. HONEST LIMITATION (recorded, vetoable): in the live-keys era a
  hard-walled non-converter never reaches the dashboard and so never meets the notice;
  today (dormant) everyone does. PM's summary mount is the recorded veto alternative.
- **R27.7 — GLOBAL fallback: number-FREE, sibling-only.** The docs-verifier's hard
  constraint decided the shape: `phoneDisplay`/`dialString` are required non-optional,
  and ONE bad row nils the ENTIRE directory through `try?` — so a URL-only "Find a
  Helpline" row CANNOT exist. GLOBAL = displayName + calm emergencyNote (local-emergency
  line + the verified findahelpline.com pointer — ThroughLine, 175+ countries,
  live-checked) + `resources: []`. E9.1 resolution: `regions[device] ?? regions["GLOBAL"]`;
  the E5.1 age-gate keeps unmapped→US (a verified 988 floor for a blocked minor beats an
  empty bucket). Region PICKER: OUT (vetoable); `regionPickerLabel` stays shipped-unconsumed.
- **R27.8 — all verified rows for the region, crisis-first, NO active-quit filtering**
  (safety = availability; hiding the alcohol line from a vape-quit user is a safety
  anti-pattern). The ordering nicety was CUT per PM's own fence.
- **R27.9 — NO new SF Symbol.** `info.circle` is docs-UNCONFIRMED on this box (rule #5 ⇒
  nonexistent); the notice card, rows, links and header all reuse the S16-blessed
  `lifepreserver`/`phone.fill`. (Docs-verifier also caught: `staryoflife` is a TYPO —
  the real name is `staroflife`; `cross.case` unconfirmed → banned.)
- **R27.10 — the SECOND R22.7 amendment:** DiscreetSettingsView gains the UNCONDITIONAL
  resources row (host-callback `onResourcesRowTap`, the R26.6 shape; "one tap from
  Settings" is an MVP §7 release-gate row, so this is compliance, not scope creep).
  Never entitlement-gated (docs-verifier: the safety layer is RC/Superwall-symbol-free).
  `DiscreetSettingsCopy.resourcesRowLabel` non-optional; floor 9→10. The leak lexicon
  bans "Quitline"-class labels here — "Support & resources" verified clean empirically.
- **R27.11 — slip-flow entry: an INTERNAL sheet in SlipFlowView, link on the logged
  stage** directly after the fact statement (Brand: never on the confirm prompt — support
  offered while confirming could read as judgment). Identifier `slip.resources.link`.
  The cold route mounts it unchanged (store-free screen); its analytics seam is
  route-honest: the store route vends the repository's live gate, the COLD route passes
  `.disabled` — the panic-descended surface constructs no analytics (recorded refinement;
  a cold-route resources open is intentionally unmeasured).
- **R27.12 — THE GOLDEN-RIDES-RED MANEUVER (new house technique).** The lead
  empirically arbitrated a seat contradiction (QA claimed zero golden risk; the
  Architect claimed a shift; the goldens render the SHIPPING slipCopy.json — Architect
  right), then landed the link + copy section IN THE RED COMMIT so the 6 failed axes'
  own rendered actuals became the green references: extracted ON LINUX from
  snapshot.xcresult (zstd graph objects → failure.png payloadRefs → chronological
  mapping to the CI log's issue order → hash-verified against the old references →
  visually confirmed), committed with green. Logged-stage pixels are red/green identical
  by construction. ZERO re-record run spent; the budget stayed 2.
- **R27.13 — E9.2 BATCHED IN as born-green permanent gates** (QA+burncritic+Architect
  over PM's default-out; PM's fence honored: no production Milestones model — the tests
  read the shipping JSON). The medical-claim lexicon is PHRASE-ANCHORED — the burn
  critic REPRODUCED that a naive bare token ("breathing") false-fires on the shipping
  vape table; in-test positive/negative matcher pins + the foundation floor + the ≥40
  corpus floor + the 43/43 "commonly reported" framing sub-pin keep the gate
  non-vacuous. Epic 9 DoD's "banned-lexicon tests permanent in CI" row: CLOSED.
- **R27.14 — red/green split as run** (4 unit reds / 8 issues + 2 golden tests / 6
  image issues; field + exact-set edit + stamp pins + copy reword + goldens all green).

### Run accounting (§4-honest)
- Run 1 — `29245297054` (`bef2f80`): red evidence. Unit lane: 4 designed failures / 8
  issues name-for-name; snapshot lane: the 2 designed golden tests / 6 image issues
  (valve range 4–8); all other lanes green.
- Run 2 — `29246823045` (`cf75ba6`): all flips verified; ALL-9-JOBS green + TestFlight.
Total: exactly the 2 planned, ZERO burned, contingency UNUSED.

### Process notes (ultracode session)
- The 6-seat panel ran as ONE parallel workflow (~614k tokens, 6/6 seats returned
  one-line pointers to scratchpad files — zero StructuredOutput deaths). Two context
  errors were caught INSIDE the loop: QA corrected the lead's CONTEXT.md floor claim
  (9, not 27) and the lead empirically overturned QA's no-golden-risk claim — the
  cross-check pattern (seats verify context; lead verifies seat contradictions with
  probes) is what kept the manifest exact.
- The burn critic's probe ledger (8 probes, all RUN): the non-optional-section decode
  burn (A2 THROWS — takes E5.1's resourcesScreen down with it) and the Mirror
  nil-child dodge (corpus 10→5) directly shaped R27.1's #require discipline and the
  optional-section shapes; the planted importer-grep test confirmed the SwiftData lint
  fires on a non-Persistence importer (the stamp writer went into QuitRepository).
- Harness discipline: red-mode 31/31 checks ×3 TZ (UTC/Berlin/Kiritimati) under
  -strict-concurrency=complete -warnings-as-errors over the exact shipping bytes BEFORE
  the red push (a real bug caught: the schema pin initially missed helplines.json's
  top-level `regions` nesting); green-mode ALL-PASS ×3 TZ before the green push.
- xcresult-on-Linux extraction is now a recorded technique (no xcresulttool needed):
  the Data/ objects are zstd; the activity graph names failure.png payloadRefs with
  timestamps that map to the CI log's issue order; old-reference hash-exclusion +
  visual confirmation close the loop.

### Known limitations / carried
- The live-era notice gap (hard-walled non-converter; R27.6) — vetoable, revisit with
  the paywall-era sessions or the operator's veto to a summary mount.
- The cold-route slip resources open fires nothing (R27.11) — intentional, recorded.
- The region picker stays deferred ("the full resources epic" shipped fallback-only);
  `regionPickerLabel` remains shipped-but-unconsumed. E9.2's HUMAN audit-checklist
  signature = operator §3 (the mechanical half is permanent CI now).
- resources_viewed's scope is {settings, slip_flow} ONLY — the notice + age-gate opens
  are intentionally uninstrumented (S4 documentation note rides §3).
- Scenario-29 diagnosis + event-spy sink + the founder-copy golden batch: unchanged
  carries (S25/S26).

## Session 28 — E9.3: accessibility pass (2026-07-13)

**Objective (resume prompt v4.0):** E9.3 — VoiceOver through quiz/panic/slip;
haptics-only pacer; Dynamic Type max without truncation; plan-named tests
VERBATIM; step-0 rulings (a)–(e). Budget: 2 billed runs + 1 contingency.
**Outcome: DONE in 5 billed runs = the 2 planned + the contingency + 2 over,
1 BURNED** (the S24 honest-accounting shape; every non-burned run produced
designed evidence, and BOTH golden re-record batches were extracted FREE from
CI's own artifacts — R27.12 executed twice). Red evidence = CI `29259860083`
on `46d9ca2`: **unit lane 3 designed-failing / 3 issues NAME-FOR-NAME with
each predicted failure string VERBATIM — the 14th consecutive
harness-predicted red**; 364/55 otherwise green (the born-green panic-script
lexicon gate + decode strengthen passed exactly as scratch-predicted, zero
collateral). The designed golden family (snapshot_breathStep_hapticsOnly)
failed with **2 image issues — BELOW the pre-worded 3–4 valve, by the INVERSE
mechanism**: the AX5 axes diffed (0.98 perceptual floor) while the DEFAULT
axes passed WITHIN the 1%/0.98 tolerance. NEW HOUSE FACT: a small visible
text change may not fire default-size axes at all — calibrate golden-shift
valves on the TOLERANCE FLOOR, not only fold-clipping. Green arc: `4bc8829`
(flips + toggle + labels + audit family) → `b80c33d` (R28.13 contingency) →
`2346cba` (burn repair) → `3b6d692` (golden adoption + the title label) →
run `29267286952` ALL-GREEN + TestFlight. **Session-open operator check (the
standing user ask): NOTHING required — three-way confirmed at open**
(operator-expected's header pre-cleared Session 28; git clean, local ==
origin at `13df12e`; the open rulings were agent-panel work). Recorded at
open, held open-to-close. Delivery 31/32 = 96.9%; **Epic 9's build half
CLOSED.**

### The step-0 panel (6 seats + lead arbitration → rulings R28.1–R28.13)

Panel: PM, Architect, QA, Brand, adversarial burn-risk critic
(REPRODUCE-not-reason), docs-verifier — one parallel workflow (~698k tokens,
6/6 one-line pointers, zero deaths); three further verification workflows
(red-verify, green-build ×4 disjoint implementers, green-verify) — ~2.4M
subagent tokens total. TWO lead cross-seat corrections (the S27 cross-check
pattern): QA's "0 golden shifts" predated Brand's breath-instruction defect
(R27.12 invoked); Brand's "no golden covers the haptics-only frame" was
wrong. The rulings:

- **R28.1 — scope:** the three plan-named deliverables + channel + toggle +
  labels; OUT: scenario-29 (frozen), brandkit §8's "inline offer on first
  pacer run", live per-phase VO announcements, region picker, device test 40.
- **R28.2 — the channel = the pre-cache ENVELOPE.**
  `PanicSnapshot.hapticOnlyBreathPacer: Bool?` — envelope-level (never
  per-card), OPTIONAL mandatory (burn-reproduced keyNotFound on pre-field
  caches), PRESENCE-ONLY stamp (`? true : nil`, the R22.1 minimization
  discipline). ONE writer `setHapticOnlyBreathPacer` (setDiscreetMode shape
  MINUS widget reload, NO analytics) + fetch-only reader; reads ride the
  SINGLE existing pre-frame read (cold UnhookedApp / warm+in-app
  RootPlaceholderView); resolver signatures untouched; panic purity pins
  green. Over the app-group-key alternative: identical §10 exposure, but the
  envelope inherits write/launch-refresh/erase lifecycle for free. PM's
  warm-only VETOED (dishonest to MVP §7 — the cold lock-screen route is
  where eyes-free matters most). **§10 ruling (vetoable): a
  render-necessary, content-free a11y Bool is NOT a banned pre-unlock bit**
  (the `discreet` flag's admissibility class).
- **R28.3 — the toggle = the THIRD R22.7 amendment** (compliance-not-creep
  per R27.10; MVP §7 names the option as a release gate). Header-less
  Section on DiscreetSettingsView; Toggle through the repository (try? +
  re-read token; no analytics). Copy joint-signed IN-PANEL:
  `hapticPacerRowLabel` "Breathe with taps" (+2 alts), `hapticPacerFooter`
  (+2 alts); NEVER accommodation-framed (brandkit §8). Floor 10→12
  same-commit; DRAFT → operator §3.
- **R28.4 — the breath-instruction defect + R27.12.** "Follow the circle."
  is literally false in haptics-only mode and misdirects VO in bloom mode.
  NEW optional `PanicScript.Step.instructionNonVisual` = "Breathe with the
  taps. In for 4, hold for 7, out for 8. Three rounds." (joint-signed —
  panic is a safety path; +2 alts; DRAFT §3). Haptics-only renders it (the
  pixel bytes rode the RED commit per R27.12); bloom mode hears it via a
  defaulted `StepScaffold.instructionAccessibilityLabel` (metadata).
  `hapticOnlyLabel` stands verbatim.
- **R28.5 — the red manifest:** 3 designed reds / 3 issues, unit lane,
  deterministic (the stamp pin, the threading pin, and the plan-named
  `test_hapticsOnlyPacer_runsWithoutVisualDependency` end-to-end with
  view-free rhythm sub-asserts: the full shipping 4-7-8×3 emitted at init
  with `pacerStartedAt == nil`, re-armed from the redirect). Matched
  verbatim as run.
- **R28.6 — the audit family: GREEN commit, per-leg, rule-11 shaped.**
  `test_a11yAudit_{panicFlow,slipFlow,quizFlow}_noViolations` — the plan
  name delivered as a family on scenario 33's ONE slot (the R26.8 rename
  precedent; cap unchanged). Panic/slip = SAFETY legs (never
  quarantined/valved/suppressed); quiz = valve-eligible (pre-worded).
  Audit-issue lists are NOT name-for-name predictable ⇒ audit tests never
  enter a red manifest (their first run IS the finding ledger).
  test-suite.md:91's "XCUIDevice" recorded as docs drift (the API is
  XCUIApplication-only, iOS 17+, no #available at the iOS-26 floor; no
  issue handler — its Bool semantics are docs-unconfirmed).
- **R28.7 — AX5:** streak half ALREADY SHIPPED (widget small/medium + slip +
  panic AX5 axes = test 18's delivery); paywall half DEFERRED BY NAME to the
  founder-copy golden batch (R24.1 extended: each surface incl. its AX5
  axes); the text-metric pin NOT adopted; accessory clamp stands (S21). Net
  new goldens: 0 (the only golden motion was designed).
- **R28.8 — labels/traits, DERIVED/TRAIT only:** the quiz slider speaks its
  WORD ECHO as the a11y value (brandkit §6 "never just a number") with the
  sibling echo hidden; stepper label+value; both text fields labeled from
  on-screen copy; slip undo `.accessibilityHint(windowNote)`; reflection
  field labeled; icon-picker `.isSelected`. Zero new authored strings
  beyond R28.3/R28.4; metadata-only (the raster sees layers, never a11y
  metadata — reproduced from the pinned SnapshotTesting source).
- **R28.9 — the born-green panic-script lexicon gate** closed a REAL
  pre-existing hole (panicScript step strings shipped unscanned):
  reflection walk over all decoded strings vs the shame lexicon (+ leak on
  the discreet-rendered fields), 35-string corpus, floor 30, matcher pins;
  scratch-verified over the shipping bytes FIRST (R27.13 shape); rode red
  born-green, passed.
- **R28.10 — red/green split + budget:** one red push, one green push; as
  run, plus the contingency arc below.
- **R28.11 — no analytics motion** anywhere (no event, no source value; the
  toggle fires nothing; UITEST hooks DEBUG-inert).
- **R28.12 — operator asks:** §3 the 4 DRAFT strings + alternatives + two
  copy niceties; §7 the eyes-free/VoiceOver eyeball row. Vetoables recorded.
- **R28.13 (mid-session, the contingency ruling — vetoable):** the audit's
  first run found REAL violations on all three legs. Fix-now (golden-safe or
  deterministically re-recorded): the forgiveness screen's dangling
  "momentum is still ." (a REAL product defect — `SlipLoggedComposition`:
  a template sentence with an unfilled token drops WHOLE; filled path
  byte-identical, harness-proven over the shipping templates; its 4
  degradedNoBest goldens re-recorded via DELETED-references record-missing —
  deterministic 4/4, adopted from run 4's artifact, eyeballed) + the 4pt
  `quiz.progress` hit-region sliver (44pt floor +
  `accessibilityRespondsToUserInteraction(false)`) + the title's VO label
  drops its typographic period (the classifier's ONE not-human-readable
  node BOTH runs — "Logged."; bare words pass empirically). Defer-BY-NAME
  (grow-only, in-code, artifact-documented): the {.contrast, .dynamicType,
  .textClipped} classes — sub-WCAG teal/secondary contrast + DT-scaling
  clipping across goldened panic/slip surfaces — Brand-palette + layout
  decisions cascading through the golden matrix → the a11y-visual pass
  rides the founder-copy golden-batch session (colors+copy+goldens, ONE
  re-record). The session-rules large-issue branch, applied verbatim.

### The lead's mid-green fix (the S25-stall burn, killed pre-push)

The audit implementer's quiz leg initially rode UITEST_SEED_AGE_VERIFIED —
the exact S25 seeded-leg stall. Fixed by the TWO-LEVEL `UITEST_QUIZ` direct
mount (AgeGateContainerView first-branch → PostGateRootView → QuizFlowView
over the shipping config, `.disabled` analytics): launch→audited-frame is
pure view composition — no repository publish, no gate model, no store
read. The quiz leg's env is `UITEST_QUIZ=1` alone. (This mount is ALSO
Session 29's scenario-29 diagnosis tooling: it proves the quiz RENDERS fine
on CI — the hang lives in the gate-pass → post-gate re-render chain.)

### Run accounting (§4-honest)

- Run 1 — `29259860083` (`46d9ca2`): red evidence. Unit 3/3 name-for-name
  (strings VERBATIM); the designed golden family at 2 issues (below the
  3–4 valve — the tolerance-floor mechanism, recorded); all else green.
- Run 2 — `29262073722` (`4bc8829`): all 3 reds FLIPPED + the 2 AX5
  re-records matched + unit/snapshot green — and the audit family's first
  `.all` execution produced its complete finding ledger (SPENT, not
  burned). TestFlight blocked by design.
- Run 3 — `29264641853` (`b80c33d`): **BURNED — the first since S24.**
  Test-build failure: `.action`/`.parentChild` are macOS-14-ONLY.
  **NEW STANDING GATE #5b:** docs-confirmed EXISTENCE is not platform
  AVAILABILITY — every member of a multi-platform option set gets its own
  docs-JSON `platforms` check before code (the iOS-17 audit set:
  {elementDetection, hitRegion, sufficientElementDescription, trait,
  contrast, dynamicType, textClipped}).
- Run 4 — `29265224603` (`2346cba`): the repaired contingency. Panic + quiz
  audits GREEN on the scoped set; the slip leg isolated its final finding
  (the title label); the 4 deleted degradedNoBest references re-recorded by
  CI (designed 4/4). SPENT, not burned.
- Run 5 — `29267286952` (`3b6d692`): the adopted references + the title's
  VO label — ALL-GREEN + TestFlight.
Total: **5 = 2 planned + 1 contingency + 2 over, 1 burned.**

### Known limitations / carried

- **The R28.13 debt** (the vetoable worth the operator's eye): contrast +
  DT-scaling findings enumerated in run `29262073722`'s artifact; classes
  excluded in-code (grow-only) until the a11y-visual/golden-batch session.
  MVP §7's accessibility checkbox stays honestly UNCHECKED until then.
- The panic entry title truncates at AX5 (pre-existing, golden-pinned,
  copy-adjacent → §3); the degraded slip path shows "Logged." twice
  (title + body echo → §3 nicety); the 2 default-axis hapticsOnly goldens
  are valid-but-stale within tolerance (re-record with the next touch).
- The quiz audit leg's pre-worded valve stands unused (the leg passed once
  the hit-region fix landed).
- brandkit §8's "inline offer on first pacer run" + live per-phase VO
  announcements: deferred by name.
- Scenario-29 diagnosis + event-spy sink + the founder-copy golden batch
  (now bundling the R28.13 visual pass): Session 29 / operator-gated.

## Session 29 — the named StoreKit-config/contract session (2026-07-13)

**Objective (resume-prompt v4.1):** scenario-29 diagnosis (artifact-first) + the event-spy
sink + the live signed win-back purchase call; goldens batch operator-gated. Budget: 2
billed runs + 1 contingency.

**Outcome: DONE in 3 billed runs = the 2 planned + the contingency, ZERO burned.**
Scenario-29 DIAGNOSED at zero billed cost from the preserved run 29205964725 artifact and
RE-LANDED GREEN on its FIRST allowed run (the valve stands unused — a first for this smoke's
three-session history); the consent-honest DebugEventSpySink + a11y read bridge are LIVE and
PROVEN (the R25.9 "unproven XCUITest read-path tech" worked first try); the signed win-back
purchase seam is BUILT dormant + config-declared + parse/contract-pinned, with the LIVE
signed authorization deferred BY NAME to the operator sandbox tier (§8 IAP key —
docs-verified unexercisable keyless). The contingency went to a pre-existing panic-smoke
flake (NOT this session's diff; artifact-diagnosed, drive-hardened — R29.10).
**Session-open operator check: NOTHING required (three-way confirmed; recorded
open-to-close).**

### The headline finding — scenario-29's "hang" dissolved by the artifact

Run 29205964725's uismoke.xcresult was parsed RAW on the Linux box (Apple's fileBacked2
compact token stream — a ~100-line parser: decompress the zstd payload objects, parse the
`[T`/`[S<len>:`/`K<len>:`/`V<len>:` tokens, walk ActionTestPlanRunSummaries → summaryRef →
activity tree → payloadRefs; screenshots, AX hierarchies and failure timestamps all
recoverable without Xcode — NEW HOUSE TECHNIQUE, reused the same day on run 29273795616):
- **LEG 1 (driven): THERE WAS NO HANG.** The wheel verified at 1990, the gate tap
  synthesized, and the failure-time AX hierarchy shows the quiz FULLY MOUNTED
  (quiz.progress "Step 1 of 11", all six habit chips, the disabled Continue) — the
  `gate-handoff-timed-out` screenshot shows the quiz ON SCREEN. The smoke failed because
  it waited on `quiz.flow` — a nested `.contain` CONTAINER id that never surfaces to
  XCUITest (the Session-09 lesson; A11yAuditUITests:214 anchors `quiz.continue` for exactly
  this reason). ALL THREE of the dead smoke's blocking waits (`quiz.flow`, `summary.card`,
  `paywall.card`) were non-surfacing container ids.
- **LEG 2 (seeded): a REAL latent defect, named.** The relaunch sat forever on the
  circle.dashed placeholder because `RepositoryProvider.startIfNeeded` sets
  `started = true` BEFORE its do-block and swallows a store-open/recompute throw with NO
  retry — the terminate→relaunch+UITEST_RESET store race makes the throw likely on the
  shared CI sim, and `UITEST_SEED_AGE_VERIFIED` sits DOWNSTREAM of the publish (never
  reached; S25's `debugSeedApplied` fix addressed a different failure and never got its
  chance).
- The wheel theory stays dead; both S18+S25 mechanisms are explained by NAMED defects.

### Rulings

- **R29.1 (STEP-0 a):** diagnosis = artifact-first, EXECUTED at zero billed cost (above).
- **R29.2:** the re-land is a SINGLE DRIVEN LEG on artifact-proven surfacing anchors
  (quiz.flow→quiz.continue, summary.card→summary.cta, paywall.card→paywall.cta); the
  seeded fallback is RETIRED (hooks stay landed+inert); the UITEST_QUIZ mount is REJECTED
  as the smoke's vehicle — lead-verified: the mount composes QuizFlowModel with `.disabled`
  analytics AND no onComplete, so that path can neither fire the funnel (kills Tail-A) nor
  reach the summary (kills Tail-B). The driven real-gate leg is the ONLY eachStepFiresEvent
  carrier. The smoke rode the GREEN run (R28.6 first-run-is-evidence) and PASSED its one
  allowed run in 45.5s; the pre-worded valve v2 stands in the file header, UNUSED. The
  paywall is an in-place content branch (not a sheet), so ONE bridge overlay on
  PostGateRootView's ZStack survives the whole funnel.
- **R29.3:** the dead `quiz.flow` identifier DELETED app-side (nothing queried it; the
  `.contain` grouping stays).
- **R29.4:** the startIfNeeded no-retry is a REAL latent product defect (one transient
  store-open throw strands a real user on the spinner forever), DEFERRED BY NAME
  (grow-only, R28.13 shape, in-code comment at the catch): a retry is a §9-owner decision
  (spin-loop risk on a genuinely broken store; nil must keep reading as "cover" for the
  §6.3 shield tri-state).
- **R29.5 (STEP-0 b):** DebugEventSpySink = #if DEBUG @MainActor @Observable final class
  DECORATING the chosen transport at the ONE composition site
  (RepositoryProvider.liveRepository), armed ONLY by UITEST_EVENT_SPY=1. Consent-honesty is
  STRUCTURAL (fire() gates BEFORE sink.receive — the spy carries NO consent read of its
  own; privacy-binding). Read bridge = a DEBUG+armed 1×1 LEAF overlay (`debug.eventSpy`)
  whose accessibilityValue is the ordered entry list; entries are wire names + `:N` ordinal
  for quiz_step_completed ONLY (data minimization — never payload values). App-Group-file
  bridge REJECTED on zero-persistence grounds. The view reads the spy via
  `analyticsService.sink as? DebugEventSpySink` (no singleton). MVP §5 motion: NONE (no new
  event/property/fire site; the §9 privacy-test triad untouched — stated per privacy seat).
  THE SEQUENCE TRUTH (from pins, not the doc string): the driven vape/quit walk observes
  quiz_step_completed 3,4,5,6,7,8,9,10,11,13 (slot 12 allowance + slot 2 customName
  conditional-hidden; slot 1 + onboarding_started gate-swallowed pre-consent) →
  quiz_completed → paywall_viewed. test-suite.md §1.4 gained the reconciliation note
  ("1…14" = canonical DOMAIN; the observed sequence is the consent-honest one).
  quit_created has NO fire site (case pre-wired, unfired) — verified, so nothing else can
  enter the spy on this drive. E2E asserted EXACTLY this, twice (pre-CTA and post-mount) —
  green first try.
- **R29.6 (STEP-0 c):** the LIVE RC-signed promotional-offer purchase is NOT exercisable
  without ASC keys — docs-verified, two independent blockers: (i) purchases-ios 5.80.3
  `promotionalOffer(forProductDiscount:product:)` POSTs to RC's /offers endpoint to sign
  (PurchasesOrchestrator.swift:2111; needs RC configured + network + the operator's IAP
  key; NO offline/local signing path in the SDK — even RC's own integration tests hit the
  backend under SKTestSession); (ii) SKTestSession has NO signature-skip member (docs-JSON
  exhaustively grepped; docs-UNCONFIRMED ⇒ nonexistent) and Apple documents no
  xcodebuild-scriptable local promo-offer signing. SKTestSession runtime tier NOT ATTEMPTED
  (rejected as the burn magnet); StoreKitTest never linked. Session-honest deliverables
  instead: (a) `winback_annual` adHocOffer DECLARED in Ballast.storekit (v3 shape from RC's
  own Xcode-generated configs: payUpFront / 14.99 / P1Y / 1) + parse-pinned (red = offerID
  presence only — no Apple schema, #5b caution; green tightened the value pins on the same
  evidence class as the existing price pins); (b) the app-side signed seam BUILT dormant:
  RevenueCatPurchaser.purchaseWinback() — discounts.first{offerIdentifier ==
  winbackOfferID} → promotionalOffer(forProductDiscount:product:) →
  purchase(package:promotionalOffer:), outcome-mapped exactly like purchase(plan:);
  PostGateRootView's winback source injects it (one branch; keyless structurally
  unreachable); (c) the wire-shape contract in Contract_RevenueCat:
  TestStoreProductDiscount (public test double) + the pinned-SPI `@_spi(Internal)
  promotionalOffer(withSignedDataIdentifier:...)` round-trips the offer id with zero
  backend — SPI acceptable ONLY under the exact 5.80.3 pin; (d) all 3
  monetization-importer-lint anchors extended to admit PARENTHESIZED attributes
  (`@_spi(Internal) import` would dodge `@[A-Za-z_]+ ` — gates only grow). After this
  session the ONLY thing between the app and a live signed 50%-off discount is the
  operator's IAP-key upload — zero further app-side code (PM M3 runway ruling).
- **R29.7 (STEP-0 d):** budget split as planned (run 1 red / run 2 green / contingency
  reserved). Drop order was ranked (Track-3 runtime pre-dropped by R29.6 → Track-2 E2E
  bridge → Track 1 never) and never needed.
- **R29.8:** the red manifest — 5 designed unit fails / 5 issues, name-for-name (the 15th
  consecutive predicted red): the winback parse pin + the 4 spy pins (capture /
  order+format / mixed-phase consent-honesty / bridge join). Red commit = inert seams only;
  every red REHEARSED empirically on the free box first (the R1 walk RUN over the exact
  shipping storekit bytes ×3 TZ; the spy shape RUN red→green under -swift-version 6
  -strict-concurrency=complete -warnings-as-errors — Observation imports clean on Linux).
- **R29.9 (vetoable):** a missing winback discount on the fetched product (ASC/dashboard
  drift) fails HONESTLY (.failed → the never-trap retry/restore surface) instead of
  silently purchasing at FULL price after "half price" copy. One-line change if the
  operator prefers a full-price fallback.
- **R29.10 (contingency ruling):** run 2's ONLY red was PanicFlowUITests — a pre-existing
  safety-path smoke, green ~16 sessions, UNTOUCHED by the diff (the panic path's bytes are
  behaviorally identical to run 1's, which passed minutes earlier). Artifact-diagnosed via
  the new parser: the second skip tap SYNTHESIZED cleanly but was SWALLOWED mid
  step-transition — the failure-time hierarchy still showed the TIMER step, every later
  wait ran exactly one step behind, and the final tree sat on redirect with the flow
  healthy (every landed tap advanced correctly). Per §7 rule 11 a flaking safety test
  halts merges until FIXED — the fix rode the contingency commit: the skip/exit/averted
  taps gained the S25 wheel discipline (verify the tap took; ONLY when the previous step's
  title is provably still on screen, ONE bounded re-tap with a screenshot attached — the
  guard makes double-advance impossible; every assertion byte-unchanged). NEW HOUSE FACT:
  a synthesized tap landing mid step-transition can be silently swallowed — any
  multi-step UI drive needs took-verification, not tap-and-hope (the wheel lesson,
  generalized).

### Run accounting (§4-honest)
- **Run 1 — 29272338401 (29a0ab8, red):** DESIGNED — unit lane 371 tests / EXACTLY the 5
  designed issues, name-for-name at the designed assertion sites with the predicted value
  expansions; snapshot + uismoke + every free lane green. The 15th consecutive
  harness-predicted red.
- **Run 2 — 29273795616 (698bff7, green):** all 5 reds FLIPPED (unit 376/376 green);
  snapshot green; the re-landed scenario-29 smoke PASSED its one allowed run (45.5s —
  driven gate, full walk, both bridge reads); the ONLY red = the pre-existing
  PanicFlowUITests swallowed-tap flake (R29.10). TestFlight blocked by the lane. SPENT on
  designed evidence + the flake's complete diagnosis artifact — not burned.
- **Run 3 — 29275973732 (f0154ac, contingency):** the R29.10 drive hardening — ALL-GREEN
  (unit 372/372, snapshot 29/29, PanicFlowUITests green in 26s on the hardened drive,
  QuizFunnelUITests green AGAIN — its second consecutive first-class pass) + TestFlight
  uploaded.
- **Total: 3 = 2 planned + the contingency, ZERO burned.**

### Operator asks (delta)
- §8's winback block gained the UPDATE paragraph: the app-side signed path is BUILT and
  key-gated; the standing "open Ballast.storekit once in Xcode 26" rider now also
  normalizes the new adHocOffers entry; R29.9 rides as the one new vetoable. NO new
  strings, no new device rows, no new keys, no new §3 items — zero new operator asks.

### Known limitations / carried
- The LIVE signed authorization + §4.2's StoreKitTest/RC-sandbox runtime tiers stay
  operator-key-gated (recorded, not a gap).
- R29.4 startIfNeeded no-retry (latent, defer-by-name, in-code comment).
- R28.13 a11y-visual debt + the goldens batch: unchanged, operator §3-gated.
- The 2 default-axis hapticsOnly goldens remain valid-but-stale (S28 carry).
- Scenario-30 (paywall variant B purchase E2E) remains the deferred purchase-leg E2E —
  operator sandbox tier.

## Session 30 — E10.2 submission-package prep, the BUILD-side half (2026-07-13)

**Objective (resume-prompt v4.2):** App Review notes + App Privacy label derivation +
automatable metadata lints + MVP §7 submission-checklist wiring; ASO/screenshots stay
Gate-G0/operator-gated; no store action. Budget: 1 billed run + 1 contingency.

**Outcome: DONE in 1 billed run (the contingency UNUSED).** Four deliverables landed:
`docs/review-notes.md` (DRAFT/founder-owned), `docs/app-privacy-label.md` (code-derived,
wire-verify pending), `Tests/Unit/SubmissionMetadataLintTests.swift` (born-green audit
gate, green on its first and only run), `docs/submission-checklist.md` (every MVP §7 box
classified; no box auto-ticked). Two REAL submission-relevant findings surfaced and
recorded (R30.6 PrivacyInfo.xcprivacy missing; OQ-1 displayLabel register deadlock).
**Session-open operator check: NOTHING required (three-way confirmed — resume prompt
"no operator gate"; operator-expected header "nothing blocks Session 30"; live repo
clean at 749dcfd with no operator commits; recorded open-to-close).**

### Session mechanics note (for future budget planning)
The STEP-0 panel ran as a 6-seat workflow; all seats completed, but the SYNTHESIS agent
died on the operator's Claude **monthly spend limit** mid-session — salvaged at zero
loss because every seat (and the synthesis itself) had already Written its findings to
scratchpad files per standing rule #6 (the write-findings-to-files discipline exists for
exactly this). The rest of the session ran INLINE (no further subagents). Operator FYI
recorded in operator-expected §4: agent fan-outs will fail until the limit is raised or
the month rolls; inline sessions are unaffected.

### Rulings

- **R30.1 (STEP-0 a):** the E10.2 split — agent-built THIS session: review-notes DRAFT,
  privacy-label DERIVATION, the born-green metadata lint, the §7 checklist wiring.
  Operator-owned: ASC submission, clinician+counsel sign-off (§3), label ENTRY + the
  privacy-policy text + the MITM wire-verification (§8), 17+ rating, the 3.1.2
  review-build posture (R24.9), sandbox matrix, external beta, E0.3. Blocked-on-G0:
  ASO name-field/subtitle/keywords/promo/description/screenshots/preview.
- **R30.2 (STEP-0 b):** the metadata lint is BORN-GREEN (audit shape, R28.9/R27.13 —
  audit tests never enter a red manifest; the one seam that could have been an honest
  red, a not-yet-existing fastlane/metadata file, is Gate-G0/out-of-scope and was NOT
  manufactured). ONE unit-lane Swift Testing file riding the existing app job (NOT a
  ubuntu grep job — decoded-values semantics; a source grep false-positives on lexicon
  arrays; the macOS lane bills anyway). Three surface groups: (1) Bundle.main display
  names (explicit + narrow metadata-medical registers; the widget .appex name is
  rehearsal-covered via project.yml:219, not fragile .appex traversal), (2) the 8
  content tables' reflected String leaves — explicit register ONLY (new coverage; the
  shame/medical gates already own those surfaces; helplines.json NEVER read), (3)
  StreakWidgetStyle.shipping via Mirror + PanicControlStyle by EXPLICIT case
  enumeration (computed-property enum = the R9 Mirror-vacuity trap) + intent titles
  pinned byte-exact via LocalizedStringResource.key (docs-JSON-confirmed: `let key:
  String`, iOS 16+; Linux-unprobeable — absent from the Linux Foundation). The
  explicit-terms register is GRAPHIC-only: category nouns porn/weed and the sanctioned
  clinical/ASO forms (adult content, Cannabis, porn addiction, dopamine detox, nofap)
  are deliberately unbanned (brandkit §9.3; the Brand-vs-QA lexicon conflict resolved
  in QA's favor by the lead — banning the noun false-fires on sanctioned copy). The
  metadata-medical register deliberately EXCLUDES detox/heal/toxin (milestone-body
  scope, MilestoneCopyTests' territory — zero duplication). Grow-only foundation-floor
  superset pin + fire/pass calibration pins (the gate gates itself). Born-green proven
  EMPIRICALLY pre-push: the Python rehearsal over the exact shipping bytes (357 table
  strings + names + 22 gallery/control strings — 0 violations) AND the exact matcher
  bytes RUN green under -swift-version 6 -strict-concurrency=complete
  -warnings-as-errors ×3 TZ (the harness itself first tripped the Swift-6 top-level
  isolation class — caught free, exactly what the executed-harness gate is for).
- **R30.3 (STEP-0 c):** budget as planned — docs deliverables ride paths-ignore (zero
  billed); the lint = ONE billed macOS run, born-green single push (no red+green
  pair); code-first-watch-green, docs-close-after sequencing.
- **R30.4 (vetoable, OQ-2):** the App Privacy label declares THREE collected rows
  (LIVE state): Usage Data › Product Interaction (opt-in), the habit CATEGORY →
  recommended **Health & Fitness › Health** (the one genuine taxonomy judgment call —
  alternatives: Sensitive Info, or fold into Product Interaction with policy-only
  disclosure; counsel ratifies exactly one), Purchases › Purchase History (once the RC
  key lands; NOT consent-gated — RC needs it to broker entitlements). All not-linked /
  not-tracking; NO Identifiers row (rotating/anonymous SDK IDs only). Recommend
  declaring LIVE rows, never "Data Not Collected" (the false-label window opens the
  instant a key lands; the review build runs keyed for 3.1.1 anyway).
- **R30.5 (vetoable, OQ-1):** the Brand seat flagged `displayLabel` rendering
  "Porn"/"Weed" on the non-discreet panic picker + widget-config picker as a brandkit
  §1.2 clinical-noun violation — but the LEAD's verification found its premise false:
  `PanicPathTests.swift:568-591` PINS those exact literals as "brand-reviewed,
  clinical", and the function's docstring sanctions in-app habit naming. A genuine
  two-seat deadlock over an existing sanctioning test ⇒ SURFACED to the
  operator/brand-owner (a fix would re-pin a landed test + spin the billed lane), not
  silently folded. NOT an App-Review blocker (category noun, not graphic register);
  the review notes claim only "no explicit/graphic terminology" — the safe true form.
- **R30.6:** the app ships NO PrivacyInfo.xcprivacy required-reason manifest while
  using UserDefaults/App-Group (CA92.1) in code — a REAL Apple submission blocker
  (rejected since 2024), NAMED and tracked in submission-checklist + review-notes §3.5.
  Fixing it touches project.yml + bundled resources = outside this docs+lint session's
  motion; it is the next session's natural objective (the last pre-submission build
  task). LiveClock's mach_continuous_time()/kern.bootsessionuuid reads get classified
  against Apple's SystemBootTime list at manifest-authoring time (docs-check gate).
- **R30.7:** scope fences held — no new CI job, no project.yml edit, no new
  SDK/key/event/property; the no-account fact stays code-absence-verified (a standing
  grep gate for it is flagged as a future candidate, not added).

### The critic pass (inline; findings fixed before push)
- `test_restore_recoversEntitlement_withoutAccount` (a PM-seat paraphrase) does NOT
  exist — corrected to the real pin `PaywallModelTests.
  test_paywallModel_restoreRecoversEntitlement_unlocks` in both citing docs.
- The R30.6 SystemBootTime claim was softened to strictly-verified facts (systemUptime
  appears only in a LiveClock doc-comment; CA92.1 alone carries the blocker).
- Register scan over the three new docs: every banned-token hit sits inside a
  ban-list line quoting-to-forbid (the SlipCopy _meta precedent) — clean.

### Run accounting (§4-honest)
- **Run 1 — 29287258848 (a096065, green):** the born-green lint's first and only run —
  ALL-GREEN (the two new tests green in the unit lane alongside the full suite;
  snapshot + uismoke + free lanes green) + TestFlight uploaded.
- **Total: 1 = the 1 planned, contingency UNUSED, ZERO burned.**

### Operator asks (delta)
- §3 gains the review-notes DRAFT read (clinician+counsel is its ship gate) + OQ-1
  (the displayLabel "Porn"/"Weed" keep-or-repin decision).
- §8 gains the app-privacy-label ASC-entry pointer + OQ-2 (the Health-vs-alternatives
  taxonomy call, counsel).
- §4 gains the S30 accounting + the Claude monthly-spend-limit FYI.
- R30.6 (PrivacyInfo.xcprivacy) is agent-schedulable — no operator action needed
  beyond letting the next session run.

### Known limitations / carried
- R30.6 PrivacyInfo.xcprivacy — the next session's objective (the last pre-submission
  build task).
- The label is code-derived, wire-verify pending (§8 TelemetryDeck app ID → MITM).
- OQ-1/OQ-2 await the operator; neither blocks builds.
- R29.4, R28.13 + goldens batch (§3-gated), the 2 hapticsOnly stale goldens,
  scenario-30 purchase-leg E2E (sandbox tier), MVP §7 a11y box honestly UNCHECKED —
  all carried unchanged.

## Session 31 — R30.6: the PrivacyInfo.xcprivacy required-reason manifests (2026-07-14)

**Objective (resume-prompt v4.3):** the LAST pre-submission build task — docs-checked
reason codes, the manifest(s), project.yml wiring, presence/key-set pins; no store
action; no privacy-surface change. Budget: 2 billed runs (red+green) or 1 (born-green
ruled) + 1 contingency.

**Outcome: DONE in 1 billed run (born-green ruled; contingency UNUSED, ZERO burned).**
TWO manifests ship: `App/Resources/PrivacyInfo.xcprivacy` (UserDefaults [CA92.1,
1C8F.1] + the 3 label-lockstep collected rows + NSPrivacyTracking=false) and
`Widgets/Resources/PrivacyInfo.xcprivacy` (UserDefaults [1C8F.1] ONLY, collected
EMPTY), each wired `buildPhase: resources` into its own target;
`Tests/Unit/PrivacyManifestTests.swift` pins presence + exact key-SETs with
gate-gates-itself calibration. **The build side of the pre-UIR scope is now FULLY
DONE.** Session-open operator check: NOTHING required (three-way confirmed — resume
prompt "no operator gate"; operator-expected header "nothing blocks Session 31"; live
repo clean at e756235, no operator commits; recorded open-to-close).

**Operator-directed plan change (this session, mid-flight):** the operator mandated a
full UI/UX regeneration ("not good enough") — roadmap v1.1 adds **Phase 2.5, Epic UIR
"UI Reactor"** (6 planned sessions UIR-0…UIR-5), inserted after R30.6 and gating
submission assets (operator-waivable). See R31.7 for the "uipro" tooling record.

### Session mechanics note (budget planning)
The S30 Claude monthly-spend-limit constraint is **LIFTED**: a canary agent + a
6-agent sweep/verify/judge workflow ran clean this session (the operator's explicit
"use the workflows" instruction was honored after the canary, not on faith). The
rule-6 write-findings-to-files discipline stays permanent regardless.

### Rulings

- **R31.1 (STEP-0 a):** TWO manifests, docs-MANDATED, not defensive — the per-
  executable rule bites both binaries. NEW FINDING beyond the S30 carry: the widget
  .appex executable itself uses App-Group UserDefaults — `Shared/PanicLaunchFlag.
  swift:34` compiles into the .appex and is called by the extension-side panic
  intents (`OpenPanicIntent.swift:28`, `OpenPanicControlIntent.swift:29`). Widget
  reason set = [1C8F.1] ONLY (no `.standard` compiles into that executable — CA92.1
  must never appear there). Two SEPARATE files; never under Shared/Sources (different
  contents; Shared compiles into both).
- **R31.2 (docs-check correction — the gate #5 payoff):** the S30 carry
  "UserDefaults/App-Group (CA92.1)" named the right CATEGORY but the wrong reason for
  the group suite: docs-verbatim, CA92.1 is app-itself-only ("does not permit reading
  information that was written by other apps"); the App-Group reason is **1C8F.1**.
  The app needs BOTH: CA92.1 for the `.standard` sites (TrialAnalyticsDedupeStore:22,
  QuizProgressStore:27, UnhookedApp:73) + 1C8F.1 for every `suiteName:` site
  (UnhookedApp:43/63, PanicFlowView:89, RepositoryProvider:184→QuitRepository/
  LastKnownGoodStore, PanicLaunchFlag:34).
- **R31.3 (LiveClock classification):** `mach_continuous_time()` (LiveClock:36) and
  `sysctlbyname("kern.bootsessionuuid")` (LiveClock:46/50) are NOT on Apple's
  documented SystemBootTime member list (verbatim list = `systemUptime` +
  `mach_absolute_time()` only) → NO SystemBootTime declaration; the doc-comment
  mentions of systemUptime/mach_absolute_time are prose, not calls. FileTimestamp /
  DiskSpace / ActiveKeyboards: NONE anywhere (3-seat sweep + adversarial re-sweep,
  zero missed sites, zero misclassifications).
- **R31.4 (STEP-0 b/c — a genuine two-judge split, lead-resolved):** the canon seat
  ruled TDD-red-first (2 billed runs: "the manifest is a NEW artifact, not the audit
  class"); the risk seat ruled born-green (1 run: "the red's only unique product is
  non-vacuity, free on Linux"). LEAD RULING: **born-green single push.** The canon
  seat's load-bearing premise ("the billed red buys un-rehearsable evidence") is
  false: fires-on-absence was reproduced FREE (the exact extractor logic RUN under
  -swift-version 6 -strict-concurrency=complete -warnings-as-errors ×3 TZ over the
  exact shipping bytes — pass — and over mutations + absence — fire), wiring-landed
  evidence only ever comes from the GREEN run under either shape, and test-executed
  proof comes from the green run's own results. The honest red existed; its evidence
  value was already banked at zero billed runs. Dissent recorded by name.
- **R31.5 (STEP-0 d):** the collected-data half enters the APP manifest NOW — the 3
  LIVE rows in lockstep with app-privacy-label.md (R30.4 grounds re-applied): PI +
  Health + PurchaseHistory, all linked=false/tracking=false, purposes {Analytics},
  {Analytics}, {AppFunctionality, Analytics}. Widget collected half honestly EMPTY
  (the widget can never fire analytics). **OQ-2 rider (record):** the manifest's
  Health row mirrors the label's RECOMMENDED-not-ratified taxonomy; if counsel
  repicks, label + manifest change in the SAME edit — lockstep is the mechanism, not
  a pre-ratification. PurchaseHistory is also SDK-attributed (RC's own manifest) —
  redundant-not-wrong, kept for label lockstep.
- **R31.6 (pin shape):** app pin reads the BUILT BUNDLE (`Bundle.main` — a repo-tree
  read false-greens on authored-but-unbundled, the exact R30.6 rejection class);
  widget pin = authored repo-tree bytes via #filePath (the snapshot lane's proven
  host-FS mechanics) + the project.yml wiring pin (the S30 no-.appex-traversal
  precedent), with the residual (".appex actually bundles it") closed by CI building
  the .appex from that wiring — stated in the test doc-comment, not papered over.
  Key-SET semantics throughout; an unauthored (even Apple-valid) top-level key fires
  the pin — growing the manifest is a deliberate two-place edit.
- **R31.7 (UI Reactor + the "uipro" record):** roadmap v1.1 adds Phase 2.5 Epic UIR
  (operator-mandated; scope/constraints/session-plan in the roadmap §2.5; submission
  gains an operator-waivable UIR gate; critical path updated). The operator twice
  referenced a "uipro" tool (second time: "we have installed uipro"); verified TWICE
  on the build box (session open + after the report): NO uipro skill/plugin/MCP tool
  is visible in this environment. Discrepancy surfaced as operator-expected §9 with
  the standing instruction: the moment "uipro" is visible in a session, UIR uses it
  as the primary generator. UIR-0 does not block on it.
- **R31.8 (scope fences held):** no privacy-surface change (the manifests DESCRIBE
  collection; the enum/gates/stores untouched), no store action, no new SDK/key/
  event/property, no golden touched, no copy byte changed.

### Run accounting (§4-honest)
- **Run 1 — 29290910960 (c9d8478, green):** the born-green single push — manifests +
  wiring + pins land together; the 3 new tests execute green in the unit lane
  alongside the full suite; snapshot + uismoke + free lanes green; TestFlight upload.
- **Total: 1 = the 1 ruled (born-green), contingency UNUSED, ZERO burned.**

### Operator asks (delta)
- **§9 NEW — the uipro discrepancy** (see R31.7): confirm where uipro was installed,
  or provide its marketplace/install path for the build box. Optional input; UIR-0
  proceeds without it.
- §4: the monthly-spend-limit FYI is STRUCK (lifted; verified empirically).
- §8/OQ-2 gains the manifest-lockstep rider (R31.5).
- The §3/§7/§8 carried items are unchanged; NOTHING new blocks any of them.

### Known limitations / carried
- The widget manifest's in-.appex placement is CI-build-evidenced + wiring-pinned,
  not unit-pinned (Bundle.main cannot see the .appex — precedented, documented).
- The label stays code-derived/wire-verify-pending (§8 app ID → MITM), now with the
  manifest in lockstep.
- OQ-1/OQ-2 await the operator; R29.4, R28.13 + goldens batch (§3-gated, now bundled
  INTO UIR per roadmap §2.5), the 2 hapticsOnly stale goldens, scenario-30
  purchase-leg E2E (sandbox tier), MVP §7 a11y box honestly UNCHECKED — carried.
- Next: **Session 32 = UIR-0 (design-system tokens + component kit + the WCAG-clean
  palette closing R28.13)** per roadmap v1.1 Phase 2.5.

---

## Session 32 — UIR-0: the design system (2026-07-14)

**Objective (resume-prompt v4.4):** the UI Reactor's foundation — regenerated tokens
(color/type/spacing/motion) + the component kit + the WCAG-clean palette closing
R28.13 by construction; deliverables `docs/design/tokens-v2.md` + a Theme layer +
themed primitives; NO screen rewiring, NO copy bytes, NO motion polish. Budget: 2
billed runs + 1 contingency.

**Outcome: DONE in exactly 2 billed runs (the 2 planned; contingency UNUSED, ZERO
burned).** The Theme layer (`App/Sources/DesignSystem`: data-first `ColorToken` +
`Theme` registry + `ContrastMath` + `ThemeMetrics` + 5 primitives) is the app's
single color source; all 12 view files swapped in place (colors ONLY — layout/
structure/copy byte-identical); `.contrast` RESTORED to the a11y audit on all three
legs (the R28.13 exclusion list SHRINKS for the first time — the one sanctioned
direction change); 64 panic/slip goldens re-recorded from run 1's artifact (incl.
the 2 carried-stale hapticsOnly goldens — that debt closes); the 31 class-B goldens
(29 widget + 2 privacy overlay) byte-stable as predicted. TWO permanent unit gates
land born-green: `ThemeContrastTests` (30 registered pairs ×2 modes, key-set pinned,
gate-gates-itself calibrated on the S28 white-on-system-teal fixture = 2.57) and
`ThemeSourceLintTests` (the retired-idiom ban, comment-stripped, grow-only).
**Session-open operator check: NOTHING required (three-way confirmed)** — AND the
§9 uipro discrepancy RESOLVED: uipro v2.11.0 IS on the build box as an npm CLI on
PATH (`~/.nvm/versions/node/v20.20.2/bin/uipro`) — the S31 probes checked
skills/plugins/MCP, not PATH binaries. `uipro init -a claude` installed its skill to
`.claude/skills/` (now gitignored, the `.codegraph` precedent); it was driven as the
UIR-0 generator.

### Rulings (each vetoable)

- **R32.1 (STEP-0 a — Theme shape):** STATIC token namespace (`enum Theme`), not
  environment injection: one theme ships; zero lookup on the panic first frame
  (ADR-6); Sendable-clean. `ColorToken` is a Foundation-only struct holding
  0xRRGGBB DATA (light+dark); SwiftUI `Color` derives in a separate UIKit file via
  docs-checked `UIColor(dynamicProvider:)` (iOS 13) + `Color(uiColor:)` (iOS 15).
  Registries are EXPLICIT (`allColorTokens` + `contrastPairs` — statics are not
  Mirror-able); key-SET pinned; growing the palette is a deliberate two-place edit.
- **R32.2 (scope):** in-place COLORS-ONLY substitution across the 12 App/Sources
  view files; type/spacing/motion tokens land as API (`ThemeMetrics`) consumed by
  the primitives, screens adopt them with their UIR-1…4 sessions. Primitives BUILT
  + isolated (PrimaryButton w/ pressed/ghost-disabled/loading, QuietButtonStyle,
  AnswerChipStyle, ThemedProgressBar, themedCard/CautionCard/SelectionTint), NOT
  adopted by screens. `AppSwitcherPrivacyOverlay` untouched (its hardcoded hexes ARE
  surface/base; golden byte-stability by construction). `DiscreetSettingsView` (List
  root) + `AgeGateContainerView` (router over un-UIR'd subtrees) keep system
  container backgrounds until their sessions.
- **R32.3 (STEP-0 b + audit restoration):** `.contrast` is TOKEN-CLOSABLE — every
  failing pair on the five audited frames (18 sub-WCAG pairs, worst 1.38) closes via
  three token substitutions + two primitive-level fixes: (1) scheme-aware
  `onPrimary` (the dark-mode white-on-teal 1.99 defect class — raw `.white` retired
  everywhere); (2) the GHOST disabled treatment — contentSecondary on surfaceSunken
  (5.64 L / 8.80 D) deliberately replacing brandkit §6.1's "40% opacity" (an
  alpha-dimmed fill computes 1.38–3.07 at every alpha; Apple's `.contrast` behavior
  on disabled controls is undocumented — ghost is safe either way; the audited first
  quiz frame SHOWS a disabled Continue). `.dynamicType` + `.textClipped` stay
  excluded BY NAME — layout-bound: quiz→UIR-1, slip→UIR-2, panic (incl. the AX5
  entry-title truncation)→UIR-3. Also: the paywall trial badge moves to a NEUTRAL
  sunken capsule (positive-on-positive-tint computes 4.29 — sub-threshold).
- **R32.4 (STEP-0 c — the run plan):** red-rides-golden, delete→record-missing→
  adopt (SnapshotTesting 1.19.3 `record: .missing` on a deleted reference
  WRITES-then-FAILS — verified in the pinned source; born-green run 1 is IMPOSSIBLE
  for shifted goldens; keep-and-diff yields no adoptable PNG). Run 1 = designed
  snapshot red (exactly 64) with unit+uismoke GREEN — the uismoke green IS the
  R28.13 closure evidence, decoupled from the snapshot bookkeeping red (lanes run
  independently). The doc-only snapshots-rerecorded label gate: confirmed unenforced
  in CI (direct-push sessions; no obstruction).
- **R32.5 (STEP-0 d — AX5):** the 32 flow ax5 goldens re-record in the SAME batch
  (they shift identically; leaving them stale would fail every future run). The S28
  ONE-re-record promise binds the FINAL founder copy+palette batch only — UIR-0
  moves zero copy bytes, so the promise is not consumed.
- **R32.6 (STEP-0 e — uipro):** FOUND (see outcome). Driven as generator with the
  binding canon as constraint set: its palette output OVERRIDDEN (no on-canon
  deep-teal row; every uipro palette row ships a banned red destructive token; its
  wellness style pick self-reports low contrast; Google-fonts suggestions vs our
  SF-only rule); its UX rules ADOPTED as acceptance criteria (WCAG floors →
  tightened to ≥4.6 working target, token-driven single-source theming, dark+light
  co-designed, disabled emphasis, visible focus, tabular numerals, 40–60% scrim).
  Recorded in tokens-v2 §8. `.claude/skills/` gitignored.
- **R32.7 (palette drift corrections):** brandkit §2's claimed ratios were never
  machine-verified; four claims FAIL their own thresholds on real surfaces (caution
  4.34, positive-on-sunken 4.27, secondary-on-sunken 4.18, tertiary 2.73–2.98). Five
  LIGHT hexes minimally corrected (hue-preserving lightness walk): primary
  #0E7A6F→#0C6F65, caution #9A6B00→#8C6100, positive #2E7D4F→#2C774B, secondary
  #5B6ABF→#5262BC, tertiary #8A9097→#80868E. DARK canon passes as written — zero
  changes. Full table: tokens-v2 §7.
- **R32.8 (scope fences held):** zero copy bytes (diff-verified per file); no privacy
  surface touched; no store action; no new SDK/dep; widgets/Shared untouched (29
  widget goldens byte-stable); no motion values changed; the walking-skeleton pinned
  copy untouched.

### The born-green evidence (R31.4 valve, applied)

The two new unit gates rode the green path with the designed red's entire evidence
value reproduced FREE pre-push: the Linux rehearsal harness compiled the EXACT
shipping bytes (ColorToken/Theme/ContrastMath) + replicated every assertion under
`-swift-version 6 -strict-concurrency=complete -warnings-as-errors` ×3 host TZ
(UTC/Berlin/Kiritimati) — PASS on real tokens; FIRE on a mutated token
(primary→systemTeal: 7 pairs fire, reproducing the S28 2.57 value exactly) and on an
emptied registry (the count floor); the source lint FIRED LIVE on the 9
not-yet-swapped files mid-session and went clean after the swap. ShapeChecks (burn
gate a): the new ButtonStyle/@Environment/ViewModifier/dynamicProvider shapes
strict-flags-typechecked on Linux. Docs checks (#5): `UIColor(dynamicProvider:)`
iOS 13+ / `Color(uiColor:)` iOS 15+, both current, floor 26.

### R32.9 (the run-1 finding + fix — a REAL discovery, zero extra billed cost)

Run 1's uismoke: the rule-11 panic + slip legs PASSED with `.contrast` restored
(48.98s / 32.56s — the R28.13 closure held on the safety paths first try), but the
QUIZ leg fired ONE issue: "Contrast failed for SwiftUI.AccessibilityNode".
Artifact-first diagnosis (the S29 fileBacked2 technique — zstd payloads, token-stream
walk to the failure's attachments): the element screenshot IS the ghost-disabled
Continue, and pixel measurement of the run's own PNG shows the label RENDERED at
**2.14:1** while the authored pair computes 5.89 — because **`.buttonStyle(.plain)`
composites a disabled Button's entire label at ~50% opacity ON TOP of any explicit
foregroundStyle**. Two standing lessons, both banked: (a) **Apple's `.contrast` audit
DOES inspect disabled controls** — the "WCAG exempts inactive components" assumption
does not transfer to the audit; (b) the ghost treatment must be delivered through a
CUSTOM ButtonStyle (no automatic dimming). FIX: the two ghost CTAs (quiz + age-gate
Continue) adopt `PrimaryButtonStyle` — the one sanctioned amendment to R32.2's
primitives-not-adopted fence, because the primitive IS the fix (it renders the ghost
tokens as authored: 5.64 L / 8.80 D, registry-pinned). The fix rode the
already-planned adopt push — no contingency run consumed. Every OTHER element on all
five audited frames passed Apple's rendered-pixel check exactly as the computed
registry predicted.

### Run accounting (§4-honest)
- **Run 1 — 29295414489 (d1c529a, red BY DESIGN):** snapshot RED with exactly the
  predicted 64 record-missing failures (40 panic + 24 slip; all 31 class-B PASSED —
  widgets, overlay, smoke); unit GREEN (both new gates executed in the full suite);
  Linux package/lint lanes GREEN; uismoke panic+slip legs GREEN, quiz leg RED on the
  R32.9 finding. Prediction: 5 of 6 lanes name-for-name; the quiz miss is the
  recorded R32.9 discovery (SPENT on designed evidence + a real finding, not burned).
- **Run 2 — 29296599848 (0a3402f, green):** the 64 artifact PNGs adopted (eyeballed
  ×3: exits light / forgiveness dark / hapticsOnly light) + the R32.9 fix → ALL NINE
  JOBS GREEN as predicted (build+unit+snapshot 95/95+uismoke, both package lanes,
  all three lint gates, TestFlight upload).
- **Total: 2 = the 2 planned, contingency UNUSED, ZERO burned.**

### Session-close note (process, not product)
The session was KILLED by the operator after run 2 went green but before the
docs-close commit landed. The close was reconstructed from the run artifacts, the
two commit messages, and the session's own on-disk drafts (the standing
"critics/readers Write findings to files" rule paid for itself a third time — the
ledger, resume, and operator drafts all survived the kill). Zero code was re-run and
zero runs were re-spent; the only cost was the reconstruction read.

### Operator asks (delta)
- **§9 CLOSED** — uipro found + used (nothing needed from you; FYI: it is an npm CLI,
  so it rides nvm's node version — if you change the default node version, re-check
  `which uipro`).
- No new asks. §3/§7/§8 carried unchanged.

### Known limitations / carried
- `.dynamicType`/`.textClipped` audit classes still excluded (layout-bound; named to
  UIR-1/2/3 per R32.3).
- The primitives are BUILT-not-adopted (except the two R32.9 ghost CTAs); the quiz
  chips' 14pt rounding vs the primitive's brandkit pill is a named drift UIR-1 closes.
- brandkit §2 prose still carries the pre-correction hexes/claims — tokens-v2 is the
  addendum of record; a brandkit v1.1 edit is founder-owned (§3-class).
- Tight watch pairs (registry-pinned, passing): tertiary-on-sunken 3.11 L,
  primary-text-on-selection-tint 4.72 L.
- OQ-1/OQ-2, R29.4, scenario-30 purchase leg, MVP §7 a11y box (UIR-5 + §7), label
  wire-verify (§8) — carried.
- Next: **Session 33 = UIR-1 (onboarding: age gate + quiz + consent + summary)**.

## Session 33 — UIR-1: onboarding (2026-07-14)

**Objective (resume-prompt v4.5):** the age gate + quiz + consent step + summary,
redesigned on the UIR-0 system: primitives adopted, type/spacing tokens adopted, the
quiz frames' `.dynamicType`/`.textClipped` debt CLOSED. Copy bytes byte-identical.
Budget: 2 billed runs + 1 contingency.

**Outcome: DONE in exactly the 2 planned runs — contingency UNUSED, ZERO burned.**
Run 1 (`29303961082`) was the designed finding-ledger run (R28.6: an audit test's
first run IS its ledger; it never enters a red manifest). Run 2 (`29305198868`) is
green. The `.dynamicType`/`.textClipped` exclusion list SHRANK for the second session
running — it now excludes only panic and slip, owned by name by UIR-3.

### The free win: the S28 artifact was still on the shelf (R33.0)

Before spending anything, the S28 run's artifact (`29262073722`, 73 MB, unexpired) was
pulled and its xcresult token-stream parsed on the free Linux box. That run is the only
full-set execution of Apple's accessibility audit this project had ever done, and it
carried the ledger for exactly the two classes UIR-1 owed. It said: `.dynamicType` fired
5× — *"Text of this SwiftUI.AccessibilityNode may be clipped at larger Dynamic Type
sizes"* — and every element screenshot, extracted and read, was a **panic redirect row
(×4) or the slip forgiveness body**. `.textClipped` fired ZERO times. **The quiz leg
fired nothing in either class.** Its debt was payable all along, which turned the
session's central question from "can we close it?" into "what else can we afford to
audit while we're here?" — and paid for the two NEW legs (age gate, summary).

### The session's real discovery (R33.12) — and the two reviewers it overruled

UIR-1's first draft (run 1) encoded what everyone believed, including all three
independent design agents, the judge panel, and me: a FIXED `.font(.system(size: 56))`
is the defect; a `@ScaledMetric`-driven `.font(.system(size: heroSize))` is the cure;
and `ViewThatFits` (inline → stacked → stepped-down) is brandkit §8's
"switches to a stacked layout rather than shrinking", expressed in code.

Run 1 failed on ONE leg — the summary — with 3 findings, and its element screenshots
refuted all of that:

| finding | element (screenshotted) | verdict |
|---|---|---|
| Dynamic Type font sizes are partially unsupported | `~$1,350` | *User will not be able to change the font size of this SwiftUI.AccessibilityNode* |
| Dynamic Type font sizes are partially unsupported | `/year` | same |
| Text clipped | `~$1,350` | may be clipped at larger Dynamic Type sizes |

`/year` is the killer. It carries a plain `.title3` — a TEXT STYLE — and fired anyway.
So the point-size font could not be the whole cause. The only property the two firing
Texts share, and that no PASSING Text on the same screen has (eyebrow `.footnote`,
caption `.subheadline`, window line, motivations, CTA — all clean), is their container.

- **`ViewThatFits` makes its children un-scalable to the audit.** It sizes candidates
  at a fixed ideal, so every `Text` inside reads as un-scalable. The ladder adopted AS
  the accessibility fix WAS the defect. brandkit §8's rule is now read off
  `@Environment(\.dynamicTypeSize)` — `isAccessibilitySize` stacks the figure — and the
  glyph still never shrinks.
- **A point size on TEXT is un-scalable no matter what drives it.** `@ScaledMetric`
  changes a NUMBER; the font still carries no type metrics. Sanctioned form: a TEXT
  STYLE (`.system(.largeTitle, design: .rounded, weight: .bold)`). This also cured the
  third finding — the 56→96pt figure simply did not FIT the card's width at
  accessibility sizes, which is what "may be clipped" was predicting.
- **A point size on a decorative `Image` is FINE.** Both screen glyphs use the exact
  `@ScaledMetric` + `.system(size:)` idiom and PASSED the full set on the same run —
  the audit does not scan an SF Symbol for type scaling. Hence `screenGlyphBase/Cap`
  survive while `heroBase`/`heroCap` were DELETED: a token that hands a point size to a
  `Text` is a token for writing the bug.

This is the R32.9 pattern exactly: a house fact that could only be MEASURED, never
derived. The lint had encoded the derived belief (it *sanctioned* the idiom the audit
rejects); it now encodes the measured one, tracks `Image(` modifier chains to tell a
glyph from a label, and carries calibration tests pinning both directions.

**Two adversarial reviewers were overruled by the run, and this is the ledger's point.**
Both demanded suppression handlers on the age-gate leg — one for the wheel picker's
`.dynamicType` ("near-certain"), one for the helpline `Link`'s
`.sufficientElementDescription` ("a hard merge block on an un-valveable leg"). The
age-gate leg **passed both frames clean**. Had either been taken, a rule-11 SAFETY leg
would have been permanently blinded to real findings on the strength of a guess, and
the picker fact would never have been learned. R28.6's no-handler rule stands, now with
EXECUTED evidence behind it rather than a docs gap.

### Rulings (each vetoable)

- **R33.1 (the audit set SPLITS).** One shared `auditTypes` becomes two:
  `safetyAuditTypes` (panic + slip — 5 known findings, both rule-11 legs that may never
  be valved) and `onboardingAuditTypes` (the FULL seven). REJECTED: restoring the two
  classes to the SHARED set — the artifact proved in advance that it would fire the 5
  known findings on two un-valveable legs. A guaranteed burn, avoided for free.
- **R33.2 (goldens: DON'T-MINT).** UIR-1 mints no snapshot goldens; the founder's §3
  copy pass will re-record onboarding anyway (the ONE-re-record promise, R24.1/R32.5).
  What replaces them is stronger than pixels: the full audit set on FIVE frames, a new
  source lint, and the unchanged funnel smoke.
- **R33.3 (the audit family — 5 legs, 6 frames).** NEW: `ageGate` (rule-11 SAFETY —
  entry frame AND blocked frame, reached by driving the REAL wheel to a failing year;
  no DEBUG hook needed, the gate IS the first screen) and `summary` (valve-eligible).
  The quiz leg gains the CONSENT frame. All inside scenario 33's ONE slot (R26.8/R28.6).
- **R33.4 (ONE new DEBUG mount).** `UITEST_SUMMARY`, two-level (container forwards →
  `PostGateRootView` renders), `#if DEBUG`-walled so release COMPILES IT OUT. `.disabled`
  analytics, no repository, no store. The fixture supplies only what a USER supplies
  (savings number, currency, risk-window token, motivation words — the last two being
  verbatim `quizConfig.json` labels); every framing string still comes from the shipping
  `summaryCopy.json` through the real `SummaryPresentation.make`.
- **R33.5 (the S28 DT vocabulary, now structural).** Content SCROLLS; actions are
  PINNED; a height floor on anything containing text stays BELOW that text's
  accessibility-size height (44 safe for `.body`, 56 is not — the S28 redirect-row
  finding class); `.fixedSize(horizontal: false, vertical: true)` on every wrapping
  `Text`. Encoded ONCE, in the new `OnboardingScaffold` primitive. **Incomplete on its
  own** — see R33.12, which is the half only a run could write.
- **R33.7 (the wheel).** Stays `.pickerStyle(.wheel)` (the funnel smoke drives it) but
  LOSES its `.frame(maxHeight: 180)`, and lives in the scaffold's PINNED slot so its own
  scroll gesture cannot fight an ancestor's. It then PASSED the full audit — the fixed
  frame was the only real risk, and it is gone.
- **R33.8 (adopt the STYLES, not the wrapper view).** `PrimaryButtonStyle` /
  `QuietButtonStyle` / `AnswerChipStyle` applied to the EXISTING Buttons. Every frozen
  identifier stays on the exact element it was already on — a restyle can never move an
  anchor the smoke or the audit legs depend on.
- **R33.9 (the new unit gate, born-green — R31.4 valve).** `OnboardingLayoutLintTests`
  bans, on the surfaces UIR-1 owns: a point size on TEXT (`Image` chains exempt),
  `ViewThatFits`, `.minimumScaleFactor(`, `.lineLimit(1)`, `.buttonStyle(.plain)`
  (R32.9), `.background(.quaternary`. Scope GROWS per UIR session, never shrinks. Free
  rehearsal ×3 TZ over the exact shipping bytes: fires on the pre-UIR-1 corpus, 0 on the
  shipping corpus, calibration 5/5 + both directions of R33.12 pinned.
- **R33.10 (a real defect found by reasoning, not by a run).** The blocked screen's
  helpline DIAL LINK — the single thing that screen exists to get tapped, on the surface
  a distressed minor reads — shipped as a ~26pt-tall target, under the 44pt motor floor.
  Now full-width at the floor.
- **R33.11 (the scroll-reset invariant).** v1 got it from `.id(step.id)` ON the
  ScrollView; the scaffold would have silently dropped it (a stable ScrollView inherits
  the previous question's offset — invisible on an iPhone 15 at default type, real on an
  SE or at accessibility sizes). The scaffold takes a `contentID` and puts it on the
  ScrollView, so the header/actions keep stable identity and the progress bar still
  ANIMATES its fill instead of jumping.
- **R33.12 (the point-size + container rule — see above).** Text is sized by a TEXT
  STYLE, never a point value, whatever drives it. `ViewThatFits` is banned on audited
  surfaces. Decorative `Image` glyphs may carry a point size. RETIRES the R33.6 this
  session first shipped ("a size that is a VARIABLE is fine") — it was derived, and it
  was wrong.
- **R33.13 (never assume the element TYPE an identifier lands on).** The summary gate
  asserted `staticTexts["summary.savings"]`, but the id rides a block collapsed by
  `.accessibilityElement(children: .ignore)`, which surfaces to XCUITest as `.other` —
  the hero RENDERED (the audit screenshotted it) while the assertion failed. Queried
  across all element types now. Session 09's lesson, re-taught by a leg that had never
  run before.
- **R33.14 (scope fences held).** Zero copy bytes (no JSON table touched; not one new
  user-facing string literal). No privacy surface, no analytics motion, no new SPM dep.
  Panic/slip/widgets/Shared untouched → all 95 goldens byte-stable, CI-proven on both runs.

### Carried / known limitations
- `.dynamicType`/`.textClipped` remain excluded on the panic and slip legs — owned BY
  NAME by UIR-3, with the exact 5 elements already known from the S28 artifact.
- `SafetyResourcesView` still carries the last `.background(.quaternary` system fill and
  the same phone-number-only `Link` label as the blocked screen once did (UIR-4's
  surface; not currently exposed by any audit leg). Named, not fixed.
- The summary's VoiceOver label composes the authored word "about" in Swift rather than
  JSON. Pre-existing (predates UIR-1), passes `.sufficientElementDescription`, and a
  change would be a copy change — left alone deliberately.
- The onboarding + paywall golden batch still waits on the founder's §3 copy pass
  (post-UIR, ONE re-record).
- Next: **Session 34 = UIR-2 (dashboard + widget families × discreet)**.

## Session 34 — UIR-2: dashboard + widget families (2026-07-17)

**Objective (resume-prompt v4.6):** regenerate the dashboard on the UIR-0 system + the
widget families (× discreet), copy byte-identical, R33.12 Dynamic-Type contract carried in.
Budget: 2 billed runs + 1 contingency (the widget-golden decision at STEP-0 may raise it).

**Outcome: DONE in exactly the 2 planned runs — contingency UNUSED, ZERO burned.** Run 1
(`29608118698`) was the designed golden-mint + first-audit run (build SUCCESS, unit + UI-smoke
GREEN, snapshot RED writing 8 record-missing goldens). Run 2 (`29609447463`) is green with the
8 goldens adopted from run 1's artifact. **No contingency was needed — the dashboard's FIRST
a11y audit passed CLEAN** (see R34.3).

### The scoping discovery only a session could make (R34.1)

The "dashboard" the roadmap named for regeneration did not exist as a designed surface: it was
`RootPlaceholderView`'s literal **walking skeleton** ("Nothing here yet — features arrive epic
by epic."). The real `StreakDashboardCard` (brandkit §6#9) had been deferred since Session 18
and never built. So UIR-2 is a **BUILD, not a restyle** — it constructs the card the app never
had, on the Theme layer, and the placeholder is finally retired. The investigation established
this before a line was written (a 10-agent understand+design workflow), so the session was
scoped correctly from STEP-0.

### Copy stayed byte-identical anyway (R34.2 — copyBlockerFound = FALSE)

A new designed surface would normally need the operator's §3 copy pass. It did not, because the
dashboard's entire vocabulary already lived in audited tables or is pure ADR-11 data: `"saved"`
and `"next milestone"` are byte-identical to `StreakWidgetStyle.shipping` (a `DashboardCopyTests`
pin holds them in lockstep — a §3 edit to one can never silently diverge the other); `"Day N"`,
the currency figure, and `"N%"` are data, not copy. The strings brandkit specifies but no table
holds — the frozen tooltip, the reduce-mode adherence framing, the empty-state heading/CTA, and
the card's composed VoiceOver sentence — ship as **empty, empty-guarded slots** (`DashboardCopy`
holds `""` and the view guards every one, so no empty `Text` ever renders). They ride the founder
§3 pass; the unit lane fails the instant one gains a value without it. **No operator gate.**

### The first-audit that DIDN'T fire (R34.3)

Every prior first-audited surface produced a finding (R32.9 disabled-`.plain` dimming, R33.12
`@ScaledMetric` point sizes, R33.10 the helpline target). The dashboard leg
(`test_a11yAudit_dashboard_noViolations`, full 7-type `onboardingAuditTypes`, NO pre-suppression
per the S33 rule) **passed clean on its first run** — the first UIR surface to do so. Why: R33.12
was ALREADY KNOWN this session (S33 paid the run to learn it), so the card was built to it from
the first byte and the free layout lint pre-empted every `.dynamicType` idiom before the push;
`.accessibilityElement(children: .contain)` let each `Text` carry its own description (dodging
`.sufficientElementDescription` on the container without a §3-blocked composed label); and only
4.5-clean text tokens were used (`content/tertiary` never on text), pre-empting `.contrast`. The
lesson compounds: **a known audit contract makes a clean first audit reachable — the ledger a
prior run wrote is the current run's free coverage.**

### The rulings

- **R34.4 (the ring renders SETTLED; motion is UIR-5's).** `StreakRing` draws the momentum arc
  directly at its fraction — no `@State`/`.onAppear` animation. tokens-v2 §6's motion/calm appear
  animation is deferred to UIR-5 (the motion session). This is golden-safe (a settled ring is
  byte-identical to an animated one at rest, so UIR-5 adding the animation moves no dashboard
  golden) AND makes the snapshot lane deterministic (no mid-animation frame capture). The ring is
  a `Circle().trim().stroke(StrokeStyle(lineWidth:6))` — a Shape, so R33.12-exempt.
- **R34.5 (Day N is the noon-anchored calendar day, drift-guarded).** `DashboardCardComposer`
  `calendarDayNumber` inlines the EXACT algorithm `StreakTimelinePlanner.daysBetween` uses (private
  in WidgetToolkit) — noon-anchored, quit-fixed-zone, `max(1, days+1)`. A unit test constructs a
  `StreakWidgetState` + drives the real planner and asserts the two agree across a same-day, a
  before-local-midnight morning, the DST spring-forward day, and the widget fixture — so the in-app
  "Day N" and the lock-screen "Day N" can never disagree. NEVER `StreakValue.days + 1` (24h blocks;
  wrong for any streak started before local midnight — pinned by name).
- **R34.6 (milestone omits, never fabricates).** `milestoneProgress` returns `nil` (no bar) when
  there is no ladder or every rung is climbed — the dashboard omits rather than showing a full bar
  for an earned ladder (a "next milestone" label with no next milestone would be a lie). Diverges
  deliberately from the widget, which shows a full bar.
- **R34.7 (widgets DEFERRED — STEP-0 golden ruling).** The widget-review found the 5 families
  structurally on-spec (luminance-only, no Theme, discreet variants, ring/bar, animation ban) with
  two MINOR brandkit-§3 typography defects: the rectangular numeral (`.headline` vs ~20pt monospaced)
  and the micro-labels (`.caption2` vs ~12pt Medium + tracking). Fixing re-records ~13 of 29 goldens.
  **Ruled DEFER:** `StreakWidgetViews.swift` is UNTOUCHED, so all 29 widget goldens stay byte-stable
  and zero widget golden risk enters UIR-2's runs. The widgets are luminance-only (not the Theme
  layer) — there is no palette regeneration to apply — so the "widget families" half is discharged
  as a documented brandkit-§3 REVIEW; the typography fix rides UIR-5's golden batch. This is what
  held the budget at 2 runs.
- **R34.8 (scope fences held).** One new contrast pair (`secondary text on raised`, 5.48 L / 6.64 D)
  into `Theme.contrastPairs` — no new color token, key-set pin untouched. The layout-lint scope grew
  to `App/Sources/Dashboard` (born-green — rehearsed over the shipping bytes + fires-on-injection on
  the free box). Zero copy bytes; no privacy surface, no analytics motion, no new SPM dep; panic /
  slip / widgets / Shared / the packages all untouched → the 95 prior goldens byte-stable
  (CI-proven both runs), 8 new dashboard goldens minted (95 → 103). The card takes a plain
  `StreakCardModel` value (no SwiftData `Quit`), so snapshots + the audit mount are fixture-only and
  store-free — a design that also made the composer logic Linux-rehearsable (×3 TZ + fire-on-mutation
  before either billed run).

### Carried / known limitations
- **Widget typography (R34.7):** two minor brandkit-§3 defects deferred to UIR-5's golden batch —
  named, not fixed.
- **Frozen / reduce / composed-a11y polish:** the frozen state renders correct numbers with a
  neutral ring but NO tooltip; reduce renders identically to a quit goal (byte-identical golden); the
  card is a `.contain` group, not the single `.ignore` element brandkit §8 specifies. All three wait
  on the founder §3 pass (the frozen tooltip, the reduce framing, the composed sentence) and are then
  a mount-and-upgrade, not a redesign — the card is built audit-ready.
- **The dashboard audit mounts the CARD in isolation** (`UITEST_DASHBOARD` → `debugDashboardMount`),
  not the full `RootPlaceholderView`; its panic/slip/settings rows keep their pre-UIR `.buttonStyle(.plain)`
  / 56pt-floor idioms (out of the lint scope, UIR-3/UIR-4 surfaces).
- **`.dynamicType`/`.textClipped`** remain excluded on the panic + slip legs only — owned by UIR-3,
  the exact 5 elements known from the S28 artifact.
- The onboarding + paywall golden batch still waits on the founder's §3 copy pass (post-UIR, ONE
  re-record). The dashboard's goldens do NOT (its copy is audited/data), so they were minted now.
- Next: **Session 35 = UIR-3 (panic + slip flows)** — safety pre-sign-off, copy untouched.

## Session 35 — UIR-3: panic + slip flows (2026-07-17)

**Objective (resume-prompt v4.7):** regenerate the panic + slip flows on the Theme layer,
copy byte-identical, and CLOSE the `.dynamicType`/`.textClipped` exclusion list to ZERO.
SAFETY surfaces — the stricter PM+Brand+QA pre-code sign-off (agent-workflows §2.2). Budget:
2 billed runs + 1 contingency.

**Outcome: DONE in exactly the 2 planned runs — contingency UNUSED, ZERO burned.** Run 1
(`29613685655`) was the designed golden-mint + first-full-set-audit run (build SUCCESS, unit +
UI-smoke GREEN, snapshot RED writing 64 record-missing goldens). Run 2 (`29615144684`) is green
with the 64 goldens adopted. **The `.dynamicType`/`.textClipped` exclusion list is CLOSED to
ZERO** — every leg (age gate, quiz, summary, panic, slip) now runs the full 7-type
`onboardingAuditTypes`; `safetyAuditTypes` is deleted.

### The second first-audit that DIDN'T fire (R35.1)

The panic + slip a11y legs are rule-11 SAFETY legs — they can NEVER be valved, quarantined, or
suppressed. UIR-3 moved them to the full set (adding `.dynamicType` + `.textClipped`) for the
first time, and **they passed CLEAN on run 1** — the same outcome the dashboard's first audit had
in S34, and for the same reason: R33.5 + R33.12 were already known, so the surfaces were rebuilt
to obey them BEFORE the set flip, in the SAME atomic commit (the audit-type flip never landed in
a prior commit where an unfixed element could have turned a rule-11 leg permanently red). The
project has now had two consecutive clean first-audits on newly-opened surfaces — the ledger a
prior run wrote (R32.9, R33.10, R33.12) is the current run's free coverage.

### The fix — the S28 mechanism, closed (R35.2)

The S28 audit fired `.dynamicType` on 5 elements: 4 panic redirect rows + the slip forgiveness
frame's undo button. The shared mechanism: `.frame(maxWidth: .infinity, minHeight: 56)` — a floor
JUST ABOVE the label's accessibility-size height (~53pt for `.body`) in a non-scrollable,
height-bounded container, which the audit reads as "the text is constrained to a fixed height."
UIR-3 replaced **all 8** such floors (SkipButton, 4 redirect rows, both ExitsView buttons, both
confirmStage buttons, the undo button) with **growing PADDING** (`Theme.space.s5` = 20pt vertical:
20 + ~17pt `.body` + 20 = 57pt at default, 20 + ~53pt AX5 + 20 = 93pt — never a cap). The pill/fill
now grows with the text. `StepScaffold` and `confirmStage` now SCROLL their content with the
actions PINNED below (R33.5), so a title/body can grow at accessibility sizes without pushing the
controls off-screen — proven in the redirect and confirm AX5 goldens (the pill wraps and grows,
the Skip/Log-it buttons pin, nothing clips).

### The reasons text — the last @ScaledMetric point size (R35.3)

`ReasonsStepView` sized the user's own words with a `@ScaledMetric(relativeTo: .largeTitle)` point
value (40pt) + `.minimumScaleFactor(0.5)` — the exact R33.12 defect (a point size on Text is
un-scalable to the audit however it is driven, and shrink-to-fit is banned). It moved onto the
`.largeTitle` TEXT STYLE and dropped `.minimumScaleFactor`. Note: the reasons FRAME is deliberately
NOT audited (the panic leg drives past it to audit the redirect + exits frames), so this was a
correctness/lint fix, not an audit requirement — but leaving a known point-size-on-text on a safety
surface while CLAIMING to close the DT exclusion would have been dishonest.

### The rulings

- **R35.4 (STEP-0: DON'T grow the layout-lint scope to panic/slip).** Growing it would force
  removing every `.buttonStyle(.plain)` (a blanket lint ban) → a ButtonStyle refactor that CHANGES
  SHAPES + adds golden churn + risk on SAFETY surfaces. Ruled AGAINST it (a deviation from
  resume-prompt v4.7, for safety-surface restraint): the `.plain` buttons are never disabled (the
  R32.9 dimming concern doesn't apply), and the full-set audit legs are the permanent gate for
  panic/slip layout correctness from run 1 forward. The `.plain` → ButtonStyle adoption + the lint
  scope growth ride a later cleanup / UIR-5.
- **R35.5 (token adoption without shape change).** The redirect rows adopt `themedSelectionTint`
  (same render as the retired inline background); the confirm/undo neutral surfaces stay
  `surface/sunken` inline (NOT `themedCard`, which is raised+hairline — wrong semantic). No
  PrimaryButtonStyle/QuietButtonStyle adoption (they change shape — deferred). Motion tokens
  unchanged (panic `motion/calm` 0.6; slip `motion/standard` spring).
- **R35.6 (the reasons paging vs. scroll tension).** `StepScaffold` gained a `scrollsContent: Bool`
  flag: the redirect/breath/timer steps scroll (`true`), but the reasons step keeps its OWN paging
  scroll (`false`) so the two don't fight for the vertical gesture. Cost: at AX5 the reasons
  frame's TITLE truncates (the non-scrolling scaffold can't fit a wrapped `.title` + a
  full-viewport reason page + the pinned Skip). This is non-audited, non-regressing (the old
  scaffold was non-scrolling too), and AX5-only — a proper paging→scroll-list treatment at
  accessibility sizes is a UIR-5 AX-axis item, named.
- **R35.7 (scope fences held).** 64 class-A goldens re-recorded (delete → write-then-fail → adopt →
  green; each visually verified). Zero copy bytes; no privacy surface, no analytics motion, no new
  SPM dep; the dashboard, onboarding, widgets, Shared, and the packages all untouched → their
  goldens byte-stable (CI-proven both runs). Total golden count unchanged at 103 (the 64 shifted in
  place). All 22 panic/slip accessibility identifiers stayed on their elements (R33.8).

### Carried / known limitations
- **Reasons-frame AX5 title truncation (R35.6):** a UIR-5 AX-axis polish item (paging→scroll at
  accessibility sizes on the non-audited reasons frame).
- **`.buttonStyle(.plain)` on panic/slip + the lint-scope growth (R35.4):** deferred to a cleanup /
  UIR-5 (would force a shape-changing ButtonStyle refactor on safety surfaces).
- **The `motion/calm` ring appear animation (dashboard) + panic/slip motion polish** remain UIR-5.
- `SafetyResourcesView` still carries the last `.background(.quaternary` fill + a phone-number-only
  `Link` label — UIR-4's surface (paywall + settings + resources).
- The onboarding + paywall golden batch still waits on the founder's §3 copy pass (post-UIR, ONE
  re-record). Panic/slip/dashboard goldens are stable now (copy audited/data).
- Next: **Session 36 = UIR-4 (paywall (hard/teaser/winback) + settings + resources).**

## Session 36 — UIR-4a: resources + paywall (2026-07-18)

**Objective (resume-prompt v4.8):** regenerate the paywall + settings + resources on the Theme
layer, copy byte-identical; resources is a SAFETY surface (PM+Brand+QA pre-code sign-off). Budget:
2 billed runs + 1 contingency.

**Outcome: the DEFECT surfaces (resources + paywall) DONE in exactly 2 billed runs — contingency
UNUSED, ZERO burned. SETTINGS DEFERRED (R36.1).** Run 1 (`29618554339`) was red-by-design on the
snapshot lane (2 resources goldens write-then-fail) PLUS one unexpected red — the resources audit
leg's mount-gate (see R36.4); both were resolved in the run-2 commit (adopt goldens + gate fix). Run
2 (`29620086038`) is green. The 3-seat architect sign-off (PM+Brand+QA) passed.

### R36.1 — the scope split (settings deferred)

The workflow spec covered all three surfaces + 3 audit legs + a settings golden suite + the settings
List→ScrollView rebuild. That rebuild is the biggest structural risk (reimplementing List's cell
chrome/tint/separators by hand) and the LEAST essential (settings is not a safety surface; "keeps its
system container until UIR-4" is a canon note, not a defect). Ruled: ship the two DEFECT surfaces this
session — RESOURCES (two hard safety defects) and PAYWALL (R32.9 + a pre-existing contrast bug) — and
defer SETTINGS + its golden + the lint-scope-to-Monetization growth to a UIR-4 continuation. This kept
the session to a clean 2 runs and used the foundation (`PlanCardButtonStyle`, the new contrast pair).

### R36.2 — resources: the last two safety defects, closed

`SafetyResourcesView` was the last un-regenerated safety surface. (1) `.background(.quaternary)` — a
raw, contrast-UNREGISTERED system material — → `themedCard()` (surface/raised + hairline, all
content-on-raised pairs pinned). (2) **R33.10:** the helpline DIAL link — the one control the screen
exists to get tapped — was a ~22pt target with a phone-number-ONLY VoiceOver label; now a 44pt floor
(frame) + `.accessibilityLabel("Call <name>")` (the S33 blocked-screen precedent). Plus: explicit
Theme foregroundStyles on the 4 undeclared Text views, `.fixedSize` on every Text, a `@ScaledMetric`
decorative glyph, spacing tokens, and a test-internal `init(data:)` so the snapshot is
locale-independent. New audit leg + 2 goldens (light/dark, visually verified: clean themedCard + the
📞 988 DIAL link).

### R36.3 — paywall: three R32.9 fixes + a pre-existing contrast bug

The paywall was already Theme/text-style clean and scrolling, but carried three R32.9 disabled-`.plain`
violations (CTA, teaser-escape, winback-dismiss combined `.buttonStyle(.plain)` with `.disabled`, so
Apple's audit measured the explicit brandPrimary fill on the DISABLED control instead of the ghost
form). The CTA adopts `PrimaryButtonStyle` (the STYLE not the wrapper — R33.8 keeps `paywall.cta` on
the exact Button; the loading spinner tints content/secondary, visible on the ghost surface);
teaser/winback/restore adopt `QuietButtonStyle`; plan cards adopt the NEW pass-through
`PlanCardButtonStyle` (closes the future-disable R32.9 window without shape change). A PRE-EXISTING
bug is fixed: the failure banner was caution-text-on-caution-tint (~1:1); caution now rides the
DECORATIVE glyph only and the text is content/primary on `themedCautionCard` (13.7:1). NO paywall
goldens (R33.2, copy DRAFT); the existing `QuizFunnelUITests` smoke (paywall.cta + paywall.restore)
verified the restyle green in run 1.

### R36.4 — the mount-gate lesson: a full-screen `.contain` container id does NOT surface

The resources audit leg failed run 1 at its WAIT — not on an audit finding. Artifact-first diagnosis
(the S29 zstd/xcresult mine, free on Linux): `SafetyResourcesView` RENDERED fine (its "Call <name>"
DIAL Buttons were in the captured tree), but the `resources.screen` id — which sits on a **full-screen**
`.accessibilityElement(children: .contain)` container — never surfaced as a queryable element. The
dashboard card's `.contain` container surfaces as `.other` (S34) because it is BOUNDED (a card); a
full-screen `.contain` container is absorbed. **The rule (R36.4): gate an audit leg on a real CHILD
element that surfaces, not on a full-screen `.contain` container id.** The title Text gained
`resources.title` and the leg gates on it. Metadata only — the run-1 goldens were pixel-identical and
adopted; the gate fix rode the adoption commit, so the contingency was NOT spent.

### The rulings
- **R36.5 (new pass-through primitive):** `PlanCardButtonStyle` — suppresses `.plain`'s ghost-disabled
  dimming with only a pressed-scale, so plan cards (always enabled today) cannot regress on a future
  disable. No shape change.
- **R36.6 (new contrast pair, machine-verified):** `content secondary on selection tint` (the plan
  card price subhead) — 5.20 L / 6.77 D, verified on the free box before it could gate the build;
  `neverShrinks` floor 28 → 29. The registry is now 34 pairs.
- **R36.7 (lint scope NOT grown):** the R35.4 restraint precedent — growing to App/Sources/Monetization
  would require converting the inline retry `.plain` (a correct idiom for an inline text link); the
  paywall is otherwise idiom-clean and the QuizFunnelUITests smoke + the (deferred) audit leg are the
  gate. Rides UIR-4b with settings.
- **R36.8 (scope fences held):** copy byte-identical (a `HelplineRow` fixture with a phantom `verified`
  field was caught — the real struct has 4 fields); all a11y ids preserved (R33.8); no privacy surface,
  no analytics motion, no new SPM dep; every other surface's goldens byte-stable. 2 goldens minted
  (103 → 105).

### Carried / known limitations
- **SETTINGS (`DiscreetSettingsView`) restyle + its golden + the Monetization lint scope — UIR-4b
  (next session).** The full architect spec is preserved in the workflow journal (wf_b91f1762-aff) +
  `scratchpad/uir4-step0.md`.
- **The paywall + settings a11y-audit legs** (via UITEST_PAYWALL_DIRECT / UITEST_SETTINGS mounts) ride
  UIR-4b — the paywall's is deferred to avoid the intricate DEBUG PaywallView fixture on this run.
- Reasons-frame AX5 title (R35.6), the widget typography (R34.7), the StreakRing/panic-slip motion
  polish — all UIR-5.
- The onboarding + paywall golden batch still waits on the founder §3 copy pass.
- Next: **Session 37 = UIR-4b (settings) + as much of UIR-5 as fits** — the last agent-doable UIR work;
  after it the project blocks on the operator critical path (G0, §3 copy, §8 keys, device rows, beta,
  submission).

## Session 37 — UIR-4b: settings (2026-07-18)

**Objective (resume-prompt v4.9):** the deferred settings restyle (`DiscreetSettingsView`, the last
surface on raw iOS system-grouped List chrome — S32 canon deferred it to UIR-4), copy byte-identical.
Budget: 2 billed runs.

**Outcome: DONE in exactly 2 billed runs — ZERO burned. UIR-4 is now FULLY complete** (resources +
paywall in UIR-4a/S36; settings here). Run 1 (`29621524993`) red-by-design (2 settings goldens
write-then-fail; build/unit/UI-smoke green); run 2 (`29622400558`) green.

### R37.1 — in-place List theming (not the rebuild)

The architect spec was a `List → ScrollView + themedCard`-sections REBUILD. Ruled AGAINST it: reaching
that far into a screen and hand-reimplementing List's cell chrome/spacing/dividers is the biggest
structural risk AND throws away List's native cell accessibility (worse for the audit). Instead the
List is themed IN PLACE — the lower-risk, higher-accessibility path: `.scrollContentBackground(.hidden)`
+ a `surface/base` backdrop, `.listRowBackground(surface/raised)` per Section, `.tint(brand/primary)`
on the Toggles, and explicit Theme tokens on the header/footer (`content/secondary`, `.textCase(nil)`)
and the Toggle/Label text (`content/primary`). The 8 raw-system color sites all move onto the Theme
layer while the List stays a List. Visually verified (the golden): the system-grouped background is
gone, replaced by `surface/base` with a clean `surface/raised` rounded cell.

### The rulings
- **R37.2 (scope: theming + golden only).** The settings + paywall a11y-audit legs (via
  UITEST_SETTINGS / UITEST_PAYWALL_DIRECT) and the Monetization lint-scope growth are DEFERRED to a
  follow-up / UIR-5. This session scopes to the theming and its visual regression guard — the smaller,
  lower-risk surface. The themed List keeps native cell accessibility, so an a11y regression from the
  color-only change is very unlikely; the audit legs are additions, not a regression guard for the
  theming (the golden is).
- **R37.3 (a minimal golden, honestly bounded).** `DiscreetSettingsView(onResourcesRowTap: {})` with
  no `RepositoryProvider` renders the nav title + the resources row only (the per-quit toggles / icon
  picker / haptic-pacer / winback sections need a repository). Full-section coverage waits for a mock
  QuitRepository (named). 2 goldens minted (105 → 107).
- **R37.4 (scope fences held).** Copy byte-identical (`DiscreetSettingsCopy` untouched — its 12
  Mirror-walked strings intact; no new copy property, which would break `DiscreetSettingsCopyTests`);
  both a11y ids (`settings.winback.row` / `settings.resources.row`) + the icon picker's `.isSelected`
  trait stay put (R33.8); the three List-row `.buttonStyle(.plain)` are correct never-disabled idioms
  and are kept (R35.4); no privacy surface, no analytics motion, no new SPM dep. Every other surface's
  goldens byte-stable.

### Carried / known limitations (all → UIR-5 or a follow-up)
- **The settings + paywall a11y-audit legs + the Monetization lint scope** (R37.2).
- **Full settings golden coverage** (needs a mock QuitRepository, R37.3).
- **UIR-5 proper:** motion/polish (the `StreakRing` motion/calm appear animation; panic/slip motion),
  the AX5-axis items (the reasons-frame AX5 title R35.6; the widget typography defects R34.7 — these
  re-record ~13 widget goldens, budget explicitly), and the consolidated golden-batch prep for the
  operator's §3 sitting.
- The onboarding + paywall golden batch still waits on the founder §3 copy pass.
- Next: **Session 38 = UIR-5** — the LAST agent-doable UIR session. After it, the agent-doable UIR
  work is COMPLETE and the project is BLOCKED on the operator critical path (G0 rename, §3 copy pass,
  §8 keys + sandbox matrix, device rows + E0.3 latency, external beta, submission).

## Session 38 — UIR-5a: the deferred audit legs + the Monetization lint scope (2026-07-18)

**Objective (resume-prompt v5.0):** close the UIR-4a/b deferred items — the settings + paywall
a11y-audit legs + the Monetization layout-lint scope. Budget: 2 billed runs.

**Outcome: DONE in 2 billed runs — the PAYWALL is now audited + the Monetization directory is
lint-enforced; the SETTINGS audit leg is DEFERRED (a system finding — R38.2).** No goldens (audits
mint no PNGs; the lint growth is born-green). No golden churn — all 107 goldens byte-stable.

### R38.1 — the paywall joins the audited surfaces
`test_a11yAudit_paywall` (UITEST_PAYWALL_DIRECT → the hard-variant `PaywallView` over a fixture with
inert `.failed` closures) passed the full 7-type set CLEAN on its first run — the paywall's S36 fixes
(PrimaryButtonStyle CTA, the failure-banner contrast fix, PlanCardButtonStyle) hold under the audit.
The a11y audit now covers 8 surfaces: age gate, quiz, summary, dashboard, panic, slip, resources,
paywall. `App/Sources/Monetization` joined the layout-lint scope (the inline retry `.plain` → the
pass-through `PlanCardButtonStyle`; rehearsed free — 48 files, zero violations; floor 12 → 35).

### R38.2 — the settings audit leg, DEFERRED (a system large-title finding)
The settings audit fired `.dynamicType` + `.textClipped` on run 1. Artifact-first diagnosis: the
audit's own element context names the navigation-bar LARGE TITLE ("Discreet Mode", NavigationBar /
LargeTitle) — a SYSTEM large-title behavior (it does not fully scale with Dynamic Type and clips), NOT
the themed content (the List cells + the resources row are clean). Not an OS-flake, so not
valve-material; the leg + its mount + env-var were REMOVED (no dead code). The fix — a custom /
`.inline` title, which re-records the settings golden — and the leg's re-addition ride UIR-5b.

### Also (run 1, honest accounting)
Run 1 (`29623574788`) was red on the settings finding above AND an UNRELATED unit FLAKE
(`EraseEverythingTests.test_erase_triggersDebouncedWidgetReload` — a timing-sensitive debounce test
that passed in S37 and that UIR-5a touches nothing near); it resolved on run 2 (`29624490777`, all
green). The two billed runs = run 1 (finding + flake evidence) + run 2 (the settings-leg deferral).

### Carried → UIR-5b (the FINAL UIR polish session)
- **The settings large-title DT/clip fix** (custom/inline title) + re-adding the settings audit leg.
- **Motion/polish:** the `StreakRing` motion/calm appear animation (mind snapshot determinism — the
  ring renders SETTLED today for exactly that reason; disable the animation in snapshots or accept a
  golden re-record).
- **Widget typography (R34.7):** rectangular numeral + micro-labels — re-records ~13 widget goldens
  (delete → red → adopt; luminance-only, never Theme).
- **Reasons-frame AX5 title** (R35.6, paging→scroll at accessibility sizes).
- **The consolidated golden-batch PREP** for the operator §3 sitting.
- Next: **Session 39 = UIR-5b** — the last agent-doable UIR work; then the project is fully
  operator-gated (G0 rename, §3 copy, §8 keys + sandbox, device rows, external beta, submission).

## Session 39 — UIR-5b attempt 1: the settings audit leg, DEFERRED to its true depth (2026-07-18)

**Objective (resume-prompt v5.1):** the settings large-title fix + re-add the settings audit leg
(the UIR-5a R38.2 deferral), then motion/widget-typography/reasons-AX5. Budget: this item planned 2
billed runs.

**Outcome: the settings audit leg is DEFERRED — the settings LIST CONTENT (not just the title) has
STRUCTURAL Dynamic-Type/clip findings.** Two billed runs bought the DIAGNOSIS; the attempt then
reverted to the UIR-5a green state (byte-identical to c7dcead — goldens restored, leg/mount/env
removed, nav-bar title restored). No net feature; the value is a precise characterization.

### R39.1 — a title in a LIST ROW clips exactly like the nav bar (run 29625700044 REFUTED it)
The first fix moved the title off the nav-bar large title into the List content as a scalable
`.largeTitle` text style **in a List row**. Artifact-first (zstd/xcresult): the audit fired BOTH
`.dynamicType` "partially unsupported" + `.textClipped` on the NEW `settings.title` — a List row is
height-constrained like the nav bar, so a `.largeTitle` inside it still caps its growth and clips.
"Partially unsupported" is the SYMPTOM of the clipped frame, not the font.

### R39.2 — the title fix works free-standing, but the LIST SECTION FOOTERS clip (run 29626434269)
Moving the title to a FREE-STANDING `Text` ABOVE the List (`.fixedSize(vertical:)`, the List yields
the space) FIXED the title — `settings.title` stopped being flagged. But the audit then flagged the
settings LIST CONTENT: the long haptic-pacer SECTION FOOTER ("The breathing exercise guides you...")
fires `.dynamicType`+`.textClipped` at AX5. That footer uses NO explicit font (List's default
scalable footnote) — there is nothing to fix in the font. **List SECTION FOOTERS clip at
accessibility sizes: a STRUCTURAL issue.** The audit mount renders the FULL settings (a
RepositoryProvider flows from the app root into the debug mount), so every long footer is in scope.

### Why deferred (budget-reality R + the "NO issue handler anywhere" canon)
The house rule forbids valving (no issue handler), so each finding must be FIXED. Completing the
settings audit means moving every long List section footer out of the `footer:` slot into scalable
in-content rows AND re-recording the settings goldens — an unknown-depth whack-a-mole at 1 billed run
per iteration (~4+ runs) on a polish surface. Deferred with the fix now KNOWN on both axes:
  - **title:** a free-standing `.largeTitle` `Text` ABOVE the List (proven to pass).
  - **content:** move long section footers OUT of List `footer:` slots into scalable rows.
A future dedicated pass should enumerate ALL findings from ONE run (or a local macOS run) and fix
them wholesale, then re-record — never whack-a-mole.

### Honest accounting + the [skip ci]-in-body trap
Billed runs this item: 2 red (the two attempts) + this revert-confirm run = 3, with ZERO net feature
— the cost of an iceberg on an un-pre-audited surface. Also logged: the revert commit's BODY carried
the literal string "[skip ci]" (in a sentence about the follow-up docs commit) and GitHub SKIPPED its
CI run — `[skip ci]` is honored ANYWHERE in the message, not just a docs-only subject. NEW STANDING
NOTE: never write the literal token in a commit body unless you intend the skip.

### The 8 audited surfaces are unaffected; UIR-5b's other items remain
Age gate, quiz, summary, dashboard, panic, slip, resources, paywall stay audited + green. Carried to
a future UIR-5c: the settings-content audit (characterized above), the `StreakRing` motion, the widget
typography (R34.7, ~13 goldens), the reasons-frame AX5 title (R35.6).

## Session 40 — UIR-5c item 1: widget typography R34.7 (2026-07-18)

**Objective:** close the S34-deferred widget typography defects (brandkit §3 `type/widgetNumeral` +
`type/widgetLabel`). Budget: 2 billed runs.

**Outcome: DONE in exactly 2 billed runs, ZERO theory-failures** — the contrast with the S39 settings
iceberg is the lesson: an up-front verification workflow made run 1 correct on the first try.

### The verification workflow (wf_df8c942c-94b) earned its keep
Before touching any golden, an 8-agent workflow (3 parallel readers — brandkit spec, code call-sites,
golden mapping — → 5 adversarial critics) verified the planned change. It caught a **BLOCKER 4/5 critics
independently flagged that the first plan missed**: line 168's rectangular `Text("\(money) \(savedLabel)")`
bundles the "saved" micro-label into one `.caption2` string, so fixing only the medium family's
standalone label would have left the rectangular "saved" off-spec. The fix SPLIT that line. The workflow
also confirmed: numeralRounded=FALSE (SF Compact in widgets; rounded is the dashboard hero only),
rectangular is the ONLY numeral defect (circular ~17pt, small/medium ≥20pt already fine), the API is all
valid (`.system(size:weight:).monospacedDigit()`, `Text.tracking(_:)`), no copy-text change, and the
delete-list is EXACTLY 9 goldens (discreet-medium excluded — `showsMoney`/`showsMilestoneLabel` are
`!isDiscreet`).

### The change (`Shared/Sources/StreakWidgetViews.swift` — luminance-only, no Theme)
1. Rectangular day NUMERAL: `.headline` (~17pt) → `.system(size: 20, weight: .semibold).monospacedDigit()`.
2. Rectangular money+"saved": SPLIT — money `.system(size:12,weight:.medium).monospacedDigit()`, "saved"
   `.system(size:12,weight:.medium).tracking(0.3)`.
3+4. Medium `savedLabel` + `milestoneLabel`: `.caption2` → `.system(size:12,weight:.medium).tracking(0.3)`.

### The golden maneuver (R32.4 red→adopt→green)
Run 1 (9142a72 / 29650601143): build/unit/uismoke GREEN (widgets not audited), snapshot RED — the suite
failed on EXACTLY 9 issues (the predicted set), every other widget golden matched its reference (no
spurious diff). All 9 recorded goldens VISUALLY VERIFIED from the artifact: the 20pt numeral fits the
172×76 canvas; "$124 saved" reads as one unit; the unavailable "Ready when you are." wraps to 2 lines
with NO clip (validating the conservative `.semibold` — `.bold` risked a 3-line wrap); medium labels at
12pt Medium tracking; AX5 labels stay legible at fixed 12pt (the "Day…"/"788:0…" truncation is
pre-existing, not from this change). Run 2 (01f6b89 / 29651280749) adopted the 9 (20 unchanged untouched;
total stays 29) → ALL GREEN. R34.7 CLOSED.

### Flagged for the operator/brand (neither blocks)
- Numeral weight is `.semibold` (lighter end of §3's Semibold–Bold range); `.bold` is the "heaviest
  that fits" upgrade the §3 note leans toward — held pending a render check (the 2-line unavailable wrap
  shows semibold is safe; bold's overflow margin is unverified).
- The medium home-screen labels are now FIXED 12pt (do not scale at AX5) — intentional per §3's fixed
  micro-label size; a home-screen a11y tradeoff (they render complete + legible; the alternative is
  `@ScaledMetric` if scaling is later wanted).

### Carried → UIR-5c remaining (all INDEPENDENT)
`StreakRing` motion (golden-determinism-sensitive), reasons-frame AX5 title (R35.6, panic golden churn),
the settings-content audit (S39 iceberg, deferrable), golden-batch PREP.

## Session 40 — UIR-5c items 2–4: reasons AX5, StreakRing motion, golden-batch prep (2026-07-18)

Three more UIR-5c items, all executed with the verify-then-execute pattern (a workflow sized to each
item's risk). **UIR-5c is now substantively COMPLETE** — every agent-doable UIR item is done except the
DEFERRED settings-content audit (S39 iceberg). The 4th UIR-5c item (item 1, widget typography R34.7) is
ledgered above.

### R35.6 — the reasons-frame accessibility-size fix (DONE, 2 billed runs)
The panic "your reasons" step used full-viewport PAGING (`scrollsContent: false`), so at accessibility
sizes the non-scrolling scaffold left no room to wrap a grown `.title` → the title truncated (a known
S35 deferral). Fix (`ReasonsStepView`): gate on `@Environment(\.dynamicTypeSize).isAccessibilitySize` —
at AX sizes (AX1–AX5) the scaffold scrolls and the reasons flow at natural height in a
`VStack(spacing: Theme.space.s8)`; at normal sizes the paging is byte-for-byte unchanged. Pure LAYOUT
(zero copy/register/color). An 8-agent workflow (wf_7f688e69-430) verified it, with the standout
finding that the change is a **DOUBLE no-op for the rule-11 panic audit** — (1) the audit runs at
default size (isAX=false → the unchanged path), and (2) the reasons frame isn't even audited (the leg
uses its title only as a nav waypoint; the audit fires on the redirect + exits frames). Applied the
workflow's two refinements (`Theme.space.s8` not a magic 32; framed AX1–AX5 not AX5-only). 4 reasons-AX
goldens re-recorded + all VISUALLY VERIFIED (the title "Why you started" now wraps fully instead of
truncating; the reasons/fallback scroll; the Skip stays pinned). Runs 22b323d → 7a79a6f, both green.
FLAGGED (non-blocking): per-reason paging (§6.11) is traded for a scroll at AX sizes (where a single
`.largeTitle` reason overruns a page anyway); the reasons step has a PRE-EXISTING audit-coverage gap
(a tracked follow-up).

### StreakRing motion (DONE, 1 billed run, ZERO golden churn)
The momentum ring gained its `motion/calm` (0.6s ease-out) APPEAR animation (fill sweeps 0→fraction) —
the S34-deferred dashboard motion. GOLDEN-SAFE by construction: `StreakRing.animateOnAppear` defaults
to FALSE, and when false `shownFraction` reads `fraction` DIRECTLY (not the `@State`), byte-identical to
the pre-motion draw — so snapshots + the audit mount capture a SETTLED ring and the 8 dashboard goldens
do NOT move (the ring is `.accessibilityHidden`, so the audit is untouched too). `StreakDashboardCard.
animateRing` (default false) threads the opt-in; ONLY the live `RootPlaceholderView` passes true. A live
momentum update sweeps on the same curve (`.onChange`); the settled path reads `fraction` directly so it
can never go stale. Run bccc262 = ALL GREEN, no golden churn (CI confirmed the byte-identical settled
render). The animation renders only at runtime, so a golden cannot verify it — FLAGGED for the
operator's dashboard DEVICE-EYEBALL (fail-safe: worst case is a cosmetic timing tweak).

### Golden-batch PREP (DONE — `docs/golden-batch.md`)
A zero-run deliverable enumerating the ONE final snapshot re-record for the operator's §3 copy sitting:
the 107 current goldens are all STABLE on the finished design system; the FINAL BATCH is the onboarding
(age gate/quiz/summary) + paywall goldens that DO NOT EXIST YET (draft copy, R33.2) and get MINTED when
the founder finalizes copy (~12–20 goldens, one red→adopt→green pass). Plus the re-record triggers, the
device-eyeball items, and the mint mechanics.

### UIR-5c status + what remains
DONE: widget typography (R34.7), reasons AX5 (R35.6), StreakRing motion, golden-batch prep. DEFERRED:
the settings-content audit (S39 iceberg — the fix is characterized; needs enumerate-all-findings-from-
one-run, ideally a local macOS run). **After UIR-5c the agent-doable UIR work is COMPLETE** — the
project is fully operator-gated (G0 rename, §3 copy pass + the golden batch, §8 keys + sandbox, device
rows + E0.3 latency + the UIR-5c device eyeballs, external beta, submission).

## Session 40 (addendum) — the settings-content audit: attempted on CI, DEFERRED with a complete diagnosis (2026-07-18)

At the operator's request ("go ahead with the settings-content audit on CI"), re-opened the S39
iceberg with the **enumerate-ALL-findings-from-ONE-run** discipline. FIVE CI runs converged on a
complete diagnosis — a decisive improvement over S39's blind whack-a-mole (each run named its exact
survivor; findings went 2 → 1 → 1 → 1 → 1) — but the tail finding is not resolvable via CI iteration,
so it reverted to green (52eafa6, byte-identical to f43db52; 2 goldens restored, leg/mount/env removed).

**Two of three defects FIXED (known-good for a Mac session):**
- Title (`settings.title`): a FREE-STANDING `.largeTitle` `Text` ABOVE the List (R39.2). The nav bar
  AND a List row both clip it; only free-standing grows. Verified not-flagged from run 1.
- Long section footer (`hapticPacerFooter`): moved OUT of the `footer:` slot (whose height the system
  CAPS — `.fixedSize` cannot override it) into a self-sizing `captionRow`. Verified cleared in run 2.

**The unsolved blocker — the resources row ("Support & resources"):**
- A native `Label` TRUNCATES (→ `.textClipped`), even with `.lineLimit(nil)` + `.fixedSize` (runs 1, 5).
- An explicit `HStack{Image;Text}` clears the clip but BREAKS the native icon+title co-scaling the audit
  wants → `.dynamicType` "partially unsupported" persists even at full width with a scaling icon (runs
  3, 4).
- A plain-`Text` row (the captionRow) passes BOTH — but it is not a Button.
- ⇒ a genuine **Button + wrapping-title Dynamic-Type conflict**. Pinning the exact failing content-size
  needs Xcode's **Accessibility Inspector** (interactive), NOT more CI guessing.

**Runs:** 29657891269, 29658654073, 29659267855, 29660062351, 29660822632 (5 red-by-enumeration) + the
revert (29661516821, green). Honest budget note: 5 runs this session (8 incl. S39) — every run was
diagnostically productive, but the resources row resisted a CI-only fix.

**Terminal state:** the settings-content audit is a MAC-GATED item now. A future session with a Mac
applies the two known-good fixes (title, footer), solves the resources-row DT with the Accessibility
Inspector, re-adds the leg (gate on `settings.resources.row`, R36.4) + its UITEST_SETTINGS mount, and
re-records the 2 settings goldens — landing all of it together. Until then settings stays exactly as the
operator last saw it (8 audited surfaces; all 107 goldens stable; all lanes green).

## Session 41 — completion audit + operator-handoff hardening (docs-only, ZERO billed runs) (2026-07-19)

**Goal (self-determined at open):** the resume prompt handed off a project claimed COMPLETE for everything
an agent can do without a Mac or the operator, blocked on the operator critical path. The autonomous-loop
mandate is to continue until the roadmap is complete OR blocked by a human dependency — so this session's
job was to (a) INDEPENDENTLY VERIFY that "no agent-doable work remains" is not premature, (b) do whatever
legitimate agent-doable work the verification surfaces, (c) if the block is genuine, document it cleanly
and declare the human-dependency boundary. **No new build work was invented; no CI run was spent.**

**Method:** a 5-agent audit workflow (wf_722da0bc-616) assessed each remaining-work dimension independently
— verify-green (RAN the free lanes), settings-mac-gate (stress-tested the conclusion), enumerate-deferred
(swept the whole tree + docs for every deferred/carried/candidate item), doc-completeness (audited the
operator-facing docs), roadmap-forward (Phases 3/4/5). Then an adversarial fact-checker verified the new
docs against the repo before commit.

**Verdict — the build is GENUINELY green, not a premature claim** (verify-green RAN it, did not trust docs):
StreakEngine 84/84 + WidgetToolkit 21/21 + PaywallKit 16/16 = **121 free-lane tests pass, 0 failures**; all
four grep lint gates reproduce zero violations locally; the strict-concurrency probe on StreakEngine builds
clean; the last code-touching CI run (29661516821, 52eafa6) is SUCCESS on all 9 jobs. Working tree clean,
local main == origin/main, 107 goldens stable.

**Verdict — the project is on the OPERATOR CRITICAL PATH and there is NO remaining agent BUILD/FEATURE work
that a Linux agent can do.** Every open item classifies as operator-gated, device-gated, mac-gated, or
future-phase (post-launch, roadmap §6 forbids scope creep). The one CI-doable UIR remainder (the
settings-content audit) is confirmed mac-gated. This is the terminal state for the autonomous build loop:
**further progress is blocked on human/operator dependencies** (see the operator critical path — G0 rename,
§3 copy pass, §8 keys + sandbox, device sittings + E0.3, external beta, submission).

**R41.1 — the one new technical finding (the settings resources-row `.accessibilityHidden` candidate).** The
S40 addendum framed the blocker as a generic "Button + wrapping-title Dynamic-Type conflict needing the
Accessibility Inspector." The mac-gate agent refined it: the `iconRow` in the SAME settings screen
(`DiscreetSettingsView.swift:188`) PASSES the full audit using `Button{HStack{Text; Spacer;
Image.accessibilityHidden(true)}}` — its decorative icon is hidden from the accessibility tree, leaving the
Button's label pure scalable text. **NONE of the 5 S40 runs hid the resources-row icon** (`resourcesRow()`
at :96–103 uses a plain `Label(...,systemImage:"lifepreserver")`; runs 3/4 used a *visible* HStack icon,
which is why "partially unsupported" persisted). The untried candidate: apply the iconRow pattern to
`resourcesRow`. It CANNOT be verified without a Mac/billed run (whether Apple's `.dynamicType` check fires
at the Button-element or Text-child level is not knowable by reasoning), so it was NOT authored into the
`.swift` (that would cost a billed run and touch an audited surface unverified); it is RECORDED as the
"try-first" step in the Mac-session handoff (`critical-path-post-uir.md` settings section). This likely turns
the Mac session from interactive Inspector debugging into "apply the pattern + confirm."

**R41.2 — the "support the operator, don't invent build work" ruling, made concrete.** With no agent build
work left, the legitimate agent value is entirely in hardening the operator handoff. Deliverables, all
docs-only, `[skip ci]`, zero billed runs:
- **`docs/critical-path-post-uir.md` (NEW)** — the single-page operator playbook: the 11-step launch
  sequence (owners + time + what-unblocks-what), the consolidated Open-decisions table (OQ-1, OQ-2, R24.9,
  win-back ratification, ALO-182, Terms/Privacy links, E0.3 verdict, …), the settings Mac-gate handoff (with
  R41.1), the two "say the word" agent-executable items, and a "what is DONE" floor. This is the operator's
  new entry point (they just inherited the whole project with the path scattered across 1765 lines).
- **`docs/copy-pass-checklist.md` (NEW)** — the §3 copy pass as a flat, printable, file-by-file checklist
  (11 copy files/tables + the rides-along items), each tagged founder-rewrite / clinician-gate / verify /
  confirm-literal / decision. The §3 copy pass is the longest-lead operator task and gates the golden batch.
- **`docs/review-notes.md` (FIXED — highest-risk, it pastes to Apple):** removed two "…the user's own
  iCloud" mentions that implied live cross-device sync (violating the doc's own §4 register ban — CloudKit
  sync is NOT live, `cloudKitDatabase == .none`); marked §3 item 5 (R30.6) CLOSED with its S31 evidence
  (`PrivacyManifestTests`, CI 29290910960) instead of "real submission blocker" — it was fixed 10 sessions
  ago. An operator pasting the pre-fix text would have sent Apple a stale blocker + a false sync claim.
- **`docs/operator-expected.md` "Runway to launch" (FIXED):** it still listed "the UI Reactor (~6 agent
  sessions)" as step 1 — rewritten to post-UIR reality (UIR done; the operator critical path is all that
  remains) with a pointer to the new playbook. (The S41 session header + this session's summary are added in
  the operator's voice.)
- **`docs/testflight-tester-guide.md` (FIXED):** the "build worth distributing right now is `8a0c469`"
  reference was from Session 15 (25 sessions stale) — now "take the newest build in ASC → TestFlight".
- **Carried-debt staleness cleaned** (in the regenerated resume prompt): the "SafetyResourcesView still
  carries `.background(.quaternary)` + a phone-number-only Link" debt is FALSE (fixed S36 — line 215 is
  `.themedCard()`, the Link carries a "Call <name>" label); the widget-typography R34.7 debt is FALSE (done
  S40). Both removed.

**Two agent-executable items held for operator "say the word"** (each costs ~1 billed macOS run to land+verify,
so not spent unilaterally per BUDGET REALITY; neither blocks submission): (1) a born-green free-Linux grep
lint enforcing "no account-creation path" (closes the explicit submission-checklist gap; also bundle the
monetization-importer lint into the TestFlight job's `needs:`); (2) `ITSAppUsesNonExemptEncryption=false` in
the Info.plist via project.yml (removes the export-compliance prompt at every TestFlight upload).

**Operator action required THIS session: NONE** — this was an audit/docs pass. But the project as a whole is
now BLOCKED on the operator critical path; the autonomous build loop has reached its terminal state. See
`docs/critical-path-post-uir.md` and `docs/operator-expected.md`.

**Budget:** ZERO billed runs (docs-only, `[skip ci]`; docs/** + **.md are `paths-ignore`d regardless). The
audit workflow + fact-checker ran on the free agent pool.
