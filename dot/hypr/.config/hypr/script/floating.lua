local f = require("script.helper")
local M = {}

local function video(rules)
    return function()
        local win = f.active_win()
        local mon = f.active_mon()
        if not win or not mon then return end

        local corner = rules.corner
        if corner == "next" or corner == "prev" then
            local curr = f.get_corner_index(win, mon)
            local step = (corner == "next") and 1 or -1
            local next_idx = ((curr + step - 1) % #f.CORNERS) + 1
            corner = f.CORNERS[next_idx]
        elseif not corner and rules.prop then
            corner = f.CORNERS[f.get_corner_index(win, mon)]
        end

        if rules.prop then
            local target
            if rules.prop == "next" or rules.prop == "prev" then
                local dir = (rules.prop == "next") and 1 or -1
                local next_prop, current_prop = f.get_next_size(win.size.x, win.size.y, dir)
                local ratio = next_prop / current_prop
                target = { x = win.size.x * ratio, y = win.size.y * ratio }
            else
                target = f.size(rules.prop, rules.dimension)
            end
            f.new():resize(target):run()
        end

        if corner then
            win = f.active_win()
            f.new():move(f.get_corner_pos(corner, win, mon)):run()
        end
        f.new():cursor(f.get_center_pos(f.active_win())):run()
    end
end

function M.float()
    return f.new():float({ action = "toggle" }):done()
end

function M.pin()
    return f.new():pin({ action = "toggle" }):done()
end

function M.float_corner()
    return function()
        f.new()
            :float({ action = "toggle" })
            :pin({ action = "toggle" })
            :resize(f.BASE_RESOLUTION)
            :run()
        video({ prop = f.SIZES[4], corner = "br" })()
    end
end

function M.clockwise()
    return video({ corner = "next" })
end

function M.anticlockwise()
    return video({ corner = "prev" })
end

function M.enlarge()
    return video({ prop = "next" })
end

function M.shrink()
    return video({ prop = "prev" })
end

return M
