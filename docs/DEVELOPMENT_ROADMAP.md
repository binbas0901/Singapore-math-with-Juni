# Singapore Math with Juni --- Development Roadmap

**Version:** 1.0 \| **Date:** 2026-11-17 \| **Status:** Proposed execution baseline\
**Authority:** PROJECT_BLUEPRINT.md v1.0 and AGENTS.md v1.0\
**Target:** One complete Primary 1 learning unit, private offline iPad beta.

## 1. Execution principles

The product owner approves material decisions and release readiness. The lead coordinates actual agent sessions, assigns bounded tasks, integrates reviewed outputs and maintains PROJECT_STATUS.md. Codex implements and tests repository changes; research and education agents produce traceable curriculum and original content. Agents may work concurrently only where interfaces and path ownership are agreed. If the tools do not support delegation, execute sequentially and report that accurately. No task is completed by this document alone.

Honor D01--D13: native SwiftUI, content-driven offline learning, prerecorded Juni narration, moon-only brand, stylus and hybrid recognition, guided mastery, local parent dashboard, portable content and phased content tooling. No runtime AI, mandatory account, cloud sync or public release in the first beta. Use synthetic learner records for development. All proposed technical choices remain subject to architecture review.

## 2. Milestones and release gates

  -------------------------------------------------------------------------------------------------------------------------------------------------------
  Milestone         Outcome                          Exit evidence                                                                      Gate
  ----------------- -------------------------------- ---------------------------------------------------------------------------------- -----------------
  M0 / Sprint 0     Foundation and execution setup   Baseline documents reviewed; status ledger and environment plan                    G0

  M1 / Sprint 1     Verified curriculum and scope    Official source provenance; P1 coverage matrix; reviewed first-unit scope          G1

  M2 / Sprint 2     Stable contracts and toolchain   Architecture, schema, fixtures, math/mastery interfaces; reproducible build path   G0, G2, G3

  M3 / Sprint 3     Parallel core implementation     Local loader, persistence, widgets, narration and workbook tested                  G2, G3

  M4 / Sprint 4     Vertical slice                   One reviewed complete lesson, offline flow and recognition fallback demonstrated   G1--G5

  M5 / Sprint 5     Complete learning unit           Every approved lesson, assessment and enrichment reviewed and packaged             G1--G5

  M6 / Sprint 6     Integrated release candidate     Physical iPad test, accessibility, privacy, rights and recovery evidence           G3--G6

  M7 / Sprint 7     Private beta                     Authorized installation and owner acceptance; feedback backlog                     G6
  -------------------------------------------------------------------------------------------------------------------------------------------------------

Sprints are dependency-based work packages, not calendar commitments. Estimate durations after environment and content throughput are measured. Do not advance a milestone with a missing mandatory gate; record exceptions only for nonmandatory work with owner approval.

## 3. Actionable backlog

Every row specifies task ID, accountable role, prerequisites, output and acceptance evidence. Reviewer follows the role label after the slash. Paths are proposed repository ownership boundaries; the lead reconciles them at M2. Initial status for all tasks is backlog unless marked ready in section 6. Existing documents are produced artifacts, not independently accepted gates.

### Sprint 0 --- Foundation

  --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ID             Owner / reviewer   Dependencies                  Deliverable                                    Acceptance criteria
  -------------- ------------------ ----------------------------- ---------------------------------------------- -----------------------------------------------------------------------------------------------------------------------------------------------------------------
  LEAD-001       Lead / Owner       None                          docs/ --- blueprint, AGENTS, roadmap, status   All 13 decisions present; references consistent; status ledger initialized; owner review recorded.

  ENV-001        Release / Lead     LEAD-001 (draft sufficient)   docs/environment.md; repository setup plan     Check actual Codex access, Git permissions, Mac/Xcode and iPad; record versions, costs, blockers and signing path; obtain authorization before remote creation.

  ENV-002        Release / QA       ENV-001                       app/ build skeleton; CI configuration          Authorized repo initialized; clean checkout builds and runs a smoke test on macOS; exact commands and logs recorded; no secrets committed.
  --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

### Sprint 1 --- Curriculum

  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ID             Owner / reviewer         Dependencies                  Deliverable                                          Acceptance criteria
  -------------- ------------------------ ----------------------------- ---------------------------------------------------- ---------------------------------------------------------------------------------------------------------------------------------------------------------
  CUR-001        Curriculum / QA          LEAD-001 (draft sufficient)   references/source-register.md                        Retrieve official MOE syllabus; verify edition and applicability, URL, date, page references, checksum if bytes available; flag missing sources.

  CUR-002        Curriculum / Education   CUR-001                       curriculum/p1/objectives.json; docs/coverage-p1.md   All P1 objectives mapped to stable IDs, source pages and strands; explicit gaps, prerequisites and core/enrichment distinctions; independent check.

  CUR-003        Curriculum / Education   CUR-002                       docs/first-unit.md                                   Propose number-sense/number-bond unit with verified ranges and prerequisites; map each objective to teaching/practice/assessment; owner approves scope.

  CUR-004        Curriculum / QA          CUR-001                       curriculum/p2--p6/; docs/CURRICULUM_MASTER.md        Map remaining levels with provenance and completeness report; may run alongside implementation; no requirement to finish before private beta.
  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

### Sprint 2 --- Architecture and contracts

  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ID             Owner / reviewer              Dependencies                  Deliverable                                Acceptance criteria
  -------------- ----------------------------- ----------------------------- ------------------------------------------ ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  IOS-001        iOS / Lead                    LEAD-001                      docs/ARCHITECTURE.md                       Define modules, state transitions, dependency boundaries, deployment target proposal and offline threat model; reconcile with DATA-001 and MATH-000.

  DATA-001       Data / iOS                    CUR-002, IOS-001 draft        schemas/; curriculum/fixtures/             Versioned schema for lesson/activity/objective/media/manifest; good and bad fixtures; references and prerequisite graph validated.

  MATH-000       Math / Education              CUR-003, DATA-001 draft       docs/mastery-contract.md                   Specify deterministic grading, seeds, evidence and proposed thresholds; assisted/independent distinction; recognition uncertainty neutral; owner review for learning policy.

  LEAD-002       Lead / QA                     IOS-001, DATA-001, MATH-000   docs/contracts.md; task path assignments   Freeze initial interfaces; verify all fixture contracts agree; approve reversible defaults and isolate parallel branches.

  EDU-001        Education / Curriculum + QA   CUR-003, DATA-001             curriculum/p1/vertical-slice/              One original CPA lesson, narration transcript, independent check, misconceptions, feedback and enrichment; verify every answer and objective link.
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

### Sprint 3 --- Core implementation

  --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ID             Owner / reviewer               Dependencies        Deliverable                                 Acceptance criteria
  -------------- ------------------------------ ------------------- ------------------------------------------- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  DATA-002       Data / QA                      LEAD-002            tools/validate_content.py; tests/content/   CLI rejects duplicate IDs, cycles, invalid references, missing media, unsupported versions and malformed items; documented reproducible test command.

  IOS-002        iOS / QA                       LEAD-002, ENV-002   app/ lesson shell and navigation            Load fixture lesson; pause/resume/replay; invalid packages fail safely; no network dependency; build and unit tests pass.

  IOS-003        iOS / QA                       LEAD-002, ENV-002   app/ workbook and recognition adapter       PencilKit save/erase/reopen; local recognition feasibility spike with synthetic numeric samples; uncertain answers confirmed; keypad always available; report actual device/model limitations.

  IOS-004        iOS / Math                     LEAD-002, ENV-002   app/ reusable math views                    Counting, number representation and number bonds maintain correct state; touch alternatives and labels; fixture tests.

  MATH-001       Math / QA                      LEAD-002            app/ domain math and mastery; tests/math/   Seeded generation reproducible; bound/equivalence tests; no false mastery from hints or retries; review scheduling fixtures.

  DATA-003       Data / QA                      LEAD-002, ENV-002   app/ persistence module                     Transactional local evidence and workbook metadata; migration and interruption/restart tests; no accounts or external writes.

  CREATIVE-001   Creative / Education + Owner   EDU-001             assets/; audio/; media manifest             Moon-only mascot prototype, transcripts, local audio playback assets; owner brand approval and rights ledger; paid production only after budget authorization.

  IOS-005        iOS / QA                       LEAD-002, ENV-002   app/ media playback                         Local narration replay, transcripts and graceful missing-asset state; no runtime speech generation; tests with placeholder assets.
  --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

### Sprint 4 --- Vertical slice

  ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ID             Owner / reviewer   Dependencies                                                                              Deliverable                                Acceptance criteria
  -------------- ------------------ ----------------------------------------------------------------------------------------- ------------------------------------------ ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  IOS-006        iOS / Lead         IOS-002, IOS-003, IOS-004, IOS-005, MATH-001, DATA-003, EDU-001, DATA-002, CREATIVE-001   app/ integrated lesson; packaged fixture   Complete concrete/pictorial/abstract flow as appropriate; confirmed answer updates evidence; resume after restart; replay works offline.

  IOS-007        iOS / QA           DATA-003, MATH-001, IOS-002                                                               app/ parent dashboard                      Parent-protected local history, concept evidence, next recommendation and settings; synthetic fixture totals reconcile; no remote sync.

  QA-001         QA / Lead          IOS-006, IOS-007                                                                          docs/qa/vertical-slice.md                  Independent answer/pedagogy checks, integration tests, airplane-mode and physical-device evidence where available; record device blockers; owner accepts slice before expansion.
  ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

### Sprint 5 --- Complete unit

  -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ID             Owner / reviewer              Dependencies                                Deliverable                               Acceptance criteria
  -------------- ----------------------------- ------------------------------------------- ----------------------------------------- --------------------------------------------------------------------------------------------------------------------------------------------------------------
  EDU-002        Education / Curriculum + QA   QA-001, CUR-003                             curriculum/p1/first-unit/                 All approved lessons authored and reviewed; each target has instruction, practice and independent assessment; remediation and advanced enrichment separated.

  MATH-002       Math / QA                     EDU-002, MATH-001                           app/ unit generators; tests/math/         Every item family covered by deterministic and boundary tests; assessment items not answer-revealing; no ambiguous answers.

  CREATIVE-002   Creative / Education          EDU-002, CREATIVE-001                       assets/; audio/; rights register          Approved voice/illustrations for all required lessons; transcript matches audio; licensed, local and referenced; no placeholder production narration.

  DATA-004       Data / QA                     EDU-002, CREATIVE-002, MATH-002, DATA-002   tools/package_content.py; unit manifest   Reproducible versioned package; validation passes; checksum and coverage report emitted; unsupported packages rejected.

  IOS-008        iOS / QA                      DATA-004, QA-001                            app/ unit navigation and placement        Recommended path, allowed exploration, placement and retention review operate with local evidence; no forced mastery or missing prerequisites.
  -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

### Sprint 6 --- Release candidate

  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ID             Owner / reviewer   Dependencies                          Deliverable                    Acceptance criteria
  -------------- ------------------ ------------------------------------- ------------------------------ ---------------------------------------------------------------------------------------------------------------------------------------------------------------
  QA-002         QA / Lead          IOS-008, IOS-007, DATA-004, ENV-002   docs/qa/release-candidate.md   FR01--FR12 traceability; full unit in airplane mode on physical iPad; restart recovery, accessibility, recognition error recovery and parent totals checked.

  REL-001        Release / QA       QA-002                                docs/release-checklist.md      Verify rights, privacy and signing; no secrets or unnecessary telemetry; clean install and upgrade tests; authorized private distribution mechanism selected.

  LEAD-003       Lead / Owner       REL-001                               docs/release-approval.md       No unresolved release-blocking defects; all gates evidenced; owner approval for installation/distribution.
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

### Sprint 7 --- Private beta

  -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ID             Owner / reviewer         Dependencies   Deliverable                     Acceptance criteria
  -------------- ------------------------ -------------- ------------------------------- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
  REL-002        Release / Owner          LEAD-003       signed build; docs/install.md   With authorization, install on target iPad directly or via private TestFlight; record build version and actual installation evidence.

  QA-003         QA / Education + Owner   REL-002        docs/beta-feedback.md           Observe child usability only with parent consent; record anonymized observations and remediation backlog; no uploads of handwriting or identifiers without approval.

  LEAD-004       Lead / Owner             QA-003         docs/next-release-plan.md       Review learning feedback and defect priorities; owner decides whether to expand to full P1; no automatic public release.
  -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## 4. Dependency and parallel execution plan

``` mermaid
flowchart TD
 A[Foundation] --> B[Official syllabus and P1 mapping]
 A --> C[Environment and build setup]
 A --> D[Architecture draft]
 B --> E[Approved first unit and content schema]
 D --> E
 E --> F[Shared contracts]
 E --> G[Reviewed slice lesson and media]
 F --> H[Math and content tools]
 F --> I[iOS modules and storage]
 C --> I
 G --> J[Integrated slice]
 H --> J
 I --> J
 J --> K[QA and owner slice gate]
 K --> L[Full unit production]
 L --> M[Release candidate and device QA]
 M --> N[Authorized private beta]
 B --> O[P2–P6 mapping: parallel]
```

Critical dependency chain: source verification → approved unit → contracts → integrated slice → acceptance → full unit → physical-device release gate. Mac readiness is a parallel prerequisite for native build acceptance, not a blocker to research or portable tools. Parallel agents must not edit the same paths; the lead owns integration and interface changes. Creative assets and education content may progress together using stable IDs. Do not commission production audio until scripts and budget are approved.

## 5. Acceptance and requirement traceability

  Blueprint requirement       Primary evidence tasks
  --------------------------- ---------------------------
  FR01 Content-driven         DATA-001, IOS-002, QA-002
  FR02 Offline                IOS-005, IOS-006, QA-002
  FR03 Reusable math          IOS-004, MATH-002
  FR04 Stylus workbook        IOS-003, QA-002
  FR05 Hybrid recognition     IOS-003, IOS-006, QA-002
  FR06 Adaptive progression   MATH-001, IOS-008
  FR07 Exploration            IOS-008, QA-002
  FR08 Parent reporting       IOS-007, QA-002
  FR09 Integrity              DATA-002, DATA-004
  FR10 Persistence            DATA-003, QA-002
  FR11 Accessibility          IOS-004, IOS-005, QA-002
  FR12 Child safety           IOS-001, REL-001, QA-002

Apply G0--G6 from AGENTS.md. Record test commands, actual results, commit/build IDs, reviewer and device/OS. An unexecuted test is not a pass. Independent review is required for learning content; automated math tests do not establish teaching quality. Use blocker severity: critical (safety/privacy/data loss/wrong mathematics), high (required flow unavailable), medium (workaround available), low (cosmetic). Critical/high release defects block acceptance. No numeric learning efficacy claim from a single learner beta.

## 6. Immediate dispatch queue

1.  **LEAD-001** --- ready: create status ledger and reconcile foundational documents; seek baseline approval.
2.  **CUR-001** --- ready in parallel: retrieve official syllabus and create source register, not an invented curriculum summary.
3.  **ENV-001** --- ready in parallel: establish available agent/repo/Mac workflow; report costs and required authorizations without provisioning anything.
4.  **IOS-001** --- start architecture draft after foundation baseline; avoid locking technical choices before source/contracts review.
5.  **CUR-002** --- dispatch when CUR-001 accepted; then CUR-003 and DATA-001.

Dispatch means actually invoking an available agent or executing the task in the current session. This document does neither. Lead must check tools and repository context before assignment.

### Agent dispatch template

``` text
Task ID / accountable role / reviewer:
Read: PROJECT_BLUEPRINT.md, AGENTS.md, DEVELOPMENT_ROADMAP.md, PROJECT_STATUS.md
Objective / decision IDs / requirement IDs:
Accepted dependencies and evidence:
Allowed paths / branch:
Deliverables and acceptance criteria (copy task row):
Required tests and independent review:
Budget and permission limits:
Report: artifacts, executed checks, missing checks, risks, blockers, next action.
```

Maintain a status ledger with task ID, state, assignee/session, dependency evidence, branch, artifact links, test evidence, reviewer and next action. Allowed states: backlog, ready, in progress, review, blocked, accepted. Do not mark accepted merely because an artifact exists. Use task ID in commits and PRs. Run independent review and record findings before merging.

## 7. Owner decisions and blockers

  --------------------------------------------------------------------------------------------------------------------------------------------------------------
  Item                                             Needed by               Handling
  ------------------------------------------------ ----------------------- -------------------------------------------------------------------------------------
  Official syllabus verification                   M1                      Research agent retrieves; flag unavailable or superseded source

  Repository and agent access                      M0/M2                   Inspect actual capabilities; request authorization for external changes

  Mac, Xcode, signing and device                   M2/M6                   Evaluate local/remote paths and costs; owner chooses if expense needed

  Unit scope and mastery policy                    M1/M2                   Owner approves after curriculum and education review

  Handwriting feasibility                          M3                      Benchmark locally; preserve keypad fallback; do not claim accuracy without evidence

  Mascot and voice licensing/budget                M3/M5                   Owner approves appearance and spending; rights register before beta

  Public privacy, cloud, naming and distribution   Post-beta               Separate review and approvals; not first-unit scope
  --------------------------------------------------------------------------------------------------------------------------------------------------------------

## 8. After the private beta

Expand to a complete verified P1 curriculum, then P2--P6; maintain coverage reports and independent review. Build curriculum studio only after stable authoring workflow and schemas. Consider optional cloud sync only with separately approved privacy, consent, deletion/export and security design. Public distribution requires rights, naming/trademark, child privacy and App Store review. Android and complex handwriting are future proposals, not commitments. No dates or budgets have been approved.

## 9. Baseline limitations

This roadmap was derived from the two existing project documents. It proposes work decomposition, dependencies, path allocation and gates; these do not supersede approved product decisions. No official source was retrieved for this roadmap, no repository or agent session was created, and no code or device tests were executed. The proposed unit sequence remains provisional until CUR-003. The P2--P6 inventory is an explicit parallel stream rather than a private-beta prerequisite, to avoid delaying validation of the first unit. Update the status ledger and roadmap through the lead when evidence or owner decisions change.
