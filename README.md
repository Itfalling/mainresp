# 🏝️ Build Your Island

An original Roblox island-building progression game. You start on a tiny island and grow it into a thriving, personalized one by gathering, building, farming, fishing, raising animals, selling goods, and expanding.

> *"I started with almost nothing, and now I built an entire island."*

## Status

| Phase | | |
|---|---|---|
| 1. Island Core | ✅ | Own island per player, R15, DataStore saving (session-locked, migrations, repair), coins, backpack, HUD, tools, camera |
| **First playable loop** (2–7 + tutorial) | ✅ **playable** | Chop & mine, build houses with real construction, farm, fish (reel minigame), cows & chickens, market sell/buy with demand, quest chain |
| **Rework** | ✅ | **Unique islands** (seed + shape + theme, expand in any direction, paint terrain, plant trees, clear land) · **click to interact** with what you hold (no prompts) · **keyframed R15 animations** everyone sees · **sounds + music** · **visit islands, likes, helpers** · **safe trading** · emotes · settings · polished UI, lighting and models |
| 8–18 | 🔜 | Crafting, more NPCs, weather events... See [docs/ARCHITECTURE.md §20](docs/ARCHITECTURE.md#20-complete-implementation-order) |

## Quick start

**Easiest:** open **`BuildYourIsland.rbxl`** (in this repository; `BuildYourIsland.rbxlx` is the same place as text) in Roblox Studio and press **Play**.

Or with Rojo:

```bash
rokit install            # installs Rojo (pinned in rokit.toml)
rojo serve               # then Connect from the Rojo plugin in a new Baseplate
# or
rojo build default.project.json -o BuildYourIsland.rbxlx
```

In Studio, set **Game Settings → Avatar → R15**. Enable **Game Settings → Security → Studio Access to API Services** to test real DataStore saving. To try visiting and trading, use **Test → Clients and Servers → 2 players**.

**How to play, controls, admin commands and the testing checklist: [docs/PLAYABLE_LOOP.md](docs/PLAYABLE_LOOP.md).** Setup details: [docs/PHASE_1.md](docs/PHASE_1.md).

## Documentation

- **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)**: the complete technical architecture. It covers the folder hierarchy, every module, remote and system (island, build, resource, farming, animal, fishing, economy, animation, data, security, UI), the first playable milestone, and the implementation order.
- **[docs/PLAYABLE_LOOP.md](docs/PLAYABLE_LOOP.md)**: how to play the full loop, controls, admin commands, testing checklist, new script index.
- **[docs/PHASE_1.md](docs/PHASE_1.md)**: what Phase 1 does, setup, script index, testing checklist, customization.
- **[docs/ASSETS.md](docs/ASSETS.md)**: how the animations and sounds work, where every sound comes from, and how to swap in your own art.

## Project layout

```text
src/
├── ReplicatedStorage/Shared      configs, Net, utilities, island generator, keyframe animations
├── ServerScriptService/Server    Main + services (server-authoritative)
└── StarterPlayer/.../Client      Main + controllers + UI
tests/                            engine-free logic tests (luau CLI)
docs/                             architecture & phase guides
```

## Honesty about assets

**No asset ID in this repository is made up.** Animations are real R15 keyframes written in code. Sounds are either files built into the Roblox client (`rbxasset://sounds/...`) or audio IDs from Roblox's official Creator Hub tutorials, each labelled with its source. The few sounds without a verified source (animal calls, birds) are clearly marked `rbxassetid://PLACEHOLDER` and skipped. See [docs/ASSETS.md](docs/ASSETS.md).

## Development checks

```bash
./tests/run_logic_tests.sh                                  # logic tests (needs `luau`)
rojo sourcemap default.project.json -o sourcemap.json
luau-lsp analyze --sourcemap=sourcemap.json --defs=<roblox globalTypes.d.luau> --platform=roblox src
```
