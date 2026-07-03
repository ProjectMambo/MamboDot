-- =============================================================================
-- EXECUTION
-- =============================================================================
hl.on("hyprland.start", function()
    hl.exec_cmd(
        "dbus-update-activation-environment --systemd XDG_DATA_HOME XDG_DATA_DIRS XDG_CACHE_HOME XDG_CONFIG_HOME")
    hl.exec_cmd("systemctl --user import-environment XDG_DATA_HOME XDG_DATA_DIRS XDG_CACHE_HOME XDG_CONFIG_HOME")
    hl.exec_cmd("systemctl --user start plasma-kglobalaccel.serviceyX")
    hl.exec_cmd("kbuildsycoca6 --noincremental")
    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprlock")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("avizo-service")
    hl.exec_cmd("mako")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)
