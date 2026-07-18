# Resume Prompt: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Resume Prompt v5.2 |
| Last updated | 2026-07-18 (Session 39 close: **UIR-5b attempt 1 — the SETTINGS audit leg is DEFERRED to its true depth; reverted to the UIR-5a green state (byte-identical, all 107 goldens restored, 8 audited surfaces intact).** Two billed runs bought the DIAGNOSIS, no net feature. **R39.1:** a title in a LIST ROW clips exactly like the nav bar (a row is height-constrained) — `.dynamicType`/`.textClipped` fire on it. **R39.2:** a FREE-STANDING `.largeTitle` `Text` ABOVE the List FIXES the title (proven), but the audit then flags the settings LIST CONTENT — the long haptic-pacer SECTION FOOTER clips at AX5, and it uses NO explicit font (List's default scalable footnote): **List SECTION FOOTERS clip at accessibility sizes, a STRUCTURAL issue, not a font fix.** Deferred because completing it (move every long footer out of the `footer:` slot + re-record goldens) is unknown-depth whack-a-mole at 1 billed run/iteration on a polish surface — a future pass must enumerate ALL findings from ONE run (or a local macOS run) and fix wholesale. **The fix is now KNOWN on both axes** (title: free-standing text above the List; content: footers out of List slots). Also logged: `[skip ci]` in a commit BODY (not just the subject) skips the run — never write the literal token unless you mean it. Superseded S38 header below.) |
| _superseded_ | (Session 38 close: **UIR-5a DONE in exactly 2 billed runs — the deferred audit legs + the Monetization lint scope.** The **PAYWALL** joins the audited surfaces — `test_a11yAudit_paywall` (UITEST_PAYWALL_DIRECT → the hard-variant fixture) passed the FULL 7-type set CLEAN on its first run; the a11y audit now covers **8 surfaces** (age gate, quiz, summary, dashboard, panic, slip, resources, paywall). `App/Sources/Monetization` joined the layout-lint scope (48 files, floor 12 → 35, born-green; the inline retry `.plain` → the pass-through `PlanCardButtonStyle`). No goldens (audits mint none; the lint growth is born-green) — all 107 goldens byte-stable. **R38.2 = the SETTINGS audit leg is DEFERRED:** its run-1 `.dynamicType`+`.textClipped` fired on the navigation-bar LARGE TITLE ("Discreet Mode", NavigationBar/LargeTitle — a SYSTEM behavior, not the themed content), so the fix is a custom/`.inline` title (which re-records the settings golden), owned by UIR-5b. Run 1 also carried an UNRELATED erase-debounce unit FLAKE (passed in S37; resolved on run 2). **UIR-5b (motion/polish + the settings large-title fix + widget typography + reasons AX5 + golden-batch prep) is the LAST agent-doable UIR work.** Superseded S37 header below.) |
| _superseded_ | (Session 37 close: **UIR-4b DONE in exactly 2 billed runs — UIR-4 FULLY COMPLETE.** `DiscreetSettingsView` moved onto the Theme layer via in-place List theming (`.scrollContentBackground(.hidden)` + surface/base backdrop + `.listRowBackground(surface/raised)` per Section + `.tint(brand/primary)` + Theme text tokens), keeping List's native cell accessibility; 2 goldens minted (105 → 107), golden visually verified. Deferred to UIR-5: the settings/paywall audit legs + the Monetization lint scope + full settings golden coverage. **Every screen in the build is now regenerated onto the design system.** Superseded S36 header below.) |
| _superseded_ | (Session 36 close: **UIR-4a DONE in exactly 2 billed runs** — the two DEFECT surfaces regenerated: **RESOURCES** (safety) — `.background(.quaternary)` → `themedCard`, the R33.10 DIAL link (44pt floor + "Call <name>" label), 2 goldens + a new audit leg that passed the full 7-type set CLEAN on run 1 (the THIRD consecutive clean first-audit); **PAYWALL** — 3 R32.9 disabled-`.plain` fixes (`PrimaryButtonStyle`/`QuietButtonStyle` + the new pass-through `PlanCardButtonStyle`) + a pre-existing caution-on-caution contrast bug, no goldens (draft copy, verified by the QuizFunnelUITests smoke). **SETTINGS DEFERRED to UIR-4b** (the List→ScrollView restyle — the biggest structural risk, cleanly separable; full spec preserved in `scratchpad/uir4-step0.md` + workflow journal wf_b91f1762-aff). New contrast pair (34 total, Linux-verified). **R36.4 = the mount-gate lesson: a full-screen `.accessibilityElement(children: .contain)` container id does NOT surface as a queryable element (unlike a bounded card) — gate an audit leg on a real CHILD element.** Superseded S35 header below.) |
| _superseded_ | (Session 35 close: **UIR-3 DONE in exactly 2 billed runs** — the panic + slip flows (rule-11 SAFETY surfaces) are regenerated on the Theme layer with a PM+Brand+QA pre-code sign-off, copy byte-identical. **The `.dynamicType`/`.textClipped` exclusion list is CLOSED to ZERO** — all 8 `minHeight: 56` floors became growing PADDING (the exact S28 mechanism), `StepScaffold`/`confirmStage` scroll with pinned actions (R33.5), the reasons text moved off a `@ScaledMetric` point size onto `.largeTitle` (R33.12), both audit legs joined the full 7-type set and `safetyAuditTypes` is deleted. **The rule-11 panic/slip legs passed CLEAN on run 1** (the SECOND consecutive clean first-audit — the ledger a prior run wrote is the current run's free coverage). 64 class-A goldens re-recorded + visually verified; total unchanged at 103. STEP-0: did NOT grow the lint scope to panic/slip (would force a shape-changing `.buttonStyle(.plain)` refactor on safety surfaces — the full-set audit legs are the gate instead; deferred to UIR-5). Carried: the reasons-frame AX5 title truncation (R35.6, a UIR-5 AX-axis item) and the `.plain`→ButtonStyle refactor. Superseded S34 header below.) |
| _superseded_ | (Session 34 close: **UIR-2 DONE in exactly 2 billed runs** — the 2 planned, contingency UNUSED, ZERO burned. The **real `StreakDashboardCard` + `StreakRing`** are built on the Theme layer — the `RootPlaceholderView` "walking skeleton" that had stood in for the dashboard since Session 18 is RETIRED, replaced by one card per active quit (streak-day hero, flame + momentum figure, the momentum ring, money saved, next-milestone bar). **Copy is byte-identical** (R34.2, copyBlockerFound=FALSE): every string is audited (`"saved"`/`"next milestone"`, pinned byte-identical to `StreakWidgetStyle`) or pure ADR-11 data; the §3-blocked polish strings ship empty-guarded. **The dashboard is AUDITED FOR THE FIRST TIME and its first audit passed CLEAN** (R34.3) — the first UIR surface to fire nothing, because R33.12 was already known and the card was built to it from the first byte (the free layout lint pre-empted every `.dynamicType` idiom; `children:.contain` + 4.5-clean tokens pre-empted the rest). **Widgets were DEFERRED at STEP-0** (R34.7): the 5 families are on-spec bar two minor brandkit-§3 typography defects; `StreakWidgetViews.swift` was UNTOUCHED so the 29 widget goldens stay byte-stable and no golden churn entered the budget. 8 dashboard goldens minted (95 → 103); the a11y exclusion list did not shrink this session (panic + slip remain, UIR-3's job).) |
| Phase | Phase 2.5 (UI Reactor): pre-UIR build 100% DONE; **UIR-0…4 DONE; UIR-5a DONE (8 audited surfaces incl. paywall)**; UIR-5b attempt 1 (S39) DEFERRED the settings audit leg (STRUCTURAL List-footer AX5 finding — characterized). **Remaining (UIR-5c): the settings-content audit [characterized], `StreakRing` motion, widget typography (R34.7), reasons AX5 (R35.6), golden-batch prep** — polish; then the project is fully operator-gated. The 8 audited surfaces + all 107 goldens are green. |
| Next session objective | **Session 40: UIR-5c — the remaining UIR polish. (a) The settings-content audit [OPTIONAL/deferrable]: title = free-standing `.largeTitle` `Text` above the List (R39.2, proven); content = move the long List SECTION FOOTERS out of the `footer:` slot into scalable in-content rows; enumerate ALL findings from ONE run before fixing (avoid the S39 whack-a-mole). (b) `StreakRing` motion (golden-safe). (c) widget typography R34.7 (~13 goldens). (d) reasons-frame AX5 title R35.6. (e) golden-batch PREP. Each is INDEPENDENT — a red on one must not block the others; sequence lowest-risk first. Copy untouched.** |

> **What changed in Session 39 (UIR-5b attempt 1):** the **settings audit leg stays DEFERRED**, now
> diagnosed to its true depth and reverted to the UIR-5a green state (byte-identical). The finding is
> NOT just the nav-bar large title — the settings **List CONTENT** clips at AX5: a `.largeTitle` in a
> List ROW clips like the nav bar (R39.1), and even with a free-standing title (which PASSES, R39.2),
> the long **List section FOOTERS** clip at AX5 with no font to fix (structural). Completing it is
> unknown-depth whack-a-mole per billed run, so it is deferred with the fix now known on both axes. The
> **8 audited surfaces + all 107 goldens stay green.** Full ledger: Session 39 in `docs/past-prompts.md`
> (R39.1–R39.2). [Prior — S38/UIR-5a:] the **paywall** joins the audited surfaces — its first
> audit passed the full 7-type set CLEAN — and the Monetization directory is now layout-lint-enforced
> (48 files, born-green). The **settings audit leg is DEFERRED**
> (R38.2): its `.dynamicType`+`.textClipped` fired on the navigation-bar LARGE TITLE — a SYSTEM
> large-title behavior, not the themed content — so the fix (a custom/`.inline` title, which re-records
> the settings golden) is owned by UIR-5b. Full ledger: Session 38 in `docs/past-prompts.md`
> (R38.1–R38.2). [Prior:] every screen is on the Theme layer (S37 settings, native cell accessibility
> kept); THREE consecutive clean first-audits (dashboard, panic+slip, resources) + the paywall's clean
> first audit make FOUR. The mount-gate lesson (R36.4): **gate an audit leg on a real CHILD element,
> not a full-screen `.contain` container id.**

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
  UIR-1 DONE (S33), UIR-2 DONE (S34), UIR-3 DONE (S35), UIR-4 DONE (S36 resources+paywall / S37
  settings), UIR-5a DONE (S38 — the deferred audit legs + Monetization lint scope; the audit now
  covers 8 surfaces incl. the paywall).** Remaining: **UIR-5b** — the settings large-title fix +
  motion/polish + widget typography + reasons AX5 + golden-batch prep. **The
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

**Session 39 — UIR-5b, the FINAL UIR session (the settings large-title fix + motion/polish + widget
typography + reasons AX5 + golden-batch prep).** UIR-0…4 + UIR-5a are all DONE — every screen is
regenerated and 8 surfaces are audited. This is the last agent-doable UIR work; after it the project
is fully operator-gated.

1. **Session-open checks:** the standing three-way operator check + `which uipro`.
2. **The settings large-title fix (R38.2 — re-adds the deferred audit leg).** The settings audit
   fired `.dynamicType`+`.textClipped` on the navigation-bar LARGE TITLE ("Discreet Mode",
   NavigationBar/LargeTitle — a SYSTEM behavior, NOT the themed content). Fix:
   `.navigationBarTitleDisplayMode(.inline)` OR a custom `.principal` toolbar title with a Theme text
   style (verify the chosen form does not itself clip). This re-records the 2 settings goldens
   (red→adopt-from-artifact→green, VISUALLY VERIFY) and RE-ADDS the settings audit leg (UITEST_SETTINGS
   mount → `DiscreetSettingsView`, gate on `settings.resources.row` — a real Button, R36.4; R28.6
   valve-eligible). The mount + env-var were removed in S38 — re-add them. Re-confirm the leg passes.
3. **UIR-5 motion/polish:** the `StreakRing` motion/calm appear animation
   (`Dashboard/StreakRing.swift` — currently renders SETTLED; add the appear animation,
   golden-safe since settled == animated at rest); any panic/slip motion polish. Keep
   golden-safe.
4. **AX5-axis + widget typography:** the reasons-frame AX5 title truncation (R35.6 — a paging→scroll
   treatment at accessibility sizes on the non-audited reasons frame); the widget typography
   defects (R34.7 — rectangular numeral `.headline`→~20pt monospaced; micro-labels
   `.caption2`→~12pt Medium+tracking in `Shared/Sources/StreakWidgetViews.swift` — this
   re-records ~13 of the 29 widget goldens; DELETE the affected rectangular+medium references
   so they write-then-fail, budget it explicitly).
5. **Golden-batch PREP** for the operator §3 sitting (the final onboarding+paywall re-record
   waits on the founder copy pass — do NOT mint them; prepare the list).
6. **Goldens:** settings re-records 2; widget typography re-records ~13; any new surface mints. Plan
   red→adopt-from-artifact, VISUALLY VERIFY each. **R36.4: gate any new audit leg on a real
   CHILD element, never a full-screen `.contain` container id.**
7. **Constraints:** copy BYTE-IDENTICAL; DORMANT monetization canon; widgets luminance-only
   (never Theme); no privacy surface.
0. STEP-0 candidates: (a) the widget-golden re-record budget (the dominant cost — delete →
   red → adopt) vs the settings re-record — likely TWO separate red-then-green golden batches; (b)
   whether to split the widget typography from the settings fix + motion across two sessions (the
   settings fix + motion are one coherent golden batch); (c) the run budget.

**After this session the agent-doable UIR work is COMPLETE and the project is BLOCKED on
the operator critical path** (G0 rename, §3 copy pass, §8 keys + sandbox matrix, device
rows + E0.3 latency, external beta, submission).

At close: hand this prompt off to the OPERATOR CRITICAL PATH (the UI regeneration is complete);
the UIR ledger grows R39.x.

**After UIR-5b, the agent-doable UIR work is COMPLETE and the project is BLOCKED on the
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
4. GitHub Actions billing headroom (§4 — Session 37 used exactly 2). Spend limit
   LIFTED; fan-outs available.
5. TestFlight testers (§5) — carried; the funnel E2E is machine-proven.
6. TelemetryDeck app ID (§8) — carried; gates the label/manifest wire-verify.
7. **§8 keys + config:** RevenueCat → Superwall → ASC promotional offer + IAP Key →
   the App Privacy label ENTRY (OQ-2 first) + the privacy-policy text. Sequenced at
   sandbox-matrix time.

## Resume prompt (copy-paste for next session)

> You are the lead build agent for **unhooked-quit-widget** (app **Ballast**, org
> `com.beyondkaira`). Session 39 is CLOSED (UIR-5b attempt 1 — the SETTINGS audit leg DEFERRED to its
> true depth, reverted to the UIR-5a green state byte-identical; 2 billed runs bought the diagnosis, no
> net feature). **8 audited surfaces + all 107 goldens are green.** The settings finding is now KNOWN:
> a `.largeTitle` in a List ROW clips like the nav bar (R39.1); a FREE-STANDING title above the List
> FIXES the title (R39.2) but the settings LIST CONTENT then flags — the long List SECTION FOOTERS clip
> at AX5 with no font to fix (structural). It was deferred rather than whack-a-moled at 1 billed run per
> guess. **Every screen is regenerated onto the design system.**
> **Session 40 = UIR-5c, the remaining UIR polish — INDEPENDENT items, sequence lowest-risk first, a
> red on one must NOT block the others:** (a) the SETTINGS-CONTENT audit [OPTIONAL/deferrable — enumerate
> ALL findings from ONE run or a local macOS run BEFORE fixing; title = free-standing `.largeTitle`
> `Text` above the List (proven), content = long section footers OUT of the `footer:` slot into scalable
> in-content rows]; (b) the `StreakRing` motion/calm appear animation (golden-safe — settled == animated
> at rest); (c) widget typography R34.7 (re-records ~13 widget goldens, budget it); (d) the reasons-frame
> AX5 title R35.6; (e) the consolidated golden-batch PREP. Copy untouched. AFTER UIR-5c the agent-doable
> UIR work is COMPLETE — the project blocks on the operator critical path.**
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
> typography defects deferred to UIR-5b) and the **R33.12 Dynamic-Type contract** (text =
> TEXT STYLES only; no `ViewThatFits`; point sizes only on decorative `Image`s; content
> scrolls, actions pin; the AX-size pivot reads `isAccessibilitySize`). In-app motion is
> UIR-5b's scope. **R38.2: a navigation-bar LARGE TITLE fires `.dynamicType`/`.textClipped` to
> the audit — use `.inline` or a custom Theme title on any audited screen.**
> READ FIRST: the Session 38 ledger (R38.1–R38.2) + Session 37 (R37.1–R37.4) in
> `docs/past-prompts.md`, `docs/design/tokens-v2.md` (§5.1 R33.12 + §6 the primitives),
> `docs/roadmap.md` §2.5, `docs/frontend-brandkit.md` §6 (items 7/8/14/15 = paywall,
> settings, resources) + §8, `docs/operator-expected.md` §3 (the paywall/settings/
> winback DRAFT copy items), `App/Sources/DiscreetSettingsView.swift`,
> `App/Sources/Dashboard/StreakRing.swift`, `Shared/Sources/StreakWidgetViews.swift`,
> `Tests/UITests/A11yAuditUITests.swift` (the settings-leg deferral comment),
> `docs/session-rules.md`.
> **This session:** STEP-0 rulings (the settings fix + motion = one golden batch; the widget
> typography = a separate one; budget the runs) → the settings large-title fix + re-add the audit
> leg → motion/polish → widget typography → reasons AX5 → golden-batch prep → verify → flag operator
> items.
> Budget: plan 2 billed runs + 1 contingency (rule the golden budget at STEP-0).
> **At session end (UIR-5b is the LAST UIR session):** append the Session 39 ledger, then this resume
> prompt hands off to the OPERATOR CRITICAL PATH (the UI regeneration is COMPLETE), update
> `docs/operator-expected.md`, `codegraph sync`, commit `[skip ci]`, push, `gh run watch` green
> (verify the conclusion via `gh run view --json` — the watcher's exit code lies).

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
