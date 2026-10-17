import Foundation

/// Finds the game data the app shares with the HTML prototype: assets/sprites.json and
/// assets/packs/*.json. The Xcode project copies the repo's `assets` folder into the app
/// bundle as-is; the ANGRY_ASSETS environment variable points somewhere else instead (for tests).
enum GameAssets {
    static func url(_ path: String) -> URL? {
        var roots: [URL] = []
        if let env = ProcessInfo.processInfo.environment["ANGRY_ASSETS"] { roots.append(URL(fileURLWithPath: env)) }
        if let res = Bundle.main.resourceURL { roots.append(res.appendingPathComponent("assets")) }
        for root in roots {
            let url = root.appendingPathComponent(path)
            if FileManager.default.fileExists(atPath: url.path) { return url }
        }
        return nil
    }

    static func data(_ path: String) -> Data {
        guard let url = url(path), let data = try? Data(contentsOf: url) else {
            fatalError("Missing game data: assets/\(path). Run tools/export_packs.py and check the assets folder reference.")
        }
        return data
    }
}
