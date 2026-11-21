# DATA-001 independent closeout review

**Disposition — recommend Lead acceptance of the DATA-001 data-contract scope.** The three remaining package validation findings are closed at exact [PR #9](https://github.com/binbas0901/Singapore-math-with-Juni/pull/9) head `f5e69025b4bccc9795f04cfa410f5331e6f82dcf`. Keep the PR open and defer the LEAD-002 interface freeze pending reconciliation.

## Review basis

Independent Data Architecture and QA closeout for the versioned content contract and U07 fixtures under D02, D07–D09 and D11–D13. Reviewed the two earlier QA reports, Lead dispositions and closeout instructions, accepted CUR-003 v1.2 (integrated at `75f545c`, metadata synchronized at `e518160`), architecture v1.3, the schema, checker and corrected fixtures. The previous QA reports, authored package and schema JSON are byte-identical to the focused-review checkpoint `5f87d46`. This review adds only this report. [Initial independent review](data-001-independent-review.md) · [Focused independent review](data-001-final-review.md) · [Lead closeout instructions](https://github.com/binbas0901/Singapore-math-with-Juni/pull/9#issuecomment-7069028809) · [Accepted CUR-003](https://github.com/binbas0901/Singapore-math-with-Juni/blob/e518160/docs/first-unit.md) · [Architecture v1.3](../ARCHITECTURE.md)

## Checks executed

Python 3.9.6 with jsonschema 4.25.1. Both documented checker invocations exited 0. The fixture run accepted all 10 positives and rejected all 65 negatives with their expected diagnostics. An independent count of the fixture directories confirmed 10 and 65. The closeout revision adds one positive and 12 negatives. All three whitespace checks exited 0.

```sh
/tmp/juni-data001-venv/bin/python tools/check_data001.py
/tmp/juni-data001-venv/bin/python tools/check_data001.py --package curriculum/fixtures/u07/package
git diff --check
git diff --check e518160...f5e69025b4bccc9795f04cfa410f5331e6f82dcf
git diff --check 5f87d46 f5e69025b4bccc9795f04cfa410f5331e6f82dcf
```

Independently constructed each mutation from the original package in its own temporary directory. Recomputed every listed file's byte count and SHA-256 and generated a synthetic review pin from the final manifest for each run. Exercised the bundled CLI with `--package <temp-bundle> --education-review <temp-review.json> --bundle-file-list`. Each rejected mutation exited 1, emitted its expected diagnostic on stderr and produced no allowlist on stdout. The unmodified content control and eight valid synthetic WAV variants exited 0 with empty stderr and emitted exactly `manifest.json`, `catalog.json`, `lesson.json` and `placeholder.wav`.

| Finding | Independent test and result |
| --- | --- |
| Guided recombination | Removed only `clearBond`, only `linkBond`, and only `moveCounter` from Try in three separate package runs. All rejected with `action` naming the missing operation. The outward move and return share `moveCounter`, so one legal-action mutation covers both directions. In a separate fold probe, omitting only the final return left C1 in the bowl and failed the expected completed return-state comparison. |
| Isolated worksheets | Moved both original Check slots with their answer and working regions to `try-sheet`, removed the old sheet and assigned Check to `try-sheet`. The shared sheet had three valid slots covering guided, original Check and replacement items. Rejected with `worksheet: U07 Try and Check require distinct worksheet IDs`. |
| PCM byte rate and alignment | Reproduced the prior combined 8 kHz mono 8-bit WAV mutation with byte rate 8000→1 and block alignment 1→2. Repeated with each field changed alone. All three rejected with `media: inconsistent PCM byte rate or block alignment`. |
| PCM channels and frames | Three channels with consistent byte rate and alignment, and zero channels, both rejected as unsupported PCM. A stereo 16-bit data chunk with 5,005 complete frames and one additional byte rejected as incomplete frames. |
| RIFF and chunk boundaries | Oversized RIFF declaration, extra byte outside RIFF, data chunk overrun, missing pad after odd-sized data with corrected RIFF length, and an incomplete trailing chunk header inside RIFF all rejected with `media`. |
| Supported PCM controls | Mono and stereo at each of 8, 16, 24 and 32 bits passed. Each used 5,005 frames at 1,001 Hz for exactly 5,000 ms and a padded odd-sized `JUNK` chunk. Mono 8-bit also exercised a padded odd-sized data chunk. |

## U07 mathematical storyboard

Compared the original `e6246c2` fixture's Observe activity, workspaces, worksheets and item quantities and answers against the reviewed head. Those fields match. Replayed the corrected fixture using independent assertions.

- **Observe.** C1–C6 stay distinct and conserved. Tray/bowl counts at 0/1/2/3/4 seconds are 6/0, 5/1, 4/2, 4/2 and 6/0. Boundary probes at 999, 1999, 2999 and 3999 ms confirm the state before each transition. At 3 s the linked 6 = 2 + 4 bond maps the bowl to part A and tray to part B. Recombination retains the completed bond. Manual chapters yield the same counts. Full and time-truncated cue folds agree at 5000, 2999, 3000, 3999, 4000, 1000, 0, 2000 and 5000 ms in that replay order.
- **Try.** Seven counters begin in the tray. Moving C1 and linking gives 7 = 1 + 6. Clearing preserves that completed bond while C1 is still in the bowl. Returning C1 restores the exact baseline positions and retains the completed bond on the projected state. Try references `try-sheet`.
- **Check.** Whole 8 and known part 3 require 5, with separate answer and working regions in `check-sheet` and no preset model workspace. The reserved 9 = 4 + 5 replacement has its own slot. Both items answer 5.

## Remaining gates and handoff

- **Data contract.** The checker enforces authored action and worksheet identities, manifests and supported PCM structure. The regression suite also exercises candidate-specific disclosure and delivery references, supported-family question signatures, distinct numeric and model outcomes, and synthetic identity joins. The three prior counterexamples now reject. No remaining blocker was found within the closeout scope.
- **Education.** Review semantic neutrality across prompts, retries, captions, actual narration, manual steps, accessibility and replay. Verify comparable replacement demand and the effect of having already disclosed 5. A current manifest digest and reference demonstrate the pin mechanism. Human approval, speech alignment and production rights provenance require separate verification. The test bundles used synthetic rights and review records.
- **MATH-000 and Education.** Resolve exposure equivalence and propagation across items, families and sessions, and reconcile retry, practice fallback, reuse and mastery/retention policy with the shared fixtures. A different question signature alone cannot justify independent credit after the shared answer has been disclosed. The provisional owner defaults for beta testing leave this eligibility decision open.
- **IOS-001 and DATA-003.** Reconcile serialization and verify immutable occurrence, attempt and ink joins against actual persisted records. Enforce durable exposure before revealing delivery, freeze the submission before feedback, and verify transaction recovery and worksheet isolation across resume. Swift decoding, live input and recognition, observed model sufficiency, actual playback, accessibility, offline completion and physical iPad behavior were outside this repository-only review and remain untested here.

Lead should record scoped acceptance and coordinate the remaining Education, MATH-000 and iOS/data reconciliation. No new owner decision is needed for the three validator corrections. Interface freeze, app acceptance and release gates remain open.
