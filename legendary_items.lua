-- This file is a part of MRNIU/factorio_LegendaryMechStart
-- (https://github.com/MRNIU/factorio_LegendaryMechStart).
--
-- legendary_items.lua for MRNIU/factorio_LegendaryMechStart.

--------------------------------------------------------------------------------------
-- 配置传奇机甲
local function init_legendary_mech_armor(mech_armor)
    local grid = mech_armor.grid

    -- 手动指定装备位置配置 (机甲网格: 15宽 × 17高，索引从0开始)
    local equipment_positions = {
        -- toolbelt-equipment(3×1) - 放在顶部
        {
            name = "toolbelt-equipment",
            positions = {
                { 0, 0 }, { 3, 0 }, { 6, 0 }, { 9, 0 }, { 12, 0 } -- 5个工具栏装备
            }
        },

        -- fusion-reactor-equipment(4×4) - 主要能源设备
        {
            name = "fusion-reactor-equipment",
            positions = {
                { 0, 1 }, -- 左上角 (0,1) 到 (3,4)
                { 4, 1 }, -- 中上 (4,1) 到 (7,4)
                { 0, 5 }, -- 左下 (0,5) 到 (3,8)
                { 4, 5 }, -- 右上 (4,5) 到 (7,8)
            }
        },

        -- night-vision-equipment(2×2) - 夜视装备
        {
            name = "night-vision-equipment",
            positions = {
                { 12, 1 } -- 右上角 (12,1) 到 (13,2)
            }
        },

        -- energy-shield-mk2-equipment(2×2) - 能量护盾
        {
            name = "energy-shield-mk2-equipment",
            positions = {
                { 12, 3 }, -- (4,5) 到 (5,6)
                { 12, 5 }, -- (6,5) 到 (7,6)
                { 12, 7 }  -- (8,5) 到 (9,6)
            }
        },

        -- solar-panel-equipment(1×1) - 太阳能板
        {
            name = "solar-panel-equipment",
            positions = {
                { 14, 1 } -- 最右上角
            }
        },

        -- belt-immunity-equipment(1×1) - 传送带免疫
        {
            name = "belt-immunity-equipment",
            positions = {
                { 14, 2 } -- 紧邻太阳能板下方
            }
        },

        -- battery-mk3-equipment(1×2) - 电池，放在右侧
        {
            name = "battery-mk3-equipment",
            positions = {
                { 14, 3 },  -- (14,3) 到 (14,4)
                { 14, 5 },  -- (14,5) 到 (14,6)
                { 14, 7 },  -- (14,7) 到 (14,8)
                { 14, 9 },  -- (14,9) 到 (14,10)
                { 14, 11 }, -- (14,11) 到 (14,12)
                { 14, 13 }, -- (14,13) 到 (14,14)
                { 14, 15 }  -- (14,15) 到 (14,16)
            }
        },


        -- personal-laser-defense-equipment(2×2) - 个人激光防御
        {
            name = "personal-laser-defense-equipment",
            positions = {
                { 10, 1 }, -- (10,5) 到 (11,6)
                { 10, 3 }, -- (12,5) 到 (13,6)
                { 10, 5 }, -- (0,9) 到 (1,10)
                { 10, 7 }  -- (2,9) 到 (3,10)
            }
        },

        -- personal-roboport-mk2-equipment(2×2) - 个人机器人港
        {
            name = "personal-roboport-mk2-equipment",
            positions = {
                { 8, 1 }, -- (4,9) 到 (5,10)
                { 8, 3 }, -- (6,9) 到 (7,10)
                { 8, 5 }, -- (8,9) 到 (9,10)
                { 8, 7 }  -- (10,9) 到 (11,10)
            }
        },

        -- exoskeleton-equipment(2×4) - 外骨骼装备，放在底部
        {
            name = "exoskeleton-equipment",
            positions = {
                { 0, 9 },   -- (0,11) 到 (1,14)
                { 2, 9 },   -- (2,9) 到 (3,14)
                { 4, 9 },   -- (4,9) 到 (5,14)
                { 6, 9 },   -- (6,9) 到 (7,14)
                { 8, 9 },   -- (8,9) 到 (9,14)
                { 10, 9 },  -- (10,9) 到 (9,14)
                { 12, 9 },  -- (12,11) 到 (13,14)
                { 0, 13 },  -- (0,13) 到 (1,16) - 注意这里是y=15，到y=16正好不超出17的边界
                { 2, 13 },  -- (2,13) 到 (3,16)
                { 4, 13 },  -- (4,13) 到 (5,16)
                { 6, 13 },  -- (6,13) 到 (7,16)
                { 8, 13 },  -- (8,13) 到 (9,16)
                { 10, 13 }, -- (10,13) 到 (11,16)
                { 12, 13 }  -- (12,13) 到 (13,16)
            }
        }
    }

    -- 按指定位置添加装备
    for _, equipment_config in pairs(equipment_positions) do
        for i, position in ipairs(equipment_config.positions) do
            grid.put {
                name = equipment_config.name,
                position = position,
                quality = "legendary"
            }
        end
    end
end

--------------------------------------------------------------------------------------
--- 给玩家添加传奇机甲装甲
local function give_legendary_mech_armor(player)
    -- 检查玩家装备栏是否有空位
    local armor_inventory = player.get_inventory(defines.inventory.character_armor)
    if not armor_inventory then
        return
    end

    -- 添加传奇机甲装甲
    armor_inventory.insert({
        name = "mech-armor",
        count = 1,
        quality = "legendary"
    })
    -- 初始化传奇机甲装甲
    init_legendary_mech_armor(armor_inventory[1])
end

--------------------------------------------------------------------------------------
-- 给玩家背包添加传奇物品
local function give_legendary_items(player, items)
    local main_inventory = player.get_inventory(defines.inventory.character_main)
    if not main_inventory then
        return
    end

    local added_items = {}

    for _, item_data in pairs(items) do
        local item_name = item_data.name or item_data[1]
        local item_count = item_data.count or item_data[2] or 1
        local item_quality = item_data.quality or "legendary"

        if prototypes.item[item_name] then
            local legendary_item = {
                name = item_name,
                count = item_count,
                quality = item_quality
            }

            local inserted = main_inventory.insert(legendary_item)
            if inserted > 0 then
                table.insert(added_items, item_count .. "x " .. item_quality .. " " .. item_name)
            end
        end
    end
end

--------------------------------------------------------------------------------------
-- 预设的传奇物品包
local preset_legendary_items = {
    -- 建造机器人和武器装备
    { name = "construction-robot", count = 200 },                     -- 建造机器人
    { name = "construction-robot", count = 200, quality = "normal" }, -- 建造机器人
    { name = "logistic-robot", count = 200, quality = "normal" },     -- 物流机器人
    { name = "roboport", count = 20, quality = "normal" },            -- 机器人港

    -- 高级生产设施
    { name = "assembling-machine-3", count = 100 }, -- 组装机 3
    { name = "oil-refinery", count = 20 },          -- 炼油厂
    { name = "chemical-plant", count = 40 },        -- 化工厂
    { name = "foundry", count = 40 },               -- 铸造厂
    { name = "electromagnetic-plant", count = 40 }, -- 电磁工厂
    { name = "biochamber", count = 40 },            -- 生物培养室
    { name = "biolab", count = 10 },                -- 生物实验室
    { name = "cryogenic-plant", count = 40 },       -- 低温工厂


    -- 信标和模块
    { name = "beacon", count = 40 },                 -- 信标
    { name = "speed-module-3", count = 400 },        -- 速度模块3
    { name = "efficiency-module-3", count = 100 },   -- 效率模块3
    { name = "productivity-module-3", count = 400 }, -- 产能模块3

    -- 电力设施
    { name = "small-electric-pole", count = 150, quality = "normal" }, -- 小电线杆
    { name = "big-electric-pole", count = 50, quality = "normal" },    -- 大电线杆
    { name = "substation", count = 400, quality = "normal" },          -- 变电站
    { name = "solar-panel", count = 1000 },                            -- 太阳能板
    { name = "accumulator", count = 1000 },                            -- 蓄电池

    -- 采掘和流体设备
    { name = "electric-furnace", count = 100 },                   -- 电炉
    { name = "big-mining-drill", count = 40 },                    -- 大型采矿机
    { name = "offshore-pump", count = 20 },                       -- 近海抽水机
    { name = "pumpjack", count = 20 },                            -- 抽油机
    { name = "pump", count = 50 },                                -- 泵
    { name = "pipe", count = 200, quality = "normal" },           -- 管道
    { name = "pipe-to-ground", count = 100, quality = "normal" }, -- 地下管道

    -- 机械臂
    { name = "long-handed-inserter", count = 200, quality = "normal" }, -- 长臂机械臂
    { name = "fast-inserter", count = 400, quality = "normal" },        -- 快速机械臂
    { name = "bulk-inserter", count = 50, quality = "normal" },         -- 批量机械臂
    { name = "stack-inserter", count = 50, quality = "normal" },        -- 集装机械臂

    -- 传送带系统
    { name = "turbo-transport-belt", count = 4000, quality = "normal" },  -- 传送带
    { name = "turbo-underground-belt", count = 200, quality = "normal" }, -- 地下传送带
    { name = "turbo-splitter", count = 100, quality = "normal" },         -- 分流器

    -- 物流系统
    { name = "steel-chest", count = 50, quality = "normal" },                     -- 钢箱
    { name = "logistic-chest-active-provider", count = 50, quality = "normal" },  -- 紫箱
    { name = "logistic-chest-passive-provider", count = 50, quality = "normal" }, -- 红箱
    { name = "logistic-chest-storage", count = 50, quality = "normal" },          -- 黄箱
    { name = "logistic-chest-buffer", count = 50, quality = "normal" },           -- 绿箱
    { name = "logistic-chest-requester", count = 50, quality = "normal" },        -- 蓝箱

    -- 太空探索
    { name = "rocket-silo", count = 1 },                                     -- 火箭发射井
    { name = "cargo-landing-pad", count = 1, quality = "normal" },           -- 货物着陆垫
    { name = "space-platform-starter-pack", count = 1, quality = "normal" }, -- 太空平台启动包
    { name = "low-density-structure", count = 200, quality = "normal" },     -- 低密度结构
    { name = "rocket-fuel", count = 200, quality = "normal" },               -- 火箭燃料
    { name = "processing-unit", count = 200, quality = "normal" },           -- 蓝板(处理器)

    -- 杂项
    { name = "uranium-235", count = 400, quality = "normal" },  -- 铀235
    { name = "submachine-gun", count = 3 },                     -- 冲锋枪
    { name = "uranium-rounds-magazine", count = 1600 },         -- 铀弹药
    { name = "laser-turret", count = 100, quality = "normal" }, -- 激光炮塔
    { name = "repair-pack", count = 100, quality = "normal" }   -- 修理包
}

--------------------------------------------------------------------------------------
-- 添加初始物品
local function add_start_items(player)
    if not player then
        return
    end

    -- 清空玩家各类物品栏（背包、护甲、武器、弹药）
    local inventories_to_clear = {
        defines.inventory.character_main,
        defines.inventory.character_armor,
        defines.inventory.character_guns,
        defines.inventory.character_ammo
    }

    for _, inv_index in pairs(inventories_to_clear) do
        local inv = player.get_inventory(inv_index)
        if inv then
            inv.clear()
        end
    end

    -- 给玩家传奇机甲装甲（直接穿戴）
    give_legendary_mech_armor(player)
    give_legendary_items(player, preset_legendary_items)
end

return {
    add_start_items = add_start_items
}
