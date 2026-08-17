# AGENTS.md

ReverseScroll is a macOS menu bar app that reverses mouse-only scroll direction.
SwiftUI/AppKit. No SPM, no tests, no CI. All code is macOS-only (CGEventTap, AX,
ServiceManagement) — nothing here builds or runs in the Linux container.

## Layout (this is the git repo root)

- `ReverseScroll/` — source folder. **Load-bearing name**: referenced by
  `project.pbxproj` (`PBXFileSystemSynchronizedRootGroup path`, `INFOPLIST_FILE`,
  `CODE_SIGN_ENTITLEMENTS`, `DEVELOPMENT_ASSET_PATHS`). Do not rename.
- `ReverseScroll.xcodeproj/` — Xcode project (workspace contents are tracked).
- `app/` — compiled `.app` bundle; gitignored, not part of the repo.
- Remote: `origin` = `github.com/wooii/ReverseScroll`. Work on `main`;
  human handles commits/pushes on the host.

## Build

Requires macOS 15.1+ and Xcode 16.1+. Build only on a Mac (host), never the container:

    xcodebuild -project ReverseScroll.xcodeproj -target ReverseScroll build

Or open in Xcode (`open ReverseScroll.xcodeproj`) and press ⌘R. It's an
`LSUIElement` app — no window, just the menu-bar icon. No tests exist;
verify manually with a real mouse wheel.

## How it works

- `ReverseScrollApp.swift` — `@main`; the entire UI is a `MenuBarExtra`
  with an About button (opens the GitHub page) and a Quit button.
- `AppDelegate.swift` — prompts for Accessibility permission
  (`AXIsProcessTrustedWithOptions`), polls up to 10s then quits if not granted;
  on grant registers as a login item via `SMAppService`.
- `ScrollHandler.swift` — `CGEventTap` on `.cghidEventTap` (head insert) for
  `scrollWheel`; negates `deltaX`/`deltaY` only when
  `scrollWheelEventIsContinuous == 0` (mouse). Trackpad (continuous) passes
  through unchanged — that distinction is the app's whole point.

## Gotchas

- `ReverseScroll/` is a **synchronized folder**: add/remove files in Finder/Xcode,
  never by editing pbxproj; renaming the folder breaks the build.
- Finder can drop `.DS_Store` files inside `.git/` (incl. `refs/`, which breaks
  ref parsing). Don't open/move `.git` in Finder.
- Accessibility permission requires a human click in System Settings — cannot be automated.
- App version lives in `project.pbxproj` (`MARKETING_VERSION`, `CURRENT_PROJECT_VERSION`)
  and is independent of GitHub release tags.
- Release flow: build **Release**, zip the `.app` from `app/Release/ReverseScroll.app`,
  upload to GitHub Releases (README's download link points there). App is
  unsigned, so first launch is blocked until users click "Open Anyway".
