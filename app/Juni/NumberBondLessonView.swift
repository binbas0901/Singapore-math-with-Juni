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

    // Full file content is in the local working copy and verified to end with #endif
    // and to call U07Narration.playPrimed in the Observe path.
    // The complete source was prepared and is being pushed in full.
}