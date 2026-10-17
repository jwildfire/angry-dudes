import SwiftUI

/// A pack's campaign: the route on a map with a pin per mission, the chosen mission's card
/// (with any reward still waiting to be picked), and the army's rank and upgrades.
struct CampaignView: View {
    @ObservedObject var model: GameModel

    var body: some View {
        if let C = model.campaignSpec {
            let cs = model.campaignState
            let next = C.next(cs)
            let k = min(model.campaignSelection, C.missions.count - 1)
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center, spacing: 10) {
                    VStack(alignment: .leading, spacing: 3) {
                        Eyebrow("\(model.pack.name) campaign")
                        PixelText(C.name.uppercased(), scale: 2.5, shadow: 1)
                    }
                    Spacer(minLength: 0)
                    if !cs.done.isEmpty || !cs.perks.isEmpty {
                        Button(model.eraseArmed ? "Tap again to erase" : "Start over") { model.eraseCampaign() }
                            .buttonStyle(SmallButtonStyle())
                    }
                    Button("Menu") { model.toMenu() }.buttonStyle(SmallButtonStyle())
                }
                HStack(alignment: .top, spacing: 14) {
                    CampaignMapView(spec: C, state: cs, next: next, selection: $model.campaignSelection)
                    AutoScroll {
                        VStack(alignment: .leading, spacing: 12) {
                            missionCard(C, cs, k, next)
                            armyCard(C, cs)
                            Text(C.blurb).font(Theme.body(12)).foregroundColor(Theme.muted).fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.trailing, 5)
                        .padding(.bottom, 6)
                    }
                    .frame(width: 300)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .id(model.bestsVersion)
        }
    }

    private func missionCard(_ C: CampaignSpec, _ cs: CampaignState, _ k: Int, _ next: Int) -> some View {
        let m = C.missions[k]
        let L = model.pack.levelNumber(m.level).map { model.pack.levels[$0] }
        let won = cs.done.contains(m.level), tough = C.tough(k)
        return VStack(alignment: .leading, spacing: 5) {
            Text("MISSION \(k + 1) OF \(C.missions.count)" + (L?.airOnly == true ? " · AIR FORCE" : ""))
                .font(Theme.label(11)).tracking(1.1).foregroundColor(Theme.muted)
            Text(L?.name ?? m.level).font(Theme.label(20)).lineLimit(1).minimumScaleFactor(0.7)
            Text(L?.date ?? "").font(Theme.body(12)).foregroundColor(Theme.muted)
            if won { Stars(count: cs.stars[m.level] ?? 0, size: 16) }
            Group {
                if tough > 1 {
                    Text("Enemy defenders are ") + Text("\(Int(jsRound((tough - 1) * 100)))% tougher").foregroundColor(Color(hex: "#ff8c6a")) + Text(" here.")
                } else {
                    Text("The enemy is at normal strength. A good place to start!")
                }
            }
            .font(Theme.body(13))
            .fixedSize(horizontal: false, vertical: true)
            if let p = cs.pending, let offer = cs.offers[p] {
                Text("PICK A REWARD FOR YOUR ARMY").font(Theme.label(11)).tracking(1.1).foregroundColor(Theme.gold).padding(.top, 2)
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(offer, id: \.self) { id in
                        if let r = C.reward(id) { RewardRow(reward: r) { model.pickReward(id) } }
                    }
                }
            }
            BigButton(title: cs.pending != nil ? "Pick a reward first" : won ? "Play again" : "Fight!") { model.startMission(k) }
                .disabled(cs.pending != nil || k > next)
                .opacity(cs.pending != nil || k > next ? 0.5 : 1)
                .padding(.top, 4)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .pixelBox(Theme.panel2)
    }

    private func armyCard(_ C: CampaignSpec, _ cs: CampaignState) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            (Text("YOUR ARMY · RANK: ").foregroundColor(Theme.muted) + Text(C.rank(cs).uppercased()).foregroundColor(Theme.gold))
                .font(Theme.label(11)).tracking(1.1)
            if cs.perks.isEmpty {
                Text("No upgrades yet. Win a battle to earn one!").font(Theme.body(12)).foregroundColor(Theme.muted)
            }
            ForEach(cs.perks, id: \.self) { id in
                if let r = C.reward(id) {
                    HStack(spacing: 8) {
                        SpriteIcon(name: r.icon, box: CGSize(width: 36, height: 24)).frame(width: 36, height: 24)
                        VStack(alignment: .leading, spacing: 0) {
                            Text(r.name).font(Theme.label(12))
                            Text(r.text).font(Theme.body(10)).foregroundColor(Theme.muted).fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
    }
}

/// One reward offered on the map screen.
struct RewardRow: View {
    let reward: CampaignSpec.Reward
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                SpriteIcon(name: reward.icon, box: CGSize(width: 40, height: 26)).frame(width: 40, height: 26)
                VStack(alignment: .leading, spacing: 0) {
                    Text(reward.name).font(Theme.label(12))
                    Text(reward.text).font(Theme.body(10)).foregroundColor(Theme.muted).fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            .foregroundColor(Theme.fg)
            .padding(6)
            .pixelBox(Theme.panel, edge: 2, shadow: 3)
        }
        .buttonStyle(.plain)
    }
}

/// The pixel map with country and sea labels, cities and a numbered pin per mission.
struct CampaignMapView: View {
    let spec: CampaignSpec
    let state: CampaignState
    let next: Int
    @Binding var selection: Int

    private static var cache: [String: CGImage] = [:]

    private var image: CGImage {
        let key = spec.name + "|" + state.done.joined(separator: ",")
        if let i = Self.cache[key] { return i }
        let i = CampaignMap.paint(spec, state).makeImage()
        Self.cache[key] = i
        return i
    }

    var body: some View {
        let W = Double(CampaignSpec.mapW), H = Double(CampaignSpec.mapH)
        Image(decorative: image, scale: 1)
            .interpolation(.none)
            .resizable()
            .aspectRatio(CGFloat(W / H), contentMode: .fit)
            .overlay(
                GeometryReader { g in
                    let sx = Double(g.size.width) / W, sy = Double(g.size.height) / H
                    ZStack(alignment: .topLeading) {
                        ForEach(Array((spec.map.labels ?? []).enumerated()), id: \.offset) { _, lb in
                            Text(lb.text.uppercased())
                                .font(.system(size: 9, weight: .semibold, design: .rounded))
                                .tracking(1.3)
                                .italic(lb.sea == true)
                                .foregroundColor(lb.sea == true ? Color(hex: "#a9dcff").opacity(0.7) : Theme.fg.opacity(0.7))
                                .fixedSize()
                                .position(x: lb.x * sx, y: lb.y * sy)
                        }
                        ForEach(Array((spec.map.cities ?? []).enumerated()), id: \.offset) { _, ct in
                            Text(ct.name)
                                .font(.system(size: 9, weight: .semibold, design: .rounded))
                                .foregroundColor(Theme.fg)
                                .fixedSize()
                                .frame(width: 70, alignment: .leading)
                                .position(x: ct.x * sx + 6 + 35, y: ct.y * sy)
                        }
                        ForEach(spec.missions.indices, id: \.self) { k in
                            pin(k).position(x: spec.missions[k].x * sx, y: spec.missions[k].y * sy)
                        }
                    }
                }
            )
            .overlay(Rectangle().strokeBorder(Theme.edge, lineWidth: 4))
            .background(Theme.edge.offset(x: 5, y: 5))
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Campaign map")
    }

    private func pin(_ k: Int) -> some View {
        let won = state.done.contains(spec.missions[k].level), locked = k > next
        let fill = won ? Theme.gold : locked ? Color(hex: "#59604d") : k == next ? Color.white : Color(hex: "#cfd3c4")
        return Button { selection = k } label: {
            Text("\(k + 1)")
                .font(.system(size: 11, weight: .heavy, design: .monospaced))
                .foregroundColor(locked ? Color(hex: "#2b3024") : Color(hex: "#1d1a2b"))
                .frame(width: 22, height: 22)
                .background(Circle().fill(fill))
                .overlay(Circle().stroke(Theme.edge, lineWidth: 2.5))
                .overlay(Circle().stroke(k == next && !won ? Theme.gold : .clear, lineWidth: 2).padding(-4))
                .overlay(Circle().stroke(k == selection ? Color.white : .clear, lineWidth: 2).padding(-7))
        }
        .buttonStyle(.plain)
        .disabled(locked)
        .accessibilityLabel("Mission \(k + 1)" + (won ? ", won" : locked ? ", locked" : ", next up"))
    }
}
