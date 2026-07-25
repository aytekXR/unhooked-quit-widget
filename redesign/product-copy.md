# Ballast — In-App Copy System

**Scope.** Every string a user can read, organized by flow: shipped screens, redesign-proposed screens (widget moment, quit management, erase, milestones, empty states), system surfaces, errors, and a policy-gated notification library. Written for the founder's §3 copy pass — this document proposes bytes; the founder owns them (`docs/operator-expected.md` §3). Safety strings additionally require clinician + counsel sign-off before ship (`safetyCopy.json` is flagged DRAFT for exactly this reason).

**How to read the tables.** Each row is marked **Keep** (shipped string is canon — do not touch; goldens and lexicon gates stay green), **Refine** (small byte change, re-record goldens), or **New** (no string exists today). Current strings are quoted verbatim from the audited copy tables in `App/Resources/Content/` — the JSON file cited per section is where new bytes land; copy never lives inline in views.

**Non-negotiables inherited from the brand direction, restated once:** no exclamation marks, no urgency, no countdown language, nothing red, "a slip" never "relapse" or "failure," claims hedged ("commonly reported," "~," "usually about 15 minutes"), habit words never on shoulder-visible or discreet surfaces, faith echoed but never generated, the user's words outrank ours. Primary tagline: **"Steady beats perfect."** ASO subtitle: **"Quit habits. Keep momentum."**

---

## 1. Voice & tone rules

Voice per brand direction: **Steady, Discreet, Forgiving, Honest, Quietly proud** — the calm hand on the shoulder at 11pm. Six working rules with pass/fail examples:

**Rule 1 — Coach, never judge; quote the user back to themselves.**
Our copy frames, theirs stars. Whenever the user has given us a word (a motivation, a custom habit name), echo it verbatim before writing anything of our own.
- Do: "You said this matters for your Focus. It still does."
- Don't: "Don't give up now — think how disappointed you'd be."

**Rule 2 — Waves are weather, not enemies.**
The water metaphor carries difficulty. There is no fight, no battle, no enemy, no willpower test. Urges crest and pass; the user surfs, they don't win.
- Do: "Urges crest and pass — usually within about 15 minutes. Just this wave."
- Don't: "Crush the craving. Beat the urge. Stay strong, soldier."

**Rule 3 — Hedge every claim; honesty is the positioning.**
Numbers are floored and prefixed with "~". Health effects are "commonly reported," never promised. If we can't prove it, we don't say it.
- Do: "~$1,340 saved in a year, if you stay on track."
- Don't: "You will save $1,342.50 and your lungs will heal in 72 hours."

**Rule 4 — Nothing ever counts down against the user.**
Time in Ballast only accumulates in the user's favor. Windows of opportunity are stated as availability, never as expiry pressure.
- Do: "Undo stays available for 10 minutes."
- Don't: "Hurry — only 10 minutes left to undo." / "Offer ends tonight."

**Rule 5 — Pride is a fact, delivered the way you'd congratulate an adult.**
Celebration copy states what happened and stops. One short sentence of meaning is allowed; hype is not.
- Do: "That one passed. 12 urges surfed and counting."
- Don't: "AMAZING. You're absolutely crushing it. Streak legend."

**Rule 6 — Discreet means silent about the habit, not vague about the help.**
Any string visible over a shoulder (widgets, notifications, app switcher, settings row labels for discreet quits) carries zero habit context — but the utility stays plain. "Reset" and "Tracked goal" are the sanctioned neutral vocabulary.
- Do: "Tracked goal" / "Ready when you are." / "Opens a quick reset."
- Don't: "3 days vape-free" anywhere the phone can be seen locked.

**Mechanics that fall out of these rules:** second person, present tense, sentences under ~14 words wherever possible, verbs over adjectives, sentence case everywhere (also a Turkish İ/ı requirement), periods on full sentences, no periods on labels or row titles, no ellipses of hesitation, no emoji in product copy.

---

## 2. First run — age gate

Source: `ageGateCopy.json`, `AgeGateView.swift`, `AgeGateBlockedView.swift`. The gate is the first brand moment — the redesign adds the crest mark here, so the copy can stay lean and let the mark carry warmth. These strings are panel-signed; changes are refinements only.

### Age gate

| Element | Current | New copy | Notes |
|---|---|---|---|
| Title | "A quick age check" | "A quick age check" | **Keep.** |
| Body | "Ballast is made for adults — it's rated 17+ on the App Store. Choose the year you were born so we can confirm your age. We keep only a yes-or-no answer. Your birth year is never saved." | "Ballast is made for adults — it's rated 17+ on the App Store. Pick the year you were born. We keep only a yes-or-no answer — your birth year is never saved." | **Refine.** One sentence shorter; same signed facts, same order. |
| Picker label | "Year of birth" | "Year of birth" | **Keep.** |
| CTA | "Continue" | "Continue" | **Keep.** Ghost-disabled until a year is chosen. |
| Footer | "No account, no sign-up. This stays on your device." | "No account, no sign-up. This stays on your device." | **Keep.** The privacy promise belongs on screen one. |

### Blocked screen (under 17)

| Element | Current | New copy | Notes |
|---|---|---|---|
| Title | "Support is here for you" | "Support is here for you" | **Keep.** |
| Body | "Because Ballast is rated 17+, we can't open the full app for you yet. That said — if anything feels hard right now, these free, confidential lines are here. You don't have to be in a crisis to reach out." | Same | **Keep.** Constraint lands on the app, never on the user — signed framing. |
| Helpline rows | Verified rows from `helplines.json` | Same | **Keep.** Never restyle, never add unverified numbers. |
| Back action | "Go back" | "Go back" | **Keep.** |

---

## 3. Onboarding quiz, line by line

Source: `quizConfig.json` (slots are fixed analytics step numbers — copy changes must never renumber). The shipped questions are strong; the rewrite adds two interstitials (the personality and forgiveness moments the funnel lacks) and softens the two bare-keyboard steps. Interstitials are informational steps with no answer — they emit no analytics slot.

| Slot | Element | Current | New copy | Notes |
|---|---|---|---|---|
| 1 | Title | "What would you like to focus on?" | "What would you like to focus on?" | **Keep.** |
| 1 | Choices | "Vaping / Adult content / Alcohol / Cannabis / Doomscrolling / Something else" | Same | **Keep.** Clinical nouns for sensitive categories; word + color-chip tiles, never vice illustrations. |
| 2 | Title (custom name) | "What should we call it?" | "What should we call it?" | **Keep.** |
| 2 | Placeholder | "In your words" | "In your words" | **Keep.** |
| 2 | Helper | "Stays on this device." | "Only you will ever see this. It stays on your phone." | **Refine.** The bare-keyboard step earns one warmer reassurance line. |
| 3 | Consent title | "Share app usage data?" | "Share app usage data?" | **Keep.** |
| 3 | Consent helper | "You'd share which steps you reach and your habit type — never your answers, notes, or the times you log, and never tied to you. It's off until you choose, and nothing's been sent yet." | Same | **Keep.** Audit-backed, jointly signed. Exemplary as-is. |
| 3 | Choices | "Share usage data" / "No thanks" | Same | **Keep.** Equal visual weight is the point. |
| 4 | Title | "How often, lately?" | "How often, lately?" | **Keep.** "Lately" removes the confessional weight of "how bad is it." |
| 5 | Title (spend) | "Roughly what do you spend a week?" | "Roughly what do you spend a week?" | **Keep.** |
| 5 | Helper | "An estimate is fine — this powers your money saved." | "A rough guess is fine — this powers your money-saved counter. Zero is fine too." | **Refine.** Names the payoff and legitimizes zero-spend habits (doomscrolling) so nobody invents a number. |
| 6 | Title | "How long has this been around?" | "How long has this been around?" | **Keep.** "This," never "your addiction." |
| 7 | Title (triggers) | "When do the urges usually show up?" | "When do the urges usually show up?" | **Keep.** |
| 7 | Helper | "Pick any that fit." | "Pick any that fit — this shapes your first plan." | **Refine.** Signals the answers are used, which they are (risk window). |
| 8 | Title | "Have you worked on this before?" | "Have you worked on this before?" | **Keep.** |
| — | **New interstitial A** (after slot 8, shown only if answer ≠ "This is my first try") | — | Title: "Past tries count." Body: "Most people who quit for good tried more than once first. This time you'll have help at the exact moment it's hard — on your lock screen." CTA: "Continue" | **New.** Empathy + the product wedge in two sentences. Skippable step, no slot, waterline art per illustration direction. |
| 9 | Title (motivations) | "What's driving this? Pick what fits." | "What's driving this? Pick what fits." | **Keep.** |
| 9 | Helper | "Your words, in your order." | Same | **Keep.** The best helper line in the app. |
| 10 | Title (effects) | "Noticed any of these lately?" | "Noticed any of these lately?" | **Keep.** Medical-claims review still applies to choice labels. |
| — | **New interstitial B** (before slot 11) | — | Eyebrow: "One thing before your goal" Title: "A slip is never day zero." Body: "If you slip, Ballast archives your best streak and keeps your momentum. Nothing here ever resets to nothing." CTA: "Good to know" | **New.** The forgiveness promise, placed before the user commits — this is the differentiator stated at the moment of maximum doubt, and it seeds the paywall headline. The primary tagline is deliberately withheld here; its one in-app appearance is the summary footer (§4). |
| 11 | Title (goal) | "What's the goal?" | "What's the goal?" | **Keep.** |
| 11 | Choices | "Quit completely" / "Cut down" | Same | **Keep.** Reduce is first-class (ADR-11). |
| 12 | Title (allowance) | "What weekly limit feels right?" | "What weekly limit feels right?" | **Keep.** |
| 12 | Helper | "You can change this anytime." | Same | **Keep.** |
| 13 | Title (commitment) | "How ready do you feel?" | "How ready do you feel?" | **Keep.** |
| 13 | Slider echoes | "Taking it slow / Getting there / Ready when you are / Ready to start today" | Same | **Keep.** All four are judgment-free; "Taking it slow" is a valid answer, not a bottom rung. |
| — | Back / Continue | "Back" / "Continue" | Same | **Keep.** |
| — | Save-retry note | "That didn't save just yet — nothing's lost. Tap Continue to try again." | Same | **Keep.** Canonical error register — see §13. |

**Explicitly rejected:** a social-proof step. The PRD specced one, but Ballast has no verifiable user statistics and Rule 3 forbids invented ones ("Join 50,000 quitters" is a fabricated statistic). Interstitial B does the persuasion work honestly.

---

## 4. Quiz summary and the widget moment

### Summary card

Source: `summaryCopy.json`, `QuizSummaryView.swift`. The screen that "carries the conversion." Copy is already tight; the drama returns via the waterline backdrop and composition (sibling design doc), plus one closing line and a real CTA.

| Element | Current | New copy | Notes |
|---|---|---|---|
| Eyebrow | "Based on your answers" | "Based on your answers" | **Keep.** |
| Savings hero | "~$1,340" + "/year" | Same format | **Keep.** Floored, "~" prefixed — the hedge is the brand. |
| Savings caption | "saved in a year, if you stay on track." | Same | **Keep.** |
| Savings-absent line | "Every clean day is time and focus back — we'll count the streak that matters to you." | Same | **Keep.** |
| Risk-window lines | "Your first hard window is likely evenings." (et al.) | Same six | **Keep.** Reflection hedges over the user's own answers. |
| Motivation intro | "You're doing this for:" | "You're doing this for:" | **Keep.** Followed by their words, verbatim, largest type on the card. |
| Card footer | — | "Steady beats perfect." | **New.** The primary tagline's one in-app appearance — a quiet signature under the horizon rule, not a headline. |
| CTA | "Continue" | "Start your streak" | **Refine.** The moment deserves a verb. Works on both routes (paywall next or dashboard next) and for Reduce goals — the streak is clean-days either way. |

### The widget moment (new screen)

The product's north-star metric is "panic widget added by D1 ≥ 40%," and no screen serves it. This step mounts after the summary CTA (post-paywall on live-key builds, so payment friction never blocks it) and re-offers from Settings. This is also where `widget_added` analytics finally gets a fire point.

| Element | New copy | Notes |
|---|---|---|
| Eyebrow | "Before the first hard moment" | Not "One more thing" — no keynote cosplay. |
| Title | "Put help on your lock screen" | |
| Body | "The panic button works before you even unlock your phone. Add the Ballast widget, and a 90-second reset is one tap away — right when an urge shows up." | The wedge, stated plainly. "~90 seconds" hedging not needed; the flow is skippable and self-paced. |
| Visual caption | "This is what it looks like. Numbers only, if you prefer — it never names the habit." | Sits under a live preview of the rectangular widget; the second sentence is the discreet-mode preview the app currently lacks. |
| Primary CTA | "Show me how" | Opens a 3-step guided overlay: "Press and hold your lock screen" → "Tap Customize, then the widget area" → "Choose Ballast." Each step one line, no body text. |
| Secondary CTA | "Maybe later" | Quiet button. A settings row keeps the door open (§11). |
| Discreet footnote | "Prefer quieter? The Reset button in Control Center does the same job and carries no name at all." | Serves Dan without naming why. |

---

## 5. Paywall and monetization

Source: `paywallCopy.json`, `PaywallView.swift`. The shipped register is honest and audit-safe; keep it. The rewrite adds the missing benefits list (the wall currently sells "your full plan" without saying what that is) and keeps every disclosure byte legal-owned.

| Element | Current | New copy | Notes |
|---|---|---|---|
| Headline | "Keep your momentum." | "Keep your momentum." | **Keep.** Earned by interstitial B; "Steady beats perfect." stays a tagline, not a price tag. |
| Subhead | "Your full plan — every widget, every panic tool." | "Everything you just set up, working for you." | **Refine.** Points at the sunk value the quiz created — the honest version of loss-framing: possession, not threat. |
| Benefits list | — | "Panic button on your lock screen, Control Center, and Action button" · "Streak, momentum, and money saved — honest numbers, kept on your phone" · "Discreet mode, disguised app icons, one-tap erase" · "Track up to three habits at once" | **New.** Four rows, SF Symbols per icon direction. Both feature-gated bullets are honest-only: "one-tap erase" requires the erase UI (§11) and "up to three" requires quit management (§10) — neither ships in copy before it ships in product. |
| Positioning line | "No account. No sign-up. Apple handles billing — cancel in one tap." | Same | **Keep.** Audit-safe register (the "No server" canon is deliberately withheld here — founder's call to restore). |
| Notes line | "Your notes and journal never leave your device." | Same | **Keep.** |
| Plan titles | "Monthly" / "Yearly" | Same | **Keep.** |
| Trial badge | "3-day free trial" | Same | **Keep.** |
| Price lines | "%@ / month", "%@ / year" | Same | **Keep.** Prices bind from ProductCatalog/StoreKit, never copy. |
| Trial mechanics | "Free for 3 days, then %@ per year. Cancel anytime." | Same | **Keep.** |
| CTAs | "Start free trial" / "Subscribe" | Same | **Keep.** |
| Restore | "Restore purchases" | Same | **Keep.** Always visible. |
| Auto-renew disclosure | (full Apple boilerplate) | Same | **Keep.** Legal-owned; verify Apple's current wording at submission. |
| Terms / Privacy | "Terms of Use" / "Privacy Policy" | Same | **Keep** — but they must become functional links; dead labels are a submission blocker. |
| Teaser escape | "Look around for a day first" | Same | **Keep.** |
| Teaser note | "Full access for one day. Then this screen returns." | Same | **Keep.** Factual duration, zero countdown. |
| Teaser-expiry eyebrow | "Your free day wrapped up. Everything you set up is still here." | Same | **Keep.** |
| Win-back offer | "Your annual plan, now at half price." | Same | **Keep.** Real ASC discount — the claim is honest. |
| Win-back mechanics | "%@ for your first year, then %@ per year. Cancel anytime." | Same | **Keep.** |
| Win-back reassurance / dismiss | "Everything you set up is still here." / "Not now" | Same | **Keep.** |

**Design contract restated for anyone touching this surface:** no countdowns, no fake discounts, no "one-time offer," renewal terms on-screen before purchase, restore always visible, paid users never re-walled.

---

## 6. Dashboard and navigation shell

Source: `RootPlaceholderView.swift`, `StreakDashboardCard.swift`, `DashboardCopy.swift`. The sibling design doc gives the dashboard a real shell; this section supplies the words, including the two strings that currently ship **empty** (frozen framing, reduce framing).

| Element | Current | New copy | Notes |
|---|---|---|---|
| Screen title | — (no title) | "Today" | **New.** Habit-neutral, shoulder-safe, present-tense — the brand's tense. |
| Streak hero | "Day 34" | Same | **Keep.** SF Rounded, monospaced digits. |
| Momentum label | "82%" + ring | "82% momentum" | **Refine.** Name the number once; the ring alone doesn't teach the concept. |
| Momentum explainer (tap) | — | "Momentum is your clean days over all your days. A slip barely moves it — only time does." | **New.** One-sentence popover; kills the #1 predictable support question. |
| Money line | "$412" + "saved" | Same | **Keep.** Zero-spend renders nothing, never "$0". |
| Next-milestone label | "next milestone" | Same | **Keep.** Discreet variant keeps the bare bar, drops the word. |
| Averted-urge line | — | "12 urges surfed and counting." | **New.** On the card below the milestone bar; hidden until count ≥ 1. Singular: "1 urge surfed and counting." Data already stored in UrgeEvents. |
| Frozen-state framing | "" (ships empty) | "Paused — your phone's clock changed. Your streak is safe and picks up on its own." | **New.** Pairs with the neutral gray ring; paused is a state, never a problem. |
| Reduce framing | "" (ships empty) | "Within your limit: {{n}} of {{allowance}} this week." Adherence footer: "{{days}} of the last 7 days on plan." | **New.** Unblocks the Alex persona surface. Never renders "over your limit" as a headline — an over week reads "This week: {{n}} of {{allowance}}." Same data, no verdict. |
| Slip row | "Vaping" + undo-arrow icon | "Log a slip" (row within each quit's card; discreet quits: "Log it") | **Refine.** The current row reads as a habit label, not an action. Verb-first fixes it and un-clutters multi-quit. |
| Panic entry | "Panic" tinted row | Floating button "Panic" with support line "One tap. About 90 seconds." Discreet: "Reset" / "Take a moment." | **Refine.** Label stays "Panic" for cross-surface consistency with the Control Center control; the support line is new. Visual priority is the design doc's job. |
| Settings entry | gray row | "Settings" | **Refine.** See §11 for the renamed sheet. |
| Add-quit row | — | "Add another quit" footer: "Track up to three at once." | **New.** See §11. |
| Pending-undo banner | "Slip logged. Undo?" + "Undo" | Same | **Keep.** Byte-identical to `slipCopy.json` dashboard section. |

---

## 7. Panic flow

Source: `panicScript.json`, `PanicFlowView.swift`. This copy is the soul of the product and it is already right. Changes are additive only: the averted-count fact on the celebration, a dismiss affordance on the cold route, and a helpline path from inside the flow (a person mid-crisis currently has no route to 988 without exiting — the brief flags this as an accident, and copy treats it as a decision).

| Element | Current | New copy | Notes |
|---|---|---|---|
| Entry title | "Let's take this one wave at a time." | Same | **Keep.** |
| Entry title (discreet) | "Take a moment." | Same | **Keep.** |
| Breath title / instruction | "Breathe with me" / "Follow the circle. In for 4, hold for 7, out for 8. Three rounds." | Same | **Keep.** |
| Haptics-only label / non-visual | "Feel the taps — in, hold, out." / "Breathe with the taps. In for 4, hold for 7, out for 8. Three rounds." | Same | **Keep.** |
| Breath skip | "Skip breathing" | Same | **Keep.** Every step skippable. |
| Timer title | "This will pass" | Same | **Keep.** |
| Timer instruction | "Urges crest and pass — usually within about 15 minutes. You don't have to win forever right now. Just this wave." | Same | **Keep.** The live wave visual (design doc) illustrates this line; the words don't change. |
| Timer subtext | "Stay here as long as you like. Nothing is counting down against you." | Same | **Keep.** Rule 4's origin. |
| Timer continue | "I'm ready to keep going" | Same | **Keep.** |
| Reasons title / framing | "Why you started" / "In your own words:" | Same | **Keep.** Their words at .largeTitle — the hero type of the app. |
| Reasons empty-fallback | "You chose this for your own reasons. They still count right now." | Same | **Keep.** |
| Redirect title / instruction | "What now?" / "Pick something small for the next few minutes." | Same | **Keep.** |
| Redirect options | "Get a glass of water / Step outside for two minutes / Message someone you trust / One more round of breathing" | Same | **Keep.** |
| In-flow support affordance (steps 2–3, bottom-trailing) | — | "More support" | **New.** Footnote-weight quiet link on the wave-timer and reasons steps, opening SafetyResourcesView as a sheet inside the flow — a person mid-crisis currently has no path to a helpline without exiting. Never on the pacer frame (latency budget). Safety-content panel must sign placement. |
| Redirect footer link | — | "Or talk to someone — free, confidential helplines" | **New.** The same affordance, given a full sentence where the redirect step has room. Not a fifth tile — help sits below the choices, always present, never alarming. Safety-content panel must sign placement. |
| Exit — passed | "The urge passed" (discreet: "Done") | Same | **Keep.** |
| Exit — slipped | "I slipped" (discreet: "Log it") | Same | **Keep.** |
| Celebration line | "That one passed. That's the whole skill — surfing the wave instead of fighting it." | Same, plus fact line: "{{count}} urges surfed and counting." (first time: "That's one urge surfed.") | **Refine.** Quiet pride as a stat. Discreet quits: count line only, no habit context needed — it already has none. |
| Celebration dismiss | — (swipe/sit) | "Done" | **New.** The cold route needs a door; a quiet button is the door. |

### Panic quit picker

| Element | Current | New copy | Notes |
|---|---|---|---|
| Title | "Which one needs you right now?" | Same | **Keep.** |
| Discreet row label | "Your goal" | Same | **Keep.** |

---

## 8. Slip flow and undo

Source: `slipCopy.json`. Tonally the best surface in the app — every shipped byte stays. The one addition is a forward path: after logging, the sheet currently dead-ends.

| Element | Current | New copy | Notes |
|---|---|---|---|
| Confirm title / body | "Log a slip?" / "This just records it and starts a fresh streak. Your best is kept safe." | Same | **Keep.** |
| Confirm CTAs | "Log it" / "Not now" | Same | **Keep.** |
| Confirm retry note | "That didn't save just yet — nothing's lost. Tap Log it to try again whenever you're ready." | Same | **Keep.** |
| Logged title / body | "Logged." / "Your best — {{bestStreak}} — is safe, and your momentum is still {{momentum}}. When you're ready, the next hour starts now." | Same | **Keep.** |
| No-best variant | "Logged. Your momentum is still {{momentum}}. The next hour starts whenever you're ready." | Same | **Keep.** |
| Reflection prompt / placeholder | "Want to note what was going on? (optional, stays on your device)" / "What was happening right before?" | Same | **Keep.** |
| Reflection CTAs | "Skip" / "Save note" | Same | **Keep.** |
| Undo banner / window / confirmation | "Slip logged. Undo?" / "Undo stays available for 10 minutes." / "Undone. Your streak is right where it was." | Same | **Keep.** |
| Encouragement rotation | "One slip is one data point, not a verdict." (et al.) | Same three | **Keep.** |
| Motivation echo | "You said this matters for your {{motivation}}. It still does." | Same | **Keep.** |
| Resources link | "Support & resources" | Same | **Keep.** |
| Forward path | — | "Back to today" (primary quiet) · "One round of breathing" (secondary, opens the pacer) | **New.** Agency returned with two small doors: home, or a regulated minute. Not on the cold route's store-free variant if it complicates the buffer — engineering may keep "Done" there. |

---

## 9. Milestones and quiet celebrations

Source: `milestones.json` — 43 written bodies, currently rendered nowhere. Two new surfaces spend this dormant content. All bodies keep their "commonly reported" hedge verbatim; no new milestone copy is drafted here (the catalog is already signed against the medical register).

### Milestone unlock card (dashboard, on boundary crossing)

| Element | New copy | Notes |
|---|---|---|
| Eyebrow | "Milestone" | Ember (#E8833A) glyph moment per palette rules — the flame's second sanctioned appearance. |
| Title | From catalog — e.g. "One week" | Verbatim. |
| Body | From catalog — e.g. "A week. Commonly reported by now: steadier energy through the afternoon and fewer automatic reaches for it." | Verbatim. |
| Dismiss | "Done" | 600ms waterline-rise reveal, one soft haptic, nothing else. |

Discreet quits: the card still renders (in-app content is behind the unlock), but uses the time-only title and swaps the body for "A marker worth noting. Your numbers tell the story." — zero habit vocabulary even inside the app, matching the discreet dashboard's posture.

### Milestone list (new screen, from the next-milestone bar)

| Element | New copy | Notes |
|---|---|---|
| Title | "Milestones" | |
| Unlocked rows | Catalog title + body | Verbatim. |
| Locked rows | "Unlocks at two weeks" | Time only — no preview of the body; anticipation without promise. |
| Footer | "Milestones describe what people commonly report, not clinical outcomes." | Reuses the signed `notMedicalCareDisclaimer` fragment; do not redraft. |

---

## 10. Quit management and empty states

The engine supports three concurrent quits; the UI supports one, created once. These are the missing surfaces, with their words.

### Add a quit

| Element | New copy | Notes |
|---|---|---|
| Entry row (dashboard) | "Add another quit" footer "Track up to three at once." | |
| Re-entry quiz title | "What's next?" | Drops into the existing habit picker (slot 1) and a shortened path: habit → spend → triggers → motivations → goal. No consent re-ask, no commitment slider. |
| At-limit note | "You're tracking three — that's the limit. Remove one to add another." | Stated as fact, no apology, no upsell. |

### Edit a quit (new sheet, from the quit's card in Streak Detail — design doc §6.17)

| Element | New copy | Notes |
|---|---|---|
| Title | Quit name (discreet: "Tracked goal") | |
| Rows | "Weekly spend" · "Weekly limit" (Reduce only) · "Show numbers only" (discreet toggle) · "Motivations" | Motivations row reopens slot 9 — the user's words stay editable; they power the panic flow. |
| Delete row | "Stop tracking" | Amber text row at the bottom, per no-red rule. |

### Delete confirmation (destructive)

| Element | New copy | Notes |
|---|---|---|
| Title | "Stop tracking {{name}}?" | Discreet: "Stop tracking this goal?" |
| Body | "This removes its streak, notes, and history from this device — for good. Your other quits stay put. Your best here: {{bestStreak}}." | States the cost honestly, including what's lost. There is no server copy to soften this — say so by omission, not euphemism. |
| Confirm / cancel | "Stop tracking" / "Keep it" | Confirm is amber, never red. |

### Empty state (zero quits — reachable once deletion ships)

| Element | New copy | Notes |
|---|---|---|
| Title | "Ready when you are." | Deliberate echo of the widget's unavailable state — one phrase, both surfaces, same meaning. Crest mark anchors the screen per icon direction. |
| Body | "Start a quit — or a cut-down — whenever it feels right. Everything stays on this device." | |
| CTA | "Start a quit" | Opens the full quiz. |

---

## 11. Settings, privacy, and legal microcopy

The shipped sheet is titled "Discreet Mode" while hosting unrelated rows — IA debt the redesign resolves by renaming it **"Settings"** (a pushed screen in the new shell, no longer a sheet). Sections follow the design doc §6.11's canonical order — panic access first, because settings order restates product values. All row labels below are new unless marked otherwise. Per-quit editing (spend, limit, motivations, delete) deliberately does **not** live here — it lives on the quit's card in Streak Detail (§10), so Settings stays app-level.

| Section | Row / element | Copy | Notes |
|---|---|---|---|
| — | Screen title | "Settings" | **Refine** from "Discreet Mode". |
| Panic access | Section header | "Panic access" | Help first — the order is the message. |
| Panic access | Widget row | "Add the lock-screen button" | Reopens the widget moment (§4). The persistent home of the north-star metric. |
| Panic access | Control Center row | "Add the Control Center button" | **New.** Same guided flow, Control Center variant. |
| Discreet Mode | Section header | "Discreet Mode" | The name finally matches the content. |
| Discreet Mode | Per-quit toggle | "Show numbers only" footer: "Widgets and buttons for this quit drop every habit word. The app switcher shows a blank card." | **Refine.** Footer finally explains the any-quit-discreet shield behavior. Discreet rows: "Tracked goal" — **Keep**. |
| Discreet Mode | Icon picker | "App icon" options "Default / Calendar style / Timer style" footer: "The alternate icons carry no Ballast color, so your home screen stays quiet." | Option labels **Keep**. |
| Privacy & Data | Section header | "Privacy & Data" | |
| Privacy & Data | Data screen link | "What leaves this device" | Opens the privacy dashboard below. |
| Privacy & Data | Analytics toggle | "Share usage data" footer: "Off means nothing leaves this device. On shares which screens you reach and your habit type — never your words, notes, or times, and never tied to you." | **New.** Closes the GDPR-hygiene gap: consent asked once in the quiz, revisitable forever here. Footer reuses the signed consent register. |
| Privacy & Data | Erase row | "Erase everything" | Amber label. See dialog below. |
| Breathing | Section header | "Breathing" | |
| Breathing | Haptics toggle | "Breathe by touch" footer: "The pacer guides with taps instead of the screen. Works with your eyes closed." | **Refine** of the haptics-only toggle. |
| Your plan | Winback row | "See your plan options" | **Keep** (conditional). |
| Your plan | Subscriber row | "Manage subscription" | **New.** Links to App Store management; the honest counterpart to "cancel in one tap." |
| Support | Resources row | "Support & resources" | **Keep.** |
| About | Rows | "Terms of Use" · "Privacy Policy" · "Version {{n}}" | Labels **Keep**; must be live links pre-submission. |

### Privacy dashboard ("What leaves this device")

| Element | New copy |
|---|---|
| Title | "What leaves this device" |
| Lead (sharing off) | "Nothing. Ballast has no account, no sign-up, and no server of ours. Your streaks, notes, and answers live only on this device." |
| Lead (sharing on) | "Only this: which screens you reach and your habit type — as anonymous counts, never tied to you. Your answers, notes, and log times never leave." |
| Purchases note | "If you subscribe, Apple processes payment and Ballast checks your subscription status. That's the whole list." |
| Footer | "Change your mind anytime with the switch above, or erase everything below." |

### Erase everything (destructive dialog — the promise the store listing makes)

| Element | New copy | Notes |
|---|---|---|
| Title | "Erase everything?" | |
| Body | "This deletes every streak, note, answer, and setting, resets your app icon, and returns Ballast to a fresh install. There's no copy anywhere else — once it's gone, it's gone. If you have a subscription, it stays with your Apple Account." | Icon reset is stated because a disguised icon surviving an "erase" would be a broken promise; entitlement survival is stated because losing paid access would be a false fear. |
| Confirm / cancel | "Erase everything" / "Keep my data" | Amber confirm, rendered as the design doc §6.16's 600ms hold-to-confirm (deliberateness without a countdown; VoiceOver gets a standard double-activation alternative). No type-to-confirm theater — the copy carries the weight. |
| Completion | "Everything's gone. This app is now exactly as it was before you opened it." | A crest-anchored confirmation screen (design doc §6.16), then the fresh age gate. Shown once, never again. |

---

## 12. Safety surfaces

These strings are the one place calm caution is allowed, and they are clinician + counsel gated. **Every current byte is Keep** — reproduced here only so no parallel document redrafts them: resources title "Support, whenever you want it"; intro "These are free, confidential lines. You don't have to be in crisis to call."; footer disclaimer "Ballast tracks habits and streaks. It is not a substitute for professional medical or mental-health care. If you're in immediate danger, call your local emergency number."; alcohol notice "One thing worth knowing" / "For some people who drink heavily or daily, stopping suddenly can be physically risky…" with "See resources" / "Got it".

Two additions, both routed through the safety-content panel:

| Element | New copy | Notes |
|---|---|---|
| GLOBAL region body | "Helplines differ by country, so we only list numbers we've verified. findahelpline.com keeps a free, current list for where you are." CTA: "Find a helpline" | The GLOBAL region currently renders visually empty — correct by policy, but it should explain itself. Never add unverified numbers instead. |
| Alcohol notice placement | Same signed copy, additionally mounted on the quiz summary when the habit is alcohol | Fixes the known gap: with live keys, a hard-walled non-converter would otherwise never see the caution. Copy unchanged; placement is the fix. |

---

## 13. Error and edge states

Ballast's architecture deletes whole error categories: **no account means no auth errors; no sync means no sync errors.** Write nothing for them. The canonical error register (set by the shipped quiz retry note): name what happened, confirm nothing is lost, offer the retry, never claim success without durable bytes, always amber, never red.

| Failure mode | Copy | Status |
|---|---|---|
| Quiz save failed | "That didn't save just yet — nothing's lost. Tap Continue to try again." | **Keep** (`quizConfig.json`). |
| Slip save failed | "That didn't save just yet — nothing's lost. Tap Log it to try again whenever you're ready." | **Keep** (`slipCopy.json`). |
| Payment failed | "That didn't go through. You can try again, or restore a previous purchase." + "Try again" | **Keep** (`paywallCopy.json`). |
| Restore found nothing | "No previous purchase found on this Apple Account." | **Keep.** |
| Restore succeeded | "You're all set — your subscription is active." | **Keep.** |
| Paywall offline (products won't load) | "Plans can't load right now. Check your connection and try again — everything else in Ballast works offline." | **New.** The second clause is a brag stated as reassurance. |
| Clock rollback (frozen streak) | "Paused — your phone's clock changed. Your streak is safe and picks up on its own." | **New** (§6). |
| Icon switch failed | "That icon change didn't take. Try again in a moment." | **New.** One line; the system alert already did the talking. |
| Haptics unavailable in touch mode | "Taps aren't available right now — follow the circle instead." | **New.** Graceful fallback to the visual pacer. |
| Widget has no data | "Ready when you are." | **Keep** (`StreakWidgetStyle.swift`). |
| Future iCloud sync (parked) | Draft for the CloudKit flip only: "iCloud is catching up. Everything is safe on this device." | **Parked.** Do not ship before sync exists — docs already over-claimed sync once. |

---

## 14. Notification library (policy-gated)

**Policy first.** Ballast ships zero notifications today, deliberately: the panic path must never depend on them, and win-back is in-app only — that stays true. This library is a proposal for **opt-in-only** notifications, each enabled by its own toggle, requested in context (never a permission prompt at first launch). Global anti-spam rules: hard cap one notification per day and three per week across all types; nothing between 21:00 and 09:00 local except nothing at all; every notification deep-links to a calm surface, never the paywall; when any quit is discreet, **all** notifications system-wide use the discreet variant (the lock screen is the most shoulder-visible surface the product touches). Never sent, ever: streak-at-risk guilt, "we miss you," win-back offers, undo-window expiry, anything with a count-down.

| Notification | Trigger | Title | Body | Cadence & rules |
|---|---|---|---|---|
| Milestone unlocked | Streak crosses a catalog boundary; user opted in via the unlock card ("Tell me next time" toggle) | Catalog title, e.g. "One week" | "A milestone on your streak. Open when you like — it'll keep." Discreet: title "Ballast" body "A marker worth a look, whenever you like." | Max 1/day; delivered at 09:30 local, never at the actual unlock instant (3am milestones wait for morning). Deep-link: milestone card. |
| Evening check-in | User's quiz triggers include evenings/after-work AND user opted in on the summary ("Want a nudge before your hard window?") | "Checking in" | "This is the window you called out. If it gets loud, the panic button is on your lock screen." Discreet: "The quiet hour is yours. Your tools are one tap away." | Max 1/day, first 14 days only, then auto-stops with a final line: "That's the last of these unless you ask again." One-tap "End these" action on every delivery. |
| Trial ending | 24h before trial converts; automatic for trialists (honesty notification, not marketing) | "Your free trial ends tomorrow" | "If Ballast isn't for you, cancel now and pay nothing. If it is, you don't need to do anything." | Exactly once per trial. Exempt from the opt-in requirement because silence here would be the dark pattern. Deep-link: Manage subscription. |
| Weekly reflection | Sunday 18:00 local; opted in via Settings | "Your week" | "{{clean}} clean days, {{surfed}} urges surfed. Open for the details." Discreet: "Your week is ready when you are." | Max 1/week; suppressed entirely if the week contains zero opens and zero events (no data, no message). Deep-link: dashboard. |

Copy rules inside notifications: no habit nouns in any variant (even non-discreet — the lock screen is pre-unlock, same doctrine as widgets), no numbers in discreet variants, no exclamation marks, nothing that reads as a summons.

---

## 15. Widgets and system surfaces

All shipped strings **Keep** — lexicon-gated and golden-pinned; listed so sibling documents quote them correctly. Rectangular widget: "Day 34" / "$412 saved" / panic button (discreet: money dropped, label "Reset"). Unavailable state: "Ready when you are." Gallery: "Streak — Your streak, on your lock screen. A quick reset is one tap away." Control Center: "Panic — Opens a full-screen reset, instantly." and "Reset — Opens a quick reset." Alternate icons: "Calendar style" / "Timer style". App-switcher shield: no text by design — a blank card draws no eye.

For the marketing sibling: no widget or gallery string may ever name a habit — the social export that printed "VAPE-FREE" on a widget mock fabricated a state the product refuses to render.

---

## 16. Copy governance

- Every string lives in an audited table (`quizConfig.json`, `slipCopy.json`, `panicScript.json`, `summaryCopy.json`, `paywallCopy.json`, `ageGateCopy.json`, `safetyCopy.json`, `milestones.json`); views render bytes, never literals. New strings in this document land in those tables or new sibling tables with the same `_meta.audit` discipline.
- The founder owns final bytes. Rows marked **Keep** require no action and keep goldens green; **Refine/New** rows enter the §3 copy pass and then the one golden re-record batch (`docs/golden-batch.md`).
- Every proposed string above was drafted against the CI lexicon gates: no shame tokens, no habit leakage on shoulder-visible surfaces, no medical claims, no urgency. Run `SlipLexiconTests` and `PaywallCopyTests` before trusting any human's promise, including this document's.
- Safety-adjacent additions (§7 helpline link, §12 GLOBAL body and notice placement) require the PM + Brand + QA safety panel plus clinician/counsel review — they do not ship on the founder pass alone.
- Turkish fast-follow: all strings here are drafted for the warm-informal *sen* register, sentence case only (İ/ı), no idioms — "one wave at a time" translates as meaning, not image, and the no-shame gate re-runs as its own pass on translated bytes.
