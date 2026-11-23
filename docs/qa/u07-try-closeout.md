# U07 Try recombination — independent iOS QA closeout

**PASS — the targeted Try recombination defect is closed.** Independently reviewed and tested `c5d0543daac89fe4251f321cb9d757093c6fbd40`, the verified head of draft PR #28. Scope covers the single material finding in the original QA report and the Lead’s closeout criteria. [Original QA report](u07-preview-refinement-review.md#material-defect) · [Lead closeout request](https://github.com/binbas0901/Singapore-math-with-Juni/pull/28#issuecomment-7084770944)

## Acceptance evidence

| Check | Result |
| --- | --- |
| Recombine button, drag and tap | All three paths entered whole verification after the correct split. XCTest confirmed seven counters in the tray and an empty bowl after each path. The live model uses the same counter identities throughout. |
| Completed split and live counters | XCTest found a separate **Completed split** card showing historical parts 1 and 6 with generic part labels. The active **Number bond** card was absent, and the live workspace labelled its groups **Tray** and **Bowl · 0**. |
| Independent whole verification | **Whole** and **Your count** both had the accessibility value **Blank** on entry. The prompt asks the learner to count the tray, and inspection of the recombination and retry announcements found no stated whole total. The historical parts and individually countable counters remain available. Counter labels announce stable numeric identities, including **Counter 7 in tray**. These identities can cue the total, as flagged in the earlier report, while the group and bond labels withhold the cardinal answer. |
| Stale submission | Recombination cleared the missing-part entry of 6, removed **Check my answer**, and left **Check my count** disabled. Explicitly re-entering 6 produced neutral recount feedback and kept **Continue to Check** absent. The former missing-part submission and its erroneous feedback could not recur on the recombined model. |
| Continue and editing | Submitting 7 revealed **Tray · 7**, **Whole 7**, and **Continue to Check**. The continuation opened the independent eight-counter workspace with a blank missing-part field. Moving a counter back to the bowl after verification removed the history and continuation, and reset the split field to blank with submission disabled. Source review also confirmed that changing a digit after retry clears retry feedback and changing the grouping during verification resets the count. The existing preview stage tabs still allow direct navigation. |

No remaining material defect was found in the guided Try recombination flow. Accessibility evidence comes from XCTest queries and source inspection. Live VoiceOver and physical iPad were outside this run. The tester recorded the two Try screenshots as XCTest attachments. Screenshot export did not complete, so the distinction between the cards and live groups was verified through their rendered labels, accessibility elements and source layout.

## Full simulator run

Ran the shared **U07 Preview** scheme serially on the 13-inch iPad Pro (M5), UDID `2C76743A-F457-494B-BE68-3C7498A183DE`, using Xcode 26.3 (`17C529`). The invocation used `-parallel-testing-enabled NO -disableAutomaticPackageResolution CODE_SIGNING_ALLOWED=NO` and fresh derived data. Xcode exited successfully and reported **5 executed, 0 failures** in one full run.

| XCTest | Result |
| --- | --- |
| `testWelcomeScreenInPortraitAndLandscape` | Passed |
| `testCheckAcceptsTrayAsKnownPartAndHomeResetsBothWorkspaces` | Passed |
| `testCheckStartsBlankAndUsesBothModelAndNumber` | Passed |
| `testObserveRecombinesAndReplayPreservesTryWork` | Passed |
| `testTryManuallyRecombinesByDragAndTapAndResetsWhenEdited` | Passed |

The earlier intermittent Check startup failure did not recur in this run. Its root cause remains unconfirmed. Local evidence is in `/private/tmp/juni-u07-closeout-c5d0543.log` and `/private/tmp/juni-u07-closeout-c5d0543.xcresult`.

The report is the sole QA branch artifact. No owner decision is required to close this finding. The verdict is for Lead review of the draft preview.
