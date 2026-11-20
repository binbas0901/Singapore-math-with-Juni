# Singapore Math with Juni — Product Design
Version 1.1 | 2026-11-19 | Owner-approved design directions; specification pending integration review

## 1. Purpose and authority

A calm, premium Montessori-inspired interactive mathematics school for iPad, with Juni as a friendly, voice-led teacher. Teach mathematical understanding and reasoning, not merely answer selection. This document consolidates the owner's twenty product-design choices from the design conversation. It extends D01–D13 in [PROJECT_BLUEPRINT.md](PROJECT_BLUEPRINT.md); it does not silently change the approved first-unit release scope, curriculum authority, architecture contracts or educational review gates. See [DEVELOPMENT_ROADMAP.md](DEVELOPMENT_ROADMAP.md), [ARCHITECTURE.md](ARCHITECTURE.md) and [first-unit.md](first-unit.md). The PD identifiers below identify decisions, not additional accepted roadmap tasks.

## 2. Approved product decision register

| ID | Area | Approved direction | Implementation meaning |
|---|---|---|---|
| PD-01 | Teacher voice | Friendly female teacher | Warm, clear, patient, expressive, not excessively childish; consistent ElevenLabs voice across levels; prerecorded local audio. |
| PD-02 | Teaching | Hybrid interactive teaching | Brief explanation, demonstration, participation, feedback, independent work and mastery; avoid long passive lectures. |
| PD-03 | Visual identity | Premium Montessori | Warm cream, tactile wooden materials, restrained color, dimensional illustrations and calm interface. Moon-only brand, no stars. Final palette/assets pending. |
| PD-04 | Lesson layout | Compact teacher header | Juni, concise instructions, replay and narration controls at top; mathematics owns the main workspace. |
| PD-05 | Journey | Guided learning with exploration | Recommended next lesson plus browsable curriculum, subject to parent controls and evidence-based progression. |
| PD-06 | Duration | 10–15 minute adaptive guided lessons | Shorten or extend based on readiness and evidence; pause/resume; no time-based mastery or forced completion. |
| PD-07 | Demonstration | Animated objects plus virtual teaching hand | Synchronized cue-driven movements, highlights and gesture demonstrations; hand appears only when mathematically useful. |
| PD-08 | Assistance | Progressive intelligent assistance | Retry, visual hint, guided interaction, reteaching, fresh independent item; distinguish assisted evidence. |
| PD-09 | Workbook | Hybrid | One focused problem during guided instruction; multi-question sheets for independent practice and assessment; saved working, pen, eraser, undo/redo. |
| PD-10 | Manipulatives | Guided tools and Math Lab | Shared interactive components for lessons and free exploration; lab use does not automatically earn mastery. |
| PD-11 | Motivation | Mastery and Juni's Garden | Moon-phase evidence plus optional decorative garden items earned through genuine understanding; no currency, streak penalties, ads or leaderboards. |
| PD-12 | Parent experience | Complete parent control center | Evidence, errors, retention, saved ink, assignments, goals, levels, enrichment, revision and home activity suggestions; advanced features phased. |
| PD-13 | Orientation | Adaptive dual orientation, landscape-first | Landscape optimized for demonstrations/lab; portrait for workbook/reading; support both with preserved state and narration. |
| PD-14 | Placement | Hybrid diagnostic | Parent selects approximate level; adaptive friendly assessment recommends starting point; skip/manual override permitted; skips require equivalent independent evidence for mastery. |
| PD-15 | Enrichment | Depth and acceleration | Optional reasoning, puzzles, multiple solutions, word problems and progression above level when ready; clearly distinguish core/enrichment. |
| PD-16 | Character | Expressive animated teacher | Speaking, waiting, thinking, encouraging, correcting, celebrating and attentive states; compact presence, reduced-motion alternative. Attentive does not imply microphone listening. |
| PD-17 | Sound | Voice plus tactile effects | Natural bead clicks, counters, block placement and gentle confirmation; independent voice/SFX controls; no continuous music in lessons. |
| PD-18 | Routine | Personalized flexible daily plan | Recommended warm-up/review, new lesson, independent practice and optional challenge; configurable duration, no punishment for absence. |
| PD-19 | Adaptation | Concept-based adaptive intelligence | Change representation, scaffolding or reasoning complexity using errors, hint use and independent/retention evidence; not merely number size. |
| PD-20 | Navigation | Five sections | Home, Explore, Math Lab, Workbook, Garden; separately protected Parents entry. |

## 3. Information architecture and screens

| Destination | Intended experience |
|---|---|
| Home | Continue interrupted session; recommended personalized learning plan; review due; short welcoming message. |
| Explore | Level/strand/unit/topic hierarchy; evidence-based moon labels; distinguish unavailable, core and challenge content; parent-controlled exploration. |
| Math Lab | Free manipulation of installed tools with optional guidance, separate from scored assessment. |
| Workbook | Guided single-item working and independent multi-item worksheets; handwriting tools and saved work; supported answer confirmation/keypad. |
| Garden | Optional quiet creative space with mastery-earned decorations; no interruption to mathematics. |
| Parents | Protected entry separate from five child destinations; local evidence and assignments/settings; future optional synchronization. |
| Lesson runtime | Compact Juni header, concise instruction/transcript, replay, pause, progress and exit; main mathematical workspace, explicit submission when applicable; accessible alternative interactions. |

Layout behavior: landscape-first, with portrait reflow, not rotation-dependent content loss. Preserve item seed, counters, answer, hint state, ink and narration continuity on rotation; explicit user pause and operating-system interruption behavior follow runtime contracts. Avoid fixed side panels that reduce mathematical space. Navigation sketches from the conversation were illustrative; no approved final screen assets exist.

## 4. Learning experience

Typical lesson: discover → watch/understand → learn together → your turn → show what you know. The sequence supports readiness, engagement and mastery, using concrete–pictorial–abstract (CPA) when appropriate, not a compulsory three-step ritual for every task. Include explanation, manipulation, representation, reasoning and application. Target 10–15 minutes flexibly (supersedes earlier suggested 8–12 minute planning target; no hard duration cap or grading rule). Adaptation and breaks may shorten or extend a session.

First-unit illustration (U07; final educational approval still required): show six counters; Juni demonstrates moving two into a bowl; child performs a split and identifies the remaining four; connect to whole/part diagram; fill missing part; independent new whole eight and known part three; explain with drawing or counters. Formal operation notation introduced only in the appropriate curriculum sequence. This is a storyboard example, not approved lesson copy or a new curriculum objective.

Assistance ladder: neutral retry; reveal a relevant representation; guide an action; reteach with an explanation; offer a fresh independent item. The content/engine decides transitions from observed evidence. Do not assume every error diagnoses a misconception. Incorrect attempts are not punished; recognition uncertainty is confirmed before grading. Independent assessment must not reveal answers; request for a hint creates assisted evidence and a fresh independent check. Exact mastery thresholds, placement cutoffs, review intervals and adaptation rules await MATH-000, owner/education review and test fixtures.

Proposed moon labels from blueprint: new/not introduced, crescent/emerging, half/assisted, gibbous/independent, full/retained. Include text labels; never score speed, repetition of exposed answers, free play or completion as mastery. Garden unlock rules must use genuine evidence and avoid loss or monetization; exact economy/decoration mechanisms not approved.

## 5. Voice, animation and tactile interaction

- ElevenLabs generates original narration in production, not on the learner device at runtime. Deliver local versioned audio with transcript, asset ID, locale, rights record and hash. Voice audition, commercial rights, budget and actual recordings still require approval. Do not use a child's likeness or voice.
- Scripts include introduction, demonstration, guidance, correction, remediation and summary, with varied common prompts. State-based playback selects appropriate approved clips; no live AI tutor, network or microphone requirement.
- Associate timeline cue IDs/times with deterministic mathematical actions, highlights and teaching hand gestures. For demonstrations, block conflicting inputs or explicitly separate observe and try states; reset to a deliberate valid starting state before independent attempts. Pause/replay must not corrupt mathematical state or duplicate scoring. Synchronization approach is a proposed implementation contract to validate, not an existing feature.
- Juni remains in a compact header with speaking/idle/encouragement/etc. expressions; support captions, replay, mute and reduced motion. Narration must not obscure essential text or depend on hearing alone.
- Teaching hand shows purposeful gestures with plausible anatomy, direction and contact point; never obscures mathematical targets. Use separate reusable hand states and a static/accessible fallback. Final character style, hand assets and animation technology require design review.
- Tactile SFX reinforce spatial interactions without competing with narration; separate controls; no continuous background music during lessons.

## 6. Mathematical tools and workbook

Shared tool inventory direction: counters, abacus, ten-frame, number bond, bar model, base-ten blocks, number line, fractions, clock; other curriculum-driven manipulatives later. First unit uses only the necessary subset, not all eight tools. Exact bead conventions, movement rules and mathematical invariants are educational/component requirements; do not infer a specific abacus convention from aesthetic references. Lab and lesson reuse the same mathematical state model; no mastery inference from free exploration.

Workbook: large writing area; single item during guided instruction, sheets for independent practice/assessment; save and reopen ink; undo/redo/erase; distinguish scratch working and final response. Supported numerical recognition is on-device with confirmation and keypad fallback; no recognition error becomes a math error. No automatic interpretation of arbitrary worked solutions implied. Parent review is protected and local. Multi-question sheet layout, writing ergonomics and left/right-handed use to be prototyped.

## 7. Visual and accessibility design

Approved aesthetic: premium Montessori, not a busy game. Proposed palette (not final): cream #FAF5E9, wood #D5AE7C, teal #558C85, lavender #BDB0DB, moonlight #F2CE78, midnight #303E50. Test text contrast rather than using arbitrary palette pairs; consistent typography, large targets, restrained animation, clear focus labels, scalable layout, touch alternatives to drag/handwriting, accessible transcripts and non-color mastery labels. No stars. No unlicensed assets; source references and actual final asset rights documented separately.

## 8. Delivery boundaries

Existing roadmap and owner-approved initial scope remain authoritative. A complete first P1 unit with a single lesson vertical slice first; offline installed content, local progress, basic protected parent dashboard. Final navigation should accommodate the complete vision; unavailable sections/tools must be clearly labeled or withheld rather than pretend to be functional.

| Stage | Design execution |
|---|---|
| Before lesson UI implementation | High-fidelity home and U07 lesson flow, workbook, navigation and core reusable components; visual system; state/interaction storyboard; owner review; reconcile with IOS-001, DATA-001, MATH-000 and LEAD-002. |
| Vertical slice / initial unit | Required teaching header, voice replay/captions, limited mathematical tools, progressive guidance, handwriting/fallback, local evidence, resume, basic parent views. Validate physical iPad and offline operation. |
| After core validation | Expand Math Lab and worksheets, diagnostic/daily recommendation breadth, parent analytics/control, Garden decorations, advanced enrichment, additional tools and grades. Exact sequencing and beta inclusion changes require explicit roadmap approval. |
| Later | Optional phone/cloud synchronization, public release, complex handwriting, full curriculum studio and other previously deferred capabilities. |

The complete parent control center, Garden and broad tool catalog are approved long-term design directions, not newly mandated initial-beta deliverables. Design does not authorize paid media, hosted CI, publication, network activity in the child app or new data collection. Do not alter the 34-task ledger or task acceptance counts solely because these decisions are recorded; Lead must reconcile roadmap impacts with ongoing curriculum/architecture work without conflicting writes.

## 9. Design verification and next steps

Proposed review checklist:
- All PD-01–20 represented; D01–D13, source provenance and release gates retained.
- High-fidelity layouts readable in both orientations; large usable math workspace; no distracting teacher animation.
- Storyboard demonstrates narration, cue timing, interactions, correction escalation, recognition fallback, fresh independent check and pause/resume.
- Confirm mathematical invariants and learning progression with Education reviewer; confirm interfaces with engineering.
- Obtain owner approval of final visual system, character, voice samples and screen designs before production implementation; independently review rights and accessibility.
- Integrate through reviewed PR; no implementation or test claims from this documentation alone.

Open decisions: exact visual assets/palette/typography, voice and license/budget, narration cue format and animation technique, mastery/diagnostic/retention thresholds, Garden reward specifics, precise rollout of advanced features, and orientation/audio behavior under actual interruptions. All require validation, not silent assumptions.

## Owner-approved character refinement — 2026-11-19

The owner replaced crescent-moon Juni with a friendly **full-moon character** and approved the revised visual concept in the design conversation. Use a warm golden round moon, subtle lunar craters, expressive eyes and a friendly face in the premium Montessori style. No stars or human mascot. This refines PD-03 and PD-16; it does not change the five moon-phase mastery indicators, the female ElevenLabs teacher voice, or lesson scope. Update the older crescent-moon home mockup accordingly. Production character assets, expression consistency, lip sync, visual fidelity, accessibility and rights review remain open. The approved illustrative reference is held in the conversation; no production asset is asserted in this repository.
