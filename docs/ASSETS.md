# Animations, Sounds and Art: Replacing Placeholders

**Nothing in this repository is a real Roblox asset ID.** Every animation and sound uses the literal string `rbxassetid://PLACEHOLDER`, and no mesh or decal IDs were invented. The game is built so you can paste real IDs into config files without touching any other code.

| Asset | Config | Behaviour while it's a placeholder |
|---|---|---|
| Animations | `ReplicatedStorage/Shared/Config/AnimationConfig` | Markers fire at the configured times, `Ended` fires after `Length`, and the local player sees a simple procedural arm pose |
| Sounds | `ReplicatedStorage/Shared/Config/SoundConfig` | Silently skipped (logged once when `GameConfig.Debug` is on) |
| Item icons | `ResourceConfig` `Image` field | The UI shows the emoji `Icon` instead |
| Tool models | `ServerStorage/Tools/<ToolId>` | Procedural low-poly model from `ToolModelFactory` |
| Island props | `ServerStorage/Islands/Props/<Name>` | Procedural props from `IslandProps` |

---

## 1. Creating R15 animations

1. In Studio, insert an R15 rig (Avatar tab → Rig Builder → R15, Block or your preferred body).
2. **For tool animations, add the tool joint the game uses** so you can keyframe the tool itself:
   - Add a Part named `Handle` to the rig (or paste your tool model's Handle).
   - Add a `Motor6D` named **`ToolGrip`** inside `RightHand`, with `Part0 = RightHand` and `Part1 = Handle`.
   - The game creates exactly this joint at runtime (see `ToolService`), so keyframes on `Handle` play back correctly.
3. Open the Animation Editor (Avatar tab → Animation Editor), select the rig, and create the animation.
4. Match the **Length** and **Priority** in `AnimationConfig`, or update the config to match your animation.
5. **Add markers.** Right-click the timeline → Add Animation Event, and use exactly the marker names from the config:

   | Animation | Marker(s) | Config time |
   |---|---|---|
   | AxeSwing | `Hit` | 0.30 |
   | AxeHeavySwing | `Hit` | 0.50 |
   | PickaxeSwing | `Hit` | 0.32 |
   | HammerSwing | `HammerHit` | 0.31 |
   | HammerHeavy | `HammerHit` | 0.50 |
   | PlaceWood / PlaceStone | `WoodPlace` / `StonePlace` | 0.40 / 0.45 |
   | BuildFinish | `BuildFinish` | 0.55 |
   | ShovelDig | `Dig` | 0.45 |
   | HoeTill / TillGround | `Till` | 0.38 |
   | PlantSeed | `Plant` | 0.50 |
   | WaterPlant / WaterLoop | `Water` | 0.50 / 0.40 |
   | HarvestCrop / PickCrop | `Pick` | 0.42 / 0.30 |
   | FeedAnimal | `Feed` | 0.50 |
   | MilkCow | `Milk` | 0.60 |
   | PetAnimal | `Pet` | 0.50 |
   | FishingCast | `Cast` | 0.45 |
   | FishingCatch | `Catch` | 0.50 |
   | CraftWork | `CraftHit` | 0.35 |

   If you forget a marker, the **watchdog** in `AnimationPlayer` fires it at the config time anyway and prints a warning telling you which one is missing.
6. Publish: File → Publish to Roblox (or the Animation Editor's "..." → Publish to Roblox). Publish it under the **same owner as the game** (your user or the group), otherwise it won't load.
7. Copy the ID and paste it into `AnimationConfig`:

   ```lua
   HammerSwing = anim({
       Id = "rbxassetid://1234567890",   -- ← your uploaded id
       ...
   }),
   ```

8. Once all the gameplay animations are real, set `AnimationConfig.UseProceduralFallback = false`.

### Movement animations

The `Movement` entries (Idle, Walk, Run, Jump, Fall, Climb, Swim, SwimIdle) are written into the default R15 `Animate` script by `AnimationService.ApplyMovementOverrides`. While they are placeholders, Roblox's default R15 animations are used.

### Priorities (spec §73)

- Movement → `Movement`
- Tool actions and building → `Action`
- Fishing and major interactions → `Action2`
- Celebrations → `Action3`
- Death → `Action4`

Tool **hold** animations (AxeIdle, BuildIdle...) should key only the arms and torso, so walking legs still play.

### Animal rigs (Phase 6)

The Cow* entries target a custom rig driven by an `AnimationController` + `Animator`. The server `AnimationService` plays them with the same API.

---

## 2. Sounds

1. Find sounds in the Creator Store (Toolbox → Audio) that are free to use, or upload your own (Creator Hub → Development Items → Audio).
2. Paste IDs into `SoundConfig.Sounds.<Name>.Id`.
3. Tune `Volume`, `PitchVariation` (a random ± speed that keeps repeated hits from sounding robotic) and `RollOffMaxDistance`.
4. Every important action has its own entry: WoodHit, TreeFall, RockHit, RockBreak, BuildComplete, AreaUnlock, LevelUp, RareReward, Milk and so on. Give them distinct sounds (spec §149).

## 3. Tool models

Create a Model named exactly like the tool ID (e.g. `WoodenAxe`, `IronPickaxe`, `GoldHammer`) in `ServerStorage/Tools`:

```text
WoodenAxe (Model)
├── Handle (Part/MeshPart)
│   └── Grip (Attachment)   ← where the palm holds it
│                             +Y points along the tool towards the head
│                             -Z points where the blade/tip faces
└── Blade (MeshPart)        ← welded to Handle
```

`ToolModelFactory` makes every part massless and non-colliding. `ToolService` joins `Handle` to `RightHand.RightGripAttachment` with the `ToolGrip` Motor6D. For fine-tuning, change `Grip.Offset` for the tool type in `ToolConfig`.

## 4. Island props

Models placed in `ServerStorage/Islands/Props` override the procedural ones by name: `SpawnPad`, `IslandSign`, `StarterChest`, `Dock`, `HousePlot`, `FarmPlot`.

- Build them around the origin, with the base at Y = 0 and the front facing −Z.
- Keep a `PromptAnchor` Attachment where the interaction prompt should appear.
- **StarterChest** needs a `Body` part and a `Lid` part. Add a `ClosedOffset` CFrame attribute on the Lid (`Body.CFrame:ToObjectSpace(Lid.CFrame)`) so it can swing open.
- **IslandSign** needs a `Board` part with a SurfaceGui named `SignGui` containing `Title` and `Subtitle` TextLabels.
