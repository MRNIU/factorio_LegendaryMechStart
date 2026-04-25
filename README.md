# Legendary Mech Start

A Factorio 2.0 Space Age mod that drops every player into a fully-equipped legendary mech armor at spawn and seeds the team with enough industrial gear to go interplanetary on day one.

## What it does

- **Legendary mech armor on spawn** for every player (single-player, host and late joiners in multiplayer). The equipment grid is packed automatically from a prioritised wishlist, so adding or removing items only takes editing the list.
- **Personal starter kit** in each player's inventory: bootstrap materials, personal construction and logistic robots, defensive turrets, temporary wiring and piping, spare ammunition and repair packs.
- **Team resource cache** placed once per save into legendary steel chests at map spawn: rocket silo, space-platform starter pack, all end-game production buildings (foundry, electromagnetic plant, biochamber, cryogenic plant, biolab, ...), modules, 4000 turbo belts, the legendary solar/accumulator array, etc. The placer is non-destructive — it only uses open tiles within 15 tiles of `(0, 0)` and spills the remainder on the ground if the spawn area is crowded.
- **Freeplay intro cleanup**: the mod re-runs after the cutscene finishes, so the default pistol and firearm magazines Freeplay hands out are removed.
- **Quality-aware**: every inserted stack declares its `quality` explicitly. End-game production buildings are legendary; bulk infrastructure (belts, pipes, chests, poles) stays normal on purpose.
- **Multiplayer-aware**: the team cache is deposited on the first `on_player_created` in the save and tracked with `storage.team_cache_placed`, so cutscene replays and late joiners never duplicate it.
- **Safe on missing prototypes**: every insert checks `prototypes.item[name]` / `prototypes.equipment[name]` first, so disabled DLC or renamed prototypes are silently skipped rather than crashing the save.

## Equipment grid (legendary `mech-armor`, 15 × 17)

All items legendary; positions computed by a first-fit packer at runtime.

| Category | Item | Count |
| :-- | :-- | :-: |
| Power | Fusion Reactor | 6 |
| | Battery MK3 | 7 |
| | Solar Panel | fills remaining 1×1 gaps |
| Defense | Energy Shield MK2 | 4 |
| | Personal Laser Defense | 3 |
| Mobility | Exoskeleton | 10 |
| | Belt Immunity | 1 |
| Utility | Personal Roboport MK2 | 4 |
| | Night Vision | 1 |
| | Toolbelt | 5 (provides +125 main-inventory slots) |

Steady-state draw is ~10–15 MW; peak (all four roboports charging simultaneously) approaches ~96 MW and is buffered by the MK3 batteries. Six legendary fusion reactors deliver 37.5 MW sustained.

## Personal pack (every player's inventory)

| Category | Item | Quality | Count |
| :-- | :-- | :-: | :-: |
| Weapons (slot-filled) | Submachine Gun | Legendary | 3 |
| Ammo (slot-filled) | Uranium Rounds Magazine | Legendary | 600 (200 × 3 slots) |
| Spare ammo | Uranium Rounds Magazine | Legendary | 200 |
| Repair | Repair Pack | Normal | 50 |
| Raw materials | Iron / Copper Plate | Normal | 100 each |
| | Steel Plate / Stone Brick / Concrete | Normal | 50 each |
| | Coal | Normal | 100 |
| Robots | Construction Robot | Normal | 100 |
| | Logistic Robot | Normal | 50 |
| Wiring | Medium Electric Pole | Normal | 50 |
| Piping | Pipe | Normal | 50 |
| | Pipe to Ground | Normal | 20 |
| Defense | Laser Turret | Normal | 20 |

## Team cache (legendary chests at map spawn, once per save)

| Category | Item | Quality | Count |
| :-- | :-- | :-: | :-: |
| Raw materials | Iron / Copper Plate | Normal | 400 each |
| | Steel Plate / Stone Brick | Normal | 150 each |
| | Concrete / Landfill | Normal | 450 / 500 |
| | Plastic Bar / Sulfur | Normal | 200 each |
| | Coal | Normal | 400 |
| Starter power | Big Electric Pole | Normal | 50 |
| | Substation | Normal | 100 |
| | Substation | Legendary | 50 |
| | Solar Panel / Accumulator | Legendary | 400 each |
| Logistics network | Construction Robot | Normal | 100 |
| | Logistic Robot | Normal | 150 |
| | Roboport | Legendary | 20 |
| | Steel Chest + 5 Logistic Chest variants | Normal | 50 each |
| Inserters | Long-handed / Fast | Normal | 200 each |
| | Bulk / Stack | Normal | 50 each |
| Transport | Turbo Transport Belt | Normal | 4000 |
| | Turbo Underground / Splitter | Normal | 200 / 100 |
| Production | Assembling Machine 3 | Legendary | 100 |
| | Electric Furnace | Legendary | 100 |
| | Oil Refinery | Legendary | 10 |
| | Chemical Plant | Legendary | 20 |
| | Foundry | Legendary | 20 |
| | Electromagnetic Plant | Legendary | 20 |
| | Biochamber | Legendary | 20 |
| | Cryogenic Plant | Legendary | 20 |
| | Biolab | Legendary | 10 |
| Modules & Beacons | Beacon | Legendary | 20 |
| | Speed / Efficiency / Productivity Module 3 | Legendary | 200 / 100 / 200 |
| Mining & Fluids | Big Mining Drill | Legendary | 40 |
| | Offshore Pump / Pumpjack | Legendary | 20 each |
| | Pump | Normal | 50 |
| | Pipe / Pipe to Ground | Normal | 150 / 80 |
| Space | Rocket Silo | Legendary | 1 |
| | Cargo Landing Pad | Normal | 1 |
| | Space Platform Starter Pack | Normal | 1 |
| | Low Density Structure | Normal | 500 |
| | Rocket Fuel | Normal | 200 |
| | Processing Unit | Normal | 400 |
| Military | Uranium Rounds Magazine | Legendary | 800 |
| | Uranium-235 (Kovarex seed) | Normal | 40 |
| | Laser Turret | Normal | 80 |
| | Repair Pack | Normal | 50 |

## Multiplayer behaviour

| Event | Personal pack | Team chests |
| :-- | :-: | :-: |
| Host / single player, first `on_player_created` | re-granted | spawned near `(0, 0)` |
| Host `on_cutscene_finished` (wipes Freeplay's pistol) | re-granted | already placed, not re-spawned |
| Late joiner `on_player_created` | granted | already placed, not re-spawned |

## Design notes

- **Total stacks** (first player: personal + everything they personally carry) fit well under the 330 main-inventory slots granted by legendary mech-armor (+125) and five legendary toolbelts (+125). The inventory delivery therefore has no overflow fallback.
- **Team cache placement** is anchored to `LuaForce::get_spawn_position(surface)` — the force's configured spawn (`(0, 0)` on vanilla Nauvis) — rather than the character's actual position. This keeps the cache at map origin even when a sibling mod (e.g. [BestLanding](https://github.com/MRNIU/factorio_BestLanding)) pushes the player far from spawn by filling the area with a landing blueprint.
- If no free tile exists within 15 tiles of `(0, 0)`, any items that could not be placed into a chest are spilled on the ground — the placer never destroys existing entities.

## Installation

1. Download the mod file.
2. Drop it into your Factorio `mods` folder.
3. Launch Factorio and enable the mod in the mod list.
4. Start a new game.

## Compatibility

- Factorio 2.0.76 or newer.
- Requires `base`, `space-age`, `quality`.

## License

MIT — see [LICENSE](LICENSE).

## Author

- **NZH** — zhihong@nzhnb.com
- Repository: <https://github.com/MRNIU/factorio_LegendaryMechStart>

## Changelog

See [changelog.txt](changelog.txt).
