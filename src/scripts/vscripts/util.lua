local Util = {}

-- A store of player names
local storedNames = {}

-- Create list of spells with certain attributes
local chanelledSpells = {}
local targetSpells = {}

-- Grab contributors file
local contributors = LoadKeyValues('scripts/kv/contributors.kv')
local bannedKV = LoadKeyValues('scripts/kv/banned.kv')

-- This function RELIABLY gets a player's name
-- Note: PlayerResource needs to be loaded (aka, after Activated has been called)
--       This method is safe for all of our internal uses
function Util:GetPlayerNameReliable(playerID)
    -- Ensure player resource is ready
    if not PlayerResource then
        return 'PlayerResource not loaded!'
    end

    -- Grab their steamID
    local steamID = tostring(PlayerResource:GetSteamAccountID(playerID) or -1)

    -- Return the name we have set, or call the normal function
    return storedNames[steamID] or PlayerResource:GetPlayerName(playerID)
end

-- Store player names
ListenToGameEvent('player_connect', function(keys)
    -- Grab their steamID
    local steamID64 = tostring(keys.xuid)
    local steamIDPart = tonumber(steamID64:sub(4))
    if not steamIDPart then return end
    local steamID = tostring(steamIDPart - 61197960265728)

    -- Store their name
    storedNames[steamID] = keys.name
end, nil)

-- Encodes a byte to send over the network
-- This function expects a number from 0 - 254
-- This function returns a character, values 1 - 255
function Util:EncodeByte(v)
    -- Check for negative
    if v < 0 then
        print("Warning: Tried to encode a number less than 0! Clamping to 255")
        return string.char(255)
    end

    -- Add one to the value
    v = math.floor(v) + 1

    -- Ensure a valid value
    if v > 255 then
        print("Warning: Tried to encode a number larger than 254! Clamped to 255")
        return string.char(255)
    end
    -- Return the correct character

    return string.char(v)
end

-- Merges the contents of t2 into t1
function Util:MergeTables(t1, t2)
    for k,v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k] or false) == "table" then
                Util:MergeTables(t1[k] or {}, t2[k] or {})
            else
                t1[k] = v
            end
        else
            t1[k] = v
        end
    end
    return t1
end

-- Sets up spell properties
function Util:SetupSpellProperties(abs)
    for k,v in pairs(abs) do
        if k ~= 'Version' and k ~= 'ability_base' then
            if v.AbilityBehavior then
                -- Check if this spell is channelled
                if string.match(v.AbilityBehavior, 'DOTA_ABILITY_BEHAVIOR_CHANNELLED') then
                    chanelledSpells[k] = true
                end

                -- Check if this spell is target based
                if string.match(v.AbilityBehavior, 'DOTA_ABILITY_BEHAVIOR_UNIT_TARGET') then
                    targetSpells[k] = true
                end
            end
        end
    end

    -- techies remote mines are channeled
    --chanelledSpells['techies_remote_mines'] = true
end

-- Tells you if a given spell is channelled or not
function Util:isChannelled(skillName)
    if chanelledSpells[skillName] then
        return true
    end

    return false
end

-- Tells you if a given spell is target based one or not
function Util:isTargetSpell(skillName)
    if targetSpells[skillName] then
        return true
    end

    return false
end

-- Picks a random rune
function Util:pickRandomRune()
    local validRunes = {
        0,
        1,
        2,
        3,
        4,
        5,
        6
    }

    return validRunes[math.random(#validRunes)]
end

-- Returns true if a player is premium
function Util:playerIsPremium(playerID)
    -- Check our premium rank
    return self:getPremiumRank(playerID) > 0
end

-- Returns a player's premium rank
function Util:getPremiumRank(playerID)
    local steamID = PlayerResource:GetSteamAccountID(playerID)
    local conData = contributors[tostring(steamID)]

    -- Default is no premium
    local totalPremium = 0

    -- Check their contributor status
    if conData then
        -- Do they have premium?
        if conData.premium then
            -- Add this to their total premium
            totalPremium = totalPremium + conData.premium
        end
    end

    -- TODO: Check dota tickets

    -- They are not
    return totalPremium
end

-- Returns if a player is a time burger
function Util:isTimeBurgler(playerID)
    local allTimeBurglers = bannedKV.timeburglers

    local steamID = PlayerResource:GetSteamAccountID(playerID)

    return allTimeBurglers[tostring(steamID)] ~= nil 
end

-- Returns a player's voting power
function Util:getVotingPower(playerID)
    -- Are they a time burgler?
    if self:isTimeBurgler(playerID) then
        -- Time burglers get one less vote
        return self:getPremiumRank(playerID)
    end

    return self:getPremiumRank(playerID) + 1
end

-- Attempts to fetch gameinfo of players
function Util:fetchPlayerData()
    local fullPlayerArray = {}

    local maxPlayerID = 24

    for playerID=0,maxPlayerID-1 do
        if PlayerResource:GetConnectionState(playerID) >= 2 then
            local steamID = PlayerResource:GetSteamAccountID(playerID)
            table.insert(fullPlayerArray, steamID)
        end
    end

    local statInfo = LoadKeyValues('scripts/vscripts/statcollection/settings.kv')
    local gameInfoHost = 'https://api.getdotastats.com/player_summary.php'
    
    local payload = {
        modIdentifier = statInfo.modID,
        schemaVersion = 1,
        players = fullPlayerArray
    }

    -- Make the request
    local req = CreateHTTPRequest('POST', gameInfoHost)

    -- Add the data
    req:SetHTTPRequestGetOrPostParameter('payload', json.encode(payload))

    -- Send the request
    req:Send(function(res)
        if res.StatusCode ~= 200 or not res.Body then
            print('Failed to query for player info!')
            return
        end

        -- Try to decode the result
        local obj, pos, err = json.decode(res.Body, 1, nil)

        -- Feed the result into our callback
        if err then
            print(err)
            return
        end

        if obj and obj.result then
            local mapData = {}

            for k,data in pairs(obj.result) do
                local steamID = data.steamID32
                local lastUpdateRaw = data.dataUpdated
                local lastAbandonRaw = data.lastAbandon
                local totalAbandons = data.numAbandons
                local totalWins = data.numWins
                local totalGames = data.numGames
                local numFails = data.numFails

                mapData[steamID] = {
                    lastUpdateRaw = lastUpdateRaw,
                    lastUpdate = GameRules.util:parseTime(lastUpdateRaw),
                    lastAbandonRaw = lastAbandonRaw,
                    lastAbandon = GameRules.util:parseTime(lastAbandonRaw),
                    totalAbandons = totalAbandons,
                    totalWins = totalWins,
                    totalGames = totalGames,
                    numFails = numFails
                }
            end

            -- Push to pregame
            GameRules.pregame:onGetPlayerData(mapData)
        end
    end)
end

-- Parses a time
function Util:parseTime(timeString)
    timeString = timeString or ''

    local year = 2016
    local month = 04
    local day = 29

    local hour = 17
    local minute = 43
    local second = 0

    local parts = timeString:gmatch(' ')
    if parts == 2 then
        print('woot!')
    end

    return {
        year = year,
        month = month,
        day = day,

        hour = hour,
        minute = minute,
        second = second
    }
end

-- Returns a set of abilities that won't trigger stuff like aftershock / essence aura
local toIgnore
function Util:getToggleIgnores()
    return toIgnore
end

(function()
    toIgnore = {
        nyx_assassin_burrow = true,
        spectre_reality = true,
        techies_focused_detonate = true,
        furion_teleportation = true,
    }

    local abs = LoadKeyValues('scripts/npc/npc_abilities.txt')
    local absCustom = LoadKeyValues('scripts/npc/npc_abilities_custom.txt')

    for k,v in pairs(absCustom) do
        abs[k] = v
    end

    for abilityName,data in pairs(abs) do
        if type(data) == 'table' then
            if data.AbilityBehavior and string.match(data.AbilityBehavior, 'DOTA_ABILITY_BEHAVIOR_TOGGLE') then
                toIgnore[abilityName] = true
            end
        end
    end

    -- No items
    local items = LoadKeyValues('scripts/npc/items.txt')
    for abilityName,data in pairs(items) do
        toIgnore[abilityName] = true
    end
end)()

-- Define the export
return Util