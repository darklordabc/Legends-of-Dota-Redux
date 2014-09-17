--[[
Usage:

statcollection.addStats({
    modID = 'YourUniqueModID',
    someStat = 'someOtherValue'
})

You can call statcollection.addStats() with a table at any stage to add new stats,
old stats will still remain, if you provide new values, the new values will override
the old values.

statcollection.sendStats({
    anyExtraStats = 'WhatEver'
})

The statcollection.sendStats() can either be called blank, or with a table of extra
stats, if you've already added all the stats using addStats, then you can simply
call this function with no arguments.

Readers beware: You are REQUIRED to set AT LEAST modID to your mods unique ID
]]


-- Require libs
local JSON = require('lib.json')
local md5 = require('lib.md5')

-- Begin statcollection module
module('statcollection', package.seeall)

-- The extra fields to copy into the stats
local extraFields = {}

-- This function should be called to setup the module
function addStats(args)
    -- Ensure args were passed
    local toSearch = args[1] or {}

    -- Check if the modID has been set
    if not toSearch.modID then
        print('ERROR: Please call statcollection.addStats() with modID!')
        return
    end

    -- Store the fields
    for k,v in pairs(toSearch) do
        extraFields[k] = v
    end
end

-- Function to send stats
function sendStats(args)
    -- Ensure some stats were passed
    local extrafields = (args and args[1]) or {}

    -- Check if the modID has been set
    if not extraFields.modID then
        print('ERROR: Please call statcollection.addStats() with modID!')
        return
    end

    -- Grab useful info to make a 'unique' hash
    local currentTime = GetSystemTime()
    local ip = Convars:GetStr('hostip')
    local port = Convars:GetStr('hostport')
    local randomness = RandomFloat(0, 1)..'/'..RandomFloat(0, 1)..'/'..RandomFloat(0, 1)..'/'..RandomFloat(0, 1)..'/'..RandomFloat(0, 1)

    -- Setup the string to be hashed
    local toHash = ip..':'..port..' @ '..currentTime..' + '..randomness..' + '

    -- Build the stats array
    local stats = {}

    -- Copy in the extra fields
    for k,v in pairs(extraFields) do
        -- Ensure the field doesn't already exist
        if not stats[k] then
            stats[k] = v
        end
    end

    -- Add all the fields into the toHash
    for k,v in pairs(stats) do
        toHash = toHash..tostring(k)..'='..tostring(v)..','
    end

    -- Store the unique match ID
    stats.matchID = md5.sumhexa(toHash)

    -- Send the message
    FireGameEvent("stat_collection", {
        json = JSON:encode(stats)
    })
end
