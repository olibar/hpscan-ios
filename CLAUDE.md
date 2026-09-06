# hpscan for iOS

iPhone/iPad app that registers the device as a "Scan to Computer" destination
on HP inkjet all-in-ones (LEDM REST interface, HTTP port 8080/80), receives
the pages when the user presses Scan on the printer and saves them as PDF or
JPEG. Standalone project: the Go client `hpscan` (github.com/olibar/hpscan)
was the protocol reference, nothing is shared with it.

## Layout

- `Packages/HPScanKit` -- SwiftPM package, zero dependencies, iOS 17 /
  macOS 14. All protocol, session state machine, PDF writing, discovery and
  file output. Builds and tests on a Mac with Command Line Tools only.
  - `Sources/HPScanKit/{XML,LEDM,Session,Output,Discovery}`
  - `Sources/hpscankit-cli` -- macOS harness (`discover`, `serve`) to validate
    the protocol against a real printer without Xcode.
  - `Tests/HPScanKitTests` -- XCTest, fake printer transport, XML fixtures.
- `hpscan/` -- the iOS app target (SwiftUI + UIKit glue only). Opened via
  `hpscan.xcodeproj`, which is generated from `project.yml` with XcodeGen.
  Edit `project.yml`, never the target settings in Xcode; regenerate with
  `xcodegen generate` and commit both.

## Commands

```sh
cd Packages/HPScanKit && swift build && swift test      # core, works with CLT alone
swift run hpscankit-cli discover                        # list _scanner._tcp on the LAN
swift run hpscankit-cli serve 192.168.1.20:8080 --out ~/Scans --name "My iPhone"
xcodegen generate                                       # after changing project.yml
xcodebuild -scheme hpscan -destination 'generic/platform=iOS Simulator' build
```

## Conventions

- Swift 6 language mode, strict concurrency. Sessions are actors, UI state is
  `@MainActor @Observable`, cross-task data is `Sendable` value types.
- Debug logging with `os.Logger(subsystem: "com.sinimed.hpscan", category:)`
  at operation start/end and decision points, prefixed with the component
  (`ledm:`, `session:`, `discover:`, `sink:`). Never log full page payloads.
- Every network call has an explicit per-request timeout
  (`URLRequest.timeoutInterval`); the event long-poll is `wait + 30 s`.
- Errors carry context (`LEDMError.status(method, path, status, body)`).
- ASCII only in code, comments, docs and commit messages.
- New settings: update `ScanPreferences`, its `validate()`, the SettingsView
  form and the README table in the same commit.
- iOS runs the listener in the foreground only. Do not add background modes
  or audio hacks without an explicit request.

## Git

Feature branches (`feature/<name>`, `bugfix/<name>`), merge to `main`.
