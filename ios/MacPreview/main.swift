// A Mac build of the game, made from the same Swift files as the iPhone app, for trying it
// out and testing it on a Mac without Xcode. Build and run with ios/tools/mac-preview.sh.
//
//   mac-preview.sh                       play in a window (mouse = finger)
//   mac-preview.sh --test script.txt     play a scripted battle offscreen, print what happened,
//                                        and save screenshots (see Headless.swift)
import SwiftUI

struct MacPreviewApp: App {
    @StateObject private var model = GameModel()

    var body: some Scene {
        WindowGroup("Angry Dudes") {
            RootView(model: model)
                .frame(minWidth: 700, minHeight: 330)
                .preferredColorScheme(.dark)
        }
        .defaultSize(width: 844, height: 390)
    }
}

let args = CommandLine.arguments
if let i = args.firstIndex(of: "--test"), i + 1 < args.count {
    let out = args.firstIndex(of: "--out").flatMap { $0 + 1 < args.count ? args[$0 + 1] : nil } ?? FileManager.default.currentDirectoryPath
    let ok = MainActor.assumeIsolated { Headless.run(script: args[i + 1], outDir: URL(fileURLWithPath: out)) }
    exit(ok ? 0 : 1)
} else if let i = args.firstIndex(of: "--icon"), i + 1 < args.count {
    MainActor.assumeIsolated { Headless.makeIcon(URL(fileURLWithPath: args[i + 1])) }
    exit(0)
} else {
    MacPreviewApp.main()
}
