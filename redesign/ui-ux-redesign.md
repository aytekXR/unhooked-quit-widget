# Ballast — UI/UX Redesign Blueprint

**Scope:** Complete redesign specification for the Ballast iOS app (repo working title "Unhooked," `/Users/ae/repo/unhooked-quit-widget`). This document is the design team's execution blueprint: information architecture, flows, every screen, the visual system, motion, and accessibility. Brand facts (palette, taglines, principles) are quoted verbatim from the brand direction and are shared with four sibling documents — do not restate them differently anywhere.

**Binding constraints honored throughout:** no red anywhere (Low Sun amber carries all warnings and errors); no countdowns or urgency mechanics; widgets stay luminance-only; the panic path stays animation-free at entry and store/entitlement-free (ADR-6); copy bytes are founder-owned — every string in this document is a **DRAFT proposal** routed through the copy tables and lexicon gates, never a direct rewrite; discreet surfaces stay habit-context-free; accessibility identifiers are CI-load-bearing and must be preserved; crisis-safety surfaces (`SafetyResourcesView`, helplines, alcohol notice, under-17 support screen) may only become easier to reach, never harder.

---

## 1. Product understanding

**Vision.** Ballast is a privacy-first, multi-vice, no-account quit app that wins at the exact moment of urge — on the phone, at the lock screen. Its one-liner: *"Your streak on your lock screen. Your panic button one tap away."* Three differentiators carry the product: (1) lock-screen-native intervention — an interactive widget and Control Center controls that cold-launch a ~90-second urge-surfing flow in under 2 seconds; (2) forgiveness as a mechanic — a slip archives your best, Momentum survives the reset, a 10-minute undo exists, and there is no "day 1 again"; (3) privacy as architecture — no accounts, no first-party server, on-device SwiftData, discreet mode, disguised icons, an app-switcher shield, one-tap erase. The name is the thesis: ballast is the weight below the waterline that doesn't push the ship anywhere — it keeps it steady in rough water. Primary tagline: **"Steady beats perfect."** ASO subtitle retains **"Quit habits. Keep momentum."**

**Audience.** Adults 17+ quitting or cutting down. Three verified personas: **Jake, 22** (vaping; money-saved is his motivator; arrives via TikTok), **Dan, 26** (quitting adult content; "privacy is everything; will not create an account"), and **Alex, 31** (sober-curious; cutting down, not identity-quitting; no AA framing). Secondary: cannabis, doomscrolling, free-text custom habits. EN first, Turkish fast-follow. Under-17 users are routed to a support screen, never into the app.

**Jobs-to-be-done.**

| Job | Moment | Surface that must win it |
|---|---|---|
| "Get me through the next 90 seconds" | Mid-urge, phone in hand, often at night | Lock-screen widget → panic flow |
| "Prove my progress is real" | Daily glances, weak moments | Widgets, dashboard card, milestones, money saved |
| "Don't let one slip erase me" | Immediately after a slip, shame window | Slip flow, momentum, undo |
| "Keep this off everyone's radar" | Shoulder-visible moments, shared phones | Discreet mode, alt icons, shield, erase |
| "Show me the money" | Rationalizing the quit | Summary hero, dashboard, systemMedium widget |

**Core loop.** Install → quiz personalizes (motivations, spend, triggers) → **widget adoption** (currently missing — the redesign's single most important addition) → urge strikes → one tap from the lock screen → breathe, read your own reasons, redirect → urge averted (quiet pride, stat banked) or slip (forgiven, momentum kept) → dashboard reflects honest progress → milestones renew commitment → repeat. The product's north-star metrics — panic widget added by D1 ≥ 40%, panic uses per WAU — both live inside this loop, and the current UI serves neither.

---

## 2. Current UX review

An honest audit of the shipping TestFlight build. The engineering under this UI is excellent — the critique below is almost entirely about surfaces, hierarchy, and missing connective tissue, not mechanics.

**Navigation & information architecture.** There is no navigation shell. The post-onboarding root is literally named `RootPlaceholderView` — no title, no tabs, no toolbar, no detail views. Every action on the dashboard (slip rows, Discreet Mode entry, Panic entry) renders as a visually identical tinted list row, so the most important button in the product — Panic — has the same visual weight as "open settings." The one settings surface, `DiscreetSettingsView`, is a system `List` titled "Discreet Mode" that also hosts unrelated rows (haptics-only pacer, win-back offer, Support & resources): a settings screen wearing a privacy feature's name. There is no erase button (despite a drafted App Review claim), no analytics-consent revisit, no about/legal, no way to add, edit, or delete a quit. Slip reflection notes are written and never resurfaced. Getting to Safety Resources from *inside* the panic flow is impossible — a person mid-crisis must exit or slip first.

**Onboarding.** The quiz (`QuizFlowView`) is data-driven, checkpointed, and audit-clean — structurally the best-engineered onboarding in the category — but visually flat: 11–13 near-identical screens of full-width pill chips with no per-step art, no encouraging interstitials, and no social-proof step (the PRD specced one; it was never built). The spend and custom-name steps drop into a bare keyboard. The quiz summary — the brandkit's "most designed single screen in the app" — lost its drama when the 64pt hero was capped to `.largeTitle` for accessibility, and no compensating layout idea was added: no chart, no risk-window visual, no habit texture. Most critically, **the funnel never mentions the widget**. The product's #1 metric is panic-widget adoption by D1, and the app never teaches, previews, or deep-links it.

**The panic flow** (`PanicFlowView`) is the soul of the product and mostly earns it: the haptic-synced breath bloom is genuinely therapeutic content, the reasons pages give the user's words hero type, and the exits are tonally perfect. But the middle sags: the urge-timer step is a static SF `timer` glyph under the product's core therapeutic claim ("urges crest and pass in ~15 minutes") — the one place a live visual is begging to exist. The celebration screen on the cold route has no dismiss affordance, reading as a dead end. The panic quit picker is placeholder-grade `circle.dashed` rows.

**Visual hierarchy & the one-template problem.** The app has essentially one visual move — centered text plus one SF glyph on `surface/base` — repeated across the age gate, panic steps, resources, and celebration. It is calm, but it reads as unfinished sameness rather than designed restraint. The brand's three-glyph custom budget (crest, breath bloom, momentum ring) is only one-third spent in-app: the crest exists solely as the app icon; there is no brand moment anywhere inside the product. Ember (`#E8833A`) appears exactly once (the dashboard flame), so the palette in practice is teal/indigo/gray — cooler and flatter than intended.

**Spacing & typography.** Fundamentals are strong: the 560pt content measure, `OnboardingScaffold`'s pinned-actions structure, monospaced ticking digits, SF Rounded heroes. Weaknesses are compositional, not tokenal: hero moments (summary savings, Day N) sit at the same optical weight as body screens; whitespace is uniform rather than rhythmic; nothing on any screen establishes a horizon or anchor.

**Accessibility.** A genuine strength — Apple audit green on 8 surfaces at all 7 Dynamic Type sizes, 56pt panic/slip targets, haptics-only pacer, Reduce Motion variants. One parked defect: `DiscreetSettingsView`'s nav-bar large title and section footers fail at AX5. The redesign's custom settings screen (§6.11) retires that defect by construction.

**Dead-end flows.** Post-slip there is no forward path except closing the sheet. The alcohol notice mounts only on the dashboard, so with live keys a hard-walled non-converter would never see it — a safety-relevant sequencing bug the redesign fixes by moving it ahead of the paywall. The paywall's Terms/Privacy render as dead labels.

**What must not change.** The slip flow's tone and mechanics; the consent step's honesty; the age-gate-blocked support screen; the shield's deliberate blankness; zero panic-entry animation; luminance-only widgets; the discreet lexicon discipline. These are the product's spine.

---

## 3. Design principles

Verbatim from the brand direction, with product-specific application appended to each.

1. **"Win the urge, not the session."** Every redesign decision is judged at minute zero: the panic path gains a live wave visual and a quiet help affordance but not one frame of entry animation, no store read, no new IO. Dashboard hierarchy is rebuilt so "help me now" out-ranks everything else on the screen.
2. **"The door is always open."** No red exists, no countdown exists, no failure state exists. The new erase confirm uses Low Sun amber, not alarm styling. The panic button never renders disabled, including in every new surface. Milestone cards never show "missed" states — only unlocked and next.
3. **"Discreet by default, private by architecture."** Every new surface passes the shoulder test before it ships: milestone cards, the widget-adoption preview, and streak detail all have discreet variants with zero habit context; the new Privacy & Data screen makes the architecture visible ("No account. No cloud we control. One-tap erase.").
4. **"Calm is designed, not empty."** One strong, warm move per screen — the Waterline motif, the user's words at hero size, or one Ember-lit moment — replaces the repeated centered-glyph template. If a screen reads as unfinished rather than serene, it has failed this principle.
5. **"The user's words are the hero type."** The reasons pages keep the largest text in the app; the summary echoes motivations verbatim; custom habit names render exactly as typed everywhere non-discreet; new surfaces (milestone cards, streak detail) quote the user back to themselves before adding our copy.
6. **"Honest numbers, verified pixels."** Savings stay floored with the `~` prefix; milestones keep the "commonly reported" hedge; every new color pair enters `ThemeContrastTests` before it renders; nothing fake, nothing eyeballed, nothing that counts down against the user.
7. **"Accessibility is the design, not a pass."** Text styles, never point sizes (R33.12 is law); content scrolls while actions stay pinned; 56pt targets where hands shake; rhythm preserved under Reduce Motion; the settings AX5 defect is retired by replacing the system List, not patching it.

---

## 4. Redesigned information architecture & navigation model

### Before

A flat, shell-less graph: `AgeGate → Quiz → Summary → (Paywall) → RootPlaceholderView`, with three sheets (slip, discreet settings, resources) and one modal universe (panic) hanging off it. No titles, no detail level, no depth. Everything the app will need next — milestones, multiple quits, journal, erase, plan management — has nowhere to live.

### After: a two-level "harbor" model, deliberately without a tab bar

A tab bar was evaluated and rejected. Tabs advertise breadth; Ballast's job is depth at one moment. Worse, a persistent tab bar taxes the panic flow (full-screen cover would hide it anyway), adds shoulder-visible labels, and forces premature IA commitments ("Journal" as a top-level destination before the feature earns it). Instead:

**Level 1 — Home** (rebuilt from `RootPlaceholderView`, renamed `HomeView`). A `NavigationStack` root with a real title and toolbar. Three zones, strictly ranked: (a) **Help now** — the floating `PanicEntryButton` (finally built as the brandkit specs) pinned bottom-center above the safe area; (b) **Your quits** — one `StreakDashboardCard` per quit, each tappable into Streak Detail, plus an "Add another" affordance when fewer than 3 quits exist; (c) **Today** — milestone-unlock card, averted-urge stat line, pending-undo banner, alcohol notice when applicable. The toolbar carries a single `gearshape` to Settings. Title is "Today" (copy doc §6) — habit-neutral, shoulder-safe, present tense, and safe under a disguised icon: a large "Ballast" title would out the Calendar-style disguise the moment the app opens. One title for every state; no discreet variant needed.

**Level 2 — Streak Detail** (new, one push per quit). The destination the day-hero card has always implied: full momentum story, milestone timeline, averted-urge history, money detail, reflection notes, per-quit actions (log slip, discreet toggle, edit, delete). This is where journal/history and reduce-mode adherence live when they ship — inside the quit they belong to, not as top-level tabs.

**Settings** (rebuilt as a pushed screen, not a sheet) with honest sections: *Panic access* (widget & control setup, re-entry to the adoption flow), *Discreet Mode* (per-quit toggles + live widget preview + icon picker — the name finally matches the content), *Privacy & Data* (analytics consent revisit, "what leaves this device," **Erase everything**), *Support & resources*, *Your plan* (restore / win-back / plan options), *About* (version, Terms, Privacy — functional links, retiring the dead-label blocker).

**Modal strategy.** Full-screen cover, zero transition: panic flow (cold and warm — unchanged, ADR-6). Sheets (300ms standard spring): slip flow, safety resources, widget-adoption overlay, milestone detail. Inline, never modal: alcohol notice, undo banner, error/retry notes. System dialogs only where the OS demands them (icon-change alert). The erase confirm is a full sheet, not an alert — it deserves room to be honest.

**Deep-link surface (all pre-frame, App Group-flag routed, unchanged mechanics):** `panic` (source-attributed: widget / control / action-button / in-app), `panic?quit=UUID` (bound), plus two new internal destinations — `home/quit/UUID` (widget non-button tap target) and `settings/panic-access` (from the adoption flow's "later" path). No new cold-path work is added: the two new links resolve on the normal-launch branch only.

**Why this wins:** the hierarchy finally matches the value hierarchy (help > progress > admin); every missing feature has an obvious home; the app gains depth without gaining shoulder-visible surface area; and nothing new touches the panic path's first frame.

---

## 5. Redesigned user flows

### 5.1 First run: age gate → quiz → summary → alcohol notice → (paywall) → widget adoption → Home

1. **Age gate** — unchanged mechanics; gains the crest mark as the app's first brand moment (§6.1).
2. **Quiz** — same 11–13 steps and engine; visual pass adds the continuous Waterline onboarding field (one field whose state advances with progress — creative doc §4), a designed keyboard experience for spend/custom-name, and the copy doc §3's two encouragement interstitials: **A** — "Past tries count." after the prior-attempts step (shown only when this isn't a first try), **B** — "A slip is never day zero." before the goal step. The PRD's social-proof step stays rejected: Ballast has no verifiable user statistics and invented ones are banned; the interstitials do the persuasion work honestly.
3. **Summary** — rebuilt as the payoff it was specced to be (§6.5): Waterline backdrop, savings hero recomposed for drama-without-point-sizes, a real risk-window visual.
4. **Alcohol notice** — *moved here*, before any paywall, when the habit is alcohol. Fixes the known gap where a hard-walled non-converter never sees the one mandatory caution. Same once-stamp, same copy, same amber card — only the mount point changes.
5. **Paywall** (when keys are live) — unchanged flow; visual alignment only (§6.6).
6. **Widget adoption** (new, §6.15) — one screen, immediately post-entitlement-resolution (post-paywall or post-summary in dormant builds): a live preview of the lock-screen widget rendering *the user's own Day 0 state*, a guided add (Ballast cannot programmatically install accessory widgets — the guide is honest about the steps), the Control Center control as secondary, "Maybe later" as a quiet escape that seeds a dismissible Home card. Fires the currently-unwired `widget_added` analytics via the app-group handshake when the widget's first timeline render lands.
7. **Home** — first-run state shows the streak card at Day 0 with the next-milestone bar already alive (the 12h vape rung makes this immediate for Jake).

*What changed and why:* the funnel finally serves the north-star metric (widget adoption), the safety notice can no longer be paywalled away, and every added step is skippable so quiz-completion ≥ 70% is not put at risk.

### 5.2 Panic from the lock screen / Control Center / Action button

Steps 1–3 (intent → App Group flag → pre-frame route from the snapshot) are untouchable and untouched. Inside the flow:

1. **Breath pacer** — unchanged, on flat Canvas. The pacer is the panic path's first frame, and the illustration doctrine bans the Waterline motif from that frame outright — not "if cheap enough," but categorically. The flow's first designed moment arrives at step 2.
2. **Wave timer step** (redesigned) — the static timer glyph becomes a live, slow horizon: a wave crest that rises and settles on a ~15-minute curve, counting *up* elapsed ride time ("Riding it — 2 min"), never down. This is the therapeutic claim made visible: urges crest and pass.
3. **Reasons pages** — unchanged (already the best screen in the app).
4. **Redirect menu** — unchanged options; visual pass only.
5. **Exits** — unchanged. The celebration gains a proper dismiss affordance on the cold route and the quiet averted-count line ("12 urges surfed and counting" — brandkit's own example).
6. **New: a persistent quiet "More support" affordance** (footnote-weight, bottom-trailing) on every panic step after the pacer, opening Safety Resources as a sheet *inside* the flow. Today a person mid-crisis has no path to 988 without exiting; this is the deliberate design decision the brief asked for. It renders from the pre-cached snapshot's region field — no store read.

### 5.3 In-app panic

The pinned tinted row becomes the floating `PanicEntryButton` (§6.7): 56pt+, Harbor Teal fill, wind glyph, always above the fold, visually unmistakable from every other control. Discreet variant: "Reset," `arrow.counterclockwise`, same prominence — discretion changes words, never availability.

### 5.4 Slip logging + undo

Mechanics untouched (archive-to-best, banked seconds, 10-minute boundary-inclusive undo, crash-safe cold route). Two additions: (1) the logged screen gains a **"what now" bridge** — two quiet options below the reflection field (labels per copy doc §8): "Back to today" (returns to Home) and "One round of breathing" (opens the pacer warm) — closing today's dead end; (2) reflection notes become readable in Streak Detail's private notes list, giving the written-but-never-resurfaced notes a home. Slips continue to animate at standard 300ms — procedurally identical to any other log.

### 5.5 Discreet mode setup

Same toggles, rebuilt surface: the Discreet Mode section of the new Settings shows a **live widget preview pair** (normal vs. numbers-only) rendered from the user's real state, so the effect is seen before it's committed; a one-line explanation of the any-quit-discreet shield behavior (today subtle and unexplained); the icon picker with actual icon thumbnails. The neutral "Tracked goal" labeling discipline is preserved everywhere.

### 5.6 Monetization

Flow logic unchanged (hard/teaser variants, sticky assignment, win-back at +7 days, no notifications ever). Redesign contributions: the paywall inherits the Waterline backdrop so the brand's most commercially important screen is also its most designed; Terms/Privacy become functional links in About and on the paywall; Settings gains "Your plan" so never-paid users have a generic upgrade path (today the paywall is reachable only post-quiz or via win-back). All anti-dark-pattern contracts hold: no countdowns, no fake discounts, restore always visible.

### 5.7 Getting help

Origins grow from three to five: Settings row, slip-flow link, alcohol notice, **panic-flow "More support"** (5.2), and Streak Detail's support row. GLOBAL region's number-free state gets a designed empty treatment (§6.12) instead of a visually empty screen.

### 5.8 Erase everything (new UI over the finished data layer)

Settings → Privacy & Data → "Erase everything" → full sheet: plain statement of exactly what is deleted (quits, notes, widgets' data, settings, the disguise icon reset — matching `EraseFlow` behavior verbatim), amber `themedCautionCard`, a single confirm requiring a deliberate action (hold-to-confirm, 600ms fill — deliberateness without a countdown), then a final system-free confirmation screen: DRAFT "Everything's gone. This app is now exactly as it was before you opened it." This delivers the App Review claim the shipping UI currently cannot.

### 5.9 Add another quit (new)

Home's "Add another" (visible under 3 quits) → shortened quiz (habit → frequency → spend → triggers → motivations → goal; skips consent and age, already answered) → mini-summary → new card on Home. Unlocks the already-built multi-quit engine, panic picker, and per-widget selector. Deleting a quit (from Streak Detail) reveals the brandkit-specced EmptyState (§6.19).

### 5.10 Milestone unlock (new)

On the first Home appearance after a milestone boundary passes: the unlock card renders with the **waterline rise** — the crest lifting over the horizon line in a single 600ms breath — one soft haptic, Ember-lit glyph, "commonly reported" body from `milestones.json`. Never a modal, never blocking, never sound. Discreet quits: the time-only catalog title (e.g. "One week") with the neutral body "A marker worth noting. Your numbers tell the story." (copy doc §9) — zero habit vocabulary, no Ember. The full ladder lives in Streak Detail.

---

## 6. Screen-by-screen redesign

Format per screen: **Purpose · Layout (top→bottom) · Components · Hierarchy · Imagery · Micro-interactions · Motion · States.** Existing accessibility identifiers are preserved on every redesigned surface.

### 6.1 Age gate (`App/Sources/AgeGate/AgeGateView.swift`)

**Purpose:** 17+ compliance; the app's first impression. **Layout:** crest mark (the brand glyph's first in-app appearance, replacing the calendar SF symbol) over a whisper of the Horizon Gradient confined to the top fifth → title "A quick age check" → body → sunken-well year wheel (no pre-selected passing year, unchanged) → pinned Continue → privacy footer ("No account, no sign-up. This stays on your device."). **Hierarchy:** crest > title > wheel > CTA. **Imagery:** the crest at ~64pt glyph scale, drawn, not photographic; gradient never behind text. **Micro-interactions:** wheel detents with light haptic ticks; Continue un-ghosts on any selection. **Motion:** none on entry; Continue press at quick 200ms. **States:** ghost-disabled Continue until a year is chosen; under-17 routes to 6.2. *Why:* the first screen finally spends the brand's most valuable asset — today the crest exists only as an icon on a store page.

### 6.2 Age-gate blocked screen (`AgeGateBlockedView.swift`)

**Purpose:** a support surface, not a wall. **Keep essentially as-is** — it is one of the strongest surfaces tonally. Visual pass only: helpline rows adopt the redesigned card style (16pt radius, Crest surface), the lifepreserver glyph warms to hierarchical Harbor Teal rendering, and spacing takes the new rhythm. Zero red, teal reserved for phone numbers, verified-rows-only rendering, 44pt `tel:` targets, "Call <name>" VoiceOver labels — all preserved verbatim. **States:** none new; no path into the app, ever.

### 6.3 Onboarding quiz (`Quiz/QuizFlowView.swift`)

**Purpose:** the conversion engine; ≥70% completion target. **Layout:** thin Dusk Indigo progress bar on the sunken track (kept) → step eyebrow (new: section label, e.g. "About your habit," Ink Secondary footnote) → question at `.title2` Semibold → answer chips → pinned Continue + quiet Back. **Components:** `AnswerChipStyle` evolves from uniform full-width rows: single-select steps render as a 2-column grid of squarer chips (radius 16) where option count ≥ 5 and labels are short, full-width where labels are long — variety without novelty; multi-select keeps full-width with trailing checkmarks. The habit picker uses word + color-chip tiles (never vice illustrations — iconography ban). The commitment slider becomes the specced **CommitmentSlider** with haptic detents and word echoes. **Keyboard steps** (spend, custom name): the input well gets a `.largeTitle` Rounded live echo of the typed value above the field, so the moment feels designed rather than bare. **Imagery:** one continuous Waterline field behind `OnboardingScaffold` (≤12% opacity behind content, state advancing with quiz progress — creative doc §4), plus the two encouragement interstitials from 5.1 rendered as full field moments. **Micro-interactions:** chip selection at instant 100ms with a light haptic tick; progress bar eases at quick 200ms. **Motion:** step transitions at standard 300ms spring, horizontal push. **States:** checkpoint resume (kept); Back preserves answers (kept); ghost Continue until a required choice exists. *All strings remain DRAFT founder property.*

### 6.4 Analytics consent step (quiz slot 3)

**Purpose:** plain-language opt-in before anything could fire. **Change nothing structural** — this is exemplary privacy UX ("Share app usage data?", two equal chips, default off, deliberate choice required). Visual pass only: the two chips render at exactly equal visual weight (audited in snapshots — no accidental primary), and the helper text keeps `.subheadline` with full Dynamic Type. A small `eye.slash`-adjacent glyph pair (arrow leaving device / arrow crossed out) may illustrate the two options; hierarchical rendering, no persuasion asymmetry. **States:** cannot continue without a choice (kept).

### 6.5 Quiz summary (`Quiz/QuizSummaryView.swift`)

**Purpose:** the payoff card; carries conversion into the paywall. **Layout:** full-bleed Waterline field (Harbor Teal sky into Dusk Indigo water, one soft crest-glow) behind a raised card at 24pt radius → eyebrow "Based on your answers" → savings hero: "~$1,340" in `.largeTitle` SF Rounded Bold monospaced-digits, **"/year" set as a separate `.title2` element and the whole figure given a full-width stage**: the card's horizon line (thin luminous waterline rule) sits directly beneath the number, Moss-colored figure, generous 32pt clearspace above and below — drama recovered through composition, color, and the motif, never point sizes → caption "saved in a year, if you stay on track." → **risk-window band** (new visual): a 24-hour horizontal band with the user's likely hard window (e.g. evenings) rendered as a deeper indigo segment under the label "Your first hard window is likely evenings." — a real visual for a real derivation (`SummaryDerivation.swift`) → hairline → "You're doing this for:" + motivations echoed verbatim at `.title2` Semibold, the user's words visually out-ranking ours → quiet card footer "Steady beats perfect." — the primary tagline's one in-app appearance, a signature under the horizon rule, never a headline → CTA (label founder-owned; propose stronger than "Continue" — DRAFT per copy doc §4: "Start your streak", which works on both routes and for Reduce goals). **Motion:** the savings figure settles with a calm 600ms fade-up on first appearance only; Reduce Motion → opacity-only. **States:** zero-spend users see the risk-window + motivations composition with no money block (never "$0" — kept).

### 6.6 Paywall (`Monetization/PaywallView.swift`, hard / teaser / winback)

**Purpose:** convert without tricks. **Layout:** Waterline backdrop (subdued, ≤ top third; 55% scrim floor before any text overlays) → "Keep your momentum." → trust line "No account. No sign-up. Apple handles billing — cancel in one tap." → plan cards (radius 24, annual pre-selected with the positive-green "3-day free trial" badge on a neutral capsule; monthly beneath) → renewal terms on-screen pre-purchase → primary CTA → quiet escapes (teaser: "Look around for a day first") → Restore, Terms, Privacy as **functional links**. **Hierarchy:** headline > annual card > CTA > escapes. **Micro-interactions:** plan selection at instant 100ms, selection tint at primary@12%. **Motion:** sheet at standard 300ms; no attention animation on CTAs, ever. **States:** amber failure banner with always-available retry/restore (kept); win-back variant composes the honest $14.99 first-year offer with the same layout; teaser re-present keeps the zero-shame eyebrow ("Your free day wrapped up. Everything you set up is still here."). No countdowns, no fake discounts, never re-paywall paid users — contract unchanged.

### 6.7 Home (rebuilt from `RootPlaceholderView.swift`)

**Purpose:** the daily anchor: help > progress > admin. **Layout:** nav title "Today" (copy doc §6 — one habit-neutral title for every state, safe under a disguised icon) with `gearshape` toolbar → pending-undo banner slot (neutral sunken card, kept) → milestone-unlock card slot (6.20, when fresh) → one `StreakDashboardCard` per quit (kept — it's already polished: Day N Rounded hero, Ember flame, indigo momentum % + 72pt ring, Moss money, next-milestone bar) now **tappable → Streak Detail**, with the slip action demoted into the card's own quiet trailing button ("Log a slip," `arrow.uturn.backward.circle`) — no more free-floating look-alike rows → averted-urge line when > 0 (DRAFT: "12 urges surfed and counting." — footnote, Ink Secondary, quiet pride as a stat) → "Add another" ghost card when quits < 3 → floating **PanicEntryButton**: 56pt-min capsule, Harbor Teal fill, Foam wind glyph + label "Panic" with support line "One tap. About 90 seconds." ("Reset" / "Take a moment." + `arrow.counterclockwise` when discreet — copy doc §6), pinned bottom-center, content scroll insets beneath it, never disabled, never covered. **Hierarchy:** Panic > streak cards > today items > add/admin. **Imagery:** none on the shell — the cards and button are the design; calm here means confident structure, not decoration. **Micro-interactions:** card press scales 0.98 at quick 200ms; ring keeps its opt-in 600ms appear fill. **States:** first-run (Day 0 card + widget-adoption card if deferred); frozen streak (Harbor Gray ring + the currently-empty frozen tooltip line finally shipped — copy founder-gated); reduce-mode quits show the adherence variant (6.21); empty state after last deletion (6.19).

### 6.8 Panic flow (`PanicFlowView.swift`)

**Purpose:** win 90 seconds. **Entry:** unchanged — first frame is the pacer, zero decorative animation, snapshot-only reads. **Step 1, breath pacer:** the 220pt bloom keeps its sinusoidal scale synced to CoreHaptics, on flat Canvas — the Waterline motif is banned from the panic path's first frame (illustration doctrine + latency budget), so this screen changes nothing. Reduce Motion → opacity pulsing (kept); haptics-only mode → "Feel the taps — in, hold, out." + progress dots (kept). **Step 2, wave timer (the big upgrade):** replacing the static SF timer glyph — a full-width horizon with one wave crest that swells and settles along a slow ~15-minute curve (TimelineView-driven like the pacer), elapsed ride time counting **up** in monospaced digits ("2 min riding it"), copy unchanged ("Urges crest and pass — usually within about 15 minutes… Just this wave." / "Stay here as long as you like. Nothing is counting down against you."). The visual is ambient, sub-1Hz, Reduce Motion → the crest as a static composition with a slow opacity breath. **Step 3, reasons:** unchanged — user's words at `.largeTitle` Semibold, one per page. **Step 4, redirect menu:** four 56pt rows on Sheet surface, glyphs warmed to hierarchical teal. **Exits:** filled teal "The urge passed" over quiet "I slipped" (kept). **New on steps 2–4:** the quiet "More support" affordance (5.2). **Celebration:** crest watermark behind the checkmark, averted-count stat line, one soft haptic, 600ms fade — and a proper "Done" quiet button on the cold route. **States:** skippable breathing (kept); empty-reasons fallback line (kept); every state store-free.

### 6.9 Panic quit picker (`PanicPlaceholderView.swift` — `PanicQuitPickerView`)

**Purpose:** one tap into the right flow when no quit is bound. **Layout:** "Which one needs you right now?" at `.title2` → one 56pt card-row per quit: habit name (or "Your goal" when discreet — kept), current Day N in monospaced digits, chevron. **Hierarchy:** equal-weight rows — no quit is more urgent than another. **Micro-interactions:** single tap routes immediately; no confirmation. **Motion:** none on entry (still the cold path). **States:** renders from the snapshot only; if only one quit exists this screen never mounts (kept).

### 6.10 Slip flow (`SlipFlowView.swift`)

**Purpose:** forgiveness as mechanics. **Keep the flow's copy, rhythm, and neutrality wholesale** — this is the product's moral center. Visual pass: stages adopt Sheet surface + 16pt-radius cards; the undo banner stays a neutral sunken card (never amber — a slip is not a warning). **Additions:** the "what now" bridge on the logged screen (5.4) — two quiet buttons, "Back to today" and "One round of breathing" (copy doc §8); the reflection field keeps local autosave and its shipped placeholder — the prompt already says "stays on your device," and it needs no second reassurance. **Motion:** standard 300ms everywhere — a slip must never feel cinematically marked (kept). **States:** store route with reflection; cold route without (kept); failed durable write shows the calm retry note and never claims "Logged." (kept); undone confirmation "Undone. Your streak is right where it was." (kept).

### 6.11 Settings (rebuilt from `DiscreetSettingsView.swift`)

**Purpose:** honest admin, finally named honestly. **Layout:** custom-built list on the design system (retiring the system `List` and, by construction, the AX5 nav-title/footer defect) → sections: **Panic access** (rows: "Add the lock-screen button," "Add the Control Center button" — copy doc §11; each opening the adoption guide with live previews; wires `widget_added` re-entry) → **Discreet Mode** (per-quit "numbers only" toggles with the live before/after widget preview pair; one-sentence shield explanation; icon picker with real thumbnails for Default / Calendar style / Timer style) → **Privacy & Data** (analytics consent toggle — the GDPR-hygiene gap, closed; "What leaves this device" → 6.22; **Erase everything** → 6.16) → **Breathing** (haptics-only pacer toggle) → **Support & resources** → **Your plan** (restore; win-back row when eligible; plan options for never-paid users) → **About** (version, functional Terms/Privacy, credits). **Hierarchy:** panic access first — settings order restates product values. **States:** discreet quits labeled "Tracked goal" even here (kept); win-back row conditional (kept).

### 6.12 Safety resources (`SafetyResourcesView.swift`)

**Purpose:** free, confidential help, one tap from five origins. **Keep structure and every verification rule:** region-resolved rows (US / TR / GLOBAL), verbatim numbers, verified-only rendering, ALO-182 suppressed until verified, 44pt dial links, not-medical-care footer. Visual pass: rows to the new card style; lifepreserver in hierarchical teal. **GLOBAL empty treatment (new):** no illustration — a decorated help-vacuum would read as evasion (creative doc §5). Instead: the lifepreserver glyph, generous space, and a single card carrying the copy doc §12 explanation ("Helplines differ by country, so we only list numbers we've verified…") with the "Find a helpline" pointer to findahelpline.com — designed through restraint, never blank, never softened with brand art. **States:** unchanged otherwise; `safetyCopy.json` still requires clinician + counsel sign-off before any string ships.

### 6.13 Alcohol withdrawal notice (inline card)

**Purpose:** the one mandatory caution, shown once, calmly. **Content and tone unchanged** (amber tint at 10%, lifepreserver, "One thing worth knowing," "Got it" / "See resources," durable once-stamp; never red). **Placement change only:** mounts in the first-run flow immediately after the summary and before any paywall (5.1), and additionally on Home if somehow unseen. Fixes the operator-logged gap where a hard-walled non-converter would never see it.

### 6.14 App-switcher privacy overlay (`AppSwitcherPrivacyOverlay.swift`)

**Purpose:** the multitasking card never outs the app. **Redesign decision: change nothing.** The blank theme-matched surface (#F7F6F3 / #121417), no logo, fail-toward-privacy behavior is the correct design; a blank card draws no eye. Documented here so no future visual pass "brands" it.

### 6.15 Widget-adoption screen (NEW — the highest-leverage screen in this document)

**Purpose:** serve the north-star metric (panic widget added by D1 ≥ 40%); wire `widget_added`. **Layout:** title (DRAFT per copy doc §4: "Put help on your lock screen") → a device-frame illustration of a lock screen with the **user's real rectangular widget state** rendered inside it ("Day 0" + their currency zero-suppressed money line + the wind-glyph panic button; discreet users see the discreet variant — the preview obeys every lexicon rule because it renders the true feed) → a 3-step guided add (honest about iOS's manual flow: press and hold the lock screen → Customize → add Ballast) → secondary card for the Control Center / Action-button "Panic" control → quiet "Maybe later" (copy doc §4; seeds a dismissible Home card; routes exist at `settings/panic-access`). **Hierarchy:** preview > steps > secondary > escape. **Imagery:** the device frame is the one place marketing-style composition enters the product — Horizon Gradient behind the mock lock screen only. **Micro-interactions:** steps check themselves off if the app detects the widget's first timeline render (app-group handshake — the `widget_added` fire point). **States:** re-enterable from Settings forever; never re-prompts after success.

### 6.16 Erase everything (NEW UI over `EraseFlow.swift`)

**Purpose:** deliver the one-tap-erase promise. **Layout:** sheet → title (DRAFT per copy doc §11: "Erase everything?") → plain-language manifest of exactly what is deleted (quits & streaks, notes, widget data, settings, disguise icon reset) matching data-layer behavior verbatim → amber `themedCautionCard` ("This can't be undone.") → **hold-to-confirm** button: 600ms press-and-hold with a filling Low Sun ring (deliberateness without a countdown; VoiceOver users get a double-activation alternative) → success screen: crest alone on Canvas, DRAFT "Everything's gone. This app is now exactly as it was before you opened it." **States:** cancel is always the easy path (quiet button, sheet swipe); failure shows the calm retry note pattern. Entitlement survival via RevenueCat is stated honestly on the manifest.

### 6.17 Streak Detail (NEW — Level 2 of the IA)

**Purpose:** the destination the dashboard card implies; home for milestones, history, notes, and per-quit admin. **Layout:** large header: Day N hero (`.largeTitle` Rounded Bold, monospaced) over a thin waterline rule → momentum block (indigo % + ring, with the plain-language momentum explanation the app has never offered — same string as the dashboard popover, copy doc §6: "Momentum is your clean days over all your days. A slip barely moves it — only time does.") → money block (Moss, floored) → **milestone timeline**: unlocked rungs with Ember-lit glyphs + "commonly reported" bodies from `milestones.json` (43 dormant bodies finally rendered), next rung with progress; no missed states exist → averted-urge history ("This month: 9 urges surfed") → private notes list (slip reflections, on-device, DRAFT header "Only on this phone.") → actions: Log a slip · Discreet toggle · Edit quit · Delete quit (delete uses the amber confirm pattern, never red). **Discreet variant:** "Tracked goal," numbers-only, no milestone bodies. **Motion:** header settles at calm 600ms on push; milestone unlock uses the waterline rise. **States:** frozen (Harbor Gray ring + explanation line), reduce-mode (6.21 adherence framing replaces streak framing).

### 6.18 Add-a-quit flow (NEW)

**Purpose:** unlock the built-but-surfaceless multi-quit engine. **Layout:** shortened quiz (6 steps — habit, frequency, spend, triggers, motivations, goal) in the same quiz chrome → mini-summary card → lands on Home with the new card in place. **States:** entry hidden at 3 quits (engine cap); each new quit offers a per-widget binding hint ("Add a widget for this one too") linking to 6.15.

### 6.19 Empty state (NEW — required the moment quit deletion ships)

**Purpose:** the brandkit-specced "Start your first quit" surface. **Layout:** a day-tone Waterline field crop (top third, fading to Canvas) with the crest half-risen over the waterline (creative doc §5) → DRAFT "Ready when you are." (deliberately echoing the widget's unavailable-state line) → primary "Start a quit" → quiet "Erase everything" remains reachable via Settings. Calm, one move, no illustration clutter. **States:** this is itself a state; it must also pass the shoulder test (no habit words — it always can, since no quits exist).

### 6.20 Milestone unlock card (NEW, Home + Streak Detail)

**Purpose:** the retention loop the app lacks, from 43 pieces of dormant content. **Layout:** raised card → Ember-rendered milestone glyph (the sanctioned second spend of `#E8833A`) → milestone title → "commonly reported" body → quiet "See all" → Streak Detail's timeline. **Motion:** the waterline rise — crest lifting over the horizon line in one 600ms breath + one soft haptic. Never confetti, never sound, never a modal. **Discreet variant:** time-only catalog title + "A marker worth noting. Your numbers tell the story." (copy doc §9), no Ember. **States:** appears once per unlock; dismisses on tap or next visit.

### 6.21 Reduce-mode adherence surface (NEW, completes Alex's persona)

**Purpose:** make "cut down" a first-class goal (engine `AdherenceCalculator` + allowance quiz step already exist; `DashboardCopy.reduceModeFraming` ships empty). **Layout:** the reduce-mode `StreakDashboardCard` variant swaps the Day N hero for a weekly-allowance reading — "3 of 5 this week" in Rounded monospaced digits with a Moss adherence bar (within allowance = positive; over allowance = neutral Ink Secondary, **never amber** — going over is data, not a warning) → Streak Detail shows adherent-weeks history. **New interaction:** "Log one" quiet button on the card — occurrence logging distinct from slips, feeding adherence. Framing strings are founder-gated (§3-blocked) — layout ships behind the copy gate.

### 6.22 Privacy dashboard — "What leaves this device" (NEW, inside Settings)

**Purpose:** convert the privacy architecture into visible product value. **Layout:** one screen, two states. Consent off: a single lead line (copy doc §11: "Nothing. Ballast has no account, no sign-up, and no server of ours…") with the crest. Consent on: the literal 19-event enum listed by name, plus "never your answers, notes, or the times you log, and never tied to you," with the consent toggle right there. **Hierarchy:** the honesty *is* the design; no decoration. This screen doubles as the analytics-consent revisit surface (GDPR hygiene).

### 6.23 Widgets — accessoryRectangular / accessoryCircular / accessoryInline (`Shared/Sources/StreakWidgetViews.swift`)

**Redesign decision: no visual changes.** Luminance-only rendering, "Day 34" at 20pt Semibold monospaced, "$412 saved" micro-line, wind-glyph `Button(intent:)`, discreet variant (money dropped, `arrow.counterclockwise`, "Reset" label), "Ready when you are." unavailable state, data-only circular/inline — all correct and golden-pinned (29 goldens). The redesign's job here is adoption (6.15), not pixels. Any change would burn goldens for zero user value.

### 6.24 Widgets — systemSmall / systemMedium

**Keep current composition** (title2-bold day line, monospaced ticker, momentum gauge, Moss-free luminance discipline, 12pt +0.3-tracked micro-labels, discreet bar without the word "milestone"). One proposal evaluated and rejected: giving the systemMedium milestone bar a waterline-styled track. The illustration doctrine bans the motif from widgets absolutely — even as a luminance-only line — and the golden batch would re-record for decoration. Widgets change for adoption (6.15), never for pixels.

### 6.25 Panic / Reset Control Center controls (`Widgets/Sources/PanicControlWidget.swift`)

**No changes** to the controls themselves (wind / `arrow.counterclockwise`, honest descriptions, not Shortcuts-discoverable). They gain discoverability through 6.15 and Settings → Panic access.

### 6.26 Alternate app icons (system surface)

Primary crest icon re-rendered per §10 (Surfaced Breath — Refined) with full dark/tinted/clear appearances. "Calendar style" and "Timer style" keep zero brand color (the disguise is the absence of identity) but are re-drawn on the same geometric grid as the crest so they feel like quality apps, not clip art. Erase continues to reset to the primary icon (kept — an "erased" phone doesn't keep the disguise).

### 6.27 Widget gallery / settings-gallery strings

**No changes.** "Streak — Your streak, on your lock screen. A quick reset is one tap away." passes the habit-leak lexicon and reads well. Pre-add gallery text remains shoulder-safe by CI.

### 6.28 Debug/test surfaces

Not user-facing; the redesign's obligation is preservation: every renamed or rebuilt view keeps its accessibility identifiers (CI-load-bearing), the `UITEST_*` direct mounts continue to resolve, and new screens (Home, Streak Detail, Settings, Erase, Widget adoption) each get a direct-mount env hook and audit coverage before merge.

---

## 7. Missing pages & missing features — proposals and priority

| Proposal | Rationale | Priority |
|---|---|---|
| **Widget-adoption screen** (6.15) + `widget_added` wiring | The north-star metric is unmeasurable and unserved; also the marketing hero shot | **P0 — pre-launch** |
| **Erase UI** (6.16) | App Review claim currently untrue; data layer finished; small build | **P0 — pre-launch** |
| **Alcohol notice re-sequencing** (6.13) | Safety surface must precede any paywall | **P0 — pre-launch** |
| **Home rebuild + PanicEntryButton** (6.7) | The most important button has no visual priority today | **P0 — pre-launch** |
| **Functional Terms/Privacy links + About** | Named submission blocker | **P0 — pre-launch** |
| **Funnel instrumentation** (`panic_opened`, `slip_logged`, `quit_created`, `widget_added`) | Month-3 kill/pivot checkpoint is meaningless without it | **P0 — pre-launch** |
| **Settings rebuild** (6.11) incl. consent revisit + AX5 retirement | IA debt + GDPR hygiene + the one open a11y defect | **P1 — launch window** |
| **Streak Detail + milestone timeline + averted stat + notes** (6.17) | 43 dormant milestone bodies and stored UrgeEvents = free retention | **P1 — launch window** |
| **Milestone unlock card + waterline rise** (6.20) | The retention loop; spends Ember as intended | **P1 — launch window** |
| **Wave timer step + in-panic "More support"** (6.8) | Weakest panic step becomes the most ownable; crisis access is a duty-of-care fix | **P1 — launch window** |
| **Add-a-quit + delete + EmptyState** (6.18, 6.19) | Headline differentiator ("up to three") currently undemonstrable | **P1–P2** |
| **Reduce-mode adherence surface** (6.21) | Completes the Alex persona; copy-gated | **P2 — post-copy-pass** |
| **Privacy dashboard** (6.22) | Converts architecture into visible value | **P2** |
| **Summary/quiz visual pass + encouragement interstitials** (6.3, 6.5) | Conversion-side polish; coordinates with the founder copy pass + golden re-record | **P1, batched with §3 sitting** |
| Live Activity 15-min timer, share cards, StandBy night state, journal insights | Roadmap-confirmed post-v1.0; the IA above gives each a home (Streak Detail / panic step 2) | **Post-v1.0** |
| Notifications | Deliberately none; any proposal is a policy question, not a gap — unchanged | **—** |

---

## 8. Accessibility

Platform-specific commitments; each existing ruling stays law.

- **Dynamic Type:** text styles only, never point sizes on text (R33.12); every new surface (Home, Streak Detail, Settings, Erase, Widget adoption, milestone cards) ships at all 7 sizes through the Apple audit before merge. Point sizes survive only on decorative SF-symbol images and inside widgets (DT-clamped platform surfaces). `OnboardingScaffold`'s scroll-content/pinned-actions structure extends to every new full-screen surface. Line length stays ≤ ~34ch via the 560pt measure. The StreakRing and wave visual are omitted at AX sizes (precedent: ring already omits); numbers and words carry the meaning.
- **VoiceOver:** every new element gets labels/hints/traits at build time, not retrofit. Specifics: the wave timer announces elapsed ride time on demand, never automatically ("nothing counts down against you" applies to audio too); hold-to-confirm erase offers a standard double-activation alternative with an explicit hint; milestone cards read title → hedged body → "See all"; the widget-adoption preview is described ("Preview of your lock screen widget: Day 0…"); discreet surfaces' labels stay habit-free ("Reset," "Tracked goal" — kept).
- **Contrast:** every rendered pair enters the machine-verified registry (`ThemeContrastTests`, 34 pairs × 2 modes today; new pairs — Ember-on-Crest at glyph scale, waterline-on-Canvas, Low Sun fill ring — get pinned before first render). Driftwood `#80868E` stays large-text/icon-only (its 3.11 pair is the registry's watch-listed tightest). Horizon Gradient never sits behind text without the pinned 55% scrim. Widgets stay luminance-only, meaning in glyph + text, never hue.
- **Hit targets:** 44pt global floor; 56pt on panic and slip paths via growing padding, never height floors — extended to the PanicEntryButton, redirect rows, exits, and the erase confirm. Ghost-disabled treatment (contentSecondary on sunken), never opacity.
- **Reduce Motion:** rhythm preserved, spectacle dropped — the pacer's opacity pulse at the 4-7-8 curve (kept), the wave becomes a static crest with a slow opacity breath, the waterline rise becomes a cross-fade, card presses drop scale. Nothing loses meaning when motion is off.
- **Haptics:** the pacer's CoreHaptics sync is therapeutic content (kept); haptics-only mode remains a first-class eyes-free path with non-visual instructions; new haptic moments are limited to one soft tap (milestone, celebration) and detent ticks (slider, wheel).
- **RTL:** not applicable at launch (EN, then Turkish — both LTR); layout nevertheless uses leading/trailing semantics throughout so RTL costs nothing later. Turkish: sentence case only (İ/ı casing), +30% expansion room in labels, and the no-shame lexicon gate re-run as its own pass on translated strings.

---

## 9. Visual design system

**Design language summary.** Warm-calm, water-anchored, honestly numeric. Surfaces elevate by tone, not shadow; color is scarce and semantic; numbers are monospaced and never inflated; the Waterline motif gives key screens one designed signature; dark mode is the primary design target (evening risk windows).

### 9.1 Palette (single source of truth: `Theme.swift` / `docs/design/tokens-v2.md`; the stale hexes in `brandkit/branding-assets/tokens.json` must not be resurrected)

| Token | Name | Light | Dark | Usage |
|---|---|---|---|---|
| brand/primary | Harbor Teal | `#0C6F65` | `#4CC8B9` | Primary actions, links, selection, the breath-pacer bloom, streak identity. Streak is always teal; momentum is always indigo — never confused. |
| brand/primaryPressed | Deep Water | `#0A5F57` | `#6ADACB` | Pressed/active state of primary controls at 0.98 scale. |
| brand/onPrimary | Foam | `#FFFFFF` | `#08302B` | Text/glyphs on primary fills; dark mode deliberately dark-on-light-teal. |
| brand/secondary | Dusk Indigo | `#5262BC` | `#93A0E8` | Momentum figures, momentum ring, progress fills, quiz progress. Momentum ONLY. |
| brand/accentFlame | Ember | `#E8833A` | `#F29D5C` | Streak flame glyph and milestone-unlock moments ONLY. Never on buttons, never as text, never above 10% of a screen. |
| semantic/positive | Moss | `#2C774B` | `#6FCE97` | Money saved, urge averted, adherence days, trial-active badge. |
| semantic/caution | Low Sun | `#8C6100` | `#E5B84B` | ALL warnings AND all errors — no red anywhere, ever. Always icon + text, never color-only. |
| semantic/info | Slate | `#3D6C9E` | `#8FB6E0` | Passive notices and status lines. |
| semantic/paused | Harbor Gray | `#6E7681` | `#9AA3AD` | Frozen-streak and discreet ring rendering — paused is neutral, never a problem. |
| surface/base | Canvas | `#F7F6F3` | `#121417` | Screen background; warm off-white, never clinical white. |
| surface/raised | Crest | `#FFFFFF` | `#1C1F24` | Cards; dark elevates by tone, not shadow. |
| surface/sunken | Tidepool | `#EEECE7` | `#0B0D0F` | Grouped backgrounds, tracks, input wells, ghost-disabled fills. |
| surface/overlay | Sheet | `#FFFFFF` | `#22262C` | Sheets and the panic redirect menu; scrim black@55%, floor-pinned. |
| content/primary | Ink | `#1A1D21` | `#F2F1EE` | Primary text. |
| content/secondary | Ink Secondary | `#565D66` | `#A8AFB8` | Supporting copy, quiet buttons, ghost-disabled labels. |
| content/tertiary | Driftwood | `#80868E` | `#6E757E` | Large text and icons ONLY (3.0 tier); doubles as border/strong. |
| border/hairline | Hairline | `#E2E0DB` | `#2B3036` | 1px separators; decorative-exempt. |
| — | Horizon Gradient | `#0C6F65` → `#5262BC` | same | Marketing, App Store frames, share cards, illustration backdrops, and the in-app Waterline fields ONLY; never a text background without the 55% scrim; never in widgets; never in app UI chrome. |

Alphas: selection tint primary@12%; caution tint @10%; scrim black@55%; pacer bloom .25/.28/.35. Disabled = ghost (contentSecondary on sunken), never opacity.

### 9.2 Typography

Apple system type only — strategy, not thrift (free Dynamic Type, vibrancy, Turkish coverage). Roles, never point sizes:

| Role | Style | Face | Use |
|---|---|---|---|
| Hero numeral | `.largeTitle` Bold, monospaced digits | SF Rounded | Day N, summary savings, adherence reading |
| User's reasons | `.largeTitle` Semibold | SF Pro | Panic reasons — the largest text in the app by intent |
| Screen title | `.title2` Semibold | SF Pro | Questions, card titles, milestone titles |
| Body | `.body` (17) | SF Pro | Copy |
| Secondary | `.subheadline` (15) | SF Pro | Helpers, quiet buttons |
| Legal/meta | `.footnote` (13) | SF Pro | Disclaimers — must survive AX sizes |
| Widget numerals | ~20pt Semibold monospaced | SF (Compact, system) | Widgets only (DT-clamped surface) |
| Widget micro-labels | 12pt Medium, +0.3 tracking | SF | "saved," "next milestone" |

No weight below Regular; monospaced digits wherever a number ticks. Lost hero drama is recovered through composition — color (Moss money, Rounded numerals), the waterline motif, generous space — never type size. Marketing/web/social: Inter Display (headlines, −1% tracking) + Inter (text) with tabular numerals; no serif anywhere.

### 9.3 Spacing, radii, elevation

- **Spacing scale:** 4 / 8 / 12 / 16 / 20 / 24 / 32 / 48. New compositional rule: hero blocks get 32 above and below; the one-move-per-screen element gets 48 of clearspace on at least one axis.
- **Radii:** 10 (small controls) / 16 (cards, chips-grid) / 24 (plan cards, hero cards, sheets) / full (pills, PanicEntryButton).
- **Elevation:** two levels only — raised (Crest) and overlay (Sheet); tone-based in dark mode, hairline-plus-tone in light. No drop-shadow language beyond the system sheet shadow.
- **Content measure:** 560pt max width; 44pt/56pt touch floors via growing padding.

### 9.4 Components (inventory)

**Existing, kept:** `PrimaryButtonStyle` (Harbor Teal pill, Deep Water pressed @0.98, ghost disabled, width-locked spinner) · `QuietButtonStyle` (Ink Secondary text, ≥44pt, never shrunk) · `AnswerChipStyle` (extended with the 2-column grid variant) · `PlanCardButtonStyle` · `ThemedProgressBar` (Dusk Indigo on Tidepool, 4pt visual / 44pt a11y frame) · `themedCard` / `themedCautionCard` / `themedSelectionTint` / `themedScreenSurface` · `OnboardingScaffold` · `StreakDashboardCard` + `StreakRing` (6pt trim, indigo, 12-o'clock origin, Harbor Gray when discreet/frozen, omitted at AX sizes) · `BreathBloomView` · `StepScaffold` + `SkipButton` · SlipSheet stages · widget family templates.

**New:** `PanicEntryButton` (floating 56pt+ capsule, teal/Foam, wind glyph, discreet twin, no disabled state) · `WaterlineField` (layered flat bands + one soft light-form + thin luminous waterline; quiet static variant behind the wave timer step only — never the panic entry frame) · `WaterlineRule` (the hairline horizon under hero numbers) · `WaveTimerView` (TimelineView, ~15-min crest curve, count-up) · `MilestoneCard` (Ember glyph tier) · `CommitmentSlider` (haptic detents) · `EmptyState` · `HoldToConfirmButton` (600ms Low Sun fill ring, double-activation alternative) · `WidgetPreviewFrame` (renders the true widget feed into a device mock) · `SettingsListRow` (custom, retiring the system List) · `StatLine` (quiet-pride averted counter).

### 9.5 Iconography

SF Symbols only in v1 — regular scale, weight matched to adjacent text, hierarchical Harbor Teal for navigation, monochrome in widgets. Kind vocabulary: slip = `arrow.uturn.backward.circle` (a turn, never an X); help = lifepreserver; panic = wind; discreet = `eye.slash`; erase = trash paired with amber copy. Banned forever: broken chains, skulls, warning triangles in slip flows, locks-as-shame, habit paraphernalia anywhere (habit picker stays word + color-chip tiles). The custom-glyph budget is exactly three marks on the SF Symbols grid — crest, breath bloom, momentum ring — and this redesign spends it: crest at the age gate, celebration watermark, and empty state; bloom stays the panic flow's center of gravity; ring stays the daily companion.

### 9.6 Illustration — "Waterline fields"

The brand's second visual move and the cure for one-template sameness. No mascots, no people, no hands, no photography, no habit imagery, ever. Exactly three ingredients: layered flat bands of the Horizon Gradient (Harbor Teal sky into Dusk Indigo water), one soft light-form (the crest circle or its glow), and a thin luminous waterline. Rothko calm, drawn with iOS precision: flat shapes, one subtle radial glow maximum, no texture above 3%, no hot colors beyond Ember at glyph scale, every composition legible in grayscale. **Lives:** the continuous quiz field + interstitials, summary backdrop, empty states, milestone cards, the wave timer step's quiet field, share cards, App Store screenshot backdrops, social. **Never lives:** widgets (luminance-only), the panic path's first frame (the pacer stays flat Canvas — doctrine and latency budget both), any discreet surface (zero brand color is the disguise), the app-switcher shield (deliberately blank).

---

## 10. App icon concepts

1. **Surfaced Breath — Refined (RECOMMENDED).** Keep the existing mark's geometry — the soft off-white circle cresting a thin horizon on the teal-to-indigo vertical field — re-rendered with contemporary depth: crest enlarged ~8% for grid presence; the hard 1px horizon replaced by a luminous waterline glow (a 2–3% blur bloom hugging the line, brightest at the crest's intersection); a whisper of vertical light falloff in the sky; the submerged reflection deepened toward Dusk Indigo. Composition detail: crest center sits at ~38% height on the icon grid; waterline at ~55%; reflection ellipse compressed to ~40% of crest height. Full iOS 26 appearance set — dark (already night-toned; keep), tinted (crest as template), clear. Rationale: the concept is proven and precious — polysemous (sun rising / head above water / breath surfacing), habit-neutral, family-safe, rename-proof; only the execution is dated. Preserves recognition for existing TestFlight users.
2. **Waterline Keel.** Above a thin waterline, calm negative space; below, a single rounded keel-weight form in deep indigo hanging steady — the ballast itself. Teal above, indigo below, one white line between. The only concept that literalizes "Ballast" without nautical cliché (anchors read tattoo/navy, and "stuck" contradicts forgiveness). Composition: keel form at 2:3 width-to-depth, centered mass just below the line so it reads *held*, not sinking. Risk: bottom-weighted forms can read as sinking at glance distance — prototype at 29pt before further investment.
3. **Breath Ring.** A single soft teal ring, open at 12 o'clock, crest-dot resting in the gap, on the deep indigo field — momentum ring and breath bloom collapsed into one mark. Connects the icon to the one brand glyph users see daily. Composition: ring stroke ≈ icon-width/11; gap ≈ 28°; dot diameter ≈ 1.4× stroke. Risk: crowded territory (Activity rings, meditation apps); differentiation hangs on the crest-dot surviving small sizes.
4. **First Light.** No shapes: the two-zone horizon field alone with a soft light bloom breathing at the waterline — the moment before dawn. Maximally discreet (indistinguishable from a wallpaper app at shoulder distance — a genuine feature here) and stunning in dark/tinted modes. Risk: too quiet for App Library findability and search-result recall. Keep as the ceiling of restraint the chosen icon is measured against.

Discreet alternates ("Calendar style," "Timer style") remain zero-brand-color by definition, redrawn on the crest's geometric grid for quality parity.

---

## 11. Motion & interaction language

**Doctrine: "Breath, not bounce."** Every animation regulates, orients, or quietly confirms; nothing celebrates loudly, nothing pressures.

| Token | Value | Use |
|---|---|---|
| instant | 100ms linear | Chip ticks, selection tints |
| quick | 200ms easeOut | Press feedback, progress-bar advance |
| standard | 300ms spring 0.35/0.85 | Navigation, sheets, undo banner, slips (always — never marked) |
| calm | 600ms easeInOut | Milestone reveals, ring fills, celebration fades, summary hero settle, erase hold-fill |
| breath | 4-7-8 sinusoid | The pacer — therapeutic content, CoreHaptics-synced, not decoration |
| wave | ~15-min crest curve, sub-1Hz | The panic wave timer — ambient, counts up only |

**Hard rules (unchanged and re-affirmed):** the panic flow entry has ZERO decorative animation — the first frame is the pacer and the <2s budget spends nothing on transitions; widgets never animate (system ticking only); slips move at standard 300ms so logging one feels procedurally identical to any other action; celebrations are a 600ms fade plus one soft haptic — never confetti, never sound by default; nothing ever counts down against the user.

**Signature moments (the complete celebration vocabulary):**
- **The waterline rise** — a milestone unlock renders as the crest lifting over the horizon line in a single 600ms breath. That is the entire celebration vocabulary.
- **The breath bloom** — the 4-7-8 sinusoid, scale + haptics in lockstep; Reduce Motion preserves the rhythm as opacity.
- **The wave** — the urge timer's crest swelling and settling; elapsed time counts up; Reduce Motion renders it still with a slow opacity breath.
- **The quiet settle** — hero numerals (summary, Streak Detail header) fade-up once at calm 600ms; never on re-visits.

**Haptics vocabulary:** breath-synced taps (pacer; the eyes-free mode's primary channel) · light detent ticks (year wheel, CommitmentSlider, chip select) · one soft confirmation tap (milestone, celebration, purchase success) · nothing on slips beyond the standard button response — a slip is never haptically marked. Reduce Motion drops scale and parallax only; rhythm and meaning always survive.

---

*End of blueprint. Coordinate all string proposals through `docs/copy-pass-checklist.md` (founder-owned), all safety copy through clinician + counsel sign-off, and all visual changes with `docs/golden-batch.md` so the snapshot re-record happens exactly once.*
