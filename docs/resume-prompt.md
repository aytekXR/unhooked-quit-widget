# Resume Prompt: Unhooked — The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Resume Prompt v4.5 |
| Last updated | 2026-07-14 (Session 32 close: **UIR-0 DONE in exactly 2 billed runs** — the 2 planned, contingency UNUSED, ZERO burned. The Theme layer (`App/Sources/DesignSystem`: data-first `ColorToken` registry + `ContrastMath` + `ThemeMetrics` + 5 primitives) is the app's single color source; all 12 view files swapped in-place onto the machine-verified tokens-v2 palette (5 LIGHT hexes drift-corrected from brandkit §2 — R32.7; DARK canon clean); **`.contrast` RESTORED to the a11y audit on all three legs** — the R28.13 exclusion list SHRANK for the first time; 64 panic/slip goldens re-recorded from the run-1 artifact (the 2 stale hapticsOnly goldens close); 31 class-B goldens byte-stable as predicted; TWO permanent unit gates born-green (`ThemeContrastTests` 30-pair registry ×2 modes + `ThemeSourceLintTests` retired-idiom ban). R32.9 was the session's real discovery: **Apple's `.contrast` audit DOES inspect disabled controls, and `.buttonStyle(.plain)` auto-dims a disabled label to ~50% opacity ON TOP of any foregroundStyle** (artifact-measured 2.14:1 against an authored 5.89) — the ghost CTAs now ride `PrimaryButtonStyle`. **The §9 uipro discrepancy is RESOLVED** — uipro v2.11.0 IS on the box as an npm CLI on PATH; the S31 probes searched skills/plugins/MCP, not PATH binaries; its skill is gitignored and it was driven as the UIR-0 generator with canon overrides recorded in tokens-v2 §8. The session was killed by the operator after run 2 went green but before the docs-close commit; the close was reconstructed from artifacts + on-disk drafts with zero re-spent runs.) |
| Phase | Phase 2.5 (UI Reactor): pre-UIR build 100% DONE; **UIR-0 DONE**; UIR-1…UIR-5 remain; everything else operator-gated |
| Next session objective | **Session 33: UIR-1 — onboarding: age gate + quiz + consent step + summary, redesigned on the UIR-0 system (primitives adopted, type/spacing tokens adopted, the quiz frames' `.dynamicType`/`.textClipped` debt closed)** |

> **What changed in Session 32:** the design system exists in code. Every later UIR
> session consumes `Theme` + the primitives and re-records only its own surfaces'
> goldens. Full ledger: Session 32 in `docs/past-prompts.md` (R32.1–R32.9).

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
   pattern — S29/S30/S31/S32 ran it red→green as an EXECUTED harness, the
   stronger form). (b) **qualified-name** — a Darwin-only file's NON-SDK
   qualified type references get Linux-PROBED before push; both-SDK files use
   the bare-name-exact typealias, NEVER the module-qualified form. (c)
   **non-Sendable SDK results:** a nonisolated async SDK call whose result
   type is not Sendable CANNOT return into a @MainActor conformance under
   strict flags (sanctioned fix: `@preconcurrency import`, sole-importer
   file). (d) **lint anchors admit attributes WITH parenthesized arguments:**
   import-anchored grep lints use `^(@[A-Za-z_]+(\([A-Za-z_]+\))? )*import …`
   (S29: `@_spi(Internal) import` would dodge the paren-less atom).
4. **Access-level gate + empirical harness:** scan for private types in
   non-private signatures, and RUN (never just typecheck) a Linux scratch
   harness over the exact shipping bytes of every pure-Foundation/PaywallKit/
   DesignSystem-data API — probe the BOUNDARY, under MULTIPLE HOST TIMEZONES
   (the standing set: UTC/Berlin/Kiritimati). JSON pins use JSONSerialization
   key-SET semantics — and (S31) plist pins use PropertyListSerialization
   key-SET semantics — never byte/string equality. The free package lane runs
   `swift test` WITHOUT warnings-as-errors — close the gap pre-push with
   `swift build --build-tests -Xswiftc -strict-concurrency=complete
   -Xswiftc -warnings-as-errors --package-path Packages/<pkg>` (or the
   scratch harness for app-side pure subsets).
5. **Docs-check gate:** every Darwin-only / AppIntents / WidgetKit / SwiftUI /
   SF-Symbol / third-party member spelling verified against official docs
   BEFORE code (`developer.apple.com/tutorials/data/documentation/<path>.json`;
   SDK repos' tagged raw source for third-party) — AND per-member platform
   availability (#5b). **S31 proof-of-worth: the docs-check corrected the
   carried CA92.1 assumption (App-Group = 1C8F.1) and kept
   mach_continuous_time OUT of the manifest. The privacy manifests re-derive on
   ANY UserDefaults/timestamp/boot-time/disk-space/keyboard API addition — the
   pin fires on manifest drift, but the SWEEP must rerun whenever such an API
   enters a diff.** **S32 rider: docs CONFIRM existence + availability, they do
   NOT describe rendered behavior** — `.buttonStyle(.plain)`'s disabled
   auto-dimming is undocumented and only the run artifact revealed it (R32.9).
   When a claim is about PIXELS, measure pixels.
6. Docs-only commits carry `[skip ci]`; never spawn agent workflows for
   docs-only changes. Critic/reader agents Write findings to scratchpad files
   and return a one-line pointer (permanent — it has now paid for itself THREE
   times; S32's killed session was reconstructed entirely from those files).
   **The S30 monthly-spend-limit constraint is LIFTED (S31-verified); fan-outs
   are available. If a fan-out dies mid-session, salvage from the seats' files
   and finish inline (the S30 playbook).**
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
   billed runs). **The born-green ruling (R31.4) extends beyond the audit class
   when — and only when — the designed red's ENTIRE evidence value is
   reproduced free (executed harness: pass-on-real-bytes + fire-on-mutation/
   absence) AND the green run's own results prove the new tests executed;
   record the split if seats disagree.** A schema/shared-pass change sweeps the
   FUNCTION-level blast radius of every pin on it. NEW SPM deps land in the
   GREEN commit, never red (R24.8). The golden-rides-red maneuver (R27.12) +
   deleted-reference record-missing re-records (S28/R32.4: `record: .missing`
   on a DELETED reference WRITES-then-FAILS — born-green run 1 is IMPOSSIBLE
   for shifted goldens; keep-and-diff yields no adoptable PNG) stand.
   Golden-shift valves calibrate on the TOLERANCE FLOOR. xcresult artifacts are
   FULLY readable on the Linux box (the S29 fileBacked2 token parser) —
   artifact-first diagnosis before ANY billed hypothesis run. Every multi-step
   UI drive verifies each tap TOOK (R29.10).

### S32 additions (permanent, UIR-era)

- **The Theme layer is load-bearing:** every color in App/Sources rides `Theme`
  (`ThemeSourceLintTests` bans the retired idioms — comment-stripped, grow-only);
  every NEW fg/bg pair a view introduces gets a `Theme.contrastPairs` entry in the
  SAME diff (the registry is the R28.13 by-construction gate; growing the palette
  is a deliberate two-place edit pinned by key-set). The GHOST disabled treatment
  (contentSecondary on surfaceSunken) is the standing disabled form — NEVER
  alpha-dimmed fills. Raw `.white`/`Color.white` on fills is BANNED (the dark-mode
  1.99:1 defect class).
- **Disabled controls are audited (R32.9):** Apple's `.contrast` audit inspects
  them, and `.buttonStyle(.plain)` composites a disabled label at ~50% opacity over
  any explicit `foregroundStyle`. A disabled CTA therefore MUST ride a custom
  ButtonStyle (`PrimaryButtonStyle`), never `.plain`. Any new disabled-state control
  gets its rendered pixels checked, not just its authored tokens.
- **`.dynamicType` / `.textClipped`** stay excluded from the audit UNTIL each owning
  surface's UIR session closes its frames (quiz→UIR-1, slip→UIR-2, panic→UIR-3).
  Restoring a class = deleting the exclusion AND fixing what fires. The exclusion
  list may now only SHRINK.
- **uipro:** present as an npm CLI (`which uipro`; rides nvm's node v20.20.2). Its
  skill lives at `.claude/skills/` (gitignored; reinstall with `uipro init -a claude`
  if absent). Use its domain searches as generator input; the brandkit + tokens-v2
  canon OVERRIDE it wherever they conflict (its palettes ship a banned red
  destructive token; its type advice assumes Google Fonts, not our SF-only rule).

## Where we are

- **The pre-UIR build side is 100% DONE:** the M1 loop, the widget suite, the
  DORMANT monetization vertical, the safety layer, the accessibility layer, the
  machine-proven funnel E2E, the signed win-back seam (IAP-key-gated), the
  submission package's build half, and the required-reason privacy manifests for
  BOTH executables with permanent key-set pins.
- **Phase 2.5 — Epic UIR "UI Reactor" (roadmap v1.1 §2.5, operator-mandated):**
  **UIR-0 DONE (S32).** Remaining: UIR-1 onboarding → UIR-2 dashboard+widgets →
  UIR-3 panic+slip → UIR-4 paywall+settings+resources → UIR-5 motion+AX5+
  golden-batch prep. Binding constraints live in roadmap §2.5: copy BYTE-IDENTICAL
  (§3 founder-owned), no red anywhere, a11y only strengthens, privacy surfaces
  untouched, ADR-6 panic latency, safety surfaces keep the stricter pre-code
  sign-off loop, goldens re-record per-session from run artifacts, the operator's
  §3 batch stays ONE final re-record.
- **StreakEngine 1.2.0 / WidgetToolkit 1.1.0 / PaywallKit 1.0.0 untouched.**
  purchases-ios 5.80.3 + SuperwallKit 4.16.1 + SnapshotTesting 1.19.3 +
  TelemetryDeck 2.14.1 exact-pinned. TestFlight LIVE (Session 32 build).
- **Carried debts (all named):** OQ-1 (displayLabel) + OQ-2 (label taxonomy, with
  the R31.5 manifest-lockstep rider) awaiting the operator; R29.4 (startIfNeeded
  no-retry); the quiz chips' 14pt-vs-pill drift (closes in UIR-1); brandkit §2 prose
  still carries pre-correction hexes (tokens-v2 is the record; a brandkit edit is
  founder-owned); tight watch pairs tertiary-on-sunken 3.11 L / primary-text-on-tint
  4.72 L (registry-pinned, passing); scenario-30 purchase-leg E2E (sandbox tier);
  MVP §7 a11y box honestly UNCHECKED (UIR-5 + §7 device work close it); the label is
  code-derived/wire-verify-pending (§8 app ID).

## Next session objective (one session, definition of done below)

**Session 33 — UIR-1: onboarding** (age gate + quiz + consent step + summary):

1. **Session-open checks:** the standing three-way operator check + `which uipro`.
2. **Redesign onboarding ON the UIR-0 system:** adopt the primitives
   (`PrimaryButton`/`QuietButtonStyle`/`AnswerChipStyle`/`ThemedProgressBar`), adopt
   the type/spacing tokens (`ThemeMetrics`), apply brandkit §6.4/§6.6/§6.7 shapes,
   and close the quiz frames' `.dynamicType`/`.textClipped` findings.
3. **Constraints:** copy bytes BYTE-IDENTICAL (§3); the consent step's equal-choice
   rule (E8.2) and the age gate's zero-analytics/byte-frozen rules hold
   structurally; every new fg/bg pair enters `Theme.contrastPairs` in the same diff.
4. **Goldens:** onboarding surfaces have NO goldens today — decide at STEP-0 whether
   UIR-1 mints them (named-slot budget!) or rides the audit + unit pins only.
5. **NOT this session:** dashboard/widgets (UIR-2), panic/slip (UIR-3), paywall/
   settings/resources (UIR-4), motion (UIR-5), any copy byte, any privacy surface.
0. STEP-0 candidates: (a) quiz-leg DT closure mechanics — the audit runs ONE
   auditTypes set for all legs, so a per-leg restore needs a split or a full fix;
   (b) golden-minting policy for onboarding; (c) primitive adoption order;
   (d) AX5 stacked-layout rules for the summary hero.

At close: overwrite this prompt for UIR-2; the UIR ledger grows R33.x.

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
4. GitHub Actions billing headroom (§4 — Session 32 used exactly 2). The Claude
   monthly spend limit is LIFTED (S31-verified); fan-outs available.
5. TestFlight testers (§5) — carried; the funnel E2E is machine-proven.
6. TelemetryDeck app ID (§8) — carried; gates the label/manifest wire-verify.
7. **§8 keys + config:** RevenueCat key → Superwall key + dashboard → ASC
   promotional offer + In-App Purchase Key → the App Privacy label ENTRY
   (docs/app-privacy-label.md; OQ-2 first — NOTE R31.5: the ASC label and the
   shipped manifest's collected-data half are in LOCKSTEP; if counsel repicks the
   taxonomy, one session updates label doc + manifest + pin together) + the
   privacy-policy text. All sequenced at sandbox-matrix time.
8. *(struck — S31: the monthly-spend-limit item is closed)*
9. *(struck — S32: uipro FOUND on PATH, driven as the UIR generator; nothing needed)*

## Resume prompt (copy-paste for next session)

> You are the lead build agent for **unhooked-quit-widget** (app name **Ballast**,
> org `com.beyondkaira`). Session 32 is CLOSED (exactly 2 billed runs = the 2
> planned, contingency UNUSED, ZERO burned; UIR-0 DONE — the Theme layer + tokens-v2
> + the themed primitives + the WCAG-clean palette; `.contrast` RESTORED to the a11y
> audit on all three legs; 64 goldens re-recorded from the run-1 artifact; R32.9: the
> `.plain`-auto-dims-disabled-labels discovery; uipro FOUND on PATH and driven as
> generator). **Session 33 = UIR-1: onboarding (age gate + quiz + consent + summary)
> redesigned on the UIR-0 system — primitives + type/spacing tokens adopted, the quiz
> frames' `.dynamicType`/`.textClipped` debt closed, copy bytes byte-identical.**
> Local Swift toolchain: `. ~/.local/share/swiftly/env.sh`.
> **Session-open:** the three-way operator check + `which uipro`.
> **Standing gates:** CodeGraph query-first + `codegraph sync` at close; `swiftc
> -parse` every touched file + neighbor import/annotation coverage + the deprecation
> gate + #5b per-member platform availability; the FOUR burn gates (rule #3); UIKit
> app-only APIs never enter Shared/Sources; access-level scan + Linux harness RUN
> empirically ×3 TZ; JSON pins key-SET (plists via PropertyListSerialization);
> docs-only commits `[skip ci]`; check the STAGED set; critics REPRODUCE under
> `-strict-concurrency=complete -warnings-as-errors` and WRITE findings to files;
> NEVER `git stash`; `git fetch` + `git log origin/main` before every push; app-lane
> red evidence = the CI run on the red commit — born-green ONLY when the red's entire
> evidence value is reproduced free AND the green run proves the tests executed
> (R31.4); the panic route NEVER queries entitlements/teaser/winback; audit tests
> never enter a red manifest; golden-shift valves calibrate on the TOLERANCE FLOOR;
> a11y tests on safety paths may never be quarantined; artifact-first diagnosis
> before ANY billed hypothesis run; every multi-step UI drive verifies each tap TOOK
> (R29.10); copy stays BYTE-IDENTICAL through every UIR session (§3 founder-owned);
> any new UserDefaults/timestamp/boot/disk/keyboard API in a diff re-runs the S31
> manifest sweep (rule #5). PLUS the S32 Theme rules: every color rides `Theme`
> (lint-enforced); every NEW fg/bg pair enters `Theme.contrastPairs` in the same
> diff; the ghost disabled form (never alpha-dimmed, never `.plain` on a disabled
> CTA); no raw `.white` on fills; `.dynamicType`/`.textClipped` stay excluded until
> each surface session closes its frames (the list may only SHRINK).
> READ FIRST: the Session 32 ledger (R32.1–R32.9) in `docs/past-prompts.md`,
> `docs/design/tokens-v2.md`, `docs/roadmap.md` §2.5, `docs/frontend-brandkit.md` §6
> (components) + §8, the S28 ledger's DT/clipping finding list, `docs/operator-
> expected.md` §3, `docs/session-rules.md`.
> **This session:** STEP-0 rulings (a)–(d) → the onboarding redesign on the UIR-0
> system → verify → flag operator items.
> Budget: plan 2 billed runs + 1 contingency (the goldens decision at STEP-0 may
> change this).
> **At session end:** append the Session 33 ledger, overwrite this resume prompt
> (UIR-2), update `docs/operator-expected.md`, `codegraph sync`, commit `[skip ci]`,
> push, `gh run watch` green (verify the conclusion via `gh run view --json` — the
> watcher's exit code lies).

## Standing rules reminders (do not relearn these)

- **Theme canon (S32, NEW):** `docs/design/tokens-v2.md` IS the palette record
  (brandkit §2 prose drifted — R32.7); `Theme.contrastPairs` is the WCAG gate
  (unit-lane, key-set pinned, grow-only); the a11y audit runs {contrast,
  elementDetection, hitRegion, sufficientElementDescription, trait}; widgets stay
  luminance-only and NEVER import Theme; `AppSwitcherPrivacyOverlay` keeps its
  hardcoded surface hexes until its goldens are deliberately re-recorded;
  `DiscreetSettingsView` + `AgeGateContainerView` keep system container backgrounds
  until their own UIR sessions.
- **ADR-11 binding:** displayed "Day N" = 1-based CALENDAR day at local midnight in
  the quit's FIXED start timezone — never `TimeZone.current`, never
  `StreakValue.days`. Count by NOON anchoring. The feed zone travels as a STRING
  identifier. **Durations are the exception-by-domain:** the teaser = 24h wall-clock
  (R25.7); the win-back window = 7×86_400s wall-clock, INCLUSIVE boundary (R26.3) —
  never calendar-anchored.
- Analytics ONLY via the closed enum; zero events before opt-in; the widget
  extension can NEVER fire analytics. Wire values: `ballast.monthly`/
  `ballast.annual`; `variant` ∈ {"teaser","hard"}; `source` gains "teaser_expiry"
  (S25, ratification pending); `offer` = {"winback_annual"};
  `resources_viewed.source` ∈ {"settings","slip_flow"} CLOSED (R27.4). purchase
  fires ONLY on user-initiated PAID (.active) completions; winback_converted co-fires
  BEFORE purchase; winback_shown co-fires with paywall_viewed(source:.winback); the
  paywall funnel is source-segmented. The consent-honest OBSERVED funnel starts at
  slot 3 (S19-R1).
- **Privacy-manifest canon (S31):** TWO manifests, per-executable truth — app =
  UserDefaults [CA92.1, 1C8F.1] + the 3 label-lockstep collected rows; widget .appex
  = [1C8F.1] ONLY (no `.standard` compiles there), collected EMPTY;
  NSPrivacyTracking=false always; never share one file across targets; never place a
  manifest under Shared/Sources; reason codes ONLY from the fetched docs enumerations
  (mach_continuous_time/kern.bootsessionuuid are NOT SystemBootTime members — R31.3);
  the manifests re-derive with the label (R31.5 lockstep) and on any
  required-reason-API addition (rule #5).
- **Entitlement canon (S23+S24):** the mapper has NO clock; `willRenew` pin-ignored;
  the package persists ZERO bytes; `Product` = {monthly, annual} TIER. App-side:
  present-but-inactive ⇒ `isActive:false` NEVER nil; unknown SKU honors an active
  entitlement; `entitlements.all` is the extraction read.
- **DORMANT canon (S24–S26):** key absent ⇒ the SDK symbol is never referenced at
  runtime. NEVER call `Purchases.configure` OR `Superwall.configure` without the
  operator key. The paywall screen is reachable ONLY via the live gate or DEBUG
  `UITEST_PAYWALL=1|teaser`. `Superwall.reset()` is NOT in the erase order (R25.2).
  The winback source purchases through `purchaseWinback()` (the signed path, R29.6);
  every other source rides `purchase(plan:)`; missing-discount fails honestly (R29.9).
- **Teaser canon (S25):** single-use escape; entitled ALWAYS wins; teaser state lives
  ONLY in AppSettings; re-entry = the post-gate root's dashboard branch. **Win-back
  canon (S26):** eligibility = ANY `.lapsed` + stamp ≥ 7d; dismissible OFFER once per
  process + the eligible-only settings row; prices via ProductCatalog constants.
- **Safety canon (S27):** the resources screen is STORE-FREE by construction; only
  `verified: true` rows render on ANY user surface; the GLOBAL region stays
  NUMBER-FREE; the E5.1 age-gate surface keeps its own funcs, zero-fire + unmapped→US,
  byte-frozen; the alcohol notice is once-EVER app-wide, inline amber card, "Got it" ≥
  prominence, stamp at display, erase-swept; helpline rows are NEVER lexicon-scanned.
- **A11y canon (S28, amended by S32):** the eyes-free pacer preference is a
  §10-admissible pre-unlock bit (presence-only stamp `? true : nil`); the panic route
  still opens NO store. The audit family: panic/slip legs are rule-11; the quiz leg
  carries the R28.6 valve; **the R28.13 class exclusions are now SHRINK-only —
  `.contrast` is CLOSED (S32); `.dynamicType`/`.textClipped` remain, owned by
  UIR-1/2/3.** `UITEST_QUIZ` mounts the quiz through BOTH levels with zero store
  dependency — DEBUG-inert, `.disabled` analytics, NO completion seam. A template
  sentence with an unfilled token drops WHOLE. BreathBloom stays a11y-hidden.
- **Funnel-smoke canon (S29):** scenario-29 anchors on SURFACING elements only
  (nested `.contain` container ids never surface, Session-09 class); the smoke's valve
  v2 stands in its header; UITEST_EVENT_SPY arms the spy + bridge (DEBUG-inert
  otherwise); the spy is a SINK-tier decorator (consent-honesty structural); the
  bridge exposes wire names + step ordinals ONLY.
- **Metadata-lint canon (S30):** the explicit-terms register is GRAPHIC-only —
  category nouns (porn/weed) and the sanctioned clinical/ASO forms are NEVER banned;
  the metadata-medical register excludes detox/heal/toxin (milestone-body scope);
  helplines.json is never read; `PanicControlStyle` is enumerated (Mirror-vacuous);
  intent titles pin via `LocalizedStringResource.key`; the widget .appex display name
  is rehearsal-covered (project.yml), never .appex-traversed. Lexicons only GROW
  (foundation-floor superset pins).
- The consent choice is a DEVICE SETTING; erase resets it OFF. Erase order: rows
  (sweeps teaserExpiresAt + paywallVariantAssigned + lapseObservedAt +
  alcoholNoticeShownAt) → infallible local clears (incl. the trial dedupe marker) →
  owned files → widget reload → `resetEntitlement()` → CloudKit purge LAST.
- No shame copy (lexicons only GROW); no medical claims (the milestone gate is
  PHRASE-ANCHORED); no red anywhere (the notice card is AMBER); motivations VERBATIM;
  the paywall bans countdowns/fake discounts/"one-time offer"; prices are NEVER
  copy-table literals; the hard variant has NO close.
- Monotonic fields never decrease; streaks freeze, never inflate (ADR-7); the widget
  floors at Day 1 and runs NO clock guard (ADR-6).
- WITNESS discipline: three advance paths only; widgets never advance it.
- Erase discipline: local-first; owned file-set = {panic-snapshot.json, panic outcome
  buffer, widget-state.json} in THREE enumeration sites; zero active quits ⇒
  widget-state REMOVED (never present-empty); post-erase relaunch = fresh install
  (entitlements survive BY DESIGN).
- Panic path stays thin: panic surfaces NEVER open the store, query entitlements,
  teaser, OR winback state; the panic-descended cold slip route constructs NO
  analytics (R27.11); the widget feed is label-free BY FIELD SET (R1) + presence-only
  discreet (R22.1); the shield policy is tri-state FAIL-CLOSED.
- Never weaken a QA assertion; TDD red first (the R31.4 born-green valve is the ONLY
  sanctioned exception shape); `cloudKitDatabase` stays `.none` until the §4.3 flip.
- Snapshot goldens: light/dark ×5 families ×normal/discreet + AX5 home-only; fixtures
  dated 2025 epoch 2026-07-07T12:00:00Z; `pauseDate`/frozen clocks freeze tickers; the
  ONBOARDING + PAYWALL golden batch waits for the founder copy pass (post-UIR, ONE
  re-record); the SLIP-FLOW goldens include the resources link (S27) and the
  never-dangle degraded copy (S28); the panic/slip goldens are on the tokens-v2
  palette as of S32. SnapshotTesting 1.19.3 + TelemetryDeck 2.14.1 + purchases-ios
  5.80.3 + SuperwallKit 4.16.1 pinned EXACT.
</content>
