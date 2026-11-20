# Codex dispatch packets
Read AGENTS.md, docs/PROJECT_BLUEPRINT.md, docs/PROJECT_STATUS.md and docs/ARCHITECTURE.md before work. No child data, paid provisioning or remote changes beyond authorized repo. Return task ID, branch, commit, commands/results, changed paths, blockers and review request.

## ENV-001 local environment verification

Use the dedicated task branch. Record macOS and tool versions, Xcode SDKs, read-only GitHub access and repository status, simulator runtime and device inventories, and signing readiness. Run `swift test --package-path app/JuniCore` and report the host test results. Update [environment evidence](environment.md) and [project status](PROJECT_STATUS.md) for Lead review. ENV-002 requires ENV-001 acceptance.

## IOS-001 review task
Review docs/ARCHITECTURE.md against blueprint, first-unit and actual curriculum inventory. Find contradictions in state transitions, range-specific mastery, offline threat model, module boundaries and acceptance criteria. Return findings with line references. No canonical schema or mastery thresholds until DATA-001 and MATH-000 reconciliation; LEAD-002 freezes contracts.

## Subsequent gated tasks
DATA-001: versioned schemas and positive/negative fixtures, once CUR-002 accepted and IOS-001 draft available. MATH-000: deterministic scoring/evidence contract after CUR-003 accepted and DATA-001 draft. ENV-002: Xcode skeleton and CI after ENV-001 accepted. EDU-001: U07 original teaching package after CUR-003 and DATA-001 accepted. No dependency override. Independent reviewer records evidence before acceptance.
