import Foundation

// The battle packs, decoded from assets/packs/<id>.json (exported from js/packs/*.js by
// tools/export_packs.py). Field names match the JavaScript, so the pack format described at
// the top of js/packs/ww2.js applies here too. Anything a pack leaves out is nil.

struct Boom: Decodable { let r: Double; let p: Double }
struct XY: Decodable { let x: Double; let y: Double }
struct Spread: Decodable { let n: Int; let deg: Double }
struct GunSpec: Decodable { let x: Double; let y: Double; let vx: Double; let vy: Double }
struct UnloadSpec: Decodable { let unit: String; let count: Int; let vx: Double?; let vy: Double?; let spread: Double? }

/// Anything the player can use, and the projectiles those things fire (shells, bombs, arrows).
final class UnitSpec: Decodable {
    /// The unit's id in the pack ("rifleman"); empty for nested projectile specs.
    var key = ""

    let name: String?
    let kind: String?           // sling | fire | drive | air
    let sprite: String?
    let gunner: String?
    let icon: String?
    let w: Double?
    let h: Double?
    let density: Double?
    let best: String?
    let tap: String?            // the special move: shout, chute, detonate, pound, dash, split, jump, shoot, ram, unload, blowup
    let shout: String?
    let hint: String?
    let melee: String?
    let chuteSprite: String?
    let boom: Boom?
    let power: Double?
    let fuse: Double?
    let bounce: Double?
    let spin: Double?
    let faceVel: Bool?
    let lift: Double?
    let wind: Bool?
    let impact: Bool?
    let speed: Double?
    let push: Double?
    let hp: Double?
    let shots: Int?
    let gun: GunSpec?
    let shell: UnitSpec?
    let style: String?          // air units: plane | rain
    let bombs: Int?
    let spacing: Double?
    let alt: Double?
    let bomb: UnitSpec?
    let say: String?
    let pierce: Int?
    let pierceDmg: Double?
    let round: Bool?
    let sound: String?
    let dash: Double?
    let splitInto: String?
    let ox: Double?
    let ramSpeed: Double?
    let jump: Double?
    let unload: UnloadSpec?
    let count: Int?
    let gap: Double?
    let every: Double?
    let vx: Double?
    let vy: Double?
    let jitter: Double?
    let proj: UnitSpec?
    let soft: Bool?
    let stick: Bool?
    let life: Double?
    let enemy: Bool?
    let spread: Spread?
    let fire: Bool?
    let troops: String?         // planes that drop paratroopers instead of bombs
    let boat: Bool?             // vehicles that float on water
    let reach: Double?          // sharpshoot range
    let shotDmg: Double?
    let blast: String?          // tunnel mine call-out
    let boosts: Int?            // jetpack bursts per flight
    let boost: Double?
    let boostX: Double?
    let lowLevel: Bool?         // planes that fly under the flak
    let dropVx: Double?         // extra drop speed for planes' bombs and rockets
    let dropVy: Double?

    private enum CodingKeys: String, CodingKey {
        case name, kind, sprite, gunner, icon, w, h, density, best, tap, shout, hint, melee, chuteSprite, boom, power,
             fuse, bounce, spin, faceVel, lift, wind, impact, speed, push, hp, shots, gun, shell, style, bombs, spacing,
             alt, bomb, say, pierce, pierceDmg, round, sound, dash, splitInto, ox, ramSpeed, jump, unload, count, gap,
             every, vx, vy, jitter, proj, soft, stick, life, enemy, spread, fire, troops, boat, reach, shotDmg, blast,
             boosts, boost, boostX, lowLevel, dropVx, dropVy
    }

    var displayName: String { name ?? key }
    var iconSprite: String { icon ?? (kind == "fire" ? (gunner ?? sprite ?? key) : (sprite ?? key)) }
}

struct BlockSpec: Decodable {
    let key: String
    let name: String?
    let sprite: String?
    let hp: Double
    let density: Double
    let pts: Double
    let debris: [String]
    let w: Double?
    let h: Double?
    let fixed: Bool?
    let sensor: Bool?
    let explodes: Boom?
    let fire: Bool?
    let slab: Bool?
    let boat: Bool?             // a ship's hull: floats on water, never splashes
    let caps: [String]?         // slab end pieces (bow and stern), replacing the outline
}

struct ReactSpec: Decodable {
    let type: String            // shooter | sniper | antitank | claw | oil | flak | heal
    let range: Double?
    let lift: Double?
    let height: Double?
    let say: String?
    let sound: String?
    let muzzle: XY?
    let every: Double?
    let vx: Double?
    let vy: Double?
    let shell: UnitSpec?
    let amount: Double?
    let damage: Double?
}

struct DefenderSpec: Decodable {
    let key: String
    let name: String?
    let sprite: String?
    let w: Double
    let h: Double
    let hp: Double
    let density: Double
    let pts: Double
    let cells: Int?
    let ox: Double?
    let react: ReactSpec?
    let float: Bool?            // hangs in the air on a tether (observation balloons)
    let explodes: Boom?         // goes up when knocked out (V-1 ramps)
    let fire: Bool?
}

struct GroundColors: Decodable { let top: String; let hi: String; let base: String; let lo: String }
struct TrenchColors: Decodable { let cut: String; let plank: String; let floor: String; let slat: String }

struct ThemeSpec: Decodable {
    let sky: [String]
    let sun: String?
    let clouds: Bool?
    let cloud: String?
    let hills: [String]
    let split: Double?
    let left: GroundColors
    let right: GroundColors
    let rock: [String]?
    let trees: String?
    let treeColor: String?
    let weather: String?
    let night: Bool?
    let trench: TrenchColors?
    let water: String?
    let waterHi: String?
    let planet: [String]?       // a planet in a night sky: body, bands or land, optional ring
}

struct LevelSpec: Decodable {
    struct Extra: Decodable { let type: String; let x: Double; let alt: Double? }
    struct Cliff: Decodable { let x: Double; let h: Double }
    /// A trench cut into the ground (a lower floor), or a river or moat when `water` is set.
    struct Trench: Decodable { let x: Double; let w: Double; let d: Double; let water: Bool? }
    struct Crater: Decodable { let x: Double; let r: Double? }

    let id: String
    let name: String
    let date: String
    let theme: String
    let history: String
    let tip: String
    let fortX: Double
    let fort: [String]
    let extras: [Extra]?
    let arsenal: [String: Int]
    let wind: Double?
    let cliff: Cliff?
    /// Battlefield width in logical pixels; wider than 720 scrolls.
    let width: Double?
    let trenches: [Trench]?
    let craters: [Crater]?
    /// 1 on Earth, less on the Moon.
    let gravity: Double?
    /// Air Force missions: only planes, and campaign rewards for ground troops sit them out.
    let airOnly: Bool?
}

struct PackProps: Decodable {
    let bunker: String
    let pennant: [String]?
    let sling: String?
}

struct PackSpec: Decodable {
    let id: String
    let name: String
    let years: String
    let side: String
    let foe: String
    let icon: String
    let blurb: String
    let props: PackProps
    let units: [String: UnitSpec]
    let order: [String]
    let blocks: [String: BlockSpec]
    let defenders: [String: DefenderSpec]
    let themes: [String: ThemeSpec]
    let levels: [LevelSpec]
    let campaign: CampaignSpec?

    func levelNumber(_ id: String) -> Int? { levels.firstIndex { $0.id == id } }

    /// Loads every pack listed in assets/packs/index.json, in menu order.
    static func loadAll() -> [PackSpec] {
        struct Index: Decodable { let packs: [String] }
        let decoder = JSONDecoder()
        do {
            let index = try decoder.decode(Index.self, from: GameAssets.data("packs/index.json"))
            return try index.packs.map { id in
                let pack = try decoder.decode(PackSpec.self, from: GameAssets.data("packs/\(id).json"))
                for (k, u) in pack.units { u.key = k }
                return pack
            }
        } catch {
            fatalError("Battle pack data: \(error)")
        }
    }
}
