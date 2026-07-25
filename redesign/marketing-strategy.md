# Ballast — Go-to-Market & Growth Strategy

This is the execution blueprint for launching and growing **Ballast** (org `com.beyondkaira`, bundle `com.beyondkaira.ballast`), the privacy-first quit-anything app currently live on TestFlight. Everything here is grounded in the shipped product (source: `App/Sources`, `Widgets/Sources`, `Shared/Sources`), the PRD (`docs/prd.md`), the MVP spec (`docs/mvp.md`), and the brand direction. Where the brandkit's original marketing spec (`docs/frontend-brandkit.md` §9) diverges from what the app can actually render, this document re-trues it and says so explicitly. Brand facts — hexes, taglines, principles — are quoted verbatim from the design direction so this document agrees with its four siblings.

Business context that shapes every decision below: revenue target is $5,000/mo net by month 6; the kill/pivot checkpoint at launch+3 months fires on <1,000 quiz-completing installs/mo or <4% conversion; the feasibility verdict named **distribution, not engineering, as the load-bearing risk**. This plan treats organic short-video plus ASO as the primary engine, with everything else in support.

---

## Ground Rules: Constraints Every Asset Must Honor

These are product invariants, not style preferences. Any asset that violates one does not ship.

| Constraint | Marketing consequence |
|---|---|
| Trademark clearance (G0) still open | No paid asset, ASO listing, or domain-branded material ships until "Ballast" clears. "Unhooked" is unusable (5+ collisions incl. a direct competitor). |
| `<2s` panic latency is unmeasured on hardware (E0.3) | Until the device measurement lands, all copy says **"fast"** / "before you even unlock" — never a number. The moment it lands, "<2s from lock screen to breathing" becomes the ownable claim. |
| Erase UI does not exist yet (data layer only, `EraseFlow.swift`) | No asset may claim "one-tap erase" until the settings row ships. The privacy story until then: "No account. No cloud we control. Everything stays on your device." |
| Multi-quit UI does not exist (one quiz = one quit) | No asset shows three quit cards or says "quit up to three at once" until quit-management ships. The brandkit §9.2 frame 4 is retired (see Screenshot Storyboard). |
| No shame, no urgency | Zero countdowns, zero "last chance," zero fake discounts, zero red, zero before/after imagery, zero fear statistics. This is a CI-enforced product contract (37-token shame lexicon) and it extends to marketing. |
| No medical claims | "Commonly reported," "~," "usually about 15 minutes." Banned: "recover," "treatment," "cure," addiction-medicine framing. `safetyCopy.json` requires clinician + counsel sign-off. |
| Copy is founder-owned | Marketing may draft; the founder's copy pass (§3, `docs/operator-expected.md`) approves. Strings in this doc are drafts for that sitting. |
| Sensitive categories stay clinical | "Adult content," never explicit terms, in every ASO field, caption, and video. Faith is echoed, never generated. |
| Discretion is sacred | Never show the discreet alternate icons as store marketing decoration (showing them *is* the screenshot story, per brandkit §9.1). Never fabricate widget states the shipped widget can't render — the old `ballast-story-panic-1080x1920.png` social export printed "VAPE-FREE" on a widget mock, violating the habit-leak rule; all social exports are re-rendered. |

Marketing typography: **Inter Display** (headlines, -1% tracking) + **Inter** (text) with tabular numerals — SF cannot be licensed off-Apple surfaces, and this permanently retires the Segoe-fallback exports in `brandkit/branding-assets/social/`. Marketing color: the app palette verbatim, led by Harbor Teal `#0C6F65`, Dusk Indigo `#5262BC`, Canvas `#F7F6F3` / `#121417`, with the **Horizon Gradient** (`#0C6F65` → `#5262BC`) reserved for backdrops — never as a text background without the pinned 55% scrim. Illustration: the **Waterline fields** system only — no mascots, no people, no photography, no habit imagery, ever.

---

## 1. Positioning & Competitive Frame

### The market as users experience it

| Cluster | Examples | What they sell | Where they fail our user |
|---|---|---|---|
| Single-vice quiz-funnel apps | Quittr (~$3M yr-1), Fortify-class adult-content apps | Identity + streaks + heavy subscription | Single habit, shame-coded resets ("Day 1 again"), accounts required, loud branding on the home screen |
| Community sobriety trackers | I Am Sober, Nomo | Milestones + community | Accounts, public-ish identity, recovery-culture register that the sober-curious and privacy-first users reject |
| Clinical program apps | Reframe, Smoke Free | Courses, CBT programs | Expensive, homework-shaped, single-vice, data-hungry |
| Free counters | Puff Count, generic day counters | A number | No help at the moment of urge; nothing between you and the craving |

Every incumbent shares one structural flaw: **when the urge hits, their help is four steps away** — wake phone, unlock, find app, find feature. Ballast's help is on the lock screen before authentication.

### The wedge

Three moats, in the order we say them:

1. **Lock-screen-native intervention.** An interactive widget button, Control Center controls, and Action-button support cold-launch a ~90-second urge-surfing reset (`OpenPanicIntent`, ADR-6 thin panic path). No competitor lives at the lock screen.
2. **Forgiveness as a mechanic.** A slip archives your best, your Momentum score survives the reset, and a 10-minute undo means a mistap costs nothing (`StreakEngine`, `SlipFlowView`). Incumbents monetize shame; we made shame structurally impossible — there is no red anywhere in the product.
3. **Privacy as architecture.** No account, no first-party server, on-device SwiftData, discreet mode, disguised icons, an app-switcher shield. Not a policy promise — an architecture competitors would have to rebuild their business to copy.

### The one-sentence position

> **Ballast is the private quit companion that wins the exact moment of urge — a panic button on your lock screen and forgiveness mechanics that keep one slip from ever erasing progress.**

The name is the thesis, and we say so in press and About copy: *ballast is the weight below the waterline that doesn't push the ship anywhere — it keeps it steady in rough water.*

### What we never position against

We never punch at recovery communities, AA, therapy, or medication — "This app tracks your progress — it isn't medical care" is both a legal line and a positioning virtue. Our enemy is the shame loop and the four-step unlock, never other people's recovery.

---

## 2. Target Audience & Personas

Adults 17+ quitting or cutting down. Under-17s are routed to a support screen with helplines — this is a compliance feature and a brand statement; never target minors in any channel.

### Jake — 22, retail worker, quitting vaping
- **Motivator:** money. The dashboard money figure, the summary's "~$1,340/year" projection, and the widget's "$412 saved" line are built for him.
- **Where he is:** TikTok (found his last three apps there), YouTube Shorts, Instagram Reels.
- **Acquisition:** the lock-screen panic demo as hero short-video format; vape-math content ("what your Elf Bars cost per year"); ASO on "quit vaping" terms. Message lead: *"Help before you even unlock."* + real money numbers.

### Dan — 26, self-improvement X/Reddit native, quitting adult content
- **Motivator:** control and privacy. "Will not create an account." The entire privacy architecture — discreet mode, "Adult content" clinical labeling, app-switcher shield, neutral "Reset" control — is his product surface.
- **Where he is:** X (self-improvement/looksmaxxing-adjacent but allergic to macho cringe), r/pornfree and r/NoFap (as a reader), Hacker News (privacy architecture angle).
- **Acquisition:** privacy-architecture content ("we can't see your data — here's the code structure that makes it impossible"), discreet-mode demos, X threads. Never NoFap-warrior tone — the brand is explicitly anti-macho. Message lead: *"Your quit is nobody's business."*

### Alex — 31, sober curious, cutting back alcohol
- **Motivator:** feeling better, not identity change. No AA framing, no "sober" identity demanded. The "Cut down" goal, weekly allowance step, and the calm alcohol notice serve her.
- **Where she is:** Instagram (sober-curious aesthetic accounts), podcasts, newsletters (mindful-drinking substacks), Google ("cut back on drinking app").
- **Acquisition:** Dry January / Sober October content moments, SEO on moderation queries, IG carousels on gentle mechanics. Message lead: *"'Cut down' is as legitimate a goal as 'quit.'"* — **gated on Reduce-mode UI shipping** (adherence display is currently §3-blocked); until then Alex-targeted assets lead with forgiveness + the alcohol-aware safety posture, not adherence features.

### Mara — 29, designer, quitting doomscrolling (secondary)
- **Motivator:** attention and irony-fluent self-awareness. Custom habit slot + doomscroll milestone ladder serve her.
- **Where she is:** X and TikTok (the very channels she's quitting — the irony is the content).
- **Acquisition:** "I quit TikTok using an app I found on TikTok" self-aware formats; design-community word of mouth (the no-red, no-countdown design story travels well among designers). Low spend; high shareability.

---

## 3. Brand Messaging House

### Roof — primary tagline

> **Steady beats perfect.**

This is the emotional thesis and the primary line on the App Store first screenshot, the landing hero, and the Product Hunt end card. **"Quit habits. Keep momentum."** is retained as the functional ASO-subtitle line — it describes the mechanics, not the feeling.

### Alternate lines (sanctioned, use verbatim)

- "A slip isn't day zero."
- "Help before you even unlock."
- "One wave at a time."
- "Your quit is nobody's business."
- "The calm way to quit anything."

### Pillars — value props (the six, in canonical order)

1. **Help at the moment of urge** — a panic button on your lock screen, Control Center, or Action button opens a 90-second breathing reset before you even unlock the phone. No app-hunting mid-craving.
2. **A slip is never day zero** — your best streak is archived, your momentum score survives the reset, and a 10-minute undo means a mistap never costs you anything. Forgiveness is a mechanic, not a mood.
3. **Private by architecture, not by promise** — no account, no sign-up, no server of ours; everything stays on your device. Discreet mode, disguised app icons, and an app-switcher shield mean your quit is nobody's business. (Add "one-tap erase" the day the erase UI ships.)
4. **Quit anything** — vaping, alcohol, adult content, cannabis, doomscrolling, or a habit you name yourself. And "cut down" is as legitimate a goal as "quit." (Add "up to three at once — one app, one price" the day quit-management ships.)
5. **Honest numbers only** — real money saved (floored, never inflated), health milestones hedged as "commonly reported," transparent pricing with no countdowns, no fake discounts, no tricks.
6. **Your reasons, in your words** — the largest type in the app is reserved for the motivations you wrote, shown back to you at the exact moment an urge peaks.

### Elevator pitch (30 seconds)

> Every quit app helps you count days. None of them help you at 11pm when the urge actually hits — the help is locked behind your passcode, four taps away. Ballast puts a panic button on your lock screen: one tap opens a 90-second breathing reset before you even unlock your phone. And when you slip, you don't go back to day one — your best is archived, your momentum survives, and the next hour starts now. No account, no cloud we control. Steady beats perfect.

### Tone rules (distilled for marketing hands)

1. Coach, never judge. The user's words outrank ours.
2. Short second-person sentences, present tense, verbs over adjectives.
3. Water carries difficulty: waves are weather, not enemies. No fight/battle/war language.
4. Always "a slip," never "relapse" or "failure."
5. Hedge every claim: "commonly reported," "~," "usually about 15 minutes."
6. Zero exclamation marks. Zero urgency. Nothing counts down against the user.
7. Pride is quiet and factual: "That one passed. 12 urges surfed and counting." — a stat, not confetti.
8. Agency returns to the user: "When you're ready, the next hour starts now."
9. Clinical nouns for sensitive categories; faith echoed, never generated.
10. Turkish (fast-follow): warm-informal *sen*, sentence case only, no idioms, no-shame gate re-run as its own pass.

---

## 4. App Store Listing Strategy

iOS only — Android is explicitly never for v1, so there is no Play Store listing. The "feature graphic" deliverable is repurposed below for Product Hunt and Open Graph duty.

### Name, subtitle, promotional text

- **App name (30 chars):** `Ballast — Quit & Cut Back` (25 chars). This deliberately overrules the brandkit §9.3 vice-in-name pattern, which feasibility already flagged: no vice words in the display name (family-visible in App Library, purchase receipts, and Screen Time reports — the audience's own discretion need argues against it). Fallback if search testing demands a category noun: `Ballast: Quit Habit Tracker`.
- **Subtitle (30 chars):** `Quit habits. Keep momentum.` (27 chars) — the retained functional tagline, carrying "quit" + "habits" as indexed terms.
- **Promotional text (rotatable, no review needed):** launch default: `No account. No sign-up. Nothing leaves your device.` Rotate seasonally (see §10). Add `One-tap erase.` only after the erase UI ships.

### Keyword directions (100-char field; no explicit terms ever)

Themes, to be composed and iterated with search-popularity data: `quit,vaping,drinking,sober,streak,tracker,urge,craving,habit,nicotine,alcohol,widget,panic,counter`. Porn-adjacent discovery is carried by subtitle/description language ("adult content") — never the keyword field, never the name. Category: Health & Fitness primary, Lifestyle secondary.

### Screenshot storyboard (6.9" 1320×2868 primary + 6.7" 1290×2796, dark-mode first — evenings are the risk window)

Device frames on Canvas-tinted backdrops (`#121417` dark set / `#F7F6F3` light set), captions in Inter Display over Waterline-field art. Privacy positioning lands in the first three captions (MVP release criterion). This re-trues brandkit §9.2: **frame 4 (three quit cards) is retired** until multi-quit ships, and **"one-tap erase" is removed from frame 3** until the erase UI ships.

| Slot | Visual (real, renderable UI) | Caption |
|---|---|---|
| 1 | Lock screen, rectangular widget: "Day 34," "$412 saved," wind-glyph Panic button | **Steady beats perfect.** Your streak — and help — on your lock screen. |
| 2 | Panic flow breath pacer mid-bloom (220pt teal circle) | Urges pass. This 90-second reset helps them pass. No account. Nothing leaves your device. |
| 3 | Discreet mode: numbers-only "Reset" widget + Calendar-style icon on a home screen | Your quit is nobody's business. Discreet widgets, a disguised icon, on-device everything. |
| 4 | Slip forgiveness screen: "Logged. Your best — 34 days — is safe, and your momentum is still 82%." | A slip isn't day zero. Your best is saved. Your momentum survives. |
| 5 | Quiz summary card: "~$1,340 /year" hero + risk-window line + motivations | Two minutes of questions. A plan in your own words. |
| 6 | Panic reasons page: the user's motivations at hero type ("Your own reasons. At the exact moment they matter.") | The biggest text in the app is yours. |
| 7 | Paywall pricing frame: plan cards with plain renewal terms | 3-day free trial. No countdowns. No tricks. Cancel in one tap. |

Frame 4 is the differentiator frame — keep it inside the first-scroll set on every device size. When quit-management ships, a new "Quit up to three at once" frame re-enters at slot 5 and the set goes to 8.

### Feature graphic / social hero (PH gallery 1270×760, OG 1200×630)

Waterline-field composition: Horizon Gradient (`#0C6F65` sky → `#5262BC` water), thin luminous waterline, the crest circle rising just above it, "Steady beats perfect." in Inter Display white (scrim-checked), small crest-mark + "Ballast" lockup lower-left. No device frame, no UI — this asset is the brand's one purely emotional image. Legible in grayscale, per illustration doctrine.

### App preview video (~20s, captured on-device, captions burned in for silent viewing)

| Time | Shot | Overlay text |
|---|---|---|
| 0.0–3.0 | Lock screen. Thumb taps the widget's wind button. App opens directly into the breath pacer. | "An urge hits. Don't even unlock." |
| 3.0–7.5 | Breath bloom expanding and contracting, one full cycle. | "In for 4. Hold for 7. Out for 8." |
| 7.5–10.5 | Reasons page: a motivation at hero type. | "Your reasons, in your words." |
| 10.5–13.0 | Tap "The urge passed" → quiet celebration screen. | "That one passed." |
| 13.0–16.0 | Dashboard card: Day N, momentum ring filling (its 600ms appear animation), money saved. | "A slip is never day zero." |
| 16.0–18.0 | Settings icon picker → home screen showing the Calendar-style disguised icon. | "Nobody has to know." |
| 18.0–20.0 | End card: crest over waterline, "Ballast — Steady beats perfect." | — |

No music-driven cuts, no bounce transitions — "breath, not bounce" governs video pacing too. Once E0.3 lands under 2s, shot 1's overlay becomes "Lock screen to breathing in under 2 seconds." and this video is re-cut with an on-screen timer — that version becomes the hero everywhere.

### What we never do in ASO

Before/after imagery, fear statistics, fake ratings badges, explicit terminology, medical claims, discreet-icon marketing, urgency mechanics. (Carried forward verbatim from brandkit §9.2/9.3 discipline.)

---

## 5. Landing Page Blueprint

One page at the cleared domain. Dark theme default (the audience visits at night), light supported. Built on the Waterline visual system, Inter Display/Inter, app palette verbatim. Primary CTA everywhere: App Store badge (TestFlight "Join the beta" during pre-launch).

### Section 1 — Hero
- **H1:** `Steady beats perfect.`
- **Sub:** `Ballast is the private way to quit anything — with a panic button on your lock screen and a streak that forgives. No account. Nothing leaves your device.`
- **Visual:** iPhone lock screen render with the real rectangular widget ("Day 34 · $412 saved" + wind button) over a Horizon Gradient waterline field.
- **CTA:** App Store badge + quiet secondary link "How it works." No email gate here.

### Section 2 — The moment that matters (how it works, 3 steps)
- **H2:** `Help before you even unlock.`
- Three columns, each with a real screen capture: **1. One tap.** "The panic button lives on your lock screen, in Control Center, or on your Action button." **2. Ninety seconds.** "Breathe with the circle — in for 4, hold for 7, out for 8. Urges crest and pass, usually within about 15 minutes." **3. Your words.** "Then the app shows you your own reasons, in your own words, at the biggest type it has."

### Section 3 — Forgiveness block
- **H2:** `A slip isn't day zero.`
- **Body:** `Log a slip and your best streak is archived, not erased. Your momentum score survives. Mistapped? Undo stays available for ten minutes. There's no red in this app, no countdowns, and no lecture — just the next hour, starting now.`
- **Visual:** the forgiveness screen ("Logged. Your best — 34 days — is safe…").

### Section 4 — Privacy block
- **H2:** `Your quit is nobody's business.`
- Four short cards: **No account** ("There's nothing to sign up for. We couldn't read your data if we wanted to — there's no server of ours to send it to."), **Discreet mode** ("Widgets show numbers only. The app disguises itself as a calendar or timer."), **Shoulder-proof** ("The app switcher shows a blank card, never your streak."), **You're in control** ("Analytics are off unless you opt in — and even then, never your answers, notes, or times."). Add an **Erase** card when the UI ships.

### Section 5 — Honest social proof
No fabricated testimonials, ever. At launch this section runs **"Built like we mean it"**: three verifiable product facts styled as quotes — `"No red anywhere in the app — errors are amber, because shame doesn't help."` / `"Milestones say 'commonly reported,' because we won't promise what we can't know."` / `"The panic button has no disabled state. Help is never turned off."` Replace progressively with real App Store reviews (quoted with rating, unedited) once they exist.

### Section 6 — Pricing
- **H2:** `Transparent, like everything else.`
- Monthly $6.99 · Annual $29.99 with a 3-day free trial (mirror live ASC config; show the A/B arm's price only to its cohort — i.e., don't publish $39.99 on the page). Renewal terms in plain sight. Line: `No countdown timers. No fake discounts. Cancel in one tap — Apple handles billing.`

### Section 7 — FAQ
1. *Is this medical treatment?* — No. Ballast tracks your progress and helps you through urges; it isn't medical care. If you drink heavily or daily, stopping suddenly can be physically risky — talk to a doctor. Free, confidential helplines are built into the app.
2. *Do I need an account?* — No. There's nothing to create and nothing to log into.
3. *What data do you collect?* — None, unless you opt in to anonymous usage analytics — and even then, never your answers, notes, or the times you log.
4. *What can I quit?* — Vaping, alcohol, adult content, cannabis, doomscrolling, or anything you name yourself. "Cut down" is a valid goal, not a compromise.
5. *What happens when I slip?* — Your best streak is archived, your momentum survives, and you can undo within ten minutes. Never day zero.
6. *Will people see it on my phone?* — Only if you want them to. Discreet mode strips habit words from every widget, and the app icon can look like a calendar or timer.

### Section 8 — Footer CTA
- **H2:** `The next hour starts now.`
- App Store badge, quiet newsletter field (`One calm email now and then. No streak guilt, ever.` — this is the only email capture in the entire funnel), links: Privacy, Terms, Support, Press kit. (Functional Terms/Privacy URLs are a pre-submission blocker — this page is where they live.)

---

## 6. Launch Strategy

### Phase 0 — Readiness (now → gates cleared)
Marketing cannot start the clock until: G0 trademark clearance; founder copy pass (§3 — the longest-lead item, gates goldens → screenshots → submission); erase UI built or claims softened in `docs/review-notes.md`; E0.3 latency measured; SaaS keys live; Terms/Privacy URLs functional. Marketing work that can proceed in parallel: landing page build, waterline asset system, video capture rigs, this calendar, SEO drafts.

### Phase 1 — Quiet beta (4–6 weeks pre-launch)
Grow TestFlight via the landing page waitlist. Seed 3–5 short videos to validate the panic-demo format before spending the launch window on it. Recruit 10–15 beta users across all three personas for feedback quotes (with explicit written permission — privacy-first brand means we ask twice). Begin publishing SEO articles (they need indexing lead time).

### Phase 2 — App Store launch (timed to the New Year quitting spike)
Submit in early December; target live by mid-December so the listing has reviews and stable rankings before January 1. Review posture decisions (teaser vs defended hard wall, dormant vs live keys) are operator calls in `docs/critical-path-post-uir.md` — marketing's only requirement: **keys must be live before paid acquisition of any kind**, or the funnel is unmeasurable and the month-3 checkpoint is meaningless.

### Phase 3 — Product Hunt (first full week of January, Tue–Thu, 12:01am PT)

- **Tagline (60 chars):** `The panic button for quitting anything — on your lock screen`
- **Gallery:** the dedicated six-card 1270×760 PH set from the creative inventory §9.4 — hero card (the emotional image) first, the screen-recorded lock-screen demo second, then forgiveness, privacy architecture, honest pricing, and the widget family — with the 20s preview video attached.
- **Hunter strategy:** self-hunt from the maker account — PH's algorithm no longer privileges big hunters, and the authenticity fits the brand. Notify the waitlist the night before ("we're on Product Hunt tomorrow — no pressure, genuinely"), answer every comment personally for 24 hours, and pre-draft honest answers to the three hard questions (data privacy, medical evidence for urge surfing, pricing).
- **First comment (draft, for founder approval):**
  > Hi PH — solo founder here. I built Ballast because every quit app I tried helped me count days but abandoned me at 11pm when the urge actually hit — the help was always four taps past my passcode. Ballast puts a panic button on the iOS lock screen: one tap opens a 90-second breathing reset before the phone is even unlocked. The other half is forgiveness: a slip archives your best streak and your momentum survives — never "day 1 again." And it's private by architecture: no account, no server of ours, on-device data, a discreet mode that disguises the whole app. It won't diagnose you, coach you loudly, or count down at you. Steady beats perfect. I'd genuinely love your questions — especially the hard ones.

### Phase 4 — Sustain (weeks 3–12)
Shift to the content engine (§7), SEO compounding (§9), and seasonal moments (§10). All spend and effort decisions defer to the month-3 checkpoint metrics (§Measurement).

### Press kit (hosted at /press)
Fact sheet (one page: what/who/pricing/availability + the name-thesis paragraph); founder story (300 words: the 11pm problem); icon set (primary crest only — never discreet alternates); 7 screenshots + preview video; waterline brand art; privacy-architecture one-pager ("what we cannot see, and why" — Dan's story is also the journalist's story); hedged-claims note (why the app says "commonly reported" — an honest differentiator angle journalists can build a story on); contact. Pitch targets: iOS/design press (the lock-screen-widget craft angle), privacy press, and habit/behavior-change newsletters — not addiction-recovery media, where we have no standing to speak.

---

## 7. Social Content Engine

Primary: TikTok + Reels + Shorts (same vertical asset, cross-posted). The hero format is the **lock-screen panic demo** — feasibility named it the load-bearing distribution bet. All screen recordings show real UI only; nothing fabricated; sensitive categories referenced clinically or via the "custom habit" slot on screen.

### TikTok / Reels concepts (hook + beats)

1. **The demo.** Hook: *"Your quit app can't help you until you unlock your phone. Mine helps before that."* Beats: phone face-up on a table → screen wakes → tap widget button → breath pacer blooming → "one wave at a time" → end card. 15s. Re-cut with an on-screen stopwatch the day the <2s measurement lands.
2. **Day 1 again.** Hook: *"The worst words in any quit app: 'Day 1 again.'"* Beats: text-on-screen montage of shame-reset patterns (generic, no competitor names) → cut to Ballast slip screen: "Your best — 34 days — is safe, and your momentum is still 82%" → "A slip isn't day zero."
3. **POV: 11pm.** Hook: *"POV: it's 11pm and the craving just hit."* Beats: dark room, phone lights up, one tap, the bloom breathing in real time for 20 uncut seconds with the 4-7-8 captions. No voiceover. The calm IS the content.
4. **Vape math.** Hook: *"I asked 100 people what their vape costs a year. Nobody knew."* Beats: quick math on screen → the app's summary hero "~$1,340 /year" → "floored, never inflated — if anything you'll save more." (Jake's video.)
5. **The disguise.** Hook: *"This calendar app is not a calendar app."* Beats: home screen with Calendar-style icon → open → dashboard → settings → icon picker → "Your quit is nobody's business." (Dan's video — no habit named on screen.)
6. **No red.** Hook: *"There is no red anywhere in this app. That's on purpose."* Beats: UI tour — amber warnings, teal actions, indigo momentum → "Shame doesn't help people quit. So we made it structurally impossible."
7. **We can't see your data.** Hook: *"Our quit app has no accounts. Not 'optional.' None exist."* Beats: age gate footer ("No account, no sign-up") → consent step defaulting off → "There's no server of ours. We couldn't sell your data if we wanted to."
8. **Urge surfing, honestly.** Hook: *"Urges usually pass in about 15 minutes. Here's what to do with those 15 minutes."* Beats: the technique explained over the timer step → "Nothing is counting down against you" → hedged, calm, useful even to people who never install.
9. **Action button.** Hook: *"The best use of the iPhone Action button nobody talks about."* Beats: Settings → Action button → Ballast Panic control → side-button press → instant pacer. Pure utility content; strong search traffic.
10. **Why no notifications.** Hook: *"Our app will never send you a notification. Here's why."* Beats: "Guilt pings don't work at 11pm. Help has to be where your thumb already is" → lock-screen widget demo. Contrarian, highly shareable.
11. **Quitter's Day.** Hook: *"Today is the day most New Year's resolutions end. Good."* Beats: "Because the streak was never the point. Steady beats perfect" → slip-forgiveness demo. (Second Friday of January — calendar anchor.)
12. **I quit TikTok on TikTok.** Hook: *"I'm using an app to quit the app you're watching this on."* Beats: custom habit "Doomscrolling" → widget on lock screen → self-aware sign-off: "Anyway. Close the app." (Mara's video; ironic reach format.)

### Instagram (feed/carousel) concepts

1. **Design-principles carousel:** "7 rules we design by" — one principle per card over waterline fields ("The door is always open," "Calm is designed, not empty," …). Design-community shareable.
2. **Waterline art posts:** the illustration system as standalone calm-feed content, one alternate tagline per image. Brand-building, zero ask.
3. **"Commonly reported" carousel:** milestone bodies as gentle cards ("By the one-day mark: taste and smell start feeling a little sharper — commonly reported."), closing card explains the hedge: "We say 'commonly reported' because we won't promise what we can't know."
4. **The slip screen, annotated:** one screenshot, five callouts (best archived, momentum intact, undo window, no red, your note stays on your device).
5. **Quiet pride stat:** "12 urges surfed and counting." over the horizon gradient. A stat, not confetti.
6. **The two icons:** primary crest next to the Calendar disguise: "One of these is a quit app. That's the point." (Editorial image, not a store asset — honoring the §9.1 rule against discreet-icon *store* marketing.)

### X posts (drafted, founder voice)

1. `Every quit app: "Day 1 again." / Ballast: "Your best — 34 days — is safe, and your momentum is still 82%." / Shame is a design choice. We chose otherwise.`
2. `We put the panic button on the lock screen because at 11pm, four taps is three too many.`
3. `Things Ballast doesn't have: accounts, servers, red, countdowns, notifications, "last chance" offers. Things it has: a breathing circle, your own reasons in your own words, and a streak that forgives.`
4. `Our milestone copy says "commonly reported" instead of promising outcomes. Honesty is slower marketing. It's also the only kind we'd want aimed at us.`
5. `The name: ballast is the weight below the waterline that doesn't push the ship anywhere. It keeps it steady in rough water. That's the whole product.`

### LinkedIn angle

One lane only: **building calm technology** — the founder essay series ("Why we made shame structurally impossible," "Monetizing without dark patterns: no countdowns, no fake discounts, and a winback that's just… an honest discount," "Privacy by unrepresentability: analytics that can't leak"). Audience: product/design/indie-dev community — a credibility flywheel that feeds press and hiring, not installs. Never target people in recovery on LinkedIn.

---

## 8. Email Campaigns

**Structural reality:** the app has no accounts and no in-app email capture — by design, and it stays that way. Email therefore reaches only landing-page subscribers and can only be triggered by email-list behavior, never app behavior. This is a feature: we get to say "we don't know if you installed, slipped, or quit — and that's the point."

List rules: single quiet capture point (landing footer), double opt-in, evening send window (the audience's risk window is when they're thinking about this), unsubscribe in one tap, zero streak-guilt, zero urgency, no open-tracking pixels (privacy brand practices what it preaches — measure by clicks and replies only).

### Onboarding sequence (trigger: newsletter signup)

| # | Timing | Subject | Body outline |
|---|---|---|---|
| 1 | Immediately | `You're in. One setup step actually matters.` | Warm welcome, one screenshot, one job: add the lock-screen widget / Control Center control (illustrated steps — this email does the widget-adoption work the app currently doesn't). CTA: App Store. |
| 2 | Day 2 | `The 90-second move` | Urge surfing explained honestly (crest-and-pass, ~15 min, hedged). The breath pacer as the tool. Useful even if they never install. |
| 3 | Day 5 | `A slip isn't day zero` | Forgiveness mechanics: archived best, momentum, 10-minute undo. "There's no red in the app. There's none in these emails either." |
| 4 | Day 9 | `What we can't see` | Privacy architecture in plain words: no account, no server of ours, opt-in-only analytics, discreet mode. |
| 5 | Day 14 | `Steady beats perfect` | The philosophy note: the name-thesis paragraph, one waterline image, quiet CTA. Then cadence drops to at-most-monthly. |

### Win-back sequence (trigger: subscribed 30+ days, never clicked an App Store link)

| # | Timing | Subject | Body outline |
|---|---|---|---|
| 1 | Day 30 | `Still thinking about it? That counts.` | "Reading about quitting is already a form of trying." One idea (the 15-minute wave), one CTA, zero pressure. |
| 2 | Day 45 | `The lock screen trick` | Pure utility: the Action-button/Control-Center setup as a tip. Position the product as the tool for a technique they already own. |
| 3 | Seasonal (e.g., Quitter's Day, Oct 1) | `Most resolutions end this week. Good.` | The steady-beats-perfect reframe. Final regular touch; survivors move to the monthly note. |

The in-app winback (the honest $14.99 first-year offer, 7 days post-trial-lapse) is a product surface, not email — it is never mirrored to the list, because we cannot and should not know who lapsed.

---

## 9. Blog & SEO Program

Compounding channel for high-intent queries; every article is genuinely useful without installing, hedged per the medical-claims rules, and ends with one quiet CTA. Publish 2/week from Phase 1.

| # | Article | Target query | Notes |
|---|---|---|---|
| 1 | How long do cravings actually last? (What the "urge wave" really is) | "how long do cravings last" | Cornerstone; hedged ~15-min framing; links every other post. |
| 2 | Urge surfing: a 90-second technique you can do without unlocking your phone | "urge surfing technique" | The panic flow's method, teachable standalone. |
| 3 | What your vape actually costs you a year (calculator) | "how much does vaping cost per year" | Interactive calculator = link magnet; mirrors the app's floored math. |
| 4 | Quit apps that don't make you create an account | "quit app no account" / "private sobriety app" | Dan's query; honest comparison table. |
| 5 | A slip is not a relapse: why "day 1 again" is bad design | "relapsed on day 30 quitting vaping" | The forgiveness thesis; careful vocabulary (slip, not relapse, explained explicitly). |
| 6 | Cutting back vs quitting: choosing the goal you'll actually keep | "how to cut back on drinking without quitting" | Alex's query; includes the alcohol-withdrawal caution + helplines. |
| 7 | How to put a panic button on your iPhone lock screen | "iphone lock screen custom button" / "action button ideas" | Utility SEO; doubles as the widget-adoption tutorial. |
| 8 | Dry January, without the all-or-nothing trap | "dry january tips" | Seasonal cornerstone, refreshed yearly. |
| 9 | Why our app has no red in it | "habit app design shame" | Design-press bait; low volume, high shareability. |
| 10 | The 4-7-8 breath: what it does and how to use it mid-craving | "4-7-8 breathing technique" | High-volume query; maps to the pacer. |
| 11 | Quitting doomscrolling with the phone you're doomscrolling on | "how to stop doomscrolling" | Mara's query; custom-habit walkthrough. |
| 12 | What "commonly reported" means: an honest guide to quit-timeline claims | "quit vaping timeline benefits" | Captures timeline searches while modeling the hedge discipline. |
| 13 | Where to get real help: every helpline in our app, and why we verified them | "quit smoking helpline" | Publishes the verified `helplines.json` list; service journalism; counsel-reviewed. |

---

## 10. Promotional Campaigns & Seasonal Moments

Standing rule: **content-led, never discount-led.** The anti-dark-pattern contract bans countdowns, fake discounts, and "one-time offers" — so seasonal moments change what we *say*, never what we *charge*. The only price promotion that exists anywhere is the in-app $14.99 winback (an honest 50% of control, in-app only, never advertised).

| Moment | Window | Play |
|---|---|---|
| New Year | Dec 26 – Jan 15 | The launch window. Promo text rotates to `New year. Same you. That's enough.` Full content-calendar burst (§11); PH launch; Dry January article refreshed. |
| Quitter's Day | 2nd Friday of January | Our most ownable moment — the day resolutions collapse is the day "A slip isn't day zero" lands hardest. TikTok #11, X thread, email #3 (seasonal), promo text: `A slip isn't day zero.` |
| World No Tobacco Day | May 31 | Vaping-focused content week (Jake); vape-math calculator push; no triumphalism — "cutting down counts today too." |
| Sober October / Stoptober | October | Alex's window; moderation-first content; refresh article #6; promo text: `"Cut down" is a goal, not a compromise.` |
| No-Nic November | November | Community-adjacent vaping moment; Action-button tutorial re-push before the December submission anniversary. |
| App milestones (post-launch) | As earned | Quiet-pride stats only, aggregated and opt-in-derived: "Ballast users have surfed N urges." Publish only when analytics consent and volume make the number honest; never individual stories without written permission. |

Paid acquisition: none until (a) keys are live, (b) funnel instrumentation is wired, and (c) organic has validated the demo format. Then small TikTok Spark Ads boosting the proven organic winners — never net-new ad creative first.

---

## 11. Four-Week Content Calendar (launch month: App Store live → PH → Quitter's Day)

| Week | Day | Channel | Asset |
|---|---|---|---|
| 1 | Mon | TikTok/Reels/Shorts | #1 The demo (hero) |
| 1 | Tue | Blog | Article 1: How long do cravings last |
| 1 | Wed | X | Post 2 (lock screen / four taps) |
| 1 | Thu | TikTok | #3 POV: 11pm |
| 1 | Fri | Instagram | Waterline art + "One wave at a time." |
| 1 | Sun | Email | Onboarding #1 to full waitlist ("we're live") |
| 2 | Mon | TikTok | #2 Day 1 again |
| 2 | Tue | Product Hunt | Launch day: gallery, first comment, all-day replies; X post 5 (name thesis) |
| 2 | Wed | LinkedIn + X | Founder essay: "Why we made shame structurally impossible"; PH thank-you post |
| 2 | Thu | Blog | Article 7: lock-screen panic button tutorial |
| 2 | Fri | TikTok | #9 Action button |
| 3 | Mon | TikTok | #5 The disguise |
| 3 | Tue | Blog | Article 4: no-account quit apps |
| 3 | Wed | Instagram | Slip-screen annotated carousel |
| 3 | Thu | X | Post 3 (things we don't have) |
| 3 | Fri (Quitter's Day) | All | TikTok #11 + X post 1 + email win-back #3 + promo text swap to `A slip isn't day zero.` |
| 4 | Mon | TikTok | #6 No red |
| 4 | Tue | Blog | Article 5: a slip is not a relapse |
| 4 | Wed | Instagram | Design-principles carousel |
| 4 | Thu | TikTok | #7 We can't see your data |
| 4 | Fri | X + LinkedIn | Post 4 (commonly reported) + essay 2: honest monetization |
| 4 | Sun | Email | Onboarding cadence review; retro against §Measurement |

Weekly rhythm thereafter: 2 TikToks, 1 blog post, 2 X posts, 1 IG, biweekly LinkedIn — with monthly review against the checkpoint metrics.

---

## Measurement & the Month-3 Checkpoint

The kill/pivot checkpoint (<1,000 quiz-completing installs/mo or <4% conversion at launch+3 months) is only meaningful if the funnel is instrumented. Marketing's hard dependencies on engineering, stated plainly:

| Metric (target) | Status | Blocker |
|---|---|---|
| Panic widget added by D1 ≥40% (north star) | Unmeasurable | `widget_added` unwired; no in-app adoption step exists — email #1 and TikTok #9 are the stopgap, but the post-summary widget-adoption screen in the product redesign is the real fix. |
| Panic uses per WAU | Unmeasurable | `panic_opened` / `panic_step_reached` enum-defined, not fired. |
| Quiz completion ≥70%, quiz→trial ≥8%, trial→paid ≥35% | Ready when keys live | TelemetryDeck + RevenueCat keys are empty in all shipping builds. |
| Post-slip D7 retention | Unmeasurable | `slip_logged` fire point is a named TODO. |
| Channel attribution | Partial | No accounts and no ad SDKs by design — use Apple Search Ads-free proxies: promo-code-free App Store Connect sources, PH referrer spikes, per-video App Store page views. Accept coarse attribution as a privacy cost worth paying, and say so publicly. |

Weekly during launch month, monthly after: installs by source-proxy, quiz completion, trial starts, conversion, panic uses/WAU, widget-adoption rate, content view→profile→store click-through on TikTok. The pre-registered decision rule stands: if month-3 numbers miss, engineering weeks convert to distribution weeks — this plan is written so that conversion has somewhere productive to land (the content engine, not more features).
