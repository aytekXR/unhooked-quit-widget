# Ballast Design Roadmap

A prioritized implementation plan for the Ballast redesign, grounded in the shipping codebase at `unhooked-quit-widget`. This is the execution spine for the four sibling documents (UI/UX Redesign Blueprint, Go-to-Market & Growth Strategy, In-App Copy System, Creative Asset Inventory): they say *what good looks like*; this says *what to build, in what order, in which files*.

---

## Execution status (updated Session 54, 2026-07-27)

The operator answered `operator-expected.md` §0 with **(B) — the redesign runs before launch** —
as a direct instruction ("take all the designs live, don't wait for my approval"). Waves 1–3 landed
on `main`, and sessions 51/53/54 then landed ME-3, ME-8 and ME-4 individually — all green through CI.
**Phase 4's build items are DONE (ME-9 landed in S58)**, so the final golden batch is next — and it now owes only the AGE GATE and the QUIZ, the paywall and summary having minted their own.

| Item | State | Landed in |
|---|---|---|
| QW-1 tokens.json regenerated | ✅ done | wave 1 (`65df4de`) |
| QW-2 Erase UI | ✅ done | wave 1 (`152890b`) |
| QW-4 Panic entry visual priority | ✅ done | wave 1 (`152890b`) |
| QW-5 Averted-urge stat | ✅ done | wave 2 (`9f724a0`) |
| QW-7 Functional Terms/Privacy links | ✅ done | S46 (`3a10442`) — the two PAGES are still the operator's to publish |
| QW-9 Parked AX5 settings defects | ✅ done | **wave 3 (S50)** — retired by construction by ME-7; see below |
| QW-10 Panic in-flow support | ✅ done | wave 1 (`2e3f2dc`) |
| ME-1 Widget-adoption moment | ✅ done | wave 2 (`0bc768d`) — `widget_added` wired, and re-enterable from Settings as of wave 3 |
| ME-2 Dashboard IA & nav shell | ✅ done | wave 2 (`9f724a0`) — Home "Today" shell + tappable cards |
| ME-5 Panic timer live wave | ✅ done | wave 2 (`e82a5a1`) |
| ME-6 App icon re-render | ✅ done | wave 1 (`d061dd1`) |
| ME-7 Settings IA | ✅ done | **wave 3 (S50)** |
| §6.17 Streak Detail (milestone catalog's first renderer) | ✅ done | wave 2 (`d6d6d95`) |
| **QW-3** Analytics fire-points | ⬜ open | Phase 1 leftover — `widget_added` landed with ME-1; the rest are still dormant |
| **QW-6** Crest at the age gate | ⬜ open | Phase 2 |
| **QW-8** Consent revisit toggle | ⬜ open | ME-7 built its home (*Privacy & Data*); the toggle + §6.22 are the next increment |
| **QW-11** Social PNG re-render | ⬜ open | marketing, gated on G0 |
| **ME-3** Milestone unlock moments | ✅ **done — S51** | `30beabe` + 6 goldens (`9988ad5`); an 11th audit leg, clean on its first run |
| **ME-4** Summary payoff redesign | ✅ **done — S54** | `0482e56` + 6 goldens. Full-bleed `WaterlineField` at `progress: 1`, 24pt card (via a DEFAULTED radius parameter, so the other twelve cards cannot move), Moss numeral, "/year" → `.title2`, the new `WaterlineRule` horizon, 32pt clearspace, motivations `.title2`, and the reveal moved off the root onto the figure. **ZERO new strings, ZERO new contrast pairs.** **Two deviations, both measured and both argued in code:** the risk window is a designed sunken well with an indigo marker, NOT §6.5's 24-hour band — four of the six tokens (`social`/`alone`/`boredom`/`stress`) carry no clock meaning, so shading an hour for them fabricates a finding `mvp.md` §7 forbids, and `quizConfig.json` gives `evenings` a *label*, no hours; and `WaterlineRule` is a `brand/primary` gradient rather than creative §2's white Foam, because `surface/raised` is `#FFFFFF` in light mode. **The session's finding was in ME-8's own number** — see the ME-9 row |
| **ME-9** Paywall polish + goldens | ✅ **done — S58** | The §6.6 Waterline band (top third, feathered), the opaque floors under both translucent fills, the widened *Your plan* settings gate, and **6 new paywall goldens** — the surface's first ever. **THE SCOPING NOTE THIS ROW USED TO CARRY WAS WRONG IN ONE LOAD-BEARING CLAUSE, and it was measured rather than argued.** It said: confine the field to the top third and the two doubly-translucent fills "are never involved". They are: `PaywallView`'s plan cards live inside a `ScrollView` (`:33`) and the crop is measured against the SCREEN, so a scrolled card travels up into the band — light `primary action text on selection tint` computes 4.716 with no field and **4.387 under one, against its 4.5 floor**. **The crop is a composition choice; the FLOORS are the guarantee.** With an opaque `surface/base` pinned under the selected plan card and inside `themedCautionCard()`, every scroll position is safe to **0.1640** — 2.7× the shipped 0.06 and clear of the 0.08 hard ceiling. Both floors are byte-identical wherever no field exists. **§6.6's "55% scrim floor" is deliberately NOT literal, also measured:** `Theme.alpha.scrim` is 55% BLACK sized for white text over a full-strength image; applied here it would drop light-mode `content/primary` from 15.650 to **3.351** and `content/secondary` to **1.320** — the scrim meant to protect the text is what would break it. **Two things the row predicted correctly:** the trial badge and 24pt cards were already shipped (UIR-4), so no visual pass was owed there; and the settings row needed no new copy — `winbackRowLabel` already reads "See your plan options". But widening its GATE without widening its DESTINATION would have been a defect: the row's tap hardcoded `source: .winback`, which swaps in the SIGNED promotional-offer purchase path (S29/R29.6) that a never-paid user neither deserves nor can complete. `PaywallRouting.planRowSource` now returns the source, `.settings` — already in the closed enum and already in MVP §5, so **zero analytics vocabulary was added**. A lapsed user inside the 7-day quiet window still gets no row. **A gate hole found in passing and closed:** `ThemeSourceLintTests` banned `Color.white`/`Color.black`/`(.white)` but not the leading-dot shorthand, so `color: .white` or `[.white, .clear]` — exactly how a gradient or mask is written — slipped all three. Eight terminator-qualified entries added, born-green over the real corpus and each proven to fire; a bare `": .white"` was rejected because it collides with `trimmingCharacters(in: .whitespaces)`. **ZERO new strings, ZERO new contrast pairs** (the band carries no text; the floors restore registered composites rather than creating new ones). |
| **ME-8** Waterline primitive + quiz pass | ✅ **done — S53** | `8345e74`. The `WaterlineField` primitive + the continuous quiz field, the keyboard-step live echo, and the haptic-detent slider. **Two spec deviations, both forced and both recorded:** the field ships at 6% opacity with an 8% hard ceiling, NOT the creative doc's "≤12%" — at 12% dark-mode `content/tertiary` computes 2.63:1 against its 3.0 floor; and the field takes no clock input, because both specs ask for state that advances with PROGRESS, not perpetual motion. **Carried to ME-8b:** the two §3 interstitials, the crest keyed to the slider, the step eyebrow, the 2-column chip grid, the 300ms step transition |
| **ME-8b** Quiz interstitials + the remaining §6.3 items | ⬜ open | **NEW, carved out of ME-8 in S53 and named rather than dropped.** The copy deck §3 drafts both interstitials verbatim, so no founder round-trip is needed — but they are the expensive half: `QuizFunnelUITests` taps a hard-coded `0..<11` loop, `QuizFlowModelTests` pins `visibleSteps.map(\.slot)` as two exact arrays plus `count == 11/13`, and a new informational surface owes a 12th audit leg. A **view-layer** overlay keyed off the current step leaves `visibleSteps` — and therefore the fixed analytics slots (R1) — untouched, which is the route to take |
| **ME-4b** The 24-hour risk-window band | ⬜ open — **OPERATOR-GATED, not agent-blocked** | **NEW, carved out of ME-4 in S54 and named rather than dropped.** §6.5's clock band needs two things an agent may not decide: (1) **axis labels**, which are new user-visible copy the deck never drafted (its summary table says the six window lines are "Keep. Same six"); and (2) **a product decision about the four non-temporal tokens** — `social`/`alone`/`boredom`/`stress` denote a mood or context, not an hour, so a shaded clock segment for those users asserts a finding the derivation never made. There is also no range to source even for `evenings`: `quizConfig.json` carries `{"id":"evenings","label":"Evenings"}`. Recorded in `operator-expected.md` §0. If the operator declines it, ME-4's sunken-well treatment is the final answer and this row closes |
| Final golden batch + **LB-5** screenshots | ⬜ open | after ME-9 (**ME-4 is now done**), exactly as Phase 4 sequences it. **ME-8 improved its economics:** `QuizFlowView` has zero goldens today, so the batch's 6 quiz/age-gate goldens will capture the Waterline field on their FIRST mint — no re-record, and no `pauseDate` seam to thread, because the field reads no clock. **S54 rider:** the summary's 4 goldens were re-recorded and 2 zero-spend axes minted in ME-4, so the batch no longer owes that surface anything |
| LB-1…LB-4, LB-6 | ⬜ open | Phase 5, post-launch |

**Two constraint notes below are stale in the operator's favour, and this correction is itself
re-counted at S54 rather than carried forward:** hard constraint 5 says "107 snapshot goldens …
34 WCAG-pinned contrast pairs". Counted from disk and source at S54: **143 goldens across 13
suites**, **32 registered contrast pairs**, and **11 audited surfaces** (not 8, and no longer the
10 this note previously claimed — ME-3 added the 11th in S51). **The suite count was ALREADY 13
before ME-4**, not the 12 the S52 figure claimed; ME-4 added two axes to an existing suite, no new
suite, no new leg and no new pair. **Count these, never quote them** — this line has now been wrong
three times, including in the very correction that replaced the S52 numbers:
`find Tests/Snapshot/__Snapshots__ -name '*.png' | wc -l` ·
`grep -c 'ContrastPair(' App/Sources/DesignSystem/Theme.swift` ·
`grep -c 'func test_a11yAudit_' Tests/UITests/A11yAuditUITests.swift`.
The substance of the constraint is unchanged: any visual change budgets a golden re-record.

**One item is worth reading before touching a settings-adjacent surface again.** QW-9 stood parked
for ten sessions as "Mac-gated, needs Xcode's Accessibility Inspector" after seven billed CI runs
hunting for a row shape that would satisfy Apple's audit. The shape was never the variable — every
failure was a `List` row or a `Section(footer:)` slot, whose height iOS caps. ME-7's rebuild
removed the `List` and the class went with it. `SettingsSourceLintTests` now bans those containers
in all shipping source; if a future item genuinely needs one, it owes an audit leg rendering that
surface's longest string at AX5 first.

---

## How to read this roadmap

**Scoring.** Every task carries Effort × Impact:

| Score | Effort | Impact |
|---|---|---|
| **S** | ≤ 1 day | **High** — moves a north-star metric, closes a submission blocker, or fixes a top-3 critique |
| **M** | 1–5 days | **Med** — strengthens brand, retention, or trust measurably |
| **L** | 1+ week | **Low** — polish; do opportunistically |

Priority = impact per unit effort, then filtered through five **hard constraints** that outrank any score:

1. **The panic path is sacred.** Nothing joins the cold panic path's first frame — no animation, no IO, no SDK (ADR-6; `App/Sources/PanicRouteResolver.swift`, `Shared/Sources/PanicLaunchFlag.swift`).
2. **Copy bytes are founder-owned.** Design moves pixels, never words. New surfaces ship with DRAFT copy tables routed through the founder pass (`docs/copy-pass-checklist.md`); safety copy additionally needs clinician + counsel sign-off.
3. **Code is truth.** `App/Sources/DesignSystem/Theme.swift` and `docs/design/tokens-v2.md` are the color/type record. `brandkit/branding-assets/tokens.json` carries stale pre-correction hexes — never source from it (see QW-1).
4. **Structural kindness is non-negotiable.** No red anywhere (Low Sun `#8C6100` carries all warnings and errors), no countdowns, no failure states, widgets stay luminance-only, discreet surfaces stay habit-context-free.
5. **CI is load-bearing.** Accessibility identifiers anchor UI smokes; 107 snapshot goldens, lexicon lints, and 34 WCAG-pinned contrast pairs gate every merge. Any visual change budgets a golden re-record, coordinated via `docs/golden-batch.md`.

Item IDs (QW/ME/LB) are referenced by the phase plan, dependency map, and measurement table below.

---

## Quick wins (≤ 1 day each)

| ID | What | Why | Where | Effort | Impact |
|---|---|---|---|---|---|
| QW-1 | Regenerate `brandkit/branding-assets/tokens.json` from `Theme.swift`; repoint `BRAND-GUIDELINES.md` §3 at it | Five stale light hexes (`#0E7A6F` etc.) are a live trap — any parallel workstream that reads the brandkit resurrects pre-correction, WCAG-unverified color | `brandkit/branding-assets/tokens.json`, `brandkit/branding-assets/BRAND-GUIDELINES.md`, source of truth `App/Sources/DesignSystem/Theme.swift` | S | High |
| QW-2 | **Erase UI**: a settings row + Low Sun–tinted confirm sheet (hold-to-confirm per the UX spec §6.16) invoking the existing `repository.eraseEverything()` | "One-tap erase" is a P0 story, an App Privacy claim, and a drafted App Review note — with no button. The data layer is done and tested; this is the cheapest trust win in the app | `App/Sources/EraseFlow.swift` ("Future erase UI calls THIS"), row in `App/Sources/DiscreetSettingsView.swift`; re-true `docs/review-notes.md` | S | High |
| QW-3 | Wire the dormant analytics fire-points: `panic_opened` (+cold-start bucket), `panic_step_reached`, `slip_logged` (post-undo-window), `quit_created`, `erase_all_completed` | Three of five MVP success metrics are unmeasurable today; the month-3 kill/pivot checkpoint is meaningless without them. Events are already enum-defined and consent-gated | `App/Sources/AnalyticsService.swift`, seams in `App/Sources/PanicFlowModel.swift`, `App/Sources/SlipFlowModel.swift`, `App/Sources/Quiz/QuizFlowModel.swift` | S | High |
| QW-4 | Give the in-app Panic entry visual priority: full-width `PrimaryButtonStyle` treatment (Harbor Teal `#0C6F65`, 56pt target), visually separated from slip/settings rows | The most important button on the dashboard currently reads identical to admin rows — the single worst hierarchy failure in the app | `App/Sources/RootPlaceholderView.swift`, `App/Sources/InAppPanicEntry.swift`, `App/Sources/DesignSystem/Primitives/PrimaryButton.swift` | S | High |
| QW-5 | Surface the averted-urge stat on the dashboard card ("12 urges surfed and counting") | UrgeEvents are already stored; this is the brand's own example of quiet pride and the panic flow's value proof — currently invisible | `App/Sources/Dashboard/StreakDashboardCard.swift`, `App/Sources/Dashboard/StreakCardModel.swift`; copy line → founder table `App/Sources/Dashboard/DashboardCopy.swift` | S | High |
| QW-6 | Place the crest mark at the age gate and as a watermark on the panic celebration | The brand's first screen has no brand moment; the crest exists only as the app icon. Two of the three sanctioned custom glyphs are unspent in-app | `App/Sources/AgeGate/AgeGateView.swift`, celebration step in `App/Sources/PanicFlowView.swift`; asset from `brandkit/branding-assets/icons/` | S | Med |
| QW-7 | Functional Terms/Privacy links on the paywall (currently dead labels) | Named pre-submission blocker; a 30-minute fix once URLs exist | `App/Sources/Monetization/PaywallView.swift`, `App/Resources/Content/paywallCopy.json` | S | High |
| QW-8 | Analytics-consent revisit toggle in settings | Consent is asked once in the quiz with no way to change it — a GDPR-hygiene gap and a cheap proof of the privacy story | `App/Sources/DiscreetSettingsView.swift`, consent state read by `App/Sources/AnalyticsService.swift` | S | Med |
| QW-9 | ✅ **DONE — S50.** Retired by construction by the ME-7 rebuild (the height-capped `List` was the variable, not the row shape); NOT Mac-gated, no Inspector session needed. See the Execution status table | — | — | — |
| QW-10 | Add the quiet in-flow support affordance to the panic flow: "More support" on every step after the pacer, the full "Or talk to someone" footer on the redirect step (copy deck §7) | Someone mid-crisis inside the panic flow has no path to a helpline without exiting. Make reachability a deliberate decision, not an accident. Link only — nothing on the entry frame (latency budget), and safety surfaces are never weakened | Post-pacer steps and exit states in `App/Sources/PanicFlowView.swift` → `App/Sources/SafetyResourcesView.swift`; copy → founder + clinician review of `App/Resources/Content/safetyCopy.json` | S | High |
| QW-11 | Re-render all four social PNGs on Inter Display / Inter; delete the "VAPE-FREE" lock-screen mock | Current exports use a Segoe-class fallback and one violates the brand's own habit-leak rule while fabricating a widget state the app deliberately cannot render | `brandkit/branding-assets/social/` (rebuild from the `.dc.html` templates) | S | High (marketing) |

Total: roughly **8–9 working days** of parallelizable, low-risk work — and QW-2/3/7 clear three named launch blockers.

---

## High-impact medium efforts (1–5 days)

### ME-1 — Widget-adoption moment · **M · High** (the #1 item on this roadmap)
**What:** A post-summary onboarding step that previews the lock-screen widget and the Panic/Reset Control Center control, with a guided "add it now" walkthrough — plus a dismissible dashboard nudge until a widget is detected. Preview must show the *discreet* variant when relevant. Wire `widget_added` here.
**Why:** The product north star is "panic widget added by D1 ≥ 40%," and today the app never asks, shows, or links the user to add it. This is also the marketing hero shot ("Help before you even unlock.") rendered as product.
**Where:** New step after `App/Sources/Quiz/QuizSummaryView.swift`, routed in `App/Sources/Quiz/PostGateRootView.swift`; previews composed from `Shared/Sources/StreakWidgetViews.swift` + `Shared/Sources/PanicControlStyle.swift`; detection via `Shared/Sources/WidgetFeed.swift` read timestamps; copy → new DRAFT table for the founder pass.

### ME-2 — Dashboard IA & navigation shell · **M · High**
**What:** Retire `RootPlaceholderView` in name and fact. Three visual strata: *Help now* (Panic, from QW-4, alone at top or pinned bottom), *Your quit* (streak card, averted stat, next milestone), *Log & admin* (labeled slip row, settings). Add a screen title, a real navigation container (simple stack now, tab-ready for history/milestones later), and reserve the EmptyState slot the brandkit specs.
**Why:** The brief's harshest and most accurate critique: "a genuinely nice card floating in placeholder chrome." Every later surface (milestones, journal, multi-quit) needs this shell first.
**Where:** `App/Sources/RootPlaceholderView.swift` (rename), `App/Sources/Dashboard/*`, `App/Sources/Quiz/PostGateRootView.swift`. Preserve accessibility identifiers — they anchor CI smokes.

### ME-3 — Milestone unlock moments · **M · High**
**What:** Render the 43 dormant milestone bodies: a quiet unlock card on the dashboard using the sanctioned *waterline rise* (crest lifting over the horizon line in a single 600ms breath, one soft haptic — never confetti), plus a browsable milestone list. This is Ember's (`#E8833A`, dark `#F29D5C`) sanctioned second spend, warming a palette that currently reads cooler than intended.
**Why:** A complete retention loop with zero new copy burden — the "commonly reported" hedged bodies are already written and lexicon-gated in `App/Resources/Content/milestones.json`.
**Where:** New `MilestoneUnlockCard` in `App/Sources/Dashboard/`, catalog data already feeding progress bars via `App/Sources/Dashboard/StreakCardModel.swift`. Milestone text must never reach the widget feed (`Shared/Sources/WidgetFeed.swift` is pre-unlock-readable).

### ME-4 — Summary payoff redesign · **M · High**
**What:** Restore the "most designed screen" through composition, not type size: a Waterline-field backdrop (Horizon Gradient `#0C6F65` → `#5262BC`, marketing/illustration tier only — never behind text without the pinned 55% scrim), Moss (`#2C774B`) savings numeral in SF Rounded with monospaced digits at `.largeTitle`, a drawn horizon hairline under the hero, and a simple risk-window visual (an evening-shaded day arc) replacing the text-only line.
**Why:** This screen "carries the conversion" and lost its drama to the a11y hero cap; the brand direction explicitly assigns the Waterline system to win it back.
**Where:** `App/Sources/Quiz/QuizSummaryView.swift`, `App/Sources/Quiz/SummaryPresentation.swift`; new waterline primitive in `App/Sources/DesignSystem/Primitives/` (see ME-8). Strings untouched.

### ME-5 — Panic timer step: live wave · **M · High**
**What:** Replace the static SF timer glyph with a slow live visual — a TimelineView-driven wave that crests and subsides across ~15 minutes, teal on Canvas, Reduce Motion → opacity drift at the same rhythm. No numeric countdown anywhere: nothing counts down against the user; the wave *rises and passes*, it never expires.
**Why:** The core therapeutic claim — "urges crest and pass" — currently illustrated by a static icon. This turns the weakest panic step into the most ownable screen in the category, and it's the natural precursor to the Live Activity bet (LB-3).
**Where:** Timer step in `App/Sources/PanicFlowView.swift` / `App/Sources/PanicFlowModel.swift`; reuse the sinusoid machinery from `App/Sources/BreathPacer.swift`. The entry frame stays animation-free — the wave mounts only on the timer step, after the pacer.

### ME-6 — App icon re-render: Surfaced Breath — Refined · **M · High**
**What:** Keep the mark's geometry; re-render per the recommended concept: crest enlarged ~8%, the hard 1px horizon replaced by a luminous waterline glow, a whisper of vertical light falloff, deepened submerged reflection; full iOS 26 appearance set (dark, tinted, clear). Regenerate the zero-brand-color Calendar/Timer alternates through the same pipeline.
**Why:** The concept is proven and precious (polysemous, habit-neutral, rename-proof); only the execution is a flat 2014-class gradient whose hairline vanishes at 29pt.
**Where:** `App/Resources/Assets.xcassets/AppIcon.appiconset` (+ `AppIconCalendar`/`AppIconTimer`), `brandkit/branding-assets/icons/`, `brandkit/branding-assets/generate-alt-icons.py`; verify `App/Sources/AppIconSwitcher.swift` still resolves all names.

### ME-7 — Settings IA: split Discreet Mode from Settings · **M · Med**
**What:** Rebuild the sheet as a themed, pushed **Settings** screen (custom components, not a system List) with the canonical sections shared by the UX spec §6.11 and copy deck §11 — *Panic access* (widget & Control Center adoption re-entry), *Discreet Mode* (per-quit numbers-only toggles with live discreet-widget preview, icon picker, shield explanation — fixing the unexplained per-quit/any-quit asymmetry), *Privacy & Data* ("What leaves this device," consent QW-8, erase QW-2), *Breathing* (haptics-only pacer), *Your plan* (plan options/win-back), *Support & resources*, *About* (functional Terms/Privacy, version).
**Why:** The current screen is "a settings screen wearing a privacy feature's name"; it hosts unrelated rows, carries the AX5 defect, and blocks every settings-dependent quick win from having a coherent home.
**Where:** `App/Sources/DiscreetSettingsView.swift`, `App/Sources/DiscreetSettingsCopy.swift`; preview composed from `Shared/Sources/StreakWidgetViews.swift`. Keep the "Tracked goal" neutral labeling discipline.

### ME-8 — Waterline primitive + quiz visual pass · **M · Med**
**What:** Build the Waterline field as a reusable design-system primitive (layered Horizon Gradient bands, one soft light-form, thin luminous waterline; legible in grayscale; ≤3% texture), then spend it: the continuous onboarding field behind the quiz (creative inventory §4) with the copy deck §3's two encouragement interstitials, warmer keyboard steps (spend/custom-name), summary backdrop (ME-4), empty states, milestone cards (ME-3). Upgrade the commitment slider to the spec'd haptic-detent CommitmentSlider.
**Why:** Cures the app's one-template sameness — "calm is designed, not empty" — with a single reusable component instead of per-screen art. Never in widgets, never on the panic entry frame, never on discreet surfaces, never on the shield.
**Where:** New `WaterlineField.swift` in `App/Sources/DesignSystem/Primitives/`; consumers in `App/Sources/Quiz/QuizFlowView.swift`, `OnboardingScaffold.swift`; slider in the quiz flow. Budget a golden re-record.

### ME-9 — Paywall goldens + reachable polish · **M · Med** (gated on founder copy)
**What:** Once §3 copy lands: apply the plan-card visual pass (Waterline restraint, trial badge in `#2C774B` positive), record the deferred onboarding/paywall goldens, and add a generic "See your plan options" settings row for never-paid users.
**Where:** `App/Sources/Monetization/PaywallView.swift`, `App/Resources/Content/paywallCopy.json`, `docs/golden-batch.md`.

---

## Long-term bets (1+ week)

### LB-1 — Quit management UI · **L · High**
Add-quit (shortened quiz re-entry), edit, and delete surfaces plus the brandkit EmptyState ("Start your first quit"). The engine, panic picker (`App/Sources/PanicPlaceholderView.swift`), and per-widget selector are all built — "up to 3 concurrent quits" is a headline differentiator reachable today only by test seeding. Where: new flow off the dashboard shell (ME-2), `App/Sources/Quiz/QuizFlowEngine.swift` re-entry, `App/Sources/Persistence/`. Delete must offer archive-not-erase framing; wire `quit_created`.

### LB-2 — Reduce-mode surface · **L · Med-High**
Adherence-framed progress (engine `AdherenceCalculator` exists; `DashboardCopy.reduceModeFraming` ships empty, §3-blocked) and occurrence logging distinct from slips. This makes the sober-curious persona's MVP acceptance actually renderable and honors "'cut down' is as legitimate a goal as 'quit.'" Where: `App/Sources/Dashboard/`, `App/Sources/SlipFlowView.swift` sibling flow, StreakEngine package. Copy-heavy: schedule the founder table early.

### LB-3 — Live Activity / Dynamic Island urge timer · **L · High**
The 15-minute wave (ME-5) escalated to the lock screen as a Live Activity — the urge companion persists where the urge lives. Marketing's most demoable format after the panic cold-launch. Must remain habit-context-free (shoulder test) and never gate on entitlements. Where: new target alongside `Widgets/Sources/`, state fed from the panic outcome buffer (`App/Sources/PanicOutcomeBuffer.swift`).

### LB-4 — Urge journal & risk-window insights · **L · Med**
Reflection notes are written (`App/Sources/SlipFlowModel.swift`) but never resurfaced; UrgeEvents carry timestamps that can power on-device pattern insight ("your hard window is evenings — tonight, the widget is one tap away"). Strictly on-device, opt-in visible, no notifications without a separate policy decision. Where: new History tab in the ME-2 shell.

### LB-5 — Waterline marketing system: screenshots, share cards, web · **L · High (marketing)**
The full illustration build-out on Inter Display/Inter: App Store screenshot narrative re-trued against shipped UI (the current §9.2 frame 4 shows three quit cards the app cannot render; the "one-tap erase" caption is honest only after QW-2), anonymous-safe milestone share cards, and social. Primary tagline **"Steady beats perfect."**; **"Quit habits. Keep momentum."** serves as the ASO subtitle. Where: `brandkit/branding-assets/`, `docs/frontend-brandkit.md` §9.2. Gated on trademark clearance (G0) — no asset ships under an uncleared name.

### LB-6 — Turkish localization · **L · Med**
Warm-informal *sen*, sentence case only (İ/ı), +30% label expansion, and a separate no-shame tone gate on translated strings. TR helplines already ship in `App/Resources/Content/helplines.json` (ALO-182 stays suppressed until verified). Design's job now: audit ME/LB layouts for expansion room so localization is a string job, not a layout job.

---

## Recommended implementation order

| Phase | Contents | Effort | What it unblocks |
|---|---|---|---|
| **1 — Truth & instrumentation** | QW-1, QW-3, QW-7, QW-9, QW-11 | ~1 week | Every parallel workstream inherits correct tokens and honest assets; the kill/pivot checkpoint becomes measurable; two submission blockers close. Do this before any pixel moves. |
| **2 — Trust & brand floor** | QW-2, QW-4, QW-5, QW-6, QW-8, QW-10, ME-6, ME-7 | ~2 weeks | The privacy story becomes visible product (erase, consent, privacy note); the dashboard's worst hierarchy failure is fixed; the icon and crest establish the brand before deeper redesign; settings becomes a home for everything later. Re-trues `docs/review-notes.md` claims. |
| **3 — Core loop** | ME-2, ME-1, ME-3, ME-5, ME-8 | ~2.5 weeks | The north-star widget-adoption funnel exists and is measured; the dashboard shell hosts milestones and future tabs; the panic flow's weakest step becomes its signature; sameness is cured. The demo build marketing needs for the TikTok hero format exists after this phase. |
| **4 — Conversion** | ME-4, ME-9 + founder §3 copy sitting | ~1.5 weeks (copy-gated) | Summary + paywall carry their weight; goldens re-record once (`docs/golden-batch.md`); screenshots (LB-5) can shoot against final UI. Schedule the §3 sitting during Phase 2 — it is the longest-lead dependency in the project. |
| **5 — Expansion (post-launch)** | LB-1, LB-2, LB-3, LB-4, LB-6; LB-5 runs parallel from Phase 4 | 4+ weeks | Multi-vice becomes demonstrable ("Quit anything, up to three at once"), Reduce completes the third persona, Live Activity opens the next marketing format. Sequence within Phase 5 should follow month-1 funnel data. |

Rough total to launch-ready (Phases 1–4): **~7 weeks** of design+engineering, with copy sittings as the critical path, not code.

---

## Dependencies on the sibling documents

| Roadmap item | Specified by | Notes |
|---|---|---|
| QW-1, ME-6, QW-6 crest usage | **Brand direction** + **Creative Asset Inventory** | Canonical hexes, icon concept ("Surfaced Breath — Refined") and render spec, the three-glyph budget and where each mark lives |
| QW-4, QW-5, ME-1, ME-2, ME-3, ME-7, LB-1, LB-2 | **UI/UX Redesign Blueprint** | Screen-level layouts, dashboard IA strata, widget-adoption step flow, settings sections, quit-management flows |
| ME-4, ME-5, ME-8, waterline-rise motion | **UI/UX Redesign Blueprint** + **Creative Asset Inventory** | Waterline system anatomy and bans (no widgets, no panic entry frame, no discreet surfaces); motion tokens ("breath, not bounce") |
| QW-11, LB-5, screenshot narrative, taglines | **Go-to-Market & Growth Strategy** + **Creative Asset Inventory** | ASO name/subtitle discipline, the canonical screenshot storyboard and re-truing rules, the "<2s vs fast" claim fork (blocked on the device latency measurement in `docs/operator-expected.md` §7), TikTok hero format, social re-render specs |
| All new strings: QW-2 confirm, QW-5 stat line, QW-10 link, ME-1 step, ME-3 unlock frame, LB-2 adherence framing | **In-App Copy System** → founder §3 pass | The copy doc drafts in-register ("coach, never judge"; waves are weather, not enemies); the founder owns bytes; QW-10 and any safety-adjacent line additionally needs clinician + counsel sign-off per `App/Resources/Content/safetyCopy.json` policy |
| Golden re-records for every visual item | Repo process docs | `docs/golden-batch.md` (one batched re-record, not per-item), `docs/copy-pass-checklist.md`, `docs/critical-path-post-uir.md` open-decisions table |

Cross-document invariant: brand facts (hexes, names, taglines, principles) must match the shared direction block verbatim in all five documents — where any doc disagrees with `Theme.swift`/`docs/design/tokens-v2.md` on color, the code is the record.

---

## Measurement

Analytics are opt-in, consent-gated, and structurally anonymous (19-event closed enum) — treat all numbers as directional, and note TelemetryDeck stays dormant until the operator pastes keys.

| Change | Metric it should move | Target | How to check |
|---|---|---|---|
| ME-1 widget adoption | Panic widget added by D1 | ≥ 40% (north star) | `widget_added` (wired in ME-1) ÷ `quiz_completed`, TelemetryDeck cohort by install day |
| QW-3 + ME-5 panic work | Panic uses per WAU; cold-launch latency | Growing WAU ratio; < 2s | `panic_opened` + cold-start bucket (wire values `under_1s`/`1s_to_2s`/`over_2s`, `docs/payload-audit.md`); signpost trace `com.beyondkaira.ballast / PanicColdLaunch` on device |
| QW-4 panic priority | In-app panic share of `panic_opened` by source | Directional up | Source attribution already carried on the launch flag |
| ME-3 milestones + QW-5 stat | D7/D30 retention; post-slip D7 return | Post-slip D7 ≥ baseline | `slip_logged` (QW-3) cohorts vs return sessions |
| ME-4 summary + ME-9 paywall | Quiz completion; quiz→trial; trial→paid | ≥ 70% / ≥ 8% / ≥ 35% | `quiz_step_completed` funnel, `trial_started`, `purchase`; A/B via Superwall sticky assignment once keys are live |
| ME-8 quiz pass | Per-step drop-off, especially keyboard steps | Fewer worst-step exits | `quiz_step_completed` step deltas before/after |
| QW-2 erase + QW-8 consent + ME-7 settings | Trust proxies: consent opt-in rate; review-note accuracy | Directional | Consent choice distribution; `erase_all_completed` exists but is used for claim-truth, never retention pressure |
| ME-6 icon + LB-5 assets | App Store page conversion | Directional up | App Store Connect product-page conversion, post-launch |
| LB-1 multi-quit | Second-quit creation rate | Validates the differentiator | `quit_created` count > 1 per profile-day cohort |

One honest caveat, in the product's own register: several of these surfaces exist to help someone at a hard moment, not to move a number. QW-10 (help from inside the panic flow) and every safety surface are exempt from performance judgment — they ship because they are right, and they are never weakened, gated, or A/B-tested.
