import CoreGraphics

/// World constants, the same as js/game.js.
///
/// World units are "logical pixels", the grid the sprites are drawn on. The battlefield is
/// 720 × 300 with the ground at y = 270, and y grows downward like the prototype.
/// SpriteKit runs the physics PH times larger (one logical pixel = 3 scene points), which keeps
/// 16 px blocks stacking calmly; scene y grows upward, so scene y = -y × PH.
///
/// Speeds and pushes in the pack files are in the prototype's Matter.js units (physics pixels
/// per 1/60 s step). Entity.vel and addVel convert them, so the pack numbers work unchanged.
enum K {
    static let step = 1000.0 / 60.0                 // ms per simulation step
    static let fps = 60.0
    static let PH = 3.0
    static let worldW = 720.0, worldH = 300.0, ground = 270.0   // worldW is the default; levels may be wider
    static let viewW = 720.0                        // how much battlefield fits across the screen
    static let bonus = 5000.0                       // points for each thing left in the arsenal
    static let fitTop = 70.0                        // high sky may be cropped on short screens
    static let grav = 0.001 * step * step           // gravity per step², physics pixels
    static let pointsPerMeter = 150.0               // SpriteKit's physics scale
    static let slingX = 110.0, sling = (x: 118.0, y: 249.0)
    static let bunkerX = 40.0, bunker = (x: 66.0, y: 242.0)
    static let maxPull = 50.0, maxSpeed = 24.0
    static let pullPoints = 110.0                   // finger travel (points) for a full-power pull
    static let outline = "#1d1a2b"

    /// Gravity in SpriteKit units: grav physics px/step² → points/s² → m/s².
    static var gravity: CGVector { CGVector(dx: 0, dy: -grav * fps * fps / pointsPerMeter) }
    /// Matter's frictionAir (velocity lost per step) as Box2D linear damping.
    static func damping(_ frictionAir: Double) -> CGFloat { CGFloat(-log(1 - frictionAir) * fps) }
}

/// Physics categories. Projectiles never hit each other, troops never hit each other (split
/// troops, unloading towers), and nothing bumps into sensors (barbed wire, stuck arrows).
enum Cat {
    static let ground: UInt32 = 1 << 0
    static let block: UInt32 = 1 << 1
    static let defender: UInt32 = 1 << 2
    static let vehicle: UInt32 = 1 << 3
    static let proj: UInt32 = 1 << 4
    static let troop: UInt32 = 1 << 5
    static let sensor: UInt32 = 1 << 6
    static let water: UInt32 = 1 << 7       // rivers and moats: only boats touch them
    static let solid = ground | block | defender | vehicle
    /// Everything reports contacts except water, which only boats feel (like Matter's collision filter).
    static let contacts: UInt32 = ~water
}
