# ENV-001 — Development environment and evidence

Verified 2026-11-18 on the local Mac, with simulator and test follow-up on 2026-11-19. Release Engineering completed the verification pass on `task/ENV-001-environment`. The relevant blueprint decisions are D08, D11 and D12.

## Local toolchain

| Check | Observed result |
| --- | --- |
| `sw_vers`, `uname -m` | macOS 15.7.9 (24G830), x86_64 |
| `xcode-select -p`, `xcodebuild -version` | `/Applications/Xcode.app/Contents/Developer`, Xcode 26.3 (17C529) |
| `xcodebuild -checkFirstLaunchStatus` | Exit 0 |
| `xcodebuild -showsdks` | iOS 26.2 device and simulator SDKs, macOS 26.2 SDK |
| `swift --version` | Apple Swift 6.2.4, x86_64 macOS host target |
| `git --version` | 2.50.1 (Apple Git-155) |
| `python3 --version` | 3.9.6 |
| `node --version` | 24.14.0 |
| `codex --version` | Codex CLI 0.170.0. It reported a sandbox warning while creating PATH aliases. The local Codex session inspected and edited the checkout. |
| `gh --version` | GitHub CLI 2.102.0 |

## Repository and automated tests

- On 2026-11-18, the starting working tree was clean. The task branch had no upstream. Its HEAD, local `main`, and `origin/main` pointed to `f1fc6b11ab15a8c13f7a24e95ae6f49c908495dc`.
- `git ls-remote --symref origin HEAD refs/heads/main refs/heads/task/ENV-001-environment` confirmed that GitHub's default branch was `main` at the same commit. No remote ref for the task branch was advertised.
- `gh repo view binbas0901/Singapore-math-with-Juni --json visibility,viewerPermission,defaultBranchRef,isArchived` reported an active private repository and `ADMIN` access for the authenticated viewer. That initial pass exercised read access only. The initial sandboxed remote query failed DNS resolution and succeeded with approved network access.
- `swift test --package-path app/JuniCore` passed on macOS. XCTest ran two tests, `testAllValidPairs` and `testInvalidPairs`, with zero failures. The initial sandboxed attempt could not write the compiler module cache. The approved rerun used normal cache access. A second run with `--scratch-path /private/tmp/juni-env001-b46be7` compiled from an empty build directory and passed both tests again. The 2026-11-19 rerun of the standard command again passed both XCTest cases with zero failures on macOS. The package is a portable smoke test.

## Native iPad readiness

| Check | Observed result and implication |
| --- | --- |
| `xcrun simctl list runtimes`, `xcrun simctl list devices available` | On 2026-11-19, CoreSimulator listed iOS 26.3 (runtime build version 26.3.1, build 23D8133) and six available iPad simulators. The 2026-11-18 inventory had been empty. |
| `xcrun simctl bootstatus 4CBC892C-A385-46ED-982F-ACB16937C6F3 -b`, `xcrun simctl list devices booted` | iPad (A16) reached terminal status `Finished` in 1 minute 21 seconds (exit 0). The device listing independently reported `Booted` under iOS 26.3. |
| `xcrun devicectl list devices --hide-headers` | On 2026-11-19, no devices found. Target iPad model, iPadOS version and stylus compatibility remain unverified. |
| `security find-identity -v -p codesigning` | On 2026-11-19, zero valid code-signing identities in the queried keychains. Team and provisioning readiness remain unverified. |
| Tracked project files | `app/JuniCore` is a Swift package. The checkout has no Xcode app project or workspace, so there is no app target to build, sign or install. |

Available iPad models were iPad (A16), iPad mini (A17 Pro), iPad Air 11-inch and 13-inch (M3), and iPad Pro 11-inch and 13-inch (M5).

Xcode and both iOS SDKs are available for the later app skeleton. An unsigned simulator build can check compilation once there is an app target. A physical install requires the target iPad, an authorized Apple signing team, a development signing identity and a matching provisioning profile. The proposed iPadOS 17 minimum is pending device review. Native app compilation, installation, signing, provisioning and physical-device tests remain unverified.

The runtime was installed before the follow-up. The verification incurred no costs. Existing local tools and GitHub read access supported this verification. Codex and GitHub allowances, CI costs and any Apple distribution costs were not assessed. Any spending or distribution requires owner authorization.

## Lead acceptance

The Lead independently reviewed GitHub commit [`c244cb3f205e19c1a2a94cd65b1afb5ee45bfcff`](https://github.com/binbas0901/Singapore-math-with-Juni/commit/c244cb3f205e19c1a2a94cd65b1afb5ee45bfcff) and accepted ENV-001. ENV-002 is ready for dispatch once integration into main is confirmed. Native app build, development signing and provisioning, and physical iPad and stylus verification remain downstream requirements.
