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

    -- Store for selected heroes and skills
    self.selectedHeroes = {}
    self.selectedSkills = {}

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

    -- Player wants to set their hero
    CustomGameEventManager:RegisterListener('lodChooseHero', function(eventSourceIndex, args)
        this:onPlayerSelectHero(eventSourceIndex, args)
    end)

    -- Player wants to change which ability is in a slot
    CustomGameEventManager:RegisterListener('lodChooseAbility', function(eventSourceIndex, args)
        this:onPlayerSelectAbility(eventSourceIndex, args)
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

    local allowedHeroes = {}

    for heroName,heroValues in pairs(allHeroes) do
        -- Ensure it is enabled
        if heroName ~= 'Version' and heroName ~= 'npc_dota_hero_base' and heroValues.Enabled == 1 then
            -- Store all the useful information
            local theData = {
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
            }

            if heroName == 'npc_dota_hero_invoker' then
                theData.Ability1 = 'invoker_alacrity_lod'
                theData.Ability2 = 'invoker_chaos_meteor_lod'
                theData.Ability3 = 'invoker_cold_snap_lod'
                theData.Ability4 = 'invoker_emp_lod'
                theData.Ability5 = 'invoker_forge_spirit_lod'
                theData.Ability6 = 'invoker_ghost_walk_lod'
                theData.Ability7 = 'invoker_ice_wall_lod'
                theData.Ability8 = 'invoker_sun_strike_lod'
                theData.Ability9 = 'invoker_tornado_lod'
            else
                local sn = 1
                for i=1,16 do
                    local abName = heroValues['Ability' .. i]

                    if abName ~= 'attribute_bonus' then
                        theData['Ability' .. sn] = abName
                        sn = sn + 1
                    end
                end
            end

            network:setHeroData(heroName, theData)

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

-- Player wants to select a hero
function Pregame:onPlayerSelectHero(eventSourceIndex, args)
    -- Ensure we are in the picking phase
    --if self:getPhase() ~= constants.PHASE_SELECTION then return end

    -- Grab data
    local playerID = args.PlayerID
    local player = PlayerResource:GetPlayer(playerID)

    local heroName = args.heroName

    -- Validate hero
    if not self.allowedHeroes[heroName] then
        print('Failed to find hero!')

        -- TODO: Show some kind of error
        return
    end

    -- Is there an actual change?
    if self.selectedHeroes[playerID] ~= heroName then
        -- Update local store
        self.selectedHeroes[playerID] = heroName

        -- Update the selected hero
        network:setSelectedHero(playerID, heroName)
    end
end

-- Player wants to select a new ability
function Pregame:onPlayerSelectAbility(eventSourceIndex, args)
    -- Ensure we are in the picking phase
    --if self:getPhase() ~= constants.PHASE_SELECTION then return end

    -- Grab data
    local playerID = args.PlayerID
    local player = PlayerResource:GetPlayer(playerID)

    local slot = args.slot
    local abilityName = args.abilityName

    -- TODO: Validate the slot is a valid slot index

    -- TODO: Validate ability is an actual ability

    -- TODO: Validate the ability isn't already banned

    -- TODO: Validate that the ability is allowed in this slot (ulty count)

    -- TODO: Validate that it isn't a troll build

    -- Ensure a container for this player exists
    self.selectedSkills[playerID] = self.selectedSkills[playerID] or {}

    -- Is there an actual change?
    if self.selectedSkills[playerID][slot] ~= abilityName then
        -- New ability in this slot
        self.selectedSkills[playerID][slot] = abilityName

        -- Network it
        network:setSelectedAbilities(playerID, self.selectedSkills[playerID])
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
