# DATA-001 draft content contract

**Status** · Ready for Lead and independent review. Schema version 1 and fixture content version 0.1.0 are provisional. CUR-003 Education approval and Lead acceptance remain pending.

The draft implements D02, D03, D06–D09 and D11–D13. Inputs were the accepted CUR-002 inventory, IOS-001 architecture v1.3 (`ee22c70`), PD-001 (`bd0483f`) and the CUR-003 revision (`e37801e`). The fixture traces count, numeral matching and splitting to accepted objective and concept IDs. Its bounded targets cover quantities through 10 and report evidence at the target level.

## Documents and identity

[Schema](v1/content.schema.json) · [U07 fixture](../curriculum/fixtures/u07)

| Document | Purpose |
| --- | --- |
| Catalog | Source ID, printed page and item, accepted concept mapping, bounded targets and three separately typed relationships. Advisory edges express suggested order. Readiness probes name quantities and representations eligible for support. Component mastery edges reference bounded skills with prior or concurrent independent evidence. U07 has advisory and readiness edges. |
| Lesson | Stable activity, workspace, item, family, exposure, assistance and worksheet IDs. Activity kinds cover readiness, observation, guided practice and assessment. The initial manipulative combines counters and a linked bond. Whole and parts derive from the same named counter set. |
| Manifest | Package ID, content version, locale and minimum engine version. File sizes and SHA-256 digests bind local paths to bytes. Clip identity uses the pinned manifest, asset ID and clip version. Clip metadata includes transcript, measured duration and rights provenance. |
| Submission example | Pins the manifest hash and version, worksheet/version, stable slot, runtime occurrence and answer region. Includes an immutable item snapshot, confirmed input provenance, and ordered disclosure IDs as they stood at submission. Model evidence is separate and can remain pending. The synthetic evidence class illustrates the draft payload only. |

The six-counter narration folds typed actions from a fixed baseline in ascending `(atMs, order)`. At 3 seconds the bowl is part A and the tray is part B, linked as 6 = 2 + 4. At 4 seconds the active bond clears, both counters return in cue order and the completed bond remains available as a separate example. Manual captions use the same boundaries. The audio is a five-second silent PCM placeholder for integrity and timing checks. The fixture includes separate 7 = 1 + 6 guided practice and a fresh 8 = 3 + 5 independent check with learner-selected modelling. A reserved replacement has the same authored demand and a distinct exposure key. The answer and explanation are grading and feedback data. Present the prompt and known quantities alone until disclosure is authorized.

## Run checks

From the repository root, with Python 3.9 or newer:

```sh
python3 -m venv /tmp/juni-data001-venv
/tmp/juni-data001-venv/bin/python -m pip install jsonschema==4.25.1
/tmp/juni-data001-venv/bin/python tools/check_data001.py
/tmp/juni-data001-venv/bin/python tools/check_data001.py --package curriculum/fixtures/u07/package
git diff --check
```

Executed with Python 3.9.6 and jsonschema 4.25.1. Both checker invocations passed. The suite verified the schema, package bytes and clip length, CUR-002 anchors, separate dependency graphs, boundary and manual-step projections, guided partition, confirmed inputs and assisted/independent provenance. It rejected all 23 negative cases with their expected diagnostic categories. Each negative fixture mutates a named positive document so the exact fault is reviewable. The missing-audio case removes the file in a temporary package copy. The checker uses a provisional 64 MiB sum-of-file-sizes limit and validates one exact locale.

## Reconciliation before freeze

- **MATH-000 and Education.** Agree canonical equivalence across positions, representations, seeds and sessions, and verify the reserved replacement's comparable demand. Define retry eligibility, generic versus misconception routing, policy for identifying a sufficient model, solution feedback and exhaustion behavior. Establish generator and grader provenance for generated questions, diagnostic and retention eligibility, review intervals and mastery policy. Fixture keys and classes are authored examples. The validator does not infer mathematical equivalence from them or grade submissions.
- **IOS-001 and Education.** Agree Codable discriminators, supported schema and engine versions, package activation and migration, locale fallback, caption and reduced-motion rendering, and semantic gesture anchors. Agree stable worksheet, occurrence, answer-region and logical-coordinate identities, plus snapshot and ink reference compatibility. Agree how replacement-specific help and feedback are bound to an occurrence and how the runtime falls back to practice.
- **Joint with Lead.** Exercise U07 across replay, restoration, durable exposure before any delivery channel, feedback after commit and unavailable playback with manual progression. DATA-003 owns transactional storage and recovery mechanics. LEAD-002 owns interface freeze after reconciliation.

This run verified portable data and deterministic projections. App decoding, playback, recognition, accessibility, storage recovery and physical-device/offline behavior require downstream implementation and QA. The schema covers the U07 vertical slice. Additional activities, answer types, production narration and other unit content require later authoring and review.
