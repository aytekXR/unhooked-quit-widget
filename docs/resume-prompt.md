# Resume Prompt: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Resume Prompt v5.6 |
| Last updated | 2026-07-19 (**Session 41 — the autonomous build loop reached its TERMINAL STATE.** The build is INDEPENDENTLY VERIFIED green (a 5-agent audit RAN the free lanes: 121 tests pass — StreakEngine 84/WidgetToolkit 21/PaywallKit 16; all four grep lint gates clean; strict-concurrency clean; the last code CI run 29661516821 SUCCESS on all 9 jobs) and there is **NO remaining agent BUILD/FEATURE work** — every open item is operator/device/mac/future-gated (an adversarial fact-check confirmed the handoff is not premature). This was a **DOCS-ONLY, ZERO-billed-run operator-handoff-hardening pass**: NEW `docs/critical-path-post-uir.md` (the operator's single-page 11-step launch playbook + the consolidated Open-decisions table + the settings Mac-gate handoff) and `docs/copy-pass-checklist.md` (the §3 copy pass, file-by-file); FIXED `docs/review-notes.md` (removed a stale R30.6 "submission blocker" — CLOSED S31 — and two false "the user's own iCloud" sync claims that violated the doc's own register ban and would have pasted to Apple), the operator-expected "Runway to launch" paragraph (was still "step 1 = the UI Reactor, ~6 sessions"), and a 25-session-stale `8a0c469` tester-guide build ref. **R41.1:** the settings resources-row has an UNTRIED `.accessibilityHidden(true)` candidate modeled on the SAME screen's PASSING `iconRow` (`DiscreetSettingsView.swift:203`) — RECORDED for the Mac session, NOT authored (unverifiable without a Mac/billed run; touching an audited surface unverified is banned). **NO operator action was required this session; the project is BLOCKED on the operator critical path.** READ FIRST next session: `docs/critical-path-post-uir.md`. Superseded S40-addendum header below.) |
| _superseded_ | 2026-07-18 (Session 40 addendum — **the SETTINGS-CONTENT audit was attempted on CI (operator-requested) and is now DEFINITIVELY DEFERRED as MAC-GATED, with a complete diagnosis.** 5 CI runs (enumerate-all-from-one-run) fixed 2 of 3 defects — title (free-standing `.largeTitle` above the List, R39.2) and the long footer (moved out of the height-capped `footer:` slot into a self-sizing `captionRow`) — but the resources row ("Support & resources") is an unsolved **Button + wrapping-title Dynamic-Type conflict**: a native `Label` truncates (`.textClipped`); an `HStack{Image;Text}` clears the clip but breaks the native icon+title co-scaling (`.dynamicType` "partially unsupported"); a plain-`Text` row passes both but isn't a Button. Pinning it needs Xcode's Accessibility Inspector, not CI. Reverted to green (settings unchanged; 8 audited surfaces; 107 goldens stable). **This is the operator-dependency boundary: no further CI-doable UIR work remains.** Superseded S40-UIR-5c-complete header below.) |
| _superseded_ | (Session 40 — **UIR-5c substantively COMPLETE; the agent-doable UIR work (Epic 2.5) is DONE. The project is now fully operator-gated.** Four UIR-5c items landed this session, each verify-then-execute (a workflow sized to its risk): (1) **widget typography R34.7** (§3 numeral/label, 2 runs); (2) **reasons-frame AX5 R35.6** — at accessibility sizes the panic reasons step scrolls so the title stops truncating; pure layout + a double no-op for the rule-11 audit; 4 goldens re-recorded + visually verified (2 runs); (3) **`StreakRing` motion** — the `motion/calm` appear animation, opt-in + golden-safe (byte-identical settled draw; only the live dashboard animates), 1 run ZERO golden churn, animation flagged for a device eyeball; (4) **golden-batch prep** (`docs/golden-batch.md` — the ONE final re-record for the §3 sitting). DEFERRED: the settings-content audit (S39 iceberg — characterized; needs enumerate-all-findings-from-one-run / a local macOS run). **All lanes green; 107 goldens stable. The next steps are OPERATOR-owned** (see the operator critical path). Superseded S40-item-1 header below.) |
| _superseded_ | (Session 40 — **UIR-5c item 1: widget typography R34.7 DONE in exactly 2 billed runs, ZERO theory-failures.** brandkit §3 `type/widgetNumeral` (rectangular numeral 17→20pt Semibold monospaced) + `type/widgetLabel` (rectangular "saved" SPLIT out of the money line; medium savedLabel/milestoneLabel → 12pt Medium tracking +0.3), in `Shared/Sources/StreakWidgetViews.swift` (luminance-only, no Theme). An **8-agent verify+critique workflow (wf_df8c942c-94b) made run 1 correct on the first try** — it caught a BLOCKER 4/5 critics flagged that the first plan missed (line 168's rectangular "saved" bundled in a `.caption2` money string) and produced a surgical 9-golden delete-list. 9 goldens re-recorded + all VISUALLY VERIFIED (no clip; unavailable text 2-line wrap validates `.semibold`); 20 unchanged untouched (total 29). Flagged to operator: numeral `.semibold` vs `.bold`; medium labels fixed-12pt (no AX5 scaling). **Remaining UIR-5c (all INDEPENDENT): `StreakRing` motion, reasons-frame AX5 (R35.6), settings-content audit (S39 iceberg, deferrable), golden-batch prep.** Superseded S39 header below.) |
| _superseded_ | (Session 39 close: **UIR-5b attempt 1 — the SETTINGS audit leg is DEFERRED to its true depth; reverted to the UIR-5a green state (byte-identical, all 107 goldens restored, 8 audited surfaces intact).** Two billed runs bought the DIAGNOSIS, no net feature. **R39.1:** a title in a LIST ROW clips exactly like the nav bar (a row is height-constrained) — `.dynamicType`/`.textClipped` fire on it. **R39.2:** a FREE-STANDING `.largeTitle` `Text` ABOVE the List FIXES the title (proven), but the audit then flags the settings LIST CONTENT — the long haptic-pacer SECTION FOOTER clips at AX5, and it uses NO explicit font (List's default scalable footnote): **List SECTION FOOTERS clip at accessibility sizes, a STRUCTURAL issue, not a font fix.** Deferred because completing it (move every long footer out of the `footer:` slot + re-record goldens) is unknown-depth whack-a-mole at 1 billed run/iteration on a polish surface — a future pass must enumerate ALL findings from ONE run (or a local macOS run) and fix wholesale. **The fix is now KNOWN on both axes** (title: free-standing text above the List; content: footers out of List slots). Also logged: `[skip ci]` in a commit BODY (not just the subject) skips the run — never write the literal token unless you mean it. Superseded S38 header below.) |
| _superseded_ | (Session 38 close: **UIR-5a DONE in exactly 2 billed runs — the deferred audit legs + the Monetization lint scope.** The **PAYWALL** joins the audited surfaces — `test_a11yAudit_paywall` (UITEST_PAYWALL_DIRECT → the hard-variant fixture) passed the FULL 7-type set CLEAN on its first run; the a11y audit now covers **8 surfaces** (age gate, quiz, summary, dashboard, panic, slip, resources, paywall). `App/Sources/Monetization` joined the layout-lint scope (48 files, floor 12 → 35, born-green; the inline retry `.plain` → the pass-through `PlanCardButtonStyle`). No goldens (audits mint none; the lint growth is born-green) — all 107 goldens byte-stable. **R38.2 = the SETTINGS audit leg is DEFERRED:** its run-1 `.dynamicType`+`.textClipped` fired on the navigation-bar LARGE TITLE ("Discreet Mode", NavigationBar/LargeTitle — a SYSTEM behavior, not the themed content), so the fix is a custom/`.inline` title (which re-records the settings golden), owned by UIR-5b. Run 1 also carried an UNRELATED erase-debounce unit FLAKE (passed in S37; resolved on run 2). **UIR-5b (motion/polish + the settings large-title fix + widget typography + reasons AX5 + golden-batch prep) is the LAST agent-doable UIR work.** Superseded S37 header below.) |
| _superseded_ | (Session 37 close: **UIR-4b DONE in exactly 2 billed runs — UIR-4 FULLY COMPLETE.** `DiscreetSettingsView` moved onto the Theme layer via in-place List theming (`.scrollContentBackground(.hidden)` + surface/base backdrop + `.listRowBackground(surface/raised)` per Section + `.tint(brand/primary)` + Theme text tokens), keeping List's native cell accessibility; 2 goldens minted (105 → 107), golden visually verified. Deferred to UIR-5: the settings/paywall audit legs + the Monetization lint scope + full settings golden coverage. **Every screen in the build is now regenerated onto the design system.** Superseded S36 header below.) |
| _superseded_ | (Session 36 close: **UIR-4a DONE in exactly 2 billed runs** — the two DEFECT surfaces regenerated: **RESOURCES** (safety) — `.background(.quaternary)` → `themedCard`, the R33.10 DIAL link (44pt floor + "Call <name>" label), 2 goldens + a new audit leg that passed the full 7-type set CLEAN on run 1 (the THIRD consecutive clean first-audit); **PAYWALL** — 3 R32.9 disabled-`.plain` fixes (`PrimaryButtonStyle`/`QuietButtonStyle` + the new pass-through `PlanCardButtonStyle`) + a pre-existing caution-on-caution contrast bug, no goldens (draft copy, verified by the QuizFunnelUITests smoke). **SETTINGS DEFERRED to UIR-4b** (the List→ScrollView restyle — the biggest structural risk, cleanly separable; full spec preserved in `scratchpad/uir4-step0.md` + workflow journal wf_b91f1762-aff). New contrast pair (34 total, Linux-verified). **R36.4 = the mount-gate lesson: a full-screen `.accessibilityElement(children: .contain)` container id does NOT surface as a queryable element (unlike a bounded card) — gate an audit leg on a real CHILD element.** Superseded S35 header below.) |
| _superseded_ | (Session 35 close: **UIR-3 DONE in exactly 2 billed runs** — the panic + slip flows (rule-11 SAFETY surfaces) are regenerated on the Theme layer with a PM+Brand+QA pre-code sign-off, copy byte-identical. **The `.dynamicType`/`.textClipped` exclusion list is CLOSED to ZERO** — all 8 `minHeight: 56` floors became growing PADDING (the exact S28 mechanism), `StepScaffold`/`confirmStage` scroll with pinned actions (R33.5), the reasons text moved off a `@ScaledMetric` point size onto `.largeTitle` (R33.12), both audit legs joined the full 7-type set and `safetyAuditTypes` is deleted. **The rule-11 panic/slip legs passed CLEAN on run 1** (the SECOND consecutive clean first-audit — the ledger a prior run wrote is the current run's free coverage). 64 class-A goldens re-recorded + visually verified; total unchanged at 103. STEP-0: did NOT grow the lint scope to panic/slip (would force a shape-changing `.buttonStyle(.plain)` refactor on safety surfaces — the full-set audit legs are the gate instead; deferred to UIR-5). Carried: the reasons-frame AX5 title truncation (R35.6, a UIR-5 AX-axis item) and the `.plain`→ButtonStyle refactor. Superseded S34 header below.) |
| _superseded_ | (Session 34 close: **UIR-2 DONE in exactly 2 billed runs** — the 2 planned, contingency UNUSED, ZERO burned. The **real `StreakDashboardCard` + `StreakRing`** are built on the Theme layer — the `RootPlaceholderView` "walking skeleton" that had stood in for the dashboard since Session 18 is RETIRED, replaced by one card per active quit (streak-day hero, flame + momentum figure, the momentum ring, money saved, next-milestone bar). **Copy is byte-identical** (R34.2, copyBlockerFound=FALSE): every string is audited (`"saved"`/`"next milestone"`, pinned byte-identical to `StreakWidgetStyle`) or pure ADR-11 data; the §3-blocked polish strings ship empty-guarded. **The dashboard is AUDITED FOR THE FIRST TIME and its first audit passed CLEAN** (R34.3) — the first UIR surface to fire nothing, because R33.12 was already known and the card was built to it from the first byte (the free layout lint pre-empted every `.dynamicType` idiom; `children:.contain` + 4.5-clean tokens pre-empted the rest). **Widgets were DEFERRED at STEP-0** (R34.7): the 5 families are on-spec bar two minor brandkit-§3 typography defects; `StreakWidgetViews.swift` was UNTOUCHED so the 29 widget goldens stay byte-stable and no golden churn entered the budget. 8 dashboard goldens minted (95 → 103); the a11y exclusion list did not shrink this session (panic + slip remain, UIR-3's job).) |
| Phase | **Phase 2.5 (UI Reactor) COMPLETE for everything an agent can do; the project is on the OPERATOR CRITICAL PATH.** UIR-0…4 DONE; UIR-5a DONE (8 audited surfaces); UIR-5c DONE (widget typography R34.7, reasons AX5 R35.6, StreakRing motion, golden-batch prep). ONE UIR item is MAC-GATED (the settings-content audit — S40 confirmed after 5 CI runs). **Session 41 verified the whole build is genuinely green and did a docs-only operator-handoff-hardening pass — there is no remaining agent build/feature session to run.** What remains is all operator-owned (G0 rename, §3 copy pass + the golden batch, §8 keys + sandbox, device rows + E0.3 latency + the device eyeballs, external beta, submission) — sequenced in `docs/critical-path-post-uir.md`. All lanes green; 107 goldens stable. |
| Next session objective | **There is NO agent build work to do — the project is OPERATOR-GATED (verified by a 5-agent audit + fact-check in S41).** If a future agent session opens, its job is NOT to invent build work. It is: (1) confirm the build is still green (`git fetch`; `gh run list`; the operator commits mid-session); (2) check whether the operator has UNBLOCKED anything since — e.g. finished the §3 copy pass (→ mint the final golden batch per `docs/golden-batch.md`), pasted a §8 key, said "go" on either "say the word" item (the account-absence lint / the encryption plist key), or made an open decision that needs an agent re-pin (OQ-1, OQ-2); act ONLY on genuinely-unblocked items; (3) otherwise, report that the project remains blocked on the operator critical path and stop. **Do NOT re-attempt the settings-content audit on CI** (proven unproductive on the tail); it is a Mac session that tries the R41.1 `.accessibilityHidden` candidate FIRST. Read `docs/critical-path-post-uir.md` before anything. |

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
  the label is code-derived/wire-verify-pending (§8 app ID); the settings-content
  audit is MAC-GATED (R41.1 — the `.accessibilityHidden` candidate to try first); the
  dashboard frozen-tooltip / reduce-framing / composed-a11y polish (all §3-blocked) —
  named, ride the founder pass / a Mac session. **CLEARED this session (were stale):
  `SafetyResourcesView`'s `.quaternary` fill + phone-number-only `Link` (fixed S36 —
  now `.themedCard()` + "Call <name>"); the widget typography defects R34.7 (done S40).**

## Next session objective — TERMINAL STATE: the agent build loop is COMPLETE; the project is OPERATOR-GATED

**Session 41 verified (5-agent audit + fact-check) that there is NO remaining agent build/feature work
and the build is genuinely green.** Every open item is operator/device/mac/future-gated. **If an agent
session opens, do NOT invent build work.** The objective is:
1. **Confirm still-green + pick up operator commits:** `git fetch`; `gh run list`; read any new operator
   commits (they commit mid-session). If the operator asks for something specific, that overrides this.
2. **Act ONLY on genuinely-unblocked items.** The unblock triggers and their agent actions:
   - §3 copy pass finished → mint the FINAL golden batch (`docs/golden-batch.md`; NEW goldens are
     red→adopt-from-artifact→green, VISUALLY VERIFIED — never born-green).
   - A §8 key pasted → the wake-up is the operator's; an agent only acts if a specific follow-up is asked.
   - Operator says "go" on a "say the word" item → land the account-absence grep lint (born-green, free
     Linux) and/or `ITSAppUsesNonExemptEncryption=false` in project.yml.
   - An open decision resolved (OQ-1 / OQ-2) → the one agent re-pin run it names.
3. **Otherwise:** report that the project remains blocked on the operator critical path and stop. Do NOT
   manufacture make-work or re-attempt the settings-content audit on CI (proven unproductive on the tail).
4. **The settings-content audit is a MAC session** — try the R41.1 `.accessibilityHidden(true)` candidate
   on `resourcesRow` FIRST (modeled on the passing `iconRow`, `DiscreetSettingsView.swift:203`); it was NOT
   authored here because it can't be verified without a Mac/billed run and touching an audited surface
   unverified is banned. Full handoff in `docs/critical-path-post-uir.md`.

**Read `docs/critical-path-post-uir.md` FIRST** — it is the operator's sequenced playbook and the single
source of truth for what remains.

---

_The UIR-5c section below is the Session 40 ARCHIVE (every item DONE — widget typography R34.7, reasons
AX5 R35.6, StreakRing motion, golden-batch prep; the settings-content audit MAC-GATED). Retained for
reference; not a live objective._

### [ARCHIVE] Session 40 — UIR-5c: the remaining UIR polish (all DONE)

UIR-0…4 + UIR-5a are DONE; UIR-5b (S39) deferred the settings audit leg. The items below were INDEPENDENT;
each was its own red→adopt→green golden batch.

1. **Session-open checks:** the standing three-way operator check + `which uipro`.

2. **Widget typography (R34.7): ✅ DONE (Session 40, 2 billed runs, zero theory-failures).** Rectangular
   numeral → `.system(size: 20, weight: .semibold).monospacedDigit()`; rectangular money+"saved" SPLIT
   (money mono, "saved" 12pt Medium tracking); medium savedLabel/milestoneLabel → 12pt Medium tracking
   +0.3. 9 goldens re-recorded + visually verified. An 8-agent verify+critique workflow caught the
   line-168 blocker up front. Flagged to operator: numeral `.semibold` vs `.bold`; medium labels
   fixed-12pt. Original plan (banked for reference): the EXACT spec + call-site map was
   (`docs/frontend-brandkit.md` §3 lines 124–125: `type/widgetNumeral` rectangular ~20pt /
   circular ring-center ~17pt / **Semibold–Bold** / monospaced digits — SF Compact, NOT rounded (§3
   line 110: rounded is dashboard-numeral-only); `type/widgetLabel` ~12pt / **Medium** / **tracking
   +0.3**). File `Shared/Sources/StreakWidgetViews.swift` (luminance-only, NEVER Theme; point sizes are
   the INTENDED widget form — Shared/Sources is outside the lint scope + widgets aren't audited). The
   THREE call sites (small/medium numerals already exceed 20pt via `.title2.bold` — do NOT touch them):
     - **line 165** `rectangular`: `primaryDayLine(font: .headline)` → `.system(size: 20, weight:
       .semibold).monospacedDigit()`. Affects `rectangularFamily{,_discreet}.{light,dark}` = **4
       goldens** (rectangular has NO ax5).
     - **line 238** medium `savedLabel`: `.caption2` → `.system(size: 12, weight: .medium).tracking(0.3)`.
     - **line 244** medium `milestoneLabel`: same as line 238.
       Medium labels affect `mediumFamily{,_discreet}.{light,dark,light-ax5,dark-ax5}` = up to **8
       goldens** (discreet-medium hides money→savedLabel; confirm from `StreakWidgetSnapshotTests`
       whether discreet renders `milestoneLabel` before deleting its goldens — delete ONLY the ones
       that actually change, ~8–12 total). Do NOT change label TEXT/case (copy, operator-owned).
       Weight `.semibold` vs `.bold` on the lock-screen numeral is a §3-range judgment (both comply;
       §3 says "heaviest that fits") — FLAG the choice to the operator. Maneuver: edit → `git rm` the
       changed goldens → run 1 record→red → `gh run download <id> -n test-outputs` → VISUALLY VERIFY
       each (bigger rectangular numeral; tracked medium labels; nothing else moved) → adopt → run 2 green.

3. **`StreakRing` motion (`Dashboard/StreakRing.swift`)** — golden-safe ONLY if the snapshot captures
   the SETTLED frame. RISK: an `.onAppear`-triggered animation renders the FIRST frame unsettled →
   breaks dashboard goldens. Structure it so the DEFAULT render is settled (e.g., gate the animation
   off under snapshot/reduce-motion, or animate a property identical at rest). Verify the 8 dashboard
   goldens do NOT move (they must stay byte-stable). Defer if it can't be made deterministic.

4. **Reasons-frame AX5 title (R35.6)** — the panic reasons title truncates at AX5 (a paging→scroll
   treatment). NOTE: panic is a rule-11 AUDITED leg (passed clean S35), so this is the NON-audited
   title truncation; fixing it likely re-records the panic `*ax5*` goldens — budget + visually verify.

5. **The SETTINGS-CONTENT audit [OPTIONAL/deferrable — the S39 iceberg].** If attempted: title =
   free-standing `.largeTitle` `Text` ABOVE the List (R39.2, PROVEN — never a List row); content = move
   the long List SECTION FOOTERS (e.g. the haptic-pacer footer) OUT of the `footer:` slot into scalable
   in-content rows. **ENUMERATE ALL findings from ONE audit run (or a local macOS run) BEFORE fixing** —
   do NOT whack-a-mole (S39 spent 3 runs discovering the depth). Re-adds the audit leg + re-records the
   2 settings goldens. A breadcrumb with this exact plan sits at the site in `DiscreetSettingsView`.

6. **Golden-batch PREP** for the operator §3 sitting (the final onboarding+paywall re-record waits on
   the founder copy pass — do NOT mint them; prepare the list). Zero-run documentation.

7. **Constraints:** copy BYTE-IDENTICAL; DORMANT monetization canon; widgets luminance-only (never
   Theme); no privacy surface. NEW STANDING NOTE (S39): never write `[skip ci]`/`[ci skip]` ANYWHERE in
   a commit message (body included) unless you intend the skip — GitHub honors it anywhere; docs/**` +
   `**.md` are already `paths-ignore`d so docs commits never run CI regardless.

**After UIR-5c the agent-doable UIR work is COMPLETE and the project is BLOCKED on the operator
critical path** (G0 rename, §3 copy pass, §8 keys + sandbox matrix, device rows + E0.3 latency,
external beta, submission) — see the operator-owned blockers below.

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
> `com.beyondkaira`). **The whole build side is agent-complete and the project is OPERATOR-GATED.**
> Sessions 0–31 built the functional app; Sessions 32–40 (Epic 2.5, the UI Reactor) regenerated every
> screen onto the design system; Session 41 INDEPENDENTLY VERIFIED the build is green (121 free-lane
> tests pass; all lint gates clean; last code CI run SUCCESS) and confirmed via a 5-agent audit +
> fact-check that **there is NO remaining agent build/feature work** — every open item is
> operator/device/mac/future-gated. 8 surfaces are a11y-audited; all lanes green; 107 goldens stable;
> TestFlight live.
> **READ FIRST: `docs/critical-path-post-uir.md`** — the operator's sequenced launch playbook (the 11
> steps, the Open-decisions table, the settings Mac-gate handoff, the two "say the word" agent items).
> **DO NOT invent build work. DO NOT re-attempt the settings-content audit on CI** (S40 proved the tail
> unproductive; it is a Mac session — try the R41.1 `.accessibilityHidden(true)` candidate on
> `DiscreetSettingsView.resourcesRow` FIRST, modeled on the passing `iconRow` at `:203`).
> Local Swift toolchain: `. ~/.local/share/swiftly/env.sh`.
> **Session-open:** `git fetch` + `gh run list` (the operator commits mid-session); note anything the
> operator has unblocked. `which uipro` if any (now-unlikely) UI work is requested.
> **Your objective is conditional:** act ONLY on genuinely-unblocked operator triggers — (a) §3 copy
> pass finished → mint the FINAL golden batch (`docs/golden-batch.md`; NEW goldens are
> red→adopt-from-artifact→green, VISUALLY VERIFY each PNG, NEVER born-green); (b) operator says "go" on
> a "say the word" item → the account-absence grep lint (born-green, free Linux) or
> `ITSAppUsesNonExemptEncryption=false` in project.yml; (c) an open decision resolved (OQ-1/OQ-2) → the
> one agent re-pin run it names. **Otherwise: report the project is blocked on the operator critical
> path and stop — do not manufacture make-work.**
> **Standing gates (still in force for ANY code touched):** CodeGraph query-first + `codegraph sync` at
> close; `swiftc -parse` every touched file + neighbor import/annotation coverage + the deprecation gate
> + per-member platform availability; the FIVE burn gates (incl. `try?`-flatten); UIKit app-only APIs
> never enter Shared/Sources; access-level scan + Linux harness RUN empirically ×3 TZ; JSON pins key-SET;
> docs-only commits `[skip ci]`; check the STAGED set (the settings.json subagent pin never rides a
> feature commit); critics WRITE findings to files; NEVER `git stash`; `git fetch` before every push;
> app-lane red evidence = the CI run — NEW snapshot goldens are red→adopt-from-artifact→green (VISUALLY
> VERIFY each PNG), NEVER born-green; the panic route NEVER queries entitlements/teaser/winback; a rule-11
> SAFETY leg is NEVER pre-suppressed on a prediction; golden-shift valves calibrate on the TOLERANCE
> FLOOR; artifact-first diagnosis before ANY billed hypothesis run; every multi-step UI drive verifies
> each tap TOOK; copy stays BYTE-IDENTICAL (§3 founder-owned). PLUS the Theme rules (every color rides
> `Theme`; every new fg/bg pair enters `Theme.contrastPairs` in the same diff; the ghost disabled form;
> no raw `.white`; widgets luminance-only, NEVER Theme) and the **R33.12 Dynamic-Type contract** (text =
> TEXT STYLES only; no `ViewThatFits`; point sizes only on decorative `Image`s; content scrolls, actions
> pin; the AX-size pivot reads `isAccessibilitySize`). **R38.2: a navigation-bar LARGE TITLE fires
> `.dynamicType`/`.textClipped` to the audit — use `.inline` or a custom Theme title on any audited
> screen. R41.1: an audited Button row's decorative icon must be `.accessibilityHidden(true)` so the
> element's label stays pure scalable text (the passing `iconRow` pattern).**
> READ (as needed): `docs/critical-path-post-uir.md` (FIRST), `docs/copy-pass-checklist.md`,
> `docs/operator-expected.md` (§3 copy, §7 device, §8 keys, the veto list), `docs/golden-batch.md`,
> `docs/submission-checklist.md`, the Session 41 + 40 ledgers in `docs/past-prompts.md`,
> `docs/session-rules.md`, and — only if the relevant work is actually unblocked — `docs/design/
> tokens-v2.md`, `App/Sources/DiscreetSettingsView.swift`, `Tests/UITests/A11yAuditUITests.swift`.
> **At session end (whether or not anything was unblocked):** update `docs/operator-expected.md` +
> `docs/critical-path-post-uir.md`, append a ledger entry to `docs/past-prompts.md`, regenerate this
> resume prompt, `codegraph sync`, commit `[skip ci]`, push. If a billed run WAS spent (a genuinely
> unblocked code item), `gh run watch` green and verify via `gh run view --json` (the watcher's exit
> code lies).

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
