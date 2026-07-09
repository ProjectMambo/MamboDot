-- =============================================================================
-- EXECUTION
-- =============================================================================
local f = require("script.helper")

hl.on("hyprland.start",
    f.new()
    :boot({
        "dbus-update-activation-environment --systemd XDG_DATA_HOME XDG_DATA_DIRS XDG_CACHE_HOME XDG_CONFIG_HOME WAYLAND_DISPLAY XDG_CURRENT_DESKTOP",
        "systemctl --user import-environment XDG_DATA_HOME XDG_DATA_DIRS XDG_CACHE_HOME XDG_CONFIG_HOME WAYLAND_DISPLAY XDG_CURRENT_DESKTOP",
        "systemctl --user start plasma-kglobalaccel.service",
        "systemctl --user start hyprland-session.target",
    })
    :exec({
        "playerctld daemon",
        "kbuildsycoca6 --noincremental",
        "hyprlock", "waybar", "hyprpaper", "hypridle", "avizo-service", "mako",
        "/usr/lib/hyprpolkitagent/hyprpolkitagent",
        "wl-paste --type text --watch cliphist store",
        "wl-paste --type image --watch cliphist store"
    })
    :done()
)
