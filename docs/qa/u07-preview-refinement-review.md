# U07 Preview refinement — independent iOS and Mathematics Education QA

**Verdict — Changes requested before prototype acceptance.** The split arithmetic, counter interaction and independent answer checks are sound in the reviewed paths. Try needs to distinguish the completed split from the recombined counters and give the learner a chance to verify the whole.

## Scope and sources

- Task and role — U07 Preview refinement, independent iOS and Mathematics Education QA. Status — review with one material finding. Reviewed PR #28 at `e30724279e96cd02c49f4ffd958e73e82af056d0` on `qa/u07-preview-refinement`. The diff from the visual implementation `adce2f9343e69201e4f50b5de283c5d21f185230` to the reviewed head affects only `docs/PROJECT_STATUS.md`. [PR #28](https://github.com/binbas0901/Singapore-math-with-Juni/pull/28) · [Latest Lead review](https://github.com/binbas0901/Singapore-math-with-Juni/pull/28#issuecomment-7084456371)
- Instructional baseline — P1-L016 and P1-ADD-01-C01, using the accepted first-unit sequence and preparatory Education draft at `29213ce19abe18d09beaa775060179e543000cd5`. Applied the blueprint’s iPad-first, number-sense, moon-only and offline-first constraints to this preview scope. [First-unit specification](../first-unit.md#u07-vertical-slice) · [PR #25 teaching draft](https://github.com/binbas0901/Singapore-math-with-Juni/blob/29213ce19abe18d09beaa775060179e543000cd5/docs/spikes/u07-education-content.md)

## Material defect

### Try presents the old split as the current number bond after recombination

In Try, move one of seven counters to the bowl, enter 6 and tap **Check my answer**. Follow the recombination invitation by returning the bowl counter to the tray or tapping **Recombine counters**. The current groups are now **Tray · 7** and **Bowl · 0**, but the adjacent card still reads **Number bond** with **Bowl 1** and **Tray 6**. Its shape and colour links still point to the live groups. The submit control remains enabled with 6, and tapping it on this completed state replaces the completion feedback with a recount error and the initial instruction to split again. The completion prompt also sends the learner on to Check immediately, with the total already labelled. The teaching draft calls for retaining the completed diagram separately from the live groups and allowing the learner to verify the whole before moving on. Observe already distinguishes the retained diagram with **Completed example**. Carry that distinction into Try and keep the completed split out of active submission until the learner starts editing a split again. [Workspace and transitions](../../app/Juni/U07Preview.swift#L236-L338)

## Mathematics, progression and interaction

| Area | Evidence and assessment |
| --- | --- |
| Observe | The tray counts progress 6 → 5 → 4, with bowl counts 0 → 1 → 2. The linked diagram shows whole 6 with Bowl 2 and Tray 4. Recombination restores 6 and 0, and the retained bond is titled **Completed example**. Replay restores six unpartitioned counters without discarding Try work. Child-facing surfaces use words, numerals and a bond diagram throughout. |
| Try | The recommended path opens a separate workspace with seven counters. Prompts respond to an empty bowl, one in the bowl and excess counters. Before validation the tray total disappears, so the learner must count and enter 6. Success requires both the one-counter bowl and the correct numeral. Recombination restores seven and preserves the entered numeral. The completion presentation needs the correction above. |
| Moves and conservation | Selection followed by a destination button and coordinate drag to a group both use the same move function. Stable IDs are inserted into or removed from the bowl set, and the tray is the complement. Each counter has exactly one location. The drag preview is hidden from accessibility and a drop outside the regions leaves the groups intact. The suite exercises tap-select/tap-place and a tray-to-bowl drag. |
| Check | A separate workspace starts at Whole 8, Part 1 with value 3, and Part 2 blank. Eight counters begin in the tray. Group totals and group-to-bond links are absent before correct submission. The numeral 5 alone and a wrong numeral with the correct model both produce the same neutral recount feedback. Successful submissions accept both Bowl 3 / Tray 5 and Tray 3 / Bowl 5, then link the part nodes to the actual groups. The original prompt stays neutral as counters move. |
| Home | Resume returns to the last visited stage with its in-memory work. Start Over clears Observe, Try and Check and reopens Observe. The suite checks an in-progress Check resume and reset of both workspaces. |

## Simulator execution and visual evidence

Ran the shared **U07 Preview** scheme with Xcode 26.3 (`17C529`) on the 13-inch iPad Pro (M5), simulator ID `2C76743A-F457-494B-BE68-3C7498A183DE`, with iOS 26.3.1 as reported by XCTest. The tests launched the app with `-u07-preview`. The full suite ran serially with `-parallel-testing-enabled NO -disableAutomaticPackageResolution CODE_SIGNING_ALLOWED=NO`.

| Test | Result |
| --- | --- |
| `testWelcomeScreenInPortraitAndLandscape` | Passed in the full suite. |
| `testCheckAcceptsTrayAsKnownPartAndHomeResetsBothWorkspaces` | Passed in the full suite. |
| `testCheckStartsBlankAndUsesBothModelAndNumber` | Failed in the full suite at launch. XCTest found the Observe controls where it expected **Start lesson preview**, before any Check assertions ran. The isolated retry passed, including the drag, neutral feedback and Bowl-as-known checks. The initial startup failure remains unexplained. |
| `testObserveRecombinesAndReplayPreservesTryWork` | Passed in the full suite. It verifies the recombined tray total and completion prompt. The stale active bond and resubmission behavior are source findings beyond its assertions. |

Inspected Observe and Check in portrait and Try in landscape. The large counters, persistent caption, and distinct tray and bowl names, shapes and colours read clearly. In the captured states all active controls fit without scrolling or clipping. The Check prompt wraps cleanly in portrait, and all eight counters remain visible even though the eighth wraps to a second row. Its blank node and generic labels give neither group a predetermined role. The Try capture keeps the two groups, bond, keypad and destination controls in view together. The pale disabled button labels are less readable, and the initial instruction could name the destination buttons to make tap-to-place more discoverable.

Local evidence is under `/private/tmp/juni-u07-qa-e307242/`. The original run’s completed test counts are in `independent.log`. Its `independent.xcresult` was still staging failure diagnostics when the Observe and Try PNGs were copied out. The isolated rerun is recorded in `check-retry.log` and the finalized `check-retry.xcresult`. The following PNGs are the XCTest captures inspected for layout.

| File | SHA-256 |
| --- | --- |
| `observe-portrait.png` | `e9ae4be4dd92dc96dfb1f988451462482e5c2bc6b886c62e9173a003cf4e6e90` |
| `try-landscape.png` | `9f6b263b34b5ed518f378886c6781f1fa9f4d5659a381c4a9f214358d7d52500` |
| `check-portrait.png` | `95239a6f737afe5cbd37780abaff249f703ce41ee409e8f151d1530f3d8f1d83` |

## Nonblocking improvements

- In Try, link the bowl and tray part labels to the model after the learner places one counter. The current target bond uses the group labels from entry, even while the bowl is empty. In Check, **Known part** and **Missing part** would make the generic **Part 1** and **Part 2** clearer while preserving neutral group assignment.
- The stage tabs permit direct entry to Try and Check, which is practical for a preview. The Observe endpoint offers a clear **Try together** action. Try’s finished caption could offer an equally explicit next action after the learner verifies the recombined whole.
- Accessibility queries verify the diagram values, group labels, blank state and movable counter labels. Source inspection shows labelled destinations, selected traits, an accessible clear key and step/submission announcements. Counter labels use stable numeric IDs, which can sound like cardinal numbers after regrouping. Check exposes individual counters for counting, with no automatic group totals or missing numeral. A live VoiceOver session should confirm traversal, announcements, focus after movement and the distinction between counter identity and group count.

## Intentionally excluded production work

Readiness activities, recorded narration, timing and one-to-one count cues, drawing and Pencil/handwriting input, durable relaunch resume, attempt/exposure provenance, mastery and parent reporting remain outside this captions-only preview. This review covers one supplied iPad simulator at its default text size. Physical iPad, additional sizes, accessibility text scaling, live VoiceOver and reduced-motion playback remain unverified. No production gate or learner outcome is inferred.

## Handoff

The report is the sole repository artifact. No owner scope decision is needed for the finding. Lead and iOS should review the Try completion correction, then independent QA should recheck both recombination methods and rerun the full suite to verify the launch sequence.
