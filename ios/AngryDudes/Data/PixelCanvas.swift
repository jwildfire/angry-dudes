import CoreGraphics
import SpriteKit

/// An 8-bit RGBA color, parsed from the "#rrggbb" strings the packs and sprites use.
struct RGBA: Hashable {
    var r: UInt8, g: UInt8, b: UInt8, a: UInt8

    init(r: UInt8, g: UInt8, b: UInt8, a: UInt8 = 255) {
        self.r = r; self.g = g; self.b = b; self.a = a
    }

    init(_ hex: String, alpha: Double = 1) {
        var s = Substring(hex)
        if s.hasPrefix("#") { s = s.dropFirst() }
        if s.count == 3 { s = Substring(s.map { "\($0)\($0)" }.joined()) }
        let v = UInt32(s, radix: 16) ?? 0
        r = UInt8((v >> 16) & 0xff); g = UInt8((v >> 8) & 0xff); b = UInt8(v & 0xff)
        a = UInt8(max(0, min(255, (alpha * 255).rounded())))
    }

    static let clear = RGBA(r: 0, g: 0, b: 0, a: 0)
    static let white = RGBA(r: 255, g: 255, b: 255)
}

/// SKColor lookup with a cache, so per-frame drawing doesn't re-parse hex strings.
enum Palette {
    private static var cache: [String: SKColor] = [:]

    static func color(_ hex: String) -> SKColor {
        if let c = cache[hex] { return c }
        let v = RGBA(hex)
        let c = SKColor(red: CGFloat(v.r) / 255, green: CGFloat(v.g) / 255, blue: CGFloat(v.b) / 255, alpha: 1)
        cache[hex] = c
        return c
    }
}

/// A tiny software canvas for building pixel art: sprites, the battlefield background,
/// text. Pixels are premultiplied RGBA; fills clip to the canvas and blend when translucent.
struct PixelCanvas {
    let width: Int
    let height: Int
    private(set) var px: [UInt8]

    init(width: Int, height: Int) {
        self.width = max(1, width)
        self.height = max(1, height)
        px = [UInt8](repeating: 0, count: self.width * self.height * 4)
    }

    mutating func fill(_ x: Int, _ y: Int, _ w: Int, _ h: Int, _ c: RGBA) {
        let x0 = max(0, x), y0 = max(0, y), x1 = min(width, x + w), y1 = min(height, y + h)
        guard x0 < x1, y0 < y1, c.a > 0 else { return }
        if c.a == 255 {
            for yy in y0..<y1 {
                var i = (yy * width + x0) * 4
                for _ in x0..<x1 {
                    px[i] = c.r; px[i + 1] = c.g; px[i + 2] = c.b; px[i + 3] = 255
                    i += 4
                }
            }
        } else {
            let a = Int(c.a), ia = 255 - a
            let pr = Int(c.r) * a / 255, pg = Int(c.g) * a / 255, pb = Int(c.b) * a / 255
            for yy in y0..<y1 {
                var i = (yy * width + x0) * 4
                for _ in x0..<x1 {
                    px[i] = UInt8(pr + Int(px[i]) * ia / 255)
                    px[i + 1] = UInt8(pg + Int(px[i + 1]) * ia / 255)
                    px[i + 2] = UInt8(pb + Int(px[i + 2]) * ia / 255)
                    px[i + 3] = UInt8(a + Int(px[i + 3]) * ia / 255)
                    i += 4
                }
            }
        }
    }

    mutating func set(_ x: Int, _ y: Int, _ c: RGBA) { fill(x, y, 1, 1, c) }

    func alpha(_ x: Int, _ y: Int) -> UInt8 {
        guard x >= 0, y >= 0, x < width, y < height else { return 0 }
        return px[(y * width + x) * 4 + 3]
    }

    /// Draws `src` (or the part of it in `from`) with its top-left corner at x, y.
    mutating func draw(_ src: PixelCanvas, _ x: Int, _ y: Int, from: (x: Int, y: Int, w: Int, h: Int)? = nil) {
        let r = from ?? (0, 0, src.width, src.height)
        for sy in 0..<r.h {
            let ty = y + sy, yy = r.y + sy
            guard ty >= 0, ty < height, yy >= 0, yy < src.height else { continue }
            for sx in 0..<r.w {
                let tx = x + sx, xx = r.x + sx
                guard tx >= 0, tx < width, xx >= 0, xx < src.width else { continue }
                let si = (yy * src.width + xx) * 4, ti = (ty * width + tx) * 4
                let a = Int(src.px[si + 3])
                if a == 0 { continue }
                let ia = 255 - a
                px[ti] = UInt8(Int(src.px[si]) + Int(px[ti]) * ia / 255)
                px[ti + 1] = UInt8(Int(src.px[si + 1]) + Int(px[ti + 1]) * ia / 255)
                px[ti + 2] = UInt8(Int(src.px[si + 2]) + Int(px[ti + 2]) * ia / 255)
                px[ti + 3] = UInt8(a + Int(px[ti + 3]) * ia / 255)
            }
        }
    }

    /// Every opaque pixel becomes `c`; used for the white hit flash.
    func silhouette(_ c: RGBA) -> PixelCanvas {
        var out = PixelCanvas(width: width, height: height)
        for y in 0..<height { for x in 0..<width where alpha(x, y) > 0 { out.set(x, y, c) } }
        return out
    }

    func makeImage() -> CGImage {
        let data = Data(px) as CFData
        return CGImage(width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: width * 4,
                       space: CGColorSpace(name: CGColorSpace.sRGB)!,
                       bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                       provider: CGDataProvider(data: data)!, decode: nil, shouldInterpolate: false, intent: .defaultIntent)!
    }

    func makeTexture() -> SKTexture {
        let t = SKTexture(cgImage: makeImage())
        t.filteringMode = .nearest
        return t
    }
}

/// The prototype's small seeded random generator (mulberry32), so backgrounds come out the same.
func seededRandom(_ seed: Int) -> () -> Double {
    var s = UInt32(truncatingIfNeeded: seed)
    return {
        s = s &+ 0x6D2B79F5
        var t = (s ^ (s >> 15)) &* (1 | s)
        t = (t &+ ((t ^ (t >> 7)) &* (61 | t))) ^ t
        return Double(t ^ (t >> 14)) / 4294967296.0
    }
}

/// JavaScript's Math.round (halves round up, toward +∞).
@inline(__always) func jsRound(_ x: Double) -> Double { (x + 0.5).rounded(.down) }
@inline(__always) func clamp<T: Comparable>(_ v: T, _ a: T, _ b: T) -> T { v < a ? a : (v > b ? b : v) }

/// Whole numbers with thousands commas, like the prototype's toLocaleString("en-US").
func fmt(_ n: Int) -> String {
    let digits = String(abs(n))
    var out = ""
    for (i, ch) in digits.enumerated() {
        if i > 0 && (digits.count - i) % 3 == 0 { out.append(",") }
        out.append(ch)
    }
    return (n < 0 ? "-" : "") + out
}
