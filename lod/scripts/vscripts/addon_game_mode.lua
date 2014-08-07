-- Load modules
require('skillmanager')
require('easytimers')
require('lod')

if lod == nil then
	print('LOD FAILED TO INIT!')
	return
end

function Precache( context )
	--[[PrecacheResource('particle', 'particles/creature_splitter.pcf', context)
	PrecacheResource('particle', 'particles/frostivus_gameplay.pcf', context)
	PrecacheResource('particle', 'particles/frostivus_herofx.pcf', context)
	PrecacheResource('particle', 'particles/generic_aoe_persistent_circle_1.pcf', context)
	PrecacheResource('particle', 'particles/holdout_lina.pcf', context)
	PrecacheResource('particle', 'particles/test_particle.pcf', context)
	PrecacheResource('particle', 'particles/nian_gameplay.pcf', context)
	PrecacheResource('particle', 'particles/nian_gameplay_b.pcf', context)
	PrecacheResource('particle', 'particles/nian_temp.pcf', context)]]



	--PrecacheResource('', '')

	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
end

-- Create the game mode when we activate
function Activate()
	GameRules.lod = lod()
	GameRules.lod:InitGameMode()
end
