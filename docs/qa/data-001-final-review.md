# DATA-001 focused independent Data Architecture and QA re-review

**Recommendation — request further changes.** Keep DATA-001 in review. The checked-in U07 fixture matches the accepted mathematical storyboard and both checker commands pass. The validator still accepts a guided workspace that cannot clear its bond, a worksheet shared by Try and Check, and a bundled WAV with inconsistent PCM format fields. Close the package validation gaps and obtain the outstanding Education assessment before Lead acceptance.

## Review basis

Reviewed exact commit `ff71de381841de180e48619d2d74a6de3d2b66bc`, identified by the Lead as the PR #9 head and matching the local PR branch and remote-tracking ref. The review branch started clean at that commit. Read the original independent review, the Lead's intake and correction comments, the blueprint and current status, accepted CUR-002 at `49cbfca`, accepted CUR-003 v1.2 at `75f545c` with metadata at `e518160`, architecture v1.3 at `ee22c70`, the schema, fixtures and checker. The local CUR-002 inventory and architecture matched those baselines. The original review matched the bytes at `269f927` (SHA-256 `b6448076122c325234c9e17cd4676801fb2a143dc9d6903346c38eb71df25e46`). Blueprint decisions D02, D03, D06–D09 and D11–D13 apply. This review changes only this report. [PR #9](https://github.com/binbas0901/Singapore-math-with-Juni/pull/9) · [Lead re-review request](https://github.com/binbas0901/Singapore-math-with-Juni/pull/9#issuecomment-7066596174) · [Original review](data-001-independent-review.md) · [Accepted U07](https://github.com/binbas0901/Singapore-math-with-Juni/blob/e518160/docs/first-unit.md#u07-vertical-slice) · [Contract](../../schemas/README.md)

## Exact validation results

Python 3.9.6 and jsonschema 4.25.1. Both commands ran from the repository root at the reviewed commit.

| Command | Result |
| --- | --- |
| `/tmp/juni-data001-venv/bin/python tools/check_data001.py` | Exit 0. Nine named positives accepted and 53 named negatives rejected with the expected diagnostics. Final output was `PASS: schema, package, submission, CUR-002 anchors, U07 cue projection, 9 positive and 53 negative regression fixtures`. |
| `/tmp/juni-data001-venv/bin/python tools/check_data001.py --package curriculum/fixtures/u07/package` | Exit 0. `PASS: curriculum/fixtures/u07/package`. |
| `git diff --check`, `git diff --check 2651bdf ff71de3`, and `git diff --check f7649f3 ff71de3` | Exit 0 each, empty output. |

## Original 18 probes replayed

Independent mutations used schema-validated copies of the authored documents and temporary hash-consistent package copies. Thirteen probes rejected and five passed in their stated validation contexts.

| # | Probe | Result at reviewed commit |
| --- | --- | --- |
| 1 | Independent prompt explicitly gives 5 | Development lesson passes. Bundled package rejects stale pin with `review`. A matching synthetic pin passes. |
| 2 | Neutral retry explicitly gives 5 | Same result as probe 1. Neutral retry carrying disclosure metadata separately rejects with `exposure` in the suite. |
| 3 | Copy original question into replacement while retaining its distinct key | Rejects with `freshness`. |
| 4 | Point task hint exclusively at the six-counter worked example disclosure | Rejects with `exposure`. |
| 5 | Record original guide as delivered on an independent replacement occurrence | Rejects with `assistance`. |
| 6 | Change readiness activities from 6/7/8 to 10 | Rejects with `prerequisite`. |
| 7 | Add an acyclic count-to-split component mastery edge | Rejects with `prerequisite`. |
| 8 | Empty the Try workspace's legal actions | Rejects with `action`. |
| 9 | Change only the recombination caption to say the whole is five | Rejects with `timeline`. Mutating the caption and transcript to the same false sentence passes. |
| 10 | Add a second slot for the same item under a distinct slot ID | Rejects with `duplicate`. |
| 11 | Use arbitrary occurrence and confirmed-ink IDs | Standalone submission passes. Synthetic join regressions reject the unlinked occurrence and ink separately with `runtimeLink`. |
| 12 | Independent response with a pending model | Passes with `modelOutcome: pending`. |
| 13 | Independent response with an incorrect observed model | Passes with `modelOutcome: incorrect`. Probes 12 and 13 reject a claim of sufficient model evidence in the suite. |
| 14 | Add an unlisted physical file | Rejects with `file`. |
| 15 | Provide invalid audio with matching byte count/hash and synthetic bundled metadata | Rejects with `media`. |
| 16 | Add the replacement's answer-revealing feedback to its independent snapshot | Rejects with `evidence`. Candidate-specific feedback itself is supported. |
| 17 | Change the frozen manifest digest | Rejects with `identity`. |
| 18 | Advertise six seconds for the five-second PCM clip | Rejects with `timeline`. |

## D1–D5 dispositions

- **D1 · Candidate delivery.** The original 8/3 guide renders 3 and the replacement 9/4 guide renders 4. Independently verified that original guide exposure plus an empty replacement delivery list passes as independent. Replacement guide delivery plus its disclosure passes as assisted. Claiming independence then rejects with `evidence`, and omitting its disclosure rejects with `exposure`. Assigning the original guide or feedback to the replacement rejects with `assistance` or `exposure`, respectively. The suite also accepts practice-only fallback and candidate-specific feedback when replacement help is absent. The standalone checker accepts prior original feedback in a replacement's independent snapshot and accepts replacement feedback in an assisted snapshot. It sees disclosure membership and the candidate key. Committed receipts and event ordering must establish whether feedback came from an earlier attempt. In particular, both items answer **5** and the original feedback explicitly gives 5. Education and MATH-000 must determine when prior original help or feedback disqualifies this replacement and encode that decision before relying on its independence.
- **D2 · Freshness and neutrality.** Within the supported static family, the checker ties the key to family ID, whole and known part. Changing the key on an otherwise identical replacement fails, and the candidate demand fields and help metadata are checked. The shipped independent prompt and neutral retry leave the unknown unfilled as written. Fresh synthetic pins accepted both answer-bearing text mutations, demonstrating the semantic approval boundary. Education must review answer leakage and demand across copy, representations, audio, captions, accessibility, manual and replay channels. MATH-000 owns equivalence beyond the static signature and propagation across families, representations, versions, seeds and sessions.
- **D3 · Readiness and guided behavior.** Count and numeral match probe 6/7/8 for split-to-10, mapped to P1-ADD-01-C01 and P1-L016. U06 → U07 → U08 remains advisory with zero component mastery dependencies for that split. The suite rejects both lesson-side and catalog-side readiness drift. The checker exercises Try through the move and link, and matches manual captions to the transcript. The staged mutations below show two structural gaps. Semantic agreement between prose and the projected state stays with Education.
- **D4 · Worksheet and frozen evidence.** Wrong slot, wrong worksheet version and modified frozen item prompt each rejected with `identity` in added probes. The package pins package ID, content version, locale and exact manifest bytes. The worksheet enforces one slot per item within the worksheet and one answer region per slot. Numeric correctness, observed/pending model sufficiency and response eligibility are separate. The synthetic join compares session, occurrence, attempt, worksheet, region, ink, confirmed value and delivery/exposure fields against fixed records. Runtime must join real immutable records, observe the learner's model, verify recognition and confirmation lineage, and enforce the ordered durable exposure, submit and feedback sequence. Revalidating a static original snapshot offers no evidence that later runtime feedback cannot mutate it.
- **D5 · Bundle, audio and review pin.** The staged bundled CLI emitted exactly `manifest.json`, `catalog.json`, `lesson.json` and `placeholder.wav`, exit 0 and empty stderr. Missing and stale review pins rejected with `review`. An extra symlink rejected with `file` and truncated frame data with `media`. Package checks enforce safe relative paths, exact listed physical files, byte count/hash, and CUR-002 source/objective/concept anchors. The docs distinguish schema, minimum engine and immutable content versions and state version-bump and migration expectations. The synthetic external review record demonstrated only the digest and nonempty reference check. Release must establish independent reviewer provenance, semantic approval, actual speech alignment and rights clearance for the exact artifact. The bundled test used the silent development clip with synthetic rights metadata.

## Remaining DATA-001 corrections

| Area | Reproduction and requested correction |
| --- | --- |
| D3 · Guided recombination | Remove only `clearBond` from the Try workspace's `legalActions`. The lesson validator accepts it even though the accepted path lets the learner recombine after linking and the fold's clear action is required to complete the bond. Exercise the full move → link → clear → return sequence in package validation and add a negative fixture for the missing action. |
| D3/D4 · U07 worksheet separation | Append the two Check slots to `try-sheet` and change Check's worksheet reference to `try-sheet`. The lesson validator accepts the shared worksheet. Enforce distinct U07 worksheet references or explicitly specify and verify an equivalent activity-scoped isolation rule with iOS. The checked-in fixture uses separate sheets. |
| D5 · PCM header integrity | On a temporary bundle, change the 8 kHz mono 8-bit WAV's byte rate from 8000 to 1 and block alignment from 1 to 2. Recompute the manifest's file hash and the external review digest. The bundled validator accepts it because Python's frame reader derives frame size from channel count and sample width and ignores the conflicting fields. Validate PCM format consistency, including byte rate and block alignment, and add a hash-consistent negative fixture. Device decoder behavior for this malformed header was untested. |

## Exact U07 storyboard

| Phase | Verified fixture behavior |
| --- | --- |
| Observe | C1–C6 remain distinct and conserved. At 0, 1, 2, 3 and 4 seconds tray/bowl counts are 6/0, 5/1, 4/2, 4/2 and 6/0. C1 moves at 1 s and C2 at 2 s. The 3 s link maps bowl to part A (2) and tray to part B (4). At 4 s the link clears before the two returns, preserving the completed 6–2–4 example. Manual chapters follow the same boundaries. Full and time-truncated cue folds agree at 5000, 2999, 3000, 3999, 4000, 1000, 0, 2000 and 5000 ms. |
| Try | A distinct seven-counter baseline, with drag, tap-select/place and accessible action, starts at 7/0. Moving C1 and linking gives 7 = 1 + 6. Clearing and returning C1 restores all seven to the tray and preserves the completed example in the projection. Work and answer use `try-sheet`. |
| Independent Check | Whole 8, known part 3, unknown 5. `check-sheet` supplies separate answer and working regions and permits learner-selected counters, drawing or accessible marking. The authored activity supplies no preset model workspace or missing group. Reserved replacement is 9 = 4 + 5 in a separate slot. Its independence after earlier help remains subject to the exposure decision above. |

## Handoff

DATA-001 and the Lead should resolve the three remaining validator findings and rerun independent review against the corrected commit. Education must assess neutral access, the meaning of narration/manual states and replacement demand and leakage. MATH-000 and the owner retain evidence, retry, reuse and mastery policy decisions. IOS-001 and DATA-003 own serialized runtime identities, safe rendering of learner-facing fields, transaction durability, receipt ordering and recovery. LEAD-002 remains gated on reconciliation. This was a repository data review using synthetic inputs. Swift decoding, actual speech or playback, accessibility, recognition, offline completion, persistence and physical iPad behavior remain unverified.
