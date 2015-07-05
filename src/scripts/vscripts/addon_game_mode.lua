-- Debug info for noobs
print('\n\nBeginning to run legends of dota script....')

-- Ensure LoD is compiled
local tst = LoadKeyValues('scripts/npc/npc_heroes_custom.txt')
if tst == 0 or tst == nil then
    print('FAILURE! You are attempting to run an UNCOMPILED version! Please either compile OR download the latest release from the releases section of github.\n\n')
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

-- Stat collection
local statCollection = require('lib.statcollection')

-- Stat collection
--[[require('lib.statcollection')
statcollection.addStats({
	modID = '2374504c2c518fafc9731a120e67fdf5'
})

-- Store source1 info
statcollection.addFlags({
    source1 = GameRules:isSource1()
})

-- Load GDS options module
require('lib.optionsmodule')

-- Should we load dedicated config?
local loadGDSOptions = true
local tst = LoadKeyValues('cfg/dedicated.kv')
if tst ~= 0 and tst ~= nil then
    -- Load dedicated stuff
    require('dedicated')(tst)

    loadGDSOptions = false
else
    if IsDedicatedServer() then
        print('WARNING: You are running a dedicated server but have the team allocation code turned OFF, this can cause MAJOR issues! See: dedicated.kv on the repo for more info.')
    end
end

-- Init load helper
require('lib.loadhelper')

]]

-- Init utilities
local util = require('util')

-- Load hax
--require('hax')

-- Load survival
--require('survival')

-- Load specific modules
local Constants = require('constants')
local SkillManager = require('skillmanager')
local OptionManager = require('optionmanager')
local SpellFixes = require('spellfixes')
local Timers = require('easytimers')

--[[
    FUNCTION DEFINITIONS
]]
local stub = function()end

setupGamemodeSettings = stub
slotTypeString = stub
isUlt = stub
isPassive = stub
isPlayerOnValidTeam = stub
isValidSkill = stub
isValidHeroName = stub
getMulticastDelay = stub
getSkillID = stub
isValidSlot = stub
isSkillBanned = stub
GetSkillOwningHero = stub
banSkill = stub
buildDraftString = stub
addHeroDraft = stub
getPlayerSlot = stub
sendChatMessage = stub
sendDireMessage = stub
sendRadiantMessage = stub
sendTeamMessage = stub
alreadyHas = stub
CheckBans = stub
setupSlotType = stub
setupSlotTypes = stub
validateBuild = stub
fixBuilds = stub
postGamemodeSettings = stub
getOptionsString = stub
shuffle = stub
optionToValue = stub
valueToOption = stub
finishVote = stub
backdoorFix = stub
upgradeTowers = stub
botSkillsOnly = stub
doLock = stub
getRandomHeroName = stub
getSpellIcon = stub
loadSpecialGamemode = stub
buildAllowedTabsString = stub
fireLockChange = stub
setTowerOwnership = stub
addExtraTowers = stub
applyTowerSkills = stub
applyBuildingSkills = stub
prepareCreepSkills = stub
applyCreepSkills = stub
levelSpiritSkills = stub
tranAbility = stub
transHero = stub
printOptionsToPlayer = stub
registerConsoleCommands = stub
registerServerCommands = stub
registerHeroBanning = stub
registerFancyConsoleCommands = stub
handleFreeCourier = stub
handleFreeScepter = stub
handleHeroBuffing = stub
getHealthBuffer = stub

--[[
    Constants mostly
]]

-- Unique skills constants
local UNIQUE_SKILLS_NONE = 0
local UNIQUE_SKILLS_TEAM = 1
local UNIQUE_SKILLS_GLOBAL = 2

-- List of tabs to allow
local allowedTabs = {
    main = true,
    neutral = true,
    wraith = true,
    itemsActive = true,
    itemsPassive = true
}

-- String version of allowed tabs
local allowedTabsString = ''

-- Free courier
local FREE_COURIER_NONE = 0
local FREE_COURIER_WALKING = 1
local FREE_COURIER_FLYING = 2

--[[
    GAMEMODE STUFF
]]

-- Balance constants
local BALANCE_NONE = 0
local BALANCE_BASIC = 1
local BALANCE_EXTENDED = 2

-- Stage constants
local STAGE_WAITING = 0
local STAGE_VOTING = 1
local STAGE_BANNING = 2
local STAGE_HERO_BANNING = 3
local STAGE_PICKING = 4
local STAGE_PLAYING = 10

-- Gamemode constants
local GAMEMODE_AP = 1   -- All Pick
local GAMEMODE_SD = 2   -- Single Draft
local GAMEMODE_MD = 3   -- Mirror Draft
local GAMEMODE_AR = 4   -- All Random

-- Skill list constants
local SKILL_LIST_YOUR = 1
local SKILL_LIST_BEAR = 2
local SKILL_LIST_TOWER = 3
local SKILL_LIST_BUILDING = 4
local SKILL_LIST_CREEP = 5

-- Valid interfaces
local validInterfaces = {
    [SKILL_LIST_YOUR] = true,
    [SKILL_LIST_BEAR] = true,
}

-- The current stage we are in
local currentStage = STAGE_WAITING

-- Has LoD started?
local lodHasStarted = false

-- Stores which heroes a player can use skills from
-- draftArray[playerID][heroID] = true
local draftArray = {}

-- Player's vote data, key = playerID
local voteData = {}

-- Table of banned skills
local bannedSkills = {}

-- Skill list for a given player
local skillList = {}

-- List of skills for towers (per team)
local towerSkills = {}

-- List of skills for buildings (per team)
local buildingSkills = {}

-- List of skills for creeps (per team)
local creepSkills = {}

-- The total amount banned by each player
local totalBans = {}

-- When the hero selection started
local heroSelectionStart = nil

-- A list of heroes that were picking before the game started
local brokenHeroes = {}

-- Stick skills into slots
local handled = {}
local handledPlayerIDs = {}

-- Teams which have requested extra time
local extraTime = {}

-- A list of warning attached to skills
local skillWarnings

-- List of tower connectors
local towerConnectors = {}

--[[
    STATUS VARIABLES
]]

-- User is trying to pick
local hasHero = {}
local hasBanned = {}
local banChance = {}
local bannedHeroes = {}

--[[
    CONSTANTS
]]
local SPLIT_CHAR = string.char(7)

local SERVER_COMMAND = 0x10000000
local CLIENT_COMMAND = 268435456--0x80000000

--[[
    LOAD EXTERNAL OPTIONS
]]

-- Check for options module
local patchOptions = false
--if Options then
    --[[ CURRENTLY NOT NEEDED, RECODE THIS IF NEEDED
    -- Woot, load the options :)
    patchOptions = true

    -- Constants for option lookup
    local GAME_MODE = '0'
    local MAX_SLOTS = '1'
    local MAX_REGULAR = '2'
    local MAX_ULTIMATE = '3'
    local BANS = '4'
    local EASY_MODE = '5'
    local TROLL_MODE = '6'
    local HIDE_PICKS = '7'
    local STARTING_LEVEL = '8'
    local BONUS_GOLD = '9'
    local UNIQUE_SKILLS = '10'

    -- Read in the settings
    local banInfo = Options.getOption('lod', BANS, maxBans)
    if banInfo == 'h' then
        -- Host banning mode
        maxBans = 500
        hostBanning = true
    else
        -- Regular banning
        maxBans = tonumber(banInfo)
        hostBanning = false
    end

    gamemode = tonumber(Options.getOption('lod', GAME_MODE, gamemode-1)) + 1
    maxSlots = tonumber(Options.getOption('lod', MAX_SLOTS, maxSlots))
    maxSkills = tonumber(Options.getOption('lod', MAX_REGULAR, maxSkills))
    maxUlts = tonumber(Options.getOption('lod', MAX_ULTIMATE, maxUlts))

    -- Remove banning time if no bans are allowed
    if maxBans <= 0 then
        OptionManager:SetOption('banningTime', 0)
    end

    startingLevel = tonumber(Options.getOption('lod', STARTING_LEVEL, startingLevel))
    bonusGold = tonumber(Options.getOption('lod', BONUS_GOLD, bonusGold))

    useEasyMode = tonumber(Options.getOption('lod', EASY_MODE, 0)) == 1
    banTrollCombos = tonumber(Options.getOption('lod', TROLL_MODE, 0)) == 0
    hideSkills = tonumber(Options.getOption('lod', HIDE_PICKS, 1)) == 1]]
--[[else
    -- Are we using GDS option?
    if GDSOptions then
        if loadGDSOptions then
            -- Set it up
            GDSOptions.setup('2374504c2c518fafc9731a120e67fdf5', function(err, options)
                -- Check for an error
                if err then
                    print('Something went wrong and we got no options: '..err)
                    return
                end

                -- Check if voting is already over
                if currentStage > STAGE_VOTING then return end

                -- Attempt to pull the slaveID
                if OptionManager:GetOption('slaveID') == -1 then
                    OptionManager:SetOption('slaveID', loadhelper.getHostID())
                end

                if OptionManager:GetOption('slaveID') == -1 then
                    print('Option loading failed, slaveID == -1')
                    return
                end

                -- Set settings go go go
                OptionManager:SetOption('gamemode', tonumber(GDSOptions.getOption('gamemode', 2)))

                OptionManager:SetOption('maxSlots', tonumber(GDSOptions.getOption('maxslots', 2)))
                OptionManager:SetOption('maxSkills', tonumber(GDSOptions.getOption('maxskills', 2)))
                OptionManager:SetOption('maxUlts', tonumber(GDSOptions.getOption('maxults', 2)))
                OptionManager:SetOption('maxBans', tonumber(GDSOptions.getOption('maxbans', 5)))
                OptionManager:SetOption('banTrollCombos', GDSOptions.getOption('blocktrollcombos', true))
                OptionManager:SetOption('startingLevel', tonumber(GDSOptions.getOption('startinglevel', 0)))
                OptionManager:SetOption('useEasyMode', GDSOptions.getOption('useeasymode', false))
                OptionManager:SetOption('hideSkills', GDSOptions.getOption('hideenemypicks', true))
                OptionManager:SetOption('bonusGold', tonumber(GDSOptions.getOption('bonusstartinggold', 0)))
                OptionManager:SetOption('forceUniqueSkills', tonumber(GDSOptions.getOption('uniqueskills', 2)))

                OptionManager:SetOption('allowBearSkills', GDSOptions.getOption('allowBearSkills', false))
                OptionManager:SetOption('allowTowerSkills', GDSOptions.getOption('allowTowerSkills', false))
                OptionManager:SetOption('wtfMode', GDSOptions.getOption('wtfMode', false))
                OptionManager:SetOption('universalShop', GDSOptions.getOption('universalShop', false))
                OptionManager:SetOption('fastJungleCreeps', GDSOptions.getOption('fastJungleCreeps', false))
                OptionManager:SetOption('allVision', GDSOptions.getOption('allVision', false))
                OptionManager:SetOption('respawnModifier', tonumber(GDSOptions.getOption('respawnModifier', 0)))
                OptionManager:SetOption('freeScepter', GDSOptions.getOption('freeScepter', false))
                OptionManager:SetOption('multicastMadness', GDSOptions.getOption('multicastMadness', false))
                OptionManager:SetOption('maxHeroLevel', tonumber(GDSOptions.getOption('maxHeroLevel', 25)))
                OptionManager:SetOption('customSpellPower', tonumber(GDSOptions.getOption('customSpellPower', 1)))
                OptionManager:SetOption('customItemPower', tonumber(GDSOptions.getOption('customItemPower', 1)))
                OptionManager:SetOption('freeCourier', GDSOptions.getOption('freeCourier', false))
                OptionManager:SetOption('middleTowers', tonumber(GDSOptions.getOption('middleTowers', 1)))
                OptionManager:SetOption('allowBuildingSkills', GDSOptions.getOption('allowBuildingSkills', false))
                OptionManager:SetOption('allowCreepSkills', GDSOptions.getOption('allowCreepSkills', false))
                OptionManager:SetOption('buffHeroes', GDSOptions.getOption('buffHeroes', false))
                OptionManager:SetOption('buffTowers', GDSOptions.getOption('buffTowers', false))
                OptionManager:SetOption('buffBuildings', GDSOptions.getOption('buffBuildings', false))
                OptionManager:SetOption('buffCreeps', GDSOptions.getOption('buffCreeps', false))
                OptionManager:SetOption('buffNeutralCreeps', GDSOptions.getOption('buffNeutralCreeps', false))
                OptionManager:SetOption('preventFountainCamping', GDSOptions.getOption('preventFountainCamping', false))
                OptionManager:SetOption('useLevel1ults', GDSOptions.getOption('useLevel1ults', false))
                OptionManager:SetOption('fullPriceSellback', GDSOptions.getOption('fullPriceSellback', false))

                -- Grab the slaveID
                local slaveID = OptionManager:GetOption('slaveID')

                voteData[slaveID] = voteData[slaveID] or {}
                voteData[slaveID][0] = valueToOption(0, OptionManager:GetOption('gamemode'))
                voteData[slaveID][1] = valueToOption(1, OptionManager:GetOption('maxSlots'))
                voteData[slaveID][2] = valueToOption(2, OptionManager:GetOption('maxSkills'))
                voteData[slaveID][3] = valueToOption(3, OptionManager:GetOption('maxUlts'))
                voteData[slaveID][4] = valueToOption(4, OptionManager:GetOption('maxBans'))
                voteData[slaveID][5] = valueToOption(5, (OptionManager:GetOption('banTrollCombos') and 1) or 0)
                voteData[slaveID][6] = valueToOption(6, OptionManager:GetOption('startingLevel'))
                voteData[slaveID][7] = valueToOption(7, (OptionManager:GetOption('useEasyMode') and 1) or 0)
                voteData[slaveID][8] = valueToOption(8, (OptionManager:GetOption('hideSkills') and 1) or 0)
                voteData[slaveID][9] = valueToOption(9, OptionManager:GetOption('bonusGold'))
                voteData[slaveID][10] = valueToOption(10, OptionManager:GetOption('forceUniqueSkills'))
                --voteData[slaveID][11] = valueToOption(11, OptionManager:GetOption('forceUniqueSkills'))
                --voteData[slaveID][12] = valueToOption(12, OptionManager:GetOption('forceUniqueSkills'))
                --voteData[slaveID][13] = valueToOption(13, OptionManager:GetOption('forceUniqueSkills'))
                --voteData[slaveID][14] = valueToOption(14, OptionManager:GetOption('forceUniqueSkills'))
                --voteData[slaveID][15] = valueToOption(15, OptionManager:GetOption('forceUniqueSkills'))
                voteData[slaveID][16] = valueToOption(16, OptionManager:GetOption('allowBearSkills'))
                voteData[slaveID][17] = valueToOption(17, OptionManager:GetOption('allowTowerSkills'))
                voteData[slaveID][18] = valueToOption(18, OptionManager:GetOption('wtfMode'))
                voteData[slaveID][19] = valueToOption(19, OptionManager:GetOption('universalShop'))
                voteData[slaveID][20] = valueToOption(20, OptionManager:GetOption('fastJungleCreeps'))
                voteData[slaveID][21] = valueToOption(21, OptionManager:GetOption('allVision'))
                voteData[slaveID][22] = valueToOption(22, OptionManager:GetOption('respawnModifier'))
                voteData[slaveID][23] = valueToOption(23, OptionManager:GetOption('freeScepter'))
                voteData[slaveID][24] = valueToOption(24, OptionManager:GetOption('multicastMadness'))
                voteData[slaveID][25] = valueToOption(25, OptionManager:GetOption('maxHeroLevel'))
                voteData[slaveID][26] = valueToOption(26, OptionManager:GetOption('customSpellPower'))
                voteData[slaveID][27] = valueToOption(27, OptionManager:GetOption('customItemPower'))
                voteData[slaveID][28] = valueToOption(28, OptionManager:GetOption('freeCourier'))
                voteData[slaveID][29] = valueToOption(29, OptionManager:GetOption('middleTowers'))
                voteData[slaveID][30] = valueToOption(30, OptionManager:GetOption('allowBuildingSkills'))
                voteData[slaveID][31] = valueToOption(31, OptionManager:GetOption('allowCreepSkills'))
                voteData[slaveID][32] = valueToOption(32, OptionManager:GetOption('buffHeroes'))
                voteData[slaveID][33] = valueToOption(33, OptionManager:GetOption('buffTowers'))
                voteData[slaveID][34] = valueToOption(34, OptionManager:GetOption('buffBuildings'))
                voteData[slaveID][35] = valueToOption(35, OptionManager:GetOption('buffCreeps'))
                voteData[slaveID][36] = valueToOption(36, OptionManager:GetOption('buffNeutralCreeps'))
                voteData[slaveID][37] = valueToOption(37, OptionManager:GetOption('preventFountainCamping'))
                voteData[slaveID][38] = valueToOption(38, OptionManager:GetOption('useLevel1ults'))
                voteData[slaveID][39] = valueToOption(39, OptionManager:GetOption('fullPriceSellback'))
            end)
        else
            -- Disable it
            GDSOptions.setup()
        end
    end
end
]]

-- This will contain the total number of votable options
local totalVotableOptions = 0

-- Load voting options
local votingList = LoadKeyValues('scripts/kv/voting.kv');

-- This will store the total number of choices for each option
local totalChoices = {}

-- Are we still voting?
local stillVoting = true

-- Generate choices index
for k,v in pairs(votingList) do
    -- Count number of choices
    local total = 0
    for kk, vv in pairs(v.options) do
        total = total+1
    end

    -- Store it
    totalChoices[tonumber(k)] = total

    -- We found another option
    totalVotableOptions = totalVotableOptions+1
end

-- Slot types
local slotTypes = {}

local SLOT_TYPE_ABILITY = '1'
local SLOT_TYPE_ULT = '2'
local SLOT_TYPE_EITHER = '3'
local SLOT_TYPE_NEITHER = '4'

-- Ban List
local banList = {}
local wtfAutoBan = {}
local noTower = {}
local noTowerAlways = {}
local noBear = {}
local noHero = {}

-- Load and process the bans
(function()
    -- Load in the ban list
    local tempBanList = LoadKeyValues('scripts/kv/bans.kv')

    -- Store no multicast
    SpellFixes:SetNoCasting(tempBanList.noMulticast, tempBanList.noWitchcraft)
    noTower = tempBanList.noTower
    noTowerAlways = tempBanList.noTowerAlways
    noBear = tempBanList.noBear
    wtfAutoBan = tempBanList.wtfAutoBan
    noHero = tempBanList.noHero

    -- Bans a skill combo
    local function banCombo(a, b)
        -- Ensure ban lists exist
        banList[a] = banList[a] or {}
        banList[b] = banList[b] or {}

        -- Store the ban
        banList[a][b] = true
        banList[b][a] = true
    end

    -- Loop over the banned combinations
    for skillName, group in pairs(tempBanList.BannedCombinations) do
        for skillName2,_ in pairs(group) do
            banCombo(skillName, skillName2)
        end
    end

    -- Function to do a category ban
    local doCatBan
    doCatBan = function(skillName, cat)
        for skillName2,sort in pairs(tempBanList.Categories[cat] or {}) do
            if sort == 1 then
                banCombo(skillName, skillName2)
            elseif sort == 2 then
                doCatBan(skillName, skillName2)
            else
                print('Unknown category banning sort: '..sort)
            end
        end
    end


    -- Loop over category bans
    for skillName,cat in pairs(tempBanList.CategoryBans) do
        doCatBan(skillName, cat)
    end

    -- Ban the group bans
    for _,group in pairs(tempBanList.BannedGroups) do
        for skillName,__ in pairs(group) do
            for skillName2,___ in pairs(group) do
                banCombo(skillName, skillName2)
            end
        end
    end
end)()

-- Ability stuff
local abs = LoadKeyValues('scripts/npc/npc_abilities.txt')
local absCustom = LoadKeyValues('scripts/npc/npc_abilities_custom.txt')
local iconLookup = {}
local skillLookup = {}

function buildSkillListLookup()
    -- Load the abilities file
    local tempSkillList = LoadKeyValues('scripts/kv/abilities.kv').skills

    -- Loop over all tabs
    for tabName,skills in pairs(tempSkillList) do
        -- Is this tab allowed?
        if allowedTabs[tabName] then
            -- Loop over all skills
            for skillName,skillIndex in pairs(skills) do
                -- Do patch
                local doInclude = true

                -- Grab the source1 string
                local s1Skill = string.gsub(skillIndex, '_s1', '')
                local s2Skill = string.gsub(skillIndex, '_s2', '')

                -- Check if this is a source1 only skill
                if s1Skill ~= tostring(skillIndex) then
                    -- Copy it across
                    skillIndex = s1Skill

                    -- If not source1, we can't include
                    if not GameRules:isSource1() then
                        doInclude = false
                    end
                elseif s2Skill ~= tostring(skillIndex) then
                    -- Copy it across
                    skillIndex = s2Skill

                    -- If not source1, we can't include
                    if GameRules:isSource1() then
                        doInclude = false
                    end
                end

                -- If we should include it, do it
                if doInclude then
                    -- Check if it's valid
                    if tonumber(skillIndex) ~= nil then
                        -- Store the skill
                        skillLookup[skillName] = tonumber(skillIndex)
                    end
                end
            end
        end
    end
end

-- Merge custom abilities into main abiltiies file
for k,v in pairs(absCustom) do
    abs[k] = v
end

-- Build icon lookup
for k,v in pairs(abs) do
    if k ~= 'Version' then
        if v.AbilityTextureName then
            iconLookup[k] = v.AbilityTextureName
        elseif v.BaseClass and v.BaseClass ~= 'item_datadriven' then
            iconLookup[k] = v.BaseClass
        else
            iconLookup[k] = k
        end
    end
end

-- Create list of spells with certain attributes
util:SetupSpellProperties(abs)

-- Load the hero KV file
local heroKV = LoadKeyValues('scripts/npc/npc_heroes.txt')

-- Build a table of valid hero IDs to pick from, and skill owners
local validHeroIDs = {}
local validHeroNames = {}
local skillOwningHero = {}
for k,v in pairs(heroKV) do
    if k ~= 'Version' and k ~= 'npc_dota_hero_base' then
        -- If this hero has an ID
        if v.HeroID then
            -- Store the hero name as valid
            validHeroNames[k] = true

            -- Store the ID as valid
            table.insert(validHeroIDs, v.HeroID)

            -- Loop over all possible 16 slots
            for i=1,16 do
                -- Grab the ability
                local ab = v['Ability'..i]

                -- Did we actually find an ability?
                if ab then
                    -- Yep, store this hero as the owner
                    skillOwningHero[ab] = v.HeroID
                end
            end
        end
    end
end

local ownersKV = LoadKeyValues('scripts/kv/owners.kv')
for k,v in pairs(ownersKV) do
    skillOwningHero[k] = tonumber(v);
end

-- Change random seed
local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
math.randomseed(tonumber(timeTxt))

-- These numbers are used to encode radiant / dire skills
local encodeRadiant = math.random(50,100)
local encodeDire = math.random(50,100)

-- Should we hide the enemy team's skills
local hideSkills = true

-- Stores player locks
local playerLocks = {}

-- Stores when the next timer should end (-1 = no timer)
local endOfTimer = -1

-- Version stuff
local versionFile = LoadKeyValues('addoninfo.txt')
local versionNumber = versionFile.version

-- Returns the current version
function getLodVersion()
    return versionNumber
end

isUlt = function(skillName)
    -- Check if it is tagged as an ulty
    if abs[skillName] and abs[skillName].AbilityType and abs[skillName].AbilityType == 'DOTA_ABILITY_TYPE_ULTIMATE' then
        return true
    end

    return false
end

-- Returns if a skill is a passive
isPassive = function(skillName)
    if abs[skillName] and abs[skillName].AbilityBehavior and string.match(abs[skillName].AbilityBehavior, 'DOTA_ABILITY_BEHAVIOR_PASSIVE') and not string.match(abs[skillName].AbilityBehavior, 'DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE') then
        return true
    end

    return false
end

-- Returns true if the player is on a valid team
isPlayerOnValidTeam = function(playerID)
    local team = PlayerResource:GetTeam(playerID)

    return team == DOTA_TEAM_BADGUYS or team == DOTA_TEAM_GOODGUYS
end

-- Checks to see if this is a valid skill
isValidSkill = function(skillName)
    if skillLookup[skillName] == nil then return false end

    -- For now, no validation
    return true
end

-- Tells you if a hero name is valid, or not
isValidHeroName = function(heroName)
    if validHeroNames[heroName] then
        return true
    end

    return false
end

-- Returns the ID for a skill, or -1
getSkillID = function(skillName)
    if skillName == nil then return -1 end

    -- If the skill wasn't found, return -1
    if skillLookup[skillName] == nil then return -1 end

    -- Otherwise, return the correct value
    return skillLookup[skillName]
end

-- Ensures this is a valid slot
isValidSlot = function(slotNumber)
    if slotNumber == nil then return false end

    if slotNumber < 0 or slotNumber >= OptionManager:GetOption('maxSlots') then return false end
    return true
end

-- Checks to see if a skill is already banned
isSkillBanned = function(skillName)
    return bannedSkills[skillName] or false
end

-- Returns the ID (or -1) of the hero that owns this skill
GetSkillOwningHero = function(skillName)
    return skillOwningHero[skillName] or -1
end

banSkill = function(skillName)
    -- Make sure the skill isn't already banned
    if not isSkillBanned(skillName) then
        -- Store the ban
        bannedSkills[skillName] = true

        -- Fire the ban event
        FireGameEvent('lod_ban', {
            skill = skillName
        })
    end
end

buildDraftString = function(playerID)
    -- Ensure this player has a draft array
    draftArray[playerID] = draftArray[playerID] or {}

    -- Rebuild draft string
    local str
    for k,v in pairs(draftArray[playerID]) do
        -- Ensure it is actually enabled
        if v then
            -- Add to the combo
            if str then
                str = str..'|'..k
            else
                str = k
            end
        end
    end

    return str or ''
end

addHeroDraft = function(playerID, heroID)
    -- Ensure this player has a draft array
    draftArray[playerID] = draftArray[playerID] or {}

    -- Check if we are chaning anything
    local changed = false
    if not draftArray[playerID][heroID] then
        changed = true
    end

    -- Enable this hero in their draft
    draftArray[playerID][heroID] = true

    -- Return the changed status
    return changed
end

getPlayerSlot = function(playerID)
    -- Grab the cmd player
    local cmdPlayer = PlayerResource:GetPlayer(playerID)
    if not cmdPlayer then return -1 end

    -- Find player slot
    local team = cmdPlayer:GetTeam()
    local playerSlot = 0
    for i=0, 9 do
        if i >= playerID then break end

        if PlayerResource:GetTeam(i) == team then
            playerSlot = playerSlot + 1
        end
    end
    if team == DOTA_TEAM_BADGUYS then
        playerSlot = playerSlot + 5
    end

    return playerSlot
end

--[[
    Message Senders
]]

sendChatMessage = function(playerID, msg, args)
    -- Fire the event
     FireGameEvent('lod_msg', {
        playerID = playerID,
        msg = msg,
        args = table.concat(args or {}, SPLIT_CHAR)
    })
end

sendRadiantMessage = function(msg, args)
    -- Fire the event
     FireGameEvent('lod_msg', {
        playerID = -DOTA_TEAM_GOODGUYS,
        msg = msg,
        args = table.concat(args or {}, SPLIT_CHAR)
    })
end

sendDireMessage = function(msg, args)
    -- Fire the event
     FireGameEvent('lod_msg', {
        playerID = -DOTA_TEAM_BADGUYS,
        msg = msg,
        args = table.concat(args or {}, SPLIT_CHAR)
    })
end

sendTeamMessage = function(teamID, msg, args)
    -- Fire the event
     FireGameEvent('lod_msg', {
        playerID = -teamID,
        msg = msg,
        args = table.concat(args or {}, SPLIT_CHAR)
    })
end

-- Checks if the player already has this skill
alreadyHas = function(skillList, skill)
    for i=1,OptionManager:GetOption('maxSlots') do
        if skillList[i] == skill then
            return true
        end
    end

    return false
end

CheckBans = function(skillList2, slotNumber, skillName, playerID)
    -- Old fashion bans
    if isSkillBanned(skillName) then
        return '#lod_skill_banned'
    end

    -- Check for uniqye skills
    if not OptionManager:GetOption('allowBearSkills') or not skillName == 'lone_druid_spirit_bear' then
        if OptionManager:GetOption('forceUniqueSkills') == UNIQUE_SKILLS_TEAM then
            -- Team based unqiue skills
            local team = PlayerResource:GetTeam(playerID)

            for playerID2,skillLists3 in pairs(skillList) do
                -- Ensure same team
                if team == PlayerResource:GetTeam(playerID2) then
                    for interface,_ in pairs(skillLists3) do
                        local skills = skillLists3[interface]
                        for slot,skill in pairs(skills) do
                            if skill == skillName then
                                if not (skillList2 == skills and slot == slotNumber) then
                                    return '#lod_taken_team', {
                                        getSpellIcon(skillName),
                                        tranAbility(skillName)
                                    }
                                end
                            end
                        end
                    end
                end
            end
        elseif OptionManager:GetOption('forceUniqueSkills') == UNIQUE_SKILLS_GLOBAL then
            -- Global unique skills
            for playerID2,skillLists3 in pairs(skillList) do
                for interface,_ in pairs(skillLists3) do
                    local skills = skillLists3[interface]
                    for slot,skill in pairs(skills) do
                        if skill == skillName then
                            if not (skillList2 == skills and slot == slotNumber) then
                                return '#lod_taken_global', {
                                    getSpellIcon(skillName),
                                    tranAbility(skillName)
                                }
                            end
                        end
                    end
                end
            end
        end
    end

    -- Are we using the draft array?
    if OptionManager:GetOption('useDraftArray') then
        -- Ensure this player has a drafting array
        draftArray[playerID] = draftArray[playerID] or {}

        -- Check their drafting array
        if not draftArray[playerID][GetSkillOwningHero(skillName)] then
            return '#lod_not_in_pool', {
                getSpellIcon(skillName),
                tranAbility(skillName)
            }
        end
    end

    -- Check if they actually already have this skill
    -- This is to prevent crashes
    for i=1,OptionManager:GetOption('maxSlots') do
        if skillList2[i] == skillName then
            return '#lod_already_in_draft', {
                getSpellIcon(skillName),
                tranAbility(skillName)
            }
        end
    end

    -- Should we ban troll combos?
    if OptionManager:GetOption('banTrollCombos') then
        if banList[skillName] then
            -- Loop over all our slots
            for i=1,OptionManager:GetOption('maxSlots') do
                -- Ignore the skill in our current slot
                if i ~= slotNumber then
                    -- Check the banned combo
                    if banList[skillName][skillList2[i]] then
                        return '{0} <font color=\"#EB4B4B\">{1}</font> can not be used with {2}<font color=\"#EB4B4B\">{3}</font>', {
                            getSpellIcon(skillName),
                            tranAbility(skillName),
                            getSpellIcon(skillList2[i]),
                            tranAbility(skillList2[i])
                        }
                    end
                end
            end
        end
    end

    -- Dont allow multicast when madness is on
    if OptionManager:GetOption('multicastMadness') and skillName == 'ogre_magi_multicast_lod' then
        return '#lod_multicast_no_multicast'
    end
end

-- Sets up slot types
setupSlotType = function(playerID)
    if slotTypes[playerID] then return end

    -- Create store for this player
    slotTypes[playerID] = {}

    if playerID >= 0 then
        for interface,_ in pairs(validInterfaces) do
            slotTypes[playerID][interface] = {}
        end
    end

    -- Put stuff in
    for j=0,OptionManager:GetOption('maxSlots')-1 do
        -- Workout if we can allow an ulty, or a skill in the given slot
        local skill = false
        local ult = false

        if j < OptionManager:GetOption('maxSkills') then
            skill = true
        end

        if j >= OptionManager:GetOption('maxSlots')-OptionManager:GetOption('maxUlts') then
            ult = true
        end

        -- Grab the result
        local res
        if skill and not ult then
            res = SLOT_TYPE_ABILITY;
        elseif skill and ult then
            res = SLOT_TYPE_EITHER;
        elseif not skill and ult then
            res = SLOT_TYPE_ULT;
        else
            res = SLOT_TYPE_NEITHER;
        end

        if playerID >= 0 then
            -- Store the result
            for interface,_ in pairs(validInterfaces) do
                slotTypes[playerID][interface][j] = res
            end
        else
            slotTypes[playerID][j] = res
        end
    end
end

setupSlotTypes = function()
    local maxPlayers = 10

    for i=0,maxPlayers-1 do
        setupSlotType(i)
    end

    for i=2,3 do
        setupSlotType(-i)
    end
end

findRandomSkill = function(playerID, interface, slotNumber, filter)
    -- Workout if we can put an ulty here, or a skill
    local canUlt
    local canSkill

    setupSlotType(playerID)
    local slotType = slotTypes[playerID][interface][slotNumber]

    if slotType == SLOT_TYPE_EITHER then
        canUlt = true
        canSkill = true
    elseif slotType == SLOT_TYPE_ABILITY then
        canUlt = false
        canSkill = true
    elseif slotType == SLOT_TYPE_ULT then
        canUlt = true
        canSkill = false
    else
        canUlt = false
        canSkill = false
    end

    -- There is a chance there is no valid skill
    if not canUlt and not canSkill then
        -- Damn scammers! No valid skills!
        return '#lod_no_valid_skills'
    end

    -- Build a list of possible skills
    local possibleSkills = {}

    for k,v in pairs(skillLookup) do
        -- Ensure the player doesn't already have the skill
        if not alreadyHas(skillList[playerID][interface], k) then
            -- Check filter
            if not filter or filter(k) then
                -- Check type of skill
                if (canUlt and isUlt(k)) or (canSkill and not isUlt(k)) then
                    -- Check for bans
                    if not CheckBans(skillList[playerID][interface], slotNumber+1, k, playerID) then
                        -- Can't random meepo ulty
                        if k ~= 'meepo_divided_we_stand' then
                            -- Stop bearception
                            if k ~= 'lone_druid_spirit_bear' or interface == SKILL_LIST_YOUR then
                                if not skillWarnings[k] then
                                    -- Valid skill, add to our possible skills
                                    table.insert(possibleSkills, k)
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Did we find no possible skills?
    if #possibleSkills == 0 then
        return '#lod_no_valid_skills'
    end

    -- Pick a random skill
    return nil, possibleSkills[math.random(#possibleSkills)]
end

-- Ensures the person has all their slots used
validateBuild = function(playerID)
    -- Ensure it exists
    skillList[playerID] = skillList[playerID] or {}

    -- Loop over all slots
    for interface,_ in pairs(validInterfaces) do
        skillList[playerID][interface] = skillList[playerID][interface] or {}
        for j=0,OptionManager:GetOption('maxSlots')-1 do
            -- Do they have a skill in this slot?
            if not skillList[playerID][interface][j+1] then
                local msg, skillName = findRandomSkill(playerID, interface, j)

                -- Did we find a valid skill?
                if skillName then
                    -- Pick a random skill
                    skillList[playerID][interface][j+1] = skillName
                end
            end
        end
    end
end

-- Fixes broken heroes
fixBuilds = function()
    -- Give skills
    for k,v in pairs(brokenHeroes) do
        if k and IsValidEntity(k) then
            local playerID = k:GetPlayerID()

            -- Validate the build
            validateBuild(playerID)

            -- Grab their build
            local build = skillList[playerID][SKILL_LIST_YOUR]

            -- Apply the build
            SkillManager:ApplyBuild(k, build)

            -- Store playerID has handled
            handledPlayerIDs[playerID] = true
        end
    end

    -- No more broken heroes
    brokenHeroes = {}
end

-- Builds a string to represent the type of slots allowed for the given player
slotTypeString = function (playerID, interface)
    if not slotTypes[playerID] or (interface and not slotTypes[playerID][interface]) then return '' end

    local str = ''
    for j=0,OptionManager:GetOption('maxSlots')-1 do
        if interface then
            str = str..slotTypes[playerID][interface][j]
        else
            str = str..slotTypes[playerID][j]
        end
    end

    return str
end

-- Prints options to the given player
printOptionsToPlayer = function(playerID)
    -- Announce results
    sendChatMessage(playerID, '#lod_results', {
        OptionManager:GetOption('maxSlots'),
        OptionManager:GetOption('maxSkills'),
        ((OptionManager:GetOption('maxSkills') == 1 and '#lod_ability') or '#lod_abilities'),
        OptionManager:GetOption('maxUlts'),
        ((maxUlts == 1 and '#lod_ ability') or '#lod_abilities'),
        ((OptionManager:GetOption('banTrollCombos') and '#lod_BANNED') or '#lod_ALLOWED'),
        OptionManager:GetOption('startingLevel'),
        OptionManager:GetOption('bonusGold'),
        OptionManager:GetOption('maxHeroLevel')
    })

    -- Announce which gamemode we're playing
    sendChatMessage(playerID, '#lod_gamemode', {
        '#lod_gamemode'..OptionManager:GetOption('gamemode')
    })

    -- Are we using easy mode?
    if OptionManager:GetOption('useEasyMode') then
        -- Tell players
        sendChatMessage(playerID, '#lod_easy_mode')
    end

    if OptionManager:GetOption('fullPriceSellback') then
        -- Tell players
        sendChatMessage(playerID, '#lod_full_price_sellback')
    end

    if OptionManager:GetOption('useLevel1ults') then
        -- Tell players
        sendChatMessage(playerID, '#lod_level1_ults')
    end

    if OptionManager:GetOption('preventFountainCamping') then
        -- Tell players
        sendChatMessage(playerID, '#lod_prevent_fountain_camping')
    end

    -- Are we using unique skills?
    if OptionManager:GetOption('forceUniqueSkills') > 0 then
        sendChatMessage(playerID, '#lod_unique_skills', {
            ((OptionManager:GetOption('forceUniqueSkills') == UNIQUE_SKILLS_TEAM and '#lod_us_team_based') or (OptionManager:GetOption('forceUniqueSkills') == UNIQUE_SKILLS_GLOBAL and '#lod_us_global'))
        })
    end

    -- WTF Mode stuff
    if OptionManager:GetOption('wtfMode') then
        sendChatMessage(playerID, '#lod_wtf')
    end

    -- Universal Shop
    if OptionManager:GetOption('universalShop') then
        sendChatMessage(playerID, '#lod_universal_shop')
    end

    -- Fast Jungle
    if OptionManager:GetOption('fastJungleCreeps') then
        sendChatMessage(playerID, '#lod_fast_jungle_creeps')
    end

    -- All Vision
    if OptionManager:GetOption('allVision') then
        sendChatMessage(playerID, '#lod_all_vision')
    end

    -- Multicast madness
    if OptionManager:GetOption('multicastMadness') then
        sendChatMessage(playerID, '#lod_multicast_madness')
    end

    -- Fast Scepter
    if OptionManager:GetOption('freeScepter') then
        sendChatMessage(playerID, '#lod_fast_scepter')
    end

    -- Survival
    --[[if OptionManager:GetOption('loadSurvival') then
        sendChatMessage(playerID, '#lod_survival')
    end]]

    -- Respawn Timer
    local respawnModifier = OptionManager:GetOption('respawnModifier')
    if respawnModifier ~= 0 then
        if respawnModifier < 0 then
            sendChatMessage(playerID, '#lod_respawn_modifier_constant', {
                '#lod_respawn_'..(-respawnModifier)
            })
        else
            -- Round two one decimal place
            local rounded = math.floor(respawnModifier*10)/10

            sendChatMessage(playerID, '#lod_respawn_modifier_variable', {
                '#lod_respawn_'..tostring(rounded):gsub('%.', '_')
            })
        end
    end

    -- Tell the user which mode it is
    if currentStage == STAGE_BANNING then
        -- Banning mode
        if not OptionManager:GetOption('hostBanning') then
            sendChatMessage(playerID, '#lod_banning', {
                math.ceil(endOfTimer-Time()),
                OptionManager:GetOption('maxBans')
            })
        else
            if playerID ~= -1 then
                -- Tell other players to sit tight
                if OptionManager:GetOption('slaveID') ~= playerID then
                    sendChatMessage(playerID, '#lod_host_banning')
                else
                    -- Send banning info to main player
                    sendChatMessage(playerID, '#lod_banning', {
                        math.ceil(endOfTimer-Time()),
                        OptionManager:GetOption('maxBans')
                    })
                end
            else
                -- Tell other players to sit tight
                for i=0,9 do
                    if OptionManager:GetOption('slaveID') ~= i then
                        sendChatMessage(i, '#lod_host_banning')
                    else
                        -- Send banning info to main player
                        sendChatMessage(-1, '#lod_banning', {
                            math.ceil(endOfTimer-Time()),
                            OptionManager:GetOption('maxBans')
                        })
                    end
                end
            end
        end
    elseif currentStage == STAGE_PICKING then
        -- Picking mode
        sendChatMessage(playerID, '#lod_picking', {
            math.ceil(endOfTimer-Time())
        })
    end

    if OptionManager:GetOption('maxSlots') > 6 then
        sendChatMessage(playerID, '#lod_slotWarning')
    end
end

-- Takes the current gamemode number, and sets the required settings
setupGamemodeSettings = function()
    -- Default to not using the draft array
    OptionManager:SetOption('useDraftArray', false)

    -- Single Draft Mode
    if OptionManager:GetOption('gamemode') == GAMEMODE_SD then
        -- We need the draft array for this
        OptionManager:SetOption('useDraftArray', true)

        -- We need some skills drafted for us
        OptionManager:SetOption('autoDraftHeroNumber', 10)
    end

    -- Mirror Draft Mode
    if OptionManager:GetOption('gamemode') == GAMEMODE_MD then
        -- We need the draft array for this
        OptionManager:SetOption('useDraftArray', true)

        -- We need some skills drafted for us
        OptionManager:SetOption('autoDraftHeroNumber', 0)

        -- Number of heroes to pick from
        local totalHeroes = 10

        -- Loop over the 4 players on each team
        for i=0,4 do
            -- Stores an array of heroes we have already added to the draft
            local taken = {};

            local total = 0
            while total < totalHeroes do
                -- Pick a random heroID
                local heroID = validHeroIDs[math.random(#validHeroIDs)]

                -- Have we already allocated this heroID?
                if not taken[heroID] then
                    -- Store it as allocated
                    taken[heroID] = true

                    -- Increment total
                    total = total+1

                    -- Allocate to all other players
                    addHeroDraft(i, heroID)
                    addHeroDraft(i+5, heroID)
                end
            end
        end
    end

    -- All Random
    if OptionManager:GetOption('gamemode') == GAMEMODE_AR then
        -- No picking time
        OptionManager:SetOption('pickingTime', 0)

        -- Users are not allowed to pick skills
        OptionManager:SetOption('allowedToPick', false)

        -- Force random heroes
        OptionManager:SetOption('forceRandomHero', true)

        -- Players can still ban things though
    end

    -- Should we draft heroes for players?
    if OptionManager:GetOption('useDraftArray') and OptionManager:GetOption('autoDraftHeroNumber')>0 then
        -- Pick random heroes for each player
        for i=0,9 do
            local total = 0
            while total < OptionManager:GetOption('autoDraftHeroNumber') do
                -- Pick a random heroID
                local heroID = validHeroIDs[math.random(#validHeroIDs)]

                -- Attempt to add this hero
                if addHeroDraft(i, heroID) then
                    -- Success, this player got another hero to draft from
                    total = total+1
                end
            end
        end
    end

    -- Are we using easy mode?
    if OptionManager:GetOption('useEasyMode') then
        -- Enable it
        Convars:SetInt('dota_easy_mode', 1)
    end

    -- Are we using unique heroes?
    if OptionManager:GetOption('uniqueHeroes') then
        -- Force unique
        GameRules:SetSameHeroSelectionEnabled(false)
    else
        -- Allow the same
        GameRules:SetSameHeroSelectionEnabled(true)
    end

    if OptionManager:GetOption('fullPriceSellback') then
        -- Enable it
        Convars:SetFloat('dota_item_fullprice_buyback_interval', 100000000)
    end

    -- WTF Mode stuff
    if OptionManager:GetOption('wtfMode') then
        -- Ban skills
        for k,v in pairs(wtfAutoBan) do
            bannedSkills[k] = true
        end

        -- Enable WTF
        Convars:SetBool('dota_ability_debug', true)
    end

    -- Universal Shop
    if OptionManager:GetOption('universalShop') then
        GameRules:SetUseUniversalShopMode(true)
    end

    -- Fast creep spawning
    if OptionManager:GetOption('fastJungleCreeps') then
        Convars:SetFloat('dota_neutral_spawn_interval', 0)
        Convars:SetFloat('dota_neutral_initial_spawn_delay', 1)
    end

    -- All Vision
    if OptionManager:GetOption('allVision') then
        Convars:SetBool('dota_all_vision', true)
    end

    if OptionManager:GetOption('banningTime') > 0 then
        -- Move onto banning mode
        currentStage = STAGE_BANNING

        -- Store when the banning phase ends
        endOfTimer = Time() + OptionManager:GetOption('banningTime')
    else
        -- Move onto selection mode
        currentStage = STAGE_PICKING

        -- Store when the banning phase ends
        endOfTimer = Time() + OptionManager:GetOption('pickingTime')
    end

    -- Load events?
    --[[if OptionManager:GetOption('loadSurvival') then
        -- Load her up
        survival.InitSurvival()
    end]]

    -- Setup allowed tabs
    GameRules.allowItemModifers = OptionManager:GetOption('allowItemModifers')

    -- Build ability string
    buildAllowedTabsString()

    -- Build the ability list
    buildSkillListLookup()

    if not OptionManager:GetOption('allowBearSkills') then
        validInterfaces[SKILL_LIST_BEAR] = nil
    end

    -- Setup player slot types
    setupSlotTypes()

    -- Update state
    GameRules.lod:OnEmitStateInfo()

    -- Print the options
    printOptionsToPlayer(-1)
end

-- Called when picking ends
postGamemodeSettings = function()
    -- All Random
    if OptionManager:GetOption('gamemode') == GAMEMODE_AR then
        -- Create random builds

        -- Loop over all players
        for i=0,9 do
            -- Ensure it exists
            skillList[i] = skillList[i] or {}

            -- Loop over all slots
            for interface,_ in pairs(validInterfaces) do
                for j=0,OptionManager:GetOption('maxSlots')-1 do
                    local msg, skillName = findRandomSkill(i, interface, j)

                    -- Did we find a valid skill?
                    if skillName then
                        -- Pick a random skill
                        skillList[i][interface][j+1] = skillName
                    end
                end
            end
        end
    end
end

-- Returns the current options encoded as a string
getOptionsString = function()
    local str = ''

    for k,v in pairs(voteData[OptionManager:GetOption('slaveID')] or {}) do
        str = str .. util:EncodeByte(k) .. util:EncodeByte(v)
    end

    return str
end

-- Shuffles a table
shuffle = function(t)
  local n = #t
  if n > 6 then n = 6 end

  while n >= 2 do
    -- n is now the last pertinent index
    local k = math.random(n) -- 1 <= k <= n
    -- Quick swap
    t[n], t[k] = t[k], t[n]
    n = n - 1
  end

  return t
end

optionToValue = function(optionNumber, choice)
    local option = votingList[tostring(optionNumber)]
    if option then
        if option.values and option.values[tostring(choice)] then
            return tonumber(option.values[tostring(choice)])
        end
    end

    return -1
end

valueToOption = function(optionNumber, value)
    local option = votingList[tostring(optionNumber)]
    if option then
        if option.values then
            for k,v in pairs(option.values) do
                if tonumber(value) == tonumber(v) then
                    return tonumber(k)
                end
            end
        end
    end

    return 0
end

-- This function tallys the votes, and sets the options
finishVote = function()
    -- Create container for all the votes
    local votes = {}
    for i=0,totalVotableOptions-1 do
        votes[i] = {}
    end

    -- Loop over all players
    for i=0,9 do
        -- Ensure this player is actually in
        if PlayerResource:IsValidPlayer(i) then
            -- Ensure they have vote data
            voteData[i] = voteData[i] or {}

            -- Loop over all options
            for j=0,totalVotableOptions-1 do
                -- Grab their vote
                local theirVote = voteData[i][j] or 0

                -- Did they even vote?
                if theirVote > 0 then
                    -- Increment the vote count by 1
                    votes[j][theirVote] = (votes[j][theirVote] or 0) + 1
                end
            end
        end
    end

    local winners = {}

    -- For now, the winner will be the choice with the most votes (if there is a draw, the one that comes first in Lua will win)
    for i=0,totalVotableOptions-1 do
        local high = 0
        local winner = 0

        for k,v in pairs(votes[i]) do
            if v > high then
                winner = k
                high = v
            end
        end

        -- Store the winner
        winners[i] = winner
    end

    -- Multipliers
    OptionManager:SetOption('customSpellPower', optionToValue(26, winners[26]))
    OptionManager:SetOption('customItemPower', optionToValue(27, winners[27]))

    -- Buffs
    OptionManager:SetOption('buffHeroes', optionToValue(32, winners[32]))
    OptionManager:SetOption('buffTowers', optionToValue(33, winners[33]))
    OptionManager:SetOption('buffBuildings', optionToValue(34, winners[34]))
    OptionManager:SetOption('buffCreeps', optionToValue(35, winners[35]))
    OptionManager:SetOption('buffNeutralCreeps', optionToValue(36, winners[36]))

    -- Set options
    OptionManager:SetOption('maxSlots', optionToValue(1, winners[1]))
    OptionManager:SetOption('maxSkills', optionToValue(2, winners[2]))
    OptionManager:SetOption('maxUlts', optionToValue(3, winners[3]))

    -- Balance mode
    --OptionManager:SetOption('balanceMode', optionToValue(11, winners[11]))

    -- Bans
    OptionManager:SetOption('hostBanning', false)
    OptionManager:SetOption('maxBans', optionToValue(4, winners[4]))
    if OptionManager:GetOption('maxBans') == 0 then
        -- No banning phase
        OptionManager:SetOption('banningTime', 0)
    end
    if OptionManager:GetOption('maxBans') == -1 then
        -- Host banning mode
        OptionManager:SetOption('hostBanning', true)
        OptionManager:SetOption('maxBans', 100)
        OptionManager:SetOption('maxHeroBans', 10)
    end

    -- Hide skills
    OptionManager:SetOption('hideSkills', optionToValue(8, winners[8]) == 1)

    -- Block troll combos
    OptionManager:SetOption('banTrollCombos', optionToValue(5, winners[5]) == 1)

    -- Grab the gamemode
    OptionManager:SetOption('gamemode', optionToValue(0, winners[0]))

    -- Grab the starting level
    OptionManager:SetOption('startingLevel', optionToValue(6, winners[6]))

    -- Grab bonus gold
    OptionManager:SetOption('bonusGold', optionToValue(9, winners[9]))

    -- Are we using easy mode?
    OptionManager:SetOption('useEasyMode', optionToValue(7, winners[7]) == 1)

    -- Are we using unique skills?
    OptionManager:SetOption('forceUniqueSkills', optionToValue(10, winners[10]))

    -- Uniqye heroes
    OptionManager:SetOption('uniqueHeroes', optionToValue(28, winners[28]) == 1)

    -- Free courier
    OptionManager:SetOption('freeCourier', optionToValue(40, winners[40]))

    -- Number of towers in each lane
    OptionManager:SetOption('middleTowers', optionToValue(29, winners[29]))

    -- Prevent fountain camping?
    OptionManager:SetOption('preventFountainCamping', optionToValue(37, winners[37]) == 1)

    -- Use level 1 ults?
    OptionManager:SetOption('useLevel1ults', optionToValue(38, winners[38]) == 1)

    -- Full price sellbacks?
    OptionManager:SetOption('fullPriceSellback', optionToValue(39, winners[39]) == 1)

    -- Allowed tabs
    allowedTabs.main = optionToValue(11, winners[11]) == 1
    allowedTabs.neutral = optionToValue(12, winners[12]) == 1
    allowedTabs.wraith = optionToValue(13, winners[13]) == 1
    allowedTabs.itemsActive = optionToValue(14, winners[14]) >= 1
    allowedTabs.itemsPassive = optionToValue(14, winners[14]) >= 2
    allowedTabs.OP = optionToValue(15, winners[15]) == 1

    -- Should we allocate item modifiers?
    OptionManager:SetOption('allowItemModifers', allowedTabs.itemsPassive)

    -- Custom bears / towers
    OptionManager:SetOption('allowBearSkills', optionToValue(16, winners[16]) == 1)
    OptionManager:SetOption('allowTowerSkills', optionToValue(17, winners[17]) == 1)
    OptionManager:SetOption('allowBuildingSkills', optionToValue(30, winners[30]) == 1)
    OptionManager:SetOption('allowCreepSkills', optionToValue(31, winners[31]) == 1)

    -- WTF Mode
    OptionManager:SetOption('wtfMode', optionToValue(18, winners[18]) == 1)

    -- Universal shop mode
    OptionManager:SetOption('universalShop', optionToValue(19, winners[19]) == 1)

    -- Fast jungle
    OptionManager:SetOption('fastJungleCreeps', optionToValue(20, winners[20]) == 1)

    -- All Vision
    OptionManager:SetOption('allVision', optionToValue(21, winners[21]) == 1)

    -- Spawn modifier option
    OptionManager:SetOption('respawnModifier', optionToValue(22, winners[22]))

    -- Scepter upgrade
    OptionManager:SetOption('freeScepter', optionToValue(23, winners[23]) == 1)

    -- Multicast madness
    OptionManager:SetOption('multicastMadness', optionToValue(24, winners[24]) == 1)

    -- Grab max level
    OptionManager:SetOption('maxHeroLevel', optionToValue(25, winners[25]))

    -- Enforce the max level
    if OptionManager:GetOption('startingLevel') > OptionManager:GetOption('maxHeroLevel') then
        OptionManager:SetOption('startingLevel', OptionManager:GetOption('maxHeroLevel'))
    end

    GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel(Constants.XP_PER_LEVEL_TABLE)
    GameRules:GetGameModeEntity():SetCustomHeroMaxLevel(OptionManager:GetOption('maxHeroLevel'))
    GameRules:GetGameModeEntity():SetUseCustomHeroLevels(true)

    -- Events
    --OptionManager:SetOption('loadSurvival', optionToValue(25, winners[25]) == 1)

    -- Add settings to our stat collector
    --[[statcollection.addStats({
        modes = {
            useLevel1ults = OptionManager:GetOption('useLevel1ults'),
            fullPriceSellback = OptionManager:GetOption('fullPriceSellback'),
            wtfMode = OptionManager:GetOption('wtfMode'),
            allVision = OptionManager:GetOption('allVision'),
            useEasyMode = OptionManager:GetOption('useEasyMode'),
            bonusGold = OptionManager:GetOption('bonusGold'),
            startingLevel = OptionManager:GetOption('startingLevel'),
            maxHeroLevel = OptionManager:GetOption('maxHeroLevel'),
            gamemode = OptionManager:GetOption('gamemode'),
            hideSkills = OptionManager:GetOption('hideSkills'),
            banTrollCombos = OptionManager:GetOption('banTrollCombos'),
            hostBanning = OptionManager:GetOption('hostBanning'),
            maxBans = OptionManager:GetOption('maxBans'),
            maxHeroBans = OptionManager:GetOption('maxHeroBans'),
            banningTime = OptionManager:GetOption('banningTime'),
            maxSlots = OptionManager:GetOption('maxSlots'),
            maxSkills = OptionManager:GetOption('maxSkills'),
            maxUlts = OptionManager:GetOption('maxUlts'),

            forceUniqueSkills = OptionManager:GetOption('forceUniqueSkills'),

            allowBearSkills = OptionManager:GetOption('allowBearSkills'),
            allowTowerSkills = OptionManager:GetOption('allowTowerSkills'),
            allowBuildingSkills = OptionManager:GetOption('allowBuildingSkills'),
            allowCreepSkills = OptionManager:GetOption('allowCreepSkills'),

            mainTab = allowedTabs.main,
            neutralTab = allowedTabs.neutral,
            wraithTab = allowedTabs.wraith,
            itemsActiveTab = allowedTabs.itemsActive,
            itemsPassiveTab = allowedTabs.itemsPassive,
            OPTab = allowedTabs.OP,
        }
    })]]

    -- Setup gamemode specific settings
    setupGamemodeSettings()
end

-- A fix for source1 backdoor protection
backdoorFix = function()
    local ents = Entities:FindAllByClassname('npc_dota_tower')

    -- List of towers to not protect
    local ignore = {
        dota_goodguys_tower1_bot = true,
        dota_goodguys_tower1_mid = true,
        dota_goodguys_tower1_top = true,
        dota_badguys_tower1_bot = true,
        dota_badguys_tower1_mid = true,
        dota_badguys_tower1_top = true
    }

    -- Loop over all ents
    for k,ent in pairs(ents) do
        local name = ent:GetName()
        local ab

        -- Check if this unit has backdoor protection
        if ent:HasAbility('backdoor_protection') then
            ab = ent:FindAbilityByName('backdoor_protection')
        elseif ent:HasAbility('backdoor_protection_in_base') then
            ab = ent:FindAbilityByName('backdoor_protection_in_base')
        end

        -- Should we protect it?
        if not ignore[name] then
            -- Stop towers going down in the wrong order
            ent:AddNewModifier(ent, nil, 'modifier_invulnerable', {})

            -- Prevent anal (backdooring)
            ent:AddNewModifier(ent, ab, 'modifier_'..ab:GetAbilityName(), {})
        else
            ent:RemoveModifierByName('modifier_backdoor_protection')
            ent:RemoveModifierByName('modifier_backdoor_protection_in_base')
        end
    end

    -- Protect rax
    ents = Entities:FindAllByClassname('npc_dota_barracks')
    for k,ent in pairs(ents) do
        -- Stop it going down before towers are removed
        ent:AddNewModifier(ent, nil, 'modifier_invulnerable', {})

        -- Prevent Anal (backdooring)
        ent:AddNewModifier(ent, ent:FindAbilityByName('backdoor_protection_in_base'), 'modifier_backdoor_protection_in_base', {})
    end

    -- Protect ancient
    ents = Entities:FindAllByClassname('npc_dota_fort')
    for k,ent in pairs(ents) do
        -- Stop the fort going down before the correct towers
        ent:AddNewModifier(ent, nil, 'modifier_invulnerable', {})

        -- Prevent backdooring
        ent:AddNewModifier(ent, ent:FindAbilityByName('backdoor_protection_in_base'), 'modifier_backdoor_protection_in_base', {})
    end
end

-- A function that returns true if the given skill is valid for bots
botSkillsOnly = function(skillName)
    -- We require a random passive
    if isPassive(skillName) then
        return true
    end

    if skillName == 'abaddon_borrowed_time' then
        return true
    end

    -- Not a valid skill
    return false
end

-- Gives a free courier
local givenFreeCouriers = {}
handleFreeCourier = function(hero)
    -- Free courier option
    local freeCourier = OptionManager:GetOption('freeCourier')
    if freeCourier ~= FREE_COURIER_NONE then
        local team = hero:GetTeam()
        if not givenFreeCouriers[team] then
            givenFreeCouriers[team] = true

            -- Give the item to the player
            local item = CreateItem('item_courier', hero, hero)
            if item then
                hero:AddItem(item)

                -- Make the player use the item
                GameRules:GetGameModeEntity():SetThink(function()
                    -- Ensure the unit is valid still
                    if IsValidEntity(hero) then
                        if IsValidEntity(item) then
                            -- Grab playerID
                            local playerID = hero:GetPlayerOwnerID()

                            -- Use the item
                            hero:CastAbilityImmediately(item, playerID)
                        end
                    end
                end, 'freeCourier'..DoUniqueString('freeCourier'), 1, nil)
            end

            if freeCourier == FREE_COURIER_FLYING then
                local flyingItem = CreateItem('item_flying_courier', hero, hero)
                if flyingItem then
                    hero:AddItem(flyingItem)
                end
            end
        end
    end
end

-- Gives a free scepter
handleFreeScepter = function(unit)
    -- Give free scepter
    if OptionManager:GetOption('freeScepter') then
        unit:AddNewModifier(unit, nil, 'modifier_item_ultimate_scepter', {
            bonus_all_stats = 0,
            bonus_health = 0,
            bonus_mana = 0
        })
    end
end

-- Buffs a hero
handleHeroBuffing = function(hero)
    -- Hero buffing
    if OptionManager:GetOption('buffHeroes') > 0 then
        local healthItem = getHealthBuffer()
        healthItem:ApplyDataDrivenModifier(hero, hero, "modifier_health_mod_"..OptionManager:GetOption('buffHeroes'), {})
    end
end

-- Gets the health buffing item
local healthBuffer
getHealthBuffer = function()
    if not IsValidEntity(healthBuffer) then
        healthBuffer = CreateItem("item_health_modifier", nil, nil)
    end

    return healthBuffer
end

-- Called when LoD starts
function lod:InitGameMode()
    print('\n\nLegends of dota started! (v'..getLodVersion()..')')
    GameRules:GetGameModeEntity():SetThink('OnThink', self, 'GlobalThink', 0.25)
    GameRules:GetGameModeEntity():SetThink('OnEmitStateInfo', self, 'EmitStateInfo', 5)

    -- Override source1 hooks
    SkillManager:overrideHooks()

    -- Set the selection time
    GameRules:SetHeroSelectionTime(60)
    --GameRules:SetSameHeroSelectionEnabled(false)    -- Default to off, we will turn it on if it is enabled in the options

    -- Setup standard rules

    GameRules:GetGameModeEntity():SetTowerBackdoorProtectionEnabled( true )
    --GameRules:GetGameModeEntity():SetBotThinkingEnabled( true )

    -- Precache orgre magi stuff
    PrecacheUnitByNameAsync('npc_precache_npc_dota_hero_ogre_magi', function()
        CreateUnitByName('npc_precache_npc_dota_hero_ogre_magi', Vector(-10000, -10000, 0), false, nil, nil, 0)
    end)

    -- Precache survival resources
    --[[PrecacheUnitByNameAsync('npc_precache_survival', function()
        CreateUnitByName('npc_precache_survival', Vector(-10000, -10000, 0), false, nil, nil, 0)
    end)]]

    -- Precache wraithnight stuff
    PrecacheUnitByNameAsync('npc_precache_wraithnight', function()
        CreateUnitByName('npc_precache_wraithnight', Vector(-10000, -10000, 0), false, nil, nil, 0)
    end)

    -- Precache the stuff that needs to always be precached
    PrecacheUnitByNameAsync('npc_precache_always', function()
        CreateUnitByName('npc_precache_always', Vector(-10000, -10000, 0), false, nil, nil, 0)
    end)

    -- Setup console commands
    registerConsoleCommands()

    -- Setup load helper
    --loadhelper.init()

    -- Load survival commands
    --survival.LoadCommands()

    -- Start listening to NPC spawns
    listenToNPCs()

    -- Ban meepo ulty, for now
    --banSkill('meepo_divided_we_stand')

    -- Setup phase stuff
    GameRules:SetCustomGameSetupTimeout(-1)
    GameRules:EnableCustomGameSetupAutoLaunch(false)

    print('Everything seems good!\n\n')
end

-- Emits state info every 5 seconds
function lod:OnEmitStateInfo()
    -- Build the state table
    local s = {
        -- Add the version
        ['v'] = getLodVersion(),

        -- Add the current stage
        ['s'] = currentStage,

        -- Add options
        ['o']           = getOptionsString(),
        ['spellMult']   = OptionManager:GetOption('customSpellPower'),
        ['itemMult']    = customItemPower,
        ['slots']       = OptionManager:GetOption('maxSlots'),
        ['skills']      = OptionManager:GetOption('maxSkills'),
        ['ults']        = OptionManager:GetOption('maxUlts'),
        ['trolls']      = (OptionManager:GetOption('banTrollCombos') and 1) or 0,
        ['hostBanning'] = (OptionManager:GetOption('hostBanning') and 1) or 0,
        ['hideSkills']  = (hideSkills and 1) or 0,
        ['source1']     = (GameRules:isSource1() and 1) or 0,
        --['balance']     = OptionManager:GetOption('balanceMode'),
        ['slaveID']     = OptionManager:GetOption('slaveID'),
        ['tabs']        = allowedTabsString,
        ['bans']        = OptionManager:GetOption('maxBans'),
        ['bear']        = (OptionManager:GetOption('allowBearSkills') and 1 or 0) + (OptionManager:GetOption('allowTowerSkills') and 2 or 0) + (OptionManager:GetOption('allowBuildingSkills') and 4 or 0) + (OptionManager:GetOption('allowCreepSkills') and 8 or 0),

        -- Store the end of the next timer
        ['t'] = endOfTimer,
    }

    -- Bear state
    local b = {}

    -- Loop over all players
    for i=0,9 do
        -- Grab their skill list
        local l = (skillList[i] or {})[SKILL_LIST_YOUR] or {}
        local lb = (skillList[i] or {})[SKILL_LIST_BEAR] or {}

        -- Calculate number to encode with
        local encode = 0
        if hideSkills then
            if PlayerResource:GetTeam(i) == DOTA_TEAM_BADGUYS then
                encode = encodeDire
            elseif PlayerResource:GetTeam(i) == DOTA_TEAM_GOODGUYS then
                encode = encodeRadiant
            end
        end

        -- Grab this player's slot
        local slot = getPlayerSlot(i)

        -- Store playerID --> Slot
        s[tostring(i)] = slot

        -- Loop over this player's skills
        for j=1,12 do
            -- Ensure the slot is filled
            s[tostring(i..j)] = s[tostring(i..j)] or -1
            b[tostring(i..j)] = b[tostring(i..j)] or -1

            if slot ~= -1 then
                -- Store the ID of this skill
                local sid = getSkillID(l[j])

                if sid == -1 then
                    s[tostring(slot..j)] = sid
                else
                    s[tostring(slot..j)] = sid+encode
                end

                -- Store for bear
                local sid = getSkillID(lb[j])

                if sid == -1 then
                    b[tostring(i..j)] = sid
                else
                    b[tostring(i..j)] = sid+encode
                end
            end
        end

        -- Store draft
        s['s'..i] = buildDraftString(i)

        -- Store locks
        s['l'..slot] = playerLocks[i] or 0

        -- Store slot into
        s['t'..i] = slotTypeString(i, SKILL_LIST_YOUR)
        b['t'..i] = slotTypeString(i, SKILL_LIST_BEAR)
    end

    local banned = {}
    for k,v in pairs(bannedSkills) do
        table.insert(banned, k)
    end

    -- Store bans
    local bns
    for k,v in pairs(banned) do
        if not bns then
            bns = getSkillID(banned[k])
        else
            bns = bns..'|'..getSkillID(banned[k])
        end
    end
    s['b'] = bns

    -- Send bear info
    if OptionManager:GetOption('allowBearSkills') then
        FireGameEvent('lod_state_bear', b)
    end

    -- Send tower info
    if OptionManager:GetOption('allowTowerSkills') then
        local t = {}

        for i=2,3 do
            t['t'..i] = slotTypeString(-i)

            -- Calculate number to encode with
            local encode = 0
            if hideSkills then
                if i == DOTA_TEAM_BADGUYS then
                    encode = encodeDire
                elseif i == DOTA_TEAM_GOODGUYS then
                    encode = encodeRadiant
                end
            end

            -- Grab tower skills
            local skillz = towerSkills[i] or {}

            for j=1,12 do
                -- Store the ID of this skill
                local sid = getSkillID(skillz[j])

                if sid == -1 then
                    t[tostring(i..j)] = sid
                else
                    t[tostring(i..j)] = sid+encode
                end
            end
        end

        -- Emit it
        FireGameEvent('lod_state_tower', t)
    end

    -- Send building info
    if OptionManager:GetOption('allowBuildingSkills') then
        local t = {}

        for i=2,3 do
            t['t'..i] = slotTypeString(-i)

            -- Calculate number to encode with
            local encode = 0
            if hideSkills then
                if i == DOTA_TEAM_BADGUYS then
                    encode = encodeDire
                elseif i == DOTA_TEAM_GOODGUYS then
                    encode = encodeRadiant
                end
            end

            -- Grab tower skills
            local skillz = buildingSkills[i] or {}

            for j=1,12 do
                -- Store the ID of this skill
                local sid = getSkillID(skillz[j])

                if sid == -1 then
                    t[tostring(i..j)] = sid
                else
                    t[tostring(i..j)] = sid+encode
                end
            end
        end

        -- Emit it
        FireGameEvent('lod_state_building', t)
    end

    -- Send creep info
    if OptionManager:GetOption('allowCreepSkills') then
        local t = {}

        for i=2,3 do
            t['t'..i] = slotTypeString(-i)

            -- Calculate number to encode with
            local encode = 0
            if hideSkills then
                if i == DOTA_TEAM_BADGUYS then
                    encode = encodeDire
                elseif i == DOTA_TEAM_GOODGUYS then
                    encode = encodeRadiant
                end
            end

            -- Grab tower skills
            local skillz = creepSkills[i] or {}

            for j=1,12 do
                -- Store the ID of this skill
                local sid = getSkillID(skillz[j])

                if sid == -1 then
                    t[tostring(i..j)] = sid
                else
                    t[tostring(i..j)] = sid+encode
                end
            end
        end

        -- Emit it
        FireGameEvent('lod_state_creep', t)
    end

    -- Send picking info to everyone
    FireGameEvent('lod_state', s)

    -- Run again after a delay
    return 5
end

-- Thinker function, run roughly once every second
local fixedBackdoor = false
local doneBotStuff = false
local patchedOptions = false
local shownHosterIssue = false
function lod:OnThink()
    -- Source1 fix to the backdoor issues
    if not fixedBackdoor and GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        -- Fix tower skills
        setTowerOwnership()

        -- Done with this thinker
        return
    end

    -- Decide what to do
    if currentStage == STAGE_WAITING then
        -- Wait for hero selection to start
        if GameRules:State_Get() >= DOTA_GAMERULES_STATE_HERO_SELECTION then
            -- Options patch
            if patchOptions then
                if not patchedOptions then
                    -- Only do it once
                    patchedOptions = true

                    -- No longer voting
                    stillVoting = false

                    -- Setup all the fancy gamemode stuff
                    setupGamemodeSettings()
                end
            else
                -- We must have a valid slaveID before we can do anything
                if OptionManager:GetOption('slaveID') == -1 then
                    OptionManager:SetOption('slaveID', 0)

                    --[[OptionManager:SetOption('slaveID', loadhelper.getHostID())

                    -- Is it still broken?
                    if OptionManager:GetOption('slaveID') == -1 then
                        if not shownHosterIssue then
                            shownHosterIssue = true
                            print('\n\nERROR: No host was found, either no players are on a team, no players have LoD installed, or something very bad.\nNo options screen will be shown until a valid host player is found!\n')

                            -- Sick of my servers getting screwed because of this, kill the server
                            SendToServerConsole('quit')
                        end

                        return 0.1
                    end]]
                end

                -- Move onto the voting stage
                currentStage = STAGE_VOTING

                -- Send the voting info
                self:OnEmitStateInfo()
            end

            -- Sleep until the voting time is over
            return 0.1
        end

        -- Run again in a moment
        return 0.1
    end

    if currentStage == STAGE_VOTING then
        -- Are we still voting?
        if stillVoting then
            PauseGame(true)
            return 0.1
        end

        -- Workout who won
        finishVote()

        -- Sleep
        return 0.1
    end

    if currentStage == STAGE_BANNING then
        -- Pause the game
        PauseGame(true)

        -- Wait for banning to end
        if Time() < endOfTimer then return 0.1 end

        -- Allow each team to get extra time again
        extraTime = {}

        -- Fix locks
        playerLocks = {}

         -- Tell everyone
        sendChatMessage(-1, '#lod_picking', {
            OptionManager:GetOption('pickingTime')
        })

         -- Change to picking state
        currentStage = STAGE_PICKING

        -- Store when the picking phase ends
        endOfTimer = Time() + OptionManager:GetOption('pickingTime')

        -- Update the state
        self:OnEmitStateInfo()

        -- Sleep
        return 0.1
    end

    if currentStage == STAGE_HERO_BANNING then
        -- Pause the game
        PauseGame(true)

        -- Wait for banning to end
        if Time() < endOfTimer then return 0.1 end

        -- Allow each team to get extra time again
        extraTime = {}

        -- Fix locks
        playerLocks = {}

        -- Change to picking state
        currentStage = STAGE_PICKING

        -- Store when the picking phase ends
        endOfTimer = Time() + OptionManager:GetOption('pickingTime')

        -- Update the state
        self:OnEmitStateInfo()

        -- Sleep
        return 0.1
    end

    if currentStage == STAGE_PICKING then
        -- Pause the game
        PauseGame(true)

        -- Wait for picking to end
        if Time() < endOfTimer and GameRules:State_Get() < DOTA_GAMERULES_STATE_PRE_GAME then return 0.1 end

        -- Validate all builds
        for i=0,9 do
            validateBuild(i)

            -- Precache the builds <3
            SkillManager:PrecacheBuild((skillList[i] or {})[SKILL_LIST_YOUR] or {})
        end

        -- Change to the playing stage
        currentStage = STAGE_PLAYING

        -- Post gamemode stuff
        postGamemodeSettings()

        -- Fix any broken heroes
        fixBuilds()

        -- Unpause the game
        PauseGame(false)

        -- Update the state
        self:OnEmitStateInfo()

        -- Add extra towers
        addExtraTowers()

        -- Apply the tower skills
        applyTowerSkills()

        -- Apply the building skills
        applyBuildingSkills()

        -- Prepare creep skills
        prepareCreepSkills()

        -- Upgrade towers
        upgradeTowers()

        -- Warn the players again
        if OptionManager:GetOption('maxSlots') > 6 then
            sendChatMessage(-1, '#lod_slotWarning')
        end

        -- Sleep
        return 0.1
    end

    -- Don't stop the timer!
    if currentStage == STAGE_PLAYING then
        if not lodHasStarted then
            --[[for i=0,9 do
                -- Grab their heronames
                local heroName = PlayerResource:GetSelectedHeroName(i)

                -- Check if we have a name
                if heroName and heroName ~= '' then
                    -- Precache this hero
                    SkillManager:PrecacheHero(heroName)
                end
            end]]

            -- Wait until hero selection ends
            if GameRules:State_Get() <= DOTA_GAMERULES_STATE_HERO_SELECTION then return 0.5 end
            lodHasStarted = true

            -- Ensure all player's have a hero
            for i=0,9 do
                local ply = PlayerResource:GetPlayer(i)

                if ply then
                    if PlayerResource:GetSelectedHeroID(i) == -1 then
                        ply:MakeRandomHeroSelection()
                    end
                end
            end

            -- Load up the special gamemode stuff
            loadSpecialGamemode()
        end

        return 0.1
    end

    -- We should never get here
    print('WARNING: Unknown stage: '..currentStage)
end

-- Sets ownership of tower
-- Doesn't appear to work :O
setTowerOwnership = function()
    -- Ensure tower skills are allowed
    if not OptionManager:GetOption('allowTowerSkills') then return end
    if 1 ==1 then return end -- disabled

    local towers = Entities:FindAllByClassname('npc_dota_tower')

    -- Loop over all ents
    for k,tower in pairs(towers) do
        local team = tower:GetTeam()

        -- Make it controllable by a player
        for i=0,9 do
            if PlayerResource:GetTeam(i) == team then
                tower:SetControllableByPlayer(i, true)
            else
                tower:SetControllableByPlayer(i, false)
            end
        end
    end
end

-- Upgrades towers
upgradeTowers = function()
    -- Grab the health buffer
    local buffer = getHealthBuffer()

    -- Should we buff towers?
    local buffTowers = OptionManager:GetOption('buffTowers')
    if buffTowers > 1 then
        local towers = Entities:FindAllByClassname('npc_dota_tower')
        -- Loop over all ents
        for k,tower in pairs(towers) do
            tower:SetBaseDamageMax(tower:GetBaseDamageMax() * buffTowers)
            tower:SetBaseDamageMin(tower:GetBaseDamageMin() * buffTowers)
            buffer:ApplyDataDrivenModifier(tower, tower, "modifier_other_health_mod_"..buffTowers, {})
        end

        local fountains = Entities:FindAllByClassname('ent_dota_fountain')
        -- Loop over all ents
        for k,fountain in pairs(fountains) do
            fountain:SetBaseDamageMax(fountain:GetBaseDamageMax() * buffTowers)
            fountain:SetBaseDamageMin(fountain:GetBaseDamageMin() * buffTowers)
        end
    end

    -- Should we buff buildings?
    local buffBuildings = OptionManager:GetOption('buffBuildings')
    if buffBuildings > 1 then
        local buildings = Entities:FindAllByClassname('npc_dota_building')
        -- Loop over all ents
        for k,building in pairs(buildings) do
            buffer:ApplyDataDrivenModifier(building, building, "modifier_other_health_mod_"..buffBuildings, {})
        end

        local racks = Entities:FindAllByClassname('npc_dota_barracks')
        -- Loop over all ents
        for k,rack in pairs(racks) do
            buffer:ApplyDataDrivenModifier(rack, rack, "modifier_other_health_mod_"..buffBuildings, {})
        end

        local forts = Entities:FindAllByClassname('npc_dota_fort')
        -- Loop over all ents
        for k,fort in pairs(forts) do
            buffer:ApplyDataDrivenModifier(fort, fort, "modifier_other_health_mod_"..buffBuildings, {})
        end
    end

    -- Should we prevent fountain camping?
    if OptionManager:GetOption('preventFountainCamping') then
        local toAdd = {
            [SkillManager:GetMultiplierSkillName('ursa_fury_swipes')] = 4,
            templar_assassin_psi_blades = 1
        }

        local fountains = Entities:FindAllByClassname('ent_dota_fountain')
        -- Loop over all ents
        for k,fountain in pairs(fountains) do
            for skillName,skillLevel in pairs(toAdd) do
                fountain:AddAbility(skillName)
                local ab = fountain:FindAbilityByName(skillName)
                if ab then
                    ab:SetLevel(skillLevel)
                end
            end

            local item = CreateItem('item_monkey_king_bar', fountain, fountain)
            if item then
                fountain:AddItem(item)
            end
        end
    end
end

-- Adds extra towers
addExtraTowers= function()
    -- Is there any work to do?
    if OptionManager:GetOption('middleTowers') > 1 then
        local lanes = {
            top = true,
            mid = true,
            bot = true
        }

        local teams = {
            good = DOTA_TEAM_GOODGUYS,
            bad = DOTA_TEAM_BADGUYS
        }

        local patchMap = {
            dota_goodguys_tower3_top = '1021_tower_radiant',
            dota_goodguys_tower3_mid = '1020_tower_radiant',
            dota_goodguys_tower3_bot = '1019_tower_radiant',

            dota_goodguys_tower2_top = '1026_tower_radiant',
            dota_goodguys_tower2_mid = '1024_tower_radiant',
            dota_goodguys_tower2_bot = '1022_tower_radiant',

            dota_goodguys_tower1_top = '1027_tower_radiant',
            dota_goodguys_tower1_mid = '1025_tower_radiant',
            dota_goodguys_tower1_bot = '1023_tower_radiant',

            dota_badguys_tower3_top = '1036_tower_dire',
            dota_badguys_tower3_mid = '1031_tower_dire',
            dota_badguys_tower3_bot = '1030_tower_dire',

            dota_badguys_tower2_top = '1035_tower_dire',
            dota_badguys_tower2_mid = '1032_tower_dire',
            dota_badguys_tower2_bot = '1029_tower_dire',

            dota_badguys_tower1_top = '1034_tower_dire',
            dota_badguys_tower1_mid = '1033_tower_dire',
            dota_badguys_tower1_bot = '1028_tower_dire',
        }

        for team,teamNumber in pairs(teams) do
            for lane,__ in pairs(lanes) do
                local threeRaw = 'dota_'..team..'guys_tower3_'..lane
                local three = Entities:FindByName(nil, threeRaw) or Entities:FindByName(nil, patchMap[threeRaw] or '_unknown_')

                local twoRaw = 'dota_'..team..'guys_tower2_'..lane
                local two = Entities:FindByName(nil, twoRaw) or Entities:FindByName(nil, patchMap[twoRaw] or '_unknown_')

                local oneRaw = 'dota_'..team..'guys_tower1_'..lane
                local one = Entities:FindByName(nil, oneRaw) or Entities:FindByName(nil, patchMap[oneRaw] or '_unknown_')

                -- Unit name
                local unitName = 'npc_dota_'..team..'guys_tower_lod_'..lane

                if one and two and three then
                    -- Proceed to patch the towers
                    local onePos = one:GetOrigin()
                    local threePos = three:GetOrigin()

                    -- Workout the difference in the positions
                    local dif = threePos - onePos
                    local sep = dif / (OptionManager:GetOption('middleTowers') + 1)

                    -- Remove the middle tower
                    UTIL_Remove(two)

                    -- Used to connect towers
                    local prevTower = three

                    for i=1,OptionManager:GetOption('middleTowers') do
                        local newPos = threePos - (sep * i)

                        local newTower = CreateUnitByName(unitName, newPos, false, nil, nil, teamNumber)

                        if newTower then
                            -- Make it unkillable
                            newTower:AddNewModifier(ent, nil, 'modifier_invulnerable', {})

                            -- Store connection
                            towerConnectors[newTower] = prevTower
                            prevTower = newTower
                        else
                            print('Failed to create tower #'..i..' in lane '..lane)
                        end
                    end

                    -- Store initial connection
                    towerConnectors[one] = prevTower
                else
                    -- Failure
                    print('Failed to patch towers!')
                end
            end
        end
    end
end

-- Applies tower skills if they are allowed
applyTowerSkills = function()
    -- Ensure tower skills are allowed
    if not OptionManager:GetOption('allowTowerSkills') then return end

    -- Ensure there isn't one sided tower skills
    if not towerSkills[DOTA_TEAM_BADGUYS] then
        if towerSkills[DOTA_TEAM_GOODGUYS] then
            towerSkills[DOTA_TEAM_BADGUYS] = {}
            for k,v in pairs(towerSkills[DOTA_TEAM_GOODGUYS]) do
                towerSkills[DOTA_TEAM_BADGUYS][k] = v
            end
        end
    end

    if not towerSkills[DOTA_TEAM_GOODGUYS] then
        if towerSkills[DOTA_TEAM_BADGUYS] then
            towerSkills[DOTA_TEAM_GOODGUYS] = {}
            for k,v in pairs(towerSkills[DOTA_TEAM_BADGUYS]) do
                towerSkills[DOTA_TEAM_GOODGUYS][k] = v
            end
        end
    end

    local towers = Entities:FindAllByClassname('npc_dota_tower')

    -- Loop over all ents
    for k,tower in pairs(towers) do
        local team = tower:GetTeam()

        local skillz = towerSkills[team]
        if skillz then
            SkillManager:ApplyBuild(tower, skillz)
        end
    end

    -- Set the ownership
    setTowerOwnership()

    -- Upgrade towers


    -- Log that this was successful
    print('Done allocating tower skills!')
end

-- Applies building skills if they are allowed
applyBuildingSkills = function()
    -- Ensure building skills are allowed
    if not OptionManager:GetOption('allowBuildingSkills') then return end

    -- Ensure there isn't one sided building skills
    if not buildingSkills[DOTA_TEAM_BADGUYS] then
        if buildingSkills[DOTA_TEAM_GOODGUYS] then
            buildingSkills[DOTA_TEAM_BADGUYS] = {}
            for k,v in pairs(buildingSkills[DOTA_TEAM_GOODGUYS]) do
                buildingSkills[DOTA_TEAM_BADGUYS][k] = v
            end
        end
    end

    if not buildingSkills[DOTA_TEAM_GOODGUYS] then
        if buildingSkills[DOTA_TEAM_BADGUYS] then
            buildingSkills[DOTA_TEAM_GOODGUYS] = {}
            for k,v in pairs(buildingSkills[DOTA_TEAM_BADGUYS]) do
                buildingSkills[DOTA_TEAM_GOODGUYS][k] = v
            end
        end
    end

    -- List of ents to apply building skills to
    local toApplyTo = {
        'npc_dota_barracks',
        'npc_dota_building',
        'npc_dota_fort'
    }

    -- Apply building skills to the buildings in question
    for _,buildingType in pairs(toApplyTo) do
        local buildings = Entities:FindAllByClassname(buildingType)

        -- Loop over all ents
        for k,building in pairs(buildings) do
            local team = building:GetTeam()

            local skillz = buildingSkills[team]
            if skillz then
                SkillManager:ApplyBuild(building, skillz)
            end
        end
    end

    -- Log that this was successful
    print('Done allocating building skills!')
end

-- Prepares creep skills
prepareCreepSkills = function()
    -- Ensure there isn't one sided building skills
    if not creepSkills[DOTA_TEAM_BADGUYS] then
        if creepSkills[DOTA_TEAM_GOODGUYS] then
            creepSkills[DOTA_TEAM_BADGUYS] = {}
            for k,v in pairs(creepSkills[DOTA_TEAM_GOODGUYS]) do
                creepSkills[DOTA_TEAM_BADGUYS][k] = v
            end
        end
    end

    if not creepSkills[DOTA_TEAM_GOODGUYS] then
        if creepSkills[DOTA_TEAM_BADGUYS] then
            creepSkills[DOTA_TEAM_GOODGUYS] = {}
            for k,v in pairs(creepSkills[DOTA_TEAM_BADGUYS]) do
                creepSkills[DOTA_TEAM_GOODGUYS][k] = v
            end
        end
    end
end

-- Applies skills onto the given creep
applyCreepSkills = function(creep)
    -- Ensure building skills are allowed
    if not OptionManager:GetOption('allowCreepSkills') then return end

    local team = creep:GetTeam()
    local skillz = creepSkills[team]
    if skillz then
        SkillManager:ApplyBuild(creep, skillz, true)
    end
end

-- When a hero spawns
local specialAddedSkills = {}
local mainHeros = {}
local givenBonuses = {}
local doneBots = {}
local resetGold = {}
local spiritBears = {}
function listenToNPCs()
    ListenToGameEvent('npc_spawned', function(keys)
        -- Grab the unit that spawned
        local spawnedUnit = EntIndexToHScript(keys.entindex)

        -- Ensure it's a valid unit
        if IsValidEntity(spawnedUnit) then
            -- Make sure it is a hero
            if spawnedUnit:IsHero() then
                -- Grab their playerID
                local playerID = spawnedUnit:GetPlayerID()

                -- Handle hero buffing
                handleHeroBuffing(spawnedUnit)

                -- Don't touch this hero more than once :O
                if handled[spawnedUnit] then return end
                handled[spawnedUnit] = true

                -- Handle the free courier stuff
                --handleFreeCourier(spawnedUnit)

                -- Handle free scepter stuff
                handleFreeScepter(spawnedUnit)

                -- Fix gold bug
                if PlayerResource:HasRepicked(playerID) and not resetGold[playerID] then
                    resetGold[playerID] = true
                    PlayerResource:SetGold(playerID, 525, false)
                end

                -- Only give bonuses once
                if not givenBonuses[playerID] then
                    -- We have given bonuses
                    givenBonuses[playerID] = true

                    local startingLevel = OptionManager:GetOption('startingLevel')
                    -- Do we need to level up?
                    if startingLevel > 1 then
                        -- Level it up
                        --for i=1,startingLevel-1 do
                        --    spawnedUnit:HeroLevelUp(false)
                        --end

                        -- Fix EXP
                        spawnedUnit:AddExperience(Constants.XP_PER_LEVEL_TABLE[startingLevel], false, false)
                    end

                    -- Any bonus gold?
                    if OptionManager:GetOption('bonusGold') > 0 then
                        PlayerResource:SetGold(playerID, OptionManager:GetOption('bonusGold'), true)
                    end
                end

                -- Give bots skills differently
                if PlayerResource:IsFakeClient(playerID) then
                    if not doneBots[playerID] then
                        doneBots[playerID] = true
                        skillList[playerID] = nil
                    end

                    -- Generate skill list if not already have one
                    if skillList[playerID] == nil then
                        -- Store the bots skills
                        local tmpSkills = SkillManager:GetHeroSkills(spawnedUnit:GetClassname()) or {}
                        skillList[playerID] = {}

                        for interface,_ in pairs(validInterfaces) do
                            skillList[playerID][interface] = {}
                        end

                        -- Filter the skills
                        for k,v in pairs(tmpSkills) do
                            if not CheckBans(skillList[playerID][SKILL_LIST_YOUR], #skillList[playerID][SKILL_LIST_YOUR]+1, v, playerID) then
                                table.insert(skillList[playerID][SKILL_LIST_YOUR], v)
                            end
                        end

                        -- Grab how many skills to add
                        local addSkills = OptionManager:GetOption('maxSlots') - 4 + (#tmpSkills - #skillList[playerID][SKILL_LIST_YOUR])

                        -- Do we need to add any skills?
                        if addSkills <= 0 then return end

                        -- Add the skills
                        for interface,_ in pairs(validInterfaces) do
                            for i=1,addSkills do
                                local msg, skillName = findRandomSkill(playerID, interface, i, botSkillsOnly)

                                -- Failed to find a new skill
                                if skillName == nil then break end

                                table.insert(skillList[playerID][SKILL_LIST_YOUR], skillName)
                            end
                        end

                        -- Sort it randomly
                        --skillList[playerID][SKILL_LIST_YOUR] = shuffle(skillList[playerID][SKILL_LIST_YOUR])

                        -- Store that we added skills
                        specialAddedSkills[playerID] = {}
                        for k,v in pairs(skillList[playerID][SKILL_LIST_YOUR]) do
                            local found = false
                            for kk,vv in pairs(tmpSkills) do
                                if vv == v then
                                    found = true
                                    break
                                end
                            end

                            if not found then
                                specialAddedSkills[playerID][SkillManager:GetMultiplierSkillName(v)] = true
                            end
                        end
                    end

                    print('APPLY!')
                    SkillManager:ApplyBuild(spawnedUnit, skillList[playerID][SKILL_LIST_YOUR])

                    return
                end

                -- Check if the game has started yet
                if currentStage > STAGE_PICKING then
                    -- Validate the build
                    validateBuild(playerID)

                    -- Grab their build
                    local build = (skillList[playerID] or {})[SKILL_LIST_YOUR] or {}

                    -- Apply the build
                    SkillManager:ApplyBuild(spawnedUnit, build)

                    -- Store playerID has handled
                    handledPlayerIDs[playerID] = true
                else
                    -- Store that this hero needs fixing
                    brokenHeroes[spawnedUnit] = true

                    -- Remove their skills
                    SkillManager:RemoveAllSkills(spawnedUnit)
                end
            end

            -- Check if we should apply custom bear skills
            if OptionManager:GetOption('allowBearSkills') and spawnedUnit:GetClassname() == 'npc_dota_lone_druid_bear' then
                -- Kill server if no one is on it anymore
                GameRules:GetGameModeEntity():SetThink(function()
                    -- Ensure the unit is valid still
                    if IsValidEntity(spawnedUnit) then
                        -- Grab playerID
                        local playerID = spawnedUnit:GetPlayerOwnerID()

                        -- Store the bear
                        spiritBears[playerID] = spawnedUnit

                        -- Grab the skill list
                        local skillz = (skillList[playerID] or {})[SKILL_LIST_BEAR]
                        if skillz then
                            -- Change levels if already allocated skillz
                            if not handled[spawnedUnit] then
                                -- We are now handled
                                handled[spawnedUnit] = true

                                -- Apply the build
                                SkillManager:ApplyBuild(spawnedUnit, skillz)
                            end

                            -- Grab their hero
                            local hero = PlayerResource:GetSelectedHeroEntity(playerID)

                            if hero then
                                -- Level skills based on hero
                                levelSpiritSkills(spawnedUnit, skillz, hero:GetLevel())
                            end
                        end
                    end
                end, 'spiritBear'..DoUniqueString('spiritBear'), 0.1, nil)
            end

            -- Creep buffing
            local unitName = spawnedUnit:GetUnitName()
            if string.find(unitName, 'creep') or string.find(unitName, 'neutral') or string.find(unitName, 'siege') or string.find(unitName, 'roshan') then
                if spawnedUnit:GetTeamNumber() == DOTA_TEAM_NEUTRALS then
                    -- Neutral Creep
                    local buffNeutralCreeps = OptionManager:GetOption('buffNeutralCreeps')
                    if buffNeutralCreeps > 1 then
                        local buffer = getHealthBuffer()
                        spawnedUnit:SetBaseDamageMin(spawnedUnit:GetBaseDamageMin() * buffNeutralCreeps)
                        spawnedUnit:SetBaseDamageMax(spawnedUnit:GetBaseDamageMax() * buffNeutralCreeps)
                        buffer:ApplyDataDrivenModifier(spawnedUnit, spawnedUnit, "modifier_other_health_mod_"..buffNeutralCreeps, {})
                    end
                else
                    -- Lane Creep
                    local buffCreeps = OptionManager:GetOption('buffCreeps')
                    if buffCreeps > 1 then
                        local buffer = getHealthBuffer()
                        spawnedUnit:SetBaseDamageMin(spawnedUnit:GetBaseDamageMin() * buffCreeps)
                        spawnedUnit:SetBaseDamageMax(spawnedUnit:GetBaseDamageMax() * buffCreeps)
                        buffer:ApplyDataDrivenModifier(spawnedUnit, spawnedUnit, "modifier_other_health_mod_"..buffCreeps, {})
                    end
                end

                -- Apply creep skills
                applyCreepSkills(spawnedUnit)
            end
        end
    end, nil)
end

--[[ListenToGameEvent('modifier_event', function(keys)
    for k,v in pairs(keys) do
        print(k)
        print(v)
    end
end, nil)
ListenToGameEvent('dota_ability_changed', function(keys)
    print('hmmm')
end, nil)
ListenToGameEvent('dota_non_player_used_ability', function(keys)
    print('hmmm 2')
end, nil)]]

ListenToGameEvent('entity_hurt', function(keys)
    -- Grab the entity that was hurt
    local ent = EntIndexToHScript(keys.entindex_killed)

    -- Check for tower connections
    if ent:GetHealth() <= 0 and towerConnectors[ent] then
        local tower = towerConnectors[ent]
        towerConnectors[ent] = nil

        if IsValidEntity(tower) then
            -- Make it killable!
            tower:RemoveModifierByName('modifier_invulnerable')
        end
    end
end, nil)

ListenToGameEvent('entity_killed', function(keys)
    -- Ensure our respawn modifier is in effect
    local respawnModifier = OptionManager:GetOption('respawnModifier')
    if respawnModifier == 0 then return end

    -- Grab the killed entitiy (it isn't nessessarily a hero!)
    local hero = EntIndexToHScript(keys.entindex_killed)

    -- Ensure it is a hero
    if IsValidEntity(hero) then
        if hero:IsHero() then
            if hero:WillReincarnate() then return end
            if hero:IsReincarnating() then return end

            local timeLeft = hero:GetRespawnTime()

            if respawnModifier < 0 then
                timeLeft = -respawnModifier
            else
                timeLeft = timeLeft * respawnModifier
            end

            Timers:CreateTimer(function()
                if IsValidEntity(hero) and not hero:IsAlive() then
                    hero:SetTimeUntilRespawn(timeLeft)
                end
            end, DoUniqueString('respawn'), 0.1)
        end
    end
end, nil)

-- Levels up a player's bear skills
levelSpiritSkills = function(spiritBear, skillz, playerLevel)
    for i=1,OptionManager:GetOption('maxSlots') do
        local skillName = skillz[i]

        -- Ensure the bear has it
        if skillName and spiritBear:HasAbility(skillName) then
            local skill = spiritBear:FindAbilityByName(skillName)
            if skill then
                -- Workout the level of the skill
                local requiredLevel = 0
                if isUlt(skillName) then
                    if playerLevel >= 16 then
                        requiredLevel = 3
                    elseif playerLevel >= 11 then
                        requiredLevel = 2
                    elseif playerLevel >= 6 then
                        requiredLevel = 1
                    end
                else
                    if playerLevel >= 16 then
                        requiredLevel = 4
                    elseif playerLevel >= 12 then
                        requiredLevel = 3
                    elseif playerLevel >= 8 then
                        requiredLevel = 2
                    elseif playerLevel >= 4 then
                        requiredLevel = 1
                    end
                end

                if requiredLevel > skill:GetMaxLevel() then
                    requiredLevel = skill:GetMaxLevel()
                end

                if skill:GetLevel() < requiredLevel then
                    -- Level the skill
                    skill:SetLevel(requiredLevel)
                end
            end
        end
    end
end

-- Auto level bot skills <3
local botUsedPoints = {}
ListenToGameEvent('dota_player_gained_level', function(keys)
    -- Check every player
    for playerID = 0,9 do
        -- Grab their hero
        local hero = PlayerResource:GetSelectedHeroEntity(playerID)

        if hero then
            -- Grab our level
            local level = hero:GetLevel()

            -- Check for spirit bears
            local sb = spiritBears[playerID]
            if sb and IsValidEntity(sb) then
                -- Grab the skill list
                local skillz = (skillList[playerID] or {})[SKILL_LIST_BEAR]
                if skillz then
                    levelSpiritSkills(sb, skillz, level)
                end
            end

            -- Ensure there is something to check
            local toCheck = specialAddedSkills[playerID]
            if toCheck ~= nil then
                -- Point checker
                botUsedPoints[playerID] = botUsedPoints[playerID] or 0

                for skillName,v in pairs(toCheck) do
                    -- Grab a reference to teh skill
                    local skill = hero:FindAbilityByName(skillName)

                    if skill then
                        local retries = 20
                        while retries > 0 and skill:GetHeroLevelRequiredToUpgrade() <= level and level-botUsedPoints[playerID] > 0 do
                            retries = retries - 1

                            local newLevel = skill:GetLevel() + 1
                            if newLevel <= skill:GetMaxLevel() then
                                -- Level the skill
                                skill:SetLevel(newLevel)

                                -- Bot has used a point
                                botUsedPoints[playerID] = botUsedPoints[playerID] + 1
                            else
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end, nil)

-- Returns how many more people need to lock their skills
local function countLocks()
    local locksLeft = 0
    for i=0,9 do
        if PlayerResource:GetConnectionState(i) == 2 then
            if playerLocks[i] ~= 1 then
                locksLeft = locksLeft + 1
            end
        end
    end

    return locksLeft
end

-- Tells players about a given player's current lock status
fireLockChange = function(playerID)
    FireGameEvent('lod_lock', {
        slot = getPlayerSlot(playerID),
        lock = playerLocks[playerID] or 0
    })
end

-- Do a lock for the given player
doLock = function(playerID)
    -- Is it valid to use this?
    if currentStage ~= STAGE_BANNING and currentStage ~= STAGE_PICKING and currentStage ~= STAGE_HERO_BANNING then return end

    local first = true
    if playerLocks[playerID] == 1 then
        first = false
    end

    -- Can only unlock during the picking phase
    if currentStage ~= STAGE_PICKING then
        first = true
    end

    -- Store our lock as taken
    playerLocks[playerID] = 1

    -- Check if every other player in the game has locked their skills
    local locksLeft = countLocks()

    -- Ensure only one lock / player
    if not first then
        if locksLeft == 0 then
            -- All locks are in place, move on!
            endOfTimer = Time()
            sendChatMessage(playerID, '#lod_all_locked')
        else
            playerLocks[playerID] = nil
            sendChatMessage(playerID, '#lod_skilled_unlocked', {
                locksLeft
            })
        end
        fireLockChange(playerID)
        return
    end

    if locksLeft == 0 then
        -- All locks are in place, move on!
        endOfTimer = Time()
        sendChatMessage(playerID, '#lod_all_locked')
    else
        -- Tell them how long left
        sendChatMessage(playerID, '#lod_locks_left', {
            locksLeft
        })
    end
    fireLockChange(playerID)
end

-- Register server hax
registerServerCommands = function()
    Convars:RegisterCommand('lod_applybuild', function(name, target, source)
        -- Server only command!
        if not Convars:GetCommandClient() then
            local target = tonumber(target)
            local source = tonumber(source)
            if target == nil or source == nil then
                print('Command usage: '..name..' targetID sourceID')
                return
            end

            if target < 0 or target > 9 then
                print('Valid targetIDs are [0,9]')
                return
            end

            if source < 0 or source > 9 then
                print('Valid sourceIDs are [0,9]')
                return
            end

            local sourceBuild = (skillList[source] or {})[SKILL_LIST_YOUR]
            if not sourceBuild then
                print('Failed to find a build with ID '..source)
                return
            end

            -- Apply the build
            SkillManager:ApplyBuild(PlayerResource:GetSelectedHeroEntity(target), sourceBuild)
        end
    end, '', SERVER_COMMAND)

    -- Prints all builds
    Convars:RegisterCommand('lod_printbuilds', function(name)
        -- Server only command!
        if not Convars:GetCommandClient() then
            for i=0,9 do
                local b = (skillList[i] or {})[SKILL_LIST_YOUR]
                if b then
                    local txt
                    for j=1,16 do
                        local s = b[j]
                        if s then
                            if txt then
                                txt = txt..','..s
                            else
                                txt = s
                            end
                        end
                    end

                    txt = txt or ''

                    if b.hero then
                        txt = b.hero..' '..txt
                    end

                    print(i..': '..txt)
                end
            end
        end
    end, '', SERVER_COMMAND)

    -- Edits a skill in a build
    Convars:RegisterCommand('lod_editskill', function(name, playerID, skillSlot, skillName)
        -- Server only command!
        if not Convars:GetCommandClient() then
            local playerID = tonumber(playerID)
            local skillSlot = tonumber(skillSlot)
            if playerID == nil or skillSlot == nil or skillName == nil then
                print('Command usage: '..name..' playerID skillSlot skillName')
                return
            end

            if playerID < 0 or playerID > 9 then
                print('Valid playerIDs are [0,9]')
                return
            end

            if skillSlot < 1 or skillSlot > OptionManager:GetOption('maxSlots') then
                print('Valids slots are 1 - '..OptionManager:GetOption('maxSlots'))
                return
            end

            if not isValidSkill(skillName) then
                print(skillName..' is not a valid skill.')
                return
            end

            skillList[playerID] = skillList[playerID] or {}
            skillList[playerID][SKILL_LIST_YOUR] = skillList[playerID][SKILL_LIST_YOUR] or {}
            skillList[playerID][SKILL_LIST_YOUR][skillSlot] = skillName
        end
    end, '', SERVER_COMMAND)

    -- Allows you to set the host
    Convars:RegisterCommand('lod_sethost', function(name, newHostID)
        -- Only server can run this
        if not Convars:GetCommandClient() then
            -- Input validation
            if newHostID == nil then
                print('Command usage: '..name..' newHostID')
                return
            end

            newHostID = tonumber(newHostID)
            if newHostID == nil then
                print('Command usage: '..name..' newHostID')
                return
            end

            -- Ensure we are at the correct stage
            if currentStage ~= STAGE_WAITING then
                print('You can only change the host during the waiting period.')
                return
            end

            -- Store and report
            OptionManager:SetOption('slaveID', newHostID)
            print('Host was set to playerID '..newHostID)
        end
    end, 'Host stealer', SERVER_COMMAND)

    -- Prints out playerIDS
    Convars:RegisterCommand('lod_ids', function(name, newHostID)
        -- Only server can run this
        if not Convars:GetCommandClient() then
            for i=0,9 do
                print(i..': '..PlayerResource:GetSteamAccountID(i)..' - '..util:GetPlayerNameReliable(i))
            end
        end
    end, 'Host stealer', SERVER_COMMAND)

    -- Turn cycling skills on
    Convars:RegisterCommand('lod_cycle', function(name, newHostID)
        -- Only server can run this
        if not Convars:GetCommandClient() then
            if lodHasStarted then
                print('It is too late to use this.')
                return
            end

            -- Turn it on
            OptionManager:SetOption('cyclingBuilds', true)
            print('Cycling builds was enabled.')
        end
    end, 'Turn cycling skills on', SERVER_COMMAND)

    print('LoD server commands loaded!')
end

-- Registers hero banning
registerHeroBanning = function()
    -- Source1 hero banning
    --[[if GameRules:isSource1() and OptionManager:GetOption('enableHeroBanning') then
        Convars:RegisterCommand('dota_select_hero', function(name, heroName)
            local cmdPlayer = Convars:GetCommandClient()
            if cmdPlayer then
                local playerID = cmdPlayer:GetPlayerID()

                -- Random hero
                if heroName == 'random' then
                    -- Attempt to random
                    heroName = getRandomHeroName()

                    -- Did we fail?
                    if heroName == 'random' then
                        sendChatMessage(playerID, '#lod_cant_random_hero')
                        return
                    end
                end

                -- Validate hero name
                if not isValidHeroName(heroName) then
                    sendChatMessage(playerID, '#lod_invalid_hero', {
                        heroName
                    })
                    return
                end

                -- Are we in voting?
                if currentStage ~= STAGE_HERO_BANNING and currentStage < STAGE_PLAYING then
                    sendChatMessage(playerID, '#lod_hero_bannning_invalid')
                    return
                end

                -- Are we in the banning stage?
                if currentStage == STAGE_HERO_BANNING then
                    -- Host banning mode?
                    if OptionManager:GetOption('hostBanning') and playerID ~= 0 then
                        sendChatMessage(playerID, '#lod_wait_host_ban')
                        return
                    end

                    -- Already banned?
                    if bannedHeroes[heroName] then
                        sendChatMessage(playerID, '#lod_hero_already_banned', {
                            '#'..heroName
                        })
                        return
                    end

                    -- Ensure they have a value to compare against
                    hasBanned[playerID] = hasBanned[playerID] or 0

                    -- Have they hit their banning limit?
                    if hasBanned[playerID] >= OptionManager:GetOption('maxHeroBans') then
                        sendChatMessage(playerID, '#lod_hero_ban_limit')
                        return
                    end

                    -- Warn them about the ban first
                    if banChance[playerID] ~= heroName then
                        -- Store the chance
                        banChance[playerID] = heroName

                        -- Tell them about it
                        sendChatMessage(playerID, '#lod_confirm_hero_ban', {
                            '#'..heroName
                        })
                        return
                    end

                    -- Ok, ban this hero
                    bannedHeroes[heroName] = true
                    hasBanned[playerID] = hasBanned[playerID]+1

                    -- Do locks
                    if hasBanned[playerID] >= OptionManager:GetOption('maxHeroBans') then
                        doLock(playerID)
                    end

                    -- Tell everyone
                    sendChatMessage(-1, '#lod_hero_banned', {
                        '#'..heroName,
                        hasBanned[playerID],
                        OptionManager:GetOption('maxHeroBans')
                    })
                    return
                end

                -- Should we force a random hero name?
                if OptionManager:GetOption('forceRandomHero') then
                    -- Grab a random hero name
                    heroName = getRandomHeroName()

                    -- Make sure it worked
                    if heroName == 'random' then
                        sendChatMessage(playerID, '#lod_cant_random_hero')
                        return
                    end
                end

                -- Check bans
                if bannedHeroes[heroName] then
                    sendChatMessage(playerID, '#lod_hero_is_banned', {
                        '#'..heroName
                    })
                    return
                end

                -- Stop multiple picks
                if hasHero[playerID] then return end
                hasHero[playerID] = true

                -- Attempt to create them their hero
                if GameRules:isSource1() then
                    CreateHeroForPlayer(heroName, cmdPlayer)
                else
                    PrecacheUnitByNameAsync(heroName, function()
                        CreateHeroForPlayer(heroName, cmdPlayer)
                    end)
                end
            end
        end, 'hero selection override', CLIENT_COMMAND)
    end]]
end

-- Register fancy functions
registerFancyConsoleCommands = function()
    -- Swap two slots
    Convars:RegisterCommand('lod_swap_slots', function(name, theirInterface, slot1, slot2)
        -- Input validation
        theirInterface = tonumber(theirInterface)
        slot1 = tonumber(slot1)
        slot2 = tonumber(slot2)
        if theirInterface == nil then return end
        if slot1 == nil then return end
        if slot2 == nil then return end

        -- Grab the player
        local cmdPlayer = Convars:GetCommandClient()
        if cmdPlayer then
            local playerID = cmdPlayer:GetPlayerID()
            local team = PlayerResource:GetTeam(playerID)

            -- Ensure a valid team
            if not isPlayerOnValidTeam(playerID) then
                sendChatMessage(playerID, '#lod_invalid_team')
                return
            end

            -- Stop people who have spawned from picking
            if handledPlayerIDs[playerID] then
                sendChatMessage(playerID, '#lod_already_spawned')
                return
            end

            -- Ensure we are in banning mode
            if currentStage ~= STAGE_PICKING then
                sendChatMessage(playerID, '#lod_only_during_pick')
                return
            end

            -- Ensure we are ALLOWED to pick
            if not OptionManager:GetOption('allowedToPick') then
                sendChatMessage(playerID, '#lod_not_allowed_pick')
                return
            end

            -- Ensure this is a valid slot
            if not isValidSlot(slot1) or not isValidSlot(slot2) then
                sendChatMessage(playerID, '#lod_invalid_slot')
                return
            end

            -- Ensure different slots
            if slot1 == slot2 then
                sendChatMessage(playerID, '#lod_swap_slot_self')
                return
            end

            -- Check interfaces
            if not validInterfaces[theirInterface] and theirInterface ~= SKILL_LIST_TOWER and theirInterface ~= SKILL_LIST_BUILDING and theirInterface ~= SKILL_LIST_CREEP then
                sendChatMessage(playerID, '#lod_invalid_interface')
                return
            end

            -- Ensure this player has a skill list
            if theirInterface < SKILL_LIST_TOWER then
                skillList[playerID] = skillList[playerID] or {}
                skillList[playerID][theirInterface] = skillList[playerID][theirInterface] or {}
                setupSlotType(playerID)

                -- Copy skill over
                local tmpSkill = skillList[playerID][theirInterface][slot1+1]
                skillList[playerID][theirInterface][slot1+1] = skillList[playerID][theirInterface][slot2+1]
                skillList[playerID][theirInterface][slot2+1] = tmpSkill

                -- Swap slot types
                local tmpSlot = slotTypes[playerID][theirInterface][slot1]
                slotTypes[playerID][theirInterface][slot1] = slotTypes[playerID][theirInterface][slot2]
                slotTypes[playerID][theirInterface][slot2] = tmpSlot
            else
                local list
                if theirInterface == SKILL_LIST_TOWER then
                    list = towerSkills
                elseif theirInterface == SKILL_LIST_BUILDING then
                    list = buildingSkills
                elseif theirInterface == SKILL_LIST_CREEP then
                    list = creepSkills
                end

                list = list or {}
                list[team] = list[team] or {}
                setupSlotType(-team)

                -- Copy skill over
                local tmpSkill = list[team][slot1+1]
                list[team][slot1+1] = list[team][slot2+1]
                list[team][slot2+1] = tmpSkill

                -- Swap slot types
                local tmpSlot = slotTypes[-team][slot1]
                slotTypes[-team][slot1] = slotTypes[-team][slot2]
                slotTypes[-team][slot2] = tmpSlot
            end

            -- Grab this player's playerSlot
            local playerSlot = getPlayerSlot(playerID)

            -- Prepare encoding number
            local encode = 0
            if hideSkills then
                if cmdPlayer:GetTeam() == DOTA_TEAM_BADGUYS then
                    encode = encodeDire
                elseif cmdPlayer:GetTeam() == DOTA_TEAM_GOODGUYS then
                    encode = encodeRadiant
                end
            end

            local tid = playerID
            local sn
            if theirInterface == SKILL_LIST_TOWER then
                tid = -team
            end

            -- Tell everyone


            if theirInterface >= SKILL_LIST_TOWER then
                if theirInterface == SKILL_LIST_TOWER then
                    sn = getSkillID(towerSkills[team][slot1+1])
                elseif theirInterface == SKILL_LIST_BUILDING then
                    sn = getSkillID(buildingSkills[team][slot1+1])
                elseif theirInterface == SKILL_LIST_CREEP then
                    sn = getSkillID(creepSkills[team][slot1+1])
                end
            else
                sn = getSkillID(skillList[playerID][theirInterface][slot1+1])
            end
            if sn ~= -1 then sn = sn + encode end
            FireGameEvent('lod_skill', {
                playerID = tid,
                slotNumber = slot1,
                skillID = sn,
                playerSlot = playerSlot,
                interface = theirInterface
            })

            if theirInterface >= SKILL_LIST_TOWER then
                if theirInterface == SKILL_LIST_TOWER then
                    sn = getSkillID(towerSkills[team][slot2+1])
                elseif theirInterface == SKILL_LIST_BUILDING then
                    sn = getSkillID(buildingSkills[team][slot2+1])
                elseif theirInterface == SKILL_LIST_CREEP then
                    sn = getSkillID(creepSkills[team][slot2+1])
                end
            else
                sn = getSkillID(skillList[playerID][theirInterface][slot2+1])
            end
            if sn ~= -1 then sn = sn + encode end
            FireGameEvent('lod_skill', {
                playerID = tid,
                slotNumber = slot2,
                skillID = sn,
                playerSlot = playerSlot,
                interface = theirInterface
            })

            FireGameEvent('lod_swap_slot', {
                playerID = tid,
                slot1 = slot1,
                slot2 = slot2,
                interface = theirInterface
            })

            -- Tell the player
            sendChatMessage(playerID, '#lod_swap_success', {
                (slot1+1),
                (slot2+1)
            })

        end
    end, 'Swap two slots.', CLIENT_COMMAND)

    -- When a user wants to stick a skill into a slot
    Convars:RegisterCommand('lod_skill', function(name, theirInterface, slotNumber, skillName)
        -- Input validation
        theirInterface = tonumber(theirInterface)
        if theirInterface == nil then return end
        if slotNumber == nil then return end
        if skillName == nil then return end

        -- Grab the player
        local cmdPlayer = Convars:GetCommandClient()
        if cmdPlayer then
            local playerID = cmdPlayer:GetPlayerID()
            local team = PlayerResource:GetTeam(playerID)

            -- Ensure a valid team
            if not isPlayerOnValidTeam(playerID) then
                sendChatMessage(playerID, '#lod_invalid_team')
                return
            end

            -- Check locks
            if playerLocks[playerID] then
                sendChatMessage(playerID, '#lod_please_unlock')
                return
            end

            -- Stop people who have spawned from picking
            if handledPlayerIDs[playerID] then
                sendChatMessage(playerID, '#lod_already_spawned')
                return
            end

            -- Ensure we are in banning mode
            if currentStage ~= STAGE_PICKING then
                sendChatMessage(playerID, '#lod_only_during_pick')
                return
            end

            -- Ensure we are ALLOWED to pick
            if not OptionManager:GetOption('allowedToPick') then
                sendChatMessage(playerID, '#lod_not_allowed_pick')
                return
            end

            -- Convert slot to a number
            slotNumber = tonumber(slotNumber)

            -- Ensure this is a valid slot
            if not isValidSlot(slotNumber) then
                sendChatMessage(playerID, '#lod_invalid_slot')
                return
            end

            -- Check interfaces
            if not validInterfaces[theirInterface] and theirInterface ~= SKILL_LIST_TOWER and theirInterface ~= SKILL_LIST_BUILDING and theirInterface ~= SKILL_LIST_CREEP then
                sendChatMessage(playerID, '#lod_invalid_interface')
                return
            end

            -- Check tower bans
            if theirInterface == SKILL_LIST_CREEP or theirInterface == SKILL_LIST_BUILDING then
                if noTowerAlways[skillName] then
                    sendChatMessage(playerID, '#noTower', {
                        getSpellIcon(skillName),
                        tranAbility(skillName),
                        noTower[skillName]
                    })
                    return
                end
            elseif theirInterface == SKILL_LIST_TOWER then
                if (OptionManager:GetOption('banTrollCombos') and noTower[skillName]) or noTowerAlways[skillName] then
                    sendChatMessage(playerID, '#noTower', {
                        getSpellIcon(skillName),
                        tranAbility(skillName),
                        noTower[skillName]
                    })
                    return
                end
            elseif theirInterface == SKILL_LIST_BEAR then
                if noBear[skillName] then
                    sendChatMessage(playerID, '#noBear', {
                        getSpellIcon(skillName),
                        tranAbility(skillName)
                    })
                    return
                end
            elseif theirInterface == SKILL_LIST_YOUR then
                if OptionManager:GetOption('banTrollCombos') and noHero[skillName] then
                    sendChatMessage(playerID, '#noHero', {
                        getSpellIcon(skillName),
                        tranAbility(skillName)
                    })
                    return
                end
            end

            local activeList

            if theirInterface < SKILL_LIST_TOWER then
                -- Ensure this player has a skill list
                skillList[playerID] = skillList[playerID] or {}
                skillList[playerID][theirInterface] = skillList[playerID][theirInterface] or {}
                activeList = skillList[playerID][theirInterface]
            else
                if theirInterface == SKILL_LIST_TOWER then
                    towerSkills[team] = towerSkills[team] or {}
                    activeList = towerSkills[team]
                elseif theirInterface == SKILL_LIST_BUILDING then
                    buildingSkills[team] = buildingSkills[team] or {}
                    activeList = buildingSkills[team]
                elseif theirInterface == SKILL_LIST_CREEP then
                    creepSkills[team] = creepSkills[team] or {}
                    activeList = creepSkills[team]
                end
            end

            -- Ensure this is a valid skill
            if not isValidSkill(skillName) then
                -- Perhaps they tried to random?
                if skillName == 'random' and theirInterface < SKILL_LIST_TOWER then
                    local msg
                    msg,skillName = findRandomSkill(playerID, theirInterface, slotNumber)

                    if msg then
                        sendChatMessage(playerID, msg)
                        return
                    end
                else
                    sendChatMessage(playerID, '#lod_invalid_skill', {
                        skillName
                    })
                    return
                end
            end

            -- Ensure this is a valid slot
            if skillName == 'lone_druid_spirit_bear' and theirInterface ~= SKILL_LIST_YOUR then
                sendChatMessage(playerID, '#lod_bearception')
                return
            end

            -- Ensure it isn't the same skill
            if activeList[slotNumber+1] ~= skillName then
                local slotType
                if theirInterface >= SKILL_LIST_TOWER then
                    setupSlotType(-team)
                    slotType = slotTypes[-team][slotNumber]
                else
                    setupSlotType(playerID)
                    slotType = slotTypes[playerID][theirInterface][slotNumber]
                end

                -- Make sure ults go into slot 3 only
                if(isUlt(skillName)) then
                    if slotType ~= SLOT_TYPE_ULT and slotType ~= SLOT_TYPE_EITHER then
                        sendChatMessage(playerID, '#lod_no_ult')
                        return
                    end
                else
                    if slotType ~= SLOT_TYPE_ABILITY and slotType ~= SLOT_TYPE_EITHER then
                        sendChatMessage(playerID, '#lod_no_regular')
                        return
                    end
                end

                local msg,args = CheckBans(activeList, slotNumber+1, skillName, playerID)
                if msg then
                    sendChatMessage(playerID, msg, args)
                    return
                end

                -- Store this skill into the given slot
                activeList[slotNumber+1] = skillName

                -- Grab this player's playerSlot
                local playerSlot = getPlayerSlot(playerID)

                -- Prepare encoding number
                local encode = 0
                if hideSkills then
                    if cmdPlayer:GetTeam() == DOTA_TEAM_BADGUYS then
                        encode = encodeDire
                    elseif cmdPlayer:GetTeam() == DOTA_TEAM_GOODGUYS then
                        encode = encodeRadiant
                    end
                end

                -- Tell everyone
                if theirInterface < SKILL_LIST_TOWER then
                    FireGameEvent('lod_skill', {
                        playerID = playerID,
                        slotNumber = slotNumber,
                        skillID = getSkillID(skillName)+encode,
                        playerSlot = playerSlot,
                        interface = theirInterface
                    })
                else
                    FireGameEvent('lod_skill', {
                        playerID = -team,
                        slotNumber = slotNumber,
                        skillID = getSkillID(skillName)+encode,
                        playerSlot = playerSlot,
                        interface = theirInterface
                    })
                end

                -- Tell the player
                sendChatMessage(playerID, '#lod_slot_success', {
                    getSpellIcon(skillName),
                    tranAbility(skillName),
                    (slotNumber+1)
                })

                -- Check for warnings
                if skillWarnings[skillName] then
                    -- Send the warning
                    sendChatMessage(playerID, '#warning_'..skillName, skillWarnings[skillName])
                end
            end
        end
    end, 'Select the given skill.', CLIENT_COMMAND)
end

-- Init console commands
registerConsoleCommands = function()
    if IsDedicatedServer() then
        registerServerCommands()
    end

    -- Register the fancy commands (we do this to avoid hitting Lua limits on varaible numbers)
    registerFancyConsoleCommands()

    -- When a user tries to ban a skill
    Convars:RegisterCommand('lod_ban', function(name, skillName)
        -- Input validation
        if skillName == nil then return end

        -- Grab the player
        local cmdPlayer = Convars:GetCommandClient()
        if cmdPlayer then
            local playerID = cmdPlayer:GetPlayerID()

            -- Ensure a valid team
            if not isPlayerOnValidTeam(playerID) then
                sendChatMessage(playerID, '#lod_invalid_team')
                return
            end

            -- Host banning mode?
            if OptionManager:GetOption('hostBanning') and playerID ~= 0 then
                sendChatMessage(playerID, '#lod_wait_host_ban')
                return
            end

            -- Ensure this is a valid skill
            if not isValidSkill(skillName) then
                sendChatMessage(playerID, '#lod_invalid_skill', {
                    skillName
                })
                return
            end

            -- Ensure we are in banning mode
            if currentStage ~= STAGE_BANNING then
                sendChatMessage(playerID, '#lod_only_during_ban')
                return
            end

            -- Ensure they have bans left
            totalBans[playerID] = totalBans[playerID] or 0
            if totalBans[playerID] >= OptionManager:GetOption('maxBans') then
                -- Send failure message
                sendChatMessage(playerID, '#lod_no_more_bans')
                -- Don't ban the skill
                return
            end

            -- Check if they are a hater
            if OptionManager:GetOption('allowBearSkills') and skillName == 'lone_druid_spirit_bear' then
                sendChatMessage(-1, '#lod_sb_hater', {
                    util:GetPlayerNameReliable(playerID)
                })
                return
            end

            -- Is this skill banned?
            if not isSkillBanned(skillName) then
                -- Increase the total number of bans of this person
                totalBans[playerID] = (totalBans[playerID] or 0) + 1

                -- Do the actual ban
                banSkill(skillName)

                -- Tell the user it was successful
                sendChatMessage(playerID, '#lod_ban_successful', {
                    getSpellIcon(skillName),
                    tranAbility(skillName),
                    totalBans[playerID],
                    OptionManager:GetOption('maxBans')
                })
            else
                -- Already banned
                sendChatMessage(playerID, '#lod_already_banned')
            end

            if totalBans[playerID] >= OptionManager:GetOption('maxBans') then
                doLock(playerID)
            end
        end
    end, 'Ban a given skill', CLIENT_COMMAND)

    -- When a user tries to recommend a skill
    Convars:RegisterCommand('lod_recommend', function(name, skillName, text)
        -- Input validation
        if skillName == nil then return end

        -- Grab the player
        local cmdPlayer = Convars:GetCommandClient()
        if cmdPlayer then
            local playerID = cmdPlayer:GetPlayerID()

            -- Ensure a valid team
            if not isPlayerOnValidTeam(playerID) then
                sendChatMessage(playerID, '#lod_invalid_team')
                return
            end

            -- Ensure this is a valid skill
            if not isValidSkill(skillName) then
                sendChatMessage(playerID, '#lod_invalid_skill', {
                    skillName
                })
                return
            end

            -- Grab their team
            local team = PlayerResource:GetTeam(playerID)

            -- Convert text
            text = text or '#lod_recommends'

            -- Send the message to their team
            sendTeamMessage(team, '<font color=\"#4B69FF\">{0}</font> {1} {2} <a href=\"event:menu_{3}\"><font color=\"#ADE55C\">{4}</font> <font color=\"#EB4B4B\">[menu]</font></a> <a href=\"event:info_{3}\"><font color=\"#EB4B4B\">[info]</font></a>', {
                util:GetPlayerNameReliable(playerID),
                text,
                getSpellIcon(skillName),
                skillName,
                tranAbility(skillName)
            })
        end
    end, 'Recommends a given skill', CLIENT_COMMAND)

    -- When a user requests more time
    Convars:RegisterCommand('lod_more_time', function(name)
        -- Grab the player
        local cmdPlayer = Convars:GetCommandClient()
        if cmdPlayer then
            local playerID = cmdPlayer:GetPlayerID()

            -- Ensure a valid team
            if not isPlayerOnValidTeam(playerID) then
                sendChatMessage(playerID, '#lod_invalid_team')
                return
            end

            -- Check the current phase
            if currentStage ~= STAGE_PICKING then
                sendChatMessage(playerID, '#lod_extra_time_wrong_stage')
                return
            end

            -- Grab their team
            local team = PlayerResource:GetTeam(playerID)

            -- Allow extra time ONCE from each team
            extraTime[team] = extraTime[team] or 0
            if extraTime[team] >= 1 then
                sendChatMessage(playerID, '#lod_already_time')
                return
            end
            extraTime[team] = extraTime[team] + 1

            -- Allocate extra time
            endOfTimer = endOfTimer + 60

            -- Tell the player
            sendChatMessage(-1, '#lod_time_allocated', {
                (team == DOTA_TEAM_GOODGUYS and 'RADIANT' or team == DOTA_TEAM_BADGUYS and 'DIRE' or 'an unknown team :O')
            })

            -- Update state
            GameRules.lod:OnEmitStateInfo()
        end
    end, 'Grants extra time for each team', CLIENT_COMMAND)

    -- When a user wants to view the options
    Convars:RegisterCommand('lod_show_options', function(name)
        -- Grab the player
        local cmdPlayer = Convars:GetCommandClient()
        if cmdPlayer then
            local playerID = cmdPlayer:GetPlayerID()

            -- Ensure a valid team
            if not isPlayerOnValidTeam(playerID) then
                sendChatMessage(playerID, '#lod_invalid_team')
                return
            end

            -- Send the options
            printOptionsToPlayer(playerID)
        end
    end, 'Shows options to a player', CLIENT_COMMAND)

    -- When a user wants to be host
    Convars:RegisterCommand('lod_host', function(name)
        -- Grab the player
        local cmdPlayer = Convars:GetCommandClient()
        if cmdPlayer then
            local playerID = cmdPlayer:GetPlayerID()

            if OptionManager:GetOption('slaveID') == -1 then
                OptionManager:SetOption(playerID)
            end
        end
    end, 'Allows a player to register as the host', CLIENT_COMMAND)

    -- When a user locks their skills
    Convars:RegisterCommand('lod_lock_skills', function(name)
        -- Grab the player
        local cmdPlayer = Convars:GetCommandClient()
        if cmdPlayer then
            local playerID = cmdPlayer:GetPlayerID()

            -- Ensure a valid team
            if not isPlayerOnValidTeam(playerID) then
                sendChatMessage(playerID, '#lod_invalid_team')
                return
            end

            -- Do the lock
            doLock(playerID)
        end
    end, 'Locks a players skills', CLIENT_COMMAND)

    -- Shows the given set
    Convars:RegisterCommand('lod_show_set', function(name, setNum)
        -- Server only command!
        local ply = Convars:GetCommandClient()
        if ply then
            -- This command doesnt work if we have 6 or less slots
            if OptionManager:GetOption('maxSlots') <= 6 then return end

            setNum = tonumber(setNum)
            if setNum < 0 or setNum > 1 then
                sendChatMessage(playerID, '#lod_invalid_set_nums', {
                    0, 1
                })
                return
            end

            local playerID = ply:GetPlayerID()
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            if hero then
                SkillManager:ShowSet(hero, setNum)
            end
        end
    end, '', CLIENT_COMMAND)

    -- Toggles the given set
    local currentToggles = {}
    Convars:RegisterCommand('lod_toggle_set', function(name)
        -- Server only command!
        local ply = Convars:GetCommandClient()
        if ply then
            -- This command doesnt work if we have 6 or less slots
            if OptionManager:GetOption('maxSlots') <= 6 then return end

            local playerID = ply:GetPlayerID()

            -- Decide which set to show
            local setNum = 1
            if currentToggles[playerID] == 1 then
                setNum = 0
            end
            currentToggles[playerID] = setNum

            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            if hero then
                SkillManager:ShowSet(hero, setNum)
            end
        end
    end, '', CLIENT_COMMAND)

    -- User is trying to update their vote
    Convars:RegisterCommand('lod_vote', function(name, optNumber, theirChoice)
        -- We are only accepting numbers
        optNumber = tonumber(optNumber)
        theirChoice = tonumber(theirChoice)

        local cmdPlayer = Convars:GetCommandClient()
        if cmdPlayer then
            local playerID = cmdPlayer:GetPlayerID()

            -- Ensure a valid team
            if not isPlayerOnValidTeam(playerID) then
                sendChatMessage(playerID, '#lod_invalid_team')
                return
            end

            if currentStage == STAGE_VOTING then
                -- Check if we are using slave mode, and we are a slave
                if OptionManager:GetOption('slaveID') >= 0 and playerID ~= OptionManager:GetOption('slaveID') then
                    sendChatMessage(playerID, '#lod_only_host')
                    return
                end

                if optNumber < 0 or optNumber >= totalVotableOptions then
                    -- Tell the user
                    sendChatMessage(playerID, '#lod_invalid_option')
                    return
                end

                -- Validate their choice
                if theirChoice < 0 or theirChoice >= totalChoices[optNumber] then
                    -- Tell the user
                    sendChatMessage(playerID, '#lod_invalid_choice')
                    return
                end

                -- Grab vote data
                voteData[playerID] = voteData[playerID] or {}

                -- Store vote
                voteData[playerID][optNumber] = theirChoice

                -- Are we in slave mode?
                if OptionManager:GetOption('slaveID') >= 0 then
                    -- Update everyone
                    FireGameEvent('lod_slave', {
                        opt = optNumber,
                        nv = theirChoice
                    })
                end
            else
                -- Tell them voting is over
                sendChatMessage(playerID, '#lod_during_voting')
            end
        end
    end, 'Update a user\'s vote', CLIENT_COMMAND)

    -- Users tries to lock the options in
    Convars:RegisterCommand('finished_voting', function(name, skillName)
        -- Grab the player
        local cmdPlayer = Convars:GetCommandClient()
        if cmdPlayer then
            local playerID = cmdPlayer:GetPlayerID()

            -- Ensure a valid team
            if not isPlayerOnValidTeam(playerID) then
                sendChatMessage(playerID, '#lod_invalid_team')
                return
            end

            -- Ensure the player is actually the host
            if playerID == OptionManager:GetOption('slaveID') then
                -- We are no longer waiting for the vote
                stillVoting = false
            else
                -- Tell the player they can't use this
                sendChatMessage(playerID, '#lod_only_host_use')
            end
        end
    end, 'Toggles the pause during the waiting phase', CLIENT_COMMAND)

    -- User asks for decoding info
    Convars:RegisterCommand('lod_decode', function(name, theirNumber, theirVersion)
        if theirNumber == nil or theirVersion == nil then return end

        -- We are only accepting numbers
        theirNumber = tonumber(theirNumber)

        local cmdPlayer = Convars:GetCommandClient()
        if cmdPlayer then
            local playerID = cmdPlayer:GetPlayerID()

            if cmdPlayer:GetTeam() == DOTA_TEAM_BADGUYS then
                -- Send out the encodings
                FireGameEvent('lod_decode', {
                    playerID = playerID,
                    code = encodeDire + theirNumber,
                    team = DOTA_TEAM_BADGUYS,
                    version = getLodVersion()
                })
            elseif cmdPlayer:GetTeam() == DOTA_TEAM_GOODGUYS then
                -- Send out the encodings
                FireGameEvent('lod_decode', {
                    playerID = playerID,
                    code = encodeRadiant + theirNumber,
                    team = DOTA_TEAM_GOODGUYS,
                    version = getLodVersion()
                })
            end
        end
    end, 'User asked for decoding info', CLIENT_COMMAND)

    print('LoD client commands loaded!')
end

-- Attempts to pick a random hero, returns 'random' if it fails
getRandomHeroName = function()
    local choices = {}

    for k,v in pairs(validHeroNames) do
        if not bannedHeroes[k] then
            table.insert(choices, k)
        end
    end

    if #choices > 0 then
        return choices[math.random(#choices)]
    else
        return 'random'
    end
end

-- Returns a html image tag for use with chat messages
getSpellIcon = function(skillName)
    return '<IMG SRC="img://resource/flash3/images/spellicons/'..(iconLookup[skillName] or 'nothing')..'.png" WIDTH="18" HEIGHT="18"/>'
end

-- Returns a translatable version of the spell name
tranAbility = function(skillName)
    return '#DOTA_Tooltip_ability_'..skillName
end

-- Returns a translatable version of the hero name
transHero = function(heroName)
    return '#npc_dota_hero_'..heroName
end

-- Builds the allowed tabs strings
buildAllowedTabsString = function()
    local str
    for k,v in pairs(allowedTabs) do
        if v then
            if not str then
                str = k
            else
                str = str..'||'..k
            end
        end
    end

    allowedTabsString = str or ''
end

--[[
    Special Gamemodes
]]
loadSpecialGamemode = function()
    if OptionManager:GetOption('cyclingBuilds') then
        -- Settings for cycling skills
        local minTime = 1           -- Min wait time before trying again
        local maxTime = 30          -- Max wait time before trying again
        local startChance = 1/10    -- The starting chance of changing builds
        local chanceGain = 1/100    -- The increase in chance each time we don't change builds
        local onDeadChance = 1.0    -- Value our chance will increase by if we are DEAD when we are meant to change builds

        -- Create a timer for each player
        for i=0,9 do
            -- We need new scope here
            (function(playerID, ourChance)
                -- Kill server if no one is on it anymore
                GameRules:GetGameModeEntity():SetThink(function()
                    -- Just stop if it is a bot
                    if PlayerResource:IsFakeClient(playerID) then return end

                    if math.random() <= ourChance then
                        -- Grab the hero
                        local hero = PlayerResource:GetSelectedHeroEntity(playerID)
                        if hero and hero:IsAlive() then
                            -- Build list of valid builds
                            local possibleBuilds = {}
                            for i=0,9 do
                                if skillList[i] and skillList[i][SKILL_LIST_YOUR] and skillList[i][SKILL_LIST_YOUR].hero then
                                    table.insert(possibleBuilds, skillList[i][SKILL_LIST_YOUR])
                                end
                            end

                            -- If there are any valid ones
                            if #possibleBuilds > 0 then
                                -- Apply a random one
                                local chosenBuild = possibleBuilds[math.random(#possibleBuilds)]

                                SkillManager:ApplyBuild(hero, chosenBuild)
                            end

                            ourChance = startChance
                        else
                            -- They WILL change on their next roll
                            ourChance = ourChance + onDeadChance
                        end
                    else
                        ourChance = ourChance + chanceGain
                    end

                    -- Wait a random period
                    return math.random(minTime,maxTime)
                end, 'cyclingTimer'..playerID, math.random(minTime,maxTime), nil)
            end)(i, chanceGain)
        end

        Say(nil, 'Cycling builds was enabled. You will get a new build randomly every so often.', false)
    end
end

-- Define skill warnings
skillWarnings = {
    life_stealer_infest = {getSpellIcon('life_stealer_infest'), tranAbility('life_stealer_infest'), getSpellIcon('life_stealer_consume'), tranAbility('life_stealer_consume')},
    shadow_demon_demonic_purge = {getSpellIcon('shadow_demon_demonic_purge'), tranAbility('shadow_demon_demonic_purge'), transHero('shadow_demon')},
    phantom_lancer_phantom_edge = {getSpellIcon('phantom_lancer_phantom_edge'), tranAbility('phantom_lancer_phantom_edge'), getSpellIcon('phantom_lancer_juxtapose'), tranAbility('phantom_lancer_juxtapose')},
    keeper_of_the_light_spirit_form = {getSpellIcon('keeper_of_the_light_spirit_form'), tranAbility('keeper_of_the_light_spirit_form')},
    luna_eclipse = {getSpellIcon('luna_eclipse'), tranAbility('luna_eclipse'), getSpellIcon('luna_lucent_beam'), tranAbility('luna_lucent_beam')},
    puck_illusory_orb = {getSpellIcon('puck_illusory_orb'), tranAbility('puck_illusory_orb'), getSpellIcon('puck_ethereal_jaunt'), tranAbility('puck_ethereal_jaunt')},
    techies_remote_mines = {getSpellIcon('techies_remote_mines'), tranAbility('techies_remote_mines'), getSpellIcon('techies_focused_detonate'), tranAbility('techies_focused_detonate')},
    nyx_assassin_burrow = {getSpellIcon('nyx_assassin_burrow'), tranAbility('nyx_assassin_burrow'), getSpellIcon('nyx_assassin_vendetta'), tranAbility('nyx_assassin_vendetta')},
    lone_druid_true_form = {getSpellIcon('lone_druid_true_form'), tranAbility('lone_druid_true_form')},
    phoenix_supernova = {getSpellIcon('phoenix_supernova'), tranAbility('phoenix_supernova')},
}

--[[if GameRules:isSource1() then
    skillWarnings.ogre_magi_multicast_lod = {getSpellIcon('ogre_magi_multicast'), tranAbility('ogre_magi_multicast')}
end]]

if lod == nil then
	print('LOD FAILED TO INIT!\n\n')
	return
end

-- Precaching
function Precache(context)
end

-- Create the game mode when we activate
function Activate()
    -- Init stat collection
    --[[statCollection:init({
        modID = '2374504c2c518fafc9731a120e67fdf5'
    })]]

	GameRules.lod = lod()
	GameRules.lod:InitGameMode()
end

-- Attempt to allow players to not load
--[[if not GameRules:isSource1() then
    Convars:SetInt('dota_wait_for_players_to_load', 0)
end]]

-- Debug info for noobs
print('Legends of Dota script has run successfully!\n\n')
