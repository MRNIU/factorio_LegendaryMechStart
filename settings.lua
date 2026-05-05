-- Copyright The MRNIU/factorio_LegendaryMechStart Contributors
-- 设置阶段：声明 Mod settings。runtime-global 表示整张地图统一开关。

data:extend({
    {
        type          = "bool-setting",
        name          = "LegendaryMechStart-spawn-spidertron",
        setting_type  = "runtime-global",
        default_value = true,
        order         = "a-spidertron",
    },
})
