# ENV-001 — Development environment and evidence
Version 1.0 | 2026-11-17 | Blocked on external access

Observed in current execution: Linux x86_64, Swift 6.2.1, Git 2.47.3, Python 3.13.5. No codex, gh or xcodebuild executable on PATH. No authenticated GitHub repository or Codex task access exposed. Local Git initialization and Swift package smoke test are separately recorded in bootstrap-evidence.txt. This is not a native iPad build.

## Workflow
1. Owner connects GitHub to Codex, authorizes a private repository named singapore-math-with-juni. Import the supplied bootstrap tree; never publish the official PDF or child data. Review access scope. Do not purchase services.
2. On web/desktop, open https://chatgpt.com/codex, select Cloud, create environment, select repository, let Codex inspect and prepare tools, review and publish. Mobile may use a published environment. See https://learn.chatgpt.com/docs/environments/cloud-environments and https://help.openai.com/en/articles/20001545-using-codex-cloud (checked 2026-11-17).
3. Run the first task in CODEX_TASKS.md; require tool versions, swift test, git status, branch and evidence. Separate tasks use separate branches/workspaces; reviewed PRs merge to main. No force push or automatic merge.
4. Use a Mac with compatible Xcode for native builds, simulator and signing. A private macOS CI runner is an alternative for unsigned simulator builds, subject to owner authorization and budget. Physical iPad/Pencil tests still necessary. Record xcodebuild -version, xcrun simctl list devices available, iPadOS version and stylus compatibility. Do not collect device serials.
5. ENV-002 creates Xcode project and CI, verifies clean checkout build and smoke test; use automatic development signing with authorized Apple account for direct device install, or separately approved TestFlight membership/distribution. No signing keys in Git.

## Costs and blockers
No spending incurred here. Codex limits depend on account; inspect actual allowance. GitHub hosting/CI quotas, Mac access and Apple program fees require owner verification before commitment. No runtime AI expense. Remote access, repository permissions, native build host, device OS and signing remain unverified. Proposed iPadOS 17 minimum subject to device check. ENV-001 cannot be accepted until actual access evidence is available.
