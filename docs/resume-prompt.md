# Resume Prompt: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Resume Prompt v2.3 |
| Last updated | 2026-07-10 (Session 11 close: E4.1 design RATIFIED + red WIP 5/6 committed af00116 `[skip ci]`; markdown audit done; 0 billed runs used) |
| Phase | Phase 1 core build — Epics 0–1 CLOSED; E2.1–E2.4 + E3.1 + E3.2 DONE; **E4.1 IN PROGRESS (half-done)** |
| Next session objective | **Session 12: COMPLETE E4.1 — write SlipFlushTests, push the red-evidence run, implement green, snapshots + refs** |

> **What changed in Session 11:** the cold-route slip design point was settled FIRST
> (judge panel + adversarial verify) and the full decision record is in the Session 11
> ledger entry of `docs/past-prompts.md` — READ IT BEFORE ANY E4.1 CODE; it is binding.
> Winner: the §9-rule-2 buffer grows slip support; drafts carry the SLIP-TIME evidence
> tuple (monotonic reading + witness) so the deferred flush application equals a live
> `logSlip` byte-for-byte; in-session cold undo = an appended revocation record;
> window measurements pass `lastKnownGood: nil` everywhere (ratified E1.3 reading);
> NO cold pre-cache rewrite (single-writer pin — in-memory draft fold instead); store
> undo deletes the undone row (CloudKit tombstoning noted for the §4.3 flip).
> Committed WIP (af00116, `[skip ci]`, NOT a red commit — no evidence claimed): inert
> API surface (Slip payload fields, draft captured*/revokesDraftID fields, QuitSnapshot
> additive streak fields, repository undo-lifecycle stubs, SlipFlowModel/SlipCopy) + 33
> designed-red tests in 5 files, all parse-gated. The subagent session limit killed the
> remaining two authors; **Tests/Unit/SlipFlushTests.swift is missing** and the
> UI-smoke file landed complete. Billed macOS runs used: 0 — the full 3–4-run budget
> is intact for Session 12. **Until the red run lands: any code push to main will show
> ~30 DESIGNED failures from af00116's suites. That red is expected, not a regression.**

---

## Standing tooling rule — CodeGraph (permanent, applies to every agent)

The repo is CodeGraph-indexed (`.codegraph/`, machine-local). **Query it first**: use
the `codegraph_explore` MCP tool (shell: `codegraph explore "<symbols or question>"`)
BEFORE grep/find or manual file reading. Pass this instruction into every
subagent/workflow prompt. Check dependents before editing public symbols. **Before the
session-end commit, run `codegraph sync` and confirm `codegraph status` is clean.**

## Where we are

- **StreakEngine 1.2.0** (tagged, unchanged in Session 11 — E4.1 needs ZERO engine
  changes: `applySlip`/`undoSlip`/`PendingSlipUndo`/`undoWindowSeconds` shipped in
  E1.3). Ratified semantics: Sessions 03–07 + the Session 11 decision record.
- **QuitRepository**: E4.1 stubs are on `main` (af00116) with INERT behavior —
  `undoSlip(slipID:)` returns false, `finalizePendingSlips()` returns 0,
  `updateSlipNote` no-op, `pendingUndoSlip()` nil, `logSlip` still writes
  `isPendingUndo=false` and drops the engine's `pendingUndo`. `flushPanicOutcomes`
  still inserts UrgeEvents only (no slip transition, no revocation handling).
- **Slip flow UI**: `SlipFlowModel`/`SlipRoute`/`SlipFraming`/`SlipCopy` exist as
  inert skeletons; `SlipFlowView` does NOT exist; the production `PanicFlowView`
  still wires `onSlipRoute: { _ in }` and parks on `panic.flow.slipPlaceholder`;
  `slipCopy.json` is NOT yet bundled (SlipCopyTests are red on that by design) and
  still needs the agent-drafted `confirm.retryNote` key added (flag for operator
  tone review when bundling — the panicScript precedent: bundle only the consumed
  file, update REVIEW.md, flag the operator).
- **Red suite on main (af00116)**: SlipUndoLifecycleTests (11), SlipFlowModelTests
  (16), SlipCopyTests (3), PanicPathTests +2, EraseEverythingTests +1,
  SlipFlowUITests (1 smoke). All parse-gated; designed failures traced per test in
  the Session 11 ledger.
- **TestFlight: LIVE.** CI signing read-only; never re-enable MATCH_BOOTSTRAP.
  macOS CI minutes bill 10x; docs-only commits carry `[skip ci]`.
- **Brand kit stays load-bearing** — slip flow is THE zero-shame surface: "a slip"
  never "a relapse"; slip motion = motion/standard 300ms spring, NEVER the panic
  600ms calm; amber only for destructive/caution — the undo banner is NEUTRAL;
  slip glyph `arrow.uturn.backward.circle`; 56pt targets; motivation echo in SF Pro
  (not Rounded).

## Next session objective (one session, definition of done below)

**Session 12 — complete E4.1** (decision record = Session 11 ledger, binding):

1. **Write `Tests/Unit/SlipFlushTests.swift`** (the missing 6th red file — the
   deferred-application pins; conventions from QuitRepositoryTests, buffer pointed
   at the harness pre-cache directory): the equivalence property
   (`test_flush_deferredSlip_equalsLiveLogSlip_forCapturedTuple`, parameterized
   same-boot / reboot-between / rolled-back-wall), slip-time-span-not-flush-span
   (`test_flush_slipAfterPreSlipReboot_banksSlipTimeSpan_notFlushTimeSpan`),
   duplicate-draft-ids apply once, replay-after-save-before-clear not doubled,
   revoked-pair drop + revocation-never-an-UrgeEvent + slip→undo→slip lands exactly
   one, nil-quit slip = unattributed UrgeEvent only, erased-quit drop, APPEND-order
   (not wall-sort), two-slips-same-quit only-newest-pending, witness unchanged,
   window-closed-by-flush-time lands finalized, heal-collision bounded (inequalities).
   Every test fails DESIGNED on the current stubs (flush applies no transition).
2. **Push the red commit** → billed run 1 = THE red evidence for the WHOLE E4.1
   suite (~45 designed failures, build green, pre-existing suites green).
3. **Green** (billed run 2): implement per the decision record — repository
   lifecycle (logSlip flag+payload+finalize-prior, undoSlip engine-gated restore +
   row delete, finalizePendingSlips + `#Index<Slip>([\.isPendingUndo])` landing
   together, updateSlipNote, pendingUndoSlip), flush two-pass slip application
   (captured tuple; nil-witness window check), `rebuildPanicSnapshot` populates the
   additive card fields, SlipFlowModel real behavior (durable-first confirm, framing
   math + draft fold, revocation undo, live gate, note autosave), SlipFlowView +
   PanicFlowView attachment (placeholder dies), RootPlaceholderView minimal slip
   entry + pending-undo banner + scene-phase finalize, bundle slipCopy.json +
   retryNote + REVIEW.md update. Add SlipFlowSnapshotTests with the green commit
   (record: .missing fails-while-recording on CI — that run doubles as the
   snapshot-lane red, the Session 10 precedent).
4. **Refs/pins** (billed run 3): commit goldens from the `test-outputs` artifact
   (`snapshots-rerecorded` discipline), any review pins, verify all-green.
5. Scope guards: no analytics (E8); no engine changes; never weaken the zero-store
   pins or any QA assertion; all new SwiftData code in `App/Sources/Persistence/**`
   (importer lint); `swiftc -parse` every touched file before every push; NEW
   Darwin/Foundation calls AND bare SDK member spellings get a docs check (two
   sessions each lost a billed run to this).

## Resume prompt (copy-paste for next session)

> You are the lead build agent for **unhooked-quit-widget** (app name **Ballast**,
> org `com.beyondkaira`). E4.1 is HALF-DONE on `main` (af00116): design ratified,
> API stubs inert, 33 designed-red tests committed `[skip ci]` with NO CI evidence
> claimed; `Tests/Unit/SlipFlushTests.swift` is missing. Local Swift toolchain:
> `. ~/.local/share/swiftly/env.sh`. **CodeGraph standing rule** (query first; sync
> before session-end commit). **Parse gate** every touched Swift file; docs-check
> new Darwin APIs and bare SDK member spellings.
> READ FIRST: the **Session 11 entry in `docs/past-prompts.md`** (the BINDING E4.1
> decision record — mechanism, ratified decisions, named pins), then
> `docs/session-rules.md`, `docs/implementation-plan.md` (E4.1 row),
> `docs/architecture.md` §7/§9/§10, `docs/test-suite.md` §3.3/§7, and the red suite
> files on disk (they encode the contract).
> **This session:** write SlipFlushTests (designed-red) → push = the ONE red
> evidence run → green per the decision record → snapshot goldens from the CI
> artifact → refs/pins run. Budget 3–4 billed macOS runs total.
> **At session end:** append the Session 12 ledger entry, overwrite this resume
> prompt (next objective per `roadmap.md` — E3.3 entry-point matrix or E5.1 age
> gate; NOTE: E5.1's third named test needs E8.1's event enum — pick deliberately),
> update `docs/operator-expected.md`, `codegraph sync`, commit, push, `gh run watch`
> green. Docs-only commits carry `[skip ci]`.

## Operator-owned blockers (not agent work; carry until closed)

1. **E0.3 device measurement** (`docs/spike-panic-latency.md`) — STILL the only
   blocker on the permanent latency gate; measures the real flow's first frame.
2. **Content tone review:** `panicScript.json` ships in TestFlight builds (Session
   10). **`slipCopy.json` joins it when Session 12 bundles it** — including the new
   agent-drafted `confirm.retryNote` line.
3. TestFlight housekeeping: internal-tester group; expire the stray
   bundle-version-"1" build.
4. GitHub Actions billing headroom: Session 11 used 0 runs; Session 12 needs 3–4.
5. Slack webhook rotation (optional hygiene) — unchanged.
6. **Until Session 12's red run: a code push to main shows ~30 DESIGNED failures**
   from af00116's suites — expected red, not a regression.

## Standing rules reminders (do not relearn these)

- No shame copy; no medical claims; no red anywhere in UI; discreet variants
  mandatory; motivations render VERBATIM in user order.
- Analytics via the closed `AnalyticsEvent` enum only (E8); zero events before
  opt-in; `logSlip` stays synchronous-local on the store-backed path.
- Monotonic fields never decrease — undo is the ONE sanctioned exemption (§9r3);
  streaks freeze, never inflate (ADR-7). `Quit.totalCleanSeconds` is BANKED-only.
- WITNESS discipline: three advance paths only; erase clears it; flush/undo never
  advance it; deferred slips apply with the SLIP-TIME witness, windows with nil.
- Erase discipline: local-first; key sweep; owned file-set sweep; cloud purge last.
- Panic path stays thin (ADR-6): the panic route NEVER opens the store; the cold
  slip flow writes ONLY the buffer file (single-writer pre-cache pin). Single
  store; no accounts (ADR-2).
- Never weaken a QA assertion; TDD red first (red evidence = the CI run on the red
  commit; a build failure is NOT evidence); `cloudKitDatabase` stays `.none` until
  the §4.3 flip (which must now also design undone-slip tombstoning).
- Snapshot goldens: pinned in-test geometry (.iPhone13) + AX5 axis; goldens
  re-record deliberately via the CI artifact; SnapshotTesting stays exact-pinned
  at 1.19.3.
