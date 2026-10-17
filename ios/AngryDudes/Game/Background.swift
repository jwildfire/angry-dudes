import CoreGraphics

/// Paints the still part of a battlefield (sky, sun or moon, clouds, hills, ground, cliff,
/// craters, trenches and rivers, the player's bunker and slingshot) into one pixel canvas, the
/// same way the prototype's buildBackground does. The canvas covers the whole battlefield plus
/// `pad` pixels on each side; world x = 0 is at canvas x = pad, world y = 0 at canvas y = -oy.
enum Background {
    /// `skyTop` is the world y just under the HUD: on a short screen the sun, moon and planet move
    /// down to it so they stay in view.
    static func paint(pack: PackSpec, level: LevelSpec, levelIndex: Int, worldW: Int, pad: Int, height: Int, oy: Int, skyTop: Int = 0) -> PixelCanvas {
        let ox = pad
        var c = PixelCanvas(width: worldW + pad * 2, height: height)
        guard let th = pack.themes[level.theme] else { return c }
        let gy = oy + Int(K.ground)
        let bufW = c.width, bufH = height

        // sky bands with a dithered edge between them
        let bh = Double(gy) / Double(th.sky.count)
        for (k, col) in th.sky.enumerated() {
            c.fill(0, Int(jsRound(Double(k) * bh)), bufW, Int(bh.rounded(.up)) + 1, RGBA(col))
        }
        if th.sky.count > 1 {
            for i in 1..<th.sky.count {
                let y = Int(jsRound(Double(i) * bh)), col = RGBA(th.sky[i - 1])
                for x in stride(from: 0, to: bufW, by: 2) { c.set(x, y, col) }
                for x in stride(from: 1, to: bufW, by: 4) { c.set(x, y + 1, col) }
            }
        }

        let sr = seededRandom(levelIndex + 41)
        if th.night == true {
            let star = RGBA("#fff6c8")
            for _ in 0..<(bufW * gy / 160) {
                let sx = Int(sr() * Double(bufW)), sy = Int(sr() * Double(gy) * 0.7)
                c.set(sx, sy, star)
            }
            if let pl = th.planet, pl.count >= 2 {
                // a planet hanging in space: [ocean or body, land or bands, ring]
                let px0 = ox + worldW - 130, py0 = oy + max(52, skyTop + 24), pr = seededRandom(9)
                let ring = pl.count > 2 ? RGBA(pl[2]) : nil
                if let ring { c.fill(px0 - 34, py0 - 1, 68, 2, ring) }
                disc(&c, px0, py0, 20, RGBA(pl[0]))
                let bands = RGBA(pl[1])
                for _ in 0..<26 {
                    let bx = px0 - 16 + Int(pr() * 28), by = py0 - 15 + Int(pr() * 28)
                    c.fill(bx, by, 3 + Int(pr() * 5), 2, bands)
                }
                if let ring { c.fill(px0 - 34, py0 + 1, 14, 1, ring); c.fill(px0 + 20, py0 + 1, 14, 1, ring) }
            } else {
                let my = oy + max(40, skyTop + 13)
                disc(&c, ox + worldW - 100, my, 9, RGBA("#f3efd2"))
                let shade = RGBA(th.sky[min(1, th.sky.count - 1)])
                c.fill(ox + worldW - 104, my - 4, 3, 2, shade)
                c.fill(ox + worldW - 97, my + 4, 2, 2, shade)
            }
        } else if let sun = th.sun {
            disc(&c, ox + worldW - 80, oy + max(44, skyTop + 14), 10, RGBA(sun))
        }
        if th.clouds == true {
            let r = seededRandom(levelIndex + 3)
            let col = RGBA(th.cloud ?? "#ffffff")
            for i in 0..<Int((Double(bufW) / 120).rounded(.up)) {
                let x = Int(Double(i * 120) + r() * 60)
                let y = oy + 20 + Int(r() * 60)
                cloud(&c, x, y, big: r() < 0.5, col)
            }
        }

        // two rows of rolling hills, with trees on the far row
        let hr = seededRandom(17)
        let rows: [(String, Double, Double, Double, Double, Double)] = [
            (th.hills[0], 34, 10, 47, 19, 0.3),
            (th.hills.count > 1 ? th.hills[1] : th.hills[0], 16, 6, 31, 13, 1.7),
        ]
        for (k, h) in rows.enumerated() {
            let col = RGBA(h.0)
            for x in stride(from: 0, to: bufW, by: 2) {
                let fx = Double(x - ox)
                let raw = h.1 + h.2 * sin(fx / h.3 + h.5) + h.2 * 0.5 * sin(fx / h.4 + h.5 * 2)
                let hh = Int(jsRound(raw / 2)) * 2
                c.fill(x, gy - hh, 2, hh, col)
                if let trees = th.trees, k == 0, hr() < 0.08 {
                    tree(&c, x, gy - hh + 1, kind: trees, color: th.treeColor)
                }
            }
        }

        // ground, split into two colors (beach sand and grass) or one
        let split = ox + Int(level.cliff?.x ?? th.split ?? 9999)
        groundBand(&c, 0, clamp(split, 0, bufW), gy, bufH, th.left, seed: 3)
        if split < bufW { groundBand(&c, max(0, split), bufW - max(0, split), gy, bufH, th.right, seed: 11) }
        if let cliff = level.cliff {
            let cx = ox + Int(cliff.x), ch = Int(cliff.h), top = gy - ch
            let rr = seededRandom(5)
            let rock = (th.rock ?? ["#8d8a82", "#6f6c66", "#aaa79f"]).map { RGBA($0) }
            c.fill(cx, top, bufW - cx, ch, rock[0])
            var y = top + 5
            while y < gy {
                var x = cx
                while x < bufW {
                    if rr() < 0.6 { c.fill(x, y, 3 + Int(rr() * 4), 1, rock[1]) }
                    x += 4
                }
                y += 6
            }
            c.fill(cx, top, 2, ch, rock[2])
            c.fill(cx - 1, top, 1, ch, RGBA(K.outline))
            groundBand(&c, cx, bufW - cx, top, top + 4, th.right, seed: 23)
        }

        // shell craters (scenery), then trenches and rivers cut into the ground
        let tc = th.trench ?? TrenchColors(cut: "#3b2a1c", plank: "#6b4a2b", floor: "#8a6a45", slat: "#5e3a1d")
        for k in level.craters ?? [] {
            let kx = ox + Int(k.x), r = k.r ?? 12
            var dy = 0.0
            while dy <= r / 2 {
                let w = Int(jsRound((1 - pow(dy / (r / 2 + 0.5), 2)).squareRoot() * r))
                c.fill(kx - w, gy + Int(dy), w * 2, 1, RGBA(dy == 0 ? th.left.lo : tc.cut))
                dy += 1
            }
            let ri = Int(r)
            c.fill(kx - ri - 2, gy - 1, 3, 1, RGBA(th.left.hi))
            c.fill(kx + ri - 1, gy - 1, 3, 1, RGBA(th.left.hi))
        }
        for t in level.trenches ?? [] {
            let tx = ox + Int(t.x), tw = Int(t.w), td = Int(t.d)
            if t.water == true {
                // a river or moat: dark banks, water up to just below ground level, a few wave crests
                c.fill(tx, gy, tw, td, RGBA(tc.cut))
                c.fill(tx, gy + 4, tw, td - 4, RGBA(th.water ?? "#3f78b5"))
                let hi = RGBA(th.waterHi ?? "#7fb8e8")
                c.fill(tx, gy + 4, tw, 1, hi)
                var x = tx + 3
                while x < tx + tw - 3 { c.fill(x, gy + 7 + (x / 9) % 2, 4, 1, hi); x += 9 }
                continue
            }
            c.fill(tx, gy, tw, td, RGBA(tc.cut))
            var y = gy
            while y < gy + td { c.fill(tx, y, 2, 3, RGBA(tc.plank)); c.fill(tx + tw - 2, y, 2, 3, RGBA(tc.plank)); y += 4 }
            c.fill(tx + 2, gy, tw - 4, 4, RGBA("#000000", alpha: 0.3))
            c.fill(tx, gy + td - 2, tw, 2, RGBA(tc.floor))
            var x = tx
            while x < tx + tw { c.fill(x, gy + td - 2, 1, 2, RGBA(tc.slat)); x += 3 }
        }

        // the player's side: bunker and slingshot
        let sheet = SpriteSheet.shared
        let bunker = sheet.canvas(pack.props.bunker)
        for i in 0..<3 { c.draw(bunker, ox + Int(K.bunkerX) + i * 16, oy + Int(K.ground) - 16) }
        c.draw(sheet.canvas(pack.props.sling ?? "slingshot"), ox + Int(K.slingX), oy + Int(K.ground) - 24)
        return c
    }

    static func disc(_ c: inout PixelCanvas, _ cx: Int, _ cy: Int, _ r: Int, _ col: RGBA) {
        for dy in -r...r {
            let w = Int(jsRound(sqrt(Double(r * r - dy * dy))))
            c.fill(cx - w, cy + dy, w * 2, 1, col)
        }
    }

    private static func cloud(_ c: inout PixelCanvas, _ x: Int, _ y: Int, big: Bool, _ col: RGBA) {
        if big {
            c.fill(x + 5, y - 2, 5, 1, col); c.fill(x + 3, y - 1, 9, 1, col)
            c.fill(x + 1, y, 16, 2, col); c.fill(x, y + 2, 20, 2, col)
        } else {
            c.fill(x + 3, y - 1, 4, 1, col); c.fill(x + 1, y, 9, 1, col); c.fill(x, y + 1, 12, 2, col)
        }
    }

    private static func groundBand(_ c: inout PixelCanvas, _ x0: Int, _ w: Int, _ gy: Int, _ h: Int, _ g: GroundColors, seed: Int) {
        let r = seededRandom(seed)
        let base = RGBA(g.base), top = RGBA(g.top), hi = RGBA(g.hi), lo = RGBA(g.lo)
        c.fill(x0, gy, w, h - gy, base)
        c.fill(x0, gy, w, 3, top)
        c.fill(x0, gy, w, 1, hi)
        var x = x0
        while x < x0 + w { c.set(x, gy - 1, top); x += 2 + Int(r() * 5) }
        x = x0
        while x < x0 + w { if r() < 0.55 { c.set(x, gy + 3, top) }; x += 2 }
        let n = Int((Double(w * (h - gy)) / 24).rounded(.up))
        for _ in 0..<max(0, n) {
            let px = x0 + Int(r() * Double(w))
            let py = gy + 5 + Int(r() * Double(max(1, h - gy - 5)))
            c.fill(px, py, 2, 1, lo)
        }
    }

    private static func tree(_ c: inout PixelCanvas, _ x: Int, _ base: Int, kind: String, color: String?) {
        if kind == "palm" {
            let trunk = RGBA(color ?? "#7a5634"), leaf = RGBA("#3f8a3a")
            c.fill(x, base - 10, 1, 10, trunk); c.fill(x + 1, base - 6, 1, 6, trunk)
            c.fill(x - 4, base - 11, 9, 1, leaf); c.fill(x - 5, base - 10, 2, 1, leaf); c.fill(x + 4, base - 10, 2, 1, leaf); c.fill(x - 2, base - 12, 5, 1, leaf)
        } else if kind == "stump" {
            // shell-blasted tree stumps of the Western Front
            let col = RGBA(color ?? "#4a3b2a")
            c.fill(x, base - 9, 2, 9, col); c.fill(x - 2, base - 7, 2, 1, col); c.fill(x + 2, base - 5, 2, 1, col); c.fill(x + 1, base - 10, 1, 1, col)
        } else if kind == "pine" {
            let col = RGBA(color ?? "#56656b")
            c.fill(x, base - 7, 1, 7, col); c.fill(x - 1, base - 4, 3, 4, col); c.fill(x - 2, base - 1, 5, 2, col)
        } else {
            c.fill(x, base - 4, 1, 4, RGBA("#5e3a1d"))
            let col = RGBA(color ?? "#4f7f3a")
            c.fill(x - 3, base - 9, 7, 5, col); c.fill(x - 2, base - 10, 5, 1, col); c.fill(x - 2, base - 4, 5, 1, col)
        }
    }
}
