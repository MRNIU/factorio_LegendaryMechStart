-- Copyright The MRNIU/factorio_LegendaryMechStart Contributors

local legendary_items = require("legendary_items")

-- ============================================================================
-- 持久化状态
--   storage.given_items[player_index] = true  该玩家已经发过个人包
--   storage.team_cache_placed                 整档只一次：团队箱是否已落地
--
-- 发放模型：
--   - 每个玩家 on_player_created 时拿 PERSONAL 包（进背包）
--   - 第一个被创建的玩家同时触发团队箱落地：以他的 position 为中心，
--     在出生点附近生成若干传奇钢箱并装入所有团队资源
--   - host 经历 cutscene 会再触发 ForceAddStartItem，这时只重发个人包；
--     `storage.team_cache_placed` 已是 true，不会重复生成团队箱
--   - late joiner 不经历 cutscene，ForceAddStartItem 对他们不触发
-- ============================================================================

local function ensure_storage()
    if not storage.given_items then storage.given_items = {} end
end

local function OnInit()
    storage.given_items       = {}
    storage.team_cache_placed = false
end

local function give(player_index)
    ensure_storage()
    local player = game.players[player_index]
    if not (player and player.valid) then return end

    legendary_items.add_start_items(player)
    storage.given_items[player_index] = true

    if not storage.team_cache_placed then
        -- 以"力量的出生点"为中心（Nauvis 默认是 (0,0)），而不是 player.position：
        -- BestLanding 等 mod 会在 (0,0) 铺大蓝图，引擎找不到落脚点就把玩家推到几十
        -- 瓦片外；用 spawn 点能保证箱子稳定出现在地图原点附近。
        local spawn = player.force.get_spawn_position(player.surface)
        local chest_count = legendary_items.place_team_cache(
            player.surface, spawn, player.force)
        storage.team_cache_placed = true
        if chest_count > 0 then
            player.print("[LegendaryMechStart] Team resources placed into " ..
                chest_count ..
                " legendary steel chests at map spawn (any remainder spilled on the ground).")
        else
            player.print("[LegendaryMechStart] No free tiles within 15 of map spawn; " ..
                "all team resources spilled on the ground there.")
        end
    end
end

--------------------------------------------------------------------------------------
-- 首次发放：on_player_created（每玩家最多触发一次）
local function AddStartItem(event)
    ensure_storage()
    if storage.given_items[event.player_index] then return end
    give(event.player_index)
end

--------------------------------------------------------------------------------------
-- 强制再发：cutscene 结束/取消后清掉 Freeplay 塞的开场手枪
-- late joiner 不经历 cutscene，不会触发此路径
local function ForceAddStartItem(event)
    give(event.player_index)
end

--------------------------------------------------------------------------------------
script.on_init(OnInit)
script.on_event(defines.events.on_player_created, AddStartItem)
script.on_event(defines.events.on_cutscene_cancelled, ForceAddStartItem)
script.on_event(defines.events.on_cutscene_finished, ForceAddStartItem)
