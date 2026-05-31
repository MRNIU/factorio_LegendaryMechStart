# Legendary Mech Start

A Factorio 2.0 Space Age mod that drops every player into fully-equipped legendary mech armor, seeds the team with enough industrial gear to go interplanetary on day one, and can place a legendary spidertron on each planet.

## What it does

- **Legendary mech armor on spawn** for every player (single-player, host and late joiners in multiplayer). The equipment grid is packed automatically from a prioritised wishlist, so adding or removing items only takes editing the list.
- **Personal starter kit** in each player's inventory: bootstrap materials, personal construction and logistic robots, defensive turrets, temporary wiring and piping, spare ammunition and repair packs. Inventory items are inserted after the character main inventory is available and at least one tick after the mech armor is equipped so toolbelt bonuses can refresh first.
- **Team resource cache** delivered once per save. If legendary spidertrons are enabled, the Nauvis team resources are loaded into the Nauvis spidertron trunk instead of being placed on the ground. If spidertrons are disabled, the same Nauvis cache is placed into normal steel chests near map spawn.
- **Optional seven-color legendary science packs** can be enabled with a runtime-global map setting before the team resource cache is delivered.
- **Optional legendary spidertron on each planet**: a fully-equipped legendary spidertron is spawned once per planet surface, then loaded one tick later with a common maintenance kit plus planet-specific cargo. Nauvis/Vulcanus/Gleba also receive a normal-quality defense package and dedicated spidertron ammo-slot rockets.
- **Freeplay intro cleanup**: the mod re-runs after the cutscene finishes, so the default pistol and firearm magazines Freeplay hands out are removed.
- **Quality-aware**: every inserted stack declares its `quality` explicitly. Core production assets, mining drills, pumpjacks, recyclers, agricultural towers, modules, and beacons are legendary; bulk infrastructure, robots, roboports, chests, inserters, power equipment, weapons, ammo, and consumables stay normal on purpose.
- **Multiplayer-aware**: the team resources are tracked with `storage.team_cache_placed`, so cutscene replays and late joiners never duplicate them.
- **Safe on missing prototypes and unexpected overflow**: every insert checks `prototypes.item[name]` / `prototypes.equipment[name]` first. The intended path fits in the target inventory; if an unexpected partial insert still happens, the remainder is logged and spilled near the player or spidertron.

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

## Spidertron grid (legendary `spidertron`, 15 × 11)

All items legendary; positions are computed by the same first-fit packer used for mech armor. The current wishlist uses exactly 165 cells.

| Category | Item | Count |
| :-- | :-- | :-: |
| Power | Fusion Reactor | 4 |
| | Battery MK3 | 5 |
| Mobility | Exoskeleton | 6 |
| Defense | Energy Shield MK2 | 3 |
| | Personal Laser Defense | 2 |
| Utility | Personal Roboport MK2 | 2 |
| | Toolbelt | 5 |

The toolbelts are intentional: the starter spidertron carries more than a normal spidertron trunk comfortably holds once robots, power parts, logistics chests, rockets, and repair packs are included.

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

## Spidertron cargo and fallback team cache

All planet spidertrons receive the common maintenance kit below. If spidertron spawning is disabled, the fallback Nauvis team cache uses the same common kit, defense kit, and Nauvis-specific cargo in normal steel chests near map spawn.

| Scope | Item | Quality | Count |
| :-- | :-- | :-: | :-: |
| Common | Construction Robot | Normal | 500 |
| | Logistic Robot | Normal | 200 |
| | Roboport | Normal | 20 |
| | Repair Pack | Normal | 200 |
| | Big Electric Pole / Substation | Normal | 50 each |
| | Steel Chest | Normal | 50 |
| | Active Provider / Passive Provider / Storage / Requester / Buffer Chest | Normal | 50 each |
| | Fast Inserter | Normal | 100 |
| | Bulk / Stack Inserter | Normal | 50 each |
| Defense: Nauvis/Vulcanus/Gleba only | Rocket / Explosive Rocket | Normal | 200 each |
| | Atomic Bomb | Normal | 10 |
| | Laser Turret | Normal | 50 |
| | Spidertron ammo slot: Rocket | Normal | 400 |

| Planet | Item | Quality | Count |
| :-- | :-- | :-: | :-: |
| Nauvis | Rocket Silo | Legendary | 1 |
| | Cargo Landing Pad | Normal | 1 |
| | Space Platform Starter Pack | Normal | 1 |
| | Assembling Machine 3 / Electric Furnace | Legendary | 100 / 400 |
| | Oil Refinery | Legendary | 20 |
| | Chemical Plant / Foundry / Electromagnetic Plant / Biochamber / Cryogenic Plant | Legendary | 80 / 20 / 20 / 20 / 20 |
| | Biolab | Legendary | 10 |
| | Automation (red) / Logistic (green) / Chemical (blue) / Military (black) / Utility (yellow) / Production (purple) / Space (white) Science Pack (setting enabled) | Legendary | 1600 / 1600 / 1000 / 600 / 500 / 300 / 200 |
| | Centrifuge | Legendary | 50 |
| | Beacon | Legendary | 100 |
| | Speed / Productivity / Efficiency Module 3 | Legendary | 1000 / 400 / 100 |
| | Big Mining Drill | Legendary | 60 |
| | Pumpjack | Legendary | 20 |
| | Offshore Pump | Normal | 20 |
| | Uranium-235 | Normal | 100 |
| | Radar | Legendary | 50 |
| | Turbo Transport Belt | Normal | 4000 |
| | Turbo Underground Belt / Turbo Splitter | Normal | 200 / 100 |
| Vulcanus | Foundry / Big Mining Drill | Legendary | 30 each |
| | Calcite | Normal | 1000 |
| | Tungsten Ore / Tungsten Plate / Tungsten Carbide | Normal | 500 each |
| | Carbon | Normal | 500 |
| | Pipe / Pipe to Ground / Pump | Normal | 300 / 150 / 50 |
| | Foundation | Normal | 200 |
| Fulgora | Recycler | Legendary | 50 |
| | Electromagnetic Plant | Legendary | 30 |
| | Lightning Rod / Lightning Collector | Normal | 100 / 50 |
| | Accumulator / Scrap | Normal | 1000 each |
| | Holmium Ore / Holmium Plate | Normal | 500 each |
| | Superconductor / Supercapacitor | Normal | 200 each |
| Gleba | Biochamber / Agricultural Tower | Legendary | 30 each |
| | Heating Tower / Rocket Turret | Normal | 10 / 20 |
| | Carbon Fiber / Landfill | Normal | 200 / 500 |
| Aquilo | Cryogenic Plant | Legendary | 30 |
| | Heating Tower | Normal | 20 |
| | Heat Pipe | Normal | 500 |
| | Heat Exchanger / Steam Turbine | Normal | 50 each |
| | Rocket Fuel / Ice Platform | Normal | 500 each |
| | Concrete / Refined Concrete | Normal | 1000 each |
| | Lithium / Lithium Plate | Normal | 500 each |
| | Quantum Processor | Normal | 100 |
| | Fusion Reactor / Fusion Generator / Fusion Power Cell | Normal | 2 / 8 / 100 |

## Multiplayer behaviour

| Event | Personal pack | Team resources |
| :-- | :-: | :-: |
| Host / single player, first `on_player_created` | re-granted | queued for Nauvis spidertron, or chests if spidertrons are disabled |
| Host `on_cutscene_finished` (wipes Freeplay's pistol) | re-granted | already delivered, not duplicated |
| Late joiner `on_player_created` | granted | already delivered, not duplicated |

## Design notes

- **Personal inventory capacity** is checked through `LuaInventory::insert` after the character main inventory is available and at least one tick after legendary mech-armor and five toolbelts are equipped. The designed loadout should fit; unexpected leftovers are logged and spilled near the player.
- **Fallback team cache placement** is anchored to `LuaForce::get_spawn_position(surface)` — the force's configured spawn (`(0, 0)` on vanilla Nauvis) — rather than the character's actual position. This keeps the cache at map origin even when a sibling mod (e.g. [BestLanding](https://github.com/MRNIU/factorio_BestLanding)) pushes the player far from spawn by filling the area with a landing blueprint.
- **Spidertron placement** is delayed until the next tick after a surface appears. This lets sibling mods finish landing-area cleanup and blueprint placement before the spidertron searches for a non-colliding position near `(0, 0)`.
- **Spidertron trunk and ammo capacity** is checked through `LuaInventory::insert` one tick after the spidertron equipment grid is packed. The log records trunk slots, grid size, toolbelt count, and inventory bonus; the designed cargo should fit, and unexpected leftovers are logged and spilled near the spidertron.
- If spidertrons are disabled and no free tile exists within 15 tiles of `(0, 0)`, any fallback chest items that could not be placed are spilled on the ground — the placer never destroys existing entities.

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
