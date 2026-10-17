import SpriteKit

// Loading packs and levels, and building the fort from its letter drawing.
extension BattleScene {
    func usePack(_ i: Int) {
        packIndex = clamp(i, 0, packs.count - 1)
        pack = packs[packIndex]
        units = pack.units
        byKey = [:]
        for (c, b) in pack.blocks where b.slab != true { byKey[b.key] = c }
        for (c, d) in pack.defenders { byKey[d.key] = c }
    }

    func nameOf(_ key: String) -> String {
        if let u = units[key] { return u.displayName }
        if let c = byKey[key] { return pack.blocks[c]?.name ?? pack.defenders[c]?.name ?? key }
        return key
    }

    func loadLevel(_ i: Int) {
        levelIndex = clamp(i, 0, pack.levels.count - 1)
        let level = pack.levels[levelIndex]
        self.level = level

        for e in ents { e.node.removeFromParent() }
        for p in planes { p.node.removeFromParent() }
        for g in groundNodes { g.removeFromParent() }
        ents = []; planes = []; particles = []; popups = []; tracers = []; pendingBooms = []; scheduled = []; contacts = []
        groundNodes = []
        trail = []; lastTrail = []; active = nil; aim = nil; phase = .ready
        simT = 0; graceUntil = 1200; score = 0; winAt = 0; shake = 0
        worldW = level.width ?? K.worldW
        camX = 0; camHoldX = nil; camHoldUntil = 0; gesture = nil; introPan = false
        gravK = level.gravity ?? 1
        physicsWorld.gravity = CGVector(dx: 0, dy: K.gravity.dy * CGFloat(gravK))
        applyCampaignUnits()

        // the ground, with any trenches cut into it as lower floors, and water only boats float on
        var gx0 = -800.0
        for t in (level.trenches ?? []).sorted(by: { $0.x < $1.x }) {
            addGround(from: gx0, to: t.x, top: K.ground)
            addGround(from: t.x, to: t.x + t.w, top: K.ground + t.d)
            gx0 = t.x + t.w
            if t.water == true { addWater(t) }
        }
        addGround(from: gx0, to: worldW + 800, top: K.ground)
        if let cliff = level.cliff {
            let cw = worldW + 300 - cliff.x
            addGround(cx: cliff.x + cw / 2, cy: K.ground - cliff.h / 2, w: cw, h: cliff.h)
        }

        // Each column stacks on whatever is already below it (open ground, a trench floor or a
        // cliff top), so towers, gates and huts can sit side by side.
        let rows = level.fort.map { Array($0) }
        func columnBase(_ c: Int) -> Double { groundAt(level.fortX + Double(c) * 16 + 8) }
        var cols = (0..<(rows.map(\.count).max() ?? 0)).map(columnBase)
        func topOf(_ c: Int, _ n: Int) -> Double {
            var t = Double.infinity
            for k in c..<(c + n) { t = min(t, k < cols.count ? cols[k] : columnBase(k)) }
            return t
        }
        for row in rows.reversed() {
            var c = 0
            while c < row.count {
                let ch = String(row[c]), x = level.fortX + Double(c) * 16
                defer { c += 1 }
                if ch == "." || ch == "-" { continue }
                if let b = pack.blocks[ch], b.slab == true {
                    var n = 1
                    while c + n < row.count && row[c + n] == row[c] { n += 1 }
                    var top = topOf(c, n)
                    let sh = b.h ?? 8
                    if b.boat == true { top = min(top, K.ground) }      // a ship's hull floats on the water
                    addBlock(ch, cx: x + Double(n) * 8, bottom: top, w: Double(n) * 16, h: sh)
                    for k in c..<min(c + n, cols.count) { cols[k] = top - sh }
                    c += n - 1
                } else if let b = pack.blocks[ch] {
                    if b.boat == true { cols[c] = min(cols[c], K.ground) }
                    addBlock(ch, cx: x + 8, bottom: cols[c])
                    cols[c] -= b.h ?? 16
                } else if let d = pack.defenders[ch] {
                    let n = d.cells ?? 1, top = topOf(c, n)
                    addDefender(ch, cx: x + Double(n) * 8, bottom: top)
                    for k in c..<min(c + n, cols.count) { cols[k] = top - 16 }
                }
            }
        }
        for ex in level.extras ?? [] {
            guard let ch = byKey[ex.type] else { continue }
            let at = groundAt(ex.x) - (ex.alt ?? 0)
            if pack.blocks[ch] != nil { addBlock(ch, cx: ex.x, bottom: at) }
            else if pack.defenders[ch] != nil { addDefender(ch, cx: ex.x, bottom: at) }
        }

        // in a campaign, every mission's defenders are tougher than the last
        let tough = campaignToughness
        if tough != 1 { for e in ents where e.kind == .defender { e.hp = (e.hp ?? 0) * tough; e.maxHp *= tough } }
        arsenal = [:]
        let issued = campaignArsenal(level)
        for k in pack.order { if let n = issued[k], n > 0 { arsenal[k] = n } }
        // Star targets: knocking everything out plus typical wreckage is the base; each item left over adds a bonus.
        var base = 0.0
        for e in ents {
            if e.kind == .defender { base += e.pts } else if e.kind == .block && e.block?.fixed != true { base += e.pts * 0.5 }
        }
        starLine = (jsRound((base + K.bonus) / 1000) * 1000, jsRound((base + 2 * K.bonus) / 1000) * 1000)
        // A full pull lands a troop about 600 px out. Wider levels launch faster so the farthest defender on the ground
        // (balloons don't count: they're for planes) can still be reached; higher targets count as a bit farther.
        var far = 0.0
        for e in ents where e.kind == .defender && e.defender?.float != true { far = max(far, e.x + 24 + (K.ground - e.y)) }
        topSpeed = K.maxSpeed * clamp(sqrt(max(0, far - K.sling.x) / 600 * gravK), 1, 1.4)
        // After a couple of losses, a bonus troop makes the next try a little easier.
        extraTroop = nil
        if Store.losses(pack: pack.id, level: level.id) >= 2 {
            extraTroop = pack.order.first { (arsenal[$0] ?? 0) > 0 && units[$0]?.kind == "sling" }
                ?? pack.order.first { (arsenal[$0] ?? 0) > 0 }
            if let k = extraTroop { arsenal[k, default: 0] += 1 }
        }
        selected = firstAvailable()
        newWind()
        layout()
    }

    func startBattle() {
        mode = .play
        if camMax > 0 {
            // start on the fort, then pan back to the launcher
            camX = camMax; camHoldX = camMax; camHoldUntil = simT + 1500; introPan = true
        }
        // name tags over the defenders worth knowing about
        var named = Set<String>()
        for d in defenders() {
            guard let def = d.defender, def.react != nil || def.float == true || d.pts >= 5000, !named.contains(d.key) else { continue }
            named.insert(d.key)
            let sh = Double(d.sprite.size.height) / K.PH
            say((def.name ?? d.key).uppercased(), d.x, d.y - d.h / 2 - (sh - d.h) - 10, "#ffffff", life: 2800)
        }
    }

    func groundAt(_ x: Double) -> Double {
        guard let level else { return K.ground }
        if let cliff = level.cliff, x >= cliff.x { return K.ground - cliff.h }
        for t in level.trenches ?? [] where x >= t.x && x < t.x + t.w { return K.ground + t.d }
        return K.ground
    }

    /// Below the surface of a river or moat.
    func inWater(_ x: Double, _ y: Double) -> Bool {
        for t in level?.trenches ?? [] where t.water == true && x >= t.x && x < t.x + t.w && y > K.ground + 5 { return true }
        return false
    }

    func firstAvailable() -> String? { pack.order.first { (arsenal[$0] ?? 0) > 0 } }

    func newWind() {
        let w = level?.wind ?? 0
        wind = w > 0 ? jsRound((Double.random(in: 0..<1) * 2 - 1) * w) : 0
    }

    func defenders() -> [Entity] { ents.filter { $0.kind == .defender && !$0.dead } }
    func defendersLeft() -> Int { ents.reduce(0) { $0 + ($1.kind == .defender && !$1.dead ? 1 : 0) } }
    func aliveReactor(_ type: String) -> [Entity] { defenders().filter { $0.defender?.react?.type == type } }

    // MARK: building bodies

    private func addGround(from a: Double, to b: Double, top: Double) {
        guard b > a else { return }
        addGround(cx: (a + b) / 2, cy: top + 100, w: b - a, h: 200)
    }

    private func addWater(_ t: LevelSpec.Trench) {
        let n = SKNode()
        n.position = CGPoint(x: (t.x + t.w / 2) * K.PH, y: -(K.ground + 2) * K.PH)
        let b = SKPhysicsBody(rectangleOf: CGSize(width: t.w * K.PH, height: 4 * K.PH))
        b.isDynamic = false
        b.categoryBitMask = Cat.water
        b.collisionBitMask = 0
        b.contactTestBitMask = 0
        n.physicsBody = b
        addChild(n)
        groundNodes.append(n)
    }

    private func addGround(cx: Double, cy: Double, w: Double, h: Double) {
        let n = SKNode()
        n.position = CGPoint(x: cx * K.PH, y: -cy * K.PH)
        let b = SKPhysicsBody(rectangleOf: CGSize(width: w * K.PH, height: h * K.PH))
        b.isDynamic = false
        b.friction = 0.9
        b.categoryBitMask = Cat.ground
        b.collisionBitMask = Cat.solid | Cat.proj | Cat.troop
        b.contactTestBitMask = Cat.contacts
        n.physicsBody = b
        addChild(n)
        groundNodes.append(n)
    }

    func addEnt(_ e: Entity) {
        e.born = simT
        if e.kind == .block || e.kind == .defender { e.wet0 = inWater(e.x, e.y) }   // bridge piers built in the river
        entityLayer.addChild(e.node)
        ents.append(e)
    }

    @discardableResult
    func addBlock(_ ch: String, cx: Double, bottom: Double, w: Double? = nil, h: Double? = nil) -> Entity? {
        guard let d = pack.blocks[ch] else { return nil }
        let w = w ?? d.w ?? 16, h = h ?? d.h ?? 16
        let body = SKPhysicsBody(rectangleOf: CGSize(width: w * K.PH, height: h * K.PH))
        body.friction = 0.8
        body.restitution = 0.05
        body.linearDamping = K.damping(0.01)
        body.angularDamping = K.damping(0.01)
        body.isDynamic = d.fixed != true
        body.categoryBitMask = d.sensor == true ? Cat.sensor : Cat.block
        body.collisionBitMask = d.sensor == true ? 0 : Cat.solid | Cat.proj | Cat.troop | (d.boat == true ? Cat.water : 0)
        body.contactTestBitMask = Cat.contacts
        let e = Entity(kind: .block, key: d.key, sprite: d.sprite ?? d.key, w: w, h: h, body: body, mass: d.density * w * h * K.PH * K.PH)
        let hp = d.slab == true ? d.hp * w / 96 + d.hp * 0.4 : d.hp
        e.hp = hp; e.maxHp = hp; e.pts = d.pts; e.block = d; e.tile = d.slab == true
        e.node.position = CGPoint(x: cx * K.PH, y: -(bottom - h / 2) * K.PH)
        e.applySprite()
        addEnt(e)
        return e
    }

    @discardableResult
    func addDefender(_ ch: String, cx: Double, bottom: Double) -> Entity? {
        guard let d = pack.defenders[ch] else { return nil }
        let body = SKPhysicsBody(rectangleOf: CGSize(width: d.w * K.PH, height: d.h * K.PH))
        body.friction = 0.9
        body.restitution = 0
        body.linearDamping = K.damping(0.01)
        body.angularDamping = K.damping(0.01)
        body.isDynamic = d.float != true
        body.categoryBitMask = Cat.defender
        body.collisionBitMask = Cat.solid | Cat.proj | Cat.troop
        body.contactTestBitMask = Cat.contacts
        let e = Entity(kind: .defender, key: d.key, sprite: d.sprite ?? d.key, w: d.w, h: d.h, body: body, mass: d.density * d.w * d.h * K.PH * K.PH)
        e.hp = d.hp; e.maxHp = d.hp; e.pts = d.pts; e.ox = d.ox ?? 0; e.defender = d
        e.node.position = CGPoint(x: cx * K.PH, y: -(bottom - d.h / 2) * K.PH)
        e.applySprite()
        addEnt(e)
        return e
    }
}
