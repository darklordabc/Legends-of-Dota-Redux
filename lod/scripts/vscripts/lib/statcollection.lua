--[[
Usage:

You firstly need to include the module like so:

require('lib.statcollection')

You can then begin to collect stats like this:

statcollection.addStats({
    modID = 'YourUniqueModID',
    someStat = 'someOtherValue'
})

You can call statcollection.addStats() with a table at any stage to add new stats,
old stats will still remain, if you provide new values, the new values will override
the old values.

When you're ready to store the stats (only call this once!)

statcollection.sendStats({
    anyExtraStats = 'WhatEver'
})

The statcollection.sendStats() can either be called blank, or with a table of extra
stats, if you've already added all the stats using addStats, then you can simply
call this function with no arguments.

Readers beware: You are REQUIRED to set AT LEAST modID to your mods unique ID
]]

-- Begin statcollection module
module('statcollection', package.seeall)

-- Require libs
local JSON = require('lib.json')
local md5 = require('lib.md5')

-- Max number of players
local maxPlayers = 10

-- A table of stats we have collected
local collectedStats = {}

-- Makes sure we don't call the stat collection multiple times
local alreadySubmitted = false

-- This function should be called with a table of stats to add
function addStats(toSearch)
    -- Ensure args were passed
    toSearch = toSearch or {}

    -- Store the fields
    for k,v in pairs(toSearch) do
        collectedStats[k] = v
    end
end

-- This function adds a single stat, but wont override existing stats
function addStatsSafe(name, value)
    -- Ensure the stat doesn't exist
    if collectedStats[name] == nil then
        -- Store the new value
        collectedStats[name] = value
    end
end

-- Function to send stats
function sendStats(extraFields)
    -- Ensure it is only called once
    if alreadySubmitted then
        print('ERROR: You have already called statcollection.sendStats()')
        return
    end

    -- Ensure some stats were passed
    extraFields = extraFields or {}

    -- Copy in the extra fields
    for k,v in pairs(extraFields) do
        -- Ensure the field doesn't already exist
        if not collectedStats[k] then
            collectedStats[k] = v
        end
    end

    -- Check if the modID has been set
    if not collectedStats.modID then
        print('ERROR: Please call statcollection.addStats() with modID!')
        return
    end

    -- Build common stats
    addStatsSafe('duration', GameRules:GetGameTime())

    -- Build player array
    local playersData = {}
    for i=0, maxPlayers-1 do
        -- Ensure we have a valid player in this slot
        if PlayerResource:IsValidPlayer(i) then
            -- Grab their teamID
            local teamID = PlayerResource:GetTeam(i)

            -- Attempt to find hero data
            local heroData, itemData
            local hero = PlayerResource:GetSelectedHeroEntity(i)
            if IsValidEntity(hero) then
                -- Build ability data
                local abilityData = {}
                local abilityCount = 0
                while abilityCount < 32 do
                    -- Grab an ability
                    local ab = hero:GetAbilityByIndex(abilityCount)

                    -- Check if it is valid
                    if IsValidEntity(ab) then
                        -- Store ability
                        table.insert(abilityData, {
                            --abilityID = ab:GetAbilityIndex(),
                            abilityName = ab:GetClassname(),
                            level = ab:GetLevel()
                        })
                    end

                    -- Move onto the next ability slot
                    abilityCount = abilityCount + 1
                end

                -- Build item data
                itemData = {}
                local itemCount = 0
                while itemCount < 12 do
                    -- Grab an item
                    local item = hero:GetItemInSlot(itemCount)

                    -- Check if the item is valid
                    if IsValidEntity(item) then
                        -- Store the item
                        table.insert(itemData, {
                            --itemID = item:GetAbilityIndex(),
                            itemName = item:GetClassname(),
                            itemStartTime = item:GetPurchaseTime()
                        })
                    end

                    -- Move onto the next item
                    itemCount = itemCount + 1
                end

                -- Store hero info
                heroData = {
                    heroID = PlayerResource:GetSelectedHeroID(i),
                    level = PlayerResource:GetLevel(i),
                    kills = PlayerResource:GetKills(i),
                    assists = PlayerResource:GetAssists(i),
                    deaths = PlayerResource:GetDeaths(i),
                    abilities = abilityData
                }

            end

            -- Attempt to find their slotID
            local slotID
            for j=0, maxPlayers do
                if PlayerResource:GetNthPlayerIDOnTeam(teamID, j) then
                    slotID = j
                    break
                end
            end

            local playerData = {
                playerName = PlayerResource:GetPlayerName(i),
                steamID32 = PlayerResource:GetSteamAccountID(i),
                teamID = teamID,
                slotID = slotID,
                hero = heroData,
                items = itemData
            }

            -- Store the data
            table.insert(playersData, playerData)
        end

        -- Add round data
        addStatsSafe('rounds', {
            players = playersData
        })
    end

    -- Print out the collected stats
    DeepPrintTable(collectedStats)

    -- Tell the user the stats are being sent
    print('Sending stats...')

    -- Stop this function from being called again
    alreadySubmitted = true

    -- Grab useful info to make a 'unique' hash
    local currentTime = GetSystemTime()
    local ip = Convars:GetStr('hostip')
    local port = Convars:GetStr('hostport')
    local randomness = RandomFloat(0, 1)..'/'..RandomFloat(0, 1)..'/'..RandomFloat(0, 1)..'/'..RandomFloat(0, 1)..'/'..RandomFloat(0, 1)

    -- Setup the string to be hashed
    local toHash = ip..':'..port..' @ '..currentTime..' + '..randomness..' + '

    -- Add all the fields into the toHash
    for k,v in pairs(collectedStats) do
        toHash = toHash..tostring(k)..'='..tostring(v)..','
    end

    -- Store the unique match ID
    collectedStats.matchID = md5.sumhexa(toHash)

    -- Send the message
    FireGameEvent("stat_collection", {
        json = JSON:encode(collectedStats)
    })
end
