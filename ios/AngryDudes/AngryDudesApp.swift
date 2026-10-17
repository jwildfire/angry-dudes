#if os(iOS)
import SwiftUI

@main
struct AngryDudesApp: App {
    @StateObject private var model = GameModel()

    var body: some Scene {
        WindowGroup {
            RootView(model: model)
                .statusBarHidden(true)
                .persistentSystemOverlays(.hidden)
                .defersSystemGestures(on: .bottom)      // a swipe on the arsenal bar shouldn't go home
                .preferredColorScheme(.dark)
        }
    }
}
#endif
