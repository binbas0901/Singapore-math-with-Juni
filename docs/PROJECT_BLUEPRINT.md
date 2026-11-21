# Singapore Math with Juni
## Master Project Blueprint

**Version:** 1.2 | **Date:** 2026-11-17 | **Status:** Baseline for owner review  
**Owner:** Product owner | **Delivery model:** AI-agent-driven development  
**First release:** One complete Primary 1 learning unit, private iPad beta

## 1. Mission and product vision

Build a complete, engaging, rigorous Singapore mathematics learning application that teaches rather than merely quizzes. Juni, a moon-themed teaching companion inspired by the owner's daughter the initial learner (whose name means moon in Nepali), guides children through original explanations, interactive mathematical models, handwritten work and mastery practice. Begin with one child and evolve toward a public product covering Primary 1–6 with advanced enrichment. Singapore mathematics curriculum alignment must be prominent; do not imply Ministry of Education (MOE) endorsement.

## 2. Approved decision register

| ID | Decision | Implementation constraint |
|---|---|---|
| D01 | Personal-first, eventual public release | Private beta first; design for broader use without exposing child data. |
| D02 | Structured curriculum plus adaptive mastery | Follow coherent prerequisites while responding to learning evidence. |
| D03 | Prerecorded mascot instruction | ElevenLabs narration generated during production; offline playback; no live AI tutor. |
| D04 | Juni, moon-inspired mascot | Moon is the sole celestial brand symbol; no star motifs or star rewards. |
| D05 | Singapore Math with Juni | Use exact product name; availability/trademark review before publication. |
| D06 | Complete curriculum plus advanced enrichment | Cover every verified P1–P6 objective over time; distinguish enrichment from core. |
| D07 | Guided mastery with freedom | Recommended path, exploration and parent controls; no rigid universal lockstep. |
| D08 | iPad with stylus | Interactive teaching and digital workbook; touch alternatives where practical. |
| D09 | Hybrid handwriting | Recognize supported final answers locally; preserve free-form working; keypad fallback. |
| D10 | Hybrid parent dashboard | Same-device offline reporting first; optional cloud synchronization later. |
| D11 | Native Swift and SwiftUI | iPad-first; keep curriculum and math definitions portable. |
| D12 | Phased hybrid content management | Python, JSON and Git initially; dedicated curriculum studio later. |
| D13 | One complete initial learning unit | Validate one vertical slice before expanding to a full unit and then P1. |

**Subsequent approved direction:** use AI agents to perform research, design, coding, content generation, testing and documentation, with the owner approving significant choices. This supersedes a manual-development-first workflow, not the offline product requirements.

**Owner direction, 2026-11-21 — offline teaching first, conversational tutor later:** D03 and the first private-beta scope remain unchanged. Finish the offline-first app with one complete first unit, independently reviewed instructional content, local prerecorded narration, validated math tools, mastery evidence, parent controls and actual iPad testing. A natural voice-conversational AI teacher is an optional *later research and prototype phase*, not included in the initial release or in this 34-task roadmap. Preserve a clean boundary between verified lesson/math/evidence actions and replaceable instructor presentation so a future authorized AI tutor can request permitted actions without owning grading. Future cloud voice use, child-data handling, vendor contracts, security/privacy review and recurring payments require a separate explicit owner decision and testing. The owner's existing approximately $120/month live-tutor budget is comparison context, **not authorization to purchase or enable an AI service**. No microphone collection, cloud endpoint or real-time AI dependency is approved for the offline beta. Owner-approved Juni is a friendly golden **full moon** (not crescent); preserve moon-phase progress indicators as distinct pedagogy from mascot silhouette.

**Owner-approved provisional beta learning rules, 2026-11-21 (MATH-000):** For synthetic implementation and trial, plan four eligible **complete independent first-response successes across at least two learning dates**, with essential facet/model coverage and a prespecified opportunity window (4 in up to 5 is a draft, with precise stopping details pending). Permit **spaced familiar-bond reuse for retention** after at least **48 elapsed hours since the latest applicable interaction**, including relevant practice, hint, example, answer disclosure or prior prompt; maintain permanent provenance and avoid recent-answer leakage, while distinguishing familiar retrieval from novel transfer. Trial **successive 2-, 7- and 21-day retention gaps** from qualifying completions. In a two-item retention check, a single incorrect result prompts a targeted later follow-up rather than loss of previously earned achievement. This approval is for *provisional development and measurement*, **not pedagogical validation, final policy acceptance, paid services, or interface freeze**. Independent Education/QA review, sufficiently diverse items and clear recovery/facet rules remain required; other debated policy and scoring details are not implicitly approved. No change to D03 offline-first scope.

**Owner-approved extension, 2026-11-21 — rested familiar retrieval for *initial* mastery (MATH-000):** An independently solved previously taught number bond **may contribute to the initial bounded four-success assessment** after at least **48 elapsed hours since the latest applicable exposure or interaction**, including prompts, examples, practice, hints, answers and relevant cross-task disclosures. The child's response must be independently confirmed and show a learner-produced mathematical model when the rubric requires one; recent answer echo or help makes the attempt ineligible. Preserve four complete eligible first responses across at least **two successful learning dates**, with reviewed facet coverage. Permanently track **familiar independent retrieval** separately from **novel transfer** and do not claim the learner demonstrated transfer to unseen relationships based solely on familiar questions. This expands the previous 48-hour reuse approval, which covered retention only. It is provisional beta development/testing approval, not Education validation or approval of zero/equal-part substitutability, stopping/replacement mechanics, mixed-stage advancement, clock/recovery conventions or ongoing cadence. MATH-000 remains under review; offline-first scope is unchanged.

## 3. Audience and experience

Initial learner: a six-year-old child using an iPad with a stylus, with strong reading ability. Do not assume that reading ability implies mathematical mastery. Use short explanations, accessible controls, repeatable narration, low reading burden, immediate constructive feedback and a calm interface. Offer an age-appropriate placement assessment and enrichment as the learner demonstrates readiness. Future users include children across P1–P6 and their caregivers; placement should depend on demonstrated knowledge rather than age alone.

Core learning flow:

1. Resume recommended lesson or explore an available topic.
2. Juni introduces the learning goal using prerecorded voice and visuals.
3. Concrete phase: manipulate countable objects or virtual representations of manipulatives.
4. Pictorial phase: connect objects to diagrams, number bonds, bar models or other appropriate representations.
5. Abstract phase: solve symbolic problems and explain reasoning where appropriate.
6. Practice independently; receive deterministic feedback and targeted scaffolding.
7. Complete a mastery check without answer-revealing hints.
8. Update local learning history and recommend next steps or later review.

CPA means concrete–pictorial–abstract. It is a teaching approach, not a mandatory mechanical sequence for every question. Include reasoning, application, problem solving and multiple representations, not just procedural speed.

## 4. Curriculum authority and content governance

Primary source candidate: Singapore MOE, *2021 Primary Mathematics Syllabus (Primary 1 to 6)*, October 2025 revision. Candidate URL: https://www.moe.gov.sg/-/media/files/primary/2021-primary-mathematics-syllabus-p1-to-p6-updated-october-2025.pdf

This reference was identified during planning. The research agent must retrieve the official document, verify edition, applicability, page numbers, objectives and any subsequent updates before treating the inventory as authoritative. Record the retrieval date, URL, document version and provenance. If unavailable, flag the blocker rather than inventing objectives.

Organize by level → strand → unit → topic → concept → lesson → activity. Expected broad strands: Number and Algebra; Measurement and Geometry; Statistics. Verify actual level-specific scope and sequencing. Maintain stable source-objective identifiers and a coverage matrix linking each applicable objective to instruction, practice and assessment. Distinguish official requirements from proposed sequencing, pedagogical extensions and original advanced enrichment. Track prerequisites and avoid unsupported claims of full alignment. Use original lesson wording, examples, illustrations and audio; review rights before using third-party material.

Content lifecycle: source verification → mapping → instructional design → problem and asset production → mathematical validation → independent pedagogical review → device testing → approval → versioned publication. A generated lesson is not automatically an approved lesson.

## 5. First release scope

The owner approved **Primary 1 — Numbers and Number Bonds to 10** on 2026-11-17. CUR-003 specification is accepted; owner sample-slice approval remains pending. The proposed sequence starts with counting, recognizing, writing, comparing and ordering numbers, then moves to parts and wholes, making ten and applying number bonds. It closes with a mastery assessment and an optional number puzzle. The [unit specification](first-unit.md) gives the proposed sequence and learning targets.

### Required capabilities

- Offline learner home, lesson navigation and resume state.
- Juni character with prerecorded explanations, prompts, encouragement and replay.
- Reusable counting manipulatives, number representations and number-bond activities.
- Stylus workbook and supported handwritten numerical final answers with confirmation/fallback.
- Deterministic problem generation and answer validation; independent mastery checks.
- Local progress persistence, guided next steps, review and enrichment.
- Basic parent dashboard with learning history and mastery evidence; parent-protected access.
- Versioned content manifest, schemas, validation tools and automated tests.
- Installable private beta on a physical iPad, after required signing and build setup.

### Deferred

Complete P1 and P2–P6, public App Store launch, remote dashboard/cloud synchronization, full curriculum studio, Android, complex equation recognition, additional mathematical widgets beyond unit needs and elaborate character animation not needed for teaching. Live generative AI tutoring and mandatory Internet access are explicitly out of scope for the intended product.

## 6. Functional requirements

| ID | Requirement | Acceptance evidence |
|---|---|---|
| FR01 | Content-driven lessons | Add a supported activity via validated content without changing Swift UI code. |
| FR02 | Offline teaching | Complete installed unit in airplane mode including narration and assessment. |
| FR03 | Reusable interactive math | Manipulatives and models maintain mathematically correct state, support touch. |
| FR04 | Stylus workbook | Draw, erase, save and reopen working; support touch or appropriate fallback. |
| FR05 | Hybrid recognition | Confirm uncertain results; correct errors or use keypad; recognition errors do not penalize mastery. |
| FR06 | Adaptive progression | Fixture tests demonstrate prerequisite guidance, targeted remediation and review. |
| FR07 | Exploration | Learner can explore as allowed by parent settings without falsely marking mastery. |
| FR08 | Parent reporting | Show completed learning, evidence, next steps, practice and review needs from local data. |
| FR09 | Content integrity | Invalid or incomplete packages fail validation with actionable errors. |
| FR10 | Persistence | Restart app without losing completed work or progress. |
| FR11 | Accessibility | Legible text, clear contrast, replay/captions, accessible labels and non-audio alternatives. |
| FR12 | Child safety | No advertising, open chat, external links in learner flow or unnecessary personal data collection in beta. |

## 7. Mastery and assessment design

Use guided progression, diagnostic evidence, independent answers and retention checks. Proposed moon-phase states: new moon (not introduced), crescent (beginning), half moon (assisted), gibbous (independent), full moon (retained mastery). Provide text labels as well as visuals; no star rewards. Do not treat time spent, lesson completion or repeated guesses as mastery. Keep assisted attempts distinct from independent attempts and avoid penalizing handwriting recognition failures.

Proposed evidence fields: concept ID, item and seed, learner answer, correctness, assistance level, attempt time, content version and recognition confirmation. Derive recommendations from transparent local rules. Thresholds, review intervals, placement rules and parent restriction behavior are not yet approved; the education and math agents must propose and test these. Enrichment should deepen reasoning rather than merely accelerate into later grades.

## 8. Brand and media

Approved: Juni, moon-inspired identity, exact product name, no star iconography. Singapore math curriculum is central, not secondary to entertainment. Proposed palette: midnight blue, lavender and moonlight gold; proposed tagline: “Little steps. Bright minds.” Final character form, expressions, palette and animation assets require owner approval. Keep a consistent character reference sheet and asset manifest. Avoid depicting or using the actual child's likeness or voice without explicit permission.

Voice: generate original scripts using ElevenLabs during development, store approved audio locally and pair each clip with transcript, locale, script version and asset identifier. Reuse generic feedback clips when pedagogically appropriate. Verify chosen voice rights and commercial terms before public release. No API key or runtime dependency in the child app. Select Rive or a simpler native animation approach after evaluating quality, licensing and integration effort.

## 9. Architecture baseline

Native Swift/SwiftUI application with reusable modules: lesson orchestration, math activity engine, mastery engine, workbook/recognition, character/audio, persistence and parent reporting. Separate content from application logic. Local content and student data remain usable offline. Future cloud service is optional and must not be necessary for core features.

| Area | Candidate technology / status |
|---|---|
| Native app | Swift, SwiftUI — approved |
| Stylus | PencilKit — proposed |
| Playback | AVFoundation — proposed |
| Recognition | Vision/Core ML or constrained local recognizer — feasibility spike required |
| Animation | Rive or native alternative — proposed |
| Storage | SQLite/GRDB or appropriate native persistence — evaluate before adoption |
| Content | Versioned JSON; Python tooling — approved direction |
| Repository | Private GitHub monorepo — proposed, not yet created/verified |
| Synchronization | CloudKit or custom backend — deferred, not selected |
| Build and test | Xcode, Swift Testing/XCTest, physical iPad; TestFlight if appropriate |

Proposed data entities: curriculum objective, concept, lesson, activity, problem template, asset, learner profile, attempt, mastery evidence, recommendation and content version. Stable IDs, schema versioning, migration and deterministic generator seeds are mandatory design considerations. Define explicit module contracts before parallel coding. Do not execute arbitrary code embedded in curriculum packages. Keep secrets outside the repository and app bundles.

Nonfunctional targets to validate: reliable offline behavior, usable performance on target iPad, accessible touch targets, limited package size, reproducible content/builds, recoverable local state and bounded operating costs. Minimum iPadOS version and quantitative performance targets remain open.

## 10. Agent-driven delivery model

The owner provides decisions, design approval, access authorization and real-world feedback. The lead agent maintains scope, interfaces, backlog, dependencies and integration decisions. Agents are task roles, not already-running autonomous employees. Use ChatGPT Project for shared planning, ChatGPT Work when available for substantial research/content tasks, Codex for repository changes and testing, and image generation for approved creative assets. Availability, usage limits and permissions must be confirmed at execution time.

| Agent | Inputs | Outputs / completion gate |
|---|---|---|
| Lead architect | Blueprint, owner decisions | Architecture, task packets, ADRs, integration plan; owner approval of material choices |
| Curriculum | Official MOE documents | Source ledger and objective matrix; every mapping traceable |
| Education | Verified objectives, learner needs | Original scripts, CPA activities, assessments; independent review |
| iOS | Architecture, contracts, content fixtures | SwiftUI app and reusable widgets; compile and test evidence |
| Math engine | Objectives, assessment policy | Deterministic generators, validators, mastery logic; boundary and property tests |
| Data/tooling | Data contracts | Schemas, storage and content packaging; migration and validation tests |
| Creative | Approved brand/script | Character assets, illustrations, audio manifest; consistency and rights review |
| QA | Requirements, code, content | Independent tests, curriculum checks, defect reports; no unresolved critical defects |
| Release | Reviewed integrated build | Build instructions, signing/test evidence and private-beta checklist |

### Operating rules

- Each task packet specifies objective, source files, scope, dependencies, allowed changes, outputs, acceptance criteria and test commands.
- Use isolated branches/worktrees for parallel changes; avoid simultaneous ownership of the same files. Lead agent defines shared contracts first.
- Agents must read the current blueprint and repository AGENTS.md before editing. Do not override approved decisions silently.
- Record assumptions, source citations, commands actually executed, test outcomes and blockers. Never claim a build, test, deployment or review that did not occur.
- Each deliverable receives independent review; unresolved correctness issues block release. Owner approves material scope changes, expenses, service connections and public deployment.
- Use pull requests and review diffs; merge only after required checks. No credentials, personal child records or unlicensed assets in repository or agent prompts.
- No background execution is assumed; tasks are launched through supported tools and tracked through actual outputs. macOS/Xcode access and device signing cannot be replaced by source generation alone.

## 11. Proposed repository structure and shared records

```text
singapore-math-with-juni/
  PROJECT_BLUEPRINT.md
  AGENTS.md
  DEVELOPMENT_ROADMAP.md
  PROJECT_STATUS.md
  app/
  curriculum/
  schemas/
  assets/
  audio/
  tools/
  tests/
  docs/
    ARCHITECTURE.md
    decisions/
  references/
    CURRICULUM_MASTER.md
```

Keep source references and provenance rather than redistributing third-party PDFs without rights. Use Git history for version control, a task tracker for ownership and status, and architecture decision records (ADRs) for significant changes. Track large media separately if appropriate. This structure is a proposal, not an existing repository.

## 12. Delivery roadmap and gates

| Sprint | Work | Exit gate |
|---|---|---|
| 0 | Blueprint, agent instructions, roadmap, environment/repository setup | Owner-approved scope; runnable agent task plan and access verified |
| 1 | Official curriculum verification and mapping, first-unit selection | Source-backed objective matrix; initial unit mapped and reviewed |
| 2 | Architecture, schemas, recognition spike, test fixtures | Agreed interfaces; validated fixture; recognition fallback demonstrated |
| 3 | Parallel app, math/data, content and media development | Independently reviewed modules using shared contracts |
| 4 | Integrate first complete lesson | Offline vertical slice on physical iPad; basic progress and workbook work |
| 5 | Complete unit and assessments | Every scoped objective taught and assessed; reviewed audio and content |
| 6 | Quality, accessibility, regression and privacy checks | All beta gates met; remaining noncritical issues documented |
| 7 | Private beta and owner feedback | Observed usability and learning evidence; prioritized revisions |

After beta, expand P1, reassess publishing readiness, then extend P2–P6 and enrichment. Cloud sync and studio are separate later investments. Sprints denote dependency stages, not promised dates.

### Beta release gate

- All scoped learning objectives traceable to verified sources, with original reviewed lessons and independent assessments.
- All installed lessons, audio, activities, handwriting fallback and local reporting function offline; completion survives relaunch.
- No critical mathematical, privacy, data-loss or crash defects; automated tests and device checks recorded.
- Parent controls and reporting behave as specified; no live AI or mandatory cloud calls.
- Owner approves character, narration, first-unit experience and installation on the target device.
- Private-beta feedback is recorded with minimal personal data; no claim of proven learning efficacy based on one child.

## 13. Privacy, costs and risks

Local-first, data-minimizing design. Use a local learner alias where possible; do not sync raw handwriting or detailed child records by default. Parent controls must protect settings and external actions. Before public distribution, assess applicable child privacy law (including COPPA where relevant), App Store children's app requirements, consent, retention/deletion, analytics, security and vendor licensing; obtain appropriate professional review. Optional cloud sync needs a separate threat model and opt-in design.

Cost drivers: agent usage, Mac/build access, Apple developer distribution, voice generation, animation licensing, media storage and future hosting. No amounts or subscriptions approved; obtain owner approval before spending. Offline inference costs should be zero in normal child usage, but development, distribution and maintenance are not free.

| Risk | Mitigation |
|---|---|
| Incorrect curriculum interpretation | Verify primary sources, maintain coverage and independent educator review. |
| Unreliable handwriting recognition | Early device spike, constrained answers, confirmation and keypad fallback. |
| Agent integration conflicts | Shared contracts, isolated worktrees, scoped tasks and independent review. |
| Content production exceeds capacity | Reusable templates, validator, one-unit release and controlled expansion. |
| No usable Mac or signing setup | Verify development environment before promising an installable build. |
| Inconsistent mascot or licensing | Approved reference sheet, rights ledger and asset versioning. |
| Child privacy exposure | Minimize local data, no default cloud/analytics, security and release review. |
| Overstated learning effectiveness | Track independent evidence and observe beta without claiming clinical/educational validation. |

## 14. Open decisions and immediate next action

Open: confirmed Mac/Xcode and target device access; GitHub repository and agent access; Education approval of the first-unit specification; final mascot/art/voice; persistence and animation libraries; content schema; mastery thresholds; precise lesson duration; privacy and release policy; budget; iPadOS deployment target. Do not treat these as approved merely because a candidate appears here.

**Next deliverable: AGENTS.md**, establishing execution rules and task handoff format. Follow with DEVELOPMENT_ROADMAP.md and PROJECT_STATUS.md, then launch the curriculum verification and architecture work in the appropriate supported environments. The owner should add this blueprint to the ChatGPT Project and later commit the approved version to the repository. No external repository, agent process, curriculum verification, app build or cloud connection has been created by this document.

## 15. Change control

This blueprint is the product baseline once approved. The lead agent proposes changes with rationale, impact, alternatives and acceptance criteria. Owner approves changes to scope, cost, policy or user experience. Update version, decision register and dependent documents. Preserve prior decisions in Git history. If a conflict arises, follow the latest explicitly approved decision and record the reconciliation rather than silently guessing.
