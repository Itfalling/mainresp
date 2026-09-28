# Build Your Island: Technical Architecture

This document is the blueprint for the whole game. Phase 1 (Island Core) and the **first playable loop** (gathering, building, farming, fishing, animals, market and tutorial quests: the core of phases 2–7 and 10) are implemented in `src/`. The sections for later phases set out the contracts those phases must follow, so they plug in without rewrites.

Legend: ✅ implemented · 🔜 planned (phase number in brackets)

> **The big rework** replaced several early designs. Where an older section below disagrees with this box, the box wins:
> - **Unique islands.** Fixed expansion "areas" are gone. Each island is a set of 16-stud **chunks** grown from a seed + shape (`Shared/Util/IslandGen`), with a **theme**. Players buy any chunk next to their land and paint the terrain. See §8.
> - **Click to interact.** There are no ProximityPrompts. Objects carry the `Interactable` tag and attributes, the client hovers / outlines / clicks, and the server checks distance, permission and what you're holding (`InteractRequest`). See §10.
> - **Keyframed R15 animation** replicated through character attributes (`ActionAnim`, `HoldPose`); every client animates every rig. `AnimationPlayer` / `ProceduralFallback` were removed. See §15.
> - **Multiplayer:** `VisitService` (visit / like / helpers) and `TradeService` (safe trading).
> - **Sounds** use only built-in client files and audio from Roblox's official tutorials (see ASSETS.md).

---

## 1. Complete technical architecture

### Principles

| Rule | How it is enforced |
|---|---|
| Server authority | Clients only send *requests* (`Net.FireServer`). Every reward, currency change, placement and unlock is decided in a server service. |
| One owner per concern | Coins → `EconomyService`. Saving → `DataService`. Islands → `IslandService`. Tools → `ToolService`. Animation → `AnimationService` (sets replicated attributes) + `AnimationController` (plays keyframes on every rig). No other script writes those things. |
| Config over code | Every tunable number lives in `ReplicatedStorage/Shared/Config/*`. The configs are deep-frozen, so a write at runtime errors loudly. |
| No random remotes | `RemoteConfig` lists every remote, including the ones later phases will use. `Net` refuses unknown names. |
| Animation-first | Mechanics react to animation markers; the server times effects to the same `AnimationConfig` marker times the keyframes use. |
| Honest assets | No invented asset IDs. Animations are keyframes in code, sounds are built-in client files or IDs from Roblox's official docs, and anything unverified is a labelled `rbxassetid://PLACEHOLDER` that is skipped. |
| R15 only | `Shared/Util/R15` is the single source of part/motor names. The code never references R6 parts. |
| Layered dependencies | A service may only `require` services listed above it in `Main.server.luau`, so require cycles can't happen. |

### Runtime data flow

```text
 CLIENT                                   SERVER
 ──────                                   ──────
 InputController ── action ──► ToolController / InventoryController / IslandController
                                    │ Net.FireServer("EquipToolRequest", id)
                                    ▼
                             Net (rate limit + pcall) ──► ToolService / IslandService / ...
                                                              │ validate → mutate via
                                                              ▼
                                                         DataService.Set(path, value)
                                                              │ dirty flag + batched op
 ClientState ◄──────────── StateSync {Ops} ◄──────────────────┘
     │ Observe("Coins") etc.
     ▼
 UIController (counters, "+25 🪙" floats), Hotbar, Island panel, Backpack
```

Feedback (sound, VFX, camera) also travels server → client. Services call `SoundService`/`VFXService`, which fire `PlaySound`/`PlayVFX`/`CameraShake`, and clients render them from pools.

### Service layers (server)

```text
L1  DataService · AntiExploitService · WorldService · SoundService · VFXService · AnimationService
L2  EconomyService · InventoryService · ProgressionService
L3  InteractionService · ToolService
L4  IslandService
L5  PlayerService (lifecycle orchestrator) · AdminService
```

### Controller layers (client)

```text
L1  ClientState · InputController · AudioController · VFXController · CameraController
L2  AnimationController
L3  UIController
L4  InteractionController · ToolController
L5  InventoryController · IslandController
```

Each module exposes `Init()` (create state, register handlers) and `Start()` (connect events, start loops). The entry scripts run all `Init`s, then all `Start`s.

---

## 2. Complete folder hierarchy

Rojo maps `src/` into the place (see `default.project.json`).

```text
ReplicatedStorage
├── Shared                                   (src/ReplicatedStorage/Shared)
│   ├── Net                                  ✅ the only remote layer
│   ├── Config
│   │   ├── GameConfig                       ✅ global knobs, data/anti-exploit/world settings
│   │   ├── InputConfig                      ✅ action → key/gamepad bindings
│   │   ├── IslandConfig                     ✅ slots, chunks, themes, shapes, expansion cost, paint palette, starter layout
│   │   ├── ItemConfig                       ✅ item registry (merges item sources)
│   │   ├── ResourceConfig                   ✅ wood, stone, fiber, clay, sand, water, ores...
│   │   ├── RarityConfig                     ✅ Common → Mythic
│   │   ├── ToolConfig                       ✅ 9 tool types × tiers, grips, animations
│   │   ├── AnimationConfig                  ✅ every animation: length, priority, markers, marker effects
│   │   ├── SoundConfig                      ✅ every sound (built-in client files + official-docs IDs)
│   │   ├── VFXConfig                        ✅ procedural effects
│   │   ├── EconomyConfig                    ✅ currencies
│   │   ├── ProgressionConfig                ✅ XP curves, titles, XP sources
│   │   ├── RemoteConfig                     ✅ every remote + rate limits
│   │   ├── BuildConfig / BuildingConfig     ✅ grid rules · 13 buildings with costs, steps, housing
│   │   ├── CropConfig                       ✅ 7 crops, growth stages, farm plot layout
│   │   ├── FishConfig                       ✅ 19 fish, 4 zones, reel minigame tuning
│   │   ├── AnimalConfig                     ✅ cow + chicken, variants, care model
│   │   ├── ShopConfig                       ✅ seeds, animals, tool upgrades, farm/backpack upgrades
│   │   ├── QuestConfig                      ✅ 4-quest tutorial chain
│   │   ├── RecipeConfig                     🔜 [8]
│   │   ├── WeatherConfig / EventConfig      🔜 [13]
│   ├── Util
│   │   ├── Signal · Maid · TableUtil · Format · Validate · Serializer   ✅
│   │   ├── RateLimiter · AssetId · R15 · IslandLayout                   ✅
│   │   └── IslandGen · Placement · CropGrowth · AnimalMath              ✅ shared by server + client
│   ├── Building
│   │   └── BuildingModels                   ✅ procedural staged building models + ghost
│   └── Animation
│       └── Keyframes                        ✅ R15 keyframe actions, hold poses, NPC idle
└── Remotes                                  ✅ created at runtime by Net.Init()

ServerScriptService
└── Server                                   (src/ServerScriptService/Server)
    ├── Main (Script)                        ✅ boot order
    ├── Services
    │   ├── DataService                      ✅
    │   ├── AntiExploitService               ✅
    │   ├── WorldService                     ✅ (world/lighting/ocean; WeatherService takes over lighting in [13])
    │   ├── SoundService                     ✅ server → client sound requests
    │   ├── VFXService                       ✅ server → client effect requests
    │   ├── AnimationService                 ✅
    │   ├── EconomyService                   ✅
    │   ├── InventoryService                 ✅
    │   ├── ProgressionService               ✅
    │   ├── InteractionService               ✅
    │   ├── ToolService                      ✅
    │   ├── IslandService                    ✅
    │   ├── PlayerService                    ✅
    │   ├── AdminService                     ✅
    │   ├── ResourceService / GatherService  ✅ pooled nodes, tool-tier checks, respawn
    │   ├── BuildService                     ✅ validation, atomic cost, hammer construction, move/delete
    │   ├── FarmService / CropService        ✅ till → plant → water → harvest, timestamp growth
    │   ├── FishingService                   ✅ server-rolled fish, bite window, reel anti-cheat
    │   ├── AnimalService                    ✅ housing, feeding, happiness, milk/eggs, pet
    │   ├── ShopService (+ demand in Economy) ✅ sell / buy at the market stall
    │   ├── CraftingService / ProductionService / StorageService 🔜 [8]
    │   ├── NPCService / QuestService        ✅ merchant NPC · tutorial quest chain (more NPCs [10])
    │   ├── AchievementService               🔜 [11]
    │   ├── VisitorService                   🔜 [12]
    │   └── WeatherService / EventService    🔜 [13]
    ├── Data
    │   ├── DataSchema                       ✅ template, migration, repair
    │   └── MockDataStore                    ✅ Studio fallback
    ├── Island
    │   ├── IslandBuilder                    ✅ terrain + props per slot
    │   ├── IslandProps                      ✅ procedural placeholder props (market stall, fishing spots...)
    │   ├── NodeModels · CropModels · AnimalModels  ✅ procedural trees/rocks, crop stages, cow/chicken
    ├── Tools
    │   └── ToolModelFactory                 ✅ placeholder tool models / custom-art loader
    └── Util
        └── Notify                           ✅ toast/banner helper

ServerStorage                                (art overrides; all optional)
├── Buildings  NPCs  Animals  Resources  VFX
├── Tools                                    e.g. ServerStorage/Tools/WoodenAxe (Handle + Grip)
└── Islands/Props                            e.g. ServerStorage/Islands/Props/StarterChest

StarterPlayer
└── StarterPlayerScripts
    └── Client                               (src/StarterPlayer/StarterPlayerScripts/Client)
        ├── Main (LocalScript)               ✅ boot order
        ├── ClientState                      ✅ read-only profile mirror
        ├── Controllers
        │   ├── InputController              ✅
        │   ├── AudioController              ✅
        │   ├── VFXController                ✅
        │   ├── CameraController             ✅
        │   ├── AnimationController          ✅
        │   ├── UIController                 ✅
        │   ├── InteractionController        ✅
        │   ├── ToolController               ✅
        │   ├── InventoryController          ✅
        │   ├── IslandController             ✅
        │   ├── QuestController              ✅ quest card (what to do next)
        │   ├── BuildController              ✅ build mode: ghost preview, expand, paint, move/delete/clear
        │   │   (Client/Build/LandEditor)    ✅ expand tiles + paint brush
        │   ├── FarmController               ✅ seed picker, crop timers
        │   ├── FishingController            ✅ bobber, bite alert, reel minigame, catch card
        │   ├── AnimalController             ✅ animal status billboards
        │   ├── ShopController               ✅ market window (sell / buy)
        │   ├── TradeController              ✅ trade invites + window
        │   ├── PlayersController            ✅ players list: visit / trade / go home
        │   ├── SocialController             ✅ emotes + settings
        │   └── IslandCreatorController      ✅ create-your-island screen with live map
        └── UI
            ├── Theme · Components · HUD · Notifications · Hotbar · InventoryPanel  ✅

StarterGui                                   (empty: UI is built by UIController so it
                                              lives in version control)
```

---

## 3. ModuleScript list

| Module | Side | Phase | Responsibility |
|---|---|---|---|
| Net | shared | 1 | Remote creation, rate limiting, safe handlers |
| GameConfig, InputConfig, IslandConfig, ItemConfig, ResourceConfig, RarityConfig, ToolConfig, AnimationConfig, SoundConfig, VFXConfig, EconomyConfig, ProgressionConfig, RemoteConfig | shared | 1 | Data (see §2) |
| Signal, Maid, TableUtil, Format, Validate, Serializer, RateLimiter, AssetId, R15, IslandLayout | shared | 1 | Utilities |
| Keyframes, IslandGen | shared | rework | Keyframe animation data · unique island generator |
| VisitService, TradeService | server | rework | Visiting, likes, helpers · safe trading |
| DataService, AntiExploitService, WorldService, SoundService, VFXService, AnimationService, EconomyService, InventoryService, ProgressionService, InteractionService, ToolService, IslandService, PlayerService, AdminService | server | 1 | Services |
| DataSchema, MockDataStore, IslandBuilder, IslandProps, ToolModelFactory, Notify | server | 1 | Server helpers |
| ClientState, 10 controllers, 6 UI modules | client | 1 | Client |
| ResourceService, GatherService | server | 2 | Trees/rocks, pooled nodes, gathering |
| BuildService (+ BuildConfig, BuildingConfig) | server | 3 | Placement, construction |
| FarmService, CropService (+ CropConfig) | server | 4 | Plots, crops |
| FishingService (+ FishConfig) | server | 5 | Casting, bites, catches |
| AnimalService (+ AnimalConfig) | server | 6 | Animals, happiness, production |
| ShopService | server | 7 | Buying, market |
| CraftingService, ProductionService, StorageService (+ RecipeConfig) | server | 8 | Processing |
| NPCService, QuestService (+ QuestConfig) | server | 10 | NPCs, quests, tutorial |
| AchievementService | server | 11 | Achievements, collection book |
| VisitorService | server | 12 | Visits, permissions, likes |
| WeatherService, EventService (+ WeatherConfig, EventConfig) | server | 13 | Weather, day/night, events |

## 4. ServerScript list

Exactly one Script: `ServerScriptService/Server/Main`. Everything else is a ModuleScript that Main boots. This keeps start order deterministic.

## 5. LocalScript list

Exactly one LocalScript: `StarterPlayerScripts/Client/Main`. The default R15 `Animate` script that Roblox inserts into characters stays in place. `AnimationService` writes real movement IDs into it when you provide them.

---

## 6. RemoteEvent list

All are RemoteEvents in `ReplicatedStorage/Remotes`, created by `Net.Init()` from `RemoteConfig`.

**Client → Server** (rate-limited per player; see `RemoteConfig.RateLimits`)

| Remote | Payload | Handled by |
|---|---|---|
| ClientReady | none | DataService (replies with a full StateSync) |
| EquipToolRequest / HotbarRequest | `toolOrItemId` (`""` = empty hands) / hotbar edit | ToolService |
| InteractRequest | `object: Instance` (what you clicked) | InteractionService → the kind's handler |
| SwingRequest | none (cosmetic swing at nothing) | ToolService |
| EmoteRequest | `"Wave" \| "Cheer" \| "Point" \| "Dance"` | PlayerService |
| CreateIslandRequest | `{Theme, Shape, Seed, Name}` | IslandService |
| ExpandIslandRequest | `cx, cz` | IslandService |
| PaintTerrainRequest | `{ {X, Z}, ... } (≤ 24), material` | IslandService |
| RenameIslandRequest / IslandSettingsRequest | `name` / `{Visitors}` or `{Helper, Allowed}` | IslandService |
| RemoveNodeRequest | `nodeId` (clear a wild tree / rock) | ResourceService |
| BuildRequest / DeleteBuildRequest / MoveBuildRequest | `{Op="Place", BuildingId, X, Z, Rotation}` / `uniqueId` / `uniqueId, x, z, rotation` | BuildService |
| FishingRequest | `{Op = "Cast" (Target) \| "Hook" \| "Reel", ...}` | FishingService |
| SellItemRequest / PurchaseRequest | `itemId, quantity` / `shopItemId, quantity` | ShopService |
| VisitRequest / LikeRequest | `userId` (`0` = go home) / `userId` | VisitService |
| TradeRequest | `{Op = Invite \| Respond \| Offer \| Coins \| Ready \| Cancel, ...}` | TradeService |
| SettingsRequest | `{MusicVolume?, SfxVolume?, CameraShake?}` | PlayerService |
| CraftRequest | reserved | (later phase) |

Remotes with no handler yet are drained by `Net.FinalizeHandlers()`, and firing one adds an anti-exploit strike.

**Server → Client**

| Remote | Payload |
|---|---|
| StateSync | `{Full = profile}` or `{Ops = {{Path, Value}, ...}}` |
| Notify | `{Kind = Toast/Success/Error/Banner, Text, Subtitle?, Icon?, Style?}` |
| PlaySound | `soundName, position?` |
| PlayVFX | `effectName, position` |
| CameraShake | `intensity (capped), duration` |
| OpenUI | `{Screen = Market \| IslandSettings \| IslandInfo, ...}` |
| FishingEvent | cast / bite / result packets |
| TradeEvent | `{Op = Invite \| State \| Closed, ...}` |

Animations are **not** a remote: they replicate as character attributes (`ActionAnim`, `HoldPose`, `Held`) and animal attributes (`AnimalAnim`).

---

## 7. Workspace structure

```text
Workspace
├── Terrain                 ocean (WorldService) + island land (IslandBuilder)
├── Islands                 one Model per online player
│   └── Island_<UserId>     attributes: OwnerUserId, IslandId, SlotIndex, IslandName, IslandLevel
│       ├── Terrain         (reserved for part-based terrain details)
│       ├── Props           spawn pad, dock, house plot, farm plot
│       ├── Interactables   StarterChest, IslandSign
│       ├── AreaMarkers     🔒 unlock signs (attribute AreaId)
│       ├── Buildings       [3]  one Model per structure (attrs OwnerUserId, IslandId, BuildingId, UniqueId)
│       ├── Decorations     palms, flowers; player decor [3]
│       ├── Resources       [2]  pooled trees/rocks
│       ├── Crops           [4]
│       ├── Animals         [6]
│       ├── Production      [8]
│       └── FishingSpots    [5]
├── ResourceZones           shared/world resource areas [9]
├── NPCs                    [10]
├── FishingZones            shared fishing water volumes [5]
├── World                   shared scenery / hub
├── ClientAudio             (client-only) pooled 3D sound emitters
└── ClientEffects           (client-only) pooled VFX parts
```

`Workspace.StreamingEnabled = true`. Islands are 1000 studs apart, so each client streams its own island.

---

## 8. Island architecture

**Slots.** Each server has `GameConfig.MaxIslandsPerServer` slots on a grid (`IslandLayout.GetSlotOrigin`). A joining player takes the lowest free slot, and it is freed only after their data is saved and the terrain is cleared.

**Island-local coordinates.** All layout data and all saved positions (buildings, crops, animals) are relative to the slot origin. A saved island therefore loads into any slot on any server. Use `IslandService.ToLocal` / `ToWorld`.

**Identity and ownership.** Each island has three identifiers:

- `Island.IslandId`: a GUID created once and saved in the profile.
- `OwnerUserId`: stored as an attribute and in server maps.
- The runtime `Island` record, which `IslandService` holds in `islandsByPlayer` and `islandsById`.

Ownership is never inferred from position alone. `IslandService.GetIslandFromInstance()` walks up to the model's `IslandId` attribute and resolves it through the server map.

**Generation (`Shared/Util/IslandGen`, pure and shared by server and client).**
- The island is a set of owned **chunks** (`"cx_cz"`, 16×16 studs) on a 27×27 grid around the slot origin.
- `GenerateStarter(seed, shape)` grows ~52–64 chunks from a forced central plaza with a priority frontier shaped by the chosen **shape** field (Round, Crescent, Twin, Long, Wild) plus seeded noise, then fills pockets, so every seed gives a different, connected coastline.
- `NewSampler(islandData):Sample(x, z)` gives height, material, shore distance and ownership. The coast follows the signed distance to the owned-chunk union pushed outward and wobbled by noise. Beaches rise with a smoothstep, hills scale with the theme's `HillAmp`, the plaza is flattened, and materials come from the **theme** (Ground / Alt / Beach / Cliff / Seabed) or the player's **paint** (8-stud cells).
- `ChunkSpots` / `AllSpots` place 0–2 resource nodes per chunk from theme weights (rarer ore further out); `ChunkDeco` scatters theme decorations.

**Terrain (`Server/Island/IslandTerrain`).** A single `Terrain:WriteVoxels` (4-stud resolution) writes an island or one expanded chunk. During expansion the land rises in 8 blended steps with sound, VFX and a camera shake, and players standing there are lifted.

**Expansion.** `ExpandIslandRequest(cx, cz)` requires a chunk next to your land and inside the grid, `count < MaxChunks(islandLevel)` (starter + 24 + 12 per level) and coins (`ExpansionCost`: 100 plus linear and quadratic growth, rounded to 10). The client shows the candidates as glowing tiles (build mode → Expand).

**Customisation.** Paint (13 materials, free, ≤ 3000 cells), rename (TextService-filtered), plant Nature buildings (saplings, boulders), clear wild nodes (`RemovedNodes`), and add soil tiles.

**Boundaries.** `Placement.IsOnLand(sampler, center, size)`: every footprint corner must be owned, at least 4 studs inland and above the beach. Client preview and server validation use the same function.

**Permissions.** `IslandService.CanAccess(player, island, permission)`: the owner can do everything, **helpers** get Gather / Farm / Animals / Hammer, and visitors get Visitor / Fish / Market. `VisitService` enforces the visitor mode (Everyone / Friends / Nobody) and tracks where each player is (`OnIsland` attribute).

## 9. Build system architecture (Phase 3)

- **BuildingConfig**: `{ Id, Category, DisplayName, Cost = {Coins, Items}, Footprint = Vector2, Height, UnlockIslandLevel, Model = "ServerStorage/Buildings/<Id>", Stages = {...}, BuildSteps = n, XP }`. Categories: Homes, Farm, Production, Utility, Decoration.
- **BuildConfig**: `GridSize` (from `GameConfig.BuildGridSize`), `RotationStep = 90`, `MaxSlope`, `PlacementRange`, `Cooldown`.
- **Client BuildController**:
  1. Enter build mode. `CameraController.SetMode("Build")` runs, world clicks pause and `Interact` is blocked, so Q/E rotate.
  2. A ghost preview snaps to the grid, raycasting against terrain only.
  3. Client-side validity check (bounds via `Placement.IsOnLand`, overlap via `GetPartBoundsInBox`) tints the ghost green or red.
  4. Confirming sends `BuildRequest(buildingId, localPos, yaw)`.
- **Server BuildService** validates everything in §141: owner, distance, ID, unlock, cost (atomic `InventoryService.RemoveItems` + `EconomyService.SpendCoins`), bounds, yaw ∈ {0, 90, 180, 270}, overlap, and cooldown. It then spawns a **construction site** (`BuildingState = "Constructing"`, `Progress = 0`).
- **Construction:** the player holds the hammer and clicks the site (`InteractRequest`, kind `ConstructionSite`). The server plays HammerSwing and applies the step at its `HammerHit` marker time. The server rate-limits it and advances `Progress` by 1 / `BuildSteps`. Model pieces tagged `BuildStage = n` become visible as progress crosses each stage. The final step plays HammerHeavy → BuildFinish, then a completion reveal: dust + sparkle, `BuildComplete` sound, banner, and `ProgressionService.Award("BuildComplete")`. Both staged-model and piece-reveal buildings are supported through the `Stages` table.
- **Save format** (Island.Buildings): `{ BuildingId, UniqueId, Position = {X, Y, Z} (island-local), Rotation, Variant, State, Progress }`. On load, every entry is validated: known ID, in bounds, no overlap. Invalid entries go to Quarantine.

## 10. Resource architecture (Phase 2)

- `ResourceConfig` gains **node types**: `Tree = { Resource = "Wood", Health = 100, ToolType = "Axe", MinTier = 1, Drops = {Min, Max}, Respawn = 45, XPSource = "ChopTree" }`, plus Rock, FiberBush, ClayPatch and so on.
- **ResourceService** spawns nodes per island from `IslandGen.AllSpots` (theme weights per chunk) and respawns the 3×3 chunk area when land is added. Nodes are **pooled**: states are Visible → Depleted (hidden, parts kept) → Respawned. Instances are never created or destroyed per harvest. Each node has `NodeId`, `IslandId` and `NodeType` attributes plus a CollectionService tag.
- **Gathering flow (click to interact):**
  1. The player holds an axe and hovers a tree: it outlines green with "🪓 Chop · Oak Tree" (`InteractionController`).
  2. A click faces the tree, predicts the swing locally (`AnimationController.PlayLocal`) and sends `InteractRequest(treeModel)`. If it's far away, the character walks there first.
  3. `InteractionService` checks the bounding-box distance and permission, then calls the `ResourceNode` handler (`GatherService.TryGather`).
  4. The server validates the **held** tool's type and tier (`ToolService.GetHeld`), cooldown and node health, plays the swing for everyone (`ActionAnim`) and applies the hit at the marker time.
  5. The server applies damage = `tool.Power`. On depletion it rolls drops (plus `tool.ResourceBonus`), calls `InventoryService.AddItem`, `ProgressionService.Award`, and the WoodChips/RockChips VFX and TreeFall/RockBreak sounds.
- Stats (`WoodCollected`, `StoneCollected`) already increment in InventoryService.

## 11. Farming architecture (Phase 4)

- **CropConfig**: `{ SeedCost, GrowTime, Stages = 6, SellValue, XP, Season?, Rarity, WaterBoost }`, plus crop items merged into ItemConfig.
- **Plots** live in the starter `FarmPlot` zone, later in placed farm buildings. Each tile is saved as `{ CropId, Position (local), PlantedAt, Watered, Fertilized }`.
- Growth is computed from **server timestamps**, never ticked per frame: `stage = f((now − PlantedAt) × multipliers)`. Visuals update only when the stage changes. Offline growth uses the same formula, capped (§102).
- Flow: till (HoeTill `Till` marker) → plant (PlantSeed `Plant` marker) → water (WaterPlant `Water` marker) → harvest (HarvestCrop `Pick` marker). Every step is a `*CropRequest` validated per §142.
- Automation (sprinklers, fertilizer, greenhouses) are modifiers in the multiplier stack (Phase 14).

## 12. Animal architecture (Phase 6)

- **AnimalConfig**: `{ Housing = "Barn", Produce = "Milk", ProduceTime, Food, HappinessDecay, Variants = {Brown, Spotted, Golden...} }`.
- **Save format**: `{ AnimalId, UniqueId, Variant, Position, Happiness, Hunger, ProduceReadyAt }`.
- **Simulation tiers (§114)**, re-evaluated every 2 s by distance to the nearest player:
  - CLOSE: state machine at 5 Hz with wander and pathing.
  - MEDIUM: 1 Hz.
  - FAR: no movement; timers only.
  All tiers use one scheduler loop, not per-animal loops.
- Rigs use `AnimationController` + `Animator`, played through server `AnimationService` with the Cow* entries already in AnimationConfig.
- **Milk flow:** FeedAnimal → happiness ↑ → `ProduceReadyAt` reached → the player equips the Bucket → MilkCow (non-interruptible) → the `Milk` marker triggers the server grant → Milk item + MilkSplash + sound + float.

## 13. Fishing architecture (Phase 5)

- **FishConfig**: fish (`Rarity, Value, WeightRange, Difficulty, Zones, XP`) plus zone loot tables (`StarterPond`, `River`, `Ocean`, `Cave`, `AncientLake`).
- **Server-authoritative encounter:**
  1. `FishingRequest{Op = "Cast"}`. The server checks that the rod is equipped, the player is near a FishingSpot or zone, and the cooldown has passed.
  2. The server picks the fish (a weighted roll, modified by rod tier, events and weather) and a bite time, and stores the encounter server-side.
  3. At the bite time, the server tells the client and starts a reaction window.
  4. The client runs the reeling minigame (keep the indicator in the target zone) and streams `Op = "Reel"` progress at a low rate.
  5. The server checks timing plausibility: minimum duration by difficulty and the reaction window. On success it grants the fish.
  The client never names the fish.
- Rod grip is `RightHand` via `ToolGrip` (§77). Casting uses FishingCast `Cast` marker → bobber arc. Catch uses FishingCatch `Catch` marker → splash and reveal UI (a special reveal for rare-and-up).

## 14. Economy architecture

- **Currencies** (`EconomyConfig`): Island Coins (primary) and Gems. Event tokens are added as new currency entries.
- **Only `EconomyService` changes currencies.** Every call carries a `reason`. Large gains are logged by AntiExploitService.
- **Prices** are defined once, on item definitions (`SellValue`). The Phase 7 market multiplies them by `EconomyConfig.GlobalSellMultiplier` × rarity × active market demand. Market events are announced through Notify and shown in the Sell UI (§65).
- **Sell flow (§145):** `SellItemRequest(itemId, qty)` → validate → `InventoryService.RemoveItem` → server computes the price → `EconomyService.AddCoins`. The client sees the new coin count, and the `+N 🪙` float fires automatically.
- **Sinks:** land expansion (quadratic cost), tools, seeds, animals, buildings, soil tiles, saplings, upgrades. **Player trading** moves coins and items between players (never creates them).
- **Fair monetization (§96):** Robux sells cosmetics and optional convenience only. No progression item is Robux-exclusive.

## 15. Animation architecture

- **AnimationConfig**: every animation with `Id` (optional uploaded animation), `Priority`, `Length`, `Looped`, `Markers`, `MarkerEffects` (sound + VFX + shake at a marker) and `Interruptible`. Names are globally unique through a flat `Index`.
- **Keyframes** (shared): the actual motion. `Actions[name] = { Keys = { {T, Pose, Ease} }, Legs? }` for R15 joints (`Root`, `Waist`, `Neck`, shoulders / elbows / wrists, hips / knees / ankles), `Holds[name]` upper-body hold poses (HoldAxe, HoldRod, HoldItem...), and `NPCIdle`. T is a fraction of the config `Length`, so impacts line up with markers.
- **Server AnimationService** replicates animation as **attributes**: `PlayAnimation(rig, name)` sets `ActionAnim = "Name;ServerTime;Speed;Seq"`, `SetHoldPose(rig, pose)` sets `HoldPose`, and `PerformAction(player, name, marker, callback)` locks the player, plays the action and runs the gameplay callback at the marker time.
- **Client AnimationController** tracks every player character and every `NPCRig`-tagged model within 180 studs. Each `RunService.Stepped` it samples the active action (synced to server time), blends it with the hold pose and writes `Motor6D.Transform`. It fires `MarkerEffects` locally and exposes `PlayLocal` for instant prediction of your own actions. With a real uploaded `Id`, it plays that `AnimationTrack` instead.
- **Animals** (cow, chicken) are built with `Motor6D` limbs. The server sets `AnimalAnim` (Idle / Walk / Eat / Happy) and clients animate legs, head, tail and wings procedurally.
- **Tool grip:** a `Motor6D` named `ToolGrip` from `RightHand` (C0 = `RightGripAttachment`) to the held model's `Handle` (C1 = `Grip`). Holdable items (seed sacks, crops) use the same grip.

See `docs/ASSETS.md` for tweaking keyframes or swapping in uploaded animations.

## 16. DataStore architecture

- **One key per player** (`Player_<UserId>` in `BuildYourIsland_PlayerData_v1`). The record is `{ Data = profile, SessionLock = { Id, JobId, PlaceId, Time }, SavedAt }`.
- **Profile** (`DataSchema`): Coins, Gems, XP, Level, Inventory, Tools, Island (IslandId, Name, Level, XP, Created, Seed, Theme, Shape, Chunks, Paint, RemovedNodes, Access {Visitors, Helpers}, Buildings, Crops (per soil tile), Animals, Upgrades, Storage, Production, Likes, Visits), Social (likes given, trades, visits), Quests, Achievements, Collection, Recipes, Cosmetics, Stats, Settings, Flags, Meta, and Quarantine. This covers everything listed in §97.
- **Load:** `UpdateAsync` takes the session lock. If another live server holds it, the load waits and retries, then takes over a stale lock (Studio takes it immediately). Retries use exponential backoff. **If loading fails, the player is kicked with a friendly message and nothing is saved** (§148).
- **Migrations:** v1 → v2 starter kit; v2 → v3 turns the old areas into a chunk island (seeded from the IslandId, +10 chunks per extra area, land claimed under every building) and the old farm tiles into SoilTile buildings (growing crops move with them).
- **Repair:** `DataSchema.Sanitize` migrates, reconciles, fixes types, clamps numbers, and moves unknown IDs to `Quarantine`. Quarantined IDs are restored automatically when they become valid again.
- **Save:** `UpdateAsync` checks that we still own the lock; otherwise it cancels, stops saving and kicks the player ("opened in another server"). `DataSchema.IsSaveable` gates every write. JSON size is monitored.
- **When saves happen:** dirty-flag autosave (`AutosaveInterval`, staggered), a lock refresh every `SessionLockTimeout / 4`, `ReleaseProfile` on leave (after a `ProfileReleasing` hook so services can serialize live state), and `BindToClose` for all remaining profiles.
- **Replication:** `DataService.Set/Increment/Update` mark the profile dirty and queue `{Path, Value}` ops, flushed once per frame per player in one `StateSync` packet. Private keys (Quarantine) never leave the server.
- **Studio:** with API access off, an in-memory `MockDataStore` runs the identical code path.
- **Offline progress (§102)** uses `Meta.LastSavedAt` versus `os.time()`, with strict caps per system.

## 17. Security architecture

| Layer | Mechanism |
|---|---|
| Transport | `Net`: known remotes only; token-bucket rate limit per player per remote; handlers wrapped in `pcall`; unhandled remotes drained and flagged |
| Arguments | `Validate` (types, finite numbers, integer ranges, ID patterns, Vector3 magnitude) at the top of every handler |
| Authority | Amounts, rewards, prices and XP come only from server config. Clients send intents (IDs), never values. |
| Ownership | `IslandService.CanAccess` for every island action. The InteractionService resolver checks it on every prompt. Owner-only prompts are hidden client-side but still validated. |
| Distance | Server-side distance checks on interactions (and on build, gather and fish in later phases) |
| Anti-exploit | Strike system with a time window. Nothing is kicked for a single oddity; there are warn and kick thresholds (no kicks in Studio). Signals: rate limits, invalid IDs, speed sampling, too-far interactions, large currency gains |
| Data | Session locks, save gating, no blank overwrite, quarantine instead of deletion |
| Admin | `AdminService` runs only for whitelisted UserIds (or in Studio), parses commands server-side, and routes them through normal services |

## 18. UI architecture

- One `ScreenGui` (`IslandUI`, `ResetOnSpawn = false`, `CoreUISafeInsets`) authored at **1280×720 design size** and scaled with `UIScale`, so it fits phones, tablets, PC and console.
- Layers: HUD (TopBar, Left, Right, Bottom and Touch slots) → Modals (Backpack...) → Overlay (toasts, banners, floats).
- A **Theme** module holds all colours and fonts. **Components** provides Create, Button (with press bounce and click sound), Pill, ProgressBar, Panel and Bounce.
- Frames are created once, updated in place, and pooled (item cards, float labels, VFX).
- **State-driven:** UI observes `ClientState` keys. Coin and item feedback is automatic, based on value diffs.
- **Mobile:** 64 px+ touch targets, tap an object to use it, a USE button while something is held (auto-targets what's in front of you), the left menu buttons, and a collapsible island panel that starts collapsed on touch.
- Implemented: BuildMode UI (categories left, info right, controls bottom), seed picker, crop/animal billboards, fishing minigame + catch card, Market window, quest card under the island panel. Planned: Settings [16].

---

## 19. First playable milestone

Spec §157 lists 18 steps. All of them are implemented (see [PLAYABLE_LOOP.md](PLAYABLE_LOOP.md) for how to play and test each one):

| # | Step | Status |
|---|---|---|
| 1 | Spawn on your own island | ✅ |
| 2–3 | Gather wood / stone | ✅ Hold the axe / pickaxe and click the tree / rock: swing, health bar, trees fall, nodes respawn |
| 4–5 | Build a house with a construction animation | ✅ Build mode ghost → construction site → hammer hits reveal the house stage by stage |
| 6–8 | Plant, grow and harvest crops | ✅ Till → plant → water → 6 growth stages → harvest |
| 9–10 | Fish and catch fish | ✅ Cast → bite → reel minigame → catch card |
| 11–12 | Sell items, earn coins | ✅ Market stall: Sell tab, Sell All, market demand bonus |
| 13–14 | Buy a cow, milk it | ✅ Barn → buy cow → feed wheat → milk when READY |
| 15 | Expand the island | ✅ Buy any chunk next to your land (build mode → Expand); it rises from the sea with the theme's trees and decorations |
| 16–18 | Save, leave, rejoin, see progress | ✅ buildings, crops (keep growing offline), animals, quests all save |

The "Start Your Island" quest chain walks a new player through the whole loop in order.

## 20. Complete implementation order

| Phase | Name | Adds to the loop |
|---|---|---|
| 1 ✅ | Island Core | Island, data, HUD, backpack, tools, interaction, expansion, admin |
| 2 ✅ | Resource Gathering | Trees, rocks, Axe/Pickaxe gathering, respawn pools |
| 3 ✅ | Building System | Build mode, preview, validation, marker-driven construction, move/delete |
| 4 ✅ | Farming | Tilling, seeds, growth stages, watering, harvesting, crop sales |
| 5 ✅ | Fishing | Zones, cast/bite/reel minigame, rarities, catch reveal |
| 6 ✅ | Animals | Cows/chickens, housing, happiness, production timers, milking |
| 7 ✅ | Economy + Shop | Market, sell UI, shops, tool upgrades, market demand |
| 8 | Production + Crafting | Workshop, mill, bakery, dairy, smoker, queues |
| 9 | Island Expansion content | Resources and zones for each area; area unlock UI polish |
| 10 (part ✅) | NPCs + Quests | ✅ merchant NPC + tutorial quest chain · 🔜 farmer, fisher, carpenter, blacksmith; daily quests |
| 11 | Progression | Achievements, collection book, titles |
| 12 | Visitors + Social | Visiting, permissions, likes, showcase, naming (TextService filtering), themes |
| 13 | Events + Weather | Weather, day/night, meteor showers, festivals, wandering merchant |
| 14 | Automation | Sprinklers, auto feeders and collectors, conveyors |
| 15 | Data + Security | Hardening pass, offline progress caps, load tests |
| 16 | UI Polish | Settings, transitions, mobile layout pass |
| 17 | Performance | Streaming, pooling audits, remote traffic, NPC/animal tiers |
| 18 | Polish | Lighting, terrain, real animations, VFX, audio, onboarding |

Each phase ships with setup steps, a testing checklist, and changes that never rename existing systems, remotes or data keys.
