-- Copyright The MRNIU/factorio_LegendaryMechStart Contributors

local M = {}

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

function M.pack(grid, wishlist, default_quality)
    if not (grid and wishlist) then return end

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
                if not grid.put({ name = spec.name, position = pos, quality = quality }) then
                    break
                end
            end
        end
    end
end

return M
