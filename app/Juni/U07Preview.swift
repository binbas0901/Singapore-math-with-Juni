#if DEBUG
import AVFoundation
import JuniCore
import SwiftUI

struct U07Preview: View {
    private enum Page: String {
        case observe = "Observe"
        case tryIt = "Try"
        case check = "Check"
        case completion, review
    }

    // Nominal cue keys also define the captions-only schedule.
    private enum DemoStep: Int, CaseIterable {
        case intro, count, whole, first, second, otherGroup, countTray, bond, recombine, ready

        var start: Int { [0, 5, 12, 19, 22, 26, 32, 38, 49, 60][rawValue] }

        var clipID: String {
            "u07-observe-" + ["intro", "count", "whole", "first", "second", "other-group",
                              "count-tray", "bond", "recombine", "ready"][rawValue]
        }

        var nextStart: Int { DemoStep(rawValue: rawValue + 1)?.start ?? Self.end }
        var cues: [Int] { Self.cues.filter { (start..<nextStart).contains($0) } }
        var quiet: TimeInterval { self == .otherGroup ? 2 : self == .whole ? 1 : 0.5 }

        var caption: String {
            switch self {
            case .intro: "Let’s count the counters in this tray."
            case .count: "One, two, three, four, five, six."
            case .whole: "Six is the whole. That means all the counters. Watch me split them into two groups."
            case .first: "One into the bowl."
            case .second: "One more into the bowl. Two in the bowl."
            case .otherGroup: "The tray is our other group. How many are there?"
            case .countTray: "One, two, three, four. Four in the tray."
            case .bond: "Two in the bowl. Four in the tray. Two and four make six. This picture is a number bond."
            case .recombine: "Let’s put the two back. One, two, three, four, five, six. We still have six!"
            case .ready: "Ready to make your own split? Tap Try."
            }
        }

        static let end = 64
        static let cues = (
            allCases.map(\.start) + Array(6...10) + [20, 23, 33, 34, 35, 40, 42, 51]
            + Array(52...57) + [end]
        ).sorted()
    }

    private struct DemoFrame: Equatable {
        var time = 0
        var manual = true
        var countIndex = 0
        var waitingForFirstCue = false

        var step: DemoStep { DemoStep.allCases.last { $0.start <= time } ?? .intro }
        var bowl: Set<Int> {
            if manual {
                switch step {
                case .first: return [1]
                case .second, .otherGroup, .countTray, .bond: return [1, 2]
                default: return []
                }
            }
            switch time {
            case 20..<23: return [1]
            case 23..<51: return [1, 2]
            default: return []
            }
        }

        var historical: Bool { manual ? step.rawValue >= DemoStep.recombine.rawValue : time >= 51 }
        var canTry: Bool { manual ? step == .ready : time == DemoStep.end }

        var countOrder: [Int] {
            switch step {
            case .count, .recombine: Array(1...6)
            case .countTray: Array(3...6)
            default: []
            }
        }

        var indicatedCounter: Int? {
            if step == .first { return bowl.contains(1) ? 1 : nil }
            if step == .second { return bowl.contains(2) ? 2 : nil }
            if manual {
                return countOrder.indices.contains(countIndex) ? countOrder[countIndex] : nil
            }
            if waitingForFirstCue { return nil }
            switch time {
            case 5..<12: return min(time - 4, 6)
            case 32..<38: return min(time - 29, 6)
            case 52..<60: return min(time - 51, 6)
            default: return nil
            }
        }

        var canCountNext: Bool { manual && countIndex + 1 < countOrder.count }

        var indicatedWord: String? {
            guard let indicatedCounter, let index = countOrder.firstIndex(of: indicatedCounter) else {
                return nil
            }
            return ["One", "Two", "Three", "Four", "Five", "Six"][index]
        }

        var linkedGroups: Set<CounterGroup> {
            switch step {
            case .whole: [.tray]
            case .otherGroup: [.tray]
            case .bond where manual: [.tray, .bowl]
            case .bond:
                time < 40 ? [.bowl] : time < 42 ? [.tray] : [.tray, .bowl]
            case .recombine where !historical: [.tray, .bowl]
            default: []
            }
        }
    }

    private let ink = Color(red: 0.14, green: 0.21, blue: 0.31)
    private let paper = Color(red: 0.98, green: 0.96, blue: 0.91)
    private let teal = Color(red: 0.12, green: 0.35, blue: 0.34)

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var page: Page?
    @State private var resumePage: Page?
    @State private var animateCelebration = false
    private let celebrationMessage = Prompt.checkSuccess.caption
    @Environment(\.scenePhase) private var scenePhase
    @State private var demo = DemoFrame()
    @State private var demoPosition: TimeInterval = 0
    @State private var failedAudioStep: DemoStep?
    @State private var demoRun: UUID?
    @State private var narration: AVAudioPlayer?
    @State private var promptPaused = false

    private var playing: Bool { demoRun != nil }
    @State private var guided = Working(isGuided: true)
    @State private var independent = Working()
    @State private var trayFrame = CGRect.zero
    @State private var bowlFrame = CGRect.zero
    @GestureState private var dragLocation: CGPoint?
    @Namespace private var demoCounters

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                if let page {
                    if page != .completion && page != .review {
                        header
                        navigation(page)
                    }
                    switch page {
                    case .observe: observe
                    case .tryIt: workspace(guided: true, work: $guided)
                    case .check: workspace(guided: false, work: $independent)
                    case .completion: completion
                    case .review: completedWork
                    }
                } else {
                    welcome
                }
            }
            .frame(maxWidth: 1320)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
        }
        .id(page)
        .overlay {
            if let dragLocation {
                GeometryReader { geometry in
                    let origin = geometry.frame(in: .global).origin
                    counter(false)
                        .position(x: dragLocation.x - origin.x, y: dragLocation.y - origin.y)
                }
                .allowsHitTesting(false)
                .accessibilityHidden(true)
            }
        }
        .background(paper.ignoresSafeArea())
        .foregroundStyle(ink)
        .tint(teal)
        .preferredColorScheme(.light)
        .onChange(of: scenePhase) { _, phase in
            if phase != .active { pauseNarration() }
        }
        .onReceive(NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification)) { note in
            if note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt == AVAudioSession.InterruptionType.began.rawValue {
                pauseNarration()
            }
        }
        .onDisappear {
            pauseDemo()
            stopPrompt()
        }
        .onChange(of: PromptContext(page: page, prompt: activePrompt)) { previous, next in
            if previous.page != next.page && next.page != .observe { pauseDemo() }
            stopPrompt()
            if next.page == .completion && previous.page != .check { return }
            if let prompt = next.prompt { playPrompt(prompt) }
        }
    }

    private var welcome: some View {
        VStack(spacing: 20) {
            JuniMoon().frame(width: 190, height: 190)
            Text("Singapore Math with Juni")
                .font(.largeTitle.bold())
                .accessibilityAddTraits(.isHeader)
            Text("Split a whole")
                .font(.system(.largeTitle, design: .rounded, weight: .heavy))
            Text("Move counters into two groups, then put them back together.")
                .font(.title3)
            if let resumePage {
                Text("Resume keeps your work. Start over clears this lesson.")
                    .font(.callout)
                Button("Resume") { page = resumePage }
                    .buttonStyle(PreviewButton(prominent: true))
                Button("Start Over") { startOver() }
                    .buttonStyle(PreviewButton())
            } else {
                Button("Start lesson preview") { startOver() }
                    .buttonStyle(PreviewButton(prominent: true))
            }
            Text("U07 lesson preview").font(.subheadline)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 55)
    }

    private func startOver() {
        stopPrompt()
        resetDemo()
        guided = Working(isGuided: true)
        independent = Working()
        resumePage = nil
        animateCelebration = false
        page = .observe
    }

    private func goHome() {
        pauseNarration()
        animateCelebration = false
        resumePage = page
        page = nil
    }

    private var completedBond: some View {
        bond(8, 3, independent.answer, title: "Your number bond",
             knownGroup: independent.bowl.count == 3 ? .bowl : .tray)
    }

    private var completion: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Group {
                    if animateCelebration && !reduceMotion {
                        CelebratingJuni()
                    } else {
                        JuniMoon(reaction: .delighted)
                    }
                }
                .frame(width: 156, height: 156)
                Text(celebrationMessage)
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier("check-celebration")
                promptControls(.checkSuccess)
            }
            completedBond
                .padding(20)
                .background(.white, in: RoundedRectangle(cornerRadius: 24))
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 12) { completionActions }
                VStack(spacing: 12) { completionActions }
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: 620)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    private var completionActions: some View {
        Group {
            Button("Play Again") { startOver() }
                .buttonStyle(PreviewButton(prominent: true))
            Button("See My Work") {
                animateCelebration = false
                page = .review
            }
            .buttonStyle(PreviewButton())
            Button("Back to Home") { goHome() }
                .buttonStyle(PreviewButton())
        }
    }

    private var completedWork: some View {
        VStack(alignment: .leading, spacing: 16) {
            Button("Back to Completion") { page = .completion }
                .buttonStyle(PreviewButton())
            Text("My Check work").font(.title2.bold()).accessibilityAddTraits(.isHeader)
            AdaptiveColumns {
                regions(whole: 8, bowl: independent.bowl, showCounts: true, work: nil, reviewing: true)
            } side: {
                completedBond
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(.white, in: RoundedRectangle(cornerRadius: 22))
            }
        }
    }

    private var header: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Split a whole").font(.title2.bold()).accessibilityAddTraits(.isHeader)
                Text("U07 lesson preview").font(.subheadline)
            }
            Spacer()
            Button("Home") { goHome() }
            .buttonStyle(PreviewButton())
        }
    }

    private func navigation(_ current: Page) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack { pageButtons(current) }
            VStack(alignment: .leading) { pageButtons(current) }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Lesson stages")
    }

    private func pageButtons(_ current: Page) -> some View {
        ForEach([Page.observe, .tryIt, .check], id: \.self) { stage in
            Button(stage.rawValue) {
                if stage != .observe { pauseDemo() }
                page = stage
            }
                .buttonStyle(PreviewButton(prominent: current == stage))
                .accessibilityAddTraits(current == stage ? .isSelected : [])
        }
    }

    private var observe: some View {
        let run = demoRun
        return VStack(alignment: .leading, spacing: 16) {
            teachingPrompt(demo.step.caption, identifier: "observe-caption", reaction: demoReaction)
            ViewThatFits(in: .horizontal) {
                HStack { demoButtons }
                VStack(alignment: .leading) { demoButtons }
            }
            AdaptiveColumns {
                regions(whole: 6, bowl: demo.bowl,
                        showCounts: demo.step.rawValue >= DemoStep.whole.rawValue,
                        hideTrayCount: (DemoStep.first.rawValue...DemoStep.countTray.rawValue).contains(demo.step.rawValue)
                            || (demo.step == .recombine && !demo.manual && demo.time < 57),
                        work: nil)
                    .frame(maxWidth: .infinity)
            } side: {
                VStack(spacing: 12) {
                    let showsParts = demo.step.rawValue >= DemoStep.bond.rawValue
                    if demo.step.rawValue >= DemoStep.whole.rawValue {
                        bond(6, showsParts ? 2 : nil, showsParts ? 4 : nil,
                             title: demo.historical ? "Our split" : "Number bond",
                             knownGroup: showsParts ? .bowl : nil, showParts: showsParts,
                             teaching: !demo.historical)
                    } else {
                        Color.clear.frame(height: 1).accessibilityHidden(true)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(.white, in: RoundedRectangle(cornerRadius: 22))
            }
        }
        .task(id: run) {
            guard let run else { return }
            await runDemo(run)
        }
    }

    private func runDemo(_ run: UUID) async {
        let clock = ContinuousClock()
        for step in DemoStep.allCases.dropFirst(demo.step.rawValue) {
            guard demoRun == run, page == .observe, !Task.isCancelled else { return }
            let fallbackDuration = Double(step.nextStart - step.start)
            let fallback = U07Narration.Timeline(cues: step.cues, fallbackDuration: fallbackDuration)
            var (timeline, player) = failedAudioStep == step ? (fallback, nil) : U07Narration.observe(
                step.clipID, cues: step.cues, fallbackDuration: fallbackDuration, quiet: step.quiet
            )
            if demo.manual {
                demoPosition = timeline.offset(for: manualCue)
            }
            narration = player
            let playback = player.map { U07Narration.ObservePlayback(player: $0) }
            if let player, demoPosition < player.duration {
                player.currentTime = demoPosition
                if !player.play() {
                    let cue = timeline.cue(at: demoPosition)
                    timeline = fallback
                    demoPosition = timeline.offset(for: cue)
                    failedAudioStep = step
                    narration = nil
                }
            }
            showDemo(timedFrame(timeline), animate: false)
            var previousTick = clock.now
            while demoPosition < timeline.duration {
                do {
                    try await clock.sleep(for: .milliseconds(25))
                    try Task.checkCancellation()
                } catch {
                    return
                }
                guard demoRun == run, page == .observe else { return }
                let now = clock.now
                let delta = previousTick.duration(to: now).components
                let elapsed = Double(delta.seconds) + Double(delta.attoseconds) / 1e18
                previousTick = now
                if let player = narration, let playback {
                    switch playback.tick(player: player, position: demoPosition, elapsed: elapsed, now: now) {
                    case .position(let position):
                        demoPosition = position
                    case .waitingForCompletion:
                        continue
                    case .stopped:
                        pauseDemo()
                        return
                    }
                } else {
                    demoPosition += elapsed
                }
                let frame = timedFrame(timeline)
                if frame != demo { showDemo(frame) }
            }
            narration?.stop()
            narration = nil
            demoPosition = 0
            failedAudioStep = nil
        }
        showDemo(DemoFrame(time: DemoStep.end, manual: false))
        demoRun = nil
    }

    private func timedFrame(_ timeline: U07Narration.Timeline) -> DemoFrame {
        DemoFrame(time: timeline.cue(at: demoPosition), manual: false,
                  waitingForFirstCue: demoPosition < timeline.offsets[0])
    }

    private var manualCue: Int {
        switch demo.step {
        case .count, .countTray: demo.step.start + demo.countIndex
        case .first: 20
        case .second: 23
        case .recombine: 52 + demo.countIndex
        default: demo.time
        }
    }

    private var demoReaction: JuniMoon.Reaction {
        switch demo.step {
        case .otherGroup: .thinking
        case .first, .second, .count, .countTray: .focused
        case .recombine where demo.historical: .delighted
        case .ready: .delighted
        default: .smiling
        }
    }

    private var demoButtons: some View {
        Group {
            Button(playing ? "Pause" : "Play") {
                if playing { pauseDemo() } else { playDemo() }
            }
            .buttonStyle(PreviewButton(prominent: true))
            .disabled(!playing && demo.time == DemoStep.end)
            Button("Replay") {
                resetDemo()
                playDemo()
            }
            .buttonStyle(PreviewButton())
            Button(demo.canCountNext ? "Count next" : "Next step") {
                if demo.canCountNext {
                    var frame = demo
                    frame.countIndex += 1
                    showDemo(frame, animate: false)
                    return
                }
                pauseDemo()
                failedAudioStep = nil
                if let next = DemoStep(rawValue: demo.step.rawValue + 1) {
                    demoPosition = 0
                    showDemo(DemoFrame(time: next.start), animate: false)
                } else {
                    demoPosition = 0
                    showDemo(DemoFrame(time: DemoStep.end), animate: false)
                }
            }
            .buttonStyle(PreviewButton())
            .disabled(demo.canTry)
            if demo.canTry {
                Button("Try together") { page = .tryIt }
                    .buttonStyle(PreviewButton(prominent: true))
            }
        }
    }

    private func resetDemo() {
        pauseDemo()
        failedAudioStep = nil
        demoPosition = 0
        showDemo(DemoFrame(), animate: false)
    }

    private func playDemo() {
        guard page == .observe, scenePhase == .active else { return }
        stopPrompt()
        demoRun = UUID()
    }

    private func pauseDemo() {
        guard playing else { return }
        demoRun = nil
        narration?.stop()
        narration = nil
    }

    private func pauseNarration() {
        pauseDemo()
        if narration != nil {
            narration?.pause()
            promptPaused = true
        }
    }

    private func showDemo(_ frame: DemoFrame, animate: Bool = true) {
        let announce = frame.step != demo.step
        let animation: Animation? = animate && !reduceMotion && frame.bowl != demo.bowl
            ? .easeInOut(duration: 0.38) : nil
        withAnimation(animation) { demo = frame }
        if announce && (frame.manual || narration == nil) {
            var message = frame.step.caption
            if frame.manual, let word = frame.indicatedWord {
                message += " " + word
            }
            AccessibilityNotification.Announcement(message).post()
        } else if frame.manual, let word = frame.indicatedWord {
            AccessibilityNotification.Announcement(word).post()
        }
    }

    private func teachingPrompt(
        _ prompt: String, identifier: String, reaction: JuniMoon.Reaction = .smiling
    ) -> some View {
        HStack(spacing: 18) {
            JuniMoon(reaction: reaction).frame(width: 84, height: 84)
            Text(prompt)
                .font(.system(.title2, design: .rounded, weight: .semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier(identifier)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background(.white, in: RoundedRectangle(cornerRadius: 24))
    }

    private enum Feedback {
        case correct, retry
    }

    private enum WholeVerification {
        case counting, retry, verified
    }

    private struct Working {
        var isGuided = false
        var bowl: Set<Int> = []
        var selection: Int?
        var answer: Int?
        var hasEnteredAnswer = false
        var feedback: Feedback?
        var verification: WholeVerification?
    }

    private struct PromptContext: Equatable {
        let page: Page?
        let prompt: Prompt?
    }

    private enum Prompt: String {
        case tryEntry = "try-entry", tryCount = "try-count", tryBond = "try-bond"
        case trySplit = "try-split", tryRecount = "try-recount", tryDone = "try-done"
        case tryRetry = "try-retry", tryMoveBack = "try-move-back", tryRecountRetry = "try-recount-retry"
        case checkEntry = "check-entry", checkAnswer = "check-answer", checkRetry = "check-retry"
        case checkSuccess = "check-success"

        var clipID: String { "u07-" + rawValue }

        var caption: String {
            switch self {
            case .tryEntry: "Here are seven counters. Move one from the tray to the bowl."
            case .tryCount: "The bowl has one. The counters in the tray are the other part. How many are in the tray?"
            case .tryBond: "Put that number in the empty part of the number bond."
            case .trySplit: "You made two groups. One and six make seven. Put the bowl counter back in the tray. How many are there now?"
            case .tryRecount: "How many counters are together in the tray? Count them and enter the number."
            case .tryDone: "Seven again! You split the whole and put it back together."
            case .tryRetry: "Try once more. How many are in the other part?"
            case .tryMoveBack: "We need one in the bowl. Move counters back until just one is there."
            case .tryRecountRetry: "Count the counters in the tray again."
            case .checkEntry: "The whole is eight. One part is three. What is the other part? Show how your two parts make eight with counters."
            case .checkAnswer: "Put your answer in the empty part."
            case .checkRetry: "Take another look. The whole is eight. One part is three. What is the other part? Show how your two parts make eight."
            case .checkSuccess: "You showed both parts and how they make eight. Well done!"
            }
        }
    }

    private var activePrompt: Prompt? {
        switch page {
        case .tryIt:
            switch guided.verification {
            case .verified: return .tryDone
            case .retry: return .tryRecountRetry
            case .counting: return .tryRecount
            case nil: break
            }
            if guided.feedback == .correct { return .trySplit }
            if guided.bowl.isEmpty { return .tryEntry }
            if guided.bowl.count > 1 { return .tryMoveBack }
            if guided.feedback == .retry { return .tryRetry }
            return guided.hasEnteredAnswer ? .tryBond : .tryCount
        case .check:
            if independent.feedback == .retry { return .checkRetry }
            return independent.hasEnteredAnswer ? .checkAnswer : .checkEntry
        case .completion: return .checkSuccess
        default: return nil
        }
    }

    private func stopPrompt() {
        narration?.stop()
        narration = nil
        promptPaused = false
    }

    private func playPrompt(_ prompt: Prompt) {
        stopPrompt()
        guard scenePhase == .active else { return }
        if let player = U07Narration.player(for: prompt.clipID), player.play() {
            narration = player
        } else {
            AccessibilityNotification.Announcement(prompt.caption).post()
        }
    }

    private func promptControls(_ prompt: Prompt) -> some View {
        let player = narration
        return HStack {
            if let narration, narration.isPlaying || promptPaused {
                Button(promptPaused ? "Resume narration" : "Pause narration") {
                    if promptPaused {
                        if narration.play() { promptPaused = false } else { stopPrompt() }
                    } else {
                        narration.pause()
                        promptPaused = true
                    }
                }
            }
            Button("Replay prompt") { playPrompt(prompt) }
        }
        .buttonStyle(PreviewButton())
        .task(id: player) {
            guard let player else { return }
            while player.isPlaying || promptPaused {
                do { try await Task.sleep(for: .milliseconds(100)) } catch { return }
            }
            if narration === player { stopPrompt() }
        }
    }

    private func workspace(guided isGuided: Bool, work: Binding<Working>) -> some View {
        let whole = isGuided ? 7 : 8
        let known = isGuided ? 1 : 3
        let state = work.wrappedValue
        return VStack(alignment: .leading, spacing: 16) {
            if let prompt = activePrompt {
                teachingPrompt(prompt.caption, identifier: "workspace-prompt")
                HStack {
                    promptControls(prompt)
                    if prompt == .tryCount {
                        Button("Next prompt") { work.wrappedValue.hasEnteredAnswer = true }
                            .buttonStyle(PreviewButton())
                    }
                }
            }
            AdaptiveColumns {
                VStack(alignment: .leading, spacing: 12) {
                    regions(whole: whole, bowl: state.bowl,
                            showCounts: isGuided && (state.bowl.isEmpty || state.feedback == .correct),
                            hideTrayCount: state.verification != nil && state.verification != .verified,
                            work: work)
                    Text(state.selection == nil
                         ? "Drag a counter, or tap one to pick it up."
                         : "Counter selected. Choose where to put it.")
                        .font(.subheadline)
                    HStack {
                        Button("Put in tray") { moveSelection(work, intoBowl: false) }
                            .accessibilityIdentifier("put-in-tray")
                            .disabled(state.selection.map { !state.bowl.contains($0) } ?? true)
                        Button("Put in bowl") { moveSelection(work, intoBowl: true) }
                            .accessibilityIdentifier("put-in-bowl")
                            .disabled(state.selection.map { state.bowl.contains($0) } ?? true)
                    }
                    .buttonStyle(PreviewButton())
                    Button("Recombine counters") {
                        updateBowl([], work: work)
                    }
                    .buttonStyle(PreviewButton(prominent: isGuided && state.feedback == .correct))
                    .disabled(state.bowl.isEmpty)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } side: {
                VStack(spacing: 12) {
                    if let verification = state.verification {
                        bond(verification == .verified ? whole : nil, known, whole - known,
                             title: "Completed split", knownGroup: nil)
                        if verification == .verified {
                            Button("Continue to Check") { page = .check }
                                .buttonStyle(PreviewButton(prominent: true))
                        } else {
                            bondNode("Your count", value: state.answer)
                            keypad(work)
                            Button("Check my count") {
                                let result: WholeVerification = state.answer == whole ? .verified : .retry
                                work.wrappedValue.verification = result
                            }
                            .buttonStyle(PreviewButton(prominent: true))
                            .disabled(state.answer == nil)
                        }
                    } else {
                        bond(whole, known, state.answer, title: "Number bond", knownGroup: isGuided ? .bowl : nil)
                        keypad(work)
                        Button("Check my answer") {
                            let bowlCount = state.bowl.count
                            let trayCount = whole - bowlCount
                            let modelMatches = bowlCount == known || (!isGuided && trayCount == known)
                            let matches = modelMatches
                                && state.answer == NumberBond.missingPart(whole: whole, known: known)
                            if matches && !isGuided {
                                animateCelebration = true
                                page = .completion
                                return
                            }
                            let feedback: Feedback = matches ? .correct : .retry
                            work.wrappedValue.feedback = feedback
                        }
                        .buttonStyle(PreviewButton(prominent: true))
                        .disabled(state.answer == nil)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(.white, in: RoundedRectangle(cornerRadius: 22))
            }
        }
    }

    private func moveSelection(_ work: Binding<Working>, intoBowl: Bool) {
        guard let id = work.wrappedValue.selection else { return }
        move(id, work: work, intoBowl: intoBowl)
    }

    private func move(_ id: Int, work: Binding<Working>, intoBowl: Bool) {
        var bowl = work.wrappedValue.bowl
        if intoBowl {
            bowl.insert(id)
        } else {
            bowl.remove(id)
        }
        updateBowl(bowl, work: work)
    }

    private func updateBowl(_ bowl: Set<Int>, work: Binding<Working>) {
        var state = work.wrappedValue
        state.selection = nil
        if state.verification != nil && bowl == state.bowl {
            work.wrappedValue = state
            return
        }
        let recombined = state.isGuided && state.feedback == .correct && bowl.isEmpty
        if recombined || state.verification != nil {
            state.answer = nil
        }
        if state.isGuided { state.hasEnteredAnswer = false }
        state.bowl = bowl
        state.feedback = nil
        state.verification = recombined ? .counting : nil
        work.wrappedValue = state
    }

    private enum CounterGroup {
        case tray, bowl

        var title: String { self == .tray ? "Tray" : "Bowl" }
        var opposite: Self { self == .tray ? .bowl : .tray }
        var symbol: String { self == .tray ? "rectangle" : "oval" }
        var tint: Color {
            self == .tray ? Color(red: 0.29, green: 0.24, blue: 0.54)
                : Color(red: 0.12, green: 0.35, blue: 0.34)
        }

        var fill: Color {
            self == .tray ? Color(red: 0.92, green: 0.89, blue: 0.98)
                : Color(red: 0.86, green: 0.94, blue: 0.90)
        }
    }

    private func regions(
        whole: Int, bowl: Set<Int>, showCounts: Bool, hideTrayCount: Bool = false,
        work: Binding<Working>?, reviewing: Bool = false
    ) -> some View {
        let counters = Array(1...whole)
        return VStack(spacing: 12) {
            region(.tray, ids: counters.filter { !bowl.contains($0) },
                   showCount: showCounts && !hideTrayCount, work: work, reviewing: reviewing)
            region(.bowl, ids: counters.filter { bowl.contains($0) },
                   showCount: showCounts, work: work, reviewing: reviewing)
        }
    }

    private func region(
        _ group: CounterGroup, ids: [Int], showCount: Bool,
        work: Binding<Working>?, reviewing: Bool
    ) -> some View {
        let intoBowl = group == .bowl
        let observing = work == nil && !reviewing
        let isOtherGroup = observing && group == .tray
            && (demo.step == .otherGroup || demo.step == .countTray)
        let title = isOtherGroup ? "Tray · Other group"
            : showCount ? "\(group.title) · \(ids.count)" : group.title
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 7) {
                Image(systemName: group.symbol).accessibilityHidden(true)
                Text(title)
                if observing, !demo.manual, !reduceMotion,
                   let indicated = demo.indicatedCounter, ids.contains(indicated) {
                    Image(systemName: "hand.point.down.fill").accessibilityHidden(true)
                }
            }
            .font(.title3.bold())
            .foregroundStyle(group.tint)
            .accessibilityAddTraits(.isHeader)
            .accessibilityIdentifier(intoBowl ? "bowl-label" : "tray-label")

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 72, maximum: 94), spacing: 8)],
                      alignment: .leading, spacing: 6) {
                ForEach(ids, id: \.self) { id in
                    if let work {
                        let selected = work.wrappedValue.selection == id
                        Button {
                            work.wrappedValue.selection = selected ? nil : id
                        } label: {
                            counter(selected)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Counter in \(intoBowl ? "bowl" : "tray")")
                        .accessibilityHint("Select to move this counter")
                        .accessibilityAddTraits(selected ? .isSelected : [])
                        .accessibilityIdentifier("counter-\(id)")
                        .highPriorityGesture(counterDrag(id, work: work))
                    } else if reviewing {
                        counter(false)
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel("Counter in \(group.title.lowercased())")
                            .accessibilityIdentifier("counter-\(id)")
                    } else {
                        demoCounter(id, group: group)
                            .matchedGeometryEffect(id: id, in: demoCounters)
                    }
                }
            }
            .frame(minHeight: 150, alignment: .topLeading)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(group.fill, in: RoundedRectangle(cornerRadius: intoBowl ? 32 : 16))
        .overlay {
            RoundedRectangle(cornerRadius: intoBowl ? 32 : 16)
                .strokeBorder(group.tint.opacity(observing && demo.linkedGroups.contains(group) ? 1 : 0.35),
                              lineWidth: observing && demo.linkedGroups.contains(group) ? 4 : 2)
                .allowsHitTesting(false)
        }
        .contentShape(Rectangle())
        .onGeometryChange(for: CGRect.self) { geometry in
            geometry.frame(in: .global)
        } action: { frame in
            guard work != nil else { return }
            if intoBowl {
                bowlFrame = frame
            } else {
                trayFrame = frame
            }
        }
    }

    private func demoCounter(_ id: Int, group: CounterGroup) -> some View {
        let indicated = demo.indicatedCounter == id
        let shownWord = group == .tray && indicated ? demo.indicatedWord : nil
        return counter(false)
            .overlay {
                if indicated {
                    Circle().inset(by: 2).strokeBorder(group.tint, lineWidth: 3)
                }
            }
            .overlay(alignment: .bottom) {
                if let shownWord {
                    Text(shownWord)
                        .font(.caption.bold())
                        .padding(.horizontal, 5)
                        .background(.white, in: Capsule())
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(shownWord ?? "Counter in \(group.title.lowercased())")
            .accessibilityAddTraits(indicated ? .isSelected : [])
            .accessibilityIdentifier("observe-counter-\(id)")
    }

    private func counterDrag(_ id: Int, work: Binding<Working>) -> some Gesture {
        DragGesture(minimumDistance: 8, coordinateSpace: .global)
            .updating($dragLocation) { value, location, _ in location = value.location }
            .onEnded { value in
                if bowlFrame.contains(value.location) {
                    move(id, work: work, intoBowl: true)
                } else if trayFrame.contains(value.location) {
                    move(id, work: work, intoBowl: false)
                }
            }
    }

    private func counter(_ selected: Bool) -> some View {
        Circle()
            .fill(.linearGradient(colors: [Color(red: 1, green: 0.80, blue: 0.32),
                                           Color(red: 0.85, green: 0.52, blue: 0.13)],
                                  startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay { Circle().strokeBorder(.white.opacity(0.6), lineWidth: 2).padding(4) }
            .overlay {
                if selected {
                    Circle().strokeBorder(teal, lineWidth: 4)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.white, teal)
                        .font(.title3)
                }
            }
            .padding(2)
            .frame(width: 72, height: 72)
            .contentShape(Rectangle())
    }

    private func bond(
        _ whole: Int?, _ known: Int?, _ missing: Int?, title: String,
        knownGroup: CounterGroup?, showParts: Bool = true, teaching: Bool = false
    ) -> some View {
        VStack(spacing: 8) {
            Text(title).font(.headline)
            bondNode("Whole", value: whole,
                     linked: teaching && (demo.step == .whole || demo.linkedGroups.count == 2))
            if showParts {
                Canvas { context, size in
                    var branches = Path()
                    branches.move(to: CGPoint(x: size.width * 0.5, y: 0))
                    branches.addLine(to: CGPoint(x: size.width * 0.25, y: size.height))
                    branches.move(to: CGPoint(x: size.width * 0.5, y: 0))
                    branches.addLine(to: CGPoint(x: size.width * 0.75, y: size.height))
                    context.stroke(branches, with: .color(teal), lineWidth: 3)
                }
                .frame(height: 20)
                .accessibilityHidden(true)
                HStack(spacing: 8) {
                    bondNode("Part 1", value: known, group: knownGroup,
                             linked: teaching && demo.linkedGroups.contains(.bowl))
                        .frame(maxWidth: .infinity)
                    bondNode("Part 2", value: missing, group: knownGroup?.opposite,
                             linked: teaching && demo.linkedGroups.contains(.tray))
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .frame(maxWidth: 340)
    }

    private func bondNode(_ label: String, value: Int?, group: CounterGroup? = nil, linked: Bool = false) -> some View {
        let title = group?.title ?? label
        return VStack(spacing: 2) {
            if let group {
                Label(title, systemImage: group.symbol).font(.headline)
            } else {
                Text(title).font(.headline)
            }
            Text(value.map(String.init) ?? "?")
                .font(.system(.largeTitle, design: .rounded, weight: .bold).monospacedDigit())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .frame(minWidth: 100)
        .foregroundStyle(group?.tint ?? ink)
        .background(group?.fill ?? paper, in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            if linked {
                RoundedRectangle(cornerRadius: 14).strokeBorder(group?.tint ?? teal, lineWidth: 3)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(value.map(String.init) ?? "Blank")
        .accessibilityIdentifier(label == "Part 2" ? "missing-part" : label)
    }

    private func clearAnswerFeedback(_ work: Binding<Working>) {
        work.wrappedValue.feedback = nil
        if work.wrappedValue.verification == .retry {
            work.wrappedValue.verification = .counting
        }
    }

    private func keypad(_ work: Binding<Working>) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4)) {
            ForEach([1, 2, 3, 4, 5, 6, 7, 8, 9, 0], id: \.self) { digit in
                Button {
                    work.wrappedValue.hasEnteredAnswer = true
                    work.wrappedValue.answer = digit
                    clearAnswerFeedback(work)
                } label: {
                    Text(digit.formatted()).font(.title3.bold()).frame(maxWidth: .infinity)
                }
                .accessibilityIdentifier("key-\(digit)")
            }
            Button {
                work.wrappedValue.hasEnteredAnswer = false
                work.wrappedValue.answer = nil
                clearAnswerFeedback(work)
            } label: {
                Image(systemName: "delete.left").frame(maxWidth: .infinity)
            }
            .accessibilityLabel("Clear answer")
        }
        .buttonStyle(PreviewButton())
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Number keypad")
    }
}

private struct AdaptiveColumns<Main: View, Side: View>: View {
    @Environment(\.dynamicTypeSize) private var typeSize

    @ViewBuilder let main: () -> Main
    @ViewBuilder let side: () -> Side

    var body: some View {
        ViewThatFits(in: .horizontal) {
            if !typeSize.isAccessibilitySize {
                HStack(alignment: .top, spacing: 20) {
                    main().frame(minWidth: 350)
                    side().frame(width: 350)
                }
            }
            VStack(spacing: 16) {
                main()
                side()
            }
        }
    }
}

private struct PreviewButton: ButtonStyle {
    var prominent = false
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .frame(minHeight: 44)
            .foregroundStyle(prominent ? Color.white : Color(red: 0.14, green: 0.21, blue: 0.31))
            .background(prominent ? Color(red: 0.12, green: 0.35, blue: 0.34) : Color(red: 0.93, green: 0.91, blue: 0.86),
                        in: RoundedRectangle(cornerRadius: 12))
            .opacity(isEnabled ? (configuration.isPressed ? 0.72 : 1) : 0.45)
    }
}

private struct CelebratingJuni: View {
    @State private var started = false

    var body: some View {
        JuniMoon(reaction: .delighted)
            .keyframeAnimator(initialValue: CGFloat.zero, trigger: started) { view, lift in
                view.offset(y: lift)
            } keyframes: { _ in
                CubicKeyframe(-14, duration: 0.28)
                CubicKeyframe(0, duration: 0.36)
                CubicKeyframe(-5, duration: 0.16)
                CubicKeyframe(0, duration: 0.20)
            }
            .task { started = true }
    }
}

private struct JuniMoon: View {
    enum Reaction: String {
        case smiling, focused, thinking, delighted
    }

    var reaction: Reaction = .smiling

    var body: some View {
        ZStack {
            Circle().fill(.radialGradient(
                colors: [Color(red: 1, green: 0.92, blue: 0.59), Color(red: 0.94, green: 0.67, blue: 0.24)],
                center: .topLeading, startRadius: 0, endRadius: 195
            ))
            Canvas { context, size in
                let edge = size.width
                func oval(_ x: Double, _ y: Double, _ width: Double, _ height: Double) -> Path {
                    Path(ellipseIn: CGRect(x: x * edge, y: y * edge, width: width * edge, height: height * edge))
                }
                let tan = Color(red: 0.64, green: 0.37, blue: 0.13)
                let brown = Color(red: 0.27, green: 0.16, blue: 0.10)
                for (x, y, radius) in [(0.19, 0.20, 0.17), (0.59, 0.13, 0.10), (0.22, 0.72, 0.11)] {
                    context.fill(oval(x, y, radius, radius * 0.88), with: .color(tan.opacity(0.19)))
                }
                for x in [0.32, 0.60] {
                    let y = reaction == .thinking && x > 0.5 ? 0.40 : 0.43
                    let height = reaction == .focused ? 0.07 : 0.10
                    context.fill(oval(x, y, 0.08, height), with: .color(brown))
                }
                for x in [0.19, 0.69] {
                    context.fill(oval(x, 0.55, 0.12, 0.06), with: .color(.orange.opacity(0.6)))
                }
                if reaction == .delighted || reaction == .thinking {
                    let width = reaction == .delighted ? 0.16 : 0.07
                    context.fill(oval(0.5 - width / 2, 0.56, width, 0.10), with: .color(brown))
                    return
                }
                var smile = Path()
                smile.move(to: CGPoint(x: 0.43 * edge, y: 0.55 * edge))
                smile.addQuadCurve(to: CGPoint(x: 0.57 * edge, y: 0.55 * edge),
                                   control: CGPoint(x: 0.5 * edge, y: 0.70 * edge))
                context.stroke(smile, with: .color(brown), style: StrokeStyle(lineWidth: edge * 0.023, lineCap: .round))
            }
        }
        .shadow(color: .orange.opacity(0.23), radius: 15, y: 5)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Juni, a \(reaction.rawValue) golden full moon")
        .accessibilityAddTraits(.isImage)
    }
}
#endif
