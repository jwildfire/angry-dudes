import SpriteKit

// Launching things: troops from the sling, weapons from the bunker, vehicles, and call-ins
// from the sky (bomber planes, arrow storms, cannon barrages).
extension BattleScene {
    func spend(_ key: String) {
        arsenal[key, default: 0] -= 1
        lastTrail = trail
        trail = []
    }

    func begin(_ group: [Entity], plane: Plane? = nil) -> Active {
        camHoldX = nil
        let a = Active(group: group, plane: plane, t0: simT)
        active = a
        phase = .active
        return a
    }

    /// Projectiles never hit each other (arrow storms, shotgun volleys, bombs in a line).
    @discardableResult
    func spawnProj(_ spec: UnitSpec, _ x: Double, _ y: Double, _ vx: Double, _ vy: Double,
                   trail: Bool = false, bomb: Bool = false, rain: Bool = false) -> Entity {
        let round = spec.round == true
        let w = spec.w ?? 6, h = spec.h ?? w
        let body: SKPhysicsBody
        let area: Double
        if round {
            body = SKPhysicsBody(circleOfRadius: w / 2 * K.PH)
            area = Double.pi * pow(w / 2 * K.PH, 2)
        } else {
            body = SKPhysicsBody(rectangleOf: CGSize(width: w * K.PH, height: h * K.PH))
            area = w * h * K.PH * K.PH
        }
        body.friction = round ? 0.5 : 0.4
        body.restitution = spec.bounce ?? 0.1
        body.linearDamping = K.damping(0.002)
        body.angularDamping = K.damping(0.002)
        body.usesPreciseCollisionDetection = true
        body.categoryBitMask = Cat.proj
        body.collisionBitMask = Cat.solid | Cat.troop
        body.contactTestBitMask = Cat.contacts
        let e = Entity(kind: .proj, key: spec.key.isEmpty ? "shot" : spec.key, sprite: spec.sprite ?? "proj_shell",
                       w: w, h: h, body: body, mass: (spec.density ?? 0.004) * area)
        e.unit = spec
        e.center = true
        e.faceVel = spec.faceVel != false && !round
        e.trail = trail; e.bomb = bomb; e.rain = rain
        e.node.position = CGPoint(x: x * K.PH, y: -y * K.PH)
        if e.faceVel { e.node.zRotation = atan2(-vy, vx) }
        e.applySprite()
        addEnt(e)
        if let fuse = spec.fuse { e.fuseAt = simT + fuse }
        if let p = spec.pierce { e.pierce = p }
        if let life = spec.life { e.fizzleAt = simT + life }
        e.vel = (vx, vy)
        if let spin = spec.spin { e.angularVel = spin }
        return e
    }

    @discardableResult
    func spawnTroop(_ u: UnitSpec, _ x: Double, _ y: Double, _ vx: Double, _ vy: Double, melee: Bool = false) -> Entity {
        let w = u.w ?? 12, h = u.h ?? 16
        let body = SKPhysicsBody(rectangleOf: CGSize(width: w * K.PH, height: h * K.PH))
        body.friction = 0.6
        body.restitution = 0.2
        body.linearDamping = K.damping(0.002)
        body.angularDamping = K.damping(0.002)
        body.usesPreciseCollisionDetection = true
        body.categoryBitMask = Cat.troop
        body.collisionBitMask = Cat.solid | Cat.proj
        body.contactTestBitMask = Cat.contacts
        let e = Entity(kind: .proj, key: u.key, sprite: u.sprite ?? u.key, w: w, h: h, body: body,
                       mass: (u.density ?? 0.003) * w * h * K.PH * K.PH)
        e.unit = u
        e.troop = true
        e.trail = true
        e.melee = melee
        e.node.position = CGPoint(x: x * K.PH, y: -y * K.PH)
        e.applySprite()
        addEnt(e)
        e.vel = (vx, vy)
        e.angularVel = 0.03
        return e
    }

    func launchSling(_ key: String, _ vx: Double, _ vy: Double) {
        guard let u = units[key] else { return }
        spend(key)
        let e = spawnTroop(u, K.sling.x, K.sling.y, vx, vy)
        play("twang")
        _ = begin([e])
    }

    func launchFire(_ key: String, _ vx: Double, _ vy: Double) {
        guard let u = units[key] else { return }
        let k = u.speed ?? 1
        spend(key)
        let n = u.spread?.n ?? 1, step = (u.spread?.deg ?? 0) * .pi / 180
        var group: [Entity] = []
        for i in 0..<n {
            let a = (Double(i) - Double(n - 1) / 2) * step, c = cos(a), s = sin(a)
            group.append(spawnProj(u, K.bunker.x, K.bunker.y - Double(i), (vx * c - vy * s) * k, (vx * s + vy * c) * k, trail: i == 0))
        }
        muzzle(K.bunker.x + 4, K.bunker.y)
        play(u.sound ?? "thump")
        _ = begin(group)
    }

    func launchDrive(_ key: String) {
        guard let u = units[key] else { return }
        let w = u.w ?? 32, h = u.h ?? 12
        let body = SKPhysicsBody(rectangleOf: CGSize(width: w * K.PH, height: h * K.PH))
        body.friction = 0
        body.restitution = 0
        body.linearDamping = K.damping(0.01)
        body.allowsRotation = false
        body.categoryBitMask = Cat.vehicle
        body.collisionBitMask = Cat.solid | Cat.proj | Cat.troop | (u.boat == true ? Cat.water : 0)
        body.contactTestBitMask = Cat.contacts
        spend(key)
        let e = Entity(kind: .vehicle, key: key, sprite: u.sprite ?? key, w: w, h: h, body: body,
                       mass: (u.density ?? 0.003) * w * h * K.PH * K.PH)
        e.unit = u
        e.ox = u.ox ?? 0
        e.hp = hp(u); e.maxHp = hp(u)
        e.driving = true
        e.shots = u.shots ?? 0
        e.lastX = 18
        e.node.position = CGPoint(x: 18 * K.PH, y: -(K.ground - h / 2 - 0.5) * K.PH)
        e.applySprite()
        addEnt(e)
        play("engine")
        _ = begin([e])
    }

    func callIn(_ key: String, _ tx: Double) {
        guard let u = units[key] else { return }
        spend(key)
        if u.style == "rain" { callRain(u, tx); return }
        if u.style == "mine" { digMine(u, tx); return }
        let sprite = u.sprite ?? key, s = SpriteSheet.shared.size(sprite)
        let sw = Double(s.width), sh = Double(s.height)
        // On a short screen the top of the sky sits behind the HUD, so planes fly a little
        // lower there; the bomb lead below uses the same altitude, so the aim still holds.
        let bombs = u.bombs ?? 1, spacing = u.spacing ?? 16, speed = u.speed ?? 2
        let alt = max(u.alt ?? 40, visibleTop + 3)
        let drops = (0..<bombs).map { tx + (Double($0) - Double(bombs - 1) / 2) * spacing }
        // how far ahead of the target to let go: fly the drop forward with the same drag and gravity the game uses
        let g = K.grav * gravK * (1 - (u.bomb?.lift ?? 0))
        var dvx = speed * 0.3 * K.PH + (u.dropVx ?? 0), dvy = dropVy(u), dx = 0.0, dy = alt * K.PH
        var k = 0
        while k < 3000 && dy < (groundAt(tx) - 8) * K.PH { dvy += g; dvx *= 0.998; dvy *= 0.998; dx += dvx; dy += dvy; k += 1 }
        let lead = u.troops != nil ? speed * 18 : dx / K.PH
        let node = SKSpriteNode(texture: SpriteSheet.shared.texture(sprite))
        node.size = CGSize(width: sw * K.PH, height: sh * K.PH)
        node.zPosition = 25
        fxLayer.addChild(node)
        let plane = Plane(unit: u, x: -sw - 10, y: alt, w: sw, h: sh, drops: drops.map { $0 - lead }, node: node)
        if let flak = aliveReactor("flak").first, u.lowLevel != true {
            plane.shootAt = max(150, min(plane.drops[0] - 40, flak.x - 190))
        }
        planes.append(plane)
        say(u.say ?? "INCOMING!", clamp(tx, 60, worldW - 60), max(70, visibleTop + 14), "#ffffff")
        play("plane")
        _ = begin([], plane: plane)
    }

    /// Projectiles arrive from the upper left and land around tx.
    func callRain(_ u: UnitSpec, _ tx: Double) {
        guard let spec = u.proj else { return }
        let top = -30.0, vx = (u.vx ?? 2) * K.PH, vy0 = (u.vy ?? 1) * K.PH
        let h = (groundAt(tx) - 40 - top) * K.PH
        var g = K.grav * gravK * (1 - (spec.lift ?? 0))
        if g == 0 { g = 0.001 }
        let t = (-vy0 + sqrt(vy0 * vy0 + 2 * g * h)) / g
        let lead = vx * t / K.PH
        let count = u.count ?? 10, gap = u.gap ?? 6, every = u.every ?? 70, jitter = u.jitter ?? 6
        let act = begin([])
        for i in 0..<count {
            scheduled.append(Scheduled(at: simT + Double(i) * every) { [weak self] in
                guard let self else { return }
                let x = tx - lead + (Double(i) - Double(count - 1) / 2) * gap + (self.rnd() - 0.5) * jitter
                let e = self.spawnProj(spec, x, top - self.rnd() * 10, vx, vy0, rain: true)
                act.group.append(e)
                if act.lead == nil { act.lead = e }
                if i == 0 { self.play(u.sound ?? "volley") }
            })
        }
        say(u.say ?? "INCOMING!", clamp(tx, 60, worldW - 60), max(70, visibleTop + 14), "#ffffff")
    }

    /// Tunnelers dig under the target, the ground rumbles, then it goes up from underneath.
    func digMine(_ u: UnitSpec, _ tx: Double) {
        let gy = groundAt(tx), dirt = level.flatMap { pack.themes[$0.theme]?.left.base } ?? "#7a5634"
        _ = begin([])
        say(u.say ?? "DIGGING…", clamp(tx, 60, worldW - 60), gy - 40, "#ffffff")
        for k in 0..<4 {
            scheduled.append(Scheduled(at: simT + 350 * Double(k)) { [weak self] in
                guard let self else { return }
                self.shake = max(self.shake, 1.5 + Double(k))
                self.play("thud")
                self.debris(tx + (self.rnd() - 0.5) * 20, gy - 2, [dirt, "#5a3c22"], 6)
            })
        }
        scheduled.append(Scheduled(at: simT + 1500) { [weak self] in
            guard let self else { return }
            self.pendingBooms.append(.at(x: tx, y: gy - 6, boom: self.boom(u) ?? Boom(r: 50, p: 5), fire: false))
            self.debris(tx, gy - 6, [dirt, "#5a3c22", "#a39b8b"], 40)
            self.say(u.blast ?? "KA-BOOM!", clamp(tx, 60, self.worldW - 60), gy - 50, "#ff8c1a")
        })
    }

    func updatePlanes() {
        var i = planes.count - 1
        while i >= 0 {
            defer { i -= 1 }
            let p = planes[i], u = p.unit, speed = u.speed ?? 2
            if p.down {
                p.vy += 0.06
                p.x += speed * 0.8
                p.y += p.vy
                p.angle = min(0.9, p.angle + 0.02)
                if Int(jsRound(simT / K.step)) % 2 == 0 { smoke(p.x + p.w / 2, p.y + p.h / 2) }
                if p.y + p.h / 2 >= groundAt(p.x + p.w / 2) {
                    pendingBooms.append(.at(x: p.x + p.w / 2, y: groundAt(p.x + p.w / 2) - 4, boom: Boom(r: 16, p: 2), fire: false))
                    p.node.removeFromParent()
                    planes.remove(at: i)
                }
                continue
            }
            p.x += speed
            if let shootAt = p.shootAt, p.x + p.w / 2 >= shootAt {
                if let flak = aliveReactor("flak").first, let R = flak.defender?.react {
                    p.down = true
                    for _ in 0..<5 { puff(p.x + p.w / 2 + (rnd() - 0.5) * 30, p.y + (rnd() - 0.5) * 16) }
                    muzzle(flak.x + (R.muzzle?.x ?? 0), flak.y + (R.muzzle?.y ?? 0))
                    play("boom")
                    say(R.say ?? "SHOT DOWN!", clamp(p.x + p.w / 2, 80, worldW - 80), p.y - 10, "#ff8c1a")
                    continue
                }
                p.shootAt = nil
            }
            while p.next < p.drops.count && p.x + p.w / 2 >= p.drops[p.next] {
                if let tk = u.troops, let tu = units[tk] {
                    // paratroopers jump with their chutes already open, then land on whoever is below
                    let jumper = spawnTroop(tu, p.x + p.w / 2, p.y + p.h, speed * 0.4 * K.PH, 0.5)
                    jumper.usedTap = true
                    openChute(jumper)
                    if let active, active.plane === p { active.group.append(jumper) }
                } else if let bomb = u.bomb {
                    spawnProj(bomb, p.x + p.w / 2, p.y + p.h - 2, speed * 0.3 * K.PH + (u.dropVx ?? 0), dropVy(u), bomb: true)
                }
                p.next += 1
            }
            if p.x > worldW + 120 {
                p.node.removeFromParent()
                planes.remove(at: i)
            }
        }
    }

    func rnd() -> Double { Double.random(in: 0..<1) }

    /// The prototype's `u.dropVy || 0.5`.
    private func dropVy(_ u: UnitSpec) -> Double {
        if let v = u.dropVy, v != 0 { return v }
        return 0.5
    }
}
