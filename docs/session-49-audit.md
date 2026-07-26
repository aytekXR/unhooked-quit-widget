# Session 49 — independent adversarial audit of the S48B redesign wave

| Field | Value |
|---|---|
| Document | Session 49 audit report |
| Created | 2026-07-26 |
| Range audited | `38a0461..8ef20b9` (9 commits — the S48B parallel-session redesign wave) |
| Method | `wf_1f3dc932-e63` — 6 read-only dimension finders → an independent refuter per finding (default-REFUTED) → a completeness critic. 21 agents. Plus operator-side verification of every load-bearing claim. |
| Why this document exists | The S48B wave landed the three most dangerous change classes this codebase has taken in one push — **irreversible data destruction** (QW-2 erase UI), **live payments** (the RevenueCat key went live), and **a safety surface** (QW-10 panic support) — in ~2 hours, with CI still in flight. Nothing had audited it. |
| Scope note | Written from an **isolated git worktree** at `8ef20b9`. A second agent session was concurrently editing `/home/aytek/repo/unhooked`, so this audit never wrote to the shared tree. `operator-expected.md`, `resume-prompt.md` and `past-prompts.md` were deliberately NOT touched — the S48B session owns them. |

---

## 0. The one thing to read if you read nothing else

**`HoldToConfirmButton` gates its safe branch on two assistive technologies, and there are more than
two.** The erase confirm is the only irreversible action in the app. Its hold-to-confirm gesture is
bypassed for assistive users by rendering a standard `Button` instead — correct instinct, incomplete
enumeration. Details in §1. **The erase surface is not one of the 8 CI-audited surfaces, so no lane
can ever catch this.**

And a process note that matters more than any single finding: **the audit's own proposed fix was a
hallucinated API.** Both the finder and its adversarial refuter independently recommended
`@Environment(\.accessibilityFullKeyboardAccessEnabled)`. That property **does not exist** —
Apple's docs JSON returns 404 for it, and it is absent from the authoritative
`EnvironmentValues` member list. Two agents agreed on a fiction; only the project's
existence gate caught it. Recorded in §6 because it is a reusable lesson, not a one-off.

---

## 1. HIGH — the erase confirm has un-gated assistive activation paths

**File:** `App/Sources/DesignSystem/Primitives/HoldToConfirmButton.swift:30-66`
**Introduced:** `152890b` (new file). **Untouched since.**

```swift
@Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
@Environment(\.accessibilitySwitchControlEnabled) private var switchControlEnabled

var body: some View {
    if voiceOverEnabled || switchControlEnabled {
        Button(action: action) { chrome }          // safe: deliberate focus-then-activate
    } else {
        chrome
            .onLongPressGesture(minimumDuration: holdDuration) { holdProgress = 0; action() }
            .accessibilityAddTraits(.isButton)     // advertises "activate me"…
            .accessibilityHint(assistiveHint)      // …with no .accessibilityAction to receive it
    }
}
```

The author's reasoning is explicitly correct — the file's own docstring says *"a timed gesture is
never a gate for a non-visual user."* The defect is that the gate enumerates **two** assistive input
modes. Verified against Apple's documentation:

| Assistive mode | Detectable? | In the gate? |
|---|---|---|
| VoiceOver | `accessibilityVoiceOverEnabled` — **exists** (docs 200) | ✅ yes |
| Switch Control | `accessibilitySwitchControlEnabled` — **exists** (docs 200) | ✅ yes |
| **Assistive Access** | `accessibilityAssistiveAccessEnabled` — **exists**, iOS 18+ (docs 200) | ❌ **no** |
| **Voice Control** | **no API exists** in `EnvironmentValues` or `UIAccessibility` | ❌ impossible |
| **Full Keyboard Access** | **no API exists** in `EnvironmentValues` or `UIAccessibility` | ❌ impossible |

Two consequences, and they compound:

1. **`accessibilityAssistiveAccessEnabled` is a real, docs-confirmed omission.** Assistive Access is
   the iOS mode built for users with cognitive disabilities — precisely the population for whom an
   accidental, irreversible, total-data erase is most harmful.
2. **A detection-based gate can never be complete.** Voice Control and Full Keyboard Access are not
   reportable through any Apple API. So the `else` branch will always be reachable by *some*
   assistive user, and in that branch the element advertises `.isButton` while offering no
   `.accessibilityAction`.

**What actually happens in that branch cannot be determined from this machine** — it is one of two
defects, and both are real:

- **(a)** SwiftUI synthesizes the long-press `perform` on accessibility activation → **a single
  activation irreversibly erases everything**, bypassing the 600 ms deliberateness entirely; or
- **(b)** the activation is dropped → **the erase feature is unreachable** for those users, on a
  control that tells them it is a button.

(a) is HIGH; (b) is MEDIUM. Distinguishing them needs a simulator or device — see §5.

### Recommended fix (both APIs verified against Apple docs JSON)

Stop detecting, and make the accessible path structural. `.accessibilityRepresentation` is
iOS 15.0+, not deprecated:

```swift
chrome
    .onLongPressGesture(minimumDuration: holdDuration) { … }   // touch: unchanged
    // Every assistive technology — including the ones iOS cannot report — gets the
    // author's own sanctioned alternative: a standard Button whose focus-then-activate
    // IS the deliberate act. No AT detection, so nothing can be left off the list.
    .accessibilityRepresentation { Button(action: action) { Text(label) } }
```

This subsumes the existing `if/else` (both `@Environment` reads can then go), matches the design
intent already documented in the file, and removes the enumeration problem rather than extending it.

**It is deliberately NOT applied here.** Three reasons, all standing project rules: the erase
surface carries no audit leg so the change is unverifiable from Linux; R41.1 bans touching a gated
surface unverified; and the file belongs to a concurrently-active session. **This is a coordinated
item, not a drive-by fix.**

### The durable fix is a test, not a modifier

The reason this reached `main` is structural: **settings/erase is absent from the 8 audited
surfaces.**

```
test_a11yAudit_{ageGate, quizFlow, summary, dashboard, panicFlow, slipFlow, resources, paywall}
```

Adding a settings/erase audit leg is the change that prevents the *next* one. It needs a
`UITEST_SETTINGS` mount (precedent: `UITEST_RESOURCES` / `UITEST_DASHBOARD` in `PostGateRootView`)
and per R36.4 must gate on a real **child** element, never a full-screen `.contain` container id.

---

## 2. MEDIUM — the safety-copy sign-off package is now stale

**File:** `App/Resources/Content/safetyCopy.json`

`8ef20b9`'s range added a `panicSupport` block with two user-visible strings, live-rendered at
`App/Sources/PanicFlowView.swift:365`:

- `moreSupportLabel`: "More support"
- `redirectFooterLabel`: "Or talk to someone — free, confidential helplines"

`_meta.review_status` is still `"DRAFT — needs clinician + counsel sign-off"`.

**This is NOT a gate bypass** — an audit agent called it one, and that is wrong. The file is still
DRAFT and unsigned, and the author wrote the gate into the block itself: *"Safety-content panel must
sign placement before ship."* That is conscientious, not careless.

**The real issue is yours and only yours.** `operator-expected.md` §3 tells you the safety words are
*"now FINAL pending their pass"* and inventories exactly what to send a clinician. That inventory is
now stale by two strings — and by a question the author explicitly raised and nobody has asked the
panel: **is a support link on the panic flow's post-pacer steps the right placement?** If the package
goes out on §3's inventory, the clinician reviews a stale set and never sees the placement question.

**Action: re-inventory the package before sending it.** No code change.

---

## 3. Confirmed lower-severity findings

| # | Sev | File | Finding |
|---|---|---|---|
| 3.1 | MED | `RootPlaceholderView.swift:235-237` | The new panic-entry support line `Text` (`.footnote`, centered, inside a `maxWidth: .infinity` VStack) has no `.fixedSize(horizontal: false, vertical: true)`. R33.12 item 4 requires it on every wrapping `Text`. Dashboard **is** an audited surface, but `OnboardingLayoutLintTests` scopes `App/Sources/{AgeGate,Quiz,Dashboard,Monetization}` — **not** root `App/Sources/`, so the free lint cannot see it. Practical clipping risk is low (both strings are short); the invariant is still violated. |
| 3.2 | MED | `Tests/Unit/DashboardCopyTests.swift` | `panicEntryDiscreetSupportLine` is pinned only by literal (`== "Take a moment."`), not cross-pinned to `panicScript.json`'s `entryTitleDiscreet` — though its own docstring claims byte-identity with it. Editing the panic script would redden `PanicFlowTests` but leave the dashboard button silently divergent. The sibling `panicEntryLabel` does this correctly (cross-pin **and** literal). |
| 3.3 | LOW | `Tests/Unit/DiscreetSettingsCopyTests.swift:95` | The Mirror-walk non-vacuity floor still reads `>= 12` after `DiscreetSettingsCopy` grew 12 → 20 stored fields (8 new erase strings). The shame/leak scan does walk all 20, but the collapse detector is now blind to a computed-property collapse of any of the 8 new ones. Should be `>= 20`. |
| 3.4 | LOW | `EraseEverythingView.swift:59-62` | `Text(copy.eraseConfirmTitle)` missing `.fixedSize(horizontal: false, vertical: true)`. Inside a ScrollView with no height constraint, so clipping risk is ~zero; literal R33.12 violation on a non-audited surface. |

## 3.5 Hygiene — `ci-mirror-full.log` is committed to the repo

Added by `152890b`. 1778 lines. Contents reviewed: **no secrets** (no `sk_`, `appl_`, `Bearer`,
`-----BEGIN`, no signing identity — "Sign to Run Locally" only), but it does leak a *different*
machine's absolute paths (`/tmp/claude-501/-Users-ae-repo/…`, `/Users/ae/Library/Developer/…`,
developer username `ae`) and a simulator UDID.

Two compounding gaps:

- `*.log` is absent from `.gitignore`.
- CI `paths-ignore` covers only `docs/**` and `**.md`, so a root `.log` **triggers a full billed
  macOS run** (private repo → 10× minutes).
- Same class: **`redesign/**` is not in `paths-ignore` either.** The two redesign commits were spared
  only because someone remembered `[skip ci]` — a person-dependent guard on a structural leak. Every
  future `redesign/` docs commit without it burns a 10×-billed run.

---

## 3.6 REFUTED by CI evidence — the `snapshot_redirectStep` "stale goldens" claim

Recorded because it is instructive, and because it was the audit's second HIGH.

An agent found that QW-10 added an unconditionally-rendered footer `Button`
("Or talk to someone — free, confidential helplines") to `RedirectStepView`
(`PanicFlowView.swift:506-521`), that `snapshot_redirectStep` reaches the `.redirect` stage, and that
the four `snapshot_redirectStep.*.png` were **never** re-recorded in the range (confirmed — `git log`
on those paths in `38a0461..origin/main` is empty). It concluded the snapshot lane would go RED, at
HIGH severity.

**It does not. `✔ Test snapshot_redirectStep() passed after 1.267 seconds`** on the green run
(`30184618367`, job `89746959464`). The whole `PanicFlowSnapshotTests` suite passed. The goldens are
not stale.

The mechanism is **undetermined from here**, and the two candidates have opposite implications — so
this is an operator eyeball, not a conclusion:

- **The footer sits below the scroll fold.** `StepScaffold` scrolls content and pins actions (R33.5),
  so the button may be rendered but outside the captured device frame. If so, the golden is honestly
  byte-stable — but **a safety affordance that requires scrolling to discover** is worth a deliberate
  look, since QW-10's entire purpose is that "someone mid-crisis has a path to a helpline."
- **The delta fell inside tolerance.** The suite runs `precision: 0.99` / `perceptualPrecision: 0.98`,
  so up to 1% of pixels may differ. If a whole button slipped under that, the panic goldens are less
  sensitive than assumed.

Either way the audit's reasoning — "a new visible button therefore the golden must move" — was a
prediction about pixels, and the project's own rule says that is a HYPOTHESIS, not a finding. CI had
already answered it.

---

## 4. CLEAN — verified negatives worth having

These were probed adversarially and came back clean. They are results, not omissions.

- **App icons carry no alpha channel.** All five replaced 1024s are `color_type=2` (opaque RGB),
  1024×1024, non-interlaced — independently confirmed by reading each PNG's IHDR. The App Store
  icon-transparency rejection class is **cleared**. `Contents.json` complete; `AppIconSwitcher` still
  resolves every asset name.
- **QW-1's tokens.json claim is true.** Every hex in `tokens.json` matches `Theme.swift`. The five
  "stale pre-correction" hexes survive only inside the `_meta.rule` prohibition string documenting
  their removal — not as values. `BRAND-GUIDELINES.md` carries no contradicting hex.
- **Erase is complete.** All 13 local persistence surfaces are cleared: 5 SwiftData entity sweeps +
  `save()`, `lastKnownGoodStore`, `quizProgressStore`, `trialDedupeStore`, the App-Group defaults key
  sweep, `panicSnapshotStore`, `panicOutcomeBuffer`, **`widget-state.json` plus
  `scheduleWidgetReload()`** (so no widget keeps rendering a dead streak), and the **alternate app
  icon is reset to primary** (a surviving discreet icon would be a home-screen habit leak). No
  keychain usage exists.
- **Erase cannot reset a trial, and cannot cost a paying user their subscription.** RevenueCat v5 has
  no anonymous-ID reset (`logOut()` throws for anonymous users), so the erase does a
  `invalidateCustomerInfoCache()` — a cache clear, not an identity reset. Entitlements are
  Apple-account-level and StoreKit restores them on the next receipt sync. Documented at
  `QuitRepository.swift:702-713`. This was the monetization-integrity hole worth checking; it is
  closed by design.
- **ADR-6 holds — the live SDK never touches the panic path.** `Purchases.configure()` runs from
  `startIfNeeded()` via the `.task` on `AgeGateContainerView`, which mounts only on the
  `.placeholderTabs` branch. On `.panicPlaceholder` that container is never in the hierarchy.
- **The R46.2 fix is correct on all three legs** (construction / purchase-restore / foreground), and
  the concurrency is sound: `CachingEntitlementProvider` is an `actor`, so interleaved refreshes
  serialize FIFO and no stale snapshot can win.
- **Privacy declarations already anticipated the live key.** `app-privacy-label.md` states RC's
  App-Functionality collection is deliberately not analytics-consent-gated, and
  `PrivacyInfo.xcprivacy` declares `NSPrivacyCollectedDataTypePurchaseHistory` under
  App Functionality, with `automaticDeviceIdentifierCollectionEnabled: false`. The key is `appl_`
  (public SDK key, designed to ship in a binary); no `sk_`/secret key, token, or `.p8` anywhere in
  the range.
- **No new unregistered contrast pairs**; every fg/bg combination the wave introduces already has a
  `Theme.contrastPairs` entry. **No accessibility identifier was renamed** (`root.panicEntry` is
  preserved across the `.plain` → `PrimaryButtonStyle` change; a Button surfaces as `.button`
  regardless of style), so no UI smoke anchor broke. **No discreet-surface habit-context leak.**
- **Every hard-coded CI floor still passes**: account-absence ≥100 (actual 123), Theme lint ≥25
  (106), layout lint ≥35 (49), contrast pairs ≥29.
- **The dashboard goldens correctly did NOT churn.** `DashboardSnapshotTests` renders
  `StreakDashboardCard` *directly*, never `RootPlaceholderView` — so QW-4's panic-entry redesign
  moves no golden. This explains the otherwise-suspicious diffstat (12 panic PNGs changed, 0
  dashboard).

---

## 5. What only a human can do

1. **Decide who lands the §1 erase fix, and verify it on a device.** Turn on **Full Keyboard
   Access**, then **Voice Control**, then **Assistive Access**, focus the erase confirm, and activate
   it once. That single test distinguishes defect (a) from (b) and is not reproducible on Linux or in
   CI as currently configured. Until then the erase row is the riskiest control in the app.
2. **Re-inventory the clinician + counsel safety package** before sending it (§2), and add the
   author's own placement question: is a support link on the panic flow's post-pacer steps right?
3. **Eyeball the dark and tinted app icons.** They are legal (no alpha) but *opaque* — Apple prefers
   dark/tinted variants to omit their background so the system supplies it. These carry their own, so
   they will render differently from the platform default. A design call, not a defect.

---

## 6. Method note — the correlated-hallucination lesson

Worth keeping, because it changes how much a refuter is worth.

The adversarial harness worked as designed on **reachability**: both the finder and the refuter
flagged, unprompted, that the runtime claim was unverifiable from this machine ("*cannot run the
code… confidence MEDIUM*"). That is the harness behaving well — the project's rule that *a confident
prediction about runtime behavior is a HYPOTHESIS, not a finding* was honored by both.

It failed completely on **API existence**. The finder proposed
`@Environment(\.accessibilityFullKeyboardAccessEnabled)`; the refuter, told to default to REFUTED and
to verify independently, wrote *"YES. This key is available since iOS 17"* — and both were wrong.
The property does not exist:

```
swiftui/environmentvalues/accessibilityfullkeyboardaccessenabled.json → HTTP 404
swiftui/environmentvalues/accessibilityvoiceoverenabled.json          → HTTP 200
swiftui/environmentvalues/accessibilityswitchcontrolenabled.json      → HTTP 200
```

Neither `EnvironmentValues` nor `UIAccessibility` exposes any Full-Keyboard-Access member.

**The lesson: adversarial verification does not protect against a shared prior.** Two agents drawn
from the same distribution hallucinate the same plausible API and confirm each other. Only an
*external oracle* — here, the docs JSON — breaks the tie. This is exactly why standing rule #2/#5
treats a member the docs JSON does not confirm as nonexistent even when it looks obvious, and that
rule should be applied to **agent-proposed fixes**, not just to hand-written code. Had this shipped
it would have failed the build under `-warnings-as-errors` and burned a billed macOS run for zero
evidence.

---

## 7. Also recorded: `main` went red and was fixed by its own author

`8ef20b9` failed CI — `A11yAuditUITests.test_a11yAudit_summary_noViolations`,
`A11yAuditUITests.swift:347`, *"Contrast nearly passed"* — caused by the new summary footer rendering
`Theme.color.contentTertiary` (the carried "tight watch" pair, `tertiary-on-sunken 3.11 L`, below the
4.5:1 floor). The TestFlight upload was skipped as a result. The S48B session diagnosed and fixed it
independently in `5d83646` (footer moved to secondary ink) and CI returned green. This audit's
diagnosis, reached separately from the failed job log, matched that fix exactly.

Free package lanes were re-run first-hand on the audited bytes: **StreakEngine 84 / WidgetToolkit 21
/ PaywallKit 16 = 121 pass.**
