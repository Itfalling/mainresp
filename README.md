# 🏝️ Build Your Island

An original Roblox island-building progression game. You start on a tiny island and grow it into a thriving, personalized one by gathering, building, farming, fishing, raising animals, selling goods, and expanding.

> *"I started with almost nothing, and now I built an entire island."*

## Status

| Phase | | |
|---|---|---|
| 1. Island Core | ✅ **playable** | Own island per player, R15, saving, coins, backpack, HUD, tools, interactions, camera, area expansion |
| 2–18 | 🔜 | See [docs/ARCHITECTURE.md §20](docs/ARCHITECTURE.md#20-complete-implementation-order) |

## Quick start

```bash
rokit install            # installs Rojo (pinned in rokit.toml)
rojo serve               # then Connect from the Rojo plugin in a new Baseplate
# or
rojo build default.project.json -o BuildYourIsland.rbxlx
```

In Studio, set **Game Settings → Avatar → R15**. Optionally enable **Studio Access to API Services** to test real saving.

Full setup, admin commands and the testing checklist are in **[docs/PHASE_1.md](docs/PHASE_1.md)**.

## Documentation

- **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)**: the complete technical architecture. It covers the folder hierarchy, every module, remote and system (island, build, resource, farming, animal, fishing, economy, animation, data, security, UI), the first playable milestone, and the implementation order.
- **[docs/PHASE_1.md](docs/PHASE_1.md)**: what Phase 1 does, setup, script index, testing checklist, customization.
- **[docs/ASSETS.md](docs/ASSETS.md)**: how to replace the placeholder animations, sounds and models with real assets.

## Project layout

```text
src/
├── ReplicatedStorage/Shared      configs, Net, utilities, animation core
├── ServerScriptService/Server    Main + services (server-authoritative)
└── StarterPlayer/.../Client      Main + controllers + UI
tests/                            engine-free logic tests (luau CLI)
docs/                             architecture & phase guides
```

## Honesty about assets

This repository contains **no real animation or sound IDs**. Every one is `rbxassetid://PLACEHOLDER` and clearly labelled. The game runs without them: animation markers still drive gameplay timing, and placeholder sounds are skipped. When you paste in real IDs, nothing else needs to change. See [docs/ASSETS.md](docs/ASSETS.md).

## Development checks

```bash
./tests/run_logic_tests.sh                                  # logic tests (needs `luau`)
rojo sourcemap default.project.json -o sourcemap.json
luau-lsp analyze --sourcemap=sourcemap.json --defs=<roblox globalTypes.d.luau> --platform=roblox src
```
