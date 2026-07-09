# Resume Prompt: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Resume Prompt v2.0 |
| Last updated | 2026-07-09 (Session 08 close: E2.4 DONE — one-tap erase, local-first, CloudSyncControlling seam; no engine changes, StreakEngine stays 1.2.0) |
| Phase | Phase 1 core build — Epics 0–1 CLOSED; E2.1–E2.4 DONE and CI-verified (Epic 2 core complete; §4.3 flip + contract tier deferred by design) |
| Next session objective | **E3.1 — panic path productionizing (production clock/widget seams, launch wiring, pre-cache, panic route)** |

> **What changed in Session 08:** E2.4 is DONE and CI-verified (red 29016220253 →
> green 29017223500 all test lanes → review pins 669eb1b). `eraseEverything()` landed
> on QuitRepository in a **LOCAL-FIRST order** (ratified: entities → witness clear →
> defaults key sweep + store file-set removal → debounced reload → CloudKit purge
> LAST behind the new `CloudSyncControlling` seam; unavailable ⇒ skip, available +
> failure ⇒ surfaces after local completion). Architecture §10's erase order was
> corrected to match; §5.1 gained the seam. The witness is erased state
> (`LastKnownGoodStore.clear()`). NEW MECHANICAL RULE: `swiftc -parse` every touched
> Swift file before pushing (a backslash-continuation typo cost a billed red run).
> CI incident to watch: one TestFlight upload job was cancelled by GitHub with
> "job was not acquired by Runner of type hosted" AFTER all test gates were green.

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
  live): guard + reboot cap + `healFrozenStreak`. Semantics ratified in Sessions
  03–07 "Key decisions" in `past-prompts.md` — READ THEM before touching the engine.
- **QuitRepository** (`App/Sources/Persistence/QuitRepository.swift`, @MainActor, the
  sole SwiftData importer — CI grep enforces): createQuit (max-3), synchronous
  logSlip, logUrgeEvent, activeQuits, streakValue (guard + witness end-to-end),
  recomputeDerivedState() (dedupe merge + heal + once-per-boot witness restart),
  debounced widget reload, and **eraseEverything() (E2.4)** — local-first, behind
  `CloudSyncControlling` (mock-tested; production CKContainer conformance arrives
  with the §4.3 flip). Init now takes `cloud:` + `appGroupDefaults:`.
- **LKG witness discipline (Sessions 06–08, ratified — do not weaken):** three
  advance paths only (two-gate real-wall; once-per-boot heal restart ≤ cap;
  same-boot uptime accrual); no path ever writes an unverified wall; **erase clears
  the witness** (fresh install has none; the chain re-establishes normally).
- **Erase scope pins (Session 08):** defaults clearing is a KEY SWEEP over the App
  Group suite; file clearing is scoped to the store FILE SET (never the directory);
  orphaned child rows are erased by explicit per-type deletes, not cascade;
  E7 (RevenueCat reset) and E8 (`erase_all_completed`) are named TODO seams inside
  `eraseEverything` — wire there, not elsewhere.
- **TestFlight: LIVE** (builds 23/24 real; one upload lost to the runner-acquisition
  incident — check the latest run before assuming the lane is broken). CI signing
  read-only; never re-enable MATCH_BOOTSTRAP without an operator decision.
- **Brand kit (`brandkit/`)**: consult before any UI/copy/icon work — E3.1 touches
  the panic route UI shell, so this applies this session (no red anywhere, etc.).

## Next session objective (one session, definition of done below)

**E3.1 — PanicIntent + first-class launch mode** (`implementation-plan.md` E3.1,
deps E2.2 ✓; E0.3 device measurement still operator-owned — see scope adjustments),
strictly test-first:

1. **Production seams (carried since Session 06):** `ClockProviding` conformance
   (sleep-INCLUSIVE monotonic uptime — mach_continuous_time-derived — + boot session
   UUID + wall clock) and `WidgetRefreshing` conformance (WidgetCenter), both inside
   App/Sources/Persistence (the no-Date()-in-production lint stays honest: the
   conformance is the one sanctioned reader).
2. **App-launch wiring (carried since Session 07):** open the store + build the
   repository AFTER first frame (ADR-6 budget), production witness suite = App Group
   defaults, and run `recomputeDerivedState()` at launch. DESIGN POINT to settle
   red-test-first: UnhookedApp must not import SwiftData (sole-importer lint) — a
   provider/owner type inside App/Sources/Persistence, or a deliberate, reviewed
   allowlist extension in ci.yml (prefer the former).
3. **Panic pre-cache:** the plan's `test_motivationsPreCache_updatedOnEveryQuitWrite`
   — motivations pre-cached to App Group on EVERY repository write. **ERASE CARRY
   ITEM (review-confirmed 3/3, latent):** whichever shape the pre-cache takes,
   erase must provably cover it — defaults keys are already swept; if any FILE
   (panic-snapshot.json / widget-state.json, architecture §4) lands, its name JOINS
   `eraseLocalArtifacts` + a file-shaped sentinel erase test IN THE SAME SESSION.
4. **Panic launch route:** `test_panicLaunch_withQuitID_selectsThatQuit`,
   `test_panicLaunch_noQuitSelected_showsQuitPicker` (placeholder-grade picker is
   fine — the real flow UI is E3.2), `test_panicLaunch_skipsSDKInitBeforeFirstFrame`
   scope-adjusted: no SDKs exist yet, so the pin is "zero store/repository work
   before the panic first frame" (init-order spy).
5. **Latency gate:** `test_panicColdLaunch_signpost_underBudget` remains BLOCKED on
   the E0.3 operator measurement for its threshold — keep the harness, never
   hardcode a verdict; wire the permanent gate only if the measurement lands.

Scope guards: no full panic flow UI (E3.2), no real CloudKit, no paywall/analytics
SDKs, never weaken a QA assertion; `logSlip` stays synchronous-local; witness
discipline unchanged; TDD red first with CI red evidence for app lanes; run
`swiftc -parse` on every touched Swift file BEFORE each push (Session 08 rule).

---

## Resume prompt (copy-paste for next session)

> You are the lead build agent for **unhooked-quit-widget** (app name **Ballast**, org
> `com.beyondkaira`). Epics 0–1 CLOSED; E2.1–E2.4 DONE and CI-verified; StreakEngine
> is 1.2.0 (tagged); one-tap erase is live (local-first, CloudSyncControlling seam).
> Local Swift toolchain: `. ~/.local/share/swiftly/env.sh`. **CodeGraph is a standing
> rule:** `codegraph_explore` first for any code question (pass the rule to every
> subagent), blast-radius before edits, `codegraph sync` + `codegraph status` before
> the session-end commit. **Parse gate:** `swiftc -parse` every touched Swift file
> before every push. Read `docs/session-rules.md`, `docs/implementation-plan.md`
> (E3.1), `docs/architecture.md` §5.1/§7/§11/ADR-6, `docs/test-suite.md` §1.2/§7,
> `brandkit/` (the panic route shows UI), and the Session 06–08 entries in
> `docs/past-prompts.md` — Session 08 defines the erase scope pins and the
> pre-cache/erase carry item; Sessions 06–07 define the witness discipline.
>
> **This session: E3.1 — panic path productionizing** per resume-prompt §objective:
> production ClockProviding/WidgetRefreshing conformances, post-first-frame launch
> wiring + recomputeDerivedState() (repository stays the sole SwiftData importer —
> settle the provider-type design red-test-first), motivations pre-cache on every
> write (AND its erase coverage — file-shaped pre-cache extends eraseLocalArtifacts
> + sentinel test in the same session), panic route quit selection, init-order pin.
> The latency gate threshold stays blocked on the operator's E0.3 measurement.
>
> **At session end:** append the Session 09 entry to `docs/past-prompts.md`,
> overwrite `docs/resume-prompt.md` with the next objective (per `roadmap.md` —
> E3.2 panic flow UI or E4.1 slip flow + undo are the natural successors; pick by
> what E3.1 actually closed), update the untracked `OPERATOR-TODO.md`, run
> `codegraph sync`, commit, push, and verify GitHub Actions is green
> (`gh run watch`). Fix small CI issues immediately; document large ones at the top
> of the next resume prompt.

## Operator-owned blockers (not agent work; carry until closed)

1. **E0.3 device measurement** (`docs/spike-panic-latency.md`, iPhone 15-class, full
   Xcode) — NOW LOAD-BEARING: it sets the E3.1 permanent latency-gate threshold.
2. TestFlight housekeeping: internal testers; expire stray build "1"; export
   compliance only if ASC prompts. Watch for a repeat of the runner-acquisition
   cancellation (Session 08, run 29017223500's upload job) — if it recurs,
   `gh run rerun <id> --failed` is usually enough.
3. GitHub Actions billing headroom check before heavy sessions (Session 08 ran 4
   billed macOS runs).
4. Slack webhook rotation (optional hygiene) — unchanged.
5. Content sign-off before ship (safetyCopy.json, helplines, TR L10n) — unchanged.
6. Drift decision: MVP §7 "<2s 10/10" vs test-suite §1.5 "p90 < 2s" — becomes
   load-bearing when the E3 latency gate is wired.

## Standing rules reminders (do not relearn these)

- No shame copy; no medical claims; no red anywhere in UI; discreet variants mandatory.
- Analytics via the closed `AnalyticsEvent` enum only (E8); zero events before
  opt-in; `logSlip` stays synchronous-local.
- Monotonic fields never decrease — undo (E4.1) is the ONE sanctioned exemption;
  streaks freeze, never inflate (ADR-7); the heal resumes, never credits beyond
  verified + cap. `Quit.totalCleanSeconds` is BANKED-only.
- WITNESS discipline (Sessions 06–08): three advance paths only; no unverified wall
  writes; createQuit never refreshes it; erase clears it; never hardcode a verdict.
- Erase discipline (Session 08): local-first order is ratified; cloud purge last,
  skip-when-unavailable, surface-when-failed; file sweep stays scoped to the owned
  file set; E7/E8 wire inside the named seams in `eraseEverything`.
- Undo lifecycle (flag=true, finalize sweep, undoSlip, isPendingUndo index) is
  E4.1's, as ONE unit. `#Index<Slip>([\.at])` → first time-ordered query;
  UrgeEvent.at → E12.4.
- Panic path stays thin (ADR-6). Single CloudKit-mirrored SwiftData store; no
  accounts, no backend (ADR-2). Never re-introduce `dev.placeholder.quitwidget`.
  Never weaken a QA assertion; TDD red first, always (test-suite §7); red evidence =
  local swift test for packages, the CI run on the red commit for app lanes.
- StreakEngine ratified semantics: Sessions 03–07 "Key decisions" — input type is
  `StreakSnapshot`; package `///` docs consumer-self-contained; no
  `@Attribute(.unique)` ever; `cloudKitDatabase` stays `.none` until the §4.3
  red-test-first flip is deliberately taken.
