# Resume Prompt: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Resume Prompt v2.7 |
| Last updated | 2026-07-11 (Session 15 close: E8.1 COMPLETE — burned `29130610823` → red evidence `29130875659` → green `29131380401`, 3 billed runs) |
| Phase | Phase 1 core build — Epics 0–1 CLOSED; E2.1–E2.4 + E3.1–E3.3 + E4.1–E4.2 + E8.1 DONE; delivery 17/32 (53%) |
| Next session objective | **Session 16: E5.1 — age gate (first screen); resolve the `age_gate_blocked` schema tension BEFORE red (see below)** |

> **What changed in Session 15:** E8.1 shipped WHOLE — the closed `AnalyticsEvent`
> enum (19 MVP §5 cases byte-pinned, no Date/float representable, snake_case
> `panic_opened` source map), the @MainActor `AnalyticsService` facade whose `fire()`
> is the ONE consent gate (default OFF), the `AnalyticsSink` seam, TelemetryDeck
> 2.14.1 exact-pinned with a lazy post-frame dormant transport (empty operator app
> ID ⇒ NoopSink — the ADR-8 double gate), and the FIRST live fire-points:
> `urge_averted` (warm + cold flush arms) and `slip_undone` — both red-first, both
> post-save. One run burned on a missing test-file import (new gate below). ALSO:
> the operator's Control Center panic fix is UNCOMMITTED on their Mac —
> `operator-expected.md` §0; it constrains which files agents may touch (see
> standing note 6). Full ledger: Session 15 in `docs/past-prompts.md`.

---

## Standing tooling rules (permanent, apply to every agent)

1. **CodeGraph**: the repo is indexed (`.codegraph/`, machine-local). Query
   `codegraph_explore` (shell: `codegraph explore "<symbols or question>"`) BEFORE
   grep/find or manual reading; pass this instruction into every subagent/workflow
   prompt; check blast radius before editing public symbols. **Before the
   session-end commit: `codegraph sync` + confirm `codegraph status` clean.**
2. **Parse gate**: `swiftc -parse` every touched Swift file before every push.
   **Session 15 lesson — the parse gate is IMPORT-BLIND (syntax-only):** for every
   NEW test file, copy the import block from the closest proven neighbor
   (SlipFlushTests for repository harnesses) and grep the file's non-Foundation
   types against its imports before push — a missing `import StreakEngine` burned
   run `29130610823` after sailing through parse, harness, AND two critics
   (a read-only critic's "compiles clean" claim is NOT compile evidence).
3. **Access-level gate (Session 12):** scan for private types named in non-private
   signatures (`@Test` methods are internal), and RUN (never just typecheck) a
   Linux scratch harness over the exact shipping bytes of every pure-Foundation
   API, with usage-exercise — both red and green profiles when a designed red
   exists (Session 15: both predictions matched CI test-for-test).
4. **Docs-check gate (Session 13):** every Darwin-only / AppIntents / SF-Symbol /
   third-party-SDK member spelling gets verified against official docs BEFORE the
   code is written. **Session 15 refinement: for SPM deps, ALSO clone the pinned
   tag and grep the actual source** (product names, signatures, reserved-key lists)
   — it caught nothing this time only because the web docs-check was right; it is
   cheap and decisive.
5. Docs-only commits carry `[skip ci]`; never spawn agent workflows for docs-only
   changes (operator rule). Critic/reader agents Write findings to a scratchpad
   file and return a one-line pointer (zero structured-output retry-cap deaths in
   Session 15 — the fix works); salvage path if violated: `agent-*.jsonl`.
6. **RETIRED same day (kept so numbering holds):** the Mac-tree conflict guard.
   The operator pushed the panic fix as `8a0c469` (rebased; CI `29132554144`
   all-green + TestFlight; both device paths confirmed working). Its files are
   ordinary editable surface again, and `panic_opened` wiring is UNBLOCKED (the
   `cold_start_ms` value still waits on E0.3 numbers — the case ships unfired).
   The general habit survives the guard: `git fetch` + `git log origin/main`
   before EVERY push — the operator commits mid-session.
7. **Privacy-surface gate (agent-workflows §2.2, exercised in Session 15):**
   anything touching stores/`AnalyticsEvent`/outbound gets an Architect-agent
   pre-approval BEFORE implementation; adding an enum case is Architect-gated AND
   requires the MVP §5 table row to exist first.

## Where we are

- **The analytics boundary is LIVE**: every future feature instruments against the
  closed enum (that was E8.1's whole point — "enum lands week 1"). Adding an event
  = MVP §5 row + Architect approval + case + fixture + whitelist entry (the
  completeness tests force the last two).
- **Consent is double-gated shut**: `isOptedIn` hardwired `{ false }` in
  RepositoryProvider until E8.2's consent step; transport dormant until the
  operator drops the TelemetryDeck app ID (`AnalyticsConfiguration`,
  operator-expected §8). Zero events can leave any build today.
- **Deferred fire-points (each named, none forgotten):** `slip_logged` — the
  four-arm post-save placement is spec'd VERBATIM in the Session 15 Architect
  verdict (scratchpad is gone; the ledger's Process notes summarize it: fire once
  per row transitioning to permanent, post-save, quit-guarded, at logSlip's
  superseded-priors / flush's superseded+lands-finalized / undoSlip past-window /
  finalizePendingSlips window-closed arms; NEVER inside `finalizeRow` — it runs
  pre-save); `panic_opened` (UNBLOCKED — the Mac fix landed as `8a0c469` with
  `WarmPanicEntry` as a third consumption site; the `cold_start_ms` VALUE still
  waits on E0.3 numbers, the case ships unfired);
  `panic_step_reached` (ADR-6 warm-up design needed: first consented receive must
  not pay SDK init pre-frame in PanicFlowModel construction);
  `erase_all_completed` (consent-wipe ordering design; TODO comment at the erase
  seam stands).
- **StreakEngine 1.2.0** — untouched. **TestFlight LIVE** through green
  `29131380401`. CI signing read-only; never re-enable MATCH_BOOTSTRAP; macOS
  minutes bill 10x.
- Brand kit load-bearing: no red anywhere; slip strings CI-gated (SlipLexiconTests);
  discreet variants neutral; motivations VERBATIM.

## Next session objective (one session, definition of done below)

**Session 16 — E5.1 age gate (first screen)** (implementation-plan row, verbatim
goal): birth-year entry; under-17 blocked to resources; only a boolean stored.

0. **BEFORE red — resolve the schema tension:** the plan's third named test
   `test_ageGate_firesAgeGateBlocked_withNoAgeProperty()` fires `age_gate_blocked`,
   which is NOT an MVP §5 row, and the enum is closed + Architect-gated + byte-pinned
   (adding a case without a fixture/whitelist row fails the completeness tests BY
   DESIGN). Path: PM-style decision recorded in the ledger + MVP §5 row added
   deliberately + Architect approval + case/fixture/whitelist in the SAME red — or
   re-spec the test against an existing event. Do not silently invent the event.
1. **Red first** (billed run 1): the three plan-named tests —
   `test_ageGate_under17_blocksAndShowsResources()`,
   `test_ageGate_birthYearNeverPersisted()` (AppSettings gains ONLY `ageGatePassed`),
   the third per the step-0 decision.
2. **Green** (billed run 2): the gate screen (first screen, before ANY habit
   content — feasibility condition #6), resources routing for under-17, boolean-only
   persistence.
3. Scope guards: safety-content sign-off applies (age gate is on the
   agent-workflows §2.2 stricter-loop list — PM+Brand+QA copy table before code;
   operator adjudicates disagreement); no quiz screens beyond the gate (E5.2); no
   birth year in ANY store, file, or payload (test-pinned).
4. Budget: 2 billed runs (+ check operator-expected §4 headroom — Session 15 used 3).

## Operator-owned blockers (not agent work; carry until closed)

1. ~~§0 panic-fix push~~ **CLOSED same day**: `8a0c469` landed (rebased, CI
   `29132554144` all-green + TestFlight), operator device-verified cold+warm,
   sheet ruling stands unvetoed. Only the optional gstack FYI remains in §0.
2. E0.3 device measurement (`docs/spike-panic-latency.md`) — still the only blocker
   on the permanent latency gate.
3. E3.3 device matrix (operator-expected §7).
4. Content tone review + E4.2 copy-audit checklist signature (operator-expected §3).
5. GitHub Actions billing headroom (§4 — Session 15 used 3 runs, 1 burned).
6. TestFlight housekeeping (§5); Slack webhook rotation (§6, optional).
7. NEW §8: TelemetryDeck app ID whenever convenient (transport stays dormant and
   harmless without it).

## Resume prompt (copy-paste for next session)

> You are the lead build agent for **unhooked-quit-widget** (app name **Ballast**,
> org `com.beyondkaira`). E8.1 is DONE (green `29131380401`); Session 16 = E5.1
> age gate — but FIRST resolve the `age_gate_blocked` schema tension (objective
> step 0 above: MVP §5 has no such row; the enum is closed, byte-pinned, and
> Architect-gated). Local Swift toolchain: `. ~/.local/share/swiftly/env.sh`.
> **Standing gates:** CodeGraph query-first + sync at close; `swiftc -parse` every
> touched file + the NEW import-coverage check on every new test file (copy the
> closest proven neighbor's import block — Session 15 burned a run on this);
> access-level scan + Linux harness RUN empirically; docs-check every SDK spelling
> (clone pinned tags for SPM deps); docs-only commits `[skip ci]`, no workflows for
> docs-only work; critics Write findings to files; privacy-surface changes need
> Architect pre-approval BEFORE implementation; safety-content (the age gate IS
> one) needs the PM+Brand+QA copy sign-off before code; `git fetch` +
> `git log origin/main` before every push (the operator commits mid-session —
> the Session 15 panic fix landed exactly that way, as `8a0c469`).
> READ FIRST: `docs/implementation-plan.md` E5.1 row + Epic 5, `docs/mvp.md` §5
> (the closed event table) + §7, `docs/architecture.md` §5.1 + ADR-8,
> `docs/operator-expected.md` §0/§4/§8, the Session 15 ledger's deferred
> fire-point list, `docs/session-rules.md`.
> **This session:** step-0 schema decision → red (the three named tests) → THE
> red-evidence run → green (gate screen + boolean-only persistence + resources
> routing) → verify all-green → flag operator-owned items.
> **At session end:** append the Session 16 ledger, overwrite this resume prompt
> (next objective per `roadmap.md` — likely E5.2 quiz engine or E8.2 consent
> screen; E8.2 also retires the hardwired `isOptedIn: { false }`), update
> `docs/operator-expected.md`, `codegraph sync`, commit `[skip ci]`, push,
> `gh run watch` green.

## Standing rules reminders (do not relearn these)

- Analytics ONLY via the closed `AnalyticsEvent` enum (LIVE since E8.1); zero
  events before opt-in (the gate is `AnalyticsService.fire`, the one and only);
  never a generic track; adding a case = MVP §5 row + Architect + fixture +
  whitelist (completeness tests enforce). Analytics never pre-frame on the panic
  path (ADR-6); fires are post-save, BESIDE writes, never inside (invariant 3).
- No shame copy (slip strings CI-gated; lexicon only GROWS); no medical claims; no
  red anywhere in UI; discreet variants mandatory; motivations VERBATIM in user
  order.
- Monotonic fields never decrease — undo is the ONE sanctioned exemption (§9r3);
  streaks freeze, never inflate (ADR-7); `Quit.totalCleanSeconds` is BANKED-only.
- WITNESS discipline: three advance paths only; erase clears it; flush/undo never
  advance it; deferred slips apply with the SLIP-TIME witness, windows with nil.
- Erase discipline: local-first; key sweep; owned file-set sweep; cloud purge last;
  `logSlip` stays synchronous-local.
- Panic path stays thin (ADR-6): panic surfaces NEVER open the store; single-writer
  pre-cache pin; single store; no accounts (ADR-2).
- E3.3 attribution ceiling is a RECORDED ADJUSTMENT (control family →
  `.controlCenter`); the analytics wire map covers all five PanicSource cases
  snake_case — never fabricate `.actionButton`.
- Never weaken a QA assertion; TDD red first (red evidence = the CI run on the red
  commit; build failures are NOT evidence — Session 15 paid to relearn this);
  `cloudKitDatabase` stays `.none` until the §4.3 flip (undone-slip tombstoning
  designs with it).
- Snapshot goldens: pinned in-test geometry (.iPhone13) + AX5 axis; re-record
  deliberately via the CI artifact; SnapshotTesting 1.19.3 + TelemetryDeck 2.14.1
  exact-pinned.
- Carried product notes: store-route SlipFraming passes momentum/motivation nil
  (dashboard epic feeds real values); dashboard-half slip XCUITest waits for the
  fixture-seeding session.
