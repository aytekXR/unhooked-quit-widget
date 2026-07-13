# Resume Prompt: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Resume Prompt v4.1 |
| Last updated | 2026-07-13 (Session 28 close: E9.3 COMPLETE — the accessibility pass; Epic 9's build half CLOSED. The eyes-free pacer preference travels the pre-cache ENVELOPE (`PanicSnapshot.hapticOnlyBreathPacer: Bool?`, presence-only stamp, ONE repository writer, read off the single existing pre-frame read on cold/warm/in-app — panic purity pins untouched); the settings toggle is the THIRD R22.7 amendment ("Breathe with taps" + footer, DRAFT §3); the quiz/panic/slip VoiceOver label+trait pass landed (the slider speaks its WORD ECHO, never "50 percent"; stepper/field labels; icon-picker `.isSelected`; undo hint; the taps-anchored `instructionNonVisual` replaces the literally-false "Follow the circle" in haptics-only mode — its pixel bytes rode RED per R27.12 — and is the bloom mode's VO override); the a11y-AUDIT FAMILY is permanent CI on scenario 33's slot (per-leg: panic/slip = rule-11 safety legs, quiz via the two-level DEBUG `UITEST_QUIZ` direct mount — pure view composition, zero store dependency; scope = the iOS member set MINUS {.contrast, .dynamicType, .textClipped}, the R28.13 GROW-ONLY debt with every finding in run `29262073722`'s artifact). The audit's first run FIXED two real defects: the forgiveness screen's dangling "momentum is still ." (`SlipLoggedComposition` sentence-drop; filled path byte-identical, harness-proven; degradedNoBest goldens re-recorded via deleted-reference record-missing) and the 4pt `quiz.progress` hit-region sliver; the title's VO label drops its typographic period (the classifier's one not-human-readable node). Born-green: the panic-script lexicon gate (35-string Mirror corpus — a real scan hole closed). Red evidence = CI `29259860083` (3 designed unit fails / 3 issues NAME-FOR-NAME with VERBATIM predicted strings — the 14th consecutive — + the designed golden family at 2 image issues BELOW the 3–4 valve: the AX5 axes diffed, the DEFAULT axes passed WITHIN the 1%/0.98 tolerance — NEW HOUSE FACT: calibrate golden-shift valves on the TOLERANCE FLOOR, not only fold-clipping). Final green run `29267286952` ALL-GREEN + TestFlight. **5 billed runs = 2 planned + contingency + 2 over, 1 BURNED** (run 3: `.action`/`.parentChild` EXIST in docs but are macOS-14-ONLY → NEW STANDING GATE #5b). Session-open operator check: NOTHING required (three-way confirmed; recorded open-to-close). |
| Phase | Phase 2 — E2–E6 (minus operator device QA) + E7.1–E7.3 build-COMPLETE + E8 CLOSED + E9 build-COMPLETE; delivery 31/32 (96.9%) |
| Next session objective | **Session 29: the named StoreKit-config/contract session — scenario-29 diagnosis + the event-spy sink + the live signed win-back purchase call (the goldens batch stays gated on the operator §3 copy pass)** |

> **What changed in Session 28:** a visually-impaired user can now run the
> whole panic loop eyes-free — the haptics-only pacer has a settings toggle
> and reaches the cold lock-screen route; VoiceOver reads honest labels
> through quiz/panic/slip; a permanent runtime accessibility audit gates
> every merge, and its first run already fixed two real defects. Full
> ledger: Session 28 in `docs/past-prompts.md` (rulings R28.1–R28.13).

---

## Standing tooling rules (permanent, apply to every agent)

1. **CodeGraph**: query `codegraph_explore` (shell: `codegraph explore "..."`)
   BEFORE grep/find or manual reading; pass this instruction into every
   subagent/workflow prompt; check blast radius before editing public symbols.
   **Before the session-end commit: `codegraph sync` + confirm status clean.**
2. **Parse gate**: `swiftc -parse` every touched Swift file before every push.
   PLUS the import-AND-ANNOTATION coverage check on every NEW test file: copy
   the closest proven neighbor's import block AND its type-declaration
   attributes. The deprecation gate (S21): any API form in a new file that NO
   neighbor uses gets its docs DEPRECATION metadata checked — and (S22) an
   operator/initializer the docs JSON does NOT CONFIRM is treated as
   nonexistent even if tutorials use it; (S23) third-party SDK members too —
   verify against the SDK's ACTUAL tagged source. **(S28, #5b) docs-confirmed
   EXISTENCE is not platform AVAILABILITY: every member of a multi-platform
   type/option-set gets its OWN docs-JSON `platforms` array check before code
   (run 29264641853's burn: `.action`/`.parentChild` are macOS-14-only on
   XCUIAccessibilityAuditType; the iOS-17 audit set is {elementDetection,
   hitRegion, sufficientElementDescription, trait, contrast, dynamicType,
   textClipped}).** Cross-import overlays are FILE-granular; UIApplication and
   every UIKit app-only API live in App/Sources ONLY.
3. **The burn gates (S24/S25 — all Linux-reproducible, all permanent):**
   (a) **spurious-await** — every `await` in a NEW file must mark a genuinely
   async/cross-actor operation; mockup-typecheck new closure-into-seam shapes
   under `-strict-concurrency=complete -warnings-as-errors` (the ShapeChecks
   pattern). (b) **qualified-name** — a Darwin-only file's NON-SDK qualified
   type references get Linux-PROBED before push; the PaywallKit module
   exports an enum ALSO named `PaywallKit` so `PaywallKit.<Type>` resolves to
   the ENUM; both-SDK files use the bare-name-exact typealias, NEVER the
   module-qualified form. (c) **non-Sendable SDK results:** a nonisolated
   async SDK call whose result type is not Sendable CANNOT return into a
   @MainActor conformance under strict flags — probe every new SDK-facing
   conformance with a stub-module mockup (sanctioned fix: `@preconcurrency
   import`, scoped to the sole-importer file). (d) **lint anchors admit
   attributes:** import-anchored grep lints use `^(@[A-Za-z_]+ )*import …`.
4. **Access-level gate + empirical harness:** scan for private types in
   non-private signatures, and RUN (never just typecheck) a Linux scratch
   harness over the exact shipping bytes of every pure-Foundation/PaywallKit
   API — probe the BOUNDARY, under MULTIPLE HOST TIMEZONES (TZ=UTC minimum;
   the standing set: UTC/Berlin/Kiritimati). JSON pins use JSONSerialization
   key-SET semantics, never byte/string equality (S27: helplines.json nests
   under a top-level `regions` key — pin the REAL shape). The free package
   lane runs `swift test` WITHOUT warnings-as-errors — close the gap pre-push
   with `swift build --build-tests -Xswiftc -strict-concurrency=complete
   -Xswiftc -warnings-as-errors --package-path Packages/<pkg>` (or the
   scratch harness for app-side pure subsets).
5. **Docs-check gate:** every Darwin-only / AppIntents / WidgetKit / SF-Symbol /
   third-party member spelling verified against official docs BEFORE code
   (`developer.apple.com/tutorials/data/documentation/<path>.json`; SDK repos'
   tagged raw source for third-party) — AND per-member platform availability
   (#5b above). Recorded S27: `info.circle`/`cross.case` are docs-UNCONFIRMED
   on this box (⇒ nonexistent); `staryoflife` is a TYPO (`staroflife` is
   real); the shipped-and-blessed set is the safe palette (`lifepreserver`,
   `phone.fill`, `hand.tap`, …). Earlier recordings (RC PeriodType, logOut()
   throws, cachedCustomerInfo, Superwall configure/reset, promotional-offer
   spellings) unchanged. **(S28) `performAccessibilityAudit` is
   XCUIApplication-only (iOS 17+; no #available at the iOS-26 floor); audit
   issue lists are NOT name-for-name predictable — audit tests never enter a
   red manifest (they land with green; their first run IS the finding
   ledger); the audit's not-human-readable label classifier rejects terse
   word+period labels ("Logged.") while bare words and full sentences pass.**
6. Docs-only commits carry `[skip ci]`; never spawn agent workflows for
   docs-only changes. Critic/reader agents Write findings to scratchpad files
   and return a one-line pointer. **NEVER `git stash` mid-session.** Check the
   STAGED set before every commit.
7. `git fetch` + `git log origin/main` before EVERY push — the operator
   commits mid-session.
8. **Privacy-surface gate:** anything touching stores/`AnalyticsEvent`/outbound
   gets Architect pre-approval BEFORE implementation; adding an enum case is
   Architect-gated AND needs the MVP §5 row first (mvp.md is OPERATOR-ONLY;
   deviations ride the R24.9 flagged shape — pending ratifications: S25's
   teaser_expiry source + {teaser,hard} labels; S26's mvp §6 in-app-only
   win-back). Safety-content needs the PM+Brand+QA joint copy-table sign-off
   BEFORE code (executed in-panel; E4.2/S16/S27/S28 precedent).
   `widget-state.json` remains a §10 surface; no entitlement / teaser /
   winback bit enters any pre-unlock file (presence-only Bool ceiling —
   **S28: a render-necessary, content-free a11y Bool is ADMISSIBLE, the
   `discreet` flag's class, R28.2 vetoable**). Scanned string tables must be
   STRUCTS with STORED NON-OPTIONAL properties; optional sections get
   `#require`d into the walk; a lexicon over sourced material is a
   false-positive machine — scan AUTHORED framing only.
9. **BUDGET REALITY:** there is no zero-billed-run code session; free lanes
   exist, free runs do not. App-lane red evidence = the CI run on the red
   commit; package-lane red is the free local `swift test` (push red+green
   together — cancel-in-progress is FALSE on main, so two pushes = two full
   billed runs). A schema/shared-pass change sweeps the FUNCTION-level blast
   radius of every pin on it. NEW SPM deps land in the GREEN commit, never
   red (R24.8). The golden-rides-red maneuver (R27.12) re-records SHIFTED
   goldens from the red run's own artifact (zstd xcresult graph →
   failure.png payloadRefs → chronological mapping, hash-verified,
   eyeballed). **(S28) A SMALL visible text change may fall WITHIN the
   1%/0.98 snapshot tolerance at default type size and fire ONLY the AX5
   axes — calibrate golden-shift valves on the TOLERANCE-FLOOR mechanism,
   not only fold-clipping; DELETED-reference record-missing re-records are
   DETERMINISTIC (n/n) where diff-prediction is not, and the recorded
   references ride the run's test-outputs artifact for free adoption.**

## Where we are

- **The M1 loop + the discreet-capable widget suite + a build-COMPLETE DORMANT
  monetization vertical + the safety layer + THE ACCESSIBILITY LAYER:** age
  gate → quiz (slot-3 consent) → summary → dashboard placeholder (+ the
  once-ever alcohol notice) → panic (visual OR eyes-free haptics-only pacer,
  user-switchable) → slip (resources link; the never-dangle forgiveness
  copy) → undo; five widget families (normal + discreet), per-widget quit
  binding, one-tap erase, the app-switcher shield; the post-gate resources
  screen; VoiceOver-honest labels through quiz/panic/slip; the per-leg
  a11y-audit family in CI. E7.1/E7.2/E7.3 stay dormant until the operator's
  keys (§8).
- **StreakEngine 1.2.0 / WidgetToolkit 1.1.0 / PaywallKit 1.0.0 untouched.**
  purchases-ios 5.80.3 + SuperwallKit 4.16.1 + SnapshotTesting 1.19.3 +
  TelemetryDeck 2.14.1 exact-pinned. TestFlight LIVE (Session 28 build).
- **THE R28.13 DEBT (grow-only, artifact-documented):** the {.contrast,
  .dynamicType, .textClipped} audit classes are excluded IN-CODE in
  `A11yAuditUITests` with every finding enumerated in run `29262073722`'s
  test-outputs artifact: sub-WCAG contrast on the panic skip /
  exits-slipped buttons, slip confirm-cancel/undo, secondary body texts,
  the disabled quiz Continue (white on teal@0.35 ≈1.3:1); textClipped on
  the redirect options/skip/confirm subtext under DT scaling. Restoring a
  class = delete it from the exclusion + fix what fires. The fixes are
  Brand-palette + layout-growth decisions cascading across the panic/slip
  golden matrix — they ride the **a11y-visual/golden-batch session**
  (bundled with the operator §3 copy pass: colors+copy+goldens, ONE
  re-record). MVP §7's accessibility checkbox stays honestly UNCHECKED
  until then.
- Copy status: the §3 founder queue GAINS the S28 a11y block (the toggle
  label+footer, the instructionNonVisual line — each with recorded
  alternatives — plus two niceties: the AX5-truncating panic entry title
  and the degraded slip path's "Logged." title+body echo), atop the S27
  safety items and the carried winback/teaser/paywall/settings items.
  Goldens still deferred to the post-founder-copy batch; also
  valid-but-stale within tolerance: the 2 default-axis hapticsOnly goldens
  (they depict the superseded "Follow the circle" line).
- **Epic 9: build half CLOSED** (E9.1+E9.2 S27; E9.3 S28). Remaining Epic 9:
  operator sign-offs (helpline verification, clinician/counsel pass, §7
  copy-audit signature, 17+/clinical ASC metadata) + device test 40.

## Next session objective (one session, definition of done below)

**Session 29 — the named StoreKit-config/contract session** (the deferral
debt named across S24–S27; the last build work before E10.2):

1. **Scenario-29 diagnosis** from run `29205964725`'s preserved test-outputs
   artifact (stage-boundary screenshots + the gate-handoff-timed-out
   attachments) — the gate→quiz hand-off hang, 0-for-2 by two mechanisms
   (S18 wheel-retired; S25 seeded-leg zero-button tree). NEW TOOLING since
   S25: the two-level `UITEST_QUIZ` direct mount proves the quiz RENDERS
   fine on CI — the hang lives in the gate-pass → post-gate re-render chain
   (candidate suspects per S25: the store-truth re-read timing, the
   PostGateRootView mount seam under the UITest env, the a11y-tree shape
   post-transition). Re-land scenario-29 ONLY with its pre-worded valve v2.
2. **The event-spy sink** (Tail-A / test-suite §1.4 "eachStepFiresEvent"):
   the consent-honest DebugEventSpySink decorator inside the
   AnalyticsService composition + the a11y read bridge (the recorded
   R25.9/Architect-P6 design; unproven XCUITest read-path tech — budget its
   first run explicitly).
3. **The live signed win-back purchase call** (E7.3's named deferral): the
   promotional-offer signing path against the local `Ballast.storekit`
   config at the contract tier (test-suite §4.2; S24 ground truth:
   xcodebuild never engages a scheme's StoreKit configuration — the
   unit/contract harness path must carry it; the ASC promotional offer +
   In-App Purchase Key stay §8 operator items).
4. **NOT this session:** the goldens batch (operator §3-gated; now bundles
   the R28.13 visual pass — colors+copy+goldens in ONE re-record);
   `Superwall.reset()` erase wiring (live-key §8); the live Superwall
   register/presentation path (live-key).
0. STEP-0 candidates: (a) the diagnosis method — artifact-first, no billed
   run until a fix hypothesis exists; (b) the event-spy's read-path tech +
   its first-run budget; (c) whether the win-back signing path is
   exercisable WITHOUT ASC keys (docs-verify the promotional-offer
   signature requirements against StoreKitTest); (d) the budget split
   across the three tracks + which track drops if the panel finds one
   over-risky. Budget: **2 billed runs + 1 contingency.**

At close: the build runway drops to ~1 session (E10.2 submission-package
prep) after this one.

## Operator-owned blockers (not agent work; carry until closed)

1. E0.3 device measurement (`docs/spike-panic-latency.md`) — still the only
   blocker on the permanent latency gate. Best done in the ONE consolidated
   physical sitting (§7).
2. E3.3 + E6.2 + E6.3 device matrix rows (operator-expected §7) + the
   lock-screen day-counter row + the S27 safety-layer eyeball + NEW: the
   S28 eyes-free/VoiceOver eyeball (device test 40's perceptual half).
3. Content tone review (§3) — GROWS: the S28 a11y block (4 DRAFT strings +
   alternatives + 2 copy niceties), atop the S27 safety items, the carried
   winback (5), teaser (3), paywallCopy (20 + register decision), settings
   strings/icons, MVP §5/§6 ratifications, and the 3.1.1 riders. The §3
   pass now ALSO gates the R28.13 visual pass (one golden batch).
4. GitHub Actions billing headroom (§4 — Session 28 used 5: 2 planned +
   contingency + 2 over, 1 burned; the burn class is now gated #5b).
5. TestFlight testers (§5) — carried; safety + accessibility layers are in.
6. TelemetryDeck app ID (§8) — carried; the last gate on real funnel data.
7. **§8 keys + config:** the RevenueCat key → the Superwall key + dashboard →
   the ASC promotional offer + In-App Purchase Key upload. All sequenced at
   sandbox-matrix time; nothing blocks builds.

## Resume prompt (copy-paste for next session)

> You are the lead build agent for **unhooked-quit-widget** (app name
> **Ballast**, org `com.beyondkaira`). E9.3 is COMPLETE (red `29259860083`
> 3/3 name-for-name with VERBATIM strings, the 14th consecutive; the audit
> family live + scoped per R28.13; final green `29267286952` + TestFlight;
> 5 billed runs, 1 burned — the platform-availability lesson is standing
> gate #5b). **Session 29 = the named StoreKit-config/contract session:
> scenario-29 diagnosis (artifact-first) + the event-spy sink + the live
> signed win-back purchase call; the goldens batch stays operator-gated.**
> Local Swift toolchain: `. ~/.local/share/swiftly/env.sh`.
> **Standing gates:** CodeGraph query-first + sync at close; `swiftc -parse`
> every touched file + neighbor import/annotation coverage + the deprecation
> gate (docs-UNCONFIRMED spellings are nonexistent) + **#5b per-member
> platform availability (docs-JSON `platforms`)**; the FOUR burn gates
> (rule #3); UIKit app-only APIs never enter Shared/Sources; access-level
> scan + Linux harness RUN empirically ×3 TZ; JSON pins use key-SET
> semantics; docs-only commits `[skip ci]`; check the STAGED set; critics
> REPRODUCE under `-strict-concurrency=complete -warnings-as-errors`; NEVER
> `git stash`; scanned string tables = STRUCTS with STORED NON-OPTIONAL
> properties, optional sections `#require`d; schema/shared-pass changes
> sweep FUNCTION-level pin blast radius; `git fetch` + `git log origin/main`
> before every push; app-lane red evidence = the CI run on the red commit
> (2 billed runs + 1 contingency); the panic route NEVER queries
> entitlements/teaser/winback; no entitlement/teaser/winback bit enters any
> pre-unlock file (a render-necessary content-free a11y Bool is admissible,
> R28.2); audit tests never enter a red manifest; golden-shift valves
> calibrate on the TOLERANCE FLOOR; a11y tests on safety paths may never be
> quarantined (rule 11).
> READ FIRST: the Session 28 ledger in `docs/past-prompts.md`
> (R28.1–R28.13 — esp. R28.13's debt + the two-level UITEST_QUIZ mount),
> the Session 25 ledger (R25.9's event-spy design + scenario-29's valve v2 +
> the preserved artifact `29205964725`), the S24 StoreKit ground truths
> (xcodebuild never engages scheme StoreKit configs) + S26's
> promotional-offer findings, `Tests/UITests/A11yAuditUITests.swift`,
> `docs/test-suite.md` §4.2/§1.4, `docs/operator-expected.md` §3/§7/§8,
> `docs/session-rules.md`.
> **This session:** STEP-0 rulings (a)–(d) → red (app-lane manifest per
> panel) → green → verify → flag operator items. Budget: 2 billed runs + 1
> contingency.
> **At session end:** append the Session 29 ledger, overwrite this resume
> prompt (next per `roadmap.md`), update `docs/operator-expected.md`,
> `codegraph sync`, commit `[skip ci]`, push, `gh run watch` green (verify
> the conclusion via `gh run view --json` — the watcher's exit code lies).

## Standing rules reminders (do not relearn these)

- **ADR-11 binding:** displayed "Day N" = 1-based CALENDAR day at local
  midnight in the quit's FIXED start timezone — never `TimeZone.current`,
  never `StreakValue.days`. Count by NOON anchoring. The feed zone travels as
  a STRING identifier. **Durations are the exception-by-domain:** the teaser
  = 24h wall-clock (R25.7); the win-back window = 7×86_400s wall-clock,
  INCLUSIVE boundary (R26.3) — never calendar-anchored.
- Analytics ONLY via the closed enum; zero events before opt-in; the widget
  extension can NEVER fire analytics. Wire values: `ballast.monthly`/
  `ballast.annual`; `variant` ∈ {"teaser","hard"}; `source` gains
  "teaser_expiry" (S25, ratification pending); `offer` = {"winback_annual"};
  `resources_viewed.source` ∈ {"settings","slip_flow"} CLOSED (R27.4).
  purchase fires ONLY on user-initiated PAID (.active) completions;
  winback_converted co-fires BEFORE purchase; winback_shown co-fires with
  paywall_viewed(source:.winback); the paywall funnel is source-segmented.
- **Entitlement canon (S23+S24):** the mapper has NO clock; `willRenew`
  pin-ignored; the package persists ZERO bytes; `Product` = {monthly, annual}
  TIER. App-side: present-but-inactive ⇒ `isActive:false` NEVER nil; unknown
  SKU honors an active entitlement; `entitlements.all` is the extraction read.
- **DORMANT canon (S24–S26):** key absent ⇒ the SDK symbol is never
  referenced at runtime. NEVER call `Purchases.configure` OR
  `Superwall.configure` without the operator key. The paywall screen is
  reachable ONLY via the live gate or DEBUG `UITEST_PAYWALL=1|teaser`.
  `Superwall.reset()` is NOT in the erase order (R25.2).
- **Teaser canon (S25):** single-use escape; entitled ALWAYS wins; teaser
  state lives ONLY in AppSettings; re-entry = the post-gate root's dashboard
  branch. **Win-back canon (S26):** eligibility = ANY `.lapsed` + stamp ≥ 7d;
  dismissible OFFER once per process + the eligible-only settings row; prices
  via ProductCatalog constants.
- **Safety canon (S27):** the resources screen is STORE-FREE by construction;
  only `verified: true` rows render on ANY user surface; the GLOBAL region
  stays NUMBER-FREE; the E5.1 age-gate surface keeps its own funcs,
  zero-fire + unmapped→US, byte-frozen; the alcohol notice is once-EVER
  app-wide (both goal modes), inline amber card, "Got it" ≥ prominence,
  stamp at display, erase-swept; helpline rows are NEVER lexicon-scanned.
- **A11y canon (S28, NEW):** the eyes-free pacer preference is a
  §10-admissible pre-unlock bit (render-necessary, content-free — the
  `discreet` flag's class; presence-only stamp `? true : nil`); the panic
  route still opens NO store. The audit family: panic/slip legs are rule-11
  (never quarantined/valved/suppressed); the quiz leg carries the R28.6
  valve; the R28.13 class exclusions are grow-only and in-code, findings in
  run `29262073722`'s artifact. `UITEST_QUIZ` mounts the quiz through BOTH
  levels (AgeGateContainerView → PostGateRootView) with zero store
  dependency — DEBUG-inert; the gate's un-bypassability stays unit-pinned.
  A template sentence with an unfilled token drops WHOLE
  (`SlipLoggedComposition` — the copy never invents a number and never
  dangles). BreathBloom stays a11y-hidden; the instruction line + haptics
  carry the rhythm.
- The consent choice is a DEVICE SETTING; erase resets it OFF. Erase order:
  rows (sweeps teaserExpiresAt + paywallVariantAssigned + lapseObservedAt +
  alcoholNoticeShownAt) → infallible local clears (incl. the trial dedupe
  marker) → owned files → widget reload → `resetEntitlement()` → CloudKit
  purge LAST.
- No shame copy (lexicons only GROW); no medical claims (the milestone gate
  is PHRASE-ANCHORED); no red anywhere (the notice card is AMBER);
  motivations VERBATIM; the paywall bans countdowns/fake discounts/"one-time
  offer"; prices are NEVER copy-table literals; the hard variant has NO close.
- Monotonic fields never decrease; streaks freeze, never inflate (ADR-7); the
  widget floors at Day 1 and runs NO clock guard (ADR-6).
- WITNESS discipline: three advance paths only; widgets never advance it.
- Erase discipline: local-first; owned file-set = {panic-snapshot.json, panic
  outcome buffer, widget-state.json} in THREE enumeration sites; zero active
  quits ⇒ widget-state REMOVED (never present-empty); post-erase relaunch =
  fresh install (entitlements survive BY DESIGN; a fresh teaser day, winback
  clock and alcohol-notice stamp are all grantable post-erase — accepted
  fresh-install semantics).
- Panic path stays thin: panic surfaces NEVER open the store, query
  entitlements, teaser, OR winback state; the panic-descended cold slip route
  constructs NO analytics (R27.11); the widget feed is label-free BY FIELD
  SET (R1) + presence-only discreet (R22.1); the shield policy is tri-state
  FAIL-CLOSED.
- Never weaken a QA assertion; TDD red first; `cloudKitDatabase` stays `.none`
  until the §4.3 flip.
- Snapshot goldens: light/dark ×5 families ×normal/discreet + AX5 home-only;
  fixtures dated 2025 epoch 2026-07-07T12:00:00Z; `pauseDate`/frozen clocks
  freeze tickers; the ONBOARDING + PAYWALL golden batch waits for the founder
  copy pass (S17 R5 + R24.1 + R28.7/R28.13 — it now bundles each surface's
  AX5 axes AND the contrast/textClipped visual pass); the SLIP-FLOW goldens
  include the resources link (S27) and the never-dangle degraded copy (S28).
  SnapshotTesting 1.19.3 + TelemetryDeck 2.14.1 + purchases-ios 5.80.3 +
  SuperwallKit 4.16.1 pinned EXACT.
