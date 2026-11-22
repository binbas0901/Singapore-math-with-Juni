import SwiftUI

@main
struct JuniApp: App {
    var body: some Scene {
        WindowGroup {
#if DEBUG
            if ProcessInfo.processInfo.arguments.contains("-u07-preview") {
                U07Preview()
            } else {
                scaffold
            }
#else
            scaffold
#endif
        }
    }

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
