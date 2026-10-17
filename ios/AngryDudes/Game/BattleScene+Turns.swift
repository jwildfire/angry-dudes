import SpriteKit

// Turn flow: wait for this turn's launch to stop moving, let the dust settle, then the next
// turn, a win or a loss. Scoring and stars work like the prototype: every defender knocked out
// wins the battle, and anything left in the arsenal is worth 2,000 bonus points.
extension BattleScene {
    func busy(_ e: Entity) -> Bool {
        if e.dead { return false }
        if e.kind == .vehicle {
            let calm = !e.driving && e.speed < 0.3 && simT - e.lastAct > 1300
            e.calm = calm ? e.calm + 1 : 0
            return e.calm < 50
        }
        if e.chute { return true }
        e.calm = (simT - e.born > 400 && e.speed < 0.4) ? e.calm + 1 : 0
        return e.calm < 40
    }

    func checkActive() {
        guard let active else { return }
        let t = simT - active.t0
        let planeBusy = active.plane.map { p in planes.contains { $0 === p } } ?? false
        let shells = ents.contains { $0.bomb && !$0.dead }
        let waiting = !scheduled.isEmpty
        let members = active.group.filter { busy($0) }.count > 0
        if (!planeBusy && !shells && !waiting && !members) || t > 16000 {
            self.active = nil
            phase = .settling
            settleStill = 0
            settleStart = simT
        }
    }

    func checkSettle() {
        guard phase == .settling else { return }
        let moving = !pendingBooms.isEmpty || !planes.isEmpty || ents.contains {
            !$0.dead && !$0.isStatic && !$0.body.isResting && $0.speed > 0.25
        }
        settleStill = moving ? 0 : settleStill + 1
        if settleStill > 30 || simT - settleStart > 4500 { finishTurn() }
    }

    func finishTurn() {
        for e in ents where !e.dead && (e.kind == .proj || e.kind == .vehicle) {
            poof(e.x, e.y, 8)
            e.dead = true
        }
        if winAt > 0 || defendersLeft() == 0 { win(); return }
        if firstAvailable() == nil { lose(); return }
        healDefenders()
        if (arsenal[selected ?? ""] ?? 0) == 0 { selected = firstAvailable() }
        newWind()
        phase = .ready
    }

    func win() {
        guard mode == .play, let level else { return }
        mode = .result
        phase = .over
        let left = arsenal.values.reduce(0, +)
        let bonus = Double(left) * K.bonus
        score += bonus
        let stars = 1 + (score >= starLine.0 ? 1 : 0) + (score >= starLine.1 ? 1 : 0)
        Store.setLosses(0, pack: pack.id, level: level.id)
        Store.record(pack: pack.id, level: level.id, score: Int(score), stars: stars)
        campaignWin(stars: stars)
        play("fanfare")
        model?.battleEnded(won: true, stars: stars, score: Int(score), bonus: Int(bonus), left: left)
    }

    func lose() {
        guard mode == .play, let level else { return }
        mode = .result
        phase = .over
        Store.setLosses(Store.losses(pack: pack.id, level: level.id) + 1, pack: pack.id, level: level.id)
        play("sad")
        model?.battleEnded(won: false, stars: 0, score: Int(score), bonus: 0, left: 0)
    }

    /// The line above the arsenal bar.
    var hint: String {
        guard mode == .play else { return "" }
        if phase == .active, let a = active?.lead, !a.dead, let u = a.unit, let tap = u.tap {
            var t: String
            switch tap {
            case "shout": t = "Tap to shout!"
            case "chute": t = a.chute ? "Floating down…" : "Tap to pop the parachute!"
            case "detonate": t = "Tap to set off the charge!"
            case "pound": t = "Tap for a ground pound!"
            case "dash": t = "Tap to charge!"
            case "split": t = "Tap to split up!"
            case "sharpshoot": t = "Tap to fire at the nearest defenders!"
            case "jump": t = "Tap to jump!"
            case "ram": t = "Tap to ram!"
            case "unload": t = a.unloaded ? "Over they go!" : "Tap to send troops over the wall!"
            case "blowup": t = "Tap to blow it up!"
            case "boost": t = "Tap to fire the jetpack!"
            case "shoot": t = a.shots > 0 ? "Tap to fire! \(a.shots) \(a.shots == 1 ? "shot" : "shots") left" : "Out of ammo."
            default: t = ""
            }
            if a.usedTap && ["shout", "dash", "split", "pound", "sharpshoot"].contains(tap) { t = "" }
            return t
        }
        switch phase {
        case .active: return "Here it comes…"
        case .settling: return "Waiting for the dust to settle…"
        default: return selected.flatMap { units[$0]?.hint } ?? ""
        }
    }
}
