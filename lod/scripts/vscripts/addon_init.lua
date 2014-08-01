-- Tell the user it is loading
print('\n\nLegends of Dota modules are loading...')

-- Load modules
require('skillmanager')
require('easytimers')

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
print('Done precaching!')

-- Tell the user it has loaded
print('Legends of Dota modules have finished loading!\n\n')
