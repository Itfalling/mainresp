# The First Playable Loop

This build turns the Phase 1 island into a real game. Everything in the spec's first playable milestone (§157) now works end to end:

**gather → build → farm → fish → raise animals → sell → buy upgrades → expand → save**

The "Start Your Island" quest card on the right of the screen walks a new player through it in order.

---

## Open it

**Easiest:** open `BuildYourIsland.rbxlx` from the repository in Roblox Studio and press **Play**.

**With Rojo:** connect the Rojo plugin to `default.project.json` (see [PHASE_1.md](PHASE_1.md#setup)).

Required settings are the same as Phase 1: **Avatar type R15** (Game Settings → Avatar) and **max players ≤ 8**.

---

## Controls

| Action | Keyboard / mouse | Gamepad | Touch |
|---|---|---|---|
| Use / swing tool, cast, reel | Left click (hold to reel) | R2 | **USE** button (hold to reel) |
| Equip hotbar tool | 1 – 8 | L1 / R1 | Tap a hotbar slot |
| Interact (chop, till, feed, fish, sell...) | **E** (hold where shown) | X | Tap the prompt |
| Market: shop / Pet an animal | **F** | Y | Tap the prompt |
| Talk to the merchant | **T** | — | Tap the prompt |
| Build mode | **B** or 🔨 button | D-pad up | 🔨 button |
| Rotate building | R · Q / E | X · D-pad ← → | ⟳ ROTATE |
| Backpack | **I** / **G** or 🎒 | Y | 🎒 button |
| Cancel / close / stop fishing | **X** | B | ✕ buttons |

---

## How to play (the quest chain)

### 1. START YOUR ISLAND
1. **Open the Starter Chest** by the spawn: you get an Axe, Pickaxe, Hammer, Hoe, Watering Can, Fishing Rod, some Wood/Stone/Fiber and 6 Wheat Seeds.
2. **Chop trees** (equip the Axe, click near a tree or press E on it). Each hit shows a health bar; the tree falls and regrows later. → **Wood**
3. **Mine rocks** with the Pickaxe. → **Stone**. Fiber bushes are picked by hand.
4. **Build a house:** press **B**, pick *Homes → Small Cottage*, move the green ghost onto free land and click / PLACE. A construction site appears. Equip the **Hammer** and hit it (or press E): every hit raises the next stage until the cottage is finished.
5. **Farm:** walk to the soil plot. E on a tile: **till** (Hoe) → **plant** (a seed picker opens when you carry more than one seed type) → **water** (crops grow 50% faster) → wait for **READY!** → **harvest**. Tiles show the crop, stage and a live countdown.
6. **Fish:** walk to the end of the dock, equip the rod and click (or press E at the 🎣 spot). When the **!** appears, click fast. Then **hold** the button to lift the green zone and keep the 🐟 inside it until the bar fills.
7. **Sell:** at the market stall press **E** (Sell). Sell single items or everything at once. Items in **demand** (📈) pay extra for a while.

### 2. RAISE YOUR FIRST ANIMAL
Build a **Barn** (Build → Farm), buy a **Cow** at the market (**F** → Buy → Animals; the first cow comes with a free bucket), **feed** it 1 Wheat, wait for 🥛 **READY!**, then **milk** it. Chickens (Chicken Coop) lay eggs the same way. Press **F** on an animal to pet it (happiness ❤️).

### 3. GROW YOUR ISLAND
Harvest, fish and sell more, then **unlock Whispering Forest** with the 🔒 sign on your shore or the UNLOCK button in the island panel. New land rises from the sea with new trees, rocks and fishing spots.

### 4. ISLAND ADVENTURER
Buy a Stone Pickaxe, build a Wooden Cabin, collect eggs and reach Island Level 5.

Everything you do gives Island XP. Levels unlock new seeds, animals, tools and buildings.

---

## Admin / test commands

Studio: everyone. Live game: only `GameConfig.AdminUserIds`.

```text
/givecoins me 5000          /givegems me 50
/giveitem me Wood 100       /givetool me StoneAxe
/givexp me 500              /giveislandxp me 200
/setislandlevel me 5        /unlockarea me Forest
/growcrops me               finish every planted crop now
/finishbuilds me            complete every construction site now
/spawnanimal me Cow         add a cow (needs a free Barn slot)
/readyanimals me            make every animal's milk / eggs ready now
/save me                    /resetdata me   (Studio only)
/debug me
```

---

## Testing checklist

### Gathering
- [ ] Equip the Axe and click next to a tree: swing animation, hit sound, wood chips, health bar drops, the tree wobbles.
- [ ] 4 hits (Wooden Axe) fell the tree: it tips over away from you, "+N 🪵 Wood" floats up, it regrows after ~40 s.
- [ ] Hitting a rock with the Axe does nothing; the Pickaxe mines it.
- [ ] Pressing E on a tree without an Axe tells you what you need.
- [ ] With a full backpack, gathering tells you the backpack is full (sell something at the market).

### Building
- [ ] B opens build mode (categories left, info right, hints bottom), the camera pulls back, prompts pause.
- [ ] The ghost is green on free unlocked land and red with a reason on water, locked land, steep ground, on top of a tree/landmark, too far, or when you can't afford it.
- [ ] R / Q / E rotate. PLACE charges the cost once and creates a construction site with a progress label.
- [ ] Each hammer hit (swing or E) adds exactly one stage; the last one plays the completion effect and banner.
- [ ] Edit tab: click a building → MOVE (re-place it) or DELETE (tap twice; refunds 50%, or 100% if never hammered).
- [ ] A Barn with cows in it cannot be deleted.

### Farming
- [ ] Till → plant → water → harvest each play their animation and effect; the tile label shows stage + countdown, 💧 when watered.
- [ ] Carrying two seed types opens the seed picker. Out of seeds → a message pointing at the market.
- [ ] Leave the game while crops grow, come back later: they kept growing.
- [ ] Only the first 6 tiles are usable; *Bigger Farm* in the shop adds 3.

### Fishing
- [ ] Cast from the dock: bobber arcs out, line is drawn, "Waiting for a bite" shows.
- [ ] Clicking before the **!** scares the fish ("Too early"). Missing the hook window loses it.
- [ ] The reel minigame: holding lifts the zone, releasing drops it; keeping the fish inside fills the bar.
- [ ] A catch shows the card (rarity colour, weight, NEW! the first time) and adds the fish to the backpack.
- [ ] Walking away or unequipping the rod ends fishing cleanly. X stops fishing.

### Animals
- [ ] Buying a cow without a Barn is refused with a clear message.
- [ ] The cow wanders inside its pen. Its label shows hearts and Hungry / ⏳ countdown / READY!
- [ ] Feeding takes 1 Wheat; milking needs the bucket (free with the first cow) and gives Milk.

### Market
- [ ] E at the stall opens the Sell tab; F opens Buy. The demand banner shows boosted items and a countdown.
- [ ] Sell 1 / Sell All / SELL ALL PRODUCE pay the shown amount (coins count up with a sound).
- [ ] Buy tab shows 🔒 level locks, ✔ OWNED tools, MAX upgrades, red prices you can't afford.
- [ ] Walking away from the stall closes the window.

### Quests
- [ ] The quest card shows each task with progress (e.g. 12/20) and a 💡 hint for the next one.
- [ ] Buying Wood does NOT count for "Collect Wood" (only gathering does).
- [ ] Finishing all tasks pays the reward with a banner and starts the next quest.

### Saving
- [ ] With API access enabled: build, plant, buy a cow, then stop and play again. Buildings (and their construction progress), crops, animals, quests and upgrades all come back.

### Security (try from the client command bar)
- [ ] `GatherRequest` for a node on someone else's island or far away is rejected.
- [ ] `BuildRequest` with a position in the sea, a bad rotation or an unaffordable building is rejected and charges nothing.
- [ ] `FishingRequest {Op="Reel", Success=true}` instantly after hooking is rejected (too fast) and flagged.
- [ ] `SellItemRequest("Wood", 1e9)` / `PurchaseRequest` far from the stall are rejected.

### Automated
```bash
./tests/run_logic_tests.sh     # 28 engine-free tests: configs cross-reference, growth/animal math, placement, migration
```

---

## New scripts (delivery format)

### Shared: `ReplicatedStorage/Shared`
| Script | Type | Purpose |
|---|---|---|
| `Config/BuildConfig` · `Config/BuildingConfig` | ModuleScript | Grid rules; 13 buildings (cost, footprint, steps, housing) |
| `Config/CropConfig` | ModuleScript | 7 crops, growth stages, farm layout; generates crop + seed items |
| `Config/FishConfig` | ModuleScript | Fish, zones, rarity weights, minigame tuning, `MinReelTime` |
| `Config/AnimalConfig` | ModuleScript | Cow and chicken, variants, care constants, milk/egg items |
| `Config/ShopConfig` | ModuleScript | Everything the market sells |
| `Config/QuestConfig` | ModuleScript | The tutorial quest chain |
| `Util/IslandContent` | ModuleScript | Deterministic node / fishing spot / farm plot layout |
| `Util/Placement` | ModuleScript | Build grid math shared by preview and validator |
| `Util/CropGrowth` · `Util/AnimalMath` | ModuleScript | Timestamp growth / care math (server + client agree) |
| `Building/BuildingModels` | ModuleScript | Procedural staged building models and the placement ghost |

### Server: `ServerScriptService/Server`
| Script | Type | Purpose |
|---|---|---|
| `Services/ResourceService` | ModuleScript | Spawns and pools nodes, health, fall-over, respawn |
| `Services/GatherService` | ModuleScript | Validates gathering (tool type/tier, range, cooldown), grants drops |
| `Services/BuildService` | ModuleScript | Placement validation, atomic cost, construction stages, move/delete |
| `Services/CropService` · `Services/FarmService` | ModuleScript | Crop visuals/stages · till/plant/water/harvest |
| `Services/FishingService` | ModuleScript | Server-authoritative cast/bite/hook/reel |
| `Services/AnimalService` | ModuleScript | Housing, feeding, production, pets, wandering |
| `Services/ShopService` | ModuleScript | Sell and buy at the market stall |
| `Services/NPCService` | ModuleScript | Mia the Merchant (R15 NPC) |
| `Services/QuestService` | ModuleScript | Quest progress from server events, rewards |
| `Island/NodeModels` · `Island/CropModels` · `Island/AnimalModels` | ModuleScript | Procedural placeholder models |

### Client: `StarterPlayer/StarterPlayerScripts/Client/Controllers`
| Script | Type | Purpose |
|---|---|---|
| `GatherController` | ModuleScript | Turns swing impacts into gather / hammer requests; health bars |
| `BuildController` | ModuleScript | Build mode UI, ghost preview, move/delete |
| `FarmController` | ModuleScript | Seed picker, crop countdown labels |
| `FishingController` | ModuleScript | Bobber + line, bite alert, reel minigame, catch card |
| `AnimalController` | ModuleScript | Animal status labels |
| `ShopController` | ModuleScript | Market window (sell / buy, demand) |
| `QuestController` | ModuleScript | Quest card |

---

## Known limitations

- **Animations and sounds are placeholders** (`rbxassetid://PLACEHOLDER`, never fake IDs). Gameplay timing still runs from the animation markers, and simple procedural arm poses stand in until you add real animations. See [ASSETS.md](ASSETS.md).
- **Models are procedural** (parts built in code). Drop real models into `ServerStorage` to override them, as described in ASSETS.md.
- Crafting, production buildings, more NPCs, daily quests, visiting and weather are later phases (see [ARCHITECTURE.md §20](ARCHITECTURE.md#20-complete-implementation-order)).
