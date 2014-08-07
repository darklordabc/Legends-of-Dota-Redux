-- Ensure lod exists
if _G.lod == nil then
    _G.lod = class({})
end

-- Load modules
require('skillmanager')
require('easytimers')
require('lod')

if lod == nil then
	print('LOD FAILED TO INIT!')
	return
end

function Precache( context )

	print('PRECACHING CALLED!')

	-- Precache all :: crazy!
	lod:precacheAll(context)

	--[[PrecacheResource('particle', 'particles/creature_splitter.pcf', context)
	PrecacheResource('particle', 'particles/frostivus_gameplay.pcf', context)
	PrecacheResource('particle', 'particles/frostivus_herofx.pcf', context)
	PrecacheResource('particle', 'particles/generic_aoe_persistent_circle_1.pcf', context)
	PrecacheResource('particle', 'particles/holdout_lina.pcf', context)
	PrecacheResource('particle', 'particles/test_particle.pcf', context)
	PrecacheResource('particle', 'particles/nian_gameplay.pcf', context)
	PrecacheResource('particle', 'particles/nian_gameplay_b.pcf', context)
	PrecacheResource('particle', 'particles/nian_temp.pcf', context)]]

	-- Precache models we might need
	PrecacheResource('model', 'models/heroes/juggernaut/jugg_healing_ward.vmdl', context)
	PrecacheResource('model', 'models/heroes/tiny_01/tiny_01.vmdl', context)
	PrecacheResource('model', 'models/heroes/tiny_02/tiny_02.vmdl', context)
	PrecacheResource('model', 'models/heroes/tiny_03/tiny_03.vmdl', context)
	PrecacheResource('model', 'models/heroes/tiny_04/tiny_04.vmdl', context)
	PrecacheResource('model', 'models/heroes/tiny_01/tiny_01_tree.vmdl', context)
	PrecacheResource('model', 'models/props_gameplay/frog.vmdl', context)
	PrecacheResource('model', 'models/props_gameplay/chicken.vmdl', context)
	PrecacheResource('model', 'models/heroes/shadowshaman/shadowshaman_totem.vmdl', context)
	PrecacheResource('model', 'models/heroes/witchdoctor/witchdoctor_ward.vmdl', context)
	PrecacheResource('model', 'models/heroes/enigma/eidelon.vmdl', context)
	PrecacheResource('model', 'models/heroes/enigma/eidelon.vmdl', context)
	PrecacheResource('model', 'models/heroes/beastmaster/beastmaster_bird.vmdl', context)
	PrecacheResource('model', 'models/heroes/beastmaster/beastmaster_beast.vmdl', context)
	PrecacheResource('model', 'models/heroes/venomancer/venomancer_ward.vmdl', context)
	PrecacheResource('model', 'models/heroes/death_prophet/death_prophet_ghost.vmdl', context)
	PrecacheResource('model', 'models/heroes/pugna/pugna_ward.vmdl', context)
	PrecacheResource('model', 'models/heroes/witchdoctor/witchdoctor_ward.vmdl', context)
	PrecacheResource('model', 'models/heroes/dragon_knight/dragon_knight_dragon.vmdl', context)
	PrecacheResource('model', 'models/heroes/rattletrap/rattletrap_cog.vmdl', context)
	PrecacheResource('model', 'models/heroes/furion/treant.vmdl', context)
	PrecacheResource('model', 'models/heroes/nightstalker/nightstalker_night.vmdl', context)
	PrecacheResource('model', 'models/heroes/nightstalker/nightstalker.vmdl', context)
	PrecacheResource('model', 'models/heroes/broodmother/spiderling.vmdl', context)
	PrecacheResource('model', 'models/heroes/weaver/weaver_bug.vmdl', context)
	PrecacheResource('model', 'models/heroes/gyro/gyro_missile.vmdl', context)
	PrecacheResource('model', 'models/heroes/invoker/forge_spirit.vmdl', context)
	PrecacheResource('model', 'models/heroes/lycan/lycan_wolf.vmdl', context)
	PrecacheResource('model', 'models/heroes/lone_druid/true_form.vmdl', context)
	PrecacheResource('model', 'models/heroes/undying/undying_flesh_golem.vmdl', context)
	PrecacheResource('model', 'models/development/invisiblebox.vmdl', context)
	PrecacheResource('model', 'models/heroes/terrorblade/demon.vmdl', context)



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
