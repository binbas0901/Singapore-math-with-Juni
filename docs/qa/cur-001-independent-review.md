# CUR-001 independent curriculum QA

**Reviewer** — Independent Curriculum QA, separate from the original research and same-session audit

**Review date** — 2026-11-19 (America/Denver)

**Status** — Review complete. CUR-001 remains in review for the Lead's decision.

**Recommendation** — Accept CUR-001 source verification. Correct the two low-severity register findings below when recording acceptance.

The review verified the curriculum source for D06 (P1–P6 coverage) and D13 (first P1 unit), with D01 and the blueprint's original-content requirements governing reuse. Evidence was checked against the [source register](../../references/source-register.md) and [previous audit](../CUR-QA-AUDIT.md).

## Provenance and file integrity

- The [MOE primary syllabus index](https://www.moe.gov.sg/primary/curriculum/syllabus) identifies the 2021 Primary 1–6 Mathematics syllabus as updated October 2025. [Corporation Primary School](https://www.corporationpri.moe.edu.sg/departments/mathematics/) links to the register's official media URL.
- An independent HTTPS download from the [register's MOE media URL](https://www.moe.gov.sg/api/media/92bff26d-b2b4-4535-b868-b8415c744b91/2021-Primary-Mathematics-Syllabus-P1-to-P6-Updated-October-2025.pdf) returned HTTP 200 and `application/pdf` (server response dated 2026-11-20 02:51:19 UTC, November 19 locally). The [index's current PDF link](https://www.moe.gov.sg/media/files/primary/92bff26d-b2b4-4535-b868-b8415c744b91.pdf) yielded an identical file by `cmp`. The shell download succeeded with network approval after sandbox DNS failed. Web preview returned a JavaScript challenge.
- The PDF signature and EOF marker passed. `pdfinfo` reported 50 pages, 806,004 bytes, PDF 1.7, unencrypted. `shasum -a 256` produced `e8f77fe10d768e2ad5266dfc39a8821674be7eb1c81bc545ba4b841b12ae70e1`, an exact match to the previously acquired copy's recorded SHA-256. This comparison uses the project's prior fingerprint and an independently retrieved official file.
- `pdftotext -layout` extracted all 50 pages. A page-by-page check confirmed sequential printed numbers and October 2025 footers on physical pages 2–50. The cover is physical page 1 and has no printed number. The contents entries resolve to the five named sections on pp. 3, 7, 17, 23 and 29. Pages 6, 16 and 22 carry footer text only in extraction. The level tables are continuous through the P6 Foundation material on p. 50. The PDF copies and extracted text are in local temporary storage outside Git.

## Applicability, pathways and strands

The publisher is Singapore's Ministry of Education. The cover identifies implementation beginning with the 2021 P1 cohort and credits the Curriculum Planning and Development Division. The October 2025 footers identify the revision. Footnotes on pp. 30 and 31 state that in 2025 the 2021 syllabus applied to P1–P5 while P6 used the 2013 syllabus. P6 moved to the 2021 syllabus from 2026, making it applicable to P1–P6.

Printed p. 4 specifies a common P1–P4 syllabus and assumes no prior formal mathematics learning. Standard continues that common syllabus at P5–P6. Foundation revisits selected P1–P4 concepts and skills, and its newly introduced material is a subset of Standard. The Standard tables have unqualified level headings and the Foundation tables are explicitly marked. Printed p. 30 establishes the three curriculum strands. The table records where each strand is listed.

| Level and pathway | Printed span | Number and Algebra | Measurement and Geometry | Statistics |
|---|---:|---:|---:|---:|
| P1 common | 31–32 | 31 | 32 | 32 |
| P2 common | 33–34 | 33 | 34 | 34 |
| P3 common | 35–36 | 35 | 36 | 36 |
| P4 common | 37–40 | 37–38 | 39 | 40 |
| P5 Standard | 41–42 | 41 | 42 | — |
| P6 Standard | 43–44 | 43 | 44 | 44 |
| P5 Foundation | 45–48 | 45–46 | 47 | 48 |
| P6 Foundation | 49–50 | 49 | 49 | 50 |

P5 Standard has no separately listed Statistics strand in its tables. The register's other section ranges also match the PDF. Pages 7–15 cover the mathematics curriculum and include the framework subsection on pp. 13–14. Pedagogy spans pp. 17–21 and assessment pp. 23–28.

## Copyright and register findings

The cover carries a 2025 copyright notice for the Curriculum Planning and Development Division. It permits reproduction of the entire publication for use that is both personal and non-commercial, prohibits sale, and reserves other rights. The [MOE website terms](https://www.moe.gov.sg/terms-of-use) recognize applicable statutory fair dealing and require prior written permission for commercial reproduction or reuse, subject to those exceptions. For Juni, retain the source privately, cite page references, and author original teaching material. Product bundling, redistribution, commercial rights and any use suggesting MOE endorsement are outside this source-verification recommendation.

| Finding | Severity | Evidence and disposition |
|---|---|---|
| Acquisition record needs the independent evidence | Low | The register accurately labels the first download failure as historical, but later says a separate direct download was unavailable and still lists independent QA as pending. Record this review, retrieval date, official index link and matching fingerprint. The legacy 404 remains owner-reported. |
| Rights wording and framework label | Low | The register uses “personal/noncommercial” where the cover requires both, and its acquisition entry calls the unnumbered cover “Page 1”. Use the exact conditions and distinguish the wider mathematics curriculum section (pp. 7–15) from its framework subsection (pp. 13–14). |

The register's substantive publisher, edition, rollout, pathways, strand names, level ranges and file fingerprint all check out. Standard as the default mapping track remains a project proposal. No owner decision is required to record this source verification. Any track scope decision belongs with the Lead and owner. Objective-level mapping, teaching quality, application tests and release rights clearance were outside this review.

**Lead handoff** — Review the evidence and record the CUR-001 acceptance decision. The project ledger separately records ENV-002's integration at `1206df736d6916c2da798aa35af10d1d1000f599`, verified against the local `origin/main` ref and the merge commit parents.
