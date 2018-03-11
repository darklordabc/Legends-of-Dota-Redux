--[[
Usage:

You firstly need to include the module like so:

require('lib.optionsmodule')

You can then set it up by calling

GDSOptions.setup('YourUniqueModID', callback)

Note: callback is a function you want to run when we get options
    The callback will get two values
        argument1: Failure message, this will be nil if it worked, or a string if it failed to get options
        argument2: Options table, each key will be an option

        Note: argument2 wont exist if there was a failure message

Once your callback has fired, anytime after that, you can call:

local someOption = GDSOptions.getOption('optionName', 'defaultValue')

to get the values for options

note: Options should all be strings, so you might need to use tonumber() accordingly.

note:
    If you want to disable the annoying "command not found" if you sometimes want to disable this module
    simply call GDSOptions.setup() with no arguments
]]

-- Require libs
local libpath = (...):match('(.-)[^%.]+$')
local JSON = require(libpath .. 'json')

-- Prefix to put on all debug messages
local debugPrefix = 'GDS: '

-- This is the ID of the mod, required to work
local modID

-- Have options failed to load?
local failed = false

-- Have we already gotten options?
local gottenOptions = false

-- The callback to run
local optionsCallback

-- Data we have stored
local storedData

-- Options we have stored
local storedOptions

-- This function sets the modID
-- Returns true on success, false if it fails
-- This will only fail if you call it TWICE
local function setupFunction(newModID, theirCallback)
    -- Ensure the modID hasn't already been set
    if modID then
        print(debugPrefix..'You can not set the modID twice!')
        return false
    end

    -- Allow them to disable this module
    if not newModID then
        -- Just register the request command
        Convars:RegisterCommand('gds_request_options', checkForHost, 'Client is asking if we need to send options', 0)
        return
    end

    -- Hook callbacks
    Convars:RegisterCommand('gds_send_part', recieveOptionsPart, 'Client is sending us part of the options', 0)
    Convars:RegisterCommand('gds_send_options', recieveOptions, 'Client is done sending us the options', 0)
    Convars:RegisterCommand('gds_failure', failedOptions, 'Client is telling us options have failed to load', 0)
    Convars:RegisterCommand('gds_request_options', checkForHost, 'Client is asking if we need to send options', 0)

    -- Store it, and return success
    modID = newModID
    optionsCallback = theirCallback
    return true
end

-- Called when a player loads, will reply to them if they are the first person to ask for options
local foundHost = false
local reportPlayer = -1
function checkForHost(cmdName)
    -- Ensure it is setup
    if not modID then return end

    -- Ensure it was a valid player who called this
    local cmdPlayer = Convars:GetCommandClient()
    if cmdPlayer then
        -- Ensure we only request options once
        if foundHost then return end

        local playerID = cmdPlayer:GetPlayerID()
        if playerID == -1 then return end

        -- We have now found a host
        foundHost = true

        -- Store this player as the reporter
        reportPlayer = playerID

        -- Grab their steamID
        local steamID = tostring(PlayerResource:GetSteamAccountID(playerID))

        -- Fire the event to tell them to forward options to us
        FireGameEvent('gds_options', {
            command = '?mid='..tostring(modID)..'&uid='..steamID,
            playerID = playerID
        })

        -- Report that we got something
        print(debugPrefix..'Player '..playerID..' ('..steamID..') is pulling options for us...')
    end
end

-- Options have failed to load
function failedOptions(cmdName, message)
    -- Ensure it is setup
    if not modID then return end

    -- Only allow failure to happen once
    if failed then return end
    failed = true

    -- Ensure it was a valid player who called this
    local cmdPlayer = Convars:GetCommandClient()
    if cmdPlayer then
        local playerID = cmdPlayer:GetPlayerID()

        -- Ensure it is the correct player
        if playerID ~= reportPlayer then return end

        -- Just log the error
        print(debugPrefix..'Failed to get options: '..message)

        -- Failure
        if optionsCallback then
            optionsCallback(message)
        end
    end
end

-- Called when we get PART of the options
local optionsPart = ''
function recieveOptionsPart(cmdName, part)
    -- Ensure it is setup
    if not modID then return end

    if gottenOptions or failed then return end

    -- Ensure it was a valid player who called this
    local cmdPlayer = Convars:GetCommandClient()
    if cmdPlayer then
        local playerID = cmdPlayer:GetPlayerID()

        -- Ensure it is the correct player
        if playerID ~= reportPlayer then return end

        -- Store this part
        optionsPart = optionsPart..part
    end
end

-- Called when the client sends us options
function recieveOptions(cmdName)
    -- Ensure it is setup
    if not modID then return end

    if gottenOptions or failed then return end

    -- Ensure it was a valid player who called this
    local cmdPlayer = Convars:GetCommandClient()
    if cmdPlayer then
        local playerID = cmdPlayer:GetPlayerID()

        -- Ensure it is the correct player
        if playerID ~= reportPlayer then return end

        -- Replace escaped chars
        local options = optionsPart:gsub('&qt!', '"')

        -- Note: options should be in the format of JSON
        print('Got options: '..options)

        -- Store the options (this may fail, so use a protected call)
        local success, msg = pcall(function()
            storedData = JSON:decode(options)
            storedOptions = storedData.lobby_options
        end)

        -- Ensure it ran correctly
        if success then
            -- Success: Fire callback
            if optionsCallback then
                if storedData.error then
                    optionsCallback(storedData.error)
                else
                    optionsCallback(nil, storedOptions)
                end
            end
        else
            -- Failure, tell the mod
            optionsCallback(msg)
        end
    end
end

-- Begin options module
module('GDSOptions')

-- Returns the value for the given option if it exists, otherwise, the defult value
function getOption(option, defaultValue)
    -- Ensure we have options to give
    if not storedOptions then
        return defaultValue
    end

    -- Return the option if we have it, otherwise, the default
    if storedOptions[option] ~= nil then
        return storedOptions[option]
    else
        return defaultValue
    end
end

-- Store setup function
setup = setupFunction
