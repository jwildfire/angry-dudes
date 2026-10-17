import SpriteKit

/// A pixel particle: sparks, debris, smoke puffs, or a blast flash.
struct Particle {
    enum Style { case dot, smoke, darkSmoke, blast }
    var style: Style
    var x: Double, y: Double
    var vx = 0.0, vy = 0.0
    var life: Double
    var t: Double
    var color = "#ffffff"
    var size = 1.0
    var g = 0.12
    var r = 0.0
}

struct Popup { let text: String; let x: Double; let y: Double; let t: Double; let color: String; var life = 1100.0 }
struct Tracer { let x0: Double, y0: Double, x1: Double, y1: Double, t: Double; var color = "#ffd23f" }

// Score pop-ups, call-outs and particle effects, as in the prototype.
extension BattleScene {
    func addScore(_ n: Double, _ x: Double, _ y: Double) {
        score += n
        say(fmt(Int(n)), x, y, "#ffd23f")
    }

    func say(_ text: String, _ x: Double, _ y: Double, _ color: String, life: Double = 1100) {
        popups.append(Popup(text: text, x: x, y: y, t: simT, color: color, life: life))
    }

    func part(_ x: Double, _ y: Double, _ vx: Double, _ vy: Double, _ life: Double, _ color: String, size: Double = 1, g: Double = 0.12) {
        particles.append(Particle(style: .dot, x: x, y: y, vx: vx, vy: vy, life: life, t: simT, color: color, size: size, g: g))
    }

    func blast(_ x: Double, _ y: Double, _ r: Double, fire: Bool) {
        particles.append(Particle(style: .blast, x: x, y: y, life: 360, t: simT, r: r))
        for _ in 0..<Int(r) {
            let a = rnd() * .pi * 2, s = 0.6 + rnd() * r / 10
            part(x, y, cos(a) * s, sin(a) * s - 1, 400 + rnd() * 400, rnd() < 0.5 ? "#ff8c1a" : "#ffd23f", size: 1, g: 0.06)
        }
        for _ in 0..<6 { smoke(x + (rnd() - 0.5) * r * 0.6, y + (rnd() - 0.5) * r * 0.4) }
        if fire {
            for k in 0..<10 {
                part(x + (rnd() - 0.5) * r, y, (rnd() - 0.5) * 0.4, -0.3 - rnd() * 0.5, 900, k % 2 == 1 ? "#ff6a00" : "#ffd23f", size: 2, g: -0.005)
            }
        }
    }

    func smoke(_ x: Double, _ y: Double) {
        particles.append(Particle(style: .smoke, x: x, y: y, vx: (rnd() - 0.5) * 0.3, vy: -0.25 - rnd() * 0.3,
                                  life: 900 + rnd() * 500, t: simT, size: 2 + rnd() * 3, g: 0))
    }

    func puff(_ x: Double, _ y: Double) {
        particles.append(Particle(style: .darkSmoke, x: x, y: y, vx: 0, vy: -0.05, life: 700, t: simT, size: 4, g: 0))
    }

    func poof(_ x: Double, _ y: Double, _ n: Int) {
        for i in 0..<n {
            let a = rnd() * .pi * 2
            part(x, y, cos(a) * 1.2, sin(a) * 1.2 - 0.5, 500, i % 2 == 1 ? "#ffffff" : "#d8dde4", size: 2, g: 0.02)
        }
    }

    func debris(_ x: Double, _ y: Double, _ colors: [String], _ n: Double) {
        guard !colors.isEmpty else { return }
        for i in 0..<min(40, Int(n.rounded(.up))) {
            let a = rnd() * .pi * 2, s = 0.5 + rnd() * 2.2
            part(x + (rnd() - 0.5) * 8, y + (rnd() - 0.5) * 8, cos(a) * s, sin(a) * s - 1.2, 700 + rnd() * 500,
                 colors[i % colors.count], size: rnd() < 0.3 ? 2 : 1)
        }
    }

    func muzzle(_ x: Double, _ y: Double) {
        particles.append(Particle(style: .blast, x: x, y: y, life: 160, t: simT, r: 7))
    }

    func tracer(_ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double, color: String = "#ffd23f") {
        tracers.append(Tracer(x0: x0, y0: y0, x1: x1, y1: y1, t: simT, color: color))
    }

    func updateParticles() {
        particles.removeAll { simT - $0.t > $0.life }
        for i in particles.indices where particles[i].style != .blast {
            particles[i].x += particles[i].vx
            particles[i].y += particles[i].vy
            particles[i].vy += particles[i].g
            if particles[i].style == .dot {
                let gy = groundAt(particles[i].x)
                if particles[i].y > gy {
                    particles[i].y = gy
                    particles[i].vx *= 0.5
                    particles[i].vy *= -0.3
                }
            }
        }
        popups.removeAll { simT - $0.t >= $0.life }
        tracers.removeAll { simT - $0.t >= 160 }
    }
}
