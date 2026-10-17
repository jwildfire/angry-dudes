import CoreGraphics
import SpriteKit

/// All of the game's pixel art, read from assets/sprites.json (the same file the HTML
/// prototype is built from). Each sprite is rows of palette characters; a character's
/// color comes from the sprite's own palette, then its team's colors, then the shared palette.
final class SpriteSheet {
    static let shared = SpriteSheet()

    private struct File: Decodable {
        let palette: [String: String]
        let teams: [String: [String: String]]
        let sprites: [String: Raw]
    }
    private struct Raw: Decodable {
        let rows: [String]
        let team: String?
        let pal: [String: String]?
    }

    private let file: File
    private var canvases: [String: PixelCanvas] = [:]
    private var images: [String: CGImage] = [:]
    private var textures: [String: SKTexture] = [:]

    init() {
        do {
            file = try JSONDecoder().decode(File.self, from: GameAssets.data("sprites.json"))
        } catch {
            fatalError("sprites.json: \(error)")
        }
    }

    func has(_ name: String) -> Bool { file.sprites[name] != nil }

    func canvas(_ name: String) -> PixelCanvas {
        if let c = canvases[name] { return c }
        guard let raw = file.sprites[name], let first = raw.rows.first else {
            let empty = PixelCanvas(width: 8, height: 8)
            canvases[name] = empty
            return empty
        }
        var colors: [Character: RGBA] = [:]
        for (k, v) in file.palette { if let ch = k.first { colors[ch] = RGBA(v) } }
        if let team = raw.team, let tp = file.teams[team] { for (k, v) in tp { if let ch = k.first { colors[ch] = RGBA(v) } } }
        for (k, v) in raw.pal ?? [:] { if let ch = k.first { colors[ch] = RGBA(v) } }
        var c = PixelCanvas(width: first.count, height: raw.rows.count)
        for (y, row) in raw.rows.enumerated() {
            for (x, ch) in row.enumerated() where ch != "." {
                if let col = colors[ch] { c.set(x, y, col) }
            }
        }
        canvases[name] = c
        return c
    }

    func size(_ name: String) -> CGSize {
        let c = canvas(name)
        return CGSize(width: c.width, height: c.height)
    }

    func image(_ name: String) -> CGImage {
        if let i = images[name] { return i }
        let i = canvas(name).makeImage()
        images[name] = i
        return i
    }

    func texture(_ name: String) -> SKTexture {
        cached("s:" + name) { canvas(name) }
    }

    /// Any derived texture (flash silhouettes, cracked blocks, long slabs), built once per key.
    func cached(_ key: String, _ build: () -> PixelCanvas) -> SKTexture {
        if let t = textures[key] { return t }
        let t = build().makeTexture()
        textures[key] = t
        return t
    }

    func white(_ name: String) -> SKTexture {
        cached("w:" + name) { canvas(name).silhouette(.white) }
    }

    /// A block sprite with the crack overlay centered on its physics body.
    func cracked(_ name: String, bodyW: Double, bodyH: Double, ox: Double) -> SKTexture {
        cached("c:\(name):\(bodyH):\(ox)") {
            var c = canvas(name)
            let cx = Int(jsRound(Double(c.width) / 2 - ox)), cy = Int(jsRound(Double(c.height) - bodyH / 2))
            c.draw(SpriteSheet.crack, cx - 8, cy - 8)
            return c
        }
    }

    /// A long slab (8 px unless the block sets `h`): the top of a block sprite tiled across,
    /// with a dark outline, or with end pieces (`caps`, like a ship's bow and stern) instead.
    func slab(_ name: String, w: Int, h: Int, cracked: Bool, caps: [String]? = nil) -> SKTexture {
        cached("t:\(name):\(w):\(h):\(cracked):\(caps?.joined(separator: ",") ?? "")") {
            let src = canvas(name)
            var c = PixelCanvas(width: w, height: h)
            var x = 0
            while x < w {
                var tile = src
                if let caps, caps.count >= 2 {
                    if x == 0 { tile = canvas(caps[0]) } else if x + 16 >= w { tile = canvas(caps[1]) }
                }
                c.draw(tile, x, 0, from: (0, 0, 16, h))
                x += 16
            }
            if caps == nil {
                let k = RGBA(K.outline)
                c.fill(0, h - 1, w, 1, k); c.fill(0, 0, 1, h, k); c.fill(w - 1, 0, 1, h, k)
            }
            if cracked {
                x = 0
                while x < w { c.draw(SpriteSheet.crack, x + 6, 0, from: (0, 4, 16, 8)); x += 32 }
            }
            return c
        }
    }

    /// Three wandering crack lines, drawn the same way as the prototype.
    static let crack: PixelCanvas = {
        var c = PixelCanvas(width: 16, height: 16)
        let r = seededRandom(9), col = RGBA("#1d1a2b", alpha: 0.75)
        for _ in 0..<3 {
            var px = 3 + Int(r() * 10), py = 2 + Int(r() * 4)
            for _ in 0..<9 {
                c.set(px, py, col)
                px += Int(jsRound(r() * 2 - 1)); py += 1
            }
        }
        return c
    }()
}
