-- Define skill warnings
--[[skillWarnings = {
    life_stealer_infest = {getSpellIcon('life_stealer_infest'), tranAbility('life_stealer_infest'), getSpellIcon('life_stealer_consume'), tranAbility('life_stealer_consume')},
    shadow_demon_demonic_purge = {getSpellIcon('shadow_demon_demonic_purge'), tranAbility('shadow_demon_demonic_purge'), transHero('shadow_demon')},
    phantom_lancer_phantom_edge = {getSpellIcon('phantom_lancer_phantom_edge'), tranAbility('phantom_lancer_phantom_edge'), getSpellIcon('phantom_lancer_juxtapose'), tranAbility('phantom_lancer_juxtapose')},
    keeper_of_the_light_spirit_form = {getSpellIcon('keeper_of_the_light_spirit_form'), tranAbility('keeper_of_the_light_spirit_form')},
    luna_eclipse = {getSpellIcon('luna_eclipse'), tranAbility('luna_eclipse'), getSpellIcon('luna_lucent_beam'), tranAbility('luna_lucent_beam')},
    puck_illusory_orb = {getSpellIcon('puck_illusory_orb'), tranAbility('puck_illusory_orb'), getSpellIcon('puck_ethereal_jaunt'), tranAbility('puck_ethereal_jaunt')},
    techies_remote_mines = {getSpellIcon('techies_remote_mines'), tranAbility('techies_remote_mines'), getSpellIcon('techies_focused_detonate'), tranAbility('techies_focused_detonate')},
    nyx_assassin_burrow = {getSpellIcon('nyx_assassin_burrow'), tranAbility('nyx_assassin_burrow'), getSpellIcon('nyx_assassin_vendetta'), tranAbility('nyx_assassin_vendetta')},
n    lone_druid_true_form = {getSpellIcon('lone_druid_true_form'), tranAbility('lone_druid_true_form')},
    phoenix_supernova = {getSpellIcon('phoenix_supernova'), tranAbility('phoenix_supernova')},
}]]

require('lib/StatUploaderFunctions')

-- Precaching
function Precache(context)
    local soundList = LoadKeyValues('scripts/kv/sounds.kv')
    -- Precache sounds
    for soundPath,_ in pairs(soundList["precache_sounds"]) do
        PrecacheResource("soundfile", soundPath, context)
    end
	-- COMMENT THE BELOW OUT IF YOU DO NOT WANT TO COMPILE ASSETS
	if IsInToolsMode() then 
		local abilities = LoadKeyValues('scripts/npc/npc_abilities_custom.txt')
		for ability, block in pairs(abilities) do
			if block == "precache" then
				for precacheType, resource in pairs(block) do
					PrecacheResource(precacheType, resource, context)
				end
			end
		end
	end
	-- COMMENT THE ABOVE OUT IF YOU DO NOT WANT TO COMPILE ASSETS
end

-- Create the game mode when we activate
function Activate()
	-- Print LoD version header
    local versionFile = LoadKeyValues('addoninfo.txt')
    local versionNumber = versionFile.version
    print('\n\nLegends of dota is activating! (v'..versionNumber..')')

    -- Ensure LoD is compiled
    local tst = LoadKeyValues('scripts/npc/npc_heroes_custom.txt')
    if tst == 0 or tst == nil then
        print('FAILURE! You are attempting to run an UNCOMPILED version! Please either compile OR download the latest release from the releases section of github.\n\n')
        return
    end

    -- Change random seed
    local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
    math.randomseed(tonumber(timeTxt))

    -- Load specific modules
    local network = require('network')
    local pregame = require('pregame')
    local ingame = require('ingame')

    -- Init other stuff
    network:init()
    pregame:init()
    ingame:init()

    -- Store references (mostly used for debugging)
    GameRules.util = require('util')
    GameRules.network = network
    GameRules.pregame = pregame
    GameRules.ingame = ingame

    print('LoD seems to have activated successfully!!\n\n')

    
end

-- Boot directly into LoD interface
--Convars:SetInt('dota_wait_for_players_to_load', 0)
