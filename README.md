# Legendary Mech Start

A Factorio 2.1 Space Age mod that drops every player into fully-equipped legendary mech armor, seeds the team with enough industrial gear to go interplanetary on day one, and can place a legendary spidertron on each planet.

## What it does

- **Legendary mech armor on spawn** for every player (single-player, host and late joiners in multiplayer). The equipment grid is packed automatically from a prioritised wishlist, so adding or removing items only takes editing the list.
- **Personal starter kit** in each player's inventory: bootstrap materials, personal construction and logistic robots, defensive turrets, temporary wiring and piping, spare ammunition and repair packs. Inventory items are inserted after the character main inventory is available and at least one tick after the mech armor is equipped so toolbelt bonuses can refresh first.
- **Team resource cache** delivered once per save. If legendary spidertrons are enabled, the Nauvis team resources are loaded into the Nauvis spidertron trunk instead of being placed on the ground. If spidertrons are disabled, the same Nauvis cache is placed into normal steel chests near map spawn.
- **Optional legendary science pack cache** can be enabled with a runtime-global map setting before the team resource cache is delivered. On Nauvis, the science packs are placed into adjacent legendary passive provider chests near the bootstrap roboport instead of consuming spidertron trunk space.
- **Optional legendary spidertron on each planet**: a fully-equipped legendary spidertron is spawned once per planet surface, then loaded one tick later with a common maintenance kit plus planet-specific cargo. A bootstrap roboport is placed near it and loaded with starter robots. Nauvis/Vulcanus/Gleba also receive a normal-quality defense package and dedicated spidertron ammo-slot rockets.
- **Freeplay intro cleanup**: the mod re-runs after the cutscene finishes, so the default pistol and firearm magazines Freeplay hands out are removed.
- **Quality-aware**: every inserted stack declares its `quality` explicitly. Core production assets, mining drills, pumpjacks, recyclers, agricultural towers, modules, beacons, and inserters are legendary; bulk infrastructure, cargo robots, roboports, chests, power equipment, weapons, ammo, and consumables stay normal on purpose.
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

All items legendary; positions are computed by the same first-fit packer used for mech armor. Both current wishlists use exactly 165 cells.

| Trait | Category | Item | Count |
| :-- | :-- | :-- | :-: |
| Hostile planets | Power | Fusion Reactor | 4 |
| | | Battery MK3 | 5 |
| | Mobility | Exoskeleton | 6 |
| | Defense | Energy Shield MK2 | 3 |
| | | Personal Laser Defense | 2 |
| | Utility | Personal Roboport MK2 | 2 |
| | | Toolbelt | 5 |
| Peaceful planets | Power | Fusion Reactor | 4 |
| | | Battery MK3 | 5 |
| | Mobility | Exoskeleton | 6 |
| | Utility | Personal Roboport MK2 | 7 |
| | | Toolbelt | 5 |

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

Planet spidertron cargo is assembled from trait-based packages. If spidertron spawning is disabled, the fallback Nauvis team cache uses the same Nauvis packages in normal steel chests near map spawn. The optional science pack cache is separate from the spidertron trunk cargo.

| Scope | Item | Quality | Stacks |
| :-- | :-- | :-: | :-: |
| Common logistics | Construction Robot | Normal | 10 |
| | Logistic Robot | Normal | 20 |
| | Roboport | Normal | 2 |
| | Big Electric Pole / Substation | Normal | 1 / 2 |
| | Steel Chest | Normal | 1 |
| | Active Provider / Passive Provider / Storage / Requester / Buffer Chest | Normal | 1 each |
| | Long-handed Inserter | Legendary | 1 |
| | Bulk Inserter | Legendary | 3 |
| | Stack Inserter | Legendary | 1 |
| | Turbo Transport Belt | Normal | 40 |
| | Turbo Underground Belt / Turbo Splitter | Normal | 4 / 2 |
| Common maintenance | Repair Pack | Normal | 1 |
| Common exploration | Cargo Landing Pad | Normal | 1 |
| | Radar | Legendary | 1 |
| Common rocket launch | Rocket Silo | Legendary | 1 |
| | Processing Unit / Low Density Structure / Rocket Fuel | Normal | 2 / 4 / 10 |
| Common nuclear power | Nuclear Reactor | Legendary | 1 |
| | Uranium Fuel Cell | Legendary | 4 |
| | Heat Pipe | Normal | 4 |
| | Heat Exchanger | Legendary | 1 |
| | Steam Turbine | Legendary | 10 |
| Common fluids | Offshore Pump | Normal | 1 |
| | Pump | Normal | 1 |
| | Pipe / Pipe to Ground | Normal | 2 each |
| Common circuit control | Arithmetic / Decider / Selector / Constant Combinator | Normal | 1 each |
| | Power Switch / Display Panel | Normal | 1 each |
| Common industry | Assembling Machine 3 | Legendary | 2 |
| | Chemical Plant | Legendary | 2 |
| | Electromagnetic Plant / Recycler / Cryogenic Plant | Legendary | 1 each |
| | Beacon | Legendary | 2 |
| | Speed / Productivity / Efficiency Module 3 | Legendary | 8 / 4 / 2 |
| Hostile support: Nauvis/Vulcanus/Gleba only | Rocket / Explosive Rocket | Normal | 2 each |
| | Atomic Bomb | Normal | 1 |
| | Laser Turret | Normal | 1 |
| | Spidertron ammo slot: Rocket | Normal | 4 |

## Spidertron bootstrap roboport

When a planet spidertron is spawned or adopted, the cargo-fill stage also places one roboport near the planet origin and loads it directly with starter robots. Placement searches the origin with a 16-tile radius.

| Entity / inventory | Quality | Count |
| :-- | :-: | :-: |
| Roboport | Normal | 1 |
| Roboport robot inventory: Construction Robot | Normal | 2 stacks |
| Roboport robot inventory: Logistic Robot | Normal | 2 stacks |

| Power trait | Planets | Item | Quality | Stacks |
| :-- | :-- | :-- | :-: | :-: |
| Solar | Nauvis / Vulcanus / Gleba / Aquilo | Solar Panel | Normal | 10 |
| | | Accumulator | Normal | 10 |
| Accumulator only | Fulgora | Accumulator | Normal | 20 |

| Planet | Item | Quality | Stacks |
| :-- | :-- | :-: | :-: |
| Nauvis | Space Platform Starter Pack | Normal | 1 |
| | Electric Furnace | Legendary | 8 |
| | Oil Refinery | Legendary | 2 |
| | Chemical Plant | Legendary | 8 total |
| | Foundry | Legendary | 1 |
| | Biochamber | Legendary | 1 |
| | Biolab | Legendary | 1 |
| | Centrifuge | Legendary | 1 |
| | Beacon | Legendary | 5 total |
| | Speed / Productivity Module 3 | Legendary | 20 / 8 total |
| | Big Mining Drill | Legendary | 3 |
| | Pumpjack | Legendary | 1 |
| | Uranium-235 | Normal | 1 |
| | Fast Inserter | Legendary | 2 |
| Vulcanus | Electric Furnace | Legendary | 2 |
| | Foundry / Big Mining Drill | Legendary | 2 / 2 |
| | Pumpjack | Legendary | 1 |
| | Calcite | Normal | 20 |
| | Tungsten Ore / Tungsten Plate / Tungsten Carbide | Normal | 10 / 5 / 10 |
| | Carbon | Normal | 10 |
| | Coal / Steel Plate / Electronic Circuit / Advanced Circuit / Refined Concrete | Normal | 1 each |
| | Lubricant Barrel / Electric Engine Unit / Electric Mining Drill | Normal | 1 each |
| | Foundation | Normal | 2 |
| Fulgora | Electromagnetic Plant / Recycler | Legendary | 2 total / 3 total |
| | Lightning Collector | Legendary | 1 |
| | Scrap | Normal | 20 |
| | Holmium Ore / Holmium Plate | Normal | 10 / 5 |
| | Superconductor / Supercapacitor | Normal | 4 each |
| | Steel Plate / Copper Plate / Electronic Circuit / Battery / Plastic Bar / Refined Concrete / Stone | Normal | 1 each |
| | Water Barrel / Heavy Oil Barrel / Light Oil Barrel | Normal | 1 each |
| Gleba | Electric Furnace | Legendary | 2 |
| | Foundry | Legendary | 1 |
| | Biochamber / Agricultural Tower | Legendary | 2 each |
| | Heating Tower / Rocket Turret | Normal | 2 / 2 |
| | Carbon Fiber / Landfill | Normal | 2 / 5 |
| | Spoilage | Normal | 2 |
| | Bioflux / Yumako / Jellynut / Iron Plate / Electronic Circuit | Normal | 1 each |
| Aquilo | Electric Furnace | Legendary | 2 |
| | Foundry | Legendary | 1 |
| | Cryogenic Plant | Legendary | 2 total |
| | Pumpjack | Legendary | 1 |
| | Heating Tower | Normal | 2 |
| | Ice Platform | Normal | 5 |
| | Concrete / Refined Concrete | Normal | 10 each |
| | Lithium / Lithium Plate | Normal | 5 each |
| | Tungsten Carbide / Superconductor / Carbon Fiber / Holmium Plate | Normal | 10 / 10 / 5 / 5 |
| | Quantum Processor | Normal | 2 |
| | Fusion Reactor / Fusion Generator / Fusion Power Cell | Normal | 2 / 2 / 2 |
| | Ice / Solid Fuel | Normal | 3 / 1 |

## Optional Nauvis science pack cache

When `LegendaryMechStart-include-science-packs` is enabled before the team resource cache is delivered, the Nauvis cargo stage places the science packs into adjacent legendary passive provider chests near the bootstrap roboport. Counts are based on measured consumption for all non-repeatable technologies, using 200 packs per stack.

| Item | Quality | Stacks |
| :-- | :-: | :-: |
| Promethium Science Pack | Legendary | 0 |
| Chemical Science Pack | Legendary | 4 |
| Utility Science Pack | Legendary | 15 |
| Electromagnetic Science Pack | Legendary | 8 |
| Metallurgic Science Pack | Legendary | 6 |
| Space Science Pack | Legendary | 17 |
| Agricultural Science Pack | Legendary | 10 |
| Production Science Pack | Legendary | 9 |
| Cryogenic Science Pack | Legendary | 22 |
| Military Science Pack | Legendary | 9 |
| Logistic Science Pack | Legendary | 24 |
| Automation Science Pack | Legendary | 24 |

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
- **Bootstrap roboport placement** happens in the same delayed cargo stage. The roboport is loaded directly through `defines.inventory.roboport_robot`, so the local logistic network has active robots without needing a player to land first.
- If spidertrons are disabled and no free tile exists within 15 tiles of `(0, 0)`, any fallback chest items that could not be placed are spilled on the ground — the placer never destroys existing entities.

## Installation

1. Download the mod file.
2. Drop it into your Factorio `mods` folder.
3. Launch Factorio and enable the mod in the mod list.
4. Start a new game.

## Compatibility

- Factorio 2.1.9 or newer.
- Requires `base`, `space-age`, `quality`.

## License

MIT — see [LICENSE](LICENSE).

## Author

- **NZH** — zhihong@nzhnb.com
- Repository: <https://github.com/MRNIU/factorio_LegendaryMechStart>

## Changelog

See [changelog.txt](changelog.txt).
