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

    -- Store for options
    self.optionStore = {}

    -- Grab a reference to self
    local this = self

    --[[
        Listen to events
    ]]

    -- Options are locked
    CustomGameEventManager:RegisterListener('lodOptionsLocked', function(eventSourceIndex, args)
        this:onOptionsLocked(eventSourceIndex, args)
    end)

    -- Host looks at a different tab
    CustomGameEventManager:RegisterListener('lodOptionsMenu', function(eventSourceIndex, args)
        this:onOptionsMenuChanged(eventSourceIndex, args)
    end)

    -- Host wants to set an option
    CustomGameEventManager:RegisterListener('lodOptionSet', function(eventSourceIndex, args)
        this:onOptionChanged(eventSourceIndex, args)
    end)

    -- Network heroes
    self:networkHeroes()
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

-- Setup the selectable heroes
function Pregame:networkHeroes()
    local allHeroes = LoadKeyValues('scripts/npc/npc_heroes.txt')

    local heroData = {}
    local allowedHeroes = {}

    for heroName,heroValues in pairs(allHeroes) do
        -- Ensure it is enabled
        if heroName ~= 'Version' and heroName ~= 'npc_dota_hero_base' and heroName ~= 'npc_dota_hero_arc_warden' and heroValues.Enabled == 1 then
            -- Store all the useful information
            network:setHeroData(heroName, {
                AttributePrimary = heroValues.AttributePrimary,
                Role = heroValues.Role,
                Rolelevels = heroValues.Rolelevels,
                AttackCapabilities = heroValues.AttackCapabilities,
                AttackDamageMin = heroValues.AttackDamageMin,
                AttackDamageMax = heroValues.AttackDamageMax,
                AttackRate = heroValues.AttackRate,
                AttackRange = heroValues.AttackRange,
                MovementSpeed = heroValues.MovementSpeed,
                AttributeBaseStrength = heroValues.AttributeBaseStrength,
                AttributeStrengthGain = heroValues.AttributeStrengthGain,
                AttributeBaseIntelligence = heroValues.AttributeBaseIntelligence,
                AttributeIntelligenceGain = heroValues.AttributeIntelligenceGain,
                AttributeBaseAgility = heroValues.AttributeBaseAgility,
                AttributeAgilityGain = heroValues.AttributeAgilityGain
            })

            -- Store allowed heroes
            allowedHeroes[heroName] = true
        end
    end

    -- Store it locally
    self.allowedHeroes = allowedHeroes
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

-- Options menu changed
function Pregame:onOptionsMenuChanged(eventSourceIndex, args)
    -- Ensure we are in the options locking phase
    if self:getPhase() ~= constants.PHASE_OPTION_SELECTION then return end

    -- Grab data
    local playerID = args.PlayerID
    local player = PlayerResource:GetPlayer(playerID)

    -- Ensure they have hosting privileges
    if GameRules:PlayerHasCustomGameHostPrivileges(player) then
        -- Grab and set which tab is active
        local newActiveTab = args.v
        network:setActiveOptionsTab(newActiveTab)
    end
end

-- An option was changed
function Pregame:onOptionChanged(eventSourceIndex, args)
    -- Ensure we are in the options locking phase
    if self:getPhase() ~= constants.PHASE_OPTION_SELECTION then return end

    -- Grab data
    local playerID = args.PlayerID
    local player = PlayerResource:GetPlayer(playerID)

    -- Ensure they have hosting privileges
    if GameRules:PlayerHasCustomGameHostPrivileges(player) then
        -- Grab options
        local optionName = args.k
        local optionValue = args.v

        -- TODO: Validate option name
        -- Option values are validated at a later stage

        -- Set the option
        self.optionStore[optionName] = optionValue
        network:setOption(optionName, optionValue)
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
