# Resume Prompt: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Resume Prompt v4.8 |
| Last updated | 2026-07-17 (Session 35 close: **UIR-3 DONE in exactly 2 billed runs** — the panic + slip flows (rule-11 SAFETY surfaces) are regenerated on the Theme layer with a PM+Brand+QA pre-code sign-off, copy byte-identical. **The `.dynamicType`/`.textClipped` exclusion list is CLOSED to ZERO** — all 8 `minHeight: 56` floors became growing PADDING (the exact S28 mechanism), `StepScaffold`/`confirmStage` scroll with pinned actions (R33.5), the reasons text moved off a `@ScaledMetric` point size onto `.largeTitle` (R33.12), both audit legs joined the full 7-type set and `safetyAuditTypes` is deleted. **The rule-11 panic/slip legs passed CLEAN on run 1** (the SECOND consecutive clean first-audit — the ledger a prior run wrote is the current run's free coverage). 64 class-A goldens re-recorded + visually verified; total unchanged at 103. STEP-0: did NOT grow the lint scope to panic/slip (would force a shape-changing `.buttonStyle(.plain)` refactor on safety surfaces — the full-set audit legs are the gate instead; deferred to UIR-5). Carried: the reasons-frame AX5 title truncation (R35.6, a UIR-5 AX-axis item) and the `.plain`→ButtonStyle refactor. Superseded S34 header below.) |
| _superseded_ | (Session 34 close: **UIR-2 DONE in exactly 2 billed runs** — the 2 planned, contingency UNUSED, ZERO burned. The **real `StreakDashboardCard` + `StreakRing`** are built on the Theme layer — the `RootPlaceholderView` "walking skeleton" that had stood in for the dashboard since Session 18 is RETIRED, replaced by one card per active quit (streak-day hero, flame + momentum figure, the momentum ring, money saved, next-milestone bar). **Copy is byte-identical** (R34.2, copyBlockerFound=FALSE): every string is audited (`"saved"`/`"next milestone"`, pinned byte-identical to `StreakWidgetStyle`) or pure ADR-11 data; the §3-blocked polish strings ship empty-guarded. **The dashboard is AUDITED FOR THE FIRST TIME and its first audit passed CLEAN** (R34.3) — the first UIR surface to fire nothing, because R33.12 was already known and the card was built to it from the first byte (the free layout lint pre-empted every `.dynamicType` idiom; `children:.contain` + 4.5-clean tokens pre-empted the rest). **Widgets were DEFERRED at STEP-0** (R34.7): the 5 families are on-spec bar two minor brandkit-§3 typography defects; `StreakWidgetViews.swift` was UNTOUCHED so the 29 widget goldens stay byte-stable and no golden churn entered the budget. 8 dashboard goldens minted (95 → 103); the a11y exclusion list did not shrink this session (panic + slip remain, UIR-3's job).) |
| Phase | Phase 2.5 (UI Reactor): pre-UIR build 100% DONE; **UIR-0 + UIR-1 + UIR-2 + UIR-3 DONE**; UIR-4 + UIR-5 remain; everything else operator-gated |
| Next session objective | **Session 36: UIR-4 — paywall (hard/teaser/winback) + settings + resources, regenerated on the UIR-0…3 system (resources is a SAFETY surface — pre-code sign-off; copy untouched)** |

> **What changed in Session 35:** every screen the build has (age gate, quiz, summary,
> dashboard, panic, slip) now runs Apple's FULL accessibility audit — the exclusion list is
> EMPTY. Two consecutive clean first-audits (dashboard, then panic+slip) prove the pattern: a
> first audit passes clean when the contract (R33.5/R33.12) is already known and the free lint +
> the same-commit fix enforce it. Full ledger: Session 35 in `docs/past-prompts.md` (R35.1–R35.7).

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
   App/Sources ONLY. **S34: foundational Shape APIs (`StrokeStyle`, `.trim`,
   `.rotationEffect`) are not the deprecation gate's class — they're iOS-13-era
   stable; the gate targets deprecated/platform-specific forms.**
3. **The burn gates (S24/S25 — all Linux-reproducible, all permanent):**
   (a) **spurious-await** — every `await` in a NEW file must mark a genuinely
   async/cross-actor operation; mockup-typecheck new closure-into-seam shapes
   under `-strict-concurrency=complete -warnings-as-errors` (the ShapeChecks
   pattern). (b) **qualified-name** — a Darwin-only file's NON-SDK qualified type
   references get Linux-PROBED before push; both-SDK files use the
   bare-name-exact typealias, NEVER the module-qualified form. (c)
   **non-Sendable SDK results** cannot return into a @MainActor conformance under
   strict flags (`@preconcurrency import`, sole-importer file). (d) **lint anchors
   admit attributes WITH parenthesized arguments.** **(e) S34: a `try?` around an
   optional-chain that throws FLATTENS to `T?` in Swift 5+ — type-checked free on
   Linux before push (`(try? provider?.repository?.streakValue(...)) ?? fallback`).**
4. **Access-level gate + empirical harness:** scan for private types in
   non-private signatures, and RUN (never just typecheck) a Linux scratch
   harness over the exact shipping bytes of every pure-Foundation/PaywallKit/
   DesignSystem-data API — probe the BOUNDARY, under MULTIPLE HOST TIMEZONES
   (the standing set: UTC/Berlin/Kiritimati). **A source LINT is such an API,
   and so is a pure display-derivation** (S34 RAN `DashboardCardComposer`'s
   noon-anchor day + milestone math ×3 TZ + fire-on-mutation, and ran the layout
   lint's exact logic over the new Dashboard corpus — both born-green honestly on
   the free box). JSON pins use JSONSerialization key-SET semantics — plist pins
   use PropertyListSerialization key-SET — never byte/string equality. Free
   package lane runs `swift test` WITHOUT warnings-as-errors — close the gap
   pre-push with `swift build --build-tests -Xswiftc -strict-concurrency=complete
   -Xswiftc -warnings-as-errors --package-path Packages/<pkg>`.
5. **Docs-check gate:** every Darwin-only / AppIntents / WidgetKit / SwiftUI /
   SF-Symbol / third-party member spelling verified against official docs
   BEFORE code — AND per-member platform availability (#5b). **Proven THREE times
   now: docs CONFIRM existence + availability; they do NOT describe rendered
   behavior.** `.buttonStyle(.plain)`'s disabled dimming (R32.9) and the audit's
   rejection of `@ScaledMetric` point sizes + `ViewThatFits` (R33.12) are BOTH
   undocumented. **S34 rider: a KNOWN audit contract is free coverage — the
   dashboard's clean first audit was reachable ONLY because R33.12 (a prior run's
   ledger) was enforced by the free lint before the push. When a claim is about
   PIXELS or what an AUDIT will say, measure it — but once measured, it protects
   every later surface for free.**
6. Docs-only commits carry `[skip ci]`; never spawn agent workflows for
   docs-only changes. Critic/reader agents Write findings to scratchpad files
   and return a one-line pointer (permanent — paid for itself FIVE times; S34's
   10-agent understand+design workflow scoped the whole session before a byte was
   written, and caught that the "dashboard" was a placeholder). Fan-outs are
   available. **A reviewer's confident prediction about a runtime audit is a
   HYPOTHESIS, not a finding (S33: two reviewers refuted by the run). Never
   pre-suppress a rule-11 leg on a guess; a first audit's JOB is to produce the
   ledger — and S34 showed a first audit CAN pass clean when the contract is
   already known.** **NEVER `git stash` mid-session.** Check the STAGED set before
   every commit (the machine-local `.claude/settings.json` subagent-model pin
   NEVER rides a feature commit).
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
   Scanned string tables must be STRUCTS with STORED NON-OPTIONAL properties
   (`DashboardCopy` is an enum of static lets — admissible ONLY because its two
   live strings are pinned byte-identical to the scanned `StreakWidgetStyle`
   struct, and the rest are empty; R34.2). The App Privacy label AND the app
   manifest's collected-data half re-derive together on ANY enum/property change.
9. **BUDGET REALITY:** there is no zero-billed-run code session; free lanes
   exist, free runs do not. App-lane red evidence = the CI run on the red
   commit; package-lane red is the free local `swift test` (push red+green
   together — cancel-in-progress is FALSE on main, so two pushes = two full
   billed runs). **The born-green ruling (R31.4) extends beyond the audit class
   when — and only when — the designed red's ENTIRE evidence value is reproduced
   free (executed harness: pass-on-real-bytes + fire-on-mutation/absence) AND the
   green run's own results prove the new tests executed. NEW snapshot goldens are
   NOT born-green (R32.4 record-missing WRITES-then-FAILS on macOS): plan
   red→adopt-from-artifact→green (S34 did it in the 2 planned runs, 8 goldens).**
   NEW SPM deps land in the GREEN commit, never red. **xcresult + the test-outputs
   artifact are FULLY readable on the Linux box — artifact-first diagnosis before
   ANY billed hypothesis run, and the recorded PNGs are downloaded, VISUALLY
   VERIFIED, and committed (S34: `gh run download <id> -n test-outputs`; all 8
   dashboard goldens eyeballed before adoption).** Every multi-step UI drive
   verifies each tap TOOK (R29.10).

### S32–S34 additions (permanent, UIR-era)

- **The Theme layer is load-bearing:** every color in App/Sources rides `Theme`
  (`ThemeSourceLintTests` bans the retired idioms — comment-stripped, grow-only);
  every NEW fg/bg pair a view introduces gets a `Theme.contrastPairs` entry in the
  SAME diff (S34 added `secondary text on raised`, 5.48/6.64 — now 33 pairs). The
  GHOST disabled treatment is the standing disabled form. Raw `.white`/`Color.white`
  on fills is BANNED.
- **Disabled controls are audited (R32.9):** a disabled CTA rides a custom
  ButtonStyle, never `.plain`.
- **The Dynamic-Type contract (R33.12 — MEASURED; obey verbatim):** 1. Text is
  sized by a TEXT STYLE, never a point value (`@ScaledMetric` does NOT rescue it).
  2. `ViewThatFits` is BANNED on any audited surface — read
  `@Environment(\.dynamicTypeSize).isAccessibilitySize` for the stacked-at-AX layout
  (S34: the dashboard card OMITS its ring + goes full-width at AX sizes this way,
  proven in the light/dark-ax5 goldens). 3. A point size on a decorative `Image`
  (SF Symbol) is FINE (the dashboard flame is `.font(.system(size: 20))` and passed).
  4. Content SCROLLS; actions PIN (S34: the dashboard content scrolls, the panic
  entry is pinned in the lower reach); a height floor on anything containing text
  stays BELOW that text's accessibility-size height; `.fixedSize(horizontal: false,
  vertical: true)` on every wrapping `Text`. `OnboardingLayoutLintTests` enforces
  1–3 for free on every lane; **its scope GREW to `App/Sources/Dashboard` in S34
  and never shrinks — UIR-3 adds `App/Sources` panic/slip files** (it does NOT yet
  cover `RootPlaceholderView`, which keeps its pre-UIR `.buttonStyle(.plain)`/56pt
  idioms out of scope until its epic).
- **`.dynamicType`/`.textClipped`** remain excluded on the PANIC and SLIP legs
  only, owned BY NAME by UIR-3 — the exact 5 firing elements (4 panic redirect rows
  + the slip forgiveness body) are already known from the S28 artifact. The
  exclusion list may only SHRINK; **UIR-3 is the session that shrinks it to zero.**
- **In-app motion is UIR-5's scope (R34.4):** the `StreakRing`'s motion/calm appear
  animation is deferred there (rendering settled is golden-safe — the settled frame
  is identical animated-or-not — and keeps snapshots deterministic). Any UIR-3
  panic/slip motion polish similarly rides UIR-5 unless it's structural.
- **Never assume the element TYPE an identifier lands on (R33.13):** an id on a
  `.contain`/`.ignore`-collapsed block surfaces to XCUITest as `.other`. Query
  `descendants(matching: .any)`.
- **Widgets stay luminance-only and NEVER import Theme.** Two minor brandkit-§3
  typography defects (rectangular numeral, micro-labels) are DEFERRED to UIR-5's
  golden batch (R34.7) — `StreakWidgetViews.swift` untouched keeps the 29 goldens
  byte-stable.
- **uipro:** present as an npm CLI (`which uipro`; nvm node v20.20.2). Domain
  searches as generator input; the brandkit + tokens-v2 canon OVERRIDE it.

## Where we are

- **The pre-UIR build side is 100% DONE.**
- **Phase 2.5 — Epic UIR (roadmap §2.5, operator-mandated): UIR-0 DONE (S32),
  UIR-1 DONE (S33), UIR-2 DONE (S34), UIR-3 DONE (S35).** Remaining: UIR-4
  paywall+settings+resources → UIR-5 motion/AX5/golden-batch prep. **The
  `.dynamicType`/`.textClipped` exclusion list is CLOSED to ZERO — every leg runs the
  full 7-type set; `safetyAuditTypes` is deleted.** Binding constraints: copy
  BYTE-IDENTICAL, no red anywhere, a11y only strengthens, privacy surfaces untouched,
  ADR-6 panic latency, safety surfaces keep the stricter pre-code sign-off loop,
  goldens re-record per-session from run artifacts, the operator's §3 batch stays ONE
  final re-record.
- **StreakEngine 1.2.0 / WidgetToolkit 1.1.0 / PaywallKit 1.0.0 untouched.**
  purchases-ios 5.80.3 + SuperwallKit 4.16.1 + SnapshotTesting 1.19.3 +
  TelemetryDeck 2.14.1 exact-pinned. TestFlight LIVE.
- **Carried debts (all named):** OQ-1 (displayLabel) + OQ-2 (label taxonomy, R31.5
  manifest-lockstep) awaiting the operator; R29.4 (startIfNeeded no-retry); brandkit
  §2 prose still carries pre-correction hexes (tokens-v2 is the record); tight watch
  pairs tertiary-on-sunken 3.11 L / primary-text-on-tint 4.72 L (registry-pinned);
  scenario-30 purchase-leg E2E (sandbox tier); MVP §7 a11y box honestly UNCHECKED;
  the label is code-derived/wire-verify-pending (§8 app ID); `SafetyResourcesView`
  still carries the last `.background(.quaternary` fill + a phone-number-only `Link`
  label (UIR-4's surface); **the widget typography defects (R34.7) and the dashboard
  frozen-tooltip / reduce-framing / composed-a11y polish (all §3-blocked) — named,
  ride the founder pass / UIR-5.**

## Next session objective (one session, definition of done below)

**Session 36 — UIR-4: paywall (hard/teaser/winback) + settings + resources, on the
UIR-0…3 system:**

1. **Session-open checks:** the standing three-way operator check + `which uipro`.
2. **RESOURCES is a SAFETY surface** — the PM+Brand+QA panel signs its redesign SPEC
   BEFORE code (agent-workflows §2.2; a multi-agent gate, NOT an operator gate; copy
   untouched so no §3 copy pass). `SafetyResourcesView` still carries the last
   `.background(.quaternary` fill in the app AND a phone-number-only `Link` label —
   both close here (the `.quaternary` → a Theme surface; the DIAL link → a 44pt floor,
   the R33.10 precedent). Only `verified: true` rows render; the GLOBAL region stays
   NUMBER-FREE (safety canon S27).
3. **PAYWALL copy is DRAFT (operator §3-pending)** — like onboarding, UIR-4 will very
   likely **mint NO new paywall goldens** (they would be thrown away by the §3 pass;
   the R33.2 DON'T-MINT ruling). The paywall is reachable ONLY via the live gate or
   DEBUG `UITEST_PAYWALL=1|teaser`; the panic route NEVER reaches it. Regenerate its
   layout on the Theme layer + primitives (PrimaryButtonStyle for the CTA, QuietButton
   for restore/terms, `themedCard`/`radius/l` plan cards, the trial badge on a NEUTRAL
   sunken capsule — R32.3), R33.12/R33.5 obeyed. The paywall bans countdowns/fake
   discounts/"one-time offer"; prices are NEVER copy-table literals; the hard variant
   has NO close. Consider a paywall a11y-audit leg only if a DEBUG mount can render it
   deterministically without draft copy in a golden (rule at STEP-0).
4. **SETTINGS (`DiscreetSettingsView`)** — keeps its system container background UNTIL
   UIR-4 (S32 canon); this is that session. Regenerate on the Theme layer + primitives;
   its goldens (if any) re-record. Copy byte-identical.
5. **Goldens:** settings + resources restyle re-records THEIR goldens (plan
   red→adopt-from-artifact, the S34/S35 maneuver — VISUALLY VERIFY each). Paywall
   likely mints none (draft copy). Rule the exact golden count + run budget at STEP-0.
6. **Constraints:** copy BYTE-IDENTICAL; the DORMANT monetization canon holds (no
   `configure` without keys; the paywall's never-trap surface: retry + restore always
   reachable); the resources screen is STORE-FREE by construction; no privacy surface.
7. **NOT this session:** motion polish (UIR-5), the widget typography fix (UIR-5), the
   reasons-frame AX5 title (UIR-5), the `.plain`→ButtonStyle refactor + panic/slip lint
   scope (UIR-5), any copy byte, any privacy surface.
0. STEP-0 candidates: (a) whether the paywall mints goldens (probably NO — draft copy)
   vs settings/resources (yes); (b) whether a paywall a11y-audit leg is affordable
   given the draft copy (a DEBUG mount + `children:.contain` per S34); (c) the lint
   scope growth (settings/resources are candidates; the paywall's draft-copy churn
   argues for care); (d) the run budget.

At close: overwrite this prompt for UIR-5 (the FINAL UIR session — motion/polish + AX5
axes + the consolidated golden-batch prep for the operator's §3 sitting); the UIR ledger
grows R36.x.

**After UIR-5, the agent-doable UIR work is COMPLETE and the project is BLOCKED on the
operator critical path** (G0 rename, §3 copy pass, §8 keys + sandbox matrix, device rows +
E0.3 latency, external beta, submission) — see the operator-owned blockers below.

## Operator-owned blockers (not agent work; carry until closed)

1. E0.3 device measurement (`docs/spike-panic-latency.md`) — the one consolidated
   physical sitting (§7) clears it.
2. E3.3 + E6.2 + E6.3 device matrix rows + the lock-screen day-counter row + the S27
   safety-layer eyeball + the S28 eyes-free/VoiceOver eyeball.
3. Content tone review (§3) — the S30 review-notes DRAFT + OQ-1 + the S28 a11y block +
   S27 safety items + carried winback/teaser/paywallCopy/settings items + MVP §5/§6
   ratifications + the 3.1.1 riders. The §3 pass gates the FINAL golden batch
   (post-UIR: final copy + final palette, ONE re-record). **The dashboard's own copy
   is audited/data, so its 8 goldens are NOT in that batch — they are stable now.**
4. GitHub Actions billing headroom (§4 — Session 35 used exactly 2). Spend limit
   LIFTED; fan-outs available.
5. TestFlight testers (§5) — carried; the funnel E2E is machine-proven.
6. TelemetryDeck app ID (§8) — carried; gates the label/manifest wire-verify.
7. **§8 keys + config:** RevenueCat → Superwall → ASC promotional offer + IAP Key →
   the App Privacy label ENTRY (OQ-2 first) + the privacy-policy text. Sequenced at
   sandbox-matrix time.

## Resume prompt (copy-paste for next session)

> You are the lead build agent for **unhooked-quit-widget** (app **Ballast**, org
> `com.beyondkaira`). Session 35 is CLOSED (exactly 2 billed runs = the 2 planned,
> contingency UNUSED, ZERO burned; UIR-3 DONE — panic + slip regenerated on the Theme
> layer, copy byte-identical, the `.dynamicType`/`.textClipped` exclusion list CLOSED
> to ZERO on every leg, the rule-11 panic/slip legs passed the full set CLEAN on run 1,
> 64 goldens re-recorded + visually verified).
> **Session 36 = UIR-4: paywall (hard/teaser/winback) + settings + resources (resources
> is a SAFETY surface — the stricter PM+Brand+QA pre-code sign-off; copy untouched;
> paywall copy is DRAFT so likely mint NO paywall goldens — the R33.2 rule).**
> Local Swift toolchain: `. ~/.local/share/swiftly/env.sh`.
> **Session-open:** the three-way operator check + `which uipro`.
> **Standing gates:** CodeGraph query-first + `codegraph sync` at close; `swiftc
> -parse` every touched file + neighbor import/annotation coverage + the deprecation
> gate + per-member platform availability; the FIVE burn gates (incl. `try?`-flatten);
> UIKit app-only APIs never enter Shared/Sources; access-level scan + Linux harness RUN
> empirically ×3 TZ (a shipped LINT and a pure display-derivation are such harnesses —
> rehearse over both corpora); JSON pins key-SET; docs-only commits `[skip ci]`; check
> the STAGED set (the settings.json subagent pin never rides a feature commit); critics
> WRITE findings to files; NEVER `git stash`; `git fetch` before every push; app-lane
> red evidence = the CI run — NEW snapshot goldens are red→adopt-from-artifact→green
> (VISUALLY VERIFY each PNG), NEVER born-green; the panic route NEVER queries
> entitlements/teaser/winback; a rule-11 SAFETY leg is NEVER pre-suppressed on a
> prediction; golden-shift valves calibrate on the TOLERANCE FLOOR; artifact-first
> diagnosis before ANY billed hypothesis run; every multi-step UI drive verifies each
> tap TOOK; copy stays BYTE-IDENTICAL (§3 founder-owned). PLUS the Theme rules (every
> color rides `Theme`; every new fg/bg pair enters `Theme.contrastPairs` in the same
> diff; the ghost disabled form; no raw `.white`; widgets luminance-only, NEVER Theme,
> typography defects deferred to UIR-5) and the **R33.12 Dynamic-Type contract** (text =
> TEXT STYLES only; no `ViewThatFits`; point sizes only on decorative `Image`s; content
> scrolls, actions pin; the AX-size pivot reads `isAccessibilitySize`). In-app motion is
> UIR-5's scope.
> READ FIRST: the Session 35 ledger (R35.1–R35.7) + Session 34 (R34.1–R34.8) in
> `docs/past-prompts.md`, `docs/design/tokens-v2.md` (§5.1 R33.12 + §6 the primitives),
> `docs/roadmap.md` §2.5, `docs/frontend-brandkit.md` §6 (items 7/8/14/15 = paywall,
> settings, resources) + §8, `docs/operator-expected.md` §3 (the paywall/settings/
> winback DRAFT copy items), `App/Sources/Monetization/PaywallView.swift`,
> `App/Sources/DiscreetSettingsView.swift`, `App/Sources/SafetyResourcesView.swift`,
> `docs/session-rules.md`.
> **This session:** STEP-0 rulings (paywall likely mints NO goldens — draft copy;
> settings/resources re-record; resources is a safety surface) → the paywall + settings
> + resources regeneration + the resources safety pre-sign-off → verify → flag operator
> items.
> Budget: plan 2 billed runs + 1 contingency (rule the golden budget at STEP-0).
> **At session end:** append the Session 36 ledger, overwrite this resume prompt
> (UIR-5, the FINAL UIR session), update `docs/operator-expected.md`, `codegraph sync`,
> commit `[skip ci]`, push, `gh run watch` green (verify the conclusion via `gh run
> view --json` — the watcher's exit code lies).

## Standing rules reminders (do not relearn these)

- **Theme canon (S32, amended S33/S34/S35):** `docs/design/tokens-v2.md` IS the palette
  record; `Theme.contrastPairs` is the WCAG gate (unit-lane, key-set pinned, grow-only —
  33 pairs as of S34); **the a11y audit set is now ONE FULL SET for EVERY leg (UIR-3
  closed the exclusion to zero; `safetyAuditTypes` is deleted)** — age gate/quiz/summary/
  dashboard/panic/slip all run the full seven; widgets stay luminance-only and NEVER
  import Theme; `AppSwitcherPrivacyOverlay` keeps its hardcoded surface hexes until its
  goldens are deliberately re-recorded; **`DiscreetSettingsView` keeps its system
  container background until UIR-4 — that is Session 36.** `Theme.type` holds ONLY glyph
  point sizes — no hero/text point size (R33.12).
  The `StreakRing` is a Shape (`Circle().trim().stroke(StrokeStyle(lineWidth:6))`), not a
  point-size glyph.
- **ADR-11 binding:** displayed "Day N" = 1-based CALENDAR day at local midnight in the
  quit's FIXED start timezone — never `TimeZone.current`, never `StreakValue.days`. Count
  by NOON anchoring. The feed zone travels as a STRING identifier. **The dashboard's
  `DashboardCardComposer.calendarDayNumber` inlines the exact `StreakTimelinePlanner`
  algorithm and is drift-guarded against the widget planner in the unit lane (R34.5) — the
  in-app "Day N" and the widget "Day N" can never disagree.** Durations are the
  exception-by-domain: teaser 24h wall-clock; win-back window 7×86_400s inclusive.
- Analytics ONLY via the closed enum; zero events before opt-in; the widget extension can
  NEVER fire analytics. Wire values: `ballast.monthly`/`ballast.annual`; `variant` ∈
  {"teaser","hard"}; `source` gains "teaser_expiry" (ratification pending); `offer` =
  {"winback_annual"}; `resources_viewed.source` ∈ {"settings","slip_flow"} CLOSED. purchase
  fires ONLY on user-initiated PAID completions; winback_converted co-fires BEFORE purchase.
  **The dashboard fires NOTHING — it is a display surface (R34.8).**
- **Privacy-manifest canon (S31):** TWO manifests, per-executable truth — app = UserDefaults
  [CA92.1, 1C8F.1] + the 3 label-lockstep rows; widget .appex = [1C8F.1] ONLY, collected
  EMPTY; NSPrivacyTracking=false always; reason codes ONLY from the fetched docs enumerations.
- **Entitlement canon (S23+S24):** the mapper has NO clock; the package persists ZERO bytes;
  present-but-inactive ⇒ `isActive:false` NEVER nil; unknown SKU honors an active entitlement.
- **DORMANT canon (S24–S26):** key absent ⇒ the SDK symbol is never referenced at runtime.
  NEVER call `Purchases.configure`/`Superwall.configure` without the operator key. The paywall
  is reachable ONLY via the live gate or DEBUG `UITEST_PAYWALL=1|teaser`.
- **Teaser canon (S25) / Win-back canon (S26):** single-use escape; entitled ALWAYS wins;
  eligibility = ANY `.lapsed` + stamp ≥ 7d; dismissible OFFER once per process.
- **Safety canon (S27):** the resources screen is STORE-FREE; only `verified: true` rows render;
  the GLOBAL region stays NUMBER-FREE; the E5.1 age-gate keeps its own funcs, byte-frozen; the
  alcohol notice is once-EVER app-wide, inline amber card, "Got it" ≥ prominence; helpline rows
  are NEVER lexicon-scanned; a helpline DIAL link is a 44pt-floor target (R33.10). **The alcohol
  notice + the pending-undo banner render inside the S34 dashboard (RootPlaceholderView) — UIR-3
  touches the panic/slip FLOWS, not these dashboard-mounted cards (UIR-4's surfaces, or they
  ride their own epics).**
- **A11y canon (S28, amended S32/S33/S34):** the eyes-free pacer preference is a §10-admissible
  pre-unlock bit; the panic route opens NO store. The audit family: panic/slip/**ageGate** legs
  are rule-11 (NEVER quarantined/valved/suppressed); quiz + summary + **dashboard** legs carry
  the R28.6 valve. **NO issue handler anywhere.** `UITEST_QUIZ`/`UITEST_SUMMARY`/**`UITEST_DASHBOARD`**
  mount their screens through BOTH levels with zero store dependency — `#if DEBUG`-walled,
  `.disabled`/no analytics. A template sentence with an unfilled token drops WHOLE.
  **`children:.contain` (not `.ignore`) lets each `Text` carry its own description when a composed
  a11y sentence is §3-blocked (R34.3) — the dashboard's clean first audit used this.**
- **Funnel-smoke canon (S29):** scenario-29 anchors on SURFACING elements only (nested `.contain`
  container ids never surface — R33.13); UITEST_EVENT_SPY arms the spy + bridge (DEBUG-inert
  otherwise).
- **Metadata-lint canon (S30):** the explicit-terms register is GRAPHIC-only; the metadata-medical
  register excludes detox/heal/toxin; helplines.json is never read; intent titles pin via
  `LocalizedStringResource.key`. Lexicons only GROW.
- The consent choice is a DEVICE SETTING; erase resets it OFF. Erase order: rows → infallible local
  clears → owned files → widget reload → `resetEntitlement()` → CloudKit purge LAST.
- No shame copy (lexicons only GROW); no medical claims (the milestone gate is PHRASE-ANCHORED); no
  red anywhere; motivations VERBATIM; the paywall bans countdowns/fake discounts/"one-time offer";
  prices are NEVER copy-table literals; the hard variant has NO close.
- Monotonic fields never decrease; streaks freeze, never inflate (ADR-7); the widget floors at
  Day 1 and runs NO clock guard (ADR-6). **The dashboard renders a frozen streak
  (`clockSanity == .clockRolledBack`) with its correct numbers + a neutral ring, no red, no alarm
  (R34.4) — the tooltip is §3-blocked.**
- WITNESS discipline: three advance paths only; widgets never advance it.
- Erase discipline: local-first; owned file-set = {panic-snapshot.json, panic outcome buffer,
  widget-state.json} in THREE enumeration sites; zero active quits ⇒ widget-state REMOVED;
  post-erase relaunch = fresh install (entitlements survive BY DESIGN).
- Panic path stays thin: panic surfaces NEVER open the store, query entitlements, teaser, OR
  winback state; the widget feed is label-free BY FIELD SET + presence-only discreet; the shield
  policy is tri-state FAIL-CLOSED.
- Never weaken a QA assertion; TDD red first (the R31.4 born-green valve is the ONLY sanctioned
  exception shape; NEW snapshot goldens are NOT born-green — R32.4); `cloudKitDatabase` stays
  `.none` until the §4.3 flip.
- Snapshot goldens: light/dark ×5 widget families ×normal/discreet + AX5 home-only; the DASHBOARD
  card ×{active(4 axes),discreet(2),frozen,reduce} = 8 (S34, on the tokens-v2 palette, copy
  audited — NOT in the founder batch); fixtures dated 2025 epoch; `pauseDate`/frozen clocks freeze
  tickers; the ONBOARDING + PAYWALL golden batch waits for the founder copy pass (post-UIR, ONE
  re-record); the panic/slip goldens are on the tokens-v2 palette (S32) and UIR-3 re-records them
  on the restyle. SnapshotTesting 1.19.3 + TelemetryDeck 2.14.1 + purchases-ios 5.80.3 +
  SuperwallKit 4.16.1 pinned EXACT.
