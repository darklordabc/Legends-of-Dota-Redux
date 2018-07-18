--[[
    Simple timer library by Ash47
]]

-- This will be exported as Timers
EasyTimers = {}

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
function EasyTimers:CreateTimer(...)
    -- Grab the gamemode entity
    local gm = GameRules:GetGameModeEntity()

    -- Ensure it exists
    if not gm then
        print('WARNING: Timer created too soon!')
        return
    end

    -- Run the timer
    gm:SetThink(...)
end

-- Export functions
return EasyTimers
