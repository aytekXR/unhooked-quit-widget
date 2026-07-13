# Resume Prompt: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Resume Prompt v4.4 |
| Last updated | 2026-07-14 (Session 31 close: R30.6 DONE in exactly 1 billed run — born-green ruled over a recorded two-judge split, contingency UNUSED, ZERO burned. TWO required-reason manifests ship: the APP's `App/Resources/PrivacyInfo.xcprivacy` (UserDefaults **[CA92.1, 1C8F.1]** — the S30 carry's CA92.1 was the right category but the App-Group reason is 1C8F.1, docs-verbatim; both codes verified per-site — PLUS the 3 collected-data rows in LOCKSTEP with `docs/app-privacy-label.md` (R30.4/R31.5, OQ-2 rider recorded), NSPrivacyTracking=false) and the WIDGET's `Widgets/Resources/PrivacyInfo.xcprivacy` (**[1C8F.1] ONLY**, collected EMPTY — NEW R31.1 finding: the .appex executable itself reaches App-Group UserDefaults via Shared/PanicLaunchFlag from the extension-side panic intents, so the second manifest is docs-MANDATED). LiveClock's mach_continuous_time()/kern.bootsessionuuid: NOT on the documented SystemBootTime list → no declaration (R31.3). Pins: `Tests/Unit/PrivacyManifestTests.swift` — app half reads Bundle.main (built-bundle honest), widget half reads authored bytes + the project.yml wiring pin (the S30 no-.appex-traversal precedent), key-SET semantics, gate-gates-itself calibration, rehearsed ×3 TZ under strict flags pre-push. **The pre-UIR build side is FULLY DONE.** ALSO this session, operator-mandated: roadmap v1.1 adds **Phase 2.5 Epic UIR "UI Reactor"** — full UI/UX regeneration, 6 sessions, gating submission assets (waivable). The S30 Claude spend-limit constraint is LIFTED (canary + a 6-agent workflow ran clean); the "uipro" tool the operator reports installed is NOT visible on the build box — operator-expected §9.) |
| Phase | Phase 2.5 (UI Reactor): pre-UIR build 100% DONE (E2–E10.2 + R30.6); UIR-0…UIR-5 are the remaining build sessions; everything else operator-gated |
| Next session objective | **Session 32: UIR-0 — the design system: regenerated tokens (color/type/spacing/motion) + component kit + the WCAG-clean palette that closes R28.13 by construction** |

> **What changed in Session 31:** the missing required-reason privacy manifests (the
> last real Apple submission blocker in the build) now ship for BOTH executables with
> docs-verbatim reason codes, label-lockstep collected-data, and permanent key-set
> pins. The operator mandated the UI Reactor epic (roadmap v1.1 §2.5) — the next
> build sessions redesign every surface without touching a copy byte. Full ledger:
> Session 31 in `docs/past-prompts.md` (R31.1–R31.8).

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
   pattern — S29/S30/S31 ran it red→green as an EXECUTED harness, the stronger
   form). (b) **qualified-name** — a Darwin-only file's NON-SDK qualified type
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
   UTC/Berlin/Kiritimati). JSON pins use JSONSerialization key-SET semantics —
   and (S31) plist pins use PropertyListSerialization key-SET semantics — never
   byte/string equality. The free package lane runs `swift test` WITHOUT
   warnings-as-errors — close the gap pre-push with
   `swift build --build-tests -Xswiftc -strict-concurrency=complete
   -Xswiftc -warnings-as-errors --package-path Packages/<pkg>` (or the
   scratch harness for app-side pure subsets).
5. **Docs-check gate:** every Darwin-only / AppIntents / WidgetKit / SF-Symbol /
   third-party member spelling verified against official docs BEFORE code
   (`developer.apple.com/tutorials/data/documentation/<path>.json`; SDK repos'
   tagged raw source for third-party) — AND per-member platform availability
   (#5b). **S31 proof-of-worth: the docs-check corrected the carried CA92.1
   assumption (App-Group = 1C8F.1) and kept mach_continuous_time OUT of the
   manifest (not on the documented list) — never classify from memory. The
   privacy manifests re-derive on ANY UserDefaults/timestamp/boot-time/
   disk-space/keyboard API addition — the pin fires on manifest drift, but the
   SWEEP must rerun whenever such an API enters a diff.**
6. Docs-only commits carry `[skip ci]`; never spawn agent workflows for
   docs-only changes. Critic/reader agents Write findings to scratchpad files
   and return a one-line pointer (permanent — it has paid for itself twice).
   **(S31) The S30 monthly-spend-limit constraint is LIFTED — canary-verified;
   fan-outs are available again. If a fan-out ever dies mid-session, salvage
   from the seats' files and finish inline (the S30 playbook).**
   **NEVER `git stash` mid-session.** Check the STAGED set before every commit.
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
   optional sections get `#require`d into the walk. The App Privacy label AND
   the app manifest's collected-data half re-derive together on ANY enum/
   property change (payload-audit §7 + app-privacy-label.md + R31.5 lockstep).
9. **BUDGET REALITY:** there is no zero-billed-run code session; free lanes
   exist, free runs do not. App-lane red evidence = the CI run on the red
   commit; package-lane red is the free local `swift test` (push red+green
   together — cancel-in-progress is FALSE on main, so two pushes = two full
   billed runs). **(S31) The born-green ruling extends beyond the audit class
   when — and only when — the designed red's ENTIRE evidence value is
   reproduced free (executed harness: pass-on-real-bytes + fire-on-mutation/
   absence) AND the green run's own results prove the new tests executed;
   record the split if seats disagree.** A schema/shared-pass change sweeps
   the FUNCTION-level blast radius of every pin on it. NEW SPM deps land in
   the GREEN commit, never red (R24.8). The golden-rides-red maneuver (R27.12)
   + deleted-reference record-missing re-records (S28) stand. Golden-shift
   valves calibrate on the TOLERANCE FLOOR. xcresult artifacts are FULLY
   readable on the Linux box (the S29 fileBacked2 token parser) —
   artifact-first diagnosis before ANY billed hypothesis run. Every multi-step
   UI drive verifies each tap TOOK (R29.10).

## Where we are

- **The pre-UIR build side is 100% DONE:** the M1 loop, the widget suite, the
  DORMANT monetization vertical, the safety layer, the accessibility layer, the
  machine-proven funnel E2E, the signed win-back seam (IAP-key-gated), the
  submission package's build half, and now (S31) the required-reason privacy
  manifests for BOTH executables with permanent key-set pins.
- **Phase 2.5 — Epic UIR "UI Reactor" (roadmap v1.1 §2.5, operator-mandated):**
  regenerate the full UI/UX in 6 one-objective sessions (UIR-0 tokens → UIR-1
  onboarding → UIR-2 dashboard+widgets → UIR-3 panic+slip → UIR-4
  paywall+settings+resources → UIR-5 motion+AX5+golden-batch prep). Binding
  constraints live in roadmap §2.5: copy BYTE-IDENTICAL (§3 founder-owned), no
  red anywhere, a11y only strengthens (UIR-0 closes R28.13 by construction),
  privacy surfaces untouched, ADR-6 panic latency, safety surfaces keep the
  stricter pre-code sign-off loop, goldens re-record per-session from run
  artifacts, the operator's §3 batch stays ONE final re-record.
- **StreakEngine 1.2.0 / WidgetToolkit 1.1.0 / PaywallKit 1.0.0 untouched.**
  purchases-ios 5.80.3 + SuperwallKit 4.16.1 + SnapshotTesting 1.19.3 +
  TelemetryDeck 2.14.1 exact-pinned. TestFlight LIVE (Session 31 build).
- **Carried debts (all named):** OQ-1 (displayLabel) + OQ-2 (label taxonomy — now
  with the R31.5 manifest-lockstep rider) awaiting the operator; R29.4
  (startIfNeeded no-retry); R28.13 (closes INSIDE UIR-0); the 2 hapticsOnly stale
  goldens (UIR re-records anyway); scenario-30 purchase-leg E2E (sandbox tier);
  MVP §7 a11y box honestly UNCHECKED (UIR-5 + §7 device work close it); the label
  is code-derived/wire-verify-pending (§8 app ID); **§9 uipro discrepancy** (the
  operator reports it installed; not visible on the build box — check at every
  UIR session open; use it as the primary generator the moment it appears).

## Next session objective (one session, definition of done below)

**Session 32 — UIR-0: the design system** (the UI Reactor's foundation; every later
UIR session consumes its output):

1. **Session-open checks:** the standing three-way operator check; PLUS probe for
   `uipro` (skill/plugin/MCP — see §9): if visible, load it FIRST and make it the
   generator for everything below; if not, proceed on the documented workflows and
   re-record its absence.
2. **Token regeneration:** color/type/spacing/motion tokens rebuilt from brandkit
   §1/§2/§3/§5/§7 intent — with the HARD constraint that the new palette passes
   WCAG contrast on every R28.13-deferred class (the S28 audit findings are the
   acceptance list; closing them by construction is UIR-0's reason to exist).
   Deliverables: `docs/design/tokens-v2.md` (the brandkit addendum) + a Theme
   layer in App/Sources (single source of truth the views consume).
3. **Component kit:** inventory brandkit §6's MVP components; implement the themed
   primitives (buttons, cards, chips, progress, the streak ring spec) WITHOUT
   rewiring screens yet (screens migrate in UIR-1…4 — keeps this session
   one-objective and the diff reviewable).
4. **Goldens:** only the surfaces a Theme swap actually re-renders re-record, from
   the run's own artifacts (R27.12 lineage); everything else must stay
   byte-stable — a golden that shifts UNexpectedly is a finding, not a re-record.
5. **NOT this session:** screen redesigns (UIR-1…4), copy changes (NEVER — §3),
   motion polish (UIR-5), any privacy/store surface.
0. STEP-0 candidates: (a) Theme-layer shape (environment-injected theme vs static
   token namespace — Architect seat); (b) which R28.13 classes are token-closable
   vs layout-bound (layout-bound ones ride their surface's UIR session — name
   them); (c) golden-diff budget: which goldens are EXPECTED to shift in UIR-0
   (likely: any surface already consuming shared colors) and the run plan
   (red-rides-golden vs born-green re-record from artifact); (d) whether the AX5
   axes land per-session or consolidated in UIR-5 (the S28 ONE-re-record promise
   constrains); (e) uipro presence probe result.

At close: overwrite this prompt for UIR-1; the UIR ledger grows R32.x.

## Operator-owned blockers (not agent work; carry until closed)

1. E0.3 device measurement (`docs/spike-panic-latency.md`) — the one
   consolidated physical sitting (§7) clears it.
2. E3.3 + E6.2 + E6.3 device matrix rows (operator-expected §7) + the
   lock-screen day-counter row + the S27 safety-layer eyeball + the S28
   eyes-free/VoiceOver eyeball.
3. Content tone review (§3) — the S30 review-notes DRAFT (clinician+counsel) +
   OQ-1 + the S28 a11y block + S27 safety items + carried winback/teaser/
   paywallCopy/settings items + MVP §5/§6 ratifications + the 3.1.1 riders.
   The §3 pass gates the FINAL golden batch (post-UIR: final copy + final
   palette together, ONE re-record — roadmap §2.5).
4. GitHub Actions billing headroom (§4 — Session 31 used exactly 1). The Claude
   monthly spend limit is LIFTED (S31-verified); fan-outs available.
5. TestFlight testers (§5) — carried; the funnel E2E is machine-proven.
6. TelemetryDeck app ID (§8) — carried; gates the label/manifest wire-verify.
7. **§8 keys + config:** RevenueCat key → Superwall key + dashboard → ASC
   promotional offer + In-App Purchase Key → the App Privacy label ENTRY
   (docs/app-privacy-label.md; OQ-2 first — NOTE R31.5: the ASC label and the
   shipped manifest's collected-data half are in LOCKSTEP; if counsel repicks
   the taxonomy, one session updates label doc + manifest + pin together) +
   the privacy-policy text. All sequenced at sandbox-matrix time.
8. *(struck — S31: the monthly-spend-limit item is closed)*
9. **NEW — uipro:** the operator reports "we have installed uipro"; it is NOT
   visible on the build box (verified twice 2026-07-14: skills, both plugin
   surfaces, MCP/deferred tools). Either it lives on another machine (Mac?) or
   the install didn't take. If UIR should run on it, make it visible to the
   build environment (marketplace name / install path); otherwise UIR proceeds
   on the documented workflows. Does NOT block UIR-0.

## Resume prompt (copy-paste for next session)

> You are the lead build agent for **unhooked-quit-widget** (app name
> **Ballast**, org `com.beyondkaira`). Session 31 is CLOSED (1 billed run,
> born-green ruled over a recorded judge split, contingency unused, ZERO
> burned; R30.6 DONE — both executables ship docs-verbatim required-reason
> manifests with label-lockstep collected-data and key-set pins; roadmap v1.1
> adds Phase 2.5 Epic UIR, operator-mandated). **Session 32 = UIR-0: the
> design system — regenerated tokens + component kit + the WCAG-clean palette
> closing R28.13 by construction; deliverables docs/design/tokens-v2.md + a
> Theme layer + themed primitives; NO screen rewiring, NO copy byte changes,
> NO motion polish yet.**
> Local Swift toolchain: `. ~/.local/share/swiftly/env.sh`.
> **Session-open:** the three-way operator check + the uipro probe (§9 — if a
> uipro tool is visible, it becomes the primary generator; record either way).
> **Standing gates:** CodeGraph query-first + sync at close; `swiftc -parse`
> every touched file + neighbor import/annotation coverage + the deprecation
> gate + #5b per-member platform availability; the FOUR burn gates (rule #3);
> UIKit app-only APIs never enter Shared/Sources; access-level scan + Linux
> harness RUN empirically ×3 TZ; JSON pins key-SET (plists via
> PropertyListSerialization, S31); docs-only commits `[skip ci]`; check the
> STAGED set; critics REPRODUCE under `-strict-concurrency=complete
> -warnings-as-errors`; NEVER `git stash`; `git fetch` + `git log origin/main`
> before every push; app-lane red evidence = the CI run on the red commit —
> born-green beyond the audit class ONLY when the red's entire evidence value
> is reproduced free AND the green run proves the tests executed (R31.4); the
> panic route NEVER queries entitlements/teaser/winback; audit tests never
> enter a red manifest; golden-shift valves calibrate on the TOLERANCE FLOOR;
> a11y tests on safety paths may never be quarantined; artifact-first
> diagnosis before ANY billed hypothesis run; every multi-step UI drive
> verifies each tap TOOK (R29.10); copy stays BYTE-IDENTICAL through every
> UIR session (§3 founder-owned); any new UserDefaults/timestamp/boot/disk/
> keyboard API in a diff re-runs the S31 manifest sweep (rule #5).
> READ FIRST: the Session 31 ledger in `docs/past-prompts.md` (R31.1–R31.8),
> `docs/roadmap.md` §2.5 (the UIR epic — scope, constraints, session plan),
> `docs/frontend-brandkit.md` (§1/§2/§3/§5/§6/§7/§8), the S28 ledger's R28.13
> finding list (the WCAG acceptance list), `docs/operator-expected.md` §3/§9,
> `docs/session-rules.md`.
> **This session:** STEP-0 rulings (a)–(e) → tokens-v2 + Theme layer + themed
> primitives → the golden plan per (c) → verify → flag operator items.
> Budget: plan 2 billed runs (the Theme swap WILL shift some goldens —
> red-rides-golden or artifact re-record per the (c) ruling) + 1 contingency.
> **At session end:** append the Session 32 ledger, overwrite this resume
> prompt (UIR-1), update `docs/operator-expected.md`, `codegraph sync`, commit
> `[skip ci]`, push, `gh run watch` green (verify the conclusion via
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
  The consent-honest OBSERVED funnel starts at slot 3 (S19-R1).
- **Privacy-manifest canon (S31, NEW):** TWO manifests, per-executable truth —
  app = UserDefaults [CA92.1, 1C8F.1] + the 3 label-lockstep collected rows;
  widget .appex = [1C8F.1] ONLY (no .standard compiles there), collected
  EMPTY; NSPrivacyTracking=false always; never share one file across targets;
  never place a manifest under Shared/Sources; reason codes ONLY from the
  fetched docs enumerations (mach_continuous_time/kern.bootsessionuuid are
  NOT SystemBootTime members — R31.3); the manifests re-derive with the label
  (R31.5 lockstep) and on any required-reason-API addition (rule #5).
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
  carries the R28.6 valve; the R28.13 class exclusions are grow-only UNTIL
  UIR-0 closes them (then they SHRINK — the one sanctioned direction change).
  `UITEST_QUIZ` mounts the quiz through BOTH levels with zero store
  dependency — DEBUG-inert, `.disabled` analytics, NO completion seam.
  A template sentence with an unfilled token drops WHOLE. BreathBloom
  stays a11y-hidden.
- **Funnel-smoke canon (S29):** scenario-29 anchors on SURFACING elements only
  (nested `.contain` container ids never surface, Session-09 class); the
  smoke's valve v2 stands in its header; UITEST_EVENT_SPY arms the spy +
  bridge (DEBUG-inert otherwise); the spy is a SINK-tier decorator
  (consent-honesty structural); the bridge exposes wire names + step
  ordinals ONLY.
- **Metadata-lint canon (S30):** the explicit-terms register is GRAPHIC-only —
  category nouns (porn/weed) and the sanctioned clinical/ASO forms are NEVER
  banned; the metadata-medical register excludes detox/heal/toxin
  (milestone-body scope); helplines.json is never read; `PanicControlStyle`
  is enumerated (Mirror-vacuous); intent titles pin via
  `LocalizedStringResource.key`; the widget .appex display name is
  rehearsal-covered (project.yml), never .appex-traversed. Lexicons only
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
- Never weaken a QA assertion; TDD red first (the R31.4 born-green valve is
  the ONLY sanctioned exception shape); `cloudKitDatabase` stays `.none`
  until the §4.3 flip.
- Snapshot goldens: light/dark ×5 families ×normal/discreet + AX5 home-only;
  fixtures dated 2025 epoch 2026-07-07T12:00:00Z; `pauseDate`/frozen clocks
  freeze tickers; the ONBOARDING + PAYWALL golden batch waits for the founder
  copy pass (bundling AX5 axes + the R28.13 contrast/textClipped visual
  pass — post-UIR, ONE re-record); the SLIP-FLOW goldens include the
  resources link (S27) and the never-dangle degraded copy (S28).
  SnapshotTesting 1.19.3 + TelemetryDeck 2.14.1 + purchases-ios 5.80.3 +
  SuperwallKit 4.16.1 pinned EXACT.
