-- Debug info for noobs
print('\n\nBeginning to run legends of dota script....')

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
require('lib.statcollection')
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
    require('dedicated')

    loadGDSOptions = false
end

-- Init load helper
require('lib.loadhelper')

-- Init utilities
require('util')

-- Load hax
require('hax')

-- Load survival
require('survival')

-- Load specific modules
local SkillManager = require('SkillManager')
local Timers = require('easytimers')

--[[
    FUNCTION DEFINITIONS
]]
local setupGamemodeSettings
local slotTypeString
local isUlt
local isPassive
local isPlayerOnValidTeam
local isValidSkill
local isValidHeroName
local isChannelled
local getMulticastDelay
local getSkillID
local isValidSlot
local isSkillBanned
local GetSkillOwningHero
local banSkill
local buildDraftString
local addHeroDraft
local getPlayerSlot
local sendChatMessage
local sendDireMessage
local sendRadiantMessage
local sendTeamMessage
local alreadyHas
local CheckBans
local setupSlotType
local setupSlotTypes
local validateBuild
local fixBuilds
local postGamemodeSettings
local getOptionsString
local shuffle
local optionToValue
local finishVote
local backdoorFix
local botSkillsOnly
local doLock
local getRandomHeroName
local getSpellIcon
local loadSpecialGamemode
local buildAllowedTabsString
local fireLockChange
local setTowerOwnership
local applyTowerSkills
local levelSpiritSkills
local tranAbility
local transHero

--[[
    SETTINGS
]]

-- Banning Period (2 minutes)
local banningTime = 60 * 2

-- Hero picking time
local heroBanningTime = 60

-- Picking Time (3 minutes)
local pickingTime = 60 * 3

-- Should we use slave voting, set ID = -1 for no
-- Set to the ID of the player who is the master
local slaveID = -1

-- Enable hero banning?
local enableHeroBanning = false

--[[
    VOTEABLE OPTIONS
]]

-- Total number of skill slots to allow
local maxSlots = 6

-- Total number of normal skills to allow
local maxSkills = 6

-- Total number of ults to allow (Ults are always on the right)
local maxUlts = 2

-- Should we ban troll combos?
local banTrollCombos = true

-- The starting level
local startingLevel = 1

-- The amount of bonus gold to award players
local bonusGold = 0

-- Should we turn easy mode on?
local useEasyMode = true

-- Are users allowed to pick skills?
local allowedToPick = true

-- Should we force random heroes?
local forceRandomHero = false

-- Enable WTF Mode?
local wtfMode = false

-- Unique skills constants
local UNIQUE_SKILLS_NONE = 0
local UNIQUE_SKILLS_TEAM = 1
local UNIQUE_SKILLS_GLOBAL = 2

-- Force unique skills?
local forceUniqueSkills = UNIQUE_SKILLS_NONE

-- Allow the passives on skills to be used
local allowItemModifers = true

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

-- Allow bear and tower skills?
local allowBearSkills = true
local allowTowerSkills = false

--[[
    GAMEMODE STUFF
]]

-- Max number of bans
local maxBans = 5
local maxHeroBans = 2

-- Host banning mode?
local hostBanning = false

-- Balance constants
local BALANCE_NONE = 0
local BALANCE_BASIC = 1
local BALANCE_EXTENDED = 2

-- Which balance mode to use
balanceMode = BALANCE_BASIC

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

-- The gamemode
local gamemode = GAMEMODE_AP    -- Set default gamemode

-- Skill list constants
local SKILL_LIST_YOUR = 1
local SKILL_LIST_BEAR = 2
local SKILL_LIST_TOWER = 3

-- Valid interfaces
local validInterfaces = {
    [SKILL_LIST_YOUR] = true,
    [SKILL_LIST_BEAR] = true,
}

-- Enable cycling builds
local cyclingBuilds = false

-- Are we using the draft arrays -- This will allow players to only pick skills from white listed heroes
local useDraftArray = true

-- How many heroes should the game auto allocate if we're using the draft array?
local autoDraftHeroNumber = 10

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

--[[
    CONSTANTS
]]
local SPLIT_CHAR = string.char(7)

--[[
    LOAD EXTERNAL OPTIONS
]]

-- Check for options module
local patchOptions = false
if Options then
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
        banningTime = 0
    end

    startingLevel = tonumber(Options.getOption('lod', STARTING_LEVEL, startingLevel))
    bonusGold = tonumber(Options.getOption('lod', BONUS_GOLD, bonusGold))

    useEasyMode = tonumber(Options.getOption('lod', EASY_MODE, 0)) == 1
    banTrollCombos = tonumber(Options.getOption('lod', TROLL_MODE, 0)) == 0
    hideSkills = tonumber(Options.getOption('lod', HIDE_PICKS, 1)) == 1
else
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

                -- Set settings go go go
                gamemode = tonumber(GDSOptions.getOption('gamemode', 2))

                maxSlots = tonumber(GDSOptions.getOption('maxslots', 2))
                maxSkills = tonumber(GDSOptions.getOption('maxskills', 2))
                maxUlts = tonumber(GDSOptions.getOption('maxults', 2))

                maxBans = tonumber(GDSOptions.getOption('maxbans', 5))
                if maxBans == -1 then
                    -- Host banning mode
                    maxBans = 500
                    hostBanning = true
                end

                forceUniqueSkills = tonumber(GDSOptions.getOption('uniqueskills', 2))

                banTrollCombos = GDSOptions.getOption('blocktrollcombos', true)
                useEasyMode = GDSOptions.getOption('useeasymode', false)
                hideSkills = GDSOptions.getOption('hideenemypicks', true)

                startingLevel = tonumber(GDSOptions.getOption('startinglevel', 0))
                bonusGold = tonumber(GDSOptions.getOption('bonusstartinggold', 0))

                -- Only allow it in the waiting stage
                if currentStage == STAGE_WAITING then
                    -- Skip the voting screen
                    patchOptions = true
                elseif currentStage == STAGE_VOTING then
                    -- No longer voting
                    stillVoting = false

                    -- Setup all the fancy gamemode stuff
                    setupGamemodeSettings()
                end
            end)
        else
            -- Disable it
            GDSOptions.setup()
        end
    end
end

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
local noMulticast = {}
local wtfAutoBan = {}
local noTower = {}

-- Load and process the bans
(function()
    -- Load in the ban list
    local tempBanList = LoadKeyValues('scripts/kv/bans.kv')

    -- Store no multicast
    noMulticast = tempBanList.noMulticast
    noTower = tempBanList.noTower
    wtfAutoBan = tempBanList.wtfAutoBan

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

    -- Loop over category bans
    for skillName,cat in pairs(tempBanList.CategoryBans) do
        for skillName2,__ in pairs(tempBanList.Categories[cat] or {}) do
            banCombo(skillName, skillName2)
        end
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

                -- Check if this is a source1 only skill
                if s1Skill ~= tostring(skillIndex) then
                    -- Copy it across
                    skillIndex = s1Skill

                    -- If not source1, we can't include
                    if not GameRules:isSource1() then
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

-- Create list of channeled spells
local chanelledSpells = {}
for k,v in pairs(abs) do
    if k ~= 'Version' and k ~= 'ability_base' then
        -- Check if this spell is channelled
        if v.AbilityBehavior and string.match(v.AbilityBehavior, 'DOTA_ABILITY_BEHAVIOR_CHANNELLED') then
            chanelledSpells[k] = true
        end
    end
end

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

-- Tells you if a given spell is channelled or not
isChannelled = function(skillName)
    if chanelledSpells[skillName] then
        return true
    end

    return false
end

-- Function to work out if we can multicast with a given spell or not
canMulticast = function(skillName)
    -- No channel skills
    if isChannelled(skillName) then
        return false
    end

    -- No banned multicast spells
    if noMulticast[skillName] then
        return false
    end

    -- Must be a valid spell
    return true
end

-- Custom multicast delays [export to KV if gets too big]
--[[local multicastDelay = {
    item_satanic = 3.5
}

-- Returns how long to wait before casting again
getMulticastDelay = function(skillName)
    -- Check if there is a custom delay for this skill
    if multicastDelay[skillName] ~= nil then
        -- Yep, ensure it's a number and return it
        return tonumber(multicastDelay[skillName])
    end

    -- Default delay
    return 0.1
end]]

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

    if slotNumber < 0 or slotNumber >= maxSlots then return false end
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
    for i=1,maxSlots do
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
    if not allowBearSkills or not skillName == 'lone_druid_spirit_bear' then
        if forceUniqueSkills == UNIQUE_SKILLS_TEAM then
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
        elseif forceUniqueSkills == UNIQUE_SKILLS_GLOBAL then
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
    if useDraftArray then
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

    -- Should we ban troll combos?
    if banTrollCombos then
        -- Check if they actually already have this skill
        for i=1,maxSlots do
            if skillList2[i] == skillName then
                return '#lod_already_in_draft', {
                    getSpellIcon(skillName),
                    tranAbility(skillName)
                }
            end
        end

        if banList[skillName] then
            -- Loop over all our slots
            for i=1,maxSlots do
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
    for j=0,maxSlots-1 do
        -- Workout if we can allow an ulty, or a skill in the given slot
        local skill = false
        local ult = false

        if j < maxSkills then
            skill = true
        end

        if j >= maxSlots-maxUlts then
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
        for j=0,maxSlots-1 do
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
    for j=0,maxSlots-1 do
        if interface then
            str = str..slotTypes[playerID][interface][j]
        else
            str = str..slotTypes[playerID][j]
        end
    end

    return str
end

-- Takes the current gamemode number, and sets the required settings
setupGamemodeSettings = function()
    -- Default to not using the draft array
    useDraftArray = false

    -- Single Draft Mode
    if gamemode == GAMEMODE_SD then
        -- We need the draft array for this
        useDraftArray = true

        -- We need some skills drafted for us
        autoDraftHeroNumber = 10
    end

    -- Mirror Draft Mode
    if gamemode == GAMEMODE_MD then
        -- We need the draft array for this
        useDraftArray = true

        -- We need some skills drafted for us
        autoDraftHeroNumber = 0

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
    if gamemode == GAMEMODE_AR then
        -- No picking time
        pickingTime = 0

        -- Users are not allowed to pick skills
        allowedToPick = false

        -- Force random heroes
        forceRandomHero = true

        -- Players can still ban things though
    end

    -- Should we draft heroes for players?
    if useDraftArray and autoDraftHeroNumber>0 then
        -- Pick random heroes for each player
        for i=0,9 do
            local total = 0
            while total < autoDraftHeroNumber do
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
    if useEasyMode then
        -- Tell players
        sendChatMessage(-1, '#lod_easy_mode')

        -- Enable it
        Convars:SetInt('dota_easy_mode', 1)
    end

    -- Are we using unique skills?
    if forceUniqueSkills > 0 then
        sendChatMessage(-1, '#lod_unique_skills', {
            ((forceUniqueSkills == UNIQUE_SKILLS_TEAM and '#lod_us_team_based') or (forceUniqueSkills == UNIQUE_SKILLS_GLOBAL and '#lod_us_global'))
        })
    end

    -- Announce which gamemode we're playing
    sendChatMessage(-1, '#lod_gamemode', {
        '#lod_gamemode'..gamemode
    })

    -- Announce results
    sendChatMessage(-1, '#lod_results', {
        maxSlots,
        maxSkills,
        ((maxSkills == 1 and '#lod_ability') or '#lod_abilities'),
        maxUlts,
        ((maxUlts == 1 and '#lod_ ability') or '#lod_abilities'),
        ((banTrollCombos and '#lod_BANNED') or '#lod_ALLOWED'),
        startingLevel,
        bonusGold
    })

    -- WTF Mode stuff
    if wtfMode then
        sendChatMessage(-1, '#lod_wtf')

        -- Ban skills
        for k,v in pairs(wtfAutoBan) do
            bannedSkills[k] = true
        end

        -- Enable WTF
        Convars:SetBool('dota_ability_debug', true)
    end

    if banningTime > 0 then
        if not hostBanning then
            sendChatMessage(-1, '#lod_banning', {
                banningTime,
                maxBans
            })
        else
            -- Tell other players to sit tight
            for i=0,9 do
                if slaveID ~= i then
                    sendChatMessage(i, '#lod_host_banning')
                else
                    -- Send banning info to main player
                    sendChatMessage(-1, '#lod_banning', {
                        banningTime,
                        maxBans
                    })
                end
            end
        end

        -- Move onto banning mode
        currentStage = STAGE_BANNING

        -- Store when the banning phase ends
        endOfTimer = Time() + banningTime
    else
        -- Tell everyone
        sendChatMessage(-1, '#lod_picking', {
            pickingTime
        })

        -- Move onto selection mode
        currentStage = STAGE_PICKING

        -- Store when the banning phase ends
        endOfTimer = Time() + pickingTime
    end

    -- Setup allowed tabs
    GameRules.allowItemModifers = allowItemModifers

    -- Build ability string
    buildAllowedTabsString()

    -- Build the ability list
    buildSkillListLookup()

    if not allowBearSkills then
        validInterfaces[SKILL_LIST_BEAR] = nil
    end

    -- Setup player slot types
    setupSlotTypes()

    -- Update state
    GameRules.lod:OnEmitStateInfo()
end

-- Called when picking ends
postGamemodeSettings = function()
    -- All Random
    if gamemode == GAMEMODE_AR then
        -- Create random builds

        -- Loop over all players
        for i=0,9 do
            -- Ensure it exists
            skillList[i] = skillList[i] or {}

            -- Loop over all slots
            for interface,_ in pairs(validInterfaces) do
                for j=0,maxSlots-1 do
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

    for k,v in pairs(voteData[slaveID] or {}) do
        str = str .. util.EncodeByte(k) .. util.EncodeByte(v)
    end

    return str
end

-- Shuffles a table
shuffle = function(t)
  local n = #t

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

    -- Set options
    maxSlots = optionToValue(1, winners[1])
    maxSkills = optionToValue(2, winners[2])
    maxUlts = optionToValue(3, winners[3])

    -- Balance mode
    balanceMode = optionToValue(11, winners[11])

    -- Bans
    hostBanning = false
    maxBans = optionToValue(4, winners[4])
    if maxBans == 0 then
        -- No banning phase
        banningTime = 0
    end
    if maxBans == -1 then
        -- Host banning mode
        hostBanning = true
        maxBans = 100
        maxHeroBans = 10
    end

    -- Hide skills
    hideSkills = optionToValue(8, winners[8]) == 1

    -- Block troll combos
    banTrollCombos = optionToValue(5, winners[5]) == 1

    -- Grab the gamemode
    gamemode = optionToValue(0, winners[0])

    -- Grab the starting level
    startingLevel = optionToValue(6, winners[6])

    -- Grab bonus gold
    bonusGold = optionToValue(9, winners[9])

    -- Are we using easy mode?
    useEasyMode = optionToValue(7, winners[7]) == 1

    -- Are we using unique skills?
    forceUniqueSkills = optionToValue(10, winners[10])

    -- Allowed tabs
    allowedTabs.main = optionToValue(11, winners[11]) == 1
    allowedTabs.neutral = optionToValue(12, winners[12]) == 1
    allowedTabs.wraith = optionToValue(13, winners[13]) == 1
    allowedTabs.itemsActive = optionToValue(14, winners[14]) >= 1
    allowedTabs.itemsPassive = optionToValue(14, winners[14]) >= 2
    allowedTabs.OP = optionToValue(15, winners[15]) == 1

    -- Should we allocate item modifiers?
    allowItemModifers = allowedTabs.itemsPassive

    -- Custom bears / towers
    allowBearSkills = optionToValue(16, winners[16]) == 1
    allowTowerSkills = optionToValue(17, winners[17]) == 1

    -- WTF Mode
    wtfMode = optionToValue(18, winners[18]) == 1

    -- Add settings to our stat collector
    statcollection.addStats({
        modes = {
            useEasyMode = useEasyMode,
            bonusGold = bonusGold,
            startingLevel = startingLevel,
            gamemode = gamemode,
            hideSkills = hideSkills,
            banTrollCombos = banTrollCombos,
            hostBanning = hostBanning,
            maxBans = maxBans,
            maxHeroBans = maxHeroBans,
            banningTime = banningTime,
            maxSlots = maxSlots,
            maxSkills = maxSkills,
            maxUlts = maxUlts,

            forceUniqueSkills = forceUniqueSkills,

            allowBearSkills = allowBearSkills,
            allowTowerSkills = allowTowerSkills,

            mainTab = allowedTabs.main,
            neutralTab = allowedTabs.neutral,
            wraithTab = allowedTabs.wraith,
            itemsActiveTab = allowedTabs.itemsActive,
            itemsPassiveTab = allowedTabs.itemsPassive,
            OPTab = allowedTabs.OP,
        }
    })

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

-- Called when LoD starts
function lod:InitGameMode()
    print('\n\nLegends of dota started!')
    GameRules:GetGameModeEntity():SetThink('OnThink', self, 'GlobalThink', 0.25)
    GameRules:GetGameModeEntity():SetThink('OnEmitStateInfo', self, 'EmitStateInfo', 5)

    -- Override source1 hooks
    SkillManager:overrideHooks()

    -- Set the selection time
    GameRules:SetHeroSelectionTime(60)
    GameRules:SetSameHeroSelectionEnabled(true)

    -- Setup standard rules
    if not GameRules:isSource1() then
        GameRules:GetGameModeEntity():SetTowerBackdoorProtectionEnabled( true )
        --GameRules:GetGameModeEntity():SetBotThinkingEnabled( true )
    else
        -- Precache wraithnight
        CreateUnitByName('npc_precache_wraithnight', Vector(-10000, -10000, 0), false, nil, nil, 0)
    end

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
        ['slots']       = maxSlots,
        ['skills']      = maxSkills,
        ['ults']        = maxUlts,
        ['trolls']      = (banTrollCombos and 1) or 0,
        ['hostBanning'] = (hostBanning and 1) or 0,
        ['hideSkills']  = (hideSkills and 1) or 0,
        ['source1']     = (GameRules:isSource1() and 1) or 0,
        ['balance']     = balanceMode,
        ['slaveID']     = slaveID,
        ['tabs']        = allowedTabsString,
        ['bans']        = maxBans,
        ['bear']        = (allowBearSkills and 1 or 0) + (allowTowerSkills and 2 or 0),

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
        for j=1,6 do
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
    if allowBearSkills then
        FireGameEvent('lod_state_bear', b)
    end

    -- Send tower info
    if allowTowerSkills then
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

            for j=1,6 do
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

    -- Send picking info to everyone
    FireGameEvent('lod_state', s)


    -- Run again after a delay
    return 5
end

-- Thinker function, run roughly once every second
local fixedBackdoor = false
local doneBotStuff = false
local patchedOptions = false
function lod:OnThink()
    -- Source1 fix to the backdoor issues
    if not fixedBackdoor and GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        if GameRules:isSource1() then
            -- Only run once
            fixedBackdoor = true

            -- Fix backdoor
            backdoorFix()
        end

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
                if slaveID == -1 then
                    slaveID = loadhelper.getHostID()

                    -- Is it still broken?
                    if slaveID == -1 then
                        return 0.1
                    end
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

        if GameRules:isSource1() and enableHeroBanning then
            -- Tell everyone
            sendChatMessage(-1, '#lod_hero_banning', {
                heroBanningTime
            })

            -- Change to picking state
            currentStage = STAGE_HERO_BANNING

            -- Store when the picking phase ends
            endOfTimer = Time() + heroBanningTime
        else
            -- Tell everyone
            sendChatMessage(-1, '#lod_picking', {
                pickingTime
            })

             -- Change to picking state
            currentStage = STAGE_PICKING

            -- Store when the picking phase ends
            endOfTimer = Time() + pickingTime
        end

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
        endOfTimer = Time() + pickingTime

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

        -- Apply the tower skills
        applyTowerSkills()

        -- Sleep
        return 0.1
    end

    -- Don't stop the timer!
    if currentStage == STAGE_PLAYING then
        if not lodHasStarted then
            -- Wait until hero selection ends
            if GameRules:State_Get() <= DOTA_GAMERULES_STATE_HERO_SELECTION then return 0.1 end
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

-- EXP Needed for each level
local XP_PER_LEVEL_TABLE = {
    0,-- 1
    200,-- 2
    500,-- 3
    900,-- 4
    1400,-- 5
    2000,-- 6
    2600,-- 7
    3200,-- 8
    4400,-- 9
    5400,-- 10
    6000,-- 11
    8200,-- 12
    9000,-- 13
    10400,-- 14
    11900,-- 15
    13500,-- 16
    15200,-- 17
    17000,-- 18
    18900,-- 19
    20900,-- 20
    23000,-- 21
    25200,-- 22
    27500,-- 23
    29900,-- 24
    32400 -- 25
}

-- Sets ownership of tower
-- Doesn't appear to work :O
setTowerOwnership = function()
    -- Ensure tower skills are allowed
    if not allowTowerSkills then return end
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

-- Applies tower skills if they are allowed
applyTowerSkills = function()
    -- Ensure tower skills are allowed
    if not allowTowerSkills then return end

    -- Dump dire tower skills
    print('Dire Towers:')
    for k,v in pairs(towerSkills[DOTA_TEAM_BADGUYS] or {}) do
        print(v)
    end

    -- Dump radiant tower skills
    print('Radiant Towers:')
    for k,v in pairs(towerSkills[DOTA_TEAM_GOODGUYS] or {}) do
        print(v)
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
end

-- When a hero spawns
local specialAddedSkills = {}
local mainHeros = {}
local givenBonuses = {}
local doneBots = {}
local resetGold = {}
local spiritBears = {}
ListenToGameEvent('npc_spawned', function(keys)
    -- Grab the unit that spawned
    local spawnedUnit = EntIndexToHScript(keys.entindex)

    -- Make sure it is a hero
    if spawnedUnit:IsHero() then
        -- Grab their playerID
        local playerID = spawnedUnit:GetPlayerID()

        -- Don't touch this hero more than once :O
        if handled[spawnedUnit] then return end
        handled[spawnedUnit] = true

        -- Fix gold bug
        if PlayerResource:HasRepicked(playerID) and not resetGold[playerID] then
            resetGold[playerID] = true
            PlayerResource:SetGold(playerID, 525, false)
        end

        -- Only give bonuses once
        if not givenBonuses[playerID] then
            -- We have given bonuses
            givenBonuses[playerID] = true

            -- Do we need to level up?
            if startingLevel > 1 then
                -- Level it up
                for i=1,startingLevel-1 do
                    spawnedUnit:HeroLevelUp(false)
                end

                -- Fix EXP
                if GameRules:isSource1() then
                    spawnedUnit:AddExperience(XP_PER_LEVEL_TABLE[startingLevel], XP_PER_LEVEL_TABLE[startingLevel], false, false)
                else
                    -- This is damned unstable, it always changes arguments FFS
                    spawnedUnit:AddExperience(XP_PER_LEVEL_TABLE[startingLevel], false, false)
                end
            end

            -- Any bonus gold?
            if bonusGold > 0 then
                PlayerResource:SetGold(playerID, bonusGold, true)
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
                local addSkills = maxSlots - 4 + (#tmpSkills - #skillList[playerID][SKILL_LIST_YOUR])

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
                skillList[playerID][SKILL_LIST_YOUR] = shuffle(skillList[playerID][SKILL_LIST_YOUR])

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
                        specialAddedSkills[playerID][v] = true
                    end
                end
            end

            -- Add the extra skills
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
    if allowBearSkills and spawnedUnit:GetClassname() == 'npc_dota_lone_druid_bear' then
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
end, nil)

-- Levels up a player's bear skills
levelSpiritSkills = function(spiritBear, skillz, playerLevel)
    for i=1,maxSlots do
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
local heroLevels = {}
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
                for skillName,v in pairs(toCheck) do
                    -- Workout the level of the skill
                    local requiredLevel = 0
                    if isUlt(skillName) then
                        if level >= 16 then
                            requiredLevel = 3
                        elseif level >= 11 then
                            requiredLevel = 2
                        elseif level >= 6 then
                            requiredLevel = 1
                        end
                    else
                        if level >= 7 then
                            requiredLevel = 4
                        elseif level >= 5 then
                            requiredLevel = 3
                        elseif level >= 3 then
                            requiredLevel = 2
                        elseif level >= 1 then
                            requiredLevel = 1
                        end
                    end

                    -- Grab a reference to teh skill
                    local skill = hero:FindAbilityByName(skillName)

                    if skill then
                        if requiredLevel > skill:GetMaxLevel() then
                            requiredLevel = skill:GetMaxLevel()
                        end

                        if skill and skill:GetLevel() < requiredLevel then
                            -- Level the skill
                            skill:SetLevel(requiredLevel)
                        end
                    end
                end
            end
        end
    end
end, nil)

-- Multicast
ListenToGameEvent('dota_player_used_ability', function(keys)
    local ply = EntIndexToHScript(keys.PlayerID or keys.player)
    if ply then
        local hero = ply:GetAssignedHero()
        if hero then
            -- Check if they have multicast
            if hero:HasAbility('ogre_magi_multicast_lod') and canMulticast(keys.abilityname) then
                local mab = hero:FindAbilityByName('ogre_magi_multicast_lod')
                if mab then
                    -- Grab the level of the ability
                    local lvl = mab:GetLevel()

                    -- If they have no level in it, stop
                    if lvl == 0 then return end

                    -- How many times we will cast the spell
                    local mult = 0

                    -- Grab a random number
                    local r = RandomFloat(0, 1)

                    -- Calculate multiplyer
                    if lvl == 1 then
                        if r < 0.25 then
                            mult = 2
                        end
                    elseif lvl == 2 then
                        if r < 0.2 then
                            mult = 3
                        elseif r < 0.4 then
                            mult = 2
                        end
                    elseif lvl == 3 then
                        if r < 0.125 then
                            mult = 4
                        elseif r < 0.25 then
                            mult = 3
                        elseif r < 0.5 then
                            mult = 2
                        end
                    end

                    -- Are we doing any multiplying?
                    if mult > 0 then
                        local ab = hero:FindAbilityByName(keys.abilityname)

                        -- If we failed to find it, it might hav e been an item
                        if not ab and hero:HasModifier('modifier_item_ultimate_scepter') then
                            for i=0,5 do
                                -- Grab the slot item
                                local slotItem = hero:GetItemInSlot(i)

                                -- Was this the spell that was cast?
                                if slotItem and slotItem:GetClassname() == keys.abilityname then
                                    -- We found it
                                    ab = slotItem
                                    break
                                end
                            end
                        end

                        if ab then
                            -- How long to delay each cast
                            local delay = 0.1--getMulticastDelay(keys.abilityname)

                            -- Grab the position
                            local pos = hero:GetCursorPosition()
                            local target = hero:GetCursorCastTarget()
                            local isTargetSpell = false

                            local playerID = hero:GetPlayerID()

                            if target then
                                isTargetSpell = true
                            end

                            local targets
                            if target then
                                targets = FindUnitsInRadius(target:GetTeam(),
                                    target:GetOrigin(),
                                    nil,
                                    256,
                                    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                                    DOTA_UNIT_TARGET_ALL,
                                    DOTA_UNIT_TARGET_FLAG_NONE,
                                    FIND_ANY_ORDER,
                                    false
                                )
                            end

                            Timers:CreateTimer(function()
                                -- Ensure it still exists
                                if IsValidEntity(ab) then
                                    -- Position cursor
                                    hero:SetCursorPosition(pos)

                                    local ourTarget = target

                                    -- If we have any targets to pick from, pick one
                                    local doneTarget = false
                                    if targets then
                                        -- While there is still possible targets
                                        while #targets > 0 do
                                            -- Pick a random target
                                            local index = math.random(#targets)
                                            local t = targets[index]

                                            -- Ensure it is valid and still alive
                                            if IsValidEntity(t) and t:GetHealth() > 0 and t ~= ourTarget then
                                                -- Target is valid and alive, target it
                                                --hero:SetCursorCastTarget(t)
                                                ourTarget = t
                                                hero:CastAbilityOnTarget(ourTarget, ab, playerID)
                                                doneTarget = true
                                                break
                                            else
                                                -- Invalid target, remove it and find another
                                                table.remove(targets, index)
                                            end
                                        end
                                    end

                                    -- If we failed to find a target, target the original
                                    if not doneTarget then
                                        if isTargetSpell then
                                            if not IsValidEntity(ourTarget) or ourTarget:GetHealth() <= 0 then
                                                return
                                            end
                                        end

                                        -- Cast onto original target
                                        hero:CastAbilityOnTarget(ourTarget, ab, playerID)
                                    end

                                    -- Run the spell again
                                    print('Multicast '..ab:GetClassname())
                                    ab:OnSpellStart()

                                    mult = mult-1
                                    if mult > 1 then
                                        return delay
                                    end
                                end
                            end, DoUniqueString('multicast'), delay)

                            -- Create sexy particles
                            local prt = ParticleManager:CreateParticle('ogre_magi_multicast', PATTACH_OVERHEAD_FOLLOW, hero)
                            ParticleManager:SetParticleControl(prt, 1, Vector(mult, 0, 0))
                            ParticleManager:ReleaseParticleIndex(prt)

                            prt = ParticleManager:CreateParticle('ogre_magi_multicast_b', PATTACH_OVERHEAD_FOLLOW, hero:GetCursorCastTarget() or hero)
                            prt = ParticleManager:CreateParticle('ogre_magi_multicast_b', PATTACH_OVERHEAD_FOLLOW, hero)
                            ParticleManager:ReleaseParticleIndex(prt)

                            prt = ParticleManager:CreateParticle('ogre_magi_multicast_c', PATTACH_OVERHEAD_FOLLOW, hero:GetCursorCastTarget() or hero)
                            ParticleManager:SetParticleControl(prt, 1, Vector(mult, 0, 0))
                            ParticleManager:ReleaseParticleIndex(prt)

                            -- Play the sound
                            hero:EmitSound('Hero_OgreMagi.Fireblast.x'..(mult-1))
                        end
                    end
                end
            end
        end
    end
end, nil)

-- Abaddon ulty fix
ListenToGameEvent('entity_hurt', function(keys)
    -- Grab the entity that was hurt
    local ent = EntIndexToHScript(keys.entindex_killed)

    -- Ensure it is a valid hero
    if ent and ent:IsRealHero() then
        -- The min amount of hp
        local minHP = 400

        -- Ensure their health has dropped low enough
        if ent:GetHealth() <= minHP then
            -- Do they even have the ability in question?
            if ent:HasAbility('abaddon_borrowed_time') then
                -- Grab the ability
                local ab = ent:FindAbilityByName('abaddon_borrowed_time')

                -- Is the ability ready to use?
                if ab:IsCooldownReady() then
                    -- Grab the level
                    local lvl = ab:GetLevel()

                    -- Is the skill even skilled?
                    if lvl > 0 then
                        -- Fix their health
                        ent:SetHealth(2*minHP - ent:GetHealth())

                        -- Add the modifier
                        ent:AddNewModifier(ent, ab, 'modifier_abaddon_borrowed_time', {
                            duration = ab:GetSpecialValueFor('duration'),
                            duration_scepter = ab:GetSpecialValueFor('duration_scepter'),
                            redirect = ab:GetSpecialValueFor('redirect'),
                            redirect_range_tooltip_scepter = ab:GetSpecialValueFor('redirect_range_tooltip_scepter')
                        })

                        -- Apply the cooldown
                        if lvl == 1 then
                            ab:StartCooldown(60)
                        elseif lvl == 2 then
                            ab:StartCooldown(50)
                        else
                            ab:StartCooldown(40)
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
end, '', 0)

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
end, '', 0)

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

        if skillSlot < 1 or skillSlot > maxSlots then
            print('Valids slots are 1 - '..maxSlots)
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
end, '', 0)

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
        if hostBanning and playerID ~= 0 then
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
        if totalBans[playerID] >= maxBans then
            -- Send failure message
            sendChatMessage(playerID, '#lod_no_more_bans')
            -- Don't ban the skill
            return
        end

        -- Check if they are a hater
        if allowBearSkills and skillName == 'lone_druid_spirit_bear' then
            sendChatMessage(-1, '#lod_sb_hater', {
                util.GetPlayerNameReliable(playerID)
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
                maxBans
            })
        else
            -- Already banned
            sendChatMessage(playerID, '#lod_already_banned')
        end

        if totalBans[playerID] >= maxBans then
            doLock(playerID)
        end
    end
end, 'Ban a given skill', 0)

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
            util.GetPlayerNameReliable(playerID),
            text,
            getSpellIcon(skillName),
            skillName,
            tranAbility(skillName)
        })
    end
end, 'Recommends a given skill', 0)

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

        -- Grab their team
        local team = PlayerResource:GetTeam(playerID)

        -- Allow extra time ONCE from each team
        extraTime[team] = extraTime[team] or 0
        if extraTime[team] >= 2 then
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
end, 'Grants extra time for each team', 0)

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
end, 'Locks a players skills', 0)

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
        if not allowedToPick then
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
        if not validInterfaces[theirInterface] and theirInterface ~= SKILL_LIST_TOWER then
            sendChatMessage(playerID, '#lod_invalid_interface')
            return
        end

        -- Ensure this player has a skill list
        if theirInterface ~= SKILL_LIST_TOWER then
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
            towerSkills = towerSkills or {}
            towerSkills[team] = towerSkills[team] or {}
            setupSlotType(-team)

            -- Copy skill over
            local tmpSkill = towerSkills[team][slot1+1]
            towerSkills[team][slot1+1] = towerSkills[team][slot2+1]
            towerSkills[team][slot2+1] = tmpSkill

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


        if theirInterface == SKILL_LIST_TOWER then
            sn = getSkillID(towerSkills[team][slot1+1])
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

        if theirInterface == SKILL_LIST_TOWER then
            sn = getSkillID(towerSkills[team][slot2+1])
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
end, 'Ban a given skill', 0)

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
        if not allowedToPick then
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
        if not validInterfaces[theirInterface] and theirInterface ~= SKILL_LIST_TOWER then
            sendChatMessage(playerID, '#lod_invalid_interface')
            return
        end

        -- Check tower bans
        if theirInterface == SKILL_LIST_TOWER then
            if noTower[skillName] then
                sendChatMessage(playerID, '#noTower', {
                    getSpellIcon(skillName),
                    tranAbility(skillName),
                    '#noTower_'..skillName
                })
                return
            end
        end

        local activeList

        if theirInterface ~= SKILL_LIST_TOWER then
            -- Ensure this player has a skill list
            skillList[playerID] = skillList[playerID] or {}
            skillList[playerID][theirInterface] = skillList[playerID][theirInterface] or {}
            activeList = skillList[playerID][theirInterface]
        else
            towerSkills[team] = towerSkills[team] or {}
            activeList = towerSkills[team]
        end

        -- Ensure this is a valid skill
        if not isValidSkill(skillName) then
            -- Perhaps they tried to random?
            if skillName == 'random' and theirInterface ~= SKILL_LIST_TOWER then
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
            if theirInterface == SKILL_LIST_TOWER then
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
            if theirInterface ~= SKILL_LIST_TOWER then
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
end, 'Ban a given skill', 0)

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
            if slaveID >= 0 and playerID ~= slaveID then
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
            if slaveID >= 0 then
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
end, 'Update a user\'s vote', 0)

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
        if playerID == slaveID then
            -- We are no longer waiting for the vote
            stillVoting = false
        else
            -- Tell the player they can't use this
            sendChatMessage(playerID, '#lod_only_host_use')
        end
    end
end, 'Toggles the pause during the waiting phase', 0)

-- User is trying to pick
local hasHero = {}
local hasBanned = {}
local banChance = {}
local bannedHeroes = {}

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
    return '<IMG SRC="img://resource/flash3/images/spellicons/'..skillName..'.png" WIDTH="18" HEIGHT="18"/>'
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
    if cyclingBuilds then
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
                                SkillManager:ApplyBuild(hero, possibleBuilds[math.random(#possibleBuilds)])
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

-- Source1 hero banning
if GameRules:isSource1() and enableHeroBanning then
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
                if hostBanning and playerID ~= 0 then
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
                if hasBanned[playerID] >= maxHeroBans then
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
                if hasBanned[playerID] >= maxHeroBans then
                    doLock(playerID)
                end

                -- Tell everyone
                sendChatMessage(-1, '#lod_hero_banned', {
                    '#'..heroName,
                    hasBanned[playerID],
                    maxHeroBans
                })
                return
            end

            -- Should we force a random hero name?
            if forceRandomHero then
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
    end, 'hero selection override', 0)
end

-- User asks for decoding info
Convars:RegisterCommand('lod_decode', function(name, theirNumber, theirVersion)
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
end, 'User asked for decoding info', 0)

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
        slaveID = newHostID
        print('Host was set to playerID '..slaveID)
    end
end, 'Host stealer', 0)

-- Prints out playerIDS
Convars:RegisterCommand('lod_ids', function(name, newHostID)
    -- Only server can run this
    if not Convars:GetCommandClient() then
        for i=0,9 do
            print(i..': '..PlayerResource:GetSteamAccountID(i)..' - '..util.GetPlayerNameReliable(i))
        end
    end
end, 'Host stealer', 0)

-- Turn cycling skills on
Convars:RegisterCommand('lod_cycle', function(name, newHostID)
    -- Only server can run this
    if not Convars:GetCommandClient() then
        if lodHasStarted then
            print('It is too late to use this.')
            return
        end

        -- Turn it on
        cyclingBuilds = true
        print('Cycling builds was enabled.')
    end
end, 'Turn cycling skills on', 0)

-- Define skill warnings
skillWarnings = {
    life_stealer_infest = {getSpellIcon('life_stealer_infest'), tranAbility('life_stealer_infest'), getSpellIcon('life_stealer_consume'), tranAbility('life_stealer_consume')},
    shadow_demon_demonic_purge = {getSpellIcon('shadow_demon_demonic_purge'), tranAbility('shadow_demon_demonic_purge'), transHero('shadow_demon')},
    phantom_lancer_phantom_edge = {getSpellIcon('phantom_lancer_phantom_edge'), tranAbility('phantom_lancer_phantom_edge'), getSpellIcon('phantom_lancer_juxtapose'), tranAbility('phantom_lancer_juxtapose')},
    keeper_of_the_light_spirit_form = {getSpellIcon('keeper_of_the_light_spirit_form'), tranAbility('keeper_of_the_light_spirit_form')},
    luna_eclipse = {getSpellIcon('luna_eclipse'), tranAbility('luna_eclipse'), getSpellIcon('luna_lucent_beam'), tranAbility('luna_lucent_beam')},
    puck_illusory_orb = {getSpellIcon('puck_illusory_orb'), tranAbility('puck_illusory_orb'), getSpellIcon('puck_ethereal_jaunt'), tranAbility('puck_ethereal_jaunt')},
    techies_remote_mines = {getSpellIcon('techies_remote_mines'), tranAbility('techies_remote_mines'), getSpellIcon('techies_focused_detonate'), tranAbility('techies_focused_detonate')},
    lone_druid_true_form = {getSpellIcon('lone_druid_true_form'), tranAbility('lone_druid_true_form')},
    phoenix_supernova = {getSpellIcon('phoenix_supernova'), tranAbility('phoenix_supernova')},
}

if lod == nil then
	print('LOD FAILED TO INIT!\n\n')
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

-- Debug info for noobs
print('Legends of Dota script has run successfully!\n\n')
