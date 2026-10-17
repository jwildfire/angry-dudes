import SwiftUI

/// The prototype's dark "war room" look: olive-black panels with hard black edges and drop
/// shadows, gold highlights, pixel art drawn crisp at whole-number scales.
enum Theme {
    static let ink = Color(hex: "#0c0f0a")
    static let panel = Color(hex: "#1b2116")
    static let panel2 = Color(hex: "#252d1d")
    static let raised = Color(hex: "#3a4526")
    static let edge = Color.black
    static let fg = Color(hex: "#f1f2e8")
    static let muted = Color(hex: "#aab197")
    static let gold = Color(hex: "#ffd23f")
    static let red = Color(hex: "#e0412c")
    static let dim = Color(hex: "#080a06").opacity(0.72)

    static func label(_ size: CGFloat) -> Font { .system(size: size, weight: .bold, design: .rounded) }
    static func body(_ size: CGFloat) -> Font { .system(size: size, weight: .regular, design: .default) }
}

extension Color {
    init(hex: String) {
        let c = RGBA(hex)
        self.init(.sRGB, red: Double(c.r) / 255, green: Double(c.g) / 255, blue: Double(c.b) / 255, opacity: 1)
    }
}

/// A sprite from sprites.json at the largest whole-number scale that fits the box.
struct SpriteIcon: View {
    let name: String
    var box = CGSize(width: 46, height: 30)

    var body: some View {
        let s = SpriteSheet.shared.size(name)
        let fit = min(box.width / s.width, box.height / s.height)
        let k = fit >= 1 ? fit.rounded(.down) : fit     // whole-number zoom, or shrink to fit
        Image(decorative: SpriteSheet.shared.image(name), scale: 1)
            .interpolation(.none)
            .resizable()
            .frame(width: s.width * k, height: s.height * k)
    }
}

/// Text in the bitmap pixel font, scaled up crisply.
struct PixelText: View {
    let text: String
    var color = "#ffffff"
    var scale: CGFloat = 2
    var shadow = 1
    var outline: String? = K.outline

    init(_ text: String, color: String = "#ffffff", scale: CGFloat = 2, shadow: Int = 1, outline: String? = K.outline) {
        self.text = text
        self.color = color
        self.scale = scale
        self.shadow = shadow
        self.outline = outline
    }

    var body: some View {
        let img = PixelFont.image(text, color: color, outline: outline, shadow: shadow)
        Image(img, scale: 1, label: Text(text))
            .interpolation(.none)
            .resizable()
            .frame(width: CGFloat(img.width) * scale, height: CGFloat(img.height) * scale)
    }
}

struct Stars: View {
    let count: Int
    var size: CGFloat = 18

    var body: some View {
        HStack(spacing: size / 4) {
            ForEach(0..<3, id: \.self) { i in
                Image(decorative: PixelFont.star(on: i < count), scale: 1)
                    .interpolation(.none)
                    .resizable()
                    .frame(width: size, height: size)
            }
        }
        .accessibilityElement()
        .accessibilityLabel("\(count) of 3 stars")
    }
}

/// A panel with a thick black edge and a hard drop shadow.
struct PixelPanel<Content: View>: View {
    var padding: CGFloat = 18
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .background(Theme.panel)
            .overlay(Rectangle().strokeBorder(Theme.edge, lineWidth: 4))
            .background(Theme.edge.offset(x: 8, y: 8))
    }
}

/// Raised pixel box: fill, black edge, hard shadow. Used for buttons and list rows.
struct PixelBox: ViewModifier {
    var fill: Color
    var edge: CGFloat = 3
    var shadow: CGFloat = 4
    var selected = false

    func body(content: Content) -> some View {
        content
            .background(fill)
            .overlay(Rectangle().strokeBorder(Theme.edge, lineWidth: edge))
            .overlay(Rectangle().strokeBorder(selected ? Theme.gold : .clear, lineWidth: 3).padding(edge - 1))
            .background(Theme.edge.offset(x: shadow, y: shadow))
    }
}

extension View {
    func pixelBox(_ fill: Color, edge: CGFloat = 3, shadow: CGFloat = 4, selected: Bool = false) -> some View {
        modifier(PixelBox(fill: fill, edge: edge, shadow: shadow, selected: selected))
    }
}

/// Big buttons: gold for the main action, dark for the others. They press down into their shadow.
struct BigButtonStyle: ButtonStyle {
    var primary = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .background(primary ? Theme.gold : Theme.panel2)
            .overlay(Rectangle().strokeBorder(Theme.edge, lineWidth: 3))
            .offset(x: configuration.isPressed ? 3 : 0, y: configuration.isPressed ? 3 : 0)
            .background(Theme.edge.offset(x: 4, y: 4))
    }
}

struct BigButton: View {
    let title: String
    var primary = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            PixelText(title.uppercased(), color: primary ? "#1d1a2b" : "#f1f2e8", scale: 2, shadow: 0, outline: primary ? nil : K.outline)
        }
        .buttonStyle(BigButtonStyle(primary: primary))
    }
}

/// Small HUD buttons.
struct SmallButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.label(13))
            .foregroundColor(Theme.fg)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Theme.panel2)
            .overlay(Rectangle().strokeBorder(Theme.edge, lineWidth: 2))
            .offset(x: configuration.isPressed ? 2 : 0, y: configuration.isPressed ? 2 : 0)
            .background(Theme.edge.offset(x: 2, y: 2))
    }
}

struct Eyebrow: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text.uppercased())
            .font(Theme.label(11))
            .tracking(1.2)
            .foregroundColor(Theme.muted)
    }
}

/// Lays chips out in rows, wrapping when a row is full.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowH: CGFloat = 0, maxX: CGFloat = 0
        for v in subviews {
            let s = v.sizeThatFits(.unspecified)
            if x > 0 && x + s.width > width { x = 0; y += rowH + spacing; rowH = 0 }
            x += s.width + spacing
            rowH = max(rowH, s.height)
            maxX = max(maxX, x - spacing)
        }
        return CGSize(width: min(maxX, width), height: y + rowH)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowH: CGFloat = 0
        for v in subviews {
            let s = v.sizeThatFits(.unspecified)
            if x > bounds.minX && x + s.width > bounds.maxX { x = bounds.minX; y += rowH + spacing; rowH = 0 }
            v.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(s))
            x += s.width + spacing
            rowH = max(rowH, s.height)
        }
    }
}

private struct SnapshotModeKey: EnvironmentKey { static let defaultValue = false }

extension EnvironmentValues {
    /// Set by the Mac preview's offscreen snapshots, which can't draw scroll views.
    var snapshotMode: Bool {
        get { self[SnapshotModeKey.self] }
        set { self[SnapshotModeKey.self] = newValue }
    }
}

/// A scroll view, except in snapshot tests, where it shows its content clipped at the start:
/// exactly what the screen shows before anyone scrolls.
struct AutoScroll<Content: View>: View {
    var axis: Axis.Set = .vertical
    @ViewBuilder var content: Content
    @Environment(\.snapshotMode) private var snapshot

    var body: some View {
        if snapshot {
            if axis == .horizontal {
                content.fixedSize(horizontal: true, vertical: false)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading).clipped()
            } else {
                content.fixedSize(horizontal: false, vertical: true)
                    .frame(minHeight: 0, maxHeight: .infinity, alignment: .top).clipped()
            }
        } else {
            ScrollView(axis, showsIndicators: false) { content }
        }
    }
}
