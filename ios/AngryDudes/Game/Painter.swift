import SpriteKit

/// Immediate-mode pixel drawing on top of SpriteKit, for the effects the prototype paints on
/// its canvas every frame: particles, blasts, trails, sling bands, aim dots, tracers, weather,
/// health bars and call-outs. Coordinates are logical pixels with y down; nodes are pooled and
/// reused, so drawing a frame doesn't allocate.
final class Painter {
    private let layer: SKNode
    private var rects: [SKSpriteNode] = []
    private var images: [SKSpriteNode] = []
    private var usedRects = 0, usedImages = 0

    init(layer: SKNode) { self.layer = layer }

    func begin() {
        usedRects = 0
        usedImages = 0
    }

    func end() {
        for i in usedRects..<rects.count where !rects[i].isHidden { rects[i].isHidden = true }
        for i in usedImages..<images.count where !images[i].isHidden { images[i].isHidden = true }
    }

    /// A filled rectangle, like canvas fillRect(x, y, w, h).
    func rect(_ x: Double, _ y: Double, _ w: Double, _ h: Double, _ color: SKColor, alpha: Double = 1, z: CGFloat) {
        guard w > 0, h > 0, alpha > 0 else { return }
        let n: SKSpriteNode
        if usedRects < rects.count {
            n = rects[usedRects]
        } else {
            n = SKSpriteNode(color: color, size: CGSize(width: 1, height: 1))
            n.anchorPoint = CGPoint(x: 0, y: 1)
            layer.addChild(n)
            rects.append(n)
        }
        usedRects += 1
        n.isHidden = false
        n.color = color
        n.alpha = CGFloat(alpha)
        n.zPosition = z
        n.position = CGPoint(x: x * K.PH, y: -y * K.PH)
        n.size = CGSize(width: w * K.PH, height: h * K.PH)
    }

    func rect(_ x: Double, _ y: Double, _ w: Double, _ h: Double, _ hex: String, alpha: Double = 1, z: CGFloat) {
        rect(x, y, w, h, Palette.color(hex), alpha: alpha, z: z)
    }

    /// A texture centered on x, y (call-outs and other text).
    func image(_ tex: SKTexture, x: Double, y: Double, alpha: Double = 1, z: CGFloat) {
        let n: SKSpriteNode
        if usedImages < images.count {
            n = images[usedImages]
        } else {
            n = SKSpriteNode(texture: tex)
            layer.addChild(n)
            images.append(n)
        }
        usedImages += 1
        n.isHidden = false
        if n.texture !== tex { n.texture = tex }
        let s = tex.size()
        n.size = CGSize(width: s.width * K.PH, height: s.height * K.PH)
        n.alpha = CGFloat(alpha)
        n.zPosition = z
        n.position = CGPoint(x: x.rounded() * K.PH, y: -y.rounded() * K.PH)
    }

    /// The prototype's pixel line: 1 × 2 dots along a Bresenham path.
    func line(_ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double, _ hex: String, z: CGFloat) {
        var x = Int(jsRound(x0)), y = Int(jsRound(y0))
        let tx = Int(jsRound(x1)), ty = Int(jsRound(y1))
        let dx = abs(tx - x), dy = -abs(ty - y), sx = x < tx ? 1 : -1, sy = y < ty ? 1 : -1
        var err = dx + dy
        let color = Palette.color(hex)
        for _ in 0..<400 {
            rect(Double(x), Double(y), 1, 2, color, z: z)
            if x == tx && y == ty { break }
            let e2 = 2 * err
            if e2 >= dy { err += dy; x += sx }
            if e2 <= dx { err += dx; y += sy }
        }
    }

    /// A filled pixel circle, one row at a time.
    func disc(_ cx: Double, _ cy: Double, _ r: Int, _ hex: String, z: CGFloat) {
        let color = Palette.color(hex)
        for dy in -r...r {
            let w = jsRound(sqrt(Double(r * r - dy * dy)))
            rect(cx - w, cy + Double(dy), w * 2, 1, color, z: z)
        }
    }
}
