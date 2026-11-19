# Codex dispatch packets
Read AGENTS.md, docs/PROJECT_BLUEPRINT.md, docs/PROJECT_STATUS.md and docs/ARCHITECTURE.md before work. No child data, paid provisioning or remote changes beyond authorized repo. Return task ID, branch, commit, commands/results, changed paths, blockers and review request.

## First task: ENV-001 remote capability verification
Inspect repository permissions without destructive operations; record OS, swift --version, python3 --version, git --version and xcodebuild availability. Run `swift test --package-path app/JuniCore`. Report actual results and whether Mac/device signing path exists. Do not claim iPad build success on Linux. Update evidence in docs/environment.md on a dedicated branch, submit review. Do not start ENV-002 until ENV-001 accepted.

## IOS-001 review task
Review docs/ARCHITECTURE.md against blueprint, first-unit and actual curriculum inventory. Find contradictions in state transitions, range-specific mastery, offline threat model, module boundaries and acceptance criteria. Return findings with line references. No canonical schema or mastery thresholds until DATA-001 and MATH-000 reconciliation; LEAD-002 freezes contracts.

## Subsequent gated tasks
DATA-001: versioned schemas and positive/negative fixtures, once CUR-002 accepted and IOS-001 draft available. MATH-000: deterministic scoring/evidence contract after CUR-003 accepted and DATA-001 draft. ENV-002: Xcode skeleton and CI after ENV-001 accepted. EDU-001: U07 original teaching package after CUR-003 and DATA-001 accepted. No dependency override. Independent reviewer records evidence before acceptance.
