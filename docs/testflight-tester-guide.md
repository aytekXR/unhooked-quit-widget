# TestFlight Tester Guide — adding people to Ballast betas

| Field | Value |
|---|---|
| Document | Operator guide (requested 2026-07-11, Session 16) |
| App | Ballast — `com.beyondkaira.ballast`, team `UH7MXG7Z94` |
| Audience | Operator only — everything here happens in App Store Connect, which agents never touch (agent-workflows §2.3) |
| Related | `operator-expected.md` §5 (add internal testers) · `docs/critical-path-post-uir.md` (the full launch sequence) |

## How builds get to TestFlight today (context you already own, for reference)

Every green CI run on `main` archives and uploads a build via the fastlane `beta`
lane (`fastlane/Fastfile`). Two properties of that lane matter for testers:

- `distribute_external: false` — CI only UPLOADS. It never pushes builds to
  external groups, so nothing reaches outsiders without your explicit action.
- Build number = the GitHub run number, so newest run = highest build. Always
  distribute the **most recent build listed in App Store Connect → Ballast →
  TestFlight → iOS Builds** — every green `main` run uploads a newer one, and
  the current build carries the complete UI-Reactor redesign, the real
  dashboard, the 8-screen accessibility audit, and the privacy manifests.
  (Historical note: the first genuinely testable build was `8a0c469` back in
  Session 15; that reference is long superseded — just take the newest.)

Uploaded builds sit in **App Store Connect → Ballast → TestFlight → iOS Builds**
until a tester group exists. That is why nobody has received anything yet.

## Part 1 — Internal testers (start here; ~10 minutes)

Internal testers are members of your App Store Connect team. Up to 100 of them,
builds available IMMEDIATELY after processing — no Apple review. Right for you,
close collaborators, and anyone you'd hand a debug build.

1. **Make each person a team member** (skip for people already on the team):
   App Store Connect → **Users and Access** → **+** → enter their name and the
   email tied to their Apple Account → pick a role — **Developer** is the
   sensible default (Marketing works for non-technical testers; both are far
   less privileged than Admin/App Manager) → under Apps, restrict them to
   **Ballast** unless they genuinely need portfolio-wide access → Invite.
   They must accept the emailed invitation before step 3 can see them.
2. **Create the internal group**: Ballast → **TestFlight** → under **Internal
   Testing** click **+** → name it (e.g. `Core Testers`) → leave **Enable
   automatic distribution** ON so every new CI build reaches the group without
   a manual step per build. (Turn it OFF later if you want to hand-pick builds;
   with it off you attach builds to the group one by one from the build page.)
3. **Add testers to the group**: open the group → **Testers** → **+** → select
   the team members from step 1 → Add. Each gets a TestFlight email invite.
4. **What the tester does**: install the **TestFlight app** from the App Store,
   open the invite email on the device (or redeem the code inside TestFlight),
   tap Accept → Install. Recommend they leave TestFlight's automatic updates on.

That closes the first checkbox of `operator-expected.md` §5.

## Part 2 — External testers (when you want outsiders; adds Apple review)

External testers need no App Store Connect account — up to 10,000 people, added
by email or via a shareable public link. The trade-off: **the first build you
distribute externally goes through Beta App Review** (typically ~a day; later
builds of the same version usually clear instantly).

1. Ballast → TestFlight → under **External Testing** click **+** → name the
   group (e.g. `Friends & Family`).
2. Add people either way:
   - **By email**: Testers → **+** → Add New Testers → enter emails (CSV import
     also available). They get the same invite-email flow as internal testers.
   - **Public link**: open the group → **Public Link** → Enable. Share the URL
     anywhere; optionally cap the tester count or disable the link later. Anyone
     with the link can join — treat it as public the moment you send it.
3. **Attach a build to the group**: the group's Builds tab → **+** → pick the
   build → answer the compliance/review prompts → Submit for Beta App Review.
   Review-notes tip for this category: mention the app is a 17+ habit tracker,
   no account or demo login needed, and that onboarding is quiz-gated (the
   same notes the roadmap plans for App Store submission).
4. Once approved, the build distributes automatically and the group's testers
   are notified.

## Part 3 — The two housekeeping items from operator-expected §5

- **Expire the stray build**: TestFlight → iOS Builds → the bundle-version-"1"
  build → **Expire Build**. Keeps the picker clean and stops anyone installing
  a pre-panic-fix skeleton.
- **Export compliance**: ✅ **already handled — the question should not appear.**
  `ITSAppUsesNonExemptEncryption = false` is declared in the app target's
  Info.plist (`project.yml` → `Unhooked` → `info.properties`), so App Store
  Connect treats the app as exempt automatically. (Ballast uses only standard
  HTTPS/OS-provided encryption and today makes zero network calls — the
  TelemetryDeck transport is dormant — so the exempt declaration is correct.)
  If ASC ever does ask, the answer is Yes → "only standard encryption
  algorithms provided by Apple's operating systems" → exempt, no documentation
  required. (Session 41: verified the key is present; the earlier "a future
  session can add it" note is superseded — it was already there.)

## Quick answers

- **Tester didn't get the email** — have them check the address matches their
  Apple Account, or use the public-link route; invites can be resent from the
  group's tester list.
- **Builds expire after 90 days** — normal TestFlight behavior; CI produces
  fresh builds continuously, so this never needs managing.
- **Feedback and crashes** — testers can send screenshots/feedback from inside
  TestFlight; both arrive under TestFlight → Feedback in App Store Connect.
- **Removing someone** — delete them from the group (external) or Users and
  Access (internal); their installed build keeps working until it expires.
