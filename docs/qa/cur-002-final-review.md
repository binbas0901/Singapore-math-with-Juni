# CUR-002 final independent Education review

19 November 2026 · Independent Education reviewer · Status **review**

**Recommendation.** M1–M3 and L1–L3 are resolved at the curriculum inventory level. Recommend Lead acceptance after a targeted wording correction makes acceptance of alternative correct strategies explicit in all six enrichment lesson assessment fields. The discrepancy predates the correction and has no effect on core mastery. The Lead owns disposition and acceptance.

**Revision reviewed.** `d77e434331e9f316b5182bc701a363a287310cb0`, compared with `fb39588c1012b980aebbd1b76df8df75631b9f1d`. The review covers the original findings, corrected JSON, coverage report, first-unit specification, blueprint, current ledger entry and both Lead comments. Applicable blueprint decisions are D02, D06, D07, D12 and D13. [Original review](cur-002-independent-review.md) · [Lead disposition](https://github.com/binbas0901/Singapore-math-with-Juni/pull/4#issuecomment-7029605195) · [Lead revision check](https://github.com/binbas0901/Singapore-math-with-Juni/pull/4#issuecomment-7029807875)

## Original findings

| Finding | Result | Independent Education verification |
|---|---|---|
| M1 | Resolved | L019 requires learners to produce or complete equations for joining and subtraction with the appropriate operation and equality signs. L020 requires completion of a true equation with expressions on both sides and evidence of equal value. L027 and L028 each require independent execution of the written algorithm on examples with and without regrouping, including alignment, exchanges where needed and the computed result. L046 requires applying both am and pm to familiar times and explicitly labels noon and midnight, with the day identified when relevant. The concept and lesson assessment fields agree for all five slots. |
| M2 | Resolved | MOE p. 32, 2D Shapes item 1.4 allows either grid. GEO-04 applies `any_linked_concept` to independent copying on a dot or square grid. Both formats remain available for practice and each has its own local readiness check. Neither format requires the other. Evidence from either alone or from both passed the data-rule check. Empty and unrelated evidence failed. |
| M3 | Resolved | The slot order is advisory. Small-set matching, pairing and bonds use evidence from the quantities in the task. Ordinal and ruler introductions use short lines or strips. Cent counting uses the actual denominations without a regrouping gate. Reading the hands begins without a number-pattern gate, and counting by fives is used at the clock-reading stage. The four remaining mastery links concern identifying ordinal positions before using ordinal notation, reading clock hands for five-minute times, and ruler use for measuring and drawing segments. Prior or concurrent independent evidence can establish each component. LEN-04 → LEN-01 summarizes the two ruler links without requiring a separate objective completion. |
| L1 | Resolved | L046 has the same target in the concept, slot and coverage row. The assessment includes one boundary-time instruction. |
| L2 | Resolved | TIM-03 requires using h and min. GEO-03 asks learners to identify component shapes. LEN-04-C01 asks learners to read a ruler directly to the nearest centimetre with an unambiguous endpoint. Shape wording introduces half circles alongside semicircles. |
| L3 | Resolved | Current JSON, coverage, first-unit header, blueprint and ledger record owner scope approval of **Numbers and Number Bonds to 10** on 2026-11-17. Education approval and CUR-002 acceptance remain pending. |

The first-unit checks are mathematically consistent. A whole of 6 with a known part of 2 leaves 4, and the fresh slice check of 8 with a known part of 3 leaves 5. I recalculated the session and mixed-review examples, including ascending and descending order, removal and the three unordered splits of 5 including zero. The unit records evidence within 0–10, preserving the distinction between introductory evidence and full-range objective mastery. Counters, diagrams and symbolic responses offer age-appropriate ways to show the same reasoning. Placement requires equivalent evidence, and scaffolding supports access to instruction.

Some readiness prompts sample the target skill directly, such as one-to-one pairing or tallying coins. Under the documented semantics these are quick diagnostic samples that can be scaffolded. At lesson authoring, use a small or assisted sample for readiness and a fresh independent example for mastery so the same performance does not serve both purposes.

## Remaining finding

**Low · Alternative strategies are explicit in six concept records and implicit in all six linked lesson slots.** At both reviewed revisions, each concept says to accept alternative correct strategies, while each lesson assessment says only “Explain a valid solution.” That wording permits alternatives, but a lesson author using only the slot loses the explicit acceptance criterion. Carry the criterion into each slot so valid evidence is evaluated against the mathematical task and its constraints.

| Slot | Alternative evidence to preserve when authoring |
|---|---|
| P1-E01 · Splits | Accept a systematic list or a counter-based demonstration that accounts for every unordered split. |
| P1-E02 · Number puzzle | Accept different ways to derive the missing values, with an explanation that respects all stated rules. |
| P1-E03 · Multi-step story | Accept different valid pairs of strategies when the learner explains the comparison. |
| P1-E04 · Equal groups | Accept different arrangements that preserve the specified equal groups and total. |
| P1-E05 · Composite picture | Accept different designs that meet the stated shape constraint. |
| P1-E06 · Picture graph | Accept different valid displays of the data and different answerable questions. |

These are illustrative rubric checks. The inventory has no authored enrichment items to execute.

## Checks executed and scope

- Recomputed SHA-256 on the previously downloaded MOE PDF outside Git. It matched the registered digest `e8f77fe10d768e2ad5266dfc39a8821674be7eb1c81bc545ba4b841b12ae70e1`. Extracted the printed pp. 31–32 with Poppler and matched all 32 page, strand, topic and item tuples, 19 on p. 31 and 13 on p. 32. Nested source references also matched.
- Ran a temporary Python audit against both Git revisions. Objective, concept and slot identities, source anchors, classifications, scope linkages and slot sequence were preserved. Verified 32 objectives, 59 core and six enrichment concepts, and 65 linked slots. The original review text was unchanged.
- Topologically sorted both prerequisite graphs. Objective edges changed from 36 to one and concept edges from 187 to four. Verified the objective summary matches the cross-objective concept links, core prerequisites precede their dependents in the advisory sequence, and 58 concepts have bounded readiness prompts.
- Reconciled all 97 Markdown rows with JSON and all 59 core assessment descriptions with their linked slots. Confirmed all six enrichment assessment discrepancies were pre-existing.
- Evaluated the declared evidence rules in the temporary audit. Either grid alone passed GEO-04, as did both together. Empty and unrelated evidence failed. All 31 other objectives still required every linked concept.
- Ran `git diff d77e434^ d77e434 --check` successfully. Engine grading, authored items, learner performance, device checks and rights clearance were outside this inventory review.

## Handoff

Lead should verify the wording correction across P1-E01–P1-E06 and record the CUR-002 disposition. CUR-003 Education review remains separate. This QA branch adds only this review report.
