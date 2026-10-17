import SpriteKit

// Campaign missions on the battlefield: the army's upgrades, tougher defenders, extra items,
// and recording each win (see Data/Campaign.swift). Outside a campaign these change nothing.
extension BattleScene {
    func applyCampaignUnits() {
        buffs = campaign?.buffs ?? [:]
    }

    var campaignToughness: Double { campaign.map { $0.spec.tough($0.index) } ?? 1 }

    /// The level's arsenal plus every reward that adds items. Ground troops sit out Air Force missions.
    func campaignArsenal(_ level: LevelSpec) -> [String: Int] {
        var a = level.arsenal
        guard let run = campaign else { return a }
        for id in run.state.perks {
            guard let add = run.spec.reward(id)?.add else { continue }
            for (k, n) in add {
                if level.airOnly == true && units[k]?.kind != "air" { continue }
                a[k, default: 0] += n
            }
        }
        return a
    }

    /// After a win: stars, the mission marked done, and (on a first win, before the last
    /// mission) three rewards offered. The offer is the same every time for a given mission.
    func campaignWin(stars: Int) {
        guard let run = campaign, let level else { return }
        let C = run.spec
        var cs = CampaignState.load(pack.id)
        cs.stars[level.id] = max(cs.stars[level.id] ?? 0, stars)
        if !cs.done.contains(level.id) {
            cs.done.append(level.id)
            if run.index < C.missions.count - 1 {
                var pool = C.rewards.filter { !cs.perks.contains($0.id) }.map(\.id)
                let pick = seededRandom(run.index * 7 + 3)
                var offer: [String] = []
                while !pool.isEmpty && offer.count < 3 { offer.append(pool.remove(at: Int(pick() * Double(pool.count)))) }
                cs.offers[level.id] = offer
                cs.pending = level.id
            }
        }
        cs.save(pack.id)
        campaign?.state = cs
    }

    // MARK: units with the army's upgrades

    func power(_ u: UnitSpec) -> Double { (u.power ?? 1) * (buffs[u.key]?.power ?? 1) }

    func boom(_ u: UnitSpec) -> Boom? {
        guard let b = u.boom else { return nil }
        guard let m = buffs[u.key], m.boomR != 1 || m.boomP != 1 else { return b }
        return Boom(r: b.r * m.boomR, p: b.p * m.boomP)
    }

    func hp(_ u: UnitSpec) -> Double { (u.hp ?? 5) * (buffs[u.key]?.hp ?? 1) }
}
