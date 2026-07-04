-- Copyright The MRNIU/factorio_LegendaryMechStart Contributors
-- 起始资源清单：蜘蛛启用时按行星塞进蜘蛛背包；蜘蛛关闭时 Nauvis 清单落地为团队箱。

local M = {}

local SETTING_INCLUDE_SCIENCE_PACKS = "LegendaryMechStart-include-science-packs"

local PLANET_TRAITS = {
    nauvis   = { hostile = true,  solar = true },
    vulcanus = { hostile = true,  solar = true },
    fulgora  = { hostile = false, accumulator_only = true },
    gleba    = { hostile = true,  solar = true },
    aquilo   = { hostile = false, solar = true },
}

local COMMON_LOGISTICS_WISHLIST = {
    { name = "construction-robot",     stacks = 10, quality = "normal" },
    { name = "logistic-robot",         stacks = 20, quality = "normal" },
    { name = "roboport",               stacks = 2,  quality = "normal" },
    { name = "big-electric-pole",      stacks = 1,  quality = "normal" },
    { name = "substation",             stacks = 2,  quality = "normal" },
    { name = "steel-chest",            stacks = 1,  quality = "normal" },
    { name = "active-provider-chest",  stacks = 1,  quality = "normal" },
    { name = "passive-provider-chest", stacks = 1,  quality = "normal" },
    { name = "storage-chest",          stacks = 1,  quality = "normal" },
    { name = "requester-chest",        stacks = 1,  quality = "normal" },
    { name = "buffer-chest",           stacks = 1,  quality = "normal" },
    { name = "long-handed-inserter",   stacks = 1,  quality = "legendary" },
    { name = "bulk-inserter",          stacks = 3,  quality = "legendary" },
    { name = "stack-inserter",         stacks = 1,  quality = "legendary" },
    { name = "turbo-transport-belt",   stacks = 40, quality = "normal" },
    { name = "turbo-underground-belt", stacks = 4, quality = "normal" },
    { name = "turbo-splitter",         stacks = 2, quality = "normal" },
}

local COMMON_MAINTENANCE_WISHLIST = {
    { name = "repair-pack", stacks = 1, quality = "normal" },
}

local COMMON_EXPLORATION_WISHLIST = {
    { name = "cargo-landing-pad",     stacks = 1,  quality = "normal" },
    { name = "radar",                 stacks = 1,  quality = "legendary" },
}

local COMMON_ROCKET_LAUNCH_WISHLIST = {
    { name = "rocket-silo",           stacks = 1,  quality = "legendary" },
    { name = "processing-unit",       stacks = 2,  quality = "normal" },
    { name = "low-density-structure", stacks = 4,  quality = "normal" },
    { name = "rocket-fuel",           stacks = 10, quality = "normal" },
}

local COMMON_NUCLEAR_POWER_WISHLIST = {
    { name = "nuclear-reactor",    stacks = 1,  quality = "legendary" },
    { name = "uranium-fuel-cell",  stacks = 4,  quality = "legendary" },
    { name = "heat-pipe",          stacks = 4,  quality = "normal" },
    { name = "heat-exchanger",     stacks = 1,  quality = "legendary" },
    { name = "steam-turbine",      stacks = 10, quality = "legendary" },
}

local COMMON_FLUIDS_WISHLIST = {
    { name = "offshore-pump",         stacks = 1,  quality = "normal" },
    { name = "pump",                  stacks = 1,  quality = "normal" },
    { name = "pipe",                  stacks = 2,  quality = "normal" },
    { name = "pipe-to-ground",        stacks = 2,  quality = "normal" },
}

local COMMON_CIRCUIT_CONTROL_WISHLIST = {
    { name = "arithmetic-combinator", stacks = 1, quality = "normal" },
    { name = "decider-combinator",    stacks = 1, quality = "normal" },
    { name = "selector-combinator",   stacks = 1, quality = "normal" },
    { name = "constant-combinator",   stacks = 1, quality = "normal" },
    { name = "power-switch",          stacks = 1, quality = "normal" },
    { name = "display-panel",         stacks = 1, quality = "normal" },
}

local COMMON_INDUSTRY_WISHLIST = {
    { name = "assembling-machine-3",  stacks = 2, quality = "legendary" },
    { name = "chemical-plant",        stacks = 2, quality = "legendary" },
    { name = "electromagnetic-plant", stacks = 1, quality = "legendary" },
    { name = "recycler",              stacks = 1, quality = "legendary" },
    { name = "cryogenic-plant",       stacks = 1, quality = "legendary" },
    { name = "beacon",                stacks = 2, quality = "legendary" },
    { name = "speed-module-3",        stacks = 8, quality = "legendary" },
    { name = "productivity-module-3", stacks = 4, quality = "legendary" },
    { name = "efficiency-module-3",   stacks = 2, quality = "legendary" },
}

local SOLAR_POWER_WISHLIST = {
    { name = "solar-panel", stacks = 10, quality = "normal" },
    { name = "accumulator", stacks = 10, quality = "normal" },
}

local ACCUMULATOR_ONLY_POWER_WISHLIST = {
    { name = "accumulator", stacks = 20, quality = "normal" },
}

local HOSTILE_SUPPORT_WISHLIST = {
    { name = "rocket",           stacks = 2, quality = "normal" },
    { name = "explosive-rocket", stacks = 2, quality = "normal" },
    { name = "atomic-bomb",      stacks = 1, quality = "normal" },
    { name = "laser-turret",     stacks = 1, quality = "normal" },
}

local BOOTSTRAP_ROBOPORT_ROBOT_WISHLIST = {
    { name = "construction-robot", stacks = 2, quality = "normal" },
    { name = "logistic-robot",     stacks = 2, quality = "normal" },
}

local NAUVIS_SCIENCE_PACK_WISHLIST = {
    -- 按非循环科技实测消耗配置；钷素科研包为 0 组，保留条目便于核账。
    { name = "promethium-science-pack",     stacks = 0,  quality = "legendary" },
    { name = "chemical-science-pack",       stacks = 22, quality = "legendary" },
    { name = "utility-science-pack",        stacks = 15, quality = "legendary" },
    { name = "electromagnetic-science-pack", stacks = 8, quality = "legendary" },
    { name = "metallurgic-science-pack",    stacks = 6,  quality = "legendary" },
    { name = "space-science-pack",          stacks = 17, quality = "legendary" },
    { name = "agricultural-science-pack",   stacks = 10, quality = "legendary" },
    { name = "production-science-pack",     stacks = 9,  quality = "legendary" },
    { name = "cryogenic-science-pack",      stacks = 4,  quality = "legendary" },
    { name = "military-science-pack",       stacks = 9,  quality = "legendary" },
    { name = "logistic-science-pack",       stacks = 24, quality = "legendary" },
    { name = "automation-science-pack",     stacks = 24, quality = "legendary" },
}

local PLANET_SPECIAL_WISHLISTS = {
    nauvis = {
        { name = "space-platform-starter-pack", stacks = 1,  quality = "normal" },
        { name = "electric-furnace",            stacks = 8,  quality = "legendary" },
        { name = "oil-refinery",                stacks = 2,  quality = "legendary" },
        { name = "chemical-plant",              stacks = 6,  quality = "legendary" },
        { name = "foundry",                     stacks = 2,  quality = "legendary" },
        { name = "biochamber",                  stacks = 1,  quality = "legendary" },
        { name = "biolab",                      stacks = 1,  quality = "legendary" },
        { name = "centrifuge",                  stacks = 1,  quality = "legendary" },
        { name = "beacon",                      stacks = 3,  quality = "legendary" },
        { name = "speed-module-3",              stacks = 12, quality = "legendary" },
        { name = "productivity-module-3",       stacks = 4,  quality = "legendary" },
        { name = "big-mining-drill",            stacks = 3,  quality = "legendary" },
        { name = "pumpjack",                    stacks = 1,  quality = "legendary" },
        { name = "uranium-235",                 stacks = 1,  quality = "normal" },
        { name = "fast-inserter",               stacks = 2,  quality = "legendary" },
    },

    vulcanus = {
        { name = "electric-furnace",     stacks = 2,  quality = "legendary" },
        { name = "oil-refinery",         stacks = 1,  quality = "legendary" },
        { name = "foundry",              stacks = 2,  quality = "legendary" },
        { name = "big-mining-drill",     stacks = 2,  quality = "legendary" },
        { name = "pumpjack",             stacks = 1,  quality = "legendary" },
        { name = "calcite",              stacks = 20, quality = "normal" },
        { name = "tungsten-ore",         stacks = 10, quality = "normal" },
        { name = "tungsten-plate",       stacks = 5,  quality = "normal" },
        { name = "tungsten-carbide",     stacks = 10, quality = "normal" },
        { name = "carbon",               stacks = 10, quality = "normal" },
        { name = "coal",                 stacks = 1,  quality = "normal" },
        { name = "steel-plate",          stacks = 1,  quality = "normal" },
        { name = "electronic-circuit",   stacks = 1,  quality = "normal" },
        { name = "advanced-circuit",     stacks = 1,  quality = "normal" },
        { name = "refined-concrete",     stacks = 1,  quality = "normal" },
        { name = "lubricant-barrel",     stacks = 1,  quality = "normal" },
        { name = "electric-engine-unit", stacks = 1,  quality = "normal" },
        { name = "electric-mining-drill", stacks = 1, quality = "normal" },
        { name = "foundation",           stacks = 2,  quality = "normal" },
    },

    fulgora = {
        { name = "recycler",              stacks = 2,  quality = "legendary" },
        { name = "electromagnetic-plant", stacks = 1,  quality = "legendary" },
        { name = "oil-refinery",          stacks = 1,  quality = "legendary" },
        { name = "lightning-collector",   stacks = 1,  quality = "legendary" },
        { name = "scrap",                 stacks = 20, quality = "normal" },
        { name = "holmium-ore",           stacks = 10, quality = "normal" },
        { name = "holmium-plate",         stacks = 5,  quality = "normal" },
        { name = "superconductor",        stacks = 4,  quality = "normal" },
        { name = "supercapacitor",        stacks = 4,  quality = "normal" },
        { name = "steel-plate",           stacks = 1,  quality = "normal" },
        { name = "copper-plate",          stacks = 1,  quality = "normal" },
        { name = "electronic-circuit",    stacks = 1,  quality = "normal" },
        { name = "battery",               stacks = 1,  quality = "normal" },
        { name = "plastic-bar",           stacks = 1,  quality = "normal" },
        { name = "refined-concrete",      stacks = 1,  quality = "normal" },
        { name = "stone",                 stacks = 1,  quality = "normal" },
        { name = "water-barrel",          stacks = 1,  quality = "normal" },
        { name = "heavy-oil-barrel",      stacks = 1,  quality = "normal" },
        { name = "light-oil-barrel",      stacks = 1,  quality = "normal" },
    },

    gleba = {
        { name = "electric-furnace",   stacks = 2, quality = "legendary" },
        { name = "foundry",            stacks = 1, quality = "legendary" },
        { name = "biochamber",         stacks = 2, quality = "legendary" },
        { name = "agricultural-tower", stacks = 2, quality = "legendary" },
        { name = "heating-tower",      stacks = 2, quality = "normal" },
        { name = "rocket-turret",      stacks = 2, quality = "normal" },
        { name = "carbon-fiber",       stacks = 2, quality = "normal" },
        { name = "landfill",           stacks = 5, quality = "normal" },
        { name = "spoilage",           stacks = 2, quality = "normal" },
        { name = "bioflux",            stacks = 1, quality = "normal" },
        { name = "yumako",             stacks = 1, quality = "normal" },
        { name = "jellynut",           stacks = 1, quality = "normal" },
        { name = "iron-plate",         stacks = 1, quality = "normal" },
        { name = "electronic-circuit", stacks = 1, quality = "normal" },
    },

    aquilo = {
        { name = "electric-furnace", stacks = 2,  quality = "legendary" },
        { name = "foundry",          stacks = 1,  quality = "legendary" },
        { name = "cryogenic-plant",  stacks = 1,  quality = "legendary" },
        { name = "pumpjack",         stacks = 1,  quality = "legendary" },
        { name = "heating-tower",    stacks = 2,  quality = "normal" },
        { name = "ice-platform",     stacks = 5,  quality = "normal" },
        { name = "concrete",         stacks = 10, quality = "normal" },
        { name = "refined-concrete", stacks = 10, quality = "normal" },
        { name = "lithium",          stacks = 5,  quality = "normal" },
        { name = "lithium-plate",    stacks = 5,  quality = "normal" },
        { name = "tungsten-carbide", stacks = 10, quality = "normal" },
        { name = "superconductor",   stacks = 10, quality = "normal" },
        { name = "carbon-fiber",     stacks = 5,  quality = "normal" },
        { name = "holmium-plate",    stacks = 5,  quality = "normal" },
        { name = "quantum-processor", stacks = 2, quality = "normal" },
        { name = "fusion-reactor",    stacks = 2,  quality = "normal" },
        { name = "fusion-generator",  stacks = 2,  quality = "normal" },
        { name = "fusion-power-cell", stacks = 2,  quality = "normal" },
        { name = "ice",               stacks = 3,  quality = "normal" },
        { name = "solid-fuel",        stacks = 1,  quality = "normal" },
    },
}

local SPIDER_AMMO_FILL = { name = "rocket", stacks = 4, quality = "normal" }

local function count_for_item(item)
    if not item.stacks then return nil end

    local prototype = prototypes.item[item.name]
    if not prototype then return nil end
    return prototype.stack_size * item.stacks
end

local function append_items(target, source)
    if not source then return end
    for _, item in ipairs(source) do
        local count = count_for_item(item)
        if count and count > 0 then
            target[#target + 1] = {
                name    = item.name,
                count   = count,
                quality = item.quality,
            }
        end
    end
end

local function include_science_packs_enabled()
    local s = settings.global[SETTING_INCLUDE_SCIENCE_PACKS]
    return s and s.value
end

function M.trunk_wishlist_for_surface(surface_name)
    local items = {}
    append_items(items, COMMON_LOGISTICS_WISHLIST)
    append_items(items, COMMON_MAINTENANCE_WISHLIST)
    local traits = PLANET_TRAITS[surface_name]
    local planet_items = PLANET_SPECIAL_WISHLISTS[surface_name]
    if traits and planet_items then
        append_items(items, COMMON_EXPLORATION_WISHLIST)
        append_items(items, COMMON_ROCKET_LAUNCH_WISHLIST)
        append_items(items, COMMON_NUCLEAR_POWER_WISHLIST)
        append_items(items, COMMON_FLUIDS_WISHLIST)
        append_items(items, COMMON_CIRCUIT_CONTROL_WISHLIST)
        append_items(items, COMMON_INDUSTRY_WISHLIST)
        if traits.solar then
            append_items(items, SOLAR_POWER_WISHLIST)
        elseif traits.accumulator_only then
            append_items(items, ACCUMULATOR_ONLY_POWER_WISHLIST)
        end
        if traits.hostile then
            append_items(items, HOSTILE_SUPPORT_WISHLIST)
        end
        append_items(items, planet_items)
    end
    return items
end

function M.team_cache_wishlist()
    return M.trunk_wishlist_for_surface("nauvis")
end

function M.science_pack_wishlist_for_surface(surface_name)
    local items = {}
    if surface_name == "nauvis" and include_science_packs_enabled() then
        append_items(items, NAUVIS_SCIENCE_PACK_WISHLIST)
    end
    return items
end

function M.roboport_robot_wishlist()
    local items = {}
    append_items(items, BOOTSTRAP_ROBOPORT_ROBOT_WISHLIST)
    return items
end

function M.ammo_fill_for_surface(surface_name)
    local traits = PLANET_TRAITS[surface_name]
    if traits and traits.hostile then
        local count = count_for_item(SPIDER_AMMO_FILL)
        if count then
            return {
                name    = SPIDER_AMMO_FILL.name,
                count   = count,
                quality = SPIDER_AMMO_FILL.quality,
            }
        end
    end
    return nil
end

function M.is_hostile_surface(surface_name)
    local traits = PLANET_TRAITS[surface_name]
    return traits and traits.hostile or false
end

return M
