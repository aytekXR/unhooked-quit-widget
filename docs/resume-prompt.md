# Resume Prompt: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Resume Prompt v2.2 |
| Last updated | 2026-07-09 (Session 10 close: E3.2 DONE — write buffer, 4-7-8 pacer, real panic flow UI, first snapshot goldens; StreakEngine stays 1.2.0) |
| Phase | Phase 1 core build — Epics 0–1 CLOSED; E2.1–E2.4 + E3.1 + E3.2 DONE and CI-verified |
| Next session objective | **E4.1 — slip flow + 10-minute undo (one unit), attached to the E3.2 panic slip seam** |

> **What changed in Session 10:** E3.2 is DONE and CI-verified (red 29041600595 →
> green 29043512846 → refs/pins 29044978442; one run wasted on a Darwin-only
> member name — see cost lesson). The panic flow is REAL UI: 4-7-8 bloom pacer
> (haptics seam + haptics-only state), urge timer, VERBATIM reasons at 40pt with
> vertical paging, redirect menu from the now-BUNDLED shipping panicScript.json,
> both exits. Outcomes ride the §9-rule-2 WRITE BUFFER (`panic-outcomes.ndjson`,
> append-only NDJSON, fsync'd, torn-tail-tolerant, erase-covered same-session) and
> flush idempotently on the normal route's deferred start — the panic route STILL
> never opens the store (spy pin extended, not weakened). The slipped exit is a
> ROUTING SEAM ONLY: `PanicSlipHandoff{quitID, source, stepsReached}` through
> `PanicFlowModel.onSlipRoute` + a `panic.flow.slipPlaceholder` parking screen —
> a TestFlight user who taps "I slipped" hits that labeled dead end TODAY, which is
> why E4.1 is next. The snapshot lane is real (10 suites × light/dark ×
> default/AX5 + discreet/haptics-only variants; goldens recorded on CI from the
> test-outputs artifact; SnapshotTesting pinned exactVersion 1.19.3; ci.yml
> simulator pick is deterministic and logs its choice).

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
  touching the engine. `StreakCalculator.applySlip` already models the slip
  transition; `pendingUndo` exists in `StreakSnapshot` (E4.1's engine surface —
  check Sessions 03–05 for the ratified undo semantics before wiring).
- **QuitRepository** (@MainActor, sole SwiftData importer — CI grep enforces):
  createQuit (max-3), synchronous logSlip (§9 rule 1 — save before UI transition;
  isPendingUndo deliberately stays false until E4.1 lands the WHOLE undo lifecycle
  as one unit), logUrgeEvent, flushPanicOutcomes (E3.2 — idempotent §9-rule-2
  replay), activeQuits, streakValue, recomputeDerivedState, eraseEverything.
- **Panic flow (E3.2):** `PanicFlowModel` + `PanicFlowView` under the content-stable
  `root.panicPlaceholder` anchor; boots from the pre-cache, writes through
  `PanicOutcomeBuffer`, NEVER the store. The slip seam E4.1 attaches to:
  `onSlipRoute: @MainActor (PanicSlipHandoff) -> Void` + `model.slipHandoff` drives
  the placeholder destination. KEY DESIGN POINT for E4.1: a slip completed on the
  COLD panic route cannot write the store (zero-store pin) — architecture §9 rule 2
  names Slip writes as buffered too. Decide deliberately: extend the outcome buffer
  with a slip draft (note text in an App-Group file — check §10 minimization
  against the buffer's `.completeUntilFirstUserAuthentication` class) vs. defer the
  cold-route slip into the next normal launch vs. hand off to the normal app. Do
  NOT weaken the zero-store pins to shortcut this.
- **LKG witness discipline (Sessions 06–08, ratified — do not weaken):** three
  advance paths only; no unverified wall writes; erase clears the witness.
- **Erase discipline (Sessions 08–10):** local-first; defaults KEY SWEEP; owned
  FILE-SET sweep (`panic-snapshot.json` + `panic-outcomes.ndjson` are in it; every
  new App Group file MUST join it + a sentinel test in the same session); cloud
  purge last; E7/E8 wire inside the named seams.
- **TestFlight: LIVE.** CI signing read-only; never re-enable MATCH_BOOTSTRAP.
- **Brand kit stays load-bearing** — slip flow is THE zero-shame surface: "a slip"
  never "a relapse"; slip motion = motion/standard 300ms ("procedurally identical
  to any other log"); amber only for destructive/caution, never red; the undo
  affordance is calm, not alarmed. `slipCopy.json` exists in App/Resources/Content
  (UNBUNDLED drafts) — bundling it follows the Session 10 panicScript precedent
  (bundle only the consumed file; update REVIEW.md; flag the operator).

## Next session objective (one session, definition of done below)

**E4.1 — slip flow + undo** (`implementation-plan.md` E4.1, deps E1.3 ✓ E2.2 ✓
E3.2-routing ✓), strictly test-first, THE WHOLE UNDO LIFECYCLE AS ONE UNIT
(isPendingUndo flag + finalize sweep + undoSlip + the `#Index<Slip>([\.isPendingUndo])`
index — Sessions 03–05 ratified undo as the ONE sanctioned monotonic-decrease
exemption):

1. Settle the cold-route slip design point FIRST (see "Where we are") — it decides
   whether the buffer grows a slip draft or the flow defers.
2. Attach the slip flow to `PanicFlowModel.onSlipRoute` (replace the
   `panic.flow.slipPlaceholder` parking screen); keep `logSlip` synchronous-local
   on the store-backed path (§9 rule 1).
3. Two-tap logging, archive + momentum framing (banked seconds never lost),
   optional reflection note autosaved on keystroke pause (notes live ONLY in the
   store — §10; never in any App Group file), 10-minute undo affordance.
4. Snapshot coverage per the now-real lane's conventions (light/dark ×
   default/AX5, discreet variant; goldens from the CI artifact, `snapshots-rerecorded`
   discipline).
5. Scope guards: no analytics (E8), no dashboard epic (a minimal slip entry point
   on the placeholder root is fine if E4.1's "from dashboard" half needs one), no
   engine changes without the ratified-semantics read, never weaken the zero-store
   pins or any QA assertion; TDD red first with CI red evidence; `swiftc -parse`
   every touched Swift file; **NEW Darwin/Foundation API calls AND bare SDK
   enum/const member spellings get verified against docs — two sessions have each
   lost a billed run to this class (String(cString:), FileProtectionType member).**

## Resume prompt (copy-paste for next session)

> You are the lead build agent for **unhooked-quit-widget** (app name **Ballast**,
> org `com.beyondkaira`). Epics 0–1 CLOSED; E2.1–E2.4 + E3.1 + E3.2 DONE and
> CI-verified; StreakEngine is 1.2.0 (tagged). The panic route renders exclusively
> from `panic-snapshot.json`, writes outcomes through `panic-outcomes.ndjson`, and
> NEVER opens the store (spy-pinned — do not weaken). Local Swift toolchain:
> `. ~/.local/share/swiftly/env.sh`. **CodeGraph is a standing rule:**
> `codegraph_explore` first for any code question (pass the rule to every
> subagent), blast-radius before edits, `codegraph sync` + `codegraph status`
> before the session-end commit. **Parse gate:** `swiftc -parse` every touched
> Swift file before every push; new Darwin/Foundation calls AND bare SDK member
> spellings get a docs check (Sessions 09+10 each lost a billed run to this).
> Read `docs/session-rules.md`, `docs/implementation-plan.md` (E4.1),
> `docs/architecture.md` §5.1/§7/§9/§10/ADR-7, `docs/test-suite.md` §3.3/§7, the
> StreakEngine undo semantics in Sessions 03–05 "Key decisions", the Session 10
> entry in `docs/past-prompts.md` (write-buffer/flush/seam patterns + the snapshot
> golden workflow), and `brandkit/` (slip flow is THE zero-shame surface).
>
> **This session: E4.1 — slip flow + 10-minute undo as ONE unit** per
> resume-prompt §objective: settle the cold-route slip design point first, attach
> to the E3.2 `PanicSlipHandoff` seam, two-tap slip + archive/momentum framing +
> reflection note (store-only, §10) + undo lifecycle (flag, finalize sweep,
> undoSlip, `#Index<Slip>([\.isPendingUndo])`), snapshots per the real lane's
> conventions.
>
> **At session end:** append the Session 11 entry to `docs/past-prompts.md`,
> overwrite `docs/resume-prompt.md` with the next objective (per `roadmap.md` —
> E3.3 entry-point matrix or E5.1 quiz are the natural successors; pick by what
> E4.1 actually closed), update the untracked `OPERATOR-TODO.md`, run
> `codegraph sync`, commit, push, and verify GitHub Actions is green
> (`gh run watch`). Fix small CI issues immediately; document large ones at the
> top of the next resume prompt.

## Operator-owned blockers (not agent work; carry until closed)

1. **E0.3 device measurement** (`docs/spike-panic-latency.md`, iPhone 15-class, full
   Xcode) — STILL the only blocker on wiring E3's permanent latency gate; the panic
   flow is now real UI, so the measurement finally exercises the true first frame.
   Decide the MVP §7 vs test-suite §1.5 wording drift together with it.
2. **Content tone review priority bump:** `panicScript.json` now SHIPS in TestFlight
   builds (Session 10 bundled it — its copy renders in the real flow). The
   clinician/legal pass on safetyCopy.json + helplines stays pre-ship.
3. TestFlight housekeeping: internal testers (nobody receives builds until a group
   exists); expire the stray bundle-version-"1" build.
4. GitHub Actions billing headroom (Session 10 ran 4 billed macOS runs, one wasted;
   E4.1 should run 3–4).
5. Slack webhook rotation (optional hygiene) — unchanged.

## Standing rules reminders (do not relearn these)

- No shame copy; no medical claims; no red anywhere in UI; discreet variants
  mandatory; motivations render VERBATIM in user order — never sorted, never edited.
- Analytics via the closed `AnalyticsEvent` enum only (E8); zero events before
  opt-in; `logSlip` stays synchronous-local on the store-backed path.
- Monotonic fields never decrease — undo (E4.1, THIS session) is the ONE sanctioned
  exemption; streaks freeze, never inflate (ADR-7). `Quit.totalCleanSeconds` is
  BANKED-only.
- WITNESS discipline (Sessions 06–08): three advance paths only; erase clears it;
  never hardcode a verdict.
- Erase discipline (Sessions 08–10): local-first; key sweep; owned file-set sweep —
  every new App Group file joins it + sentinel test in its landing session; cloud
  purge last; E7/E8 wire inside the named seams.
- Panic path stays thin (ADR-6): the panic route NEVER opens the store (E3.1 pin,
  E3.2-extended to the buffer flush); panic writes buffer per §9 rule 2. Single
  store; no accounts (ADR-2).
- Never weaken a QA assertion; TDD red first, always (test-suite §7); red evidence =
  local `swift test` for packages, the CI run on the red commit for app lanes; a
  build failure is NOT red/green evidence.
- StreakEngine ratified semantics: Sessions 03–07 "Key decisions"; no
  `@Attribute(.unique)` ever; `cloudKitDatabase` stays `.none` until the §4.3
  red-test-first flip is deliberately taken.
- Snapshot goldens: pinned in-test geometry (.iPhone13 config) + AX5 axis; goldens
  re-record deliberately via the CI artifact; SnapshotTesting stays exact-pinned.
