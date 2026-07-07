# Feasibility Report: Unhooked (App Store name: "Unhooked: Quit Vaping, Porn & Alcohol")

**Document date:** 2026-07-07 · **Inputs:** PRD v1.0 (`prd.md`), competitor research (2026-07-07), market research (2026-07-07). Competitor revenue figures are third-party estimates (Sensor Tower, BoringCashCow, founder posts) unless noted.

---

## 1. Executive Summary

**Verdict: GO WITH CAUTION.**

The market is large, willingness-to-pay is proven at 2–3x the PRD's price point, and the PRD's revenue goal ($5K/mo net by month 6) is roughly 2% of Quittr's demonstrated run-rate — the demand side clears easily. The technical bet (interactive lock-screen panic button via AppIntents on iOS 26) is real, stable, and still unowned as a marketed position. The incumbents' biggest weaknesses (Quittr's billing scandal and data breach, Puff Count's predatory weekly pricing, punitive streak resets, single-vice silos) map one-to-one onto this PRD's differentiators. Portfolio fit is excellent: no backend, no accounts, no moderation, reusable stack.

Three findings force the "caution" qualifier:

1. **The name "Unhooked" is burned.** At least five live products use it in this exact category, including a nicotine app (unhooked.today) that already markets a panic button — the PRD's core feature under the PRD's own name. Trademark risk and ASO pollution make a rename a hard precondition, not an option. The PRD itself flags this as an open question; the research resolves it: rename.
2. **The concept wedge has been partially shipped.** Quit All — Break Every Habit (March 2025, solo dev) already offers multi-vice, SOS mode, no-shame relapse logging, no-account/local-first, and lock-screen widgets — ~70% of this PRD. It has near-zero traction, which proves demand for the concept but also proves the wedge is now **execution, funnel, and brand — not concept**. The remaining feature gaps: *interactive* lock-screen panic launch, the quiz-driven funnel, the porn module, and Reduce/taper mode.
3. **Growth in this category is founder-content-driven** (3–5 TikToks/day was the Puff Count/Quittr playbook). The PRD assumes organic-first but commits to no content plan. Without one, the funnel math never gets traffic to run on.

Conditions to satisfy are listed in §7.

---

## 2. Market Feasibility

### Market size
Bottom-up (US iOS, roughly the 20–35 band the personas target), from the market research:

- **Vaping:** ~4.7M US young adults 18–25 vape (CDC); roughly half report wanting to quit → ~2–3M in-market, concentrated in the target age band.
- **Porn:** 11% of men self-identify as at least somewhat addicted; up to 25% report problematic use, peaking in late teens/20s; r/NoFap >500K members; Quittr alone reached ~1M users / ~100K paid.
- **Alcohol:** 47% of US adults say they want to cut back; mindful-drinking app market ~$1.57B (2025); r/stopdrinking ~684K–900K members; Sunnyside raised $14.6M.

**SAM ≈ 5–8M** US iOS users, 20–35, actively trying to quit one of the three vices. The PRD's goal (~170 net-new annual subs/month) requires ~0.03% of SAM per month — trivially small relative to the market. Single-vice comparables (Quittr ~$3M year one; Puff Count ~$40K MRR) each clear the target multiple times over.

### Search demand
Exact keyword volumes unavailable publicly (would need AppTweak/MobileAction), but proxy signals are strong: Puff Count built 800K+ users largely on ASO + TikTok; Quittr hit 350K downloads across 120 countries by April 2025. **Difficulty is high and rising**: a post-Quittr entrant wave crowds "quit porn" (QUITTR, CURE, Overcomer, Fortify, Rewire Companion all live), and Puff Count dominates "quit vaping." The realistic wedge is long-tail: "panic button urge," "streak widget lock screen," "no vape counter." Note that "porn" cannot safely appear in ASO metadata — incumbents use "Break Free"-style names — which means the current App Store name ("…Porn…") likely needs revision on compliance grounds alone, independent of the trademark problem.

### Monetization potential
- Category benchmarks: Quittr $12.99/mo or ~$45/yr with ~10% paid rate of ~1M users; Puff Count ~$10/wk (aggressively); Reframe/Sunnyside $79.99–$99/yr.
- RevenueCat 2025: Health & Fitness median trial→paid **39.9%** (top decile 68.3%); **hard paywalls convert ~5x freemium** (10.7% vs 2.1% download→paid by D35); 80–90% of trials start Day 0; lower price points convert trials better (47.8% vs 28.4%).
- **The PRD's $29.99/yr under-prices every comparable ($45–$100/yr).** The ≥8% quiz-completer→paid target is conservative-to-realistic. There is room to test $39.99–$49.99 annual without hurting conversion while still undercutting incumbents and converting their pricing resentment.

### User-acquisition difficulty
**High effort, low cash.** Paid UA is structurally constrained (vaping/adult-adjacent ad restrictions) — the PRD's organic-first assumption is validated. The proven channel is founder-led TikTok/UGC (one Puff Count video: 8.3M views → tens of thousands of installs); UGC Spark Ads run ~27% cheaper CPI; health-vertical CPI $0.80–$3.50; global median ~$1.72. Reddit (r/stopdrinking, r/quitvaping, r/pornfree, r/NoFap) is high-intent but allergic to self-promo — works only via genuine participation. SEO compounds slowly (Quittr also exploited LLM-SEO). **The binding constraint on this business is content output, not engineering.** The one structural asset: the lock-screen panic demo (screen-record: lock screen → tap → breathing in <2s) is a natively viral TikTok format no incumbent can copy without shipping the feature.

---

## 3. Competitor Analysis

Sourced from the embedded competitor research (2026-07-07). Revenue figures are third-party estimates unless noted; review-sentiment figures cite JustUseApp/marlvel aggregations.

| Competitor | Vice(s) | Key features | Pricing | Review sentiment | Strengths | Weaknesses | Est. revenue |
|---|---|---|---|---|---|---|---|
| **Quittr** (PRD's benchmark) | Porn only | Quiz→hard paywall, streaks, panic button (in-app only), AI therapist "Melius," content blocker, community, SEO attack pages | $12.99/mo · ~$45/yr | 4.7★ facade; **JustUseApp safety score 33.4/100** across 30K+ reviews: double-billed lifetime purchases, month-long refund fights, updates that re-paywall paid users, no support; **404 Media-reported breach exposed hundreds of thousands of users' habit data, including minors** | Brand momentum, funnel mastery, SEO moat, 1M+ downloads / 120+ countries | Single-vice, trust collapse, account-based, shame-tinged marketing | ~$300K/mo (Sensor Tower est.); ~$250K MRR at month 4 and ~$3M year 1 corroborated |
| **Quit All — Break Every Habit** (missing from PRD; closest direct threat) | Multi (smoking, vape, alcohol, social media, gambling, spending, caffeine) | SOS craving mode, home + lock-screen widgets (**read-only**), no-shame relapse logging with context, no account, local-first; iOS 17.6+, solo dev, Mar 2025 | $6.99/wk · $34.99/yr · $69.99 lifetime · free tier | Too few ratings to display a score | ~70% of this PRD already shipped and actively updated | No porn module, no *interactive* lock-screen panic, no quiz personalization, invisible marketing | Unknown (negligible traction) |
| **Puff Count** | Vaping | Puff/taper tracking, money saved | ~$10/wk; avg IAP ~$36.66 | 4.3★/2.5K; top complaints: deceptive "free" marketing, paywall blocks all post-trial use, "quitting via the app costs more than vaping" | Owns "quit vaping" ASO; TikTok-built (800K+ users) | Pricing resentment is its #1 churn driver | ~$40K MRR (BoringCashCow) |
| **Vape clone swarm** (Puff Counter, QuitPuff, ByePuff) | Vaping | Widget-first one-tap lock-screen puff logging, Control Center logging, badges; some market lifetime pricing as anti-subscription | Mixed | Early/thin | Commoditized lock-screen *logging*; validates taper mechanics + money-saved as the loved features | No intervention at the moment of urge | Unknown |
| **Brainbuddy / Fortify + porn clones** (Unhook, Overcomer, Fapulous, Delust, CURE) | Porn | CBT "rewiring" program (Brainbuddy, no panic/urge support); teletherapy + community (Fortify) | Mostly $60–$100/yr | Mixed | Established programs, clinical credibility (Fortify) | All account-based, all single-vice; nobody credible offers privacy-absolutist, no-account porn quitting | Unknown |
| **Quitzilla / Days Since / QuitLog** (legacy multi-vice) | Multi | Sobriety counters, money saved, quotes | Free for 2 habits / cheap one-time unlock | Neutral-positive | Cheap, honest, no accounts | Zero urge intervention, dated design, no lock-screen interactivity; caps what pure *tracking* can charge | Small |
| **I Am Sober** (indirect) | Alcohol/sobriety | Pledges, community, home + lock-screen widgets (TikTok-shared) | Free core; $9.99/mo–$39.99/yr plus tier | 4.9★/175K+ | Massive trust and scale | **No panic button found**; its free counter caps what anyone can charge for counting alone | Established |
| **Reframe / Sunnyside** (indirect) | Alcohol | Neuroscience curriculum (Reframe); coaching + moderation tracking, explicitly non-quit framing (Sunnyside) | $13.99/mo–$79.99+/yr; $99/yr | 4.7★/41K; 4.8★ | Prove moderation/Reduce framing converts | Heavy, account-based, program-shaped; AA-adjacent weight the Alex persona avoids | Large/VC-backed |
| **"Unhooked" name squatters** | Nicotine, porn, digital detox, psychology program | **unhooked.today already markets panic button + AI coach for nicotine**; UnhookedApp (quit porn); Unhooked — Quit Smoking & Vaping; Unhooked: Digital Detox; getunhooked.app ($199 program, Apr 2026) | Various | n/a | They own the name space | n/a | n/a |

### Differentiation opportunities (per the research's "top 3 moves")
1. **Own "the panic button on your lock screen" as the brand — under a new name.** Nobody markets interactive lock-screen intervention; the vape swarm's widgets are read-only logging, so "widget" alone isn't novel but *full-screen intervention launched from the lock screen in <2s* is still unowned. Make it App Store screenshot #1 and the hero TikTok format.
2. **Weaponize trust as marketing, not just architecture.** "No account. No server. Nothing to leak. Apple handles billing — refunds in one tap." This converts Quittr's and Puff Count's most common 1-star complaints (billing scams, refund fights, paywall bait, the breach) into acquisition copy for the Dan persona and Reddit-safe messaging.
3. **Ship Reduce/taper mode at v1 with money-saved front and center.** The vaping vertical proves taper + savings counters drive love (Jake); Sunnyside/Reframe prove moderation framing converts (Alex). Quit All and Quittr are abstinence-only — Reduce mode is the cheapest real feature gap left. **This is a point where research upgrades the PRD:** the PRD treats Reduce as a secondary goal mode; research says give it funnel and widget prominence.
4. The Alex slot specifically — a calm counter + urge tool + Reduce mode, no AA framing, no community pressure, ~$30–40/yr — is genuinely unoccupied.

---

## 4. Technical Feasibility

### Engineering complexity: moderate-low
A well-bounded, client-only iOS app with no backend for v1. The novel parts are UX polish and launch-path tuning, not systems engineering.

- **Platform check passes:** iOS 26 (shipped Sept 2025) delivered stable interactive AppIntents widgets on the lock screen, new rendering modes, Liquid Glass. The PRD's core technical bet is sound and field-proven (vape clones already ship lock-screen logging widgets).
- **Hard parts, in order:** (1) lock-to-panic-screen <2s cold — requires a deliberately thin deep-link launch path measured on real hardware; (2) streak time integrity (monotonic anchor, timezone travel, clock-fiddling guards) — fiddly but classic, well-specified in PRD §6.2/§11; (3) widget timeline freshness within 60s of writes across the app/extension boundary (App Group storage + timeline reload on write); (4) getting funnel instrumentation right the first time, since the quiz→paywall funnel is the business.
- **Not hard:** streak math, the ~2-entity SwiftData model, static milestone content tables, discreet mode (no-context widget variants + alternate icons), haptic breath pacer.

### Required APIs/services (per PRD §8 — all appropriate)
| Layer | Choice | Notes |
|---|---|---|
| UI | Swift 6 + SwiftUI | Standard |
| Widgets | WidgetKit + AppIntents (interactive), ActivityKit (P1) | iOS 26+ floor is acceptable given persona ages |
| Persistence | SwiftData + iCloud (user-key) | No server; fully local mode when iCloud off |
| Payments | StoreKit 2 via RevenueCat + Superwall | The Quittr-proven combo; reusable across the portfolio |
| Analytics | TelemetryDeck (opt-in) | Category-level events only |
| AI companion (P1 only) | One serverless function → LLM | The only server component; deferred past v1 |

### Infrastructure requirements
Effectively zero for v1: no accounts, no database, no backend. RevenueCat/Superwall/TelemetryDeck are managed SaaS already reusable across the portfolio. P1 adds one rate-limited serverless endpoint. Marginal running cost ≈ Apple developer account + low SaaS tiers.

### Estimated development effort (solo dev + AI agents)
The PRD's 4-week v1 is aggressive but in range for this operating model; **5–6 weeks is the honest estimate** once App Review friction and paywall polish are priced in.

| Workstream | Weeks |
|---|---|
| Quiz funnel (12–14 screens, personalization, per-step instrumentation) | 1.0 |
| Streak engine + slip/momentum + Reduce mode + time integrity | 1.0 |
| Widget suite (4 families + discreet variants) + AppIntents panic deep link + <2s tuning | 1.0–1.5 |
| Panic flow (breath pacer, urge timer, reasons, redirect, exit states) | 0.5–1.0 |
| Paywall (RevenueCat/Superwall A/B), settings, one-tap erase, resources screen, safety copy | 0.5 |
| App Review prep (17+ rating, clinical copy pass, screenshots), TestFlight, submission buffer | 0.5–1.0 |
| **Total v1** | **~5–6 weeks** |

P1 (Live Activity, share cards, AI companion, pattern insights) adds ~3–4 weeks, consistent with the PRD's release plan.

---

## 5. Business Feasibility

### Revenue potential vs the PRD's goals
Goal: $5,000/mo net by month 6 ≈ ~170 net-new annual subs/month at $29.99 (after Apple's 15%) plus monthlies.

- **Demand side: comfortably feasible.** ~2% of Quittr's estimated run-rate, ~12% of Puff Count's, in a category with a demonstrated ~10% paid rate and 39.9% median trial→paid.
- **Funnel math:** at the PRD's own targets (70% quiz completion, 8% completer→paid), 170 subs/mo requires ~2,100 quiz completers → **~3,000 installs/month (~100/day)**. Achievable with one modestly viral TikTok per month plus ASO long-tail — but not automatic. It requires the founder-content grind the research documents and the PRD does not commit to. This is the plan's single point of failure.
- **Pricing:** research says $29.99/yr under-prices the category. Recommendation: A/B $39.99 vs $29.99 annual via Superwall from day one; keep $6.99/mo; no lifetime (PRD-aligned, and Puff Counter-style anti-subscription clones make lifetime a race to the bottom). A partial pricing win materially reduces the installs needed.
- **Churn realism — explicit disagreement with the PRD:** the D30 subscriber retention target of ≥75% is above health-category norms, and category churn is structurally high (users leave when they succeed *or* when they relapse and delete). Treat 75% as aspirational; model the business at 60–65% and let annual-plan mix carry LTV.

### Maintenance cost profile: excellent — the portfolio-fit argument
No backend, no accounts, no community moderation (explicit non-goal), no content blocker, static content tables, managed billing/analytics. Ongoing load: annual iOS-release widget churn (WidgetKit moves every WWDC — budget 1–2 weeks each September), App Review re-submissions, and content/ASO iteration. The duty-of-care surface (resources screen, alcohol withdrawal notice, P1 AI guardrails) is static copy plus acceptance tests, not operational load.

### Distribution risks
- **Concentration:** iOS-only + App Store + organic TikTok. A TikTok reach change or an App Review reversal is a business event with no fallback channel.
- **ASO pollution from the name collision** degrades the primary free channel until the rename happens.
- **Paid ads are structurally closed** for vaping/adult-adjacent content: if organic stalls, the only plan B is more content or creator rev-share, not budget.

---

## 6. Risk Analysis

| # | Risk | Type | Likelihood | Impact | Mitigation |
|---|---|---|---|---|---|
| 1 | **Name/trademark collision:** 5+ live "Unhooked" products in-category, incl. a nicotine panic-button app and a $199 program launching Apr 2026; polluted ASO; plausible C&D | Legal / platform | **High** | **High** | **Rename before build** (hard precondition). Screen new name against App Store, USPTO, and domains; keep "panic button on your lock screen" as positioning regardless of name |
| 2 | Organic acquisition stalls without daily founder content; goal needs ~3K installs/mo and the PRD has no committed content plan | Product / GTM | High | High | Written content plan as a P0 deliverable: cadence, 10 pre-scripted lock-screen-demo formats, 2-week content bank before launch; ASO long-tail focus; genuine Reddit participation |
| 3 | Quit All (or a Quittr fast-follow) ships interactive lock-screen panic + a quiz funnel first | Product | Medium | Medium-High | Speed (5–6 week v1); own the demo format on TikTok early; fall back to trust + porn module + Reduce mode as the wedge; track Quit All monthly |
| 4 | App Review rejection/volatility on addiction + adult-adjacent content; the literal App Store name contains "Porn" | Platform | Medium | High | Precedent exists (Quittr, Fortify, CURE pass with clinical framing + 17+); PRD §6.7 pre-review checklist; clinical subtitle ("adult content"), drop the explicit vice list from the title; schedule one rejection cycle |
| 5 | WidgetKit/AppIntents API churn at iOS 27 breaks the core surface annually | Technical | Medium | Medium | Thin, isolated widget layer; 1–2 weeks budgeted each September; PRD already plans "iOS 27 widget sizes" in v1.1 |
| 6 | <2s lock-to-panic cold start missed, invalidating the headline promise | Technical | Low-Medium | Medium | Measured release criterion on oldest supported hardware; thin deep-link path bypassing full app init |
| 7 | Duty of care: vulnerable user harmed, crisis signal mishandled, or minors self-select in via TikTok despite 17+ rating | Legal / ethical | Low | Very High | PRD §6.7 kept P0 and acceptance-tested: alcohol-withdrawal notice (research confirms genuinely necessary — sudden cessation in heavy drinkers can be fatal), crisis resources one tap from every slip flow, no medical claims; P1 AI ships only with fixed crisis template + rate limits |
| 8 | Privacy incident or perception of one — existential in this category post-Quittr breach | Legal / product | Low (by architecture) | Very High | No accounts/server keeps attack surface near zero; TelemetryDeck carries habit *category* only — still sensitive-class data under GDPR/WA My Health My Data, so disclose in the privacy policy; one-tap erase; never add server-side state casually |
| 9 | $29.99/yr under-pricing caps LTV below what growth needs | Business | Medium | Medium | A/B $39.99 vs $29.99 annual at launch via Superwall; no lifetime SKU; win-back offer per PRD |
| 10 | Multi-vice positioning dilutes ASO and quiz personalization vs laser-focused single-vice funnels | Product / GTM | Medium | Medium | Generic hook → vice-personalized quiz; per-vice landing/keyword content; if data shows dilution, single-vice storefront skins over the same codebase is a cheap, portfolio-consistent pivot |

---

## 7. Final Recommendation

**GO WITH CAUTION.**

The demand, willingness-to-pay, technical foundation, and portfolio fit (no backend, tiny maintenance surface, reusable RevenueCat/Superwall/TelemetryDeck stack) all check out, and the incumbents' self-inflicted trust wounds — Quittr's 33/100 review-safety score and data breach, Puff Count's pricing resentment — create a live positioning window that favors exactly this architecture. But the research materially revises two PRD premises: the name is unusable, and the concept wedge is no longer unique — Quit All has quietly shipped most of it with zero traction, proving the winner is decided by funnel, brand, and content velocity rather than the feature list. A solo operator can win that game, but only by treating distribution as a first-class deliverable, not an afterthought.

**Conditions to satisfy (the "caution"):**

1. **Rename before build.** Clear the new name against the App Store, USPTO, and domains. Drop the explicit vice list (especially "Porn") from the title; keep vices in clinical subtitle/keyword form.
2. **Commit a written content plan pre-build** — cadence, formats, a 2-week pre-launch content bank — with the lock-screen-panic screen recording as the hero format. Treat it as P0, equal in priority to the quiz.
3. **Promote Reduce/taper mode + money-saved to headline v1 features** (already in the PRD; give them funnel and widget prominence per the research).
4. **Price-test $39.99/yr vs $29.99/yr from day one** via the already-planned Superwall A/B.
5. **Gate submission on the <2s lock-to-panic measurement and the §6.7 safety checklist** as literal release criteria (see `mvp.md` §7).
6. **Track Quit All monthly**; if it ships interactive panic + a quiz funnel before launch, revisit positioning with trust + porn module + Reduce mode as the fallback wedge.
