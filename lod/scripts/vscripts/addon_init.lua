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

-- Precache everything -- Having issues with the arguments changing
print('Precaching stuff...')
if not pcall(function()
    PrecacheUnitByName('npc_precache_everything')
end) then
    if not pcall(function()
        PrecacheUnitByName('npc_precache_everything', {})
    end) then
        print('PRE CACHING HAS FAILED! I AM A SAD PANDA!')
    end
end
--PrecacheResource('test', 'test')
print('Done precaching!')

-- Tell the user it has loaded
print('Legends of Dota has finished loading!\n\n')
