import SpriteKit

// Special moves: tap while something is moving. The moves are shared, so any army can mix and
// match them (see the pack format in js/packs/ww2.js).
extension BattleScene {
    func special() {
        guard let a = active?.lead, !a.dead, let u = a.unit else { return }
        let x = a.x, y = a.y
        switch u.tap {
        case "shout":
            if !a.usedTap { a.usedTap = true; say(u.shout ?? "CHARGE!", x, y - 14, "#ffffff"); play("shout") }
        case "chute":
            if !a.usedTap && !a.touched { a.usedTap = true; openChute(a) }
        case "detonate":
            if !a.spent { a.spent = true; pendingBooms.append(.entity(a)) }
        case "pound":
            if !a.usedTap && !a.touched {
                a.usedTap = true
                a.vel = (a.vel.x * 0.15, 17)
                a.angle = 0
                a.angularVel = 0
                say(u.shout ?? "GROUND POUND!", x, y - 16, "#ffd23f")
                play("shout")
            }
        case "dash":
            if !a.usedTap && !a.touched {
                a.usedTap = true
                a.dashing = true
                a.pierce = u.pierce ?? 0
                let v = a.vel, dir = v.x >= 0 ? 1.0 : -1.0
                a.vel = (dir * max(abs(v.x) * 1.6, u.dash ?? 14), min(v.y, 1))
                say(u.shout ?? "CHARGE!", x, y - 14, "#ffd23f")
                play("whoosh"); play("shout")
            }
        case "split":
            if !a.usedTap && !a.touched, let active {
                a.usedTap = true
                let su = u.splitInto.flatMap { units[$0] } ?? u
                let v = a.vel
                for ang in [-0.22, 0.22] {
                    let c = cos(ang), s = sin(ang)
                    active.group.append(spawnTroop(su, x, y, v.x * c - v.y * s, v.x * s + v.y * c))
                }
                poof(x, y, 8)
                say(u.shout ?? "FORM UP!", x, y - 16, "#ffd23f")
                play("shout")
            }
        case "boost":
            // a jetpack burst up and forward; a couple of them per flight
            if a.boosts < (u.boosts ?? 2) && !a.touched {
                a.boosts += 1
                a.usedTap = true
                a.vel = (max(a.vel.x, u.boostX ?? 7), -(u.boost ?? 9))
                for f in 0..<10 {
                    part(x - 4 + rnd() * 3, y + 8, -0.5 - rnd(), 0.8 + rnd(), 400, f % 2 == 1 ? "#ff8c1a" : "#ffd23f", size: 2, g: 0)
                }
                say(u.shout ?? "WHOOSH!", x, y - 14, "#ffd23f")
                play("whoosh")
            }
        case "jump":
            if abs(a.vel.y) < 0.6 && simT - a.lastJump > 500 {
                a.lastJump = simT
                a.body.isResting = false
                a.vel = (a.vel.x, -(u.jump ?? 9))
                if !a.driving { a.driving = true; a.stuck = 0; a.body.friction = 0 }
            }
        case "shoot":
            if a.shots > 0 && simT - a.lastAct > 650, let gun = u.gun, let shell = u.shell {
                a.shots -= 1
                a.lastAct = simT
                spawnProj(shell, x + gun.x, y + gun.y, gun.vx, gun.vy, bomb: true)
                muzzle(x + gun.x - 1, y + gun.y)
                play("thump")
                shake = max(shake, 2)
                a.vel = (a.vel.x - 1.5, a.vel.y)
            }
        case "ram":
            if simT - a.lastAct > 700 {
                a.lastAct = simT
                a.ramUntil = simT + 600
                a.body.isResting = false
                if !a.driving { a.driving = true; a.stuck = 0; a.body.friction = 0 }
                a.vel = ((u.ramSpeed ?? 2.6) * K.PH, a.vel.y)
                say(u.shout ?? "RAM!", x, y - 20, "#ffd23f")
                play("whoosh")
            }
        case "unload":
            if !a.unloaded, let un = u.unload, let tu = units[un.unit], let active {
                a.unloaded = true
                a.lastAct = simT
                for i in 0..<un.count {
                    let d = Double(i)
                    active.group.append(spawnTroop(tu, x + a.w / 2 - 6, y - a.h / 2 - 4 - d * 2,
                                                   (un.vx ?? 4.5) + d * (un.spread ?? 1.6), (un.vy ?? -7) - d * 0.6, melee: true))
                }
                say(u.shout ?? "OVER THE WALL!", x, y - a.h / 2 - 12, "#ffd23f")
                play("shout")
            }
        case "sharpshoot":
            if !a.usedTap {
                // picks off the nearest defenders one after another
                a.usedTap = true
                let targets = defenders().map { ($0, hypot($0.x - x, $0.y - y)) }
                    .filter { $0.1 < (u.reach ?? 170) }
                    .sorted { $0.1 < $1.1 }
                    .prefix(u.shots ?? 3)
                for (i, t) in targets.enumerated() {
                    let d = t.0
                    scheduled.append(Scheduled(at: simT + 120 + Double(i) * 200) { [weak self] in
                        guard let self, !d.dead, !a.dead else { return }
                        self.tracer(a.x, a.y - 4, d.x, d.y - 6)
                        self.play("shot")
                        self.damage(d, (u.shotDmg ?? 2.5) * (d.key == u.best ? 2 : 1))
                    })
                }
                say(u.shout ?? "SHARPSHOOTER!", x, y - 16, "#ffd23f")
            }
        case "blowup":
            if !a.spent, let boom = boom(u) {
                a.spent = true
                a.dead = true
                pendingBooms.append(.at(x: x, y: y, boom: boom, fire: true))
                say("KA-BOOM!", x, y - 20, "#ff8c1a")
            }
        default:
            break
        }
    }

    func openChute(_ e: Entity) {
        e.chute = true
        e.spriteName = e.unit?.chuteSprite ?? e.spriteName
        e.angle = 0
        e.angularVel = 0
        e.body.allowsRotation = false
        e.body.linearDamping = K.damping(0.09)
        e.vel = (e.vel.x * 0.6, min(e.vel.y, 0.5))
        play("chute")
    }

    func closeChute(_ e: Entity) {
        e.chute = false
        e.spriteName = e.unit?.sprite ?? e.spriteName
        e.body.linearDamping = K.damping(0.002)
        e.body.allowsRotation = true
    }

    func melee(_ e: Entity) {
        var hit = false
        for d in defenders() {
            let qx = d.x, qy = d.y
            if abs(qx - e.x) < 28 && qy - e.y > -20 && qy - e.y < 44 {
                damage(d, d.key == e.unit?.best ? 8 : 3)
                hit = true
                say(e.unit?.melee ?? "GOTCHA!", qx, qy - 20, "#ffffff")
            }
        }
        if hit { play("thwack") }
    }
}
