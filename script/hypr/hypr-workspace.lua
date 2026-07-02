#!/usr/bin/env lua5.4
-- Hyprland workspace action script (Lua port of the bash version)
-- Usage: hypr-workspace.lua <action> <target>
--
-- NOTE: this process is a separate Lua interpreter from Hyprland's own
-- embedded one. It has no access to the `hl` API directly -- it can only
-- ask the compositor to evaluate Lua expressions via `hyprctl dispatch
-- '<expr>'` (shorthand for `hyprctl eval 'hl.dispatch(<expr>)'`).
-- `hl.dsp.exec_raw("<legacy dispatch string>")` was tried as a compat shim
-- for old-style "dispatch NAME ARGS" strings but returned "ok" without
-- actually doing anything on this build -- so this version calls the
-- proper `hl.dsp.*` table-form dispatchers directly instead.

local NUM_WORKSPACE = 10
local ACTION = arg[1]
local TARGET_WORKSPACE = arg[2]
local TEMP_WORKSPACE = 99

local COLOR_GREEN = "\27[0;32m"
local COLOR_RED   = "\27[0;31m"
local COLOR_BLUE  = "\27[0;34m"
local COLOR_NC    = "\27[0m"

-- Run a shell command and capture its stdout
local function run(cmd)
  local handle = io.popen(cmd)
  local result = handle:read("*a")
  handle:close()
  return result
end

-- Run a command purely for its side effect (dispatch calls)
local function exec(cmd)
  os.execute(cmd)
end

-- Ask the compositor to evaluate a Lua dispatcher expression, e.g.
-- dispatch('hl.dsp.focus({ workspace = 3 })')
local function dispatch(lua_expr)
  exec(string.format("hyprctl dispatch '%s'", lua_expr))
end

local function get_active_workspace()
  local out = run("hyprctl activeworkspace -j")
  local id = out:match('"id"%s*:%s*(%-?%d+)')
  return tonumber(id)
end

-- Wrap workspace id for l(eft)/r(ight) targets, otherwise pass through
local function get_wrapped_workspace(current, target)
  if target == "l" then
    if current == 1 then
      return tostring(NUM_WORKSPACE)
    else
      return tostring(current - 1)
    end
  elseif target == "r" then
    if current == NUM_WORKSPACE then
      return "1"
    else
      return tostring(current + 1)
    end
  else
    return target
  end
end

-- Move all clients from source workspace to target workspace, then
-- refocus back to `keep_focus_on` so the visible workspace never changes
-- (this replaces the old "silent" flag we couldn't verify still exists).
local function move_workspace_content(source, target, keep_focus_on)
  local cmd = string.format(
    "hyprctl clients -j | jq -r '.[] | select(.workspace.id == %s) | .address'",
    source
  )
  local out = run(cmd)
  for addr in out:gmatch("[^\r\n]+") do
    dispatch(string.format(
      'hl.dsp.window.move({ workspace = %s, window = "address:%s" })',
      target, addr
    ))
  end
  if keep_focus_on then
    dispatch(string.format('hl.dsp.focus({ workspace = %s })', keep_focus_on))
  end
end

if not ACTION then
  io.stderr:write(COLOR_RED .. "[!] Error: No action specified" .. COLOR_NC .. "\n")
  os.exit(1)
end

local CURRENT_WORKSPACE = get_active_workspace()

print(COLOR_BLUE .. "------------------------------------------" .. COLOR_NC)
print(" Action: [" .. COLOR_GREEN .. ACTION:upper() .. COLOR_NC .. "]")
print(" Target: " .. tostring(TARGET_WORKSPACE))
print(COLOR_BLUE .. "------------------------------------------" .. COLOR_NC)

if ACTION == "workspace" then
  local dest = get_wrapped_workspace(CURRENT_WORKSPACE, TARGET_WORKSPACE)
  dispatch(string.format('hl.dsp.focus({ workspace = %s })', dest))

elseif ACTION == "movetoworkspace" then
  local dest = get_wrapped_workspace(CURRENT_WORKSPACE, TARGET_WORKSPACE)
  dispatch(string.format('hl.dsp.window.move({ workspace = %s })', dest))

elseif ACTION == "movetoworkspacesilent" then
  local dest = get_wrapped_workspace(CURRENT_WORKSPACE, TARGET_WORKSPACE)
  dispatch(string.format('hl.dsp.window.move({ workspace = %s })', dest))
  dispatch(string.format('hl.dsp.focus({ workspace = %s })', CURRENT_WORKSPACE))

elseif ACTION == "togglespecialworkspace" then
  dispatch(string.format('hl.dsp.workspace.toggle_special("%s")', TARGET_WORKSPACE))

elseif ACTION == "interchange" then
  local dest = get_wrapped_workspace(CURRENT_WORKSPACE, TARGET_WORKSPACE)
  print(COLOR_BLUE .. "[*] Swapping contents: " .. COLOR_NC .. CURRENT_WORKSPACE .. " <-> " .. dest)
  move_workspace_content(CURRENT_WORKSPACE, TEMP_WORKSPACE, CURRENT_WORKSPACE)
  move_workspace_content(dest, CURRENT_WORKSPACE, CURRENT_WORKSPACE)
  move_workspace_content(TEMP_WORKSPACE, dest, CURRENT_WORKSPACE)

else
  io.stderr:write(COLOR_RED .. "[!] Error: Invalid workspace action" .. COLOR_NC .. "\n")
  os.exit(1)
end