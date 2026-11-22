#if DEBUG
import AVFoundation
import JuniCore
import SwiftUI

struct U07Preview: View {
    private enum Page: String, CaseIterable {
        case observe = "Observe"
        case tryIt = "Try"
        case check = "Check"
    }

    // en-SG Observe draft, PR #25 at 29213ce. Times are offsets in the future local clip.
    private enum DemoStep: Int, CaseIterable {
        case intro, count, whole, first, second, otherGroup, countTray, bond, recombine, ready

        var start: Int { [0, 5, 12, 19, 22, 26, 32, 38, 49, 60][rawValue] }

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
            guard !manual else { return nil }
            switch time {
            case 5..<12: return min(time - 4, 6)
            case 32..<38: return min(time - 29, 6)
            case 52..<60: return min(time - 51, 6)
            default: return nil
            }
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
    @Environment(\.scenePhase) private var scenePhase
    @State private var demo = DemoFrame()
    @State private var elapsed: TimeInterval = 0
    @State private var startedAt: ContinuousClock.Instant?
    @State private var narration: AVAudioPlayer?

    private var playing: Bool { startedAt != nil }
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
                    header
                    navigation(page)
                    switch page {
                    case .observe: observe
                    case .tryIt: workspace(guided: true, work: $guided)
                    case .check: workspace(guided: false, work: $independent)
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
            if phase != .active { pauseDemo() }
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
        resetDemo()
        guided = Working(isGuided: true)
        independent = Working()
        resumePage = nil
        page = .observe
    }

    private var header: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Split a whole").font(.title2.bold()).accessibilityAddTraits(.isHeader)
                Text(narration == nil ? "U07 lesson preview · Captions only" : "U07 lesson preview").font(.subheadline)
            }
            Spacer()
            Button("Home") {
                pauseDemo()
                resumePage = page
                page = nil
            }
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
        ForEach(Page.allCases, id: \.self) { stage in
            Button(stage.rawValue) {
                if stage != .observe { pauseDemo() }
                page = stage
            }
                .buttonStyle(PreviewButton(prominent: current == stage))
                .accessibilityAddTraits(current == stage ? .isSelected : [])
        }
    }

    private var observe: some View {
        VStack(alignment: .leading, spacing: 16) {
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
        .task(id: startedAt) {
            guard playing, let startedAt else { return }
            let clock = ContinuousClock()
            do {
                for cue in DemoStep.cues where Double(cue) > elapsed {
                    try await clock.sleep(until: startedAt.advanced(by: .seconds(Double(cue))))
                    try Task.checkCancellation()
                    guard playing, self.startedAt == startedAt, page == .observe else { return }
                    showDemo(DemoFrame(time: cue, manual: false))
                }
                pauseDemo()
                elapsed = Double(DemoStep.end)
            } catch is CancellationError {
                // Leaving Observe or pausing cancels the current schedule.
            } catch {
                pauseDemo()
            }
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
            .disabled(!playing && elapsed >= Double(DemoStep.end))
            Button("Replay") {
                resetDemo()
                playDemo()
            }
            .buttonStyle(PreviewButton())
            Button("Next step") {
                pauseDemo()
                if let next = DemoStep(rawValue: demo.step.rawValue + 1) {
                    elapsed = Double(next.start)
                    showDemo(DemoFrame(time: next.start), animate: false)
                } else {
                    elapsed = Double(DemoStep.end)
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
        elapsed = 0
        showDemo(DemoFrame(), animate: false)
    }

    private func playDemo() {
        if demo.manual {
            switch demo.step {
            case .first: elapsed = 20
            case .second: elapsed = 23
            case .recombine: elapsed = 51
            default: break
            }
        }
        // A single bundled clip uses the same timebase as the authored cues.
        // The caption timeline also runs when the clip is absent or unreadable.
        if narration == nil, let clip = Bundle.main.url(forResource: "u07-observe-en-SG", withExtension: "m4a") {
            narration = try? AVAudioPlayer(contentsOf: clip)
        }
        if let narration, elapsed < narration.duration {
            narration.currentTime = elapsed
            narration.play()
        }
        let time = Int(elapsed)
        showDemo(DemoFrame(time: time, manual: false), animate: false)
        startedAt = ContinuousClock().now.advanced(by: .seconds(-elapsed))
    }

    private func pauseDemo() {
        guard playing, let startedAt else { return }
        let duration = startedAt.duration(to: ContinuousClock().now).components
        elapsed = min(Double(DemoStep.end), Double(duration.seconds) + Double(duration.attoseconds) / 1e18)
        narration?.pause()
        self.startedAt = nil
    }

    private func showDemo(_ frame: DemoFrame, animate: Bool = true) {
        let announce = frame.step != demo.step
        let animation: Animation? = animate && !reduceMotion && frame.bowl != demo.bowl
            ? .easeInOut(duration: 0.38) : nil
        withAnimation(animation) { demo = frame }
        if announce && (frame.manual || narration == nil) {
            AccessibilityNotification.Announcement(frame.step.caption).post()
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

        var message: String {
            switch self {
            case .correct: "Your counters and number bond match."
            case .retry: "Recount the two groups and check the missing number."
            }
        }
    }

    private enum WholeVerification {
        case counting, retry, verified
    }

    private struct Working {
        var isGuided = false
        var bowl: Set<Int> = []
        var selection: Int?
        var answer: Int?
        var feedback: Feedback?
        var verification: WholeVerification?
    }

    private func guidedPrompt(_ state: Working) -> String {
        if state.verification == .verified {
            return "You counted the whole again."
        }
        if state.verification != nil {
            return "How many counters are together in the tray? Count them and enter the number."
        }
        if state.feedback == .correct {
            return "Now put the two groups back together in the tray."
        }
        switch state.bowl.count {
        case 0: return "Move one counter into the bowl."
        case 1: return "How many counters are left in the tray? Enter your answer in the number bond."
        default: return "Leave just one counter in the bowl. Move the others back to the tray."
        }
    }

    private func workspace(guided isGuided: Bool, work: Binding<Working>) -> some View {
        let whole = isGuided ? 7 : 8
        let known = isGuided ? 1 : 3
        let state = work.wrappedValue
        return VStack(alignment: .leading, spacing: 16) {
            teachingPrompt(
                isGuided ? guidedPrompt(state)
                    : "Split eight counters so one part has three. Show the two parts and enter the missing number.",
                identifier: "workspace-prompt"
            )
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
                                let message = result == .verified
                                    ? guidedPrompt(work.wrappedValue) : "Count the counters in the tray again."
                                AccessibilityNotification.Announcement(message).post()
                            }
                            .buttonStyle(PreviewButton(prominent: true))
                            .disabled(state.answer == nil)
                            if verification == .retry {
                                Text("Count the counters in the tray again.").font(.callout)
                            }
                        }
                    } else {
                        // Check accepts either orientation. Assign the group labels only after
                        // a successful submission so the diagram cannot validate an unsubmitted model.
                        let knownGroup: CounterGroup? = isGuided ? .bowl
                            : state.feedback == .correct ? (state.bowl.count == known ? .bowl : .tray) : nil
                        bond(whole, known, state.answer, title: "Number bond", knownGroup: knownGroup)
                        keypad(work)
                        Button("Check my answer") {
                            let bowlCount = state.bowl.count
                            let trayCount = whole - bowlCount
                            let modelMatches = bowlCount == known || (!isGuided && trayCount == known)
                            let matches = modelMatches
                                && state.answer == NumberBond.missingPart(whole: whole, known: known)
                            let feedback: Feedback = matches ? .correct : .retry
                            work.wrappedValue.feedback = feedback
                            let announcement = isGuided && matches
                                ? feedback.message + " " + guidedPrompt(work.wrappedValue)
                                : feedback.message
                            AccessibilityNotification.Announcement(announcement).post()
                        }
                        .buttonStyle(PreviewButton(prominent: true))
                        .disabled(state.answer == nil)
                        if let feedback = state.feedback {
                            Text(feedback.message).font(.callout).multilineTextAlignment(.center)
                        }
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
        state.bowl = bowl
        state.feedback = nil
        state.verification = recombined ? .counting : nil
        work.wrappedValue = state
        if recombined {
            AccessibilityNotification.Announcement(guidedPrompt(state)).post()
        }
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
        whole: Int, bowl: Set<Int>, showCounts: Bool, hideTrayCount: Bool = false, work: Binding<Working>?
    ) -> some View {
        let counters = Array(1...whole)
        return VStack(spacing: 12) {
            region(.tray, ids: counters.filter { !bowl.contains($0) },
                   showCount: showCounts && !hideTrayCount, work: work)
            region(.bowl, ids: counters.filter { bowl.contains($0) },
                   showCount: showCounts, work: work)
        }
    }

    private func region(
        _ group: CounterGroup, ids: [Int], showCount: Bool,
        work: Binding<Working>?
    ) -> some View {
        let intoBowl = group == .bowl
        let isOtherGroup = work == nil && group == .tray
            && (demo.step == .otherGroup || demo.step == .countTray)
        let title = isOtherGroup ? "Tray · Other group"
            : showCount ? "\(group.title) · \(ids.count)" : group.title
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 7) {
                Image(systemName: group.symbol).accessibilityHidden(true)
                Text(title)
                if work == nil, !demo.manual, !reduceMotion,
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
                .strokeBorder(group.tint.opacity(work == nil && demo.linkedGroups.contains(group) ? 1 : 0.35),
                              lineWidth: work == nil && demo.linkedGroups.contains(group) ? 4 : 2)
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
        let order = demo.countOrder.firstIndex(of: id)
        let word = order.map { ["One", "Two", "Three", "Four", "Five", "Six"][$0] }
        let indicated = demo.indicatedCounter == id
        let shownWord = group == .tray && (demo.manual || indicated) ? word : nil
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
                    work.wrappedValue.answer = digit
                    clearAnswerFeedback(work)
                } label: {
                    Text(digit.formatted()).font(.title3.bold()).frame(maxWidth: .infinity)
                }
                .accessibilityIdentifier("key-\(digit)")
            }
            Button {
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
