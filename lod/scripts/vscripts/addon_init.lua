-- Tell the user it is loading
print('\n\nLegends of Dota is loading...')

-- Load modules
require('skillmanager')
require('easytimers')

local doneFake = false
Convars:RegisterCommand('fake', function(name, skillName, slotNumber)
    -- Check if the server ran it
    if not Convars:GetCommandClient() then
        -- Stop fake from being run more than once
        if doneFake then return end
        doneFake = true

        -- Create fake Players
        SendToServerConsole('dota_create_fake_clients')

        -- Spawn heroes for the fake players
        Timers:CreateTimer(function()
            -- Loop over all players
            for i=0, 9 do
                -- Only affect fake clients
                if PlayerResource:IsFakeClient(i) then
                    -- Grab player instance
                    local ply = PlayerResource:GetPlayer(i)

                    -- Make sure we actually found a player instance
                    if ply then
                        CreateHeroForPlayer('npc_dota_hero_viper', ply)
                    end
                end
            end
        end, 'assign_fakes', 0.1)
    end
end, 'Adds fake players', 0)

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
