import Foundation
import CoreGraphics

/// A campaign strings a pack's battles into a route on a map (the `campaign` block in a pack
/// file). Each first win offers a choice of three rewards that stay with the army for the rest
/// of the campaign, and each mission's defenders are tougher (`toughness`).
struct CampaignSpec: Decodable {
    struct Mission: Decodable { let level: String; let x: Double; let y: Double; let via: [[Double]]? }
    struct Buff: Decodable { let power: Double?; let boom: Double?; let hp: Double? }
    struct Reward: Decodable {
        let id: String, name: String, text: String, icon: String
        let add: [String: Int]?         // extra items in every battle
        let buff: [String: Buff]?       // upgrades to units
    }
    struct MapSpec: Decodable {
        struct Land: Decodable { let tint: String?; let pts: [[Double]] }
        struct River: Decodable { let w: Double?; let pts: [[Double]] }
        struct Forest: Decodable { let x: Double, y: Double, rx: Double, ry: Double }
        struct City: Decodable { let name: String; let x: Double; let y: Double }
        struct Label: Decodable { let text: String; let x: Double; let y: Double; let sea: Bool? }
        let land: [Land]
        let rivers: [River]?
        let forests: [Forest]?
        let cities: [City]?
        let labels: [Label]?
    }

    let name: String
    let blurb: String
    let ranks: [String]
    let toughness: [Double]
    let missions: [Mission]
    let rewards: [Reward]
    let map: MapSpec

    static let mapW = 384, mapH = 216

    func reward(_ id: String) -> Reward? { rewards.first { $0.id == id } }
    func tough(_ i: Int) -> Double { i < toughness.count ? toughness[i] : 1 }
    /// The first mission not won yet (missions.count when all are won).
    func next(_ s: CampaignState) -> Int { missions.firstIndex { !s.done.contains($0.level) } ?? missions.count }
    func rank(_ s: CampaignState) -> String { ranks.isEmpty ? "" : ranks[min(ranks.count - 1, s.done.count)] }
    func complete(_ s: CampaignState) -> Bool { !missions.isEmpty && s.done.count >= missions.count }
}

/// Campaign progress, saved per pack under the prototype's key name.
struct CampaignState: Codable, Equatable {
    var done: [String] = []                 // missions won, by level id
    var perks: [String] = []                // rewards picked
    var stars: [String: Int] = [:]
    var offers: [String: [String]] = [:]    // the three rewards offered after each first win
    var pending: String?                    // a win whose reward hasn't been picked yet

    static func load(_ pack: String) -> CampaignState {
        guard let data = UserDefaults.standard.data(forKey: key(pack)),
              let s = try? JSONDecoder().decode(CampaignState.self, from: data) else { return CampaignState() }
        return s
    }

    func save(_ pack: String) {
        if let data = try? JSONEncoder().encode(self) { UserDefaults.standard.set(data, forKey: CampaignState.key(pack)) }
    }

    static func erase(_ pack: String) { UserDefaults.standard.removeObject(forKey: key(pack)) }

    private static func key(_ pack: String) -> String { "angrydudes.campaign.\(pack)" }
}

/// The mission being played, handed to the battlefield.
struct CampaignRun {
    /// Every upgrade to one unit, combined.
    struct Buff { var power = 1.0, boomR = 1.0, boomP = 1.0, hp = 1.0 }

    let spec: CampaignSpec
    let index: Int
    var state: CampaignState

    var buffs: [String: Buff] {
        var out: [String: Buff] = [:]
        for id in state.perks {
            guard let r = spec.reward(id), let buff = r.buff else { continue }
            for (k, b) in buff {
                var u = out[k] ?? Buff()
                if let p = b.power { u.power *= p }
                if let m = b.boom { u.boomR *= m; u.boomP *= 1.15 }
                if let h = b.hp { u.hp *= h }
                out[k] = u
            }
        }
        return out
    }
}

/// Paints a campaign map like the prototype's drawCampaignMap: land from outlines with a sandy
/// shore, sea everywhere else, forests, rivers, cities, and the route (solid gold where you've
/// fought, dashed white ahead). Labels and mission pins are drawn on top by the SwiftUI view.
enum CampaignMap {
    static func paint(_ C: CampaignSpec, _ s: CampaignState) -> PixelCanvas {
        let W = CampaignSpec.mapW, H = CampaignSpec.mapH, M = C.map
        var c = PixelCanvas(width: W, height: H)
        var mask = [Int](repeating: 0, count: W * H)
        // land from outlines (even-odd scanline fill)
        for (n, poly) in M.land.enumerated() {
            let pts = poly.pts
            for y in 0..<H {
                let yy = Double(y) + 0.5
                var cuts: [Double] = []
                for e in 0..<pts.count {
                    let p0 = pts[e], p1 = pts[(e + 1) % pts.count]
                    if (p0[1] <= yy) != (p1[1] <= yy) { cuts.append(p0[0] + (yy - p0[1]) / (p1[1] - p0[1]) * (p1[0] - p0[0])) }
                }
                cuts.sort()
                var q = 0
                while q + 1 < cuts.count {
                    var x = max(0, Int((cuts[q] - 0.5).rounded(.up)))
                    while x < W && Double(x) < cuts[q + 1] - 0.5 { mask[y * W + x] = n + 1; x += 1 }
                    q += 2
                }
            }
        }
        let tints: [String: [String]] = ["england": ["#86a85e", "#78994f", "#97b86c"], "europe": ["#9aa860", "#8a9852", "#a9b56f"]]
        let r = seededRandom(77)
        for y in 0..<H {
            for x in 0..<W {
                let i = y * W + x, v = r()
                if mask[i] == 0 {
                    c.set(x, y, RGBA(x % 32 == 16 || y % 32 == 16 ? "#284d73" : v < 0.05 ? "#3a6a96" : "#2f5a85"))
                    continue
                }
                let t = tints[M.land[mask[i] - 1].tint ?? ""] ?? tints["europe"]!
                c.set(x, y, RGBA(v < 0.14 ? t[1] : v > 0.9 ? t[2] : t[0]))
            }
        }
        func land(_ x: Int, _ y: Int) -> Bool { x >= 0 && y >= 0 && x < W && y < H && mask[y * W + x] > 0 }
        for y in 0..<H {
            for x in 0..<W {
                let l = land(x, y)
                if land(x + 1, y) != l || land(x - 1, y) != l || land(x, y + 1) != l || land(x, y - 1) != l {
                    c.set(x, y, RGBA(l ? "#d9c48a" : "#8fc0e0"))      // sandy shore, white surf
                }
            }
        }
        for f in M.forests ?? [] {
            let fr = seededRandom(Int(f.x))
            for _ in 0..<Int((f.rx * f.ry / 3).rounded(.up)) {
                let a = fr() * .pi * 2, rr = fr().squareRoot()
                let tx = Int(jsRound(f.x + cos(a) * rr * f.rx)), ty = Int(jsRound(f.y + sin(a) * rr * f.ry))
                c.fill(tx, ty, 2, 2, RGBA("#2f5a2a")); c.set(tx, ty, RGBA("#4f8a3a"))
            }
        }
        for rv in M.rivers ?? [] {
            for k in 0..<max(0, rv.pts.count - 1) {
                route(&c, rv.pts[k], rv.pts[k + 1], "#3f78b5", dashed: false)
                if (rv.w ?? 2) < 2 { route(&c, [rv.pts[k][0] + 1, rv.pts[k][1]], [rv.pts[k + 1][0] + 1, rv.pts[k + 1][1]], "#9aa860", dashed: false) }
            }
        }
        for ct in M.cities ?? [] {
            c.fill(Int(ct.x) - 2, Int(ct.y) - 2, 5, 5, RGBA("#1d1a2b"))
            c.fill(Int(ct.x) - 1, Int(ct.y) - 1, 3, 3, .white)
        }
        // the route: solid gold where you've already fought, dashed white ahead
        for k in 1..<max(1, C.missions.count) {
            let m = C.missions[k], prev = C.missions[k - 1], won = s.done.contains(m.level)
            let pts = [[prev.x, prev.y]] + (m.via ?? []) + [[m.x, m.y]]
            for j in 0..<(pts.count - 1) {
                if won { route(&c, [pts[j][0] - 1, pts[j][1] - 1], [pts[j + 1][0] - 1, pts[j + 1][1] - 1], "#1d1a2b", dashed: false) }
                route(&c, pts[j], pts[j + 1], won ? "#ffd23f" : "#ffffff", dashed: !won)
            }
        }
        return c
    }

    private static func route(_ c: inout PixelCanvas, _ a: [Double], _ b: [Double], _ hex: String, dashed: Bool) {
        let n = Int(max(abs(b[0] - a[0]), abs(b[1] - a[1])))
        guard n > 0 else { return }
        let col = RGBA(hex)
        for k in 0...n {
            if dashed && k % 6 > 3 { continue }
            let x = Int(jsRound(a[0] + (b[0] - a[0]) * Double(k) / Double(n))), y = Int(jsRound(a[1] + (b[1] - a[1]) * Double(k) / Double(n)))
            c.fill(x, y, dashed ? 1 : 2, dashed ? 1 : 2, col)
        }
    }
}
