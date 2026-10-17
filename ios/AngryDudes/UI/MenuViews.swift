import SwiftUI

/// Pick a war, then a battle. Laid out in two columns for a phone held sideways: the packs on
/// the left, the chosen pack's campaign and battles on the right. Both lists scroll.
struct MenuView: View {
    @ObservedObject var model: GameModel

    var body: some View {
        HStack(alignment: .top, spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Eyebrow("Pick a war, then a battle")
                HStack(spacing: 10) {
                    PixelText("ANGRY", color: "#e2533e", scale: 4, shadow: 2)
                    PixelText("DUDES", color: "#4a86e8", scale: 4, shadow: 2)
                }
                .accessibilityElement()
                .accessibilityLabel("Angry Dudes")
                AutoScroll {
                    VStack(spacing: 7) {
                        ForEach(model.packs.indices, id: \.self) { i in
                            PackButton(pack: model.packs[i], selected: i == model.packIndex) { model.choosePack(i) }
                        }
                    }
                    .padding(.trailing, 4)
                    .padding(.bottom, 6)
                }
            }
            .frame(width: 240)

            VStack(alignment: .leading, spacing: 8) {
                Text("\(model.pack.side) vs. \(model.pack.foe). \(model.pack.blurb)")
                    .font(Theme.body(13))
                    .fixedSize(horizontal: false, vertical: true)
                AutoScroll {
                    VStack(alignment: .leading, spacing: 10) {
                        if let C = model.pack.campaign {
                            CampaignBanner(pack: model.pack, spec: C, state: model.campaignState) { model.openCampaign() }
                        }
                        ForEach(model.pack.levels.indices, id: \.self) { i in
                            LevelRow(number: i + 1, level: model.pack.levels[i],
                                     best: Store.best(pack: model.pack.id, level: model.pack.levels[i].id)) {
                                model.openIntro(i)
                            }
                        }
                        Text("**How to play:** pick something from your arsenal at the bottom of the screen. Drag back and let go to launch troops and weapons. Tap once to send a vehicle. For planes, tap the spot you want bombed. Tap again while it's moving for its special move.")
                            .font(Theme.body(12))
                            .foregroundColor(Theme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 4)
                    }
                    .padding(.trailing, 6)
                    .padding(.bottom, 8)
                }
                .id(model.bestsVersion)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

struct PackButton: View {
    let pack: PackSpec
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                SpriteIcon(name: pack.icon, box: CGSize(width: 34, height: 26))
                    .frame(width: 34, height: 26)
                VStack(alignment: .leading, spacing: 0) {
                    Text(pack.name).font(Theme.label(13)).lineLimit(1).minimumScaleFactor(0.75)
                    Text(pack.years).font(Theme.body(10)).foregroundColor(Theme.muted)
                }
                Spacer(minLength: 0)
            }
            .foregroundColor(Theme.fg)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity)
            .pixelBox(selected ? Theme.raised : Theme.panel2, shadow: 3, selected: selected)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

/// The way into a pack's campaign, above its battles.
struct CampaignBanner: View {
    let pack: PackSpec
    let spec: CampaignSpec
    let state: CampaignState
    let action: () -> Void

    var body: some View {
        let done = spec.complete(state)
        Button(action: action) {
            HStack(spacing: 12) {
                SpriteIcon(name: done ? "officer" : pack.icon, box: CGSize(width: 48, height: 34))
                    .frame(width: 48, height: 34)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Campaign: \(spec.name)").font(Theme.label(16)).foregroundColor(Theme.gold).lineLimit(1).minimumScaleFactor(0.8)
                    Text((done ? "Complete! " : "\(state.done.count) of \(spec.missions.count) missions won · ") + "Rank: \(spec.rank(state))")
                        .font(Theme.body(12))
                }
                Spacer(minLength: 4)
                PixelText(state.done.isEmpty ? "START" : "CONTINUE", color: "#1d1a2b", scale: 1.5, shadow: 0, outline: nil)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 7)
                    .background(Theme.gold)
                    .overlay(Rectangle().strokeBorder(Theme.edge, lineWidth: 2))
            }
            .foregroundColor(Theme.fg)
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .pixelBox(Color(hex: "#2f3a22"))
        }
        .buttonStyle(.plain)
    }
}

struct LevelRow: View {
    let number: Int
    let level: LevelSpec
    let best: Store.Best
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                PixelText("\(number)", color: "#ffd23f", scale: 2, shadow: 0)
                    .frame(width: 36, height: 36)
                    .background(Theme.ink)
                    .overlay(Rectangle().strokeBorder(Theme.edge, lineWidth: 2))
                VStack(alignment: .leading, spacing: 1) {
                    Text(level.name).font(Theme.label(16)).lineLimit(1).minimumScaleFactor(0.8)
                    Text(level.date).font(Theme.body(11)).foregroundColor(Theme.muted)
                }
                Spacer(minLength: 4)
                VStack(alignment: .trailing, spacing: 3) {
                    Stars(count: best.stars, size: 16)
                    Text(best.score > 0 ? "Best \(fmt(best.score))" : "Not played yet")
                        .font(Theme.body(10))
                        .foregroundColor(Theme.muted)
                }
            }
            .foregroundColor(Theme.fg)
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .pixelBox(Theme.panel2)
        }
        .buttonStyle(.plain)
    }
}

/// The mission briefing: a short piece of real history, the goal, a tip, and what's on each side.
struct IntroView: View {
    @ObservedObject var model: GameModel

    private var eyebrow: String {
        let pack = model.pack
        if let C = pack.campaign, let i = model.campaignIndex { return "\(C.name) · Mission \(i + 1) of \(C.missions.count)" }
        return "\(pack.name) · \(pack.side) vs. \(pack.foe)"
    }

    private var goal: String {
        let tough = model.scene.campaignToughness
        return "Knock out all \(model.scene.defendersLeft()) defenders." + (tough > 1 ? " They're \(Int(jsRound((tough - 1) * 100)))% tougher now!" : "")
    }

    private var tip: String {
        let level = model.level
        if let k = model.scene.extraTroop, let u = model.pack.units[k] {
            return "Bonus for trying hard: one extra \(u.displayName)! \(level.tip)"
        }
        return level.tip
    }

    var body: some View {
        let level = model.level
        VStack(alignment: .leading, spacing: 10) {
            Eyebrow(eyebrow)
            HStack(alignment: .lastTextBaseline, spacing: 12) {
                PixelText(level.name.uppercased(), scale: 3, shadow: 1)
                Text(level.date).font(Theme.body(13)).foregroundColor(Theme.muted)
            }
            // the middle scrolls on its own when a big battle doesn't fit, so Start stays in view
            ViewThatFits(in: .vertical) {
                details
                AutoScroll { details }
            }
            HStack(spacing: 14) {
                BigButton(title: "Start battle") { model.startBattle() }
                BigButton(title: "Back", primary: false) { model.leaveBattle() }
            }
            .padding(.top, 4)
        }
    }

    private var details: some View {
        let pack = model.pack, level = model.level
        let foes = model.fortDefenders
        return HStack(alignment: .top, spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("REAL HISTORY").font(Theme.label(10)).tracking(1.2).foregroundColor(Theme.gold)
                    Text(level.history).font(Theme.body(13)).fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.ink)
                .overlay(Rectangle().fill(Theme.gold).frame(width: 4), alignment: .leading)
                Text(tip).font(Theme.body(13)).foregroundColor(Theme.muted).fixedSize(horizontal: false, vertical: true)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text(goal).font(Theme.label(16)).fixedSize(horizontal: false, vertical: true)
                Text("Win with 2 left in your arsenal for ★★★.").font(Theme.body(12)).foregroundColor(Theme.muted)
                Eyebrow("Your arsenal")
                FlowLayout(spacing: 6) {
                    ForEach(pack.order.filter { (model.scene.arsenal[$0] ?? 0) > 0 }, id: \.self) { k in
                        if let u = pack.units[k] { Chip(sprite: u.iconSprite, text: "\(u.displayName) ×\(model.scene.arsenal[k] ?? 0)", fill: Theme.panel2) }
                    }
                }
                Eyebrow("Defenders")
                FlowLayout(spacing: 6) {
                    ForEach(foes, id: \.key) { d in Chip(sprite: d.sprite, text: d.name, fill: Color(hex: "#2a2020")) }
                }
            }
        }
    }
}

struct Chip: View {
    let sprite: String
    let text: String
    let fill: Color

    var body: some View {
        HStack(spacing: 6) {
            SpriteIcon(name: sprite, box: CGSize(width: 32, height: 20))
                .frame(height: 20)
            Text(text).font(Theme.label(12)).lineLimit(1)
        }
        .padding(.leading, 5)
        .padding(.trailing, 9)
        .padding(.vertical, 3)
        .background(fill)
        .overlay(Rectangle().strokeBorder(Theme.edge, lineWidth: 2))
    }
}

/// Victory or defeat, the stars, the score and what to do next. In a campaign, a first win
/// also offers three rewards for the army, and the way on is back to the map.
struct ResultView: View {
    @ObservedObject var model: GameModel

    var body: some View {
        let r = model.result
        let C = model.campaignSpec, cs = model.campaignState
        let campaign = model.inCampaign && C != nil
        let finished = campaign && r.won && C!.complete(cs) && model.campaignIndex == C!.missions.count - 1
        let levelId = model.level.id
        let offer = r.won && campaign ? (cs.offers[levelId] ?? []) : []
        let choosing = r.rewardLevel == levelId && !offer.isEmpty
        VStack(alignment: .leading, spacing: 8) {
            Eyebrow("Battle report")
            PixelText(finished ? "CAMPAIGN COMPLETE!" : r.won ? "VICTORY!" : "THE FORT HOLDS", color: r.won ? "#ffd23f" : "#f1f2e8", scale: 4, shadow: 2)
            if r.won { Stars(count: r.stars, size: choosing ? 26 : 40) }
            PixelText(fmt(r.score), color: "#ffd23f", scale: 3, shadow: 1)
            Text(finished ? "You fought all the way from the beaches to the Rhine. You've been promoted to \(C!.rank(cs))!" : note(r))
                .font(Theme.body(13)).foregroundColor(Theme.muted).fixedSize(horizontal: false, vertical: true)
            if choosing {
                Text("PICK A REWARD FOR YOUR ARMY").font(Theme.label(11)).tracking(1.2).foregroundColor(Theme.gold)
                RewardCards(model: model, spec: C!, offer: offer, chosen: offer.first { cs.perks.contains($0) })
            }
            HStack(spacing: 14) {
                if campaign {
                    if r.won {
                        BigButton(title: "To the map") { model.next() }
                            .disabled(cs.pending == levelId)
                            .opacity(cs.pending == levelId ? 0.5 : 1)
                        BigButton(title: "Play again", primary: false) { model.restart() }
                    } else {
                        BigButton(title: "Try again") { model.restart() }
                        BigButton(title: "Campaign map", primary: false) { model.leaveBattle() }
                    }
                } else {
                    if r.won && model.hasNextBattle {
                        BigButton(title: "Next battle") { model.next() }
                    }
                    BigButton(title: "Play again", primary: !(r.won && model.hasNextBattle)) { model.restart() }
                    BigButton(title: "Menu", primary: false) { model.toMenu() }
                }
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func note(_ r: ResultInfo) -> String {
        if !r.won { return "You ran out of troops and weapons. Try a different order, or check the tip." }
        return r.left > 0 ? "\(r.left) left in your arsenal: +\(fmt(r.bonus)) bonus" : "You used everything in your arsenal."
    }
}

/// Three rewards to choose from; the one picked stays with the army for the rest of the campaign.
struct RewardCards: View {
    @ObservedObject var model: GameModel
    let spec: CampaignSpec
    let offer: [String]
    let chosen: String?

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            ForEach(offer, id: \.self) { id in
                if let r = spec.reward(id) {
                    Button { model.pickReward(id) } label: {
                        VStack(spacing: 3) {
                            SpriteIcon(name: r.icon, box: CGSize(width: 56, height: 30)).frame(height: 30)
                            Text(r.name).font(Theme.label(12)).lineLimit(1).minimumScaleFactor(0.8)
                            Text(r.text).font(Theme.body(10)).foregroundColor(Theme.muted).multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .foregroundColor(Theme.fg)
                        .padding(7)
                        .frame(width: 150)
                        .pixelBox(chosen == id ? Theme.raised : Theme.panel2, edge: 2, shadow: 3, selected: chosen == id)
                        .opacity(chosen != nil && chosen != id ? 0.45 : 1)
                    }
                    .buttonStyle(.plain)
                    .disabled(chosen != nil)
                }
            }
        }
    }
}
