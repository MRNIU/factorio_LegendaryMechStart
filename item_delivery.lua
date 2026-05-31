-- Copyright The MRNIU/factorio_LegendaryMechStart Contributors

local M = {}

local DEFAULT_CHEST_NAME    = "steel-chest"
local DEFAULT_CHEST_QUALITY = "normal"
local DEFAULT_CHEST_RADIUS  = 15

local function normalise_item(spec, default_quality)
    if not (spec and spec.name and spec.count and spec.count > 0) then return nil end
    if not prototypes.item[spec.name] then return nil end

    return {
        name    = spec.name,
        count   = spec.count,
        quality = spec.quality or default_quality or "normal",
    }
end

function M.copy_items(items, default_quality)
    local copied = {}
    for _, spec in ipairs(items or {}) do
        local item = normalise_item(spec, default_quality)
        if item then copied[#copied + 1] = item end
    end
    return copied
end

function M.insert_into_inventory(inv, items, default_quality, label)
    if not inv then
        return M.copy_items(items, default_quality)
    end

    local leftover = {}
    for _, spec in ipairs(items or {}) do
        local item = normalise_item(spec, default_quality)
        if item then
            local inserted = inv.insert({
                name    = item.name,
                count   = item.count,
                quality = item.quality,
            })
            if inserted < item.count then
                if label then
                    log(("[LegendaryMechStart] %s inserted %d/%d %s (%s)")
                        :format(label, inserted, item.count, item.name, item.quality))
                end
                leftover[#leftover + 1] = {
                    name    = item.name,
                    count   = item.count - inserted,
                    quality = item.quality,
                }
            end
        end
    end
    return leftover
end

function M.dump_into_chests(surface, center, force, items, options)
    if not (surface and surface.valid and center) then
        return 0, M.copy_items(items, "normal")
    end

    options = options or {}
    local chest_name    = options.chest_name or DEFAULT_CHEST_NAME
    local chest_quality = options.chest_quality or DEFAULT_CHEST_QUALITY
    local radius        = options.radius or DEFAULT_CHEST_RADIUS
    local remaining     = M.copy_items(items, "normal")
    local chest_count   = 0

    while #remaining > 0 do
        local pos = surface.find_non_colliding_position(chest_name, center, radius, 1)
        if not pos then break end

        local chest = surface.create_entity({
            name        = chest_name,
            position    = pos,
            force       = force,
            quality     = chest_quality,
            raise_built = true,
        })
        if not (chest and chest.valid) then break end

        local chest_inv = chest.get_inventory(defines.inventory.chest)
        if not chest_inv then break end

        chest_count = chest_count + 1
        local inserted_any = false
        while #remaining > 0 do
            local item = remaining[1]
            local inserted = chest_inv.insert({
                name    = item.name,
                count   = item.count,
                quality = item.quality,
            })
            if inserted == 0 then
                break
            end

            inserted_any = true
            if inserted >= item.count then
                table.remove(remaining, 1)
            else
                item.count = item.count - inserted
                break
            end
        end

        if not inserted_any then break end
    end

    return chest_count, remaining
end

function M.spill_items(surface, center, force, items)
    if not (surface and surface.valid and center) then return 0 end

    local spilled = 0
    for _, item in ipairs(items or {}) do
        local stack = normalise_item(item, "normal")
        if stack then
            surface.spill_item_stack({
                position      = center,
                stack         = stack,
                enable_looted = true,
                force         = force,
                allow_belts   = false,
            })
            spilled = spilled + stack.count
        end
    end
    return spilled
end

return M
