# U07 recording manifest

**Proposed en-SG script for the Debug iPad preview.** Observe and most learner prompts follow the [preparatory Education draft in PR #25 at `29213ce19abe18d09beaa775060179e543000cd5`](https://github.com/binbas0901/Singapore-math-with-Juni/blob/29213ce19abe18d09beaa775060179e543000cd5/docs/spikes/u07-education-content.md). The dialogue column is also the full, verbatim on-screen caption. The learner can read it throughout the current step or prompt. Voice, script, recordings and usage rights await approval.

## Observe

Play starts at the current step. Replay starts with all six counters in the tray. Each clip starts on entry to its row. The JSON cue sequence is ordered exactly as listed in the last column, including the leading row-start marker where specified.

| Clip ID | Juni dialogue and caption | State on row entry | Ordered markers in sidecar |
| --- | --- | --- | --- |
| `u07-observe-intro` | Let’s count the counters in this tray. | C1–C6 in tray, bowl empty, bond hidden. | None |
| `u07-observe-count` | One, two, three, four, five, six. | Keep all six together. | Highlight C1 through C6 at their six spoken count words. |
| `u07-observe-whole` | Six is the whole. That means all the counters. Watch me split them into two groups. | Link Whole 6 to the full tray. | None |
| `u07-observe-first` | One into the bowl. | Six in tray. | Row start at 0, then move and indicate C1 at “into the bowl.” |
| `u07-observe-second` | One more into the bowl. Two in the bowl. | Five in tray, C1 in bowl. | Row start at 0, then move and indicate C2 at “into the bowl.” |
| `u07-observe-other-group` | The tray is our other group. How many are there? | Indicate tray as the other group. Hold both groups. | None |
| `u07-observe-count-tray` | One, two, three, four. Four in the tray. | C3–C6 in tray, C1–C2 in bowl. | Highlight C3 through C6 at their four spoken count words. |
| `u07-observe-bond` | Two in the bowl. Four in the tray. Two and four make six. This picture is a number bond. | Show Whole 6 and both parts, with bowl/Part 2 linked first. | Row start at 0, then link tray/Part 4 at “Four in the tray,” then both groups/Whole 6 at “Two and four make six.” |
| `u07-observe-recombine` | Let’s put the two back. One, two, three, four, five, six. We still have six! | Hold the split and completed bond. | Row start at 0, then return C1 and C2 together on “back,” then highlight C1 through C6 at the six count words. Keep the historical bond titled Our split. |
| `u07-observe-ready` | Ready to make your own split? Tap Try. | Hold recombined six and historical bond. | None. The Try together button appears after this row ends. |

Recorded rows use the decoded duration plus a quiet hold of 0.5 seconds, except Whole (1 second) and Other group (2 seconds). Caption-only rows use the Education draft’s nominal timing and cues, totaling 64 seconds when all rows are silent. Each row can fall back independently. Manual mode keeps the same captions and actions and supports Count next to inspect one counter at a time.

A successful recording completion starts the quiet hold. If a recording stops unexpectedly, Observe pauses at the last displayed position. Tap Play to retry from there, Replay to start over, or Next step to continue manually. Returning from the background also requires Play to resume timed Observe.

## Try, Check and completion

Prompts play once when the indicated activity or learner-driven state is reached. Replay prompt repeats the visible caption. Pause/Resume narration control the current recording. Learners can think indefinitely, and a new prompt replaces the old audio. The preview leaves counting and working time open after each prompt. It also accepts actions while a prompt is playing, including during the suggested five- and eight-second thinking beats. No media event grades or submits work.

| Clip ID | Juni dialogue and caption | Trigger and expected learner action |
| --- | --- | --- |
| `u07-try-entry` | Here are seven counters. Move one from the tray to the bowl. | Enter Try with seven in tray and empty bowl. Learner moves one. |
| `u07-try-count` | The bowl has one. The counters in the tray are the other part. How many are in the tray? | Exactly one in bowl. Learner counts tray. |
| `u07-try-bond` | Put that number in the empty part of the number bond. | Learner taps Next prompt or begins numeral entry. Learner enters and submits. |
| `u07-try-split` | You made two groups. One and six make seven. Put the bowl counter back in the tray. How many are there now? | Existing Try grader confirms a correct split and numeral. Learner returns the bowl counter. |
| `u07-try-recount` | How many counters are together in the tray? Count them and enter the number. | Correct split recombined. Preserve the historical split. Learner enters a fresh whole count. |
| `u07-try-done` | Seven again! You split the whole and put it back together. | Existing guided whole-count verification succeeds. Continue to Check is available. |
| `u07-try-retry` | Try once more. How many are in the other part? | Submitted guided numeral needs revision with one in bowl. |
| `u07-try-move-back` | We need one in the bowl. Move counters back until just one is there. | More than one in bowl. Learner adjusts their split. |
| `u07-try-recount-retry` | Count the counters in the tray again. | Submitted recombined count needs revision. |
| `u07-check-entry` | The whole is eight. One part is three. What is the other part? Show how your two parts make eight with counters. | Enter fresh Check. Eight in tray, bowl empty, missing slot blank. Learner builds both groups. |
| `u07-check-answer` | Put your answer in the empty part. | First keypad entry. Learner can revise and explicitly submit. |
| `u07-check-retry` | Take another look. The whole is eight. One part is three. What is the other part? Show how your two parts make eight. | Existing Check submission does not meet both grading conditions. Keep learner work editable. The same wording covers absent or inconsistent working and incorrect entries. |
| `u07-check-success` | You showed both parts and how they make eight. Well done! | Existing Check grader accepts both numeral and model. Show completion with the submitted group orientation. See My Work retains the model. Completion re-entry is quiet unless the learner replays. |

The Check introduction is adapted to the counter-only preview. The two Try recount lines are retained preview instructions. Readiness, drawing, handwriting, separate evidence-pending feedback and expanded guided help are outside the playable prototype and have no import slots here.

## Import approved files

1. Obtain owner approval for the voice, Education approval of the exact text and any preview adaptations, and clearance for rights and any spending. Record provenance, voice/settings, approval, version and file checksum for each export. Review the pronunciation of the en-SG copy and keep breaths and existing silence in mind when marking cues.
2. Export each approved spoken clip as AAC in an M4A container. Use one mono file per ID with consistent levels and minimal leading or trailing silence. Name each file `<clip-id>.m4a`, with exact case. Put the files in `app/Juni/U07Narration/`. Xcode copies this folder into the app resources on build. Import only the intended release-candidate files into the folder.
3. On the final M4A, measure each listed marker from the audio file’s start, in seconds. For rows with markers add `<clip-id>.json` alongside the audio. The file contains an `offsets` array. For example, a hypothetical first-transfer clip contains `{"offsets":[0,0.82]}`. Supply one finite, nonnegative, strictly increasing offset per listed marker. Every offset must be earlier than the decoded clip duration. The first offset must be exactly zero for first transfer, second transfer, bond and recombination. Both count rows can have a nonzero first marker, and the first counter stays unhighlighted until that word. Clip rows with no markers and all learner prompts need only the M4A.
4. Rebuild the **U07 Preview** scheme and inspect the copied `Juni.app/U07Narration/` resources. A missing or unreadable recording, or a required cue sheet that cannot be validated, falls back to the captions. The preview reads only app-bundle files and requires no connection. Test the assembled build with networking disabled on an iPad.
5. Listen to each file against the caption and watch the cue alignment at normal playback. Check pause and resume before and after moves, Replay, switching to manual, moving between workspaces mid-prompt, completion replay, backgrounding, and missing and malformed assets. Confirm Check never names or displays the unknown value before the learner supplies it or the completion already exists. Review on the target iPad with VoiceOver and Reduce Motion before release.

## Local verification

Run the shared **U07 Preview** Xcode scheme tests on an iPad simulator. The full run exercises the no-asset Observe clock, manual steps, timed pause/resume/replay, guided transitions, neutral Check prompts, and completion.

From the repository root, the following macOS check uses a temporary silent AAC fixture and tests local decoding, recorded cue timing, pause/resume/replay, and missing or malformed resources. It needs FFmpeg and a working local audio output.

```sh
ffmpeg -f lavfi -i anullsrc=r=44100:cl=mono -t 3 -c:a aac /tmp/u07-silent-fixture.m4a
swiftc -D DEBUG app/Juni/U07Narration.swift tools/check_u07_narration.swift -o /tmp/check_u07_narration
/tmp/check_u07_narration /tmp/u07-silent-fixture.m4a
```
