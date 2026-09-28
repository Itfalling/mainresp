# Animations, Sounds and Art

**No asset ID in this repository is made up.** The game is fully animated and has sound without uploading anything:

| Asset | Where | What ships |
|---|---|---|
| Animations | `Shared/Animation/Keyframes` + `Config/AnimationConfig` | **Real keyframed R15 animations written in code** (every action, hold pose and emote). Optionally swap any of them for an uploaded animation. |
| Sounds | `Config/SoundConfig` | Built-in Roblox client sounds (`rbxasset://sounds/...`) and audio IDs taken from Roblox's official Creator Hub tutorials. Each entry is labelled with its source. |
| Item icons | `ResourceConfig` `Image` field | Emoji `Icon`s in the UI |
| Tool / node / animal / prop models | `ServerStorage/...` | Procedural models built in code; drop your own models in to override them |

---

## 1. Animations

### How they work
`Keyframes` holds poses for the R15 joints (`Waist`, `Neck`, shoulders, elbows, wrists, hips, knees, ankles, `Root`) at fractions of each animation's `Length` from `AnimationConfig`. The server doesn't send animation tracks. It sets two **attributes** on the character:

- `ActionAnim = "Name;ServerStartTime;Speed;Seq"`: the action being played,
- `HoldPose = "HoldAxe"`: the upper-body pose for what's in your hands.

Every client's `AnimationController` reads them for every nearby player and NPC and writes `Motor6D.Transform` each frame. That's why **everyone sees everyone's swings**, perfectly in sync, and your own action starts instantly (predicted locally). Legs stay on Roblox's walk / idle animation unless an action needs them (crouch to plant, hop to cheer). Gameplay **markers** (e.g. `Hit` at 0.30 s of `AxeSwing`) trigger the sound, particles and camera shake on the exact impact frame.

Animals (cow, chicken) have `Motor6D` legs, head, tail and wings driven by the `AnimalAnim` attribute (Idle / Walk / Eat / Happy).

### Swing variants
`AnimationConfig.Variants` lists three swings per tool (e.g. `AxeSwing`, `AxeChopHigh`, `AxeSlash`). Variants copy the base entry's timing (Length, markers, effects, `Trail` window), so gameplay is identical whichever plays; only the keyframes differ. To add a fourth, add its name to the list and its keys to `Keyframes.Actions`. `Trail = { from, to }` is the part of the swing where the tool's `SwingTrail` is visible, and `MarkerEffects.<marker>.Punch` is the camera kick for your own hits.

### Tweaking an animation
Edit its keys in `Keyframes.Actions.<Name>`. The format is documented at the top of the file (angles in degrees, `T` = fraction of the length). Keep the impact key at the marker time from `AnimationConfig`.

### Using an uploaded animation instead (optional)
1. Make the animation in Studio's Animation Editor on an R15 rig. For tool animations, add a Part named `Handle` and a `Motor6D` named **`ToolGrip`** in `RightHand` (`Part0 = RightHand`, `Part1 = Handle`). The game creates exactly this joint at runtime.
2. Add **Animation Events** with the marker names from `AnimationConfig` (`Hit`, `HammerHit`, `Plant`, `Cast`...).
3. Publish it under the **same owner as the game**, then paste the ID into that entry's `Id` in `AnimationConfig`.

`AnimationController` then plays the real track for that animation, and everything else stays on keyframes. **Movement** (idle, walk, run, jump...) uses Roblox's default R15 `Animate` script. Movement entries in `AnimationConfig` with real IDs are written into it by `AnimationService.ApplyMovementOverrides`.

**Mia the Merchant** is a standard R15 body from a `HumanoidDescription` (colours only) dressed with welded parts in `NPCService` (hair, sun hat, apron, sleeves, skirt, boots). Her animations (`MiaIdle`, `MiaWave`, `MiaPresent`, `MiaSold`, `MiaTalk`) are keyframes like the players'.

---

## 2. Sounds

`SoundConfig` uses only two kinds of source:

| Source | Example | Why it's safe |
|---|---|---|
| **BUILTIN** | `rbxasset://sounds/impact_water.mp3` | Ships inside every Roblox client (`content/sounds`). Used: `volume_slider.ogg`, `impact_water.mp3`, `action_jump.mp3`, `action_jump_land.mp3`, `action_footsteps_plastic.mp3`, `impact_explosion_03.mp3`, `action_swim.mp3`. |
| **DOCS** | `rbxassetid://4110925712` | Used in Roblox's official tutorials on create.roblox.com: the feedback chime (*In-game sounds*), retro jingle, chomping and upbeat music (*Add 2D audio*), tool Equip / Activate (*Create player tools*), sliding gate, rain and celebration (*Add 3D audio*) and waterfall ambience (*In-game sounds*). |

`PlaybackSpeed` and `PitchVariation` turn this small set into distinct effects: a slowed explosion is a falling tree, a sped-up thud is a pickaxe hit. **CowMoo, ChickenCluck and AmbienceBirds** have no verified source yet and stay `rbxassetid://PLACEHOLDER` (skipped silently).

To use your own sounds, find free audio in the Creator Store (Toolbox → Audio) or upload your own, then paste the ID into `SoundConfig.Sounds.<Name>`. Music and ambience volume follow the player's ⚙️ Settings.

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

Models placed in `ServerStorage/Islands/Props` override the procedural ones by name: `SpawnPad`, `IslandSign`, `StarterChest`.

- Build them around the origin, with the base at Y = 0 and the front facing −Z.
- Players click them directly (the whole model is the click target), so no prompt anchor is needed.
- **StarterChest** needs a `Body` part and a `Lid` part. Add a `ClosedOffset` CFrame attribute on the Lid (`Body.CFrame:ToObjectSpace(Lid.CFrame)`) so it can swing open.
- **IslandSign** needs a `Board` part with a SurfaceGui named `SignGui` containing `Title` and `Subtitle` TextLabels.

## 5. Resource nodes and animals

- **Trees / rocks:** a Model named after the node's `Model` key (`Oak`, `Palm`, `Pine`, `SnowPine`, `Maple`, `Cactus`, `Rock`, `Iron`, `Crystal`, `Bush`, `Sand`, `Clay`...) in `ServerStorage/Resources` replaces the procedural one (see `NodeModels`).
- **Animals:** `ServerStorage/Animals/<AnimalId>` with an anchored `Body` part (see `AnimalModels`). Add `Motor6D`s named like the built-in ones (`Head`, `LegFL`...) to keep the procedural walk.
