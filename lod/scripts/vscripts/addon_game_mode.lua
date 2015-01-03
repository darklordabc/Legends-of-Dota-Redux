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

-- Init utilities
require('util')

-- Load hax
require('hax')

-- Load specific modules
local SkillManager = require('SkillManager')
local Timers = require('easytimers')

--[[
    SETTINGS
]]

-- Banning Period (3 minutes)
local banningTime = 60 * 3

-- Picking Time (3 minutes)
local pickingTime = 60 * 3

-- Should we use slave voting, set ID = -1 for no
-- Set to the ID of the player who is the master
local slaveID = -1

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

-- Unique skills constants
local UNIQUE_SKILLS_NONE = 0
local UNIQUE_SKILLS_TEAM = 1
local UNIQUE_SKILLS_GLOBAL = 2

-- Force unique skills?
local forceUniqueSkills = UNIQUE_SKILLS_NONE

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

-- Colors
local COLOR_BLUE = '#4B69FF'
local COLOR_RED = '#EB4B4B'
local COLOR_GREEN = '#ADE55C'

-- Stage constants
local STAGE_WAITING = 0
local STAGE_VOTING = 1
local STAGE_BANNING = 2
local STAGE_PICKING = 3
local STAGE_PLAYING = 4

-- Gamemode constants
local GAMEMODE_AP = 1   -- All Pick
local GAMEMODE_SD = 2   -- Single Draft
local GAMEMODE_MD = 3   -- Mirror Draft
local GAMEMODE_AR = 4   -- All Random

gamemodeNames = {
    [GAMEMODE_AP] = 'All Pick',
    [GAMEMODE_SD] = 'Single Draft',
    [GAMEMODE_MD] = 'Mirror Draft',
    [GAMEMODE_AR] = 'All Random'
}

-- The gamemode
local gamemode = GAMEMODE_AP    -- Set default gamemode

-- Are we using the draft arrays -- This will allow players to only pick skills from white listed heroes
local useDraftArray = true

-- How many heroes should the game auto allocate if we're using the draft array?
local autoDraftHeroNumber = 10

-- The current stage we are in
local currentStage = STAGE_WAITING

-- Stores which heroes a player can use skills from
-- draftArray[playerID][heroID] = true
local draftArray = {}

-- Player's vote data, key = playerID
local voteData = {}

-- Table of banned skills
local bannedSkills = {}

-- Skill list for a given player
local skillList = {}

-- The total amount banned by each player
local totalBans = {}

-- When the hero selection started
local heroSelectionStart = nil

-- A list of heroes that were picking before the game started
local brokenHeroes = {}

-- Stick skills into slots
local handled = {}
local handledPlayerIDs = {}

-- A list of warning attached to skills
local skillWarnings = {
    life_stealer_infest = '<font color="'..COLOR_RED..'">Warning:</font> <font color="'..COLOR_BLUE..'">life_stealer_infest</font> <font color="'..COLOR_GREEN..'">requires </font><font color="'..COLOR_BLUE..'">life_stealer_rage</font> <font color="'..COLOR_GREEN..'">if you want to uninfest.</font>',
    phantom_lancer_phantom_edge = '<font color="'..COLOR_RED..'">Warning:</font> <font color="'..COLOR_BLUE..'">phantom_lancer_phantom_edge</font> <font color="'..COLOR_GREEN..'">requires </font><font color="'..COLOR_BLUE..'">phantom_lancer_juxtapose</font> <font color="'..COLOR_GREEN..'">in order to make illusions.</font>',
    keeper_of_the_light_spirit_form = '<font color="'..COLOR_RED..'">Warning:</font> <font color="'..COLOR_BLUE..'">keeper_of_the_light_spirit_form</font> <font color="'..COLOR_GREEN..'">will not give you the two extra spells!</font>',
    ogre_magi_multicast = '<font color="'..COLOR_RED..'">Warning:</font> <font color="'..COLOR_BLUE..'">ogre_magi_multicast</font> <font color="'..COLOR_GREEN..'">ONLY works on Ogre Magi\'s spells!</font>',
    --doom_bringer_devour = '<font color="'..COLOR_RED..'">Warning:</font> <font color="'..COLOR_BLUE..'">doom_bringer_devour</font> <font color="'..COLOR_GREEN..'">will replace your slot 4 and 5 with creep skills!</font>',
    rubick_spell_steal = '<font color="'..COLOR_RED..'">Warning:</font> <font color="'..COLOR_BLUE..'">rubick_spell_steal</font> <font color="'..COLOR_GREEN..'">will use up slots 4, 5 and 6!</font>',
    luna_eclipse = '<font color="'..COLOR_RED..'">Warning:</font> <font color="'..COLOR_BLUE..'">luna_eclipse</font> <font color="'..COLOR_GREEN..'">requires </font><font color="'..COLOR_BLUE..'">luna_lucent_beam</font> <font color="'..COLOR_GREEN..'">if you want it to do anything.</font>',
    puck_illusory_orb = '<font color="'..COLOR_RED..'">Warning:</font> <font color="'..COLOR_BLUE..'">puck_illusory_orb</font> <font color="'..COLOR_GREEN..'">requires </font><font color="'..COLOR_BLUE..'">puck_ethereal_jaunt</font> <font color="'..COLOR_GREEN..'">if you want to teleport to your orb.</font>',
    techies_remote_mines = '<font color="'..COLOR_RED..'">Warning:</font> <font color="'..COLOR_BLUE..'">techies_remote_mines</font> <font color="'..COLOR_GREEN..'">requires </font><font color="'..COLOR_BLUE..'">techies_focused_detonate</font> <font color="'..COLOR_GREEN..'">if you want to detonate your remote mines.</font>',
}

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

-- Ban List
local banList = LoadKeyValues('scripts/kv/bans.kv')

-- Ability stuff
local abs = LoadKeyValues('scripts/npc/npc_abilities.txt')
local absCustom = LoadKeyValues('scripts/npc/npc_abilities_custom.txt')
local skillLookup = {}

function buildSkillListLookup()
    -- Load the abilities file
    local skillLookupList = LoadKeyValues('scripts/kv/abilities.kv').abs

    -- Build
    for k,v in pairs(skillLookupList) do
        if tonumber(k) ~= nil then
            if GameRules:isSource1() then
                local v1 = skillLookupList[k..'_s1']

                if v1 ~= nil then
                    v = v1
                end
            end

            local skillSplit = vlua.split(v, '||')

            if #skillSplit == 1 then
                skillLookup[v] = tonumber(k)
            else
                -- Store the keys
                for i=1,#skillSplit do
                    skillLookup[skillSplit[i]] = -(tonumber(k)+1000*(i-1))
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
function getVersion()
    return versionNumber
end

local function isUlt(skillName)
    -- Check if it is tagged as an ulty
    if abs[skillName] and abs[skillName].AbilityType and abs[skillName].AbilityType == 'DOTA_ABILITY_TYPE_ULTIMATE' then
        return true
    end

    return false
end

-- Returns if a skill is a passive
local function isPassive(skillName)
    if abs[skillName] and abs[skillName].AbilityBehavior and string.match(abs[skillName].AbilityBehavior, 'DOTA_ABILITY_BEHAVIOR_PASSIVE') and not string.match(abs[skillName].AbilityBehavior, 'DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE') then
        return true
    end

    return false
end

-- Checks to see if this is a valid skill
local function isValidSkill(skillName)
    if skillLookup[skillName] == nil then return false end

    -- For now, no validation
    return true
end

-- Tells you if a hero name is valid, or not
local function isValidHeroName(heroName)
    if validHeroNames[heroName] then
        return true
    end

    return false
end

-- Tells you if a given spell is channelled or not
local function isChannelled(skillName)
    if chanelledSpells[skillName] then
        return true
    end

    return false
end

-- Function to work out if we can multicast with a given spell or not
local function canMulticast(skillName)
    -- No channel skills
    if isChannelled(skillName) then
        return false
    end

    -- No banned multicast spells
    if banList.noMulticast[skillName] then
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
local function getMulticastDelay(skillName)
    -- Check if there is a custom delay for this skill
    if multicastDelay[skillName] ~= nil then
        -- Yep, ensure it's a number and return it
        return tonumber(multicastDelay[skillName])
    end

    -- Default delay
    return 0.1
end]]

-- Returns the ID for a skill, or -1
local function getSkillID(skillName)
    -- If the skill wasn't found, return -1
    if skillLookup[skillName] == nil then return -1 end

    -- Otherwise, return the correct value
    return skillLookup[skillName]
end

-- Ensures this is a valid slot
local function isValidSlot(slotNumber)
    if slotNumber < 0 or slotNumber >= maxSlots then return false end
    return true
end

-- Checks to see if a skill is already banned
local function isSkillBanned(skillName)
    return bannedSkills[skillName] or false
end

-- Returns the ID (or -1) of the hero that owns this skill
local function GetSkillOwningHero(skillName)
    return skillOwningHero[skillName] or -1
end

local function banSkill(skillName)
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

local function buildDraftString(playerID)
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

local function addHeroDraft(playerID, heroID)
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

local function getPlayerSlot(playerID)
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

local function sendChatMessage(playerID, msg)
    -- Fire the event
     FireGameEvent('lod_msg', {
        playerID = playerID,
        msg = msg
    })
end

-- Checks if the player already has this skill
local function alreadyHas(skillList, skill)
    for i=1,maxSlots do
        if skillList[i] == skill then
            return true
        end
    end

    return false
end

local function CheckBans(skillList2, slotNumber, skillName, playerID)
    -- Old fashion bans
    if isSkillBanned(skillName) then
        return '<font color="'..COLOR_RED..'">This skill is banned.</font>'
    end

    -- Check for uniqye skills
    if forceUniqueSkills == UNIQUE_SKILLS_TEAM then
        -- Team based unqiue skills
        local team = PlayerResource:GetTeam(playerID)

        for playerID2,skills in pairs(skillList) do
            -- Ensure same team
            if team == PlayerResource:GetTeam(playerID2) then
                for slot,skill in pairs(skills) do
                    if skill == skillName then
                        if not (skillList2 == skills and slot == slotNumber) then
                            return '<font color="'..COLOR_RED..'">'..skillName..'</font> has already been taken by someone on your team, ask them if you can use it instead.'
                        end
                    end
                end
            end
        end
    elseif forceUniqueSkills == UNIQUE_SKILLS_GLOBAL then
        -- Global unique skills
        for playerID2,skills in pairs(skillList) do
            for slot,skill in pairs(skills) do
                if skill == skillName then
                    if not (skillList2 == skills and slot == slotNumber) then
                        return '<font color="'..COLOR_RED..'">'..skillName..'</font> has already been taken, it might become free again later!'
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
            return '<font color="'..COLOR_RED..'">'..skillName..'</font> is not in your drafting pool.'
        end
    end

    -- Should we ban troll combos?
    if banTrollCombos then
        -- Loop over all the banned combinations
        for k,v in pairs(banList.BannedCombinations) do
            -- Check if this is possibly banned
            if(v['1'] == skillName or v['2'] == skillName) then
                -- Loop over all our slots
                for i=1,maxSlots do
                    -- Ignore the skill in our current slot
                    if i ~= slotNumber then
                        -- Check the banned combo
                        if v['1'] == skillName and skillList2[i] == v['2'] then
                            return '<font color="'..COLOR_RED..'">'..skillName..'</font> can not be used with '..'<font color="'..COLOR_RED..'">'..v['2']..'</font>'
                        elseif v['2'] == skillName and skillList2[i] == v['1'] then
                            return '<font color="'..COLOR_RED..'">'..skillName..'</font> can not be used with '..'<font color="'..COLOR_RED..'">'..v['1']..'</font>'
                        end
                    end
                end
            end
        end
    end
end

local function findRandomSkill(playerID, slotNumber, filter)
    -- Workout if we can put an ulty here, or a skill
    local canUlt = true
    local canSkill = true

    if slotNumber < maxSlots - maxUlts then
        canUlt = false
    end
    if slotNumber >= maxSkills then
        canSkill = false
    end

    -- There is a chance there is no valid skill
    if not canUlt and not canSkill then
        -- Damn scammers! No valid skills!
        return '<font color="'..COLOR_RED..'">There are no valid skills for this slot!</font>'
    end

    -- Build a list of possible skills
    local possibleSkills = {}

    for k,v in pairs(skillLookup) do
        -- Ensure the player doesn't already have the skill
        if not alreadyHas(skillList[playerID], k) then
            -- Check filter
            if not filter or filter(k) then
                -- Check type of skill
                if (canUlt and isUlt(k)) or (canSkill and not isUlt(k)) then
                    -- Check for bans
                    if not CheckBans(skillList[playerID], slotNumber+1, k, playerID) then
                        -- Can't random meepo ulty
                        if k ~= 'meepo_divided_we_stand' then
                            -- Valid skill, add to our possible skills
                            table.insert(possibleSkills, k)
                        end
                    end
                end
            end
        end
    end

    -- Did we find no possible skills?
    if #possibleSkills == 0 then
        return '<font color="'..COLOR_RED..'">There are no valid skills for this slot.</font>'
    end

    -- Pick a random skill
    return nil, possibleSkills[math.random(#possibleSkills)]
end

-- Ensures the person has all their slots used
local function validateBuild(playerID)
    -- Ensure it exists
    skillList[playerID] = skillList[playerID] or {}

    -- Loop over all slots
    for j=0,maxSlots-1 do
        -- Do they have a skill in this slot?
        if not skillList[playerID][j+1] then
            local msg, skillName = findRandomSkill(playerID, j)

            -- Did we find a valid skill?
            if skillName then
                -- Pick a random skill
                skillList[playerID][j+1] = skillName
            end
        end
    end
end

-- Fixes broken heroes
local function fixBuilds()
    -- Give skills
    for k,v in pairs(brokenHeroes) do
        if k and IsValidEntity(k) then
            local playerID = k:GetPlayerID()

            -- Validate the build
            validateBuild(playerID)

            -- Grab their build
            local build = skillList[playerID] or {}

            -- Apply the build
            SkillManager:ApplyBuild(k, build)

            -- Store playerID has handled
            handledPlayerIDs[playerID] = true
        end
    end

    -- No more broken heroes
    brokenHeroes = {}
end

-- Takes the current gamemode number, and sets the required settings
local function setupGamemodeSettings()
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
        sendChatMessage(-1, '<font color="'..COLOR_BLUE..'">Easy Mode</font> <font color="'..COLOR_GREEN..'">was turned on!</font>')

        -- Enable it
        Convars:SetInt('dota_easy_mode', 1)
    end

    -- Are we using unique skills?
    if forceUniqueSkills then
        sendChatMessage(-1, '<font color="'..COLOR_BLUE..'">Unique Skills</font> <font color="'..COLOR_GREEN..'">was turned on! '..((forceUniqueSkills == UNIQUE_SKILLS_TEAM and '(Team Based)') or (forceUniqueSkills == UNIQUE_SKILLS_GLOBAL and '(Global)'))..'</font>')
    end

    -- Announce which gamemode we're playing
    sendChatMessage(-1, '<font color="'..COLOR_BLUE..'">'..(gamemodeNames[gamemode] or 'unknown')..'</font> <font color="'..COLOR_GREEN..'">game variant was selected!</font>')

    -- Build the ability list
    buildSkillListLookup()
end

-- Called when picking ends
local function postGamemodeSettings()
    -- All Random
    if gamemode == GAMEMODE_AR then
        -- Create random builds

        -- Loop over all players
        for i=0,9 do
            -- Ensure it exists
            skillList[i] = skillList[i] or {}

            -- Loop over all slots
            for j=0,maxSlots-1 do
                local msg, skillName = findRandomSkill(i, j, botFilter)

                -- Did we find a valid skill?
                if skillName then
                    -- Pick a random skill
                    skillList[i][j+1] = skillName
                end
            end
        end

        -- Send this new state out
        --sendStateInfo()
    end
end

-- Shuffles a table
function shuffle(t)
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

local function optionToValue(optionNumber, choice)
    local option = votingList[tostring(optionNumber)]
    if option then
        if option.values and option.values[tostring(choice)] then
            return tonumber(option.values[tostring(choice)])
        end
    end

    return -1
end

-- This function tallys the votes, and sets the options
local function finishVote()
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

    if winners[5] == 2 then
        -- No troll combos
        banTrollCombos = false
    end

    if winners[8] == 2 then
        hideSkills = false
    else
        hideSkills = true
    end

    -- Grab the gamemode
    gamemode = optionToValue(0, winners[0])

    -- Grab the starting level
    startingLevel = optionToValue(6, winners[6])

    -- Grab bonus gold
    bonusGold = optionToValue(9, winners[9])

    -- Are we using easy mode?
    if optionToValue(7, winners[7]) == 1 then
        -- Enable easy mode
        useEasyMode = true
    else
        -- Disable easy mode
        useEasyMode = false
    end

    -- Are we using unique skills?
    if optionToValue(10, winners[10]) == 1 then
        forceUniqueSkills = true
    else
        forceUniqueSkills = false
    end

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
            maxUlts = maxUlts
        }
    })

    -- Setup gamemode specific settings
    setupGamemodeSettings()

    -- Announce results
    sendChatMessage(-1, '<font color="'..COLOR_RED..'">Results:</font> <font color="'..COLOR_GREEN..'">There will be </font><font color="'..COLOR_BLUE..'">'..maxSlots..' slots</font><font color="'..COLOR_GREEN..'">, </font><font color="'..COLOR_BLUE..'">'..maxSkills..' regular '..((maxSkills == 1 and 'ability') or 'abilities')..'</font><font color="'..COLOR_GREEN..'"> and </font><font color="'..COLOR_BLUE..'">'..maxUlts..' ultimate '..((maxUlts == 1 and 'ability') or 'abilities')..'</font><font color="'..COLOR_GREEN..'"> allowed. Troll combos are </font><font color="'..COLOR_BLUE..'">'..((banTrollCombos and 'BANNED') or 'ALLOWED')..'</font><font color="'..COLOR_GREEN..'">! Starting level is </font></font><font color="'..COLOR_BLUE..'">'..startingLevel..'</font><font color="'..COLOR_GREEN..'">! Bonus gold is </font></font><font color="'..COLOR_BLUE..'">'..bonusGold..'</font><font color="'..COLOR_GREEN..'">.</font>')
end

-- A fix for source1 backdoor protection
local function backdoorFix()
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

local canInfo = true
local function sendPickingInfo()
    -- Stop spam of this command
    if not canInfo then return end
    canInfo = false

    -- Send out info after a short delay
    GameRules:GetGameModeEntity():SetThink(function()
        -- They can ask for info again
        canInfo = true

        -- Workout if we are running source1
        local s1 = 0
        if GameRules:isSource1() then
            s1 = 1
        end

        -- Send picking info to everyone
        FireGameEvent('lod_picking_info', {
            startTime = heroSelectionStart,
            banningTime = banningTime,
            pickingTime = pickingTime,
            slots = maxSlots,
            skills = maxSkills,
            ults = maxUlts,
            trolls = (banTrollCombos and 1) or 0,
            hostBanning = (hostBanning and 1) or 0,
            hideSkills = (hideSkills and 1) or 0,
            stage = currentStage,
            s1 = s1
        })
    end, 'DelayedInfoTimer', 1, nil)
end

local canVoteInfo = true
local function sendVotingInfo()
    -- Stop spam of this command
    if not canVoteInfo then return end
    canVoteInfo = false

    -- Send out info after a short delay
    GameRules:GetGameModeEntity():SetThink(function()
        -- We must have a valid slaveID before we can do anything
        if slaveID == -1 then
            slaveID = loadhelper.getHostID()

            -- Is it still broken?
            if slaveID == -1 then
                return 1
            end
        end

        -- They can ask for info again
        canVoteInfo = true

        -- Send picking info to everyone
        FireGameEvent('lod_voting_info', {
            slaveID = slaveID
        })
    end, 'DelayedVoteInfoTimer', 1, nil)
end

--[[local canState = true
sendStateInfo = function()
    -- Stop spam of this command
    if not canState then return end
    canState = false

    -- Send out info after a short delay
    GameRules:GetGameModeEntity():SetThink(function()
        -- They can ask for info again
        canState = true

        -- Build the state table
        local s = {}

        -- Loop over all players
        for i=0,9 do
            -- Grab their skill list
            local l = skillList[i] or {}

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

                if slot ~= -1 then
                    -- Store the ID of this skill
                    local sid = getSkillID(l[j])

                    if sid == -1 then
                        s[tostring(slot..j)] = sid
                    else
                        s[tostring(slot..j)] = sid+encode
                    end
                end
            end

            -- Store draft
            s['s'..i] = buildDraftString(i)
        end

        local banned = {}
        for k,v in pairs(bannedSkills) do
            table.insert(banned, k)
        end

        -- Store bans
        local b
        for k,v in pairs(banned) do
            if not b then
                b = getSkillID(banned[k])
            else
                b = b..'|'..getSkillID(banned[k])
            end
        end
        s['b'] = b

        -- Send picking info to everyone
        FireGameEvent('lod_state', s)
    end, 'DelayedStateTimer', 1, nil)
end]]

-- A function that returns true if the given skill is valid for bots
function botSkillsOnly(skillName)
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
        ['v'] = getVersion(),

        -- Add the current stage
        ['s'] = currentStage,

        -- Add options
        ['o']           = '',
        ['slots']       = maxSlots,
        ['skills']      = maxSkills,
        ['ults']        = maxUlts,
        ['trolls']      = (banTrollCombos and 1) or 0,
        ['hostBanning'] = (hostBanning and 1) or 0,
        ['hideSkills']  = (hideSkills and 1) or 0,
        ['s1']          = (GameRules:isSource1() and 1) or 0,
        ['balance']     = balanceMode,

        -- Store the end of the next timer
        ['t'] = endOfTimer,
    }

    -- Loop over all players
    for i=0,9 do
        -- Grab their skill list
        local l = skillList[i] or {}

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

            if slot ~= -1 then
                -- Store the ID of this skill
                local sid = getSkillID(l[j])

                if sid == -1 then
                    s[tostring(slot..j)] = sid
                else
                    s[tostring(slot..j)] = sid+encode
                end
            end
        end

        -- Store draft
        s['s'..i] = buildDraftString(i)

        -- Store locks
        s['l'..i] = playerLocks[i] or 0
    end

    local banned = {}
    for k,v in pairs(bannedSkills) do
        table.insert(banned, k)
    end

    -- Store bans
    local b
    for k,v in pairs(banned) do
        if not b then
            b = getSkillID(banned[k])
        else
            b = b..'|'..getSkillID(banned[k])
        end
    end
    s['b'] = b

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

        -- Done with this thinker
        return
    end

    -- Options patch
    if patchOptions and not patchedOptions then
        -- Only do it once
        patchedOptions = true

        -- No longer voting
        stillVoting = false

        -- Move onto banning
        currentStage = STAGE_BANNING

        -- Setup all the fancy gamemode stuff
        setupGamemodeSettings()
    end

    -- Decide what to do
    if currentStage == STAGE_WAITING then
        -- Wait for hero selection to start
        if GameRules:State_Get() >= DOTA_GAMERULES_STATE_HERO_SELECTION then
            -- Move onto the voting stage
            currentStage = STAGE_VOTING

            -- Send the voting info
            sendVotingInfo()

            -- Sleep until the voting time is over
            return 1
        end

        -- Run again in a moment
        return 2
    end

    if currentStage == STAGE_VOTING then
        -- Are we still voting?
        if stillVoting then
            PauseGame(true)
            return 1
        end

        -- Workout who won
        finishVote()

        -- Move onto banning mode
        currentStage = STAGE_BANNING

        -- Store when the hero selection started
        heroSelectionStart = Time()

        -- Send the picking info
        sendPickingInfo()

        -- Tell the users it's picking time
        if banningTime > 0 then
            if not hostBanning then
                sendChatMessage(-1, '<font color="'..COLOR_GREEN..'">Banning has started. You have</font> <font color="'..COLOR_RED..'">'..banningTime..' seconds</font> <font color="'..COLOR_GREEN..'">to ban upto <font color="'..COLOR_RED..'">'..maxBans..' skills</font><font color="'..COLOR_GREEN..'">. Drag and drop skills into the banning area to ban them.</font>')
            else
                -- Send banning info to main player
                sendChatMessage(0, '<font color="'..COLOR_GREEN..'">Banning has started. You have</font> <font color="'..COLOR_RED..'">'..banningTime..' seconds</font> <font color="'..COLOR_GREEN..'">to ban upto <font color="'..COLOR_RED..'">'..maxBans..' skills</font><font color="'..COLOR_GREEN..'">. Drag and drop skills into the banning area to ban them.</font>')

                -- Tell other players to sit tight
                for i=1,9 do
                    sendChatMessage(i, '<font color="'..COLOR_GREEN..'">Banning has started. Please wait while your host bans skills and heroes.</font>')
                end
            end
        end

        -- Sleep
        return 0.1
    end

    if currentStage == STAGE_BANNING then
        -- Pause the game
        PauseGame(true)

        -- Wait for banning to end
        if Time() < heroSelectionStart + banningTime then return 1 end

        -- Change to picking state
        currentStage = STAGE_PICKING

        -- Tell everyone
        sendChatMessage(-1, '<font color="'..COLOR_GREEN..'">Picking has started. You have</font> <font color="'..COLOR_RED..'">'..pickingTime..' seconds</font> <font color="'..COLOR_GREEN..'">to pick your skills. Drag and drop skills into the slots to select them.</font>')

        -- Sleep
        return 0.1
    end

    if currentStage == STAGE_PICKING then
        -- Owkrout how long left
        local timeLeft = heroSelectionStart + pickingTime + banningTime - Time()

        if timeLeft > 60 then
            PauseGame(true)
        else
            PauseGame(false)
        end

        -- Wait for voting to end
        if timeLeft > 0 and GameRules:State_Get() < DOTA_GAMERULES_STATE_PRE_GAME then return 1 end

        -- Change to the playing stage
        currentStage = STAGE_PLAYING

        -- Post gamemode stuff
        postGamemodeSettings()

        -- Fix any broken heroes
        fixBuilds()

        -- Unpause the game
        PauseGame(false)

        -- Sleep
        return 0.1
    end

    -- Don't stop the timer!
    if currentStage == STAGE_PLAYING then
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

-- When a hero spawns
local specialAddedSkills = {}
local mainHeros = {}
local givenBonuses = {}
local doneBots = {}
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

                -- Filter the skills
                for k,v in pairs(tmpSkills) do
                    if not CheckBans(skillList[playerID], #skillList[playerID]+1, v, playerID) then
                        table.insert(skillList[playerID], v)
                    end
                end

                -- Grab how many skills to add
                local addSkills = maxSlots - 4 + (#tmpSkills - #skillList[playerID])

                -- Do we need to add any skills?
                if addSkills <= 0 then return end

                -- Add the skills
                for i=1,addSkills do
                    local msg, skillName = findRandomSkill(playerID, #skillList[playerID]+1, botSkillsOnly)

                    -- Failed to find a new skill
                    if skillName == nil then break end

                    table.insert(skillList[playerID], skillName)
                end

                -- Sort it randomly
                skillList[playerID] = shuffle(skillList[playerID])

                -- Store that we added skills
                specialAddedSkills[playerID] = {}
                for k,v in pairs(skillList[playerID]) do
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
            SkillManager:ApplyBuild(spawnedUnit, skillList[playerID])

            return
        end

        -- Check if the game has started yet
        if currentStage > STAGE_PICKING then
            -- Validate the build
            validateBuild(playerID)

            -- Grab their build
            local build = skillList[playerID] or {}

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
end, nil)

-- Auto level bot skills <3
local heroLevels = {}
ListenToGameEvent('dota_player_gained_level', function(keys)
    -- Check every player
    for playerID = 0,9 do
        -- Ensure there is something to check
        local toCheck = specialAddedSkills[playerID]
        if toCheck ~= nil then
            -- Grab their hero
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)

            local level = hero:GetLevel()

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

                if skill and skill:GetLevel() < requiredLevel then
                    -- Level the skill
                    skill:SetLevel(requiredLevel)
                end
            end
        end
    end
end, nil)

-- Multicast + Riki ulty
ListenToGameEvent('dota_player_used_ability', function(keys)
    local ply = EntIndexToHScript(keys.PlayerID or keys.player)
    if ply then
        local hero = ply:GetAssignedHero()
        if hero then
            -- Check if they have riki ult
            if hero:HasAbility('riki_permanent_invisibility_lod') then
                local iab = hero:FindAbilityByName('riki_permanent_invisibility_lod')
                if iab and iab:GetLevel() > 0 then
                    -- Remove modifier if they have it
                    if hero:HasModifier('modifier_riki_permanent_invisibility') then
                        hero:RemoveModifierByName('modifier_riki_permanent_invisibility')
                    end

                    -- Workout how long the cooldown will last
                    local cd = 4-iab:GetLevel()

                    -- Start the cooldown
                    iab:StartCooldown(cd)

                    -- Apply invis again
                    hero:AddNewModifier(hero, iab, 'modifier_riki_permanent_invisibility', {
                        fade_time = cd,
                        fade_delay = 0
                    })
                end
            end

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
                            local target

                            if not GameRules:isSource1() then
                                target = hero:GetCursorCastTarget()
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

                                    -- If we have any targets to pick from, pick one
                                    local doneTarget = false
                                    if targets then
                                        -- While there is still possible targets
                                        while #targets > 0 do
                                            -- Pick a random target
                                            local index = math.random(#targets)
                                            local t = targets[index]

                                            -- Ensure it is valid and still alive
                                            if IsValidEntity(t) and t:GetHealth() > 0 then
                                                -- Target is valid and alive, target it
                                                hero:SetCursorCastTarget(t)
                                                doneTarget = true
                                                break
                                            else
                                                -- Invalid target, remove it and find another
                                                table.remove(targets, index)
                                            end

                                        end
                                    end

                                    -- If we failed to find a target, target the original
                                    if not doneTarget and not GameRules:isSource1() then
                                        hero:SetCursorCastTarget(target)
                                    end

                                    -- Run the spell again
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

-- When a user tries to ban a skill
Convars:RegisterCommand('lod_ban', function(name, skillName)
    -- Input validation
    if skillName == nil then return end

    -- Grab the player
    local cmdPlayer = Convars:GetCommandClient()
    if cmdPlayer then
        local playerID = cmdPlayer:GetPlayerID()

        -- Host banning mode?
        if hostBanning and playerID ~= 0 then
            sendChatMessage(playerID, '<font color="'..COLOR_RED..'">Please wait while the host bans skills.</font>')
            return
        end

        -- Ensure this is a valid skill
        if not isValidSkill(skillName) then
            sendChatMessage(playerID, '<font color="'..COLOR_RED..'">This doesn\'t appear to be a valid skill.</font>')
            return
        end

        -- Ensure we are in banning mode
        if currentStage ~= STAGE_BANNING then
            sendChatMessage(playerID, '<font color="'..COLOR_RED..'">You can only ban skills during the banning phase.</font>')
            return
        end

        -- Ensure they have bans left
        totalBans[playerID] = totalBans[playerID] or 0
        if totalBans[playerID] >= maxBans then
            -- Send failure message
            sendChatMessage(playerID, '<font color="'..COLOR_RED..'">You can not ban any more skills.</font>')
            -- Don't ban the skill
            return
        end

        -- Is this skill banned?
        if not isSkillBanned(skillName) then
            -- Increase the total number of bans of this person
            totalBans[playerID] = (totalBans[playerID] or 0) + 1

            -- Do the actual ban
            banSkill(skillName)

            -- Tell the user it was successful
            sendChatMessage(playerID, '<font color="'..COLOR_BLUE..'">'..skillName..'</font> was banned. <font color="'..COLOR_BLUE..'">('..totalBans[playerID]..'/'..maxBans..')</font>')
        else
            -- Already banned
            sendChatMessage(playerID, '<font color="'..COLOR_RED..'">This skill is already banned.</font>')
        end
    end
end, 'Ban a given skill', 0)

-- When a user wants to stick a skill into a slot
Convars:RegisterCommand('lod_skill', function(name, slotNumber, skillName)
    -- Input validation
    if slotNumber == nil then return end
    if skillName == nil then return end

    -- Grab the player
    local cmdPlayer = Convars:GetCommandClient()
    if cmdPlayer then
        local playerID = cmdPlayer:GetPlayerID()

        -- Stop people who have spawned from picking
        if handledPlayerIDs[playerID] then
            sendChatMessage(playerID, '<font color="'..COLOR_RED..'">You have already spawned. You can no longer pick!</font>')
            return
        end

        -- Ensure we are in banning mode
        if currentStage < STAGE_PICKING then
            sendChatMessage(playerID, '<font color="'..COLOR_RED..'">You can only pick skills during the picking phase.</font>')
            return
        end

        -- Ensure we are ALLOWED to pick
        if not allowedToPick then
            sendChatMessage(playerID, '<font color="'..COLOR_RED..'">You are not allowed to pick skills.</font>')
            return
        end

        -- Convert slot to a number
        slotNumber = tonumber(slotNumber)

        -- Ensure this is a valid slot
        if not isValidSlot(slotNumber) then
            sendChatMessage(playerID, '<font color="'..COLOR_RED..'">This is not a valid slot.</font>')
            return
        end

        -- Ensure this player has a skill list
        skillList[playerID] = skillList[playerID] or {}

        -- Ensure this is a valid skill
        if not isValidSkill(skillName) then
            -- Perhaps they tried to random?
            if skillName == 'random' then
                msg, skillName = findRandomSkill(playerID, slotNumber)

                if msg then
                    sendChatMessage(playerID, msg)
                end
            else
                sendChatMessage(playerID, '<font color="'..COLOR_RED..'">This doesn\'t appear to be a valid skill.</font>')
                return
            end
        end

        -- Ensure it isn't the same skill
        if skillList[playerID][slotNumber+1] ~= skillName then
            -- Make sure ults go into slot 3 only
            if(isUlt(skillName)) then
                if slotNumber < maxSlots - maxUlts then
                    sendChatMessage(playerID, '<font color="'..COLOR_RED..'">You can not put an ult into this slot.</font>')
                    return
                end
            else
                if slotNumber >= maxSkills then
                    sendChatMessage(playerID, '<font color="'..COLOR_RED..'">You can not put a regular skill into this slot.</font>')
                    return
                end
            end

            local msg = CheckBans(skillList[playerID], slotNumber+1, skillName, playerID)
            if msg then
                sendChatMessage(playerID, msg)
                return
            end

            -- Store this skill into the given slot
            skillList[playerID][slotNumber+1] = skillName

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
            FireGameEvent('lod_skill', {
                playerID = playerID,
                slotNumber = slotNumber,
                skillID = getSkillID(skillName)+encode,
                playerSlot = playerSlot
            })

            -- Tell the player
            sendChatMessage(playerID, '<font color="'..COLOR_BLUE..'">'..skillName..'</font> was put into <font color="'..COLOR_BLUE..'">slot '..(slotNumber+1)..'</font>')

            -- Check for warnings
            if skillWarnings[skillName] then
                -- Send the warning
                sendChatMessage(playerID, skillWarnings[skillName])
            end
        end
    end
end, 'Ban a given skill', 0)

-- When a user requests the voting info
Convars:RegisterCommand('lod_voting_info', function(name)
    -- Ensure the hero selection timer isn't nil
    if heroSelectionStart ~= nil then
        -- Should we send voting info, or picking info?
        if currentStage == STAGE_VOTING then
            -- Send voting info
            sendVotingInfo()
        else
            -- Send picking info
            sendVotingInfo()
            sendPickingInfo()
        end
    end
end, 'Send picking info out', 0)

-- When a user requests the picking info
Convars:RegisterCommand('lod_picking_info', function(name)
    -- Ensure the hero selection timer isn't nil
    if heroSelectionStart ~= nil then
        if currentStage >= STAGE_BANNING then
            sendPickingInfo()
        end
    end
end, 'Send picking info out', 0)

-- When a user requests the state info
--[[Convars:RegisterCommand('lod_state_info', function(name)
    -- Ensure the hero selection timer isn't nil
    if heroSelectionStart ~= nil then
        if currentStage >= STAGE_BANNING then
            -- Send the state info
            sendStateInfo()
        end
    end
end, 'Send state info out', 0)]]

-- User is trying to update their vote
Convars:RegisterCommand('lod_vote', function(name, optNumber, theirChoice)
    -- We are only accepting numbers
    optNumber = tonumber(optNumber)
    theirChoice = tonumber(theirChoice)

    local cmdPlayer = Convars:GetCommandClient()
    if cmdPlayer then
        local playerID = cmdPlayer:GetPlayerID()

        if currentStage == STAGE_VOTING then
            -- Check if we are using slave mode, and we are a slave
            if slaveID >= 0 and playerID ~= slaveID then
                sendChatMessage(playerID, '<font color="'..COLOR_RED..'">Only the host can change the options.</font>')
                return
            end

            if optNumber < 0 or optNumber >= totalVotableOptions then
                -- Tell the user
                sendChatMessage(playerID, '<font color="'..COLOR_RED..'">This appears to be an invalid option.</font>')
                return
            end

            -- Validate their choice
            if theirChoice < 0 or theirChoice >= totalChoices[optNumber] then
                -- Tell the user
                sendChatMessage(playerID, '<font color="'..COLOR_RED..'">This appears to be an invalid choice.</font>')
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
            sendChatMessage(playerID, '<font color="'..COLOR_RED..'">You can only vote during the voting period.</font>')
        end
    end
end, 'Update a user\'s vote', 0)

-- Users tries to lock the options in
Convars:RegisterCommand('finished_voting', function(name, skillName)
    -- Grab the player
    local cmdPlayer = Convars:GetCommandClient()
    if cmdPlayer then
        local playerID = cmdPlayer:GetPlayerID()

        -- Ensure the player is actually the host
        if playerID == slaveID then
            -- We are no longer waiting for the vote
            stillVoting = false
        else
            -- Tell the player they can't use this
            sendChatMessage(playerID, '<font color="'..COLOR_RED..'">Only the host can use this.</font>')
        end
    end
end, 'Toggles the pause during the waiting phase', 0)

-- User is trying to pick
local hasHero = {}
local hasBanned = {}
local banChance = {}
local bannedHeroes = {
    npc_dota_hero_silencer = true,
    npc_dota_hero_lone_druid = true,
    npc_dota_hero_ogre_magi = true,
}

-- Attempts to pick a random hero, returns 'random' if it fails
local function getRandomHeroName()
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

--[[Convars:RegisterCommand('dota_select_hero', function(name, heroName)
    local cmdPlayer = Convars:GetCommandClient()
    if cmdPlayer then
        local playerID = cmdPlayer:GetPlayerID()

        -- Random hero
        if heroName == 'random' then
            -- Attempt to random
            heroName = getRandomHeroName()

            -- Did we fail?
            if heroName == 'random' then
                sendChatMessage(playerID, '<font color="'..COLOR_RED..'">Error:</font> <font color="'..COLOR_GREEN..'">You can not random a hero.</font>')
                return
            end
        end

        -- Validate hero name
        if not isValidHeroName(heroName) then
            sendChatMessage(playerID, '<font color="'..COLOR_RED..'">'..heroName..'</font> <font color="'..COLOR_GREEN..'">is not a valid hero.</font>')
            return
        end

        -- Are we in voting?
        if currentStage <= STAGE_VOTING then
            sendChatMessage(playerID, '<font color="'..COLOR_RED..'">Error: </font> <font color="'..COLOR_GREEN..'">You can not pick before the picking stage.</font>')
            return
        end

        -- Are we in the banning stage?
        if currentStage == STAGE_BANNING then
            -- Host banning mode?
            if hostBanning and playerID ~= 0 then
                sendChatMessage(playerID, '<font color="'..COLOR_RED..'">Please wait while the host bans skills.</font>')
                return
            end

            -- Already banned?
            if bannedHeroes[heroName] then
                sendChatMessage(playerID, '<font color="'..COLOR_RED..'">Error: </font> <font color="'..COLOR_BLUE..'">'..heroName..'</font> <font color="'..COLOR_GREEN..'">is already banned!</font>')
                return
            end

            -- Ensure they have a value to compare against
            hasBanned[playerID] = hasBanned[playerID] or 0

            -- Have they hit their banning limit?
            if hasBanned[playerID] >= maxHeroBans then
                sendChatMessage(playerID, '<font color="'..COLOR_RED..'">Error: </font> <font color="'..COLOR_GREEN..'">You can not ban anymore heroes.</font>')
                return
            end

            -- Warn them about the ban first
            if banChance[playerID] ~= heroName then
                -- Store the chance
                banChance[playerID] = heroName

                -- Tell them about it
                sendChatMessage(playerID, '<font color="'..COLOR_RED..'">WARNING: </font> <font color="'..COLOR_GREEN..'">Select</font> <font color="'..COLOR_BLUE..'">'..heroName..'</font> <font color="'..COLOR_GREEN..'">again to ban it.</font>')
                return
            end

            -- Ok, ban this hero
            bannedHeroes[heroName] = true
            hasBanned[playerID] = hasBanned[playerID]+1

            -- Tell everyone
            sendChatMessage(-1, '<font color="'..COLOR_BLUE..'">'..heroName..'</font> <font color="'..COLOR_GREEN..'">was banned!</font> <font color="'..COLOR_BLUE..'">('..hasBanned[playerID]..'/'..maxHeroBans..')</font>')
            return
        end

        -- Should we force a random hero name?
        if forceRandomHero then
            -- Grab a random hero name
            heroName = getRandomHeroName()

            -- Make sure it worked
            if heroName == 'random' then
                sendChatMessage(playerID, '<font color="'..COLOR_RED..'">Error:</font> <font color="'..COLOR_GREEN..'">You can not random a hero.</font>')
                return
            end
        end

        -- Check bans
        if bannedHeroes[heroName] then
            sendChatMessage(playerID, '<font color="'..COLOR_RED..'">Error: </font> <font color="'..COLOR_BLUE..'">'..heroName..'</font> <font color="'..COLOR_GREEN..'">is banned!</font>')
            return
        end

        -- Stop multiple picks
        if hasHero[playerID] then return end
        hasHero[playerID] = true

        -- Attempt to create them their hero
        PrecacheUnitByNameAsync(heroName, function()
            CreateHeroForPlayer(heroName, cmdPlayer)
        end)
    end
end, 'hero selection override', 0)]]

-- User is trying to update their vote
Convars:RegisterCommand('lod_decode', function(name, theirNumber)
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
                team = DOTA_TEAM_BADGUYS
            })
        elseif cmdPlayer:GetTeam() == DOTA_TEAM_GOODGUYS then
            -- Send out the encodings
            FireGameEvent('lod_decode', {
                playerID = playerID,
                code = encodeRadiant + theirNumber,
                team = DOTA_TEAM_GOODGUYS
            })
        end
    end
end, 'Update a user\'s vote', 0)

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
