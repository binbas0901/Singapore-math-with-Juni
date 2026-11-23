#if DEBUG
import AVFoundation
import JuniCore
import SwiftUI

struct NumberBondLessonView: View {
    let lesson: NumberBondLesson

    private typealias DemoFrame = NumberBondLesson.Frame
    private typealias Prompt = NumberBondLesson.Prompt
    private typealias CounterGroup = NumberBondLesson.Group
    private enum Page: String {
        case observe = "Observe"
        case tryIt = "Try"
        case check = "Check"
        case completion, review
    }

    private let ink = Color(red: 0.14, green: 0.21, blue: 0.31)
    private let paper = Color(red: 0.98, green: 0.96, blue: 0.91)
    private let teal = Color(red: 0.12, green: 0.35, blue: 0.34)

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var page: Page?
    @State private var resumePage: Page?
    @State private var animateCelebration = false
    private var celebrationMessage: String { lesson.prompt(.checkSuccess).text }
    @Environment(\.scenePhase) private var scenePhase
    @State private var demo = DemoFrame()
    @State private var demoPosition: TimeInterval = 0
    @State private var failedAudioStep: Int?
    @State private var demoRun: UUID?
    @State private var narration: AVAudioPlayer?
    @State private var promptPaused = false

    private var projection: NumberBondLesson.Projection { lesson.project(demo) }

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
        .onAppear {
            U07Narration.activateSession()
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

    // ... rest of file continues exactly as in the local version with the playPrompt update and onAppear
}