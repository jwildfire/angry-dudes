import SpriteKit

// Testing aid, like the prototype's ANGRY_DEBUG: launch at an exact angle and power, tap,
// and list the defenders. The macOS preview's --test mode drives battles with these.
extension BattleScene {
    var debugState: String {
        let ars = pack.order.compactMap { k in arsenal[k].map { "\(k):\($0)" } }.joined(separator: " ")
        return "pack=\(pack.id) level=\(level?.id ?? "-") mode=\(mode) phase=\(phase) score=\(Int(score)) defenders=\(defendersLeft()) wind=\(Int(wind)) speed=\(String(format: "%.1f", topSpeed)) [\(ars)]"
    }

    /// use(key, angle°, power 0–1) for sling and fire units, use(key, x) for air, use(key) for vehicles.
    @discardableResult
    func debugUse(_ key: String, _ a: Double = 0, _ p: Double = 1) -> Bool {
        guard phase == .ready, (arsenal[key] ?? 0) > 0, let u = units[key] else { return false }
        selected = key
        switch u.kind {
        case "drive": launchDrive(key)
        case "air": callIn(key, a)
        default:
            let v = topSpeed * p, r = a * .pi / 180
            if u.kind == "sling" { launchSling(key, cos(r) * v, -sin(r) * v) } else { launchFire(key, cos(r) * v, -sin(r) * v) }
        }
        return true
    }

    func debugReport(all: Bool = false) -> [String] {
        ents.filter { all ? $0.kind != .block : $0.kind == .defender }.map { e in
            var s = "\(e.key)"
            if let hp = e.hp { s += String(format: " hp %.1f", hp) }
            s += " @\(Int(e.x.rounded())),\(Int(e.y.rounded()))"
            if e.kind == .vehicle { s += String(format: " v%.2f", e.vel.x) + (e.driving ? " driving" : " stopped") }
            return s
        }
    }
}
