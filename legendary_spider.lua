-- Copyright The MRNIU/factorio_LegendaryMechStart Contributors
-- 每个行星 surface 生成一台满配传奇蜘蛛机甲。

local equipment_grid = require("equipment_grid")

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

--------------------------------------------------------------------------------
-- 蜘蛛背包预设物资
local SPIDER_TRUNK_WISHLIST = {
    { name = "construction-robot",     count = 1000, quality = "normal"    },
    { name = "logistic-robot",         count = 1000, quality = "normal"    },
    { name = "roboport",               count = 100,  quality = "normal"    },
    { name = "big-electric-pole",      count = 50,   quality = "normal"    },
    { name = "substation",             count = 200,  quality = "normal"    },
    { name = "solar-panel",            count = 1000, quality = "legendary" },
    { name = "accumulator",            count = 1000, quality = "legendary" },
    { name = "long-handed-inserter",   count = 50,   quality = "normal"    },
    { name = "fast-inserter",          count = 50,   quality = "normal"    },
    { name = "bulk-inserter",          count = 50,   quality = "normal"    },
    { name = "stack-inserter",         count = 50,   quality = "normal"    },
    { name = "steel-chest",            count = 50,   quality = "normal"    },
    { name = "active-provider-chest",  count = 50,   quality = "normal"    },
    { name = "passive-provider-chest", count = 50,   quality = "normal"    },
    { name = "storage-chest",          count = 50,   quality = "normal"    },
    { name = "buffer-chest",           count = 50,   quality = "normal"    },
    { name = "requester-chest",        count = 50,   quality = "normal"    },
    { name = "rocket",                 count = 400,  quality = "legendary" },
    { name = "explosive-rocket",       count = 400,  quality = "legendary" },
    { name = "atomic-bomb",            count = 10,   quality = "legendary" },
    { name = "laser-turret",           count = 100,  quality = "legendary" },
    { name = "repair-pack",            count = 200,  quality = "normal"    },
}

local SPIDER_AMMO_FILL = { name = "rocket", count = 400, quality = "legendary" }

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

local function has_starter_spider(surface, force)
    local r = SPIDER_SEARCH_RADII[#SPIDER_SEARCH_RADII]
    local spiders = surface.find_entities_filtered({
        area = { { -r, -r }, { r, r } },
        name = "spidertron",
        force = force,
    })
    return #spiders > 0
end

local function fill_trunk(spider)
    local inv = spider.get_inventory(defines.inventory.spider_trunk)
    if not inv then return end

    for _, item in ipairs(SPIDER_TRUNK_WISHLIST) do
        if prototypes.item[item.name] then
            local inserted = inv.insert({
                name    = item.name,
                count   = item.count,
                quality = item.quality or "legendary",
            })
            if inserted < item.count then
                log(("[LegendaryMechStart] spider trunk inserted %d/%d %s")
                    :format(inserted, item.count, item.name))
            end
        end
    end
end

local function fill_ammo(spider)
    local inv = spider.get_inventory(defines.inventory.spider_ammo)
    if not inv then return end
    if prototypes.item[SPIDER_AMMO_FILL.name] then
        inv.insert(SPIDER_AMMO_FILL)
    end
end

function M.spawn_on_surface(surface, force)
    if not (surface and surface.valid) then return false end

    force = force or game.forces.player
    if has_starter_spider(surface, force) then
        return true
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
    fill_trunk(spider)
    fill_ammo(spider)
    return true
end

return M
