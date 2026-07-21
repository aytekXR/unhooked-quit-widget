# App Review Notes — Ballast (E10.2 draft)

| Field | Value |
|---|---|
| Document | App Review Notes v1.0 DRAFT (E10.2, Session 30) |
| Status | **DRAFT / founder-owned** — agents drafted from shipped code; the operator's clinician+counsel pass (operator-expected §3) gates any clinical framing before submission; the ASC submission itself is operator-only |
| Register | Calm, factual, declarative (brandkit §1.1 Honest/Steady; the S30 Brand rules): no marketing superlatives, no unverified numbers, no medical/efficacy claims, no explicit terminology, clinical nouns for sensitive categories, no shame framing. Docs bypass the CI lexicon gates, so this register is hand-enforced — re-check on every edit |
| Evidence rule | Every factual claim below carries an anchor (a shipped test or code path) so each assertion is falsifiable and defensible — the payload-audit discipline |
| Closes (build half) | implementation-plan E10.2 "review notes (quiz-gated onboarding, PanicIntent, 17+ context, no accounts)" — the DRAFT half; sign-off + submission stay operator-owned |

---

## §1. The notes text (paste-ready draft for the ASC "App Review Information" notes field)

> Ballast is an on-device habit-tracking utility for people reducing or quitting a
> habit — vaping, adult content, alcohol, cannabis, doomscrolling, or a custom goal.
> It stores all data on-device, requires no account, and puts a lock-screen "panic"
> button one tap from a short breathing exercise.
>
> **Age gate + onboarding.** A fresh install opens on a birth-year age check (17+).
> An under-17 entry routes to a calm resources screen; no habit content is reachable
> before the gate. A passing entry leads to an onboarding quiz of 11–13 steps (spend,
> triggers, motivations; two steps appear only for a custom habit or a "cut down" goal)
> that builds a personalized summary. No account is created at
> any step.
>
> **No demo account.** There is no demo account because the app is account-free by
> design: no sign-in exists anywhere, a fresh install reaches full functionality
> after onboarding, and all content ships in the bundle rather than behind a server.
> Purchases restore through the App Store ("Restore purchases" on the paywall) — no
> credentials involved.
>
> **The panic button (AppIntents), how to exercise it.** Add the "Panic" control
> from the Control Center gallery (or a lock-screen control slot, or assign it to
> the Action button), or add the "Streak" lock-screen widget, which carries the same
> button. Tapping it launches the app directly into a full-screen urge intervention
> (breathing pacer, timer, the user's own saved motivations, redirect options). The
> path needs no account and no network, and works with notifications off and Focus
> on. A second, visually neutral "Reset" control exists so users can keep the
> feature discreet; it opens the same flow.
>
> **17+ content posture.** One trackable category is adult-content use; it is
> described in clinical terms ("Adult content") throughout, and no explicit
> terminology or imagery appears anywhere in the app. Benefit milestones are framed
> as "commonly reported," never as medical outcomes. The app is a self-tracking
> utility, not a medical or therapeutic product, and makes no such claim. A
> region-aware helplines/resources screen is one tap from Settings and from every
> slip flow; the single mandatory caution (an alcohol-withdrawal notice) points the
> user to a professional and never instructs how to withdraw.
>
> **Privacy.** No accounts and no first-party server. Data stays on-device (included
> in the user's standard iCloud device backup, like any app); this version does not
> sync across devices. Analytics are opt-in (default off, asked plainly during the
> quiz) and carry only funnel steps and the habit category — never notes, journal
> content, custom habit names, or slip timestamps, and nothing linked to the user's
> identity or used for tracking. A one-tap erase resets the app to a fresh-install
> state.
>
> **Subscriptions.** Billing is StoreKit via RevenueCat: $6.99/month, or an annual
> plan with a 3-day free trial. The paywall screen shows the price, the trial length
> and what follows it, the auto-renewal statement, Terms/Privacy, and Restore. There
> is no lifetime purchase and no notification-based win-back (the app never requests
> notification permission).

## §2. Claim-by-claim evidence anchors

| Claim | Anchor |
|---|---|
| Age gate first; under-17 → resources; one boolean persists, never the birth year | `Tests/Unit/AgeGateTests.swift`; the E5.1 ledger (S16) |
| Full funnel drives green: gate → 11–13-step quiz → summary → paywall mount | `Tests/UITests/QuizFunnelUITests.test_quizFunnel_freshInstall_gateToSummary_toPaywallMount` (scenario-29, green S29) |
| No account/auth surface exists | Code-absence verified (S30): the only "account" hits in `App/Sources`, `Shared/Sources`, `Widgets/Sources` are the two 3.1.1 "Apple Account" billing strings in `PaywallCopy.swift`; no `AuthenticationServices`, no credential UI. Account-free restore: `PaywallModelTests.test_paywallModel_restoreRecoversEntitlement_unlocks` |
| Panic control registration + cold launch | `Shared/Sources/OpenPanicControlIntent.swift` (openAppWhenRun, not Shortcuts-discoverable); `Widgets/Sources/UnhookedWidgetBundle.swift` (the "Panic"/"Reset" control pair); `Tests/Unit/PanicWarmLaunchTests.swift`, `PanicEntryPointTests.swift`; the panic route opens no store and reads no entitlement/teaser/winback state (standing rule, R27.11 class) |
| Works with Focus on / airplane / notifications off | Epic 3 DoD (zero network dependency); the operator's §7 device matrix rows record the physical halves |
| Clinical register + no explicit terms in bundled surfaces | `Tests/Unit/SubmissionMetadataLintTests.swift` (NEW, E10.2 — explicit-terms + metadata-medical registers over the bundle names, the 8 copy tables, and the widget/control/intent strings); `MilestoneCopyTests` ("commonly reported" pinned on all 43 bodies); the per-table shame/leak gates |
| Alcohol notice: once-ever, calm, points to a professional | `Tests/Unit/AlcoholNoticeStampTests.swift`; `SlipLexiconTests.test_safetyStrings_containNoForbiddenLexicon`; safetyCopy `_meta` still says DRAFT — the operator §3 clinician+counsel pass is the ship gate |
| Resources one tap from Settings + every slip flow; only verified rows render | `Tests/Unit/SafetyResourcesTests.swift`; the GLOBAL region is number-free by construction (S27) |
| Analytics opt-in, category-ceiling, no timestamps/content | `Tests/Unit/ConsentGateTests.swift`, `ConsentPersistenceTests.swift`, `AnalyticsEventTests` (`test_optOut_sendsNothing`, `test_slipLogged_payload_hasNoTimestampProperty`, `test_everyEventCase_serializesOnlyWhitelistedKeys`); `docs/payload-audit.md` §5/§6; `docs/app-privacy-label.md` |
| One-tap erase → fresh-install state | `Tests/Unit/EraseEverythingTests.swift`; `EraseUITests` |
| Paywall carries the 3.1.1/3.1.2(c) disclosure set | `Tests/Unit/PaywallCopyTests.swift` (price + trial + renewal + Terms/Privacy + Restore string-presence); `PaywallView` renders `paywall.renewalTerms` / `paywall.trialMechanics` |
| No notification permission is ever requested | The S26 in-app-only win-back ruling (mvp §6 ratification pending, operator-expected §3); the landed test that pins no notification authorization request (test-suite §7) |

## §3. Operator decisions the notes SURFACE (deliberately not resolved here)

1. **The 3.1.2 review-build posture (R24.9 carried rider).** The live paywall's hard
   variant has no close button by design. Before submission the operator either
   points the review build at the teaser variant (which carries the "look around for
   a day" escape) or keeps the hard wall and defends the posture in these notes with
   one calm sentence. Not resolved by agents.
2. **Keys at submission (the dormant-build reality).** With no keys wired, the
   summary routes to the dashboard and a reviewer never sees a purchase screen — a
   subscription app under review must show its paywall. Submit with the RevenueCat
   (and Superwall, if used) keys live, or explain the gating here. (operator-expected
   §8 sequences the keys.)
3. **The 17+ rating** is set in App Store Connect by the operator (never in code).
4. **Rename/ASO (Gate G0).** These notes use "Ballast" (the registered, TestFlight-live
   identity). The store name field, subtitle, keywords, promotional text, description,
   screenshots, and preview video are operator-owned behind Gate G0 and are NOT
   drafted here. Screenshot #1 = lock-screen panic button and preview = lock-screen →
   intervention demo remain the plan of record (mvp §7).
5. ~~**PrivacyInfo.xcprivacy (R30.6 — real submission blocker, named).**~~ **CLOSED —
   Session 31.** Both executables now ship their required-reason-API manifests: the app
   (`App/Resources/PrivacyInfo.xcprivacy`, UserDefaults [CA92.1, 1C8F.1] + the three
   label-lockstep collected rows + NSPrivacyTracking=false) and the widget .appex
   (`Widgets/Resources/PrivacyInfo.xcprivacy`, [1C8F.1] only, collected half empty).
   Verified by `PrivacyManifestTests` (CI green `29290910960`). No longer a submission
   blocker; tracked closed in `docs/submission-checklist.md`. (Kept here as an audit
   trail — this item surfaced the blocker in Session 30 and it was resolved in 31.)

## §4. Register bans (hand-enforced on every edit of this file)

- **No latency number** — E0.3 is unmeasured (`docs/spike-panic-latency.md` verdict
  pending). "Directly"/"one tap" only; never "<2s"/"under 2 seconds".
- **No "anonymous"** (struck S19) — use "not linked to the user's identity / opt-in /
  not used for tracking".
- **No medical/therapeutic/efficacy vocabulary** (treatment, cure, recover, heal,
  therapy, diagnose, clinically proven).
- **No explicit terminology; no shame framing** (slips are logged events).
- **No unshipped state described as live** — cross-device iCloud sync is NOT live
  (`cloudKitDatabase` stays `.none` until the §4.3 flip); dormant keys are stated as
  dormant.
- **Never reproduce the PRD working store title** (it contains a non-clinical
  category noun); the app is "Ballast".
