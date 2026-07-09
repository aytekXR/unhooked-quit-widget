# Resume Prompt: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Resume Prompt v2.1 |
| Last updated | 2026-07-09 (Session 09 close: E3.1 DONE — pre-cache, launch wiring, production seams, panic route; StreakEngine stays 1.2.0) |
| Phase | Phase 1 core build — Epics 0–1 CLOSED; E2.1–E2.4 + E3.1 DONE and CI-verified |
| Next session objective | **E3.2 — panic flow UI (breath → timer → reasons → redirect → exits) + the §9-rule-2 panic write buffer** |

> **What changed in Session 09:** E3.1 is DONE and CI-verified (red 29026946526 →
> green 29028256271 → pins/harden 4bd7902). The panic pre-cache is a FILE
> (`panic-snapshot.json`, Shared `PanicSnapshotStore`, content minimized per §10,
> motivations VERBATIM, discreet labels stripped) rebuilt on every mutating write and
> IN the erase sweep (the Session 08 carry item is paid — `eraseLocalArtifacts` now
> takes an owned `appGroupFileURLs` set). `RepositoryProvider` (@Observable, in
> Persistence) owns post-first-frame store open + `recomputeDerivedState()` + a
> pre-cache refresh; **the panic route provably never opens the store, pre- or
> post-frame** (spy-pinned). Production seams live: `LiveClock`
> (mach_continuous_time + kern.bootsessionuuid), `LiveWidgetRefresher`,
> `LocalOnlyCloudSync` (.unavailable until the §4.3 flip). Panic selection channel =
> `PanicLaunchFlag.quitID` App Group key (intent stays parameterless until E3.3);
> pure `PanicRouteResolver` matrix + placeholder picker under the content-stable
> `root.panicPlaceholder` id. TWO cost lessons: (1) SDK DEPRECATIONS become build
> errors under warnings-as-errors and the parse gate cannot catch them — prefer
> modern APIs when writing new Darwin/Foundation calls; (2) UI smokes should assert
> REAL elements (buttons by identifier prefix), not nested a11y container ids.

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
  live). Semantics ratified in Sessions 03–07 "Key decisions" — READ THEM before
  touching the engine. No engine change since Session 07.
- **QuitRepository** (@MainActor, sole SwiftData importer — CI grep enforces):
  createQuit (max-3), synchronous logSlip, logUrgeEvent, activeQuits, streakValue,
  recomputeDerivedState(), eraseEverything() (local-first), and **rebuildPanicSnapshot
  on every mutating write (E3.1)**. Init takes `cloud:` + `appGroupDefaults:` +
  `panicSnapshotStore:`.
- **Launch wiring (E3.1):** `RepositoryProvider.startIfNeeded(for:)` — route-aware,
  idempotent, post-first-frame via `.task` on the normal branch; publishes
  `repository` through the SwiftUI environment (E3.2/E4.1 consume it there). The
  panic route reads ONLY `panic-snapshot.json` + the `panic.launch.quitID` key.
- **LKG witness discipline (Sessions 06–08, ratified — do not weaken):** three
  advance paths only; no unverified wall writes; erase clears the witness.
- **Erase discipline (Sessions 08–09):** local-first order; defaults KEY SWEEP;
  owned FILE-SET sweep (`panic-snapshot.json` is in it; every new App Group file
  MUST join it + a sentinel test in the same session it lands); cloud purge last
  (skip-unavailable/surface-failure); E7/E8 wire inside the named seams.
- **TestFlight: LIVE.** CI signing read-only; never re-enable MATCH_BOOTSTRAP.
- **Brand kit (`brandkit/`) is LOAD-BEARING this session** — the panic flow is real
  UI: no red anywhere, breath-not-bounce motion (600ms fades, one soft haptic, zero
  decorative animation on the panic path), coach-never-judge copy, "a slip" never
  "a relapse", SF Pro (Rounded for streak numerals only), discreet variants.

## Next session objective (one session, definition of done below)

**E3.2 — panic flow UI** (`implementation-plan.md` E3.2, deps E3.1 ✓ E2.2 ✓; stub
motivations until E5.2 — the pre-cache already carries whatever motivations exist),
strictly test-first:

1. **The §9-rule-2 panic WRITE BUFFER (design point, settle first):** the panic route
   provably never opens the store (E3.1 pin — do not weaken it), so the flow's
   outcome writes (`UrgeEvent`, slip handoff) MUST buffer to an append-only App Group
   file and flush into SwiftData when the repository starts (architecture §9 rule 2:
   "a crash between panic exit and flush loses nothing"). The buffer file name JOINS
   `eraseLocalArtifacts` + a file-shaped sentinel erase test IN THE SAME SESSION
   (the Session 08→09 carry pattern). Flush wiring: `RepositoryProvider.startIfNeeded`
   is the natural seam.
2. **Breath pacer model:** `test_breathPacer_pattern_478_threeRounds()` — pure
   pattern model (unit), haptics behind a `FakeHapticsEngine`-able seam (test-suite
   §3.1); haptics-only mode honored (`AppSettings.hapticOnlyBreathPacer` exists).
3. **Flow steps + skippability:** `test_panicFlow_everyStepSkippable()`,
   `test_reasonsStep_rendersVerbatimMotivations_fromPreCache()` (the seam landed in
   E3.1 — motivations render UNEDITED, user order), `test_panicFlow_recordsStepsReached()`.
4. **Exits:** `test_exitUrgePassed_logsUrgeEventAverted()` (through the write buffer,
   NOT a store open), `test_exitSlipped_routesToSlipFlow()` scope-adjusted: E4.1
   does not exist — pin the ROUTING SEAM (a named handoff, placeholder destination),
   never a store write from the panic scene.
5. **Snapshots:** per-step snapshot tests incl. Dynamic Type XXL (the snapshot lane
   has been near-empty since E0.1 — this session makes it real; pinned simulator,
   re-record discipline per test-suite §3.3).
6. **Streak in the flow (if the design shows it):** extend `QuitSnapshot` additively +
   bump `schemaVersion` (foreign versions read as absent by design). Do NOT read the
   store for it.

Scope guards: no analytics events (E8 enum is uninhabited — `panic_step_reached`
lands with E8.1), no E4.1 slip flow (seam only), no VoiceOver device audit (device
tier; keep identifiers disciplined), no real CloudKit, never weaken the E3.1
zero-store pins or any QA assertion; `logSlip` stays synchronous-local; witness
discipline unchanged; TDD red first with CI red evidence for app lanes; `swiftc
-parse` every touched Swift file before every push; NEW Darwin/Foundation API calls:
check for current-SDK deprecations (Session 09 lost a billed run to `String(cString:)`).

---

## Resume prompt (copy-paste for next session)

> You are the lead build agent for **unhooked-quit-widget** (app name **Ballast**, org
> `com.beyondkaira`). Epics 0–1 CLOSED; E2.1–E2.4 + E3.1 DONE and CI-verified;
> StreakEngine is 1.2.0 (tagged). The panic route renders exclusively from
> `panic-snapshot.json` and NEVER opens the store (spy-pinned — do not weaken).
> Local Swift toolchain: `. ~/.local/share/swiftly/env.sh`. **CodeGraph is a standing
> rule:** `codegraph_explore` first for any code question (pass the rule to every
> subagent), blast-radius before edits, `codegraph sync` + `codegraph status` before
> the session-end commit. **Parse gate:** `swiftc -parse` every touched Swift file
> before every push; new Darwin/Foundation calls get a deprecation sanity check.
> Read `docs/session-rules.md`, `docs/implementation-plan.md` (E3.2),
> `docs/architecture.md` §5.1/§7/§9/§11/ADR-6, `docs/test-suite.md` §1.2/§3.3/§7,
> `brandkit/` (LOAD-BEARING — real panic UI this session), and the Session 06–09
> entries in `docs/past-prompts.md` — Session 09 defines the pre-cache/erase/file-set
> patterns and the zero-store panic pins; Sessions 06–08 define the witness and
> erase disciplines.
>
> **This session: E3.2 — panic flow UI** per resume-prompt §objective: the §9-rule-2
> append-only panic write buffer (+ its erase coverage in the same session), the
> 4-7-8 breath pacer model behind a haptics seam, skippable flow steps rendering
> verbatim motivations from the pre-cache, both exit states (urge-passed →
> buffered UrgeEvent; slipped → routing seam only, E4.1 owns the flow), stepsReached
> recording, and the first real snapshot-test matrix (incl. Dynamic Type XXL).
>
> **At session end:** append the Session 10 entry to `docs/past-prompts.md`,
> overwrite `docs/resume-prompt.md` with the next objective (per `roadmap.md` —
> E4.1 slip flow + undo or E3.3 entry-point matrix are the natural successors; pick
> by what E3.2 actually closed), update the untracked `OPERATOR-TODO.md`, run
> `codegraph sync`, commit, push, and verify GitHub Actions is green
> (`gh run watch`). Fix small CI issues immediately; document large ones at the top
> of the next resume prompt.

## Operator-owned blockers (not agent work; carry until closed)

1. **E0.3 device measurement** (`docs/spike-panic-latency.md`, iPhone 15-class, full
   Xcode) — STILL the only blocker on wiring E3's permanent latency gate; the
   harness has been ready since Session 02. Decide the MVP §7 vs test-suite §1.5
   wording drift together with it.
2. TestFlight housekeeping: internal testers (nobody receives builds until a group
   exists); expire the stray bundle-version-"1" build; export compliance only if ASC
   prompts.
3. GitHub Actions billing headroom before heavy sessions (Session 09 ran 4 billed
   macOS runs, one wasted on the deprecation incident; E3.2 with its snapshot matrix
   will run 3–5).
4. Slack webhook rotation (optional hygiene) — unchanged.
5. Content sign-off before ship (safetyCopy.json, helplines, TR L10n) — unchanged.

## Standing rules reminders (do not relearn these)

- No shame copy; no medical claims; no red anywhere in UI; discreet variants
  mandatory; motivations render VERBATIM in user order — never sorted, never edited.
- Analytics via the closed `AnalyticsEvent` enum only (E8); zero events before
  opt-in; `logSlip` stays synchronous-local.
- Monotonic fields never decrease — undo (E4.1) is the ONE sanctioned exemption;
  streaks freeze, never inflate (ADR-7). `Quit.totalCleanSeconds` is BANKED-only.
- WITNESS discipline (Sessions 06–08): three advance paths only; erase clears it;
  never hardcode a verdict.
- Erase discipline (Sessions 08–09): local-first; key sweep; owned file-set sweep —
  every new App Group file joins it + sentinel test in its landing session; cloud
  purge last; E7/E8 wire inside the named seams.
- Panic path stays thin (ADR-6): the panic route NEVER opens the store (E3.1 pin);
  panic writes buffer per §9 rule 2. Single store; no accounts (ADR-2).
- Undo lifecycle is E4.1's, as ONE unit. `#Index<Slip>([\.at])` → first time-ordered
  query; UrgeEvent.at → E12.4.
- Never weaken a QA assertion; TDD red first, always (test-suite §7); red evidence =
  local `swift test` for packages, the CI run on the red commit for app lanes.
- StreakEngine ratified semantics: Sessions 03–07 "Key decisions"; no
  `@Attribute(.unique)` ever; `cloudKitDatabase` stays `.none` until the §4.3
  red-test-first flip is deliberately taken.
