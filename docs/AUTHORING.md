# Monster Authoring Guide

Every monster is built from **real studded Roblox parts** (Part blocks + WedgeParts,
studs on every face), rigged with **Motor6D bones**, and animated
procedurally by a tiny client-side script. One build produces a `.rbxm` you can
drag into Roblox Studio, plus a web preview so we can *see* the result.

```
lib/Builder.luau        offline builder API (B:block, B:bone, B:sym, ...)
lib/AnimLib.luau        animation math shipped inside every model (L.ang, L.env, ...)
lib/Animator.luau       the runtime Script (RunContext=Client) that drives Motor6D.Transform
monsters/<Id>/build.luau   geometry + rig + effects for one monster
monsters/<Id>/motion.luau  the animation (a ModuleScript that runs in Roblox as-is)
monsters/<Id>/order.txt    integer sort order in the showcase
tools/build.luau        build pipeline (Lune)
tools/preview/          three.js previewer + screenshot tool
```

## Commands (run from the repo root)

```bash
lune run tools/build.luau <Id>              # build one monster, validates the motion, prints stats
node tools/preview/shoot.mjs <Id>           # out/shots/<Id>_views.png (4 angles) + <Id>_motion.png (8 frames)
node tools/preview/shoot.mjs <Id> --views=34,front --times=3.9,4.4 --zoom=2.5 --focus=0,19,-3 --name=head
#   views: 34 front side back left top low head    times: seconds   nt=N: N evenly spaced frames
lune run tools/build.luau                   # build ALL + out/Monsters.rbxm + out/MonsterShowcase.rbxl
```

The build prints `PROBLEM:` lines for typos (unknown joint names, missing emitter
names, NaNs). A clean build prints none. Always **look at the PNGs** with the
Read tool after every change — that is the only way to judge quality.

## Coordinate conventions

* Feet on **Y = 0**, centered on X = 0. The monster **faces −Z** (Roblox forward).
* Its **right** side is **+X**, left is −X. 1 unit = 1 stud. Plastic parts render
  with Roblox studs on every face, so big monsters look like the references.
* Everything you pass to the builder is in **model (world) space**.

## build.luau

```lua
return {
	DisplayName = "Celestial Peacock",
	Rarity = "Divine",          -- Epic / Legendary / Mythic / Secret / Divine / Cosmic
	Element = "Holy",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local body = B:bone("Body", "Root", v(0, 10, 0))          -- pivot point
		B:block(body, v(6, 5, 8), cf(0, 10, 0), "#ffffff")         -- size, CFrame, color
		B:sym(function(side)                                       -- side = "R" then "L" (auto-mirrored)
			local arm = B:bone("Arm" .. side, "Body", v(3, 11, 0))
			B:ball(arm, 2, cf(3.5, 11, 0), "#ffcc33", { mat = "Neon" })
		end)
	end,
}
```

### Helpers `P`
`P.v(x,y,z)` Vector3 · `P.cf(x,y,z, rx,ry,rz)` CFrame with rotation in **degrees** ·
`P.ang(rx,ry,rz)` rotation only · `P.look(from, to)` · `P.span(a, b)` → CFrame at the
midpoint whose −Z points a→b, plus length · `P.CFrame`, `P.Vector3`, `P.Color3` are
the Roblox types (`CFrame`, `Vector3`, `Color3`, `Enum` are also globals).

### Bones
`B:bone(name, parent, pivot)` – pivot is a Vector3 or CFrame. Names must be unique.
Animation rotates the bone **about its pivot in the pivot's orientation** (identity
by default = model axes). Put pivots where the real joint is (shoulder, hip, neck
base, jaw hinge, each tail segment). Chain them: `Tail1 → Tail2 → Tail3 …`.

### Parts (all return the Part) — STUD STYLE: blocks + wedges only
| call | notes |
|---|---|
| `B:block(bone, size, cf, color, opts)` | studded box — 90% of every monster |
| `B:wedge(bone, size, cf, color, opts)` | Roblox wedge: tall face at local +Z, slope descends toward −Z (snouts, beaks, claws, tail tips) |
| `B:beam(bone, a, b, w, h, color, opts)` | box spanning point a → point b (horns, limbs, tusks, bars) |
| `B:spike(bone, base, tip, width, depth, color, opts)` | tapered blade/horn/claw/tooth (2 wedges) |
| `B:tri(bone, a, b, c, thickness, color, opts)` | flat triangle (2 wedges) — ONLY for big flat membranes: wings, fins |
| `B:poly(bone, {p1, p2, ...}, thickness, color, opts)` | flat convex polygon (wings/fins) |
| `B:ring(bone, centerCF, radius, count, segSize, color, opts)` | ring of blocks (halos, crowns, collars) |
| `B:gem(bone, size, cf, color, opts)` | small Neon accent block (`opts.light=true` adds a soft PointLight) |

`B:ball`, `B:cyl`, `B:ellipsoid`, `B:cwedge` **error** — round/smooth shapes don't belong in this game.
`opts`: `mat` — only `"Plastic"` (default, studded on all 6 faces) or `"Neon"`; `tr` transparency, `name`.
Colors: `"#rrggbb"`, `{r,g,b}` (0-255) or `Color3`.

### Effects
* `B:emitter(part, preset, opts)` presets: `sparkle glow ember fire smoke drip bubble spark burst leaf`.
  opts: `color` (hex or list of hex for a gradient), `rate`, `size` (number or list), `life {a,b}`,
  `speed {a,b}`, `spread`, `accel {x,y,z}`, `light`, `name`, `enabled`. `burst` has Rate 0 –
  fire it from motion with `ctx.emit(name, count)`.
* `B:light(part, {color, brightness, range, name})` PointLight.
* `B:trail(bone, a, b, {color, life, width={1,0}, trans={0.2,1}, name})` – motion trail between
  two points carried by a bone (claw tips, tail tips, wing edges, weapon blades). Trails make the
  exaggerated motion read beautifully in game.

Presets: `sparkle glow ember fire smoke drip bubble spark burst dust leaf` (`burst` and `dust` have Rate 0 —
fire them with `ctx.emit` on impact beats). Keep it tasteful: emitters ≤ 8, lights ≤ 4 (brightness ≤ 1.5),
trails ≤ 8 per monster.

## motion.luau (runs inside Roblox exactly as written)

```lua
local L = require(script.Parent.AnimLib)
local ang, pa, wave, E = L.ang, L.pa, L.wave, L.ease
local M = {}
M.Cycle = 9                      -- loop length in seconds (idle + special move)

function M.Update(t, pose, ctx)  -- t = seconds since start (keeps growing)
	local c = t % M.Cycle         -- time inside the loop
	local roar = L.env(c, 4.0, 0.3, 1.2, 0.6, "backOut", "cubicInOut")  -- 0→1→0
	pose.Body = pa(0, 0.4 * wave(t, 0.5) - 1.2 * roar, 0,  -12 * roar, 0, 0)  -- pos xyz, rot degrees xyz
	pose.Jaw = ang(40 * roar, 0, 0)
	L.both(pose, "Arm", ang(0, 0, 30 * roar))  -- sets ArmR and the mirrored ArmL
	if ctx.crossed(4.1) then ctx.emit("RoarBurst", 60) end
end
return M
```

`pose[boneName] = CFrame` is the Motor6D.Transform: an offset **relative to the
rest pose, in the bone's pivot frame**. Unset bones stay at rest. Only Luau
built-ins + `CFrame`/`Vector3`/`math.noise` are available (no `game`, no services).

### AnimLib (`L`)
`L.ang(x,y,z)` degrees → CFrame · `L.pa(px,py,pz, rx,ry,rz)` · `L.wave(t, hz, phase)` [-1,1] ·
`L.wave01` [0,1] · `L.bounce` |sin| · `L.saw` · `L.tri` · `L.noise(t, seed, freq)` ·
`L.lerp` `L.clamp01` `L.remap(x,a,b)` `L.smoothstep` ·
`L.env(c, start, attack, hold, release, easeIn, easeOut)` 0→1→0 envelope ·
`L.track(c, {{time, value, ease}, ...})` keyframes · `L.track3`/`L.trackAng` for xyz degree triples ·
`L.mirror(cf)` · `L.both(pose, "Wing", cfRight[, cfLeft])` · `L.chain(t, hz, lag, amp)(i)` ripple down a chain.
Easings (`L.ease.*` or by name): `linear quadIn quadOut quadInOut cubicIn cubicOut cubicInOut sineInOut
expoIn expoOut backIn backOut backInOut elasticOut bounceOut`.

`ctx` (effects, optional): `ctx.crossed(sec)` true once per loop as `c` passes sec ·
`ctx.emit(emitterName, n)` · `ctx.enable(emitterName, bool)` · `ctx.light(lightName, brightness)` ·
`ctx.transparency(partName, value)` (show/hide e.g. a breath beam).

### Rotation sign cheat-sheet (bone with identity orientation)
* **+X rot** = pitch **up/back** (nose up, a forward-pointing part lifts; top of a part tips toward +Z/back). −X = nod down / lean forward.
* **+Y rot** = yaw toward the monster's **left** (−X). −Y = turn right.
* **+Z rot** = roll toward the monster's left: a part hanging **down** from a right-side (+X) pivot swings **outward/up** to +X. So for right wings/arms: `+Z` = raise/flare out. With `L.both` the left side mirrors automatically.
* Jaws hinge at the back of the mouth: lower jaw opens with **−X** (tip goes down). Upper head opens with +X.
* Translation is in studs, in the bone's frame (Y up).

## The quality bar (non-negotiable)

### Style bible — copy the "Void Leviathan" reference screenshots
* **Stud-built voxel look**: every monster is assembled from chunky studded Plastic blocks (and a few
  wedges), studs visible on every face. Think "3D pixel art": stepped, blocky silhouettes; no smooth or
  round parts at all. Shapes are built by stacking/stepping blocks (stepped chest scales, stepped horns,
  stepped spines, stepped wing membranes).
* **"Most detail with the fewest parts"**: 120–300 parts. Detail comes from *color blocking* and a few
  well-placed accent blocks, not from part spam: a lighter belly/chest of stepped plates, darker side
  panels, contrasting horns/spikes/claws, rows of small white block teeth, a black mouth interior, a
  tongue, small accent squares. Use whole or half-stud sizes (1, 1.5, 2, 0.5) so studs line up cleanly.
* **Palette**: one strong saturated main color + a darker shade of it + a light contrast color
  (lavender/white/cream/gold for horns, spikes, belly, claws) + white teeth/claws + black mouth +
  **one** neon accent color (two at most).
* **Glow is an ACCENT, not a light show**: Neon only on small things — eyes, horn tips, spike tips, thin
  stripes, mouth glow, a small gem. The build fails if Neon covers more than 7% of the visible
  surface. Never make whole limbs, bodies, halos or wings out of Neon. Lights: soft (≤1.5 brightness).
* **Cartoon appeal for kids**: big head (~1.3× realistic), big expressive eyes (neon slit/rectangle
  eyes with a dark pupil, heavy brows), big toothy mouth, chunky feet/claws, readable from far away.
  Brain-rot tycoon pets: bold, goofy, cool, a little "spammy" with spikes/teeth/tips.
* **VFX that reads well**: floating voxel cubes orbiting the monster (small bones), small sparkle
  twinkles, trails on tail tips/claws/wing tips, bursts/dust on impact beats, hidden Neon beams/bolts
  revealed with `ctx.transparency` during the signature move. Subtle at idle, big on the beat.

**Size (pet-pen scale, a player is 5 studs tall):** 10–20 studs tall (24 max), long creatures up to
~40 studs long. Fliers/swimmers hover 1.5–4 studs above the ground. Walkers stand with feet at Y≈0.

**Animation – VERY exaggerated, bouncy, cartoonish:**
* Never static. Bouncy idle (marching in place, hops, waddles, head bobs), breathing, tail wags,
  ear/fin/tentacle secondary motion with phase lag down chains, cartoon blinks (eyelid blocks on bones),
  little chomps/twitches. Floating cubes orbit and tumble.
* At least one big **signature move** per loop (roar, slam, chomp, wing burst, spin, fan display,
  scythe sweep…) with real animation principles: **anticipation** (wind-up the opposite way),
  fast **action**, **overshoot** (`backOut`, `elasticOut`), **follow-through** (tails/ears keep moving),
  **settle**. Cartoon squash: body drops 1–2 studs on landings/impacts, then springs back.
* Big amplitudes: 30–90° on limbs during actions, 20–45° head throws, jaws open 50–80°.
  The build log prints each joint's motion range — if the signature joints are under ~25°, push harder.
* Fire effects at the right beat (`ctx.emit` bursts/dust on impact frames).
* Seamless: always-on waves use absolute `t`; special moves use `c = t % M.Cycle` with envelopes
  that return to 0 before the loop ends.

**Solid construction:** blocks on a bone should overlap their neighbors at joints so nothing gaps or
detaches at extreme poses. Avoid coplanar same-size faces (z-fighting): offset by ≥0.05. Every part
must be attached to the bone that should carry it (head parts on Head, jaw parts on Jaw, etc.).

### More rotation tips
* A limb **hanging down** from its pivot: **+X swings it forward**, +Z swings a right limb outward.
* A part extending **backward** (+Z) like a tail: **−X lifts it**, +Y swings it toward the monster's left.

Study `monsters/AtomicKaiju/` — it is the reference implementation of this style.

Do not edit anything in `lib/` or `tools/`. Keep all code inside your monster's folder.
