local M = {}

M.magnitude = 10

function M.move(x, y)
    local csr = hl.get_cursor_pos()
    -- hl.config({
    --     input = {
    --         repeat_delay = 0,
    --         repeat_rate = 1000
    --     }
    -- })
    hl.dispatch(hl.dsp.cursor.move({ x = csr.x + x * M.magnitude, y = csr.y + y * M.magnitude }))
    -- hl.config({
    --     input = {
    --         repeat_delay = 100,
    --         repeat_rate = 5
    --     }
    -- })
end

function M.left()
    return function() M.move(-1, 0) end
end

function M.right()
    return function() M.move(1, 0) end
end

function M.up()
    return function() M.move(0, -1) end
end

function M.down()
    return function() M.move(0, 1) end
end

return M
