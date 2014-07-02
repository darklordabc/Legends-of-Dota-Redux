--[[
    Simple timer library by Ash47
]]

-- This will be exported as Timers
local timers = {}

function timers:CreateTimer(...)
    if not dota_base_game_mode then
        print('WARNING: Timer created too soon!')
        return
    end

    local ent = dota_base_game_mode.thisEntity

    -- Run the timer
    ent:SetThink(...)
end

-- Export functions
Timers = timers
