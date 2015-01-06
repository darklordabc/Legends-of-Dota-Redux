-- A store of player names
local storedNames = {}

-- This function RELIABLY gets a player's name
-- Note: PlayerResource needs to be loaded (aka, after Activated has been called)
--       This method is safe for all of our internal uses
local function getPlayerNameReliable(playerID)
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
function encodeByte(v)
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

-- Define exports
module('util')

GetPlayerNameReliable   = getPlayerNameReliable
EncodeByte              = encodeByte
