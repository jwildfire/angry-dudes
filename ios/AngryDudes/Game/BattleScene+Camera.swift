import SpriteKit

// Wide battlefields scroll, like the prototype: the camera starts on the fort, sweeps back to
// the launcher, follows whatever is flying, and the player can drag to look around or press
// "See fort". camX is how far the view has scrolled right, in logical pixels.
extension BattleScene {
    /// Where world x = 0 sits on screen (OX) and where the camera node goes.
    func placeCamera() {
        OX = camMax > 0 ? (viewLeft - camX).rounded() : (viewLeft + (viewW - worldW) / 2).rounded(.down)
        let W = Double(size.width), H = Double(size.height)
        camBase = CGPoint(x: (W / 2 / scale - OX) * K.PH, y: -(H / 2 / scale - OY) * K.PH)
    }

    func cameraTarget() -> Double {
        if let hold = camHoldX, simT < camHoldUntil { return hold }
        if phase == .active, let active {
            var far = -Double.infinity
            for e in active.group where !e.dead { far = max(far, e.x) }
            if let p = active.plane, planes.contains(where: { $0 === p }) { far = max(far, p.x + p.w / 2) }
            for e in ents where e.bomb && !e.dead { far = max(far, e.x) }
            return far > -.infinity ? far - viewW * 0.55 : camX
        }
        if phase == .settling { return camX }
        return 0
    }

    func updateCamera() {
        guard camMax > 0 else { camX = 0; return }
        if camHoldX != nil && camHoldUntil != .infinity && simT >= camHoldUntil { camHoldX = nil }
        let t = clamp(cameraTarget(), 0, camMax)
        camX += (t - camX) * (introPan ? 0.035 : 0.07)
        if abs(t - camX) < 0.3 {
            camX = t
            if simT >= camHoldUntil { introPan = false }
        }
    }

    var canLook: Bool { mode == .play && camMax > 0 }
    var lookingAtFort: Bool { (camHoldX ?? 0) > camMax / 2 }

    /// The HUD's "See fort" / "Back to launcher" button.
    func lookAtFort(_ on: Bool) {
        guard camMax > 0 else { return }
        camHoldX = on ? camMax : nil
        camHoldUntil = on ? .infinity : 0
    }
}
