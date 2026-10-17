import SwiftUI
import SpriteKit

/// What the HUD and arsenal bar show; the scene pushes a fresh copy every frame and SwiftUI
/// only redraws when something changed.
struct HUDState: Equatable {
    var score = 0
    var defenders = 0
    var wind = 0.0
    var hint = ""
    var selected: String?
    var arsenal: [String: Int] = [:]
    var canLook = false         // the battlefield is wider than the screen
    var lookingAtFort = false
}

struct ResultInfo: Equatable {
    var won = false
    var stars = 0
    var score = 0
    var bonus = 0
    var left = 0
    /// The campaign mission whose first win is offering rewards on this report.
    var rewardLevel: String?
}

/// The bridge between the SwiftUI screens and the battlefield scene. It owns the scene,
/// decides which screen is up (menu, mission briefing, battle, battle report) and tells the
/// scene how much of the screen the HUD and arsenal bar cover.
@MainActor
final class GameModel: ObservableObject {
    enum Screen { case menu, intro, play, result, campaign }

    let packs: [PackSpec]
    let scene: BattleScene

    @Published private(set) var screen: Screen = .menu
    @Published private(set) var packIndex: Int
    @Published private(set) var levelIndex = 0
    @Published private(set) var hud = HUDState()
    @Published private(set) var result = ResultInfo()
    /// Bumped when best scores or campaign progress may have changed, so screens re-read them.
    @Published private(set) var bestsVersion = 0
    /// The mission picked on the campaign map.
    @Published var campaignSelection = 0
    /// "Start over" needs a second tap within a few seconds.
    @Published private(set) var eraseArmed = false

    private var hudHeight = 0.0, dockHeight = 0.0
    private var safe = EdgeInsets()

    init(sceneSize: CGSize = CGSize(width: 844, height: 390)) {
        packs = PackSpec.loadAll()
        scene = BattleScene(size: sceneSize, packs: packs)
        let saved = Store.lastPack
        packIndex = packs.firstIndex { $0.id == saved } ?? 0
        scene.model = self
        scene.usePack(packIndex)
        scene.loadLevel(0)
    }

    var pack: PackSpec { packs[packIndex] }
    var level: LevelSpec { pack.levels[levelIndex] }

    // MARK: screens

    func choosePack(_ i: Int) {
        scene.campaign = nil
        packIndex = i
        levelIndex = 0
        Store.lastPack = packs[i].id
        scene.usePack(i)
        scene.loadLevel(0)
        scene.mode = .menu
    }

    func openIntro(_ i: Int) {
        levelIndex = i
        scene.loadLevel(i)
        scene.mode = .intro
        screen = .intro
        updateInsets()
    }

    func startBattle() {
        scene.startBattle()
        screen = .play
        updateInsets()
        sync(from: scene)
    }

    func restart() {
        scene.loadLevel(levelIndex)
        startBattle()
    }

    func toMenu() {
        scene.campaign = nil
        scene.mode = .menu
        screen = .menu
        bestsVersion += 1
        updateInsets()
    }

    /// Menu and Back buttons: back to the campaign map during a campaign, otherwise the menu.
    func leaveBattle() {
        if scene.campaign != nil { openCampaign() } else { toMenu() }
    }

    /// "Next battle" on the battle report (in a campaign, back to the map).
    func next() {
        if scene.campaign != nil { openCampaign() } else { openIntro(levelIndex + 1) }
    }

    func nextBattle() { openIntro(levelIndex + 1) }

    // MARK: campaign

    var campaignSpec: CampaignSpec? { pack.campaign }
    var campaignState: CampaignState { CampaignState.load(pack.id) }
    var inCampaign: Bool { scene.campaign != nil }
    var campaignIndex: Int? { scene.campaign?.index }

    func openCampaign() {
        guard let C = pack.campaign, !C.missions.isEmpty else { return }
        let cs = campaignState
        var sel = scene.campaign?.index ?? min(C.next(cs), C.missions.count - 1)
        // after winning a mission, the map moves on to the next one
        if scene.campaign != nil, cs.done.contains(C.missions[sel].level), sel < C.missions.count - 1, C.next(cs) > sel {
            sel = min(C.next(cs), C.missions.count - 1)
        }
        campaignSelection = sel
        scene.campaign = nil
        scene.mode = .menu
        eraseArmed = false
        screen = .campaign
        bestsVersion += 1
        updateInsets()
    }

    func startMission(_ k: Int) {
        guard let C = pack.campaign, k < C.missions.count, let i = pack.levelNumber(C.missions[k].level) else { return }
        scene.campaign = CampaignRun(spec: C, index: k, state: campaignState)
        openIntro(i)
    }

    /// Picks one of the offered rewards for the army.
    func pickReward(_ id: String) {
        var cs = campaignState
        guard cs.pending != nil, !cs.perks.contains(id) else { return }
        cs.perks.append(id)
        cs.pending = nil
        cs.save(pack.id)
        scene.campaign?.state = cs
        bestsVersion += 1
    }

    func eraseCampaign() {
        if eraseArmed {
            CampaignState.erase(pack.id)
            eraseArmed = false
            campaignSelection = 0
            bestsVersion += 1
        } else {
            eraseArmed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in self?.eraseArmed = false }
        }
    }

    var hasNextBattle: Bool { levelIndex < pack.levels.count - 1 }

    /// "See fort" / "Back to launcher" on a scrolling battlefield.
    func toggleLook() {
        scene.lookAtFort(!scene.lookingAtFort)
        sync(from: scene)
    }

    func select(_ key: String) {
        scene.select(key)
        sync(from: scene)
    }

    /// Called by the scene when the battle is won or lost; the report appears a moment later,
    /// so the last explosion can finish.
    func battleEnded(won: Bool, stars: Int, score: Int, bonus: Int, left: Int) {
        let pending = scene.campaign != nil ? campaignState.pending : nil
        result = ResultInfo(won: won, stars: stars, score: score, bonus: bonus, left: left,
                            rewardLevel: won && pending == scene.level?.id ? pending : nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { [weak self] in
            guard let self, self.scene.mode == .result else { return }
            self.screen = .result
            self.bestsVersion += 1
            self.updateInsets()
        }
    }

    // MARK: state from the scene

    func sync(from scene: BattleScene) {
        let h = HUDState(score: Int(scene.score), defenders: scene.defendersLeft(), wind: scene.wind, hint: scene.hint,
                         selected: scene.selected, arsenal: scene.arsenal,
                         canLook: scene.canLook, lookingAtFort: scene.lookingAtFort)
        if h != hud { hud = h }
    }

    /// Unique defenders in the loaded fort, for the mission briefing.
    var fortDefenders: [(key: String, name: String, sprite: String)] {
        var seen = Set<String>(), out: [(String, String, String)] = []
        for d in scene.defenders() where !seen.contains(d.key) {
            seen.insert(d.key)
            out.append((d.key, d.defender?.name ?? d.key, d.spriteName))
        }
        return out
    }

    // MARK: layout

    func setChrome(hud: Double? = nil, dock: Double? = nil) {
        if let hud { hudHeight = hud }
        if let dock { dockHeight = dock }
        updateInsets()
    }

    func setSafeArea(_ insets: EdgeInsets) {
        safe = insets
        updateInsets()
    }

    private func updateInsets() {
        // like the prototype, the battlefield fills the screen behind menus and fits
        // between the HUD and the arsenal bar during a battle
        let play = screen == .play
        scene.setInsets(top: play ? hudHeight : 0, bottom: play ? dockHeight : 0,
                        left: Double(safe.leading), right: Double(safe.trailing))
    }
}
