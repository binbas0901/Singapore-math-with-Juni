# Singapore Math with Juni --- Project Status

**Version:** 1.20 \| **Baseline:** 2026-11-17 \| **Maintainer:** Lead agent \| **Current milestone:** M0 / Sprint 0

## 1. Executive status

Target: one complete P1 learning unit, offline native iPad private beta, preceded by a reviewed vertical slice. D01--D13 and agent-driven delivery remain binding. This ledger is the operational state record, not an independent change to the roadmap or blueprint.

**34 tasks: 3 review, 1 ready, 24 backlog, 0 in progress, 0 blocked, 6 accepted.** No milestone gate has been accepted. ENV-001 is integrated into main at `a2954204d7edacf8f05241e3af18bf210f12f6ef`. The Lead accepted ENV-002 after independent QA verified the native iPad scaffold in the simulator. PR #2 was integrated into main at `1206df736d6916c2da798aa35af10d1d1000f599`. CUR-001 was accepted after independent source QA and integrated through PR #3 at `e546204882c4f8d12af0fca758bbf9b218d766b0`. CUR-002 accepted and integrated through PR #4 at `49cbfcaaf167940d367812e9db331739eca43bfc`. CUR-003 first-unit specification accepted and integrated through PR #7 at `75f545c9f55ab1439f3e27137049fb07cb3874e2`; owner sample-slice approval and authored lesson verification remain pending. CUR-004 is ready; DATA-001 is in review at PR #9, with independent QA corrections required (report 269f927, preserved in PR #9 at f7649f3), and MATH-000 is in review at draft PR #12. IOS-001 architecture v1.3 document baseline accepted after independent re-review; task remains review pending DATA-001/MATH-000 reconciliation. Physical-device readiness remains open.

## 2. Source baseline and evidence

The following local files were read to initialize this ledger. Hashes identify the exact source versions; repository paths and commits remain unassigned.

  ----------------------------------------------------------------------------------------------------------------------------------------------
  Source                          SHA-256                                                              Review state
  ------------------------------- -------------------------------------------------------------------- -----------------------------------------
  `PROJECT_BLUEPRINT.md` v1.0     `d16eca8a32618b8b95f72029654144ab017a226b67c153b438fa5dff10f8e147`   Produced; baseline approved by owner 2026-11-17

  `AGENTS.md` v1.0                `b31dc0693dc85830e81fdfc17ae5439db56170d23bec6db359efa6b64fa2357d`   Produced; baseline approved by owner 2026-11-17

  `DEVELOPMENT_ROADMAP.md` v1.0   `aa2d3e7112ab583f15143fbe88c3cdcacd626191fecb6755121ca426ccb8700f`   Produced; baseline approved by owner 2026-11-17
  ----------------------------------------------------------------------------------------------------------------------------------------------

Validation executed during initialization: parsed all 34 unique roadmap task IDs, checked that all referenced dependencies exist, and confirmed the blueprint contains D01--D13. This is a structural check, not educational review or an engineering test. No official curriculum verification was performed during initialization; subsequent research is recorded below.

## 3. Complete task ledger

States: backlog, ready, in progress, review, blocked, accepted. Ready means dependencies allow dispatch, not that a session is running. Draft-sufficient exceptions are explicitly inherited from the roadmap. Accountable role is not an assigned live agent. For **every row**, session, branch, commit, actual tests, reviewer identity and acceptance evidence are unassigned/not run unless recorded in section 4. Deliverable paths are targets, not assertions of existence. Acceptance criteria below are inherited verbatim from the roadmap.

### M0 / Sprint 0

  --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Task       State      Owner / reviewer   Dependencies                  Target deliverable                             Acceptance criteria                                                                                                                                               Next action
  ---------- ---------- ------------------ ----------------------------- ---------------------------------------------- ----------------------------------------------------------------------------------------------------------------------------------------------------------------- ----------------------------------------------------------------
  LEAD-001   accepted   Lead / Owner       None                          docs/ --- blueprint, AGENTS, roadmap, status   All 13 decisions present; references consistent; status ledger initialized; owner review recorded.                                                                Owner approved baseline in current conversation.

  ENV-001    accepted   Release / Lead     LEAD-001 (draft sufficient)   docs/environment.md; repository setup plan     Check actual Codex access, Git permissions, Mac/Xcode and iPad; record versions, costs, blockers and signing path; obtain authorization before remote creation.   Lead independently reviewed and accepted the evidence. Integrated into main at `a2954204`.

  ENV-002    accepted     Release / QA       ENV-001                       app/ build skeleton; CI configuration          Authorized repo initialized; clean checkout builds and runs a smoke test on macOS; exact commands and logs recorded; no secrets committed.                        Lead accepted after [independent QA review](qa/env-002-independent-review.md).
  --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

### M1 / Sprint 1

  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Task       State      Owner / reviewer         Dependencies                  Target deliverable                                   Acceptance criteria                                                                                                                                       Next action
  ---------- ---------- ------------------------ ----------------------------- ---------------------------------------------------- --------------------------------------------------------------------------------------------------------------------------------------------------------- ---------------------------------------------------
  CUR-001    accepted   Curriculum / QA          LEAD-001 (draft sufficient)   references/source-register.md                        Retrieve official MOE syllabus; verify edition and applicability, URL, date, page references, checksum if bytes available; flag missing sources.          Lead accepted independent QA; integrated through PR #3 at e546204.

  CUR-002    accepted   Curriculum / Education   CUR-001                       curriculum/p1/objectives.json; docs/coverage-p1.md   All P1 objectives mapped to stable IDs, source pages and strands; explicit gaps, prerequisites and core/enrichment distinctions; independent check.       Lead accepted after independent re-review; six enrichment slot wording corrections verified.

  CUR-003    accepted  Curriculum / Education   CUR-002                       docs/first-unit.md                                   Propose number-sense/number-bond unit with verified ranges and prerequisites; map each objective to teaching/practice/assessment; owner approves scope.   Owner scope approved; independent re-review 421a8da and L1 clarification accepted; integrated 75f545c.

  CUR-004    ready      Curriculum / QA          CUR-001                       curriculum/p2--p6/; docs/CURRICULUM_MASTER.md        Map remaining levels with provenance and completeness report; may run alongside implementation; no requirement to finish before private beta.             Eligible following CUR-001 integration; prioritize P1 review.
  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

### M2 / Sprint 2

  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Task       State      Owner / reviewer              Dependencies                  Target deliverable                         Acceptance criteria                                                                                                                                                            Next action
  ---------- ---------- ----------------------------- ----------------------------- ------------------------------------------ ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ ----------------------------------------------
  IOS-001    review      iOS / Lead                    LEAD-001                      docs/ARCHITECTURE.md                       Define modules, state transitions, dependency boundaries, deployment target proposal and offline threat model; reconcile with DATA-001 and MATH-000.                           Independent re-review at 6d656d7; R1/R2 resolved in architecture v1.3; document baseline accepted, task acceptance pending DATA-001/MATH-000 reconciliation.

  DATA-001   review     Data / iOS                    CUR-002, IOS-001 draft        schemas/; curriculum/fixtures/             Versioned schema for lesson/activity/objective/media/manifest; good and bad fixtures; references and prerequisite graph validated.                                             Agent D1–D5 corrections at ff71de3 in PR #9; author reports 9 valid and 53 invalid cases pass, pending focused independent re-review and Education semantic review. Original report 269f927 preserved.

  MATH-000   review     Math / Education              CUR-003, DATA-001 draft       docs/mastery-contract.md                   Specify deterministic grading, seeds, evidence and proposed thresholds; assisted/independent distinction; recognition uncertainty neutral; owner review for learning policy.   Independent Education/Math QA 72d370c requests F1–F7 corrections, especially finite item-pool retention, evidence thresholds, model sufficiency and exposure mappings. Preserved in draft PR #12 at 4363e6f; owner approvals pending.

  LEAD-002   backlog    Lead / QA                     IOS-001, DATA-001, MATH-000   docs/contracts.md; task path assignments   Freeze initial interfaces; verify all fixture contracts agree; approve reversible defaults and isolate parallel branches.                                                      Wait for listed dependencies; then dispatch.

  EDU-001    backlog    Education / Curriculum + QA   CUR-003, DATA-001             curriculum/p1/vertical-slice/              One original CPA lesson, narration transcript, independent check, misconceptions, feedback and enrichment; verify every answer and objective link.                             Wait for listed dependencies; then dispatch.
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

### M3 / Sprint 3

  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Task           State      Owner / reviewer               Dependencies        Target deliverable                          Acceptance criteria                                                                                                                                                                              Next action
  -------------- ---------- ------------------------------ ------------------- ------------------------------------------- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ ----------------------------------------------
  DATA-002       backlog    Data / QA                      LEAD-002            tools/validate_content.py; tests/content/   CLI rejects duplicate IDs, cycles, invalid references, missing media, unsupported versions and malformed items; documented reproducible test command.                                            Wait for listed dependencies; then dispatch.

  IOS-002        backlog    iOS / QA                       LEAD-002, ENV-002   app/ lesson shell and navigation            Load fixture lesson; pause/resume/replay; invalid packages fail safely; no network dependency; build and unit tests pass.                                                                        Wait for listed dependencies; then dispatch.

  IOS-003        backlog    iOS / QA                       LEAD-002, ENV-002   app/ workbook and recognition adapter       PencilKit save/erase/reopen; local recognition feasibility spike with synthetic numeric samples; uncertain answers confirmed; keypad always available; report actual device/model limitations.   Wait for listed dependencies; then dispatch.

  IOS-004        backlog    iOS / Math                     LEAD-002, ENV-002   app/ reusable math views                    Counting, number representation and number bonds maintain correct state; touch alternatives and labels; fixture tests.                                                                           Wait for listed dependencies; then dispatch.

  MATH-001       backlog    Math / QA                      LEAD-002            app/ domain math and mastery; tests/math/   Seeded generation reproducible; bound/equivalence tests; no false mastery from hints or retries; review scheduling fixtures.                                                                     Wait for listed dependencies; then dispatch.

  DATA-003       backlog    Data / QA                      LEAD-002, ENV-002   app/ persistence module                     Transactional local evidence and workbook metadata; migration and interruption/restart tests; no accounts or external writes.                                                                    Wait for listed dependencies; then dispatch.

  CREATIVE-001   backlog    Creative / Education + Owner   EDU-001             assets/; audio/; media manifest             Moon-only mascot prototype, transcripts, local audio playback assets; owner brand approval and rights ledger; paid production only after budget authorization.                                   Wait for listed dependencies; then dispatch.

  IOS-005        backlog    iOS / QA                       LEAD-002, ENV-002   app/ media playback                         Local narration replay, transcripts and graceful missing-asset state; no runtime speech generation; tests with placeholder assets.                                                               Wait for listed dependencies; then dispatch.
  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

### M4 / Sprint 4

  ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Task       State      Owner / reviewer   Dependencies                                                                              Target deliverable                         Acceptance criteria                                                                                                                                                                Next action
  ---------- ---------- ------------------ ----------------------------------------------------------------------------------------- ------------------------------------------ ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ----------------------------------------------
  IOS-006    backlog    iOS / Lead         IOS-002, IOS-003, IOS-004, IOS-005, MATH-001, DATA-003, EDU-001, DATA-002, CREATIVE-001   app/ integrated lesson; packaged fixture   Complete concrete/pictorial/abstract flow as appropriate; confirmed answer updates evidence; resume after restart; replay works offline.                                           Wait for listed dependencies; then dispatch.

  IOS-007    backlog    iOS / QA           DATA-003, MATH-001, IOS-002                                                               app/ parent dashboard                      Parent-protected local history, concept evidence, next recommendation and settings; synthetic fixture totals reconcile; no remote sync.                                            Wait for listed dependencies; then dispatch.

  QA-001     backlog    QA / Lead          IOS-006, IOS-007                                                                          docs/qa/vertical-slice.md                  Independent answer/pedagogy checks, integration tests, airplane-mode and physical-device evidence where available; record device blockers; owner accepts slice before expansion.   Wait for listed dependencies; then dispatch.
  ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

### M5 / Sprint 5

  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Task           State      Owner / reviewer              Dependencies                                Target deliverable                        Acceptance criteria                                                                                                                                            Next action
  -------------- ---------- ----------------------------- ------------------------------------------- ----------------------------------------- -------------------------------------------------------------------------------------------------------------------------------------------------------------- ----------------------------------------------
  EDU-002        backlog    Education / Curriculum + QA   QA-001, CUR-003                             curriculum/p1/first-unit/                 All approved lessons authored and reviewed; each target has instruction, practice and independent assessment; remediation and advanced enrichment separated.   Wait for listed dependencies; then dispatch.

  MATH-002       backlog    Math / QA                     EDU-002, MATH-001                           app/ unit generators; tests/math/         Every item family covered by deterministic and boundary tests; assessment items not answer-revealing; no ambiguous answers.                                    Wait for listed dependencies; then dispatch.

  CREATIVE-002   backlog    Creative / Education          EDU-002, CREATIVE-001                       assets/; audio/; rights register          Approved voice/illustrations for all required lessons; transcript matches audio; licensed, local and referenced; no placeholder production narration.          Wait for listed dependencies; then dispatch.

  DATA-004       backlog    Data / QA                     EDU-002, CREATIVE-002, MATH-002, DATA-002   tools/package_content.py; unit manifest   Reproducible versioned package; validation passes; checksum and coverage report emitted; unsupported packages rejected.                                        Wait for listed dependencies; then dispatch.

  IOS-008        backlog    iOS / QA                      DATA-004, QA-001                            app/ unit navigation and placement        Recommended path, allowed exploration, placement and retention review operate with local evidence; no forced mastery or missing prerequisites.                 Wait for listed dependencies; then dispatch.
  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

### M6 / Sprint 6

  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Task       State      Owner / reviewer   Dependencies                          Target deliverable             Acceptance criteria                                                                                                                                             Next action
  ---------- ---------- ------------------ ------------------------------------- ------------------------------ --------------------------------------------------------------------------------------------------------------------------------------------------------------- ----------------------------------------------
  QA-002     backlog    QA / Lead          IOS-008, IOS-007, DATA-004, ENV-002   docs/qa/release-candidate.md   FR01--FR12 traceability; full unit in airplane mode on physical iPad; restart recovery, accessibility, recognition error recovery and parent totals checked.    Wait for listed dependencies; then dispatch.

  REL-001    backlog    Release / QA       QA-002                                docs/release-checklist.md      Verify rights, privacy and signing; no secrets or unnecessary telemetry; clean install and upgrade tests; authorized private distribution mechanism selected.   Wait for listed dependencies; then dispatch.

  LEAD-003   backlog    Lead / Owner       REL-001                               docs/release-approval.md       No unresolved release-blocking defects; all gates evidenced; owner approval for installation/distribution.                                                      Wait for listed dependencies; then dispatch.
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

### M7 / Sprint 7

  -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Task       State      Owner / reviewer         Dependencies   Target deliverable              Acceptance criteria                                                                                                                                                    Next action
  ---------- ---------- ------------------------ -------------- ------------------------------- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- ----------------------------------------------
  REL-002    backlog    Release / Owner          LEAD-003       signed build; docs/install.md   With authorization, install on target iPad directly or via private TestFlight; record build version and actual installation evidence.                                  Wait for listed dependencies; then dispatch.

  QA-003     backlog    QA / Education + Owner   REL-002        docs/beta-feedback.md           Observe child usability only with parent consent; record anonymized observations and remediation backlog; no uploads of handwriting or identifiers without approval.   Wait for listed dependencies; then dispatch.

  LEAD-004   backlog    Lead / Owner             QA-003         docs/next-release-plan.md       Review learning feedback and defect priorities; owner decides whether to expand to full P1; no automatic public release.                                               Wait for listed dependencies; then dispatch.
  -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## 4. Execution and evidence records

  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Task        Session / branch                                          Artifact evidence                                                               Checks executed                                                              Reviewer / decision      Next action
  ----------- --------------------------------------------------------- ------------------------------------------------------------------------------- ---------------------------------------------------------------------------- ------------------------ -----------------------------------------
  LEAD-001    Current ChatGPT document-generation turn; no Git branch   PROJECT_BLUEPRINT.md, AGENTS.md, DEVELOPMENT_ROADMAP.md, PROJECT_STATUS.md      34 unique IDs, dependency references and D01--D13 structural checks passed   Product owner; approved 2026-11-17   Accepted

  CUR-001     Local Codex / task/CUR-001-source-review                    [Source register](../references/source-register.md); [independent QA](qa/cur-001-independent-review.md)     Independent official download, matching SHA-256, 50 pages, level and pathway anchors, rights notice     QA passed; Lead accepted     CUR-002 review after integration

  ENV-001     Local Codex / task/ENV-001-environment                    environment.md                                                                  Toolchain, GitHub read access, two passing XCTest cases, iPad (A16) boot, physical-device and signing inventories       Lead; accepted after independent review    Integrated at `a2954204`
  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

ENV-002 ran in local Codex on `task/ENV-002-ipad-scaffold`. The [verification record](qa/env-002.md) contains the clean build, simulator install and launch, screenshot, and unit and UI test results. The [independent QA report](qa/env-002-independent-review.md) reproduces the clean build, two host unit tests, the simulator launch and rotation test, and the direct install and launch. The Lead accepted the scaffold on that evidence.

## 5. Immediate dispatch queue

  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Priority       Task                 Mode                                       Dispatch condition                                           Required handoff
  -------------- -------------------- ------------------------------------------ ------------------------------------------------------------ ----------------------------------------------------------------------------------------------------
  1              LEAD-001             Owner review                               Four foundation artifacts available                          Recorded approval or findings

  2              CUR-001              Accepted; integrated                       Independent QA and Lead acceptance recorded                  PR #3 merged at e546204

  3              ENV-002              Integrated                                 PR #2 merged to main                                         Merge commit `1206df736d6916c2da798aa35af10d1d1000f599`

  4              IOS-001              Architecture                               LEAD-001 accepted                                            Architecture draft and interface boundaries

  5              CUR-002 / CUR-004    Curriculum; parallel eligible              CUR-001 accepted                                             P1 inventory / wider P2--P6 inventory; independent review

  6              CUR-003 / DATA-001   Design                                     Their respective dependencies accepted or draft sufficient   Approved unit / schema fixtures
  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

ENV-002 was dispatched after ENV-001 merged into main and is accepted and integrated into main. The curriculum and architecture reviews retain their existing dependencies.

### Dispatch brief template

``` text
Task ID / role / reviewer:
Read: PROJECT_BLUEPRINT.md, AGENTS.md, DEVELOPMENT_ROADMAP.md, PROJECT_STATUS.md
Objective / decisions / FR references:
Dependency evidence (including approved draft exceptions):
Session / branch / allowed paths:
Deliverables / acceptance criteria (copy ledger):
Tests / independent review:
Permissions / budget:
Report: outputs, actual checks, missing checks, findings, blockers, next action.
```

## 6. Milestone and quality-gate register

  ------------------------------------------------------------------------------------------------------------------
  Milestone               Status                  Evidence still required
  ----------------------- ----------------------- ------------------------------------------------------------------
  M0                      In progress             LEAD-001 accepted, environment plan

  M1                      Pending                 Official source, P1 coverage, approved unit

  M2                      Pending                 Architecture, schema, mastery contracts, reproducible build path

  M3                      Pending                 Reviewed core modules and tests

  M4                      Pending                 Integrated lesson, QA and owner slice approval

  M5                      Pending                 Complete reviewed and packaged unit

  M6                      Pending                 Device, accessibility, privacy, licensing and recovery evidence

  M7                      Pending                 Authorized install, feedback, next-release decision
  ------------------------------------------------------------------------------------------------------------------

  Gate                         Status    Evidence owner
  ---------------------------- --------- -----------------------------
  G0 Specification             Pending   Lead / Owner
  G1 Curriculum                Pending   Curriculum / Education / QA
  G2 Content                   Pending   Data / QA
  G3 Engineering               Pending   iOS / Math / Data / QA
  G4 Learning experience       Pending   Education / iOS / QA
  G5 Offline and persistence   Pending   iOS / Data / QA
  G6 Device and release        Pending   Release / QA / Owner

## 7. Risks, dependencies and owner decisions

  ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ID                Open item                                                     Impact                                                               Owner / next action
  ----------------- ------------------------------------------------------------- -------------------------------------------------------------------- ----------------------------------------
  R01               Official PDF independently verified; Lead accepted                 Source verification resolved; commercial rights remain open                    Curriculum: CUR-002; release rights review

  R02               Local Codex and authenticated GitHub read access verified   Main branch protection behavior untested                         Release verification in environment.md

  R03               Mac/Xcode and simulator startup verified. Physical iPad and development signing unavailable in this check   Blocks physical-device acceptance   Release: ENV-001/002

  R04               First unit specification accepted                         Owner sample-slice approval and authored lesson verification pending                                         Curriculum: CUR-003

  R05               Mastery thresholds and recognition feasibility unvalidated    Learning accuracy risk                                               Math: MATH-000; iOS: IOS-003

  R06               Final mascot, voice rights and production budget pending      Blocks approved production media                                     Creative: CREATIVE-001/002

  R07               Public naming, child privacy and cloud compliance pending     Blocks public release, not offline beta                              Lead: separate future review
  ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

No confirmed hard blocker is recorded yet; these are open prerequisites and risks. No budget or deadline has been approved. Owner decisions due now: baseline review only. Environment expenses, unit scope, learning policy, brand and release approvals become due at the relevant gates.

## 8. Operating rules and update log

Lead updates this ledger after actual dispatch, artifact production, review or dependency change. Record timestamp, task ID, prior/new state, session and branch, artifact/commit links, executed test results, reviewer, findings, blocker and next action. Never mark accepted without evidence and required reviewer approval. Blocked means a concrete impediment has been established; unmet normal dependencies remain backlog. Recompute counts and ready queue on each update. Apply roadmap dependencies, path ownership and G0--G6; record discrepancies rather than silently revising scope. No child identifiers or credentials in logs or Git. Keep source documents synchronized through approved change control.

  ------------------------------------------------------------------------------------------------------------------------------------------------
  Date                    Event                                                 Result
  ----------------------- ----------------------------------------------------- ------------------------------------------------------------------
  2026-11-17              Ledger initialized from three v1.0 source documents   LEAD-001 review; CUR-001 and ENV-001 ready; remaining 31 backlog

  ------------------------------------------------------------------------------------------------------------------------------------------------

## 9. Baseline limitations and reconciliation

No external agents have been launched. No remote repository exists as verified evidence in this session. CUR-001 provenance is now partially verified and documented; full-file acquisition complete; independent review remains pending. Architecture and curriculum master documents are pending (IOS-001 and CUR-004 respectively). The roadmap's early architecture draft and later reconciliation with schema/mastery contracts are interpreted as iterative design; no final contract freezes until LEAD-002. P2--P6 mapping remains parallel, not a private-beta gate. The roadmap task-level dependencies and reviewers govern scheduling; AGENTS.md remains authoritative for operating standards. If any substantive conflict emerges, halt the affected task and seek resolution.

## 10. Execution update — 2026-11-17 (v1.1)

Owner explicitly approved foundation baseline; LEAD-001 accepted. CUR-001 executed in this ChatGPT session: official MOE indexed PDF pages 4 and 30 confirm October 2025 edition and 2026 P1–6 applicability. `source-register.md` created (repository target `references/source-register.md`). Direct open returned anti-bot challenge, download failed and shell retry could not resolve host. No PDF or checksum obtained. CUR-001 remains in review pending full acquisition and independent QA; CUR-002 and CUR-004 remain backlog. IOS-001 and ENV-001 ready. No external sessions, commits or repository modifications. Current dispatch order: resolve CUR-001 acquisition and QA, proceed independently with ENV-001 and IOS-001. This update supersedes historical queue statements above.

## 11. Execution update — 2026-11-17 (v1.2)

Owner supplied original 50-page PDF from replacement official URL. SHA-256 `e8f77fe10d768e2ad5266dfc39a8821674be7eb1c81bc545ba4b841b12ae70e1`; 806004 bytes. Source register v1.1 records acquisition, edition, page ranges and rights restrictions. CUR-001 remains review pending independent QA; acquisition impediment resolved. Preliminary CUR-002 inventory `P1_OBJECTIVES_DRAFT.json` contains 32 unique source-linked entries (19 on p31, 13 on p32), count checked against PDF text. This is preparatory work only, not formal dispatch or acceptance; prerequisites and independent educational review remain pending. Ledger states/counts unchanged. No external agents or repository commits. Next: independent CUR-001 QA, then formal CUR-002 mapping and CUR-004. ENV-001 and IOS-001 remain ready.

## 12. Execution update — 2026-11-17 (v1.3)

Owner explicitly requested CUR-001 QA and CUR-002 mapping in parallel. CUR-001 internal quality recheck passed: uploaded PDF hash matches register, 50 pages, 806004 bytes, edition and scope checked. Independent QA remains open, so CUR-001 stays review. CUR-002 moved backlog → review for preparatory mapping at owner request; formal acceptance remains gated on CUR-001 and independent Education review. Outputs: `objectives.json` (repository target `curriculum/p1/objectives.json`), `coverage-p1.md` (target `docs/coverage-p1.md`), updated `source-register.md`. Source page/item multiset check passed (32 entries); unique IDs, all 65 concept links and topological prerequisites passed. 59 core slots and 6 enrichment slots are proposed, not approved or authored. No external agent, branch or commit; all checks performed in current session. CUR-003 and CUR-004 remain backlog; ENV-001 and IOS-001 ready. Current states: 1 accepted, 2 review, 2 ready, 29 backlog. Next: independent QA and educational sign-off, then CUR-003 first-unit scope.

## 13. Execution update — 2026-11-17 (v1.4)
CUR-001 and CUR-002 second-pass audit completed in same session; see CUR-QA-AUDIT.md. CUR-001 and CUR-002 remain review, separate reviewers pending. CUR-003 backlog → review for preparatory specification under explicit owner request; dependencies not waived. first-unit.md proposes 11 core sessions plus optional puzzle, six partial objectives, assessment matrix and U07 vertical slice. Updated objectives.json, coverage-p1.md and source-register.md. No external agent, branch or commit. Current counts: 1 accepted, 3 review, 2 ready, 28 backlog. Ready: ENV-001, IOS-001. Gates: separate QA, Education review, owner scope approval; later schema/mastery, device and release gates unchanged. This update supersedes historical queue and status statements.

## 14. Execution update — 2026-11-17 (v1.5)
Owner approved CUR-003 unit scope; remains review pending Education and upstream acceptance. ENV-001 ready → blocked: local tools confirmed; no authenticated remote Codex/GitHub or macOS build host available. environment.md and CODEX_TASKS.md produced. IOS-001 ready → review: architecture v1.1 records owner approval, draft module boundaries, offline threat model and verification gates; Lead review and later schema/mastery reconciliation outstanding. Local bootstrap only, no external agent launched. Current totals: 1 accepted, 4 review (CUR-001/002/003, IOS-001), 1 blocked (ENV-001), 28 backlog, 0 ready/in progress. This section supersedes historic queues. Next: owner connects GitHub/Codex, separate QA/Education reviewers, then dispatch eligible tasks. Do not waive gates.

## 15. Execution update — 2026-11-18 (v1.6)

ENV-001 moved from blocked to review on `task/ENV-001-environment` at base commit `f1fc6b1`. Verified the local Codex CLI and session, macOS and Xcode with device and simulator SDKs, and Git, Python and Node.js. Authenticated GitHub read access succeeded against the existing private origin, and GitHub reported ADMIN viewer permission. The macOS JuniCore suite passed both XCTest cases.

Xcode reported no installed simulator runtime or available simulator devices. No physical device or valid signing identity was detected. The repository contains a Swift package and has no native app target. Native app build, signing and physical iPad/stylus verification remain open. See [environment evidence](environment.md) for commands and results. Lead review is pending. ENV-002 remains backlog, gated on ENV-001 acceptance.

## 16. ENV-001 follow-up — 2026-11-19 (v1.7)

CoreSimulator listed six available iPads on iOS 26.3 (runtime build version 26.3.1, build 23D8133). The iPad (A16) completed startup in 1 minute 21 seconds and appeared as Booted. Both JuniCore XCTest cases passed again on macOS. The physical-device inventory was empty and the signing check found zero valid identities. The native app target, development signing and provisioning, and physical iPad and stylus verification remain outstanding.

Release Engineering recommends accepting ENV-001 as an environment verification once the Lead reviews the evidence in [environment.md](environment.md). The task stays in review and ENV-002 stays in backlog pending that decision.

## 17. ENV-001 Lead acceptance (v1.8)

The Lead independently reviewed GitHub commit [`c244cb3f205e19c1a2a94cd65b1afb5ee45bfcff`](https://github.com/binbas0901/Singapore-math-with-Juni/commit/c244cb3f205e19c1a2a94cd65b1afb5ee45bfcff) and accepted ENV-001. ENV-002 moved from backlog to ready. Dispatch awaits confirmation that ENV-001 is integrated into main.

The native app build and install, authorized Apple development team, valid signing identity and matching provisioning profile remain downstream requirements. Physical iPad, iPadOS and stylus compatibility and device testing remain open.

## 18. ENV-002 execution (v1.9)

Release Engineering confirmed ENV-001 integration at `a2954204d7edacf8f05241e3af18bf210f12f6ef`. The iPad scaffold builds from a clean checkout and runs on iPad (A16) in the simulator. See the [ENV-002 verification record](qa/env-002.md) for test results, the screenshot and pending checks. ENV-002 entered independent review.

## 19. ENV-002 Lead acceptance (v1.10)

The Lead accepted ENV-002 based on the [independent QA report](qa/env-002-independent-review.md), originally committed as [`ac149ff135838f60a06ca8fb42b1f97a34177347`](https://github.com/binbas0901/Singapore-math-with-Juni/commit/ac149ff135838f60a06ca8fb42b1f97a34177347). Both low-severity findings are resolved on PR #2. The workflow pins checkout v4.3.1 to its verified upstream full commit SHA and disables credential persistence. The reproduction instructions explicitly check out and verify the tested scaffold SHA.

Hosted CI, iPadOS 17 runtime and physical-device readiness remain unverified.

## 20. ENV-002 integration and CUR-001 independent QA (v1.11)

ENV-002 was integrated through [PR #2](https://github.com/binbas0901/Singapore-math-with-Juni/pull/2) at [`1206df736d6916c2da798aa35af10d1d1000f599`](https://github.com/binbas0901/Singapore-math-with-Juni/commit/1206df736d6916c2da798aa35af10d1d1000f599). [Independent curriculum QA](qa/cur-001-independent-review.md) retrieved the official October 2025 syllabus and confirmed that its SHA-256 matches the acquisition record. QA recommends accepting CUR-001. Its status remains review pending the Lead decision.

## 21. CUR-001 Lead acceptance (v1.12) — 2026-11-19

Lead inspected the independent QA report at `752930402b87eb139e674e0d72b4311512d8ec5f` and PR #3 diff. Accepted source verification: official index and media downloads match the previously recorded fingerprint, 50 pages, 806,004 bytes; edition, applicability, pathways, printed anchors and rights notice verified by independent QA. Lead did not repeat the Mac download. Both low findings corrected in source register v1.4 at `fcb134d7dbcd87a2a09c6d7f27798cb534aaf3a5`. CUR-002 remains review pending independent Education review; CUR-004 moves backlog to ready after integration, not a beta prerequisite. CUR-003 and IOS-001 remain review. Commercial rights clearance, scope of Foundation mapping and device gates remain open. No application changes or PDF committed. Counts: 4 accepted, 3 review, 1 ready, 26 backlog. Next prioritize CUR-002 independent review after PR #3 integration.

## 22. CUR-001 integration and CUR-002 independent Education review — 2026-11-19

CUR-001 was integrated into main through [PR #3](https://github.com/binbas0901/Singapore-math-with-Juni/pull/3) at [e546204](https://github.com/binbas0901/Singapore-math-with-Juni/commit/e546204882c4f8d12af0fca758bbf9b218d766b0). The [CUR-002 independent Education review](qa/cur-002-independent-review.md) independently downloaded the official PDF, matched its registered SHA-256 and reconciled all 32 numbered P1 objectives. It verified 59 core and six enrichment concepts and acyclic prerequisite graphs. CUR-002 stays in review pending Lead disposition of active-use evidence, grid-format mastery and prerequisite findings. Task counts are unchanged. No dependent work was started.

## 23. CUR-002 targeted corrections for independent Education re-review — 2026-11-19

Status remains **review**. Corrections follow the [Lead disposition on PR #4](https://github.com/binbas0901/Singapore-math-with-Juni/pull/4#issuecomment-7029605195), D02, D06, D07 and D13. The [original independent review](qa/cur-002-independent-review.md) at `fb39588c1012b980aebbd1b76df8df75631b9f1d` is preserved.

| Finding | Correction evidence |
|---|---|
| M1 | ADD-02 calls for producing meaningful equations and using equality. ADD-06 specifies independently carrying out each written algorithm, with and without regrouping, within 100. TIM-02 requires selecting and using am/pm in familiar contexts. Boundary examples use explicit noon and midnight labels. Concept and lesson assessment descriptions agree. |
| M2 | GEO-04 uses `any_linked_concept` instead of the default `all_linked_concepts`. Dot-only and square-only evidence each satisfy the official objective. Neither format depends on the other. Both slots remain for instruction as a product extension. |
| M3 | Core slot sequence stays advisory. The mapping adds 58 task-bounded readiness checks. It specifies four mastery edges for using ordinal symbols after identifying positions, reading five-minute times with knowledge of the clock hands, and measuring or drawing segments with ruler-alignment skill. Independent evidence can be prior or concurrent. The single cross-objective summary link is LEN-04 to LEN-01. Cent counting, small-set bonds and initial work with clock hands have no full-range mastery gate. |
| L1 | The P1-L046 title is synchronized in the mapping and coverage, with the repeated noon and midnight clause removed. |
| L2 | TIM-03 requires use of h and min, GEO-03 targets identification of component shapes, and LEN-04 teaches how to read to the nearest cm with a ruler. Shape wording introduces half circle and semicircle together. |
| L3 | JSON, coverage, blueprint, unit specification header and current ledger record owner approval of **Numbers and Number Bonds to 10** on 2026-11-17, with Education approval and CUR-002 acceptance pending. |

I reran SHA-256 and a temporary Python reconciliation using the previously independently downloaded official PDF outside Git. The hash matched the register and `pdftotext -layout` confirmed all 32 unique page/strand/topic/item tuples (19 on p. 31 and 13 on p. 32). Comparison to `fb39588` verified stable IDs, source anchors, slot order and classification. Counts remain 32 objectives, 59 core and six enrichment concepts, and the same 65 linked slots. Both prerequisite graphs topologically sort. Objective edges fell from 36 to one and concept edges from 187 to four as suggested sequencing and bounded readiness moved out of the mastery graph. The audit checked exact Markdown table parity for all 32 objective rows and 65 concept rows. Evidence cases accepted either grid alone or both and rejected empty or unrelated evidence. The default rule still requires all linked concepts for the other 31 objectives. This tests the inventory rules as data. Authored materials, learner assessments and runtime behavior were outside scope.

Next reviewer is an independent Education reviewer for M1–M3 and L1–L3 on the corrected PR revision, followed by Lead disposition. Task statuses and counts remain unchanged. No downstream implementation was started.

## 24. CUR-002 Lead acceptance and IOS-001 review handoff (v1.13) — 2026-11-19

Lead verified the [final independent Education review](qa/cur-002-final-review.md) (original QA commit `c62db4ea4196e610f3753b0960578bbffcb1cb62`), based on `d77e434331e9f316b5182bc701a363a287310cb0`. All M1–M3 and L1–L3 resolved. Lead copied the six existing concept assessment criteria into the linked enrichment slots at `b35d82702e4a07364816714b97a35a7cff1a2cb3` and verified all 65 concept/lesson assessment descriptions match. No changes to learning goals, stable IDs, source anchors or mastery rules. Accepted CUR-002 inventory, not authored lessons or runtime validation. PR #4 awaits integration; CUR-003 remains review; DATA-001 becomes ready after integration (IOS-001 draft sufficient); CUR-004 remains ready. Independent IOS-001 review at [`bac1438e486c6454e1966dff4f5a682e75b083ad`](https://github.com/binbas0901/Singapore-math-with-Juni/blob/bac1438e486c6454e1966dff4f5a682e75b083ad/docs/qa/ios-001-independent-review.md) recommends corrections, with no change to IOS-001 review status. No downstream code, no gate freeze. Counts: 5 accepted, 2 review, 2 ready, 25 backlog.

## 25. IOS-001 document baseline and CUR-003 review handoff (v1.14) — 2026-11-19

CUR-002 integration verified at `49cbfcaaf167940d367812e9db331739eca43bfc`. Independent architecture re-review [`6d656d7`](qa/ios-001-final-review.md) of `9691d4a` dispositions all 11 findings. Lead corrected R1/R2, explicitly mapped the remaining source tray to part B, asserted the 6–2–4 bond and recombination, and aligned its synthetic fixture with CUR-003 revision `e37801e` (pending Education approval). Advisory sequence, bounded readiness, component mastery prerequisites and placement evidence are distinguished. Architecture v1.3 at `ee22c70ec376961a0f7350326b0b34f91b6bee88` accepted as working document baseline only. IOS-001 remains in review pending DATA-001/MATH-000 reconciliation; no interface freeze, runtime or device acceptance. DATA-001 ready to draft. CUR-003 PR #7 includes the independent report and targeted unit revision, now awaiting focused re-review. Task counts unchanged: 5 accepted, 2 review, 2 ready, 25 backlog. No application changes or new paid work. Full-moon mascot design approved by owner in design conversation; record on separate design PR, no change to moon-phase evidence semantics.

## 26. CUR-003 acceptance and end-of-day design checkpoint (v1.15) — 2026-11-19

CUR-003 specification accepted and integrated at `75f545c9f55ab1439f3e27137049fb07cb3874e2`. [Final Education re-review](qa/cur-003-final-review.md) at `421a8da` resolved M1–M3 and L2; Lead clarified L1 and verified the original review was preserved, with no changes to mathematical examples. Guided readiness does not gate eligible independent evidence or permitted exploration. Eleven core sessions plus optional U12; U07 remains the first slice. Owner sample-slice approval, authored content and device verification remain downstream. Full-moon Juni refinement recorded in design PR #5 at `2761fa0daeda96055b03a6fc0f0821aeff380ae8`; production art and independent design integration remain pending. IOS-001 task remains in review; DATA-001 ready/assignment issued, completion report pending at this checkpoint; MATH-000 awaits DATA-001 draft; no new assignments tonight. Counts: 6 accepted, 1 review, 2 ready, 25 backlog.

## 27. Final November 19 checkpoint (v1.16)

Both assigned agents completed and pushed. DATA-001 draft at `e6246c2ebdf2de5a40e4ed303b2e87164f9e16aa` in open PR #9 adds 31 files (schema, portable U07 package, 23 negative cases and checker). Author reports both checker runs and whitespace check passed. Lead inspected the contract notes, catalog, lesson and checker outline; independent execution/review remains pending. CUR-003 is accepted on main even though PR #9 was authored against its prior review status. Next session: independent Data/QA review of exact draft, parallel MATH-000 draft, and subsequent joint IOS-001/DATA-001/MATH-000 reconciliation before LEAD-002. Check replacement-specific disclosure bindings, exposure equivalence, modelling and serialization. No interface freeze or runtime/device claim. Silent placeholder audio only. Design PR #5 records owner-approved full moon; home reference checksum unverified and removed at `3784e7190d5337157cdf104549ba4259d1d24802`; asset acquisition and independent design integration pending. No further agent work assigned tonight. CUR-004 remains ready. Counts: 6 accepted, 2 review, 2 ready, 24 backlog. No milestone gate accepted.

## 28. Owner-approved sequencing decision — 2026-11-21 (v1.17)

Owner confirmed **fully functional offline-first private beta before optional conversational AI tutor**. The initial unit, local prerecorded instruction, checked math/evidence and device test scope remain unchanged under D03; no runtime AI, speech upload, new cloud features or spending is authorized for the beta. The already-used roughly $120/month live tutoring budget is comparison context for later evaluation only. Preserve modular teaching/presentation interfaces at LEAD-002 without implementing AI. Future voice AI would require separate privacy, provider, parent-consent, learning-quality, cost and child-data approval gates. Full-moon Juni remains the approved mascot. DATA-001 PR #9 at `e6246c2` awaits independent Data/QA review. MATH-000 may draft against the provisional schema while separately declaring unresolved learning policy. Six accepted, two review, two ready, 24 backlog; no milestone gate accepted and no Codex agent is assumed running until user launches it.

## 29. MATH-000 draft received — 2026-11-21 (v1.18)

MATH-000 proposal `8847540140cc498a5b5e1c4bdf3f905c9d6a84bc` in draft PR #12 adds only `docs/mastery-contract.md`. Author reports local link/whitespace and U07/data fixture checks; Lead verified exact diff and reviewed contract, without independently re-running checks. Main review finding: permanent scored/disclosed relationship exclusion may exhaust bounded 0–10 assessment pools under ongoing 2/7/21-day retention; especially complements to ten. Also review threshold workload (4/5 over two dates, 2/2 retention), model sufficiency, retry/assistance and DATA-001/IOS-001 cross-contract representations. See Lead comment on PR #12. All thresholds and learning policies require independent Education review and owner approval. IOS-001 remains in review for contract reconciliation; DATA-001 remains in review; no LEAD-002 freeze. CUR-004 alone remains ready. Task counts: 6 accepted, 3 review, 1 ready, 24 backlog. No runtime or physical-device implementation evidence claimed.

## 30. DATA-001 independent QA findings received — 2026-11-21 (v1.19)

Independent Data Architecture review `269f92719d1952b0556936fccafe75564f4ebe2d` of exact PR #9 head `e6246c2ebdf2de5a40e4ed303b2e87164f9e16aa` confirms U07 six-counter cue fold, linked 6–2–4 bond, distinct 7–1–6 guided item, fresh 8–3–5 check and all 23 authored negative fixtures rejected. The QA agent additionally ran 18 adversarial probes: 15 accepted, three rejected. D1/D2 high: replacement-specific help/feedback and exposure were not bound to the active item, changed exposure key could hide identical problem, and answer-bearing neutral text passed. D3–D5 medium: readiness/action gates, worksheet/evidence identity, package allowlist/media validation and versioning. Lead preserved the original report byte-identically at PR #9 `f7649f349c8e18d1235e671a780cc4262361824a` and posted corrections. DATA-001 remains in review, no merge; MATH-000 remains proposed, IOS-001 remains in review until reconciliation. Task counts unchanged: 6 accepted, 3 review, 1 ready, 24 backlog. No new owner learning-policy approval and no runtime/device evidence.

## 31. DATA-001 corrective revision and MATH-000 independent review — 2026-11-21 (v1.20)

MATH-000 Education/Math QA report `72d370c047006911b40c52e944ce2d203b381d31` of proposal `8847540140cc498a5b5e1c4bdf3f905c9d6a84bc` recommends changes on F1–F7. The unchanged report was preserved in draft PR #12 at `4363e6f3b546f6a25069d42465a994aea4803fe5`. Major blocker: lifetime exclusion of known make-ten bonds exhausts the offline retention item pool; allow specifically reviewed, spaced reuse without retroactive evidence edits or recent-answer leakage, pending owner choice. Explicitly approve evidence thresholds, mastery facets, 2/7/21-day retention schedule, mixed 1/2 response handling, model sufficiency, retry/exposure, optional diagnostic and parent routing only after Education re-review. Lead posted review directions on PR #12. No MATH-000 acceptance.

DATA-001 agent corrected D1–D5 on open PR #9 at `ff71de381841de180e48619d2d74a6de3d2b66bc`. The revision introduces candidate-bound assistance and feedback, supported-family canonical freshness checks, readiness/action/worksheet/evidence contracts, package allowlisting, PCM validation and a manifest-pinned Education review handoff. Author reports both documented commands pass, 9 positive regression cases and 53 negative cases (including original 23); Lead inspected files/fixture inventory but did not rerun checks. Original independent report `269f927` is preserved. Focused independent Data/QA re-review of exact `ff71de3`, Education neutrality and replacement-demand check, and runtime/contract reconciliations remain mandatory. No DATA-001 acceptance.

IOS-001 architecture v1.3 document baseline remains integrated but task stays in review pending DATA-001 and MATH-000 agreement. LEAD-002 remains deferred. No change to planned offline-first beta or future optional AI voice prototype. Counts unchanged: 6 accepted, 3 review, 1 ready, 24 backlog. No milestone acceptance or physical iPad test claim.
