# Home screen — visual implementation brief
Version 0.2 | 2026-11-19 | First concept positively received by owner; production layout and assets pending review.

Companion to [PRODUCT_DESIGN.md](PRODUCT_DESIGN.md), PD-03, PD-05, PD-13, PD-18 and PD-20. Design-only; not authorization to start downstream implementation or waive curriculum/architecture gates.

## Reference
The generated home screen concept in the project design conversation (the owner called it amazing) is the visual target. Original PNG: 1536 × 1024, SHA-256 `3fce16c3bfc7f3649db25d00dd9cb8e0007cdac4ceeb4080fc819fdf2c121c0d`. The binary is held in the conversation, not yet in Git; an implementation agent needs the reference file. Do not fabricate a repo image path or use the screenshot as the live UI. Its 3:2 proportions are not the actual target iPad viewport.

## Hierarchy and layout
- Landscape-first iPad layout, responsive to safe areas, size classes and portrait.
- Header: exact app name, moon symbol, secondary descriptive tagline (copy not final), protected Parents action at right. Remove ornamental leaves if they compromise moon-only identity.
- Hero: warm, softly lit Montessori desk/room; restrained cream/sage panel; recommended daily plan with current topic, review/learn/practice/optional challenge, one strong Continue action, truthful estimated duration; expressive Juni on the right near natural wood manipulatives. Main action must not be obscured by art.
- Four destination cards in a landscape row: Explore (number tiles), Math Lab (counters/blocks), Workbook (paper and pencil), Garden (small plant and moon). Use readable concise labels; cards reflow to a suitable grid in portrait. Keep artwork distinct from interactive hit targets. These duplicate navigation entry points intentionally in the concept.
- Persistent bottom navigation: Home, Explore, Math Lab, Workbook, Garden. Selected state clear via shape, label and contrast, not only color. Parents separate and protected.
- Preserve warm ivory, muted teal, lavender, natural wood and moonlight gold. Colors/typography/spacing tokens remain proposals pending visual/accessibility review.

## Implementation approach (proposed)
Use native SwiftUI layout and accessible controls. Separate illustration layers (background, mascot, props/card art) from live text, buttons, navigation and state. Art should be original and reusable, optimized for device memory. No flattened screenshot, embedded text, or generated bitmap of the entire interface as production UI. Start from static mascot with a replaceable expression/animation adapter. Native controls adapt to Dynamic Type, VoiceOver, reduced motion and orientation. Render no personal identifiers from the reference or fixtures.

App state drives home: loading; no learner plan; resume interrupted lesson; recommended plan; review due; unit complete; unavailable content; recoverable storage error. A daily plan's duration is an estimate, not a fixed promise, and challenge is optional. Show only actually installed and implemented content; future regions clearly unavailable or withheld, per approved beta scope. No fake mastery, completion, unlocked decorations or parent statistics.

## Visual quality gates
- Compare side by side with reference at physical 13-inch target size and simulator; check hierarchy, warm dimensional art, generous spacing, layout and legibility rather than pixel matching a 3:2 image.
- Verify portrait/landscape, safe areas, larger text, VoiceOver reading order, 44pt baseline touch areas, contrast, reduced motion and navigational clarity.
- Check all example mathematical visuals for correctness (including count consistency in the workbook art), and confirm actual abacus convention with Education before depicting a teaching tool.
- Test each enabled destination/action, resume and duration states using fixtures; no dead controls disguised as working features. Physical device performance and offline behavior tested later.
- Review final mascot, assets, product copy and home screen mockup with owner before code; complete lesson storyboard and component designs, independent review and roadmap/contract reconciliation before production UI work.

Open: final character model, asset export pipeline, exact typefaces and color tokens, portrait layout, availability treatment for future features, final microcopy, verified target device dimensions/performance. No application code, paid assets, external audio or new task counts are authorized by this brief.

## Character refinement

The owner approved full-moon Juni after the original home screen mockup. Replace the crescent mascot in that illustration with the approved warm golden full moon; retain the layout, Montessori materials and navigation. The older reference is useful for layout only, not the final mascot silhouette. Do not replace the live native interface with the generated reference image. Separate character art from programmatic mathematical objects and native controls. Production character assets and actual device screenshots remain outstanding.
