-- Copyright The MRNIU/factorio_LegendaryMechStart Contributors
-- 每个行星 surface 生成一台满配传奇蜘蛛机甲。

local equipment_grid = require("equipment_grid")
local item_delivery = require("item_delivery")
local starter_loadouts = require("starter_loadouts")

local M = {}

--------------------------------------------------------------------------------
-- 传奇蜘蛛网格：base 10×6，legendary 后实际 15×11，共 165 格。
-- 采用和玩家机甲相同的 first-fit 装箱逻辑，大件优先，两套清单都正好填满。
local HOSTILE_SPIDER_EQUIPMENT_WISHLIST = {
    { name = "fusion-reactor-equipment",         count = 4 }, -- 4×4，64 格
    { name = "exoskeleton-equipment",            count = 6 }, -- 2×4，48 格
    { name = "energy-shield-mk2-equipment",      count = 3 }, -- 2×2，12 格
    { name = "personal-roboport-mk2-equipment",  count = 2 }, -- 2×2，8 格
    { name = "personal-laser-defense-equipment", count = 2 }, -- 2×2，8 格
    { name = "battery-mk3-equipment",            count = 5 }, -- 1×2，10 格
    { name = "toolbelt-equipment",               count = 5 }, -- 3×1，15 格
}

local PEACEFUL_SPIDER_EQUIPMENT_WISHLIST = {
    { name = "fusion-reactor-equipment",        count = 4 }, -- 4×4，64 格
    { name = "exoskeleton-equipment",           count = 6 }, -- 2×4，48 格
    { name = "personal-roboport-mk2-equipment", count = 7 }, -- 2×2，28 格
    { name = "battery-mk3-equipment",           count = 5 }, -- 1×2，10 格
    { name = "toolbelt-equipment",              count = 5 }, -- 3×1，15 格
}

local SPIDER_SEARCH_RADII     = { 128, 256, 512 }
local SPIDER_SEARCH_PRECISION = 1
local BOOTSTRAP_SEARCH_RADIUS = 24
local BOOTSTRAP_ROBOPORT_NAME = "roboport"
local BOOTSTRAP_ROBOPORT_QUALITY = "normal"
local BOOTSTRAP_ROBOPORT_OFFSET = { x = 10, y = 0 }

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
    return item_delivery.insert_into_inventory(inv, items, "normal", label)
end

local function equipment_wishlist_for_surface(surface_name)
    if starter_loadouts.is_hostile_surface(surface_name) then
        return HOSTILE_SPIDER_EQUIPMENT_WISHLIST
    end
    return PEACEFUL_SPIDER_EQUIPMENT_WISHLIST
end

local function place_overflow(spider, items, label)
    if #items == 0 then return 0 end

    local spilled = item_delivery.spill_items(
        spider.surface, spider.position, spider.force, items)
    log(("[LegendaryMechStart] unexpected %s overflow: %d spilled items")
        :format(label, spilled))
    return spilled
end

local function offset_position(position, offset)
    return {
        x = (position.x or position[1]) + offset.x,
        y = (position.y or position[2]) + offset.y,
    }
end

local function create_bootstrap_roboport(spider)
    if not (prototypes.entity and prototypes.entity[BOOTSTRAP_ROBOPORT_NAME]) then return nil end

    local desired = offset_position(spider.position, BOOTSTRAP_ROBOPORT_OFFSET)
    local position = spider.surface.find_non_colliding_position(
        BOOTSTRAP_ROBOPORT_NAME, desired, BOOTSTRAP_SEARCH_RADIUS, 1)
    if not position then
        log(("[LegendaryMechStart] bootstrap: no clear position for %s on %s")
            :format(BOOTSTRAP_ROBOPORT_NAME, spider.surface.name))
        return nil
    end

    local ok, entity = pcall(function()
        return spider.surface.create_entity({
            name        = BOOTSTRAP_ROBOPORT_NAME,
            position    = position,
            force       = spider.force,
            quality     = BOOTSTRAP_ROBOPORT_QUALITY,
            raise_built = true,
        })
    end)
    if not (ok and entity and entity.valid) then
        log(("[LegendaryMechStart] bootstrap: create_entity failed for %s on %s: %s")
            :format(BOOTSTRAP_ROBOPORT_NAME, spider.surface.name, tostring(entity)))
        return nil
    end

    return entity
end

local function fill_roboport(roboport)
    if not (roboport and roboport.valid) then return 0 end

    local spilled = 0
    local robot_inv = roboport.get_inventory(defines.inventory.roboport_robot)
    local robot_leftover = item_delivery.insert_into_inventory(
        robot_inv, starter_loadouts.roboport_robot_wishlist(), "normal",
        "bootstrap roboport robots " .. roboport.surface.name)
    spilled = spilled + item_delivery.spill_items(
        roboport.surface, roboport.position, roboport.force, robot_leftover)

    return spilled
end

local function place_bootstrap_roboport(spider)
    local roboport = create_bootstrap_roboport(spider)
    local spilled = fill_roboport(roboport)
    if roboport then
        log(("[LegendaryMechStart] bootstrap roboport on %s placed%s")
            :format(spider.surface.name, spilled > 0 and " with unexpected robot overflow" or ""))
    end
    return spilled
end

local function log_trunk_capacity(spider, surface_name)
    local trunk = spider.get_inventory(defines.inventory.spider_trunk)
    local grid = spider.grid
    local toolbelts = 0
    if grid and grid.count then
        toolbelts = grid.count("toolbelt-equipment")
    end

    log(("[LegendaryMechStart] spider trunk slots on %s after equipment tick: %d (grid %dx%d, toolbelts %d, inventory bonus %d)")
        :format(surface_name, trunk and #trunk or 0,
            grid and grid.width or 0, grid and grid.height or 0,
            toolbelts, grid and grid.inventory_bonus or 0))
end

local function fill_trunk(spider, surface_name)
    local inv = spider.get_inventory(defines.inventory.spider_trunk)
    if not inv then return 0 end

    local leftover = insert_items(inv, starter_loadouts.trunk_wishlist_for_surface(surface_name),
        "spider trunk " .. surface_name)
    return place_overflow(spider, leftover, "spider trunk " .. surface_name)
end

local function fill_ammo(spider, surface_name)
    local ammo = starter_loadouts.ammo_fill_for_surface(surface_name)
    if not ammo then return 0 end

    local inv = spider.get_inventory(defines.inventory.spider_ammo)
    if not inv then return 0 end

    local leftover = insert_items(inv, { ammo }, "spider ammo " .. surface_name)
    return place_overflow(spider, leftover, "spider ammo " .. surface_name)
end

function M.spawn_on_surface(surface, force)
    if not (surface and surface.valid) then return false end

    force = force or game.forces.player
    local existing = find_starter_spider(surface, force)
    if existing then
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

    equipment_grid.pack(spider.grid, equipment_wishlist_for_surface(surface.name), "legendary")
    return spider
end

function M.fill_cargo_on_surface(surface, force)
    if not (surface and surface.valid) then return nil, 0 end

    force = force or game.forces.player
    local spider = find_starter_spider(surface, force)
    if not (spider and spider.valid) then return nil, 0 end

    log_trunk_capacity(spider, surface.name)
    local trunk_spilled = fill_trunk(spider, surface.name)
    local ammo_spilled = fill_ammo(spider, surface.name)
    local roboport_spilled = place_bootstrap_roboport(spider)
    return spider, trunk_spilled + ammo_spilled + roboport_spilled
end

return M
