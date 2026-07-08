# Operator Checklist — What the Agent Needs From You

| Field | Value |
|---|---|
| Document | Operator checklist v1.0 |
| Created | 2026-07-08 (after Session 04; Apple Developer account newly purchased) |
| Owner | Operator (you). The agent must never do these — Gate G0 / device / account work. |

**None of this blocks the next coding session** (Epic-1 close-out + E2.1 are local
package/CI work). It unblocks TestFlight (E0.1 lane), marketing copy, and later epics.
Work the phases in order; each ends with a small "hand back to the agent" block.

---

## Phase 0 — Decide the real name (Gate G0)

The single gate everything else hangs on. `dev.placeholder.quitwidget` must NEVER be
registered with Apple (feasibility §7 condition 1).

- [ ] Pick the final app name.
- [ ] Check collisions: App Store search, trademark database for your market
      (USPTO/EUIPO/TÜRKPATENT), and domain availability.
- [ ] Decide your reverse-DNS org prefix (e.g. `com.beyondkaira`).

**Hand back:** the final display name + org prefix. Nothing else — the agent derives
the sweep from these and you confirm before anything is registered.

## Phase 1 — Apple Developer portal (needs Phase 0)

At <https://developer.apple.com> → Certificates, Identifiers & Profiles → Identifiers:

- [ ] App bundle ID `<org>.<name>` — capabilities: App Groups, iCloud (CloudKit).
- [ ] Widget bundle ID `<org>.<name>.widgets` — capability: App Groups.
- [ ] App Group `group.<org>.<name>.shared`.
- [ ] CloudKit container `iCloud.<org>.<name>`.
- [ ] Note your **Team ID** (Membership page, 10 characters).

**Hand back (5 strings):** app bundle ID, widget bundle ID, App Group ID, CloudKit
container ID, Team ID. The agent then sweeps exactly: `project.yml` (bundle IDs ×2,
entitlement groups ×2, display names ×2, `DEVELOPMENT_TEAM`) +
`Shared/Sources/AppIdentifiers.swift` (`appGroupID`, `loggingSubsystem`).

## Phase 2 — App Store Connect + the five CI secrets (needs Phase 1)

At <https://appstoreconnect.apple.com>:

- [ ] Create the app record (new name, app bundle ID, iOS).
- [ ] Users and Access → Integrations → App Store Connect API → create a team key,
      role **App Manager**. Download the `.p8` ONCE and store it safely; note the
      **Key ID** and **Issuer ID**.

Signing (fastlane match, used by the dormant `beta` lane):

- [ ] Create a NEW PRIVATE GitHub repo for match certificates (e.g.
      `<you>/unhooked-match-certs`).
- [ ] Choose a strong match passphrase.
- [ ] Give CI write access to that repo — simplest: a fine-grained PAT scoped to only
      that repo (Contents: read/write), embedded in the URL
      (`https://<PAT>@github.com/<you>/unhooked-match-certs.git`).
- [ ] First-time certificate generation: `fastlane match appstore` once from a Mac —
      OR tell the agent you have no Mac at hand and it will add a one-shot
      `readonly: false` bootstrap path to the lane instead.

Set the five GitHub secrets on THIS repo (names are load-bearing — `fastlane/Fastfile`
reads exactly these):

```bash
base64 -w0 AuthKey_XXXXXX.p8 | gh secret set ASC_API_KEY_P8_BASE64 -R aytekXR/unhooked-quit-widget
gh secret set ASC_KEY_ID     -R aytekXR/unhooked-quit-widget   # the 10-char key ID
gh secret set ASC_ISSUER_ID  -R aytekXR/unhooked-quit-widget   # UUID from the API page
gh secret set MATCH_GIT_URL  -R aytekXR/unhooked-quit-widget   # certs repo URL (with PAT)
gh secret set MATCH_PASSWORD -R aytekXR/unhooked-quit-widget
```

**Hand back:** "secrets set" + whether match was bootstrapped from a Mac. CI's
TestFlight gate activates on the next merge; the agent verifies the lane end-to-end.

## Phase 3 — E0.3 panic-latency device run (independent of Gate G0)

Needs: a physical iPhone 15-class device + any Mac with Xcode (free personal-team
dev signing is fine — dev installs never touch App Store Connect, so this does NOT
wait for the rename).

- [ ] Follow the runbook in `docs/spike-panic-latency.md` §Operator runbook: build to
      the device, add the lock-screen/Control widget, run
      `UnhookedUITests/PanicLatencyDeviceTests` against the device UDID, plus 10
      manual cold attempts.
- [ ] Fill the results table + verdict section in that doc.
- [ ] Decide the drift: MVP §7 "<2s on 10/10" vs test-suite §1.5 "p90 < 2s" — which is
      the release bar? (Or hand back the raw numbers and your preference.)

**Hand back:** the filled table (or raw ms numbers), the verdict, the drift decision.
This unblocks marketing copy ("2 seconds" claim vs "fast") — not code.

## Phase 4 — Content plan (feasibility condition #2)

- [ ] Decide the approach: you write the content tables (`milestones.json` per habit
      category, panic script, slip-flow copy, helpline list) — or the agent drafts them
      for your line-by-line review (they must pass the no-shame / no-medical-claims
      audit tests either way).

**Hand back:** the decision, plus source material if you have any.

---

## TL;DR — the message to paste when you have things ready

> Gate G0: name = `<name>`, org = `<org>`; IDs created: `<app>`, `<widget>`,
> `group.…shared`, `iCloud.…`; Team ID `<XXXXXXXXXX>`. Secrets: set / not yet.
> Match bootstrap: done from Mac / need the readonly:false path.
> Spike: table filled in `docs/spike-panic-latency.md`, verdict `<…>`, drift bar `<…>`.
> Content: I'll write / agent drafts.

Any subset is fine — say what's done and the agent takes it from there.
