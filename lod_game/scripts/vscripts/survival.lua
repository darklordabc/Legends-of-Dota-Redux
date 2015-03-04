-- How often we should check if we need to spawn new zombies
local spawnCheckTime = 1

-- Max number of zombies per person
local ZOMBIES_PER_HERO = 20

-- How far should zombies spawn from the players
local SPAWN_DISTANCE = 1800

local zombieInfo = {}   -- Stores info on each user's zombies

-- The time the match started (for scaling)
local startTime = 0.0

local oneGlobalTeam = false

-- This will store the item used to apply modifiers to the spawned units
local modifierItem

local function applyDefaultStats(unit, factor, sfactor)
    --unit:__KeyValueFromInt('StatusHealth', math.ceil(30 * factor))
    --unit:SetMaxHealth(math.ceil(30 * factor))
    --unit:SetHealth(unit:GetMaxHealth())
    --unit:__KeyValueFromFloat('StatusHealthRegen', math.ceil(sfactor/2))
    --unit:__KeyValueFromInt('BountyGoldMin', math.ceil(30 * sfactor))
    --unit:__KeyValueFromInt('BountyGoldMax', math.ceil(30 * sfactor))
    --unit:__KeyValueFromInt('BountyXP', math.ceil(75 * sfactor))
    --unit:__KeyValueFromInt('MovementSpeed', 375)
    --unit:__KeyValueFromInt('AttackDamageMin', math.ceil(37 * factor))
    --unit:__KeyValueFromInt('AttackDamageMax', math.ceil(45 * factor))
    --unit:__KeyValueFromInt('AttackRange', 128)
    --unit:__KeyValueFromFloat('AttackRate', 1.6)
    --unit:__KeyValueFromInt('VisionDaytimeRange', 400)
    --unit:__KeyValueFromInt('VisionNighttimeRange', 400)
    --unit:__KeyValueFromInt('ArmorPhysical', math.ceil(factor-1))
    --unit:__KeyValueFromInt('MagicalResistance', 33)
end

-- List of zombies that can spawn
local skins = {
    [1] = {
        -- How long before it can spawn?
        minTime = 0,

        -- What unit to base it off?
        unit = 'npc_dota_unit_undying_zombie',

        -- What stats should it get?
        stats = applyDefaultStats
    },

    [2] = {
        minTime = 60,
        unit = 'npc_dota_dark_troll_warlord_skeleton_warrior',
        stats = function(unit, factor, sfactor)
            -- Apply default stuff
            applyDefaultStats(unit, factor, sfactor)

            -- Give magic resist
            --unit:__KeyValueFromInt('MagicalResistance', 90)
        end
    },

    [3] = {
        minTime = 120,
        unit = 'npc_dota_visage_familiar1',
        stats = function(unit, factor, sfactor)
            -- Apply default stuff
            applyDefaultStats(unit, factor, sfactor)

            -- Apply new stuff
            --unit:__KeyValueFromFloat('AttackRate', 1.2)
            --unit:__KeyValueFromInt('AttackRange', 200)
            --unit:__KeyValueFromInt('MovementSpeed', 500)
        end
    },

    [4] = {
        minTime = 240,
        unit = 'npc_dota_neutral_granite_golem',
        stats = function(unit, factor, sfactor)
            -- Apply default stuff
            applyDefaultStats(unit, factor, sfactor)

            -- Apply new stuff
            --unit:__KeyValueFromInt('AttackRange', 600)
            --unit:__KeyValueFromInt('MovementSpeed', 500)
        end
    }
}

local function isValidPosition(pos)
    -- Check if the position is outside the valid playing area
    if pos.x < GetWorldMinX() or pos.x > GetWorldMaxX() or pos.y < GetWorldMinY() or pos.y > GetWorldMaxY() then
        -- Outside
        return false
    end

    -- Must be inside
    return true
end

local function resetPlayerID(playerID)
    -- Reset info on this player
    zombieInfo[playerID] = {
        zombieList = {}
    }

    return zombieInfo[playerID]
end

local function checkForVictory()
    -- Default to everyone being dead
    local allDeadDire = true
    local allDeadRadiant = true

    -- Loop over all players
    for playerID=0,9 do
        local hero = PlayerResource:GetSelectedHeroEntity(playerID)
        if hero and hero:IsAlive() then
            -- Check if they were on either major team
            if hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
                allDeadRadiant = false
            elseif hero:GetTeamNumber() == DOTA_TEAM_BADGUYS then
                allDeadDire = false
            end
        end
    end
end

local function reveal(hero)
    if not hero:HasModifier('modifier_truesight') then
        hero:AddNewModifier(hero, nil, 'modifier_truesight', {})
    end
end

local function unreveal(hero)
    if hero:HasModifier('modifier_truesight') then
        hero:RemoveModifierByName('modifier_truesight')
    end
end

local function initSurvival()
    -- Tell the server
    print('Survival was loaded!')

    -- Create modifier item
    modifierItem = CreateItem('item_survival_modifier', nil, nil)

    -- Reset zombie info
    zombieInfo = {}

    local doneDireRecord = false
    local doneRadiantRecord = false

    -- Can use any shop at any shop
    GameRules:SetUseUniversalShopMode(true)

    -- Disable normal creeps
    Convars:SetBool('dota_creeps_no_spawning', true)

    -- Disable bots
    SendToServerConsole('lod_nobots')

    local hasStarted = false
    local gameOver = false
    GameRules:GetGameModeEntity():SetThink(function()
        if not hasStarted then
            if not (GameRules:State_Get() >= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS) then return 0.1 end
            hasStarted = true
            startTime = Time()
            Say(nil, "Survival was loaded, try to stay alive for as long as possible!", false)
        end

        local timePassed = (Time() - startTime)
        local factor = 1 + timePassed/60
        local sfactor = math.sqrt(factor)
        local maxZombies = math.min(ZOMBIES_PER_HERO, 3*factor)

        -- Default to everyone being dead
        local allDeadDire = true
        local allDeadRadiant = true

        local radiantPlayers = false
        local direPlayers = false

        -- Loop over all the players
        for playerID=0,9 do
            local team = PlayerResource:GetTeam(playerID)
            if PlayerResource:GetConnectionState(playerID) >= 2 then
                if team == DOTA_TEAM_GOODGUYS then
                    radiantPlayers = true
                elseif team == DOTA_TEAM_BADGUYS then
                    direPlayers = true
                end
            end

            -- Grab their hero, make sure it exists, and is alive
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            if hero and hero:IsAlive() then
                -- Ensure this player has some info
                local info = zombieInfo[playerID] or resetPlayerID(playerID)

                -- Ensure they are revealed
                reveal(hero)

                -- Check if they were on either major team
                if team == DOTA_TEAM_GOODGUYS then
                    allDeadRadiant = false
                elseif team == DOTA_TEAM_BADGUYS then
                    allDeadDire = false
                end

                local totalZombies = 0
                -- Make sure each zombie is following their respective player
                for k,v in pairs(info.zombieList) do
                    if not IsValidEntity(v) then
                        -- Remove it
                        table.remove(info.zombieList, k)
                    elseif Time() > v.expireTime or not v:IsAlive() or v:GetHealth() <= 0 then
                        -- Remove it
                        table.remove(info.zombieList, k)
                        v:ForceKill(false)
                        UTIL_RemoveImmediate(v)
                    else
                        -- Increase total zombies
                        totalZombies = totalZombies+1

                        -- Make it attack it's hero
                        v:MoveToTargetToAttack(hero)
                    end
                end

                -- Check if they don't have enough zombies
                while totalZombies < maxZombies do
                    -- Pick a random, valid skin
                    local skin = {}
                    repeat
                        skin = skins[math.random(1, #skins)]
                    until timePassed >= skin.minTime

                    -- There is one more zombie
                    totalZombies = totalZombies + 1

                    -- Workout where to spawn it (ensure it is within the map bounds)
                    local pos

                    repeat
                        pos = hero:GetOrigin()
                        local ang = math.random() * 2 * math.pi;
                        pos.x = pos.x + math.cos(ang) * SPAWN_DISTANCE
                        pos.y = pos.y + math.sin(ang) * SPAWN_DISTANCE
                    until isValidPosition(pos)

                    -- Put it on the opposite team
                    local team = ((hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS) and DOTA_TEAM_BADGUYS) or DOTA_TEAM_GOODGUYS

                    -- Spawn it
                    local unit = CreateUnitByName(skin.unit, pos, true, nil, nil, team)

                    -- Stat it up
                    skin.stats(unit, factor, sfactor)

                    -- Make it attack
                    unit:MoveToTargetToAttack(hero)

                    -- Make it expire after 30 seconds
                    unit.expireTime = Time()+30

                    table.insert(info.zombieList, unit)
                end
            end
        end

        -- Game ends differently, depending on wether it is team based or not
        if not gameOver then
            if oneGlobalTeam then
                -- Output records
                if allDeadDire and not doneDireRecord then
                    Say(nil, "Dire Record: "..math.floor(Time()-startTime).." seconds!", false)
                    doneDireRecord = true
                end
                if allDeadRadiant and not doneRadiantRecord then
                    Say(nil, "Radiant Record: "..math.floor(Time()-startTime).." seconds!", false)
                    doneRadiantRecord = true
                end

                -- Team based, everyone needs to die
                if allDeadDire and allDeadRadiant then
                    -- Print total survival time
                    Say(nil, "Total Survival Time: "..math.floor(Time()-startTime).." seconds!", false)

                    -- End the gamemode
                    GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
                    GameRules:Defeated()
                    gameOver = true
                end
            else
                if direPlayers and allDeadDire then
                    Say(nil, "Dire Loses!", false)
                    GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
                    GameRules:Defeated()
                    gameOver = true
                end

                if radiantPlayers and allDeadRadiant then
                    Say(nil, "Radiant Loses!", false)
                    GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
                    GameRules:Defeated()
                    gameOver = true
                end

                -- If either team has everyone dead
                if (radiantPlayers and allDeadRadiant) or (direPlayers and allDeadDire) then
                    -- Print total survival time
                    Say(nil, "Total Survival Time: "..math.floor(Time()-startTime).." seconds!", false)
                end
            end
        end

        return spawnCheckTime
    end, 'survivalClock', spawnCheckTime, nil)

    -- Reveal heroes when they spawn
    ListenToGameEvent('npc_spawned', function(keys)
        -- Grab the unit that spawned
        local spawnedUnit = EntIndexToHScript(keys.entindex)

        -- Make sure it is a hero
        if spawnedUnit:IsHero() then
            -- Grab their playerID
            local playerID = spawnedUnit:GetPlayerID()

            -- Make this hero revealed
            reveal(spawnedUnit)
        end
    end, nil)

    -- Cleanup towers and fountain
    local ents = Entities:FindAllByClassname('npc_dota_tower')

    -- Loop over all ents
    for k,ent in pairs(ents) do
        UTIL_RemoveImmediate(ent)
    end
    ents = Entities:FindAllByClassname('npc_dota_barracks')
    for k,ent in pairs(ents) do
        UTIL_RemoveImmediate(ent)
    end
    ents = Entities:FindAllByClassname('ent_dota_fountain')
    for k,ent in pairs(ents) do
        UTIL_RemoveImmediate(ent)
    end
end

local doneInit = false
local loadCommands = function()
    Convars:RegisterCommand('lod_survival', function()
        -- Only server can run this
        if not Convars:GetCommandClient() then
            if doneInit then return end
            doneInit = true

            -- Load up survival XD
            initSurvival()
        end
    end, 'Loader for survival', 0)
end

-- Define exports
module('survival')
LoadCommands = loadCommands
InitSurvival = initSurvival
