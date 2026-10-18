# Angry Dudes for iPhone

The iPhone version of Angry Dudes, written in Swift with SpriteKit and SwiftUI. It plays the same
battle packs as the HTML prototype and draws everything from the same pixel art. Nothing is
redrawn or retyped: the app reads `assets/sprites.json` and `assets/packs/*.json` from the main
project folder.

What works: the menu with every battle pack the prototype loads, the mission briefing, playing a
battle from start to finish in landscape (sling, fire, drive and call-in, every special move,
defenders fighting back, wind, scoring and stars), wide battlefields that scroll, trenches,
rivers that only boats can cross, floating ships, observation balloons, tunnel mines, paratrooper
planes, jetpacks, low gravity on the Moon, the arsenal bar, the victory and defeat screens, and
the WWII campaign: a map of the route from Normandy to the Rhine, a reward to pick after each
first win, and defenders that get tougher mission by mission. Best scores and campaign progress
are saved on the phone, and after two losses in a row a battle starts with one bonus troop, like
the prototype.

Not yet: sound, haptics and iPad, the Level Builder and Fortress Battle modes, and some newer campaign map
features (the app shows every mission on the campaign's overall map, without chapter zooms, front lines
or skylines in the battle backgrounds).

## Run it

You need a Mac with **Xcode 16 or newer** (free from the Mac App Store).

1. Open `ios/AngryDudes.xcodeproj`.
2. Pick an iPhone simulator at the top of the window, for example "iPhone 16".
3. Press **Run** (⌘R). Turn the simulator sideways if it isn't already (⌘→).

From the command line:

```bash
xcodebuild -project ios/AngryDudes.xcodeproj -scheme AngryDudes -destination 'platform=iOS Simulator,name=iPhone 16' build
```

**On a real iPhone:** select the AngryDudes target, open *Signing & Capabilities*, choose your
team, and change the bundle identifier from `com.example.AngryDudes` to something of your own.

## Changing the game

The app and the prototype share their data, so most changes happen in the main project:

| To change | Edit | Then run |
| --- | --- | --- |
| A level, unit or fort | `js/packs/<pack>.js` | `python3 tools/export_packs.py` |
| Pixel art | `tools/sprites_<pack>.py` | `python3 tools/build_sprites.py` |
| A new battle pack | add it as the main README describes | both of the above |

`tools/export_packs.py` turns each pack that `index.html` loads into `assets/packs/<id>.json`
and lists them, in menu order, in `assets/packs/index.json`. A pack file that `index.html`
doesn't load yet is skipped, so a half-made pack never reaches the app. The Xcode project copies
the whole `assets` folder into the app, so the next build picks up the changes.

A new pack can only use special moves, defender reactions and level features the app already
knows (everything in `js/game.js` as of October 16, 2026, 21:07). Anything newer needs porting:
unknown tap moves do nothing, and unknown defender reactions are ignored.

## How the code is laid out

```
ios/
  AngryDudes.xcodeproj      the Xcode project (every file in AngryDudes/ is included automatically)
  AngryDudes/
    AngryDudesApp.swift     app entry point: landscape, full screen
    Data/                   reading sprites.json and the packs, the pixel canvas, the pixel font, best scores,
                            campaigns (Campaign.swift: rewards, saved progress, the map painter)
    Game/                   the battlefield: a port of js/game.js onto SpriteKit
      BattleScene.swift       state, screen fitting, the frame loop, touch input
      +Camera                 scrolling wide battlefields, "See fort"
      +Level                  building the fort from its letter drawing, trenches and rivers
      +Physics                collisions, damage, explosions, wind and lift
      +Launch                 sling, fire, drive, planes and paratroopers, arrow storms, tunnel mines
      +Special                tap moves: shout, chute, detonate, pound, dash, split, sharpshoot, jump, shoot, ram, unload, blowup
      +Defenders              shooters, snipers, anti-tank guns, the claw, boiling oil, healers
      +Turns                  turn flow, winning, losing, the hint line
      +Campaign               campaign missions: upgrades, tougher defenders, extra items, recording wins
      +Effects, +Draw         particles, call-outs, trails, aim dots, weather
      Background.swift        sky, hills, ground and cliff, painted like the prototype
    UI/                     SwiftUI screens: menu, briefing, HUD, arsenal bar, battle report, campaign map
  MacPreview/               a Mac build of the same code, for testing without Xcode
  tools/mac-preview.sh      builds and runs the Mac preview
```

The port follows `js/game.js` closely, so the same function names (`loadLevel`, `touch`, `hurt`,
`explode`, `special`, `reactions`, `finishTurn` and so on) are easy to find on both sides. A few
things work differently:

- **Physics.** SpriteKit's physics replaces Matter.js. It runs 3× larger than the art, like the
  prototype, and the numbers in the pack files (speeds, pushes, jump heights) are still in the
  prototype's units; `Entity.vel` converts them. Gravity and air friction match exactly.
- **How hard things hit.** SpriteKit reports a collision after it has already bounced things
  apart, so the scene remembers every body's velocity from just before each step and measures
  impacts with that.
- **Drawing.** Fort pieces, soldiers and vehicles are sprites that move with their physics bodies.
  Particles, trails, aim dots, call-outs and weather are drawn fresh each frame through a small
  pooled painter (`Painter.swift`), the way the prototype paints its canvas.
- **Text** on the battlefield and in titles uses a built-in 7-pixel bitmap font, so there are no
  font files to bundle.
- **Planes**, and the sun, moon and planets, sit a little lower on short screens so they stay
  visible under the HUD.
- **Wide battlefields** scroll like the prototype: the camera shows the fort first, pans back to
  the launcher and follows each shot. On a scrolling battlefield, aim by dragging on the left half
  of the screen; drag anywhere else to look around, or press "See fort". Vehicles and call-ins
  launch on a tap.

## Testing without Xcode

`tools/mac-preview.sh` builds the same Swift files into a Mac app using only the Command Line
Tools:

```bash
ios/tools/mac-preview.sh
```

This opens the game in a window; the mouse works like a finger. With `--test` it plays a scripted
battle offscreen on a simulated iPhone screen, prints what happened, and saves screenshots:

```bash
ios/tools/mac-preview.sh --test ios/MacPreview/omaha.txt --out /tmp/angry-shots
```

The script commands (`open`, `use`, `aim`, `tap`, `drag`, `look`, `settle`, `shot`, `expect win`,
`map`, `mission`, `reward`, …) are listed at the top of `ios/MacPreview/Headless.swift`.
Screenshots show scrolling areas as they look before anyone scrolls. To try a pack that isn't in the
game yet, point `ANGRY_ASSETS` at a folder laid out like `assets/` (a `sprites.json` and a
`packs/` folder with an `index.json`); it takes priority over the bundled data.
