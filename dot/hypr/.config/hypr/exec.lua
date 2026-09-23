-- =============================================================================
-- EXECUTION
-- =============================================================================
local f = require("script.helper")

hl.on("hyprland.start",
    f.new()
    :boot({
        "dbus-update-activation-environment --systemd PATH XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_DATA_HOME XDG_DATA_DIRS XDG_CACHE_HOME XDG_MENU_PREFIX QT_QPA_PLATFORMTHEME QT_STYLE_OVERRIDE QT_AUTO_SCREEN_SCALE_FACTOR GTK_THEME && systemctl --user start plasma-kglobalaccel.service hyprpolkitagent.service && systemctl --user restart mambodot-shell.target",
    })
    :exec({
        "playerctld daemon",
        "hyprlock",
        "hyprpaper", "hypridle", "avizo-service",
        "kbuildsycoca6 --noincremental",
    })
    :done()
)

hl.on("hyprland.shutdown",
    f.new():boot("systemctl --user stop mambodot-shell.target"):done()
)
