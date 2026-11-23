# U07 manual counting closeout

**Task and role** — Independent iOS and Mathematics Education QA for the Observe teaching prototype under D03, D08, D11 and D13. Implementation reviewed at `8fdfdeae91d2a182e2fc73a27fe86fb178de584d`, verified as the head of draft PR #31. The acceptance criteria come from the prior independent QA finding, the latest Lead review and the Education Observe cue table. [Prior QA](u07-teaching-playback-review.md) · [Lead review](https://github.com/binbas0901/Singapore-math-with-Juni/pull/31#issuecomment-7088018903) · [Education draft](https://github.com/binbas0901/Singapore-math-with-Juni/blob/29213ce19abe18d09beaa775060179e543000cd5/docs/spikes/u07-education-content.md)

**Manual counting verdict — PASS. Close the one-to-one counting defect for the exploratory Observe prototype.**

## Manual counting evidence

| Check | Result |
| --- | --- |
| Opening count | In landscape, the count starts at C1 with **One**. Five **Count next** taps advance through C2–C6 and **Two** through **Six**. All six counters stay in the tray. |
| Remaining tray | With C1 and C2 in the bowl, C3 starts again at **One**. The three following cues advance to C6 and **Four**. The bowl counters stay in the bowl and carry neutral labels. |
| Recombined whole | In portrait, the two bowl counters return, the bowl is empty and the tray contains six. Counting restarts at C1 and reaches C6. At **Four** → **Five**, the cue goes from the right of the first row to the left of the second. **Our split** preserves the prior demonstration. |
| One-to-one correspondence and accessibility | The suite asserted all 16 cues, exactly one selected counter per cue, the matching count-word label and a hittable current element. The other five elements expose neutral group labels. Source applies the outline and count-word overlay to that same counter. It posts a caption plus count-word announcement on count-stage entry and a count-word announcement on subsequent manual taps. The manual count has no timer. |
| Captions and stage controls | Direct comparison of the ten source strings against the Education draft matched 10/10 in order. The UI test checked all ten displayed captions, including the unchanged caption at each intra-stage cue. **Count next** stays available until the last word. **Next step** advances the stage after the last word. **Try together** appears at the final prompt. |
| Playback and Replay | The suite checked Pause holding the opening caption, Play resuming the timed sequence, and Replay resetting the demonstration. **Next step** from timed playback returns to a manual stage at **One** and **Count next** proceeds to **Two**. Replaying Observe preserves the learner's Try model and draft response. |
| Try and Check | In Try, after moving the given one into the bowl, the missing tray quantity and bond value stay blank before entry. The recombined whole requires a new learner count. In Check, the givens are eight and three, the missing bond value starts blank and the groups stay neutral before a correct response. The suite rejects a numeral without a matching model and accepts either orientation of a correct model. |

I inspected exact-build screenshots of the landscape opening and remaining-tray counts and the portrait **Four** and **Five** recount cues. Each shows one outline and one word attached to its counter, with the caption and control visible. The cue crosses the row boundary while the bowl and historical bond stay in view.

## Foreground Play investigation

**Disposition — reproducible simulator input issue, nonblocking for this prototype.** Both missed taps required one retry. Both immediate coordinate taps and both settled button taps worked on the first attempt. A physical iPad retap rate and material impact on a child remain unverified. A focused physical-device check of the return-from-Home gesture is appropriate before device acceptance.

I used a temporary archive of the reviewed implementation with diagnostic logging at scene-phase transitions, Play entry, pause and task start/cancellation. The probe ran in portrait. For each trial, start **Replay** in Observe, wait for the opening six-count caption, press Home, wait for XCTest to report `runningBackground`, wait two seconds, then call `app.activate()`. Invoke one of the following inputs and check whether the button becomes **Pause**. If it stays **Play**, verify the held caption and tap **Play** again. In all six trials verify that playback advances to the whole-six caption.

| Input after `app.activate()` returned | First taps missed | Outcome |
| --- | --- | --- |
| Immediate `app.buttons["Play"].tap()` | 2 of 2, trials 1 and 4 | Caption held. A second button tap resumed in both trials. |
| Immediate tap at the recorded Play center, portrait window coordinates (55, 299.5 points) | 0 of 2, trials 2 and 5 | Both resumed on the first tap. |
| Same Play element tap after one second | 0 of 2, trials 3 and 6 | Both resumed on the first tap. |

The immediate requests were issued with no deliberate delay. XCTest first resolved the target and waited on system UI, logging event synthesis about 1.1 seconds after the requests. The scene logged active about 0.27–0.29 seconds after activation returned. Neither missed element tap logged Play entry or started a playback task. The successful retries entered Play in the active scene from approximately 5.56 and 5.63 seconds, scheduled playback and advanced to the whole cue. This places the observed failures before playback scheduling. The probe did not record event routing or a resolved hit target for the missed taps, so the specific input-delivery or hit-testing cause remains open. The reviewed source contains no foreground Play fix.

## Checks executed

- Xcode 26.3 (17C529), iPad (A16), iOS 26.3.1 (23D8133), simulator `4CBC892C-A385-46ED-982F-ACB16937C6F3`. Ran the exact implementation with the full `Juni` scheme test action, Debug, `-parallel-testing-enabled NO`, with no test filter. The structured result was **6 passed, 0 failed, 0 skipped**. Result bundle `/private/tmp/juni-independent-8fdf.xcresult`.
- The two focused tests ran serially on the temporary instrumented copy. The foreground trial test passed in 122.286 seconds, including detection and recovery for both misses. The first Reduce Motion attempt failed in 65.213 seconds when the probe did not sample the one-second **One** cue after Replay. Its manual sequence, transfer and switch-back assertions passed. Result bundle `/private/tmp/juni-independent-probe.xcresult`.

- The Reduce Motion retry **passed** in 71.061 seconds. With the simulator setting verified on, the probe stepped through all six opening manual cues in portrait, replayed, paused during the timed count and confirmed a single selected counter with a count word. Playback resumed through the first transfer, and **Next step** switched to the manual second-transfer state with two in the bowl. The probe verified restoration of the original system setting. Result bundle `/private/tmp/juni-independent-motion-retry.xcresult`.

| Full serial suite test | Result | Seconds |
| --- | --- | ---: |
| `testWelcomeScreenInPortraitAndLandscape` | Pass | 13.462 |
| `testCheckAcceptsTrayAsKnownPartAndHomeResetsBothWorkspaces` | Pass | 21.750 |
| `testCheckStartsBlankAndUsesBothModelAndNumber` | Pass | 18.950 |
| `testObserveRecombinesAndReplayPreservesTryWork` | Pass | 71.646 |
| `testObserveTimedPlaybackPausesResumesAndSwitchesToManual` | Pass | 87.351 |
| `testTryManuallyRecombinesByDragAndTapAndResetsWhenEdited` | Pass | 21.649 |

## Scope and handoff

The simulator ran in captions-only mode. Live VoiceOver speech and focus traversal, physical iPad input and recorded narration remain unverified. The accessibility evidence covers XCTest labels and selected state, plus source inspection of the announcement calls. The Lead can use this closeout to review the focused prototype gate. No owner decision is needed.
