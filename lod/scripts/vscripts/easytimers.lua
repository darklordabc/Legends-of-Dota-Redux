--[[
    Simple timer library by Ash47
]]

-- This will be exported as Timers
local timers = {}

--[[
    Timers:CreateTimer(function()
        -- Stick your function here

        return how long until the next fire, or nothing to stop firing
    end, 'some_name', delay)

    some_name needs to be unique, otherwise it will be overriden

    delay is how long to wait before firing the FIRST time

    The first argument can also be a function NAME, such as 'think',
    in this case, you will also need to pass the object to call 'think' on
]]
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
