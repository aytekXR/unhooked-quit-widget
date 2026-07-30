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
unit / snapshot / UI-smoke lanes on a macOS runner (10x-billed — keep runs
lean; docs-only commits carry `[skip ci]`). The TestFlight upload lane is LIVE
on green merges to `main` — see `fastlane/Fastfile`.
