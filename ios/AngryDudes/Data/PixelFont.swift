import CoreGraphics
import SpriteKit

/// A small 7 px tall bitmap font for battlefield call-outs ("RAT-A-TAT!", "1,500"), titles and
/// buttons. Text is drawn the way the prototype draws it: a dark outline, then the color on top.
/// No font files to bundle, and it stays crisp at any integer scale.
enum PixelFont {
    static let height = 7

    private static let glyphs: [Character: [String]] = [
        "A": [".###.", "#...#", "#...#", "#####", "#...#", "#...#", "#...#"],
        "B": ["####.", "#...#", "#...#", "####.", "#...#", "#...#", "####."],
        "C": [".###.", "#...#", "#....", "#....", "#....", "#...#", ".###."],
        "D": ["####.", "#...#", "#...#", "#...#", "#...#", "#...#", "####."],
        "E": ["#####", "#....", "#....", "####.", "#....", "#....", "#####"],
        "F": ["#####", "#....", "#....", "####.", "#....", "#....", "#...."],
        "G": [".###.", "#...#", "#....", "#.###", "#...#", "#...#", ".####"],
        "H": ["#...#", "#...#", "#...#", "#####", "#...#", "#...#", "#...#"],
        "I": ["###", ".#.", ".#.", ".#.", ".#.", ".#.", "###"],
        "J": ["..###", "...#.", "...#.", "...#.", "#..#.", "#..#.", ".##.."],
        "K": ["#...#", "#..#.", "#.#..", "##...", "#.#..", "#..#.", "#...#"],
        "L": ["#....", "#....", "#....", "#....", "#....", "#....", "#####"],
        "M": ["#...#", "##.##", "#.#.#", "#.#.#", "#...#", "#...#", "#...#"],
        "N": ["#...#", "#...#", "##..#", "#.#.#", "#..##", "#...#", "#...#"],
        "O": [".###.", "#...#", "#...#", "#...#", "#...#", "#...#", ".###."],
        "P": ["####.", "#...#", "#...#", "####.", "#....", "#....", "#...."],
        "Q": [".###.", "#...#", "#...#", "#...#", "#.#.#", "#..#.", ".##.#"],
        "R": ["####.", "#...#", "#...#", "####.", "#.#..", "#..#.", "#...#"],
        "S": [".####", "#....", "#....", ".###.", "....#", "....#", "####."],
        "T": ["#####", "..#..", "..#..", "..#..", "..#..", "..#..", "..#.."],
        "U": ["#...#", "#...#", "#...#", "#...#", "#...#", "#...#", ".###."],
        "V": ["#...#", "#...#", "#...#", "#...#", "#...#", ".#.#.", "..#.."],
        "W": ["#...#", "#...#", "#...#", "#.#.#", "#.#.#", "#.#.#", ".#.#."],
        "X": ["#...#", "#...#", ".#.#.", "..#..", ".#.#.", "#...#", "#...#"],
        "Y": ["#...#", "#...#", ".#.#.", "..#..", "..#..", "..#..", "..#.."],
        "Z": ["#####", "....#", "...#.", "..#..", ".#...", "#....", "#####"],
        "0": [".###.", "#...#", "#..##", "#.#.#", "##..#", "#...#", ".###."],
        "1": [".#.", "##.", ".#.", ".#.", ".#.", ".#.", "###"],
        "2": [".###.", "#...#", "....#", "...#.", "..#..", ".#...", "#####"],
        "3": ["####.", "....#", "....#", ".###.", "....#", "....#", "####."],
        "4": ["...#.", "..##.", ".#.#.", "#..#.", "#####", "...#.", "...#."],
        "5": ["#####", "#....", "####.", "....#", "....#", "#...#", ".###."],
        "6": [".###.", "#....", "#....", "####.", "#...#", "#...#", ".###."],
        "7": ["#####", "....#", "...#.", "..#..", ".#...", ".#...", ".#..."],
        "8": [".###.", "#...#", "#...#", ".###.", "#...#", "#...#", ".###."],
        "9": [".###.", "#...#", "#...#", ".####", "....#", "....#", ".###."],
        "!": ["#", "#", "#", "#", "#", ".", "#"],
        ".": [".", ".", ".", ".", ".", ".", "#"],
        ",": ["..", "..", "..", "..", "..", ".#", "#."],
        "-": ["...", "...", "...", "###", "...", "...", "..."],
        "'": ["#", "#", ".", ".", ".", ".", "."],
        "\"": ["#.#", "#.#", "...", "...", "...", "...", "..."],
        "°": [".#.", "#.#", ".#.", "...", "...", "...", "..."],
        "%": ["##..#", "##.#.", "...#.", "..#..", ".#...", ".#.##", "#..##"],
        "?": [".###.", "#...#", "....#", "...#.", "..#..", ".....", "..#.."],
        ":": [".", "#", ".", ".", ".", "#", "."],
        "/": ["..#", "..#", ".#.", ".#.", ".#.", "#..", "#.."],
        "+": ["...", "...", ".#.", "###", ".#.", "...", "..."],
        "×": ["...", "...", "#.#", ".#.", "#.#", "...", "..."],
        "(": [".#", "#.", "#.", "#.", "#.", "#.", ".#"],
        ")": ["#.", ".#", ".#", ".#", ".#", ".#", "#."],
        " ": ["..", "..", "..", "..", "..", "..", ".."],
    ]

    private static func glyph(_ ch: Character) -> [String] {
        switch ch {
        case "“", "”": return glyphs["\""]!
        case "‘", "’": return glyphs["'"]!
        case "–", "—": return glyphs["-"]!
        default: return glyphs[Character(ch.uppercased())] ?? glyphs[" "]!
        }
    }

    private static func layout(_ text: String) -> [Character] {
        Array(text.replacingOccurrences(of: "…", with: "..."))
    }

    static func width(_ text: String) -> Int {
        let chars = layout(text)
        guard !chars.isEmpty else { return 0 }
        return chars.reduce(0) { $0 + glyph($1)[0].count } + chars.count - 1
    }

    /// Draws text with its top-left corner at x, y.
    static func draw(_ text: String, into c: inout PixelCanvas, x: Int, y: Int, color: RGBA) {
        var cx = x
        for ch in layout(text) {
            let g = glyph(ch)
            for (gy, row) in g.enumerated() {
                for (gx, p) in row.enumerated() where p == "#" { c.set(cx + gx, y + gy, color) }
            }
            cx += g[0].count + 1
        }
    }

    /// Text with the prototype's outline: dark copies around it, then the color on top.
    static func canvas(_ text: String, color: String, outline: String? = K.outline, shadow: Int = 1) -> PixelCanvas {
        let w = width(text)
        let pad = outline == nil ? 0 : 1
        let extra = outline == nil ? 0 : max(0, shadow - 1)
        var c = PixelCanvas(width: w + pad * 2 + extra, height: height + pad * 2 + extra)
        if let outline {
            let k = RGBA(outline)
            var offsets = [(-1, 0), (1, 0), (0, -1), (0, 1)]
            if shadow > 0 {
                for j in 1...shadow {
                    offsets.append((j, j))
                    if j > 1 { offsets += [(j - 1, j), (j, j - 1)] }
                }
            }
            for (dx, dy) in offsets { draw(text, into: &c, x: pad + dx, y: pad + dy, color: k) }
        }
        draw(text, into: &c, x: pad, y: pad, color: RGBA(color))
        return c
    }

    private static var images: [String: CGImage] = [:]

    static func image(_ text: String, color: String, outline: String? = K.outline, shadow: Int = 1) -> CGImage {
        let key = "\(text)|\(color)|\(outline ?? "-")|\(shadow)"
        if let i = images[key] { return i }
        let i = canvas(text, color: color, outline: outline, shadow: shadow).makeImage()
        images[key] = i
        return i
    }

    static func texture(_ text: String, color: String) -> SKTexture {
        SpriteSheet.shared.cached("f:\(text)|\(color)") { canvas(text, color: color, shadow: 1) }
    }

    /// The prototype's 9×9 pixel star, gold when earned.
    static func star(on: Bool) -> CGImage {
        let key = on ? "*on" : "*off"
        if let i = images[key] { return i }
        let rows = ["....#....", "....#....", "...###...", "#########", ".#######.", "..#####..", "..#####..", ".##...##.", ".#.....#."]
        var c = PixelCanvas(width: 9, height: 9)
        let col = RGBA(on ? "#ffd23f" : "#3b4330")
        for (y, row) in rows.enumerated() { for (x, p) in row.enumerated() where p == "#" { c.set(x, y, col) } }
        let i = c.makeImage()
        images[key] = i
        return i
    }
}
