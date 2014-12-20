-- Check if they are trying to load into remote LoD mode
if GetMapName() == 'connect_to_ash47' then
    print("Connected to one of ash47's servers...")
    SendToServerConsole("connect lod.ash47.net")

    return
end

-- Ensure lod exists
if _G.lod == nil then
    _G.lod = class({})

    -- Checks if we are running in source1, or 2
    local isSource1 = Convars:GetStr('dota_local_addon_game') ~= nil

	function GameRules:isSource1()
	    return isSource1
	end
end

-- Should we load dedicated config?
if LoadKeyValues('cfg/dedicated.kv') then
    require('dedicated')
end

-- Stat collection
require('lib.statcollection')
statcollection.addStats({
	modID = '2374504c2c518fafc9731a120e67fdf5'
})

-- Init load helper
require('lib.loadhelper')

-- Load modules
require('lod')

-- Load hax
require('hax')

if lod == nil then
	print('LOD FAILED TO INIT!')
	return
end

-- Precaching
function Precache(context)
end

-- Create the game mode when we activate
function Activate()
	GameRules.lod = lod()
	GameRules.lod:InitGameMode()
end
