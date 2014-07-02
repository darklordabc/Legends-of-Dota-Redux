print("gamemode started to load...")

--[[
    SETTINGS
]]

-- Max number of bans
local maxBans = 5

-- Banning Period
local banningTime = 0

-- Picking Time
local pickingTime = 180

-- Should we auto allocate teams?
local autoAllocateTeams = true

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

-- Checks to see if this is a valid skill
local function isValidSkill(skillName)
    -- For now, no validation
    return true
end

-- Ensures this is a valid slot
local function isValidSlot(slotNumber)
    if slotNumber < 0 or slotNumber > 3 then return false end
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
            pickingTime = pickingTime
        })
    end, 'DelayedInfoTimer', 2, nil)
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
local radiant = true
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
        if skillList[playerID][slotNumber] ~= skillName then
            -- Store this skill into the given slot
            skillList[playerID][slotNumber] = skillName

            -- Tell everyone
            FireGameEvent('lod_skill', {
                playerID = playerID,
                slotNumber = slotNumber,
                skillName = skillName
            })
        end
    end
end, 'Ban a given skill', 0)

-- When a user tries to ban a skill
Convars:RegisterCommand('lod_picking_info', function(name)
    -- Ensure the hero selection timer isn't nil
    if heroSelectionStart ~= nil then
        sendPickingInfo()
    end
end, 'Send picking info out', 0)

-- Setup the thinker
thisEntity:SetThink(think, 'PickingTimers', 0.25, nil)

-- Set the hero selection time
GameRules:SetHeroSelectionTime(banningTime+pickingTime)
