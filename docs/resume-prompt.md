# Resume Prompt: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Resume Prompt v4.3 |
| Last updated | 2026-07-13 (Session 30 close: E10.2 submission-package prep, the BUILD-side half — DONE in 1 billed run, contingency UNUSED, ZERO burned. The four deliverables: `docs/review-notes.md` (DRAFT/founder-owned; every claim evidence-anchored; the 3.1.2/keys/rename decisions SURFACED not resolved), `docs/app-privacy-label.md` (3 collected rows code-derived from the closed enum — Product Interaction + the habit category → recommended Health & Fitness › Health (OQ-2, counsel ratifies) + Purchase History-once-keyed; NO Identifiers row; wire-verify pending the §8 app ID), `Tests/Unit/SubmissionMetadataLintTests.swift` (the born-green explicit-terms + metadata-medical audit gate over bundle names + the 8 content tables + widget/control/intent strings — born-green proven EMPIRICALLY pre-push: Python rehearsal over the exact shipping bytes 0-violations + the exact matcher bytes RUN under strict flags ×3 TZ; category nouns porn/weed deliberately unbanned, helplines never read, PanicControlStyle enumerated against the R9 Mirror-vacuity trap, intent titles pinned via docs-confirmed `LocalizedStringResource.key`), and `docs/submission-checklist.md` (every MVP §7 box classified [M]/[O]/[F] with exact CI evidence; NO box auto-ticked). TWO real findings surfaced: **R30.6 — the app ships NO PrivacyInfo.xcprivacy required-reason manifest while using UserDefaults/App-Group (CA92.1) in code, a REAL Apple submission blocker and Session 31's objective**; OQ-1 — the displayLabel "Porn"/"Weed" two-seat deadlock (an existing test PINS them as brand-reviewed; Brand wants "Adult content"/"Cannabis") surfaced to the operator. Session-open operator check: NOTHING required (three-way confirmed; recorded open-to-close). Session-mechanics note: the STEP-0 panel's synthesis agent died on the operator's Claude MONTHLY SPEND LIMIT — salvaged at zero loss because every seat Writes findings to files (rule 6 exists for this); the session completed INLINE. Until the limit is raised or the month rolls, run sessions inline-first and treat subagent fan-outs as unavailable.) |
| Phase | Phase 2/3 seam: E2–E9 build halves CLOSED + E10.2 build half CLOSED; delivery 32/32 build-side except R30.6; remaining build = the R30.6 manifest, then everything else is operator-gated |
| Next session objective | **Session 31: R30.6 — the PrivacyInfo.xcprivacy required-reason manifest (app + widget targets), the LAST pre-submission build task. Then the build side is fully DONE pending operator gates** |

> **What changed in Session 30:** the submission package's build half exists — a
> reviewer-notes draft the operator can sign, an App-Privacy-label row set derived
> from the closed enum with code evidence, a permanent explicit-terms/metadata lint
> gate in CI, and the §7 checklist wired to its evidence with every operator gate
> named. One genuine submission blocker was discovered and named (R30.6, the missing
> required-reason manifest — Session 31 closes it). Full ledger: Session 30 in
> `docs/past-prompts.md` (R30.1–R30.7, OQ-1/OQ-2).

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
   pattern — S29/S30 ran it red→green as an EXECUTED harness, the stronger form;
   S30's harness caught a top-level-isolation miss for free). (b)
   **qualified-name** — a Darwin-only file's NON-SDK qualified type
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
   (#5b). Recorded S30: `LocalizedStringResource.key` = `let key: String`,
   iOS 16+ (absent from Linux Foundation — Linux-unprobeable, docs-JSON is the
   evidence). **Session 31's docs-check targets: Apple's required-reason API
   categories + `NSPrivacyAccessedAPITypes` manifest keys (CA92.1 UserDefaults;
   classify LiveClock's `mach_continuous_time()` + `kern.bootsessionuuid`
   against the SystemBootTime list) — Apple publishes these as docs pages;
   verify every reason code against the current list, never from memory.**
6. Docs-only commits carry `[skip ci]`; never spawn agent workflows for
   docs-only changes. Critic/reader agents Write findings to scratchpad files
   and return a one-line pointer — **(S30) this discipline just paid for
   itself: the panel synthesis died on the operator's Claude MONTHLY SPEND
   LIMIT and was salvaged from its files at zero loss. Until the operator
   raises the limit (or the month rolls), treat subagent fan-outs as
   UNAVAILABLE and run sessions inline.** **NEVER `git stash` mid-session.**
   Check the STAGED set before every commit.
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
   optional sections get `#require`d into the walk. **(S30) The App Privacy
   label re-derives on ANY enum/property change (payload-audit §7 +
   app-privacy-label.md) — an enum edit now also invalidates a submitted
   label; say so in any session that touches it.**
9. **BUDGET REALITY:** there is no zero-billed-run code session; free lanes
   exist, free runs do not. App-lane red evidence = the CI run on the red
   commit; package-lane red is the free local `swift test` (push red+green
   together — cancel-in-progress is FALSE on main, so two pushes = two full
   billed runs). A schema/shared-pass change sweeps the FUNCTION-level blast
   radius of every pin on it. NEW SPM deps land in the GREEN commit, never
   red (R24.8). The golden-rides-red maneuver (R27.12) + deleted-reference
   record-missing re-records (S28) stand. Golden-shift valves calibrate on
   the TOLERANCE FLOOR. xcresult artifacts are FULLY readable on the Linux box
   (the S29 fileBacked2 token parser) — artifact-first diagnosis before ANY
   billed hypothesis run. Every multi-step UI drive verifies each tap TOOK
   (R29.10 — previous-frame guard + ONE bounded re-tap, evidence attached).

## Where we are

- **Everything through E10.2's build half is DONE:** the M1 loop, the widget suite,
  the DORMANT monetization vertical, the safety layer, the accessibility layer, the
  machine-proven funnel E2E with its event-spy tail, the signed win-back seam
  (IAP-key-gated), and now the submission package's build half (review-notes draft,
  privacy-label derivation, the metadata lint gate, the wired §7 checklist).
- **The ONE remaining build task: R30.6** — no `PrivacyInfo.xcprivacy` exists while
  the app uses required-reason APIs (UserDefaults/App-Group, CA92.1 — confirmed in
  `PanicLaunchFlag.swift`/`PanicFlowView.swift`/`UnhookedApp.swift`; LiveClock's
  `mach_continuous_time()`/`kern.bootsessionuuid` need classification). Apple
  rejects without it (since 2024).
- **StreakEngine 1.2.0 / WidgetToolkit 1.1.0 / PaywallKit 1.0.0 untouched.**
  purchases-ios 5.80.3 + SuperwallKit 4.16.1 + SnapshotTesting 1.19.3 +
  TelemetryDeck 2.14.1 exact-pinned. TestFlight LIVE (Session 30 build).
- **Carried debts (all named):** R30.6 (Session 31); OQ-1 (displayLabel
  "Porn"/"Weed" — operator/brand call; an existing test pins the literals) + OQ-2
  (label taxonomy — counsel) awaiting the operator, neither blocks builds; R29.4
  (startIfNeeded no-retry — §9-owner decision); R28.13 a11y-visual classes + the
  goldens batch (operator §3-gated, ONE re-record bundling colors+copy+goldens);
  the 2 default-axis hapticsOnly goldens (valid-but-stale); scenario-30's
  purchase-leg E2E (operator sandbox tier); MVP §7 accessibility checkbox honestly
  UNCHECKED; the label is code-derived/wire-verify-pending (§8 app ID).

## Next session objective (one session, definition of done below)

**Session 31 — R30.6: the PrivacyInfo.xcprivacy required-reason manifest** (the last
pre-submission build task; after it the build side is fully DONE pending operator
gates):

1. **Docs-check FIRST (gate #5):** fetch Apple's current required-reason API
   category list + the `NSPrivacyAccessedAPITypes`/`NSPrivacyAccessedAPIType…`
   manifest key spellings from the official docs pages; enumerate EVERY
   required-reason API the app + widget targets actually use (grep-driven sweep:
   UserDefaults (CA92.1 confirmed), file-timestamp APIs, boot-time APIs — classify
   LiveClock's `mach_continuous_time()` + `kern.bootsessionuuid` against the
   SystemBootTime category; disk-space; active-keyboard). Reason codes only from
   the documented enumerations — docs-UNCONFIRMED spellings are nonexistent.
2. **Author the manifest(s):** `PrivacyInfo.xcprivacy` for the app target (and the
   widget target if Apple's rules require a separate one for the .appex — verify
   against docs; SDKs carry their own). Include the NSPrivacyCollectedDataTypes
   half consistent with `docs/app-privacy-label.md` (the label IS the source; keep
   them in lockstep) and NSPrivacyTracking=false.
3. **Wire into project.yml** (bundled resource per target) — the XcodeGen shape.
4. **Test shape:** a designed red IS honestly available here (the manifest does not
   exist → a unit-lane pin on its presence + key-set is born-red over a real inert
   seam) — STEP-0 rules red-vs-born-green + the pin design (JSONSerialization
   key-SET semantics over the bundled plist/xcprivacy bytes; it is a plist —
   PropertyListSerialization, same key-set discipline).
5. **NOT this session:** any store action; ASO; the OQ-1 label fix (operator);
   any privacy-surface change (the manifest DESCRIBES, never changes, collection).
0. STEP-0 candidates: (a) one manifest or two (app + appex) — docs-verified;
   (b) red-vs-born-green for the presence/key-set pins; (c) budget split (likely
   2 billed runs: red + green, or 1 if born-green is ruled); (d) whether the
   collected-data half enters the manifest now (keys dormant) or at key-land —
   consistency with the label doc decides.

At close: the build side is FULLY DONE; everything that remains
(submission, keys, sandbox matrix, beta, goldens, ASO) runs on the operator's clock.

## Operator-owned blockers (not agent work; carry until closed)

1. E0.3 device measurement (`docs/spike-panic-latency.md`) — the one
   consolidated physical sitting (§7) clears it.
2. E3.3 + E6.2 + E6.3 device matrix rows (operator-expected §7) + the
   lock-screen day-counter row + the S27 safety-layer eyeball + the S28
   eyes-free/VoiceOver eyeball (device test 40's perceptual half).
3. Content tone review (§3) — now ALSO the S30 review-notes DRAFT
   (clinician+counsel is its ship gate) + OQ-1 (displayLabel keep-or-repin) +
   the S28 a11y block + S27 safety items + carried winback/teaser/paywallCopy/
   settings items + MVP §5/§6 ratifications + the 3.1.1 riders. The §3 pass
   gates the R28.13 visual pass + goldens batch (ONE re-record).
4. GitHub Actions billing headroom (§4 — Session 30 used exactly 1, contingency
   unused) **+ the Claude MONTHLY SPEND LIMIT is HIT (S30): subagent fan-outs
   fail until it is raised or the month rolls; inline sessions unaffected.**
5. TestFlight testers (§5) — carried; the funnel E2E is machine-proven.
6. TelemetryDeck app ID (§8) — carried; ALSO now gates the label
   wire-verification (app-privacy-label.md is code-derived until the MITM runs).
7. **§8 keys + config:** the RevenueCat key → the Superwall key + dashboard →
   the ASC promotional offer + In-App Purchase Key upload (the app-side signed
   path is BUILT — the key is the ONLY gate on the live 50%-off discount) →
   the App Privacy label ENTRY (docs/app-privacy-label.md; OQ-2 taxonomy call
   first) + the privacy-policy text. All sequenced at sandbox-matrix time;
   nothing blocks builds.

## Resume prompt (copy-paste for next session)

> You are the lead build agent for **unhooked-quit-widget** (app name
> **Ballast**, org `com.beyondkaira`). Session 30 is CLOSED (1 billed run,
> contingency unused, ZERO burned; the E10.2 build half is DONE — review-notes
> draft + privacy-label derivation + the born-green metadata lint + the wired
> §7 checklist; R30.6 discovered and named). **Session 31 = R30.6: the
> PrivacyInfo.xcprivacy required-reason manifest (app + widget targets),
> docs-checked reason codes, project.yml wiring, presence/key-set pins — the
> LAST pre-submission build task; no store action; no privacy-surface change.**
> Local Swift toolchain: `. ~/.local/share/swiftly/env.sh`.
> **Standing gates:** CodeGraph query-first + sync at close; `swiftc -parse`
> every touched file + neighbor import/annotation coverage + the deprecation
> gate (docs-UNCONFIRMED spellings are nonexistent) + #5b per-member platform
> availability; the FOUR burn gates (rule #3); UIKit app-only APIs never enter
> Shared/Sources; access-level scan + Linux harness RUN empirically ×3 TZ;
> JSON pins use key-SET semantics (PropertyListSerialization for the plist);
> docs-only commits `[skip ci]`; check the STAGED set; critics REPRODUCE under
> `-strict-concurrency=complete -warnings-as-errors`; NEVER `git stash`;
> `git fetch` + `git log origin/main` before every push; app-lane red evidence
> = the CI run on the red commit; the panic route NEVER queries
> entitlements/teaser/winback; audit tests never enter a red manifest;
> golden-shift valves calibrate on the TOLERANCE FLOOR; a11y tests on safety
> paths may never be quarantined; artifact-first diagnosis on the Linux box
> before ANY billed hypothesis run; every multi-step UI drive verifies each
> tap TOOK (R29.10). **(S30) The Claude monthly spend limit is HIT — run
> INLINE, no subagent fan-outs, until the operator raises it or the month
> rolls; if any agent IS spawned it must Write findings to files first-thing.**
> READ FIRST: the Session 30 ledger in `docs/past-prompts.md` (R30.1–R30.7,
> OQ-1/OQ-2), `docs/submission-checklist.md` (the named blockers),
> `docs/app-privacy-label.md` (the manifest's collected-data half must stay in
> lockstep with it), `docs/operator-expected.md` §3/§4/§8,
> `docs/session-rules.md`.
> **This session:** STEP-0 rulings (a)–(d) → docs-check the reason codes →
> author + wire the manifest(s) → the presence/key-set pins per the red-vs-
> born-green ruling → verify → flag operator items. Budget: likely 2 billed
> runs (red + green) or 1 (born-green ruled) + 1 contingency.
> **At session end:** append the Session 31 ledger, overwrite this resume
> prompt (the build side closes — what follows is operator-gated; the next
> agent session after 31 is on-demand: OQ fixes, goldens batch post-§3, or
> sandbox-matrix support), update `docs/operator-expected.md`, `codegraph
> sync`, commit `[skip ci]`, push, `gh run watch` green (verify the conclusion
> via `gh run view --json` — the watcher's exit code lies).

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
  dependency — DEBUG-inert, `.disabled` analytics, NO completion seam.
  A template sentence with an unfilled token drops WHOLE. BreathBloom
  stays a11y-hidden.
- **Funnel-smoke canon (S29):** scenario-29 anchors on SURFACING elements only
  (`quiz.continue`/`summary.cta`/`paywall.cta` — nested `.contain` container
  ids never surface, Session-09 class); the smoke's valve v2 stands in its
  header; UITEST_EVENT_SPY arms the spy + bridge (DEBUG-inert otherwise); the
  spy is a SINK-tier decorator (consent-honesty structural); the bridge
  exposes wire names + step ordinals ONLY.
- **Metadata-lint canon (S30, NEW):** the explicit-terms register is
  GRAPHIC-only — category nouns (porn/weed) and the sanctioned clinical/ASO
  forms (adult content, Cannabis, porn addiction, dopamine detox, nofap) are
  NEVER banned; the metadata-medical register excludes detox/heal/toxin
  (milestone-body scope); helplines.json is never read; `PanicControlStyle`
  is enumerated (Mirror-vacuous); intent titles pin via
  `LocalizedStringResource.key`; the widget .appex display name is
  rehearsal-covered (project.yml:219), never .appex-traversed. Lexicons only
  GROW (foundation-floor superset pins).
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
