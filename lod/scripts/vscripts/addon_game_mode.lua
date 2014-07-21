print("gamemode started to load...")

--[[
    SETTINGS
]]

-- Max number of bans
local maxBans = 0

-- Banning Period
local banningTime = 0

-- Picking Time
local pickingTime = 300

-- Should we auto allocate teams?
local autoAllocateTeams = false

-- Total number of skill slots to allow
local maxSlots = 5

-- Total number of normal skills to allow
local maxSkills = 4

-- Total number of ults to allow (Ults are always on the right)
local maxUlts = 1

--[[
    GAMEMODE STUFF
]]

-- Stage constants
local STAGE_WAITING = 0
local STAGE_BANNING = 1
local STAGE_PICKING = 2
local STAGE_PLAYING = 3

-- The current stage we are in
local currentStage = STAGE_WAITING

-- Table of banned skills
local bannedSkills = {}

-- Skill list for a given player
local skillList = {}

-- The total amount banned by each player
local totalBans = {}

-- When the hero selection started
local heroSelectionStart = nil

-- Ability stuff
local abs = LoadKeyValues('scripts/npc/npc_abilities.txt')
local skillLookupList = LoadKeyValues('scripts/kv/abilities.kv').abs
local skillLookup = {}
for k,v in pairs(skillLookupList) do
    skillLookup[v] = tonumber(k)
end

local function isUlt(skillName)
    -- Check if it is tagged as an ulty
    if abs[skillName] and abs[skillName].AbilityType and abs[skillName].AbilityType == 'DOTA_ABILITY_TYPE_ULTIMATE' then
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

local function getPlayerSlot(playerID)
    -- Grab the cmd player
    local cmdPlayer = PlayerResource:GetPlayer(playerID)
    if not cmdPlayer then return -1 end

    -- Find player slot
    local team = cmdPlayer:GetTeam()
    local playerSlot = 0
    for i=0, 9 do
        if i >= playerID then break end

        if PlayerResource:GetTeam() == team then
            playerSlot = playerSlot + 1
        end
    end
    if team == DOTA_TEAM_BADGUYS then
        playerSlot = playerSlot + 5
    end

    return playerSlot
end

local canInfo = true
local function sendPickingInfo()
    -- Stop spam of this command
    if not canInfo then return end
    canInfo = false

    -- Send out info after a short delay
    thisEntity:SetThink(function()
        -- They can ask for info again
        canInfo = true

        -- Send picking info to everyone
        FireGameEvent('lod_picking_info', {
            startTime = heroSelectionStart,
            banningTime = banningTime,
            pickingTime = pickingTime,
            slots = maxSlots,
            skills = maxSkills,
            ults = maxUlts
        })
    end, 'DelayedInfoTimer', 1, nil)
end

local canState = true
local function sendStateInfo()
    -- Stop spam of this command
    if not canState then return end
    canState = false

    -- Send out info after a short delay
    thisEntity:SetThink(function()
        -- They can ask for info again
        canState = true

        -- Build the state table
        local s = {}

        -- Loop over all players
        for i=0,9 do
            -- Grab their skill list
            local l = skillList[i] or {}

            -- Loop over this player's skills
            for j=1,6 do
                -- Ensure the slot is filled
                s[tostring(i..j)] = s[tostring(i..j)] or -1

                local slot = getPlayerSlot(i)
                if slot ~= -1 then
                    -- Store the ID of this skill
                    s[tostring(slot..j)] = getSkillID(l[j])
                end
            end
        end

        local banned = {}
        for k,v in pairs(bannedSkills) do
            table.insert(banned, k)
        end

        -- Store bans
        for i=1,50 do
            s['b'..i] = getSkillID(banned[i])
        end

        -- Send picking info to everyone
        FireGameEvent('lod_state', s)
    end, 'DelayedStateTimer', 1, nil)
end

-- Run to handle
local function think()
    -- Decide what to do
    if currentStage == STAGE_WAITING then
        -- Wait for hero selection to start
        if GameRules:State_Get() >= DOTA_GAMERULES_STATE_HERO_SELECTION then
            -- Store when the hero selection started
            heroSelectionStart = GameRules:GetGameTime()

            -- Move onto banning mode
            currentStage = STAGE_BANNING

            sendPickingInfo()

            -- Sleep until the banning time is up
            return banningTime
        end

        -- Run again in a moment
        return 0.25
    end

    if currentStage == STAGE_BANNING then
        -- Change to picking state
        currentStage = STAGE_PICKING

        -- Sleep until picking is over
        return pickingTime
    end

    if currentStage == STAGE_PICKING then
        -- Change to the playing stage
        currentStage = STAGE_PLAYING

        -- Stop
        return
    end

    -- We should never get here
    print('WARNING: Unknown stage: '+currentStage)
end

-- Stick people onto teams
local radiant = false
ListenToGameEvent('player_connect_full', function(keys)
    -- Should we auto allocate teams?
    if autoAllocateTeams then
        -- Grab the entity index of this player
        local entIndex = keys.index+1
        local ply = EntIndexToHScript(entIndex)

        -- Set their team
        if radiant then
            radiant = false
            ply:SetTeam(DOTA_TEAM_GOODGUYS)
        else
            radiant = true
            ply:SetTeam(DOTA_TEAM_BADGUYS)
        end
    end
end, nil)

-- Stick skills into slots
local handled = {}
ListenToGameEvent('npc_spawned', function(keys)
    -- Grab the unit that spawned
    local spawnedUnit = EntIndexToHScript(keys.entindex)

    -- Make sure it is a hero
    if spawnedUnit:IsHero() then
        -- Don't touch this hero more than once :O
        if handled[spawnedUnit] then return end
        handled[spawnedUnit] = true

        -- Grab their playerID
        local playerID = spawnedUnit:GetPlayerID()

        -- Don't touch bots
        if PlayerResource:IsFakeClient(playerID) then return end

        -- Grab their build
        local build = skillList[playerID] or {}

        -- Apply the build
        SkillManager:ApplyBuild(spawnedUnit, build)
    end
end, nil)

-- When a user tries to ban a skill
Convars:RegisterCommand('lod_ban', function(name, skillName)
    -- Ensure this is a valid skill
    if not isValidSkill(skillName) then return end

    -- Ensure we are in banning mode
    if currentStage ~= STAGE_BANNING then return end

    -- Grab the player
    local cmdPlayer = Convars:GetCommandClient()
    if cmdPlayer then
        local playerID = cmdPlayer:GetPlayerID()

        -- Ensure they have bans left
        totalBans[playerID] = totalBans[playerID] or 0
        if totalBans[playerID] >= maxBans then
            -- Send failure message

            -- Don't ban the skill
            return
        end

        -- Is this skill banned?
        if not isSkillBanned(skillName) then
            -- Increase the total number of bans of this person
            totalBans[playerID] = (totalBans[playerID] or 0) + 1

            -- Do the actual ban
            banSkill(skillName)
        end
    end
end, 'Ban a given skill', 0)

-- When a user wants to stick a skill into a slot
Convars:RegisterCommand('lod_skill', function(name, slotNumber, skillName)
    -- Ensure this is a valid skill
    if not isValidSkill(skillName) then return end

    -- Is the skill banned?
    if isSkillBanned(skillName) then return end

    -- Convert slot to a number
    slotNumber = tonumber(slotNumber)

    -- Ensure this is a valid slot
    if not isValidSlot(slotNumber) then return end

    -- Ensure we are in banning mode
    if currentStage ~= STAGE_PICKING then return end

    -- Grab the player
    local cmdPlayer = Convars:GetCommandClient()
    if cmdPlayer then
        local playerID = cmdPlayer:GetPlayerID()

        -- Ensure this player has a skill list
        skillList[playerID] = skillList[playerID] or {}

        -- Ensure it isn't the same skill
        if skillList[playerID][slotNumber+1] ~= skillName then
            -- Make sure ults go into slot 3 only
            if(isUlt(skillName)) then
                if slotNumber < maxSlots - maxUlts then return end
            else
                if slotNumber >= maxSkills then return end
            end

            -- Store this skill into the given slot
            skillList[playerID][slotNumber+1] = skillName

            -- Grab this player's playerSlot
            local playerSlot = getPlayerSlot(playerID)

            -- Tell everyone
            FireGameEvent('lod_skill', {
                playerID = playerID,
                slotNumber = slotNumber,
                skillName = skillName,
                playerSlot = playerSlot
            })
        end
    end
end, 'Ban a given skill', 0)

-- When a user requests the picking info
Convars:RegisterCommand('lod_picking_info', function(name)
    -- Ensure the hero selection timer isn't nil
    if heroSelectionStart ~= nil then
        sendPickingInfo()
    end
end, 'Send picking info out', 0)

-- When a user requests the state info
Convars:RegisterCommand('lod_state_info', function(name)
    -- Ensure the hero selection timer isn't nil
    if heroSelectionStart ~= nil then
        -- Send the state info
        sendStateInfo()
    end
end, 'Send state info out', 0)

-- Setup the thinker
thisEntity:SetThink(think, 'PickingTimers', 0.25, nil)

-- Set the hero selection time
GameRules:SetHeroSelectionTime(banningTime+pickingTime)
