import SpriteKit
import SwiftUI
import Metal
import ImageIO
import UniformTypeIdentifiers

/// Plays a scripted battle offscreen (no window, no Xcode) on a simulated iPhone screen held
/// sideways, prints what happened, and saves screenshots of the scene with the SwiftUI screens
/// drawn on top. The game runs exactly as in the app, one 1/60 s frame at a time, just faster
/// than real time.
///
/// Script lines (# starts a comment):
///   pack ww2                 choose a battle pack            menu / intro 0 / start
///   open 0                   open a battle and start it      wait 1500 / settle
///   use mortar 62 0.8        launch at 62° and 80% power     use p51 520   (air: target x)
///   use jeep                 roll out a vehicle              tap   (special move)
///   drag 300 200 220 240     drag on screen (points from the top-left), like a finger
///   select grenade           pick from the arsenal bar       report
///   look                     press "See fort" (look state: print the camera)
///   map / map 3              open the campaign map / pick mission 3 on it
///   mission 3                fight campaign mission 3       reward 2   (pick the 2nd reward)
///   campaign                 print campaign progress        erase      (start the campaign over)
///   shot name                save name.png                    result (show the battle report)
///   expect win | lose        fail the run unless the battle ended that way
@MainActor
final class Headless {
    static let phone = CGSize(width: 844, height: 390)          // iPhone 15 held sideways, in points
    static let phoneSafeArea = EdgeInsets(top: 0, leading: 59, bottom: 21, trailing: 59)

    let model: GameModel
    var scene: BattleScene { model.scene }
    let renderer: SKRenderer
    let device: MTLDevice
    let queue: MTLCommandQueue
    let base = CACurrentMediaTime()
    var t = 0.0
    let out: URL

    init(out: URL) {
        device = MTLCreateSystemDefaultDevice()!
        queue = device.makeCommandQueue()!
        model = GameModel(sceneSize: Headless.phone)
        renderer = SKRenderer(device: device)
        renderer.scene = model.scene
        renderer.ignoresSiblingOrder = true
        self.out = out
        model.setSafeArea(Headless.phoneSafeArea)
        renderer.update(atTime: base)
        layoutChrome()
        _ = sceneImage(scale: 2)        // SKRenderer's first offscreen render comes out empty
    }

    static func run(script path: String, outDir: URL) -> Bool {
        guard let text = try? String(contentsOfFile: path, encoding: .utf8) else {
            print("can't read \(path)")
            return false
        }
        try? FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)
        let h = Headless(out: outDir)
        var ok = true
        for raw in text.split(separator: "\n", omittingEmptySubsequences: false) {
            let line = raw.split(separator: "#", maxSplits: 1, omittingEmptySubsequences: false).first.map(String.init)?
                .trimmingCharacters(in: .whitespaces) ?? ""
            if line.isEmpty { continue }
            print("> \(line)")
            if !h.exec(line.split(separator: " ").map(String.init)) { ok = false }
        }
        print(ok ? "SCRIPT OK" : "SCRIPT FAILED")
        return ok
    }

    func exec(_ w: [String]) -> Bool {
        func num(_ i: Int, _ d: Double = 0) -> Double { i < w.count ? Double(w[i]) ?? d : d }
        switch w[0] {
        case "pack":
            if let i = model.packs.firstIndex(where: { $0.id == w[1] }) { model.choosePack(i) }
            frames(30)
        case "menu": model.toMenu(); layoutChrome(); frames(2)
        case "intro": model.openIntro(Int(num(1))); layoutChrome(); frames(2)
        case "start": model.startBattle(); layoutChrome(); frames(2)
        case "open":
            model.openIntro(Int(num(1)))
            model.startBattle()
            layoutChrome()
            advance(1500)
            print("  \(scene.debugState)")
        case "select": model.select(w[1]); frames(1)
        case "use":
            let ok = w.count > 3 ? scene.debugUse(w[1], num(2), num(3)) : scene.debugUse(w[1], num(2))
            print(ok ? "  launched" : "  not ready: \(scene.debugState)")
            frames(1)
        case "aim":
            // aim key x y [power] [high]: solve the angle that passes through world point (x, y)
            // like a player: try the arc asked for, then the other arc, then less power
            let power = num(4, 1), high = w.contains("high")
            var found: (a: Double, p: Double)?
            for p in stride(from: power, through: 0.5, by: -0.05) {
                for h in [high, !high] {
                    if found == nil, let a = solveAngle(w[1], num(2), num(3), power: p, high: h) { found = (a, p) }
                }
            }
            guard let shot = found else {
                print("  no angle reaches \(num(2)),\(num(3))")
                return false
            }
            let ok = scene.debugUse(w[1], shot.a, shot.p)
            print(ok ? String(format: "  launched at %.1f° and %.0f%%", shot.a, shot.p * 100) : "  not ready: \(scene.debugState)")
            frames(1)
        case "aimfar":
            // aimfar key: can a full pull reach the farthest defender on the ground? (wide levels launch faster)
            let far = scene.defenders().filter { $0.defender?.float != true }.max { $0.x + (K.ground - $0.y) < $1.x + (K.ground - $1.y) }
            guard let d = far else { return true }
            let reach = [false, true].contains { solveAngle(w[1], d.x, d.y - d.h / 2, power: 1, high: $0) != nil }
            print("  farthest \(d.key) @\(Int(d.x)),\(Int(d.y)): " + (reach ? "in reach" : "OUT OF REACH"))
            return reach
        case "map":
            // map: open the pack's campaign map; map N: pick mission N (1-based) on it
            if w.count > 1 { model.campaignSelection = Int(num(1)) - 1 } else { model.openCampaign() }
            layoutChrome(); frames(2)
        case "mission":
            // mission N: fight campaign mission N (1-based), straight into the battle
            model.startMission(Int(num(1)) - 1)
            model.startBattle()
            layoutChrome()
            advance(1500)
            print("  \(scene.debugState)")
        case "reward":
            // reward N: pick the Nth offered reward
            let cs = model.campaignState
            if let p = cs.pending, let offer = cs.offers[p], Int(num(1)) - 1 < offer.count { model.pickReward(offer[Int(num(1)) - 1]); print("  picked \(offer[Int(num(1)) - 1])") }
            else { print("  no reward waiting"); return false }
        case "campaign":
            let cs = model.campaignState
            print("  campaign: done \(cs.done) perks \(cs.perks) pending \(cs.pending ?? "-") offers \(cs.offers)")
        case "erase":
            model.eraseCampaign(); model.eraseCampaign()
        case "tap": scene.special(); frames(1)
        case "look":
            // press "See fort" / "Back to launcher", or `look state` to print the camera
            if !w.contains("state") { model.toggleLook(); frames(90) }
            print(String(format: "  camera x %.0f of %.0f, world %.0f wide", scene.camX, scene.camMax, scene.worldW))
        case "drag": drag(num(1), num(2), num(3), num(4), release: !w.contains("hold"))
        case "release": scene.pointerUp(scenePoint(lastPointer.x, lastPointer.y)); frame()
        case "wait": advance(num(1))
        case "settle": settle()
        case "nodes":
            // look for broken transforms that would stop SpriteKit drawing the frame
            var count = 0, bad: [String] = []
            func visit(_ n: SKNode) {
                count += 1
                let p = n.position
                var broken = !p.x.isFinite || !p.y.isFinite || !n.zRotation.isFinite || !n.xScale.isFinite
                if let sp = n as? SKSpriteNode, !sp.size.width.isFinite || !sp.size.height.isFinite { broken = true }
                if broken { bad.append("\(type(of: n)) \(n.name ?? "") pos \(p) size \((n as? SKSpriteNode)?.size ?? .zero) rot \(n.zRotation) hidden \(n.isHidden)") }
                n.children.forEach(visit)
            }
            visit(scene)
            print("  \(count) nodes, cam \(scene.cam.position) scale \(scene.cam.xScale)")
            bad.prefix(10).forEach { print("    BAD \($0)") }
        case "report":
            print("  \(scene.debugState)")
            for line in scene.debugReport(all: w.count > 1) { print("    \(line)") }
        case "shot": snapshot(w.count > 1 ? w[1] : "shot", ui: !w.contains("noui"))
        case "result":
            RunLoop.main.run(until: Date().addingTimeInterval(1.2))
            layoutChrome()
            frames(2)
        case "expect":
            let won = scene.mode == .result && model.result.won
            let lost = scene.mode == .result && !model.result.won
            let pass = (w[1] == "win" && won) || (w[1] == "lose" && lost)
            print(pass ? "  PASS: \(w[1]) (score \(model.result.score), \(model.result.stars) stars)" : "  FAIL: expected \(w[1]), \(scene.debugState)")
            return pass
        default:
            print("  unknown command")
            return false
        }
        return true
    }

    // MARK: time

    func frame() {
        t += 1.0 / 60
        renderer.update(atTime: base + t)
    }

    func frames(_ n: Int) { for _ in 0..<n { frame() } }

    func advance(_ ms: Double) { frames(Int((ms / K.step).rounded())) }

    /// Runs until the turn is over and the player can go again (or the battle ended).
    func settle(maxMs: Double = 40000) {
        var n = 0.0
        while n < maxMs && !(scene.phase == .ready || scene.mode == .result) { frame(); n += K.step }
        print("  \(scene.debugState)  (+\(Int(n)) ms)")
    }

    /// Same flight math as the aiming dots (gravity, lift, air friction), plus today's wind for
    /// shells that feel it. No collisions.
    func solveAngle(_ key: String, _ tx: Double, _ ty: Double, power: Double, high: Bool) -> Double? {
        guard let u = scene.pack.units[key] else { return nil }
        let sling = u.kind == "sling"
        let x0 = sling ? K.sling.x : K.bunker.x, y0 = sling ? K.sling.y : K.bunker.y
        let k = sling ? 1 : (u.speed ?? 1), lift = sling ? 0 : (u.lift ?? 0)
        let push = u.wind == true ? K.grav * scene.wind * 0.06 : 0
        var best: (a: Double, d: Double)?
        for tenth in stride(from: high ? 890 : 50, through: high ? 450 : 450, by: high ? -1 : 1) {
            let a = Double(tenth) / 10, r = a * .pi / 180
            var px = x0 * K.PH, py = y0 * K.PH
            var vx = cos(r) * scene.topSpeed * power * k, vy = -sin(r) * scene.topSpeed * power * k
            var d = Double.infinity
            for _ in 0..<600 {
                vy += K.grav * scene.gravK * (1 - lift); vx += push; vx *= 0.998; vy *= 0.998; px += vx; py += vy
                d = min(d, hypot(px / K.PH - tx, py / K.PH - ty))
                if py / K.PH > K.ground + 10 { break }
            }
            if best == nil || d < best!.d { best = (a, d) }
        }
        guard let b = best, b.d < 4 else { return nil }
        return b.a
    }

    // MARK: input

    /// Screen points (top-left origin) → scene coordinates, through the camera.
    func scenePoint(_ x: Double, _ y: Double) -> CGPoint {
        let k = Double(scene.cam.xScale), c = scene.cam.position
        return CGPoint(x: Double(c.x) + (x - Headless.phone.width / 2) * k, y: Double(c.y) - (y - Headless.phone.height / 2) * k)
    }

    var lastPointer = (x: 0.0, y: 0.0)

    func drag(_ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double, release: Bool = true) {
        lastPointer = (x1, y1)
        scene.pointerDown(scenePoint(x0, y0))
        frame()
        for i in 1...10 {
            let f = Double(i) / 10
            scene.pointerMoved(scenePoint(x0 + (x1 - x0) * f, y0 + (y1 - y0) * f))
            frame()
        }
        if release {
            scene.pointerUp(scenePoint(x1, y1))
            frame()
        }
    }

    // MARK: screenshots

    /// Lays out the SwiftUI screens once so the HUD and dock report their real heights.
    func layoutChrome() {
        _ = chromeImage(scale: 1)
        frames(1)
    }

    func chromeImage(scale: CGFloat) -> CGImage? {
        let view = RootView(model: model, showsScene: false, simulatedSafeArea: Headless.phoneSafeArea)
            .frame(width: Headless.phone.width, height: Headless.phone.height)
            .environment(\.colorScheme, .dark)
            .environment(\.snapshotMode, true)
        let r = ImageRenderer(content: view)
        r.scale = scale
        return r.cgImage
    }

    /// Renders the scene offscreen. The viewport must stay the phone's size times `scale`:
    /// the scene resizes itself to fit whatever it is drawn into (.resizeFill).
    func sceneImage(scale: CGFloat) -> CGImage? {
        let W = Int(Headless.phone.width * scale), H = Int(Headless.phone.height * scale)
        let td = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm, width: W, height: H, mipmapped: false)
        td.usage = [.renderTarget, .shaderRead]
        td.storageMode = .managed
        guard let tex = device.makeTexture(descriptor: td), let cb = queue.makeCommandBuffer() else { return nil }
        let rp = MTLRenderPassDescriptor()
        rp.colorAttachments[0].texture = tex
        rp.colorAttachments[0].loadAction = .clear
        rp.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        rp.colorAttachments[0].storeAction = .store
        renderer.render(withViewport: CGRect(x: 0, y: 0, width: W, height: H), commandBuffer: cb, renderPassDescriptor: rp)
        if let blit = cb.makeBlitCommandEncoder() { blit.synchronize(resource: tex); blit.endEncoding() }
        cb.commit()
        cb.waitUntilCompleted()
        var bytes = [UInt8](repeating: 0, count: W * H * 4)
        tex.getBytes(&bytes, bytesPerRow: W * 4, from: MTLRegionMake2D(0, 0, W, H), mipmapLevel: 0)
        let info = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        guard let provider = CGDataProvider(data: Data(bytes) as CFData) else { return nil }
        return CGImage(width: W, height: H, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: W * 4,
                       space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: info, provider: provider,
                       decode: nil, shouldInterpolate: false, intent: .defaultIntent)
    }

    func snapshot(_ name: String, ui showUI: Bool = true) {
        let scale: CGFloat = 2
        guard let world = sceneImage(scale: scale) else { print("  scene render failed"); return }
        let ui = showUI ? chromeImage(scale: scale) : nil
        let W = world.width, H = world.height
        guard let ctx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: 0,
                                  space: CGColorSpace(name: CGColorSpace.sRGB)!,
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return }
        ctx.draw(world, in: CGRect(x: 0, y: 0, width: W, height: H))
        if let ui { ctx.draw(ui, in: CGRect(x: 0, y: 0, width: W, height: H)) }
        guard let img = ctx.makeImage() else { return }
        let url = out.appendingPathComponent(name + ".png")
        Headless.writePNG(img, to: url)
        print("  saved \(url.path)")
    }

    static func writePNG(_ img: CGImage, to url: URL) {
        guard let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else { return }
        CGImageDestinationAddImage(dest, img, nil)
        CGImageDestinationFinalize(dest)
    }

    // MARK: app icon

    /// A 1024 × 1024 app icon: a GI in front of a Normandy sky, from the game's own sprites.
    static func makeIcon(_ url: URL) {
        var c = PixelCanvas(width: 32, height: 32)
        let sky = ["#6fbff5", "#94d2fa", "#bfe6fd"]
        for (i, col) in sky.enumerated() { c.fill(0, i * 8, 32, 9, RGBA(col)) }
        Background.disc(&c, 25, 6, 3, RGBA("#ffe25a"))
        c.fill(0, 24, 32, 8, RGBA("#d6b878"))
        c.fill(0, 24, 32, 2, RGBA("#e3c98e"))
        c.fill(0, 24, 32, 1, RGBA("#f1dfb0"))
        let guy = SpriteSheet.shared.canvas("rifleman")
        c.draw(guy, (32 - guy.width) / 2, 25 - guy.height)
        let small = c.makeImage()
        guard let ctx = CGContext(data: nil, width: 1024, height: 1024, bitsPerComponent: 8, bytesPerRow: 0,
                                  space: CGColorSpace(name: CGColorSpace.sRGB)!,
                                  bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else { return }
        ctx.interpolationQuality = .none
        ctx.draw(small, in: CGRect(x: 0, y: 0, width: 1024, height: 1024))
        if let img = ctx.makeImage() { writePNG(img, to: url) }
        print("saved \(url.path)")
    }
}
