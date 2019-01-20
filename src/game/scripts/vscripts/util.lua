if not util then
    util = class({})
end

-- A store of player names
local storedNames = {}

-- Create list of spells with certain attributes
local chanelledSpells = {}
local targetSpells = {}
local regularSpells = LoadKeyValues('scripts/npc/npc_abilities.txt')

-- Grab steamid data
util.contributors = util.contributors or LoadKeyValues('scripts/kv/contributors.kv')
util.patrons = util.patrons or LoadKeyValues('scripts/kv/patrons.kv')
util.patreon_features = util.patreon_features or LoadKeyValues('scripts/kv/patreon_features.kv')
util.bannedKV = util.bannedKV or LoadKeyValues('scripts/kv/banned.kv')

function CDOTABaseAbility:GetTalentSpecialValueFor(value)
    local base = self:GetSpecialValueFor(value)
    local talentName
    local kv = self:GetAbilityKeyValues()
    for k,v in pairs(kv) do -- trawl through keyvalues
        if k == "AbilitySpecial" then
            for l,m in pairs(v) do
                if m[value] then
                    talentName = m["LinkedSpecialBonus"]
                end
            end
        end
    end
    if talentName then
        local talent = self:GetCaster():FindAbilityByName(talentName)
        if talent and talent:GetLevel() > 0 then base = base + talent:GetSpecialValueFor("value") end
    end
    return base
end

-- This function RELIABLY gets a player's name
-- Note: PlayerResource needs to be loaded (aka, after Activated has been called)
--       This method is safe for all of our internal uses
function util:GetPlayerNameReliable(playerID)
    -- Ensure player resource is ready
    if not PlayerResource then
        return 'PlayerResource not loaded!'
    end

    -- Grab their steamID
    local steamID = tostring(PlayerResource:GetSteamAccountID(playerID) or -1)

    -- Return the name we have set, or call the normal function
    return storedNames[steamID] or PlayerResource:GetPlayerName(playerID)
end

-- Round number
function util:round(num, idp)
    if num >= 0 then return math.floor(num+.5)
    else return math.ceil(num-.5) end
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
function util:EncodeByte(v)
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
function util:MergeTables(t1, t2)
    for k,v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k] or false) == "table" then
                util:MergeTables(t1[k] or {}, t2[k] or {})
            else
                t1[k] = v
            end
        else
            t1[k] = v
        end
    end
    return t1
end

function util:DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[self:DeepCopy(orig_key)] = self:DeepCopy(orig_value)
        end
        setmetatable(copy, self:DeepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- Sets up spell properties
function util:SetupSpellProperties(abs)
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
function util:isChannelled(skillName)
    if chanelledSpells[skillName] then
        return true
    end

    return false
end

-- Tells you if a given spell is target based one or not
function util:isTargetSpell(skillName)
    if targetSpells[skillName] then
        return true
    end

    return false
end

-- Picks a random rune
function util:pickRandomRune()
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


function util:sortTable(input)
    local array = {}
    for heroName in pairs(input) do
        array[heroName] = {}
        while #array[heroName] ~= self:getTableLength(input[heroName]) do
            for abilityName, position in pairs(input[heroName]) do
                if self:getTableLength(array[heroName])+1 == tonumber(position) then
                    table.insert(array[heroName], abilityName)
                end
            end
        end
    end
    return array
end

function util:swapTable(input)
    local array = {}
    for k,v in pairs(input) do
        if type(v) == 'table' then
            array[k] = self:swapTable(v)
        else
            table.insert(array, k)
        end
    end
    return array
end


-- Returns true if a player is premium
function util:playerIsPremium(playerID)
    -- Check our premium rank
    return self:getPremiumRank(playerID) > 0
end

-- Returns true if a player is bot
function util:isPlayerBot(playerID)
    return PlayerResource:GetSteamAccountID(playerID) == 0
end

-- Returns a player's premium rank
function util:getPremiumRank(playerID)
    local steamID = tostring(PlayerResource:GetSteamAccountID(playerID))
    local conData

    for k,v in pairs(util.contributors) do
        if tostring(v.steamID3) == steamID then
            conData = v
            break
        end
    end

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


function isPlayerHost(player)
    if type(player) == 'number' then
        player = PlayerResource:GetPlayer(player)
    end
    return player.isHost
end

function setPlayerHost(oldHost, newHost)
    if isPlayerHost(oldHost) then
        oldHost.isHost = nil
        newHost.isHost = true
    end
end

function getPlayerHost()
    for i=0,DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayer(i) then
            local player = PlayerResource:GetPlayer(i)
            if player and player.isHost then
                return player
            end
        end
    end
end


function util:GetActivePlayerCountForTeam(team)
    local number = 0
    for x=0,DOTA_MAX_TEAM do
        local pID = PlayerResource:GetNthPlayerIDOnTeam(team,x)
        if PlayerResource:IsValidPlayerID(pID) and (PlayerResource:GetConnectionState(pID) == 1 or PlayerResource:GetConnectionState(pID) == 2) then
            number = number + 1
        end
    end
    return number
end

function util:GetActiveHumanPlayerCountForTeam(team)
    local number = 0
    for x=0,DOTA_MAX_TEAM do
        local pID = PlayerResource:GetNthPlayerIDOnTeam(team,x)
        if PlayerResource:IsValidPlayerID(pID) and not self:isPlayerBot(pID) and (PlayerResource:GetConnectionState(pID) == 1 or PlayerResource:GetConnectionState(pID) == 2) then
            number = number + 1
        end
    end
    return number
end

function util:secondsToClock(seconds)
  local seconds = math.abs(tonumber(seconds))

  if seconds <= 0 then
    return "00:00";
  else
    mins = string.format("%02.f", math.floor(seconds/60));
    secs = string.format("%02.f", math.floor(seconds - mins *60));
    return mins..":"..secs
  end
end

-- Returns if a player is a time burger
function util:isTimeBurgler(playerID)
    local allTimeBurglers = util.bannedKV.timeburglers

    local steamID = PlayerResource:GetSteamAccountID(playerID)

    return allTimeBurglers[tostring(steamID)] ~= nil
end

-- Returns a player's voting power
function util:getVotingPower(playerID)
    -- Are they a time burgler?
    if self:isTimeBurgler(playerID) then
        -- Time burglers get one less vote
        return self:getPremiumRank(playerID)
    end

    return self:getPremiumRank(playerID) + 1
end

-- Attempts to fetch gameinfo of players
function util:fetchPlayerData()
    local this = self

    -- Protected call
    local status, err = pcall(function()
        -- Only fetch player data once
        if this.fetchedPlayerData then return end

        local fullPlayerArray = {}

        local maxPlayerID = 24

        for playerID=0,maxPlayerID-1 do
            local steamID = PlayerResource:GetSteamAccountID(playerID)
            if steamID ~= 0 then
                table.insert(fullPlayerArray, steamID)
            end
        end

        -- Did we fail to find anyone?
        if #fullPlayerArray <= 0 then return end

        local statInfo = LoadKeyValues('scripts/vscripts/statcollection/settings.kv')
        local gameInfoHost = 'https://api.getdotastats.com/player_summary.php'

        local payload = {
            modIdentifier = statInfo.modID,
            schemaVersion = 1,
            players = fullPlayerArray
        }

        -- Make the request
        local req = CreateHTTPRequestScriptVM('POST', gameInfoHost)

        if not req then return end
        this.fetchedPlayerData = true

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
                    local steamID = tostring(data.sid)

                    local totalAbandons = data.na
                    local totalWins = data.nw
                    local totalGames = data.ng
                    local totalFails = data.nf

                    local lastAbandon = data.la
                    local lastFail = data.lf
                    local lastGame = data.lr
                    local lastUpdate = data.lu

                    mapData[steamID] = {
                        totalAbandons = totalAbandons,
                        totalWins = totalWins,
                        totalGames = totalGames,
                        totalFails = totalFails,

                        lastAbandon = lastAbandon,
                        lastFail = lastFail,
                        lastGame = lastGame,
                        lastUpdate = lastUpdate
                    }
                end

                -- Push to pregame
                GameRules.pregame:onGetPlayerData(mapData)
            end
        end)
    end)

    -- Failure?
    if not status then
        this.fetchedPlayerData = nil
    end
end

function util:split(pString, pPattern)
    local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
    local fpat = '(.-)' .. pPattern
    local last_end = 1
    local s, e, cap = pString:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= '' then
            table.insert(Table,cap)
        end
        last_end = e+1
        s, e, cap = pString:find(fpat, last_end)
    end
    if last_end <= #pString then
        cap = pString:sub(last_end)
        table.insert(Table, cap)
    end

    return Table
end

-- Works out the time difference between two LoD times
function util:timeDifference(lodCurrentTime, lodPreviousTime)
    return self:countSeconds(lodCurrentTime) - self:countSeconds(lodPreviousTime)
end

-- Calculates how many seconds in the given LoD timestamp
function util:countSeconds(lodTime)
    local seconds = lodTime.second
    local minuteSeconds = lodTime.minute * 60
    local hourSeconds = lodTime.hour * 60 * 60

    local daySeconds = lodTime.day * 60 * 60 * 24
    local monthSeconds = self:getDaysInPreviousMonths(lodTime.month) * 60 * 60 * 24
    local yearSeconds = lodTime.year * 60 * 60 * 24 * 365

    -- Add all the seconds together
    return seconds + minuteSeconds + hourSeconds + daySeconds + monthSeconds + yearSeconds
end

-- Works out how many days have passed in order to get to the given month
function util:getDaysInPreviousMonths(currentMonth)
    local daysInMonth = {
        [1] = 31,
        [2] = 28,
        [3] = 31,
        [4] = 30,
        [5] = 31,
        [6] = 30,
        [7] = 31,
        [8] = 31,
        [9] = 30,
        [10] = 31,
        [11] = 30,
        [12] = 31
    }

    local total = 0

    for i=1,(currentMonth-1) do
        total = total + daysInMonth[i] or 0
    end

    return total
end

-- Parses a time
function util:parseTime(timeString)
    timeString = timeString or ''

    local year = 0
    local month = 0
    local day = 0

    local hour = 0
    local minute = 0
    local second = 0

    local parts = self:split(timeString, '%s')

    if #parts == 2 then
        local dateParts = self:split(parts[1], '-')
        local timeParts = self:split(parts[2], ':')

        year = tonumber(dateParts[1])
        month = tonumber(dateParts[2])
        day = tonumber(dateParts[3])

        hour = tonumber(timeParts[1])
        minute = tonumber(timeParts[2])
        second = tonumber(timeParts[3])
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

function util:getTableLength(t)
  if not t then return nil end
  local length = 0

  for k,v in pairs(t) do
    length = length + 1
  end

  return length
end

function CDOTABaseAbility:GetAbilityLifeTime(buffer)
    local kv = self:GetAbilityKeyValues()
    local duration = self:GetDuration()
    local delay = 0
    if not duration then duration = 0 end
    if self:GetChannelTime() > duration then duration = self:GetChannelTime() end
    for k,v in pairs(kv) do -- trawl through keyvalues
        if k == "AbilitySpecial" then
            for l,m in pairs(v) do
                for o,p in pairs(m) do
                    if string.match(o, "duration") then -- look for the highest duration keyvalue
                        checkDuration = self:GetLevelSpecialValueFor(o, -1)
                        if checkDuration > duration then duration = checkDuration end
                    elseif string.match(o, "delay") then -- look for a delay for spells without duration but do have a delay
                        checkDelay = self:GetLevelSpecialValueFor(o, -1)
                        if checkDelay > duration then delay = checkDelay end
          end
                end
            end
        end
    end
  ------------------------------ SPECIAL CASES -----------------------------
  if self:GetName() == "juggernaut_omni_slash" then
    local bounces = self:GetLevelSpecialValueFor("omni_slash_jumps", -1)
    delay = self:GetLevelSpecialValueFor("omni_slash_bounce_tick", -1) * bounces
  elseif self:GetName() == "medusa_mystic_snake" then
    local bounces = self:GetLevelSpecialValueFor("snake_jumps", -1)
    delay = self:GetLevelSpecialValueFor("jump_delay", -1) * bounces
  elseif self:GetName() == "witch_doctor_paralyzing_cask" then
    local bounces = self:GetLevelSpecialValueFor("bounces", -1)
    delay = self:GetLevelSpecialValueFor("bounce_delay", -1) * bounces
  elseif self:GetName() == "zuus_arc_lightning" or self:GetName() == "leshrac_lightning_storm" then
    local bounces = self:GetLevelSpecialValueFor("jump_count", -1)
    delay = self:GetLevelSpecialValueFor("jump_delay", -1) * bounces
  elseif self:GetName() == "furion_wrath_of_nature" then
    local bounces = self:GetLevelSpecialValueFor("max_targets_scepter", -1)
    delay = self:GetLevelSpecialValueFor("jump_delay", -1) * bounces
  elseif self:GetName() == "death_prophet_exorcism" then
    local distance = self:GetLevelSpecialValueFor("max_distance", -1) + 2000 -- add spirit break distance to be sure
    delay = distance / self:GetLevelSpecialValueFor("spirit_speed", -1)
  elseif self:GetName() == "necrolyse_death_pulse" then
    local distance = self:GetLevelSpecialValueFor("area_of_effect", -1) + 2000 -- add blink range + buffer zone to be safe
    delay = distance / self:GetLevelSpecialValueFor("projectile_speed", -1)
  elseif self:GetName() == "spirit_breaker_charge_of_darkness" then
    local distance = math.sqrt(15000*15000*2) -- size diagonal of a 15000x15000 square
    delay = distance / self:GetLevelSpecialValueFor("movement_speed", -1)
  end
  --------------------------------------------------------------------------
    duration = duration + delay
    if buffer then duration = duration + buffer end
    return duration
end

function DebugCalls()
    if not GameRules.DebugCalls then
        print("Starting DebugCalls")
        GameRules.DebugCalls = true

        debug.sethook(function(...)
            local info = debug.getinfo(2)
            local src = tostring(info.short_src)
            local name = tostring(info.name)
            if name ~= "__index" then
                print("Call: ".. src .. " -- " .. name)
            end
        end, "c")
    else
        print("Stopped DebugCalls")
        GameRules.DebugCalls = false
        debug.sethook(nil, "c")
    end
end


function CDOTA_BaseNPC:GetAbilityCount()
    local count = 0
    for i=0,23 do
        if self:GetAbilityByIndex(i) then
            count = count + 1
        end
    end
    return count
end


function CDOTA_BaseNPC:GetUnsafeAbilitiesCount()
    local count = 0
    local randomKv = self.randomKv
    for i=0,23 do
        if self:GetAbilityByIndex(i) then
            local ability = self:GetAbilityByIndex(i)
            local name = ability:GetName()
            if not randomKv["Safe"][name] and name ~= "attribute_bonus" and not self.ownedSkill[name] then
                count = count + 1
            end
        end
    end
    return count
end


function CDOTA_BaseNPC:GetCastRangeIncrease()
 local range = 0
 local stack_range = 0
 for _, parent_modifier in pairs(self:FindAllModifiers()) do
   if parent_modifier.GetModifierCastRangeBonus then
     range = math.max(range,parent_modifier:GetModifierCastRangeBonus())
   end
   if parent_modifier.GetModifierCastRangeBonusStacking then
     stack_range = stack_range + parent_modifier:GetModifierCastRangeBonusStacking()
   end
 end
 local hTalent = nil
 for talent_name,talent_range_bonus in pairs(CAST_RANGE_TALENTS) do
   hTalent = self:FindAbilityByName(talent_name)
   if hTalent ~= nil and hTalent:GetLevel() > 0 then
     stack_range = stack_range + talent_range_bonus
   end
   hTalent = nil
 end
 return range + stack_range
end

function CDOTABaseAbility:GetTrueCooldown()
  if Convars:GetBool('dota_ability_debug') then return 0 end
  local cooldown = self:GetCooldown(-1)
  local hero = self:GetCaster()
  local mabWitch = hero:FindAbilityByName('death_prophet_witchcraft')
  if mabWitch then cooldown = cooldown - mabWitch:GetLevel() end
  local cooldown_reduct = 0
  local cooldown_reduct_stack = 0
  for k,v in pairs(hero:FindAllModifiers()) do
      if v.GetModifierPercentageCooldown then
        cooldown_reduct = math.max(cooldown_reduct,v:GetModifierPercentageCooldown())
      end
      if v.GetModifierPercentageCooldownStacking then
        cooldown_reduct_stack = cooldown_reduct_stack + v:GetModifierPercentageCooldownStacking()
      end
  end
  cooldown = cooldown * math.max(0.01,(1 - (cooldown_reduct + cooldown_reduct_stack)*0.01))
  return cooldown
end

function CDOTA_BaseNPC:GetCooldownReduction()
  if Convars:GetBool('dota_ability_debug') then return 0 end
  local hero = self

  local cooldown_reduct = 0
  local cooldown_reduct_stack = 0
  for k,v in pairs(hero:FindAllModifiers()) do
      if v.GetModifierPercentageCooldown then
        cooldown_reduct = math.max(cooldown_reduct,v:GetModifierPercentageCooldown())
      end
      if v.GetModifierPercentageCooldownStacking then
        cooldown_reduct_stack = cooldown_reduct_stack + v:GetModifierPercentageCooldownStacking()
      end
  end
  return math.max(0.01,(1 - (cooldown_reduct + cooldown_reduct_stack)*0.01))
end


-- modifierEventTable = {
--     caster = caster,
--     parent = parent,
--     ability = ability,
--     original_duration = duration,
--     modifier_name = modifier_name,
-- }
function CDOTA_BaseNPC:GetTenacity(modifierEventTable)
    local tenacity = 1
    for _, parent_modifier in pairs(self:FindAllModifiers()) do
        if parent_modifier.GetTenacity then
            tenacity = tenacity * (1- (parent_modifier:GetTenacity(modifierEventTable)/100))
        end
    end
    return tenacity
end



function CDOTA_BaseNPC:GetWillPower(modifierEventTable)
    local willpower = 1
    for _, parent_modifier in pairs(self:FindAllModifiers()) do
        if parent_modifier.GetWillPower then
            willpower = willpower * (1+ (parent_modifier:GetWillPower(modifierEventTable)/100))
        end
    end
    return willpower
end

function CDOTA_BaseNPC:GetSummonersBoost(modifierEventTable)
    local boost = 1
    for _, parent_modifier in pairs(self:FindAllModifiers()) do
        if parent_modifier.GetSummonersBoost then
            boost = boost * (1+ (parent_modifier:GetSummonersBoost(modifierEventTable)/100))
        end
    end
    return boost
end

function CDOTA_BaseNPC:GetBATReduction()
    local reduction = 0
    for _, parent_modifier in pairs(self:FindAllModifiers()) do
        if parent_modifier.GetBATReductionConstant then
            reduction = reduction - parent_modifier:GetBATReductionConstant()
        end
    end
    return reduction
end

function CDOTA_BaseNPC:GetBaseBAT()
    local reduction = 0
    local pct = 1
    self.BAT = self.BAT or ALLHEROES[self:GetUnitName()]["AttackRate"]
    local time = self.BAT
    for _, parent_modifier in pairs(self:FindAllModifiers()) do
        if parent_modifier.GetModifierBaseAttackTimeConstant then
            if parent_modifier:GetName() ~= "modifier_bat_manager" then
                time = parent_modifier:GetModifierBaseAttackTimeConstant()
            end
        end
        if parent_modifier.GetBATReductionConstant then
            reduction = reduction - parent_modifier:GetBATReductionConstant()
        end
        if parent_modifier.GetBATReductionPercentage then
            pct = pct - (parent_modifier:GetBATReductionPercentage() /100)
        end
    end
    time = time * pct
    return time-reduction
end

function ShuffleArray(input)
  local rand = math.random
    local iterations = #input
    local j

    for i = iterations, 2, -1 do
        j = rand(i)
        input[i], input[j] = input[j], input[i]
    end
end

function util:MoveArray(input, index)
    index = index or 1
    local temp = table.remove(input, index)
    table.insert(input, temp)
end

function util:RandomChoice(input)
    local temp = {}
    for k in pairs(input) do
        table.insert(temp, k)
    end
    return input[temp[math.random(#temp)]]
end

function CDOTABaseAbility:HasAbilityFlag(flag)
    if not GameRules.perks[flag] then return false end
    return GameRules.perks[flag][self:GetAbilityName()] ~= nil
end

function util:split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function util:anyBots()
    if GameRules.pregame.enabledBots == true then return true end
    local maxPlayerID = 24
    local count = 0
    local toggle = false
    for playerID=0,(maxPlayerID-1) do
        print(playerID, self:isPlayerBot(playerID), PlayerResource:IsFakeClient(playerID), PlayerResource:GetPlayer(playerID))
        if PlayerResource:GetPlayer(playerID) and (PlayerResource:IsFakeClient(playerID) or PlayerResource:GetSteamAccountID(playerID) == 0) then
            toggle = true
        end
    end
    return toggle
end

function util:isSinglePlayerMode()
    local maxPlayerID = 24
    local count = 0
    for playerID=0,(maxPlayerID-1) do
        if not self:isPlayerBot(playerID) then
            count = count + 1
            if count > 1 then return false end
        end
    end

    return true
end

function util:checkPickedHeroes( builds )
    local players = {}

    for i=0,23 do
        local ply = PlayerResource:GetPlayer(i)
        if ply then
            if not builds[i] then
                table.insert(players, i)
            end
        end
    end

    if #players == 0 then
        return nil
    else
        return players
    end
end

function util:isCoop()
    local RadiantHumanPlayers = self:GetActivePlayerCountForTeam(DOTA_TEAM_GOODGUYS)
    local DireHumanPlayers = self:GetActiveHumanPlayerCountForTeam(DOTA_TEAM_BADGUYS)
    if RadiantHumanPlayers == 0 or DireHumanPlayers == 0 then
        return true
    else
        return false
    end
end

function CDOTABaseAbility:CreateIllusions(hTarget,nIllusions,flDuration,flIncomingDamage,flOutgoingDamage,flRadius)
    local caster = self:GetCaster()
    local ability = self
    local player = caster:GetPlayerOwnerID()
    if not flRadius then flRadius = 50 end
    local illusions = {}
    local vRandomSpawnPos = {
        Vector( flRadius, 0, 0 ),
        Vector( 0, flRadius, 0 ),
        Vector( -flRadius, 0, 0 ),
        Vector( 0, -flRadius, 0 ),
    }

    for i=#vRandomSpawnPos, 2, -1 do
      local j = RandomInt( 1, i )
      vRandomSpawnPos[i], vRandomSpawnPos[j] = vRandomSpawnPos[j], vRandomSpawnPos[i]
    end
    for i =1, nIllusions do
        if not vRandomSpawnPos or #vRandomSpawnPos == 0 then
            vRandomSpawnPos[1] = RandomVector(flRadius)
        end
        local illusion = CreateUnitByName(hTarget:GetUnitName(),hTarget:GetAbsOrigin() +vRandomSpawnPos[1],true,caster,caster:GetOwner(),caster:GetTeamNumber())
        table.remove(vRandomSpawnPos, 1)
        illusion:MakeIllusion()
        illusion:SetControllableByPlayer(player,true)
        illusion:SetPlayerID(player)
        illusion:SetHealth(hTarget:GetHealth())
        illusion:SetMana(hTarget:GetMana())
        illusion:AddNewModifier(caster, ability, "modifier_illusion", {duration = flDuration, outgoing_damage=flOutgoingDamage, incoming_damage = flIncomingDamage})

        --make sure this unit actually has stats
        if illusion.GetStrength then
            --copy over all the stat modifiers from the original hero
            for k,v in pairs(hTarget:FindAllModifiersByName("modifier_stats_tome")) do
                local instance = illusion:AddNewModifier(illusion, v:GetAbility(), "modifier_stats_tome", {stat = v.stat})
                instance:SetStackCount(v:GetStackCount())
            end
        end

        local level = hTarget:GetLevel()
        for i=1,level-1 do
            illusion:HeroLevelUp(false)
        end

        for abilitySlot=0,23 do
            local abilityTemp = caster:GetAbilityByIndex(abilitySlot)

            if abilityTemp then
                illusion:RemoveAbility(abilityTemp:GetAbilityName())
            end
        end

        illusion:SetAbilityPoints(0)
        for abilitySlot=0,23 do
            local abilityTemp = hTarget:GetAbilityByIndex(abilitySlot)

            if abilityTemp then
                illusion:AddAbility(abilityTemp:GetAbilityName())
                local abilityLevel = abilityTemp:GetLevel()
                if abilityLevel > 0 then
                    local abilityName = abilityTemp:GetAbilityName()
                    local illusionAbility = illusion:FindAbilityByName(abilityName)
                    if illusionAbility then
                        illusionAbility:SetLevel(abilityLevel)
                    end
                end
            end
        end

        for itemSlot=0,8 do
            local item = hTarget:GetItemInSlot(itemSlot)
            if item then
                local itemName = item:GetName()
                local newItem = CreateItem(itemName, illusion,illusion)
                illusion:AddItem(newItem)
            end
        end
        table.insert(illusions,illusion)
    end
    ResolveNPCPositions(hTarget:GetAbsOrigin(),flRadius*1.05)
    return illusions
end

function CDOTA_BaseNPC:FixIllusion(source)

    for abilitySlot=0,23 do
        local abilityTemp = self:GetAbilityByIndex(abilitySlot)

        if abilityTemp then
            self:RemoveAbility(abilityTemp:GetAbilityName())
        end
    end
    self:SetAbilityPoints(0)
    for abilitySlot=0,23 do
        local abilityTemp = source:GetAbilityByIndex(abilitySlot)

        if abilityTemp then

            self:AddAbility(abilityTemp:GetAbilityName())
            local abilityLevel = abilityTemp:GetLevel()
            if abilityLevel > 0 then
                local abilityName = abilityTemp:GetAbilityName()
                local illusionAbility = self:FindAbilityByName(abilityName)
                if illusionAbility then
                    illusionAbility:SetLevel(abilityLevel)
                end
            end
        end
    end
end


function CDOTA_BaseNPC:HasAbilityWithFlag(flag)
    for i = 0, 23 do
    local ability = self:GetAbilityByIndex(i)
    if ability and not ability:IsHidden() and ability:HasAbilityFlag(flag) then
      return true
    end
  end
  return false
end

function CDOTABaseAbility:IsCustomAbility()
    return IsCustomAbilityByName(self:GetAbilityName())
end

function IsCustomAbilityByName(name)
    return regularSpells[name:gsub("_lod", ""):gsub("_redux", "")] == nil
end

function CDOTA_BaseNPC:HasUnitFlag(flag)
    return GameRules.perks[flag][self:GetName()] ~= nil
end

function GetRandomAbilityFromListForPerk(flag)
    numberOfValues = 0
    local localTable = {}

    -- Getting the number of abilities and recreating the table
     for k,v in pairs(GameRules.perks[flag]) do
        if not k then
            break
        else

            numberOfValues = numberOfValues + 1
            localTable[numberOfValues] = v
        end
    end

    local random = RandomInt(1,numberOfValues)
    return localTable[random]
end



function CDOTA_BaseNPC:IsSleeping()
    return self:HasModifier("modifier_bane_nightmare") or self:HasModifier("modifier_elder_titan_echo_stomp") or self:HasModifier("modifier_sleep_cloud_effect") or self:HasModifier("modifier_naga_siren_song_of_the_siren")
end

function CDOTA_BaseNPC:FindItemByName(item_name)
    for i=0,5 do
        local item = self:GetItemInSlot(i)
        if item and item:GetAbilityName() == item_name then
            return item
        end
    end
    return nil
end

local voteCooldown = 150
util.votesBlocked = {}
util.votesRejected = {}
function util:CreateVoting(votingName, initiator, duration, percent, onaccept, onvote, ondecline, voteForInitiator)
    percent = percent or 100
    if util.activeVoting then
        if util.activeVoting.name == votingName and Time() >= util.activeVoting.recieveStartTime then
            util.activeVoting.onvote(initiator, true)
        else
            --TODO: Display error message - Can't start a new voting while there is another ongoing voting
        end
        return
    end

    if util.votesRejected[initiator] and util.votesRejected[initiator] >= 2 then
        util:DisplayError(initiator, "#votingPlayerBanned")
        return
    end

    -- If a vote fails, players cannot call another vote for 5 minutes, to prevent abuse.
    if util.votesBlocked[initiator] then
        util:DisplayError(initiator, "#votingCooldown")
        return
    end

    -- If a vote has been called of this type recently, block
    if util.votesBlocked[votingName] then
        util:DisplayError(initiator, "#voteCooldown")
        return
    end

    -- Temporarily block future votes if the vote is not succesful
    util.votesBlocked[votingName] = true
    util.votesBlocked[initiator] = true

    Timers:CreateTimer({
        useGameTime = false,
        endTime = voteCooldown,
        callback = function()
            util.votesBlocked[votingName] = false
            util.votesBlocked[initiator] = false
        end
    })

    local CheckForEnd = function(force)
        local votesAccepted = 0
        local totalPlayers = 0
        local votesDeclined = 0
        for PlayerID = 0, 23 do
            if PlayerResource:IsValidPlayerID(PlayerID) and not util:isPlayerBot(PlayerID) then
                local state = PlayerResource:GetConnectionState(PlayerID)
                if state == 1 or state == 2 then
                    if util.activeVoting.votes[PlayerID] ~= nil then
                        if util.activeVoting.votes[PlayerID] then
                            votesAccepted = votesAccepted + 1
                        else
                            votesDeclined = votesDeclined + 1
                        end
                    end
                    totalPlayers = totalPlayers + 1
                end
            end
        end
        local accept
        --If voting was declined x players, so percent can't be reached
        if votesDeclined > 0 and votesDeclined / totalPlayers >= 1 - (percent * 0.01) then
            accept = false
        end
        --If voting was accepted by % players
        if votesAccepted / totalPlayers >= percent * 0.01 then
            accept = true
        end

        if accept ~= nil or force then
            if accept == nil then accept = false end

            if accept then
                util.votesBlocked[initiator] = false
                if onaccept then
                    onaccept()
                end
            else
                if ondecline then
                    ondecline()
                end
                util.votesRejected[initiator] = (util.votesRejected[initiator] or 0) + 1
            end

            Timers:RemoveTimer(util.activeVoting.pauseChecker)
            Timers:RemoveTimer(util.activeVoting.vote_counter)
            CustomGameEventManager:Send_ServerToAllClients("universalVotingsUpdate", {votingName = votingName, accept = accept})
            util.activeVoting = nil
            PauseGame(false)
        end
    end

    local pauseChecker = Timers:CreateTimer({
        useGameTime = false,
        callback = function()
            if not GameRules:IsGamePaused() then
                PauseGame(true)
            end
            return 1/30
        end
    })
    local vote_counter = Timers:CreateTimer({
        useGameTime = false,
        endTime = duration,
        callback = function()
            CheckForEnd(true)
        end
    })
    local _onvote = function(pid, accepted)
        util.activeVoting.votes[pid] = accepted
        if onvote then
            onvote(pid, accepted)
        end
        CheckForEnd()
    end
    util.activeVoting = {
        name = votingName,
        votes = {},
        recieveStartTime = Time() + 3,
        onvote = _onvote,
        pauseChecker = pauseChecker,
        vote_counter = vote_counter
    }
    CustomGameEventManager:Send_ServerToAllClients("lodCreateUniversalVoting", {
        title = votingName,
        initiator = initiator,
        duration = duration
    })
    if voteForInitiator ~= false then
        _onvote(initiator, true)
    end
end

function CDOTA_BaseNPC:FindItemByNameEverywhere(item_name)
    for i=0,14 do
        local item = self:GetItemInSlot(i)
        if item and item:GetAbilityName() == item_name then
            return i,item
        end
    end
    return nil,nil

end

function CDOTA_BaseNPC:PopupNumbers(target, pfx, color, lifetime, number, presymbol, postsymbol)
    local armor = target:GetPhysicalArmorValue()
    local damageReduction = ((0.02 * armor) / (1 + 0.02 * armor))
    number = number - (number * damageReduction)
    local lens_count = 0
    for i=0,5 do
       local item = self:GetItemInSlot(i)
       if item ~= nil and item:GetName() == "item_aether_lens" then
           lens_count = lens_count + 1
       end
    end
    number = number * (1 + (.08 * lens_count) + (self:GetIntellect()/1600))

    number = math.floor(number)
    local pfxPath = string.format("particles/msg_fx/msg_%s.vpcf", pfx)
    local pidx
    if pfx == "gold" or pfx == "lumber" then
        pidx = ParticleManager:CreateParticleForTeam(pfxPath, PATTACH_CUSTOMORIGIN, target, target:GetTeamNumber())
    else
        pidx = ParticleManager:CreateParticle(pfxPath, PATTACH_CUSTOMORIGIN, target)
    end

    local digits = 0
    if number ~= nil then
        digits = #tostring(number)
    end
    if presymbol ~= nil then
        digits = digits + 1
    end
    if postsymbol ~= nil then
        digits = digits + 1
    end

    ParticleManager:SetParticleControl(pidx, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(pidx, 1, Vector(tonumber(presymbol), tonumber(number), tonumber(postsymbol)))
    ParticleManager:SetParticleControl(pidx, 2, Vector(lifetime, digits, 0))
    ParticleManager:SetParticleControl(pidx, 3, color)
end

DisableHelpStates = DisableHelpStates or {}
function CDOTA_PlayerResource:SetDisableHelpForPlayerID(nPlayerID, nOtherPlayerID, disabled)
    if nPlayerID ~= nOtherPlayerID then
        DisableHelpStates[nPlayerID] = DisableHelpStates[nPlayerID] or {}
        DisableHelpStates[nPlayerID][nOtherPlayerID] = disabled
        CustomNetTables:SetTableValue("phase_ingame", "disable_help_data", DisableHelpStates)
    end
end

function CDOTA_PlayerResource:IsDisableHelpSetForPlayerID(nPlayerID, nOtherPlayerID)
    return DisableHelpStates[nPlayerID] ~= nil and DisableHelpStates[nPlayerID][nOtherPlayerID] and PlayerResource:GetTeam(nPlayerID) == PlayerResource:GetTeam(nOtherPlayerID)
end

function util:DisplayError(pid, message)
    local player = PlayerResource:GetPlayer(pid)
    if player then
        CustomGameEventManager:Send_ServerToPlayer(player, "lodCreateIngameErrorMessage", {message=message})
    end
end

function util:EmitSoundOnClient(pid, sound)
    local player = PlayerResource:GetPlayer(pid)
    if player then
        CustomGameEventManager:Send_ServerToPlayer(player, "lodEmitClientSound", {sound=sound})
    end
end

-- Returns a set of abilities that won't trigger stuff like aftershock / essence aura
local toIgnore
function util:getToggleIgnores()
    return toIgnore
end

local abilityKVs = {}
function util:getAbilityKV(ability, key)
    if key then
        if abilityKVs[ability] then
            return abilityKVs[ability][key]
        end
    elseif ability then
        return abilityKVs[ability]
    else
        return abilityKVs
    end
end

function util:contains(table, element)
    if table then
        for _, value in pairs(table) do
            if value == element then
                return true
            end
        end
    end
    return false
end

function util:removeByValue(t, value)
    for i,v in pairs(t) do
        if v == value then
            table.remove(t, i)
            break
        end
    end
end

function util:tableCount(t)
    local counter = 0
    for _ in pairs(t) do
        counter = counter + 1
    end
    return counter
end

-- Function to get the original ability values to be used
function StoreSpecialKeyValues(object,ability,abilityName)
  if not ABILITIES_TXT then
    ABILITIES_TXT = LoadKeyValues("scripts/npc/npc_abilities.txt")
    ITEMS_TXT = LoadKeyValues("scripts/npc/items.txt")
    --for k,v in pairs(LoadKeyValues("scripts/npc/npc_abilities_override.txt")) do ABILITIES_TXT[k] = v end
    --for k,v in pairs(LoadKeyValues("scripts/npc/npc_abilities_custom.txt")) do ABILITIES_TXT[k] = v end
  end

  if not ability then ability = object end

  for k,v in pairs(ABILITIES_TXT[abilityName]["AbilitySpecial"]) do
    for K,V in pairs(v) do
      if K ~= "var_type" and K ~= "LinkedSpecialBonus" then
        local array = StringToArray(V)
        object[tostring(K)] = tonumber(array[ability:GetLevel()]) or tonumber(array[#array])
      end
    end
  end
end

function StringToArray(inputString, seperator)
  if not seperator then seperator = " " end
  local array={}
  local i=1

  for str in string.gmatch(inputString, "([^"..seperator.."]+)") do
    array[i] = str
    i = i + 1
  end
  return array
end
function GenerateTalentAbilityList()
		local tab = LoadKeyValues("scripts/npc/npc_abilities.txt")
		for k,v in pairs(tab) do
			if type(v) ~= "number" then
				if v.AbilitySpecial then
					for K,V in pairs(v.AbilitySpecial) do
						if V.LinkedSpecialBonus then
							print("'"..V.LinkedSpecialBonus.."'","'"..k.."'")
						end
					end
				end
			end
		end
	end

(function()
    toIgnore = { -- These are abilities that wont trigger essence aura (among other things)
        nyx_assassin_burrow = true,
        spectre_reality = true,
        techies_focused_detonate = true,
        furion_teleportation = true,
        life_stealer_consume = true,
        winter_wyvern_arctic_burn = true,
        life_stealer_control = true,
        eat_tree_eldri = true,
        shadow_demon_shadow_poison_release = true,
        storm_spirit_ball_lightning = true,
        ability_wards = true,
        ability_wards_op = true,
        elder_titan_return_spirit = true,
    }

    abilityKVs = LoadKeyValues('scripts/npc/npc_abilities.txt')
    local absOverride = LoadKeyValues('scripts/npc/npc_abilities_override.txt')
    local absCustom = LoadKeyValues('scripts/npc/npc_abilities_custom.txt')

    util:MergeTables(abilityKVs, absOverride)
    util:MergeTables(abilityKVs, absCustom)

    for abilityName,data in pairs(abilityKVs) do
        if type(data) == 'table' then
            if data.AbilityBehavior and string.match(data.AbilityBehavior, 'DOTA_ABILITY_BEHAVIOR_TOGGLE') then
                toIgnore[abilityName] = true
            end
        else
            abilityKVs[abilityName] = nil
        end
    end

    -- No items
    local items = LoadKeyValues('scripts/npc/items.txt')
    for abilityName,data in pairs(items) do
        toIgnore[abilityName] = true
    end

end)()
