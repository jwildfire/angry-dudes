import SpriteKit

// Defenders fighting back: shooters knock low flyers down, snipers pop parachutes, tanks and
// cannons fire at vehicles, boiling oil pours on the gate, druids heal between turns.
// (Flak is handled with the planes in BattleScene+Launch.swift.)
extension BattleScene {
    func reactions() {
        guard let active else { return }
        let group = active.group.filter { !$0.dead }
        for d in defenders() {
            guard let R = d.defender?.react else { continue }
            let dx = d.x, dy = d.y
            switch R.type {
            case "shooter":
                for a in group where a.troop && !a.shotDown && !a.touched && a.speed >= 3 {
                    let ax = a.x, ay = a.y
                    if ax < dx && dx - ax < (R.range ?? 90) && ay > dy - (R.height ?? 40) {
                        a.shotDown = true
                        let mx = dx + (R.muzzle?.x ?? -8), my = dy + (R.muzzle?.y ?? -6)
                        tracer(mx, my, ax, ay)
                        tracer(mx, my + 1, ax + 3, ay - 2)
                        let v = a.vel
                        a.vel = (v.x * 0.25, max(v.y, 1))
                        play(R.sound ?? "shot")
                        say(R.say ?? "BANG!", dx, dy - 18, "#ffd23f")
                    }
                }
            case "sniper":
                for a in group where a.chute && !a.sniped {
                    if hypot(dx - a.x, dy - a.y) < (R.range ?? 150) {
                        if a.snipeAt == nil { a.snipeAt = simT + 900 }
                        if let t = a.snipeAt, simT >= t {
                            a.sniped = true
                            tracer(dx - 6, dy - 6, a.x, a.y - 12)
                            play("shot")
                            closeChute(a)
                            say(R.say ?? "SNIPER!", dx, dy - 20, "#ffd23f")
                        }
                    }
                }
            case "antitank":
                for a in group where a.kind == .vehicle {
                    if dx > a.x && dx - a.x < (R.range ?? 300) && simT - d.lastShot > (R.every ?? 1900) && simT - active.t0 > 900,
                       let shell = R.shell, let m = R.muzzle {
                        d.lastShot = simT
                        spawnProj(shell, dx + m.x, dy + m.y, R.vx ?? -13, R.vy ?? -0.4, bomb: true)
                        muzzle(dx + m.x + 2, dy + m.y)
                        play("thump")
                    }
                }
            case "claw":
                // a crane on the wall grabs a vehicle and flips it back
                for a in group where a.kind == .vehicle {
                    if abs(a.x - dx) < (R.range ?? 60) && simT - d.lastShot > (R.every ?? 2500) {
                        d.lastShot = simT
                        a.body.isResting = false
                        a.vel = (-2, -(R.lift ?? 13))
                        a.driving = false
                        a.lastAct = simT
                        damage(a, R.damage ?? 2)
                        tracer(dx, dy, a.x, a.y, color: "#3a3546")
                        say(R.say ?? "THE CLAW!", dx, dy - 20, "#ffd23f")
                        play("whoosh")
                    }
                }
            case "oil":
                for a in group where a.kind == .vehicle {
                    if abs(a.x - dx) < (R.range ?? 40) && a.y > dy && simT - d.lastShot > (R.every ?? 1500) {
                        d.lastShot = simT
                        for i in 0..<14 {
                            part(dx + (rnd() - 0.5) * 10, dy + 4, (rnd() - 0.5) * 0.6, 0.5 + rnd(), 700,
                                 i % 2 == 1 ? "#ff8c1a" : "#3a3546", size: 2, g: 0.15)
                        }
                        damage(a, R.damage ?? 3)
                        play("sizzle")
                        say(R.say ?? "HOT OIL!", dx, dy - 16, "#ff8c1a")
                    }
                }
            default:
                break
            }
        }
    }

    /// Each healer patches up the most hurt defender between turns.
    func healDefenders() {
        var healed = false
        for h in aliveReactor("heal") {
            guard let R = h.defender?.react else { continue }
            let hurt = defenders().filter { $0 !== h && ($0.hp ?? 0) < $0.maxHp }
                .min { ($0.hp ?? 0) / $0.maxHp < ($1.hp ?? 0) / $1.maxHp }
            guard let d = hurt, let hp = d.hp else { continue }
            d.hp = min(d.maxHp, hp + (R.amount ?? 1))
            healed = true
            for _ in 0..<6 { part(d.x + (rnd() - 0.5) * 10, d.y, 0, -0.4 - rnd() * 0.4, 700, "#7ad04f", size: 1, g: 0) }
            say(R.say ?? "HEALED!", h.x, h.y - 22, "#7ad04f")
        }
        if healed { play("heal") }
    }
}
