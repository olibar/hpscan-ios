# hpscan for iOS (Scan to Me)

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
  - `Tests/HPScanKitTests` -- Swift Testing (`import Testing`, `#expect`), fake
    printer transport (`FakePrinter` actor behind `HTTPTransport`), XML fixtures.
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

## Release (App Store)

- Product name `hpscan`, bundle id `com.sinimed.hpscan`, home-screen name
  "Scan to Me", App Store name "Scan to Me for HP printers". App Store Connect
  record exists under the SiniMed Pte Ltd team; the explicit App ID was
  registered by hand on the developer portal (Xcode's managed profile used the
  team's wildcard App ID).
- To ship: bump `MARKETING_VERSION` (and `CURRENT_PROJECT_VERSION` for every
  upload) in `project.yml`, run `xcodegen generate`, commit, tag `vX.Y.Z`,
  then in Xcode select "Any iOS Device", Product > Archive, Distribute App >
  App Store Connect. Attach the processed build to the version in App Store
  Connect and fill "What's New".
- `hpscan/Info.plist` carries `ITSAppUsesNonExemptEncryption = NO` (plain
  HTTP only) and `hpscan/PrivacyInfo.xcprivacy` declares no tracking and no
  collected data; keep both true if networking or analytics ever change.
- The privacy policy is `PRIVACY.md` in this repo, linked from App Store
  Connect. Reviewers have no HP printer: the review notes explain the
  requirement; attach a screen recording of a real scan.
- Screenshots: 6.9" iPhone (iPhone 17 Pro Max simulator, 1320x2868) and 13"
  iPad (2064x2752); use the Manual add with the printer's IP from a simulator.

## Git

Feature branches (`feature/<name>`, `bugfix/<name>`), merge to `main`.
