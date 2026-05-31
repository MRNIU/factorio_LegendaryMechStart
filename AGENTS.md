# AGENTS.md

本文档为 Claude Code（claude.ai/code）在本仓库中工作时提供指引。

## 项目定位

Factorio 2.0 Mod（`LegendaryMechStart`），用 Lua 编写。仓库本身即是部署的 Mod——它以 `%APPDATA%/Factorio/mods/LegendaryMechStart/` 的形式被游戏直接加载，没有构建步骤、没有包管理器、没有测试套件。改代码后重启 Factorio（或重新载入存档）即生效。

`info.json` 声明的依赖：`base >= 2.0.76`、`space-age`、`quality`。代码里会直接使用 Space Age 和 Quality 提供的物品 / API。

## 兄弟 Mod

本 Mod 是 NZH 维护的开局 Mod 家族的一员：

- **`LegendaryMechStart`（本仓库）** — 传奇机甲 + 装备网格 + 个人包 + 行星蜘蛛载货 + 团队资源兜底箱
- [`LegendaryShipStart`](https://github.com/MRNIU/factorio_LegendaryShipStart) — 预置传奇太空飞船
- [`BestLanding`](https://github.com/MRNIU/factorio_BestLanding) — 着陆区清理 + 行星资源 + 起始蓝图
- [`nzh_factorio_mod`](https://github.com/MRNIU/nzh_factorio_mod) — 整合包，一键启用上面三个

**如果发现本 Mod 要做的事和兄弟 Mod 重叠了**（比如"清理着陆区" vs `BestLanding`、"生成太空飞船" vs `LegendaryShipStart`），先停下问用户，不要在本仓库重复实现。

和 `BestLanding` 交互时尤其要注意：它在 `on_init` 会在 spawn 附近清地并铺一张几十万字符的蓝图，会把玩家的实际落点推到几十瓦片外。本 Mod 的兜底团队箱放置因此**锚定 `LuaForce::get_spawn_position(surface)`**（默认 `(0, 0)`）而不是 `player.position`。传奇蜘蛛生成延后一 tick，避免抢在 `BestLanding` 清理流水线之前落地后又被删掉。

## 常用命令

- **运行 / 迭代**：启动 Factorio，启用本 Mod，开新游戏。没有 CLI。（注：Claude Code 跑在 WSL、Mod 文件通过 Windows 挂载访问，Claude 无法直接启动 Factorio 或 FactorioModDebug；运行验证需要你在 Windows 侧手工操作。）
- **语法检查 / 预提交**：改完任何 `.lua` 后跑一次 `for f in *.lua; do luac5.4 -p "$f" || break; done`（全 Mod 扫一遍 < 100 ms），能抓 `end` 缺失 / 括号不匹配 / 字符串没闭合等语法问题；**不查语义**（undefined global、类型错误等）。
- **调试**：`.vscode/launch.json` 里配了三个 [FactorioModDebug](https://marketplace.visualstudio.com/items?itemName=justarandomgeek.factoriomod-debug) VS Code 插件的启动项（纯调试、hook settings+data、profile 模式）。追控制流问题时优先用它们，别靠 `print`。
- **打包发布**：把文件夹压缩成 `LegendaryMechStart_<version>.zip`，压缩包最外层是文件夹本身。版本号必须和 `info.json`、`changelog.txt` 顶条一致。
- **Changelog 格式**：Factorio 严格格式（99 个 `-` 的分隔行、`Version:`、`Date:`、缩进的 `Changes:` 块），用英文写。

## 架构

多个 Lua 文件，按职责拆开：

### `control.lua` — 事件注册 + 状态机

- `on_init` → 初始化 `storage.given_items = {}`、`storage.team_cache_placed = false`、蜘蛛生成/载货队列、玩家个人包队列，并把 Nauvis 加入待生成队列。
- `on_player_created` → 调 `AddStartItem`，已发过个人包的玩家直接跳过。
- `on_cutscene_cancelled` + `on_cutscene_finished` → 调 `ForceAddStartItem`，**有意再清背包、再发个人包**（用来抹掉 Freeplay 开场动画结束时塞给 host 的手枪 + 手枪子弹）。team cache 只看 `storage.team_cache_placed`，不会重发。
- `on_surface_created` → 对新行星 surface 加入蜘蛛生成队列；太空平台跳过。
- `on_tick` → 只在队列非空时临时注册：下一 tick 生成蜘蛛，再下一 tick 填 trunk / ammo；玩家个人背包也延后一 tick 插入。这样等兄弟 Mod 完成同一事件里的清理 / 蓝图后再找落脚点，同时给工具腰带的背包容量加成时间刷新。
- `on_runtime_mod_setting_changed` → 打开蜘蛛开关时，扫描已有行星 surface，为还没处理过的 surface 排队。
- 蜘蛛开关开启时，Nauvis 团队资源随 Nauvis 蜘蛛进入 trunk，不落地生成箱子；蜘蛛开关关闭时才由首个玩家触发 `legendary_items.place_team_cache`，在 spawn 附近生成普通钢箱兜底。

持久化状态：

| 字段 | 语义 |
| :-- | :-- |
| `storage.given_items[player_index] = true` | 这个玩家已经发过个人包 |
| `storage.team_cache_placed : bool` | 整档的团队资源是否已经进入 Nauvis 蜘蛛或兜底箱 |
| `storage.pending_spider_surfaces[index] = tick` | 到 tick 后需要尝试生成蜘蛛的 surface |
| `storage.pending_spider_cargo[index] = tick` | 到 tick 后需要给该 surface 蜘蛛填 trunk / ammo |
| `storage.pending_player_loadouts[player_index] = tick` | 到 tick 后需要给该玩家主背包插入个人包 |
| `storage.spawned_spider_surfaces[index] = true` | 该 surface 已经生成或检测到起始蜘蛛 |

### `legendary_items.lua` — 玩法逻辑

对外导出四个函数：

| 函数 | 作用 |
| :-- | :-- |
| `prepare_start_items(player)` | 清 4 个库存 → 穿传奇机甲并装箱装备网格 → 武器槽和弹药槽铺满 |
| `finish_start_items(player)` | 在下一 tick 按 `PERSONAL_WISHLIST` 塞主背包；插不满的部分进附近普通钢箱，再放不下才 spill |
| `add_start_items(player)` | 兼容包装：立即执行 `prepare_start_items` + `finish_start_items` |
| `place_team_cache(surface, center, force)` | 蜘蛛关闭时的兜底：在 `center` 附近半径 15 瓦片内找空地，放普通钢箱并装入 Nauvis 团队清单；放不下的部分 `spill_item_stack` 撒到 `center`，**不会破坏任何既有实体** |

个人包和机甲装备仍在本文件里；团队资源和蜘蛛背包改到 `starter_loadouts.lua`：

| 表 | 含义 |
| :-- | :-- |
| `EQUIPMENT_WISHLIST` | 机甲装备按优先级排的 `{name, count}` 列表，`equipment_grid.pack` 用 first-fit 自动算坐标 |
| `PERSONAL_WISHLIST` | 每个玩家都发的个人包（`{name, count, quality}`） |
### `starter_loadouts.lua` — 团队资源 + 行星蜘蛛载货

- `COMMON_TRUNK_WISHLIST`：每颗行星蜘蛛都有的建设/物流/维护包。
- `DEFENSE_TRUNK_WISHLIST`：只给 Nauvis / Vulcanus / Gleba 的防御包；Fulgora / Aquilo 不给武器弹药。
- `PLANET_TRUNK_WISHLISTS`：按 `surface.name` 分发的行星专属 cargo。
- `ammo_fill_for_surface(surface_name)`：只给有防御包的行星返回蜘蛛 `spider_ammo` 槽火箭，**不要把这部分挪进 trunk**。
- `team_cache_wishlist()`：蜘蛛关闭时的兜底箱清单，复用 common + defense + Nauvis 专属 cargo，避免两份表漂移。

### `legendary_spider.lua` — 行星传奇蜘蛛

- `spawn_on_surface(surface, force)` 在 `(0,0)` 附近找不碰撞位置生成传奇 `spidertron`。
- 搜索半径按 `{128, 256, 512}` 逐级放宽，三档都失败才退回 `(0,0)` 并写 log。
- 生成前会在 512 半径内检查是否已有玩家势力 `spidertron`，用于避免老存档从 `BestLanding` 迁移过来后重复生成。
- 蜘蛛装备网格走 `equipment_grid.pack`，清单正好填满 legendary spidertron 的 15×11 网格。
- `spawn_on_surface` 只负责找/建蜘蛛和装装备网格；control 会排 `pending_spider_cargo`，下一 tick 才填 trunk / ammo。
- trunk / ammo 插入前检查 `prototypes.item`；插不满会写 log，并把剩余物品转入蜘蛛旁的普通钢箱，再放不下才 spill。
- `fill_cargo_on_surface` 返回蜘蛛实体；control 用这个返回值判断 Nauvis 团队资源是否已完成。
- 填 cargo 前会重新读取 trunk，并记录 trunk 槽数、网格尺寸、工具腰带数量和 `LuaEquipmentGrid::inventory_bonus`。

### `item_delivery.lua` — 插入与溢出兜底

- `insert_into_inventory(inv, items, default_quality, label)` 统一处理 `LuaInventory::insert` 返回值，返回未插入的 leftover；有 `label` 时会记录 partial insert。
- `dump_into_chests(surface, center, force, items, options)` 在指定中心附近放普通钢箱并塞 leftover，不破坏既有实体。
- `spill_items(surface, center, force, items)` 只作为最后兜底；个人包和蜘蛛 cargo/ammo 都必须先走钢箱。

### `equipment_grid.lua` — 通用 first-fit 装箱

- `pack(grid, wishlist, default_quality)` 读取 `prototypes.equipment[name].shape`，按 wishlist 顺序从左上到右下找第一个空矩形。
- 玩家机甲和蜘蛛机甲都用这套逻辑。改装备数量时优先调整 wishlist，不手写坐标。

### 装备网格自动装箱

装备网格 **15 宽 × 17 高**（legendary `mech-armor`，下标从 0 开始）。`equipment_grid.pack` 按 wishlist 顺序逐件调 `find_first_fit(grid, w, h)` 从左上往右下扫第一个空矩形。**大件放前面**（2×4 外骨骼、4×4 核聚变反应堆），否则会被小件切碎后放不下。

**wishlist 总占格必须 ≤ 255**（不含 `solar-panel` 这种填缝项）。`find_first_fit` 放不下时**静默跳过**该装备，不报错也不警告——`night-vision` / `belt-immunity` 这种 `count=1` 的小件超额时会直接消失。改任何 count 前先把每件 `count × width × height` 重新加一遍，逼近 255 时尤其要小心碎片化（小件的形状决定了实际可用空间小于面积差）。

尺寸速查：
- `fusion-reactor-equipment` 4×4；`exoskeleton-equipment` 2×4；
- `personal-roboport-mk2` / `personal-laser-defense` / `energy-shield-mk2` / `night-vision` 都是 2×2；
- `battery-mk3` 1×2；`toolbelt` 3×1；`solar-panel` / `belt-immunity` 1×1。

### 团队资源兜底箱布置

- 只在蜘蛛开关关闭时使用。蜘蛛开启时，团队资源进入 Nauvis 蜘蛛 trunk，不在地上生成箱子。
- 圆心是 `player.force.get_spawn_position(player.surface)`，默认 `(0, 0)`，**不是 `player.position`**——引擎会因为 `BestLanding` 的蓝图占满 spawn 而把玩家推出去几十瓦片。
- 半径 15 瓦片（`TEAM_CHEST_RADIUS`）；每轮 `find_non_colliding_position` 返回离圆心最近的空格，放好箱子再循环，从而箱子会围着 spawn 聚成一小团。
- 箱子是普通 `steel-chest`，符合“大规模基础设施/容器不升品质”的规则。
- 半径内没有空位时退化为 `spill_item_stack` 撒到 `(0, 0)`。

### 容量预算与溢出保底

- 背包可用槽 = 80（基础）+ 125（legendary mech-armor）+ 125（5 × legendary toolbelt）= **330 槽**。
- `PERSONAL_WISHLIST` ~16 堆；正常应全部进入玩家主背包，但仍要保留 `insert` leftover 处理，因为工具腰带 bonus 可能在装备后下一 tick 才刷新。
- 蜘蛛 trunk / ammo 也延后一 tick 再插入；如果工具腰带 bonus 仍没刷新，leftover 会进蜘蛛旁普通钢箱，避免科技瓶或弹药静默丢失。

### Quality 系统

每个 wishlist 条目都显式写 `quality`；没写的话 `equipment_grid.pack` / 个人包插入仍默认 `"legendary"`，`starter_loadouts` 里的插入默认 `"normal"`。当前平衡规则：核心生产建筑、采矿机、抽油机、回收机、农业塔、模块、信标用传奇；机械臂、机器人、机器人港、武器弹药、炮塔、电力设备、箱子、传送带、管道、地砖、矿物、原料、中间产物用普通。

### Prototype 存在性检查

`item_delivery.insert_into_inventory`、`place_team_cache`、`equipment_grid.pack`、蜘蛛 trunk / ammo 填充在每次插入/放置前都先查 `prototypes.item[name]` 或 `prototypes.equipment[name]`；这样 DLC 被禁用或 prototype 改名时对应条目会静默跳过而不是崩溃。加新物品时保留这个检查。

## Factorio API 参考

- Wiki：<https://wiki.factorio.com/>
- Mod 站：<https://mods.factorio.com/>
- Prototype API（data 阶段）：<https://lua-api.factorio.com/latest/index-prototype.html>
- Runtime API（control 阶段）：<https://lua-api.factorio.com/latest/index-runtime.html>

本 Mod 常用的运行时 API：

- `LuaPlayer::get_inventory`、`defines.inventory.character_main` / `character_armor` / `character_guns` / `character_ammo` / `chest`
- `LuaInventory::insert` / `clear`、`LuaItemStack::set_stack`
- `LuaEquipmentGrid::put` / `get`、`width` / `height`、`prototypes.equipment[<name>].shape.{width,height}`
- `LuaSurface::find_non_colliding_position` / `find_entities_filtered` / `create_entity` / `spill_item_stack`
- `LuaForce::get_spawn_position(surface)`（用它而不是 `player.position` 作兜底团队箱圆心）
- `defines.inventory.spider_trunk` / `spider_ammo`
- `settings.global`、`defines.events.on_runtime_mod_setting_changed`
- `defines.events.on_init` / `on_configuration_changed` / `on_player_created` / `on_cutscene_cancelled` / `on_cutscene_finished` / `on_surface_created` / `on_tick`

## 本地化

`locale/zh-CN/zh-CN.cfg` 提供中文翻译。`[mod-name]` / `[mod-description]` 节里的 key 必须和 `info.json` 的 `name`（`LegendaryMechStart`）完全一致，Factorio 才会正确匹配。

## 语言约定

- Lua 代码注释、`AGENTS.md`：**中文**。新注释只写中文。
- `README.md`、`changelog.txt`、`info.json` 的 `description` / `title`、Mod portal 上对外展示的内容：**英文**。
- `locale/*.cfg` 按对应语言写。
- 版权头 `-- Copyright The MRNIU/factorio_LegendaryMechStart Contributors` 必须保留在每个 Lua / cfg 文件顶部。
- 技术标识符（函数名、API 字段、事件名）不翻译，用反引号包住原样保留。
