-- Tell the user it is loading
print('\n\nLegends of Dota is loading...')

Convars:RegisterCommand('fake', function(name, skillName, slotNumber)
    -- Check if the server ran it
    --if not Convars:GetCommandClient() then
        -- Create fake Players
        SendToServerConsole('dota_create_fake_clients')
    --end
end, 'Adds fake players', 0)

-- Stick people onto teams
ListenToGameEvent('player_connect_full', function(keys)
    -- Grab the entity index of this player
    local entIndex = keys.index+1
    local ply = EntIndexToHScript(entIndex)

    -- Set their team
    ply:SetTeam(DOTA_TEAM_GOODGUYS)
    --ply:SetTeam(DOTA_TEAM_BADGUYS)
end, nil)

-- Tell the user it has loaded
print('Legends of Dota has finished loading!\n\n')
