# DATA-001 draft content contract

**Status** · DATA-001 is in review. CUR-003 v1.2 was accepted and integrated at `75f545c`, with metadata synchronized at `e518160`. The DATA-001 schema and engine contracts remain provisional.

The draft follows D02, D03, D06–D09 and D11–D13, the accepted CUR-002 inventory and CUR-003 unit specification, IOS-001 architecture v1.3 (`ee22c70`) and PD-001 (`bd0483f`). The U07/L016 fixture preserves the six-counter 6 = 2 + 4 split and recombination, the separate guided 7 = 1 + 6 partition and the independent 8 = 3 + 5 check with learner-selected modelling. The reserved 9 = 4 + 5 replacement illustrates comparable authored demand for review. The clip is a silent, five-second PCM development placeholder. [Schema](v1/content.schema.json) · [U07 fixtures](../curriculum/fixtures/u07)

## Authoring validation

| Area | Checks |
| --- | --- |
| Curriculum | Every package check compares catalog source ID, printed page, item, concept-to-objective mapping and concept classification with the accepted CUR-002 inventory. U07 binds the split target to P1-ADD-01-C01, preserves U06 → U07 → U08 as advisory order and rejects component mastery gates on the L016 split target. The readiness activity references the split target and matches the declared 6/7/8 probes for counting and numeral matching. The catalog supplies the probe representations. |
| Replay and guided practice | Cue projection conserves counters from the baseline, validates action order, checks the linked and completed bonds and verifies manual boundary states. Package validation exercises the guided move and link against the actual Try workspace's legal actions. U07 joins the chapter text in cue order and compares it with the clip transcript. Education checks what that text and the actual recorded speech mean at each state. |
| Question freshness | For the supported static missing-part shape, equal family ID, whole and known part must use the same exposure key within a package. Renaming the key or changing the item, wording or family-version label does not create a fresh candidate. Assessment candidates must have distinct keys and cannot be disclosed by earlier authored phases or one another's authored delivery. Cross-family equivalence and exposure across versions, representations, seeds and sessions remain provisional. |
| Worksheet and response | Each worksheet version allows one slot per item and one answer region per slot. A submission pins the exact worksheet, slot, answer region and item snapshot. Model counts and confirmed numeric responses yield separate draft outcomes for this fixture. `evidenceClass` describes response eligibility. A pending or incorrect model provides no model credit even when a response is independent and numerically correct. |

### Candidate delivery

The assessment's `assistanceIds` and `feedbackDisclosureIds` belong to its primary `itemId`. Every reserved replacement has its own entry in `replacementDeliveries`, with explicit assistance and feedback arrays. Each help step names its item. The guided-action template renders `{knownPart}` from that exact item snapshot. It renders 3 for the original and 4 for the replacement. Task-specific help and feedback disclose only their candidate's key. Reteach may additionally link a declared worked example. Neutral retries carry no disclosure metadata. Feedback uses only the committed candidate's feedback references and explanation.

A submission keeps `deliveredAssistanceIds` for the active occurrence separate from `exposureAtSubmit`, which can include relevant prior work. The checker rejects help assigned to another candidate and requires the current help's disclosures in the frozen exposure snapshot. Original help can precede a distinct eligible replacement. Whether earlier feedback also leaves the replacement eligible depends on the reviewed scope of that disclosure. Task-specific help on the replacement makes its submission assisted. If the learner requests help and the active item has no valid help, route the item to practice using `deliveryMode: practice` and assisted evidence. When the original has already been submitted, later feedback never rewrites its frozen result.

### Required Education and rights review

A bundled manifest requires an external independent Education approval record with `manifestSha256` and a nonempty `reviewRef`. Provide it with `--education-review`. Keep the record outside the package. The checker verifies the pin and presence of the reference. The release reviewer verifies the record's provenance and approval against the exact manifest before handing it to the packager. A content or asset change invalidates the prior pin.

Education must review every candidate's prompt and retry for answer neutrality, comparable demand and correct quantities. Review learner-visible representations, spoken narration, transcripts, captions, manual steps, accessibility labels and announcements, replay and alternate delivery channels against the intended state. Check feedback and disclosures for applicability, including answers that carry over between candidate questions. The bundled review gate invalidates stale approval for any copy change. It cannot decide whether free text gives away an answer or whether recorded speech matches the script. Any production asset also needs independently verified rights provenance. A manifest's `cleared` field is an assertion for that reviewer.

## Runtime records and limits

The item occurrence binds the local session, pinned content (package ID, version, locale and manifest digest), lesson/activity, exact item ID/version and snapshot, worksheet ID/version and slot. An attempt binds that occurrence, attempt ordinal and answer region. Confirmed handwriting additionally binds the immutable ink revision in that region and its confirmed value. [Synthetic linked records](../curriculum/fixtures/u07/runtime-links.json) illustrate the occurrence and ink join.

A standalone submission check validates authored references and internal consistency. The application must match the snapshot against actual persisted occurrence, attempt, ink and delivery records. It must commit exposure before any revealing delivery, freeze the attempt before feedback and preserve the original evidentiary record across retries, replacements and restarts. It must verify observable model evidence before recording an observed model. For this static fixture, the model outcome compares the observed whole and unordered parts with the frozen item. Physical modelling, independent observation, drawing interpretation, mastery credit and persistence need downstream verification.

## Packaging and versioning

Schema version identifies the wire format. Minimum engine version identifies required reader behavior. Content version identifies immutable authored bytes within a package and locale. The checker currently supports schema 1, engine 1, one exact locale and a provisional 64 MiB listed-file limit. This revision updates the provisional schema 1 draft and bumps the fixture content to 0.1.1. Earlier draft payloads require reauthoring or an explicit migration before use.

After a package is issued, retain its exact manifest and bytes for existing evidence pins. Publish edited bytes with a new content version and manifest digest. Keep stable IDs for the same entity across versions. Bump individual versions where supported when changing item semantics, worksheet slot or region identity, cue semantics or clip bytes. Give a genuinely different entity a new ID. Preserve interpretation of old submissions through pinned snapshots or an explicit migration and retain original provenance. An incompatible published format change requires a schema version decision. New reader behavior requires a minimum engine version decision.

For a distributable package, run the following command to emit the file allowlist. The packager copies only emitted paths and runs the same package validation against the actual staged bundle before handoff. The checker rejects extra physical files, symlinks, mismatched hashes, unreferenced file records and placeholder rights in bundled mode.

```sh
/tmp/juni-data001-venv/bin/python tools/check_data001.py --package "$bundle_path" --education-review "$review_path" --bundle-file-list
```

PCM WAV is the supported authoring format in this draft. The checker reads complete mono or stereo integer PCM frame data, rejects unsupported formats and incomplete frames, and verifies the declared duration from the decoded frame count and sample rate. Device playback and actual audio-to-script alignment remain downstream.

## Run checks

From the repository root with Python 3.9 or newer:

```sh
python3 -m venv /tmp/juni-data001-venv
/tmp/juni-data001-venv/bin/python -m pip install jsonschema==4.25.1
/tmp/juni-data001-venv/bin/python tools/check_data001.py
/tmp/juni-data001-venv/bin/python tools/check_data001.py --package curriculum/fixtures/u07/package
git diff --check
```

The suite retains the 23 original negative mutations and adds candidate-delivery, question-signature, review-pin, readiness, worksheet, evidence, runtime-link and bundle probes. The runtime-link cases use synthetic records. The answer-bearing prose cases test stale approval, and the caption case tests drift from the transcript. The bundle case switches fixture metadata in a temporary directory to exercise the checker and confers no production rights or Education approval.

## Reconciliation before freeze

MATH-000 and Education still own canonical cross-family equivalence, demand comparability, exposure propagation, retry and exhaustion rules, learning thresholds, retention intervals and mastery policy. IOS-001 and DATA-003 still own serialization alignment, durable exposure and attempt transactions, activation and recovery. Physical iPad, offline completion, recognition, accessibility and playback checks remain downstream. DATA-001 requires focused independent re-review before acceptance. LEAD-002 owns the interface freeze.
