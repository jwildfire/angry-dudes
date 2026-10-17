import SpriteKit

/// The node that carries an entity's physics body, so contacts can find their entity.
final class EntityNode: SKNode {
    weak var entity: Entity?
}

/// Anything on the battlefield with a physics body: fort blocks, defenders, the player's
/// vehicles, and projectiles (troops in flight count as projectiles, like the prototype).
final class Entity {
    enum Kind: Int { case block = 0, defender, vehicle, proj }

    let kind: Kind
    let node = EntityNode()
    let body: SKPhysicsBody
    let sprite = SKSpriteNode()
    private var flashNode: SKSpriteNode?

    var key: String
    let w: Double, h: Double
    var hp: Double?
    var maxHp = 0.0
    var pts = 0.0
    var ox = 0.0
    /// Mass the way Matter.js measures it (density × area in physics pixels); the damage and
    /// blast formulas were tuned with it. The SpriteKit body is given the same mass.
    let mass: Double
    var block: BlockSpec?
    var defender: DefenderSpec?
    var unit: UnitSpec?
    var tile = false
    var center = false

    // flags and timers, named after the prototype's
    var faceVel = false, troop = false, trail = false, melee = false, bomb = false, rain = false
    var wet0 = false            // started out in the water (bridge piers), so it doesn't splash
    var born = 0.0
    var dead = false
    var spent = false, boomed = false, touched = false, usedTap = false
    var chute = false, landed = false, snagged = false, shotDown = false, sniped = false
    var dashing = false, unloaded = false, driving = false, freeze = false
    var snagAt = 0.0
    var stuckAt: Double?, fuseAt: Double?, fizzleAt: Double?, snipeAt: Double?
    var flash = 0.0, ramUntil = -1e9, lastAct = -1e9, lastJump = -1e9, lastShot = -1e9
    var pierce = 0
    var boosts = 0
    var restoreVel: CGVector?
    var shots = 0
    var stuck = 0, calm = 0
    var lastX = 0.0
    var preVel = CGVector.zero
    var cracked = false { didSet { if cracked != oldValue { applySprite() } } }
    var spriteName: String { didSet { if spriteName != oldValue { applySprite() } } }

    init(kind: Kind, key: String, sprite: String, w: Double, h: Double, body: SKPhysicsBody, mass: Double) {
        self.kind = kind
        self.key = key
        self.spriteName = sprite
        self.w = w
        self.h = h
        self.body = body
        self.mass = mass
        node.entity = self
        node.physicsBody = body
        node.zPosition = 10 + CGFloat(kind.rawValue)
        node.addChild(self.sprite)
        body.mass = CGFloat(mass)
    }

    /// Call once the entity's tile/center/ox are set.
    func applySprite() {
        let sheet = SpriteSheet.shared, PH = K.PH
        let tex: SKTexture
        if tile {
            tex = sheet.slab(spriteName, w: Int(w), h: Int(h), cracked: cracked, caps: block?.caps)
        } else if cracked {
            tex = sheet.cracked(spriteName, bodyW: w, bodyH: h, ox: ox)
        } else {
            tex = sheet.texture(spriteName)
        }
        let sw = Double(tex.size().width), sh = Double(tex.size().height)
        sprite.texture = tex
        sprite.size = CGSize(width: sw * PH, height: sh * PH)
        // non-centered sprites sit on the bottom of the body (people's feet, tank tracks)
        sprite.position = (center || tile) ? .zero : CGPoint(x: ox * PH, y: -(h / 2 - sh / 2) * PH)
        if let f = flashNode {
            f.texture = sheet.white(spriteName)
            f.size = sprite.size
        }
    }

    func setFlash(_ on: Bool) {
        if on && flashNode == nil && !tile {
            let f = SKSpriteNode(texture: SpriteSheet.shared.white(spriteName))
            f.size = sprite.size
            f.alpha = 0.75
            f.zPosition = 0.5
            sprite.addChild(f)
            flashNode = f
        }
        flashNode?.isHidden = !on
    }

    // MARK: positions and velocities in the prototype's units

    var x: Double { Double(node.position.x) / K.PH }
    var y: Double { -Double(node.position.y) / K.PH }

    /// Velocity in Matter units (physics px per step, y down).
    var vel: (x: Double, y: Double) {
        get { (Double(body.velocity.dx) / K.fps, -Double(body.velocity.dy) / K.fps) }
        set { body.velocity = CGVector(dx: newValue.x * K.fps, dy: -newValue.y * K.fps) }
    }
    var speed: Double { let v = vel; return hypot(v.x, v.y) }

    func addVel(_ dx: Double, _ dy: Double) {
        body.velocity = CGVector(dx: body.velocity.dx + CGFloat(dx * K.fps), dy: body.velocity.dy - CGFloat(dy * K.fps))
    }

    /// Angle in the prototype's convention (clockwise, y down).
    var angle: Double {
        get { -Double(node.zRotation) }
        set { node.zRotation = CGFloat(-newValue) }
    }
    /// Angular velocity in Matter units (radians per step, clockwise).
    var angularVel: Double {
        get { -Double(body.angularVelocity) / K.fps }
        set { body.angularVelocity = CGFloat(-newValue * K.fps) }
    }

    var isStatic: Bool { !body.isDynamic }
}
