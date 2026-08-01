# unhooked-quit-widget

Native iOS quit-anything streak app — ships as **Ballast** (org `com.beyondkaira`).
The git repo slug is the only place the old working title "Unhooked" survives —
the Xcode project, all five targets, the scheme and the Swift module are `Ballast*`.
All product decisions live in `docs/` — start with `docs/resume-prompt.md`.
The live operator checklist is `docs/operator-expected.md`.

## Building

The `.xcodeproj` is generated, not committed:

```sh
brew install xcodegen
xcodegen generate
open Ballast.xcodeproj
```

Portfolio stub packages live in `Packages/` and test standalone:

```sh
swift test --package-path Packages/StreakEngine
```

CI (`.github/workflows/ci.yml`) runs package units on Linux and the app's
unit / snapshot / UI-smoke lanes on a macOS runner. **The runners are FREE** —
this repo is public, and `actions/runs/<id>/timing` reports billable
`MACOS.total_ms = 0`. Docs-only commits still carry `[skip ci]`, for wall clock
and signal, not for cost. (Every doc here used to say the opposite; S61 measured
it. See `docs/resume-prompt.md`.) The TestFlight upload lane is LIVE
on green merges to `main` — see `fastlane/Fastfile`.
