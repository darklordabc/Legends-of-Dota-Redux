-- Libraries
local constants = require('constants')
local network = require('network')
local OptionManager = require('optionmanager')

--[[
    Main pregame, selection related handler
]]

local Pregame = class({})

-- Init pregame stuff
function Pregame:init()
    -- Set it to the loading phase
    self:setPhase(constants.PHASE_LOADING)

    -- Init thinker
    GameRules:GetGameModeEntity():SetThink('onThink', self, 'PregameThink', 0.25)

    -- Grab a reference to self
    local this = self

    -- Listen to events
    CustomGameEventManager:RegisterListener('lodOptionsLocked', function(eventSourceIndex, args)
        this:onOptionsLocked(eventSourceIndex, args)
    end)
end

-- Thinker function to handle logic
function Pregame:onThink()
    -- Grab the phase
    local ourPhase = self:getPhase()

    --[[
        LOADING PHASE
    ]]
    if ourPhase == constants.PHASE_LOADING then
        -- Are we in the custom game setup phase?
        if GameRules:State_Get() >= DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
            self:setPhase(constants.PHASE_OPTION_SELECTION)
        end

        -- Wait for time to pass
        return 0.1
    end

    --[[
        OPTION SELECTION PHASE
    ]]
    if ourPhase == constants.PHASE_OPTION_SELECTION then
        return 0.1
    end

    --[[
        BANNING PHASE
    ]]
    if ourPhase == constants.PHASE_BANNING then
        -- Is it over?
        if Time() >= self:getEndOfPhase() then
            -- Change to picking phase
            self:setPhase(constants.PHASE_SELECTION)
            self:setEndOfPhase(Time() + OptionManager:GetOption('pickingTime'))
        end

        return 0.1
    end

    -- Selection phase
    if ourPhase == constants.PHASE_SELECTION then
        -- Is it over?
        if Time() >= self:getEndOfPhase() then
            -- Change to picking phase
            self:setPhase(constants.PHASE_REVIEW)
            self:setEndOfPhase(Time() + OptionManager:GetOption('reviewTime'))
        end

        return 0.1
    end

    -- Review
    if ourPhase == constants.PHASE_REVIEW then
        -- Is it over?
        if Time() >= self:getEndOfPhase() then
            -- Change to picking phase
            self:setPhase(constants.PHASE_INGAME)

            -- Kill the selection screen
            GameRules:FinishCustomGameSetup()
        end

        return 0.1
    end

    -- Shouldn't get here
end

-- Options Locked event was fired
function Pregame:onOptionsLocked(eventSourceIndex, args)
    -- Ensure we are in the options locking phase
    if self:getPhase() ~= constants.PHASE_OPTION_SELECTION then return end

    -- Grab data
    local playerID = args.PlayerID
    local player = PlayerResource:GetPlayer(playerID)

    -- Ensure they have hosting privileges
    if GameRules:PlayerHasCustomGameHostPrivileges(player) then
        -- Should verify if the teams are locked here, oh well

        -- Move onto the next phase
        if OptionManager:GetOption('banningTime') > 0 then
            -- There is banning
            self:setPhase(constants.PHASE_BANNING)
            self:setEndOfPhase(Time() + OptionManager:GetOption('banningTime'))

        else
            -- There is not banning
            self:setPhase(constants.PHASE_SELECTION)
            self:setEndOfPhase(Time() + OptionManager:GetOption('pickingTime'))

        end
    end
end

-- Sets the stage
function Pregame:setPhase(newPhaseNumber)
    -- Store the current phase
    self.currentPhase = newPhaseNumber

    -- Update the phase for the clients
    network:setPhase(newPhaseNumber)
end

-- Sets when the next phase is going to end
function Pregame:setEndOfPhase(endTime)
    -- Store the time
    self.endOfTimer = endTime

    -- Network it
    network:setEndOfPhase(endTime)
end

-- Returns when the current phase should end
function Pregame:getEndOfPhase()
    return self.endOfTimer
end

-- Returns the current phase
function Pregame:getPhase()
    return self.currentPhase
end

-- Return an instance of it
return Pregame()
