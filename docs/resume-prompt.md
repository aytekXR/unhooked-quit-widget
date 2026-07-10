# Resume Prompt: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Resume Prompt v2.6 |
| Last updated | 2026-07-10 (Session 14 close: E4.2 COMPLETE — red `29122473990` → green `29123195424`, 2 billed runs, zero burned) |
| Phase | Phase 1 core build — Epics 0–1 CLOSED; E2.1–E2.4 + E3.1–E3.3 + E4.1–E4.2 DONE; delivery 16/32 (50%) |
| Next session objective | **Session 15: E8.1 — typed `AnalyticsEvent` enum + `AnalyticsService` (TelemetryDeck wrapper; unblocks E5.1 and retires the deferred-events backlog)** |

> **What changed in Session 14:** E4.2 shipped WHOLE in 2 runs — the permanent
> zero-shame gate `SlipLexiconTests.test_slipStrings_containNoForbiddenLexicon()`
> (37-token lexicon, casefold+diacritic-fold matching, word-boundary `sin`/`cure`,
> reflection-driven corpus so new `SlipCopy` fields can't dodge the scan, an
> only-grows foundation-floor pin), and the copy centralization: `slipCopy.json`
> gained the `dashboard` section (byte-identical to the shipped literals),
> `SlipCopy.Dashboard` is decode-tolerant (retryNote precedent), and
> `RootPlaceholderView` renders every slip string from the ONE audited table. NO
> goldens changed. The checklist's human half → operator (`operator-expected.md`
> §3). Full ledger: Session 14 in `docs/past-prompts.md`.

---

## Standing tooling rules (permanent, apply to every agent)

1. **CodeGraph**: the repo is indexed (`.codegraph/`, machine-local). Query
   `codegraph_explore` (shell: `codegraph explore "<symbols or question>"`) BEFORE
   grep/find or manual reading; pass this instruction into every subagent/workflow
   prompt; check blast radius before editing public symbols. **Before the
   session-end commit: `codegraph sync` + confirm `codegraph status` clean.**
2. **Parse gate**: `swiftc -parse` every touched Swift file before every push.
3. **Access-level gate (Session 12):** scan for private types named in non-private
   signatures (`@Test` methods are internal), and `swiftc -typecheck` a scratch
   harness on the Linux toolchain for every NEW pure-Foundation API shape —
   include a USAGE-exercise file calling the new API the way the tests will.
   **Session 14 refinement: RUN the harness, don't just typecheck it** — empirical
   assertions over the exact shipping bytes (decode both states, exercise the
   exact algorithm over the exact corpus) caught everything before CI, twice.
4. **Docs-check gate (Session 13):** every Darwin-only / AppIntents / SF-Symbol /
   third-party-SDK member spelling gets verified against official docs (the
   `developer.apple.com/tutorials/data/...json` endpoints work headlessly) BEFORE
   the code is written. Never answer SDK questions from memory. **E8.1 note: this
   now covers the TelemetryDeck SDK surface too — verify signal/parameter APIs
   against its official docs, and pin the SPM dependency EXACT (the
   SnapshotTesting 1.19.3 precedent).**
5. Docs-only commits carry `[skip ci]`; never spawn agent workflows for docs-only
   changes (operator rule). **Subagent structured outputs keep dying at the retry
   cap (Sessions 13 AND 14, sweep + both critics): critic/reader agents must
   Write findings to a scratchpad file and return a one-line pointer — reserve
   structured outputs for small schemas.** Salvage path if it happens anyway: the
   payloads survive in the workflow transcript `agent-*.jsonl`.

## Where we are

- **StreakEngine 1.2.0** — untouched since Session 07; E8.1 needs ZERO engine work.
- **E4.2 is DONE and green** (`29123195424`): `slipCopy.json` is THE one audited
  slip strings table (now incl. the `dashboard` section); `SlipLexiconTests` is
  the permanent unit-lane gate; `RootPlaceholderView` has no inline slip literals;
  `SlipCopy.degraded` is total (incl. `Dashboard.degraded`).
- **Analytics seams waiting for E8.1** (all deliberately deferred to it):
  `panic_opened` (source channel EXISTS since E3.3 — `UrgeEvent.source` persists
  per-launch attribution), `urge_averted` / `slip_logged` / `slip_undone`
  (repository writes exist; MVP §5: `slip_logged` fires POST-undo-window, never at
  tap — `finalizePendingSlips` is the natural hook), `panic_step_reached` (model
  records `stepsReached`), `erase_all_completed` (erase flow exists),
  `quiz_*`/paywall events (features not built yet — enum cases only).
- **TestFlight: LIVE** through the green run. CI signing read-only; never
  re-enable MATCH_BOOTSTRAP. macOS CI minutes bill 10x.
- Brand kit stays load-bearing: no red anywhere; no shame lexicon (now
  CI-enforced for slip strings); discreet variants neutral; motivations VERBATIM.

## Next session objective (one session, definition of done below)

**Session 15 — E8.1 typed `AnalyticsEvent` enum + `AnalyticsService`**
(implementation-plan row, verbatim goal): the §5.1 architecture enum wrapped by
the app-local `AnalyticsService` over the TelemetryDeck SDK — forbidden
properties are unrepresentable; opt-in default OFF; on-device queue. App code,
NOT a shared package (architecture §14).

1. **Red first** (billed run 1), the four plan-named tests:
   `test_analyticsFacade_hasNoGenericTrackMethod()` (API-shape assertion),
   `test_slipLogged_payload_hasNoTimestampProperty()`,
   `test_everyEventCase_serializesOnlyWhitelistedKeys()` (exhaustive over
   `CaseIterable` fixtures), `test_optOut_sendsNothing()` (network spy — zero
   events before opt-in is an MVP §5/release-criteria HARD rule).
2. **Green** (billed run 2): the closed enum (every MVP §5 event, properties per
   its table ONLY — no journal content, no slip timestamps, `cold_start_ms`
   bucketed), the service with opt-in default OFF + on-device queue, TelemetryDeck
   SPM dep pinned exact. Wiring existing seams (panic/slip/urge/erase call sites)
   is IN scope if the run budget holds — the enum's whole point is that features
   instrument against it; wiring quiz/paywall events is NOT (features don't exist).
3. **Acceptance:** every §5 event representable; forbidden properties
   unrepresentable BY TYPE; opt-in gate proven by the network spy.
4. Scope guards: no dashboards/insights (E8.2 owns the proxy-inspection doc);
   analytics NEVER on the panic path pre-frame (ADR-6 thinness — fire-and-forget
   after first frame, or from the store-side write); `logSlip` stays synchronous-
   local (the event fires beside, never inside, the durable write); never weaken
   a QA assertion; SwiftData stays inside `App/Sources/Persistence/**`.
5. **Risk note (new-dependency class):** adding the TelemetryDeck SPM package to
   project.yml is the first third-party runtime dep since SnapshotTesting — a CI
   build-failure risk the parse gate can't catch. Mitigate: docs-check the SDK
   API first; pin exact; if the SDK fights the macOS CI build, land the enum +
   service behind a protocol seam with a no-op transport (the HapticsPlaying
   precedent) and defer the SDK binding — the four named tests bind to the
   facade, not the transport.
6. Budget: 2 billed runs.

## Resume prompt (copy-paste for next session)

> You are the lead build agent for **unhooked-quit-widget** (app name **Ballast**,
> org `com.beyondkaira`). E4.2 is DONE (green `29123195424`); Session 15 = E8.1
> typed `AnalyticsEvent` enum + `AnalyticsService` (see the objective above).
> Local Swift toolchain: `. ~/.local/share/swiftly/env.sh`. **Standing gates:**
> CodeGraph query-first + sync at close; `swiftc -parse` every touched file; the
> access-level scan + Linux harness RUN empirically with usage-exercise;
> docs-check every SDK spelling (incl. TelemetryDeck) before writing code;
> docs-only commits `[skip ci]`, no workflows for docs-only work; critic/reader
> subagents Write findings to files, never big structured outputs.
> READ FIRST: `docs/implementation-plan.md` E8.1 row + Epic 8 DoD,
> `docs/mvp.md` §5 (the event table — the ONLY properties allowed),
> `docs/architecture.md` §5.1 + §14, the E3.3/E4.1 deferred-seam list in the
> Session 13/14 ledgers, `docs/session-rules.md`.
> **This session:** red (the four named tests) → THE red-evidence run → green
> (closed enum + service, opt-in OFF, exact-pinned SDK or the no-op-transport
> fallback) → verify all-green → wire existing seams if budget holds → flag
> anything operator-owned. Budget 2 billed macOS runs.
> **At session end:** append the Session 15 ledger, overwrite this resume prompt
> (next objective per `roadmap.md` — likely E5.1 age gate, now unblocked),
> update `docs/operator-expected.md`, `codegraph sync`, commit `[skip ci]`,
> push, `gh run watch` green.

## Operator-owned blockers (not agent work; carry until closed)

1. **E0.3 device measurement** (`docs/spike-panic-latency.md`) — STILL the only
   blocker on the permanent latency gate.
2. **E3.3 device matrix** (`docs/operator-expected.md` §7) — lock screen / CC /
   Action button / in-app × Focus on/off, one airplane-mode pass; includes the
   "Reset" control gallery check.
3. **Content tone review + the NEW E4.2 copy-audit checklist sign-off**
   (`docs/operator-expected.md` §3): the mechanical half is CI-enforced now;
   the judgment half (MVP §7 "copy audit" line) needs your signature. The E4.2
   dashboard strings are byte-moves — no new drafting to review beyond E4.1's
   `confirm.retryNote`.
4. TestFlight housekeeping: internal-tester group; expire the stray
   bundle-version-"1" build.
5. GitHub Actions billing headroom: Session 14 used 2 runs; Session 15 needs 2.
6. Slack webhook rotation (optional hygiene) — unchanged.

## Standing rules reminders (do not relearn these)

- No shame copy (slip strings now CI-gated by `SlipLexiconTests` — the lexicon
  only GROWS); no medical claims; no red anywhere in UI; discreet variants
  mandatory; motivations render VERBATIM in user order.
- Analytics via the closed `AnalyticsEvent` enum only (E8.1 BUILDS it); zero
  events before opt-in; `logSlip` stays synchronous-local on the store-backed
  path; `slip_logged` fires post-undo-window (MVP §5), never at tap.
- Monotonic fields never decrease — undo is the ONE sanctioned exemption (§9r3);
  streaks freeze, never inflate (ADR-7). `Quit.totalCleanSeconds` is BANKED-only.
- WITNESS discipline: three advance paths only; erase clears it; flush/undo never
  advance it; deferred slips apply with the SLIP-TIME witness, windows with nil.
- Erase discipline: local-first; key sweep (3 flag keys — the full
  `dictionaryRepresentation` sweep covers them); owned file-set sweep; cloud
  purge last.
- Panic path stays thin (ADR-6): panic surfaces NEVER open the store; single-
  writer pre-cache pin; single store; no accounts (ADR-2). Analytics never
  pre-frame on the panic path.
- E3.3 attribution ceiling is a RECORDED ADJUSTMENT: control family →
  `.controlCenter`; `.actionButton` reserved; do not "fix" it without a platform
  API.
- Never weaken a QA assertion; TDD red first (red evidence = the CI run on the
  red commit; build failures are NOT evidence); `cloudKitDatabase` stays `.none`
  until the §4.3 flip (which must also design undone-slip tombstoning).
- Snapshot goldens: pinned in-test geometry (.iPhone13) + AX5 axis; re-record
  deliberately via the CI artifact; SnapshotTesting exact-pinned at 1.19.3.
- Carried product notes: store-route SlipFraming passes momentum/motivation nil
  (feed real values in the dashboard epic); dashboard-half slip XCUITest waits
  for the fixture-seeding session.
