-- Tell the user it is loading
print('\n\nLegends of Dota is loading...')

Convars:RegisterCommand('fake', function(name, skillName, slotNumber)
    -- Check if the server ran it
    --if not Convars:GetCommandClient() then
        -- Create fake Players
        SendToServerConsole('dota_create_fake_clients')
    --end
end, 'Adds fake players', 0)

-- Load modules
require('skillmanager')

-- Tell the user it has loaded
print('Legends of Dota has finished loading!\n\n')
