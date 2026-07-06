local M = {}

function M.refresh()
    hl.dispatch(hl.dsp.exec_cmd("notify-send 'Refreshing...'"))
    hl.dispatch(hl.dsp.exec_cmd("pkill waybar|mako|avizo-service|hyprpaper"))
    hl.dispatch(hl.dsp.exec_cmd("waybar &"))
    hl.dispatch(hl.dsp.exec_cmd("mako &"))
    hl.dispatch(hl.dsp.exec_cmd("avizo-service &"))
    hl.dispatch(hl.dsp.exec_cmd("hyprpaper &"))
    hl.dispatch(hl.dsp.exec_cmd("update-desktop-database ~/.local/share/applications"))
    hl.dispatch(hl.dsp.exec_cmd("kbuildsycoca6 --noincremental"))
    hl.dispatch(hl.dsp.exec_cmd("source ~/.zshenv"))
    hl.dispatch(hl.dsp.exec_cmd("hyprctl reload"))
end

return M
