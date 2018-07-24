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

-- Precache obstacles
require('obstacles')

-- Misc functions
require('util')

-- Option storage
require('optionmanager')

-- Networking functions
require('network')

-- Chat commands
require('commands')

--Interaction with server (https://github.com/darklordabc/Legends-of-Dota-Server)
require('stats_client')

-- Custom Shop
require('lib/playertables')
require('lib/notifications')
require('lib/keyvalues')
-- require('panorama_shop')

-- Misc functions for Angel Arena Black Star abilities/items
require('lib/util_aabs')

-- IMBA
require('lib/util_imba')
require('lib/util_imba_funcs')
require('lib/animations')

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
        for ability,content in pairs(abilities) do
            if type(content) == "table" then
                for block,val in pairs(content) do
                  if block == "precache" then
                    for precacheType, resource in pairs(val) do
                        PrecacheResource(precacheType, resource, context)
                    end
                  end
                end
            end
        end
    end
    -- COMMENT THE ABOVE OUT IF YOU DO NOT WANT TO COMPILE ASSETS
    PrecacheResource("particle","particles/econ/events/battlecup/battle_cup_fall_destroy_flash.vpcf",context)
    PrecacheResource("particle","particles/world_tower/tower_upgrade/ti7_radiant_tower_proj.vpcf",context)
    PrecacheResource("particle","particles/world_tower/tower_upgrade/ti7_dire_tower_projectile.vpcf",context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_monkey_king.vsndevts",context)
    PrecacheResource("soundfile","soundevents/memes_redux_sounds.vsndevts",context)
    PrecacheUnitByNameSync("npc_dota_lucifers_claw_doomling", context)
    PrecacheUnitByNameSync("npc_bot_spirit_sven", context)

    precacheObstacles(context)
end

-- Create the game mode when we activate
function Activate()
    -- Print LoD version header
    local versionFile = LoadKeyValues('addoninfo.txt')
    local versionNumber = versionFile.version
    print('\n\nDota 2 Redux is activating! (v'..versionNumber..')')

    -- Ensure LoD is compiled
    local tst = LoadKeyValues('scripts/npc/npc_heroes_custom.txt')
    if tst == 0 or tst == nil then
        print('FAILURE! You are attempting to run an UNCOMPILED version! Please either compile OR download the latest release from the releases section of github.\n\n')
        return
    end

    

    -- print("888888")
    -- local shit = LoadKeyValues('scripts/npc/abilities/imba/imba_abilities.kv')
    -- local shit2 = {}
    -- local i = 1
    -- for k,v in pairs(shit) do
    --     if v.ScriptFile and string.match(k, "imba") and not string.match(k, "special_bonus") and not string.match(k, "imba_tower_") and not string.match(k, "ancient") and not string.match(k, "behemoth") and not string.match(k, "fountain") and not string.match(k, "imba_mega") and not string.match(k, "imba_super") and not string.match(k, "imba_roshan") then
    --         local newKey = string.gsub(v.ScriptFile, "abilities/dota_imba/", "")
    --         newKey = string.gsub(newKey, ".lua", "")
    --         shit2[newKey] = shit2[newKey] or {}
    --         table.insert(shit2[newKey], "\""..k.."\"".."  ".."\"1\"")
    --         -- print(i)
    --         i = i + 1
    --     end
    -- end

    -- for k,v in pairs(shit2) do
    --     print("\""..k.."\"")
    --     print("{")
    --     for k1,v1 in pairs(v) do
    --         print("    "..v1)
    --     end
    --     print("}")
    -- end
    -- print("888888")

    -- Load specific modules

    local pregame = require('pregame')
    local ingame = require('ingame')

    -- Init other stuff
    network:init()
    pregame:init()
    ingame:init()
    StatsClient:SubscribeToClientEvents()

    -- Store references (mostly used for debugging)
    GameRules.util = require('util')
    GameRules.pregame = pregame
    GameRules.ingame = ingame

    print('LoD seems to have activated successfully!!\n\n')

    -- PlayerResource:SetCustomTeamAssignment(0, DOTA_TEAM_BADGUYS)
    -- PlayerResource:SetCustomTeamAssignment(1, DOTA_TEAM_GOODGUYS)
    -- GameRules:LockCustomGameSetupTeamAssignment(true)
end

-- Boot directly into LoD interface
--Convars:SetInt('dota_wait_for_players_to_load', 0)
