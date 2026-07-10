# Resume Prompt: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Resume Prompt v2.4 |
| Last updated | 2026-07-10 (Session 12 close: E4.1 COMPLETE — red→green→refs all-green on `8cf1461`; 4 billed runs used incl. 1 burned) |
| Phase | Phase 1 core build — Epics 0–1 CLOSED; E2.1–E2.4 + E3.1 + E3.2 + **E4.1 DONE**; delivery 14/32 (~44%) |
| Next session objective | **Session 13: E3.3 — panic entry-point matrix (per-widget quit parameter, per-source attribution, discreet "Reset" control)** |

> **What changed in Session 12:** E4.1 shipped WHOLE — both slip routes, the undo
> lifecycle, the deferred cold application (SlipFlushTests' 13 pins incl. the R-WIT
> equivalence property), SlipFlowView + the real panic→slip mount (the
> `panic.flow.slipPlaceholder` dead end is GONE), the root-placeholder store slip
> entry + pending-undo banner + scene-phase finalize, `slipCopy.json` bundled with
> the agent-drafted `confirm.retryNote` (operator tone review flagged), and 24 new
> snapshot goldens (repo total 64). Main is ALL-GREEN; the TestFlight lane uploaded
> the slip-flow build. Full ledger + the burned-run lesson: Session 12 entry in
> `docs/past-prompts.md`.

---

## Standing tooling rules (permanent, apply to every agent)

1. **CodeGraph**: the repo is indexed (`.codegraph/`, machine-local). Query
   `codegraph_explore` (shell: `codegraph explore "<symbols or question>"`) BEFORE
   grep/find or manual reading; pass this instruction into every subagent/workflow
   prompt; check blast radius before editing public symbols. **Before the
   session-end commit: `codegraph sync` + confirm `codegraph status` clean.**
2. **Parse gate**: `swiftc -parse` every touched Swift file before every push.
3. **Access-level gate (NEW, Session 12 — a burned run bought it):** the parse gate
   is SYNTAX-only. Before every push that adds test/production Swift, also (a) scan
   for private types named in non-private signatures (`@Test` methods are internal —
   a file-`private` parameter type is a build error), and (b) `swiftc -typecheck` a
   scratch harness on the Linux toolchain for every NEW API-shape assumption
   (StreakEngine + pure-Foundation files compile locally; empirical typecheck beats
   declaration cross-check — it caught a field-name misnomer the same day).
4. Docs-check new Darwin/Foundation calls and bare SDK member spellings (two
   sessions each lost a billed run to this class before the gates existed).
5. Docs-only commits carry `[skip ci]`; never spawn agent workflows for docs-only
   changes (operator rule, Session 12).

## Where we are

- **StreakEngine 1.2.0** — unchanged in Sessions 11–12; E3.3 needs ZERO engine work.
- **E4.1 is DONE and all-green** (`8cf1461`): logSlip opens the undo window
  (flag + persisted `PendingSlipUndo` payload), `undoSlip` engine-gated exact
  restore + row delete, `finalizePendingSlips` scene-phase sweep
  (+ `#Index<Slip>([\.isPendingUndo])`), two-pass flush applying deferred slips
  from the SLIP-TIME evidence tuple, pre-cache carries the additive streak fields,
  SlipFlowModel/SlipFlowView live on both routes, `slipCopy.json` bundled.
- **Widgets target already has the walking-skeleton surfaces** E3.3 parameterizes:
  `Widgets/Sources/OpenPanicIntent.swift` (AppIntent), `PanicControlWidget.swift`
  (ControlWidget), `SkeletonWidget.swift`, `UnhookedWidgetBundle.swift`. E3.1
  landed the quitID channel (`PanicLaunchFlag.selectedQuitID()` →
  `PanicRouteResolver.resolve(selectedQuitID:snapshot:)`); the intent PARAMETER
  that feeds it is E3.3's work.
- **Attribution today**: every cold panic launch is recorded `.lockscreenWidget`
  (E3.2 default — `PanicFlowView.init(quit:script:)` hardcodes the source).
  `PanicSource` already has all five cases. E3.3 threads the TRUE source from each
  entry point into the flow (and therefore into UrgeEvents/drafts). Analytics
  events stay E8 — attribution here means the persisted `source` field only.
- **TestFlight: LIVE**, now carrying the full panic→slip→undo loop. CI signing
  read-only; never re-enable MATCH_BOOTSTRAP. macOS CI minutes bill 10x.
- **Brand kit stays load-bearing**: discreet control variant must be titled
  "Reset" with a neutral symbol (implementation-plan E3.3); no red anywhere;
  slip motion 300ms spring; undo banner NEUTRAL.

## Next session objective (one session, definition of done below)

**Session 13 — E3.3 panic entry-point matrix** (implementation-plan row, verbatim
goal): ControlWidget registration (Control Center, Action button, lock-screen
control) + per-widget quit parameter; discreet variant titled "Reset".

1. **Red first** (billed run 1 = the red evidence): the two named tests —
   `test_panicIntent_parameter_quitEntity_resolvesActiveQuits()` (the intent's
   quit parameter resolves against active quits; drives the entity/query design)
   and `test_controlWidget_discreetMode_usesNeutralTitleAndSymbol()` — plus the
   per-source attribution pins this row implies (each entry point's launch lands
   its TRUE `PanicSource` on the draft/UrgeEvent; the `.lockscreenWidget`
   hardcode dies). Design the intent parameter against the PRE-CACHE (the panic
   path never opens the store — ADR-6; the widget target already reads
   `panic-snapshot.json` by design intent, architecture §4).
2. **Green** (billed run 2): quit-parameterized `OpenPanicIntent` (+ entity/query
   over the pre-cache cards), source threading (widget kind / control / action
   button / in-app → `PanicLaunchFlag` → `PanicFlowView`), discreet "Reset"
   control variant, `PanicControlWidget` + lock-screen family registration.
3. Widget-surface snapshots only if a rendering surface changes (budget 2–3
   billed runs total; refs run only if goldens are added).
4. **Acceptance**: all four sources reachable and correctly attributed
   (store-persisted `source`); the manual device matrix (lock screen / CC /
   Action button × Focus on/off) is documented for the operator in
   `docs/operator-expected.md` — it is operator-owned device work.
5. Scope guards: no analytics (E8); no engine changes; never weaken a QA
   assertion; SwiftData stays inside `App/Sources/Persistence/**` (the widget
   target reads the pre-cache FILE, never the store); all standing gates above.

**Why E3.3 over E5.1 (deliberate pick, Session 12):** E5.1's third named test
needs E8.1's `AnalyticsEvent` enum (dependency), while E3.3 is dependency-free
(deps: E3.1 ✓), closes Epic 3's build half, kills the `.lockscreenWidget`
attribution FYI, and hands the operator real device surfaces to exercise in the
physical-device pass they asked for.

## Resume prompt (copy-paste for next session)

> You are the lead build agent for **unhooked-quit-widget** (app name **Ballast**,
> org `com.beyondkaira`). E4.1 is DONE (all-green `8cf1461`); Session 13 = E3.3
> panic entry-point matrix (see the objective above). Local Swift toolchain:
> `. ~/.local/share/swiftly/env.sh`. **Standing gates:** CodeGraph query-first +
> sync at close; `swiftc -parse` every touched file; the Session-12 ACCESS-LEVEL
> gate (private-type-in-internal-signature scan + local typecheck harnesses for
> new API shapes); docs-check new Darwin APIs; docs-only commits `[skip ci]`, no
> workflows for docs-only work.
> READ FIRST: `docs/implementation-plan.md` E3.3 row + Epic 3 DoD,
> `docs/architecture.md` §4/§5 (intents, App Group files, pre-cache), the Session
> 09 ledger (quitID channel: intent parameter → E3.3) and Session 12 ledger (gates,
> carried limitations), `Widgets/Sources/*` (the four skeleton files),
> `App/Sources/PanicRouteResolver.swift`, `docs/session-rules.md`.
> **This session:** red (two named E3.3 tests + attribution pins) → THE red
> evidence run → green (parameterized intent + entity over pre-cache cards, source
> threading, discreet "Reset" control) → verify all-green → document the manual
> device matrix for the operator. Budget 2–3 billed macOS runs.
> **At session end:** append the Session 13 ledger, overwrite this resume prompt
> (next objective per `roadmap.md` — likely E4.2 zero-shame copy gate (small; may
> pair with E5.1) or E5.1 age gate (mind the E8.1 dependency on its third named
> test)), update `docs/operator-expected.md`, `codegraph sync`, commit `[skip ci]`,
> push, `gh run watch` green.

## Operator-owned blockers (not agent work; carry until closed)

1. **E0.3 device measurement** (`docs/spike-panic-latency.md`) — STILL the only
   blocker on the permanent latency gate; measures the real flow's first frame.
2. **Content tone review, now TestFlight-visible:** `panicScript.json` AND
   `slipCopy.json` (bundled Session 12) — including the ONE new agent-drafted
   `confirm.retryNote` line (REVIEW.md item 3).
3. TestFlight housekeeping: internal-tester group; expire the stray
   bundle-version-"1" build.
4. GitHub Actions billing headroom: Session 12 used 4 runs; Session 13 needs 2–3.
5. Slack webhook rotation (optional hygiene) — unchanged.
6. **E4.1 on-device recipe** (operator asked): run from Xcode with scheme env vars
   `FORCE_PANIC_ROUTE=1` + `UITEST_SEED_PANIC_SNAPSHOT=1` → picker → panic flow →
   "I slipped" → two-tap slip flow with live 10-minute undo. A plain TestFlight
   launch still shows the walking-skeleton root (no quiz/onboarding yet creates
   quits, so the store-route slip entry has nothing to list).

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
  commit; a build failure is NOT evidence — Session 12 paid for the reminder);
  `cloudKitDatabase` stays `.none` until the §4.3 flip (which must also design
  undone-slip tombstoning).
- Snapshot goldens: pinned in-test geometry (.iPhone13) + AX5 axis; goldens
  re-record deliberately via the CI artifact; SnapshotTesting stays exact-pinned
  at 1.19.3.
- Carried product notes: store-route SlipFraming passes momentum/motivation nil
  (unreachable surface until the dashboard epic — feed real values then);
  dashboard-half slip XCUITest waits for the fixture-seeding session.
