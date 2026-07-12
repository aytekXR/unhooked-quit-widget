# Operator Expected — the live "what only aytek can do" checklist

| Field | Value |
|---|---|
| Status | LIVE — updated at every session close (operator request, Session 10) |
| Last updated | 2026-07-12 (**Session 23 CLOSED: E7.1 PACKAGE HALF DONE — the app now has an entitlement BRAIN (PaywallKit 1.0.0), and nothing was needed from you, open to close.** The four-state machine (`never|trial|active|lapsed`) ships pure: no clock (offline can NEVER flip a paying user to locked-out — your architecture's anti-Quittr grace rule, enforced by construction), no persisted bytes (the "cache" is in-memory; RevenueCat's SDK owns durable caching app-side, later), no prices or SKUs (the state machine knows monthly-vs-annual and nothing else). Nothing renders it yet — no paywall screen exists; that is Session 24's job, and it is deliberate (the same package-half-first split your E6.1→E6.2 widget sessions used). **Billed runs: exactly the 1 planned, zero burned, contingency unused** (red evidence was FREE — the local Linux package lane predicted all 11 failing tests / 17 issues issue-for-issue, the 9th consecutive; red+green rode ONE push, CI `29192612869`). **Nothing new is expected from you** — §3 gains no strings (the package has no user-facing surface). One forward heads-up in §8: Session 24 wires RevenueCat DORMANT behind your RC key, exactly like the TelemetryDeck pattern you already know — your RC account + App Store Connect products become blocking only at sandbox-verification time, not for the build. Five vetoable rulings at the bottom; the one worth your eye is the OFFLINE GRACE call: a lapsed-while-offline trial keeps premium until the device next reaches RevenueCat — the direction your docs mandate, but it is a real product call now enforced by tests.) |
| Superseded header (S22) | 2026-07-12 (**Session 22 CLOSED: E6.3 discreet mode + alternate icons + the app-switcher shield DONE — every widget family now hides its habit on demand.** Toggle a quit discreet and its lock-screen widget shows "Day N" + a neutral "Reset" arrow — no money, no wind glyph; the app-switcher card goes blank; two new innocuous app icons ("Calendar style" / "Timer style") switch from the new one-screen settings sheet; one-tap erase now also puts the ORIGINAL icon back (OS icon state survives a data wipe — we reset it, plus a launch self-heal). **Billed runs: exactly the 2 planned, zero burned, contingency unused — the zero-burn streak restarts** (red evidence `29183485997` matched the prediction name-for-name, the 8th consecutive; green `29184196211` all-green + TestFlight). **Three things worth your eye:** (1) §3 gains the 8 DRAFT settings strings AND the two DRAFT GENERATED app icons — agents drew them to your brandkit's spec (pure-geometry tiles; regenerate anytime with `brandkit/branding-assets/generate-alt-icons.py`); veto or replace at will; (2) §3 also carries a REAL decision: your brandkit contradicts itself on whether the discreet icons may appear in App Store screenshots (§9.1 says never, §9.2's frame 3 shows one) — the panel says NEVER (one public exposure makes the "innocuous" icon reverse-image-linkable to Ballast forever); you own ASO, so you decide; (3) the veto list gains the Session 22 rulings — the most product-visible: the app-switcher cover only protects DISCREET users (the plan's spec); making it universal is a one-line change if you want banking-app-style protection for everyone. Session 23 = E7.1 PaywallKit.) |
| Superseded header (S21) | 2026-07-12 (**Session 21 CLOSED: E6.2 widget families + the widget feed DONE — a REAL five-family streak widget now ships on TestFlight.** The lock screen shows "Day N" + money saved + the panic button, self-ticking, timezone-fixed, erased clean by one-tap erase. **Billed runs: 4 — the planned 2 + the contingency + ONE over** (§4 has the honest accounting: one burned on a deprecated-API build failure the neighbor-copy rule should have caught — its closing gate is now standing; one spent on a single stale test fixture the new timezone field legitimately flipped, 243/244 green). **Two things worth your eye:** (1) the widget gallery now shows REAL strings ("Streak" / "Your streak, on your lock screen…") — they are DRAFT and join your §3 pass, alongside milestones.json which now ships in-bundle; (2) the veto list below gains six Session 21 rulings — the StandBy deferral and the SkeletonWidget retirement are the two most user-visible: **your testers' placed widgets vanished with the retirement; they re-add "Streak" once.** Session 22 = E6.3 discreet mode.) |
| Superseded header (S20) | 2026-07-12 (**Session 20 CLOSED: E6.1 widget timeline provider DONE — 1 billed run, zero burned.** WidgetToolkit stopped being a stub: it now owns the streak timeline planner (day rollover at local midnight, stale-grace, ticking counters). **Nothing was needed from you, open to close — and nothing new blocks Session 21.** Two things worth your eye, both below: (1) §4 — the "possibly ZERO billed runs" hope from the last close was WRONG and is struck; there is no such thing as a free code session. (2) The **NEW ADR-11 day rule** in the veto list: your widget will say "Day 2" the morning after someone quits on Tuesday night — not 24 hours later. That is a product decision and it is now binding on the dashboard too. Session 21 = E6.2, which finally makes a real widget render on the lock screen.) |
| Rule for agents | Update this file at session end alongside `resume-prompt.md`. It is TRACKED (in `docs/`) so the operator can read it anywhere on the go. The untracked root `OPERATOR-TODO.md` is now just a pointer here. |

Nothing below blocks the next session (Session 24 = E7.1's APP half: the
RevenueCat wiring builds DORMANT behind your RC key — the TelemetryDeck
precedent — so it needs neither your RevenueCat account nor App Store Connect
products to build; those become blocking §-items only at sandbox-verification
time, and the RC-key item itself lands at Session 24's close).
**§0 is CLOSED** (only its optional gstack FYI remains). Items below §0 are
ordered by how much they age; check a box by replacing `[ ]` with `[x]` and the
next session's agent will prune completed items.

> **Session 23 outcome (2026-07-12):** E7.1's PACKAGE half is DONE — PaywallKit
> 1.0.0 owns the entitlement state machine. What that means concretely: the
> logic that will decide "show the paywall or the dashboard" now exists, is
> 98.21%-covered behind a new CI-enforced 90% floor on the FREE Linux lane,
> and was adversarially reviewed (a reentrancy probe ran 1,600 concurrent
> refreshes against a slow event sink — the trial-start event fired exactly
> once, every time; three deliberate mutants were planted and every one was
> killed by the shipped tests). A new panel role born from Session 22's
> UIWindow lesson — the docs-verifier — checked every RevenueCat claim
> against the SDK's actual source and killed two pieces of folklore before
> any code used them. **Nothing from you was needed, and nothing new is
> asked** — no strings, no device rows, no decisions. The five Session 23
> rulings are in the veto list; the offline-grace one is the real product
> call.

> **Session 22 outcome (2026-07-12):** E6.3 is DONE — discreet mode is REAL on
> every family. The discreet flag rides the widget feed additively (Architect-
> approved field set; a non-discreet user's file is unchanged byte-shape);
> discreet rectangular/medium drop the money line entirely ("$412 saved" is an
> outing signal — the mockup's own transform); the medium milestone bar keeps
> its bar but drops the WORD "milestone" (recovery vocabulary; privacy-panel
> amendment); the panic button swaps to the same neutral counterclockwise
> arrow + "Reset" your Control-Center control already uses. The app-switcher
> shield is a real WINDOW above every sheet — the panel caught that a naive
> overlay would have left your warm-panic sheet (your verbatim motivations!)
> visible in the switcher — and it FAILS CLOSED: if the app cannot yet tell
> whether any quit is discreet, it covers. 16 new snapshot goldens recorded
> via the red run's own artifact (second session in a row the trick worked).
> **Your NEW asks: §3 (strings + icons + the screenshot decision) and §7 (four
> device rows).** Six vetoable rulings at the bottom — the widget_added
> deferral was UNANIMOUS (6/6 panel).

> **Session 21 outcome (2026-07-12):** E6.2 is DONE — the widget is REAL. Every
> mutating write now also rewrites `widget-state.json` (a deliberately minimal,
> label-free file: your habit category, motivations, and notes are NEVER in it —
> it is readable before first unlock, so its field set was privacy-ruled before
> code). Each quit remembers the timezone it was created in, so "Day N" rolls at
> YOUR midnight and a flight can never mint a free day. The widget gallery
> offers "Streak" in five sizes (lock-screen rectangular with the panic button,
> the day ring, the one-liner, and the two home sizes with money + momentum +
> the milestone bar); a per-widget selector binds each widget to ONE quit by id,
> so an erased or archived quit shows a calm "Ready when you are." instead of
> silently switching to another habit. One-tap erase removes the widget file in
> the same sweep (test-pinned in three places).
>
> **What earned its keep:** the adversarial critics caught TWO would-be burned
> runs before they happened (a missing cross-import that would have failed every
> target, and a timezone-decode inversion that passed on a Berlin-zone machine
> and failed on CI's UTC runner — reproduced, fixed, verified under three host
> zones). One run WAS burned anyway (a deprecated API in a new test file — the
> gate that closes that class is now permanent), and one more went to a single
> stale fixture (243/244 green). Honest total: 4.
>
> **Your NEW asks: §3 gains the widget gallery strings + milestones.json (both
> DRAFT, both now shipping); §7 gains the tinted-mode + widget device rows.**
> Six vetoable rulings at the bottom — StandBy deferral and SkeletonWidget
> retirement are the product-visible two.

> **Session 20 outcome (2026-07-12):** E6.1 is DONE — the **widget's brain**
> shipped. `WidgetToolkit` (the portfolio package that was a stub since Session 01)
> now owns the timeline planner: it decides when a widget re-renders (at the
> user's local midnight, so the day number turns over when *their* day does),
> keeps the last-known streak **ticking** when something has gone stale, and
> refuses to invent a number when there is no data (no "Day 0" on a fresh or
> erased device). **Nothing renders it yet** — the app half of the feed is
> Session 21's job, and that is deliberate: the plan tags this row
> "[PKG:WidgetToolkit]" and the app-side work would have cost two more billed runs.
> **Billed runs: exactly the 1 planned, zero burned.**
>
> **What earned its keep this session:** the review agents REPRODUCED five real
> bugs rather than reasoning about them, and one was serious — in Chile and Cuba,
> where the clocks spring forward *at* midnight, a user who quit on that day would
> have had their streak read **one day low forever**. It was invisible to every
> test that existed and is now pinned by one that fails on the old code. Also
> caught: "Day 0"/"Day -399" if someone sets their device clock back; the
> stale-widget flag being silently dead; and a timezone bug that would have
> detonated *next* session, inside the writer, far from its cause.
>
> **Your NEW asks: none.** Two FYIs: §4's budget correction, and the **ADR-11 day
> rule** in the veto list at the bottom (a genuine product call — please read that
> one).

> **Session 19 outcome (2026-07-11):** E8.2 is DONE — the consent step renders at
> the quiz's fixed slot 3 ("Share app usage data?" — plain-language helper, the
> two choices visually EQUAL, default off, nothing pre-selected, nothing sent
> before the choice), your pick persists to `AppSettings.analyticsOptIn` at the
> tap, and the hardwired consent-off closures are RETIRED: the one production
> analytics gate now reads your stored choice live on every fire, so an opt-in
> made mid-quiz governs that same run's later events (the summary's
> quiz_completed included) while a decline transmits nothing, ever. Post-erase =
> consent OFF again, re-asked (test-pinned). **`docs/payload-audit.md` is NEW —
> your operator-run MITM release gate** (mitmproxy procedure, the code-derived
> allow-list, a worked FAIL example, the archive checklist that feeds the App
> Privacy label); its §1 explains the sequencing: the property half can only run
> AFTER your §8 app ID ships in a build (the zero-before-consent half is
> verifiable even now). **Billed runs: exactly the 2 planned, zero burned**
> (red evidence `29164705316` matched the two-lane prediction issue-for-issue —
> the sixth consecutive harness-predicted red → green `29165381934` +
> TestFlight). Your NEW asks: §3 gains the 4 consent DRAFT strings (one style
> fork flagged); §8 gains the run-the-audit follow-up and is now the LAST gate
> on real funnel data. Ten vetoable rulings at the bottom.

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
- [ ] **NEW (Session 19 — THE CONSENT STRINGS, ~5 min, rides the same pass):**
      quizConfig.json's slot-3 step now carries the 4 consent strings — title
      "Share app usage data?", the helper ("You'd share which steps you reach and
      your habit type — never your answers, notes, or the times you log, and
      never tied to you. It's off until you choose, and nothing's been sent
      yet."), and the two choice labels "Share usage data" / "No thanks". All
      DRAFT/founder-owned like their siblings; PM+Brand+QA joint-signed
      (safety-content gate) with ONE Brand strike already applied: "anonymous"
      was removed everywhere as an unverifiable overclaim — the payload audit
      can prove what leaves the device, not that it is "anonymous"; the
      audit-backed "never tied to you" carries the reassurance instead. Two
      founder calls ride along: (a) the helper's opener is the conditional
      "You'd share…" (Brand's marginally-less-nudging pick) vs the imperative
      "Turn this on to share…" — both register-clean, your call; (b) do NOT let
      any "change this anytime in Settings" promise creep in — no settings
      analytics surface exists yet (a recorded roadmap candidate), and the copy
      must promise nothing unbuilt.
- [ ] **NEW (Session 21 — THE WIDGET GALLERY STRINGS, ~5 min, rides the same pass):**
      `Shared/Sources/StreakWidgetStyle.swift` is the streak widget's ONE audited
      string table (9 strings: gallery name "Streak" + description, the
      "today"/"saved"/"next milestone" micro-labels, the empty-state line
      "Ready when you are.", the "Day 7" gallery sample, the panic button's
      accessibility label). All DRAFT/founder-owned; PM+Brand+QA joint-signed;
      CI-scanned against BOTH the shame lexicon AND a habit-leak lexicon on
      every run. NOTE: the in-widget micro-copy is baked into the 15 recorded
      snapshot goldens — a rewrite re-records those goldens (cheap, batch it
      with the rest of this pass).
- [ ] **NEW (Session 21 — MILESTONES.JSON NOW SHIPS, ~10 min, rides the same pass):**
      `App/Resources/Content/milestones.json` is now bundled (the widget feed
      maps each quit's milestone ladder from it — hours only; its titles/bodies
      never reach the widget). Its ~40 milestone strings ("commonly reported"
      framing, per its own _meta audit note) are DRAFT and will first RENDER on
      the E9 dashboard — review them with the same medical-claims eye as the
      effects step: experiential, never clinical promises.
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

- [ ] **NEW (Session 22 — THE SETTINGS STRINGS, ~3 min, rides the same pass):**
      `App/Sources/DiscreetSettingsCopy.swift` — 8 strings: "Discreet Mode"
      (screen title), "Widgets" / "Widgets for this streak show numbers only."
      (section header/footer — the footer deliberately promises only what the
      toggle observably does, the S19 rule), "App Icon", "Default",
      "Calendar style", "Timer style" (the two picker names are brandkit §4.3
      LITERALS — confirm rather than rewrite), "Settings" (the entry's
      VoiceOver label). All DRAFT/founder-owned except the two literals;
      CI-scanned (shame + habit-leak, non-vacuity floor). One flagged fork:
      the discreet widget button's VoiceOver label is bare "Reset" (your
      brandkit's literal); a descriptive "Reset — opens a quick reset" would
      give VoiceOver users action-hint parity and still leak nothing — panel
      shipped the literal, your call.
- [ ] **NEW (Session 22 — THE TWO GENERATED APP ICONS, ~5 min, VETO-CLASS):**
      agents generated `AppIconCalendar` + `AppIconTimer` (1024², opaque) to
      your brandkit §4.3 spec + the mockup's exact geometry/hex — warm
      gray-white tile with a 4×4 dot grid + one muted-blue today-dot (ruled
      #3D6C9E over "system blue": a static PNG can't bake a dynamic color);
      dark slate tile with a thin dial + single index mark. Look at them on a
      device home screen (§7 row). Veto/replace freely — the committed
      generator (`brandkit/branding-assets/generate-alt-icons.py`) is
      deterministic, so a tweak is a parameter edit + re-run, and NO snapshot
      golden pins icon pixels (behavior is pinned, art is yours).
- [ ] **NEW (Session 22 — THE STORE-SCREENSHOT DECISION, R22.10, ~2 min):**
      brandkit §9.1 says "NEVER use the discreet alternates in store
      marketing"; §9.2's screenshot plan frame 3 shows the Calendar icon on a
      home screen. These are mutually exclusive: one public store exposure
      makes the alternate icon reverse-image-linkable to Ballast FOREVER —
      anyone spotting "Calendar style" on a partner's phone could match it to
      your listing. The panel resolved toward §9.1 (never market them; frame 3
      should show the discreet WIDGET only, primary icon). You own ASO —
      confirm or veto before any screenshot work; note it in the brandkit when
      you decide.

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
      used **exactly its 2 planned runs, zero burned** — the zero-burn streak
      restarts (red evidence `29164705316` = exactly the 39 predicted issues,
      the sixth consecutive harness-predicted red; the green critics now
      REPRODUCE risky Swift-6 constructs under warnings-as-errors instead of
      reasoning about them — that practice caught nothing this time because
      there was nothing to catch, which is the point). Session 20 (E6.1 widget
      timeline provider) used **exactly its 1 planned run, zero burned** (green
      `29174800786`). **This CORRECTS the Session-19 close's "possibly zero billed
      runs" hope, which was simply wrong — and the correction is PERMANENT, so no
      future session re-learns it:** the WidgetToolkit package lane does run on
      free Linux CI, but `.github/workflows/ci.yml` applies NO path filter to the
      macOS `app` job — its only exclusion is `paths-ignore: docs/**, **.md`. So
      *any* push touching `Packages/**` spins the 10x macOS lane too, whether or
      not a single app file changed (and a green push to main also spins the macOS
      TestFlight lane). **Free lanes exist; free runs do not.** Only DOCS-only
      pushes are truly free. The honest lever, which Session 20 used: produce the
      package lane's red evidence LOCALLY and free (`swift test` on Linux — the
      sanctioned package-tier form per session-rules.md), then push the red and
      green commits TOGETHER so CI fires ONCE at HEAD instead of twice. Session 21
      (E6.2 — widget families + the app-side feed) planned **2 billed runs + 1
      contingency** and used **4 (1 burned)**: `29178893738` BURNED — a
      deprecated API (`UITraitCollection(traitsFrom:)`) in the NEW snapshot test
      file turned warnings-as-errors into a build failure with zero evidence
      (the closing gate is now standing rule #2 in the resume prompt: new API
      forms no neighbor uses get their docs DEPRECATION metadata checked);
      `29179114316` = the red evidence, manifest-matched name-for-name (the
      seventh consecutive harness-predicted red) AND the run whose artifact
      recorded the 15 widget goldens; `29179524777` = green 243/244 (ONE
      pre-existing fixture legitimately flipped by the new timezone backfill);
      `29179855734` = final all-green + TestFlight. The two would-be burns the
      critics caught BEFORE pushing (the cross-import overlay, the
      timezone-decode inversion) would have made it 6. Session 22 (E6.3 —
      discreet + icons + shield) planned **2 billed runs + 1 contingency** and
      used **exactly 2, zero burned, contingency unused — the zero-burn streak
      restarts**: `29183485997` = the red evidence (manifest-matched
      name-for-name, the 8th consecutive: 6 designed unit reds + 6 recording
      snapshot fns whose artifact carried the 16 new goldens; every old golden
      compared clean) → `29184196211` = green all-8-jobs + TestFlight. The
      adversarial critics caught, pre-push: a sheet-coverage hole that would
      have leaked motivations into the app switcher, a fail-open window in the
      shield policy, a UIApplication-in-Shared placement that is a hard
      extension compile error, JSONEncoder key-order randomization that would
      have made byte-equality pins flake, and a docs-unconfirmed
      UIWindow.Level operator spelling — any of the last three was a burned
      run. Session 23 (E7.1 PaywallKit, package lane) planned **1 billed run +
      1 contingency** and used **exactly 1, zero burned, contingency unused —
      the zero-burn streak continues**: red evidence was FREE (the local Linux
      package lane, 11 designed-failing / 17 issues predicted issue-for-issue,
      the 9th consecutive harness-predicted red) → red `14b1593` + green
      `098d087` pushed together → ONE CI run `29192612869` at HEAD (the new
      PaywallKit coverage gate went green in 41s on the free lane). The
      pre-push critics reproduced every lane locally before the push — and the
      free-lane/macOS-lane WARNINGS gap they closed (the free package lane
      runs no warnings-as-errors) is now a standing resume-prompt gate.
      Session 24 (E7.1 app half — RevenueCat wiring + paywall) plans
      **2 billed runs + 1 contingency**; the new SPM dependency makes the
      first macOS build the risk point. Check Settings → Billing → spending
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
      the newest build (from `b17ce0f`, run `29165381934`) completes the M1
      loop — a tester installs, passes the gate, answers the quiz (now incl.
      the calm "Share app usage data?" consent step at its third screen —
      declining changes nothing about their experience), sees THE SUMMARY
      PAYOFF (their savings figure, their hard window, their words), and gets a
      real quit whose panic flow speaks their own motivations. That is the
      product thesis in one hand-off. Follow Part 1 of the guide. (The earlier
      `8a0c469` note stands superseded.)
- [ ] Expire the stray bundle-version-"1" build; answer export compliance only if
      App Store Connect prompts (guide Part 3 has the exact answers).
- [ ] **NEW (Session 21): re-add the widget once.** SkeletonWidget was retired
      for the real "Streak" widget (new kind — a placed placeholder widget
      disappears from the lock screen). Long-press → add "Streak"; the
      rectangular size carries the panic button. Any tester who had the old
      placeholder placed must re-add too (one-time; veto ruling #6 below).

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

- [ ] **NEW (Session 21 — the E6.2 widget rows, ~15 min, same sitting works):**
      (a) **Tinted mode** (mvp feature 6's third render mode): tinted home
      screens cannot be host-snapshotted, so this is device-only QA — set a
      tinted home screen, add systemSmall/Medium "Streak", confirm legibility
      (the templates are luminance-only by design). (b) **The day ring
      mid-fill**: the circular family's ring fills across YOUR local day
      (goldens could only pin the full-ring state — ProgressView's timer form
      has no freeze seam). (c) **Freshness**: log an urge/slip, confirm the
      widget updates within ~60s. (d) **Selector binding**: with 2+ quits,
      long-press → Edit Widget → pick a quit; archive/erase that quit and
      confirm the widget shows "Ready when you are." — never another habit's
      streak.

- [ ] **NEW (Session 22 — the E6.3 device rows, ~10 min, same sitting):**
      (a) **Discreet toggle**: Settings sheet (gear on the root) → toggle a
      quit discreet → the lock-screen rectangular widget shows "Day N" + the
      counterclockwise-arrow button ONLY (no money); VoiceOver on the button
      says "Reset". (b) **Alternate icons**: pick "Calendar style", confirm
      the home-screen icon swaps (iOS shows its own confirmation alert —
      platform behavior) and the app NAME still reads "Ballast" (an iOS limit
      we recorded: a discreet icon is not a discreet app); this row also
      verifies the actool wiring end-to-end — a misspelled build setting
      fails SILENTLY, so only a device proves it. (c) **The shield**: with a
      discreet quit, background the app → the switcher card is BLANK (also
      try it with the panic sheet open — that was the panel's big catch);
      with NO discreet quit, the card shows content (per-spec; see the veto
      list if you want universal). (d) **Erase**: with an alternate icon set,
      one-tap erase → the icon reverts to the primary "surfaced breath".

## 8. TelemetryDeck app ID — NOW THE LAST GATE on real funnel data (~10 min + a ~30 min audit when you're ready)

> **Heads-up added Session 23 (no action yet):** Session 24 wires RevenueCat
> the same DORMANT way this TelemetryDeck item works — the adapter is never
> constructed until you paste your RC public SDK key, so no build talks to
> RevenueCat until you act. The concrete key item lands here at Session 24's
> close. Your RevenueCat account + App Store Connect products/offerings
> become blocking only at sandbox-verification time (the MVP §7 purchase
> matrix), not for any build half.

- [ ] Create the app in the **TelemetryDeck console** (SaaS credentials are
      operator-held by design — agent-workflows §1.3) and paste the app ID into
      `AnalyticsConfiguration.telemetryDeckAppID`
      (`App/Sources/TelemetryDeckSink.swift`). Until then the transport is a Noop
      sink and the SDK is never even initialized — zero bytes leave any build.
      **Status change (Session 19): E8.2's consent step SHIPPED, so this is now
      the ONLY remaining gate** — the moment a build carries your app ID, opted-in
      users' funnel events (quiz steps 3–13, quiz_completed, urge_averted,
      slip_undone) start flowing; decliners still transmit nothing, ever. Still
      no urgency — but it is now a one-item decision, not half a double gate.
- [ ] While creating the app, decide the **salt** (optional `Config(appID:salt:)`
      hardening — 64 random chars; TelemetryDeck says set it once and never change
      it, or distinct-user continuity breaks). Record the decision; wiring it is a
      one-line agent edit.
- [ ] **NEW (Session 19, sequenced AFTER the app ID ships in a TestFlight
      build): run `docs/payload-audit.md`** — your operator-only MITM release
      gate (~30 min with the doc open; mitmproxy + the step-by-step §4
      procedure). Archive the result per its §6 checklist
      (`docs/audits/payload-audit-<build>.md`) — that archive IS the Epic 8
      DoD's operator half and the evidence base for the App Privacy label. The
      zero-before-consent half is verifiable on today's dormant build too, if
      you want a dry run of the tooling.

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
- **Session 19 (E8.2 consent) — the panel-signed rulings, each vetoable (all
  held through the green close):**
  1. **The rendered consent step EMITS `quiz_step_completed(3)`** — post-choice,
     through the generic gate (decliners are gate-dropped by the gate itself;
     zero special-casing). It is the cleanest opt-in-numerator proxy and keeps
     the consenting funnel contiguous 3→14. Veto = suppress the slot-3 fire (a
     documented one-line test fork; tell Session 20).
  2. **Recorded LIMITATION, not a bug: the opt-in RATE has no event-based
     denominator.** `onboarding_started` and quiz slots 1–2 fire BEFORE the
     consent choice, so the gate drops them for everyone (your mvp.md §5's
     "fire nothing before the opt-in choice", enforced literally). The
     measurable funnel begins at slot 3; an opt-in rate needs an external
     denominator (App Store Connect units). The alternative — a consent event —
     is forbidden (no §5 row; adding one is yours alone).
  3. **Both hardwired consent-off sites retired into ONE vended live service**
     (composition root constructs; repository vends; the quiz model consumes) —
     an opt-in at slot 3 governs the same run's later fires. The age-gate
     surface keeps its dead service (zero-fire, belt-and-braces).
  4. **The consent choice is a device setting, by type:** slot 3 renders via a
     new `StepKind.consent` whose UI can only call `recordConsent` → your
     stored `AppSettings.analyticsOptIn` (written AT the tap) — never a
     QuizAnswer, never the resume checkpoint. Erase resets it OFF (the existing
     AppSettings row deletion; test-pinned).
  5. **Brand struck "anonymous" from the consent copy** (title + accept button)
     as an unverifiable overclaim and an asymmetric nudge; the audit-backed
     "never tied to you" rides the helper instead. Veto = restore it, but note
     the payload audit cannot prove the word.
  6. **The degraded emergency config carries NO consent step** — its users
     simply never opt in (fail-closed; an unmeasured emergency path defaulting
     to no-collection is the safe direction). Veto = a hardcoded degraded
     consent step (needs its own copy sign-off round).
  7. **`quit_created` deferred AGAIN, deliberately:** guard-4 (the opted-in spy
     that must see NOTHING at quit creation) was left un-widened precisely
     because it protected the completion seam while consent churned it. The
     wiring earns its own session (ordinal pins, multi-quit fixture, the
     guard-4 widening in the same commit).
  8. **No new UITest; the payload audit IS the end-to-end wire's gate** (a
     simulator UITest never touches real TLS or the real SDK's batching). The
     consent step shipped with stable a11y ids so E7's smoke can drive it.
  9. **No Settings opt-out surface yet** — the copy promises nothing unbuilt; a
     real Settings analytics toggle is a recorded roadmap candidate
     (GDPR/revocability fast-follow). Veto = pull it forward as its own session.
  10. **The selected consent chip uses the same hardcoded white as every
      shipping answer chip** (no brand/onPrimary token exists in-repo); the
      token refactor rides the post-founder-copy polish/golden batch with the
      Session-18 hero-sizing note.
- **Session 20 (E6.1 widget timeline provider) — the panel-signed rulings, each
  vetoable (all held through the green close):**
  1. **⚠️ THE ONE WORTH YOUR ATTENTION — "Day N" means a CALENDAR day, not a
     24-hour block (now ADR-11).** Someone who quits Tuesday at 11pm sees **"Day
     2" on Wednesday morning**, not at 11pm on Wednesday. The widget's day number
     turns over at *their* local midnight, in the timezone they quit in (so a
     flight can never hand them a free day). The alternative — counting whole
     24-hour blocks — is what the streak *engine* computes internally, and it
     would show "Day 1" all through Wednesday and "Day 0" on the quit day itself.
     Four of your own planning docs already assumed the calendar reading (the
     plan's own test is literally named "entries cross midnight, increment day"),
     so that is what shipped. **This is a real product call and it is now binding
     on the dashboard too** — whatever renders "Day N" there must use the same
     rule, or your widget and your app will disagree by a day for the same quit.
     Veto = tell Session 21 you want 24-hour blocks (a one-function change plus
     two test literals, cheap NOW, expensive once the dashboard ships).
     Side-effect worth knowing: milestones ("One full day", "72 hours") stay keyed
     to *elapsed hours*, so a milestone can unlock a day after the widget flips —
     they answer different questions on purpose.
  2. **E6.1 shipped the PACKAGE HALF ONLY** — the planner exists and is tested,
     but nothing feeds it and no widget renders it yet. The plan tags that row
     `[PKG:WidgetToolkit]` and its acceptance is "only templates live in the app";
     doing the app half too would have cost 2 more billed runs and dragged in a
     database schema change (storing each quit's start timezone) that deserves its
     own privacy review. Session 21 (E6.2) does the feed + the families together,
     which is when a real streak first appears on your lock screen. Veto = tell
     Session 21 to split it differently.
  3. **`WidgetToolkit` is Foundation-only BY RULE** — it may never import WidgetKit
     or SwiftUI. Not aesthetics: its CI lane runs on free Linux, and a WidgetKit
     import would force it onto the macOS runner that bills at 10x. WidgetKit code
     lives in the app's widget extension instead, which is exactly what the plan's
     acceptance criterion asks for.
  4. **`widget_added` is still not wired** (carried since the plan was written).
     The widget extension *structurally cannot* send analytics — it has no
     TelemetryDeck dependency, and your consent flag lives in the database, which
     ADR-6 forbids the extension from touching. Your own mvp.md already hedges the
     trigger as "via widget first-render signal", so the fix is a fire-point
     decision (the extension leaves a breadcrumb; the app sends it, behind consent),
     not a re-spec. Session 21 rules on it explicitly.
  5. **The widget gallery still shows developer jargon.** Anyone who long-presses
     to add your widget today reads **"Walking-skeleton placeholder widget."** —
     it has been shipping to TestFlight since Session 01. Real strings are
     safety-content-gated copy and join your §3 founder pass in Session 21.
- **Session 21 (E6.2 widget feed + families) — the panel-signed rulings, each
  vetoable (all held through the final green):**
  1. **StandBy is DEFERRED to v1.1** — your mvp.md §3 explicitly cuts it ("ship
     in v1.1 with Live Activity work") even though the implementation plan's
     E6.2 row and one test name assumed it; mvp.md is canonical, so the
     plan-named StandBy test was re-specced out (the Session-16 precedent) and
     the safety-gated "made it through the evening" copy defers with it. Veto =
     tell Session 22 to build the StandBy pair (it needs its own copy
     sign-off round).
  2. **The widget feed's field set (R1)** — per-quit: id, streak start, fixed
     timezone id, weekly spend + currency, banked clean seconds, momentum %,
     milestone hours. The ABSENCE list is the point (no habit category, no
     label, no motivations, no slip data). One accepted trade-off: only the
     vape ladder carries a 12h rung, so a sharp eye reading the raw file could
     infer "maybe vape" from the ladder — a single low-confidence bit, accepted
     to keep the milestone bar honest. Veto = flatten every ladder to a common
     rung set (loses per-category pacing).
  3. **"Day N" semantics on the ring/ticker (R6):** the circular family renders
     the DAY RING — the ring is progress through YOUR CURRENT DAY (it completes
     at your midnight, when the number flips), not progress toward a milestone;
     milestones live on the systemMedium bar. Veto = a milestone-progress ring
     on the lock screen (re-opens the ladder-leak and a stale-bar problem).
  4. **widget_added stays unwired; the mechanism is now RULED (R8):** the
     extension writes a tiny App-Group breadcrumb (widget kind + discreet flag
     + first-render time) and the APP transmits it later, behind your consent
     gate — the extension itself still can never send anything. Building it is
     E6.3's call (it needs one more privacy review + a fourth erase site).
     Veto = drop the breadcrumb idea entirely, or pull it forward.
  5. **WidgetToolkit bumped to 1.1.0** (the planner grew a milestone-crossings
     parameter + a decode-hardening fix; semver-minor; tag
     `widgettoolkit-v1.1.0` at your convenience).
  6. **SkeletonWidget RETIRED for the real "StreakWidget" kind** — the E0.2
     placeholder (hardcoded "Day 0", dev-jargon gallery text) is gone; placed
     placeholder widgets vanish and testers re-add "Streak" once (§5). The
     panic button carried into the rectangular family. Veto = resurrect the old
     kind as an alias (not recommended: two "Streak" cards in the gallery).
  7. **The extension links StreakEngine** (beyond the plan's WidgetToolkit-only
     note) so money-saved renders through the ONE engine formula everywhere —
     recorded deviation, Foundation-only, no privacy surface change.
- **Session 22 (E6.3 discreet + icons + shield) — the panel-signed rulings,
  each vetoable (all held through the green close):**
  1. **The discreet medium widget drops the WORD "next milestone"** (keeps the
     bare progress bar): "milestone" is recovery-culture vocabulary that
     strengthens the tracker gestalt beside a day count and a Reset button.
     Veto = keep the label (one-line render change + re-record 4 goldens).
  2. **The today-dot is #3D6C9E, not "system blue"** (§4.3 prose deviation,
     Brand-ruled): a static PNG cannot bake a dynamic color; #3D6C9E is your
     semantic/info token — non-brand, non-red, calmer. Veto = regenerate with
     #007AFF via the committed script.
  3. **The app-switcher shield covers WHEN-DISCREET (the plan's spec), and
     fails CLOSED on an indeterminate signal.** The privacy panel recommends
     UNIVERSAL (banking-app-style; non-discreet users' panic/slip sheets stay
     exposed in the switcher today, and a blank-for-everyone card is less of
     a tell than a blank-only-for-hiders card). Universal is a ONE-LINE
     policy change + zero new goldens. Veto direction of your choice.
  4. **widget_added stays unwired — DEFERRED to E8, UNANIMOUS 6/6** (the
     analytics sink is Noop until your §8 app ID, so the funnel loses ZERO
     data; building it now meant a new pre-unlock file + a fourth erase
     artifact + extension-side writes on a 2-run budget). The E8 builder
     inherits the pre-approved field set MINUS the discreet bit (privacy
     amendment: {kind, firstRenderAt} only). Veto = pull it into its own
     session.
  5. **The unavailable-state wind glyphs stay (rect button + circular
     fallback)** — a quit==nil state has no discreet flag to branch on, and
     changing the rect one re-records a committed golden. RECORDED as a
     future polish-batch candidate (neutralize both in one deliberate
     re-record). Veto = do it next session.
  6. **The two alternate icons are agent-generated DRAFT art** (see §3) —
     your veto is the intended review path; behavior tests pin
     switch/persist/reset/fire, never pixels.
- **Session 23 (E7.1 PaywallKit package half) — the panel-signed rulings,
  each vetoable (all held through the green close; the docs-verifier role —
  every RevenueCat claim checked against SDK source, no tutorials — is now a
  standing panel seat for SDK-facing sessions):**
  1. **⚠️ THE ONE WORTH YOUR ATTENTION — offline grace: the entitlement
     mapper has NO clock.** If a trial or subscription expires while the
     device is offline, the app keeps honoring the last state RevenueCat
     reported until it can reach RevenueCat again — it can never locally
     flip a paying user to locked-out (your architecture §8's own
     "never lock a paying user out because the network is down", the
     anti-Quittr rule; RevenueCat's SDK additionally enforces its own
     ~3-day grace ceiling app-side). The cost: a lapsed-while-offline trial
     keeps premium until next contact. The alternative (local expiry math)
     was proposed by QA and STRUCK by lead arbitration as contradicting
     your canon. Veto = tell Session 24 you want local expiry — it is a
     mapper change + new pins, cheap now, and it changes who gets locked
     out when.
  2. **The package persists ZERO bytes** — the "cached entitlement store"
     is in-memory only; durable caching is RevenueCat's SDK (your §3
     "entitlement state is never a data model of ours", now structural:
     nothing in the package is even Codable). A future entitlement bit in
     any pre-unlock file (widget feed / panic snapshot) is gated: Architect
     §10 pre-approval, presence-only Bool ceiling, never product/expiry.
  3. **`trial(product:)` carries NO expiry date** (privacy: no Date payload
     anywhere in the public API — nothing to tempt a future wire into
     transmitting a purchase instant). Trial-countdown UI, if ever wanted,
     is a named additive decision with its own privacy look.
  4. **PaywallKit bumped 0.0.1-skeleton → 1.0.0** (first real content, the
     WidgetToolkit precedent; tag `paywallkit-v1.0.0` at your convenience)
     and its 90% coverage floor is CI-live on the free lane (98.21% actual).
  5. **purchases-ios pinned by RECORD at 5.80.3** (exact-pin precedent) but
     NOT added to the project this session — the SDK is Darwin-only and a
     linked-but-unconfigured network SDK is a supply-chain surface with no
     consent wiring. It enters project.yml in Session 24, DORMANT behind
     your RC key (the TelemetryDeck §8 pattern).
