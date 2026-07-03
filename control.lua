-- Copyright The MRNIU/factorio_LegendaryMechStart Contributors

local legendary_items  = require("legendary_items")
local legendary_spider = require("legendary_spider")

local SETTING_SPAWN_SPIDERTRON = "LegendaryMechStart-spawn-spidertron"

-- ============================================================================
-- 持久化状态
--   storage.given_items[player_index] = true  该玩家已经发过个人包
--   storage.team_cache_placed                 整档只一次：团队资源是否已发放
--   storage.pending_spider_surfaces[index]    下一 tick 再生成蜘蛛，避开清理流水线
--   storage.pending_spider_cargo[index]       蜘蛛装备刷新后再插 trunk / ammo
--   storage.pending_player_loadouts[index]    玩家机甲装备刷新后再插个人背包
--   storage.spawned_spider_surfaces[index]    该 surface 已经处理过蜘蛛生成
--
-- 发放模型：
--   - 每个玩家 on_player_created 时拿 PERSONAL 包（进背包）
--   - 蜘蛛开关开启时，团队资源随 Nauvis 蜘蛛进入 trunk，不再地面落箱
--   - 蜘蛛开关关闭时，第一个被创建的玩家触发团队箱落地
--   - host 经历 cutscene 会再触发 ForceAddStartItem，这时只重发个人包；
--     `storage.team_cache_placed` 已是 true，不会重复生成团队资源
--   - late joiner 不经历 cutscene，ForceAddStartItem 对他们不触发
-- ============================================================================

local function ensure_storage()
    if not storage.given_items then storage.given_items = {} end
    if storage.team_cache_placed == nil then storage.team_cache_placed = false end
    if not storage.pending_spider_surfaces then storage.pending_spider_surfaces = {} end
    if not storage.pending_spider_cargo then storage.pending_spider_cargo = {} end
    if not storage.pending_player_loadouts then storage.pending_player_loadouts = {} end
    if not storage.spawned_spider_surfaces then storage.spawned_spider_surfaces = {} end
end

local OnTick

local function due_keys(queue)
    local keys = {}
    for key, ready_tick in pairs(queue) do
        if ready_tick <= game.tick then keys[#keys + 1] = key end
    end
    return keys
end

local function ensure_tick_handler()
    script.on_event(defines.events.on_tick, OnTick)
end

local function has_pending_work()
    return next(storage.pending_spider_surfaces) ~= nil
        or next(storage.pending_spider_cargo) ~= nil
        or next(storage.pending_player_loadouts) ~= nil
end

local function spawn_spidertron_enabled()
    local s = settings.global[SETTING_SPAWN_SPIDERTRON]
    return s == nil or s.value
end

local function is_planet_surface(surface)
    return surface and surface.valid and (surface.name == "nauvis" or surface.planet)
end

local function queue_spider(surface)
    ensure_storage()
    if not spawn_spidertron_enabled() then return end
    if not is_planet_surface(surface) then return end
    if storage.spawned_spider_surfaces[surface.index] then return end
    if storage.pending_spider_surfaces[surface.index] then
        ensure_tick_handler()
        return
    end

    storage.pending_spider_surfaces[surface.index] = game.tick + 1
    ensure_tick_handler()
end

local function queue_spider_cargo(surface)
    ensure_storage()
    if not is_planet_surface(surface) then return end
    if storage.pending_spider_cargo[surface.index] then
        ensure_tick_handler()
        return
    end

    storage.pending_spider_cargo[surface.index] = game.tick + 1
    ensure_tick_handler()
end

local function queue_player_loadout(player)
    ensure_storage()
    if not (player and player.valid) then return end
    if storage.pending_player_loadouts[player.index] then
        ensure_tick_handler()
        return
    end

    storage.pending_player_loadouts[player.index] = game.tick + 1
    ensure_tick_handler()
end

local function queue_all_planet_surfaces()
    for _, surface in pairs(game.surfaces) do
        if is_planet_surface(surface) then queue_spider(surface) end
    end
end

local function notify_players(message)
    for _, player in pairs(game.connected_players) do
        player.print(message)
    end
end

local function OnInit()
    storage.given_items              = {}
    storage.team_cache_placed        = false
    storage.pending_spider_surfaces  = {}
    storage.pending_spider_cargo     = {}
    storage.pending_player_loadouts  = {}
    storage.spawned_spider_surfaces  = {}
    queue_all_planet_surfaces()
end

OnTick = function()
    ensure_storage()
    for _, surface_index in ipairs(due_keys(storage.pending_spider_surfaces)) do
        storage.pending_spider_surfaces[surface_index] = nil

        local surface = game.surfaces[surface_index]
        if surface and surface.valid and spawn_spidertron_enabled() then
            local ok, result = pcall(legendary_spider.spawn_on_surface, surface, game.forces.player)
            if ok then
                storage.spawned_spider_surfaces[surface_index] = result and true or nil
                if result then
                    queue_spider_cargo(surface)
                end
            else
                log(("[LegendaryMechStart] spider stage failed on %s: %s")
                    :format(surface.name, tostring(result)))
            end
        end
    end

    for _, surface_index in ipairs(due_keys(storage.pending_spider_cargo)) do
        storage.pending_spider_cargo[surface_index] = nil

        local surface = game.surfaces[surface_index]
        if surface and surface.valid and spawn_spidertron_enabled() then
            local ok, spider, spilled = pcall(
                legendary_spider.fill_cargo_on_surface, surface, game.forces.player)
            if ok and spider then
                if surface.name == "nauvis" and not storage.team_cache_placed then
                    storage.team_cache_placed = true
                    local overflow_note = ""
                    if (spilled or 0) > 0 then
                        overflow_note = " Unexpected overflow was spilled near the spidertron."
                    end
                    notify_players("[LegendaryMechStart] Team resources loaded into the Nauvis spidertron trunk." ..
                        overflow_note)
                end
            elseif ok then
                storage.spawned_spider_surfaces[surface_index] = nil
                log(("[LegendaryMechStart] spider cargo stage found no spider on %s")
                    :format(surface.name))
            else
                log(("[LegendaryMechStart] spider cargo stage failed on %s: %s")
                    :format(surface.name, tostring(spider)))
            end
        end
    end

    for _, player_index in ipairs(due_keys(storage.pending_player_loadouts)) do
        storage.pending_player_loadouts[player_index] = nil

        local player = game.players[player_index]
        if player and player.valid then
            local ok, finished, spilled = pcall(
                legendary_items.finish_start_items, player)
            if ok and finished then
                storage.given_items[player_index] = true
                if (spilled or 0) > 0 then
                    player.print("[LegendaryMechStart] Some personal starter items did not fit in your inventory; " ..
                        "the remainder was spilled near your character.")
                end
            elseif ok then
                queue_player_loadout(player)
            else
                log(("[LegendaryMechStart] player loadout stage failed for player %d: %s")
                    :format(player_index, tostring(finished)))
            end
        end
    end

    if not has_pending_work() then
        script.on_event(defines.events.on_tick, nil)
    end
end

local function give(player_index)
    ensure_storage()
    local player = game.players[player_index]
    if not (player and player.valid) then return end

    legendary_items.prepare_start_items(player)
    queue_player_loadout(player)

    if not storage.team_cache_placed then
        if spawn_spidertron_enabled() then
            queue_spider(game.surfaces.nauvis or player.surface)
        else
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
                    " steel chests at map spawn (any remainder spilled on the ground).")
            else
                player.print("[LegendaryMechStart] No free tiles within 15 of map spawn; " ..
                    "all team resources spilled on the ground there.")
            end
        end
    end
end

--------------------------------------------------------------------------------------
-- 首次发放：on_player_created（每玩家最多触发一次）
local function AddStartItem(event)
    ensure_storage()
    if storage.given_items[event.player_index] then return end
    if storage.pending_player_loadouts[event.player_index] then return end
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
script.on_configuration_changed(function()
    ensure_storage()
end)
script.on_event(defines.events.on_player_created, AddStartItem)
script.on_event(defines.events.on_cutscene_cancelled, ForceAddStartItem)
script.on_event(defines.events.on_cutscene_finished, ForceAddStartItem)
script.on_event(defines.events.on_surface_created, function(event)
    local surface = game.surfaces[event.surface_index]
    queue_spider(surface)
end)
script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
    if event.setting == SETTING_SPAWN_SPIDERTRON and spawn_spidertron_enabled() then
        queue_all_planet_surfaces()
    end
end)
