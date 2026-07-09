# Resume Prompt: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Resume Prompt v1.9 |
| Last updated | 2026-07-09 (Session 07 close: E2.3 DONE + engine v1.2.0 + LKG witness; TestFlight bundle-version fix — build 23 is the first REAL numbered upload) |
| Phase | Phase 1 core build — Epics 0–1 CLOSED; E2.1 + E2.2 + E2.3 DONE and CI-verified |
| Next session objective | **E2.4 — one-tap erase (local + CloudKit seam + caches)** |

> **What changed in Session 07:** E2.3 is DONE and CI-verified (red 28996554955 →
> green 28997109088 → review-red 28999392466 → review-green on aaf36fe; all test
> lanes + coverage gate green throughout). StreakEngine is **1.2.0** (tagged
> `streakengine-v1.2.0`): `healFrozenStreak` — the ADR-7 freeze-then-resume healing
> re-anchor, over-cap arm only, option-(iii) mint (startAt+anchor only; createdAt
> never resets). `recomputeDerivedState()` landed in QuitRepository: deterministic
> dedupe merge (commutative+idempotent, property-tested) + heal pass + witness
> restart. **The LKG is now a conservative WITNESS** (Session 07 ratified extension —
> see standing rules below; READ the Session 07 "Key decisions" before touching any
> clock code). TestFlight correction: XcodeGen hardcoded CFBundleVersion "1", so
> Session 06's "build 20" actually uploaded as bundle version '1'; fixed (2a46abc) —
> **build 23 (0.1.0) uploaded, ASC accepting it proves per-run versioning works.**

---

## Standing tooling rule — CodeGraph (permanent, applies to every agent)

The repo is CodeGraph-indexed (`.codegraph/`, machine-local). **Query it first**: use
the `codegraph_explore` MCP tool (shell: `codegraph explore "<symbols or question>"`)
BEFORE grep/find or manual file reading — one call returns verbatim line-numbered
source + call paths + blast radius. Pass this instruction into every subagent/workflow
prompt. Check dependents before editing public symbols. **Before the session-end
commit, run `codegraph sync` and confirm `codegraph status` is clean.**

## Where we are

- **StreakEngine 1.2.0** (tagged, 84/84, llvm-cov 100/100/100, merge-blocking gate
  live): guard + reboot cap + `healFrozenStreak` (heals ONLY the across-reboot
  over-cap freeze; every other arm nil; banked fields/trackedSince immutable;
  conservative momentum). Semantics ratified in Sessions 03–07 "Key decisions" in
  `past-prompts.md` — READ THEM before touching the engine.
- **QuitRepository** (`App/Sources/Persistence/QuitRepository.swift`, @MainActor, the
  sole SwiftData importer — CI grep enforces): createQuit (max-3), synchronous
  logSlip, logUrgeEvent, activeQuits (now with a deterministic id tiebreak),
  streakValue (guard + witness end-to-end), debounced widget reload, and
  **recomputeDerivedState()** — dedupe merge (fold over same-id groups; children
  re-parented BEFORE deletes; QuizProfile re-pointed; no-op fast path) + heal pass +
  once-per-boot witness restart. Wiring to app launch / remote-change notifications
  deliberately DEFERRED to E3.1 / the §4.3 flip.
- **LKG witness discipline (Session 07, ratified — do not weaken):** the device-local
  reading (`LastKnownGoodStore`, App Group defaults, never the mirrored store) is a
  conservative WITNESS — a provable lower bound on elapsed time. Three advance paths:
  (1) the Session-06 two-gate real-wall advance (.normal vs pre-existing anchor AND
  continuity) — unchanged, preferred, the ONLY path that writes a raw wall;
  (2) heal-time restart += min(gap, cap), ONCE PER BOOT (bootID-gated);
  (3) same-boot uptime accrual (never consults a wall). Per-reboot unverifiable
  optimism ≤ cap, cumulative — the ratified in-window-channel parity bound.
  Known, documented slop: ≤ tolerance (60 s)/reboot via re-certification after a heal.
- **TestFlight: LIVE with real build numbers.** Every green merge to main uploads;
  CFBundleVersion routes through `$(CURRENT_PROJECT_VERSION)` (per-run), marketing
  version `$(MARKETING_VERSION)` = 0.1.0. CI signing read-only; never re-enable
  MATCH_BOOTSTRAP without an operator decision.
- **Brand kit (`brandkit/`)**: consult before any UI/copy/icon work. E2.4 has no UI
  beyond a possible smoke-test hook.

## Next session objective (one session, definition of done below)

**E2.4 — one-tap erase** (`implementation-plan.md` E2.4, deps E2.1 ✓ E2.2 ✓),
strictly test-first (session-rules mechanics: package/app red evidence as usual):

1. The plan's named red tests, scope-adjusted to what exists TODAY:
   `test_erase_deletesBothStoreFiles` (today = the single product store's file set —
   the non-mirrored companion store is E12; assert the store files that exist and
   leave a scope note), `test_erase_requestsCloudKitZoneDeletion` (a protocol seam +
   mock — real CloudKit purge is contract/device-tier; the store is still
   `cloudKitDatabase: .none`), `test_erase_clearsPanicPreCacheDefaults` (App Group
   defaults — TODAY that includes the LKG WITNESS: erase must clear it; a fresh
   install has no witness, and a stale one would poison the next tracking era),
   `test_erase_appRelaunch_startsAtOnboarding` (UI smoke lane),
   `test_iCloudUnavailable_appFunctionsFullyLocal` (mocked account status).
2. Erase is repository/service-layer work (architecture §10 sequence, §6 — erase is
   the complement of no-accounts); the sole-importer lint must stay green.
3. RevenueCat cache clear and the final analytics event are DEFERRED to their epics
   (E7/E8 — neither SDK nor events exist yet); leave named TODO seams, not stubs.

Scope guards: no UI (settings screen is a later epic), no real CloudKit, no paywall,
no widget rendering; never weaken a QA assertion; `logSlip` stays synchronous-local;
monotonic fields never decrease (undo is the one sanctioned exemption); no
`Date()`/`ProcessInfo` outside the sanctioned seam.

---

## Resume prompt (copy-paste for next session)

> You are the lead build agent for **unhooked-quit-widget** (app name **Ballast**, org
> `com.beyondkaira`). Epics 0–1 CLOSED; E2.1–E2.3 DONE and CI-verified; StreakEngine
> is 1.2.0 (tagged) with the ADR-7 heal live and coverage floors at 100%. Local Swift
> toolchain: `. ~/.local/share/swiftly/env.sh`. **CodeGraph is a standing rule:**
> `codegraph_explore` first for any code question (pass the rule to every subagent),
> blast-radius before edits, and `codegraph sync` + `codegraph status` before the
> session-end commit. Read `docs/session-rules.md`, `docs/implementation-plan.md`
> (E2.4), `docs/architecture.md` §6/§10/ADR-2, `docs/test-suite.md` §1.2/§7, and the
> Session 03–07 entries in `docs/past-prompts.md` before writing anything — the
> Session 07 entry defines the LKG WITNESS discipline (three advance paths) that
> erase must respect (and clear).
>
> **This session: E2.4 — one-tap erase**: the named red tests (store-file deletion,
> CloudKit zone-deletion seam with a mock, App Group defaults clear INCLUDING the
> witness, relaunch-to-onboarding smoke, fully-local mode) — scope-adjusted per
> resume-prompt §objective (companion store is E12; RevenueCat/analytics clears are
> E7/E8 seams). Test-first; repository stays the sole SwiftData importer (CI-linted).
>
> **At session end:** append the Session 08 entry to `docs/past-prompts.md`, overwrite
> `docs/resume-prompt.md` with the next objective (per `roadmap.md` — E3.1 panic
> path productionizing is the natural successor), run `codegraph sync`, commit, push,
> and verify GitHub Actions is green (`gh run watch`). Fix small CI issues
> immediately; document large ones at the top of the next resume prompt.

## Operator-owned blockers (not agent work; carry until closed)

1. ASC-side TestFlight follow-ups: export-compliance prompt if ASC asks
   (ITSAppUsesNonExemptEncryption already false), add internal testers. TestFlight
   now shows **0.1.0 (23)** — the '1' build from the bundle-version bug can be
   expired/ignored in ASC.
2. Slack webhook hygiene (optional): rotate the incoming-webhook URL that briefly sat
   in local git history; CI reads `secrets.SLACK_WEBHOOK_URL` now.
3. E0.3 device measurement (`docs/spike-panic-latency.md`, iPhone 15-class, full
   Xcode needed) — unchanged.
4. Content sign-off before ship: clinician/legal pass on `safetyCopy.json`, 3 helpline
   verify-flags, TR L10n (see `App/Resources/Content/REVIEW.md`) — unchanged.
5. Drift decision: MVP §7 "<2s 10/10" vs test-suite §1.5 "p90 < 2s" — unchanged.

## Standing rules reminders (do not relearn these)

- No shame copy; no medical claims; no red anywhere in UI; discreet variants mandatory.
- Analytics via the closed `AnalyticsEvent` enum only; zero events before opt-in;
  `logSlip` stays synchronous-local.
- Monotonic fields (`bestStreakSeconds`, `totalCleanSeconds`) never decrease — undo is
  the ONE sanctioned exemption; streaks freeze, never inflate (ADR-7); the heal
  resumes, it never credits beyond verified + cap.
  `Quit.totalCleanSeconds` is BANKED-only (== engine `priorCleanSeconds`).
- WITNESS discipline (Session 07): three advance paths only — two-gate real-wall
  (unchanged), once-per-boot heal restart ≤ cap, same-boot uptime accrual. No path
  may ever write an unverified wall; createQuit never refreshes it; never hardcode a
  verdict. Merge rules are ratified in the Session 07 ledger — determinism
  (commutative+idempotent) is a tested acceptance criterion, not a style choice.
- Undo lifecycle (flag=true, finalize sweep, undoSlip, isPendingUndo index) is E4.1's,
  as ONE unit. `#Index<Slip>([\.at])` → first time-ordered query; UrgeEvent.at → E12.4.
- Panic path stays thin (ADR-6). Single CloudKit-mirrored SwiftData store; no accounts,
  no backend (ADR-2). Never re-introduce `dev.placeholder.quitwidget`. Never weaken a
  QA assertion; TDD red first, always (test-suite §7); red evidence = local swift test
  for packages, the CI run on the red commit for app lanes.
- StreakEngine ratified semantics: Sessions 03–07 "Key decisions" in `past-prompts.md`
  — the engine's input type is `StreakSnapshot`; package `///` docs stay
  consumer-self-contained; no `@Attribute(.unique)` ever; `cloudKitDatabase` is
  `.none` until the §4.3 red-test-first flip is deliberately taken.
