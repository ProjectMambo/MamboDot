-- =============================================================================
-- EXECUTION
-- =============================================================================
local f = require("script.helper")

hl.on("hyprland.start",
    f.new()
    :boot({
        "dbus-update-activation-environment --systemd XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE WAYLAND_DISPLAY XDG_DATA_HOME XDG_DATA_DIRS XDG_CACHE_HOME XDG_MENU_PREFIX QT_QPA_PLATFORMTHEME QT_STYLE_OVERRIDE QT_AUTO_SCREEN_SCALE_FACTOR GTK_THEME",
        "systemctl --user start plasma-kglobalaccel.service",
    })
    :exec({
        "playerctld daemon",
        "hyprlock", "astal-notifd daemon", "env GDK_BACKEND=wayland ags run",
        "hyprpaper", "hypridle", "avizo-service",
        "systemctl --user start hyprpolkitagent.service",
        "wl-paste --type text --watch cliphist store",
        "wl-paste --type image --watch cliphist store",
        "kbuildsycoca6 --noincremental",
    })
    :done()
)
