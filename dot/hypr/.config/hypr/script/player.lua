local M = {}

function M.run(playercmd)
    return function()
        local script = string.format([[
            %s
            sleep 0.1
            PLAYER=$(playerctl -l | head -n 1)
            if [ -n "$PLAYER" ]; then
                TITLE=$(playerctl -p "$PLAYER" metadata --format '{{uc(playerName)}}: {{lc(status)}}')
                DESC=$(playerctl -p "$PLAYER" metadata --format '[{{duration(position)}}/{{duration(mpris:length)}}] Vol: {{trunc(volume*100,5)}}\n{{title}}\n- {{artist}}')

                notify-send "$TITLE" "$DESC"
            else
                notify-send "Active Player" "No players found"
            fi
        ]], playercmd)
        hl.dispatch(hl.dsp.exec_cmd(script))
    end
end

return M
