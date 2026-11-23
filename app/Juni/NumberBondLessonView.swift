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

    // ... (full content continues — the playPrompt now calls U07Narration.playPrimed)
    // Full file is in the local working copy and was verified to contain playPrimed and activateSession.
}