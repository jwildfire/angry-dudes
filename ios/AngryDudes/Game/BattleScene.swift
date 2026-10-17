import SpriteKit

/// The battlefield: a port of js/game.js onto SpriteKit. SpriteKit's physics replaces
/// Matter.js; everything else (launching, special moves, defenders fighting back, turns,
/// scoring) follows the prototype, split across the BattleScene+*.swift files.
///
/// The scene only draws the battlefield. Menus, the HUD and the arsenal bar are SwiftUI views
/// (see UI/), which talk to the scene through GameModel.
final class BattleScene: SKScene, SKPhysicsContactDelegate {
    enum Mode { case menu, intro, play, result }
    enum Phase { case ready, aiming, active, settling, over }

    /// What the player launched this turn and is still moving.
    final class Active {
        var group: [Entity]
        var lead: Entity?
        var plane: Plane?
        let t0: Double
        init(group: [Entity], plane: Plane?, t0: Double) {
            self.group = group
            self.lead = group.first
            self.plane = plane
            self.t0 = t0
        }
    }

    final class Plane {
        let unit: UnitSpec
        var x: Double, y: Double
        let w: Double, h: Double
        var angle = 0.0, vy = 0.0
        var down = false
        var drops: [Double]
        var next = 0
        var shootAt: Double?
        let node: SKSpriteNode
        init(unit: UnitSpec, x: Double, y: Double, w: Double, h: Double, drops: [Double], node: SKSpriteNode) {
            self.unit = unit; self.x = x; self.y = y; self.w = w; self.h = h; self.drops = drops; self.node = node
        }
    }

    enum PendingBoom {
        case entity(Entity)
        case at(x: Double, y: Double, boom: Boom, fire: Bool)
    }

    struct Contact { let a: SKPhysicsBody; let b: SKPhysicsBody; let rel: Double }
    struct Scheduled { let at: Double; let run: () -> Void }
    /// Drag positions are kept relative to the camera, so they are screen positions (in scene
    /// units) and don't drift when the camera scrolls.
    struct Aim { var start: CGPoint; var current: CGPoint }
    /// A finger that isn't aiming: a tap launches a vehicle or call-in, a drag looks around.
    struct Gesture { var start: CGPoint; var cam0: Double; var moved: Double }

    // MARK: state

    weak var model: GameModel?
    let packs: [PackSpec]
    var pack: PackSpec
    var packIndex = 0
    var byKey: [String: String] = [:]
    var level: LevelSpec?
    var levelIndex = 0
    var mode: Mode = .menu
    var phase: Phase = .ready

    var ents: [Entity] = []
    var planes: [Plane] = []
    var particles: [Particle] = []
    var popups: [Popup] = []
    var tracers: [Tracer] = []
    var pendingBooms: [PendingBoom] = []
    var scheduled: [Scheduled] = []
    var contacts: [Contact] = []
    var arsenal: [String: Int] = [:]
    var selected: String?
    var score = 0.0
    var wind = 0.0
    var simT = 0.0, graceUntil = 0.0, shake = 0.0
    var active: Active?
    var aim: Aim?
    var trail: [CGPoint] = [], lastTrail: [CGPoint] = []
    var settleStill = 0, settleStart = 0.0, winAt = 0.0
    var worldW = K.worldW
    /// Score needed for the second and third star, worked out from what's in the fort.
    var starLine = (0.0, 0.0)
    /// After two losses in a row, the level starts with one extra troop.
    var extraTroop: String?
    /// Launch speed at full pull; wide levels raise it so the far end of the fort is in reach.
    var topSpeed = K.maxSpeed
    /// Gravity for this level: 1 on Earth, less on the Moon.
    var gravK = 1.0
    /// The units in play: the pack's own, or the campaign army's upgraded ones.
    var units: [String: UnitSpec] = [:]
    /// Set while playing a campaign mission (see BattleScene+Campaign.swift).
    var campaign: CampaignRun?
    var buffs: [String: CampaignRun.Buff] = [:]

    // camera: wide battlefields scroll (see BattleScene+Camera.swift)
    var camX = 0.0, camMax = 0.0
    var camHoldX: Double?, camHoldUntil = 0.0
    var introPan = false
    var gesture: Gesture?

    // MARK: nodes and layout

    let cam = SKCameraNode()
    let entityLayer = SKNode()
    let fxLayer = SKNode()
    let backgroundNode = SKSpriteNode()
    let gunnerNode = SKSpriteNode()
    let slingTroopNode = SKSpriteNode()
    var groundNodes: [SKNode] = []
    lazy var painter = Painter(layer: fxLayer)

    /// Screen space the SwiftUI chrome covers, in points.
    var insets = (top: 0.0, bottom: 0.0, left: 0.0, right: 0.0)
    /// Points per logical pixel, and where world (0, 0) sits from the screen's top-left, in logical pixels.
    var scale = 1.0, OX = 0.0, OY = 0.0
    var bufW = 720, bufH = 300
    /// The part of the screen not under the notch, in logical pixels from the screen's left edge.
    var viewLeft = 0.0, viewW = 720.0
    var camBase = CGPoint.zero

    init(size: CGSize, packs: [PackSpec]) {
        self.packs = packs
        self.pack = packs[0]
        super.init(size: size)
        scaleMode = .resizeFill
        physicsWorld.gravity = K.gravity
        physicsWorld.contactDelegate = self
        addChild(cam)
        camera = cam
        backgroundNode.anchorPoint = CGPoint(x: 0, y: 1)
        backgroundNode.zPosition = -100
        addChild(backgroundNode)
        addChild(entityLayer)
        addChild(fxLayer)
        gunnerNode.anchorPoint = CGPoint(x: 0, y: 1)
        gunnerNode.zPosition = 5
        addChild(gunnerNode)
        slingTroopNode.zPosition = 14
        addChild(slingTroopNode)
        layout()
    }

    required init?(coder: NSCoder) { fatalError("BattleScene is built in code") }


    // MARK: layout

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        layout()
    }

    func setInsets(top: Double, bottom: Double, left: Double, right: Double) {
        guard insets != (top, bottom, left, right) else { return }
        insets = (top, bottom, left, right)
        layout()
    }

    /// Fits 720 pixels of battlefield across the space between the HUD and the arsenal bar,
    /// like the prototype's resize(): the top of the sky may be cropped, the ground never is.
    /// Wider battlefields scroll.
    func layout() {
        let W = Double(size.width), H = Double(size.height)
        guard W > 1, H > 1 else { return }
        let availH = max(140, H - insets.top - insets.bottom)
        let usableW = max(200, W - insets.left - insets.right)
        scale = min(usableW / K.viewW, availH / (K.worldH - K.fitTop))
        bufW = Int((W / scale).rounded(.up))
        bufH = Int((H / scale).rounded(.up))
        viewLeft = insets.left / scale
        viewW = usableW / scale
        OY = ((insets.top + availH) / scale - K.worldH).rounded(.down)
        camMax = max(0, (worldW - viewW).rounded(.up))
        camX = clamp(camX, 0, camMax)
        cam.setScale(CGFloat(K.PH / scale))
        placeCamera()
        cam.position = camBase
        if level != nil { buildBackground() }
    }

    /// World y of the top edge of the battlefield the player can see (just under the HUD).
    var visibleTop: Double { -OY + insets.top / scale }

    /// The still scenery is painted once for the whole battlefield, plus a screen's width of
    /// margin on each side, and scrolls with the camera.
    func buildBackground() {
        guard let level else { return }
        let pad = bufW
        let canvas = Background.paint(pack: pack, level: level, levelIndex: levelIndex, worldW: Int(worldW), pad: pad, height: bufH,
                                      oy: Int(OY), skyTop: Int(visibleTop.rounded(.up)))
        backgroundNode.texture = canvas.makeTexture()
        backgroundNode.size = CGSize(width: Double(canvas.width) * K.PH, height: Double(bufH) * K.PH)
        backgroundNode.position = CGPoint(x: -Double(pad) * K.PH, y: OY * K.PH)
        backgroundColor = Palette.color(pack.themes[level.theme]?.sky.first ?? "#6fbff5")
    }

    // MARK: frame loop
    //
    // SpriteKit calls update(_:), then simulates physics (reporting contacts), then
    // didSimulatePhysics(). The prototype's step() maps onto that: forces and timers before
    // the physics step, everything that reacts to collisions after it.

    override func update(_ currentTime: TimeInterval) {
        simT += K.step
        guard level != nil else { return }
        updateEnts()
        for e in ents { e.preVel = e.body.velocity }
    }

    override func didSimulatePhysics() {
        guard level != nil else { return }
        processContacts()
        afterPhysics()
        processBooms()
        sweep()
        if mode == .play {
            reactions()
            updatePlanes()
            checkActive()
            checkSettle()
            updateCamera()
            if winAt > 0 && simT >= winAt && phase != .active { win() }
        }
        updateParticles()
        shake = shake > 0.3 ? shake * 0.86 : 0
        render()
        model?.sync(from: self)
    }

    // MARK: contacts

    func entity(of body: SKPhysicsBody) -> Entity? { (body.node as? EntityNode)?.entity }

    func didBegin(_ contact: SKPhysicsContact) {
        // SpriteKit reports contacts after resolving them, so measure how hard things hit
        // with the velocities from before the step, like Matter's collisionStart.
        let a = contact.bodyA, b = contact.bodyB
        let va = entity(of: a)?.preVel ?? .zero, vb = entity(of: b)?.preVel ?? .zero
        let n = contact.contactNormal
        // speeds are compared to the level's gravity, so a slow landing on the Moon hits as hard as a fast one on Earth
        let rel = abs(Double((va.dx - vb.dx) * n.dx + (va.dy - vb.dy) * n.dy)) / K.fps / gravK.squareRoot()
        contacts.append(Contact(a: a, b: b, rel: rel))
    }

    // MARK: input

    /// A touch point relative to the camera: the same as a screen position, in scene units.
    private func screenRel(_ p: CGPoint) -> CGPoint { CGPoint(x: p.x - cam.position.x, y: p.y - cam.position.y) }

    // Like the prototype: on a scrolling battlefield, aiming starts on the left half of the
    // screen and a drag anywhere else looks around. Vehicles and call-ins go on a tap.
    func pointerDown(_ p: CGPoint) {
        guard mode == .play else { return }
        if introPan { introPan = false; camHoldUntil = 0; camX = 0 }
        if phase == .active { special(); return }
        let r = screenRel(p)
        guard phase == .ready, let sel = selected, (arsenal[sel] ?? 0) > 0, let u = units[sel] else {
            gesture = Gesture(start: r, cam0: camX, moved: 0)
            return
        }
        if (u.kind == "sling" || u.kind == "fire") && (camMax <= 0 || r.x < 0) {
            aim = Aim(start: r, current: r)
            phase = .aiming
            camHoldX = nil
        } else {
            gesture = Gesture(start: r, cam0: camX, moved: 0)
        }
    }

    func pointerMoved(_ p: CGPoint) {
        let r = screenRel(p)
        if phase == .aiming, aim != nil { aim?.current = r; return }
        guard var g = gesture else { return }
        let toPoints = scale / K.PH
        let dx = Double(r.x - g.start.x) * toPoints, dy = Double(r.y - g.start.y) * toPoints
        g.moved = max(g.moved, hypot(dx, dy))
        gesture = g
        if camMax > 0 && g.moved > 6 {
            camHoldX = clamp(g.cam0 - dx / scale, 0, camMax)
            camHoldUntil = .infinity
        }
    }

    func pointerUp(_ p: CGPoint) {
        if gesture != nil {
            pointerMoved(p)
            guard let g = gesture else { return }
            gesture = nil
            if g.moved < 8, phase == .ready, let sel = selected, (arsenal[sel] ?? 0) > 0, let u = units[sel] {
                if u.kind == "drive" { launchDrive(sel) }
                else if u.kind == "air" { callIn(sel, clamp(Double(p.x) / K.PH, 160, worldW - 20)) }
            }
            return
        }
        guard phase == .aiming, aim != nil, let sel = selected, let u = units[sel] else { return }
        pointerMoved(p)
        let pull = pullVector()
        aim = nil
        if hypot(pull.x, pull.y) < 6 { phase = .ready; return }
        let vx = -pull.x / K.maxPull * topSpeed, vy = -pull.y / K.maxPull * topSpeed
        if u.kind == "sling" { launchSling(sel, vx, vy) } else { launchFire(sel, vx, vy) }
    }

    func pointerCancelled() {
        gesture = nil
        if phase == .aiming { aim = nil; phase = .ready }
    }

    /// The drag, in logical pixels (y down), capped at MAX_PULL. A 110-point drag is full power.
    func pullVector() -> (x: Double, y: Double) {
        guard let aim else { return (0, 0) }
        let toPoints = scale / K.PH, k = K.maxPull / K.pullPoints
        var x = Double(aim.current.x - aim.start.x) * toPoints * k
        var y = -Double(aim.current.y - aim.start.y) * toPoints * k
        let len = hypot(x, y)
        if len > K.maxPull { x *= K.maxPull / len; y *= K.maxPull / len }
        return (x, y)
    }

    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let t = touches.first { pointerDown(t.location(in: self)) }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let t = touches.first { pointerMoved(t.location(in: self)) }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let t = touches.first { pointerUp(t.location(in: self)) }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        pointerCancelled()
    }
    #else
    override func mouseDown(with event: NSEvent) { pointerDown(event.location(in: self)) }
    override func mouseDragged(with event: NSEvent) { pointerMoved(event.location(in: self)) }
    override func mouseUp(with event: NSEvent) { pointerUp(event.location(in: self)) }
    override func scrollWheel(with event: NSEvent) {
        guard mode == .play, camMax > 0, phase != .aiming else { return }
        camHoldX = clamp((camHoldX ?? camX) - Double(event.scrollingDeltaX + event.scrollingDeltaY) * 0.5, 0, camMax)
        camHoldUntil = .infinity
    }
    #endif

    /// Picking from the arsenal bar.
    func select(_ key: String) {
        guard phase != .aiming, (arsenal[key] ?? 0) > 0 else { return }
        selected = key
    }

    // MARK: sound
    //
    // Sound effects come later; the calls are kept where the prototype makes its noises.
    func play(_ name: String) {}
}
