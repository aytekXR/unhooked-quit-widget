# App Privacy Label — the code-derived row set (E10.2)

| Field | Value |
|---|---|
| Document | App Privacy Label Derivation v1.0 (E10.2, Session 30) |
| Status | **CODE-DERIVED, wire-verify pending** — the rows below derive deterministically from the closed `AnalyticsEvent` enum + the recorded SDK manifest facts; the empirical MITM confirmation (payload-audit §4d–§4e) cannot run until the operator's TelemetryDeck app ID ships in a build (payload-audit §1, operator-expected §8) |
| Owner | Operator (aytek) enters the rows in App Store Connect and owns the privacy-policy text; agents derived the rows + evidence |
| Source of truth | `AnalyticsEventKind` + `AnalyticsEvent.parameters` (`App/Sources/AnalyticsService.swift`) — the closed enum IS MVP §5's table; re-derived per payload-audit §5/§6 |
| Closes (build half) | MVP §7 "App Privacy labels … accurate, including habit-category disclosure" — the DERIVATION half; entry + policy + wire-verification stay operator-owned |

> **Re-derivation trigger (verbatim, binding):** any `AnalyticsEvent` enum or property
> change re-derives this label. The enum is the single source of truth (it IS mvp §5);
> this label is a projection of it. It also re-derives on every TelemetryDeck /
> RevenueCat / SuperwallKit SDK bump (their manifests can change), on any change to the
> consent gate or its storage or the composition-root wiring, and at every release
> candidate (payload-audit §7).

## §1. The two build states — and which one to declare

Ballast has a double-dormancy posture: analytics transmits nothing until BOTH the
shipped consent step is answered AND the operator's TelemetryDeck app ID lands; the
monetization SDKs are never initialized until their keys land.

- **DORMANT (keyless) build:** literally nothing is collected. The transport is a Noop
  sink and no SDK initializes — zero bytes leave any build (`AnalyticsService.swift`
  Noop wiring; operator-expected §8; payload-audit §1). For that exact build,
  "Data Not Collected" is the truthful label.
- **LIVE (keyed) build:** the intended shipped configuration — opted-in users' funnel
  events flow; RevenueCat brokers entitlements.

**Recommendation (R30.4): declare the LIVE-state rows in §2, not "Data Not
Collected".** Grounds: (1) Apple expects the label to describe what the app MAY
collect as configured for use — the live path activates on a key upload, not a code
change, so a "Data Not Collected" label opens a false-label window the instant a key
lands; (2) the label is app-level and persists across builds; (3) the review build
almost certainly runs keyed, because the reviewer must exercise the paywall
(guideline 3.1.1/3.1.2); (4) in a 17+ addiction category, over-disclosure is the
trust posture. **Operator gate (record it):** if a genuinely keyless build is ever
submitted under "Data Not Collected", the label MUST flip to the §2 rows in the same
App Store Connect session that any keyed build is submitted.

**Label-mechanics caveat:** Apple's label has no per-row "opt-in only" checkbox. The
opt-in nature (default OFF; `AnalyticsService.fire` gates on the stored choice) is
expressed in the privacy policy, not the label. Do not try to encode consent in the
rows.

## §2. The COLLECTED rows (LIVE state) — enter these in App Store Connect

| Data type | Collected | Linked to identity | Used for tracking | Purposes |
|---|---|---|---|---|
| Usage Data › Product Interaction | YES (opt-in) | NO | NO | Analytics |
| Health & Fitness › Health — the habit CATEGORY (**R30.4/OQ-2, counsel to ratify**) | YES (opt-in) | NO | NO | Analytics |
| Purchases › Purchase History (once the RevenueCat key is live) | YES | NO | NO | App Functionality + Analytics |

Everything else: **Not collected** (§3). Used-for-Tracking is NO on every row — no
IDFA, no ATT prompt, no cross-context join is representable.

### Row 1 — Usage Data › Product Interaction
The funnel telemetry: `onboarding_started`, `quiz_step_completed(step_number)`,
`paywall_viewed`, `teaser_entered`, `widget_added`, `panic_opened` (bucketed
cold-start only), `panic_step_reached`, `slip_undone`, `discreet_mode_enabled`,
`resources_viewed`, `erase_all_completed`, `winback_shown`/`winback_converted`, plus
the habit-carrying events (also Row 2).
**Evidence:** the closed enum + `parameters` (`App/Sources/AnalyticsService.swift` —
cases + allow-listed keys), the consent gate in `fire()`; mvp §5's table;
payload-audit §5/§6. The only permitted host is `nom.telemetrydeck.com`
(payload-audit §3).

### Row 2 — the sensitive habit category → Health & Fitness › Health (recommended)
The coarse recovery-focus category `habit_category` ∈ {vape, porn, alcohol, weed,
doomscroll, custom} — a bounded token, NEVER the user's own word (`custom` is the
wire ceiling) — plus `goal_mode` ∈ {quit, reduce}. Carried by `quiz_completed`,
`quit_created`, `urge_averted`, `slip_logged`.
**Evidence:** `AnalyticsService.swift` (the four fire sites + the custom-ceiling
comment); `App/Sources/Persistence/PersistenceModels.swift` (the six values); mvp §5
("habit category is still sensitive-class data"); architecture §10 (legal posture);
payload-audit §6.
**The one genuine judgment call (OQ-2, vetoable):** Apple's taxonomy has no
"addiction category" type. The recommended, reviewer-safe mapping for a 17+
addiction app is **Health & Fitness › Health**; the alternatives are Sensitive Info
(GDPR special-category type) or folding into Row 1's Product Interaction with the
sensitive-class character carried only in the privacy policy. **Declare exactly one;
counsel ratifies before ASC entry.**

### Row 3 — Purchases › Purchase History
**Evidence (two independent sources):** (a) app-side analytics — `purchase{product,
period}` and `trial_started{product}` (opt-in-gated); (b) the SDK manifests as
recorded in operator-expected §8: RevenueCat declares Purchase History only, not
linked, not tracking, and the wiring switches its device-identifier collection OFF;
SuperwallKit declares Purchase History + a FileTimestamp required-reason (C617.1)
and pulls the checksummed `libcel.xcframework` Rust binary.
**Nuance the operator must know:** RevenueCat's App-Functionality collection is NOT
gated by the analytics opt-in — RC needs purchase history to broker entitlements the
moment its key is live. Only the app's own `purchase`/`trial_started` analytics
events ride the consent gate.

## §3. The absence set — leave every other type UNCHECKED

| Apple data type | Why it cannot be collected | Evidence |
|---|---|---|
| Contact Info | No account/sign-up path exists anywhere | mvp §7; no auth surface in code (review-notes §4 verification) |
| User Content | Journal/notes, quiz free text, the user's custom habit word are unrepresentable by type and never transmit | `AnalyticsService.swift` associated-value design; payload-audit §5 HARD-NEVER set; architecture §10 hard boundary |
| Financial / Payment Info | Apple handles billing; the app never sees payment data | architecture §10; mvp §6 |
| Location (Precise/Coarse) | Region via `Locale` only; no geolocation permission | architecture §10 |
| Contacts | Never accessed | no contacts API anywhere |
| Browsing / Search History | No such surface transmits | the closed enum has no such event |
| Diagnostics | Cold-start is a coarse bucket string (the `ColdStartBucket` raw values `under_1s`/`1s_to_2s`/`over_2s` — i.e. <1s / 1–2s / >2s boundaries), never a raw timing; no crash SDK linked (Apple/TestFlight crash reporting is Apple-collected, not app-collected) | `AnalyticsService.swift` ColdStartBucket; mvp §5; architecture §10 |
| Sensitive Info | The one sensitive element (habit category) is declared via Row 2; do not declare both | §2 Row 2 |
| **Identifiers (Device ID / User ID)** | **No Identifiers row.** TelemetryDeck uses a default rotating anonymous ID (its recorded design goal: "no device IDs, compatible with honest App Privacy labels"); RevenueCat's manifest declares no Identifiers row and device-ID collection is wired OFF; SuperwallKit's manifest declares none. A daily-rotating salted hash is not a persistent Device ID and is not tracking | mvp §5; architecture §10 table; operator-expected §8; past-prompts R24.2/R25.14 |

**HARD-NEVER set restated as label-absence assertions** (payload-audit §5): quiz
answer values beyond category, custom habit names, any free text, slip/urge notes,
slip/urge timestamps, precise cold-start timings, journal/reflection content, any
cross-service identifier join (`quit_index` is a 1-based ordinal, never a UUID, for
exactly this reason).

## §4. The privacy-policy rider (operator/legal-owned; pointer only)

The label alone is not sufficient: the docs mandate a privacy-policy disclosure of
the habit category as sensitive-class consumer health data under GDPR
special-category + Washington My Health My Data (substance use is explicitly
covered). The policy must state: the app collects the recovery-focus CATEGORY (not
the specifics), only with opt-in, un-linked, never sold, never used to track.
In-repo anchors to cite: architecture §10 (legal posture), mvp §5 + §7 (the
disclosure rows), feasibility risk #8, payload-audit §6.

## §5. Honest caveats

- **This label is code-derived, not yet wire-verified.** The MITM property audit
  needs the §8 TelemetryDeck app ID; until it runs, do not present the label as
  empirically confirmed. The zero-before-consent half is verifiable on today's
  dormant build.
- The SDK manifest facts rest on the operator-expected §8 recorded findings (no SPM
  checkout exists on the Linux box) — re-verify against the real
  `PrivacyInfo.xcprivacy` files in Xcode before ASC entry.
- **Session 30 adds NO privacy surface** (docs + a metadata lint only; the enum is
  unchanged) — stated per the standing PR-template rule.
- **R30.6 — CLOSED (Session 31):** both executables now ship first-party
  `PrivacyInfo.xcprivacy` manifests — the app declares UserDefaults
  **[CA92.1, 1C8F.1]** (the S30 CA92.1 carry was the app-only code; the App-Group
  suite is 1C8F.1, docs-verbatim) and the widget .appex declares **[1C8F.1]** only
  (it reaches App-Group UserDefaults via the panic-intent launch flag).
  `LiveClock.swift`'s reads were classified OFF Apple's SystemBootTime list
  (mach_continuous_time/kern.bootsessionuuid are not documented members — R31.3).
  **LOCKSTEP (R31.5, binding):** the app manifest's `NSPrivacyCollectedDataTypes`
  mirrors §2's three rows exactly — any change to this label (including a counsel
  repick of the OQ-2 taxonomy) updates the manifest + its key-set pin
  (`Tests/Unit/PrivacyManifestTests.swift`) in the same session.
