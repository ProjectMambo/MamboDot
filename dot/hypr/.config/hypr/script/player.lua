local f = require("script.helper")
local M = {}

function M.run(playercmd)
    return function()
        local player = f.new()
            :exec(playercmd)
            :sleep(0.1)
            :capture("playerctl -l | head -n 1")
            :run()
        if player ~= "" then
            local title = f.new()
                :capture(string.format("playerctl -p '%s' metadata --format '{{uc(playerName)}}: {{lc(status)}}'", player))
                :run()
            local desc = f.new()
                :capture(string.format(
                    "playerctl -p '%s' metadata --format '[{{duration(position)}}/{{duration(mpris:length)}}] Vol: {{trunc(volume*100,5)}}\n{{title}}\n- {{artist}}'",
                    player))
                :run()
            f.new():notify(title, desc):run()
        else
            f.new():notify("No players found"):run()
        end
    end
end

return M
