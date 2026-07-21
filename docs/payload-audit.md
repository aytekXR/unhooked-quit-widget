# Payload Audit — the operator-run MITM release gate

| Field | Value |
|---|---|
| Document | Payload Audit Procedure v1.0 (E8.2, Session 19) |
| Status | STANDING RELEASE GATE — operator-run against a TestFlight build; re-run on every trigger in §7 |
| Owner | Operator (aytek) — agents wrote the procedure; only you can execute it (device + LAN + TestFlight) |
| Closes | MVP §7 "Privacy & analytics" release checkboxes; architecture §10 "release-gated by proxy inspection"; ADR-8; Epic 8 DoD "payload audit executed and archived" |

## §0. Purpose & release-criteria mapping

This audit is the manual half of the privacy release gate. Each MVP §7 "Privacy &
analytics" checkbox maps to ONE observable below — a box may only be ticked by citing
the observed evidence, never by judgement:

| MVP §7 checkbox | Observable | Procedure step |
|---|---|---|
| Zero events before opt-in | NO request to the ingest host before the consent tap (and none EVER on the decliner path) | §4b, §4c |
| Opted-in events carry only §5 properties | every intercepted payload's event name ∈ the §5 enum AND its property keys ⊆ that event's allow-list row | §4e, §5 |
| No content, notes, or slip timestamps ever transmitted | the HARD-NEVER set (§5) is ABSENT from every payload | §4e, §5 |

It is the manual companion to CI test 27 (test-suite §7.9's
`telemetrydeck_interceptedPayloadForFullSessionContainsOnlyWhitelistedEventNamesAndProperties`),
covering what an in-process URLProtocol harness cannot: a real device, real TLS
(mitmproxy decrypts — the app deliberately has no certificate pinning, architecture
§10), and the real SDK's batching/backoff behavior.

## §1. Preconditions — read this first (sequencing dependency)

- **The property-audit half (§4d–§4e) REQUIRES a build with your TelemetryDeck app ID
  wired** (`AnalyticsConfiguration.telemetryDeckAppID`,
  `App/Sources/TelemetryDeckSink.swift` — operator-expected §8). Until then the sink is
  Noop and the SDK is never initialized: **zero bytes leave any build regardless of
  consent**, so "opted-in events appear" cannot be exercised. Record such a run as
  "PRECONDITION NOT MET — cannot run," never as PASS.
- **The zero-before-consent half (§4b–§4c) is verifiable even on a dormant-transport
  build** (it is still zero) — and stays mandatory after the app ID lands, which is
  when it can first FAIL.
- An iPhone on the same Wi-Fi/LAN as your Mac; ability to install a configuration
  profile on it; the TestFlight build under audit installed.

## §2. Tooling setup (mitmproxy, ~10 min once)

1. On the Mac: `brew install mitmproxy`, then run `mitmweb` (web UI on
   `http://127.0.0.1:8081`, proxy listening on `:8080`). Note the Mac's LAN IP
   (System Settings → Wi-Fi → Details).
2. On the iPhone: Settings → Wi-Fi → (your network) → Configure Proxy → **Manual** →
   Server = the Mac's LAN IP, Port = `8080`.
3. Install the mitmproxy CA on the iPhone: open `http://mitm.it` in Safari → install
   the iOS profile → Settings → General → VPN & Device Management → install → then
   **Settings → General → About → Certificate Trust Settings → enable FULL trust** for
   the mitmproxy CA.
4. TLS note: TelemetryDeck uses standard `URLSession` with **no certificate pinning**
   (architecture §10: "no certificate-pinning theater") — mitmproxy decrypts the
   payloads. That is intended and required for this audit.
5. Afterwards (every run): remove the proxy setting and delete/distrust the mitm CA
   profile.

## §3. Ingest-host reference (the ONLY permitted destination)

- TelemetryDeck SDK 2.14.1 (exact-pinned, project.yml) posts signals to its default
  ingest endpoint — host **`nom.telemetrydeck.com`** (the SDK's default `apiBaseURL`;
  the app passes only `Config(appID:)`, no endpoint override — verify the observed
  host matches on your first opted-in run and record it).
- **Any OTHER host receiving app data during onboarding is a FAIL** (ADR-2: zero
  first-party servers; three SDKs total — RevenueCat/Superwall join in E7 with their
  own documented hosts). OS/system traffic (Apple push, App Store, iCloud) is not app
  data — filter the flow list to the app's process where mitmweb allows, and judge
  only requests the app originates.

## §4. Test procedure (step-by-step; ~20 min)

- **4a. Fresh state.** Delete + reinstall the TestFlight build (or run one-tap erase
  once it ships in Settings). A fresh install must show the age gate first — that
  confirms fresh state. Clear the mitmweb flow list.
- **4b. Zero-before-consent.** Pass the age gate; answer quiz steps UP TO the consent
  step ("Share app usage data?") and STOP on it. **Expected: ZERO requests to the
  ingest host** — specifically no `onboarding_started`, no `quiz_step_completed` 1–2.
  (Design note: those events fire pre-consent and are gate-dropped for EVERYONE — the
  measurable funnel begins at slot 3. Seeing any of them here is a FAIL.)
- **4c. Decliner path.** Tap **No thanks** → Continue → finish the quiz → reach the
  summary → Continue to the dashboard. **Expected: STILL zero ingest requests, ever.**
  A decliner transmits nothing for the lifetime of the install (until they ever
  change the choice).
- **4d. Opted-in path.** Fresh state again (§4a). Reach consent → tap **Share usage
  data** → Continue. **Expected: the FIRST ingest request appears at/after the
  consent advance, carrying `quiz_step_completed` with `step_number: "3"`.** Finish
  the quiz → summary renders → expect `quiz_completed` with exactly
  `habit_category` + `goal_mode`. (The SDK batches — signals may arrive seconds later
  or grouped; wait ~60s before concluding absence.)
- **4e. Property audit.** For EVERY intercepted request: decode the JSON body and
  verify (1) each signal's event name ∈ the §5 enum's wire names; (2) its property
  keys ⊆ that event's allow-list row (TelemetryDeck adds its own SDK envelope keys —
  platform, appVersion, its rotating identifier: those are the SDK's documented
  defaults, not app payload; judge the app-supplied parameters); (3) the HARD-NEVER
  set below is ABSENT everywhere; (4) `cold_start_ms`, when it ever appears (E0.3+),
  is a bucket string — the exact `ColdStartBucket` raw values `under_1s`/`1s_to_2s`/`over_2s`
  (`AnalyticsService.swift:38-42`), never a raw number.

## §5. Expected-traffic table (the allow-list — derived from the closed enum)

Source of truth: `AnalyticsEventKind` + `AnalyticsEvent.parameters`
(`App/Sources/AnalyticsService.swift` — the closed enum IS MVP §5's table; re-derive
this table from the enum on every audit run so an enum change is caught here).

| Event (wire name) | Can appear in an onboarding+summary session? | Allowed property keys (ONLY) |
|---|---|---|
| `onboarding_started` | **NO** — fires at slot 1, pre-consent → gate-dropped for everyone | `variant` |
| `quiz_step_completed` | YES — slots 3…13, opted-in only | `step_number` |
| `quiz_completed` | YES — on summary render, opted-in only | `habit_category`, `goal_mode` |
| `urge_averted` | only after a panic flow ("The urge passed") | `habit_category` |
| `slip_undone` | only after a slip + undo | — (none) |
| all others (`paywall_viewed`, `trial_started`, `purchase`, `teaser_entered`, `quit_created`, `widget_added`, `panic_opened`, `panic_step_reached`, `slip_logged`, `discreet_mode_enabled`, `resources_viewed`, `erase_all_completed`, `winback_shown`, `winback_converted`) | later epics — most fire-points not yet wired; same allow-list applies when they land | per the enum's `parameters` |

**HARD-NEVER set — assert ABSENCE in EVERY payload (architecture §10 hard boundary):**
quiz answer VALUES beyond category (frequency, spend amounts, duration, triggers,
motivations, effects, commitment, allowance), **custom habit names** (the
`habit_category` value must be the literal `custom`, never the user's word), any
free text, slip/urge **notes**, slip/urge **timestamps**, precise cold-start timings,
journal/reflection content, and any cross-service identifier join.

**A worked FAIL (falsifiability):** a payload showing
`"habit_category": "gaming late at night"` is a FAIL — the user's custom label leaked
past the `custom` wire ceiling. Likewise `"step_number": "2"` in any session is a
FAIL (pre-consent slot transmitted), and any request to a non-§3 host carrying app
data is a FAIL.

## §6. Archive checklist (a procedure without a recorded result is not a gate)

- [ ] Save the mitmproxy flow dump (`File → Save` → `.mitm`, or export `.har`).
- [ ] Screenshot (a) the empty flow list at the end of §4b/§4c (zero-before-consent
      evidence) and (b) one decoded, property-clean payload from §4d.
- [ ] Record: build number, audit date, TelemetryDeck SDK version (2.14.1), app ID
      (redact to first 4 chars), device + iOS version.
- [ ] Write PASS/FAIL against each of the three §0 checkboxes, citing the evidence.
- [ ] Archive as `docs/audits/payload-audit-<build>.md` (+ the dump alongside) and
      commit; tick the operator-expected release-gate item.
- [ ] **App Privacy label draft inputs** (the Epic 8 DoD's third clause) derive from
      the verified inventory: Data collected = Usage Data / Product Interaction
      (funnel steps) + the habit CATEGORY (sensitive-class per GDPR / WA MHMD —
      architecture §10 legal posture); **linked to no identity; not used for
      tracking; collected only with opt-in.** The clean-payload list is the evidence
      base for those label answers.

## §7. Re-run triggers (standing regression gate)

- Every TelemetryDeck SDK bump (architecture §10 supply-chain row: the proxy gate
  re-runs on every SDK bump).
- Any `AnalyticsEvent` enum or property change (with the §5 table re-derived).
- Any change to the consent gate, its storage, or the composition-root wiring.
- Every release candidate (MVP §7 is the submission gate).
