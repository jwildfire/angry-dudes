import SwiftUI
import SpriteKit

/// The whole game screen: the live battlefield underneath, the HUD and arsenal bar during a
/// battle, and the menu, mission briefing or battle report on top.
struct RootView: View {
    @ObservedObject var model: GameModel
    /// Off only for snapshot tests, which render the scene separately.
    var showsScene = true
    /// Snapshot tests set this to stand in for a phone's notch and home indicator.
    var simulatedSafeArea: EdgeInsets?
    @State private var measuredSafeArea = EdgeInsets()

    var body: some View {
        let safe = simulatedSafeArea ?? measuredSafeArea
        ZStack {
            if showsScene {
                SpriteView(scene: model.scene, preferredFramesPerSecond: 60, options: [.ignoresSiblingOrder])
                    .ignoresSafeArea()
            }
            if model.screen == .play {
                BattleChrome(model: model, safe: safe)
            }
            switch model.screen {
            case .menu:
                Overlay(scrolls: false) { MenuView(model: model) }
            case .campaign:
                Overlay(maxWidth: 1000, scrolls: false) { CampaignView(model: model) }
            case .intro:
                Overlay(scrolls: false) { IntroView(model: model) }
            case .result:
                Overlay(maxWidth: 560) { ResultView(model: model) }
            case .play:
                EmptyView()
            }
        }
        .background(
            GeometryReader { g in
                Color.clear
                    .onAppear { safeAreaChanged(g.safeAreaInsets) }
                    .onChange(of: g.safeAreaInsets) { safeAreaChanged($0) }
            }
        )
        .foregroundColor(Theme.fg)
    }

    private func safeAreaChanged(_ insets: EdgeInsets) {
        guard simulatedSafeArea == nil else { return }
        measuredSafeArea = insets
        model.setSafeArea(insets)
    }
}

/// Dims the battlefield and centers a scrollable panel.
struct Overlay<Content: View>: View {
    var maxWidth: CGFloat = 780
    /// false when the content scrolls a part of itself (the briefing keeps its buttons in view)
    var scrolls = true
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            Theme.dim.ignoresSafeArea()
            if scrolls {
                // scroll only when the panel doesn't fit (small phones)
                ViewThatFits(in: .vertical) {
                    panel
                    AutoScroll { panel }
                }
            } else {
                panel
            }
        }
    }

    private var panel: some View {
        PixelPanel { content }
            .frame(maxWidth: maxWidth)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
    }
}

private struct HUDHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = max(value, nextValue()) }
}

private struct DockHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = max(value, nextValue()) }
}

/// The HUD strip on top and the arsenal dock at the bottom. The gap between them lets touches
/// through to the battlefield.
struct BattleChrome: View {
    @ObservedObject var model: GameModel
    let safe: EdgeInsets

    var body: some View {
        VStack(spacing: 0) {
            HUDBar(model: model, safe: safe)
                .background(GeometryReader { Color.clear.preference(key: HUDHeightKey.self, value: $0.size.height) })
            Spacer(minLength: 0)
            Dock(model: model, safe: safe)
                .background(GeometryReader { Color.clear.preference(key: DockHeightKey.self, value: $0.size.height) })
        }
        .ignoresSafeArea()
        .onPreferenceChange(HUDHeightKey.self) { model.setChrome(hud: Double($0)) }
        .onPreferenceChange(DockHeightKey.self) { model.setChrome(dock: Double($0)) }
    }
}

struct HUDBar: View {
    @ObservedObject var model: GameModel
    let safe: EdgeInsets

    var body: some View {
        let hud = model.hud
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 0) {
                Text(model.level.name).font(Theme.label(16)).lineLimit(1)
                Text(model.level.date).font(Theme.body(10)).foregroundColor(Theme.muted).lineLimit(1)
            }
            stat("Score") {
                Text(fmt(hud.score)).font(.system(size: 14, weight: .bold, design: .monospaced)).foregroundColor(Theme.gold)
            }
            stat("Wind") {
                Text(windText(hud.wind)).font(Theme.label(14))
            }
            Text("\(hud.defenders) \(hud.defenders == 1 ? "defender" : "defenders") left")
                .font(Theme.label(13))
                .lineLimit(1)
            Spacer(minLength: 0)
            if hud.canLook {
                Button(hud.lookingAtFort ? "Back to launcher" : "See fort") { model.toggleLook() }.buttonStyle(SmallButtonStyle())
            }
            Button("Restart") { model.restart() }.buttonStyle(SmallButtonStyle())
            Button(model.inCampaign ? "Map" : "Menu") { model.leaveBattle() }.buttonStyle(SmallButtonStyle())
        }
        .padding(.leading, max(12, safe.leading))
        .padding(.trailing, max(12, safe.trailing))
        .padding(.top, max(5, safe.top))
        .padding(.bottom, 5)
        .background(LinearGradient(colors: [Theme.ink.opacity(0.82), Theme.ink.opacity(0.55)], startPoint: .top, endPoint: .bottom))
        .overlay(Rectangle().fill(Theme.edge).frame(height: 2), alignment: .bottom)
    }

    private func stat<V: View>(_ label: String, @ViewBuilder value: () -> V) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 5) {
            Text(label.uppercased()).font(Theme.label(10)).tracking(0.8).foregroundColor(Theme.muted)
            value()
        }
    }

    private func windText(_ w: Double) -> String {
        if w == 0 { return "Calm" }
        let n = Int(abs(w))
        return w < 0 ? "← \(n)" : "\(n) →"
    }
}

struct Dock: View {
    @ObservedObject var model: GameModel
    let safe: EdgeInsets

    var body: some View {
        let hud = model.hud
        VStack(spacing: 0) {
            Text(hud.hint.isEmpty ? " " : hud.hint)
                .font(Theme.label(13))
                .foregroundColor(Theme.gold)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, max(12, safe.leading))
                .padding(.trailing, max(12, safe.trailing))
                .padding(.vertical, 4)
                .background(Theme.ink)
                .overlay(Rectangle().fill(Theme.edge).frame(height: 2), alignment: .bottom)
            // scroll sideways only when the arsenal doesn't fit
            ViewThatFits(in: .horizontal) {
                bar(hud).frame(maxWidth: .infinity, alignment: .leading)
                AutoScroll(axis: .horizontal) { bar(hud) }
            }
        }
        .padding(.bottom, max(4, safe.bottom - 8))
        .background(Theme.panel)
        .overlay(Rectangle().fill(Theme.edge).frame(height: 3), alignment: .top)
    }

    private func bar(_ hud: HUDState) -> some View {
        HStack(spacing: 6) {
            ForEach(model.pack.order.filter { hud.arsenal[$0] != nil }, id: \.self) { key in
                if let u = model.pack.units[key] {
                    ArsenalButton(unit: u, count: hud.arsenal[key] ?? 0, selected: key == hud.selected) {
                        model.select(key)
                    }
                }
            }
        }
        .padding(.leading, max(12, safe.leading))
        .padding(.trailing, max(12, safe.trailing))
        .padding(.top, 6)
        .padding(.bottom, 8)
    }
}

struct ArsenalButton: View {
    let unit: UnitSpec
    let count: Int
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 1) {
                SpriteIcon(name: unit.iconSprite, box: CGSize(width: 42, height: 26))
                    .frame(height: 26)
                Text(unit.displayName)
                    .font(Theme.label(11))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text("×\(count)")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(Theme.gold)
            }
            .foregroundColor(Theme.fg)
            .frame(width: 70)
            .padding(.vertical, 4)
            .pixelBox(selected ? Theme.raised : Theme.panel2, edge: 2, shadow: 3, selected: selected)
            .opacity(count > 0 ? 1 : 0.35)
        }
        .buttonStyle(.plain)
        .disabled(count == 0)
        .accessibilityLabel("\(unit.displayName), \(count) left")
    }
}
