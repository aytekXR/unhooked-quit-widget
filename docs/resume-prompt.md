# Resume Prompt: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Resume Prompt v4.0 |
| Last updated | 2026-07-13 (Session 27 close: E9.1 + E9.2 COMPLETE — the safety layer. A post-gate `SafetyResourcesView` (store-free: bundled JSON + injected analytics only) is one tap from Settings (the UNCONDITIONAL `settings.resources.row` — the SECOND R22.7 amendment) and from every slip flow (the logged-stage `slip.resources.link`, internal sheet, BOTH routes — the cold route passes `.disabled` analytics by ruling); region resolution falls back to the NEW number-FREE `GLOBAL` region (calm local-emergency line + the verified findahelpline.com pointer; the E5.1 age-gate keeps unmapped→US, byte-frozen); the alcohol withdrawal notice decodes from safetyCopy.json and shows ONCE ever app-wide (both goal modes) as an inline amber card on the dashboard, stamped via `AppSettings.alcoholNoticeShownAt: Date?` (the lapseObservedAt twin; erase-swept); `resources_viewed(source)` fires once per presentation, consent-gated, {settings, slip_flow} ONLY (the notice + age-gate opens are intentionally uninstrumented — R27.4); E9.2's milestones schema + PHRASE-ANCHORED medical-claim lexicon gates are permanent CI (born-green by design; Epic 9 DoD's lexicon row CLOSED). Red evidence = CI `29245297054` (4 designed-failing / 8 issues NAME-FOR-NAME — the 13th consecutive predicted red — + the 2 designed golden shifts / 6 image issues inside the pre-worded 4–8 fold valve) → green `cf75ba6` run `29246823045` ALL-9-JOBS + TestFlight. **Exactly 2 billed runs, ZERO burned, contingency UNUSED — the golden-rides-red maneuver (R27.12) re-recorded the 6 shifted goldens from the red run's own artifact, extracted on Linux (zstd xcresult graph → failure.png payloadRefs → chronological mapping, hash-verified), so the snapshot re-record cost NOTHING.** Session-open operator check: NOTHING required (three-way confirmed; recorded open-to-close). |
| Phase | Phase 2 — E2–E6 (minus operator device QA) + E7.1/E7.2/E7.3 build-COMPLETE + E8 CLOSED + E9.1/E9.2 DONE; delivery 30/32 (93.75%) |
| Next session objective | **Session 28: E9.3 accessibility pass — VoiceOver, haptics-only pacer, Dynamic Type max** |

> **What changed in Session 27:** the SAFETY LAYER is live. A user in a hard
> moment is one tap from verified helplines on every slip surface and from
> Settings; an unmapped-region user meets an honest GLOBAL bucket, never US
> numbers dressed as local; a new alcohol quit (or reduce goal) meets the ONE
> calm withdrawal caution, once, with "Got it" always first-class. Full
> ledger: Session 27 in `docs/past-prompts.md` (rulings R27.1–R27.14).

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
   verify against the SDK's ACTUAL tagged source. Cross-import overlays are
   FILE-granular; UIApplication and every UIKit app-only API live in
   App/Sources ONLY.
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
   key-SET semantics, never byte/string equality (S27 catch: helplines.json
   nests under a top-level `regions` key — pin the REAL shape, not the
   remembered one). The free package lane runs `swift test` WITHOUT
   warnings-as-errors — close the gap pre-push with `swift build
   --build-tests -Xswiftc -strict-concurrency=complete -Xswiftc
   -warnings-as-errors --package-path Packages/<pkg>` (or the scratch harness
   for app-side pure subsets).
5. **Docs-check gate:** every Darwin-only / AppIntents / WidgetKit / SF-Symbol /
   third-party member spelling verified against official docs BEFORE code
   (`developer.apple.com/tutorials/data/documentation/<path>.json`; SDK repos'
   tagged raw source for third-party). Recorded S27: `info.circle`/`cross.case`
   are docs-UNCONFIRMED on this box (⇒ nonexistent); `staryoflife` is a TYPO
   (`staroflife` is real); the shipped-and-blessed set is the safe palette
   (`lifepreserver`, `phone.fill`, …). Earlier recordings (RC PeriodType,
   logOut() throws, cachedCustomerInfo, Superwall configure/reset,
   promotional-offer spellings) unchanged.
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
   BEFORE code (executed in-panel; E4.2/S16/S27 precedent). `widget-state.json`
   remains a §10 surface; no entitlement / teaser / winback bit enters any
   pre-unlock file (presence-only Bool ceiling). Scanned string tables must be
   STRUCTS with STORED NON-OPTIONAL properties (a nil String? child dodges the
   Mirror lexicon walk — and S27: OPTIONAL SECTIONS in scanned tables get
   `#require`d into the walk, never blind-Mirror'd; a lexicon over sourced
   material (helpline rows) is a false-positive machine — scan AUTHORED
   framing only).
9. **BUDGET REALITY:** there is no zero-billed-run code session; free lanes
   exist, free runs do not. App-lane red evidence = the CI run on the red
   commit; package-lane red is the free local `swift test` (push red+green
   together — cancel-in-progress is FALSE on main, so two pushes = two full
   billed runs). A schema/shared-pass change sweeps the FUNCTION-level blast
   radius of every pin on it. NEW SPM deps land in the GREEN commit, never
   red (R24.8). **S27 NEW — the golden-rides-red maneuver (R27.12):** when a
   green feature must shift existing goldens, land the pixel-affecting bytes
   in the RED commit so the diffs are predicted red issues, then commit the
   red run's own failure.png actuals (extract from the artifact xcresult:
   zstd Data objects → the activity graph's failure payloadRefs, chronological
   order == the CI log's issue order; hash-exclude old references; eyeball
   the mapped images) as the green references. Requires the shifted render to
   be red/green identical by construction. Snapshot-issue counts get a
   PRE-WORDED fold-variance range when content may clip at AX5.

## Where we are

- **The M1 loop + the discreet-capable widget suite + a build-COMPLETE DORMANT
  monetization vertical + THE SAFETY LAYER:** age gate → quiz (slot-3 consent)
  → summary → dashboard placeholder (now with the once-ever alcohol notice
  card when an alcohol goal exists) → panic → slip (with the resources link)
  → undo; five widget families (normal + discreet), per-widget quit binding,
  one-tap erase incl. OS icon state + the entitlement reset + the notice
  stamp, the app-switcher shield; the post-gate resources screen one tap from
  Settings and every slip flow. E7.1/E7.2/E7.3 stay dormant until the
  operator's keys (§8).
- **StreakEngine 1.2.0 / WidgetToolkit 1.1.0 / PaywallKit 1.0.0 untouched.**
  purchases-ios 5.80.3 + SuperwallKit 4.16.1 + SnapshotTesting 1.19.3 +
  TelemetryDeck 2.14.1 all exact-pinned. TestFlight LIVE (Session 27 build).
- Copy status: the §3 founder queue GAINS the S27 safety items (the 4 notice
  strings — clinician+counsel emphasized, the resourcesScreen 4 now consumed
  post-gate, the notMedicalCareDisclaimer REWORD treatment→care, "Support &
  resources", the GLOBAL emergencyNote incl. the findahelpline.com pointer,
  the E9.2 audit-checklist signature), atop the carried winback/teaser/
  paywall/settings items. Goldens still deferred to the post-founder-copy
  batch (the 6 slip-flow goldens were re-recorded THIS session as part of the
  link landing — they now show the resources link).
- **Epic 9 status:** E9.1 + E9.2 build-DONE; the permanent lexicon gates are
  CI-live. Remaining: E9.3 (accessibility) + the operator sign-offs (helpline
  number verification, clinician/counsel copy pass, the §7 copy-audit
  signature, 17+/clinical metadata in ASC).

## Next session objective (one session, definition of done below)

**Session 28 — E9.3: accessibility pass.** Per plan: VoiceOver through
quiz/panic/slip; haptics-only pacer; Dynamic Type max without truncation.
Plan-named tests VERBATIM: `test_a11yAudit_quizPanicSlip_noViolations`
(XCUITest `performAccessibilityAudit`),
`test_hapticsOnlyPacer_runsWithoutVisualDependency`, snapshot tests at
`.accessibility5` asserting no truncation on streak + paywall copy.
Acceptance: MVP §7 accessibility gate green. Deps: E3.2, E4.1, E5.2, E7.2.

0. STEP-0 candidates: (a) **the a11y-audit XCUITest's lane + flake posture** —
   `performAccessibilityAudit` drives quiz/panic/slip in the UI-smoke lane;
   scenario-29's quiz hand-off hang is STILL OPEN (deterministic-on-CI, 0-for-2
   by two mechanisms) so a quiz-driving audit may hit the same wall — the
   panel must rule the drive path (panic/slip legs are proven drivable — the
   SlipFlowUITests precedent; the QUIZ leg may need the audit scoped or a
   pre-worded valve), and safety rule #11 (test-suite §7: a11y tests on
   safety paths may never be quarantined) constrains the valve design;
   (b) **the AX5 paywall-copy truncation pin vs the deferred paywall golden
   batch** (founder copy pass, S17 R5 + R24.1) — reconcile: AX5 snapshot pins
   on paywall copy would mint goldens the batch policy defers; candidate
   answers: pin streak surfaces now + defer the paywall half BY NAME, or
   land text-metric (non-golden) truncation pins; (c) **the haptics-only
   pacer's SURFACE**: `AppSettings.hapticOnlyBreathPacer` exists (defaulted
   false) and `BreathPacer`/`LiveHapticsEngine` ship (E3.2), but NO toggle
   surface exists — DiscreetSettingsView is toggles+icons+resources BY RULING
   (R22.7 twice-amended); a haptics row needs a THIRD amendment ruling (the
   a11y-obligation argument mirrors R27.10's compliance-not-creep) or its own
   surface; (d) VoiceOver LABEL audit scope: identifiers ≠ labels — enumerate
   the quiz/panic/slip elements needing explicit labels/traits (the S22
   "Reset" a11y-label precedent); (e) accessory-family Dynamic Type is
   CLAMPED by the system (S21 recorded) — the AX5 truncation pins scope to
   home families + in-app surfaces only.
1. Red first (app-lane, billed): per the panel's manifest.
2. Green: labels/traits + the pacer option + the AX5 pins; scope guards: the
   panic route's thinness untouched; no §10 change expected; the frozen
   scenario-29 stays frozen.
3. Budget: **2 billed runs + 1 contingency.**
4. At close: Epic 9's build half closes; the runway drops to ~2 sessions
   (StoreKit-config/contract + E10.2) to submission-ready.

## Operator-owned blockers (not agent work; carry until closed)

1. E0.3 device measurement (`docs/spike-panic-latency.md`) — still the only
   blocker on the permanent latency gate. Best done in the ONE consolidated
   physical sitting (§7).
2. E3.3 + E6.2 + E6.3 device matrix rows (operator-expected §7) + the
   lock-screen day-counter row + NEW: the S27 safety-layer eyeball rows.
3. Content tone review (§3) — GROWS: the S27 safety items (see "Copy status"
   above), plus the carried winback (5), teaser (3), paywallCopy (20 +
   register decision), settings strings/icons, MVP §5/§6 ratifications, and
   the 3.1.1 riders.
4. GitHub Actions billing headroom (§4 — Session 27 used exactly 2; zero
   burned; contingency unused).
5. TestFlight testers (§5) — carried; the safety layer just landed, which was
   the recommended bar for distributing an addiction-category beta.
6. TelemetryDeck app ID (§8) — carried; the last gate on real funnel data.
7. **§8 keys + config:** the RevenueCat key → the Superwall key + dashboard →
   the ASC promotional offer + In-App Purchase Key upload. All sequenced at
   sandbox-matrix time; nothing blocks builds.

## Resume prompt (copy-paste for next session)

> You are the lead build agent for **unhooked-quit-widget** (app name
> **Ballast**, org `com.beyondkaira`). E9.1+E9.2 are COMPLETE (red evidence
> `29245297054` — 4 designed reds / 8 issues name-for-name, the 13th
> consecutive predicted red, + 2 designed golden shifts / 6 image issues
> inside the pre-worded valve; green `cf75ba6` CI `29246823045`; exactly 2
> billed runs, zero burned — the golden-rides-red maneuver, R27.12).
> **Session 28 = E9.3 accessibility pass — VoiceOver, haptics-only pacer,
> Dynamic Type max.** Local Swift toolchain: `. ~/.local/share/swiftly/env.sh`.
> **Standing gates:** CodeGraph query-first + sync at close; `swiftc -parse`
> every touched file + neighbor import/annotation coverage + the deprecation
> gate (docs-UNCONFIRMED spellings are nonexistent); the FOUR burn gates
> (standing rule #3); UIApplication/UIKit app-only APIs never enter
> Shared/Sources; access-level scan + Linux harness RUN empirically under
> multiple host timezones (TZ=UTC minimum); JSON pins use key-SET semantics
> over the REAL file shape; docs-only commits `[skip ci]`; check the STAGED
> set before every commit; critics REPRODUCE risky constructs under
> `-strict-concurrency=complete -warnings-as-errors`; NEVER `git stash`;
> scanned string tables = STRUCTS with STORED NON-OPTIONAL properties and
> optional sections get `#require`d into the walk; a schema/shared-pass
> change sweeps FUNCTION-level pin blast radius; `git fetch` + `git log
> origin/main` before every push; app-lane red evidence = the CI run on the
> red commit (2 billed runs + 1 contingency); the panic route NEVER queries
> entitlements/teaser/winback state; no entitlement/teaser/winback bit enters
> any pre-unlock file; **a11y tests on safety paths may never be quarantined
> (test-suite §7 rule 11) — design the audit's drive path and any valve
> around that constraint at step-0.**
> READ FIRST: `docs/implementation-plan.md` E9.3 row + Epic 9 DoD, the
> Session 27 ledger in `docs/past-prompts.md` (R27.1–R27.14 — esp. R27.9's
> symbol palette, R27.10's compliance-amendment precedent for the haptics
> toggle, R27.12's golden maneuver if goldens shift), the Session 25 ledger
> (scenario-29's open hang — the a11y audit's quiz leg faces the same wall),
> `docs/mvp.md` §7 accessibility rows, `docs/test-suite.md` §1/§3.3/§7
> (rule 11), `App/Sources/BreathPacer.swift` + `LiveHapticsEngine.swift` +
> `PanicFlowView.swift` (the pacer seams), `DiscreetSettingsView.swift`
> (R22.7 twice-amended), `docs/session-rules.md`, operator-expected §3/§7/§8.
> **This session:** STEP-0 rulings (a)–(e) → red (app-lane manifest per
> panel) → green → verify → flag operator items. Budget: 2 billed runs + 1
> contingency.
> **At session end:** append the Session 28 ledger, overwrite this resume
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
  `resources_viewed.source` ∈ {"settings","slip_flow"} CLOSED — the notice +
  age-gate opens are intentionally uninstrumented (R27.4). purchase fires
  ONLY on user-initiated PAID (.active) completions; winback_converted
  co-fires BEFORE purchase; winback_shown co-fires with
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
- **Safety canon (S27, NEW):** the resources screen is STORE-FREE by
  construction (bundled JSON + injected analytics — the cold slip route
  depends on it); only `verified: true` rows render on ANY user surface (a
  row joins when the operator flips its flag — ALO 182 still hidden); the
  GLOBAL region stays NUMBER-FREE (no worldwide crisis number exists; a
  phone row there would be fabricated); the E5.1 age-gate surface keeps its
  own funcs, zero-fire + unmapped→US, byte-frozen; the alcohol notice is
  once-EVER app-wide (both goal modes), inline amber card, "Got it" ≥
  prominence, stamp at display, erase-swept; helpline rows are NEVER
  lexicon-scanned (sourced material renders verbatim — rule #12).
- The consent choice is a DEVICE SETTING; erase resets it OFF. Erase order:
  rows (sweeps teaserExpiresAt + paywallVariantAssigned + lapseObservedAt +
  alcoholNoticeShownAt) → infallible local clears (incl. the trial dedupe
  marker) → owned files → widget reload → `resetEntitlement()` → CloudKit
  purge LAST.
- No shame copy (lexicons only GROW); no medical claims (the milestone gate
  is PHRASE-ANCHORED — bare experiential vocabulary is sanctioned under
  "commonly reported" framing); no red anywhere (the notice card is AMBER);
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
  constructs NO analytics (its resources open is intentionally unmeasured —
  R27.11); the widget feed is label-free BY FIELD SET (R1) + presence-only
  discreet (R22.1); the shield policy is tri-state FAIL-CLOSED.
- Never weaken a QA assertion; TDD red first; `cloudKitDatabase` stays `.none`
  until the §4.3 flip.
- Snapshot goldens: light/dark ×5 families ×normal/discreet + AX5 home-only;
  fixtures dated 2025 epoch 2026-07-07T12:00:00Z; `pauseDate`/frozen clocks
  freeze tickers; the ONBOARDING + PAYWALL golden batch waits for the founder
  copy pass (S17 R5 + R24.1); the SLIP-FLOW goldens now include the resources
  link (S27 re-record). SnapshotTesting 1.19.3 + TelemetryDeck 2.14.1 +
  purchases-ios 5.80.3 + SuperwallKit 4.16.1 pinned EXACT.
