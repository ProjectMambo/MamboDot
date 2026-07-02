-- =============================================================================
-- VARIABLES
-- =============================================================================
local home = os.getenv("HOME")
local M = {}

-- Set Environment Variables
hl.env("XDG_DATA_HOME", home .. "/.local/share")
hl.env("XDG_DATA_DIRS", "/usr/local/share:/usr/share:" .. home .. "/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share")
hl.env("XDG_CACHE_HOME", home .. "/.cache")
hl.env("XDG_MENU_PREFIX", "arch-")

-- Define Paths
local projectDir = home .. "/ProjectMambo/MamboDot"
M.hyprDir = projectDir .. "/dot/hypr/.config/hypr"
M.scriptDir = projectDir .. "/script/hypr"
M.themesDir = M.hyprDir .. "/themes"

-- Define Apps
M.terminal = "kitty"
M.browser = "zen-browser"
M.fileManager = "dolphin"
M.notesEditor = "obsidian"
M.codeEditor = "code"

-- Define Misc
M.scratchpadName = "minimized"
M.theme = require("themes.mamboheritage")

-- Define Scripts
M.wsScript = M.scriptDir .. "/hypr-workspace.lua"

return M