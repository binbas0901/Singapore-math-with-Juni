# ENV-002 independent QA review

**Status — Review complete. Recommend Lead acceptance of the ENV-002 scaffold.**
**Reviewer — Independent QA, 2026-11-19.**
**Scope — Native iPad scaffold and reproducible local verification under D05, D08 and D11, with IOS-001 proposals A02 and A09.** [Roadmap](../DEVELOPMENT_ROADMAP.md#3-actionable-backlog) · [Architecture](../ARCHITECTURE.md#2-architecture-decisions-proposed-unless-explicitly-approved)

## Revision and method

GitHub [PR #2](https://github.com/binbas0901/Singapore-math-with-Juni/pull/2) identified base `a2954204d7edacf8f05241e3af18bf210f12f6ef` and head `5f02005eeeb68c91bc6d346832ef5b805ed7ea1b`. QA inspected the complete base-to-head diff across 11 files, including the committed screenshot, using the pinned revisions. The review used [AGENTS.md](../../AGENTS.md), the [blueprint](../PROJECT_BLUEPRINT.md), the roadmap, architecture, [project status](../PROJECT_STATUS.md) and [Release Engineering's evidence](env-002.md).

A separate non-local clone at `/private/tmp/juni-env002-independent-5f02005` had a clean, detached checkout of the pinned head. The audit used macOS 15.7.9 (24G830, Intel x86_64), Xcode 26.3 (17C529), iOS simulator SDK 26.2 and iPad (A16) on the iOS 26.3 runtime (OS 26.3.1, build 23D8133). The simulator was already booted. The DerivedData path did not exist before the build.

## Verified results

| Check | Independent result |
| --- | --- |
| Clean Debug simulator build | **Passed.** The shared `Juni` scheme built the native app and its local JuniCore package using the simulator's active architecture. The compiler targeted `x86_64-apple-ios17.0-simulator`. |
| JuniCore unit tests | **2 passed, 0 failed** on macOS. XCTest ran `testAllValidPairs` and `testInvalidPairs`. |
| XCUI launch and rotation | **1 passed, 0 failed, 0 skipped**, confirmed from the result bundle. The test launched in portrait, rotated to landscape and verified the title was hittable and contained in the window in both layouts. |
| Direct install and launch | **Passed.** `simctl install` and `simctl launch` exited successfully. Launch returned PID `61668` for `com.binbas0901.singaporemathwithjuni`. The independently captured screenshot displayed the centered welcome title. |
| Built bundle metadata | `MinimumOSVersion` was `17.0`, `UIDeviceFamily` was `[2]` (iPad only), and `UISupportedInterfaceOrientations~ipad` listed portrait, portrait upside down, landscape left and landscape right. |
| Static checks | `git diff --check`, Bash syntax, Xcode project plist syntax and shared scheme XML syntax passed. Invalid script action returned usage and exit code 64. |

## Build, CI, offline and security review

- The [verification script](../../tools/verify-ipad.sh#L1) quotes inputs, fails when a command fails, runs the host package tests before XCUI testing and disables automatic package resolution and simulator signing. The shared scheme references the correct app and UI test targets.
- [CI](../../.github/workflows/ipad.yml#L3) is manual-dispatch only. It uses a 30-minute timeout, read-only repository permissions and the local script. The [published runner inventory](https://github.com/actions/runner-images/blob/main/images/macos/macos-26-Readme.md#xcode) lists both the configured Xcode 26.3 path and an iOS 26.2 iPad (A16). This confirms the configuration matches the published inventory. Hosted execution remains unverified.
- The [welcome screen](../../app/Juni/JuniApp.swift#L1) is local SwiftUI text with an accessibility header trait. The [Xcode project](../../app/Juni.xcodeproj/project.pbxproj#L59) resolves the app's sole package locally, and [JuniCore](../../app/JuniCore/Package.swift#L1) declares no external package dependencies. Source, bundle metadata and direct Mach-O dependency inspection showed no app network client, analytics SDK, account flow or learner-data storage. The review found no committed credentials, signing material or learner records in the PR changes. Offline readiness for this screen is supported by static inspection.

## Findings by severity

No critical, high or medium findings in the reviewed scaffold.

| Severity | Finding | File |
| --- | --- | --- |
| Low | The checkout action uses a mutable major-version tag and persists the read-only checkout token in local Git configuration by default. Build and test steps require no authenticated Git commands. Pin the action to a reviewed full commit SHA and set `persist-credentials: false`. [Checkout v4 behavior](https://github.com/actions/checkout/tree/v4#checkout-v4) · [GitHub Actions security guidance](https://docs.github.com/en/actions/reference/security/secure-use) | [.github/workflows/ipad.yml, line 17](../../.github/workflows/ipad.yml#L17) |
| Low | The Release Engineering reproduction commands clone a moving branch and print its head without checking it against the revision cited in the evidence. A future run can build a different commit while following the published commands. Check out the intended full SHA explicitly. | [docs/qa/env-002.md, line 13](env-002.md#L13) |

## Reproduction and local evidence

Run the clone from the source repository. Use new paths for a repeat run.

```bash
set -euo pipefail
reviewed=5f02005eeeb68c91bc6d346832ef5b805ed7ea1b
checkout=/private/tmp/juni-env002-independent-5f02005
derived=/private/tmp/juni-env002-independent-dd-5f02005
simulator=4CBC892C-A385-46ED-982F-ACB16937C6F3

git clone --no-local --no-checkout . "$checkout"
cd "$checkout"
git switch --detach "$reviewed"
test "$(git rev-parse HEAD)" = "$reviewed"
test -z "$(git status --porcelain)"
xcrun simctl bootstatus "$simulator" -b
test ! -e "$derived"
tools/verify-ipad.sh build "$simulator" "$derived" > /private/tmp/juni-env002-independent-build.log 2>&1
tools/verify-ipad.sh test "$simulator" "$derived" > /private/tmp/juni-env002-independent-test.log 2>&1

app="$derived/Build/Products/Debug-iphonesimulator/Juni.app"
plutil -p "$app/Info.plist"
otool -L "$app/Juni.debug.dylib"
xcrun simctl install "$simulator" "$app"
xcrun simctl launch --terminate-running-process "$simulator" com.binbas0901.singaporemathwithjuni
sleep 3
xcrun simctl io "$simulator" screenshot /private/tmp/juni-env002-independent-welcome.png
```

| Local evidence | SHA-256 |
| --- | --- |
| `/private/tmp/juni-env002-independent-build.log` | `355f3c9a3b7184f82ce1137c1d655277be2523334f33f458db0d37b290f48e8b` |
| `/private/tmp/juni-env002-independent-test.log` | `c473c36e46284c273a33897119f842404c1f34cfb784d0bb51ccf3cc681349ed` |
| `/private/tmp/juni-env002-independent-welcome.png` | `729214d8b3c8b882781cd2c7ac2df659cc0576ca682def102856d4c94a6904e6` |

The UI result bundle is `Logs/Test/Test-Juni-2026.11.19_19-57-15--0700.xcresult` under the recorded DerivedData path. QA read it with `xcrun xcresulttool get test-results summary --path`. These artifacts are local to the review Mac. The QA branch carries this report.

## Unexecuted checks and handoff

- **iPadOS 17 runtime launch** was unavailable on the installed simulator inventory. The 17.0 minimum is established by compile target and bundle metadata.
- **Physical iPad, Pencil, signing and provisioning** are deferred device and release checks. This audit used the Debug simulator build.
- **Airplane-mode launch and full offline learning flow** were not executed. Offline review was static and limited to the scaffold. A physical-iPad airplane-mode run of the installed unit remains a release check.
- **Hosted workflow execution** was outside the authorized scope. The review incurred no hosted CI usage and did not merge the PR or change application code.

The roadmap's ENV-002 clean build, smoke test, evidence and source-review criteria are met. The two low findings can be tracked as follow-ups. Lead review is the next step for project status and acceptance. No owner decision is needed for the independent review itself.
