import Foundation

/// Best scores and the last pack played, kept in UserDefaults with the prototype's key names.
enum Store {
    struct Best: Codable, Equatable { var score: Int; var stars: Int }

    static func best(pack: String, level: String) -> Best {
        guard let data = UserDefaults.standard.data(forKey: key(pack, level)),
              let best = try? JSONDecoder().decode(Best.self, from: data) else { return Best(score: 0, stars: 0) }
        return best
    }

    static func record(pack: String, level: String, score: Int, stars: Int) {
        let old = best(pack: pack, level: level)
        guard score > old.score || stars > old.stars else { return }
        let new = Best(score: max(score, old.score), stars: max(stars, old.stars))
        if let data = try? JSONEncoder().encode(new) { UserDefaults.standard.set(data, forKey: key(pack, level)) }
    }

    /// Losses in a row on a level; after two, the next try gets a bonus troop.
    static func losses(pack: String, level: String) -> Int {
        UserDefaults.standard.integer(forKey: "angrydudes.losses.\(pack).\(level)")
    }

    static func setLosses(_ n: Int, pack: String, level: String) {
        UserDefaults.standard.set(n, forKey: "angrydudes.losses.\(pack).\(level)")
    }

    static var lastPack: String? {
        get { UserDefaults.standard.string(forKey: "angrydudes.pack") }
        set { UserDefaults.standard.set(newValue, forKey: "angrydudes.pack") }
    }

    private static func key(_ pack: String, _ level: String) -> String { "angrydudes.best.\(pack).\(level)" }
}
