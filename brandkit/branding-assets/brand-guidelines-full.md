# Frontend Brand Kit: Unhooked — Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Document | Frontend Brand Kit v1.0 |
| Date | 2026-07-07 |
| Inputs | PRD v1.0, MVP Definition v1.0, Architecture v1.0 |
| Scope | v1.0 MVP (EN, iOS 26+), with TR fast-follow noted where it changes design decisions |
| Owner | Brand & design-system lead |

> **Naming caveat (inherited from MVP §naming note):** "Unhooked" is a working title and a rename is a pre-build gate. Everything in this kit is name-agnostic by design — the wordmark slot, icon direction, and ASO section all survive a rename. Where the name appears in examples it is a placeholder.

---

## 1. Brand Essence

### 1.1 Personality (5 adjectives)

1. **Steady** — the brand is the calm hand on the shoulder at 11pm, not the hype coach at 7am. Nothing flashes, nothing counts down, nothing pressures.
2. **Discreet** — the product lives on a lock screen the whole family can see. The brand never outs its user. Discretion is a first-class aesthetic value, not a settings toggle.
3. **Forgiving** — slips are data, not verdicts. Visual and verbal language always leaves the door open. No red, no strikethroughs, no broken-chain metaphors.
4. **Honest** — transparent pricing, no fake urgency, no medical promises, "commonly reported" phrasing. The design mirrors this: real numbers, plain layouts, no dark patterns.
5. **Quietly proud** — streaks are celebrated with warmth, not fireworks. The user's progress is dignified, the way you'd congratulate an adult, not gamify a child.

**Anti-personality (what we are never):** clinical/medical, preachy/moralizing, macho/drill-sergeant ("NoFap warrior" culture), shame-based, cutesy/juvenile, AA-coded (per the Alex persona: no higher-power framing, no recovery-culture jargon).

### 1.2 Tone of Voice

Rules that govern every string in the app:

- **Coach, never judge.** Second person, present tense, short sentences. Verbs over adjectives.
- **The user's words outrank ours.** Panic step 3 renders their own motivations verbatim in the largest type in the app. Our copy frames; theirs stars.
- **Respect the full motivation spectrum without endorsing any.** The quiz motivation picker includes *faith* alongside energy, money, relationships, self-respect, and focus. Copy must work identically for a religiously motivated user quitting porn and a secular "sober curious" user cutting alcohol. Practically: we echo the user's chosen motivation word back to them; we never generate religious (or anti-religious) language ourselves. No "temptation," no "sin," no "purity" — and equally no dismissiveness of users for whom faith is the reason.
- **Clinical nouns for sensitive categories.** "Adult content," not slang; "a slip," not "a relapse" or "a failure" in user-facing copy. (App Review + dignity, same rule.)
- **Never lecture, never diagnose.** The one mandatory cautionary string (alcohol withdrawal notice) is stated once, calmly, and then never repeated.
- **Discreet-mode strings carry zero habit context.** "Day 34" not "Day 34 vape-free"; the Panic intent is titled "Reset" in discreet mode.
- **Localization posture:** copy nuance IS the product (PRD §7). EN ships first; TR fast-follows. Write EN source strings without idioms, sports metaphors, or wordplay so the TR pass can preserve tone rather than fight it. Turkish formal/informal register decision: use warm-informal *sen*, matching the coach voice (locked at L10n kickoff, noted here so strings aren't written in a register that can't translate).

**Three example strings:**

| Context | String | Why it's on-brand |
|---|---|---|
| Slip logged (forgiveness flow) | "Logged. Your best — 34 days — is safe, and your momentum is still 82%. When you're ready, the next hour starts now." | Fact first, identity preserved, no adjective of judgment, agency returned to the user. |
| Panic flow, urge-timer step | "Urges crest and pass — usually within about 15 minutes. You don't have to win forever right now. Just this wave." | Calm, time-boxed, physically framed; no willpower moralizing. |
| Quiet celebration (urge averted) | "That one passed. 12 urges surfed and counting." | Understated pride; a stat, not confetti copy; works verbatim in discreet mode. |

### 1.3 Naming Notes

- Rename is a **pre-build gate** (App Store collisions on "Unhooked/Unhook," including a direct quit-porn app, plus unhooked.health).
- Naming criteria for candidates: (a) no vice named in the app name's *display* on a lock screen — the widget shows the app name in some surfaces, so the name itself must pass the discreet test; (b) works as a neutral word a family member could see ("what's that app?" must have a comfortable answer); (c) pronounceable in Turkish and free of unfortunate TR meanings; (d) clean USPTO knockout + domain + handles per MVP release criteria; (e) subtitle carries the ASO keywords ("Quit Vaping, Porn & Alcohol") so the name itself can stay abstract.
- Directional candidate territories (for the naming sprint, not decisions): *tide/wave* words (urge-surfing metaphor), *unburden/lighter* words, *momentum/steady* words. Avoid: chain/shackle imagery (contradicts forgiveness), fire/burn (reads vape-adjacent), and anything recovery-culture coded.
- The flame streak glyph (🔥-style) is category vernacular and appears in widget content, but the brand mark itself should NOT be a flame — too generic post-Duolingo/Snapchat and too "streak app" rather than "calm intervention."

---

## 2. Color System

Design intent: a **calm, low-arousal palette**. The user opens this app during a physiological urge spike; color must down-regulate, not stimulate. Primary is a deep teal ("cool water" — the urge-surfing metaphor made chromatic). The one hot color in the system is reserved for the streak flame accent, never for alarms.

**Hard rule: no red anywhere in the product.** Errors and cautions use amber. Red is shame/alarm coding this category must not have (PRD non-goal). Destructive actions (erase-all) use amber + explicit copy, not color panic.

### 2.1 Core palette

| Token | Role | Light | Dark | Notes |
|---|---|---|---|---|
| `brand/primary` | Primary actions, links, selection, breath pacer | `#0E7A6F` (deep teal) | `#4CC8B9` (lifted teal) | Light: 5.0:1 on white → passes AA for normal text and UI. Dark: 8.9:1 on `#121417`. |
| `brand/primaryPressed` | Pressed/active | `#0A5F57` | `#6ADACB` | |
| `brand/onPrimary` | Text/icon on primary | `#FFFFFF` | `#08302B` | Dark-mode onPrimary is dark-on-light-teal: 7.4:1. |
| `brand/secondary` | Momentum %, progress fills, secondary chips | `#5B6ABF` (dusk indigo) | `#93A0E8` | Calm counterpoint to teal; used for "momentum" so streak (teal) and momentum (indigo) are never confused. |
| `brand/accentFlame` | Streak flame glyph, milestone moments ONLY | `#E8833A` (ember amber-orange) | `#F29D5C` | Never on buttons, never at >10% of any screen's area. Decorative-size usage exempt from text-contrast rules; when used as text-adjacent glyph it sits beside, not instead of, a labeled value. |

### 2.2 Semantic colors

| Token | Role | Light | Dark | Contrast note |
|---|---|---|---|---|
| `semantic/positive` | Urge averted, adherence day, trial active | `#2E7D4F` | `#6FCE97` | 4.9:1 / 9.3:1 vs respective surfaces. |
| `semantic/caution` | All warnings AND all errors (see hard rule) | `#9A6B00` | `#E5B84B` | Amber, always paired with an icon + text (never color-only). 4.6:1 light, 9.0:1 dark. |
| `semantic/info` | Sync status, passive notices | `#3D6C9E` | `#8FB6E0` | |
| `semantic/paused` | Frozen streak (clock-rollback state) | `#6E7681` | `#9AA3AD` | Neutral gray — a frozen streak is not a problem state. |

### 2.3 Surfaces & content

| Token | Light | Dark | Notes |
|---|---|---|---|
| `surface/base` | `#F7F6F3` (warm off-white) | `#121417` (near-black, slightly cool) | Warm light base avoids clinical white. |
| `surface/raised` | `#FFFFFF` | `#1C1F24` | Cards. |
| `surface/sunken` | `#EEECE7` | `#0B0D0F` | Grouped-list background, quiz progress track. |
| `surface/overlay` | `#FFFFFF` @ 100%, shadow-borne | `#22262C` | Sheets, panic redirect menu. |
| `content/primary` | `#1A1D21` | `#F2F1EE` | 15.6:1 / 15.1:1. |
| `content/secondary` | `#565D66` | `#A8AFB8` | 5.9:1 / 7.4:1 — safe for secondary text at all sizes. |
| `content/tertiary` | `#8A9097` (large text/icons only) | `#6E757E` | 3.2:1-class; never for body copy. |
| `border/hairline` | `#E2E0DB` | `#2B3036` | 1px separators. |

### 2.4 Widget & lock-screen legibility

- **Lock-screen accessory widgets do not use brand color.** iOS renders accessory families in the system's vibrant/tinted material over arbitrary wallpapers; we design them in pure luminance (white/gray hierarchy) and let the system tint. Never rely on teal vs orange distinctions on the lock screen — encode meaning in glyph + text, not hue.
- **Home-screen widgets** use `surface/raised`/`surface/base` backgrounds with `content/primary` numerals; the flame accent may appear at glyph size. Both light and dark widget appearances are mandatory (MVP release gate: render check in light/dark/StandBy).
- **StandBy (night, red-shifted):** the nighttime "you made it through today" state must survive iOS's red-tint night mode — again luminance-only hierarchy, large numerals, no color-encoded meaning.
- **Contrast floor for all widget text:** design to ≥4.5:1 against our own widget backgrounds; for system-material accessory widgets, use the heaviest legible weight (see §3) because vibrancy eats apparent contrast.
- **Discreet variants** use only neutrals + the system tint — zero brand color, zero habit glyphs, so nothing visually links the widget to this app category.

### 2.5 Dark mode philosophy

Dark is the primary design target (evening risk windows; StandBy is bedside). Design dark first, derive light. Dark surfaces are desaturated cool grays, never pure black except `surface/sunken`, to keep OLED smear off the breath-pacer animation.

---

## 3. Typography

Platform-native first: **SF Pro** (Text/Display per size, automatic), **SF Compact** in widgets (system-applied), **SF Pro Rounded** for streak numerals only (warmth without whimsy). **New York/serif is not used.** Turkish is fully covered by SF; no custom font — this keeps Dynamic Type, vibrancy rendering, and localization free.

All roles are bound to Dynamic Type text styles (sizes below are the `.large` default point sizes; they scale).

| Role | Style basis | Size/Weight | Usage |
|---|---|---|---|
| `type/streakHero` | Custom, scales with `.largeTitle` | 64pt / Bold / SF Pro Rounded, monospaced digits | Dashboard streak number. Monospaced digits so the counter doesn't jitter as it ticks. |
| `type/panicReason` | Custom, scales with `.largeTitle` | 40pt / Semibold | The user's own motivations, panic step 3. Largest *text* in the app by design intent. |
| `type/titleXL` | `.largeTitle` | 34pt / Bold | Screen titles, quiz summary headline. |
| `type/title` | `.title2` | 22pt / Semibold | Card titles, paywall plan names. |
| `type/body` | `.body` | 17pt / Regular | Default copy, quiz questions. |
| `type/bodyStrong` | `.body` | 17pt / Semibold | Emphasis, button labels. |
| `type/secondary` | `.subheadline` | 15pt / Regular | Supporting copy, `content/secondary`. |
| `type/caption` | `.footnote` | 13pt / Regular | Legal, renewal terms (must remain legible at largest Dynamic Type — release gate). |
| `type/widgetNumeral` | Widget-family sized | Rectangular ~20pt, circular ring center ~17pt / **Semibold–Bold**, monospaced digits | Heaviest weight that fits: vibrancy on lock screens washes out Regular. |
| `type/widgetLabel` | Widget-family sized | ~12pt / Medium, tracking +0.3 | "DAYS", "SAVED" micro-labels; uppercase EN, sentence-case TR (Turkish uppercase İ/ı pitfalls — avoid all-caps in TR builds). |

Rules: line length ≤ ~34ch for body copy (quiz reads like a conversation, not a form); no light weights anywhere (300-weight fails on vibrancy and at small sizes); numerals monospaced wherever they update live.

---

## 4. Iconography & App Icon Direction

### 4.1 In-app iconography

- **SF Symbols only, v1.** Consistent weight (`regular` scale, matched to text weight via `.symbolRenderingMode`), hierarchical rendering in brand teal for navigation, monochrome in widgets.
- Semantic assignments: breath pacer `wind`/custom concentric-circles glyph; urge timer `timer`; reasons `text.quote`; slip log `arrow.uturn.backward.circle` (a turn, not an X); momentum `chart.line.uptrend.xyaxis`; resources/help `lifepreserver`; erase `trash` paired with amber; discreet mode `eye.slash`.
- **Banned glyphs:** broken chain, skull, warning triangles in slip flows, any habit-specific imagery (bottles, pills, cigarettes) outside the private in-app habit picker — and even there, use abstract category tiles (word + color chip), not literal paraphernalia illustrations, which read as triggers.
- Custom glyph budget (3 max, drawn to SF Symbol grid): the brand mark, the breath-pacer bloom, the momentum ring.

### 4.2 Primary app icon (described)

- **Concept: "the surfaced breath."** A single rounded shape — a soft circle cresting a horizon line, readable as (a) a sun rising, (b) a head above water, (c) a breath bubble surfacing. Deliberately polysemous and habit-neutral.
- Composition: deep-teal-to-dusk-indigo vertical gradient field (`#0E7A6F → #5B6ABF` territory, tuned for icon), warm off-white crest shape occupying the upper-center, thin horizon line at the lower third. No letterforms (survives rename), no flame, no chain, no lock.
- Must read at 29pt: one shape, one line, two tonal zones. Test in grayscale and against both light/dark home screens.
- iOS 26 icon appearances: provide dark and tinted variants (tinted mode = crest shape as the template).

### 4.3 Alternate (discreet) icons — P0 feature

- **"Calendar-ish":** neutral gray-white tile, abstract month-grid dots, today-dot in system blue. Must NOT clone Apple Calendar (review risk) — no red, no day number, different grid rhythm.
- **"Timer":** dark slate tile, thin circular dial with a single index mark. Utilitarian, brandless.
- Both alternates carry zero brand color and zero crest mark — the entire point is unlinkability. Their names in the icon picker are literal ("Calendar style," "Timer style").

---

## 5. Layout & Spacing

- **Grid:** single-column, content max-width 560pt (iPad-safe without a separate layout), 20pt default screen margins (16pt on 320-class widths via layout margins).
- **Spacing tokens (4pt base):** `space/1`=4, `/2`=8, `/3`=12, `/4`=16, `/5`=20, `/6`=24, `/8`=32, `/10`=40, `/12`=48. Vertical rhythm: 24 between sections, 12 within a card, 8 label-to-value.
- **Corner radii:** `radius/s`=10 (chips, inline controls), `radius/m`=16 (cards, list groups), `radius/l`=24 (sheets, paywall plan cards), `radius/full` (pills: primary buttons, quiz answer chips). Widgets use system-provided container shapes — never draw our own widget corner masks.
- **Elevation:** two levels only. Level 0 = flat on `surface/base` with hairline borders (default; dark mode relies on surface-tone steps, not shadows). Level 1 = sheets/overlays: `shadow(color: black 12%, y: 8, blur: 24)` light mode; dark mode uses surface lightening + hairline instead of shadow. No level 2 — the app is 6 screens; depth restraint is part of the calm.
- **Touch targets:** 44pt minimum everywhere; **panic-flow and slip-flow controls 56pt minimum** (users are agitated; fat-finger tolerance is a safety feature). The lock-screen Panic button occupies the full tappable widget region.
- **One-hand rule:** all primary actions in the lower 60% of the screen; quiz "continue" is a bottom-pinned bar.

---

## 6. Component Inventory (MVP)

Fifteen components cover the v1.0 surface. States listed are the design-required set; all components have Dynamic Type + VoiceOver behavior per §8.

1. **PrimaryButton** (pill, `brand/primary`) — states: default, pressed (`primaryPressed`, scale 0.98), disabled (40% opacity, never hidden), loading (inline spinner replaces label, width locked). Used for quiz continue, paywall CTA, panic-step advance.
2. **QuietButton** (text-only, `content/secondary`) — the escape hatch: "Skip," "Not now," "Restore purchases." Always visible wherever a PrimaryButton pushes forward; transparent-pricing stance means the quiet path is never hidden or shrunk below `type/body`.
3. **PanicEntryButton** (in-app floating variant of the panic affordance) — 56pt, teal, `wind` glyph + "Panic" (discreet: "Reset"). Persistent on dashboard. States: default, pressed; no disabled state exists by design (help is never disabled).
4. **QuizStepScreen** — one question, progress bar (thin `brand/secondary` fill on `surface/sunken`), answer chips (single/multi-select pills: default / selected (teal fill, onPrimary text) / pressed), bottom-pinned continue. Back always available; answers persist on back-navigation.
5. **AnswerChip / TriggerChip** — pill, `radius/full`; multi-select shows checkmark glyph, not color alone.
6. **CommitmentSlider** — custom slider with haptic detents; value echoed in words ("Ready to start today"), never just a number.
7. **QuitSummaryCard** (quiz payoff screen) — hero savings figure (`type/streakHero` scale), risk-window line, motivation echo. This card's visual quality carries the conversion; it is the most designed single screen in the app.
8. **PaywallView** (Superwall-hosted, but design-specified here) — plan cards (`radius/l`; annual pre-selected with "3-day free trial" badge in `semantic/positive`; annual price is the Superwall-driven $29.99-vs-$39.99 A/B, so the price label is data-bound, never hardcoded), price + renewal terms at `type/caption` minimum legible size, visible close affordance after variant rules, restore + terms links as QuietButtons. **Banned within:** countdown timers, fake discounts, "one-time offer" copy — the transparent-pricing stance is a design contract, not just copy.
9. **StreakDashboardCard** (one per quit, up to 3) — streak hero numeral, flame glyph, money saved, momentum ring (`brand/secondary`), next-milestone progress bar. States: active, frozen (`semantic/paused` + "streak paused — clock issue, it'll self-heal" tooltip), reduce-mode (adherence framing), discreet (numbers only).
10. **BreathPacerView** — full-screen bloom animation (§7) + haptic pattern; states: running, haptics-only (screen shows static instruction + progress ticks), skipped. Respects Reduce Motion by switching to opacity pulsing.
11. **ReasonsView** (panic step 3) — user motivations at `type/panicReason`, one per screen-height page, vertical paging. Empty state (no motivations captured): falls back to category-generic encouragements from `panicScript.json` — never blank.
12. **RedirectMenu** (panic step 4) — 3 large list rows (60-second action / journal one line / exit options), 56pt targets.
13. **SlipSheet** — two-tap flow: confirm → forgiveness screen (best archived, momentum %, optional reflection field with autosave, 10-minute **UndoBanner** persisting across app relaunch). States: confirming, logged, undo-available, undone. Copy locked by the zero-shame checklist.
14. **Widget family templates** (6): `accessoryRectangular` (streak + saved + Panic button; discreet variant), `accessoryCircular` (day ring), `accessoryInline` (one line; discreet "Day 34"), `systemSmall` (streak + momentum), `systemMedium` (adds money + milestone bar), StandBy pair (night state). Every family ships: normal, discreet, stale-grace (last-known value keeps ticking via `timerInterval`), and placeholder/redacted states.
15. **ResourceScreen + CautionNotice** — helpline list (region-aware), "when to seek help" copy; the alcohol withdrawal notice as a one-time amber `semantic/caution` card, calm typography, no icon-of-alarm larger than 17pt. Reachable in one tap from Settings and every slip flow. Also covers **EmptyState** pattern (no quits yet: single centered illustration-free card, "Start your first quit" + one button — restraint, not mascot art).

---

## 7. Motion

Motion philosophy: **breath, not bounce.** Every animation either regulates (pacer), orients (navigation), or quietly confirms (log feedback). Nothing celebrates loudly; nothing pressures.

| Token | Duration | Easing | Use |
|---|---|---|---|
| `motion/instant` | 100ms | linear | State ticks, chip selection. |
| `motion/quick` | 200ms | easeOut | Button press feedback, sheet content fades. |
| `motion/standard` | 300ms | spring(response 0.35, damping 0.85) | Navigation pushes, sheet presentation, undo banner. |
| `motion/calm` | 600ms | easeInOut | Milestone reveal, quiet-celebration fade, momentum ring fill. |
| `motion/breath` | 4s in / 7s hold / 8s out (4-7-8 pattern) | sinusoidal (custom curve mirroring exhalation) | Breath pacer bloom, synced to CoreHaptics; 60fps via TimelineView. |

Rules:

- **Panic flow entry has zero decorative animation** — the first frame is the pacer, immediately; the <2s budget spends nothing on transitions.
- **Widgets: animation is banned.** WidgetKit timelines are static by platform design; we additionally ban simulated animation (rapid timeline entries) — battery, refresh budget, and lock-screen calm all say no. The only "motion" in widgets is system-driven `Text(timerInterval:)` ticking.
- **StandBy: no motion**, night-mode-safe static states only.
- **Celebrations:** urge-averted and milestones get `motion/calm` fades + a single soft haptic — never confetti, never sound by default.
- **Reduce Motion:** pacer becomes opacity pulsing at the same rhythm (rhythm is therapeutic content, so it's preserved; parallax/scale is what's dropped); all springs become 200ms crossfades.
- Slip flow uses `motion/standard` only — a slip must feel procedurally identical to any other log, not cinematically marked.

---

## 8. Accessibility

- **Dynamic Type:** all roles bound to text styles (§3); release gate requires largest accessibility size without truncating streak numerals or paywall renewal terms. `streakHero` caps its scaling at accessibility-XL and switches the dashboard card to a stacked layout rather than shrinking.
- **VoiceOver:** full pass through quiz, panic, and slip flows is an MVP acceptance criterion. Specifics: pacer announces phase changes ("Breathe in… hold… out") in sync with haptics; streak card is a single accessibility element ("34 days, 412 dollars saved, momentum 82 percent"); the widget Panic button has an explicit label ("Panic — opens a 90-second urge exercise"; discreet: "Reset"); undo banner is announced as a time-limited action; decorative flame glyph is hidden from the accessibility tree.
- **Haptics-only pacer:** first-class mode (settings + inline offer on first pacer run) for users who need eyes-free or screen-off regulation; CoreHaptics pattern carries the full 4-7-8 rhythm.
- **Color independence:** no meaning is ever color-only (amber cautions carry icon + text; selected chips carry checkmarks; momentum vs streak are labeled, not just hued). Palette passes common CVD simulations because teal/indigo/amber are separated in luminance, not just hue.
- **Motor:** 44pt global / 56pt panic-and-slip targets; undo window is generous (10 min) partly as a motor-error accommodation.
- **RTL & localization:** v1 is EN, TR fast-follow — both LTR, so no RTL surface ships in v1. However: build with leading/trailing (never left/right) semantics, and keep the momentum ring and progress bars direction-agnostic, so a future Arabic localization (plausible for this category) is a strings job, not a re-layout. TR specifics now: avoid all-caps labels (İ/ı casing), leave +30% string expansion room in widget labels and buttons, currency formatting via locale (₺ symbol position differs), and re-run the tone/no-shame copy checklist on TR strings as a distinct gate — tone does not survive naive translation.
- **Cognitive load:** one question per quiz screen, one action per panic step, skippable everything — the accessibility posture and the product design are the same design.

---

## 9. App Store Presence

### 9.1 Icon on the store

Primary icon per §4.2 (the crest/breath mark). It must sit comfortably in Health & Fitness grids next to clinical blues and hype gradients — the warm-teal calm is the shelf differentiator. Never use the discreet alternates in store marketing (they're a private feature, and showing them *is* the screenshot story, not the icon).

### 9.2 Screenshot narrative (7 frames)

Per MVP release criteria: lock-screen widget, panic flow, and discreet mode must appear; privacy positioning in the first three captions. Device frames on `surface/base`-tinted backdrops, caption in `type/titleXL` weight, dark-mode set rendered too.

| # | Frame | Caption (draft) |
|---|---|---|
| 1 | Lock screen with rectangular widget: streak + Panic button | "Your streak on your lock screen. Help one tap away." |
| 2 | Panic flow breath pacer mid-bloom | "Urges pass. This 90-second reset helps them pass faster. No account. Everything stays on your device." |
| 3 | Discreet mode: numbers-only widget + Calendar-style icon on a home screen | "Discreet mode. Your quit is nobody's business. On-device, no sign-up, one-tap erase." |
| 4 | Dashboard: 3 quit cards (vape/adult content/alcohol), money saved | "Quit up to three habits at once. One app, one price." |
| 5 | Slip screen showing archived best + momentum 82% | "A slip isn't day zero. Your best is saved. Your momentum survives." |
| 6 | Quiz summary card: projected $1,340/year + risk window | "90 seconds of questions. A plan that's actually yours." |
| 7 | Pricing/trust frame: plans with plain renewal terms | "3-day free trial. No countdown timers. No tricks. Cancel in one tap." |

Frame 5 is the differentiator frame; keep it in the first-page scroll on all device sizes. Adult-content references stay clinical in all frames (frame 4 card reads "Adult content," never explicit terms — ASO metadata rule).

### 9.3 Subtitle & keyword hints

- **App name (30 chars):** `[Name]: Quit Vaping & Drinking`-pattern — carry two vice terms in the name, the third in subtitle, since "porn" in the *name* field is a store-presentation risk; final split decided at rename. If review tolerance allows, PRD's full "Quit Vaping, Porn & Alcohol" stands.
- **Subtitle (30 chars) candidates:** "Streak widget & panic button" / "Quit habits. Keep momentum." — leading with the two ownable nouns (widget, panic button).
- **Keyword field themes (no explicit terms, per §6.7):** quit vaping, quit drinking, sober, nofap-adjacent clinical terms ("porn addiction" is commonly indexed via subtitle/name only — keep field terms to: quit, sober, streak, habit, tracker, urge, relapse, alcohol free, nicotine, dopamine detox, panic button, widget).
- **Promotional text:** rotate the privacy line — "No account. No cloud we control. One-tap erase." — this is the review-magnet claim competitors can't copy-paste.
- **What we never do in ASO:** before/after imagery, fear statistics, fake ratings badges, explicit terminology, medical claims ("recover," "treatment," "addiction cure" are all banned strings).

---

## 10. Token Sketch (illustrative, for the eventual design-token file)

```json
{
  "color": {
    "brand":   { "primary": {"light": "#0E7A6F", "dark": "#4CC8B9"},
                 "secondary": {"light": "#5B6ABF", "dark": "#93A0E8"},
                 "accentFlame": {"light": "#E8833A", "dark": "#F29D5C"} },
    "semantic":{ "positive": {"light": "#2E7D4F", "dark": "#6FCE97"},
                 "caution":  {"light": "#9A6B00", "dark": "#E5B84B"},
                 "info":     {"light": "#3D6C9E", "dark": "#8FB6E0"},
                 "paused":   {"light": "#6E7681", "dark": "#9AA3AD"} },
    "surface": { "base": {"light": "#F7F6F3", "dark": "#121417"},
                 "raised": {"light": "#FFFFFF", "dark": "#1C1F24"},
                 "sunken": {"light": "#EEECE7", "dark": "#0B0D0F"} },
    "content": { "primary": {"light": "#1A1D21", "dark": "#F2F1EE"},
                 "secondary": {"light": "#565D66", "dark": "#A8AFB8"} }
  },
  "space":  { "1": 4, "2": 8, "3": 12, "4": 16, "5": 20, "6": 24, "8": 32, "10": 40, "12": 48 },
  "radius": { "s": 10, "m": 16, "l": 24, "full": 9999 },
  "motion": { "instant": 100, "quick": 200, "standard": 300, "calm": 600 },
  "touch":  { "min": 44, "panic": 56 }
}
```

---

## 11. Open Design Questions

1. Final name → wordmark, icon lockup, and the name/subtitle keyword split (§9.3) all pend the naming sprint.
2. Panic intent discreet title "Reset" vs "Breathe" — user-test which draws fewer family questions and more real-moment taps.
3. Whether the momentum ring or the milestone bar earns the systemSmall widget's second data slot (only one fits at accessibility sizes).
4. TR register (*sen* vs *siz*) formally locked with the L10n pass, per §1.2.
