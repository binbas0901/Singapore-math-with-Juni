#if DEBUG
import JuniCore
import SwiftUI

struct U07Preview: View {
    private enum Page: String, CaseIterable {
        case observe = "Observe"
        case tryIt = "Try"
        case check = "Check"
    }

    private enum DemoStep: Int, CaseIterable {
        case whole, first, second, bond, together

        var bowl: Set<Int> {
            switch self {
            case .whole, .together: []
            case .first: [1]
            case .second, .bond: [1, 2]
            }
        }

        var caption: String {
            switch self {
            case .whole: "Count the counters in the tray. There are six altogether."
            case .first: "Move one counter into the bowl."
            case .second: "Move one more. Now there are two in the bowl."
            case .bond: "The bowl has two. The tray is the other part, with four. Both parts make six."
            case .together: "Bring both counters back. The same six counters are together again."
            }
        }
    }

    private let ink = Color(red: 0.14, green: 0.21, blue: 0.31)
    private let paper = Color(red: 0.98, green: 0.96, blue: 0.91)
    private let teal = Color(red: 0.12, green: 0.35, blue: 0.34)

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var page: Page?
    @State private var resumePage: Page?
    @State private var demo = DemoStep.whole
    @State private var guided = Working()
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
        demo = .whole
        guided = Working()
        independent = Working()
        resumePage = nil
        page = .observe
    }

    private var header: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Split a whole").font(.title2.bold()).accessibilityAddTraits(.isHeader)
                Text("U07 lesson preview · Captions only").font(.subheadline)
            }
            Spacer()
            Button("Home") {
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
            Button(stage.rawValue) { page = stage }
                .buttonStyle(PreviewButton(prominent: current == stage))
                .accessibilityAddTraits(current == stage ? .isSelected : [])
        }
    }

    private var observe: some View {
        VStack(alignment: .leading, spacing: 16) {
            teachingPrompt(demo.caption, identifier: "observe-caption")
            AdaptiveColumns {
                regions(
                    whole: 6, bowl: demo.bowl, showCounts: true, work: nil
                )
                .frame(maxWidth: .infinity)
            } side: {
                VStack(spacing: 12) {
                    let showsParts = demo == .bond || demo == .together
                    bond(6, showsParts ? 2 : nil, showsParts ? 4 : nil,
                         title: demo == .together ? "Completed example" : "Number bond",
                         knownGroup: showsParts ? .bowl : nil, showParts: showsParts)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(.white, in: RoundedRectangle(cornerRadius: 22))
            }
            ViewThatFits(in: .horizontal) {
                HStack { demoButtons }
                VStack(alignment: .leading) { demoButtons }
            }
        }
    }

    private var demoButtons: some View {
        Group {
            Button("Replay") { go(to: .whole) }
                .buttonStyle(PreviewButton())
            Button("Previous step") { go(to: DemoStep(rawValue: demo.rawValue - 1)) }
                .buttonStyle(PreviewButton())
                .disabled(demo == .whole)
            Button("Next step") { go(to: DemoStep(rawValue: demo.rawValue + 1)) }
                .buttonStyle(PreviewButton(prominent: true))
                .disabled(demo == .together)
            if demo == .together {
                Button("Try together") { page = .tryIt }
                    .buttonStyle(PreviewButton(prominent: true))
            }
        }
    }

    private func go(to step: DemoStep?) {
        guard let step else { return }
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.38)) { demo = step }
        AccessibilityNotification.Announcement(step.caption).post()
    }

    private func teachingPrompt(_ prompt: String, identifier: String) -> some View {
        HStack(spacing: 18) {
            JuniMoon().frame(width: 84, height: 84)
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
        case correct, retry, recombined

        var message: String {
            switch self {
            case .correct: "Your counters and number bond match."
            case .retry: "Recount the two groups and check the missing number."
            case .recombined: "All the counters are together again."
            }
        }
    }

    private struct Working {
        var bowl: Set<Int> = []
        var selection: Int?
        var answer: Int?
        var feedback: Feedback?
    }

    private func guidedPrompt(_ state: Working) -> String {
        if state.feedback == .correct {
            return "Now put the two groups back together in the tray."
        }
        if state.feedback == .recombined {
            return "You made the whole again. Try the Check when you’re ready."
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
                        work.wrappedValue.bowl.removeAll()
                        work.wrappedValue.selection = nil
                        work.wrappedValue.feedback = isGuided && state.feedback == .correct ? .recombined : nil
                    }
                    .buttonStyle(PreviewButton(prominent: isGuided && state.feedback == .correct))
                    .disabled(state.bowl.isEmpty)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } side: {
                VStack(spacing: 12) {
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
        let state = work.wrappedValue
        let recombinesGuidedModel = !intoBowl && state.bowl == [id] && state.feedback == .correct
        if intoBowl {
            work.wrappedValue.bowl.insert(id)
        } else {
            work.wrappedValue.bowl.remove(id)
        }
        work.wrappedValue.selection = nil
        work.wrappedValue.feedback = recombinesGuidedModel ? .recombined : nil
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
        whole: Int, bowl: Set<Int>, showCounts: Bool, work: Binding<Working>?
    ) -> some View {
        let counters = Array(1...whole)
        return VStack(spacing: 12) {
            region(.tray, ids: counters.filter { !bowl.contains($0) },
                   showCount: showCounts, work: work)
            region(.bowl, ids: counters.filter { bowl.contains($0) },
                   showCount: showCounts, work: work)
        }
    }

    private func region(
        _ group: CounterGroup, ids: [Int], showCount: Bool,
        work: Binding<Working>?
    ) -> some View {
        let intoBowl = group == .bowl
        let title = showCount ? "\(group.title) · \(ids.count)" : group.title
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 7) {
                Image(systemName: group.symbol).accessibilityHidden(true)
                Text(title)
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
                        .accessibilityLabel("Counter \(id) in \(intoBowl ? "bowl" : "tray")")
                        .accessibilityHint("Select to move this counter")
                        .accessibilityAddTraits(selected ? .isSelected : [])
                        .accessibilityIdentifier("counter-\(id)")
                        .highPriorityGesture(counterDrag(id, work: work))
                    } else {
                        counter(false)
                            .matchedGeometryEffect(id: id, in: demoCounters)
                            .accessibilityHidden(true)
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
                .strokeBorder(group.tint.opacity(0.35), lineWidth: 2)
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
        _ whole: Int, _ known: Int?, _ missing: Int?, title: String,
        knownGroup: CounterGroup?, showParts: Bool = true
    ) -> some View {
        VStack(spacing: 8) {
            Text(title).font(.headline)
            bondNode("Whole", value: whole)
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
                    bondNode("Part 1", value: known, group: knownGroup)
                        .frame(maxWidth: .infinity)
                    bondNode("Part 2", value: missing, group: knownGroup?.opposite)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .frame(maxWidth: 340)
    }

    private func bondNode(_ label: String, value: Int?, group: CounterGroup? = nil) -> some View {
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(value.map(String.init) ?? "Blank")
        .accessibilityIdentifier(label == "Part 2" ? "missing-part" : label)
    }

    private func keypad(_ work: Binding<Working>) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4)) {
            ForEach([1, 2, 3, 4, 5, 6, 7, 8, 9, 0], id: \.self) { digit in
                Button {
                    work.wrappedValue.answer = digit
                    work.wrappedValue.feedback = nil
                } label: {
                    Text(digit.formatted()).font(.title3.bold()).frame(maxWidth: .infinity)
                }
                .accessibilityIdentifier("key-\(digit)")
            }
            Button {
                work.wrappedValue.answer = nil
                work.wrappedValue.feedback = nil
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
                    context.fill(oval(x, 0.43, 0.08, 0.10), with: .color(brown))
                }
                for x in [0.19, 0.69] {
                    context.fill(oval(x, 0.55, 0.12, 0.06), with: .color(.orange.opacity(0.6)))
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
        .accessibilityLabel("Juni, a smiling golden full moon")
        .accessibilityAddTraits(.isImage)
    }
}
#endif
