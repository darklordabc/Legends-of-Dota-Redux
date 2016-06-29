--[[
Usage:

Simply add require('lib.loadhelper') into your addon_game_mode.lua

You don't need to call anything, this module is self contained and will hook itself accordingly

Please see the install guide in the readme
]]

-- Default our host to no one
local hostID = -1

-- Not currently loading
local stillLoading = false

-- Max number of players
local maxPlayers = 10

-- Total number of players in this lobby
local totalPlayers = -1

-- Set the time the pause started
local pauseStart = Time()

-- Variable used for client side commands
local CLIENT_COMMAND = 268435456

-- Function to check if everyone has loaded successfully
local function everyoneLoaded()
    -- If we don't know how many players, we cant know if everyone has loaded!
    if totalPlayers == -1 then return end

    local totalLoaded = 0

    -- Loop over every player and check if they have loaded
    for playerID=0,maxPlayers-1 do
        -- Has this player loaded?
        if PlayerResource:GetConnectionState(playerID) == 2 then
            totalLoaded = totalLoaded + 1
        end
    end

    -- Has everyone loaded?
    if totalLoaded >= totalPlayers then
        -- If we are still loading, resume the game
        if stillLoading then
            stillLoading = false
            PauseGame(false)
        end

        -- If they have stat collection, store that they are used our plugin
        if statcollection then
            -- Add the stat
            statcollection.addModuleStats('loadHelper', {
                enabled = true,
                duration = Time() - pauseStart
            })
        end
    end
end

-- Sends out the ID of the host
local function sendHostID()
    -- Fire the event
    FireGameEvent('lh_hostid', {
        hostID = hostID
    })
end

-- Starts up load helper
function Init()
    -- User tries to register as the host
    Convars:RegisterCommand('lh_register_host', function()
        -- Grab the player
        local cmdPlayer = Convars:GetCommandClient()
        if cmdPlayer then
            local playerID = cmdPlayer:GetPlayerID()

            -- Make sure no one has claimed themselves as the host yet
            if hostID == -1 then
                -- Store the new host
                hostID = playerID

                -- Check if we are loading, if we are, pause the game
                if GameRules:State_Get() == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
                    -- Set paused
                    PauseGame(true)

                    -- We are currently loading
                    stillLoading = true

                    -- Set the pause timer
                    pauseStart = Time()

                    -- If they have stats, record that our system is in use
                    if statcollection then
                        -- Add the stats
                        statcollection.addModuleStats('loadHelper', {
                            enabled = true,
                            hostSlotID = hostID,
                        })
                    end
                end
            end

            -- Send out the ID of the host
            sendHostID()
        end
    end, 'Registers the first caller of this command as the host', CLIENT_COMMAND)

    -- Users tries to unpause the game
    Convars:RegisterCommand('lh_resume_game', function()
        -- Grab the player
        local cmdPlayer = Convars:GetCommandClient()
        if cmdPlayer then
            local playerID = cmdPlayer:GetPlayerID()

            -- Ensure the player is actually the host
            if playerID == hostID then
                -- Is this still a valid command?
                if GameRules:State_Get() == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
                    -- Invert the loader
                    stillLoading = not stillLoading

                    -- Should we be pausing the game?
                    if stillLoading then
                        PauseGame(true)
                    else
                        PauseGame(false)
                    end
                else
                    -- Check if the game is paused for some reason
                    if stillLoading then
                        stillLoading = false
                        PauseGame(false)
                    end
                end
            end
        end
    end, 'Toggles the pause during the waiting phase', CLIENT_COMMAND)

    -- Users tries to report the total number of players
    Convars:RegisterCommand('lh_report_players', function(command, newTotalPlayers)
        -- Grab the player
        local cmdPlayer = Convars:GetCommandClient()
        if cmdPlayer then
            local playerID = cmdPlayer:GetPlayerID()

            -- Ensure the player is actually the host
            if playerID == hostID then
                -- Store new total players
                totalPlayers = tonumber(newTotalPlayers)

                -- Check if everyone is in
                everyoneLoaded()
            end
        end
    end, 'Toggles the pause during the waiting phase', CLIENT_COMMAND)

    -- Users tries to close the lobby
    local hasQuit = false
    Convars:RegisterCommand('lh_quit_game', function()
        -- Grab the player
        local cmdPlayer = Convars:GetCommandClient()
        if cmdPlayer then
            local playerID = cmdPlayer:GetPlayerID()

            -- Ensure the player is actually the host
            if playerID == hostID then
                -- Only do this once
                if hasQuit then return end
                hasQuit = true

                -- If they have stats, report back to the master server
                if statcollection then
                    -- Add the stats
                    statcollection.addModuleStats('loadHelper', {
                        enabled = true,
                        duration = Time() - pauseStart,
                        quit = true,
                    })

                    -- Tell the stat collector to collect
                    statcollection.sendStats()

                    -- Wait 5 seconds to quit
                    GameRules:GetGameModeEntity():SetThink(function()
                        -- Quit
                        SendToServerConsole('quit')
                    end, 'QuitTimer', 5, nil)
                else
                    -- Quit
                    SendToServerConsole('quit')
                end
            end
        end
    end, 'Toggles the pause during the waiting phase', CLIENT_COMMAND)

    -- Check if everyone has connected
    ListenToGameEvent('player_connect_full', function(keys)
        -- Wait a moment, then check if everyone has loaded
        GameRules:GetGameModeEntity():SetThink(function()
            -- Check if everyone has loaded
            everyoneLoaded()
        end, 'LoadChecker', 1, nil)
    end, nil)
end

-- Add load helper functions
module('loadhelper', package.seeall)

-- Returns the host's ID
function getHostID()
    return hostID
end

init = Init
