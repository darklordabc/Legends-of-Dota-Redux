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
end, nil)
