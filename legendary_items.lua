-- Copyright The MRNIU/factorio_LegendaryMechStart Contributors

-- ============================================================================
-- 装备清单（first-fit 装箱；大件优先避免被切碎）
-- 功率预算（传奇品质）：
--   产能  6 × fusion-reactor-equipment = 37.5 MW
--   稳态  ~10–15 MW（行走 + 机器人港巡航 + 偶发充护盾）
--   峰值  ~96 MW（4 × 机器人港 MK2 同时满充主导），靠 7 × battery-mk3 缓冲
-- 网格  legendary mech-armor = 15 × 17 = 255 格
--
-- 网格预算（必须 ≤ 255）：
--   exo 80 + fusion 96 + roboport 16 + shield 16 + laser 12 + nv 4
--   + battery 14 + toolbelt 15 + belt-immunity 1 = 254；solar 填最后 1 格
-- 改 wishlist 任何一项的 count 时记得重新核账，超 255 后面的小件会被
-- find_first_fit 静默跳过（NV / belt-immunity 这种 count=1 的装备会消失）
-- ============================================================================
local EQUIPMENT_WISHLIST = {
    { name = "exoskeleton-equipment",            count = 10 }, -- 2×4
    { name = "fusion-reactor-equipment",         count = 6 },  -- 4×4
    { name = "personal-roboport-mk2-equipment",  count = 4 },  -- 2×2
    { name = "energy-shield-mk2-equipment",      count = 4 },  -- 2×2
    { name = "personal-laser-defense-equipment", count = 3 },  -- 2×2
    { name = "night-vision-equipment",           count = 1 },  -- 2×2
    { name = "battery-mk3-equipment",            count = 7 },  -- 1×2
    { name = "toolbelt-equipment",               count = 5 },  -- 3×1，提供 +125 背包槽
    { name = "belt-immunity-equipment",          count = 1 },  -- 1×1
    { name = "solar-panel-equipment",            count = 99 }, -- 1×1 填剩余缝隙
}

-- ============================================================================
-- 个人包：每个玩家被创建时都发放到背包
-- ============================================================================
local PERSONAL_WISHLIST = {
    -- 消耗品（3 个弹药槽已满，这里是后备）
    { name = "uranium-rounds-magazine", count = 200, quality = "legendary" },
    { name = "repair-pack",             count = 50,  quality = "normal" },

    -- 启动原料
    { name = "iron-plate",              count = 100, quality = "normal" },
    { name = "copper-plate",            count = 100, quality = "normal" },
    { name = "steel-plate",             count = 50,  quality = "normal" },
    { name = "stone-brick",             count = 50,  quality = "normal" },
    { name = "concrete",                count = 50,  quality = "normal" },
    { name = "coal",                    count = 100, quality = "normal" },

    -- 个人机器人（4 × personal-roboport-mk2 总容量绰绰有余）
    { name = "construction-robot",      count = 100, quality = "normal" },
    { name = "logistic-robot",          count = 50,  quality = "normal" },

    -- 临时布线 / 布管
    { name = "medium-electric-pole",    count = 50,  quality = "normal" },
    { name = "pipe",                    count = 50,  quality = "normal" },
    { name = "pipe-to-ground",          count = 20,  quality = "normal" },

    -- 个人防御
    { name = "laser-turret",            count = 20,  quality = "normal" },
}

-- ============================================================================
-- 团队资源：一整档只生成一次，装进出生点附近的传奇钢箱
-- ============================================================================
local TEAM_WISHLIST = {
    -- 原料（工业量）
    { name = "iron-plate",              count = 400,  quality = "normal" },
    { name = "copper-plate",            count = 400,  quality = "normal" },
    { name = "steel-plate",             count = 150,  quality = "normal" },
    { name = "stone-brick",             count = 150,  quality = "normal" },
    { name = "concrete",                count = 450,  quality = "normal" },
    { name = "landfill",                count = 500,  quality = "normal" },
    { name = "plastic-bar",             count = 200,  quality = "normal" },
    { name = "sulfur",                  count = 200,  quality = "normal" },
    { name = "coal",                    count = 400,  quality = "normal" },

    -- 启动电力链
    { name = "big-electric-pole",       count = 50,   quality = "normal" },
    { name = "substation",              count = 100,  quality = "normal" },     -- 2 组：远距离骨架
    { name = "substation",              count = 50,   quality = "legendary" },  -- 1 组：核心节点 VIP
    { name = "solar-panel",             count = 400,  quality = "legendary" },
    { name = "accumulator",             count = 400,  quality = "legendary" },

    -- 团队物流网
    { name = "construction-robot",      count = 100,  quality = "normal" },
    { name = "logistic-robot",          count = 150,  quality = "normal" },
    { name = "roboport",                count = 20,   quality = "legendary" },
    { name = "steel-chest",             count = 50,   quality = "normal" },
    { name = "active-provider-chest",   count = 50,   quality = "normal" },
    { name = "passive-provider-chest",  count = 50,   quality = "normal" },
    { name = "storage-chest",           count = 50,   quality = "normal" },
    { name = "buffer-chest",            count = 50,   quality = "normal" },
    { name = "requester-chest",         count = 50,   quality = "normal" },

    -- 机械臂
    { name = "long-handed-inserter",    count = 200,  quality = "normal" },
    { name = "fast-inserter",           count = 200,  quality = "normal" },
    { name = "bulk-inserter",           count = 50,   quality = "normal" },
    { name = "stack-inserter",          count = 50,   quality = "normal" },

    -- 传送带（turbo 贯穿）
    { name = "turbo-transport-belt",    count = 4000, quality = "normal" },
    { name = "turbo-underground-belt",  count = 200,  quality = "normal" },
    { name = "turbo-splitter",          count = 100,  quality = "normal" },

    -- 生产设施（全传奇）
    { name = "assembling-machine-3",    count = 100,  quality = "legendary" },
    { name = "electric-furnace",        count = 100,  quality = "legendary" },
    { name = "oil-refinery",            count = 10,   quality = "legendary" },
    { name = "chemical-plant",          count = 20,   quality = "legendary" },
    { name = "foundry",                 count = 20,   quality = "legendary" },
    { name = "electromagnetic-plant",   count = 20,   quality = "legendary" },
    { name = "biochamber",              count = 20,   quality = "legendary" },
    { name = "cryogenic-plant",         count = 20,   quality = "legendary" },
    { name = "biolab",                  count = 10,   quality = "legendary" },

    -- 模块 & 信标
    { name = "beacon",                  count = 20,   quality = "legendary" },
    { name = "speed-module-3",          count = 200,  quality = "legendary" },
    { name = "efficiency-module-3",     count = 100,  quality = "legendary" },
    { name = "productivity-module-3",   count = 200,  quality = "legendary" },

    -- 采矿 & 流体
    { name = "big-mining-drill",        count = 40,   quality = "legendary" },
    { name = "offshore-pump",           count = 20,   quality = "legendary" },
    { name = "pumpjack",                count = 20,   quality = "legendary" },
    { name = "pump",                    count = 50,   quality = "normal" },
    { name = "pipe",                    count = 150,  quality = "normal" },
    { name = "pipe-to-ground",          count = 80,   quality = "normal" },

    -- 太空进程
    { name = "rocket-silo",                 count = 1,   quality = "legendary" },
    { name = "cargo-landing-pad",           count = 1,   quality = "normal" },
    { name = "space-platform-starter-pack", count = 1,   quality = "normal" },
    { name = "low-density-structure",       count = 500, quality = "normal" },
    { name = "rocket-fuel",                 count = 200, quality = "normal" },
    { name = "processing-unit",             count = 400, quality = "normal" },

    -- 军事 & 杂项
    { name = "uranium-rounds-magazine", count = 800, quality = "legendary" },
    { name = "uranium-235",             count = 40,  quality = "normal" }, -- 一组 Kovarex 种子
    { name = "laser-turret",            count = 80,  quality = "normal" },
    { name = "repair-pack",             count = 50,  quality = "normal" },
}

local WEAPON_FILL = { name = "submachine-gun", count = 1, quality = "legendary" }
local AMMO_FILL   = { name = "uranium-rounds-magazine", count = 200, quality = "legendary" }

-- 团队资源箱的类型和品质；传奇钢箱 ≈ 48 × 2.5 = 120 槽/箱，~240 堆团队资源 → 2–3 箱
local TEAM_CHEST_NAME    = "steel-chest"
local TEAM_CHEST_QUALITY = "legendary"
-- 搜索半径：只在玩家视野范围内找空位。如果 sibling mod（BestLanding 等）
-- 把近处全填满了，就让剩下的物品 spill 到地上，不破坏既有实体。
local TEAM_CHEST_RADIUS  = 15

-- ============================================================================
-- 装备网格 first-fit 装箱
-- ============================================================================

local function is_rect_free(grid, x, y, w, h)
    for dy = 0, h - 1 do
        for dx = 0, w - 1 do
            if grid.get({ x + dx, y + dy }) then
                return false
            end
        end
    end
    return true
end

local function find_first_fit(grid, w, h)
    for y = 0, grid.height - h do
        for x = 0, grid.width - w do
            if is_rect_free(grid, x, y, w, h) then
                return { x, y }
            end
        end
    end
    return nil
end

local function pack_equipment_grid(grid, wishlist, default_quality)
    default_quality = default_quality or "legendary"
    for _, spec in ipairs(wishlist) do
        local proto = prototypes.equipment[spec.name]
        if proto then
            local w       = proto.shape.width
            local h       = proto.shape.height
            local quality = spec.quality or default_quality
            for _ = 1, spec.count do
                local pos = find_first_fit(grid, w, h)
                if not pos then break end
                grid.put({ name = spec.name, position = pos, quality = quality })
            end
        end
    end
end

-- ============================================================================
-- 背包发放（个人包）
-- 容量充足：80(基础) + 125(mech-armor) + 125(5×toolbelt) = 330 槽；
-- 个人包约 16 堆，不需要溢出处理。
-- ============================================================================

local function deliver_wishlist(player, wishlist)
    local main_inv = player.get_inventory(defines.inventory.character_main)
    if not main_inv then return end

    for _, spec in ipairs(wishlist) do
        if prototypes.item[spec.name] then
            main_inv.insert({
                name    = spec.name,
                count   = spec.count,
                quality = spec.quality or "legendary",
            })
        end
    end
end

-- ============================================================================
-- 团队资源箱：只在玩家身边的空地上放箱子，不破坏既有实体
-- 找不到空位时剩余物品 spill 到玩家脚下
-- ============================================================================

-- 在 center 附近贪心生成钢箱并塞 items；find_non_colliding_position 每次
-- 返回"离 center 最近的空格"，箱子创建后占位，下一轮自然扩散到次近空格
local function dump_items_into_chests(surface, center, force, items)
    local remaining = {}
    for _, it in ipairs(items) do
        remaining[#remaining + 1] = {
            name    = it.name,
            count   = it.count,
            quality = it.quality,
        }
    end

    local chest_count = 0
    while #remaining > 0 do
        local pos = surface.find_non_colliding_position(
            TEAM_CHEST_NAME, center, TEAM_CHEST_RADIUS, 1)
        if not pos then break end -- 半径内已无空位，剩下的交给 spill

        local chest = surface.create_entity({
            name        = TEAM_CHEST_NAME,
            position    = pos,
            force       = force,
            quality     = TEAM_CHEST_QUALITY,
            raise_built = true,
        })
        if not chest then break end

        chest_count = chest_count + 1
        local chest_inv = chest.get_inventory(defines.inventory.chest)
        while #remaining > 0 do
            local item = remaining[1]
            local inserted = chest_inv.insert({
                name    = item.name,
                count   = item.count,
                quality = item.quality,
            })
            if inserted == 0 then
                break -- 本箱塞满了，换下一个
            elseif inserted >= item.count then
                table.remove(remaining, 1)
            else
                item.count = item.count - inserted
                break
            end
        end
    end

    return chest_count, remaining
end

-- 入口：在 (surface, center, force) 身边摆箱子装入全部团队资源
-- 返回生成的箱子数；半径内放不下的条目会 spill 到 center
local function place_team_cache(surface, center, force)
    local items = {}
    for _, spec in ipairs(TEAM_WISHLIST) do
        if prototypes.item[spec.name] then
            items[#items + 1] = {
                name    = spec.name,
                count   = spec.count,
                quality = spec.quality or "legendary",
            }
        end
    end

    local chest_count, leftover = dump_items_into_chests(surface, center, force, items)

    for _, item in ipairs(leftover) do
        surface.spill_item_stack({
            position      = center,
            stack         = { name = item.name, count = item.count, quality = item.quality },
            enable_looted = true,
            force         = force,
            allow_belts   = false,
        })
    end

    return chest_count
end

-- ============================================================================
-- 装甲 / 武器 / 弹药
-- ============================================================================

local function equip_mech_armor(player)
    local armor_inv = player.get_inventory(defines.inventory.character_armor)
    if not armor_inv then return end

    armor_inv.insert({ name = "mech-armor", count = 1, quality = "legendary" })
    local stack = armor_inv[1]
    if stack and stack.valid_for_read and stack.grid then
        pack_equipment_grid(stack.grid, EQUIPMENT_WISHLIST, "legendary")
    end
end

local function fill_all_slots(inventory, stack_spec)
    if not inventory then return end
    for i = 1, #inventory do
        inventory[i].set_stack(stack_spec)
    end
end

-- ============================================================================
-- 对外入口：每个玩家都调用这个；团队资源的落地由 control.lua 按 once-per-save
-- 语义单独调 place_team_cache
-- ============================================================================

local CLEARED_INVENTORIES = {
    defines.inventory.character_main,
    defines.inventory.character_armor,
    defines.inventory.character_guns,
    defines.inventory.character_ammo,
}

local function add_start_items(player)
    if not (player and player.valid) then return end

    for _, idx in ipairs(CLEARED_INVENTORIES) do
        local inv = player.get_inventory(idx)
        if inv then inv.clear() end
    end

    equip_mech_armor(player)
    fill_all_slots(player.get_inventory(defines.inventory.character_guns), WEAPON_FILL)
    fill_all_slots(player.get_inventory(defines.inventory.character_ammo), AMMO_FILL)

    deliver_wishlist(player, PERSONAL_WISHLIST)
end

return {
    add_start_items  = add_start_items,
    place_team_cache = place_team_cache,
}
