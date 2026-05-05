-- Copyright The MRNIU/factorio_LegendaryMechStart Contributors
-- 每个行星 surface 生成一台满配传奇蜘蛛机甲。

local equipment_grid = require("equipment_grid")
local starter_loadouts = require("starter_loadouts")

local M = {}

--------------------------------------------------------------------------------
-- 传奇蜘蛛网格：base 10×6，legendary 后实际 15×11，共 165 格。
-- 采用和玩家机甲相同的 first-fit 装箱逻辑，大件优先，当前清单正好填满。
local SPIDER_EQUIPMENT_WISHLIST = {
    { name = "fusion-reactor-equipment",         count = 4 }, -- 4×4，64 格
    { name = "exoskeleton-equipment",            count = 6 }, -- 2×4，48 格
    { name = "energy-shield-mk2-equipment",      count = 3 }, -- 2×2，12 格
    { name = "personal-roboport-mk2-equipment",  count = 2 }, -- 2×2，8 格
    { name = "personal-laser-defense-equipment", count = 2 }, -- 2×2，8 格
    { name = "battery-mk3-equipment",            count = 5 }, -- 1×2，10 格
    { name = "toolbelt-equipment",               count = 5 }, -- 3×1，15 格
}

local SPIDER_SEARCH_RADII     = { 128, 256, 512 }
local SPIDER_SEARCH_PRECISION = 1

--------------------------------------------------------------------------------
local function find_safe_position(surface, origin)
    for _, r in ipairs(SPIDER_SEARCH_RADII) do
        local p = surface.find_non_colliding_position(
            "spidertron", origin, r, SPIDER_SEARCH_PRECISION
        )
        if p then return p, r end
    end
    return nil, nil
end

local function find_starter_spider(surface, force)
    local r = SPIDER_SEARCH_RADII[#SPIDER_SEARCH_RADII]
    local spiders = surface.find_entities_filtered({
        area = { { -r, -r }, { r, r } },
        name = "spidertron",
        force = force,
    })
    return spiders[1]
end

local function insert_items(inv, items, label)
    if not (inv and items) then return end

    for _, item in ipairs(items) do
        if prototypes.item[item.name] then
            local quality = item.quality or "normal"
            local inserted = inv.insert({
                name    = item.name,
                count   = item.count,
                quality = quality,
            })
            if inserted < item.count then
                log(("[LegendaryMechStart] %s inserted %d/%d %s (%s)")
                    :format(label, inserted, item.count, item.name, quality))
            end
        end
    end
end

local function fill_trunk(spider, surface_name)
    local inv = spider.get_inventory(defines.inventory.spider_trunk)
    if not inv then return end

    insert_items(inv, starter_loadouts.trunk_wishlist_for_surface(surface_name),
        "spider trunk " .. surface_name)
end

local function fill_ammo(spider, surface_name)
    local ammo = starter_loadouts.ammo_fill_for_surface(surface_name)
    if not ammo then return end

    local inv = spider.get_inventory(defines.inventory.spider_ammo)
    if not inv then return end

    insert_items(inv, { ammo }, "spider ammo " .. surface_name)
end

function M.spawn_on_surface(surface, force)
    if not (surface and surface.valid) then return false end

    force = force or game.forces.player
    local existing = find_starter_spider(surface, force)
    if existing then
        fill_trunk(existing, surface.name)
        fill_ammo(existing, surface.name)
        return existing
    end

    local origin = { x = 0, y = 0 }
    local position, found_radius = find_safe_position(surface, origin)
    if not position then
        log(("[LegendaryMechStart] spider: no clear position within %d on %s, falling back to origin")
            :format(SPIDER_SEARCH_RADII[#SPIDER_SEARCH_RADII], surface.name))
        position = origin
    elseif found_radius > SPIDER_SEARCH_RADII[1] then
        log(("[LegendaryMechStart] spider: used fallback radius %d on %s")
            :format(found_radius, surface.name))
    end

    local spider = surface.create_entity({
        name     = "spidertron",
        position = position,
        force    = force,
        quality  = "legendary",
    })
    if not (spider and spider.valid) then
        log(("[LegendaryMechStart] spider: create_entity failed on %s at (%s, %s)")
            :format(surface.name, position.x, position.y))
        return false
    end

    equipment_grid.pack(spider.grid, SPIDER_EQUIPMENT_WISHLIST, "legendary")
    local trunk = spider.get_inventory(defines.inventory.spider_trunk)
    log(("[LegendaryMechStart] spider trunk slots on %s: %d (grid inventory bonus %d)")
        :format(surface.name, trunk and #trunk or 0, spider.grid and spider.grid.inventory_bonus or 0))

    fill_trunk(spider, surface.name)
    fill_ammo(spider, surface.name)
    return spider
end

return M
