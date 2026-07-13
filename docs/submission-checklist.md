# Submission Checklist — MVP §7 wired to its evidence (E10.2)

| Field | Value |
|---|---|
| Document | Submission Checklist Wiring v1.0 (E10.2, Session 30) |
| Status | LIVE — the machine-checkable halves of MVP §7 cited to their EXACT CI evidence; the operator/device/future halves enumerated with their owners. Update whenever a §7-relevant test or gate lands |
| Rule (binding, R30.1/PM s7) | **No MVP §7 box may be auto-ticked by an agent session.** Nearly every box has an operator/device/sandbox/G0 co-signature; a green CI run is NEVER "§7 satisfied." This doc cites evidence for machine halves and points to §-owners for the rest. `docs/mvp.md` itself is operator-owned and is not edited |
| Evidence-record model | The payload-audit archive shape (payload-audit §6): every operator row records dated, cited evidence (dump/screenshot/numbers) committed under `docs/` — a procedure without a recorded result is not a gate |

Legend: **[M]** machine-checkable now (exact CI job → test named) · **[O]** operator
judgment/device (operator-expected § pointer) · **[F]** future-gated (the gate named).
Split rows list every leg; the box closes only when ALL legs close.

CI lanes referenced: `streakengine-release-gate` (free Linux, coverage-floored),
`package-units` (WidgetToolkit/PaywallKit, free Linux), the two free grep lints, and
the billed macOS `app` job's three lanes — Unit (`-only-testing:UnhookedTests`),
Snapshot (`UnhookedSnapshotTests`), UI smoke (`UnhookedUITests`).

## Product

| §7 box | Legs |
|---|---|
| Quiz 12–14 steps on device; personalization flows to summary/widgets/panic | **[M]** UI smoke `QuizFunnelUITests.test_quizFunnel_freshInstall_gateToSummary_toPaywallMount` (scenario-29) + Unit `QuizSummaryPersistenceTests`/`SummaryDerivationTests`/`QuizCompletionTests` · **[O]** the on-device perceptual walk — operator-expected §2/§7 |
| Panic lock-screen tap → intervention **<2.0s cold**, 10/10, oldest device | **[F device — permanently CI-uncovered]** `PanicLatencyDeviceTests` XCTSkips on simulator by design; E0.3 is UNMEASURED (`docs/spike-panic-latency.md` verdict pending) — operator-expected §1. Never machine-green |
| Streak integrity matrix (clock back/fwd, tz cross, DST, reboot) never inflates | **[M]** `streakengine-release-gate` (the E1.2 edge suite: clock-backward freeze, tz travel, monotonicity property) + Unit reboot-jump/merge pins · **[O]** the physical reboot leg — §7 |
| Slip flow: 2 taps, archive-to-best, momentum %, 10-min undo, zero-shame copy | **[M]** Unit `SlipFlowModelTests`/`SlipUndoLifecycleTests` + UI smoke slip leg + `SlipLexiconTests`/`SlipCopyTests` · **[O]** the human copy signature — §3 (E4.2 row) |
| 3 concurrent quits + per-widget selectors, no cross-contamination | **[M — PARTIAL, honest gap]** Unit `WidgetFeedTests`/`StreakWidgetComposerTests` (bind-by-UUID, vanished-quit → "Ready when you are.") — **no dedicated 3-quit-selector UI/device test exists** · **[O]** the device selector matrix — §7 |
| All widget families light/dark/tinted; data fresh within 60s | **[M]** the Snapshot golden suite (5 families × light/dark × normal/discreet) · **[O]** tinted mode + the 60s staleness clock are device-only — §7 (Epic-6 DoD defers tinted to device) |
| Discreet mode: no-context variants + alternate icons on the physical lock screen | **[M]** Unit `AltIconSwitcherTests`/`DiscreetSettingsCopyTests` + the discreet goldens + `PrivacyOverlayPolicyTests` · **[O]** the physical lock-screen check — §7 (S22 rows) |
| Reduce mode: allowance, adherence, money-saved (alcohol persona) | **[M]** `streakengine-release-gate` reduce/adherence tests + Unit `AlcoholNoticeStampTests` · **[O]** the persona walk on device — §7 |
| iCloud-off functional; iCloud-on syncs across 2 devices; erase = fresh install on both | **[M]** Unit `EraseEverythingTests`/`EntitlementEraseWiringTests` + UI `EraseUITests` (erase leg is fully machine-pinned) · **[F]** cross-device sync is NOT live — `cloudKitDatabase` stays `.none` until the §4.3 flip · **[O]** the 2-device sitting — §7 |

## Safety (non-negotiable)

| §7 box | Legs |
|---|---|
| Resources one tap from Settings + every slip flow; US helplines verified | **[M]** Unit `SafetyResourcesTests` (reachability; verified-only rows; number-free GLOBAL) · **[O]** helpline NUMBER correctness — §3 (helpline rows are NEVER lexicon-scanned; ALO-182 flag carried) |
| Alcohol withdrawal notice present, calm, in the alcohol module | **[M]** Unit `AlcoholNoticeStampTests` + `SlipLexiconTests.test_safetyStrings_containNoForbiddenLexicon` · **[O]** clinician+counsel sign-off — §3 (safetyCopy `_meta` still DRAFT; the SHIP gate) |
| Copy audit: no medical claims / fear / fabricated stats; milestones "commonly reported" | **[M]** `MilestoneCopyTests` (framing pinned on all 43 bodies) + the per-table lexicon gates + **NEW S30 `SubmissionMetadataLintTests`** (explicit-terms + metadata-medical over bundle names, the 8 copy tables, widget/control/intent strings) · **[O]** the nuance judgment — §3 (E9.2 signature) |

## Monetization

| §7 box | Legs |
|---|---|
| Sandbox: trial start, trial→paid, monthly, restore, cancellation via RevenueCat | **[M logic]** Unit `Contract_RevenueCat` wire pins + `RevenueCatMappingTests`/`PaywallPurchaseWireTests`/`TrialStartedWireTests` + `package-units` PaywallKit state machine · **[F §8]** the live sandbox matrix needs the RC key + ASC products — operator tier |
| Superwall A/B live and remotely switchable | **[M adapter]** Unit `SuperwallFallbackTests`/`TeaserPolicyTests`/`TeaserWiringTests` · **[F §8]** dashboard config + key — operator |
| No paid feature without entitlement; no entitlement loss on update | **[M]** Unit `EntitlementModelTests`/`MonetizationCompositionTests`/`PaywallModelTests` (gating + never-trap) · **[O §8]** the on-update regression run (the Quittr-scandal row) — sandbox/device |

## Privacy & analytics

| §7 box | Legs |
|---|---|
| Proxy inspection: zero events before opt-in; only §5 properties; no content/notes/timestamps | **[M in-process]** Unit `AnalyticsEventTests` (`test_optOut_sendsNothing`, `test_slipLogged_payload_hasNoTimestampProperty`, `test_everyEventCase_serializesOnlyWhitelistedKeys`) + `ConsentGateTests`/`ConsentPersistenceTests`/`AnalyticsWiringTests` + the intercepted-payload harness (test-suite §7.9 test 27) · **[O §8]** the real-device MITM — `docs/payload-audit.md` (property half unrunnable until the TelemetryDeck app ID ships; archive per its §6) |
| App Privacy labels + privacy policy accurate incl. habit-category disclosure | **[M — delivered S30]** the derivation: `docs/app-privacy-label.md` (code-derived rows + evidence) · **[O]** ASC entry + the privacy-policy legal text + wire-verification — §8/legal; OQ-2 taxonomy call (counsel) |
| No account creation path exists anywhere | **[M-by-absence]** code-absence verified S30 (only the two 3.1.1 "Apple Account" billing strings; no auth import/UI) + `PaywallModelTests.test_paywallModel_restoreRecoversEntitlement_unlocks` (account-free restore). Flag: no standing grep gate keeps this true forever (candidate future lint; out of S30 scope) |

## App Review readiness

| §7 box | Legs |
|---|---|
| 17+ rating; porn-module copy clinical ("adult content"); no explicit terms in name/subtitle/keywords/screenshots | **[O]** the 17+ rating is an ASC setting · **[M — NEW S30]** the in-bundle half: `SubmissionMetadataLintTests.test_release_bundleContainsNoExplicitTermsInMetadata` (+ the quiz chips already render "Adult content"/"Cannabis") · **[F G0/O]** the store name/subtitle/keywords/screenshot fields exist only in ASC — operator scans them at submission (the lint cannot reach fields not in the repo) |
| **Rename completed and cleared (App Store search, USPTO, domain) — blocking** | **[F G0/O]** bundle identity `com.beyondkaira.ballast` is registered; the ASO/trademark-clearance half of G0 is open and operator-owned |
| Screenshot #1 = lock-screen panic; preview video = lock→intervention demo | **[F G0 + O device]** needs the cleared name in-frame + device capture (brandkit §9.2 draft narrative exists) |
| Accessibility pass: Dynamic Type, VoiceOver quiz+panic, haptics-only pacer | **[M]** UI `A11yAuditUITests` (panic/slip rule-11 legs + quiz leg) + haptics-only pacer tests + AX5 goldens · **[O]** the box stays **honestly UNCHECKED**: the R28.13 contrast/text-scaling exclusions wait on the §3 founder-copy golden batch (ONE re-record), and the eyes-free/VoiceOver eyeball is §7 device work |
| Crash-free ≥99.5% across ≥20-user ≥1-week TestFlight; zero P0/P1 open | **[F operator beta]** E10.1 external beta + MetricKit — §5 (testers) on the operator's clock |

## Launch readiness (gates launch, not the binary)

| §7 box | Legs |
|---|---|
| Content plan + 2-week TikTok bank (hero = lock-screen panic demo) | **[O]** founder distribution work (roadmap §5); explicitly not agent work |

## Named submission blockers (surfaced S30 — do not lose these)

1. ~~**PrivacyInfo.xcprivacy is MISSING (R30.6).**~~ **CLOSED — Session 31.** Both
   executables ship docs-checked manifests: the app (`App/Resources/
   PrivacyInfo.xcprivacy`) declares UserDefaults **[CA92.1, 1C8F.1]** + the three
   label-lockstep collected rows + NSPrivacyTracking=false; the widget .appex
   (`Widgets/Resources/PrivacyInfo.xcprivacy`) declares **[1C8F.1] only** with an
   empty collected half (R31.1 — the .appex executable reaches App-Group
   UserDefaults via `Shared/PanicLaunchFlag`, so its own manifest is docs-mandated).
   LiveClock's reads classified OFF the SystemBootTime list (R31.3). Evidence:
   **[M]** Unit `PrivacyManifestTests` (Bundle.main presence + exact key-SETs +
   self-calibration; the widget half pins authored bytes + project.yml wiring —
   Bundle.main cannot see the .appex, precedented limitation) · CI green
   `29290910960` (c9d8478). The manifests re-derive with the label (R31.5) and on
   any required-reason-API addition to a diff (the S31 sweep re-runs).
2. **A no-keys review build never shows a purchase screen** (the summary routes to
   the dashboard while the RC key is empty). Submit with keys live or explain the
   gating in the review notes (review-notes §3.2).
3. **The 3.1.2 hard-wall posture (R24.9)** — teaser review build vs defended hard
   wall; operator decision, surfaced in review-notes §3.1.

## Honest coverage gaps (flagged, not papered over)

- "3 concurrent quits + per-widget selectors" has unit coverage only — no dedicated
  UI/device test drives three quits through the selector.
- The panic-latency box is permanently CI-uncovered (device-only by design).
- The accessibility box stays unchecked despite a green audit family (see its row).
- The metadata lint reaches only in-repo surfaces; ASC-side fields (subtitle,
  keywords, promotional text, screenshots) are scanned by the operator at
  submission against the same banned-term registers (brandkit §9.3).
