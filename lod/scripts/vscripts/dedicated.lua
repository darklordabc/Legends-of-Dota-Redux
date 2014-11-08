-- Stick people onto teams
local radiant = true
ListenToGameEvent('player_connect_full', function(keys)
    -- Grab the entity index of this player
    local entIndex = keys.index+1
    local ply = EntIndexToHScript(entIndex)

    for i=0,9 do
        PlayerResource:SetPlayerReservedState(i, false)
    end

    -- Wait, then attempt to put them onto a team
    GameRules:GetGameModeEntity():SetThink(function()
        -- Validate player
        if ply then
            -- Make sure they aren't already on a team
            if ply:GetTeam() == 0 then
                -- Set their team
                if radiant then
                    radiant = false
                    ply:SetTeam(DOTA_TEAM_GOODGUYS)
                else
                    radiant = true
                    ply:SetTeam(DOTA_TEAM_BADGUYS)
                end
            end
        end
    end, 'autoallocate', 1, nil)
end, nil)

ListenToGameEvent('player_disconnect', function(keys)
    for i=0,9 do
        PlayerResource:SetPlayerReservedState(i, false)
    end

    -- Kill server if no one is on it anymore
    GameRules:GetGameModeEntity():SetThink(function()
        -- Search for players
        local foundSomeone = false
        for i=0,9 do
            if PlayerResource:GetConnectionState(i) == 2 then
                foundSomeone = true
                break
            end
        end

        -- If we failed to find someone
        if not foundSomeone then
            -- Kill the server
            SendToServerConsole('quit')
        end
    end, 'killServer', 1, nil)
end, nil)

-- Auto add bots on the dedi server
if GameRules:isSource1() then
    local addedBots = false
    ListenToGameEvent('game_rules_state_change', function(keys)
        local state = GameRules:State_Get()

        if not addedBots and state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
            addedBots = true
            SendToServerConsole('sm_gamemode 1')
            SendToServerConsole('dota_bot_populate')
        end
    end, nil)
end
