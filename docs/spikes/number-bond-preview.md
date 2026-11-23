# Number-bond lesson preview

Run the Debug app with `-number-bond-preview u07` for the accepted lesson or `-number-bond-preview synthetic-demo` for the clearly labeled captions-only demonstration. The U07 Preview scheme still accepts `-u07-preview`.

| Preview | Observe | Try | Check |
| --- | --- | --- | --- |
| U07 | 6 = 2 + 4 | 7 = 1 + 6 | 8 = 3 + 5 |
| Synthetic demonstration | 5 = 1 + 4 | 6 = 2 + 4 | 9 = 2 + 7 |

To add a third preview, copy a definition into [NumberBondLessons](../../app/Juni/NumberBondLessons) and give it a unique ID matching the filename. Set the whole, known part and expected answer for each stage. Give Check its own split, including when the parts are swapped. Author the Observe captions and ordered cues for moving counters, counting, linking the groups and recombining. Update the guided prompts and completion feedback to match. Launch with `-number-bond-preview <id>`. The app picks up the JSON from the bundled folder and uses the same view.

Local clip references are optional. For a narrated preview use lesson-prefixed M4A filenames in the existing [narration folder](../../app/Juni/U07Narration), with a cue-offset sidecar for each multi-cue Observe clip. Check entry, answer entry and retry use fixed wording populated from the Check quantities. The accepted U07 clips remain bound to the original Check question. Additional previews use captions for those three prompts. Review free-text teaching captions and recordings for semantic disclosure before using them with learners.

This preview projection follows the [DATA-001 contract](https://github.com/binbas0901/Singapore-math-with-Juni/pull/9) for missing-part arithmetic, typed counter cues, a fresh Check and separate guided and independent workspaces. DATA-001 still owns distributable packages, source and review records, exposure, and submission contracts. The preview records no mastery credit.
