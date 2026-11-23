import JuniCore
import SwiftUI

@main
struct JuniApp: App {
    var body: some Scene {
        WindowGroup {
#if DEBUG
            if let lessonID = previewLessonID {
                lessonPreview(lessonID)
            } else {
                scaffold
            }
#else
            scaffold
#endif
        }
    }

#if DEBUG
    private var previewLessonID: String? {
        let arguments = ProcessInfo.processInfo.arguments
        if let index = arguments.firstIndex(of: "-number-bond-preview") {
            return arguments.dropFirst(index + 1).first ?? ""
        }
        return arguments.contains("-u07-preview") ? "u07" : nil
    }

    @ViewBuilder
    private func lessonPreview(_ id: String) -> some View {
        if NumberBondLesson.validID(id),
           let url = Bundle.main.url(forResource: id, withExtension: "json", subdirectory: "NumberBondLessons"),
           let lesson = try? NumberBondLesson.load(from: url), lesson.id == id {
            NumberBondLessonView(lesson: lesson)
        } else {
            ContentUnavailableView(
                "Lesson unavailable", systemImage: "book.closed",
                description: Text("The bundled lesson is missing or invalid.")
            )
        }
    }
#endif

    private var scaffold: some View {
        Text("Singapore Math with Juni")
            .font(.largeTitle)
            .fontWeight(.semibold)
            .multilineTextAlignment(.center)
            .accessibilityAddTraits(.isHeader)
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
