-- Copyright The MRNIU/factorio_LegendaryMechStart Contributors
-- 起始资源清单：蜘蛛启用时按行星塞进蜘蛛背包；蜘蛛关闭时 Nauvis 清单落地为团队箱。

local M = {}

local COMMON_TRUNK_WISHLIST = {
    { name = "construction-robot",     count = 500, quality = "normal" },
    { name = "logistic-robot",         count = 200, quality = "normal" },
    { name = "roboport",               count = 20,  quality = "normal" },
    { name = "repair-pack",            count = 200, quality = "normal" },
    { name = "big-electric-pole",      count = 50,  quality = "normal" },
    { name = "substation",             count = 50,  quality = "normal" },
    { name = "steel-chest",            count = 50,  quality = "normal" },
    { name = "passive-provider-chest", count = 50,  quality = "normal" },
    { name = "storage-chest",          count = 50,  quality = "normal" },
    { name = "requester-chest",        count = 50,  quality = "normal" },
    { name = "fast-inserter",          count = 100, quality = "normal" },
    { name = "bulk-inserter",          count = 50,  quality = "normal" },
    { name = "stack-inserter",         count = 50,  quality = "normal" },
}

local DEFENSE_TRUNK_WISHLIST = {
    { name = "rocket",           count = 200, quality = "normal" },
    { name = "explosive-rocket", count = 200, quality = "normal" },
    { name = "atomic-bomb",      count = 10,  quality = "normal" },
    { name = "laser-turret",     count = 50,  quality = "normal" },
}

local PLANET_TRUNK_WISHLISTS = {
    nauvis = {
        { name = "rocket-silo",                 count = 1,    quality = "legendary" },
        { name = "cargo-landing-pad",           count = 1,    quality = "normal" },
        { name = "space-platform-starter-pack", count = 1,    quality = "normal" },
        { name = "assembling-machine-3",        count = 100,  quality = "legendary" },
        { name = "electric-furnace",            count = 200,  quality = "legendary" },
        { name = "oil-refinery",                count = 10,   quality = "legendary" },
        { name = "chemical-plant",              count = 20,   quality = "legendary" },
        { name = "foundry",                     count = 20,   quality = "legendary" },
        { name = "electromagnetic-plant",       count = 20,   quality = "legendary" },
        { name = "biochamber",                  count = 20,   quality = "legendary" },
        { name = "cryogenic-plant",             count = 20,   quality = "legendary" },
        { name = "biolab",                      count = 10,   quality = "legendary" },
        { name = "centrifuge",                  count = 50,   quality = "legendary" },
        { name = "beacon",                      count = 60,   quality = "legendary" },
        { name = "speed-module-3",              count = 600,  quality = "legendary" },
        { name = "productivity-module-3",       count = 200,  quality = "legendary" },
        { name = "efficiency-module-3",         count = 100,  quality = "legendary" },
        { name = "big-mining-drill",            count = 60,   quality = "legendary" },
        { name = "pumpjack",                    count = 20,   quality = "legendary" },
        { name = "offshore-pump",               count = 20,   quality = "normal" },
        { name = "uranium-235",                 count = 100,  quality = "normal" },
        { name = "radar",                       count = 50,   quality = "legendary" },
        { name = "turbo-transport-belt",        count = 4000, quality = "normal" },
        { name = "turbo-underground-belt",      count = 200,  quality = "normal" },
        { name = "turbo-splitter",              count = 100,  quality = "normal" },
    },

    vulcanus = {
        { name = "foundry",              count = 30,   quality = "legendary" },
        { name = "big-mining-drill",     count = 30,   quality = "legendary" },
        { name = "calcite",              count = 1000, quality = "normal" },
        { name = "tungsten-ore",         count = 500,  quality = "normal" },
        { name = "tungsten-plate",       count = 500,  quality = "normal" },
        { name = "tungsten-carbide",     count = 500,  quality = "normal" },
        { name = "carbon",               count = 500,  quality = "normal" },
        { name = "pipe",                 count = 300,  quality = "normal" },
        { name = "pipe-to-ground",       count = 150,  quality = "normal" },
        { name = "pump",                 count = 50,   quality = "normal" },
        { name = "foundation",           count = 200,  quality = "normal" },
    },

    fulgora = {
        { name = "recycler",              count = 50,   quality = "legendary" },
        { name = "electromagnetic-plant", count = 30,   quality = "legendary" },
        { name = "lightning-rod",         count = 100,  quality = "normal" },
        { name = "lightning-collector",   count = 50,   quality = "normal" },
        { name = "accumulator",           count = 1000, quality = "normal" },
        { name = "scrap",                 count = 1000, quality = "normal" },
        { name = "holmium-ore",           count = 500,  quality = "normal" },
        { name = "holmium-plate",         count = 500,  quality = "normal" },
        { name = "superconductor",        count = 200,  quality = "normal" },
        { name = "supercapacitor",        count = 200,  quality = "normal" },
    },

    gleba = {
        { name = "biochamber",         count = 30,  quality = "legendary" },
        { name = "agricultural-tower", count = 30,  quality = "legendary" },
        { name = "heating-tower",      count = 10,  quality = "normal" },
        { name = "rocket-turret",      count = 20,  quality = "normal" },
        { name = "carbon-fiber",       count = 200, quality = "normal" },
        { name = "landfill",           count = 500, quality = "normal" },
    },

    aquilo = {
        { name = "cryogenic-plant",  count = 30,   quality = "legendary" },
        { name = "heating-tower",    count = 20,   quality = "normal" },
        { name = "heat-pipe",        count = 500,  quality = "normal" },
        { name = "heat-exchanger",   count = 50,   quality = "normal" },
        { name = "steam-turbine",    count = 50,   quality = "normal" },
        { name = "rocket-fuel",      count = 500,  quality = "normal" },
        { name = "ice-platform",     count = 500,  quality = "normal" },
        { name = "concrete",         count = 1000, quality = "normal" },
        { name = "refined-concrete", count = 1000, quality = "normal" },
        { name = "lithium",          count = 500,  quality = "normal" },
        { name = "lithium-plate",    count = 500,  quality = "normal" },
        { name = "quantum-processor", count = 100, quality = "normal" },
        { name = "fusion-reactor",    count = 2,   quality = "normal" },
        { name = "fusion-generator",  count = 8,   quality = "normal" },
        { name = "fusion-power-cell", count = 100, quality = "normal" },
    },
}

local DEFENSE_SURFACES = {
    nauvis   = true,
    vulcanus = true,
    gleba    = true,
}

local SPIDER_AMMO_FILL = { name = "rocket", count = 400, quality = "normal" }

local function append_items(target, source)
    if not source then return end
    for _, item in ipairs(source) do
        target[#target + 1] = {
            name    = item.name,
            count   = item.count,
            quality = item.quality,
        }
    end
end

function M.trunk_wishlist_for_surface(surface_name)
    local items = {}
    append_items(items, COMMON_TRUNK_WISHLIST)
    if DEFENSE_SURFACES[surface_name] then
        append_items(items, DEFENSE_TRUNK_WISHLIST)
    end
    append_items(items, PLANET_TRUNK_WISHLISTS[surface_name])
    return items
end

function M.team_cache_wishlist()
    return M.trunk_wishlist_for_surface("nauvis")
end

function M.ammo_fill_for_surface(surface_name)
    if DEFENSE_SURFACES[surface_name] then
        return SPIDER_AMMO_FILL
    end
    return nil
end

return M
