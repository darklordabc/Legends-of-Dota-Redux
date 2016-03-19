local Util = {}

-- A store of player names
local storedNames = {}

-- Create list of spells with certain attributes
local chanelledSpells = {}
local targetSpells = {}

-- Grab contributors file
local contributors = LoadKeyValues('scripts/kv/contributors.kv')

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

-- Define the export
return Util