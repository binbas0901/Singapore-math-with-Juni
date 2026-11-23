# U07 offline narration independent QA

**Verdict — CHANGES REQUESTED.** Observe accepts sidecars that violate the required zero row-start marker. Fix the import/runtime contract before using it to validate the recording batch. Audio-device and final spoken-media acceptance remain open.

**Task and role.** U07 offline narration spike, independent iOS and Mathematics Education QA. Reviewed exact implementation `b057c62d18f30557c84e556a02d24e8dc040b785` in [draft PR #35](https://github.com/binbas0901/Singapore-math-with-Juni/pull/35), including the latest Lead comment, the [recording manifest](../spikes/u07-recording-manifest.md) and the [pinned PR #25 Education draft at `29213ce19abe18d09beaa775060179e543000cd5`](https://github.com/binbas0901/Singapore-math-with-Juni/blob/29213ce19abe18d09beaa775060179e543000cd5/docs/spikes/u07-education-content.md). D03 governs offline prerecorded narration. D02 and D13 preserve the distinction between guided practice and independent evidence and keep this review within the U07 slice.

## Findings

1. **Required zero row-start markers pass validation when nonzero.** The manifest requires a zero marker for first transfer, second transfer, bond emphasis and recombination. The exact loader accepts `{"offsets":[0.4,0.9]}` with a 1.7 s first-transfer fixture and returns a player and recording timeline. It validates length, order and bounds without a row-specific first-offset rule. The row already appears from playback time zero, while the declared start marker is at 0.4 s. Reject nonzero row-start markers on the four applicable rows, preserving valid nonzero first words for the two count-only rows. Verify that invalid rows use the nominal caption schedule and neighboring valid rows still use their recordings. [Loader](../../app/Juni/U07Narration.swift)
2. **Unexpected recording stops can advance the lesson on elapsed time.** The Observe loop increments the clock whenever `isPlaying` is false, including during the expected quiet hold. The same branch runs after an early stop if scene and audio-session interruption callbacks have not yet stopped the task. This is a source finding. A physical route loss or system audio interruption was not induced. Distinguish natural completion from premature stop and test the chosen paused or caption-fallback behavior before device acceptance. [Observe playback loop](../../app/Juni/U07Preview.swift)

## Caption and trigger audit

Compared manifest IDs and caption strings mechanically against the Swift declarations. All **23/23** IDs are unique and match their exact runtime captions. All **20/20** claimed verbatim lines match the pinned Education text. Reviewed each trigger against the row runner or `activePrompt` selection and action handlers. “Verbatim” refers to draft dialogue only.

| Clip ID | Runtime trigger | Text |
| --- | --- | --- |
| `u07-observe-intro` | Observe row 0, six counters in tray | Verbatim |
| `u07-observe-count` | Row 5, C1–C6 count | Verbatim |
| `u07-observe-whole` | Row 12, whole and full tray linked | Verbatim |
| `u07-observe-first` | Row 19, C1 transfer at its second marker | Verbatim |
| `u07-observe-second` | Row 22, C2 transfer at its second marker | Verbatim |
| `u07-observe-other-group` | Row 26, tray linked as other group | Verbatim |
| `u07-observe-count-tray` | Row 32, C3–C6 count | Verbatim |
| `u07-observe-bond` | Row 38, bowl then tray then whole linked | Verbatim |
| `u07-observe-recombine` | Row 49, both counters returned then C1–C6 count | Verbatim |
| `u07-observe-ready` | Row 60, recombined tray and historical bond, followed by Try access | Verbatim |
| `u07-try-entry` | Try with empty bowl and no completion state | Verbatim |
| `u07-try-count` | Exactly one in bowl before answer entry | Verbatim |
| `u07-try-bond` | Next prompt or numeral entry when the one-counter split is ready | Verbatim |
| `u07-try-split` | Correct guided numeral and split submitted | Verbatim |
| `u07-try-recount` | Correct guided split recombined, or recount draft restored after editing a retry | Adapted |
| `u07-try-done` | Correct fresh whole count submitted | Verbatim |
| `u07-try-retry` | Guided response rejected with one counter in bowl | Verbatim |
| `u07-try-move-back` | More than one counter in bowl | Verbatim |
| `u07-try-recount-retry` | Recombined whole count submitted incorrectly | Adapted |
| `u07-check-entry` | Fresh Check or return to its blank-answer prompt state | Adapted |
| `u07-check-answer` | Answer-entry state, including return to editing after retry | Verbatim |
| `u07-check-retry` | Confirmed submission fails model or numeral validation | Verbatim |
| `u07-check-success` | Correct Check transitions to completion. Later completion re-entry is quiet unless Replay prompt is tapped. | Verbatim |

### Education recommendation on adapted text

| Clip ID | Recommendation |
| --- | --- |
| `u07-check-entry` | Recommend for the counter-only preview. “Show how your two parts make eight with counters” describes the available tool while leaving both the unknown quantity and group orientation open. Re-review when drawing is available. |
| `u07-try-recount` | Recommend for the preview. “How many counters are together in the tray? Count them and enter the number.” connects the restored whole to a fresh count while keeping seven out of the prompt. |
| `u07-try-recount-retry` | Recommend as neutral guided retry feedback. “Count the counters in the tray again.” asks the learner to verify their count without giving the total or diagnosing a specific mistake. |

These are preview recommendations. Final recording text and curriculum approval remain with Education.

## Fixture results

Compiled the exact `U07Narration.swift` with `swiftc -D DEBUG` and a temporary macOS test harness. Generated low-level 440 Hz mono AAC/M4A tones with FFmpeg. Checked every offset immediately before and at its boundary, reverse cue lookup, decoded duration plus hold, and the final cue during the hold. Cross-checked the cue keys against the exact Swift counter and bond-emphasis mappings.

| Sidecar | Decoded duration + hold | Verified marker sequence |
| --- | --- | --- |
| Count | 3.3 s + 0.5 s | 0.25, 0.63, 0.99, 1.33, 1.78, 2.31 → C1–C6, individually |
| First | 1.7 s + 0.5 s | 0, 0.83 → six in tray, then C1 in bowl |
| Second | 2.2 s + 0.5 s | 0, 1.04 → C1 in bowl, then C2 joins |
| Count tray | 2.8 s + 0.5 s | 0.24, 0.57, 0.94, 1.72 → C3–C6, individually |
| Bond | 4.8 s + 0.5 s | 0, 1.14, 2.76 → bowl/Part 2, tray/Part 4, then both/Whole 6 |
| Recombine | 5.7 s + 0.5 s | 0, 0.81, 1.64, 2.04, 2.68, 3.04, 3.86, 4.62 → hold split, return both, then C1–C6 |

The four rows without sidecars also loaded and honored decoded duration plus hold. Intro 3.0 + 0.5 s, Whole 2.0 + 1.0 s, Other group 1.0 + 2.0 s, Ready 2.0 + 0.5 s. The two count-only rows accept a nonzero first word marker, and the timed renderer withholds the first indication before that marker. Recombination keeps Our split as the historical diagram after the return. The tone markers test the timing contract. Word-level alignment awaits actual speech.

**Fallback.** Ten loader cases returned no player and the expected nominal first-transfer timing: missing or corrupt M4A despite a valid JSON file, missing sidecar, malformed JSON, wrong count, negative, repeated, reversed or out-of-range offsets, and a nonnumeric offset. The separate late row-start fixture was accepted, reproducing finding 1.

## Offline and learner-state review

The app resolves exact-case local M4A and JSON paths under `Bundle.main/U07Narration`. `AVAudioPlayer(contentsOf:)` and `Data(contentsOf:)` use those local URLs. The playback path has no network request, API key, SDK integration or runtime ElevenLabs call. The supplemental build checks Xcode’s resource copy with fixture files. An airplane-mode target iPad run remains open.

A changed Try/Check prompt context stops the old player before attempting a new one. Pausing, replaying, counting and media completion do not submit or grade work. The guided split uses seven and requires a separate learner count after recombination. The fresh Check gives eight and three, leaves the missing numeral blank, keeps counter group quantities unlabelled before submission and uses neutral feedback for an incorrect numeral or missing model. Five is absent from the Check narration. The learner can enter it and must supply a matching 3/5 model in either orientation to reach completion. See My Work preserves the model. The preview accepts actions during the suggested thinking beats.

## Executed test results

**Exact-commit serial simulator run — 7 passed, 0 failed.** Shared U07 Preview scheme on iPad (A16), iOS 26.3, destination `4CBC892C-A385-46ED-982F-ACB16937C6F3`, with `-parallel-testing-enabled NO`. XCTest reported 315.272 s across the seven cases. The tracked resource directory contained no recordings.

| Test | Result |
| --- | --- |
| `testWelcomeScreenInPortraitAndLandscape` | PASS, 12.623 s |
| `testCheckAcceptsTrayAsKnownPartAndHomeResetsBothWorkspaces` | PASS, 31.754 s |
| `testCheckStartsBlankAndUsesBothModelAndNumber` | PASS, 32.947 s |
| `testCompletionWithSystemReduceMotion` | PASS, 51.253 s |
| `testObserveRecombinesAndReplayPreservesTryWork` | PASS, 78.195 s |
| `testObserveTimedPlaybackPausesResumesAndSwitchesToManual` | PASS, 87.703 s |
| `testTryManuallyRecombinesByDragAndTapAndResetsWhenEdited` | PASS, 20.797 s |

Local result bundle: `/private/tmp/juni-u07-narration-qa-dd/Logs/Test/Test-U07 Preview-2026.11.22_20-21-32--0700.xcresult`.

**JuniCore — 2 passed, 0 failed.** `xcrun swift test --package-path app/JuniCore --scratch-path /private/tmp/juni-u07-narration-qa-core` passed `NumberBondTests.testAllValidPairs` and `testInvalidPairs`. The first invocation hit sandbox restrictions on the compiler cache. The retry with cache access ran both tests.

**Host player lifecycle — PASS for state and clock.** The repository’s `tools/check_u07_narration.swift` passed using a 3.0 s non-speech M4A. The player started, paused with a stable playhead, resumed from the held position and replayed from zero using a fresh player. The tool’s loader, fallback and timing assertions also passed.

**Audible host playback — PASS for the non-speech fixture.** The default macOS output was the DisplayPort display. The owner confirmed hearing the host listening run using the exact app loader and a 440 Hz M4A. The harness started playback, paused at player time 2.675 s, held for 2 s, resumed, then replayed from zero. Audible results apply to the Mac listening run. Final speech and audible simulator or iPad routing were not verified by that run.

**Supplemental serial simulator fixture run — 2 passed, 0 failed.** Used a temporary archive of the reviewed app source with supplemental XCTest cases and local resources. The built bundle contained 19 fixture files plus the existing README. The fixture audio and test code stayed outside Git.

- `testFixtureBackgroundAndPromptTransitions` — PASS, 44.117 s. Observe held its row across Home/background and foreground, resumed on Play, replayed from the initial state and switched to manual counting. The Try entry recording exposed pause and resume controls, returned from background paused and replayed on request. Moving one counter stopped that recording, retained the correct count caption and showed no pause control for corrupt audio. Check entry started local playback with its missing slot blank. A wrong keypad entry replaced the entry prompt with its caption when audio was missing. Submission showed neutral retry without celebration.

- `testRecordedFixtureObserveRows` — PASS, 45.886 s. Playback traversed all ten fixture rows on the same iPad simulator within the recording-based windows. Verified the two transfers, both counters returned to the tray, the historical Our split diagram and Try access after the final row.

Local result bundle: `/private/tmp/juni-narration-qa/fixture-dd/Logs/Test/Test-U07 Preview-2026.11.22_20-31-02--0700.xcresult`.

## Remaining gates and handoff

- iOS and Lead should resolve the sidecar validation defect and verify early-stop handling. Repeat mixed valid/invalid rows and interruption checks on the target iPad, including background and foreground, system audio interruption and output route changes.
- Education should sign off on the exact en-SG text and three preview adaptations before recording. Recording production still needs the selected Sarah voice settings, rights and cost clearance, provenance and hashes. Listen to all 23 final clips and check caption fidelity, pronunciation, levels and cue marks against the exported files. Observe the holds and emphasis with the recorded words, including the two-counter return. Verify all Try and Check prompt replacements and completion replay with final assets.
- Device QA should verify target iPad speaker output, airplane-mode playback and full lesson completion, and VoiceOver with narration and caption-only fallback. Simulator Reduce Motion passed. No physical iPad, live VoiceOver session, deliberate route loss or final spoken media was tested.

Only this QA report is in scope for the branch. Refer the report to Lead, iOS and Education for follow-up.
