# How to Play

**create your island → gather → build → farm → fish → raise animals → sell → expand & decorate → visit friends and trade → save**

The quest card on the right walks a new player through it in order.

---

## Open it

**Easiest:** open `BuildYourIsland.rbxl` (or `BuildYourIsland.rbxlx`, the same place as text) in Roblox Studio and press **Play**.

**With Rojo:** connect the Rojo plugin to `default.project.json` (see [PHASE_1.md](PHASE_1.md#setup)).

Settings:
- **Avatar type R15** (Game Settings → Avatar).
- **Max players ≤ 8** (one island slot each).
- To test **saving** in Studio: Game Settings → Security → **Enable Studio Access to API Services**. Without it the game uses an in-memory store and warns once in Output.
- To test **visiting / trading** in Studio: Test tab → Clients and Servers → **2 players** → Start.

---

## Controls

There are **no proximity prompts**. You hold something and **click** the thing you want to use. Hovering outlines it and a tooltip says what a click will do: green means OK, orange means you need a different tool or item, and red means you're not allowed.

| Action | Keyboard / mouse | Gamepad | Touch |
|---|---|---|---|
| Hold a tool / seed / crop | **1 – 9** (again to put away), **0** empty hands | L1 / R1 | Tap a hotbar slot |
| Use it on what you hover | **Left click**. Too far away? You walk there first. | R2 / X (aim with the reticle) | Tap the object, or the **USE** button |
| Swing at nothing (practice) | Left click on empty ground | R2 | USE |
| Build mode | **B** or 🔨 | D-pad up | 🔨 |
| Rotate building | R · Q / E | X · D-pad ← → | ⟳ ROTATE |
| Backpack | **I** / **G** or 🎒 | Y | 🎒 |
| Players (visit / trade) | **P** or 👥 | — | 👥 |
| Emotes (Wave, Cheer, Point, Dance) | **T** or 😀 | D-pad down | 😀 |
| Settings (music, sound, camera shake) | ⚙️ | — | ⚙️ |
| Cancel / close / stop fishing | **X** | B | ✕ buttons |

What a click does depends on what you hold:

| You hold | You click | Result (with its animation) |
|---|---|---|
| 🪓 Axe | a tree | chop (health bar, wood chips, the tree falls and regrows) |
| ⛏️ Pickaxe | a rock / ore | mine |
| 🔨 Hammer | a construction site | build the next stage |
| 🌱 Hoe | a soil tile | till |
| 🌾 a seed sack | tilled soil (it outlines) | plant that seed |
| 🚿 Watering can | a planted tile | water (grows 50% faster) |
| anything / nothing | a ripe crop | harvest |
| 🌾 Wheat (or other crop) | a hungry animal | feed |
| 🪣 Bucket | a cow with 🥛 ready | milk (eggs are collected by hand) |
| nothing | an animal | pet it (❤️) |
| 🎣 Fishing rod | the water | cast (see Fishing) |
| anything | the market stall / merchant / chest / sign | sell / buy / open / island settings |

---

## Your own island

### Create it
New players see **CREATE YOUR ISLAND**:
1. **Theme:** 🌴 Tropical, 🌳 Meadow, 🍂 Autumn, ❄️ Snowy or 🌵 Desert. The theme sets the ground and cliff colours, which trees and rocks grow, the little decorations (flowers, shells, leaves, snowballs...), how hilly it is and which fish live near your shore.
2. **Shape:** Round, Crescent, Twin Isles, Longshore or Wild, plus **🎲 REROLL**. Every seed grows a different coastline, and the map in the middle is a live preview made by the same generator the server uses.
3. **Name** (optional, filtered).

Press **CREATE ISLAND!** and your island rises from the sea. Every island is different: the coast, the hills, and where the trees and rocks grow all come from your seed.

### Expand it (build mode → 🗺️ Expand)
Glowing squares appear on the water around your island. Hover one to see its price and click to buy it; the land rises out of the sea with trees and decorations of your theme. You can grow in **any direction**. Each chunk costs a bit more than the last, and your Island Level sets how much land you can own (the island panel shows *Land 58/76 · next 180 🪙*).

### Paint it (build mode → 🖌️ Paint)
Choose Grass, Autumn Grass, Snow, Sand, Sandstone, Dirt, Mud, Cobble Path, Brick Path, Wood Deck, Stone Tiles, Slate or Limestone. Then click or drag over your land to paint paths, plazas and gardens. It's free. The 🧽 eraser restores the natural ground.

### Shape it (build mode → ✏️ Edit)
- Click a building to **MOVE** or **DELETE** it (delete refunds 50%; the market stall can be moved but not deleted).
- Click a **wild tree or rock** and press **🪓 CLEAR IT** to remove it for good (you keep a little of what it drops).
- Build mode → 🌳 **Nature**: plant Oak, Palm, Pine and Maple saplings, boulders and fiber plants wherever you like. They are real, harvestable resources.
- Build mode → 🐄 **Farm → Soil Tile** adds more farmland (4×4, 15 🪙).

### Island settings (⚙️ ISLAND button, or click your island sign)
Rename your island, choose **who can visit** (🌍 Everyone / 💛 Friends / 🔒 Nobody), and make players in the server **helpers**. Helpers can gather, farm, feed animals and hammer on your island.

---

## Multiplayer

### Visiting
Press **P** → 🏝️ **VISIT** next to a player. Their visitor setting decides whether you may come. While visiting:
- the island card shows *Visiting <name>'s island* with ❤️ **LIKE** (once a day per island) and 🏠 **HOME**,
- you can look around, **fish** and use their **market**. Gathering, farming, animals and hammering need the owner to make you a helper,
- clicking their island sign shows its info and a LIKE button.

If the owner locks the island or leaves, visitors are sent home. Islands of everyone in the server are in the same world, so visiting is instant. Visiting players in *other* servers isn't supported.

### Trading
Press **P** → 🤝 **TRADE**. The other player gets an ACCEPT / DECLINE popup. In the trade window:
- click items in **your backpack** to offer one more, and click your offered items to take one back,
- type the **coins** you add,
- press **READY**. Any change un-readies **both** players, and when both are ready a **3-second countdown** runs before the swap.

The server re-checks both inventories and backpack space at the end and swaps everything at once (or nothing).

---

## The quest chain

1. **START YOUR ISLAND:** open the starter chest (tools, seeds, some materials), collect Wood and Stone, build a Small Cottage, plant 5 crops, catch a fish, sell something.
2. **RAISE YOUR FIRST ANIMAL:** build a Barn, buy a cow, feed it, collect milk.
3. **GROW YOUR ISLAND:** expand your island 3 times, and more.
4. **ISLAND DESIGNER:** rename your island, paint 12 cells, plant 3 trees, own 10 soil tiles.
5. **ISLAND ADVENTURER:** better tools, a cabin, eggs, Island Level 5.

Everything gives Island XP, and levels unlock seeds, animals, tools, buildings and more land.

### Fishing
Hold the rod and click the water. The bobber lands where you clicked (up to 36 studs away). Near your shore you catch your theme's fish; far out it's the open ocean. When the **!** appears, click fast. Then **hold** the button to lift the green zone and keep the 🐟 inside it until the bar fills.

---

## Animations, effects and sounds

**Game feel (cartoon juice).**
- Every tool has **three swings** (for example the axe has a diagonal chop, an overhead chop and a flat slash). Each swing picks one at random and never repeats the last one. Everyone sees the same swing: your client picks it, plays it instantly and tells the server which one.
- Swings leave a **trail** in the tool's tier colour (water drops for the watering can) and make a whoosh.
- **Camera:** each hit you land gives a springy nod and a tiny zoom squash. A tree crashing down, a rock shattering, a finished building, new land rising and a big catch all make the camera **wobble** for everyone nearby. The "Camera shake" setting turns the rotation off.
- **Trees** sway when hit, lean back, then crash down with a cartoon bounce. On impact you get a crash sound, a dust cloud, leaves, splinters and a camera wobble, then the tree poofs away.
- **Rocks and ore** squash on every hit, then **shatter into bouncing chunks** in their own colour, with dust, a flash, stars, a sound and a wobble.
- Hits flash with stars, and hovering anything clickable gives a little "boing" and outline flash. Soil squashes when tilled, sprouts pop up when planted, and harvests burst. Animals squash happily. Construction sites squash on every hammer hit, and finished buildings pop with confetti and big dust clouds. Chests and level ups throw confetti.
- **UI:** glossy buttons grow on hover and squash on press. Windows and toasts pop in with a wobble, the banner arrives on a ribbon, and "+N" numbers pop and tilt. The held hotbar slot lifts, glows and wiggles.

- Every action is a **keyframed R15 animation**: chop, mine, hammer, till, plant, water, harvest, feed, milk, pet, cast, wait, bite, reel, catch, cheer, wave, point, dance and open chest. Each tool also has its own **hold pose**. Animations are replicated: **every player sees everyone's swings**, and your own starts instantly (predicted locally). Hits land on the exact animation frame (marker) with sound, particles and a small camera shake. Cows and chickens have jointed legs, heads, tails and wings that walk, eat and hop.
- Sounds come from two sources that exist for sure: files built into the Roblox client and audio from Roblox's official tutorials. There's background music and a sea ambience; volume is in ⚙️ Settings. See [ASSETS.md](ASSETS.md#sounds).

---

## Admin / test commands

In Studio everyone can use these; in a live game only `GameConfig.AdminUserIds` can.

```text
/givecoins me 5000          /givegems me 50
/giveitem me Wood 100       /givetool me StoneAxe
/givexp me 500              /giveislandxp me 200
/setislandlevel me 5        /expand me 10        (adds 10 land chunks)
/growcrops me               finish every planted crop now
/finishbuilds me            complete every construction site now
/spawnanimal me Cow         add a cow (needs a free Barn slot)
/readyanimals me            make every animal's milk / eggs ready now
/save me                    /resetdata me   (Studio only; rejoin to see the island creator again)
```

---

## Testing checklist

### Island creation and uniqueness
- [ ] A new player sees CREATE YOUR ISLAND. Changing theme / shape / reroll redraws the preview map.
- [ ] Creating spawns you on an island that matches the preview, with the chest, sign, market stall and 6 soil tiles near the spawn.
- [ ] Two players with different seeds / themes get visibly different islands (coast, hills, trees, colours, decorations).
- [ ] Rejoining keeps the same island (no creator screen).

### Land tools
- [ ] Build mode → Expand shows glowing squares only next to your land. Hover turns one bright; the info panel shows land used and price.
- [ ] Clicking one charges the price and raises the land with dust and a rumble; players standing there are lifted. New trees / decorations appear.
- [ ] At the land limit the squares turn red and clicking does nothing.
- [ ] Paint: clicking / dragging paints 8×8 cells on your land only; the eraser restores the natural material. It stays after rejoining.
- [ ] Edit → click a wild tree → CLEAR IT (twice) removes it for good.

### Clicking and holding
- [ ] Hovering a tree with the axe outlines it green ("🪓 Chop · Oak Tree"). With the pickaxe it turns orange ("Hold your Axe to chop").
- [ ] Holding a seed sack and hovering tilled soil outlines the tile; clicking plants with the crouch + plant animation.
- [ ] Clicking a tree far away walks you to it, then chops. Pressing WASD cancels the walk.
- [ ] Other players see your hold pose and every swing (the same one of the three).
- [ ] Swinging the axe 6 times shows at least two different swings, each with a coloured trail and a whoosh.
- [ ] Chopping a tree: it sways on each hit, then crashes down with a bounce, dust, leaves and a camera wobble.
- [ ] Mining a rock: it squashes on each hit, then shatters into bouncing chunks with a wobble.
- [ ] The island creator fills the whole screen on a small Studio window and on a phone.

### Multiplayer (2-player test)
- [ ] P lists the other player with their island name, theme, level and likes.
- [ ] VISIT teleports you; the island card switches to Visiting with LIKE / HOME. LIKE works once per day.
- [ ] As a visitor, hovering their tree shows red "🔒 Ask the owner to make you a helper". After the owner makes you a helper, chopping works.
- [ ] Owner sets visitors to Nobody → the visitor is sent home.
- [ ] TRADE: invite → accept → both offer items/coins → changing an offer un-readies both → both READY → countdown → items swap. Cancel returns everything.

### Building, farming, fishing, animals, market, quests
- [ ] Build: the ghost is green on free land and red on the beach / water / steep ground / blocked spots. Hammering a site with the hammer adds one stage per hit.
- [ ] Farming: till → plant → water → harvest, each with its animation and sound. Crops keep growing while you're offline.
- [ ] Fishing: click the water to cast there, the reel minigame works, and the catch card shows.
- [ ] Animals: feed with a crop in hand, milk with the bucket, pet with empty hands. The animals walk and animate.
- [ ] Market: clicking the stall opens Sell; clicking the merchant opens Buy.
- [ ] Quests advance from real actions (expanding, painting, renaming count for Island Designer).

### Saving
- [ ] With API access enabled: expand, paint, build, plant, buy a cow, trade, then stop and play again. Everything comes back, including the island shape and paint.

### Security (try from the client command bar)
- [ ] `ExpandIslandRequest` for a chunk that isn't next to your land, or without coins, is rejected.
- [ ] `PaintTerrainRequest` on someone else's land / with an unknown material is rejected.
- [ ] `InteractRequest` on an object far away or on another island without permission is rejected.
- [ ] `TradeRequest` offering items you don't have is rejected; the final swap re-checks everything.

### Automated
```bash
./tests/run_logic_tests.sh     # 31 engine-free tests: island generator, migration, keyframes + swing variants, configs, math
```

---

## Known limitations

- **Models are procedural** (parts and meshes built in code). Drop real models into `ServerStorage` to override them (see ASSETS.md).
- **Visiting is within one server.** Players in other servers can't be visited (that would need TeleportService and reserved servers).
- Cows and chickens have no sound yet: there is no verified source for animal sounds, so they are labelled placeholders you can fill in.
