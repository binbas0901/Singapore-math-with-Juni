# Singapore Math with Juni

Read [AGENTS.md](AGENTS.md) and the [task records](docs/CODEX_TASKS.md) for the repository workflow. The original MOE syllabus PDF is excluded from this private repository.

Open `app/Juni.xcodeproj` in Xcode, select the shared `Juni` scheme and an iPad simulator, then run the SwiftUI welcome screen. The project links the exploratory `app/JuniCore` package locally.

Run `swift test --package-path app/JuniCore` for the portable package tests. See the [ENV-002 verification record](docs/qa/env-002.md) for the build and simulator test commands.
