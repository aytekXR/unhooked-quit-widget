# Resume Prompt: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Resume Prompt v4.6 |
| Last updated | 2026-07-14 (Session 33 close: **UIR-1 DONE in exactly 2 billed runs** — the 2 planned, contingency UNUSED, ZERO burned. The age gate + quiz + consent + summary are regenerated on the Theme layer, copy bytes BYTE-IDENTICAL. New primitive `OnboardingScaffold` (header pinned / content SCROLLS / actions pinned / measure capped) makes the Dynamic-Type fix STRUCTURAL. **`.dynamicType` + `.textClipped` RESTORED on all three onboarding legs — the R28.13 exclusion list SHRANK a second time — and the age gate + summary are AUDITED FOR THE FIRST TIME** (5 legs, 6 frames; the ageGate leg is rule-11 SAFETY). R33.12 is the session's discovery, and only a billed run could have written it: **a point size on TEXT is un-scalable to Apple's audit no matter what drives it — a `@ScaledMetric` does NOT rescue it — and `ViewThatFits` makes every `Text` inside it un-scalable too** (it fired on a `.title3` TEXT STYLE suffix, which is what killed the font theory). A point size on a decorative `Image` is fine (both glyphs passed). Two adversarial reviewers demanded suppression handlers on the age-gate SAFETY leg; the run REFUTED both — it passed clean, and pre-suppressing would have blinded a rule-11 leg on a guess.) |
| Phase | Phase 2.5 (UI Reactor): pre-UIR build 100% DONE; **UIR-0 + UIR-1 DONE**; UIR-2…UIR-5 remain; everything else operator-gated |
| Next session objective | **Session 34: UIR-2 — dashboard + widget families (× discreet), regenerated on the UIR-0 system** |

> **What changed in Session 33:** onboarding is on the design system, and the audit's
> real Dynamic-Type contract is now KNOWN (R33.12) instead of assumed. Every later UIR
> session inherits it — and inherits a lint that enforces it for free on every lane.
> Full ledger: Session 33 in `docs/past-prompts.md` (R33.0–R33.14).

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
   pattern — S29–S33 ran it as an EXECUTED harness, the stronger form; S33 used
   it to prove a 3-generic `@ViewBuilder` init + its `where Header == EmptyView`
   overload before spending a run). (b) **qualified-name** — a Darwin-only
   file's NON-SDK qualified type references get Linux-PROBED before push; both-SDK
   files use the bare-name-exact typealias, NEVER the module-qualified form. (c)
   **non-Sendable SDK results:** a nonisolated async SDK call whose result
   type is not Sendable CANNOT return into a @MainActor conformance under
   strict flags (sanctioned fix: `@preconcurrency import`, sole-importer
   file). (d) **lint anchors admit attributes WITH parenthesized arguments:**
   import-anchored grep lints use `^(@[A-Za-z_]+(\([A-Za-z_]+\))? )*import …`.
4. **Access-level gate + empirical harness:** scan for private types in
   non-private signatures, and RUN (never just typecheck) a Linux scratch
   harness over the exact shipping bytes of every pure-Foundation/PaywallKit/
   DesignSystem-data API — probe the BOUNDARY, under MULTIPLE HOST TIMEZONES
   (the standing set: UTC/Berlin/Kiritimati). **A source LINT is such an API:
   S33 ran the shipped lint's exact logic over both corpora (pre-change +
   shipping bytes) on the free box — that is what makes a born-green lint honest.**
   JSON pins use JSONSerialization key-SET semantics — and plist pins use
   PropertyListSerialization key-SET semantics — never byte/string equality. The
   free package lane runs `swift test` WITHOUT warnings-as-errors — close the gap
   pre-push with `swift build --build-tests -Xswiftc -strict-concurrency=complete
   -Xswiftc -warnings-as-errors --package-path Packages/<pkg>`.
5. **Docs-check gate:** every Darwin-only / AppIntents / WidgetKit / SwiftUI /
   SF-Symbol / third-party member spelling verified against official docs
   BEFORE code (`developer.apple.com/tutorials/data/documentation/<path>.json`;
   SDK repos' tagged raw source for third-party) — AND per-member platform
   availability (#5b). **S32/S33 rider, now proven TWICE: docs CONFIRM existence
   and availability; they do NOT describe rendered behavior.** `.buttonStyle(.plain)`'s
   disabled auto-dimming (R32.9) and the audit's rejection of `@ScaledMetric` point
   sizes + `ViewThatFits` (R33.12) are BOTH undocumented, and both were only ever
   knowable from a run artifact. **When a claim is about PIXELS or about what an
   AUDIT will say, measure it — do not derive it.**
6. Docs-only commits carry `[skip ci]`; never spawn agent workflows for
   docs-only changes. Critic/reader agents Write findings to scratchpad files
   and return a one-line pointer (permanent — it has paid for itself FOUR times).
   Fan-outs are available (the S30 spend-limit constraint is LIFTED). **S33 rider:
   a reviewer's confident prediction about a runtime audit is a HYPOTHESIS, not a
   finding — two independent reviewers demanded suppression handlers on the
   age-gate safety leg and the run refuted both. Never pre-suppress a rule-11 leg
   on a guess; a first audit's JOB is to produce the ledger.**
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
   Scanned string tables must be STRUCTS with STORED NON-OPTIONAL properties.
   The App Privacy label AND the app manifest's collected-data half re-derive
   together on ANY enum/property change (R31.5 lockstep).
9. **BUDGET REALITY:** there is no zero-billed-run code session; free lanes
   exist, free runs do not. App-lane red evidence = the CI run on the red
   commit; package-lane red is the free local `swift test` (push red+green
   together — cancel-in-progress is FALSE on main, so two pushes = two full
   billed runs). **The born-green ruling (R31.4) extends beyond the audit class
   when — and only when — the designed red's ENTIRE evidence value is
   reproduced free (executed harness: pass-on-real-bytes + fire-on-mutation/
   absence) AND the green run's own results prove the new tests executed.**
   NEW SPM deps land in the GREEN commit, never red (R24.8). The
   golden-rides-red maneuver (R27.12) + deleted-reference record-missing
   re-records (R32.4) stand. Golden-shift valves calibrate on the TOLERANCE
   FLOOR. **xcresult artifacts are FULLY readable on the Linux box (the S29
   fileBacked2 token parser + zstd) — artifact-first diagnosis before ANY billed
   hypothesis run. S33 did it twice: it mined the S28 artifact to learn the quiz
   debt was already payable (which PAID for two new audit legs), and it mined its
   own run-1 failure — extracting the audit's ELEMENT SCREENSHOTS (`~$1,350`,
   `/year`) — to find the true cause in one pass instead of guessing across runs.**
   Every multi-step UI drive verifies each tap TOOK (R29.10).

### S32/S33 additions (permanent, UIR-era)

- **The Theme layer is load-bearing:** every color in App/Sources rides `Theme`
  (`ThemeSourceLintTests` bans the retired idioms — comment-stripped, grow-only);
  every NEW fg/bg pair a view introduces gets a `Theme.contrastPairs` entry in the
  SAME diff. The GHOST disabled treatment (contentSecondary on surfaceSunken) is the
  standing disabled form — NEVER alpha-dimmed fills. Raw `.white`/`Color.white` on
  fills is BANNED (the dark-mode 1.99:1 defect class).
- **Disabled controls are audited (R32.9):** `.buttonStyle(.plain)` composites a
  disabled label at ~50% opacity over any explicit `foregroundStyle`. A disabled CTA
  MUST ride a custom ButtonStyle, never `.plain`.
- **The Dynamic-Type contract (R33.12 — MEASURED, not derived; obey it verbatim):**
  1. **Text is sized by a TEXT STYLE, never a point value** —
     `.font(.system(.largeTitle, design: .rounded, weight: .bold))`, never
     `.font(.system(size: x))`. A `@ScaledMetric` driving the number does NOT make it
     acceptable: the font carries no type metrics and the audit says *"User will not
     be able to change the font size."*
  2. **`ViewThatFits` is BANNED on any audited surface** — it sizes candidates at a
     fixed ideal, so every `Text` inside reads as un-scalable (it fired on a `.title3`
     suffix). Read brandkit §8's stacked-at-accessibility-sizes rule off
     `@Environment(\.dynamicTypeSize)` (`isAccessibilitySize`) instead.
  3. **A point size on a decorative `Image` (SF Symbol) is FINE** — the audit does not
     scan images for type scaling; both screen glyphs passed the full set.
  4. Content SCROLLS; actions are PINNED; a height floor on anything containing text
     stays BELOW that text's accessibility-size height (44 is safe for `.body`, 56 is
     not); `.fixedSize(horizontal: false, vertical: true)` on every wrapping `Text`.
  `OnboardingScaffold` encodes 4 structurally; `OnboardingLayoutLintTests` enforces
  1–3 for free on every lane (scope = the surfaces already regenerated; it GROWS each
  UIR session and never shrinks — **UIR-2 adds the dashboard to `scopedDirectories`**).
- **`.dynamicType`/`.textClipped`** now remain excluded on the PANIC and SLIP legs
  only, owned BY NAME by UIR-3 — the exact 5 firing elements (4 panic redirect rows +
  the slip forgiveness body) are already known from the S28 artifact. The exclusion
  list may only SHRINK.
- **Never assume the element TYPE an identifier lands on (R33.13):** an id on a block
  collapsed by `.accessibilityElement(children: .ignore)` surfaces to XCUITest as
  `.other`, NOT `.staticText`. Query `descendants(matching: .any)` when unsure.
- **uipro:** present as an npm CLI (`which uipro`; rides nvm's node v20.20.2). Use its
  domain searches as generator input; the brandkit + tokens-v2 canon OVERRIDE it
  wherever they conflict.

## Where we are

- **The pre-UIR build side is 100% DONE:** the M1 loop, the widget suite, the
  DORMANT monetization vertical, the safety layer, the accessibility layer, the
  machine-proven funnel E2E, the signed win-back seam (IAP-key-gated), the
  submission package's build half, and the required-reason privacy manifests.
- **Phase 2.5 — Epic UIR (roadmap §2.5, operator-mandated):** **UIR-0 DONE (S32),
  UIR-1 DONE (S33).** Remaining: UIR-2 dashboard+widgets → UIR-3 panic+slip →
  UIR-4 paywall+settings+resources → UIR-5 motion+AX5+golden-batch prep. Binding
  constraints in roadmap §2.5: copy BYTE-IDENTICAL (§3 founder-owned), no red
  anywhere, a11y only strengthens, privacy surfaces untouched, ADR-6 panic latency,
  safety surfaces keep the stricter pre-code sign-off loop, goldens re-record
  per-session from run artifacts, the operator's §3 batch stays ONE final re-record.
- **StreakEngine 1.2.0 / WidgetToolkit 1.1.0 / PaywallKit 1.0.0 untouched.**
  purchases-ios 5.80.3 + SuperwallKit 4.16.1 + SnapshotTesting 1.19.3 +
  TelemetryDeck 2.14.1 exact-pinned. TestFlight LIVE.
- **Carried debts (all named):** OQ-1 (displayLabel) + OQ-2 (label taxonomy, with the
  R31.5 manifest-lockstep rider) awaiting the operator; R29.4 (startIfNeeded
  no-retry); brandkit §2 prose still carries pre-correction hexes (tokens-v2 is the
  record; a brandkit edit is founder-owned); tight watch pairs tertiary-on-sunken
  3.11 L / primary-text-on-tint 4.72 L (registry-pinned, passing); scenario-30
  purchase-leg E2E (sandbox tier); MVP §7 a11y box honestly UNCHECKED (UIR-5 + §7
  device work close it); the label is code-derived/wire-verify-pending (§8 app ID);
  `SafetyResourcesView` still carries the last `.background(.quaternary` fill AND a
  phone-number-only `Link` label (UIR-4's surface, not currently audited).

## Next session objective (one session, definition of done below)

**Session 34 — UIR-2: dashboard + widget families (× discreet):**

1. **Session-open checks:** the standing three-way operator check + `which uipro`.
2. **Regenerate the dashboard ON the UIR-0 system** (primitives + `ThemeMetrics` +
   brandkit §6.1/§6.2 shapes) and bring the R33.12 Dynamic-Type contract with it.
   Add `App/Sources/Dashboard` (and whatever else this session regenerates) to
   `OnboardingLayoutLintTests.scopedDirectories` — the lint's scope GROWS.
3. **The widgets are the hard half, and they are NOT the app:** widget targets stay
   luminance-only and NEVER import `Theme` (S32 canon). Any visual change to a widget
   family re-records ITS goldens — the 31 class-B goldens are byte-stable today, and
   the 5 families × light/dark × normal/discreet grid is the budget's real risk. Rule
   the golden policy at STEP-0 (the R32.4 record-missing mechanics apply: a deleted
   reference WRITES-then-FAILS, so a born-green run 1 is IMPOSSIBLE for shifted
   goldens — plan red→adopt-from-artifact, which costs runs).
4. **Constraints:** copy bytes BYTE-IDENTICAL; ADR-11 day rule and the discreet
   presence-only feed contract are STRUCTURAL and untouchable; `widget-state.json`
   stays a §10 privacy surface; the panic route never queries entitlements.
5. **NOT this session:** panic/slip (UIR-3), paywall/settings/resources (UIR-4),
   motion (UIR-5), any copy byte, any privacy surface.
0. STEP-0 candidates: (a) the widget golden policy + run budget (the dominant cost);
   (b) whether the dashboard's own `.dynamicType` findings exist — **mine the S28/S33
   artifacts FIRST; the dashboard has never been audited, and an audit leg for it may
   be affordable exactly as the age-gate/summary legs were**; (c) how far the lint's
   scope grows this session.

At close: overwrite this prompt for UIR-3; the UIR ledger grows R34.x.

## Operator-owned blockers (not agent work; carry until closed)

1. E0.3 device measurement (`docs/spike-panic-latency.md`) — the one consolidated
   physical sitting (§7) clears it.
2. E3.3 + E6.2 + E6.3 device matrix rows (operator-expected §7) + the lock-screen
   day-counter row + the S27 safety-layer eyeball + the S28 eyes-free/VoiceOver
   eyeball.
3. Content tone review (§3) — the S30 review-notes DRAFT (clinician+counsel) + OQ-1
   + the S28 a11y block + S27 safety items + carried winback/teaser/paywallCopy/
   settings items + MVP §5/§6 ratifications + the 3.1.1 riders. The §3 pass gates
   the FINAL golden batch (post-UIR: final copy + final palette together, ONE
   re-record — roadmap §2.5).
4. GitHub Actions billing headroom (§4 — Session 33 used exactly 2). The Claude
   monthly spend limit is LIFTED; fan-outs available.
5. TestFlight testers (§5) — carried; the funnel E2E is machine-proven.
6. TelemetryDeck app ID (§8) — carried; gates the label/manifest wire-verify.
7. **§8 keys + config:** RevenueCat key → Superwall key + dashboard → ASC
   promotional offer + In-App Purchase Key → the App Privacy label ENTRY (OQ-2 first;
   R31.5 lockstep) + the privacy-policy text. All sequenced at sandbox-matrix time.
8. *(struck — S31: the monthly-spend-limit item is closed)*
9. *(struck — S32: uipro FOUND on PATH, driven as the UIR generator)*

## Resume prompt (copy-paste for next session)

> You are the lead build agent for **unhooked-quit-widget** (app name **Ballast**,
> org `com.beyondkaira`). Session 33 is CLOSED (exactly 2 billed runs = the 2 planned,
> contingency UNUSED, ZERO burned; UIR-1 DONE — onboarding regenerated on the Theme
> layer, copy byte-identical; the `OnboardingScaffold` primitive; `.dynamicType` +
> `.textClipped` RESTORED on all three onboarding legs; the age gate and summary
> audited for the FIRST time; **R33.12: a point size on TEXT is un-scalable to Apple's
> audit however it is driven, and `ViewThatFits` makes its children un-scalable too**).
> **Session 34 = UIR-2: dashboard + widget families (× discreet), regenerated on the
> UIR-0 system.**
> Local Swift toolchain: `. ~/.local/share/swiftly/env.sh`.
> **Session-open:** the three-way operator check + `which uipro`.
> **Standing gates:** CodeGraph query-first + `codegraph sync` at close; `swiftc
> -parse` every touched file + neighbor import/annotation coverage + the deprecation
> gate + per-member platform availability; the FOUR burn gates; UIKit app-only APIs
> never enter Shared/Sources; access-level scan + Linux harness RUN empirically ×3 TZ
> (a shipped LINT is such a harness — rehearse it over both corpora); JSON pins
> key-SET; docs-only commits `[skip ci]`; check the STAGED set; critics WRITE findings
> to files; NEVER `git stash`; `git fetch` before every push; app-lane red evidence =
> the CI run on the red commit — born-green ONLY under the R31.4 valve; the panic route
> NEVER queries entitlements/teaser/winback; audit tests never enter a red manifest and
> a rule-11 SAFETY leg is NEVER pre-suppressed on a reviewer's prediction (S33: two
> reviewers were refuted by the run); golden-shift valves calibrate on the TOLERANCE
> FLOOR; **artifact-first diagnosis before ANY billed hypothesis run — the audit's
> element SCREENSHOTS are extractable on Linux and they name the failing element**;
> every multi-step UI drive verifies each tap TOOK; copy stays BYTE-IDENTICAL (§3
> founder-owned). PLUS the Theme rules (every color rides `Theme`; every new fg/bg pair
> enters `Theme.contrastPairs` in the same diff; the ghost disabled form; no raw
> `.white` on fills; widgets stay luminance-only and NEVER import Theme) and the
> **R33.12 Dynamic-Type contract** (text = TEXT STYLES only; no `ViewThatFits`; point
> sizes only on decorative `Image`s; content scrolls, actions pin, no 56pt floor under
> text).
> READ FIRST: the Session 33 ledger (R33.0–R33.14) in `docs/past-prompts.md`,
> `docs/design/tokens-v2.md` (§5.1 R33.12 + §6 the primitives), `docs/roadmap.md` §2.5,
> `docs/frontend-brandkit.md` §6 + §8, the S28 ledger's DT/clipping finding list,
> `docs/operator-expected.md` §3, `docs/session-rules.md`.
> **This session:** STEP-0 rulings (the widget golden policy is the budget) → the
> dashboard + widget regeneration → verify → flag operator items.
> Budget: plan 2 billed runs + 1 contingency (the widget-golden decision at STEP-0 may
> raise this — rule it explicitly).
> **At session end:** append the Session 34 ledger, overwrite this resume prompt
> (UIR-3), update `docs/operator-expected.md`, `codegraph sync`, commit `[skip ci]`,
> push, `gh run watch` green (verify the conclusion via `gh run view --json` — the
> watcher's exit code lies).

## Standing rules reminders (do not relearn these)

- **Theme canon (S32, amended S33):** `docs/design/tokens-v2.md` IS the palette record
  (brandkit §2 prose drifted — R32.7); `Theme.contrastPairs` is the WCAG gate
  (unit-lane, key-set pinned, grow-only); the a11y audit set is now PER-LEG (R33.1) —
  `safetyAuditTypes` for panic/slip, the FULL seven for the three onboarding legs;
  widgets stay luminance-only and NEVER import Theme; `AppSwitcherPrivacyOverlay` keeps
  its hardcoded surface hexes until its goldens are deliberately re-recorded;
  `DiscreetSettingsView` keeps its system container background until UIR-4.
  `Theme.type` holds ONLY glyph point sizes — there is deliberately no hero/text point
  size (R33.12).
- **ADR-11 binding:** displayed "Day N" = 1-based CALENDAR day at local midnight in
  the quit's FIXED start timezone — never `TimeZone.current`, never
  `StreakValue.days`. Count by NOON anchoring. The feed zone travels as a STRING
  identifier. **Durations are the exception-by-domain:** the teaser = 24h wall-clock
  (R25.7); the win-back window = 7×86_400s wall-clock, INCLUSIVE boundary (R26.3).
- Analytics ONLY via the closed enum; zero events before opt-in; the widget
  extension can NEVER fire analytics. Wire values: `ballast.monthly`/
  `ballast.annual`; `variant` ∈ {"teaser","hard"}; `source` gains "teaser_expiry"
  (ratification pending); `offer` = {"winback_annual"}; `resources_viewed.source` ∈
  {"settings","slip_flow"} CLOSED. purchase fires ONLY on user-initiated PAID
  completions; winback_converted co-fires BEFORE purchase; the paywall funnel is
  source-segmented. The consent-honest OBSERVED funnel starts at slot 3.
- **Privacy-manifest canon (S31):** TWO manifests, per-executable truth — app =
  UserDefaults [CA92.1, 1C8F.1] + the 3 label-lockstep collected rows; widget .appex =
  [1C8F.1] ONLY, collected EMPTY; NSPrivacyTracking=false always; never share one file
  across targets; reason codes ONLY from the fetched docs enumerations; the manifests
  re-derive with the label (R31.5) and on any required-reason-API addition.
- **Entitlement canon (S23+S24):** the mapper has NO clock; the package persists ZERO
  bytes; present-but-inactive ⇒ `isActive:false` NEVER nil; unknown SKU honors an
  active entitlement.
- **DORMANT canon (S24–S26):** key absent ⇒ the SDK symbol is never referenced at
  runtime. NEVER call `Purchases.configure` OR `Superwall.configure` without the
  operator key. The paywall screen is reachable ONLY via the live gate or DEBUG
  `UITEST_PAYWALL=1|teaser`. The winback source purchases through `purchaseWinback()`;
  missing-discount fails honestly (R29.9).
- **Teaser canon (S25):** single-use escape; entitled ALWAYS wins; teaser state lives
  ONLY in AppSettings. **Win-back canon (S26):** eligibility = ANY `.lapsed` + stamp ≥
  7d; dismissible OFFER once per process; prices via ProductCatalog constants.
- **Safety canon (S27):** the resources screen is STORE-FREE by construction; only
  `verified: true` rows render on ANY user surface; the GLOBAL region stays
  NUMBER-FREE; the E5.1 age-gate surface keeps its own funcs, zero-fire + unmapped→US,
  byte-frozen; the alcohol notice is once-EVER app-wide, inline amber card, "Got it" ≥
  prominence, erase-swept; helpline rows are NEVER lexicon-scanned. **A helpline DIAL
  link is a 44pt-floor target (R33.10) — it is the one thing that surface exists to get
  tapped.**
- **A11y canon (S28, amended S32/S33):** the eyes-free pacer preference is a
  §10-admissible pre-unlock bit; the panic route still opens NO store. The audit
  family: panic/slip/**ageGate** legs are rule-11 (NEVER quarantined, valved, or
  suppressed); the quiz + summary legs carry the R28.6 valve. **NO issue handler
  anywhere — Apple documents no Bool semantics for it, and S33 proved the predicted
  picker/link findings were phantoms.** `UITEST_QUIZ` and `UITEST_SUMMARY` mount their
  screens through BOTH levels with zero store dependency — `#if DEBUG`-walled,
  `.disabled` analytics. A template sentence with an unfilled token drops WHOLE.
- **Funnel-smoke canon (S29):** scenario-29 anchors on SURFACING elements only (nested
  `.contain` container ids never surface — Session-09 class, re-taught as R33.13);
  UITEST_EVENT_SPY arms the spy + bridge (DEBUG-inert otherwise); the bridge exposes
  wire names + step ordinals ONLY.
- **Metadata-lint canon (S30):** the explicit-terms register is GRAPHIC-only; the
  metadata-medical register excludes detox/heal/toxin; helplines.json is never read;
  intent titles pin via `LocalizedStringResource.key`. Lexicons only GROW.
- The consent choice is a DEVICE SETTING; erase resets it OFF. Erase order: rows →
  infallible local clears → owned files → widget reload → `resetEntitlement()` →
  CloudKit purge LAST.
- No shame copy (lexicons only GROW); no medical claims (the milestone gate is
  PHRASE-ANCHORED); no red anywhere; motivations VERBATIM; the paywall bans
  countdowns/fake discounts/"one-time offer"; prices are NEVER copy-table literals;
  the hard variant has NO close.
- Monotonic fields never decrease; streaks freeze, never inflate (ADR-7); the widget
  floors at Day 1 and runs NO clock guard (ADR-6).
- WITNESS discipline: three advance paths only; widgets never advance it.
- Erase discipline: local-first; owned file-set = {panic-snapshot.json, panic outcome
  buffer, widget-state.json} in THREE enumeration sites; zero active quits ⇒
  widget-state REMOVED; post-erase relaunch = fresh install (entitlements survive BY
  DESIGN).
- Panic path stays thin: panic surfaces NEVER open the store, query entitlements,
  teaser, OR winback state; the widget feed is label-free BY FIELD SET + presence-only
  discreet; the shield policy is tri-state FAIL-CLOSED.
- Never weaken a QA assertion; TDD red first (the R31.4 born-green valve is the ONLY
  sanctioned exception shape); `cloudKitDatabase` stays `.none` until the §4.3 flip.
- Snapshot goldens: light/dark ×5 families ×normal/discreet + AX5 home-only; fixtures
  dated 2025 epoch 2026-07-07T12:00:00Z; `pauseDate`/frozen clocks freeze tickers; the
  ONBOARDING + PAYWALL golden batch waits for the founder copy pass (post-UIR, ONE
  re-record) — **UIR-1 deliberately minted NO onboarding goldens (R33.2)**; the panic/
  slip goldens are on the tokens-v2 palette as of S32. SnapshotTesting 1.19.3 +
  TelemetryDeck 2.14.1 + purchases-ios 5.80.3 + SuperwallKit 4.16.1 pinned EXACT.
