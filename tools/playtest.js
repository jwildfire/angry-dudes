// Play-test bot. Load it on the game page's console:
//   var s = document.createElement("script"); s.src = "tools/playtest.js"; document.body.appendChild(s);
// then run e.g. BOT("ww1", [0, 1, 2, 3], 10)
// It plays each level `tries` times like a kid who aims with the dotted trajectory line but isn't perfect:
// every shot picks a defender, works out roughly the right angle and power, then wobbles a little.
// It reports wins, best score, how many defenders were left, which ones survived,
// and whether anything was damaged before the first shot (an unstable fort).
// BOT(pack, levels, tries, { wobble: 2 }) makes it a sloppier shot; { random: true } just flings things.
// BOT(pack, missions, tries, { campaign: true, perks: 3 }) plays campaign missions instead, with tougher defenders
// and an army that has picked up `perks` random rewards (default: one per mission already won).
// The bot always plays with the sound off, and it only clears the progress it created (never your settings).
function botMute() {
  var b = document.getElementById("btn-sound");
  if (b && b.getAttribute("aria-pressed") === "true") b.click();
}
function botCleanup() {
  try {
    Object.keys(localStorage).forEach(function (k) { if (/^angrydudes\.(best|losses|campaign)\./.test(k)) localStorage.removeItem(k); });
  } catch (e) { /* ignore */ }
}
window.BOT = function (packId, levels, tries, opts) {
  opts = opts || {};
  botMute();
  var D = window.ANGRY_DEBUG, P = window.ANGRY_PACKS.find(function (p) { return p.id === packId; });
  var STEP = 1000 / 60, GRAV = 0.001 * STEP * STEP, PH = 3, SLING = { x: 118, y: 249 }, BUNKER = { x: 66, y: 242 };
  var wobble = opts.wobble || 1;
  function settle() { for (var i = 0; i < 120 && D.state.phase !== "ready" && D.state.mode === "play"; i++) D.advance(250); }
  function rnd(a, b) { return a + Math.random() * (b - a); }
  function targets() {
    return D.report().map(function (r) { var m = r.match(/^(\S+) hp [\d.]+ @(\d+),(\d+)/); return { key: m[1], x: +m[2], y: +m[3] }; });
  }
  // height of the shot when it reaches x = tx (the same flight model as the aiming dots), or null if it lands short
  function heightAt(from, k, lift, angle, power, tx) {
    var v = D.state.topSpeed * power * k, r = angle * Math.PI / 180;
    var vx = Math.cos(r) * v, vy = -Math.sin(r) * v, px = from.x * PH, py = from.y * PH;
    for (var i = 0; i < 2000; i++) {
      vy += GRAV * (D.state.gravity || 1) * (1 - lift); vx *= 0.998; vy *= 0.998; px += vx; py += vy;
      if (px / PH >= tx) return py / PH;
      if (py / PH > 320 || px / PH > 3000) return null;
    }
    return null;
  }
  function aim(u, t) {
    var from = u.kind === "sling" ? SLING : BUNKER, k = u.kind === "sling" ? 1 : (u.speed || 1), lift = u.lift || 0;
    if (lift >= 1) {   // lasers fly dead straight: just point at the target
      var straight = Math.atan2(from.y - (t.y - 4), t.x - from.x) * 180 / Math.PI;
      return { angle: straight + rnd(-1.5, 1.5) * wobble, power: 1 };
    }
    var flat = lift > 0.9, angle = flat ? rnd(4, 14) : rnd(28, 55), lo = 0.2, hi = 1;
    for (var i = 0; i < 24; i++) {
      var p = (lo + hi) / 2, y = heightAt(from, k, lift, angle, p, t.x);
      if (y === null || y > t.y - 6) lo = p; else hi = p;
    }
    return { angle: angle + rnd(-2, 2) * wobble, power: Math.min(1, (lo + hi) / 2 * (1 + rnd(-0.04, 0.04) * wobble)) };
  }
  function drive(k, u) {
    D.use(k);
    var tapped = 0;
    for (var i = 0; i < 90; i++) {
      D.advance(150);
      var me = D.report(true).filter(function (r) { return r.indexOf(k + " ") === 0 || r.indexOf(u.sprite + " ") === 0; })[0];
      if (!me) break;
      var x = +me.match(/@(\d+)/)[1], stopped = / stopped/.test(me) || / v0\.0/.test(me);
      var near = targets().some(function (t) { return t.x - x < 70 && t.x > x; });
      if (u.tap === "shoot" || u.tap === "jump") { if (i > 6 && i % 5 === 0) D.tap(); }
      else if (!tapped && (stopped && i > 6 || near) && Math.random() < 0.7) { D.tap(); tapped++; if (u.tap === "ram") tapped = 0; }
    }
  }
  var out = [];
  var C = P.campaign;
  (levels || (opts.campaign ? C.missions : P.levels).map(function (_, i) { return i; })).forEach(function (l) {
    var L = opts.campaign ? P.levels.find(function (x) { return x.id === C.missions[l].level; }) : P.levels[l], wins = 0, best = 0, leftSum = 0, startHurt = 0, tally = {};
    for (var t = 0; t < tries; t++) {
      if (opts.campaign) {
        var ids = C.rewards.map(function (r) { return r.id; }).sort(function () { return Math.random() - 0.5; });
        localStorage.setItem("angrydudes.campaign." + packId, JSON.stringify({ done: C.missions.slice(0, l).map(function (m) { return m.level; }),
          perks: ids.slice(0, opts.perks != null ? opts.perks : l), stars: {}, offers: {} }));
        D.mission(packId, l);
      } else D.open(packId, l);
      var hurt = D.report().some(function (r) {
        var m = r.match(/^(\S+) hp ([\d.]+)/), def = Object.keys(P.defenders).map(function (c) { return P.defenders[c]; }).find(function (x) { return x.key === m[1]; });
        return def && +m[2] < def.hp - 0.01;
      });
      if (hurt) startHurt++;
      for (var turn = 0; turn < 30 && D.state.mode === "play"; turn++) {
        var ars = D.state.arsenal, keys = Object.keys(ars).filter(function (k) { return ars[k] > 0; });
        if (!keys.length) break;
        var k = keys[Math.floor(Math.random() * keys.length)], u = P.units[k], kind = u.kind;
        var ts = targets(), tg = ts[Math.floor(Math.random() * ts.length)];
        if (!tg) break;
        if (kind === "air") D.use(k, tg.x + rnd(-10, 10) * wobble);
        else if (kind === "drive") drive(k, u);
        else {
          var a = opts.random ? { angle: rnd(28, 58), power: rnd(0.85, 1) } : aim(u, tg);
          D.use(k, a.angle, a.power);
          if (kind === "sling") { D.advance(rnd(500, 1300)); D.tap(); }
        }
        settle();
      }
      D.advance(2500);
      var s = D.state;
      if (s.mode === "result" && s.defenders === 0) { wins++; best = Math.max(best, s.score); }
      leftSum += s.defenders;
      D.report().forEach(function (r) { var key = r.split(" ")[0]; tally[key] = (tally[key] || 0) + 1; });
    }
    out.push(packId + (opts.campaign ? " M" : " L") + (l + 1) + " " + L.name + ": won " + wins + "/" + tries + ", best " + best + ", avg left " + (leftSum / tries).toFixed(1) +
      (startHurt ? ", HURT BEFORE FIRST SHOT x" + startHurt : "") +
      (Object.keys(tally).length ? " | survivors: " + Object.keys(tally).map(function (k) { return k + " x" + tally[k]; }).join(", ") : ""));
  });
  botCleanup();
  return out.join("\n");
};
// Runs BOT over many levels a few at a time so the page stays responsive; results collect in BOT_OUT.
window.BOT_ALL = function (jobs, tries, opts) {
  window.BOT_OUT = []; var q = jobs.slice();
  (function next() { var j = q.shift(); if (!j) { BOT_OUT.push("DONE"); return; } BOT_OUT.push(BOT(j[0], [j[1]], tries, opts)); setTimeout(next, 0); })();
  return q.length + " levels queued";
};
