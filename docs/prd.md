# PRD: Unhooked - The Quit-Anything Streak Widget

| Field | Value |
|---|---|
| Product | Unhooked (working title; App Store name: "Unhooked: Quit Vaping, Porn & Alcohol") |
| Version | PRD v1.0 (Draft for build) |
| Date | July 7, 2026 |
| Owner | Solo founder |
| Platforms | iOS 26+ |
| Status | Approved as high-ceiling candidate (Rank #3) |

---

## 1. Summary

**One-liner:** Your streak on your lock screen. Your panic button one tap away.

**Problem:** Relapse happens at the moment of urge, on the phone, usually at the lock screen. Incumbent quit apps (single-vice, subscription-heavy) require unlocking the phone, finding the app, and opening it: three steps too many at the exact second willpower is lowest. People juggling two habits (vape + doomscrolling, porn + weed) must run two subscriptions. And streak resets are handled so punitively that a slip becomes a spiral.

**Solution:** One app, up to three concurrent quits, with the streak counter and an **interactive panic button living directly on the lock screen** (AppIntents). One tap opens a 90-second urge-surfing intervention without ever seeing another app. Forgiveness is a feature, not a bug: slips are logged honestly without nuking identity ("day 1 again").

**Market proof:** Quittr (porn-only) reached ~$250k MRR within 4 months and ~$3M first-year revenue on this exact psychology with a worse widget story. The playbook is public; the differentiators here are multi-vice + lock-screen-native intervention + forgiveness mechanics.

---

## 2. Goals & Success Metrics

**Business goal:** $5,000/month net by month 6 (~170 net-new annual subs/month at $29.99 after Apple's 15%, plus monthlies).

| Metric | Target | Type |
|---|---|---|
| Onboarding quiz completion | ≥70% | **Funnel north star** |
| Quiz completers → trial/paid | ≥8% (hard-ish paywall category norm) | Revenue |
| Installs with panic widget added by D1 | ≥40% | Product north star |
| Panic-button uses per WAU | ≥1.0 | Value proof |
| D30 subscriber retention | ≥75% | Revenue |
| Rating | ≥4.7 | Trust |

---

## 3. Non-Goals (v1)

No community/social feed (v2; moderation load is a solo-founder trap at launch). No content blocker/DNS filtering (separate hard product; integrate later or never). No medical or therapeutic claims anywhere: this is a habit-tracking and motivation tool. No Android v1. No gambling module v1 (higher duty-of-care bar; revisit with proper resources). No shame mechanics: no red screens, no "you failed" copy, no public streak leaderboards.

---

## 4. Personas

- **Jake, 22, retail worker.** Vaping since 17, tried cold turkey twice. Money-saved counter is his motivator. Found the app through a TikTok "30 days no vape" video.
- **Dan, 26, self-improvement X/Reddit native.** Quitting porn; privacy is everything; will not create an account; converts on a strong onboarding quiz that mirrors his motivations.
- **Alex, 31, "sober curious."** Cutting alcohol, not identity-quitting. Wants a calm counter and urge tools without AA framing.

---

## 5. User Stories (prioritized)

**P0 (v1.0, weeks 1-4)**
1. As a new user, I complete a 12-step quiz that names my habit, cost, triggers, and motivations, and receive a personalized quit summary before any paywall.
2. As a user, I see my streak (days/hours), money saved, and health-milestone progress on a lock screen widget without opening the app.
3. As a user, I tap a **Panic** button on the lock screen widget and land in a full-screen 90-second intervention (breathing + urge timer + my own reasons) in under 2 seconds.
4. As a user who slipped, I log it in two taps and the app responds with recovery framing: streak archived (best: 34 days), momentum score keeps partial credit, no lecture.
5. As a user, I can run up to 3 quits at once, each with its own widget.
6. As a user, my data lives on-device/iCloud with no account and I can erase it all in one tap.

**P1 (weeks 5-9):** urge journal with pattern insight ("your risk window is Sun 10pm-1am", computed on-device); AI urge-companion chat inside the panic flow (guardrailed, see 6.6); Live Activity "urge timer" for the Dynamic Island; milestone share cards (anonymous-safe designs); Apple Health mindful-minutes write (opt-in).

**P2:** anonymous community (heavily moderated), accountability-partner pairing, quit-plan programs (structured 30/60/90-day tracks), gambling module with enhanced safeguards.

---

## 6. Functional Specification

### 6.1 Onboarding Quiz (the conversion engine; give it a full build week)
- 12-14 screens, one question each, progress bar, ~90 seconds total: habit picker (vape / porn / alcohol / weed / doomscrolling / custom) → frequency → weekly spend → duration of habit → trigger checklist → prior quit attempts → motivation picker (energy, money, relationships, self-respect, faith, focus) → symptom/effects checklist → goal (quit vs cut down) → commitment slider → personalized summary ("Based on your answers: you'll save ~$1,340/year and your first hard window is likely evenings") → social proof screen (real review quotes) → **paywall**.
- All answers stored locally only; they drive widget copy, panic-flow content, and milestone framing.
- Instrumented per-step (`quiz_step_completed(n)`) because this funnel IS the business.

### 6.2 Streak Engine
- Per-quit state: start timestamp, current streak, best streak, total clean days, slips log, money-saved (spend/week × clean time), configurable health/benefit milestones per habit type (from a static, non-medical, benefit-framed content table).
- **Slip handling (differentiator):** logging a slip archives the streak to "best," starts a new counter, and preserves a cumulative **Momentum score** (clean days ÷ total days, shown as %) so identity survives the reset. Optional "reflection" note. Undo window of 10 minutes for mis-taps. Copy tone: coach, never judge.
- Goal modes: Quit (zero) or Reduce (allowance/week; counts adherence, for the alcohol persona).
- Time integrity: streaks computed from timestamps, immune to clock fiddling within reason (monotonic anchor + sanity checks); timezone travel safe.

### 6.3 Widget Suite

| Surface | Family | Content | Notes |
|---|---|---|---|
| Lock screen | accessoryRectangular | "🔥 34 days · $412 saved" + **Panic** button | Interactive via AppIntents; Panic deep-links to intervention |
| Lock screen | accessoryCircular | Streak day count ring | Per-quit selectable |
| Lock screen | accessoryInline | "Day 34 vape-free" | Discreet-mode variant: "Day 34" only |
| Home | systemSmall | Streak + momentum % | One per quit |
| Home | systemMedium | Streak + money + next milestone bar | |
| StandBy | pair | Nighttime "you made it through today" state | Evening risk-window aware |
| Live Activity (P1) | Dynamic Island | 15-minute urge timer countdown | Started from panic flow |

**Discreet mode (P0):** every widget has a no-context variant (numbers only, neutral icon) and alternate app icons ("Calendar-ish", "Timer") because this category's users share phone screens with family. This is a top-3 requested feature across incumbent reviews.

### 6.4 Panic Flow (the product's soul)
Sequence, skippable at any point, total ~90s:
1. Full-screen breath pacer (4-7-8, three rounds, haptic-guided).
2. Urge timer: "Urges crest and pass, usually within 15 minutes" + start Live Activity (P1).
3. "Your reasons": the user's own onboarding motivations, verbatim, big type.
4. Redirect menu: 60-second cold-water/pushup/walk prompt, journal one line, or (P1) talk to the AI companion.
5. Exit states: "Urge passed" (celebrate quietly, log an averted-urge stat) or "I slipped" (route to 6.2 slip flow, zero shame copy).

### 6.5 Monetization
- **Hard-ish paywall** after the quiz (category-proven): 3-day free trial on annual.
- Pricing: $6.99/mo · $29.99/yr · no lifetime v1 (LTV protection in a high-motivation category).
- Free without paying: nothing past the quiz summary except a 1-day teaser mode (A/B: teaser vs fully hard).
- StoreKit 2 via RevenueCat; win-back offer (50% off annual) 7 days after trial lapse.

### 6.6 AI Urge Companion (P1, guardrailed)
- Single serverless endpoint → LLM with a fixed system prompt: supportive coach, urge-surfing techniques only; **hard rules:** no medical/withdrawal advice, no moralizing, and any self-harm signal returns a fixed template surfacing regional crisis resources and encouraging human help, then ends coaching.
- Rate-limited (protects cost + prevents dependence loops); transcripts stored on-device only; feature is opt-in and clearly labeled AI.

### 6.7 Safety & Content Standards (P0, non-negotiable)
- Static resources screen: region-aware helplines (e.g., SAMHSA for US) and "when to seek professional help" plain-language guidance, one tap from Settings and from every slip flow.
- Alcohol module includes a fixed notice that suddenly stopping heavy drinking can be dangerous and a doctor should guide it (this is the one place cautionary language is mandatory, phrased once, calmly).
- No before/after imagery, no fear content, no fabricated statistics. Benefit milestones phrased as "commonly reported," never as medical promises.
- App Store rating 17+; porn-module copy kept clinical ("adult content") for review compliance; no explicit terms in ASO metadata.

---

## 7. Non-Functional Requirements

- **Privacy:** no accounts; data on-device + iCloud (user-key); analytics (TelemetryDeck, opt-in) may carry funnel steps and habit *category* only, never journal content or timestamps of slips; one-tap full erase. This category's users are privacy-anxious; treat it as seriously as the pregnancy product.
- **Performance:** lock-to-panic-screen in <2s cold; widget updates within 60s of a logged event (reload timelines on write).
- **Accessibility:** haptic-only breath pacer option, Dynamic Type, VoiceOver.
- **Localization v1:** EN only (copy nuance is the product; localize after tone is proven), TR fast-follow.

## 8. Architecture & Stack

Swift 6 + SwiftUI; WidgetKit + AppIntents (interactive Panic) + ActivityKit (P1); local persistence (SwiftData) + iCloud sync; StoreKit 2 via RevenueCat + Superwall (paywall A/B, the Quittr-proven combo); TelemetryDeck; one serverless function for AI companion (P1). No accounts, no database server.

## 9. Data Model (local)

```
Quit { id, type, startAt, goalMode, weeklySpend, triggers[], motivations[],
       slips[{at, note?}], bestStreakDays, avertedUrges, discreetMode }
Settings { entitlement, discreetIcon, analyticsOptIn }
```

## 10. Analytics Events

`quiz_step_completed(n)`, `quiz_completed(habit_category)`, `paywall_viewed(variant)`, `purchase(product)`, `panic_opened(source)`, `urge_averted`, `slip_logged(category)`. Nothing content-level, ever.

## 11. Edge Cases

Multiple quits with clashing widgets (per-widget quit selector); clock set backward (monotonic guard, streak never inflates); relapse-log spam (rate-limit celebrations, never rate-limit help); user deletes a quit (export/erase confirm); iCloud off (fully local mode); Screen Time/Focus hiding notifications (panic path never depends on notifications).

## 12. Release Plan

| Release | Week | Contents |
|---|---|---|
| v1.0 | 4 | Quiz + streaks + panic flow + widgets + discreet mode + paywall (EN) |
| v1.1 | 6-7 | Live Activity urge timer, share cards, win-back offers, iOS 27 widget sizes |
| v1.2 | 9-10 | AI urge companion (guardrailed), pattern insights, Health mindful minutes |
| v1.3 | 12+ | Accountability pairing; community scoping decision with real data |

## 13. Risks & Mitigations

| Risk | Mitigation |
|---|---|
| Crowded post-Quittr entrant wave | Differentiate on lock-screen intervention + multi-vice + forgiveness; win the funnel, not the feature list |
| App Store review sensitivity (addiction/adult topics) | 17+ rating, clinical copy, resources screen, no medical claims; pre-review checklist |
| Vulnerable-user duty of care | 6.6/6.7 guardrails are P0 acceptance tests; crisis resources always one tap away |
| Ad-platform restrictions | By design: organic TikTok formats, meme placements, creator rev-share, SEO ("how to quit X") |
| High emotional churn on relapse | Momentum score + zero-shame copy + win-back pricing |

## 14. Open Questions

Name/trademark ("Unhooked" availability); launch with 3 vs 5 habit modules (lean: vape + porn + alcohol first, they carry proven demand); teaser-mode vs fully hard paywall (A/B week 1-2); whether doomscrolling module needs Screen Time API (v1: honor-system logging only, API entitlement later).
