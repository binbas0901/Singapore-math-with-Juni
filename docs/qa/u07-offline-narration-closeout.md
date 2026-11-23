# U07 offline narration technical closeout

**Verdict — PASS.** Both original narration findings are closed for the U07 technical preview at the reviewed SHA.

**Task and role.** U07 narration, independent iOS QA. Reviewed implementation `7b39bb2fba9336e58699e94ae7fe6e1fb57bea9a` against the two original findings and the Lead's closeout criteria. D03 governs local prerecorded narration. D02 and D13 preserve the guided and independent lesson paths and limit the scope to U07. GitHub reported PR #35 open and draft at the exact reviewed SHA. [Original QA findings](u07-offline-narration-review.md) · [Lead review](https://github.com/binbas0901/Singapore-math-with-Juni/pull/35#issuecomment-7091302059)

## Findings and acceptance evidence

1. **Required-zero cue validation.** The exact-commit host fixture loaded all six Observe sidecars together. First transfer, second transfer, bond and recombination each accepted exactly zero and rejected a first offset of 0.000001 s. Each rejection returned the row's nominal offsets and duration with no player. Both count rows retained their recording and 0.125 s first marker in the same bundle. An independent probe set each required-zero row to 0.25 s one at a time, and the other five recordings remained enabled in every trial. The timed renderer suppresses the first counter indication until its first word marker. The host fixture additionally passed missing and corrupt audio and missing or malformed sidecar cases. [Loader](../../app/Juni/U07Narration.swift) · [Host fixture](../../tools/check_u07_narration.swift)
2. **Unexpected stop and natural completion.** The host fixture stopped a real local player and verified that the cue clock waited without advancing, then returned stopped at 100 ms without a successful completion callback. A naturally ended file advanced to its decoded boundary and then into the quiet hold. A supplemental host probe exercised delayed success after a waiting tick, unsuccessful completion, decoder error and ten real natural endings. Every natural ending entered the hold. Source review confirmed that the Observe loop keeps its last position when waiting or paused, and each row ends after the decoded duration plus its authored hold (0.5 s by default, 1 s for Whole, 2 s for Other group). [Playback delegate](../../app/Juni/U07Narration.swift) · [Observe runner](../../app/Juni/U07Preview.swift) · [Recording manifest](../spikes/u07-recording-manifest.md)

## Executed checks

- **Host fixtures — PASS.** Compiled the reviewed Swift source and repository harness with `swiftc -D DEBUG` and ran with a 3 s silent AAC fixture. The supplemental callback probe compiled against the same narration source. Local logs are `/private/tmp/juni-qa-7b39-host.log` and `/private/tmp/juni-qa-7b39-callback.log`. The initial sandboxed run could decode the fixture but lacked audio-output access. The rerun with local audio access passed.
- **JuniCore — 2 passed, 0 failed.** `xcrun swift test --package-path app/JuniCore --scratch-path /private/tmp/juni-qa-7b39-core` passed `NumberBondTests.testAllValidPairs` and `testInvalidPairs`. The initial run hit a compiler-cache permission error. The rerun with cache access passed. Local log is `/private/tmp/juni-qa-7b39-core.log`.

### Full serial U07 UI suite

The exact checkout, with no recordings in the bundle, passed all seven tests on iPad (A16), iOS 26.3.1 (`4CBC892C-A385-46ED-982F-ACB16937C6F3`). Ran the shared `U07 Preview` scheme with `-parallel-testing-enabled NO`. XCTest reported 326.543 s across the cases. Local result bundle is `/private/tmp/juni-qa-7b39-serial.xcresult` and log is `/private/tmp/juni-qa-7b39-serial.log`.

| Test | Result |
| --- | --- |
| `testWelcomeScreenInPortraitAndLandscape` | PASS, 10.881 s |
| `testCheckAcceptsTrayAsKnownPartAndHomeResetsBothWorkspaces` | PASS, 31.064 s |
| `testCheckStartsBlankAndUsesBothModelAndNumber` | PASS, 29.985 s |
| `testCompletionWithSystemReduceMotion` | PASS, 51.405 s |
| `testObserveRecombinesAndReplayPreservesTryWork` | PASS, 95.401 s |
| `testObserveTimedPlaybackPausesResumesAndSwitchesToManual` | PASS, 86.846 s |
| `testTryManuallyRecombinesByDragAndTapAndResetsWhenEdited` | PASS, 20.960 s |

The Observe assertion allows up to 2 s for SwiftUI's transfer animation to settle when the aggregate accessibility count differs from six. It still requires exactly six settled elements, exactly one per ID C1–C6, and the expected bowl membership for each ID. A persistent duplicate or missing ID fails even when the total stays six. The view derives both regions from complementary filters on the same six IDs. [Counter assertions](../../app/JuniUITests/LaunchTests.swift) · [Region rendering](../../app/Juni/U07Preview.swift)

Check opened with a blank missing part and group labels without quantities. Replay preserved the blank. A correct numeral with absent or inconsistent working and an incorrect numeral with a correct model each produced the same neutral retry without celebration. The correct 3/5 model and numeral reached completion in either orientation. The suite exercised portrait and landscape layout, See My Work and return to completion, Home reset and system Reduce Motion. The grader still calls `NumberBond.missingPart` and checks the model before showing completion. [Check tests](../../app/JuniUITests/LaunchTests.swift) · [Check implementation](../../app/Juni/U07Preview.swift)

### Recorded simulator fixtures

**3 passed, 0 failed.** Built a temporary archive of the reviewed app for the same iPad simulator and ran supplemental cases serially. The built bundle contained 19 local fixture files plus the existing README. Added XCTest assertions and a launch-argument-gated stop injection only in the temporary archive. The injection calls `AVAudioPlayer.stop()` once after the first-transfer playhead has reached at least 0.30 s, before the 0.83 s movement marker. The checked-in loader, playback delegate and pause/retry logic were the code under test. Local result bundle is `/private/tmp/juni-qa-7b39-fixture.xcresult`, log is `/private/tmp/juni-qa-7b39-fixture.log`.

- `testFixtureBackgroundAndPromptTransitions` — PASS, 43.593 s. Observe returned to the same caption with Play after 5 s in the background and advanced only after Play. Explicit Pause restored Play, Replay returned to the introductory caption, and Next step switched to manual counting starting at One. Try exercised Pause, Resume, Replay and foreground return in the paused state. Corrupt Try count audio and missing Check answer audio left their captions active. Recorded Check entry kept the missing part blank and wrong submission produced neutral retry without celebration.

- `testRecordedFixtureObserveRows` — PASS, 45.498 s. All ten recorded rows reached their expected captions and Try became available after Ready. The first transfer put C1 in the bowl, the second added C2, and recombination returned both to the tray. Each settled state contained all six unique IDs in the expected groups. The historical Our split diagram remained visible after recombination.
- `testUnexpectedStopHoldsBeforeTransferUntilPlay` — PASS, 27.349 s. The injected stop exposed Play and held the first-transfer caption and all six IDs in the tray for 3 s, longer than the remaining clip plus hold. Play retried the same row, moved C1 on its transfer cue and proceeded to the second-transfer caption. Source inspection confirms that Play seeks to the saved `demoPosition` and Replay resets it to zero.

## Scope and handoff

The review-only artifact is this report. Non-speech test assets and temporary test instrumentation are local QA inputs. Final speech alignment and audibility with the production files, actual iPad interruptions or audio route changes, physical-iPad airplane mode, live VoiceOver, and commercial audio approval remain outside this technical closeout. Lead receives the report. Physical-device QA and Education retain the outstanding device and speech checks, and the owner retains commercial approval.
