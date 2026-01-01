-- Copyright The MRNIU/factorio_LegendaryMechStart Contributors

-- 引入传奇物品模块
local legendary_items = require("legendary_items")

--------------------------------------------------------------------------------------
-- 初始化
local function OnInit()
    storage.given_items = {}
end

--------------------------------------------------------------------------------------
-- 添加初始物品
local function AddStartItem(event)
    local player = game.players[event.player_index]

    -- 确保 storage.given_items 存在 (兼容旧存档)
    if not storage.given_items then
        storage.given_items = {}
    end

    -- 如果已经给过物品，则跳过
    if storage.given_items[event.player_index] then
        return
    end

    legendary_items.add_start_items(player)

    -- 标记为已给
    storage.given_items[event.player_index] = true
end

--------------------------------------------------------------------------------------
-- 强制重新发放初始物品（用于过场动画结束时清除系统赠送的物品）
local function ForceAddStartItem(event)
    local player = game.players[event.player_index]

    -- 即使之前给过，这里也强制清空并重新发放
    -- 这样可以清除 Freeplay 脚本在过场动画结束时赠送的手枪等默认物品
    legendary_items.add_start_items(player)

    -- 标记为已给
    storage.given_items[event.player_index] = true
end

--------------------------------------------------------------------------------------
-- 事件注册
script.on_init(OnInit)
script.on_event(defines.events.on_player_created, AddStartItem)
-- 过场动画结束/取消时，强制重置背包，确保没有系统赠送的杂物
script.on_event(defines.events.on_cutscene_cancelled, ForceAddStartItem)
script.on_event(defines.events.on_cutscene_finished, ForceAddStartItem)
