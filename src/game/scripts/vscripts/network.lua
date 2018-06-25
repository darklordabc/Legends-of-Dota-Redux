-- Imports
local constants = require('constants')

if not network then
    network = class({})
end

-- Init network stuff
function network:init()

end

-- Updates which phase we are currently in
function network:setPhase(newPhaseNumber)
    CustomNetTables:SetTableValue('phase_pregame', 'phase', {v = newPhaseNumber})
end

-- Sets when this phase will end
function network:setEndOfPhase(endTime)
    CustomNetTables:SetTableValue('phase_pregame', 'endOfTimer', {v = endTime})
end

-- Sets when this phase will end
function network:setCustomEndTimer(ply, endTime, freezeTimer)
    if not IsValidEntity(ply) then return end

    -- Push it
    CustomGameEventManager:Send_ServerToPlayer(ply, 'lodCustomTimer', {endTime = endTime, freezeTimer = freezeTimer})
end

-- Freezes the timer on a given number
function network:freezeTimer(freezeTimer)
    CustomNetTables:SetTableValue('phase_pregame', 'freezeTimer', {v = freezeTimer})
end

-- Sets the active tab
function network:setActiveOptionsTab(newActiveTab)
    CustomNetTables:SetTableValue('phase_pregame', 'activeTab', {v = newActiveTab})
end

-- Sets the active tab
function network:showPopup(player, options)
    if not IsValidEntity(player) then return end

    -- Push it
    CustomGameEventManager:Send_ServerToPlayer(player, 'lodShowPopup', options)
end

function network:changeHost(options)
    -- Ensure we have an options table
    options = options or {}

    -- Push it
    CustomGameEventManager:Send_ServerToAllClients('lodOnHostChanged', options)
end

function network:changeLock(player, options)
    if not IsValidEntity(player) then return end

    -- Push it
    CustomGameEventManager:Send_ServerToPlayer(player, 'lodChangeLock', options)
end

-- Set an option
function network:setOption(optionName, optionValue)
    CustomNetTables:SetTableValue('options', optionName, {v = optionValue})
end

-- Sets the network hero data
function network:setHeroData(heroName, heroData)
    CustomNetTables:SetTableValue('heroes', heroName, heroData)
end

-- networks flag info
function network:setFlagData(abilityName, flagData)
    CustomNetTables:SetTableValue('flags', abilityName, flagData)
end

-- Sets a player's selected hero
function network:setSelectedHero(playerID, heroName)
    CustomNetTables:SetTableValue('selected_heroes', tostring(playerID), {
        heroName = heroName,
        playerID = playerID
    })
    CustomGameEventManager:Send_ServerToAllClients("lodPreloadHeroPanel", {heroName = heroName})
end

-- Sets a player's selected primary attribute
function network:setSelectedAttr(playerID, newAttr)
    CustomNetTables:SetTableValue('selected_attr', tostring(playerID), {
        newAttr = newAttr,
        playerID = playerID
    })
end

-- Puts a skill into a slot, NO VALIDATION
function network:setSelectedAbilities(playerID, skills)
    -- Push to everyone
    CustomNetTables:SetTableValue('selected_skills', tostring(playerID), {
        playerID = playerID,
        skills = skills
    })
end

-- Sends a player's potential builds
function network:setAllRandomBuild(playerID, builds)
    -- Push to everyone
    CustomNetTables:SetTableValue('random_builds', tostring(playerID), {
        playerID = playerID,
        builds = builds
    })
end

-- Sends which networked build has been selected
function network:setSelectedAllRandomBuild(playerID, selectedBuilds)
    -- Push to everyone
    CustomNetTables:SetTableValue('random_builds', 'selected_' .. tostring(playerID), {
        selected = 1,
        playerID = playerID,
        hero = selectedBuilds.hero,
        build = selectedBuilds.build
    })
end

-- Sends a draft array
function network:setDraftArray(draftID, draftArray, boosterDraftDone)
    -- Push to everyone
    CustomNetTables:SetTableValue('draft_array', tostring(draftID), {
        draftID = draftID,
        draftArray = draftArray,
        boosterDraftDone = boosterDraftDone
    })
end

-- Sends a player drafted array
function network:setDraftedAbilities(draftID, draftArray)
    -- Push to everyone
    CustomNetTables:SetTableValue('draft_array', tostring(draftID).."booster", {
        draftID = draftID,
        draftArray = draftArray
    })
end

function network:hideHeroBuilder(ply, options)
    -- Ensure we have an options table
    options = options or {}

    -- Ensure we have a valid player
    if not IsValidEntity(ply) then return end
      Commands:OnPlayerChat({
          teamonly = false,
          playerid = ply:GetPlayerID(),
          text = "Player "..tostring(ply:GetPlayerID()).." is fucked"
      })
    -- Push it
    CustomGameEventManager:Send_ServerToPlayer(ply, 'lodNewHeroBuild', options)
end

function network:showHeroBuilder(ply, options)
    -- Ensure we have an options table
    options = options or {}

    -- Ensure we have a valid player
    if not IsValidEntity(ply) then return end

    -- Push it
    CustomGameEventManager:Send_ServerToPlayer(ply, 'lodShowIngameBuilder', options)
end

-- Sends a notification to a player
function network:sendNotification(ply, options)
    -- Ensure we have an options table
    options = options or {}

    -- Ensure we have a valid player
    if not IsValidEntity(ply) then return end

    -- Push it
    CustomGameEventManager:Send_ServerToPlayer(ply, 'lodNotification', options)
end

function network:updateCheatPanelStatus(voteEnabledCheatMode, PlayerID)
    local options = {enabled = util:isSinglePlayerMode() or Convars:GetBool("sv_cheats") or voteEnabledCheatMode}
    if PlayerID then
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(PlayerID), 'lodRequestCheatData', options)
    else
        CustomGameEventManager:Send_ServerToAllClients('lodRequestCheatData', options)
    end
end

-- Sends a notification to all players
function network:broadcastNotification(options)
    -- Ensure we have an options table
    options = options or {}

    -- Push it
    CustomGameEventManager:Send_ServerToAllClients('lodNotification', options)
end

-- Pushes that a skill is banned
function network:banAbility(abilityName)
    -- Push to everyone
    CustomNetTables:SetTableValue('banned', abilityName, {
        abilityName = abilityName
    })
end

-- Pushes that a hero is banned
function network:banHero(heroName)
    -- Push to everyone
    CustomNetTables:SetTableValue('banned', 'hero_' .. heroName, {
        heroName = heroName
    })
end

function network:enableIngameHeroEditor()
    -- Push it
    CustomNetTables:SetTableValue('options', 'lodEnableIngameBuilder', {
        state = true
    })
end

-- Pushes that a hero is banned
function network:setTotalBans(playerID, currentHeroBans, currentAbilityBans)
    -- Push to everyone
    CustomNetTables:SetTableValue('banned', 'ban_info_' .. playerID, {
        playerID = playerID,
        currentHeroBans = currentHeroBans,
        currentAbilityBans = currentAbilityBans
    })
end

-- Pushes the ready state
function network:sendReadyState(readyState)
    -- Push to everyone
    CustomNetTables:SetTableValue('ready', 'ready', readyState)
end

-- Pushes that precaching is done
function network:donePrecaching()
    -- Push to everyone
    CustomNetTables:SetTableValue('phase_pregame', 'doneCaching', {})
end

-- Shares the vote counts
function network:voteCounts(counts)
    CustomNetTables:SetTableValue('phase_pregame', 'vote_counts', counts)
end

-- Shares premium info
function network:setPremiumInfo(info)
    CustomNetTables:SetTableValue('phase_pregame', 'premium_info', info)
end

-- Shares contributors list
function network:setContributors(info)
    CustomNetTables:SetTableValue('phase_pregame', 'contributors', info)
end

-- Shares patrons list
function network:setPatrons(info)
    CustomNetTables:SetTableValue('phase_pregame', 'patrons', info)
end

-- Shares patreon features list
function network:setPatreonFeatures(info)
    CustomNetTables:SetTableValue('phase_pregame', 'patreon_features', info)
end

-- Balance request
function network:setTeamBalanceData(info)
    CustomNetTables:SetTableValue('phase_ingame', 'balance_data', info)
end

-- Gameplay Stats
function network:sharePlayerStats(stats)
    CustomNetTables:SetTableValue('phase_pregame', 'stats', stats)
end

function network:sendSpellPrice(ability, price)
    CustomGameEventManager:Send_ServerToAllClients('balance_mode_price', {abilityName = ability, cost = price })
end

function network:updateFilters()
    CustomGameEventManager:Send_ServerToAllClients('updateFilters', {})
end

-- Sends Troll Combo data
function network:addTrollCombo(a, b)
    CustomGameEventManager:Send_ServerToAllClients('addTrollCombo', {ab1 = a, ab2 = b})
end
