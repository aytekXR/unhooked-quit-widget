# Resume Prompt: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Resume Prompt v2.9 |
| Last updated | 2026-07-11 (Session 17 close: E5.2 COMPLETE — red evidence `29151832001` (25 designed cases / 55 issues, harness-predicted issue-for-issue) → green `29152486541` all-green + TestFlight, 2 billed runs, ZERO burned) |
| Phase | Phase 1 core build — Epics 0–1 CLOSED; E2.1–E2.4 + E3.1–E3.3 + E4.1–E4.2 + E5.1–E5.2 + E8.1 DONE; delivery 19/32 (59%) |
| Next session objective | **Session 18: E5.3 — personalized summary + social proof (step-0 FIRST: the social-proof content question)** |

> **What changed in Session 17:** E5.2 shipped WHOLE — the data-driven quiz is
> live inside the age-gate container (gate → quiz → quit is the ONLY path to
> content, unit-pinned): 13 config slots from bundled `quizConfig.json` (the ONE
> audited copy table, every string DRAFT/FOUNDER-OWNED — operator-expected §3),
> `createQuit(from profile:)` maps answers verbatim (motivations in user order →
> the panic pre-cache), `onboarding_started` + `quiz_step_completed` fire live
> red-first with FIXED canonical step numbers, the consent slot 3 is a reserved
> unrendered seam (E8.2's), the resume checkpoint lives in app-standard defaults
> and is erase-swept, and **`quiz_completed` is deliberately NOT fired — E5.3's
> summary render owns it** via the waiting handoff
> `QuizFlowModel.completion: (habitCategory, goalMode)`. Post-completion the app
> currently lands on the placeholder dashboard — `PostGateRootView`'s completion
> branch is E5.3's mount seam. Seven vetoable rulings in operator-expected.
> Full ledger: Session 17 in `docs/past-prompts.md`.

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
   red and green profiles when a designed red exists (Sessions 15–17: the
   harness predicted the billed red runs issue-for-issue, three times running).
4. **Docs-check gate:** every Darwin-only / AppIntents / SF-Symbol /
   third-party member spelling verified against official docs BEFORE code;
   SwiftUI under warnings-as-errors: house `.background(_:in:)` form only,
   never the bare positional `.background(<View>)`.
5. Docs-only commits carry `[skip ci]`; never spawn agent workflows for
   docs-only changes. Critic/reader agents Write findings to scratchpad files
   and return a one-line pointer. **NEVER `git stash` mid-session** — commit
   docs via pathspec with code left dirty.
6. `git fetch` + `git log origin/main` before EVERY push — the operator commits
   mid-session.
7. **Privacy-surface gate:** anything touching stores/`AnalyticsEvent`/outbound
   gets Architect pre-approval BEFORE implementation; adding an enum case is
   Architect-gated AND needs the MVP §5 row first (mvp.md is OPERATOR-ONLY).
   **Safety-content** (slip copy, resources, alcohol notice, age gate, quiz,
   companion) needs the PM+Brand+QA joint copy-table sign-off before code.

## Where we are

- **The onboarding spine is real end to end:** age gate → quiz (10–12 rendered
  screens by path) → quit creation with the user's verbatim motivations → the
  panic flow renders those words. The quiz mounts inside
  `AgeGateContainerView` via `PostGateRootView` (no active quit → quiz; else
  placeholder dashboard) — E5.3's summary mounts at the COMPLETION seam
  (`QuizFlowModel.completion != nil`), inheriting the gate for free.
- **The E5.3 handoff is waiting:** `QuizFlowModel.completion` carries
  `(habitCategory, goalMode)` — exactly `quiz_completed`'s payload. The enum
  case exists (`quizCompleted(habitCategory:goalMode:)`); NO schema work, fire
  wiring only, red-first, spy-pinned opted-IN.
- `QuizProfile` already has the E5.3 fields (`projectedAnnualSavings` = 0,
  `predictedRiskWindow` = nil at handoff) — fill them, ADD NO FIELD (CloudKit
  checklist; the schema exact-set pins will catch a drive-by).
- **Analytics boundary LIVE** (E8.1): consent hardwired OFF until E8.2; the
  quiz fires `onboarding_started` + `quiz_step_completed` with FIXED canonical
  slots (1–13; 14 = the summary, E5.3's). The consent step is the reserved
  slot-3 seam — E8.2's, do not build or renumber.
- **StreakEngine 1.2.0 untouched. TestFlight LIVE** through green `29152486541`
  — the newest build walks gate → quiz → quit creation (the first
  create-from-UI build; operator-expected §2/§5). CI signing read-only; never
  re-enable MATCH_BOOTSTRAP; macOS minutes bill 10x.
- Brand kit load-bearing: no red anywhere; slip + age-gate + QUIZ strings all
  CI-lexicon-gated; quiz copy is DRAFT pending the founder pass
  (operator-expected §3); Epic-5 goldens deliberately zero until after it.

## Next session objective (one session, definition of done below)

**Session 18 — E5.3 personalized summary + social proof** (implementation-plan
row, verbatim goal): projected yearly savings + risk-window hint derived
on-device; social-proof screen; hands off to paywall.

0. **STEP-0 (resolve BEFORE red, the Session 16/17 discipline): the
   social-proof content question.** PRD §6.1 says "real review quotes" — none
   exist pre-launch, and fabricated quotes/statistics violate MVP §7 and the
   Honest personality (brandkit §1.1). Options for the PM+Architect panel (all
   operator-vetoable, none edits mvp.md): (a) defer the social-proof SCREEN to
   post-TestFlight-feedback and ship summary-only (navigation seam reserved),
   (b) scaffold a non-testimonial trust frame (privacy positioning — "No
   account. No server." — the paywall copy MVP §6 already sanctions) with the
   founder owning final content, (c) block on operator-supplied quotes. The
   panel decides and records it vetoable; the `test_summary_shownBeforeAnyPaywall`
   navigation pin is unaffected either way.
1. **Red first** (billed run 1): the three plan-named tests —
   `test_summary_projectedSavings_matchesSpendMath()`,
   `test_riskWindowHint_derivedFromTriggerAnswers()`,
   `test_summary_shownBeforeAnyPaywall()` — plus the fire-point pin for
   `quiz_completed` on summary render (opted-IN spy; once per completion; the
   R2 ruling made this E5.3's) and pins for: QuizProfile fields filled at
   summary time (no new field), savings math Decimal-safe (weekly spend × 52,
   the §1.1 test-9 "~$1,340/year" class), risk window derived ONLY from
   frequency/trigger answers on-device, degraded/empty-answer safety (no
   answers → no invented window — "insufficient data shows nothing, not
   guesses" is the house posture).
2. **Green** (billed run 2): summary screen mounted at `PostGateRootView`'s
   completion branch (Architect decides: summary-once-then-dashboard vs
   summary-persisted; the handoff object is in memory only), the on-device math,
   `quiz_completed` fired on render (post-mount, beside nothing — it is a
   render-trigger event per the canonical table), social-proof per step-0.
3. Scope guards: (a) NO paywall (E7) — the summary "hands off" to a named seam;
   (b) NO new `AnalyticsEvent` case or associated value; (c) summary copy joins
   the audited-table discipline (extend `quizConfig.json` or a new
   `summaryCopy.json` — Architect picks; lexicon-scan either way; strings
   DRAFT/founder-owned); (d) snapshot goldens STILL deferred unless the founder
   copy pass (operator-expected §3) has landed — check its checkbox at session
   open; (e) the scenario-29 XCUITest may now cover gate→quiz→summary (its
   paywall tail stays E7) — QA rules on whether the partial earns the slot or
   waits; (f) `quit_created` wiring stays deferred unless it rides red/green
   cleanly (its fire-point is assigned: repository create path, post-save).
4. Budget: 2 billed runs planned (+1 contingency; check operator-expected §4).

## Operator-owned blockers (not agent work; carry until closed)

1. E0.3 device measurement (`docs/spike-panic-latency.md`) — still the only
   blocker on the permanent latency gate (and `panic_opened`'s `cold_start_ms`).
2. E3.3 device matrix (operator-expected §7).
3. Content tone review (§3) — NOW INCLUDES the FOUNDER QUIZ COPY PASS
   (`quizConfig.json`, all strings DRAFT; effects-step medical read; the
   motivation-elaboration decision) + safetyCopy/helplines/ageGateCopy + the
   ALO 182 verify→flip + the E4.2 checklist signature. The copy pass also
   unblocks the Epic-5 goldens batch.
4. GitHub Actions billing headroom (§4 — Session 17 used exactly its 2).
5. TestFlight testers (§5 — the newest build is the first with real onboarding
   end-to-end: gate → quiz → quit → panic with YOUR words).
6. TelemetryDeck app ID (§8, no urgency); Slack webhook rotation (§6, optional).

## Resume prompt (copy-paste for next session)

> You are the lead build agent for **unhooked-quit-widget** (app name
> **Ballast**, org `com.beyondkaira`). E5.2 is DONE (green `29152486541`);
> Session 18 = E5.3 personalized summary + social proof. Local Swift toolchain:
> `. ~/.local/share/swiftly/env.sh`.
> **Standing gates:** CodeGraph query-first + sync at close; `swiftc -parse`
> every touched file + import-coverage on every new test file; access-level
> scan + Linux harness RUN empirically (red AND green profiles); docs-check
> every SDK spelling (SwiftUI: house `.background(_:in:)` form only);
> docs-only commits `[skip ci]`, no workflows for docs-only work; critics
> Write findings to files; NEVER `git stash`; privacy-surface changes need
> Architect pre-approval BEFORE code; summary/social-proof copy gets the
> PM+Brand+QA sign-off at spec time and the FOUNDER owns final copy;
> `git fetch` + `git log origin/main` before every push.
> READ FIRST: `docs/implementation-plan.md` E5.3 row + Epic 5 DoD,
> `docs/mvp.md` §5 (quiz_completed trigger = "Personalized summary shown" —
> fire it THERE; no schema work) + §2 + §4 (the funnel metrics the trigger
> placement protects), `docs/prd.md` §6.1 (summary + social-proof framing),
> `docs/architecture.md` §3 (QuizProfile fields exist) + §7,
> `docs/operator-expected.md` §3 (founder copy pass landed? → goldens
> decision) + §4, the Session 17 ledger (the completion-seam mount; the
> social-proof step-0 question; the seven rulings), `docs/session-rules.md`,
> `docs/frontend-brandkit.md` §6.7 (QuitSummaryCard — "the most designed
> single screen in the app").
> **This session:** STEP-0 social-proof ruling (PM+Architect, vetoable) →
> Architect pre-approval (QuizProfile writes + summary mount + quiz_completed
> fire-point) → PM copy tables (draft, founder-flagged) → red (the three named
> tests + the quiz_completed pin) → THE red-evidence run → green (math +
> summary screen at the completion seam + social-proof per step-0) → verify
> all-green → flag operator items.
> **At session end:** append the Session 18 ledger, overwrite this resume
> prompt (next per `roadmap.md` — likely E8.2 consent or E6.1 widgets),
> update `docs/operator-expected.md`, `codegraph sync`, commit `[skip ci]`,
> push, `gh run watch` green.

## Standing rules reminders (do not relearn these)

- Analytics ONLY via the closed enum; zero events before opt-in; never a
  generic track; adding a case = MVP §5 row (OPERATOR) + Architect + fixture +
  whitelist. Fires post-save, BESIDE writes, never inside; never pre-frame on
  the panic path (ADR-6). The age-gate surface fires NOTHING; the quiz fires
  `onboarding_started` (once, resume-suppressed) + `quiz_step_completed`
  (fixed canonical slots) — `quiz_completed` fires ONLY on summary render.
- No shame copy (slip AND age-gate AND quiz strings CI-gated; lexicon only
  GROWS); no medical claims; no fabricated statistics or testimonials; no red
  anywhere; discreet variants mandatory where habit context exists;
  motivations VERBATIM in user order.
- Monotonic fields never decrease — undo is the ONE exemption (§9r3); streaks
  freeze, never inflate (ADR-7); `totalCleanSeconds` is BANKED-only.
- WITNESS discipline: three advance paths only; erase clears it; flush/undo
  never advance; deferred slips apply with the SLIP-TIME witness.
- Erase discipline: local-first; key sweep (incl. the quiz checkpoint,
  app-standard defaults); owned file-set; cloud purge last; post-erase
  relaunch = fresh install ⇒ the AGE GATE and the QUIZ return (by design).
- Panic path stays thin: panic surfaces NEVER open the store; the panic route
  never consults the gate or the quiz; single store; no accounts.
- Control-family attribution ceiling stands (`.controlCenter`); never
  fabricate `.actionButton`.
- Never weaken a QA assertion; TDD red first (red evidence = the CI run on the
  red commit; build failures are NOT evidence); `cloudKitDatabase` stays
  `.none` until the §4.3 flip.
- Snapshot goldens: pinned geometry (.iPhone13) + AX5; re-record deliberately
  via the CI artifact; Epic-5 goldens wait on the founder copy pass;
  SnapshotTesting 1.19.3 + TelemetryDeck 2.14.1 pinned.
- Carried product notes: store-route SlipFraming passes momentum/motivation
  nil (dashboard epic feeds real values); dashboard-half slip XCUITest waits
  for the fixture-seeding session; the quiz checkpoint is the ONE sanctioned
  in-progress free-text store; `quit_created` fire-point = repository create
  path (assigned, unwired).
