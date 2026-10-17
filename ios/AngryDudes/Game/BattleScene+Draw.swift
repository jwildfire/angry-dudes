import SpriteKit

// Per-frame drawing. Entities are SpriteKit sprites that move with their physics bodies; the
// rest (trails, the wind pennant, sling bands, aim dots, particles, call-outs, weather) is
// painted fresh each frame through the Painter, like the prototype's draw().
extension BattleScene {
    private enum Z {
        static let trail: CGFloat = 2, pennant: CGFloat = 3, bandBack: CGFloat = 4
        static let bandFront: CGFloat = 15, dots: CGFloat = 20, planeFx: CGFloat = 26
        static let particles: CGFloat = 30, tracers: CGFloat = 31, bars: CGFloat = 40
        static let arrows: CGFloat = 41, popups: CGFloat = 50, weather: CGFloat = 60
    }

    func render() {
        guard let level, let th = pack.themes[level.theme] else { return }
        painter.begin()

        // the camera scrolls wide battlefields, and screen shake jiggles it
        placeCamera()
        let sx = shake > 0 ? jsRound((rnd() - 0.5) * shake) : 0, sy = shake > 0 ? jsRound((rnd() - 0.5) * shake) : 0
        cam.position = CGPoint(x: camBase.x - sx * K.PH, y: camBase.y + sy * K.PH)

        // last shot's trail stays faintly so you can adjust; the current shot's trail is bold
        for (k, p) in lastTrail.enumerated() where k % 3 == 0 {
            dot(Double(p.x), Double(p.y), 1, alpha: 0.55, z: Z.trail)
        }
        for (k, p) in trail.enumerated() where k % 2 == 0 {
            dot(Double(p.x), Double(p.y), 2, z: Z.trail)
        }

        // wind pennant on the battlefield
        let wx = 200.0, wy = K.ground - 26, pc = pack.props.pennant ?? ["#e0412c", "#ffffff"]
        painter.rect(wx, wy, 1, 26, "#646d7b", z: Z.pennant)
        let len = Int(3 + abs(wind) * 4), dir = wind >= 0 ? 1.0 : -1.0
        for i in 0..<len {
            let col = (i / 3) % 2 == 1 ? pc[1] : pc[0]
            painter.rect(wx + dir * Double(i + 1), wy + (wind == 0 ? Double(i) : 0), 1, wind == 0 ? 1 : 3, col, z: Z.pennant)
        }

        // whoever is working the bunker for the current (or next) weapon
        let gk = selected.flatMap { units[$0]?.kind == "fire" ? $0 : nil }
            ?? pack.order.first { units[$0]?.kind == "fire" && (arsenal[$0] ?? 0) > 0 }
        if let gk, let gunner = units[gk]?.gunner {
            let tex = SpriteSheet.shared.texture(gunner), s = tex.size()
            if gunnerNode.texture !== tex { gunnerNode.texture = tex }
            gunnerNode.size = CGSize(width: s.width * K.PH, height: s.height * K.PH)
            let gx = jsRound(K.bunkerX + 24 - Double(s.width) / 2), gy = K.ground - 16 - Double(s.height)
            gunnerNode.position = CGPoint(x: gx * K.PH, y: -gy * K.PH)
            gunnerNode.isHidden = false
        } else {
            gunnerNode.isHidden = true
        }

        // the next troop sitting in the sling, with the bands
        let slingTroop = mode == .play && (phase == .ready || phase == .aiming) && selected.flatMap { units[$0]?.kind } == "sling"
        let pull = phase == .aiming ? pullVector() : (x: 0.0, y: 0.0)
        let tx = K.sling.x + pull.x, ty = K.sling.y + pull.y
        if slingTroop, let sel = selected, let u = units[sel] {
            painter.line(123, 248, tx + 3, ty, "#3d2414", z: Z.bandBack)
            let tex = SpriteSheet.shared.texture(u.sprite ?? sel), s = tex.size()
            slingTroopNode.texture = tex
            slingTroopNode.size = CGSize(width: s.width * K.PH, height: s.height * K.PH)
            let left = jsRound(tx - Double(s.width) / 2), top = jsRound(ty - Double(s.height) / 2)
            slingTroopNode.position = CGPoint(x: (left + Double(s.width) / 2) * K.PH, y: -(top + Double(s.height) / 2) * K.PH)
            slingTroopNode.isHidden = false
            painter.line(112, 248, tx - 3, ty, "#5e3a1d", z: Z.bandFront)
        } else {
            slingTroopNode.isHidden = true
        }

        for e in ents { drawEnt(e) }

        if phase == .aiming && (pull.x != 0 || pull.y != 0), let sel = selected, let u = units[sel] {
            let vx = -pull.x / K.maxPull * topSpeed, vy = -pull.y / K.maxPull * topSpeed
            if u.kind == "sling" {
                previewDots(K.sling.x, K.sling.y, vx, vy, lift: 0, steps: 45)
            } else {
                let k = u.speed ?? 1, lift = u.lift ?? 0
                previewDots(K.bunker.x, K.bunker.y, vx * k, vy * k, lift: lift, steps: lift > 0.9 ? 60 : 36)
                let ang = Int(jsRound(atan2(-vy, vx) * 180 / .pi)), pw = Int(jsRound(hypot(pull.x, pull.y) / K.maxPull * 100))
                painter.image(PixelFont.texture("\(ang)°  \(pw)%", color: "#ffffff"), x: K.bunker.x, y: K.ground - 52, z: Z.popups)
            }
        }

        for p in planes {
            p.node.position = CGPoint(x: (p.x + p.w / 2) * K.PH, y: -(p.y + p.h / 2) * K.PH)
            p.node.zRotation = CGFloat(-p.angle)
            if !p.down {
                // spinning propeller
                let px = p.x + p.w - 1, py = p.y + (Int(jsRound(simT / 50)) % 2 == 1 ? 1 : 3)
                painter.rect(px.rounded(), py.rounded(), 1, p.h - 4, "#ffffff", alpha: 0.6, z: Z.planeFx)
            }
        }

        for p in particles {
            let age = (simT - p.t) / p.life
            switch p.style {
            case .blast:
                let R = jsRound(p.r * (0.4 + age * 0.8))
                if age < 0.5 { painter.disc(jsRound(p.x), jsRound(p.y), Int(max(2, jsRound(R * 0.7))), age < 0.2 ? "#ffffff" : "#ffd23f", z: Z.particles) }
                let dirs: [(Double, Double)] = [(1, 0), (1, 1), (0, 1), (-1, 1), (-1, 0), (-1, -1), (0, -1), (1, -1)]
                for (n, d) in dirs.enumerated() {
                    let L = jsRound(R * (n % 2 == 1 ? 0.7 : 1))
                    var j = jsRound(L * 0.5)
                    while j <= L {
                        painter.rect(jsRound(p.x + d.0 * j * 0.75) - 1, jsRound(p.y + d.1 * j * 0.75) - 1, 2, 2,
                                     j > L - 3 ? "#ff8c1a" : "#ffd23f", z: Z.particles)
                        j += 2
                    }
                }
            case .smoke, .darkSmoke:
                let sz = jsRound(p.size * (1 + age * 1.5))
                let dark = p.style == .darkSmoke
                painter.rect(jsRound(p.x - sz / 2), jsRound(p.y - sz / 2), sz, sz, dark ? "#28282e" : "#787880",
                             alpha: dark ? 0.85 - age * 0.8 : 0.7 - age * 0.7, z: Z.particles - 1)
            case .dot:
                painter.rect(p.x.rounded(), p.y.rounded(), p.size, p.size, p.color, z: Z.particles)
            }
        }
        for t in tracers { painter.line(t.x0, t.y0, t.x1, t.y1, t.color, z: Z.tracers) }

        // arrows at the top edge for anything flying above the screen
        let topY = visibleTop + 2
        for e in ents where e.kind == .proj && !e.dead && e.y <= topY - 4 {
            let ax = jsRound(e.x)
            painter.rect(ax - 3, topY + 2, 7, 1, "#ffd23f", z: Z.arrows)
            painter.rect(ax - 2, topY + 1, 5, 1, "#ffd23f", z: Z.arrows)
            painter.rect(ax - 1, topY, 3, 1, "#ffd23f", z: Z.arrows)
            painter.rect(ax, topY - 1, 1, 1, "#ffd23f", z: Z.arrows)
        }
        for p in popups {
            let age = (simT - p.t) / p.life, rise = p.life > 1100 ? 4.0 : 18.0
            painter.image(PixelFont.texture(p.text, color: p.color), x: p.x, y: max(p.y - age * rise, topY + 6), z: Z.popups)
        }
        // arrows at the screen edges for defenders the camera can't see
        if camMax > 0 && mode == .play {
            let viewL = viewLeft - OX, viewR = viewL + viewW
            var offR = 0, offL = 0
            for d in defenders() { if d.x > viewR - 4 { offR += 1 } else if d.x < viewL + 4 { offL += 1 } }
            for (count, ax, dir) in [(offR, jsRound(viewR - 12), 1.0), (offL, jsRound(viewL + 12), -1.0)] where count > 0 {
                let ay = K.ground - 70
                for k in 0..<6 {
                    let half = Double(6 - k)
                    painter.rect(ax + dir * Double(k - 3) - 1, ay - half - 1, 3, half * 2 + 3, K.outline, z: Z.arrows)
                    painter.rect(ax + dir * Double(k - 3), ay - half, 1, half * 2 + 1, "#ffd23f", z: Z.arrows + 0.1)
                }
                painter.image(PixelFont.texture(String(count), color: "#ffffff"), x: ax - dir * 10, y: ay, z: Z.popups)
            }
        }
        drawWeather(th)
        painter.end()
    }

    private func drawEnt(_ e: Entity) {
        if e.defender?.float == true {
            // the tether holding an observation balloon
            painter.line(e.x, e.y + e.h / 2, e.x - 6, groundAt(e.x), "#3a3546", z: 9)
        }
        if let s = e.stuckAt { e.node.alpha = CGFloat(max(0, 1 - (simT - s) / 700)) }
        if e.kind == .block, let hp = e.hp, hp < e.maxHp * 0.6 { e.cracked = true }
        e.setFlash(e.flash > simT && !e.tile)
        guard e.kind == .defender || e.kind == .vehicle, let hp = e.hp, hp < e.maxHp, hp > 0 else { return }
        let sh = Double(e.sprite.size.height) / K.PH
        let top = jsRound(e.y - e.h / 2 - (sh - e.h) - 5), w = 14.0, f = max(0, hp / e.maxHp)
        let left = jsRound(e.x - w / 2)
        painter.rect(left - 1, top - 1, w + 2, 4, K.outline, z: Z.bars)
        painter.rect(left, top, w, 2, "#5b1d1d", z: Z.bars + 0.1)
        painter.rect(left, top, max(1, jsRound(w * f)), 2, f > 0.5 ? "#7ad04f" : f > 0.25 ? "#ffd23f" : "#e0412c", z: Z.bars + 0.2)
    }

    /// Dots along the path a launch would take, using the same gravity, lift and air friction.
    private func previewDots(_ x: Double, _ y: Double, _ vx0: Double, _ vy0: Double, lift: Double, steps: Int) {
        var px = x * K.PH, py = y * K.PH, vx = vx0, vy = vy0
        for i in 1...steps {
            vy += K.grav * gravK * (1 - lift)
            vx *= 0.998; vy *= 0.998
            px += vx; py += vy
            if i % 4 == 0 { dot(px / K.PH, py / K.PH, 2, z: Z.dots) }
        }
    }

    /// A light dot with a dark rim reads against day skies, night skies and snow alike.
    private func dot(_ x: Double, _ y: Double, _ s: Double, alpha: Double = 1, z: CGFloat) {
        let x = jsRound(x), y = jsRound(y)
        painter.rect(x - 1, y - 1, s + 2, s + 2, K.outline, alpha: alpha, z: z)
        painter.rect(x, y, s, s, "#ffffff", alpha: alpha, z: z + 0.1)
    }

    private func drawWeather(_ th: ThemeSpec) {
        let bw = Double(bufW), bh = Double(bufH)
        switch th.weather {
        case "snow":
            for i in 0..<90 {
                let d = Double(i)
                let fx = (d * 97 + simT * (0.012 + Double(i % 5) * 0.003)).truncatingRemainder(dividingBy: bw + 20) - OX - 10
                let fy = (d * 53 + simT * (0.02 + Double(i % 7) * 0.004)).truncatingRemainder(dividingBy: bh + 10) - OY - 5
                painter.rect(jsRound(fx + sin(simT / 600 + d) * 3), jsRound(fy), 1, 1, "#ffffff", z: Z.weather)
            }
        case "rain":
            for i in 0..<120 {
                let d = Double(i)
                let rx = jsRound((d * 131 + simT * 0.09).truncatingRemainder(dividingBy: bw + 40) - OX - 20)
                let ry = jsRound((d * 71 + simT * 0.32).truncatingRemainder(dividingBy: bh + 20) - OY - 10)
                painter.rect(rx, ry, 1, 3, "#c8d7eb", alpha: 0.55, z: Z.weather)
                painter.rect(rx + 1, ry + 3, 1, 2, "#c8d7eb", alpha: 0.55, z: Z.weather)
            }
        case "fireflies":
            for i in 0..<18 {
                let d = Double(i)
                let gx = Double((i * 151) % Int(worldW)), gy = 180 + Double((i * 37) % 80)
                if sin(simT / 400 + d * 1.7) > 0.3 {
                    painter.rect(jsRound(gx + sin(simT / 900 + d) * 6), jsRound(gy + cos(simT / 700 + d) * 4), 1, 1, "#e9ff8a", z: Z.weather)
                }
            }
        default:
            break
        }
    }
}
