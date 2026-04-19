# CLAUDE.md

本文档为 Claude Code（claude.ai/code）在本仓库中工作时提供指引。

## 项目定位

Factorio 2.0 Mod（`LegendaryMechStart`），用 Lua 编写。仓库本身即是部署的 Mod——它以 `%APPDATA%/Factorio/mods/LegendaryMechStart/` 的形式被游戏直接加载，没有构建步骤、没有包管理器、没有测试套件。改代码后重启 Factorio（或重新载入存档）即生效。

`info.json` 声明的依赖：`base >= 2.0.76`、`space-age`、`quality`。代码里会直接使用 Space Age 和 Quality 提供的物品/API。

## 常用命令

- **运行 / 迭代**：启动 Factorio，启用本 Mod，开新游戏。没有 CLI。（注：Claude Code 跑在 WSL、Mod 文件通过 Windows 挂载访问，Claude 无法直接启动 Factorio 或 FactorioModDebug；运行验证需要你在 Windows 侧手工操作。）
- **语法检查**：`luac5.4 -p <file>.lua` 可以对 Lua 文件做 parse-only 校验，快速发现 `end` 缺失 / 括号不匹配等语法问题。不检查语义（undefined global、类型等）。
- **调试**：`.vscode/launch.json` 里配了三个 [FactorioModDebug](https://marketplace.visualstudio.com/items?itemName=justarandomgeek.factoriomod-debug) VS Code 插件的启动项（纯调试、hook settings+data、profile 模式）。追控制流问题时优先用它们，别靠 `print`。
- **打包发布**：把文件夹压缩成 `LegendaryMechStart_<version>.zip`，压缩包最外层是文件夹本身。版本号必须和 `info.json`、`changelog.txt` 顶条一致。
- **Changelog 格式**：Factorio 严格格式（99 个 `-` 的分隔行、`Version:`、`Date:`、缩进的 `Changes:` 块），用英文写。

## 架构

两个 Lua 文件，按职责故意拆开：

- **`control.lua`** — 只管事件注册，挂了三个处理器：
  - `on_init` → 初始化 `storage.given_items = {}`。
  - `on_player_created` → 调 `AddStartItem`，已发过物品的玩家直接跳过。
  - `on_cutscene_cancelled` + `on_cutscene_finished` → 调 `ForceAddStartItem`，**有意再清空、再发一遍**。这不是冗余：Freeplay 场景脚本会在开场动画结束时重新塞一批默认物品（手枪、子弹之类），我们需要第二轮把它们抹掉。改背包发放逻辑时保留这两段式结构。

- **`legendary_items.lua`** — 所有玩法逻辑。对外只导出一个函数 `add_start_items(player)`：
  1. 清空 `character_main`、`character_armor`、`character_guns`、`character_ammo` 四个库存。
  2. 塞一件传奇 `mech-armor`，通过 `init_legendary_mech_armor` 填满它的装备网格。
  3. 枪位填满传奇冲锋枪，弹药位填满传奇铀弹。
  4. 把 `preset_legendary_items` 列表塞进主背包。

### 机甲装备网格布局

装备网格是 **15 宽 × 17 高**（下标从 0 开始）。`init_legendary_mech_armor` 对每件装备用手写 `(x, y)` 坐标摆位，没有自动装箱算法。各装备占地要记牢：
- `fusion-reactor-equipment` 是 4×4；`exoskeleton-equipment` 是 2×4；`personal-roboport-mk2` / `personal-laser-defense` / `energy-shield-mk2` / `night-vision` 都是 2×2；`battery-mk3` 是 1×2；`toolbelt` 是 3×1；`solar-panel` / `belt-immunity` 是 1×1。
- 增删装备时，必须手工验证坐标+占地不撞别的装备、也别越过 15×17 的边。源文件里每行坐标旁的注释很多已经过期（写的是老坐标），**以数字为准，别信注释**。

### 状态模型（Factorio 2.0）

Factorio 2.0 把 1.x 的 `global` 改成了 `storage`。本 Mod 唯一持久化的状态就是 `storage.given_items[player_index] = true`。`AddStartItem` 里会防御性地再初始化一遍这个表，用来兼容在当前 Mod 版本还没跑过 `on_init` 的旧存档——重构时要保留这个保护。

### Quality 系统

每次 `insert` 物品都显式写 `quality` 字段（默认 `"legendary"`，部分批量物品如传送带 / 管道 / 箱子写 `"normal"`）。`give_legendary_items` 助手函数在没写 `quality` 时默认 `"legendary"`。**生产建筑是传奇、物流基础设施刻意保持普通**——这是预期的平衡，不要未经用户同意就把什么都升到传奇。

### Prototype 存在性检查

`give_legendary_items` 会在每次 `insert` 前先判断 `if prototypes.item[item_name] then`，这样当某个 DLC 被禁用或 prototype 改名时对应物品会静默跳过而不是崩溃。加新物品时保留这个检查。

## Factorio API 参考

- Wiki：<https://wiki.factorio.com/>
- Mod 站：<https://mods.factorio.com/>
- Mod settings 教程：<https://wiki.factorio.com/Tutorial:Mod_settings>
- Prototype API（data 阶段）：<https://lua-api.factorio.com/latest/index-prototype.html>
- Runtime API（control 阶段）：<https://lua-api.factorio.com/latest/index-runtime.html>

本 Mod 常用的运行时 API：
- `LuaPlayer::get_inventory`、`defines.inventory.character_main` / `character_armor` / `character_guns` / `character_ammo`
- `LuaInventory::insert`、`LuaInventory::clear`、`LuaItemStack::set_stack`
- `LuaEquipmentGrid::put`
- `prototypes.item[<name>]`（insert 前做存在性检查）
- `defines.events.on_init`、`on_player_created`、`on_cutscene_cancelled`、`on_cutscene_finished`

## 本地化

`locale/zh-CN/zh-CN.cfg` 提供中文翻译。注意 locale 文件里的 key 是 `factorio_LegendaryMechStart`，而 `info.json` 的 `name` 是 `LegendaryMechStart`——`[mod-name]` / `[mod-description]` 节里的 key 必须和 `info.json` 的 `name` 完全一致，Factorio 才会正确匹配。这是个已知不一致，动本地化时可以顺手改掉。

## 语言约定

- Lua 代码注释、`CLAUDE.md`：**中文**。改到已有文件时，双语注释只保留中文那一半；新注释只写中文。
- `README.md`、`changelog.txt`、`info.json` 的 `description` / `title`、Mod portal 上对外展示的内容：**英文**。已有的双语条目在下次编辑到它时切换成纯英文。
- `locale/*.cfg` 按对应语言写。
- 版权头 `-- Copyright The MRNIU/factorio_LegendaryMechStart Contributors` 必须保留在每个 Lua/cfg 文件顶部。
- 技术标识符（函数名、API 字段、事件名）不翻译，用反引号包住原样保留。
