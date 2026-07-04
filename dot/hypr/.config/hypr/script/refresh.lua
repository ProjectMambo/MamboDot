local M = {}

function M.refresh()
    hl.dispatch(hl.dsp.exec_cmd("notify-send 'Refreshing...'"))
    hl.dispatch(hl.dsp.exec_cmd("hyprctl reload"))
    hl.dispatch(hl.dsp.exec_cmd("pkill waybar && waybar &"))
    hl.dispatch(hl.dsp.exec_cmd("update-desktop-database ~/.local/share/applications"))
    hl.dispatch(hl.dsp.exec_cmd("kbuildsycoca6 --noincremental"))
    hl.dispatch(hl.dsp.exec_cmd("source ~/.zshenv"))
end

return M
