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
