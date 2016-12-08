-- Imports
local constants = require('constants')

-- A store for all the net table stuff
local Network = class({})

-- Init network stuff
function Network:init()

end

-- Updates which phase we are currently in
function Network:setPhase(newPhaseNumber)
    CustomNetTables:SetTableValue('phase_pregame', 'phase', {v = newPhaseNumber})
end

-- Sets when this phase will end
function Network:setEndOfPhase(endTime)
    CustomNetTables:SetTableValue('phase_pregame', 'endOfTimer', {v = endTime})
end

-- Sets when this phase will end
function Network:setCustomEndTimer(ply, endTime, freezeTimer)
    if not IsValidEntity(ply) then return end

    -- Push it
    CustomGameEventManager:Send_ServerToPlayer(ply, 'lodCustomTimer', {endTime = endTime, freezeTimer = freezeTimer})
end

-- Freezes the timer on a given number
function Network:freezeTimer(freezeTimer)
    CustomNetTables:SetTableValue('phase_pregame', 'freezeTimer', {v = freezeTimer})
end

-- Sets the active tab
function Network:setActiveOptionsTab(newActiveTab)
    CustomNetTables:SetTableValue('phase_pregame', 'activeTab', {v = newActiveTab})
end

-- Sets the active tab
function Network:showPopup(player, options)
    if not IsValidEntity(player) then return end

    -- Push it
    CustomGameEventManager:Send_ServerToPlayer(player, 'lodShowPopup', options)
end

function Network:changeHost(options)
    -- Ensure we have an options table
    options = options or {}

    -- Push it
    CustomGameEventManager:Send_ServerToAllClients('lodOnHostChanged', options)
end

function Network:changeLock(player, options)
    if not IsValidEntity(player) then return end

    -- Push it
    CustomGameEventManager:Send_ServerToPlayer(player, 'lodChangeLock', options)
end

-- Set an option
function Network:setOption(optionName, optionValue)
    CustomNetTables:SetTableValue('options', optionName, {v = optionValue})
end

-- Sets the network hero data
function Network:setHeroData(heroName, heroData)
    CustomNetTables:SetTableValue('heroes', heroName, heroData)
end

-- Networks flag info
function Network:setFlagData(abilityName, flagData)
    CustomNetTables:SetTableValue('flags', abilityName, flagData)
end

-- Sets a player's selected hero
function Network:setSelectedHero(playerID, heroName)
    CustomNetTables:SetTableValue('selected_heroes', tostring(playerID), {
        heroName = heroName,
        playerID = playerID
    })
    CustomGameEventManager:Send_ServerToAllClients("lodPreloadHeroPanel", {heroName = heroName})
end

-- Sets a player's selected primary attribute
function Network:setSelectedAttr(playerID, newAttr)
    CustomNetTables:SetTableValue('selected_attr', tostring(playerID), {
        newAttr = newAttr,
        playerID = playerID
    })
end

-- Puts a skill into a slot, NO VALIDATION
function Network:setSelectedAbilities(playerID, skills)
    -- Push to everyone
    CustomNetTables:SetTableValue('selected_skills', tostring(playerID), {
        playerID = playerID,
        skills = skills
    })
end

-- Sends a player's potential builds
function Network:setAllRandomBuild(playerID, builds)
    -- Push to everyone
    CustomNetTables:SetTableValue('random_builds', tostring(playerID), {
        playerID = playerID,
        builds = builds
    })
end

-- Sends which networked build has been selected
function Network:setSelectedAllRandomBuild(playerID, selectedBuilds)
    -- Push to everyone
    CustomNetTables:SetTableValue('random_builds', 'selected_' .. tostring(playerID), {
        selected = 1,
        playerID = playerID,
        hero = selectedBuilds.hero,
        build = selectedBuilds.build
    })
end

-- Sends a draft array
function Network:setDraftArray(draftID, draftArray, boosterDraftDone)
    -- Push to everyone
    CustomNetTables:SetTableValue('draft_array', tostring(draftID), {
        draftID = draftID,
        draftArray = draftArray,
        boosterDraftDone = boosterDraftDone
    })
end

-- Sends a player drafted array
function Network:setDraftedAbilities(draftID, draftArray)
    -- Push to everyone
    CustomNetTables:SetTableValue('draft_array', tostring(draftID).."booster", {
        draftID = draftID,
        draftArray = draftArray
    })
end

function Network:hideHeroBuilder(ply, options)
    -- Ensure we have an options table
    options = options or {}

    -- Ensure we have a valid player
    if not IsValidEntity(ply) then return end

    -- Push it
    CustomGameEventManager:Send_ServerToPlayer(ply, 'lodNewHeroBuild', options)
end

function Network:showHeroBuilder(ply, options)
    -- Ensure we have an options table
    options = options or {}

    -- Ensure we have a valid player
    if not IsValidEntity(ply) then return end

    -- Push it
    CustomGameEventManager:Send_ServerToPlayer(ply, 'lodShowIngameBuilder', options)
end

-- Sends a notification to a player
function Network:sendNotification(ply, options)
    -- Ensure we have an options table
    options = options or {}

    -- Ensure we have a valid player
    if not IsValidEntity(ply) then return end

    -- Push it
    CustomGameEventManager:Send_ServerToPlayer(ply, 'lodNotification', options)
end

function Network:showCheatPanel(options)
    -- Ensure we have an options table
    options = options or {}

    -- Push it
    CustomGameEventManager:Send_ServerToAllClients('lodShowCheatPanel', options)
end

-- Sends a notification to all players
function Network:broadcastNotification(options)
    -- Ensure we have an options table
    options = options or {}

    -- Push it
    CustomGameEventManager:Send_ServerToAllClients('lodNotification', options)
end

-- Pushes that a skill is banned
function Network:banAbility(abilityName)
    -- Push to everyone
    CustomNetTables:SetTableValue('banned', abilityName, {
        abilityName = abilityName
    })
end

-- Pushes that a hero is banned
function Network:banHero(heroName)
    -- Push to everyone
    CustomNetTables:SetTableValue('banned', 'hero_' .. heroName, {
        heroName = heroName
    })
end

function Network:enableIngameHeroEditor()

    local options = {}
    -- Push it
    CustomGameEventManager:Send_ServerToAllClients('lodEnableIngameBuilder', options)
end

-- Pushes that a hero is banned
function Network:setTotalBans(playerID, currentHeroBans, currentAbilityBans)
    -- Push to everyone
    CustomNetTables:SetTableValue('banned', 'ban_info_' .. playerID, {
        playerID = playerID,
        currentHeroBans = currentHeroBans,
        currentAbilityBans = currentAbilityBans
    })
end

-- Pushes the ready state
function Network:sendReadyState(readyState)
    -- Push to everyone
    CustomNetTables:SetTableValue('ready', 'ready', readyState)
end

-- Pushes that precaching is done
function Network:donePrecaching()
    -- Push to everyone
    CustomNetTables:SetTableValue('phase_pregame', 'doneCaching', {})
end

-- Shares the vote counts
function Network:voteCounts(counts)
    CustomNetTables:SetTableValue('phase_pregame', 'vote_counts', counts)
end

-- Shares premium info
function Network:setPremiumInfo(info)
    CustomNetTables:SetTableValue('phase_pregame', 'premium_info', info)
end

-- Shares contributor list
function Network:setContributors(info)
    CustomNetTables:SetTableValue('phase_pregame', 'contributors', info)
end

-- Balance request
function Network:setTeamBalanceData(info)
    CustomNetTables:SetTableValue('phase_ingame', 'balance_data', info)
end

-- Gameplay Stats
function Network:sharePlayerStats(stats)
    CustomNetTables:SetTableValue('phase_pregame', 'stats', stats)
end

function Network:sendSpellPrice(ability, price)
    CustomGameEventManager:Send_ServerToAllClients('balance_mode_price', {abilityName = ability, cost = price })
end

function Network:updateFilters()
    CustomGameEventManager:Send_ServerToAllClients('updateFilters', {})
end

-- Sends Troll Combo data
function Network:addTrollCombo(a, b)
    CustomGameEventManager:Send_ServerToAllClients('addTrollCombo', {ab1 = a, ab2 = b})
end

-- Return an instance of it
return Network()