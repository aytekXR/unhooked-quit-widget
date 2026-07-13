# Resume Prompt: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Resume Prompt v4.2 |
| Last updated | 2026-07-13 (Session 29 close: the named StoreKit-config/contract session — DONE in 3 billed runs = 2 planned + contingency, ZERO burned. Scenario-29's two-year "hang" DISSOLVED by parsing run 29205964725's xcresult RAW on the Linux box (new house technique — the fileBacked2 token parser; screenshots/AX trees/timings recoverable without Xcode): the driven leg's quiz was FULLY MOUNTED at timeout and the smoke had waited on `quiz.flow`, a nested-container id that never surfaces (Session-09 class; all three of the dead smoke's waits were that class) — while the seeded leg's stall is a NAMED latent defect (`startIfNeeded` sets `started=true` before its do-block and swallows a store-open throw, no retry — R29.4 defer-by-name). The smoke RE-LANDED on surfacing anchors, single driven leg, and PASSED its one allowed run — including BOTH a11y-bridge event reads: the consent-honest `DebugEventSpySink` decorator + `debug.eventSpy` bridge (R25.9's design; the "unproven XCUITest read-path tech" is now PROVEN) asserts quiz_step_completed 3,4,5,6,7,8,9,10,11,13 → quiz_completed → paywall_viewed (the pins' truth, not the doc's "1…14" domain — §1.4 note reconciles). The signed win-back purchase: docs-verified UNEXERCISABLE keyless (RC signs server-side via /offers + IAP key; SKTestSession has NO signature-skip; StoreKitTest deliberately NOT linked) ⇒ landed as the complete dormant seam (`purchaseWinback()`: discount match → `promotionalOffer(forProductDiscount:product:)` → `purchase(package:promotionalOffer:)`; winback source injects it; missing-discount fails HONESTLY, R29.9 vetoable) + the `winback_annual` adHocOffer in Ballast.storekit (payUpFront/14.99/P1Y/1, parse-pinned) + the @_spi wire-shape contract + the lint anchors extended for parenthesized attributes. After S29 the ONLY thing between the app and the live 50%-off discount is the operator's IAP-key upload. Red = run 29272338401: EXACTLY the 5 designed unit fails name-for-name (the 15th consecutive). The contingency went to a PRE-EXISTING panic-smoke flake (not the diff): a synthesized tap swallowed mid step-transition — artifact-proven, drive-hardened with verify+one-guarded-retap (R29.10; assertions byte-unchanged). Session-open operator check: NOTHING required (three-way confirmed; recorded open-to-close). |
| Phase | Phase 2 complete-side: E2–E9 build halves CLOSED + scenario-29/event-spy/signed-seam debts CLOSED; delivery 31/32 (96.9%); remaining build = E10.2 |
| Next session objective | **Session 30: E10.2 submission-package prep (the build-side half) — App Review notes + App Privacy label derivation + metadata lints + the MVP §7 submission checklist wiring; ASO assets stay Gate-G0/operator-gated** |

> **What changed in Session 29:** the project's oldest carried debt closed —
> the full onboarding funnel (real age gate → 11-step quiz → summary →
> paywall mount) now drives green on CI with its analytics tail asserted
> end-to-end through a consent-honest debug event spy; the win-back's signed
> 50%-off purchase path is fully built and waits only on the operator's
> In-App-Purchase key; and the panic smoke's one-in-thirty flake class
> (swallowed synthesized taps) is closed with evidence. Full ledger:
> Session 29 in `docs/past-prompts.md` (R29.1–R29.10).

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
   verify against the SDK's ACTUAL tagged source (a local SwiftPM bare-repo
   cache serves offline: `git -C ~/.cache/org.swift.swiftpm/repositories/<repo>
   show <tag>:<path>`); (S28, #5b) docs-confirmed EXISTENCE is not platform
   AVAILABILITY: every member of a multi-platform type/option-set gets its OWN
   docs-JSON `platforms` array check before code. Cross-import overlays are
   FILE-granular; UIApplication and every UIKit app-only API live in
   App/Sources ONLY.
3. **The burn gates (S24/S25 — all Linux-reproducible, all permanent):**
   (a) **spurious-await** — every `await` in a NEW file must mark a genuinely
   async/cross-actor operation; mockup-typecheck new closure-into-seam shapes
   under `-strict-concurrency=complete -warnings-as-errors` (the ShapeChecks
   pattern — S29 ran it red→green as an EXECUTED harness, the stronger form).
   (b) **qualified-name** — a Darwin-only file's NON-SDK qualified type
   references get Linux-PROBED before push; both-SDK files use the
   bare-name-exact typealias, NEVER the module-qualified form. (c)
   **non-Sendable SDK results:** a nonisolated async SDK call whose result
   type is not Sendable CANNOT return into a @MainActor conformance under
   strict flags (sanctioned fix: `@preconcurrency import`, sole-importer
   file). (d) **lint anchors admit attributes WITH parenthesized arguments:**
   import-anchored grep lints use `^(@[A-Za-z_]+(\([A-Za-z_]+\))? )*import …`
   (S29: `@_spi(Internal) import` would dodge the paren-less atom).
4. **Access-level gate + empirical harness:** scan for private types in
   non-private signatures, and RUN (never just typecheck) a Linux scratch
   harness over the exact shipping bytes of every pure-Foundation/PaywallKit
   API — probe the BOUNDARY, under MULTIPLE HOST TIMEZONES (the standing set:
   UTC/Berlin/Kiritimati). JSON pins use JSONSerialization key-SET semantics,
   never byte/string equality. The free package lane runs `swift test`
   WITHOUT warnings-as-errors — close the gap pre-push with
   `swift build --build-tests -Xswiftc -strict-concurrency=complete
   -Xswiftc -warnings-as-errors --package-path Packages/<pkg>` (or the
   scratch harness for app-side pure subsets).
5. **Docs-check gate:** every Darwin-only / AppIntents / WidgetKit / SF-Symbol /
   third-party member spelling verified against official docs BEFORE code
   (`developer.apple.com/tutorials/data/documentation/<path>.json`; SDK repos'
   tagged raw source for third-party) — AND per-member platform availability
   (#5b). Recorded S29: `performAccessibilityAudit` facts (S28) unchanged;
   RC 5.80.3 `promotionalOffer(forProductDiscount:product:)` signs SERVER-side
   (PurchasesOrchestrator:2111 — no offline path; the SDK's own integration
   tests hit the backend under SKTestSession); SKTestSession has NO
   offer-signature-skip member; `.storekit` v3 `adHocOffers` entry shape =
   {internalID, offerID, referenceName, paymentMode, subscriptionPeriod,
   numberOfPeriods, displayPrice} (from RC's Xcode-generated configs — Apple
   publishes no schema).
6. Docs-only commits carry `[skip ci]`; never spawn agent workflows for
   docs-only changes. Critic/reader agents Write findings to scratchpad files
   and return a one-line pointer. **NEVER `git stash` mid-session.** Check the
   STAGED set before every commit.
7. `git fetch` + `git log origin/main` before EVERY push — the operator
   commits mid-session.
8. **Privacy-surface gate:** anything touching stores/`AnalyticsEvent`/outbound
   gets Architect pre-approval BEFORE implementation; adding an enum case is
   Architect-gated AND needs the MVP §5 row first (pending ratifications:
   S25's teaser_expiry source + {teaser,hard} labels; S26's mvp §6 in-app-only
   win-back). Safety-content needs the PM+Brand+QA joint copy-table sign-off
   BEFORE code. `widget-state.json` remains a §10 surface; no entitlement /
   teaser / winback bit enters any pre-unlock file (presence-only Bool
   ceiling; a render-necessary content-free a11y Bool is admissible, R28.2).
   Scanned string tables must be STRUCTS with STORED NON-OPTIONAL properties;
   optional sections get `#require`d into the walk.
9. **BUDGET REALITY:** there is no zero-billed-run code session; free lanes
   exist, free runs do not. App-lane red evidence = the CI run on the red
   commit; package-lane red is the free local `swift test` (push red+green
   together — cancel-in-progress is FALSE on main, so two pushes = two full
   billed runs). A schema/shared-pass change sweeps the FUNCTION-level blast
   radius of every pin on it. NEW SPM deps land in the GREEN commit, never
   red (R24.8). The golden-rides-red maneuver (R27.12) + deleted-reference
   record-missing re-records (S28) stand. Golden-shift valves calibrate on
   the TOLERANCE FLOOR. **(S29, NEW) xcresult artifacts are FULLY readable on
   the Linux box** (the fileBacked2 token parser — screenshots, AX trees,
   activity timelines, failure messages): artifact-first diagnosis before ANY
   billed hypothesis run is now the standing default for every UITest
   failure. **(S29, R29.10) a synthesized tap landing mid step-transition can
   be silently swallowed — every multi-step UI drive verifies each tap TOOK
   (previous-frame-still-visible guard + ONE bounded re-tap, evidence
   attached), never tap-and-hope.**

## Where we are

- **The M1 loop + the widget suite + the DORMANT monetization vertical + the
  safety layer + the accessibility layer + THE PROVEN FUNNEL E2E:** age gate →
  quiz (slot-3 consent) → summary → paywall mount now drives green on CI end
  to end with the analytics tail asserted through the consent-honest
  DebugEventSpySink (UITEST_EVENT_SPY=1 + the debug.eventSpy a11y bridge —
  scenario-29's slot is FILLED). The signed win-back purchase path is BUILT
  dormant (purchaseWinback(), the winback_annual adHocOffer, the wire-shape
  contract) — live the moment the operator's IAP key lands. E7.1/E7.2/E7.3
  stay dormant until the operator's keys (§8).
- **StreakEngine 1.2.0 / WidgetToolkit 1.1.0 / PaywallKit 1.0.0 untouched.**
  purchases-ios 5.80.3 + SuperwallKit 4.16.1 + SnapshotTesting 1.19.3 +
  TelemetryDeck 2.14.1 exact-pinned. TestFlight LIVE (Session 29 build).
- **Carried debts (all named):** R29.4 (startIfNeeded no-retry — §9-owner
  decision); R28.13 a11y-visual classes + the goldens batch (operator
  §3-gated, ONE re-record bundling colors+copy+goldens); the 2 default-axis
  hapticsOnly goldens (valid-but-stale); scenario-30's purchase-leg E2E
  (operator sandbox tier); MVP §7 accessibility checkbox honestly UNCHECKED.

## Next session objective (one session, definition of done below)

**Session 30 — E10.2 submission-package prep, the BUILD-side half** (the last
build session before the operator-gated launch sequence):

1. **App Review notes** (implementation-plan E10.2): quiz-gated onboarding,
   PanicIntent/cold-launch path, 17+ addiction-category context + clinical
   metadata posture, no-demo-account rationale, the hard-variant 3.1.2 posture
   (R24.9 carried rider) — drafted as a reviewable docs deliverable.
2. **App Privacy label derivation** from the code-derived §8 payload-audit
   allow-list (docs/payload-audit.md) — the label rows + their code evidence,
   ready for the operator to enter in ASC.
3. **Metadata lints where automatable** (`test_release_bundleContainsNo…`
   shape): scan the bundled metadata/copy surfaces against the banned-lexicon
   + no-medical-claims gates; born-green candidates unless a red is honestly
   designable.
4. **MVP §7 submission-checklist wiring**: the machine-checkable rows wired
   to their existing CI evidence; the operator-judgment rows enumerated with
   their §-pointers (never auto-checked).
5. **NOT this session:** ASO assets/screenshots (Gate G0 rename + brandkit
   §9 decision, operator-owned); the goldens batch (§3-gated); any store
   submission action (operator-owned).
0. STEP-0 candidates: (a) what of E10.2 is honestly agent-buildable vs
   operator-owned (the review-notes/privacy-label split); (b) whether any
   metadata lint earns a designed red (else born-green, R28.9 shape);
   (c) the budget split — docs-heavy session, likely 1 billed run + 1
   contingency (docs-only commits are free; only lint/code motion bills).

At close: the build side is DONE pending operator gates — E10.1 external
beta + submission run on the operator's clock.

## Operator-owned blockers (not agent work; carry until closed)

1. E0.3 device measurement (`docs/spike-panic-latency.md`) — the one
   consolidated physical sitting (§7) clears it.
2. E3.3 + E6.2 + E6.3 device matrix rows (operator-expected §7) + the
   lock-screen day-counter row + the S27 safety-layer eyeball + the S28
   eyes-free/VoiceOver eyeball (device test 40's perceptual half).
3. Content tone review (§3) — the S28 a11y block + S27 safety items + carried
   winback/teaser/paywallCopy/settings items + MVP §5/§6 ratifications + the
   3.1.1 riders. The §3 pass gates the R28.13 visual pass + goldens batch
   (ONE re-record).
4. GitHub Actions billing headroom (§4 — Session 29 used 3: 2 planned +
   contingency, ZERO burned).
5. TestFlight testers (§5) — carried; the funnel E2E is now machine-proven.
6. TelemetryDeck app ID (§8) — carried; the last gate on real funnel data.
7. **§8 keys + config:** the RevenueCat key → the Superwall key + dashboard →
   the ASC promotional offer + In-App Purchase Key upload (the app-side
   signed path is BUILT — the key is now the ONLY gate on the live 50%-off
   discount). All sequenced at sandbox-matrix time; nothing blocks builds.

## Resume prompt (copy-paste for next session)

> You are the lead build agent for **unhooked-quit-widget** (app name
> **Ballast**, org `com.beyondkaira`). Session 29 is CLOSED (3 billed runs =
> 2 planned + contingency, ZERO burned; the 15th consecutive predicted red;
> scenario-29 GREEN on its first allowed run incl. the a11y-bridge event
> tail; the signed win-back seam BUILT dormant; the panic smoke's
> swallowed-tap class closed — R29.10). **Session 30 = E10.2
> submission-package prep, the BUILD-side half: App Review notes + App
> Privacy label derivation from docs/payload-audit.md + automatable metadata
> lints + MVP §7 submission-checklist wiring; ASO/screenshots stay
> Gate-G0/operator-gated; no store action.**
> Local Swift toolchain: `. ~/.local/share/swiftly/env.sh`.
> **Standing gates:** CodeGraph query-first + sync at close; `swiftc -parse`
> every touched file + neighbor import/annotation coverage + the deprecation
> gate (docs-UNCONFIRMED spellings are nonexistent) + #5b per-member platform
> availability; the FOUR burn gates (rule #3 — lint anchors now admit
> parenthesized attributes); UIKit app-only APIs never enter Shared/Sources;
> access-level scan + Linux harness RUN empirically ×3 TZ; JSON pins use
> key-SET semantics; docs-only commits `[skip ci]`; check the STAGED set;
> critics REPRODUCE under `-strict-concurrency=complete -warnings-as-errors`;
> NEVER `git stash`; `git fetch` + `git log origin/main` before every push;
> app-lane red evidence = the CI run on the red commit; the panic route NEVER
> queries entitlements/teaser/winback; audit tests never enter a red
> manifest; golden-shift valves calibrate on the TOLERANCE FLOOR; a11y tests
> on safety paths may never be quarantined (rule 11); **artifact-first
> diagnosis on the Linux box before ANY billed hypothesis run (the S29
> xcresult parser technique); every multi-step UI drive verifies each tap
> TOOK (R29.10 — previous-frame guard + ONE bounded re-tap).**
> READ FIRST: the Session 29 ledger in `docs/past-prompts.md` (R29.1–R29.10),
> `docs/implementation-plan.md` E10.2 + MVP §7's checklist,
> `docs/payload-audit.md` (the App-Privacy-label source),
> `docs/operator-expected.md` §3/§7/§8, `docs/session-rules.md`.
> **This session:** STEP-0 rulings (a)–(c) → build per panel (docs
> deliverables + any lint reds) → verify → flag operator items. Budget:
> likely 1 billed run + 1 contingency (docs-heavy; only code/lint motion
> bills).
> **At session end:** append the Session 30 ledger, overwrite this resume
> prompt (next per `roadmap.md` — the build side closes; what follows is
> operator-gated), update `docs/operator-expected.md`, `codegraph sync`,
> commit `[skip ci]`, push, `gh run watch` green (verify the conclusion via
> `gh run view --json` — the watcher's exit code lies).

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
  The consent-honest OBSERVED funnel starts at slot 3 (S19-R1; the S29 §1.4
  note) — slots 1–2 + onboarding_started are gate-swallowed pre-consent.
- **Entitlement canon (S23+S24):** the mapper has NO clock; `willRenew`
  pin-ignored; the package persists ZERO bytes; `Product` = {monthly, annual}
  TIER. App-side: present-but-inactive ⇒ `isActive:false` NEVER nil; unknown
  SKU honors an active entitlement; `entitlements.all` is the extraction read.
- **DORMANT canon (S24–S26):** key absent ⇒ the SDK symbol is never
  referenced at runtime. NEVER call `Purchases.configure` OR
  `Superwall.configure` without the operator key. The paywall screen is
  reachable ONLY via the live gate or DEBUG `UITEST_PAYWALL=1|teaser`.
  `Superwall.reset()` is NOT in the erase order (R25.2). The winback source
  purchases through `purchaseWinback()` (the signed path, R29.6); every other
  source rides `purchase(plan:)`; missing-discount fails honestly (R29.9).
- **Teaser canon (S25):** single-use escape; entitled ALWAYS wins; teaser
  state lives ONLY in AppSettings; re-entry = the post-gate root's dashboard
  branch. **Win-back canon (S26):** eligibility = ANY `.lapsed` + stamp ≥ 7d;
  dismissible OFFER once per process + the eligible-only settings row; prices
  via ProductCatalog constants.
- **Safety canon (S27):** the resources screen is STORE-FREE by construction;
  only `verified: true` rows render on ANY user surface; the GLOBAL region
  stays NUMBER-FREE; the E5.1 age-gate surface keeps its own funcs,
  zero-fire + unmapped→US, byte-frozen; the alcohol notice is once-EVER
  app-wide, inline amber card, "Got it" ≥ prominence, stamp at display,
  erase-swept; helpline rows are NEVER lexicon-scanned.
- **A11y canon (S28):** the eyes-free pacer preference is a §10-admissible
  pre-unlock bit (presence-only stamp `? true : nil`); the panic route still
  opens NO store. The audit family: panic/slip legs are rule-11; the quiz leg
  carries the R28.6 valve; the R28.13 class exclusions are grow-only.
  `UITEST_QUIZ` mounts the quiz through BOTH levels with zero store
  dependency — DEBUG-inert, `.disabled` analytics, NO completion seam (it can
  never reach the summary — R29.2's reason the funnel smoke drives the REAL
  gate). A template sentence with an unfilled token drops WHOLE. BreathBloom
  stays a11y-hidden.
- **Funnel-smoke canon (S29, NEW):** scenario-29 anchors on SURFACING
  elements only (`quiz.continue`/`summary.cta`/`paywall.cta` — nested
  `.contain` container ids never surface, Session-09 class; `quiz.flow` is
  DELETED); the smoke's valve v2 stands in its header (one allowed run per
  re-flake, fires without a re-vote); UITEST_EVENT_SPY arms the spy + bridge
  (DEBUG-inert otherwise); the spy is a SINK-tier decorator (consent-honesty
  structural — it may never grow its own consent read or move above fire()'s
  gate); the bridge exposes wire names + step ordinals ONLY.
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
  fresh install (entitlements survive BY DESIGN).
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
  copy pass (bundling AX5 axes + the R28.13 contrast/textClipped visual
  pass); the SLIP-FLOW goldens include the resources link (S27) and the
  never-dangle degraded copy (S28). SnapshotTesting 1.19.3 + TelemetryDeck
  2.14.1 + purchases-ios 5.80.3 + SuperwallKit 4.16.1 pinned EXACT.
