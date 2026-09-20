-- =============================================================================
-- VARIABLES
-- =============================================================================
local home = os.getenv("HOME")
local M = {}

local path_parts = {}
local seen_paths = {}
for path in (table.concat({
    home .. "/.local/bin",
    home .. "/.npm-global/bin",
    home .. "/.cargo/bin",
    home .. "/.local/share/JetBrains/Toolbox/scripts",
    os.getenv("PATH") or "",
}, ":")):gmatch("[^:]+") do
    if not seen_paths[path] then
        table.insert(path_parts, path)
        seen_paths[path] = true
    end
end

-- Helper to recursively load themes
local function load_themes(t)
    for k, v in pairs(t) do
        if type(v) == "table" then
            load_themes(v)
        else
            t[k] = require(v)
        end
    end
    return t
end

-- Environment Variables
M.env = {
    -- XDG Base Directories
    XDG_DATA_HOME               = home .. "/.local/share",
    XDG_DATA_DIRS               = "/usr/local/share:/usr/share:" ..
        home .. "/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share",
    XDG_CACHE_HOME              = home .. "/.cache",
    XDG_MENU_PREFIX             = "arch-",
    PATH                        = table.concat(path_parts, ":"),

    -- KDE/Qt Integration (Fixes theme/contrast issues)
    QT_QPA_PLATFORMTHEME        = "kde",
    QT_STYLE_OVERRIDE           = "Breeze",
    QT_AUTO_SCREEN_SCALE_FACTOR = "1",
    GTK_THEME                   = "Breeze-Dark",
}
for k, v in pairs(M.env) do
    hl.env(k, v)
end

-- Paths
local projectDir = home .. "/ProjectMambo/MamboDot"
M.paths = {
    hypr   = projectDir .. "/dot/hypr/.config/hypr",
    script = projectDir .. "/script/hypr",
    themes = projectDir .. "/dot/hypr/.config/hypr/themes"
}

-- Apps
M.apps = {
    terminal    = "kitty",
    browser     = "zen-browser",
    fileManager = "dolphin",
    notepad     = "featherpad",
    calculator  = "qalculate-qt"
}

-- Misc
M.scratchpadName = "minimized"

-- Themes (Grouped & Loaded)
M.theme = load_themes({
    ui = {
        lgt = "themes.mamboorchelight",
        drk = "themes.mamboorchedark",
    },
    color = {
        lgt = "themes.mambooutbacklight",
        drk = "themes.mambooutbackdark",
    }
})

return M
