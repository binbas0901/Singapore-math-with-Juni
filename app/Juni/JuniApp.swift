import SwiftUI

@main
struct JuniApp: App {
    var body: some Scene {
        WindowGroup {
            Text("Singapore Math with Juni")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
