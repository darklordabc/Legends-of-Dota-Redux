print('Loaded LoD dedicated file!')

-- How long to wait after the match ends before killing the server
local endGameDelay = 15

-- If we have started or not
local hasStarted = false

-- Load bans
local bans
function loadBans()
    -- Reload steamID64s
    bans = LoadKeyValues('scripts/kv/banned.kv');
end
loadBans()

-- Console command to reload bans
Convars:RegisterCommand('reload_bans', function()
    loadBans()
end, 'Reloads the bans KV', 0)

-- Allocation stuff
local autoAllocateMode = 1
local preAllocate = {}
local extraBans = {}

-- Ban manager
local autoAllocate = {}
local steamIDs = {}
local actualDire = 0
local actualRadiant = 0
ListenToGameEvent('player_connect', function(keys)
    -- Grab their steamID
    local steamID64 = tostring(keys.xuid)

    steamIDs[keys.userid] = steamID64

    -- Check bans
    if bans[steamID64] or extraBans[steamID64] then
        SendToServerConsole('kickid '..keys.userid);
        return
    end

    if autoAllocate[steamID64] then return end

    -- Check their name
    local chr = keys.name:sub(1,1)

    -- Check if we should use auto allocation table
    if autoAllocateMode >= 2 then
        -- Check for prealloc
        if preAllocate[steamID64] then
            chr = preAllocate[steamID64]
            print('Found a preallocate for '..keys.name)
        else
            -- Check if we need to spectate non-allocated players
            if autoAllocateMode == 3 then
                print('No allocation found for '..keys.name..', setting to SPECTATOR')
                chr = 'S'
            elseif autoAllocateMode == 4 then
                -- Sorry baby, you're not invited
                print('No allocation found for '..keys.name..', KICKING!')
                SendToServerConsole('kickid '..keys.userid);
                return
            end
        end
    end

    if chr == 'R' and actualRadiant < 5 then
        autoAllocate[steamID64] = DOTA_TEAM_GOODGUYS
        actualRadiant = actualRadiant + 1
        print(keys.name..' was allocated to RADIANT')
        return
    elseif chr == 'D' and actualDire < 5 then
        autoAllocate[steamID64] = DOTA_TEAM_BADGUYS
        actualDire = actualDire + 1
        print(keys.name..' was allocated to DIRE')
        return
    elseif chr == 'S' then
        autoAllocate[steamID64] = 1
        print(keys.name..' was allocated to SPECTATOR')
        return
    end

    -- Allocate to a team
    if actualRadiant <= actualDire then
        if actualRadiant < 5 then
            autoAllocate[steamID64] = DOTA_TEAM_GOODGUYS
            actualRadiant = actualRadiant + 1
            print(keys.name..' was allocated to RADIANT')
            return
        end
    else
        if actualDire < 5 then
            autoAllocate[steamID64] = DOTA_TEAM_BADGUYS
            actualDire = actualDire + 1
            print(keys.name..' was allocated to DIRE')
            return
        end
    end

    -- Allocate to spectator
    autoAllocate[steamID64] = 1
    print(keys.name..' was allocated to SPECTATOR')
end, nil)

-- Loads the allocation code
function loadAllocationCode()
    print('Loaded LoD allocation code!')

    -- Stick people onto teams
    --local allocated = {}
    ListenToGameEvent('player_connect_full', function(keys)
        -- Grab the entity index of this player
        local entIndex = keys.index+1
        local ply = EntIndexToHScript(entIndex)

        -- Validate player
        if ply and IsValidEntity(ply) then
            -- Make sure they aren't already on a team
            --if not allocated[steamIDs[keys.userid]] then
                -- We have now allocated this player
                --allocated[steamIDs[keys.userid]] = true

                -- Don't touch bots
                if PlayerResource:IsFakeClient(ply:GetPlayerID()) then return end

                -- Find number of players on each team
                local radiant = 0
                local dire = 0
                for i=0,9 do
                    if PlayerResource:GetConnectionState(i) >= 2 or PlayerResource:IsFakeClient(i) then
                        if PlayerResource:GetTeam(i) == DOTA_TEAM_GOODGUYS then
                            radiant = radiant + 1
                        elseif PlayerResource:GetTeam(i) == DOTA_TEAM_BADGUYS then
                            dire = dire + 1
                        end
                    end
                end

                -- Check for allocaton code
                if autoAllocate[steamIDs[keys.userid]] then
                    ply:SetTeam(autoAllocate[steamIDs[keys.userid]])
                    if autoAllocate[steamIDs[keys.userid]] ~= 1 then
                        hasStarted = true
                    end
                    return
                end

                -- Should we be spectating this player?
                if dire + radiant >= 10 then
                    -- Create a spectator
                    ply:SetTeam(1)
                    return
                end

                -- Set their team
                if radiant <= dire then
                    ply:SetTeam(DOTA_TEAM_GOODGUYS)
                    hasStarted = true
                    return
                else
                    ply:SetTeam(DOTA_TEAM_BADGUYS)
                    hasStarted = true
                    return
                end

                -- Spectator
                ply:SetTeam(1)
            --end
        end
    end, nil)

    ListenToGameEvent('player_disconnect', function(keys)
        -- Prevent spam
        if not hasStarted then return end

        -- Kill server if no one is on it anymore
        GameRules:GetGameModeEntity():SetThink(function()
            -- Search for players
            local foundSomeone = false
            for i=0,9 do
                if PlayerResource:GetConnectionState(i) == 2 then
                    foundSomeone = true
                    break
                end
            end

            -- If we failed to find someone
            if not foundSomeone then
                -- Kill the server
                SendToServerConsole('quit')
            end
        end, 'killServer', 1, nil)
    end, nil)

    -- Kill the server when the match ends
    local killed = false
    ListenToGameEvent('game_rules_state_change', function(keys)
        -- Only do this once
        if killed then return end

        -- Grab the current game state
        local state = GameRules:State_Get()

        -- Check if the game is over
        if state >= DOTA_GAMERULES_STATE_POST_GAME then
            -- Don't kill again
            killed = true

            -- Kill server after a delay
            GameRules:GetGameModeEntity():SetThink(function()
                -- Kill the server
                SendToServerConsole('quit')
            end, 'killServerDelayed', endGameDelay, nil)
        end
    end, nil)
end

-- Adds bots once the game starts
function addBots()
    -- Auto add bots on the dedi server
    if GameRules:isSource1() then
        local addedBots = false
        local started = false
        ListenToGameEvent('game_rules_state_change', function(keys)
            local state = GameRules:State_Get()

            if state == DOTA_GAMERULES_STATE_INIT then
                started = true
            end

            if not started then return end

            if not addedBots and state >= DOTA_GAMERULES_STATE_PRE_GAME then
                addedBots = true
                if not noBots then
                    SendToServerConsole('sm_gmode 1')
                    SendToServerConsole('dota_bot_populate')

                    -- We now have full teams
                    actualDire = 5
                    actualRadiant = 5
                end
            end
        end, nil)
    end
end

local noBots = false
Convars:RegisterCommand('lod_nobots', function()
    -- Only server can run this
    if not Convars:GetCommandClient() then
        if noBots then return end
        noBots = true
    end
end, 'hax loader', 0)

-- Overrides a team allocation
Convars:RegisterCommand('lod_allocate', function(name, steamID, teamID)
    -- Only server can run this
    if not Convars:GetCommandClient() then
        if not steamID or not teamID then
            print(name..' [steamID64] [teamID]')
            return
        end

        -- Parse values
        steamID = tostring(steamID)
        teamID = tonumber(teamID)

        -- Set the auto allocation
        autoAllocate[steamID] = teamID
    end
end, 'Sets a team allocation', 0)

-- Shows team allocations
Convars:RegisterCommand('lod_show_allocate', function()
    -- Only server can run this
    if not Convars:GetCommandClient() then
        for k,v in pairs(autoAllocate) do
            print(k..' - '..v)
        end
    end
end, 'Sets a team allocation', 0)

-- Return the function to deal with settings
return function(data)
    -- Should we do the fastload stuff?
    if data.fastLoad == 1 then
        -- Skip the loading time
        print('Fastload was enabled!')
        Convars:SetInt('dota_wait_for_players_to_load', 0)
    end

    -- Should we add bots?
    if data.addBots == 1 then
        -- Add them
        print('Bot allocation code was loaded!')
        addBots()
    end

    -- Change allocation settings
    if data.autoAllocate ~= nil then
        -- Store the auto allocate mode
        autoAllocateMode = tonumber(data.autoAllocate)
        print('Allocation mode was set to: '..autoAllocateMode)

        -- Load auto allocation code
        if autoAllocateMode > 0 then
            loadAllocationCode()
        end
    end

    -- Check the pre allocate table
    if data.preAllocate ~= nil then
        preAllocate = data.preAllocate
        print('Auto allocation table loaded!')
    end

    -- Check if there are extra bans
    if data.banPlayers ~= nil then
        extraBans = data.banPlayers
        print('Extra bans table loaded!')
    end
end
