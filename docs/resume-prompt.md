# Resume Prompt: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Resume Prompt v2.8 |
| Last updated | 2026-07-11 (Session 16 close: E5.1 COMPLETE — red evidence `29135328846` (7 designed cases / 30 issues, harness-predicted issue-for-issue) → green `29136061287` all-green + TestFlight, 2 billed runs, ZERO burned) |
| Phase | Phase 1 core build — Epics 0–1 CLOSED; E2.1–E2.4 + E3.1–E3.3 + E4.1–E4.2 + E5.1 + E8.1 DONE; delivery 18/32 (56%) |
| Next session objective | **Session 17: E5.2 — quiz engine + 12–14 screens (agents scaffold, FOUNDER owns copy — see scope guard 3)** |

> **What changed in Session 16:** E5.1 shipped WHOLE — the age gate is the app's
> FIRST screen (conservative boundary: pass iff `currentYear − birthYear ≥ 18`,
> operator-vetoable), under-17 blocks to a calm VERIFIED-helplines resources
> surface (predicate `appliesTo:"all" AND verified:true` — US 988; TR 112 until
> the operator verifies ALO 182), only `AppSettings.ageGatePassed` is ever
> stored (schema-walk pinned), and the ENTIRE surface fires zero analytics —
> the plan's `age_gate_blocked` test was re-specced (step-0 ruling: the event is
> structurally unfireable, consent lives post-gate; no mvp.md edit was needed).
> `AgeGateContainerView` is now the normal-route ROOT above `RootPlaceholderView`
> and carries the route-level `root.placeholder` anchor in every state — E5.2
> mounts INSIDE it and inherits the gate for free. `safetyCopy.json` +
> `helplines.json` + `ageGateCopy.json` are now bundled (operator tone review
> moved up — operator-expected §3). ALSO: `docs/testflight-tester-guide.md`
> (operator request). Full ledger: Session 16 in `docs/past-prompts.md`.

---

## Standing tooling rules (permanent, apply to every agent)

1. **CodeGraph**: query `codegraph_explore` (shell: `codegraph explore "..."`)
   BEFORE grep/find or manual reading; pass this instruction into every
   subagent/workflow prompt; check blast radius before editing public symbols.
   **Before the session-end commit: `codegraph sync` + confirm status clean.**
2. **Parse gate**: `swiftc -parse` every touched Swift file before every push.
   PLUS the import-coverage check on every NEW test file (copy the closest
   proven neighbor's import block; grep non-Foundation types against imports —
   the parse gate is import-blind; Session 15 burned a run on this).
3. **Access-level gate + empirical harness:** scan for private types in
   non-private signatures, and RUN (never just typecheck) a Linux scratch
   harness over the exact shipping bytes of every pure-Foundation API — both
   red and green profiles when a designed red exists (Sessions 15 AND 16: the
   harness predicted the billed red runs issue-for-issue).
4. **Docs-check gate:** every Darwin-only / AppIntents / SF-Symbol /
   third-party member spelling verified against official docs BEFORE code; for
   SPM deps also clone the pinned tag. **Session 16 addition — SwiftUI under
   warnings-as-errors: use the house `.background(_:in:)` form, NEVER the bare
   positional `.background(<View>)` (soft-deprecated overload; a green critic
   caught two sites pre-push).**
5. Docs-only commits carry `[skip ci]`; never spawn agent workflows for
   docs-only changes. Critic/reader agents Write findings to scratchpad files
   and return a one-line pointer. **NEVER `git stash` mid-session** (a Session
   16 stash briefly reverted the uncommitted red commit; recovered) — commit
   docs via pathspec with code left dirty.
6. `git fetch` + `git log origin/main` before EVERY push — the operator commits
   mid-session.
7. **Privacy-surface gate:** anything touching stores/`AnalyticsEvent`/outbound
   gets Architect pre-approval BEFORE implementation; adding an enum case is
   Architect-gated AND needs the MVP §5 row first (mvp.md is OPERATOR-ONLY).
   **Safety-content** (slip copy, resources, alcohol notice, age gate,
   companion) needs the PM+Brand+QA joint copy-table sign-off before code.

## Where we are

- **The age gate stands.** Every future normal-route surface mounts INSIDE
  `AgeGateContainerView` — no habit content is reachable pre-gate, fail-closed,
  and that stays true through E5.2 with zero extra work. The blocked surface is
  the verified-helplines screen; unverified rows can never render there
  (test-pinned).
- **The analytics boundary is LIVE** (E8.1): closed 19-case enum, `fire()` the
  one consent gate (hardwired OFF until E8.2), TelemetryDeck dormant behind the
  operator app ID. The age gate fires NOTHING by design; `onboarding_started`
  belongs to E5.2's first quiz screen and `quiz_step_completed` /
  `quiz_completed` cases already exist in the enum (no schema work needed for
  E5.2's named tests — fire-point wiring only, spy tests inject opted-IN).
- **StreakEngine 1.2.0 untouched. TestFlight LIVE** through green `29136061287`
  — the newest build shows the AGE GATE first (operator-expected §2/§5 updated).
  CI signing read-only; never re-enable MATCH_BOOTSTRAP; macOS minutes bill 10x.
- Brand kit load-bearing: no red anywhere; slip strings CI-gated; age-gate
  strings CI-gated (SlipLexiconTests scans `ageGateCopy.json` + degraded);
  discreet variants neutral; motivations VERBATIM.

## Next session objective (one session, definition of done below)

**Session 17 — E5.2 quiz engine + 12–14 screens** (implementation-plan row,
verbatim goal): data-driven quiz (screens from a config array, one question
each, progress bar) capturing habit/frequency/spend/triggers/motivations/goal;
answers → `QuizProfile` + quit creation.

1. **Red first** (billed run 1): the five plan-named tests —
   `test_quiz_everyStepAdvance_firesQuizStepCompleted(step:)`,
   `test_quiz_answersPersistLocallyOnly()`,
   `test_quiz_backNavigation_preservesAnswers()`,
   `test_quizCompletion_createsQuitWithMotivationsAndSpend()`,
   `test_quizCompletion_writesMotivationsPreCache()`.
2. **Green** (billed run 2): the engine + config + screens, mounted INSIDE the
   age-gate container's passed branch (replacing `RootPlaceholderView` as the
   post-gate content or wrapping it — Architect decides; the gate itself is
   NOT touched).
3. Scope guards: (a) `createQuit(from profile:)` lands here (the architecture
   §5.1 note says the quiz's form arrives with E5 — repository change ⇒
   Architect privacy pre-approval BEFORE code); (b) `quiz_step_completed` /
   `quiz_completed` / `onboarding_started` fire-points are post-save,
   spy-pinned opted-IN, red-first — NO new enum cases needed or allowed;
   (c) **the consent STEP is E8.2's, not E5.2's** — leave a named seam in the
   quiz config for it (MVP §5: the opt-in prompt lives in the quiz's early
   steps), do not build the consent screen; (d) **quiz COPY is founder-owned**
   (roadmap: "agents scaffold screens, copy owned by founder") — scaffold with
   draft copy in ONE audited table (the ageGateCopy precedent), lexicon-scan
   it, and flag the operator copy pass in operator-expected §3; per-question
   PM copy table at spec time (agent-workflows §2.2 step 1); (e) custom habit
   name never leaves the device (test-pinned per the plan);
   (f) batch the E5.1+E5.2 snapshot goldens in ONE deliberate CI-artifact
   re-record IF goldens are added — E5.1 shipped none.
4. Also fold in (small, same session if it fits red/green cleanly): the Epic-5
   DoD navigation XCUITest (age gate un-bypassable end-to-end) — it needs quiz
   screens to exist (scenario 29) and may claim an E2E slot per test-suite §1.6.
5. Budget: 2 billed runs planned (+1 contingency — the quiz is the largest
   single surface yet; check operator-expected §4 headroom).

## Operator-owned blockers (not agent work; carry until closed)

1. E0.3 device measurement (`docs/spike-panic-latency.md`) — still the only
   blocker on the permanent latency gate (and on `panic_opened`'s
   `cold_start_ms`).
2. E3.3 device matrix (operator-expected §7).
3. Content tone review (§3) — NOW INCLUDES: safetyCopy/helplines (TestFlight-
   visible since E5.1), `ageGateCopy.json`, the ALO 182 verify→flip-flag task,
   and the E4.2 checklist signature.
4. GitHub Actions billing headroom (§4 — Session 16 used exactly its 2).
5. TestFlight testers (§5 — guide written; the age-gate build is live).
6. TelemetryDeck app ID (§8, no urgency); Slack webhook rotation (§6, optional).

## Resume prompt (copy-paste for next session)

> You are the lead build agent for **unhooked-quit-widget** (app name
> **Ballast**, org `com.beyondkaira`). E5.1 is DONE (green `29136061287`);
> Session 17 = E5.2 quiz engine + screens. Local Swift toolchain:
> `. ~/.local/share/swiftly/env.sh`.
> **Standing gates:** CodeGraph query-first + sync at close; `swiftc -parse`
> every touched file + import-coverage on every new test file; access-level
> scan + Linux harness RUN empirically (red AND green profiles); docs-check
> every SDK spelling (SwiftUI: house `.background(_:in:)` form only);
> docs-only commits `[skip ci]`, no workflows for docs-only work; critics
> Write findings to files; NEVER `git stash`; privacy-surface changes
> (incl. `createQuit(from profile:)`) need Architect pre-approval BEFORE code;
> quiz copy tables get the PM sign-off at spec time and the FOUNDER owns final
> copy; `git fetch` + `git log origin/main` before every push.
> READ FIRST: `docs/implementation-plan.md` E5.2 row + Epic 5 DoD,
> `docs/mvp.md` §5 (quiz events exist — no schema work) + §2,
> `docs/architecture.md` §5.1 (createQuit from-profile note) + §3,
> `docs/operator-expected.md` §3/§4, the Session 16 ledger (the gate container
> E5.2 mounts inside; the E5.2 scope guards in resume-prompt v2.8),
> `docs/session-rules.md`, `docs/frontend-brandkit.md`.
> **This session:** Architect pre-approval (repository + quiz architecture) →
> PM copy tables (draft, founder-flagged) → red (the five named tests) → THE
> red-evidence run → green (engine + config + screens inside the gate
> container) → verify all-green → flag operator items (copy pass!).
> **At session end:** append the Session 17 ledger, overwrite this resume
> prompt (next per `roadmap.md` — likely E5.3 summary screen or E8.2 consent),
> update `docs/operator-expected.md`, `codegraph sync`, commit `[skip ci]`,
> push, `gh run watch` green.

## Standing rules reminders (do not relearn these)

- Analytics ONLY via the closed enum; zero events before opt-in; never a
  generic track; adding a case = MVP §5 row (OPERATOR) + Architect + fixture +
  whitelist. Fires post-save, BESIDE writes, never inside; never pre-frame on
  the panic path (ADR-6). The age-gate surface fires NOTHING (test-pinned).
- No shame copy (slip AND age-gate strings CI-gated; lexicon only GROWS); no
  medical claims; no red anywhere; discreet variants mandatory where habit
  context exists; motivations VERBATIM in user order.
- Monotonic fields never decrease — undo is the ONE exemption (§9r3); streaks
  freeze, never inflate (ADR-7); `totalCleanSeconds` is BANKED-only.
- WITNESS discipline: three advance paths only; erase clears it; flush/undo
  never advance; deferred slips apply with the SLIP-TIME witness.
- Erase discipline: local-first; key sweep; owned file-set; cloud purge last;
  post-erase relaunch = fresh install ⇒ the AGE GATE returns (by design).
- Panic path stays thin: panic surfaces NEVER open the store; the panic route
  never consults the gate (pre-gate its pre-cache is empty by construction —
  the structural guarantee, resolver-pinned); single store; no accounts.
- Control-family attribution ceiling stands (`.controlCenter`); never fabricate
  `.actionButton`.
- Never weaken a QA assertion; TDD red first (red evidence = the CI run on the
  red commit; build failures are NOT evidence); `cloudKitDatabase` stays
  `.none` until the §4.3 flip.
- Snapshot goldens: pinned geometry (.iPhone13) + AX5; re-record deliberately
  via the CI artifact; SnapshotTesting 1.19.3 + TelemetryDeck 2.14.1 pinned.
- Carried product notes: store-route SlipFraming passes momentum/motivation nil
  (dashboard epic feeds real values); dashboard-half slip XCUITest waits for
  the fixture-seeding session; E5.1 screens have NO goldens yet (batch with
  E5.2's).
