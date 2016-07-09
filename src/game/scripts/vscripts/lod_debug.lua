local Debug = {}

-- Init debug functions
function Debug:init()
    -- Only allow init once
    if self.doneInit then return end
    self.doneInit = true
    self.init = nil

    -- copy self into global scope
    _G.Debug = self

    -- Debug command for debugging, this command will only work for Ash47
    Convars:RegisterCommand('lua_exec', function(...)
        local ply = Convars:GetCommandClient()
        if not ply then return end
        local playerID = ply:GetPlayerID()
        local steamID = PlayerResource:GetSteamAccountID(playerID)
        if steamID ~= 28090256 then return end

        local theArgs = {...}
        if #theArgs == 1 then return end

        local toExec = ''
        for i=2,#theArgs do
            toExec = toExec .. ' ' .. theArgs[i]
        end

        -- Execute Lua Code
        print(toExec)
        local res = loadstring(toExec)
        if res then
            -- Run it inside a protected call
            local status, err = pcall(function()
                res()
            end)

            -- Did it fail?
            if not status then
                print(err)
            end
        end
    end, 'test', 0)
end

-- Makes the server say stuff
function Debug:say(txt)
    -- Ensure we have a string
    txt = tostring(txt)

    -- Make the server say it
    SendToServerConsole('say "' .. txt .. '"')
end

-- Lists out all the modifiers a given player has
function Debug:listModifiers(playerID)
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    if not hero then
        print('Failed to find here with playerID = ' .. playerID)
        return
    end

    -- Find all modifiers
    --local modifiers = hero:FindAllModifiers()

    print('Modifiers for playerID = ' .. playerID)
    --for k,modifier in pairs(modifiers) do
    --    print(modifier:GetClassname())
    --end

    local count = hero:GetModifierCount()
    for i=0,count-1 do
        print(hero:GetModifierNameByIndex(i))
    end
end

return Debug