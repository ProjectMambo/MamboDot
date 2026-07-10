local M = {}

M.NUM_WORKSPACE = 10
M.TEMP_WORKSPACE = "temp"

-- ============================================================
-- INTERNAL STATE / TYPES
-- ============================================================

-- Builder: the chainable object returned by M.new(). Holds a queue of
-- deferred actions (run later via :run()/:done()) plus keybind state
-- (mod/key/rules/temp) used by the immediate-bind methods below.
local Builder = {}
Builder.__index = Builder

-- ============================================================
-- INTERNAL HELPERS
-- ============================================================

-- is_callable: returns true if `v` is a plain Lua function.
local function is_callable(v)
    return type(v) == "function"
end

-- run_one: recursively evaluates a "command" shape, where a command may be
-- a string, a function, or a table nesting more of the same. Functions are
-- called directly; strings are handed to `dispatcher`. Returns the value
-- produced by the last leaf visited.
local function run_one(v, dispatcher)
    if type(v) == "table" then
        local result
        for _, item in ipairs(v) do
            result = run_one(item, dispatcher)
        end
        return result
    elseif is_callable(v) then
        return v()
    else
        return dispatcher(v)
    end
end

-- make_action: wraps a tree-shaped command (string / function / nested
-- table) into a zero-arg action function, using run_one to walk it.
local function make_action(cmd, dispatcher)
    return function()
        return run_one(cmd, dispatcher)
    end
end

-- make_single_action: wraps a single opaque argument (e.g. a rules table)
-- into a zero-arg action function that hands it straight to `dispatcher`,
-- with no tree-walking (unlike make_action).
local function make_single_action(arg, dispatcher)
    return function()
        return dispatcher(arg)
    end
end

-- dsp: wraps a resolver function so its return value is routed through
-- hl.dispatch. If `rules` is provided, it's forwarded to the resolver.
local function dsp(resolver, rules)
    return function(c)
        if rules ~= nil then
            return hl.dispatch(resolver(c, rules))
        end
        return hl.dispatch(resolver(c))
    end
end

-- capture: runs `cmd` synchronously via io.popen and returns its stdout,
-- trimmed of trailing whitespace. Returns "" if the command can't be run.
local function capture(cmd)
    local handle = io.popen(cmd)
    if not handle then return "" end
    local result = handle:read("*a") or ""
    handle:close()
    return result:gsub("%s+$", "")
end

-- wrap: resolves a relative workspace target ("l" / "r") against the
-- currently active workspace, wrapping around at the ends. Any other
-- target is passed through unchanged.
local function wrap(current, target)
    local id = current.id
    if target == "l" then
        return (id == 1) and M.NUM_WORKSPACE or (id - 1)
    elseif target == "r" then
        return (id == M.NUM_WORKSPACE) and 1 or (id + 1)
    else
        return target
    end
end

-- override: shallow-merges `add` into `rules` in place, overwriting any
-- matching keys. Returns `rules` for convenience. No-op if `add` is nil.
local function override(rules, add)
    if add then
        for k, v in pairs(add) do rules[k] = v end
    end
    return rules
end

-- merge_list: appends each element of `extra` onto `target`, in place.
-- Returns `target` for convenience. No-op if `extra` is nil.
local function merge_list(target, extra)
    if not extra then return target end
    for _, v in ipairs(extra) do
        table.insert(target, v)
    end
    return target
end

-- build_combo: joins accumulated mod/key fragments into a "MOD + KEY"
-- combo string, as expected by hl.bind().
local function build_combo(mods, key)
    return table.concat(mods) .. " + " .. table.concat(key)
end

-- extract_dsp_rules: pulls (dispatcher, rules) out of an opts table.
-- Supports both the named form (opts.dsp / opts.rules) and the
-- positional form { ..., dsp_value, rules_value }.
local function extract_dsp_rules(opts)
    return opts.dsp or opts[1], opts.rules or opts[2]
end

-- ============================================================
-- PUBLIC HELPERS — workspace/window utilities (standalone, not part
-- of the Builder chain)
-- ============================================================

-- M.is_special: true if `ws` is a special (scratchpad-style) workspace.
function M.is_special(ws)
    return ws.name:find("special:", 1, true)
end

-- M.active_ws: returns the currently active workspace.
function M.active_ws()
    return hl.get_active_workspace()
end

-- M.active_win: returns the currently active/focused window.
function M.active_win()
    return hl.get_active_window()
end

-- M.active_mon: returns the currently active monitor.
function M.active_mon()
    return hl.get_active_monitor()
end

-- M.windows: returns the list of windows on workspace `ws` (empty table
-- if none).
function M.windows(ws)
    return hl.get_workspace_windows(ws) or {}
end

-- M.safe: normalizes a workspace target into the form hl expects:
--   number        -> stringified number
--   "l" / "r"     -> resolved relative to the active workspace
--   anything else -> treated as a special workspace name ("special:...")
function M.safe(ws)
    if type(ws) == "number" then
        return tostring(ws)
    elseif ws == "l" or ws == "r" then
        local current = M.active_ws()
        if not current and M.is_special(current) then
            M.new():notify("Could not determine active non-special workspace", "Fallback to workspace 1"):run()
            return "1"
        end
        return tostring(wrap(current, ws))
    else
        return "special:" .. tostring(ws)
    end
end

-- ============================================================
-- PUBLIC HELPERS — window geometry (corner/size math for floating
-- windows, standalone, not part of the Builder chain)
-- ============================================================

-- M.BASE_RESOLUTION: reference resolution that M.SIZES proportions are
-- computed against.
M.BASE_RESOLUTION = { x = 1920, y = 1080 }

-- M.SIZES: the size steps (as a proportion of M.BASE_RESOLUTION) that
-- M.get_next_size() cycles through.
M.SIZES = { 0.1, 0.2, 0.3, 0.4, 0.6 }

-- M.CORNER_OFFSET: pixel gap kept between a corner-anchored window and
-- the monitor edge.
M.CORNER_OFFSET = 2

-- M.CORNERS: clockwise ordering of corner names, used by
-- M.get_corner_index()/M.get_pos() and for stepping "next"/"prev".
M.CORNERS = { "ul", "ur", "br", "bl" }

-- M.size: returns { x, y } pixel dimensions for a window at proportion
-- `prop` of `dimension` (defaults to M.BASE_RESOLUTION).
function M.size(prop, dimension)
    local dim = dimension or M.BASE_RESOLUTION
    return { x = dim.x * prop, y = dim.y * prop }
end

-- M.get_corner_index: returns which corner (1=ul, 2=ur, 3=br, 4=bl) of
-- monitor `mon` window `win`'s center currently falls in.
function M.get_corner_index(win, mon)
    local cx = win.at.x + (win.size.x / 2)
    local cy = win.at.y + (win.size.y / 2)
    local mw, mh = mon.width, mon.height
    if cx < mw / 2 and cy < mh / 2 then return 1 end
    if cx >= mw / 2 and cy < mh / 2 then return 2 end
    if cx >= mw / 2 and cy >= mh / 2 then return 3 end
    return 4
end

-- M.get_pos: returns the { x, y } top-left position that anchors window
-- `win` to corner `c` ("ul"/"ur"/"br"/"bl") of monitor `mon`, keeping
-- M.CORNER_OFFSET pixels of gap from the edges.
function M.get_corner_pos(c, win, mon)
    local w, h = win.size.x, win.size.y
    local mw, mh = mon.width, mon.height
    if c == "ul" then
        return { x = M.CORNER_OFFSET, y = M.CORNER_OFFSET }
    elseif c == "ur" then
        return { x = mw - w - M.CORNER_OFFSET, y = M.CORNER_OFFSET }
    elseif c == "br" then
        return { x = mw - w - M.CORNER_OFFSET, y = mh - h - M.CORNER_OFFSET }
    else
        return { x = M.CORNER_OFFSET, y = mh - h - M.CORNER_OFFSET }
    end
end

function M.get_center_pos(win)
    local x, y = win.at.x, win.at.y
    local w, h = win.size.x, win.size.y
    return { x = x + w / 2, y = y + h / 2 }
end

-- M.get_next_size: given a window's current pixel size and a direction
-- (1 = grow, -1 = shrink), returns the next proportion from M.SIZES and
-- the proportion matching the window's current step (both clamped to
-- the ends of the list). Matches the current size against M.SIZES
-- within a small tolerance to find the starting index — this is only
-- used to determine which step you're near, not to derive the target
-- pixel size (that's scaled from the window's actual current size).
function M.get_next_size(current_w, current_h, dir)
    local current_prop = current_w / M.BASE_RESOLUTION.x
    local idx = 2
    for i, p in ipairs(M.SIZES) do
        if math.abs(p - current_prop) < 0.05 then
            idx = i
            break
        end
    end
    local next_idx = math.max(1, math.min(#M.SIZES, idx + dir))
    return M.SIZES[next_idx], M.SIZES[idx]
end

-- ============================================================
-- BUILDER — deferred action chain
--
-- exec / boot / capture / focus / move / move_all / special / resize /
-- float / pin / notify / sleep / done / run
--
-- Each of these (except done/run) queues a zero-arg action into
-- self._actions and returns self, so calls can be chained. Nothing runs
-- until :run() (or the function returned by :done()) is called.
-- ============================================================

-- Builder:exec: queues a dispatcher-style command — a string, function,
-- or nested table of either — to run through hl.dsp.exec_cmd.
function Builder:exec(cmd, rules)
    table.insert(self._actions, make_action(cmd, dsp(hl.dsp.exec_cmd, rules)))
    return self
end

-- Builder:boot: queues a command to run via hl.exec_cmd directly
-- (no dispatch step — use this for commands that don't need hl.dispatch).
function Builder:boot(cmd)
    table.insert(self._actions, make_action(cmd, hl.exec_cmd))
    return self
end

-- Builder:capture: queues a synchronous shell command whose captured
-- stdout becomes this action's result.
function Builder:capture(cmd)
    table.insert(self._actions, function()
        return capture(cmd)
    end)
    return self
end

-- Builder:focus: queues a focus dispatch using the given rules table.
function Builder:focus(rules)
    table.insert(self._actions, make_single_action(rules, dsp(hl.dsp.focus)))
    return self
end

-- Builder:move: queues a window-move dispatch using the given rules table.
function Builder:move(rules)
    table.insert(self._actions, make_single_action(rules, dsp(hl.dsp.window.move)))
    return self
end

-- Builder:move_all: queues a move of every window currently on workspace
-- `from` to workspace `to`. The window list is computed at execution
-- time (not when the chain is built), since windows may change in the
-- meantime. `rules` (if given) overrides the default move rules per
-- window.
function Builder:move_all(from, to, rules)
    table.insert(self._actions, make_single_action(from, function(ws)
        for _, window in ipairs(M.windows(ws)) do
            local move_rules = override({ workspace = to, window = "address:" .. window.address, follow = false }, rules)
            M.new():move(move_rules):run()
        end
    end))
    return self
end

-- Builder:special: queues a toggle of the given special workspace.
function Builder:special(ws)
    table.insert(self._actions, make_single_action(ws, dsp(hl.dsp.workspace.toggle_special)))
    return self
end

-- Builder:resize: queues a window-resize dispatch using the given rules
-- table (e.g. { x = ..., y = ... }).
function Builder:resize(rules)
    table.insert(self._actions, make_single_action(rules, dsp(hl.dsp.window.resize)))
    return self
end

-- Builder:float: queues a float-toggle dispatch using the given rules
-- table.
function Builder:float(rules)
    table.insert(self._actions, make_single_action(rules, dsp(hl.dsp.window.float)))
    return self
end

-- Builder:pin: queues a pin-toggle dispatch using the given rules table.
function Builder:pin(rules)
    table.insert(self._actions, make_single_action(rules, dsp(hl.dsp.window.pin)))
    return self
end

function Builder:cursor(rules)
    table.insert(self._actions, make_single_action(rules, dsp(hl.dsp.cursor.move)))
    return self
end

-- Builder:notify: queues a `notify-send` exec with an optional
-- description. Sugar over :exec().
function Builder:notify(title, desc)
    local msg = "'" .. title .. "'"
    if desc then
        msg = msg .. " '" .. desc .. "'"
    end
    return self:exec("notify-send " .. msg)
end

-- Builder:sleep: queues a `sleep` exec for `duration` seconds. Sugar
-- over :exec().
function Builder:sleep(duration)
    return self:exec("sleep " .. (tonumber(duration) or 0.0))
end

-- Builder:done: terminator for simple chains. Collapses the queued
-- actions into one real function and returns it, since hl.bind()/hl.on()
-- require an actual `function` value, not a table with __call.
--
-- NOTE: use :done() when the chain is nothing more than a straight
-- sequence of the builder methods above (exec/boot/focus/move/etc.) run
-- in order — it's just a thin auto-wrap around :run().
-- If you need custom logic — conditionals, extra Lua code between
-- steps, calling other functions, inspecting intermediate results,
-- deferring certain calls, etc. — don't use :done(). Instead wrap the
-- chain manually, e.g.:
--     hl.bind(combo, function()
--         -- custom logic here
--         M.new():exec(...):run()
--     end)
-- and call :run() yourself at the point you actually want it to execute.
function Builder:done()
    return function()
        self:run()
    end
end

-- Builder:run: executes every queued action in order and returns the
-- last action's result.
function Builder:run()
    local result
    for _, action in ipairs(self._actions) do
        result = action()
    end
    return result
end

-- ============================================================
-- BUILDER — keybind chain
--
-- bind / append / temp / combine
--
-- Unlike the deferred methods above, these call hl.bind() directly and
-- immediately as the chain executes — they are NOT queued into
-- self._actions.
-- ============================================================

-- Builder:bind: sets the baseline mod/key/rules for this chain,
-- replacing any prior baseline and clearing any accumulated temp
-- entries. Binds immediately if a dispatcher is given (opts.dsp, or
-- positional opts[1]).
function Builder:bind(opts)
    opts = opts or {}
    self._mod = {}
    self._key = {}
    self._temp = { mod = {}, key = {} }
    merge_list(self._mod, opts.mod)
    merge_list(self._key, opts.key)
    local dsp_fn, rules = extract_dsp_rules(opts)
    self._rules = rules
    if dsp_fn then
        hl.bind(build_combo(self._mod, self._key), dsp_fn, self._rules)
    end
    return self
end

-- Builder:append: permanently merges mod/key into the baseline (and
-- rules, if given), then binds immediately using the new baseline if a
-- dispatcher is given.
function Builder:append(opts)
    opts = opts or {}
    merge_list(self._mod, opts.mod)
    merge_list(self._key, opts.key)
    local dsp_fn, rules = extract_dsp_rules(opts)
    if rules ~= nil then
        self._rules = rules
    end
    if dsp_fn then
        hl.bind(build_combo(self._mod, self._key), dsp_fn, self._rules)
    end
    return self
end

-- Builder:temp: stashes mod/key into the temp accumulator instead of the
-- baseline — these only apply to THIS call unless later folded in via
-- :combine(). `rules`, like in bind/append/combine, persist into the
-- baseline until overridden.
function Builder:temp(opts)
    opts = opts or {}
    merge_list(self._temp.mod, opts.mod)
    merge_list(self._temp.key, opts.key)
    local dsp_fn, rules = extract_dsp_rules(opts)
    if rules ~= nil then
        self._rules = rules
    end
    if dsp_fn then
        local mods = merge_list({ table.unpack(self._mod) }, opts.mod)
        local key = merge_list({ table.unpack(self._key) }, opts.key)
        hl.bind(build_combo(mods, key), dsp_fn, self._rules)
    end
    return self
end

-- Builder:combine: permanently merges ALL accumulated temp mod/key
-- (plus any given in opts) into the baseline, clears the temp
-- accumulator, then binds immediately using the new baseline if a
-- dispatcher is given.
function Builder:combine(opts)
    opts = opts or {}
    merge_list(self._mod, self._temp.mod)
    merge_list(self._key, self._temp.key)
    merge_list(self._mod, opts.mod)
    merge_list(self._key, opts.key)
    self._temp = { mod = {}, key = {} }
    local dsp_fn, rules = extract_dsp_rules(opts)
    if rules ~= nil then
        self._rules = rules
    end
    if dsp_fn then
        hl.bind(build_combo(self._mod, self._key), dsp_fn, self._rules)
    end
    return self
end

-- ============================================================
-- ENTRY POINT
-- ============================================================

-- M.new: starts a new Builder chain.
function M.new()
    return setmetatable({
        _actions = {},
        _mod = {},
        _key = {},
        _rules = nil,
        _temp = { mod = {}, key = {} },
    }, Builder)
end

return M
