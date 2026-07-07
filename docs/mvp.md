# MVP: Unhooked (App Store name: "Unhooked: Quit Vaping, Porn & Alcohol")

**Document date:** 2026-07-07 · **Scope:** the PRD's "v1.0 / weeks 1–4" release, adjusted per the feasibility report. Realistic build estimate: 5–6 solo-dev+AI-agent weeks.

> **Naming note (blocking):** per the feasibility report, "Unhooked" is used by 5+ live products in this category (including a nicotine app with a panic button) and the title's explicit vice list ("…Porn…") is an ASO/review liability. This document keeps the working title because the PRD does, but **rename is a pre-build gate**, and the research explicitly contradicts the PRD's current App Store name.

---

## 1. MVP Thesis

**The single riskiest assumption this MVP validates:** *that organically-acquired users will complete a 90-second quiz and convert to a paid trial at ≥8% for a multi-vice, no-account, lock-screen-first quit app — i.e., that THIS wedge converts, not merely that the category does.*

Everything else is already de-risked by the market: category demand (Quittr ~$3M yr 1), hard-paywall quiz funnels (RevenueCat 39.9% median trial→paid), and lock-screen widget appeal (I Am Sober's widgets, the vape clone swarm). What is unproven — and what Quit All's zero-traction existence makes urgent to test — is whether a privacy-first, forgiveness-toned, multi-vice entrant can win its share of the funnel without accounts, without shame, and without paid ads. The MVP is therefore built as a **conversion-measurement instrument first and a product second**: the quiz→paywall funnel and the widget-adoption→panic-usage loop are the two things it must measure cleanly.

Secondary assumptions validated: (a) the lock-screen panic path gets used in real urge moments (≥1.0 uses/WAU); (b) forgiveness mechanics retain post-slip users instead of licensing relapse; (c) the lock-screen-panic demo works as a TikTok acquisition format.

---

## 2. Features Included

Each with a one-line acceptance criterion (AC). These are the PRD's P0 stories plus one research-driven promotion (Reduce mode prominence).

1. **Onboarding quiz (12–14 screens; the conversion engine — full build week per PRD §6.1).**
   AC: a new user reaches a personalized quit summary (projected annual savings + likely risk window) in ≤120s median, with `quiz_step_completed` firing on every step, before seeing any paywall.
2. **Hard-ish paywall after quiz, RevenueCat + Superwall.**
   AC: paywall renders after the quiz summary with $6.99/mo and annual A/B ($29.99 vs $39.99), 3-day free trial on annual, purchase completes via StoreKit 2, and the teaser-vs-hard variant is remotely switchable.
3. **Streak engine with slip forgiveness + Momentum score.**
   AC: logging a slip takes ≤2 taps, archives the streak to "best," preserves Momentum (clean days ÷ total days, shown as %), offers an optional reflection note and a 10-minute undo, and never shows shame copy.
4. **Quit and Reduce goal modes (Reduce promoted to headline per research).**
   AC: a user can set a weekly allowance, log occurrences, and see adherence-framed progress and money saved; Reduce is offered in the quiz goal step, not buried in settings.
5. **Up to 3 concurrent quits (vape, porn, alcohol modules + weed/doomscrolling/custom pickers per PRD).**
   AC: each quit has independent streak state, milestones, and a per-widget quit selector with no cross-contamination.
6. **Lock-screen widget suite (accessoryRectangular with interactive Panic button, accessoryCircular ring, accessoryInline) + home widgets (systemSmall/Medium).**
   AC: streak/money data on the lock screen updates within 60s of a logged event, and each family renders correctly in light/dark/tinted modes.
7. **Interactive Panic launch via AppIntents.**
   AC: tapping Panic on the lock-screen widget lands in the full-screen intervention in <2.0s cold start, measured on the oldest supported device.
8. **Panic flow (~90s, skippable at every step).**
   AC: breath pacer (4-7-8 × 3, haptic-guided) → urge-timer message → the user's own quiz motivations verbatim in big type → redirect menu → exit as "urge passed" (logs `urge_averted`, quiet celebration) or "I slipped" (routes to slip flow, zero shame copy).
9. **Discreet mode (P0 per PRD — top-3 requested feature across incumbent reviews).**
   AC: every widget has a numbers-only/neutral-icon variant and the app offers at least two alternate innocuous icons, all switchable in one settings screen.
10. **Money-saved counter, prominent (research: the universally loved feature in the vaping vertical).**
    AC: money saved (weekly spend × clean time) appears on the quiz summary, the main screen, and the rectangular widget by default.
11. **Safety layer (PRD §6.7, non-negotiable).**
    AC: region-aware helplines screen reachable in one tap from Settings and from every slip flow; the alcohol module shows the fixed withdrawal-danger notice once, calmly; no medical claims anywhere; milestones phrased "commonly reported."
12. **Privacy architecture: no accounts, on-device + iCloud, one-tap erase.**
    AC: the app is fully functional with iCloud off; "Erase everything" removes all local + synced data after a confirm, verified by relaunch showing a fresh install state.
13. **Streak time integrity.**
    AC: setting the device clock backward/forward or crossing timezones never inflates a streak (monotonic anchor + sanity checks pass an explicit test matrix).
14. **TelemetryDeck analytics, opt-in, category-level only.**
    AC: every event in §5 fires with only the listed properties; a proxy inspection confirms no journal content, notes, or slip timestamps leave the device.

---

## 3. Features Explicitly Excluded

Respecting the PRD's non-goals (§3), plus scope cuts to hold the 5–6 week line:

| Excluded | Why |
|---|---|
| Community/social feed | PRD non-goal (v2): moderation load is a solo-founder trap at launch. |
| Content blocker / DNS filtering | PRD non-goal: a separate hard product; Quittr has it and it isn't the wedge. |
| Medical/therapeutic claims or content | PRD non-goal and a legal/App Review requirement. |
| Android | PRD non-goal (v1); iOS 26 AppIntents is the whole technical wedge. |
| Gambling module | PRD non-goal: higher duty-of-care bar; Quit All covers it, we don't chase it. |
| Shame mechanics (red screens, "you failed," leaderboards) | PRD non-goal; forgiveness IS the differentiator. |
| AI urge companion | PRD P1 (§6.6): the only server component and the largest guardrail burden; excluded until the funnel is proven. |
| Live Activity / Dynamic Island urge timer | PRD P1: additive, not thesis-validating. |
| Urge journal pattern insights, share cards, Apple Health write | PRD P1: retention/viral polish, not conversion proof. |
| Screen Time API for doomscrolling module | PRD open question resolved lean: honor-system logging v1; entitlement later if the module earns it. |
| Lifetime SKU | PRD decision, reaffirmed by research: protects LTV; anti-subscription clones make lifetime a race to the bottom. |
| Localization beyond EN | PRD: copy tone is the product; TR fast-follow after tone is proven. |
| StandBy widget | Scope cut from the PRD's widget table: lowest-reach surface; ship in v1.1 with Live Activity work. |

---

## 4. Success Metrics

Adapted from PRD §2; each measurable from the §5 events + RevenueCat + App Store Connect. Measurement window: first 60 days post-launch.

| Metric | Target | How measured | Note vs PRD |
|---|---|---|---|
| Quiz completion (start→summary) | ≥70% | `quiz_step_completed(1)` → `quiz_completed` funnel in TelemetryDeck | Unchanged (funnel north star) |
| Quiz completers → trial start or purchase | ≥8% | `quiz_completed` → RevenueCat trial/purchase events | Unchanged; research says conservative-to-realistic |
| Trial → paid conversion | ≥35% | RevenueCat | Added: category median is 39.9%; below 35% means the paywall promise mismatches the product |
| Panic widget added by D1 | ≥40% of installs | `widget_added(kind=panic)` (via widget first-render signal) ÷ installs | Unchanged (product north star) |
| Panic uses per WAU | ≥1.0 | `panic_opened` ÷ WAU | Unchanged (value proof) |
| Post-slip D7 retention | ≥50% of users who log a slip open the app within 7 days | `slip_logged` cohort → any subsequent event | Added: directly tests the forgiveness thesis |
| D30 subscriber retention | ≥65% (report against the PRD's 75%) | RevenueCat cohorts | **Explicit disagreement with PRD:** 75% is above health-category norms; 65% is the honest bar, 75% the stretch |
| App Store rating | ≥4.7 | App Store Connect | Unchanged |
| Revenue trajectory | ≥$1,250/mo net by month 3 (on path to $5K by month 6) | RevenueCat + App Store payments | Added interim checkpoint so the month-6 goal is steerable |

---

## 5. Analytics Requirements

TelemetryDeck, **opt-in**, no user identifiers beyond TelemetryDeck's default rotating anonymous ID. Hard rule (PRD §7/§10): events may carry funnel step and habit *category* only — never journal/notes content, never slip timestamps (aggregate counts only), never quiz answer values beyond category. Habit category is still sensitive-class data (GDPR / WA My Health My Data): disclose in the privacy policy and App Privacy labels.

| Event | Trigger | Properties |
|---|---|---|
| `onboarding_started` | First quiz screen rendered | `variant` |
| `quiz_step_completed` | User advances a quiz step | `step_number` (1–14) |
| `quiz_completed` | Personalized summary shown | `habit_category` (vape/porn/alcohol/weed/doomscroll/custom), `goal_mode` (quit/reduce) |
| `paywall_viewed` | Paywall rendered | `variant` (Superwall id), `price_test` (29_99/39_99), `source` (onboarding/settings/winback) |
| `trial_started` | StoreKit trial begins (via RevenueCat) | `product` |
| `purchase` | Purchase/renewal confirmed | `product`, `period` (monthly/annual) |
| `teaser_entered` | User takes 1-day teaser instead of paying (if variant active) | `variant` |
| `quit_created` | A quit is added | `habit_category`, `goal_mode`, `quit_index` (1–3) |
| `widget_added` | Widget renders its first timeline | `kind` (panic_rect/circular/inline/home_s/home_m), `discreet` (bool) |
| `panic_opened` | Panic intervention screen appears | `source` (lockscreen_widget/home_widget/in_app), `cold_start_ms` (bucketed: <1s/1–2s/>2s) |
| `panic_step_reached` | Each panic-flow stage entered | `step` (breath/timer/reasons/redirect) |
| `urge_averted` | "Urge passed" exit tapped | `habit_category` |
| `slip_logged` | Slip confirmed (post-undo-window) | `habit_category` (no timestamp property; no note content) |
| `slip_undone` | 10-minute undo used | — |
| `discreet_mode_enabled` | Discreet toggle or alternate icon set | `component` (widget/icon) |
| `resources_viewed` | Helplines/safety screen opened | `source` (settings/slip_flow) |
| `erase_all_completed` | One-tap erase confirmed | — (final event for that ID) |
| `winback_shown` / `winback_converted` | Win-back offer displayed / redeemed (7 days post trial lapse) | `offer` |

Implementation notes: bucket `cold_start_ms` client-side so no precise timing fingerprint leaves the device; fire nothing before the analytics opt-in choice (default off until answered); the opt-in prompt lives in the quiz's early steps with plain-language copy.

---

## 6. Monetization Strategy

Per PRD §6.5, with two research-justified changes flagged.

- **Model:** hard-ish paywall after the quiz summary (category-proven; hard paywalls convert ~5x freemium per RevenueCat 2025). Nothing past the summary without trial/purchase, except the A/B'd 1-day teaser variant (PRD's planned week 1–2 test).
- **Pricing:** $6.99/mo; annual **A/B $29.99 vs $39.99** with a 3-day free trial on annual only. **Change vs PRD:** the PRD fixes $29.99/yr; research shows every comparable charges $45–$100/yr and lower-priced trials convert better — so instead of silently keeping or raising the price, run the test from day one. No lifetime SKU (PRD-aligned).
- **Trial mechanics:** 3-day trial on annual; 80–90% of trials start Day 0 (RevenueCat), so the quiz summary → paywall moment is the business. Trial-start is the primary conversion event.
- **Win-back:** 50% off annual, 7 days after trial lapse (PRD-specified), delivered via Superwall placement + local notification (never via the panic path).
- **Positioning copy on the paywall (research-driven):** "No account. No server. Nothing to leak. Apple handles billing — cancel or refund in one tap." This converts incumbents' top 1-star complaints into conversion copy and is unique to this architecture.
- **Explicitly not doing:** weekly pricing (Puff Count's ~$10/wk is its #1 resentment driver and reputational poison in this category), hidden pricing until after long surveys, or re-paywalling paid users on update (Quittr's scandal).

---

## 7. Release Criteria

The gate for App Store submission. Every item is pass/fail.

**Product**
- [ ] Quiz: all 12–14 steps complete on device, personalization (savings figure, risk window, motivations) verifiably flows into summary, widgets, and panic flow.
- [ ] Panic: lock-screen widget tap → intervention screen **<2.0s cold** on the oldest supported device, 10/10 attempts.
- [ ] Streak integrity test matrix passes: clock backward, clock forward, timezone cross, DST boundary, device reboot — streak never inflates.
- [ ] Slip flow: 2 taps, archive-to-best, Momentum % correct, 10-min undo works, copy reviewed against the zero-shame rule.
- [ ] 3 concurrent quits with per-widget selectors show no cross-contamination.
- [ ] All widget families render correctly in light/dark/tinted; data fresh within 60s of a logged event.
- [ ] Discreet mode: no-context widget variants + alternate icons verified on the physical lock screen.
- [ ] Reduce mode: allowance setting, adherence display, and money-saved verified for the alcohol persona path.
- [ ] iCloud-off mode fully functional; iCloud-on syncs across two devices; one-tap erase leaves a fresh-install state on both.

**Safety (non-negotiable, PRD §6.7)**
- [ ] Resources screen reachable in one tap from Settings and from every slip flow; US helplines (SAMHSA) verified correct.
- [ ] Alcohol withdrawal notice present, calm, shown in the alcohol module.
- [ ] Copy audit: no medical claims, no fear content, no fabricated statistics; milestones say "commonly reported."

**Monetization**
- [ ] Sandbox: trial start, trial→paid, monthly purchase, restore purchases, and cancellation all verified via RevenueCat.
- [ ] Superwall A/B live and remotely switchable (price test + teaser-vs-hard).
- [ ] No paid feature reachable without entitlement; no entitlement loss on app update (regression test — this is Quittr's scandal).

**Privacy & analytics**
- [ ] Network proxy inspection: zero events before opt-in; opted-in events carry only §5 properties; no content, notes, or slip timestamps ever transmitted.
- [ ] App Privacy labels and privacy policy accurate, including habit-category disclosure (GDPR / WA MHMD sensitive-class).
- [ ] No account creation path exists anywhere in the app.

**App Review readiness**
- [ ] 17+ age rating set; porn-module copy clinical ("adult content"); no explicit terms in name, subtitle, keywords, or screenshots.
- [ ] **Rename completed and cleared** (App Store search, USPTO, domain) — blocking, per feasibility report.
- [ ] Screenshot #1 shows the lock-screen panic button; preview video is the lock-screen→intervention demo.
- [ ] Accessibility pass: Dynamic Type, VoiceOver on quiz + panic flow, haptic-only breath pacer option.
- [ ] Crash-free rate ≥99.5% across a ≥20-user, ≥1-week TestFlight; zero P0/P1 bugs open.

**Launch readiness (per feasibility conditions — gates launch, not the binary)**
- [ ] Written content plan exists with a 2-week bank of recorded TikTok assets, hero format = lock-screen panic demo.
