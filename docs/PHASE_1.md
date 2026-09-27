# Phase 1: Island Core

**Goal:** a player joins and gets their own R15-ready island, with saving, coins, a backpack, a HUD, interactions, a camera, tools and the first expansion unlock.

## What you can do in Phase 1

1. Join. A terrain island is built for you in a free server slot, and you spawn on it.
2. A "Welcome to <Name>'s Island!" banner appears. The right panel shows island level, XP, the next area to unlock and a guide tip.
3. Walk to the **Starter Chest** and hold **E** (or tap the prompt). The chest opens and you get an Axe, a Pickaxe, a Hammer, 50 coins and some materials. You see floating "+50 🪙", "+10 🪵 Wood" and similar, a sparkle burst, and a banner.
4. Press **1 / 2 / 3** (or tap the hotbar) to equip a tool. The server welds it to your R15 `RightHand`, and a hold pose plays.
5. Click, or tap **USE** on mobile, to swing. The swing timing comes from AnimationConfig markers (a procedural arm pose until real animations exist).
6. Open the **Backpack** with **B**, **I**, gamepad **Y**, or the 🎒 button. It has tabs, search, sort, item details and Equip/Unequip for tools.
7. Read your **Island Sign**.
8. Walk to a 🔒 **area marker** on the shore. With enough coins and island level, hold E (or press UNLOCK in the panel) and the land rises out of the sea.
9. Leave and rejoin. Coins, items, tools, the equipped tool, the chest state, unlocked areas and island name all persist.

---

## Setup

### Option A: Rojo (recommended)

1. Install [Rokit](https://github.com/rojo-rbx/rokit), then run `rokit install` in this folder. That installs Rojo 7.4.4 (pinned in `rokit.toml`). You can also install Rojo 7.4+ any other way.
2. Install the Rojo Studio plugin (Studio → Plugins → Manage Plugins, or run `rojo plugin install`).
3. Run `rojo serve` in this folder.
4. Open a **new Baseplate** in Studio. Delete the `Baseplate` part and the default `SpawnLocation`; the game builds its own world.
5. In the Rojo plugin, click **Connect**.

### Option B: build a place file

```bash
rojo build default.project.json -o BuildYourIsland.rbxlx
```

Open `BuildYourIsland.rbxlx` in Studio.

### Required Studio settings

| Setting | Where | Why |
|---|---|---|
| **Avatar type: R15** | Game Settings → Avatar | Primary R15 setup. (`GameConfig.Character.ForceR15` rebuilds non-R15 characters as a safety net, but set this anyway.) |
| **Max players ≤ 8** | Game Settings → Places or Server Settings | Must be ≤ `GameConfig.MaxIslandsPerServer` (8) |
| *(optional)* **Enable Studio Access to API Services** | Game Settings → Security (the place must be published) | Real DataStore in Studio. Without it, an in-memory mock is used and progress lasts only for that play session. |
| **Lighting.Technology = Future** | Set by `default.project.json` | Nicer lighting (lower it for low-end testing) |
| **Workspace.StreamingEnabled = true** | Set by `default.project.json` | Performance with 1000-stud island spacing |
| **Players.CharacterAutoLoads = false** | Set by `default.project.json` and PlayerService | Characters spawn only once their island exists |

### Admin commands (Studio: everyone; live game: `GameConfig.AdminUserIds`)

```text
/givecoins me 5000          /givegems me 50
/giveitem me Wood 25        /givetool me IronAxe
/givexp me 500              /giveislandxp me 200
/setislandlevel me 5        /unlockarea me Forest
/save me                    /resetdata me   (Studio only)
/debug me                   (prints island/save state to the server output)
```

These work with both TextChatService (server-side `TextChatCommand`s) and legacy chat.

---

## Script index (delivery format)

The full code for every script is in `src/`. Every file starts with a header block giving SCRIPT NAME, SCRIPT TYPE, WHERE, DEPENDENCIES and REQUIRED OBJECTS where relevant.

### Server: `ServerScriptService/Server`

| Script | Type | Depends on | Notes |
|---|---|---|---|
| `Main` | Script | all services, `Net` | Boots services in layer order |
| `Services/DataService` | ModuleScript | Net, GameConfig, DataSchema, MockDataStore | Session-locked UpdateAsync saves, autosave, BindToClose, replication |
| `Services/AntiExploitService` | ModuleScript | Net, GameConfig, R15 | Strikes, thresholds, speed sampling |
| `Services/WorldService` | ModuleScript | GameConfig, IslandConfig | Workspace folders, lighting, ocean terrain |
| `Services/SoundService` | ModuleScript | Net, SoundConfig | Server → client sound requests |
| `Services/VFXService` | ModuleScript | Net, VFXConfig | Server → client effects and camera shake |
| `Services/AnimationService` | ModuleScript | Net, AnimationPlayer, AnimationConfig | Player (via client) and NPC animation; movement ID overrides |
| `Services/EconomyService` | ModuleScript | DataService, AntiExploitService | The only writer of Coins and Gems |
| `Services/InventoryService` | ModuleScript | DataService, ItemConfig | Capacity, stacks, atomic multi-remove |
| `Services/ProgressionService` | ModuleScript | DataService, Sound/VFX | Player and island XP by source ID |
| `Services/InteractionService` | ModuleScript | AntiExploitService | ProximityPrompt kinds, server checks |
| `Services/ToolService` | ModuleScript | DataService, ToolModelFactory | Ownership, hotbar, R15 Motor6D grip |
| `Services/IslandService` | ModuleScript | most of the above, IslandBuilder | Slots, ownership, access, expansion, chest and sign |
| `Services/PlayerService` | ModuleScript | Data, Island, Tool, Animation, AntiExploit | Join, spawn, R15 guard, respawn, leave |
| `Services/AdminService` | ModuleScript | services above | Secure admin commands |
| `Data/DataSchema` | ModuleScript | configs | Template, migration, repair, save gate |
| `Data/MockDataStore` | ModuleScript | TableUtil | Studio fallback store |
| `Island/IslandBuilder` | ModuleScript | IslandConfig, IslandLayout, IslandProps | Terrain and props per slot |
| `Island/IslandProps` | ModuleScript | none | Procedural sign, chest, dock, palms, plots, markers |
| `Tools/ToolModelFactory` | ModuleScript | none | Placeholder tool meshes, or custom art from ServerStorage |
| `Util/Notify` | ModuleScript | Net | Toast/banner helper |

### Shared: `ReplicatedStorage/Shared`

| Script | Notes |
|---|---|
| `Net` | Remote creation, rate limits, pcall, violation reporting |
| `Config/*` (13 modules) | All tunables. Every asset ID is a clearly marked placeholder. |
| `Util/*` (10 modules) | Signal, Maid, TableUtil, Format, Validate, Serializer, RateLimiter, AssetId, R15, IslandLayout |
| `Animation/AnimationPlayer` | Load, cache, play, markers, watchdog, virtual tracks |
| `Animation/ProceduralFallback` | Prototype poses for placeholder animations |

### Client: `StarterPlayer/StarterPlayerScripts/Client`

| Script | Type | Notes |
|---|---|---|
| `Main` | LocalScript | Waits for load, hides the default Backpack, boots controllers |
| `ClientState` | ModuleScript | Read-only profile mirror with `Observe()` |
| `Controllers/InputController` | ModuleScript | Actions for KB/M, gamepad and touch; device tracking |
| `Controllers/AudioController` | ModuleScript | Pooled 2D/3D sounds; skips placeholders |
| `Controllers/VFXController` | ModuleScript | Pooled bursts and rings; distance culling |
| `Controllers/CameraController` | ModuleScript | Zoom and FOV modes; capped shake |
| `Controllers/AnimationController` | ModuleScript | Local character AnimationPlayer; MarkerEffects |
| `Controllers/UIController` | ModuleScript | ScreenGui, scaling, HUD, notifications, automatic reward feedback |
| `Controllers/InteractionController` | ModuleScript | Prompt highlight, owner-only hiding, pause |
| `Controllers/ToolController` | ModuleScript | Hotbar, equip requests, use and swing, `ToolImpact` signal |
| `Controllers/InventoryController` | ModuleScript | Backpack open/close and sync |
| `Controllers/IslandController` | ModuleScript | Island panel, next-area checklist, welcome banner |
| `UI/Theme`, `UI/Components`, `UI/HUD`, `UI/Notifications`, `UI/Hotbar`, `UI/InventoryPanel` | ModuleScripts | UI kit and screens |

---

## Testing checklist

Run the checks in Studio **Play** (one player), then **Test → Clients and Servers** with 2–3 players.

### Island test
- [ ] The Output shows `[Build Your Island] Server ready — 14 services started` and no errors.
- [ ] Each player gets exactly one island (`Workspace.Islands.Island_<UserId>`), in different slots.
- [ ] The island model's `OwnerUserId` attribute matches the player.
- [ ] The player spawns on their own spawn pad, facing inland.
- [ ] Palms, flowers, dock, house plot, farm plot, chest, sign and seven 🔒 markers are present, sitting on the terrain (not floating or buried).
- [ ] Locked areas show as sandbars under the water.
- [ ] Player B cannot see Player A's chest or unlock prompts. Player B *can* read Player A's sign.
- [ ] When a player leaves, their island model disappears and the ocean is restored (no leftover land).
- [ ] After dying (reset character), you respawn on your own island after about 3 s.

### R15 test
- [ ] `Humanoid.RigType` is R15 and the character has `UpperTorso`, `RightHand` and so on.
- [ ] With Avatar set to R6 in Game Settings, the Output warns and the character is rebuilt as R15 (the ForceR15 safety net).

### Data test
- [ ] In Studio without API access, the Output says the mock is in use, and the game still plays.
- [ ] With API access: open the chest, equip the Axe, `/givecoins me 1000`, `/unlockarea me Forest`, then stop and play again. Coins, items, tools, the equipped Axe, the open chest and the Forest land are all restored.
- [ ] `/debug me` shows `LastSaveResult = Saved` after an autosave (60 s) or `/save me`.
- [ ] Two Studio sessions on the same account do not overwrite each other: the second waits or takes over the lock, and the first is kicked on its next save.

### Economy and inventory test
- [ ] The coin counter animates, bounces, and floats "+N 🪙" on gain and "-N" on spend.
- [ ] `/giveitem me Wood 5` floats "+5 🪵 Wood" and updates the backpack.
- [ ] The backpack header shows `used / capacity`. (`InventoryService.AddItem` enforces capacity for gameplay sources. `/giveitem` deliberately bypasses it, so real enforcement is exercised by Phase 2 gathering.)
- [ ] Backpack tabs, search ("wo") and sort (Name / Amount / Value) work; details show rarity colour and sell value.

### Tool test
- [ ] The hotbar shows the three starter tools after the chest opens.
- [ ] Pressing 1 attaches the Wooden Axe to the **RightHand**. It doesn't float, and it follows the hand.
- [ ] Pressing 1 again unequips. Pressing 2 swaps to the Pickaxe.
- [ ] Other players see the tool in your hand.
- [ ] Clicking swings (procedural pose). A swing cannot be spammed faster than the tool's cooldown.
- [ ] Clicking while the backpack is open does not swing.
- [ ] On a mobile emulator (Studio → Test → Device), the USE button appears while a tool is equipped.

### Interaction test
- [ ] Prompts show `[E] Open Starter Chest`, `[E] Read Island Sign` and `[E] Unlock (500 🪙) Whispering Forest`.
- [ ] The object under the prompt gets a soft outline.
- [ ] The chest can be claimed once only. After a rejoin it is still open and has no prompt.
- [ ] An unlock with too few coins or too low a level shows a clear red error toast.

### Expansion test
- [ ] `/givecoins me 500`, then `/setislandlevel me 2`. The panel checklist turns ✔ and the button says UNLOCK!
- [ ] Unlocking raises the Forest land with a ring VFX, a camera shake and an "AREA UNLOCKED!" banner. The coins are deducted and island XP is awarded.
- [ ] The next area (Sunny Fields) becomes the panel's target and lists "Unlock Whispering Forest" as ✔.

### Security test (Studio command bar on the **client**, or an exploit simulator)
- [ ] `game.ReplicatedStorage.Remotes.EquipToolRequest:FireServer("MythicAxe")` without owning it: nothing is equipped, and a strike is logged.
- [ ] Firing `UnlockAreaRequest` 50 times in a loop gets rate-limited, with strikes logged and no double charge.
- [ ] Firing `GatherRequest` (no handler yet) logs `UnhandledRemote` strikes.
- [ ] `EquipToolRequest` with a table or number argument is rejected safely (no errors in Output).

### Automated logic tests (no Studio needed)

```bash
./tests/run_logic_tests.sh      # needs `luau` on PATH (or LUAU=/path/to/luau)
```

These cover config integrity (every animation, sound, VFX and remote reference resolves), DataSchema repair and quarantine, layout geometry, RateLimiter, Signal, Format, Validate, and AnimationPlayer marker timing for placeholder animations.

---

## Customization

| Change | Where |
|---|---|
| Starting coins, autosave interval, max islands | `GameConfig` |
| What the Starter Chest gives | `GameConfig.StarterKit` |
| Island size, spacing, spawn/chest/dock/plot positions | `IslandConfig` (`Areas.Starter.Radius`, `StarterLayout`) |
| Expansion order, prices, levels, positions | `IslandConfig.Areas` / `AreaOrder` |
| Tool stats and tiers | `ToolConfig.Tiers` / `ToolConfig.Types` |
| Tool art | Put a Model named like the tool ID in `ServerStorage/Tools` (Handle part + Grip attachment) |
| Prop art | Put a Model in `ServerStorage/Islands/Props` (`StarterChest`, `IslandSign`, `SpawnPad`, `Dock`, `HousePlot`, `FarmPlot`) |
| XP amounts and curves, island titles | `ProgressionConfig` |
| Key bindings | `InputConfig` |
| UI colours and fonts | `Client/UI/Theme` |
| Lighting, water, terrain colours | `GameConfig.World` |
| Anti-exploit thresholds | `GameConfig.AntiExploit`, `RemoteConfig.RateLimits` |
| Real animations and sounds | `AnimationConfig`, `SoundConfig` (see `docs/ASSETS.md`) |

## Known limitations (by design for Phase 1)

- **No real animations or sounds ship with the project.** All IDs are placeholders. Markers still fire, so gameplay timing works. Sounds are silent until you add IDs.
- The procedural swing pose is **local-only** (other players see the tool, not the pose) until real animations are uploaded.
- Gathering, building, farming, fishing, animals and selling arrive in Phases 2–7. Their remotes already exist and are safely drained.
- Island names use the default `"<DisplayName>'s Island"`. Custom names with TextService filtering come in Phase 12.
