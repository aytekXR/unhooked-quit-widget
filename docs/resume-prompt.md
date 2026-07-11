# Resume Prompt: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Resume Prompt v3.0 |
| Last updated | 2026-07-11 (Session 18 close: E5.3 COMPLETE — red evidence `29156626484` (210 tests, EXACTLY the 31 designed issues, harness-predicted label-for-label on TWO lanes) → burned `29157369825` (missing `@MainActor` on the new XCUITest class — gate extended, rule 2) → `29157616479` verified the implementation whole but the new smoke flaked its first drive → the ruling-(e) valve fired (scenario-29 → E7) → final green `29158183470` + TestFlight; 4 billed runs) |
| Phase | Phase 1 core build — **Epic 5 CLOSED** (E5.1+E5.2+E5.3); E2.1–E2.4 + E3.1–E3.3 + E4.1–E4.2 + E8.1 DONE; delivery 20/32 (62%) |
| Next session objective | **Session 19: E8.2 — consent screen at the reserved slot-3 seam + payload-audit doc** |

> **What changed in Session 18:** E5.3 shipped WHOLE — the personalized summary
> is live at the completion seam (gate → quiz → SUMMARY → dashboard): projected
> savings = weeklySpend × 52 Decimal-exact stored on the EXISTING
> `QuizProfile.projectedAnnualSavings`, displayed floor-to-ten ("~$1,350/year"
> — never overstates); the risk window derives ONLY from frequency+trigger
> answers (precedence evenings > afterWork > social > alone > boredom > stress),
> stores a TOKEN, renders a hedged phrase from `summaryCopy.json` (its own
> audited table — the Architect killed the quizConfig-steps[] hazard by
> construction), and NO answers → NO line, never a guess. **`quiz_completed`
> now fires — once per completion, on summary render, via
> `QuizFlowModel.onSummaryAppear()`** (payload exactly {habit_category,
> goal_mode}; production still `.disabled`). **SOCIAL PROOF was DEFERRED by the
> step-0 panel (vetoable):** no real review quotes exist pre-launch, fabricated
> ones are banned — the summary CTA (`onContinue` in PostGateRootView) is the
> reserved NAMED seam E7 remaps; a Brand-verified trust-frame fallback table
> sits in the Session 18 ledger if the operator vetoes to (b). The scenario-29
> partial XCUITest was built, flaked its first CI drive (the wheel-adjust
> interaction), and its pre-recorded valve fired: it DEFERS to E7, where the
> full quiz→summary→paywall E2E lands with proper drive diagnostics. The
> `UITEST_RESET` fresh-install hook it introduced STAYS (inert; the recorded
> prerequisite for any state-mutating UITest). Eight vetoable rulings in
> operator-expected. Full ledger: Session 18 in `docs/past-prompts.md`.

---

## Standing tooling rules (permanent, apply to every agent)

1. **CodeGraph**: query `codegraph_explore` (shell: `codegraph explore "..."`)
   BEFORE grep/find or manual reading; pass this instruction into every
   subagent/workflow prompt; check blast radius before editing public symbols.
   **Before the session-end commit: `codegraph sync` + confirm status clean.**
2. **Parse gate**: `swiftc -parse` every touched Swift file before every push.
   PLUS the import-AND-ANNOTATION coverage check on every NEW test file: copy
   the closest proven neighbor's import block AND its CLASS DECLARATION LINE
   attributes (`@MainActor` on every UITest class — XCUIApplication is
   MainActor-isolated under Swift 6). The parse gate is import-blind
   (Session 15 burned a run) AND isolation-blind (Session 18 burned a run —
   same class, one tier up). Compile critics must trace class-level
   attributes, not just API idioms.
3. **Access-level gate + empirical harness:** scan for private types in
   non-private signatures, and RUN (never just typecheck) a Linux scratch
   harness over the exact shipping bytes of every pure-Foundation API — both
   red and green profiles when a designed red exists (Sessions 15–18: the
   harness predicted the billed red runs issue-for-issue, four times running;
   Session 18 harnessed the @Observable model + real AnalyticsService lane too).
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
   consent, companion) needs the PM+Brand+QA joint copy-table sign-off before
   code. E8.2's consent copy is squarely inside this gate.

## Where we are

- **The M1 user loop is real end to end:** age gate → quiz (10–12 screens) →
  personalized summary (savings hero + risk window + verbatim motivations) →
  placeholder dashboard → panic flow renders the user's own words → slip →
  undo. The newest TestFlight build walks all of it.
- **Every quiz-funnel event now has a LIVE fire-point:** `onboarding_started`
  (once, resume-suppressed), `quiz_step_completed` (fixed canonical slots),
  `quiz_completed` (summary render, once per completion) — plus `urge_averted`
  + `slip_undone` from E8.1. ALL still dead in production behind the double
  gate: `isOptedIn` hardwired `{ false }` until E8.2, transport DORMANT until
  the operator's TelemetryDeck app ID (§8).
- **E8.2's seam is waiting:** quizConfig.json slot 3 is the reserved unrendered
  consent step (`kind: "seam"`, `owner: "E8.2"`) — render the real consent UI
  there WITHOUT renumbering (fixed canonical slots; the progress bar shows the
  visible position). `AppSettings.analyticsOptIn` exists (default false) — NO
  schema work expected.
- The summary CTA (`onContinue` in `PostGateRootView`) is E7's named paywall
  seam. `quit_created` wiring is deferred to the E8 batch WITH the
  QuizCompletionTests guard-4 widening in the same commit (Session 18 ruling 7).
- **StreakEngine 1.2.0 untouched. TestFlight LIVE** through green
  `29158183470`. CI signing read-only; never re-enable MATCH_BOOTSTRAP; macOS
  minutes bill 10x.
- Brand kit load-bearing: no red anywhere; slip + age-gate + quiz + SUMMARY
  strings all CI-lexicon-gated; quiz AND summary copy are DRAFT pending the
  founder pass (operator-expected §3); Epic-5 goldens (incl. the summary — the
  most designed screen) deliberately zero until after it.

## Next session objective (one session, definition of done below)

**Session 19 — E8.2 consent screen + payload audit harness** (implementation-plan
row, verbatim goal): quiz-adjacent opt-in (default off) + a repeatable MITM
audit script for the release gate. Plan-named tests:
`test_consentDefaultsToOff()`, `test_analyticsEventsBlockedBeforeConsent()`;
the audit itself is a documented manual/scripted gate (`docs/payload-audit.md`)
run by the operator against a TestFlight build. Acceptance: intercepted traffic
contains only §5 events/properties. Epic 8 DoD: every call site type-checks
against the enum ✓ (E8.1); payload audit executed and archived (operator half);
App Privacy label drafted from the audit result.

0. **STEP-0 candidates (resolve BEFORE red, the Sessions 16–18 discipline):**
   (a) does the rendered consent step emit `quiz_step_completed(3)` after its
   answer? (It CAN fire honestly once opted in — the fire is beside the
   checkpoint write AFTER the choice; but MVP §5 says "fire nothing before the
   opt-in choice", and the fixed-slot funnel comparability argues for emitting;
   PM+Architect rule it, vetoable.) (b) What retires the hardwired
   `isOptedIn: { false }` — the composition-root closure reads
   `AppSettings.analyticsOptIn` (repository read helper, the
   onboardingVariant/latestSummaryInputs precedent); consent must apply to
   events fired LATER in the same quiz run (the summary's quiz_completed).
   (c) Where the consent ANSWER persists — `AppSettings.analyticsOptIn`
   directly (NOT the quiz checkpoint, NOT a QuizAnswer — the checkpoint may
   not carry the consent choice; decide + pin). (d) Resume behavior around
   slot 3 (checkpoint-resume must not re-ask or skip-forget). (e) The consent
   copy table: extend quizConfig.json's slot-3 step in place (it IS a quiz
   step) vs a separate file — note the steps[] hazard cuts the OTHER way here:
   consent IS an engine-rendered step, so its strings belong in quizConfig
   slot 3; PM+Brand+QA joint sign-off (safety-content gate), plain-language
   (MVP §5 note), DRAFT/founder-owned.
1. **Red first** (billed run 1): the two plan-named tests + pins for: slot 3
   renders between slots 2 and 4 with NO renumbering (fixed ordinals), the
   stored opt-in gates fire() live (opted-in AFTER the consent step → summary
   quiz_completed reaches the sink; declined → nothing, forever until changed),
   erase resets consent to OFF, the age-gate/pre-consent surfaces still fire
   NOTHING, checkpoint resume lands on/after slot 3 correctly.
2. **Green** (billed run 2): the consent step UI at slot 3 (calm two-choice,
   no dark pattern, decline is a first-class equal button — QuietButton
   discipline), the AppSettings write, the composition-root closure retire,
   `docs/payload-audit.md` (the operator-run MITM procedure + the §5
   expected-traffic table + the archive checklist).
3. Scope guards: (a) NO TelemetryDeck app ID wiring (§8 stays operator-owned;
   the transport stays DORMANT — consent alone still sends nothing); (b) NO new
   `AnalyticsEvent` case; (c) `quit_created` rides ONLY with the
   QuizCompletionTests guard widening (ruling 7) — QA rules if it earns the
   slot; (d) goldens STILL deferred unless the founder copy pass landed (check
   operator-expected §3 at open); (e) the quiz engine's visibility/slot logic
   is NOT re-opened — the seam renders by flipping its kind/owner handling,
   never by renumbering.
4. Budget: 2 billed runs planned (+1 contingency; check operator-expected §4).

## Operator-owned blockers (not agent work; carry until closed)

1. E0.3 device measurement (`docs/spike-panic-latency.md`) — still the only
   blocker on the permanent latency gate (and `panic_opened`'s `cold_start_ms`).
2. E3.3 device matrix (operator-expected §7).
3. Content tone review (§3) — the FOUNDER COPY PASS now covers quizConfig.json
   AND summaryCopy.json (11 new DRAFT strings; one flagged nit: the hero
   "…/year" + caption "saved in a year…" double-read; Brand's optional
   alternative recorded) + safetyCopy/helplines/ageGateCopy + the ALO 182
   verify→flip + the E4.2 checklist signature. The pass unblocks the Epic-5
   goldens batch (now incl. the summary screen).
4. GitHub Actions billing headroom (§4 — Session 18 used 4: its 2 planned + the burned-run fix + the smoke-valve removal).
5. TestFlight testers (§5 — the newest build completes the M1 loop: the
   summary payoff now renders between quiz and dashboard).
6. TelemetryDeck app ID (§8 — becomes the LAST gate on real funnel data once
   E8.2 ships); Slack webhook rotation (§6, optional).

## Resume prompt (copy-paste for next session)

> You are the lead build agent for **unhooked-quit-widget** (app name
> **Ballast**, org `com.beyondkaira`). Epic 5 is CLOSED (E5.3 green
> `29158183470`; the DoD's XCUITest clause rides E7 via the ruling-(e) valve);
> Session 19 = E8.2 consent screen + payload-audit doc. Local
> Swift toolchain: `. ~/.local/share/swiftly/env.sh`.
> **Standing gates:** CodeGraph query-first + sync at close; `swiftc -parse`
> every touched file + import-coverage on every new test file; access-level
> scan + Linux harness RUN empirically (red AND green profiles; the model +
> AnalyticsService lane is harnessable — Session 18 proved it); docs-check
> every SDK spelling (SwiftUI: house `.background(_:in:)` form only);
> docs-only commits `[skip ci]`, no workflows for docs-only work; critics
> Write findings to files; NEVER `git stash`; privacy-surface changes need
> Architect pre-approval BEFORE code; consent copy is SAFETY-CONTENT (PM+
> Brand+QA sign-off at spec time, founder owns final words, plain language);
> `git fetch` + `git log origin/main` before every push.
> READ FIRST: `docs/implementation-plan.md` E8.2 row + Epic 8 DoD,
> `docs/mvp.md` §5 (the implementation note: "fire nothing before the
> analytics opt-in choice; the opt-in prompt lives in the quiz's early steps
> with plain-language copy") + §7 privacy gates, `docs/architecture.md` §10 +
> ADR-8, `docs/operator-expected.md` §3 (founder pass landed? → goldens) + §4
> + §8, the Session 18 ledger (the slot-3 seam contract; ruling 7's
> quit_created batch plan; the step-0 candidates), `docs/session-rules.md`,
> `App/Resources/Content/quizConfig.json` (the slot-3 seam bytes),
> `App/Sources/AnalyticsService.swift` (fire() = THE gate; `.disabled`),
> `App/Sources/Quiz/QuizFlowEngine.swift` (seam visibility filter — flip it
> for a RENDERED slot 3 without renumbering).
> **This session:** STEP-0 rulings (a)–(e) (PM+Architect, vetoable) →
> Architect pre-approval (AppSettings.analyticsOptIn write path + the
> composition-root closure retire + the seam render) → PM copy table (slot-3
> strings, plain-language, DRAFT, founder-flagged; Brand+QA co-sign) → red
> (the two plan-named tests + the seam/ordering/erase/resume pins) → THE
> red-evidence run → green (consent UI + stored opt-in + closure retire +
> `docs/payload-audit.md`) → verify all-green → flag operator items.
> **At session end:** append the Session 19 ledger, overwrite this resume
> prompt (next per `roadmap.md` — likely E6.1 widgets or E7.1 paywall),
> update `docs/operator-expected.md`, `codegraph sync`, commit `[skip ci]`,
> push, `gh run watch` green.

## Standing rules reminders (do not relearn these)

- Analytics ONLY via the closed enum; zero events before opt-in; never a
  generic track; adding a case = MVP §5 row (OPERATOR) + Architect + fixture +
  whitelist. Fires post-save, BESIDE writes, never inside; never pre-frame on
  the panic path (ADR-6). The age-gate surface fires NOTHING; the quiz fires
  `onboarding_started` (once, resume-suppressed) + `quiz_step_completed`
  (fixed canonical slots) + `quiz_completed` (summary render ONLY, once per
  completion via `onSummaryAppear()`). Consent is hardwired OFF until E8.2
  retires the `{ false }` closure; the transport stays DORMANT until the
  operator app ID (§8) — the double gate.
- No shame copy (slip AND age-gate AND quiz AND summary strings CI-gated;
  lexicon only GROWS); no medical claims; no fabricated statistics or
  testimonials (the Session-18 social-proof deferral is this rule applied); no
  red anywhere; discreet variants mandatory where habit context exists;
  motivations VERBATIM in user order.
- Monotonic fields never decrease — undo is the ONE exemption (§9r3); streaks
  freeze, never inflate (ADR-7); `totalCleanSeconds` is BANKED-only.
  QuizProfile's summary fields are quiz-time projections — computed once at
  completion, NEVER wired into recomputeDerivedState (Session 18 MF2).
- WITNESS discipline: three advance paths only; erase clears it; flush/undo
  never advance; deferred slips apply with the SLIP-TIME witness.
- Erase discipline: local-first; key sweep (incl. the quiz checkpoint,
  app-standard defaults; E8.2 adds consent→OFF); owned file-set; cloud purge
  last; post-erase relaunch = fresh install ⇒ the AGE GATE and the QUIZ return.
- Panic path stays thin: panic surfaces NEVER open the store; the panic route
  never consults the gate or the quiz; single store; no accounts.
- Control-family attribution ceiling stands (`.controlCenter`); never
  fabricate `.actionButton`.
- Never weaken a QA assertion; TDD red first (red evidence = the CI run on the
  red commit; build failures are NOT evidence); `cloudKitDatabase` stays
  `.none` until the §4.3 flip.
- Snapshot goldens: pinned geometry (.iPhone13) + AX5; re-record deliberately
  via the CI artifact; Epic-5 goldens (incl. the summary) wait on the founder
  copy pass; SnapshotTesting 1.19.3 + TelemetryDeck 2.14.1 pinned.
- Carried product notes: store-route SlipFraming passes momentum/motivation
  nil (dashboard epic feeds real values); dashboard-half slip XCUITest waits
  for the fixture-seeding session; the quiz checkpoint is the ONE sanctioned
  in-progress free-text store; `quit_created` fire-point = repository create
  path (assigned; rides the E8 batch WITH the guard widening — ruling 7);
  UITest self-isolation = the `UITEST_RESET` hook (fresh-install sweep incl.
  the quiz checkpoint) — new state-mutating UITests must use it; it currently
  has NO consumer (scenario-29 deferred to E7 by the ruling-(e) valve — the
  wheel-drive flake; E7 re-lands the smoke WITH drive diagnostics).
