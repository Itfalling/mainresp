# Build Your Island: Technical Architecture

This document is the blueprint for the whole game. Phase 1 (Island Core) is implemented in `src/`. The sections for later phases set out the contracts those phases must follow, so they plug in without rewrites.

Legend: ✅ implemented in Phase 1 · 🔜 planned (phase number in brackets)

---

## 1. Complete technical architecture

### Principles

| Rule | How it is enforced |
|---|---|
| Server authority | Clients only send *requests* (`Net.FireServer`). Every reward, currency change, placement and unlock is decided in a server service. |
| One owner per concern | Coins → `EconomyService`. Saving → `DataService`. Islands → `IslandService`. Tools → `ToolService`. Animation → `AnimationPlayer` (shared core). No other script writes those things. |
| Config over code | Every tunable number lives in `ReplicatedStorage/Shared/Config/*`. The configs are deep-frozen, so a write at runtime errors loudly. |
| No random remotes | `RemoteConfig` lists every remote, including the ones later phases will use. `Net` refuses unknown names. |
| Animation-first | Mechanics react to animation markers. Placeholder animations still fire markers, driven by config timing. |
| Honest assets | Every animation/sound ID is `rbxassetid://PLACEHOLDER`. Systems skip placeholders gracefully. |
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
│   │   ├── IslandConfig                     ✅ slots, geometry, 8 expansion areas, starter layout
│   │   ├── ItemConfig                       ✅ item registry (merges item sources)
│   │   ├── ResourceConfig                   ✅ wood, stone, fiber, clay, sand, water, ores...
│   │   ├── RarityConfig                     ✅ Common → Mythic
│   │   ├── ToolConfig                       ✅ 9 tool types × tiers, grips, animations
│   │   ├── AnimationConfig                  ✅ every animation (placeholders) + markers
│   │   ├── SoundConfig                      ✅ every sound (placeholders)
│   │   ├── VFXConfig                        ✅ procedural effects
│   │   ├── EconomyConfig                    ✅ currencies
│   │   ├── ProgressionConfig                ✅ XP curves, titles, XP sources
│   │   ├── RemoteConfig                     ✅ every remote + rate limits
│   │   ├── BuildConfig / BuildingConfig     🔜 [3]
│   │   ├── CropConfig                       🔜 [4]
│   │   ├── FishConfig                       🔜 [5]
│   │   ├── AnimalConfig                     🔜 [6]
│   │   ├── RecipeConfig                     🔜 [8]
│   │   ├── QuestConfig                      🔜 [10]
│   │   ├── WeatherConfig / EventConfig      🔜 [13]
│   ├── Util
│   │   ├── Signal · Maid · TableUtil · Format · Validate · Serializer   ✅
│   │   ├── RateLimiter · AssetId · R15 · IslandLayout                   ✅
│   └── Animation
│       ├── AnimationPlayer                  ✅ shared load/cache/play/marker core
│       └── ProceduralFallback               ✅ prototype arm poses for placeholders
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
    │   ├── ResourceService / GatherService  🔜 [2]
    │   ├── BuildService                     🔜 [3]
    │   ├── FarmService / CropService        🔜 [4]
    │   ├── FishingService                   🔜 [5]
    │   ├── AnimalService                    🔜 [6]
    │   ├── ShopService (+ market in Economy) 🔜 [7]
    │   ├── CraftingService / ProductionService / StorageService 🔜 [8]
    │   ├── NPCService / QuestService        🔜 [10]
    │   ├── AchievementService               🔜 [11]
    │   ├── VisitorService                   🔜 [12]
    │   └── WeatherService / EventService    🔜 [13]
    ├── Data
    │   ├── DataSchema                       ✅ template, migration, repair
    │   └── MockDataStore                    ✅ Studio fallback
    ├── Island
    │   ├── IslandBuilder                    ✅ terrain + props per slot
    │   └── IslandProps                      ✅ procedural placeholder props
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
        │   ├── BuildController              🔜 [3]
        │   ├── FarmController               🔜 [4]
        │   ├── FishingController            🔜 [5]
        │   ├── AnimalController             🔜 [6]
        │   ├── ShopController               🔜 [7]
        │   └── QuestController              🔜 [10]
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
| AnimationPlayer, ProceduralFallback | shared | 1 | Animation core |
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

| Remote | Payload | Handled by | Phase |
|---|---|---|---|
| ClientReady | none | DataService, which replies with a full StateSync | ✅ 1 |
| EquipToolRequest | `toolId: string` (`""` = unequip) | ToolService | ✅ 1 |
| UnlockAreaRequest | `areaId: string` | IslandService | ✅ 1 |
| GatherRequest | `nodeId` | GatherService | 2 |
| BuildRequest / DeleteBuildRequest / MoveBuildRequest | `buildingId, localPosition, yaw` / `uniqueId` | BuildService | 3 |
| PlantCropRequest / WaterCropRequest / HarvestCropRequest | `plotId, cropId?` | FarmService | 4 |
| FishingRequest | `{Op = "Cast" \| "Hook" \| "Reel", ...}` | FishingService | 5 |
| AnimalInteractRequest / MilkAnimalRequest | `animalUniqueId, action` | AnimalService | 6 |
| SellItemRequest / PurchaseRequest / UpgradeRequest | `itemId, quantity` / `productId` | ShopService / EconomyService | 7 |
| CraftRequest | `recipeId, stationId` | CraftingService | 8 |
| QuestRequest | `questId, action` | QuestService | 10 |
| IslandPermissionRequest / IslandVisitRequest | `setting` / `targetUserId` | VisitorService | 12 |
| SettingsRequest | `key, value` | PlayerService | 16 |

Remotes with no handler yet are drained by `Net.FinalizeHandlers()`, and firing one adds an anti-exploit strike.

**Server → Client**

| Remote | Payload |
|---|---|
| StateSync | `{Full = profile}` or `{Ops = {{Path, Value}, ...}}` |
| Notify | `{Kind = Toast/Success/Error/Banner, Text, Subtitle?, Icon?, Style?}` |
| PlaySound | `soundName, position?` |
| PlayVFX | `effectName, position` |
| CameraShake | `intensity (capped), duration` |
| AnimationCommand | `{Op = Play/Stop/StopAll/Speed, Name, Speed?, Fade?}` |

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

**Terrain.** Smooth terrain is used for organic shores. Each area is built as three stacked cylinders: shallows sand, beach sand, and a surface in the biome material. Hills are sunk spheres. Locked areas appear as underwater sandbars, which preview the land to come. When an area is unlocked, the land rises in 12 steps with a ring VFX, a sound and a camera shake. `ClearTerrain` restores the ocean when the player leaves.

**Expansion areas** (`IslandConfig.Areas`, in unlock order):

| # | Area | Unlock | What it adds (§120) |
|---|---|---|---|
| 1 | Starter Island | none | Home, farm plot, dock |
| 2 | Whispering Forest | 500 🪙, Island Lv 2 | Hardwood, fiber, berries |
| 3 | Sunny Fields | 1.5K 🪙, Lv 4, after Forest | Big farms, pastures |
| 4 | Willow River | 4K 🪙, Lv 7 | Better fishing, clay |
| 5 | Coral Beach | 8K 🪙, Lv 10 | Ocean fishing, sand, shells |
| 6 | Stonepeak Mountain | 15K 🪙, Lv 14 | Stone, iron, copper |
| 7 | Starfall Cove | 40K 🪙, Lv 20 | Crystals, gold, epic fish |
| 8 | Great Mainland | 100K 🪙, Lv 30 | Huge late-game build space |

**Boundaries.** `IslandService.IsPointBuildable(island, worldPos)` returns true only if the point is on unlocked land, minus `BuildMargin`. BuildService (Phase 3) and FarmService (Phase 4) must call it.

**Permissions.** `IslandService.CanAccess(player, island, permission)` returns true for the owner. For anyone else, only `"Visitor"` actions pass today. In Phase 12, VisitorService adds Friends/Public modes and per-permission grants (Build, Fish, Farm, UseShops) in this one function.

---

## 9. Build system architecture (Phase 3)

- **BuildingConfig**: `{ Id, Category, DisplayName, Cost = {Coins, Items}, Footprint = Vector2, Height, UnlockIslandLevel, Model = "ServerStorage/Buildings/<Id>", Stages = {...}, BuildSteps = n, XP }`. Categories: Homes, Farm, Production, Utility, Decoration.
- **BuildConfig**: `GridSize` (from `GameConfig.BuildGridSize`), `RotationStep = 90`, `MaxSlope`, `PlacementRange`, `Cooldown`.
- **Client BuildController**:
  1. Enter build mode. `CameraController.SetMode("Build")` and `InteractionController.PausePrompts()` run so Q/E rotate instead of triggering prompts.
  2. A ghost preview snaps to the grid, raycasting against terrain only.
  3. Client-side validity check (bounds via `IslandLayout.IsOnUnlockedLand`, overlap via `GetPartBoundsInBox`) tints the ghost green or red.
  4. Confirming sends `BuildRequest(buildingId, localPos, yaw)`.
- **Server BuildService** validates everything in §141: owner, distance, ID, unlock, cost (atomic `InventoryService.RemoveItems` + `EconomyService.SpendCoins`), bounds, yaw ∈ {0, 90, 180, 270}, overlap, and cooldown. It then spawns a **construction site** (`BuildingState = "Constructing"`, `Progress = 0`).
- **Construction** is driven by animation markers. The player hammers: HammerSwing's `HammerHit` marker fires `BuildRequest{Op = "Hammer"}`. The server rate-limits it and advances `Progress` by 1 / `BuildSteps`. Model pieces tagged `BuildStage = n` become visible as progress crosses each stage. The final step plays HammerHeavy → BuildFinish, then a completion reveal: dust + sparkle, `BuildComplete` sound, banner, and `ProgressionService.Award("BuildComplete")`. Both staged-model and piece-reveal buildings are supported through the `Stages` table.
- **Save format** (Island.Buildings): `{ BuildingId, UniqueId, Position = {X, Y, Z} (island-local), Rotation, Variant, State, Progress }`. On load, every entry is validated: known ID, in bounds, no overlap. Invalid entries go to Quarantine.

## 10. Resource architecture (Phase 2)

- `ResourceConfig` gains **node types**: `Tree = { Resource = "Wood", Health = 100, ToolType = "Axe", MinTier = 1, Drops = {Min, Max}, Respawn = 45, XPSource = "ChopTree" }`, plus Rock, FiberBush, ClayPatch and so on.
- **ResourceService** spawns nodes per island from `IslandConfig` zone tables and area biomes. Nodes are **pooled**: states are Visible → Depleted (hidden, parts kept) → Respawned. Instances are never created or destroyed per harvest. Each node has `NodeId`, `IslandId` and `NodeType` attributes plus a CollectionService tag.
- **Gathering flow:**
  1. The player swings (ToolController).
  2. The `Hit` marker fires `ToolController.ToolImpact`.
  3. The client raycasts or overlaps in front of the character to find a node, then sends `GatherRequest(nodeId)`.
  4. The server validates: owner/permission, distance, tool type and tier (`ToolService.GetBestTool`), cooldown (`ToolConfig.UseCooldown`), and node health.
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
- **Sinks:** area unlocks (✅ now), tools, seeds, animals, buildings, decorations, upgrades.
- **Fair monetization (§96):** Robux sells cosmetics and optional convenience only. No progression item is Robux-exclusive.

## 15. Animation architecture

- **AnimationConfig**: every animation from spec §12, §19, §21, §26, §32 and §72 with `Id` (placeholder), `Priority`, `Length`, `Looped`, `Markers`, `MarkerEffects`, `BodyParts`, `Start`/`End`, `Interruptible` and `Fallback`. Names are globally unique through a flat `Index`.
- **AnimationPlayer** (shared): one per rig.
  - Caches `Animation` objects per ID and `AnimationTrack`s per rig, so nothing is loaded twice.
  - Maps priorities to the enum and enforces the `Interruptible` flag.
  - Offers Play / Stop / StopAll / SetSpeed / IsPlaying / GetHandle.
  - Handles behave the same for real and placeholder IDs:
    - **Real ID:** `GetMarkerReachedSignal`. A *watchdog* fires any configured marker the uploaded animation forgot, and warns once.
    - **Placeholder:** a virtual track fires markers at the configured times (scaled by speed) and `Ended` after `Length`.
- **Client AnimationController**: owns the local character's player, applies `MarkerEffects` (sound + VFX + shake at the marker), and re-emits `MarkerReached` for gameplay.
- **Server AnimationService**: `PlayAnimation(rig, name)` forwards to the owning client for player characters, or plays directly for NPC/animal rigs. It writes real movement IDs into the default `Animate` script.
- **ProceduralFallback**: while IDs are placeholders, the local character gets simple shoulder poses (Swing, Dig, Cheer...) so marker timing is visible during prototyping. Disable it with `AnimationConfig.UseProceduralFallback = false`.
- **Tool grip**: a `Motor6D` named `ToolGrip` from `RightHand` (C0 = `RightGripAttachment`) to the tool's `Handle` (C1 = `Grip` attachment). Animators can keyframe the tool.

See `docs/ASSETS.md` for authoring and importing the real animations.

## 16. DataStore architecture

- **One key per player** (`Player_<UserId>` in `BuildYourIsland_PlayerData_v1`). The record is `{ Data = profile, SessionLock = { Id, JobId, PlaceId, Time }, SavedAt }`.
- **Profile** (`DataSchema`): Coins, Gems, XP, Level, Inventory, Tools, Island (IslandId, Name, Level, XP, Theme, Permission, UnlockedAreas, Buildings, Decorations, Crops, Animals, Storage, Production, Likes, Visits), Quests, Achievements, Collection, Recipes, Cosmetics, Stats, Settings, Flags, Meta, and Quarantine. This covers everything listed in §97.
- **Load:** `UpdateAsync` takes the session lock. If another live server holds it, the load waits and retries, then takes over a stale lock (Studio takes it immediately). Retries use exponential backoff. **If loading fails, the player is kicked with a friendly message and nothing is saved** (§148).
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
- **Mobile:** 64 px+ touch targets, a USE button while a tool is equipped, the 🎒 button, ProximityPrompt tap buttons, and a collapsible island panel that starts collapsed on touch.
- Planned: BuildMode UI (categories left, info right, controls bottom) [3], Farm/Animal/Fishing panels [4–6], Shop/Sell [7], Quest list in the island panel [10], Settings [16].

---

## 19. First playable milestone

Spec §157 lists 18 steps. Their status after Phase 1:

| # | Step | Status |
|---|---|---|
| 1 | Spawn on your own island | ✅ |
| 2–3 | Gather wood / stone | Phase 2. Tool equip, swing, markers and the `ToolImpact` hook are ready. |
| 4–5 | Build a house with a construction animation | Phase 3. HammerSwing markers are ready. |
| 6–8 | Plant, grow and harvest crops | Phase 4 (farm plot zone exists) |
| 9–10 | Fish and catch fish | Phase 5 (dock exists) |
| 11–12 | Sell items, earn coins | Phase 7. Coins, the economy and feedback are ready. |
| 13–14 | Buy a cow, milk it | Phase 6 |
| 15 | Expand a section of the island | ✅ Areas unlock through the 🔒 sign or the panel button, with the land-rise effect |
| 16–18 | Save, leave, rejoin, see progress | ✅ |

The milestone is complete when Phases 2–7 land. Each phase adds one link of the loop: gather → build → farm → fish → animals → sell.

## 20. Complete implementation order

| Phase | Name | Adds to the loop |
|---|---|---|
| 1 ✅ | Island Core | Island, data, HUD, backpack, tools, interaction, expansion, admin |
| 2 | Resource Gathering | Trees, rocks, Axe/Pickaxe gathering, respawn pools |
| 3 | Building System | Build mode, preview, validation, marker-driven construction, move/delete |
| 4 | Farming | Tilling, seeds, growth stages, watering, harvesting, crop sales |
| 5 | Fishing | Zones, cast/bite/reel minigame, rarities, catch reveal |
| 6 | Animals | Cows/chickens, housing, happiness, production timers, milking |
| 7 | Economy + Shop | Market, sell UI, shops, tool upgrades, market demand |
| 8 | Production + Crafting | Workshop, mill, bakery, dairy, smoker, queues |
| 9 | Island Expansion content | Resources and zones for each area; area unlock UI polish |
| 10 | NPCs + Quests | Farmer, merchant, fisher, carpenter, blacksmith; tutorial, daily and progression quests |
| 11 | Progression | Achievements, collection book, titles |
| 12 | Visitors + Social | Visiting, permissions, likes, showcase, naming (TextService filtering), themes |
| 13 | Events + Weather | Weather, day/night, meteor showers, festivals, wandering merchant |
| 14 | Automation | Sprinklers, auto feeders and collectors, conveyors |
| 15 | Data + Security | Hardening pass, offline progress caps, load tests |
| 16 | UI Polish | Settings, transitions, mobile layout pass |
| 17 | Performance | Streaming, pooling audits, remote traffic, NPC/animal tiers |
| 18 | Polish | Lighting, terrain, real animations, VFX, audio, onboarding |

Each phase ships with setup steps, a testing checklist, and changes that never rename existing systems, remotes or data keys.
