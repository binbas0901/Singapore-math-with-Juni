# DATA-001 independent Data Architecture and QA review

**Recommendation — request changes.** Keep PR #9 open and DATA-001 in review. The positive U07 fixture reproduces the accepted storyboard, and all 23 authored negative fixtures reject as expected. The contract still permits replacement work to be recorded as independent after delivery of help intended for the original item. Close the data findings and reconcile the shared contracts with MATH-000 and IOS-001 before LEAD-002 freeze.

## Review basis

GitHub reported open PR #9 at `e6246c2ebdf2de5a40e4ed303b2e87164f9e16aa`, targeting `main`. Local HEAD matched and the worktree was clean before validation. Reviewed both Lead comments, AGENTS.md, the blueprint, the accepted CUR-002 inventory and mapping at `49cbfca`, the accepted CUR-003 v1.2 specification integrated at `75f545c` with metadata synchronized at `e518160`, architecture v1.3, the schema, fixture package, submission, checker and all negative mutations. Applicable blueprint decisions are D02, D03, D06–D09 and D11–D13. The accepted CUR-003 version was read from Git without changing the checkout. [PR #9](https://github.com/binbas0901/Singapore-math-with-Juni/pull/9) · [CUR-002 mapping](../coverage-p1.md) · [Accepted CUR-003](https://github.com/binbas0901/Singapore-math-with-Juni/blob/e518160/docs/first-unit.md) · [Architecture](../ARCHITECTURE.md) · [Draft contract](../../schemas/README.md)

## Findings requiring DATA-001 corrections

| ID | Severity | Finding and requested correction |
| --- | --- | --- |
| D1 | High | **Item-specific help and feedback lack a candidate binding.** The assessment activity assigns one help ladder to the 8/3 check and its 9/4 replacement. The guide says to move three, its disclosure keys name the original item, and feedback must include the original item's key. An independent replacement submission carrying `check-guide` passed. Appending replacement-only feedback failed with `exposure`. Adding the replacement key to shared help would instead fail the pre-offer freshness rule. Provide per-item or explicitly parameterized help and feedback with validated occurrence applicability, including a supported practice fallback when a candidate has no valid help. Cover original help → fresh replacement and help on the replacement → assisted replacement as separate cases. Preserve the original result across later feedback. |
| D2 | High | **Declared freshness and neutrality can contradict the authored content.** An exact copy of the original question retained a different replacement key and passed. A hint whose only disclosure key was the six-counter example also passed. The independent prompt and the nominally neutral retry each accepted text supplying 5. The checked-in prompt and retry are neutral for this task as written. Reject identical question signatures with different keys within the supported family, validate task-specific disclosures against their recipient and add an explicit content review gate for neutral prompts, captions, accessibility text and alternate delivery channels. General mathematical equivalence and review scope require MATH-000 and Education. |
| D3 | Medium | **Package validation can drift from accepted U07 dependencies and guided behavior.** The shipped catalog correctly uses separate advisory and bounded readiness edges, with zero component mastery prerequisites for P1-L016. The checker accepted readiness quantities changing from 6/7/8 to 10 with the catalog untouched, and accepted an unauthorized acyclic mastery edge onto U07. It also accepted a guided workspace with no legal actions and a manual recombination caption stating that the whole became five. Bind readiness activities to the declared probes, verify the U07 prerequisite mapping and validate the guided path against the workspace’s declared actions even in package mode. Review narration and manual text against the semantic state at each boundary. |
| D4 | Medium | **Worksheet and evidence snapshots need explicit identity scopes.** Unique slot IDs and a single answer region per slot are enforced, but a second slot with a new ID and the same item passed. Define whether multiple slots per item are supported and, if so, make the active slot explicit. The standalone validator accepted arbitrary occurrence and confirmed-handwriting revision IDs. Define the shared tuple and provide a synthetic linked example or document which checks require runtime records. A pending model and an incorrect observed model both passed with independent evidence class. That class can describe response eligibility, so require a separate model outcome before awarding model or mastery credit. Avoid using the evidence class as a correctness signal. |
| D5 | Medium | **Manifest checks verify listed bytes and placeholder duration, with gaps at bundle handoff.** A physical extra file passed. A manifest declaring bundled usage and cleared rights passed with hash-correct bytes that were invalid audio. Require the packaging step to emit and verify the manifest allowlist, and define the media decodability and duration check for supported bundled codecs. Rights status needs independent provenance review. Separate content version from schema and engine compatibility and document immutability and version-bump rules for authored IDs and package updates. The fixture suite currently checks CUR-002 source anchors, while the general package command validates local catalog references without comparing them to the inventory. Make the authoring gate for this comparison explicit. |

D1–D2 trace to activity-level assistance and feedback resolution in the lesson validator and exposure classification in the submission validator. D3–D5 trace to the catalog/workspace, worksheet/submission and package validators. Update the stale CUR-003 pending statement during the DATA-001 revision. [Checker](../../tools/check_data001.py) · [U07 lesson](../../curriculum/fixtures/u07/package/lesson.json) · [Synthetic submission](../../curriculum/fixtures/u07/submission.json)

## Positive evidence and boundaries

- Draft 2020-12 schema checks passed. The fixture exercises local references, typed discriminators, version pins, unique IDs in their named scopes, objective source anchors and objective-to-concept classification. U07 split evidence is bounded through 10 and maps to P1-ADD-01-C01 and P1-L016. The catalog's U06 → U07 → U08 order is advisory. Count and match are readiness support for six and upcoming quantities seven and eight.
- Observe conserved C1–C6. At 0/1/2/3/4 seconds the tray/bowl counts were 6/0, 5/1, 4/2, 4/2 and 6/0. At 3 seconds the bowl is part A (2) and the tray is part B (4). At 4 seconds the clear cue precedes the two returns, and the completed 6–2–4 example remains available. Manual chapters use the same boundaries. The independent sample order `5000, 2999, 3000, 3999, 4000, 1000, 0, 2000, 5000` produced identical states from complete and time-truncated cue lists, with six unique counters at every sample.
- Try uses a separate seven-counter baseline, and the checker projects the 7–1–6 partition. The authored independent item leaves 5 undisclosed, supplies whole 8 and known part 3, and permits learner-selected counters, drawing or accessible marking. The synthetic keypad submission pins the package and exact item snapshot and keeps model evidence separate. The synthetic confirmed-handwriting variant carries a revision ID and assisted evidence. The fixture audio is a five-second silent PCM placeholder.
- Python checks establish portable data behavior. Swift decoding, media playback and delivery barriers, restoration of live learner work, recognition, accessibility, durability, offline completion and physical iPad behavior remain downstream.

## Exact validation results

Python 3.9.6 with jsonschema 4.25.1. Commands run from the repository root on the clean reviewed head.

| Command | Result |
| --- | --- |
| `/tmp/juni-data001-venv/bin/python tools/check_data001.py` | Exit 0. `PASS: schema, package, submission, CUR-002 anchors, U07 cue projection, 23 negative fixtures` |
| `/tmp/juni-data001-venv/bin/python tools/check_data001.py --package curriculum/fixtures/u07/package` | Exit 0. `PASS: curriculum/fixtures/u07/package` |
| `git diff --check` and `git diff --check 2651bdf HEAD` | Exit 0 for both, no output. |

Inspected each negative as a mutation of the positive fixture and confirmed the reported guard category. The missing-media case leaves the engine version at its existing value and removes the WAV in a temporary package. The wrong-ink-region case changes the answer region to a working region, so it covers region role while an actual ink revision remains outside that test. Replacement-repeats-question copies the key and does not exercise an unchanged question with a different key.

| Diagnostic | Authored fixtures rejected |
| --- | --- |
| cycle | advisory-cycle, mastery-cycle |
| timeline | cue-outside-clip, cue-tie |
| file / integrity / rights | missing-media / bad-media-hash / placeholder-in-bundle |
| duplicate / action / bond | duplicate-counter / illegal-counter-source / wrong-bond |
| freshness / evidence | exposed-independent-item and replacement-repeats-question / exposed-submission |
| assistance / bounds / answer | out-of-order-help / out-of-range-probe / incorrect-answer |
| schema | unconfirmed-recognition, unknown-schema-version, unsafe-media-path |
| reference | unknown-disclosure, unknown-objective, unknown-region |
| identity | wrong-ink-region |

Additional probes used in-memory copies and temporary package directories. Each document probe ran schema validation before the applicable semantic validator. Of 18 probes, 15 were accepted and three rejected.

| Result | Probes |
| --- | --- |
| Accepted · help and freshness (5) | Answer in independent prompt, answer in neutral retry, identical replacement with a distinct key, task hint keyed only to the worked example, independent replacement after original guide disclosure |
| Accepted · curriculum and worksheet (5) | Readiness quantities drift, unauthorized U07 mastery edge, empty guided legal actions, contradictory recombination chapter, duplicate item under a distinct worksheet slot |
| Accepted · provenance and media (5) | Arbitrary occurrence and ink IDs, pending model with independent response, incorrect observed model with independent response, unlisted physical file, invalid audio with byte-correct bundled manifest |
| Rejected (3) | Replacement-specific feedback (`exposure`, exposes a contract gap), wrong manifest pin (`identity`), misdeclared placeholder duration (`timeline`) |

## Handoff to Lead

- **DATA-001 with Education** owns the schema and authoring corrections, refreshed CUR-003 status, and targeted fixture coverage. Re-run both commands against the next exact head and request focused independent re-review.
- **MATH-000 with Education** owns canonical equivalence across representations, known/unknown roles, families, seeds and sessions, the approved scope of exposure propagation, comparable replacement demand, retry and exhaustion eligibility, separate numerical/model outcomes, mastery prerequisites and retention policy.
- **IOS-001 with DATA-001** owns agreement on Codable and engine/version compatibility, occurrence and ink identities, safe presentation of only permitted fields, neutral accessibility and prompt replay, and validation before activation. Downstream iOS work verifies playback epochs, manual transitions and state restoration. DATA-003 owns durable exposure and submission transactions and recovery. Runtime proof and owner sample-slice approval remain downstream. No owner decision is needed to make the listed data corrections.
