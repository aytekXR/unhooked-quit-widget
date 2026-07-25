# Ballast — Creative Asset Inventory

Complete production inventory of every visual asset for the Ballast redesign and launch. Companion to the brand direction and the UI redesign, copy, marketing, and roadmap docs written from the same direction block. Brand facts (hexes, taglines, names) are quoted verbatim from that direction and must not drift — `App/Sources/DesignSystem/Theme.swift` / `docs/design/tokens-v2.md` are the color record; `brandkit/branding-assets/tokens.json` carries stale pre-correction hexes and must be regenerated, never referenced.

Standing invariants that bind every asset below: no red anywhere (Low Sun `#8C6100` amber carries all warnings and errors); no habit imagery ever (no bottles, pills, cigarettes, screens-of-doom); no people, hands, or mascots; widgets stay luminance-only; the panic path's first frame gets zero decorative pixels; discreet surfaces carry zero brand color; copy bytes are founder-owned — asset text shown here is layout-intent placeholder unless it quotes a shipped string.

---

## 1. App icon concepts

Four concepts, one recommendation. All render on the **Horizon Gradient** — Harbor Teal `#0C6F65` sky into Dusk Indigo `#5262BC` water — the brand's sky-to-sea field, reserved for the icon and marketing only.

### 1.1 Surfaced Breath — Refined (RECOMMENDED — build this)

- **Composition:** The existing crest geometry, re-rendered: a soft Foam-toned circle (`#FFFFFF` at ~92% opacity, feathered 2% edge) rising over a thin horizon on the vertical Horizon Gradient. Changes from the current render (`brandkit/branding-assets/icons/AppIcon-light-1024.png`): crest enlarged ~8% for grid presence; the hard 1px horizon replaced by a **luminous waterline glow** (4–6px soft-light band, Foam at 35% over the gradient seam); a whisper of vertical light falloff in the sky (top 15% brightened ≤6%); the submerged reflection deepened (crest mirrored below the line at 18% opacity, vertically compressed 60%).
- **Palette:** `#0C6F65` → `#5262BC` vertical field; crest and waterline in `#FFFFFF`; nothing else.
- **Rationale:** The concept is proven and precious — polysemous (sun rising / head above water / breath surfacing), habit-neutral, comfortable on a family-visible home screen, rename-proof with no letterforms. Only the execution is dated (flat 2014-class gradient, hairline that vanishes at 29pt). Refinement preserves recognition for existing TestFlight users.
- **Variants:** Full iOS 26 appearance set via Apple Icon Composer — **dark** (already night-toned: deepen field toward `#121417`-adjacent indigo, keep crest luminous), **tinted** (crest + waterline as a single template shape), **clear** (crest on glass). Keep the zero-brand-color discreet alternates (`AppIconCalendar`, `AppIconTimer`) exactly as shipped — they are a privacy feature, not a brand surface, and the erase flow's reset-to-primary behavior depends on them.

### 1.2 Waterline Keel (prototype at 29pt before further investment)

- **Composition:** Above a thin Foam waterline, calm negative space in Harbor Teal `#0C6F65`; below it, a single rounded keel-weight form in deep indigo (`#5262BC` shaded toward `#0A5F57` seam) hanging steady, centered, occupying ~30% of the lower field. One white line between.
- **Rationale:** The only concept that literalizes "Ballast" without nautical cliché (anchors are banned territory — tattoo/navy connotations, and "stuck" contradicts forgiveness). Semantically the truest mark: steadiness comes from what's below the surface. Risk: bottom-weighted forms can read as "sinking" at glance distance.
- **Variants:** dark / tinted straightforward (keel as template shape).

### 1.3 Breath Ring (argue against, keep on file)

- **Composition:** A single soft Harbor Teal ring (dark-mode teal `#4CC8B9` for luminosity on the deep field), open at 12 o'clock, crest-dot resting in the gap, on a Dusk Indigo `#5262BC`-to-near-black field.
- **Rationale:** Collapses the momentum ring and breath bloom — the two glyphs users see daily — into one mark. Risk: ring marks are crowded territory (Activity rings, meditation apps); differentiation depends entirely on the crest-dot surviving 29pt.

### 1.4 First Light (the ceiling of restraint — measure the winner against it)

- **Composition:** No shapes: the two-zone horizon field alone, teal over indigo, a soft light bloom breathing at the waterline.
- **Rationale:** Maximally discreet — indistinguishable from a wallpaper app at shoulder distance, a genuine feature for this audience. Risk: near-invisible recall in App Library and search results. Do not ship; use as a benchmark.

**Deliverables:** 1024×1024 masters per concept ×4 appearances (light/dark/tinted/clear), 29pt and 60pt proof renders on a real home-screen mock, one side-by-side board. Winner replaces `App/Resources/Assets.xcassets/AppIcon.appiconset` and all sizes in `brandkit/branding-assets/icons/`.

---

## 2. Illustration system spec — "Waterline fields"

The brand's second visual move and the cure for the app's one-template sameness (centered SF glyph + text, seven screens running — see `App/Sources/AgeGate/AgeGateView.swift`, `App/Sources/PanicFlowView.swift`, `App/Sources/SafetyResourcesView.swift`).

**Style, precisely:**

- **Geometry:** Layered flat horizontal bands of the Horizon Gradient (Harbor Teal `#0C6F65` sky into Dusk Indigo `#5262BC` water; dark-mode fields shift toward `#121417`-anchored night tones with `#4CC8B9`/`#93A0E8` accents). Two to four bands maximum per composition. Band edges are either razor-flat or one long low sine (amplitude ≤4% of canvas height, one crest visible). No diagonal horizons.
- **Light-forms:** Exactly one per composition — the crest circle, its glow, or a soft radial bloom at the waterline. Foam `#FFFFFF` at 25–92% opacity, feathered edges. One subtle radial glow maximum.
- **The waterline:** A thin luminous line (1–2pt at UI scale, proportionally heavier in marketing), Foam over the band seam. It is the reusable signature: hairline divider under hero numbers, the summary card's horizon, the level the crest rises over in milestone moments.
- **Line weight & fills:** No outlines anywhere — this is a fill system. Where a stroke exists (waterline, ring), it is luminous, rounded-capped, and never dark-on-light.
- **Texture:** None above 3%. A barely-there vertical grain (≤3% monochrome noise) is permitted on marketing canvases only; in-app fields are perfectly flat.
- **Palette usage:** Backgrounds spend only Horizon Gradient tones + Foam. Ember `#E8833A` (`#F29D5C` dark) appears only at glyph scale in milestone contexts, never as a field, never above 10% of a canvas. Moss `#2C774B`, Low Sun `#8C6100`, Slate `#3D6C9E` never appear in illustration — they are semantic UI colors.
- **Character treatment:** There are no characters. No mascots, no people, no hands, no photography, no habit imagery, ever. The "protagonist" of every composition is light over water.
- **Grayscale test:** Every composition must remain legible with saturation removed — value structure carries the image, not hue.

**What it must never look like:** Corporate-memphis blob people; gradient-mesh SaaS slop; stock "serenity" photography (lotus, stones, sunsets with lens flare); AA-coded iconography (chains, mountains-summited, sunrise-with-birds triumphalism); Headspace's cartoon warmth (wrong register — we are adults at 11pm); anything with eyes. If a composition could headline a generic wellness newsletter, it has failed.

**Reference caliber:** Rothko color-field calm drawn with iOS-system precision. Aim between **Calm's** restraint (without its photographic literalism), **Linear's** dark-field luminosity (without its tech-coldness), and **Stripe's** compositional discipline (without its exuberant color count). Headspace is the warmth benchmark but never the drawing style.

**Where it lives / never lives:** Lives — quiz interstitials, summary card backdrop, empty states, milestone unlock cards, share cards, App Store screenshot backdrops, social, landing page. Never — widgets (luminance-only doctrine, `Shared/Sources/StreakWidgetViews.swift`), the panic path's first frame (ADR-6 latency budget), any discreet surface (zero brand color is the disguise), the app-switcher shield (`App/Sources/AppSwitcherPrivacyOverlay.swift` stays deliberately blank).

**Master library to produce:** 12 field compositions — 4 "day" (lighter teal-dominant), 4 "dusk" (balanced, the default), 4 "night" (indigo-dominant, dark-mode-first — evenings are the stated risk window). Each at 3000×3000 master with safe crops for 1:1, 4:5, 9:16, 16:9, and a 3:1 banner.

---

## 3. Mascot evaluation

**Recommendation: AGAINST. Firmly, permanently, at the constitution level.**

Rationale:

1. **Register.** The archetype is the calm hand on the shoulder at 11pm — a steady friend, not a companion creature. A mascot infantilizes the exact moment the product exists for: an adult mid-craving. "Never cutesy" is on the anti-personality list, and this audience (a 26-year-old quitting adult content, a 31-year-old sober-curious professional) would experience a cheering blob as contempt.
2. **Discretion.** The shoulder test governs every surface. A recognizable character on a lock-screen widget, notification, or home screen is a memorable identifier — the precise thing discreet mode, alternate icons, and the app-switcher shield exist to prevent. A mascot is an anti-privacy feature.
3. **Shame mechanics.** Mascots demand emotional states. A creature that celebrates streaks must do *something* on a slip — and any legible reaction (drooping, sadness, even studied neutrality) is a shame render. The product's thesis is that a slip renders procedurally identically to any other log (`App/Sources/SlipFlowView.swift`). A mascot cannot comply.
4. **The role is filled.** The crest — the circle rising over the waterline — already carries identity, warmth, and continuity from icon to celebration watermark to empty state. It is polysemous, silent, and incapable of judging anyone. Spend the budget making the crest ubiquitous, not inventing a competitor to it.

If future marketing ever needs a "character," the answer is the crest as a light-form — animated with the 4-7-8 breath, never given a face.

---

## 4. Onboarding illustrations

Design idea: **one continuous horizon, not thirteen paintings.** The quiz (`App/Sources/Quiz/QuizFlowView.swift`, driven by `quizConfig.json`) gets a single persistent Waterline field rendered behind `OnboardingScaffold`, whose state advances with progress — the emotional twin of the progress bar. Day tones at step 1 drift to dusk by the commitment slider; the crest, absent at the start, is fully surfaced at the summary. This adds personality without per-step art production, keeps scroll performance flat, and never competes with the question. Fields render at ≤12% opacity behind content on Canvas `#F7F6F3` / `#121417` so all 34 WCAG-pinned pairs hold; the a11y contract (text styles, pinned actions) is untouched.

Per-step spec (subject / composition / mood). Steps marked ● get an additional foreground element; unmarked steps get field-state only:

| Step | Subject | Composition | Mood |
|---|---|---|---|
| Age gate ● | **The first brand moment**: crest mark half-risen over the waterline, small, above the title | Crest glyph (from the three-mark custom budget) at ~48pt, centered over a hairline waterline divider; field at day tone | Welcoming, unhurried — "you're in the right place" |
| 1. Habit picker | Field only, day tone, no crest | Word + color-chip tiles carry the screen (never vice illustrations) | Neutral, judgment-free |
| 2. Custom name | Field dims to 6% under keyboard | Waterline hairline above the input well is the only ornament | Respectful — their word, their screen |
| 3. Analytics consent | Field pauses (no advance) | Deliberately still; consent must not feel like momentum | Honest, flat, unhurried |
| 4. Frequency | Field advances one tone | Low sine appears in the top band — the first visible wave | Matter-of-fact |
| 5. Weekly spend | Field yields to keyboard (6%) | Waterline hairline above the decimal field; Moss is reserved for the summary payoff, not here | Practical, no guilt about the number |
| 6. Duration | Field advances; second band deepens | Longer wavelength on the sine — time made visible | Patient |
| 7. Triggers | Field: dusk begins | Bands shift toward `#5262BC`; this is the emotional register of "evenings are hard" | Understood, not warned |
| 8. Prior attempts | Field holds dusk; a faint second waterline appears below the first | Two lines = past attempts still count; nothing sinks | Forgiving — attempts are data, not verdicts |
| 9. Motivations ● | The user's words start to matter: selected chips gain the selection tint (primary @12%) | Field quiet behind; their words are the art | Quietly proud |
| 10. Effects | Field: dusk deepens | No new elements | Steady |
| 11. Goal (quit / cut down) | Field splits tone subtly between the two chips' rows | Equal visual weight — "cut down" is as legitimate as "quit" | Non-hierarchical |
| 12. Weekly allowance | Field as step 5 (keyboard-yielding) | Stepper on sunken well | Practical |
| 13. Commitment slider ● | Crest begins to rise as the slider moves right | Crest opacity/elevation keyed to slider value — the one moment UI state drives the field directly | Gently momentous |
| Summary (payoff) ● | **Full composition** — the drama the .largeTitle cap took away (`App/Sources/Quiz/QuizSummaryView.swift`): crest fully surfaced, luminous waterline as the card's horizon under the savings hero | Raised card sits on a night-tone field crop; waterline hairline separates hero from risk-window line; Moss `#2C774B` money numeral over it | Earned, calm, "this is yours" |
| Widget-adoption step (NEW — serves the D1 ≥40% north star) ● | Faithful render of the lock screen with the rectangular widget ("Day 1" + wind glyph), on a dusk field | Device-frame mock, actual widget pixels (from `StreakWidgetViews.swift` goldens, never fabricated states), one finger-free "Add" affordance below | Practical magic — "help before you even unlock" |

Interstitials: the PRD's never-built encouragement moments become exactly two, matching the copy deck §3 — **A** "Past tries count." after step 8 (prior attempts, shown only when it isn't a first try) and **B** "A slip is never day zero." before step 11 (goal) — using field-state transitions and the copy deck's founder-gated strings, not new art objects.

---

## 5. Empty-state artwork

| Surface | Asset | Spec |
|---|---|---|
| **Zero-quit dashboard** (needed the moment quit deletion ships; brandkit specs it, code lacks it — `App/Sources/RootPlaceholderView.swift`) | *Crest at dawn* | Day-tone Waterline field crop (top third of screen, fading to Canvas), crest half-risen, waterline hairline under the headline. CTA in Harbor Teal. This is the empty state that must feel like an invitation, not an absence. |
| **Safety resources, GLOBAL region** (renders zero phone rows by policy — `App/Sources/SafetyResourcesView.swift`) | *Deliberate calm, minimal* | No illustration expansion. One lifepreserver glyph (existing vocabulary), waterline hairline, generous space around the findahelpline.com pointer. A decorated help-vacuum would read as evasion; restraint is the honest render. Never gate or bury this surface. |
| **Panic quit picker** (`PanicPlaceholderView.swift`) | **None — explicitly art-free** | On the cold panic path; ADR-6 forbids new pixels/IO. Replace `circle.dashed` rows with the design system's 56pt card-rows (UI doc §6.9) and stop there. |
| **Reflection notes / future journal** (notes are written today, never resurfaced) | *Still water* | Night-tone field at 8%, no crest (nothing has surfaced yet), single waterline. Reserve in the library now; ships with the journal surface. |
| **Milestone list** (future surface for the 43 dormant milestone bodies) | *Horizon with markers* | Dusk field, waterline with 3–4 faint crest-dots at intervals along it — the ladder ahead, none lit. Ember is reserved for unlocked states only. |
| **Widget gallery previews** (system surface) | No art — text-only by CI lint | The habit-leak lexicon gate owns these strings; do not add imagery. |

---

## 6. Success / celebration artwork and moments

The entire celebration vocabulary is: **a 600ms fade plus one soft haptic.** Never confetti, never sound by default, never fireworks. Pride is quiet and factual.

1. **Quiet celebration (urge passed)** — `PanicFlowView` exit. Add the crest as a watermark: 15% opacity, large, low on the canvas, rising 8pt during the existing 600ms fade behind the shipped string "That one passed. That's the whole skill — surfing the wave instead of fighting it." Reduce Motion: opacity fade only. No other change — this screen's restraint is correct.
2. **Milestone unlock card (NEW — the retention loop)** — dashboard card, on unlock of any of the 43 bodies in `milestones.json`. Composition: dusk Waterline field crop inside a radius-24 raised card; the crest lifts over the waterline in the sanctioned **waterline rise** (§7.2); milestone body in `.body` with its "commonly reported" hedge intact; the flame glyph may render in Ember `#E8833A` here — one of only two places Ember is spent, ending the palette's cold drift. Dismiss is a quiet button. Never modal, never blocking.
3. **Averted-urge stat surface (NEW)** — a small dashboard line: crest-dot glyph + "12 urges surfed and counting" (existing brandkit example copy; founder confirms bytes). No animation beyond the standard 300ms appearance. A stat, not confetti copy.
4. **Best-streak archive on slip — deliberately NOT a moment.** The slip flow's forgiveness screen keeps its neutral sunken cards and standard 300ms motion. Any celebration-adjacent art here would cinematically mark the slip. This is a named anti-deliverable.
5. **Purchase / trial start confirmation** — no artwork. Standard sheet dismissal into the dashboard, which is itself the reward.
6. **Share card (P1, anonymous-safe)** — 1080×1080 export: night field, crest, waterline, "Day 34" in SF Rounded-equivalent numerals, no habit words anywhere (same rule as widgets), small Ballast wordmark. Template lives in the marketing library (§9).

---

## 7. Lottie / motion assets

**Platform ruling first:** in-app motion stays **native SwiftUI** — the breath pacer is TimelineView + CoreHaptics (`App/Sources/BreathPacer.swift`, `LiveHapticsEngine.swift`) and must remain so (haptic sync, Reduce Motion variants, Dynamic Type, and the panic latency budget all live in code, not JSON). Lottie/Rive are **marketing-and-web-only** formats here. Every in-app spec below is an implementation spec for SwiftUI; the Rive/Lottie column says whether a marketing replica is needed.

| # | Name | Trigger | Duration | Easing character | Marketing replica |
|---|---|---|---|---|---|
| 7.1 | Breath Bloom | Panic pacer (exists) | 4-7-8 ×3 (~57s) | Sinusoid, therapeutic content | **Rive** (landing + TikTok) |
| 7.2 | Waterline Rise | Milestone unlock | 600ms | calm easeInOut | Lottie (social) |
| 7.3 | Urge Wave | Panic timer step | live, ~15 min | continuous decay | Rive (demo) |
| 7.4 | Crest Surfacing | Age gate first appear | 600ms, once | calm easeInOut | — |
| 7.5 | Ring Fill | Dashboard card appear (exists) | 600ms | calm easeInOut | — |
| 7.6 | Widget-Add Guide | Widget-adoption step | ~6s loop | standard 300ms springs | Lottie (web reuse) |
| 7.7 | Hero Loop | Landing page hero | 19s loop | sinusoid | Rive (primary) |

Frame-by-frame descriptions:

- **7.1 Breath Bloom (existing — do not rebuild, replicate for marketing):** a 220pt Harbor Teal circle at bloom alphas .25/.28/.35; scale swells over 4s (in), holds 7s with a ±1% shimmer, contracts over 8s (out), synced to CoreHaptics; three rounds. Reduce Motion: same rhythm as opacity pulsing. The Rive replica must match the timing exactly — the rhythm is the brand.
- **7.2 Waterline Rise:** frame 0 — card visible, field flat, crest hidden below the waterline; 0–300ms — the waterline brightens (Foam 20%→45%) as the crest's upper arc breaks the line; 300–520ms — crest rises to rest half-surfaced, its reflection stretching below; 520–600ms — glow settles, flame glyph (Ember) fades in at caption scale, one soft haptic at ~520ms. One breath, done. Reduce Motion: crest cross-fades in place, waterline brightens, no translation.
- **7.3 Urge Wave (the panic timer step's live visual — replaces the static SF timer glyph):** a single wave profile drawn as a luminous line on the quiet field; at entry the crest is at its peak amplitude; over ~15 minutes (TimelineView-driven, no timers-as-countdown — nothing displays digits counting down against the user) the amplitude decays exponentially toward a flat waterline. The user literally watches the wave pass. A faint dot marks "now" riding the profile. Reduce Motion: amplitude renders as a slowly fading band opacity. Never blocks "I'm ready to keep going." First frame renders from pre-cached state only — zero added IO on the cold path.
- **7.4 Crest Surfacing:** the age-gate crest rises 8pt and fades from 0→100% over 600ms on first appear only; static thereafter and on subsequent launches. Reduce Motion: fade only.
- **7.6 Widget-Add Guide:** looped device mock — lock screen dims in, the widget gallery sheet slides up (300ms spring), the Streak widget card highlights, a tap ripple, the widget lands on the lock screen, hold 2s, loop. All UI states are golden-derived pixels, never fabricated (the story-panic social PNG's invented "VAPE-FREE" widget is the cautionary precedent — that state violates the habit-leak rule and cannot exist).
- **7.7 Hero Loop:** the full-bleed landing field breathing at 4-7-8 (19s cycle) — waterline glow swells and settles, crest drifts ≤4px. Autoplays muted; respects `prefers-reduced-motion` by holding the peak frame.

---

## 8. Background graphics, decorative elements, hero artwork

- **Horizon Gradient field (master):** `#0C6F65` → `#5262BC` vertical, the base of every marketing canvas. Never a text background without the pinned black 55% scrim; never inside app UI chrome; never in widgets.
- **Waterline hairline (in-app decorative token):** a 1pt luminous rule replacing the plain hairline `#E2E0DB` / `#2B3036` in exactly three places — under the summary hero, under the dashboard's Day N hero, above panic exit actions. Everywhere else, the plain hairline stays. Ration it or it becomes wallpaper.
- **Field crops for in-app surfaces:** the quiz's single continuous onboarding field (§4, ≤12% behind content), summary backdrop (night, ≤12% behind content), zero-quit empty state (day), milestone cards (dusk). Nowhere else in v1 — the dashboard's chrome, settings, resources, and all panic steps except the timer stay on flat Canvas.
- **Hero artwork (the one flagship image):** *"11pm"* — a 6000×3375 night-tone composition: deep indigo water, low luminous waterline, crest just surfaced, a faint second glow on the water. Used for the landing hero, App Store screenshot frame 1's backdrop, the press kit, and the X header re-render. It must read at thumbnail as "calm at night" — the exact feeling of the product's moment of use.
- **Grain:** ≤3%, marketing only, never in-app.

---

## 9. Marketing visuals

All store claims must be re-trued against shipped UI before export: no three-quit frame (the shipping app creates one quit), no "one-tap erase" caption until the erase UI ships, and the "<2s" number appears only after the device measurement lands (`docs/payload-audit.md` buckets) — until then the word is "fast." Captions below are layout placeholders for the founder copy pass.

### 9.1 App Store screenshots (6.9" 1320×2868 primary + 6.7" 1290×2796, dark-mode set is primary — evenings are the risk window; light set secondary)

The slot order and captions below are the marketing doc §4's canonical storyboard — privacy positioning lands in the first three captions (MVP release criterion), and slot 4 (forgiveness) stays inside the first-scroll set on every device size. Captions are placeholders for the founder copy pass.

| Slot | Composition | Caption (per marketing storyboard) |
|---|---|---|
| 1 | Lock screen mock, rectangular widget ("Day 34 / $412 saved" + wind glyph) large and real, on the *11pm* field | **Steady beats perfect.** Your streak — and help — on your lock screen. |
| 2 | Breath Bloom mid-swell inside a device frame, field behind | Urges pass. This 90-second reset helps them pass. No account. Nothing leaves your device. |
| 3 | Discreet trio: numbers-only "Reset" widget + "Calendar style" icon on a home screen + neutral Control Center control | Your quit is nobody's business. Discreet widgets, a disguised icon, on-device everything. |
| 4 | Slip forgiveness screen ("Logged. Your best — 34 days — is safe, and your momentum is still 82%.") | A slip isn't day zero. Your best is saved. Your momentum survives. |
| 5 | Quiz summary card: "~$1,340 /year" savings hero over its new horizon backdrop + risk-window line + motivations | Two minutes of questions. A plan in your own words. |
| 6 | Panic reasons page: the user's motivations at hero type | The biggest text in the app is yours. |
| 7 | Paywall pricing frame: plan cards with plain renewal terms | 3-day free trial. No countdowns. No tricks. Cancel in one tap. |

Device frames sit on Waterline fields (slot-matched day→night progression across the set); captions in Inter Display over the scrim where they overlap the field. All screen content comes from snapshot goldens — never mocked UI states. When quit management ships, the "Quit up to three at once" frame re-enters at slot 5 and the set goes to 8 (marketing §4).

### 9.2 Feature graphic / press banner

iOS has no Play-style feature graphic; produce one 1024×500 anyway for press kit, newsletter, and any future Play listing: *11pm* field crop, crest left-of-center, "Ballast" wordmark + "Steady beats perfect." right, nothing else. Export the same composition at 1200×630 for Open Graph duty (the marketing doc's OG spec) and at 1500×500 to replace `brandkit/branding-assets/social/ballast-x-header-1500x500.png` (currently Segoe-fallback slop).

### 9.3 Social templates (re-render all four existing PNGs)

All four files in `brandkit/branding-assets/social/` are re-rendered from the new system on Inter/Inter Display (the shipped exports used a Segoe-class fallback): 1080×1080 milestone card, 1080×1080 forgiveness post, 1080×1920 story, 1500×500 header. The story-panic template is rebuilt from scratch: its lock-screen mock printed "VAPE-FREE" on a widget — a state the shipped widget deliberately cannot render and a violation of the brand's own habit-leak rule. The replacement shows only golden-derived widget pixels ("Day 34," no habit words). Template kit: field background + safe-area text zones + wordmark lockup, so future posts are fill-in-the-blanks.

### 9.4 Product Hunt gallery (1270×760 ×6 + thumbnail 240×240)

1. Hero card: *11pm* field, wordmark, "Steady beats perfect."
2. Animated GIF/video: lock screen → panic tap → Breath Bloom (the hero demo, from screen recording, not fabrication).
3. Forgiveness mechanics: slip screen + momentum-survives diagram (waterline as the momentum line — it does not drop).
4. Privacy architecture: "No account. No server. On-device." with the discreet trio.
5. Honest pricing: plan cards, "No countdowns. No fake discounts."
6. The widget family lineup on one field.
Thumbnail: the app icon crest, unadorned.

### 9.5 Landing page hero

Full-bleed *11pm* field running the 7.7 Hero Loop; left column — wordmark, H1 "Steady beats perfect." with the marketing doc §5's hero sub beneath it, App Store badge; right — device mock with the lock-screen widget. ("Quit habits. Keep momentum." stays on ASO-subtitle duty; it is not the landing sub.) Below the fold: three value-prop cards (moment-of-urge, slip-isn't-day-zero, private-by-architecture) each with its field crop. Typography: Inter Display headlines (-1% tracking), Inter text, tabular numerals — SF is not licensable off-Apple surfaces.

### 9.6 TikTok / short-form end-card

1080×1920: the story template with the real demo's final frame, wordmark, "Help before you even unlock." The demo format itself (screen-recorded lock-screen panic launch) is specced in `docs/frontend-brandkit.md` §9.2 — creative team supplies only the end-card and caption overlays (Inter, scrim-backed).

---

## 10. Production notes

**Formats & masters**

- Illustration/fields: Figma vector masters; export PDF (in-app via asset catalog, single-scale vector where possible) + PNG @1x/2x/3x for raster-only slots. Marketing: 3000×3000 masters, sRGB, PNG-24; JPEG 85 only for web weight.
- App icon: 1024×1024 per appearance, assembled in **Apple Icon Composer** for iOS 26 layered/dark/tinted/clear; regenerate the full size ramp into `AppIcon.appiconset` and refresh `brandkit/branding-assets/icons/`. Keep `generate-alt-icons.py` output untouched for the discreet alternates.
- Motion: in-app = SwiftUI code (specs in §7 are the contract); marketing = **Rive** for interactive/looping (hero, bloom replica — smaller runtime, state machines, `prefers-reduced-motion` hooks), **Lottie** only where a partner surface demands JSON (some social schedulers). Export MP4/GIF fallbacks for every loop.
- Naming: `ballast-{surface}-{variant}-{mode}-{size}.{ext}` (e.g. `ballast-field-dusk-dark-3000.png`); check into `brandkit/branding-assets/` with the regenerated `tokens.json` (from `Theme.swift`, closing the stale-hex drift) and an updated `BRAND-GUIDELINES.md` §3 pointer.

**Dark mode:** every in-app-adjacent asset ships light + dark; dark is the **primary design target**. Dark fields anchor on `#121417`/`#1C1F24` with `#4CC8B9`/`#93A0E8` accents — never simply invert light masters.

**RTL:** no RTL locale is planned (EN, then Turkish — LTR), so no mirrored exports in v1. Still compose mirror-safe: the Waterline system is horizontally symmetric by nature; keep crest placements centered or parameterized, never bake directional reading into a field. Turkish text zones need +30% expansion room and sentence case only (İ/ı casing).

**Accessibility in assets:** in-app field crops cap at 12% opacity behind text so the 34 registry-pinned WCAG pairs hold untouched; marketing text over fields always sits on the pinned black 55% scrim; every composition passes the grayscale test; motion assets ship Reduce Motion variants as specced per item in §7.

**Tooling**

- **Figma** for everything vector: fields, icon drafts, screenshot frames, social kit. Sync a Figma variables file from `Theme.swift` hexes (both modes) so no stale value can re-enter.
- **Apple Icon Composer** for icon appearances; **Xcode previews + snapshot goldens** as the source of all UI pixels in marketing (never redraw screens by hand).
- **Rive** editor for 7.1/7.3/7.7 replicas; After Effects + Bodymovin only if a Lottie is contractually required.
- **AI image tools** (Midjourney / Ideogram / Firefly): exploration and mood only — final assets are rebuilt as flat vectors in Figma. The system is three ingredients and flat fills; AI renders drift into texture, extra glows, and off-palette tints that would fail the ≤3% grain and verbatim-hex rules. Never AI-generate UI screens, widgets, helpline surfaces, or anything containing text.

**Generation prompt drafts (exploration only; always post-correct hexes in vector):**

1. *Icon exploration:* "Minimal iOS app icon, abstract: a soft glowing white circle rising over a thin luminous horizontal waterline, flat vertical gradient from deep teal #0C6F65 (top) to dusk indigo #5262BC (bottom), subtle mirrored reflection below the line, Rothko-calm, flat color fields, no texture, no letterforms, no people, no red, centered composition, rendered at 1024px."
2. *Waterline field (dusk master):* "Abstract horizon color-field illustration, 3–4 flat horizontal bands transitioning teal #0C6F65 to indigo #5262BC, one thin luminous white waterline between sky and water, single soft radial glow at the line, no texture, no grain, no clouds, no birds, no people, no boats, legible in grayscale, serene and precise like a Rothko painted for a design system, 3000×3000."
3. *Night hero '11pm':* "Very dark abstract seascape color field, near-black indigo #121417 water, faint teal #4CC8B9 luminosity at a thin horizon waterline, one soft pale circle just surfaced above the line with a compressed reflection, vast negative space, calm and steady at night, flat fills, no stars, no moon, no texture, wide 16:9, 6000×3375."
4. *Milestone card backdrop:* "Small square abstract composition inside soft rounded card: dusk gradient teal #0C6F65 to indigo #5262BC, luminous thin waterline, pale circle lifting just above the line, one tiny warm ember-orange #E8833A spark at glyph scale near the circle, flat vector style, no confetti, no rays, no text, 1080×1080."
5. *Social story background:* "Vertical 1080×1920 abstract background, night-tone indigo field with low luminous teal waterline in the bottom third, generous empty upper area for text overlay, flat color fields, maximum one soft glow, no texture, no imagery of any object or person."

**Asset acceptance checklist (every export):** verbatim hexes from `Theme.swift`/direction; grayscale-legible; no red, no habit imagery, no people, no countdown motifs; UI pixels golden-derived; claims re-trued against shipped code; dark variant present; copy bytes founder-approved; discreet/widget/panic-first-frame surfaces untouched by any of it.
