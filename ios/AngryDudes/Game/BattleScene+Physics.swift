import SpriteKit

// Collisions, damage, explosions, and the per-step forces on things in flight.
extension BattleScene {
    func processContacts() {
        let list = contacts
        contacts = []
        for c in list {
            let ea = entity(of: c.a), eb = entity(of: c.b)
            touch(ea, eb)
            touch(eb, ea)
            if simT < graceUntil || c.rel < 2 { continue }
            if let ea { hurt(ea, otherBody: c.b, other: eb, rel: c.rel) }
            if let eb { hurt(eb, otherBody: c.a, other: ea, rel: c.rel) }
        }
    }

    /// What happens the moment something touches something else (other is nil for the ground).
    func touch(_ e: Entity?, _ other: Entity?) {
        guard let e, !e.dead else { return }
        let u = e.unit
        if let u, u.impact == true, !e.spent { e.spent = true; pendingBooms.append(.entity(e)) }
        if e.pierce > 0, let o = other, o.hp != nil, !o.dead, o.kind != .proj, o.block?.fixed != true, simT >= graceUntil {
            damage(o, (u?.pierceDmg ?? 5) * (u?.best == o.key ? 2.5 : 1))
            if o.dead {
                e.pierce -= 1
                e.restoreVel = CGVector(dx: e.preVel.dx * 0.85, dy: e.preVel.dy * 0.85)
            }
        }
        if u?.stick == true, e.stuckAt == nil, other !== e { e.stuckAt = simT; e.freeze = true }
        if !e.touched {
            e.touched = true
            if u?.tap == "detonate" && !e.spent { e.fuseAt = simT + 1200 }
            if e.melee && !e.chute { melee(e) }
        }
        if e.chute { closeChute(e); e.landed = true; melee(e) }
        if e.troop, let o = other, o.block?.sensor == true, !e.snagged { e.snagged = true; e.snagAt = simT }
        if e.block?.sensor == true, let o = other, o.kind == .vehicle, mode == .play { kill(e) }
    }

    func hurt(_ e: Entity, otherBody: SKPhysicsBody, other: Entity?, rel: Double) {
        guard e.hp != nil, !e.dead else { return }
        let mine = e.isStatic ? 5 : e.mass
        let mf = !otherBody.isDynamic ? 1.2 : clamp((other?.mass ?? Double(otherBody.mass)) / mine, 0.5, 4)
        var mult = 1.0
        if let o = other, let u = o.unit, u.enemy != true {
            mult *= power(u)
            if u.best == e.key { mult *= 2.5 }
            if o.dashing { mult *= 2 }
            if o.ramUntil > simT { mult *= 3 }
            if u.soft == true && e.kind == .block { mult *= 0.1 }
        }
        var dmg = (rel - 2) * 0.45 * mf * mult
        if e.kind == .vehicle { dmg *= 0.25 }
        damage(e, dmg)
    }

    func damage(_ e: Entity, _ dmg: Double) {
        guard !e.dead, let hp = e.hp, dmg > 0.05 else { return }
        e.hp = hp - dmg
        e.flash = simT + 120
        if hp - dmg <= 0 { kill(e) }
    }

    func kill(_ e: Entity) {
        if e.dead { return }
        e.dead = true
        let x = e.x, y = e.y
        switch e.kind {
        case .defender:
            addScore(e.pts, x, y - e.h / 2 - 4)
            poof(x, y, 14)
            play("ko")
            if let d = e.defender, let ex = d.explodes { pendingBooms.append(.at(x: x, y: y, boom: ex, fire: d.fire == true)) }
            if mode == .play && defendersLeft() == 0 && winAt == 0 { winAt = simT + 1600 }
        case .block:
            addScore(e.pts, x, y)
            if let d = e.block {
                debris(x, y, d.debris, e.w * e.h / 20)
                if let ex = d.explodes { pendingBooms.append(.at(x: x, y: y, boom: ex, fire: d.fire == true)) }
            }
            play("crack")
        case .vehicle:
            let big = e.unit?.tap == "blowup" && !e.spent
            pendingBooms.append(.at(x: x, y: y, boom: big ? (e.unit.flatMap { boom($0) } ?? Boom(r: 18, p: 2)) : Boom(r: 18, p: 2), fire: big))
            if big { say("KA-BOOM!", x, y - 20, "#ff8c1a") }
        case .proj:
            break
        }
    }

    func explode(_ x: Double, _ y: Double, _ boom: Boom, best: String?, fire: Bool) {
        shake = max(shake, boom.p * 1.6)
        blast(x, y, boom.r, fire: fire)
        play("boom")
        for e in ents where !e.dead {
            let dx = e.x - x, dy = e.y - y, len = max(hypot(dx, dy), 1e-9)
            var d = max(0, len - min(e.w, e.h) * 0.45)
            // a long hull counts from its nearest point, not its middle
            if e.block?.boat == true { d = max(0, hypot(max(0, abs(dx) - e.w / 2), dy) - e.h * 0.45) }
            if d > boom.r { continue }
            let f = 1 - d / boom.r
            if !e.isStatic {
                e.body.isResting = false
                let kick = f * boom.p * 5 / sqrt(max(1, e.mass))
                let v = e.vel
                e.vel = (v.x + dx / len * kick, v.y + dy / len * kick - f * boom.p * 0.8)
                if e.body.allowsRotation { e.angularVel += (Double.random(in: 0..<1) - 0.5) * 0.12 * f }
            }
            if e.hp != nil { damage(e, f * boom.p * 2.6 * (best != nil && best == e.key ? 2.5 : 1)) }
        }
    }

    func processBooms() {
        let list = pendingBooms
        pendingBooms = []
        for b in list {
            switch b {
            case .entity(let e):
                if e.boomed { continue }
                e.boomed = true
                e.dead = true
                if let u = e.unit, let boom = boom(u) { explode(e.x, e.y, boom, best: u.best, fire: u.fire == true) }
            case let .at(x, y, boom, fire):
                explode(x, y, boom, best: nil, fire: fire)
            }
        }
    }

    func sweep() {
        var removed = false
        for i in stride(from: ents.count - 1, through: 0, by: -1) where ents[i].dead {
            ents[i].node.removeFromParent()
            ents.remove(at: i)
            removed = true
        }
        // things resting on what just disappeared must wake up and fall
        if removed { for e in ents where e.body.isResting { e.body.isResting = false } }
    }

    /// Before each physics step: lift, wind, fuses, snags, and anything that left the field.
    func updateEnts() {
        let stepNo = Int(jsRound(simT / K.step))
        for e in ents where !e.dead {
            if e.kind == .proj, let u = e.unit {
                if let lift = u.lift, e.stuckAt == nil { e.addVel(0, -K.grav * lift * gravK) }
                if u.wind == true || e.chute, wind != 0, e.stuckAt == nil { e.addVel(K.grav * wind * (e.chute ? 0.03 : 0.06), 0) }
                if e.faceVel && e.stuckAt == nil && e.speed > 0.5 {
                    e.node.zRotation = atan2(e.body.velocity.dy, e.body.velocity.dx)
                    e.body.angularVelocity = 0
                }
                if let f = e.fuseAt, simT >= f, !e.spent { e.spent = true; pendingBooms.append(.entity(e)) }
                if e.snagged && simT - e.snagAt < 600 { let v = e.vel; e.vel = (v.x * 0.5, max(0, v.y) * 0.5) }
                if let s = e.stuckAt, simT - s > 700 { e.dead = true }
                if let f = e.fizzleAt, simT >= f { e.dead = true }
                if e.trail && !e.touched && stepNo % 3 == 0 { trail.append(CGPoint(x: e.x, y: e.y)) }
            }
            if e.kind == .vehicle { driveVehicle(e) }
            if !e.dead && !e.wet0 && e.unit?.boat != true && e.block?.boat != true && inWater(e.x, e.y) { splash(e) }
            if e.x < -100 || e.x > worldW + 100 || e.y > K.worldH + 80 {
                if e.kind == .defender || e.kind == .block { kill(e) } else { e.dead = true }
            }
        }
    }

    /// Things that fall in a river are gone (boats float).
    func splash(_ e: Entity) {
        let x = e.x
        for i in 0..<16 {
            part(x + (rnd() - 0.5) * 10, K.ground + 4, (rnd() - 0.5) * 1.6, -1.2 - rnd() * 1.6, 600, i % 2 == 1 ? "#ffffff" : "#7fb8e8", size: 1, g: 0.12)
        }
        play("chute")
        if e.kind == .defender || e.kind == .block {
            kill(e)
            say("SPLASH!", x, K.ground - 10, "#bfe3ff")
        } else {
            e.dead = true
            if e.troop || e.kind == .vehicle { say("SPLASH!", x, K.ground - 10, "#bfe3ff") }
        }
    }

    func afterPhysics() {
        for e in ents where !e.dead {
            if let v = e.restoreVel { e.body.velocity = v; e.restoreVel = nil }
            if e.freeze {
                // stuck arrows: pinned in place, and nothing bumps into them any more
                e.freeze = false
                e.body.isDynamic = false
                e.body.velocity = .zero
                e.body.angularVelocity = 0
                e.body.categoryBitMask = Cat.sensor
                e.body.collisionBitMask = 0
            }
        }
        var i = scheduled.count - 1
        while i >= 0 {
            if i < scheduled.count, simT >= scheduled[i].at {
                let item = scheduled.remove(at: i)
                item.run()
            }
            i -= 1
        }
    }

    func driveVehicle(_ e: Entity) {
        guard let u = e.unit else { return }
        let v = e.vel
        let grounded = abs(v.y) < 0.6
        if !e.driving {
            // SpriteKit keeps a contact's friction from when it began, so the vehicle's
            // switch from frictionless to grippy is done by hand: it slows to a stop.
            if grounded { e.vel = (v.x * 0.88, v.y) }
            return
        }
        if grounded && v.x < (u.speed ?? 1) * K.PH { e.addVel(K.grav * (u.push ?? 0.3), 0) }
        e.stuck = (e.x - e.lastX < 0.12) ? e.stuck + 1 : 0
        e.lastX = e.x
        if e.stuck > 40 || e.x > worldW - 30 { stopVehicle(e) }
    }

    func stopVehicle(_ e: Entity) {
        e.driving = false
        e.body.friction = 0.8
        e.lastAct = simT
    }
}
