# Operator Expected — the live "what only aytek can do" checklist

| Field | Value |
|---|---|
| Status | LIVE — updated at every session close (operator request, Session 10) |
| Last updated | 2026-07-11 (Session 18 CLOSED: E5.3 personalized summary DONE — **Epic 5 is now fully closed** — red evidence `29156626484` (EXACTLY the 31 designed issues, harness-predicted label-for-label on two lanes) → burned `29157369825` (the new XCUITest class missed `@MainActor`; gate now in standing rule #2) → `29157616479` verified the implementation whole (unit 210/210 + snapshot) but the new gate→quiz→summary smoke flaked its FIRST drive → the pre-recorded QA valve fired: scenario-29 defers to E7 → final green `29158183470` + TestFlight, **4 billed runs**. The newest TestFlight build completes the M1 loop: gate → quiz → the SUMMARY PAYOFF (your projected savings + your likely hard window + your words) → dashboard → panic with your words. **The step-0 social-proof ruling: the screen is DEFERRED** (no real reviews exist pre-launch; fabricated ones are banned) — veto path below. Nothing blocks Session 19 = E8.2 consent. Open for you: §1–§8; §3 now also carries the SUMMARY copy rows. Session 16 + 17 + 18 vetoable rulings at the bottom.) |
| Rule for agents | Update this file at session end alongside `resume-prompt.md`. It is TRACKED (in `docs/`) so the operator can read it anywhere on the go. The untracked root `OPERATOR-TODO.md` is now just a pointer here. |

Nothing below blocks the next session (E8.2 consent). **§0 is CLOSED**
(only its optional gstack FYI remains). Items below §0 are ordered by how much
they age; check a box by replacing `[ ]` with `[x]` and the next session's
agent will prune completed items.

> **Session 18 outcome (2026-07-11):** E5.3 is DONE and **Epic 5 is closed** — the
> personalized summary renders at quiz completion (projected annual savings =
> weekly spend × 52, displayed floored-to-ten so it never overstates; a hedged
> "first hard window" line derived ONLY from your frequency/trigger answers —
> no answers, no line, never a guess; your motivation words echoed verbatim),
> then hands off to the dashboard through the NAMED seam E7 will remap to the
> paywall. `quiz_completed` now fires on summary render (in-process only —
> nothing leaves any build until E8.2 consent + your §8 app ID). **The step-0
> social-proof ruling (vetoable, #1 below): the PRD's "real review quotes"
> screen is DEFERRED until real reviews exist** — a fully-drafted, Brand-verified
> trust-frame alternative sits in the Session 18 ledger if you'd rather ship
> that. **Billed runs: 4** (red evidence `29156626484` matched the two-lane
> harness prediction label-for-label → `29157369825` BURNED: the new XCUITest
> file was missing the one-line `@MainActor` class annotation every neighbor
> carries, a build failure with no evidence → fix → `29157616479` proved the
> whole E5.3 implementation green (unit 210/210, snapshot clean) while the NEW
> gate→quiz→summary smoke itself flaked its first-ever CI drive (the
> birth-year wheel interaction) → QA's pre-recorded deferral valve fired: the
> smoke rides E7 with proper drive diagnostics; unit-tier routing pins hold
> the un-bypassability meanwhile → final green `29158183470` + TestFlight).
> The zero-burn streak ended at two sessions; BOTH closing gates are recorded
> (standing rule #2: neighbor-copying covers class annotations, not just
> imports; state-mutating UITests need the new UITEST_RESET hook AND land
> with drive diagnostics). Your NEW asks: §3 gains the 11 summaryCopy.json
> DRAFT strings (one flagged copy nit) — everything else is carried, nothing
> new blocks.

> **Session 16 outcome (2026-07-11):** E5.1 is DONE — the age gate is the app's
> FIRST screen (birth-year wheel; conservative boundary `≥ 18` year-difference,
> vetoable below), under-17 lands on a calm VERIFIED-helplines resources screen
> (US 988; TR 112 until your §3 ALO-182 check), and exactly ONE boolean persists
> (`ageGatePassed` — the birth year never lands anywhere, test-pinned). The
> whole surface fires ZERO analytics — the plan's `age_gate_blocked` event was
> deliberately NOT created (step-0 ruling, vetoable below; your mvp.md was not
> touched). **Billed runs: 2, zero burned** (red evidence `29135328846` matched
> the local harness prediction issue-for-issue → green `29136061287` +
> TestFlight). Your only NEW asks live in §3; the TestFlight-testers item (§5)
> is now extra-timely since the newest build is the first with real onboarding.

> **Session 15 outcome (2026-07-11):** E8.1 is DONE — the closed `AnalyticsEvent`
> enum (19 MVP §5 events, forbidden properties unrepresentable BY TYPE) +
> `AnalyticsService` with the consent gate (default OFF) + TelemetryDeck 2.14.1
> exact-pinned behind a DORMANT transport; `urge_averted`/`slip_undone` fire live
> (in-process only — nothing can leave any build until BOTH the E8.2 consent step
> ships AND you provide the app ID in §8). **Billed runs used: 3** (one burned on
> a missing test-file import — red `29130610823` burned → red evidence
> `29130875659` → green `29131380401` + TestFlight). The zero-burn streak ended
> at three sessions; the gate that closes this failure class is recorded in the
> resume prompt.

> **Session 14 outcome (2026-07-10):** E4.2 is DONE — every slip/relapse string now
> comes from the ONE audited table (`slipCopy.json`, new `dashboard` section is a
> byte-move of already-shipped literals), and
> `SlipLexiconTests.test_slipStrings_containNoForbiddenLexicon()` is a PERMANENT
> unit-lane gate (37 banned tokens, list can only grow, reflection-driven corpus).
> **Billed runs used: 2** (red evidence `29122473990` → green `29123195424`, zero
> burned — third zero-burn session in a row). Nothing rendered changed: no golden
> was touched. Your half of the E4.2 acceptance is the §3 checklist signature below.

## 0. ✅ CLOSED (same day) — Control Center panic fix: pushed, rebased, device-verified

Resolution (2026-07-11): you pushed the fix as **`8a0c469`** (rebased cleanly onto
the E8.1 session commits — the file sets were kept disjoint on purpose), CI run
**`29132554144`** went all-green (162/162 unit incl. the 5 new
`PanicWarmLaunchTests`, 17/17 snapshot, TestFlight uploaded), and you confirmed
both device paths work (cold CC tap → panic flow; warm CC tap → sheet). The
sheet-vs-cover ruling stands unvetoed. **CI-history note:** the two ✗ runs from
the same evening are `29130610823` (burned build, documented in the Session 15
ledger) and `29130875659` (the E8.1 red-evidence run — red BY DESIGN); neither is
a live failure. Original context, for the record:

- [x] **Commit & push the fix from the Mac** (2 moved, 3 edited, 2 new files).
      Until then the verified fix is one careless `git checkout` from being lost,
      and the build installed on your iPhone corresponds to no commit. If
      Session 15 has already pushed E8.1 commits by the time you do this, pull
      and rebase first — the touched file sets were kept disjoint on purpose
      (see the deferral note below). Push protection tripping ⇒ secret-ify,
      never unblock-URL.
- [x] **Device-verify both paths** (the debug session's ask): COLD — app not
      running, tap Control Center "Panic" → app launches straight into the
      panic flow. WARM — app open on the dashboard, pull down Control Center,
      tap Panic → panic flow appears as a sheet over the dashboard. Doing §1's
      latency capture in the same sitting kills two birds.
- [x] **Decide the warm-mount presentation:** it ships as a swipe-dismissible
      SHEET, not a full-screen cover, because the celebration screen has no
      dismiss button and a cover would trap you there. Veto (= you want a hard
      cover + a designed dismiss affordance) or accept; if accepted, silence —
      the record stands.
- [ ] FYI from that Mac session: `gstack` 1.39 → 1.60 is available —
      `/gstack-upgrade` on the Mac when convenient.

> **Now-obsolete Session 15 consequence (kept for the record):** E8.1 deferred
> the `panic_opened` wiring because its call sites were hot in the then-uncommitted
> Mac tree. With `8a0c469` landed, that guard is RETIRED — `panic_opened` wiring
> is unblocked for a future wiring session (its `cold_start_ms` VALUE still waits
> on the §1 latency numbers; the case ships unfired until then).

## 1. E0.3 panic-latency device measurement — carried since Session 02, load-bearing

- [ ] Run the harness in `docs/spike-panic-latency.md` on an **iPhone 15-class
      physical device** with full Xcode; record the numbers in that doc (~30 min).
      It is the ONLY remaining blocker on wiring E3's permanent latency CI gate —
      and since Session 10 it measures the REAL panic flow's first frame.
- [ ] With the numbers, settle the wording drift: MVP §7 "<2 s, 10/10" vs
      test-suite §1.5 "p90 < 2.0 s" (one-line edit to the losing doc).
- [ ] While on the device (optional, ~5 min): feel-pass the 4-7-8 haptic rhythm in
      the real panic flow — input for E5's haptics-only settings work.

## 2. Try E4.1 on your device (your ask, Session 12) — ~10 min

- [ ] **From Xcode (Mac26 + iOS26 device):** open the project, edit the Unhooked
      scheme's Run environment variables, add `FORCE_PANIC_ROUTE=1` and
      `UITEST_SEED_PANIC_SNAPSHOT=1`, run on the device. You should see: the
      seeded two-quit picker → the real ~90s panic flow (4-7-8 breath bloom with
      haptics, urge timer, your seeded motivations verbatim, redirect menu) →
      exits → **"I slipped" → the NEW two-tap slip flow**: "Log a slip?" →
      "Log it" → the forgiveness screen ("Logged." + best/momentum framing, the
      calm NEUTRAL undo banner) → tap Undo within 10 minutes → "Undone. Your
      streak is right where it was."
- [ ] A plain TestFlight launch now shows the **AGE GATE first**, and (NEW,
      Session 17) a passing year lands on **THE QUIZ** — answer the 10–12
      screens (habit → … → readiness) and a real quit is created with your
      motivations verbatim; the panic flow then renders YOUR words. Enter e.g.
      2012 instead to see the blocked resources surface (988 on a US-region
      device; "Go back" recovers). **NEW (Session 18): after the quiz you now
      land on the PERSONALIZED SUMMARY** — your projected yearly savings (enter
      a weekly spend to see the hero figure; leave it blank to see the calm
      non-monetary reframe), your likely hard window (pick triggers to see it;
      pick none and no line renders — by design), and your motivation words —
      then Continue drops you on the placeholder dashboard. All quiz AND
      summary copy is DRAFT pending your §3 pass.

## 3. Content tone review — now fully TestFlight-visible — **+ NEW: E4.2 checklist signature (~15 min)**

- [ ] **NEW (E4.2 acceptance, your half): sign the MVP §7 copy-audit checklist**
      — "Copy audit: no medical claims, no fear content, no fabricated statistics;
      milestones say 'commonly reported'" — for the SLIP surface. The mechanical
      half is now CI-enforced (`Tests/Unit/SlipLexiconTests.swift` scans every
      slip string against 37 banned tokens on every run, and the list can only
      grow); your half is the judgment call a wordlist can't make: read
      `slipCopy.json` top to bottom (including the new `dashboard` section — its
      3 strings are byte-moves of copy you've already seen on device) against the
      brandkit voice (Steady / Forgiving / Honest), and record the sign-off by
      checking this box. If any string fails your read, note the replacement —
      the next session re-records the affected goldens deliberately (a string
      change is a third billed run; batch it with other copy edits if possible).
- [ ] `panicScript.json` ships since Session 10; **`slipCopy.json` ships since
      Session 12** — every string in the slip flow renders from it. Review both
      files' tone against the brand kit voice.
- [ ] **The ONE new agent-drafted line (Session 12):** `slipCopy.json`
      `confirm.retryNote` — *"That didn't save just yet — nothing's lost. Tap Log
      it to try again whenever you're ready."* Shown only when the durable write
      fails; must stay calm, zero-shame, retryable (`REVIEW.md` item 3).
- [ ] Pre-ship (unchanged): clinician/legal pass on `safetyCopy.json`; verify the
      flagged helplines; TR L10n review (`App/Resources/Content/REVIEW.md`).
- [ ] **NEW (Session 16 — E5.1 makes two more content files TestFlight-visible):**
      the age gate's blocked screen renders `safetyCopy.json`'s resourcesScreen
      framing and `helplines.json` rows, so BOTH files now ship in every build
      (previously unbundled drafts). Their clinician/legal + verification passes
      above move up your queue accordingly — same posture as when panicScript/
      slipCopy started shipping. Also review the NEW `ageGateCopy.json` (8 strings,
      both gate screens; panel-signed, CI-scanned against the shame lexicon).
- [ ] **NEW (Session 16 — ALO 182, ~5 min):** the blocked-minors surface shows only
      `appliesTo:"all"` rows with `verified: true`, so TR currently shows ONLY 112 —
      `tr_crisis` (ALO 182) is `verified: false` pending your official-source check
      (Sağlık Bakanlığı page; the file's own `_meta` MUST_VERIFY item). Verify it,
      flip its `verified` flag to `true`, and 182 joins the surface automatically
      (a unit test pins that unverified rows can never render there).
- [ ] **NEW (Session 17 — THE FOUNDER QUIZ COPY PASS, ~20 min, yours by design):**
      `App/Resources/Content/quizConfig.json` is the quiz's ONE audited copy table
      and every string in it is **DRAFT — agents scaffolded, you own the words**
      (roadmap: "agents scaffold screens, copy owned by founder"). It is
      CI-lexicon-scanned (so any shame/medical token is a build failure), and the
      Brand agent signed it with two replacements already applied (effects title;
      the lowest commitment-slider echo — "One day at a time" was rejected as
      AA-coded). Read it top to bottom against the brandkit voice and rewrite
      freely; a copy edit is cheap NOW (no snapshot goldens exist yet — see the
      rulings below). Two sub-decisions ride along:
      (a) the **effects step (slot 10)** needs your medical-claims read — chips are
      non-diagnostic self-report nouns ("Restless sleep", never "insomnia") and the
      title deliberately makes no causal claim; keep it that way;
      (b) whether the motivations step should gain an optional free-text
      "why does {motivation} matter to you?" elaboration (enriches the panic
      reasons screen; local-only like all answers) — a copy/UX call, not built yet.
- [ ] **NEW (Session 18 — THE SUMMARY COPY ROWS, ~10 min, rides the same pass):**
      `App/Resources/Content/summaryCopy.json` — 11 DRAFT strings for the
      summary screen (eyebrow, savings caption + no-spend reframe, the six
      "first hard window" phrases, motivation intro, CTA). Brand signed with
      ZERO required replacements (a first), but two founder calls ride along:
      (a) the **flagged copy nit** — the hero renders "~$1,350<small>/year</small>"
      and the caption says "saved in a year, if you stay on track." (a
      double-"year" read; Brand's optional alternative: "saved in a year at
      this rate."); (b) the risk-window phrases are REFLECTION hedges ("Your
      first hard window is likely evenings.") — keep the "likely" and never let
      "predict"-family words in (the clinical line the register gate holds).
      A copy edit is still cheap (goldens remain unrecorded until this pass).

## 4. GitHub Actions billing headroom — ~2 min per session

- [ ] Session 15 used **3** billed macOS runs (**1 burned**: a new test file was
      missing an import — TEST BUILD FAILED with no red evidence; the gate that
      closes this class is now standing rule #2 in the resume prompt). Session 16
      (E5.1 age gate) used **exactly its 2 planned runs, zero burned** (the
      Linux harness predicted the red run issue-for-issue, and a pre-push
      critic caught a would-be build-breaker in the green views). Session 17
      (E5.2 quiz — the largest surface yet) **used exactly its 2 planned runs,
      zero burned** (red evidence `29151832001` matched the harness prediction
      issue-for-issue → green `29152486541`; the fourth zero-burn TDD session).
      Session 18 (E5.3 summary) used **4** billed runs (planned 2 + 1
      contingency, ran one over): red evidence `29156626484` (exactly the 31
      designed issues, two-lane-harness-predicted) → `29157369825` **burned**
      (missing `@MainActor` on the new XCUITest class — build failure, no
      evidence) → `29157616479` (implementation verified whole; the new smoke
      itself flaked → its pre-recorded deferral valve fired) → final green
      `29158183470`. BOTH closing gates recorded in the resume prompt
      (class-annotation coverage; smokes with unproven drive interactions
      defer until they can land with diagnostics). Session 19 (E8.2 consent)
      plans **2, with 1 contingency**. Check Settings → Billing → spending
      limit before the session.
- [ ] Optional, would eliminate the burned-run class entirely: a cheap self-hosted
      macOS runner or a pre-push `xcodebuild -quiet build` step.

## 5. TestFlight housekeeping — carried from Sessions 07–09; NOW TIMELY

> **NEW (Session 16, on your request): step-by-step walkthrough in
> `docs/testflight-tester-guide.md`** — internal group setup, external
> groups/public link, and both items below, with the Ballast-specific context
> (CI uploads internal-only; build worth distributing = the `8a0c469` one).

- [ ] Add internal testers (nobody receives builds until a tester group exists).
      **This item is now MAXIMALLY timely (Session 17, doubled by Session 18):**
      the newest build (from `3b091d9`, run `29158183470`) completes the M1
      loop — a tester installs, passes the gate, answers the quiz, sees THE
      SUMMARY PAYOFF (their savings figure, their hard window, their words),
      and gets a real quit whose panic flow speaks their own motivations. That
      is the product thesis in one hand-off. Follow Part 1 of the guide. (The
      earlier `8a0c469` note stands superseded.)
- [ ] Expire the stray bundle-version-"1" build; answer export compliance only if
      App Store Connect prompts (guide Part 3 has the exact answers).

## 6. Slack webhook rotation — optional hygiene, ~5 min

- [ ] CI reads `secrets.SLACK_WEBHOOK_URL`; the old URL briefly sat in local git
      history. Rotate when convenient.

## 7. E3.3 manual device matrix — YOUR half of the E3.3 acceptance (~15 min)

The build half shipped Session 13; the acceptance's device matrix is operator-owned
device work. Any post-E3.3 build works; for seeded quits run from Xcode with scheme
env `UITEST_SEED_PANIC_SNAPSHOT=1` (two-quit pre-cache: "Vaping" + one discreet).

- [ ] **Place the surfaces** from the system galleries: the "Streak" lock-screen
      widget (its wind button); the **"Panic"** control in a lock-screen control
      slot AND in Control Center; Settings → Action Button → Controls → "Panic".
- [ ] **Discreet check:** in the controls gallery, confirm the **"Reset"** control
      shows the neutral counterclockwise-arrow glyph and its description ("Opens a
      quick reset.") carries zero habit words; place it once and fire it.
- [ ] **Run the matrix** — each row × Focus ON and OFF; at least one pass in
      airplane mode (Epic 3 DoD: zero network dependency):

      | # | Launch from | Expect | Recorded source |
      |---|---|---|---|
      | 1 | Lock-screen widget button | picker (2 quits) → flow | lockscreenWidget |
      | 2 | Lock-screen control slot | same | controlCenter (see note) |
      | 3 | Control Center "Panic" | same | controlCenter |
      | 4 | Action button | same | controlCenter (see note) |
      | 5 | "Reset" control (any surface) | same | controlCenter (see note) |
      | 6 | In-app "Panic" button on the root | picker sheet | inApp |

- [ ] The attribution VALUES are unit-pinned, so if row-by-row source inspection is
      friction, it is enough to confirm each surface OPENS the flow (Focus on/off,
      airplane ok) — that closes the matrix. To spot-check a recorded source, finish
      one flow arm ("The urge passed") and inspect the persisted UrgeEvent from an
      Xcode run.

> **Platform note (recorded adjustment, not a bug):** iOS provides NO API to tell
> Control Center vs lock-screen slot vs Action button apart — one control
> registration serves all three and YOU assign placement. Rows 2/4/5 recording
> `controlCenter` is correct behavior. `.actionButton` stays reserved in the schema.

## 8. TelemetryDeck app ID — the E8.1 transport ships DORMANT until you provide it (~10 min, whenever)

- [ ] Create the app in the **TelemetryDeck console** (SaaS credentials are
      operator-held by design — agent-workflows §1.3) and paste the app ID into
      `AnalyticsConfiguration.telemetryDeckAppID`
      (`App/Sources/TelemetryDeckSink.swift`). Until then the transport is a Noop
      sink and the SDK is never even initialized — zero bytes leave any build.
      **No urgency**: consent is independently hardwired OFF until E8.2's consent
      screen ships, so this is the second half of a double gate.
- [ ] While creating the app, decide the **salt** (optional `Config(appID:salt:)`
      hardening — 64 random chars; TelemetryDeck says set it once and never change
      it, or distinct-user continuity breaks). Record the decision; wiring it is a
      one-line agent edit.

---

## Decisions on record you can veto (FYI, no action needed)

- **Discreet quits keep VERBATIM motivations in the pre-cache** (labels stay
  stripped) — Session 10 ruling. Veto before E5.2 if you want discreet
  motivations minimized instead.
- **A completed store-route undo DELETES the Slip row** (Session 11, shipped
  Session 12) — an undone slip never counts against Reduce allowance or insights;
  its CloudKit tombstoning is a named §4.3-flip design item.
- **The cold slip flow writes ONLY the outcome buffer** (single-writer pre-cache
  pin, Session 11) — repeat-cold-slip display honesty comes from the in-memory
  draft fold, never a second writer to `panic-snapshot.json`.
- **Redirect menu ships the JSON's 4 options** (ratified override, not drift).
- **E3.3 attribution ceiling (Session 13, recorded adjustment):** control-family
  launches (Control Center / lock-screen slot / Action button) all record
  `.controlCenter` — iOS has no launch-surface API for controls (docs-checked,
  WWDC24 10157). `.actionButton` stays reserved in the schema. Veto path: a new
  dedicated `PanicSource` case for the "Reset" control would need a schema
  decision, not a platform fight.
- **Shortcuts exposure (Session 13):** the lock-screen widget intent ("Panic")
  remains Shortcuts-discoverable (pre-E3.3 behavior); a Shortcuts-run launch
  attributes `.lockscreenWidget` exactly as the old hardcode did. The control
  intent is NOT discoverable (the discreet "Reset" control rides it — a Shortcuts
  row titled "Panic" would leak what it hides).
- **Session 16 (E5.1 age gate) — the panel-signed rulings, each vetoable:**
  1. **Conservative age boundary:** birth-year-only entry (deliberate PII
     minimization) ⇒ PASS only when `currentYear − birthYear ≥ 18`; a difference
     of exactly 17 could still be a 16-year-old and BLOCKS. Costs a genuine
     17-year-old born late in the year a temporary block; duty-of-care-safe
     direction. Veto paths: literal `≥ 17`, or collect month+year.
  2. **The `age_gate_blocked` analytics event was NOT added** (the plan's third
     test was re-specced): consent lives POST-gate and is hardwired off until
     E8.2, so the event could never legally fire from a blocked user — and it
     would mark a device as a blocked minor, exactly the data this app refuses
     to hold. Instead a test pins the ENTIRE age-gate surface fires ZERO
     analytics. No mvp.md §5 edit happened (canonical, yours). Veto = tell the
     next session to propose the §5 row for you to add.
  3. **Verified-only helplines for blocked minors:** the blocked screen renders
     only `appliesTo:"all"` + `verified:true` rows (US → 988; TR → 112 until you
     verify 182, §3 above). An unverified number never faces a minor — the
     directory's own `_meta` posture, now test-pinned.
  4. **A blocked user is never locked out permanently:** nothing is persisted on
     block (the storage rule allows only the `ageGatePassed` boolean), so
     relaunch re-asks — the App-Review-standard self-attestation bar; a "Go back"
     on the blocked screen recovers a fat-fingered year in-session.
  5. **No discreet variant on the gate screens:** pre-gate no habit context
     exists to hide — "made for adults / 17+" is generic App Store language; a
     shoulder-surfer learns nothing.
- **Session 17 (E5.2 quiz) — the panel-signed rulings, each vetoable (all held
  through the green close; one look-ahead: Session 18 opens with a step-0 on
  SOCIAL-PROOF content — PRD wants "real review quotes", none exist pre-launch,
  and fabricated ones are banned by MVP §7, so the panel will pick
  defer-the-screen vs a non-testimonial trust frame; veto by telling Session 18
  your preference):**
  1. **`quiz_completed` is NOT fired by E5.2 — it moves to E5.3's summary render.**
     Your mvp.md §5 fixes its trigger as "Personalized summary shown", and the
     summary screen is E5.3's; firing it at quiz-questions-complete would inflate
     the ≥70% start→summary funnel metric and corrupt the ≥8% conversion
     denominator. E5.2 leaves a named handoff seam `(habitCategory, goalMode)`.
     mvp.md untouched (the Session-16 step-0 discipline). Veto = tell the next
     session to fire it at quit creation instead.
  2. **`quiz_step_completed` carries a FIXED canonical step number** (habit=1 …
     commitment=13; summary=14 is E5.3's): hidden conditional steps and the
     reserved consent slot simply emit no event — numbers never renumber per
     user, so funnel drop-off stays comparable. The on-screen progress bar shows
     the user's visible position ("Step 4 of 11") — two different numbers, both
     honest.
  3. **The consent step is a RESERVED, unrendered seam at slot 3** (E8.2 drops
     the real consent UI into it without renumbering). E5.2 renders nothing
     there, never touches `analyticsOptIn`.
  4. **The quiz resume checkpoint lives in app-STANDARD UserDefaults** (never the
     App Group suite — that's readable pre-unlock, and the checkpoint can hold
     the custom habit name), is cleared on completion, and one-tap erase sweeps
     it (test-pinned).
  5. **Snapshot goldens stay at zero for Epic 5 — the batch point MOVED to
     post-founder-copy.** Recording goldens against DRAFT copy guarantees a paid
     re-record when you rewrite the words; the one deliberate CI-artifact
     re-record now batches E5.1 + E5.2 + E5.3 screens AFTER your §3 copy pass.
     (Refines Session 16's "batch with E5.2" note.)
  6. **The scenario-29 quiz XCUITest defers to E5.3** — as specified it asserts
     the full funnel through summary + paywall, which don't exist yet; the
     Epic-5-DoD "age gate un-bypassable" obligation is met NOW at the unit tier
     (routing pins: gate → quiz → quit is the only path to content). Veto = a
     dedicated new E2E slot this session (the QA plan §5 documents the honest
     shape it would take).
  7. **Motivation chips store the display words themselves** (id == label:
     "Self-respect", "Faith", …) so the panic screen echoes the user's own words
     verbatim without the repository ever reading the copy table.
- **Session 18 (E5.3 summary) — the panel-signed rulings, each vetoable (all
  held through the green close):**
  1. **The social-proof screen is DEFERRED post-TestFlight-feedback** (step-0,
     PM+Architect+Brand unanimous): no real review quotes exist pre-launch;
     fabricated ones are banned (MVP §7 + Honest); no analytics event brackets
     the screen so deferral costs zero measurement; and the trust-frame
     alternative would fire the paywall's own privacy line one screen early,
     back-to-back. The summary CTA is the reserved NAMED seam E7 remaps. **Veto
     = tell Session 19 to build the trust frame — its full Brand-verified copy
     table is in the Session 18 ledger, no new panel round needed.**
  2. **Savings display FLOORS to the ten** ("~$1,350/year" from $26/wk — never
     overstate a motivational projection; the stored value stays the exact
     Decimal 1352). Veto = plain nearest-10 (one pure edit + two test literals).
  3. **Risk-window precedence** evenings > afterWork > social > alone >
     boredom > stress (clock windows beat mood states; multi-select collapses
     to the single "first" window); `frequency` reserved-but-unused v1; no
     triggers → NO line, never a guess.
  4. **`predictedRiskWindow` stores the trigger TOKEN, never the phrase** —
     your DRAFT copy stays out of the (future-mirrored) store; a copy rewrite
     never migrates rows.
  5. **Summary-once, in-memory:** relaunching during the summary's few seconds
     lands on the dashboard without re-showing it or re-firing quiz_completed —
     a conservative funnel undercount (the safe direction). No persisted flag,
     no new field. Veto = a persisted summary needs a schema decision first.
  6. **The gate→quiz→summary XCUITest was built, flaked its first CI drive,
     and its pre-recorded valve fired — scenario-29 DEFERS to E7** (where the
     full quiz→summary→paywall E2E lands with drive diagnostics). The
     `UITEST_RESET` fresh-install hook it introduced stays (test-only launch
     env; sweeps store + App Group + the quiz checkpoint; the prerequisite for
     any future state-mutating UITest). Unit routing pins hold the Epic-5
     DoD's un-bypassability meanwhile. Veto = tell Session 19 to re-land the
     smoke now and spend billed runs debugging the birth-year wheel drive.
  7. **`quit_created` wiring deferred AGAIN, with a plan:** firing it now would
     flip a green E5.2 assertion (its spy guard). It rides the E8 wiring batch
     where that guard is intentionally widened in the same commit.
  8. **The hero renders the tested display string split** (numeral hero +
     subordinate "/year" on the same baseline). The residual double-"year"
     read against the caption is YOUR §3 copy call (Brand's alternative
     recorded there); extreme-accessibility hero sizing (stack-vs-shrink)
     rides the post-copy-pass polish/golden batch.
