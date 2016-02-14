-- Libraries
local constants = require('constants')
local network = require('network')
local OptionManager = require('optionmanager')
local SkillManager = require('skillmanager')
local Timers = require('easytimers')
local SpellFixes = require('spellfixes')

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
    GameRules:SetHeroSelectionTime(0)   -- Hero selection is done elsewhere, hero selection should be instant

    -- Store for options
    self.optionStore = {}

    -- Store for selected heroes and skills
    self.selectedHeroes = {}
    self.selectedPlayerAttr = {}
    self.selectedSkills = {}

    -- Load troll combos
    self:loadTrollCombos()

    -- Init options
    self:initOptionSelector()

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

    -- Player wants to set their new primary attribute
    CustomGameEventManager:RegisterListener('lodChooseAttr', function(eventSourceIndex, args)
        this:onPlayerSelectAttr(eventSourceIndex, args)
    end)

    -- Player wants to change which ability is in a slot
    CustomGameEventManager:RegisterListener('lodChooseAbility', function(eventSourceIndex, args)
        this:onPlayerSelectAbility(eventSourceIndex, args)
    end)

    -- Network heroes
    self:networkHeroes()

    -- Setup default option related stuff
    network:setActiveOptionsTab('presets')
    self:setOption('lodOptionBanning', 1)
    self:setOption('lodOptionSlots', 6)
    self:setOption('lodOptionUlts', 2)
    self:setOption('lodOptionGamemode', 1)
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

    -- Process options ONCE here
    if not self.processedOptions then
        self:processOptions()
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

    -- Once we get to this point, we will not fire again

    -- Game is starting, spawn heroes
    if ourPhase == constants.PHASE_INGAME then
        self:spawnAllHeroes()
        self:addExtraTowers()
        self:preventCamping()
    end
end

-- Spawns all heroes (this should only be called once!)
function Pregame:spawnAllHeroes()
    local minPlayerID = 0
    local maxPlayerID = 24

    -- Loop over all playerIDs
    for playerID = minPlayerID,maxPlayerID do
        -- Is there a player in this slot?
        if PlayerResource:IsValidPlayerID(playerID) then
            -- There is, go ahead and build this player

            -- Grab their build
            local build = self.selectedSkills[playerID]

            -- Validate the player
            local player = PlayerResource:GetPlayer(playerID)
            if player ~= nil then
                local heroName = self.selectedHeroes[playerID] or self:getRandomHero()

                -- Attempt to precache their hero
                PrecacheUnitByNameAsync(heroName, function()
                    -- Create the hero and validate it
                    local hero = CreateHeroForPlayer(heroName, player)
                    if hero ~= nil and IsValidEntity(hero) then
                        SkillManager:ApplyBuild(hero, build or {})

                        -- Do they have a custom attribute set?
                        if self.selectedPlayerAttr[playerID] ~= nil then
                            -- Set it

                            local toSet = 0

                            if self.selectedPlayerAttr[playerID] == 'str' then
                                toSet = 0
                            elseif self.selectedPlayerAttr[playerID] == 'agi' then
                                toSet = 1
                            elseif self.selectedPlayerAttr[playerID] == 'int' then
                                toSet = 2
                            end

                            -- Set a timer to fix stuff up
                            Timers:CreateTimer(function()
                                if IsValidEntity(hero) then
                                    hero:SetPrimaryAttribute(toSet)
                                end
                            end, DoUniqueString('primaryAttrFix'), 0.1)
                        end
                    end
                end, playerID)
            end
        end
    end
end

-- Returns a random hero [will be unique]
function Pregame:getRandomHero()
    -- Build a list of heroes that have already been taken
    local takenHeroes = {}
    for k,v in pairs(self.selectedHeroes) do
        takenHeroes[v] = true
    end

    local possibleHeroes = {}

    for k,v in pairs(self.allowedHeroes) do
        if not takenHeroes[k] then
            table.insert(possibleHeroes, k)
        end
    end

    -- If no heroes were found, just give them pudge
    -- This should never happen, but if it does, WTF mate?
    if #possibleHeroes == 0 then
        return 'npc_dota_hero_pudge'
    end

    return possibleHeroes[math.random(#possibleHeroes)]
end

-- Setup the selectable heroes
function Pregame:networkHeroes()
    local allHeroes = LoadKeyValues('scripts/npc/npc_heroes.txt')
    local flags = LoadKeyValues('scripts/kv/flags.kv')
    local oldAbList = LoadKeyValues('scripts/kv/abilities.kv')

    -- Prepare flags
    local flagsInverse = {}
    for flagName,abilityList in pairs(flags) do
        for abilityName,nothing in pairs(abilityList) do
            -- Ensure a store exists
            flagsInverse[abilityName] = flagsInverse[abilityName] or {}
            flagsInverse[abilityName][flagName] = true
        end
    end

    -- Load in the category data for abilities
    local oldSkillList = oldAbList.skills

    for tabName, tabList in pairs(oldSkillList) do
        for abilityName,uselessNumber in pairs(tabList) do
            flagsInverse[abilityName] = flagsInverse[abilityName] or {}
            flagsInverse[abilityName].category = tabName
        end
    end

    -- Push flags to clients
    for abilityName, flagData in pairs(flagsInverse) do
        network:setFlagData(abilityName, flagData)
    end

    -- Store the inverse flags list
    self.flagsInverse = flagsInverse

    local allowedHeroes = {}
    self.heroPrimaryAttr = {}

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

            local attr = heroValues.AttributePrimary
            if attr == 'DOTA_ATTRIBUTE_INTELLECT' then
                self.heroPrimaryAttr[heroName] = 'int'
            elseif attr == 'DOTA_ATTRIBUTE_AGILITY' then
                self.heroPrimaryAttr[heroName] = 'agi'
            else
                self.heroPrimaryAttr[heroName] = 'str'
            end

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

        self:setOption(optionName, optionValue)
    end
end

-- Load up the troll combo bans list
function Pregame:loadTrollCombos()
    -- Load in the ban list
    local tempBanList = LoadKeyValues('scripts/kv/bans.kv')

    -- Store no multicast
    SpellFixes:SetNoCasting(tempBanList.noMulticast, tempBanList.noWitchcraft)

    --local noTower = tempBanList.noTower
    --local noTowerAlways = tempBanList.noTowerAlways
    --local noBear = tempBanList.noBear

    -- Create the stores
    self.banList = {}
    self.wtfAutoBan = tempBanList.wtfAutoBan
    self.noHero = tempBanList.noHero

    -- Bans a skill combo
    local function banCombo(a, b)
        -- Ensure ban lists exist
        self.banList[a] = self.banList[a] or {}
        self.banList[b] = self.banList[b] or {}

        -- Store the ban
        self.banList[a][b] = true
        self.banList[b][a] = true
    end

    -- Loop over the banned combinations
    for skillName, group in pairs(tempBanList.BannedCombinations) do
        for skillName2,_ in pairs(group) do
            banCombo(skillName, skillName2)
        end
    end

    -- Function to do a category ban
    local doCatBan
    doCatBan = function(skillName, cat)
        for skillName2,sort in pairs(tempBanList.Categories[cat] or {}) do
            if sort == 1 then
                banCombo(skillName, skillName2)
            elseif sort == 2 then
                doCatBan(skillName, skillName2)
            else
                print('Unknown category banning sort: '..sort)
            end
        end
    end


    -- Loop over category bans
    for skillName,cat in pairs(tempBanList.CategoryBans) do
        doCatBan(skillName, cat)
    end

    -- Ban the group bans
    for _,group in pairs(tempBanList.BannedGroups) do
        for skillName,__ in pairs(group) do
            for skillName2,___ in pairs(group) do
                banCombo(skillName, skillName2)
            end
        end
    end
end

-- Tests a build to decide if it is a troll combo
function Pregame:isTrollCombo(build)
    local maxSlots = self.optionStore['lodOptionCommonMaxSlots']

    for i=1,maxSlots do
        local ab1 = build[i]
        if ab1 ~= nil and self.banList[ab1] then
            for j=(i+1),maxSlots do
                local ab2 = build[j]

                if ab2 ~= nil and self.banList[ab1][ab2] then
                    -- Ability should be banned

                    return true, ab1, ab2
                end
            end
        end
    end

    return false
end

-- init option validator
function Pregame:initOptionSelector()
    -- Option validator can only init once
    if self.doneInitOptions then return end
    self.doneInitOptions = true

    self.validOptions = {
        -- Fast gamemode selection
        lodOptionGamemode = function(value)
            -- Ensure it is a number
            if type(value) ~= 'number' then return false end

            local validGamemodes = {
                [-1] = true,
                [1] = true,
                [2] = true,
                [3] = true,
                [4] = true
            }

            -- Ensure it is one of the above gamemodes
            if not validGamemodes[value] then return false end

            -- It must be valid
            return true
        end,

        -- Fast banning selection
        lodOptionBanning = function(value)
            return value == 1 or value == 2
        end,

        -- Fast slots selection
        lodOptionSlots = function(value)
            return value == 4 or value == 5 or value == 6
        end,

        -- Fast ult selection
        lodOptionUlts = function(value)
            local valid = {
                [0] = true,
                [1] = true,
                [2] = true,
                [3] = true,
                [4] = true,
                [5] = true,
                [6] = true
            }

            return valid[value] or false
        end,

        -- Common gamemode
        lodOptionCommonGamemode = function(value)
            -- Ensure gamemode is set to custom
            if self.optionStore['lodOptionGamemode'] ~= -1 then return false end

            return value == 1 or value == 2 or value == 3 or value == 4
        end,

        -- Common max slots
        lodOptionCommonMaxSlots = function(value)
            -- Ensure gamemode is set to custom
            if self.optionStore['lodOptionGamemode'] ~= -1 then return false end

            return value == 4 or value == 5 or value == 6
        end,

        -- Common max skills
        lodOptionCommonMaxSkills = function(value)
            -- Ensure gamemode is set to custom
            if self.optionStore['lodOptionGamemode'] ~= -1 then return false end

            local valid = {
                [0] = true,
                [1] = true,
                [2] = true,
                [3] = true,
                [4] = true,
                [5] = true,
                [6] = true
            }

            return valid[value] or false
        end,

        -- Common max ults
        lodOptionCommonMaxUlts = function(value)
            -- Ensure gamemode is set to custom
            if self.optionStore['lodOptionGamemode'] ~= -1 then return false end

            local valid = {
                [0] = true,
                [1] = true,
                [2] = true,
                [3] = true,
                [4] = true,
                [5] = true,
                [6] = true
            }

            return valid[value] or false
        end,

        -- Common max bans
        lodOptionBanningMaxBans = function(value)
            -- Ensure gamemode is set to custom
            if self.optionStore['lodOptionGamemode'] ~= -1 then return false end

            local valid = {
                [0] = true,
                [1] = true,
                [2] = true,
                [3] = true,
                [5] = true,
                [10] = true,
                [25] = true
            }

            return valid[value] or false
        end,

        -- Common max hero bans
        lodOptionBanningMaxHeroBans = function(value)
            -- Ensure gamemode is set to custom
            if self.optionStore['lodOptionGamemode'] ~= -1 then return false end

            local valid = {
                [0] = true,
                [1] = true,
                [2] = true,
                [3] = true
            }

            return valid[value] or false
        end,

        -- Common block troll combos
        lodOptionBanningBlockTrollCombos = function(value)
            -- Ensure gamemode is set to custom
            if self.optionStore['lodOptionGamemode'] ~= -1 then return false end

            return value == 0 or value == 1
        end,

        -- Common use ban list
        lodOptionBanningUseBanList = function(value)
            -- Ensure gamemode is set to custom
            if self.optionStore['lodOptionGamemode'] ~= -1 then return false end

            return value == 0 or value == 1
        end,

        -- Common ban all invis
        lodOptionBanningBanInvis = function(value)
            -- Ensure gamemode is set to custom
            if self.optionStore['lodOptionGamemode'] ~= -1 then return false end

            return value == 0 or value == 1
        end,

        -- Game Speed -- Starting Level
        lodOptionGameSpeedStartingLevel = function(value)
            -- Ensure gamemode is set to custom
            if self.optionStore['lodOptionGamemode'] ~= -1 then return false end

            local valid = {
                [1] = true,
                [6] = true,
                [11] = true,
                [16] = true,
                [25] = true,
                [50] = true,
                [75] = true,
                [100] = true
            }

            return valid[value] or false
        end,

        -- Game Speed -- Max Level
        lodOptionGameSpeedMaxLevel = function(value)
            -- Ensure gamemode is set to custom
            if self.optionStore['lodOptionGamemode'] ~= -1 then return false end

            local valid = {
                [6] = true,
                [11] = true,
                [16] = true,
                [25] = true,
                [50] = true,
                [75] = true,
                [100] = true
            }

            return valid[value] or false
        end,

        -- Game Speed -- Starting Gold
        lodOptionGameSpeedStartingGold = function(value)
            -- Ensure gamemode is set to custom
            if self.optionStore['lodOptionGamemode'] ~= -1 then return false end

            local valid = {
                [0] = true,
                [250] = true,
                [500] = true,
                [1000] = true,
                [2500] = true,
                [5000] = true,
                [10000] = true,
                [25000] = true,
                [50000] = true,
                [100000] = true
            }

            return valid[value] or false
        end,

        -- Game Speed -- Respawn Time
        lodOptionGameSpeedRespawnTime = function(value)
            -- Ensure gamemode is set to custom
            if self.optionStore['lodOptionGamemode'] ~= -1 then return false end

            local valid = {
                [0] = true,
                [0.5] = true,
                [0.1] = true,
                [-1] = true,
                [-10] = true,
                [-20] = true,
                [-30] = true,
                [-60] = true
            }

            return valid[value] or false
        end,

        -- Game Speed -- Towers per lane
        lodOptionGameSpeedTowersPerLane = function(value)
            -- Ensure gamemode is set to custom
            if self.optionStore['lodOptionGamemode'] ~= -1 then return false end

            local valid = {
                [3] = true,
                [4] = true,
                [5] = true,
                [6] = true,
                [7] = true,
                [8] = true,
                [9] = true,
                [10] = true
            }

            return valid[value] or false
        end,

        -- Game Speed - Scepter Upgraded
        lodOptionGameSpeedUpgradedUlts = function(value)
            -- Ensure gamemode is set to custom
            if self.optionStore['lodOptionGamemode'] ~= -1 then return false end

            return value == 0 or value == 1
        end,

        -- Game Speed - Easy Mode
        lodOptionCrazyEasymode = function(value)
            -- Ensure gamemode is set to custom
            if self.optionStore['lodOptionGamemode'] ~= -1 then return false end

            return value == 0 or value == 1
        end,

        -- Advanced -- Enable Hero Abilities
        lodOptionAdvancedHeroAbilities = function(value)
            -- Ensure gamemode is set to custom
            if self.optionStore['lodOptionGamemode'] ~= -1 then return false end

            return value == 0 or value == 1
        end,

        -- Advanced -- Enable Neutral Abilities
        lodOptionAdvancedNeutralAbilities = function(value)
            -- Ensure gamemode is set to custom
            if self.optionStore['lodOptionGamemode'] ~= -1 then return false end

            return value == 0 or value == 1
        end,

        -- Advanced -- Enable Wraith Night Abilities
        lodOptionAdvancedNeutralWraithNight = function(value)
            -- Ensure gamemode is set to custom
            if self.optionStore['lodOptionGamemode'] ~= -1 then return false end

            return value == 0 or value == 1
        end,

        -- Advanced -- Enable OP Abilities
        lodOptionAdvancedOPAbilities = function(value)
            -- Ensure gamemode is set to custom
            if self.optionStore['lodOptionGamemode'] ~= -1 then return false end

            return value == 0 or value == 1
        end,

        -- Advanced -- Hide enemy picks
        lodOptionAdvancedHidePicks = function(value)
            -- Ensure gamemode is set to custom
            if self.optionStore['lodOptionGamemode'] ~= -1 then return false end

            return value == 0 or value == 1
        end,

        -- Advanced -- Unique Skills
        lodOptionAdvancedUniqueSkills = function(value)
            -- Ensure gamemode is set to custom
            if self.optionStore['lodOptionGamemode'] ~= -1 then return false end

            return value == 0 or value == 1
        end,

        -- Advanced -- Unique Heroes
        lodOptionAdvancedUniqueHeroes = function(value)
            -- Ensure gamemode is set to custom
            if self.optionStore['lodOptionGamemode'] ~= -1 then return false end

            return value == 0 or value == 1
        end,

        -- Advanced -- Allow picking primary attr
        lodOptionAdvancedSelectPrimaryAttr = function(value)
            -- Ensure gamemode is set to custom
            if self.optionStore['lodOptionGamemode'] ~= -1 then return false end

            return value == 0 or value == 1
        end,

        -- Other -- No Fountain Camping
        lodOptionCrazyNoCamping = function(value)
            -- Ensure gamemode is set to custom
            if self.optionStore['lodOptionGamemode'] ~= -1 then return false end

            return value == 0 or value == 1
        end,

        -- Other -- Universal Shop
        lodOptionCrazyUniversalShop = function(value)
            -- Ensure gamemode is set to custom
            if self.optionStore['lodOptionGamemode'] ~= -1 then return false end

            return value == 0 or value == 1
        end,

        -- Other -- All Vision
        lodOptionCrazyAllVision = function(value)
            -- Ensure gamemode is set to custom
            if self.optionStore['lodOptionGamemode'] ~= -1 then return false end

            return value == 0 or value == 1
        end,

        -- Other -- Multicast Madness
        lodOptionCrazyMulticast = function(value)
            -- Ensure gamemode is set to custom
            if self.optionStore['lodOptionGamemode'] ~= -1 then return false end

            return value == 0 or value == 1
        end,

        -- Other -- WTF Mode
        lodOptionCrazyWTF = function(value)
            -- Ensure gamemode is set to custom
            if self.optionStore['lodOptionGamemode'] ~= -1 then return false end

            return value == 0 or value == 1
        end,
    }

    -- Callbacks
    self.onOptionsChanged = {
        -- Fast Gamemode
        lodOptionGamemode = function(optionName, optionValue)
            -- If we are using a hard coded gamemode, then, set all options automatically
            if optionValue ~= -1 then
                -- Gamemode is copied
                self:setOption('lodOptionCommonGamemode', optionValue, true)

                -- Total slots is copied
                self:setOption('lodOptionCommonMaxSlots', self.optionStore['lodOptionSlots'], true)

                -- Max skills is always 6
                self:setOption('lodOptionCommonMaxSkills', 6, true)

                -- Max ults is copied
                self:setOption('lodOptionCommonMaxUlts', self.optionStore['lodOptionUlts'], true)

                -- Banning mode depends on the option, but is baically copied
                if self.optionStore['lodOptionBanning'] == 1 then
                    self:setOption('lodOptionBanningMaxBans', 0, true)
                    self:setOption('lodOptionBanningMaxHeroBans', 0, true)
                    self:setOption('lodOptionBanningUseBanList', 1, true)
                else
                    self:setOption('lodOptionBanningMaxBans', self.fastBansTotalBans, true)
                    self:setOption('lodOptionBanningMaxHeroBans', self.fastHeroBansTotalBans, true)
                    self:setOption('lodOptionBanningUseBanList', 0, true)
                end

                -- Block troll combos is always on
                self:setOption('lodOptionBanningBlockTrollCombos', 1, true)

                -- Default, we don't ban all invisiblity
                self:setOption('lodOptionBanningBanInvis', 0, true)

                -- Starting level is lvl 1
                self:setOption('lodOptionGameSpeedStartingLevel', 1, true)

                -- Max level is 25
                self:setOption('lodOptionGameSpeedMaxLevel', 25, true)

                -- No bonus starting gold
                self:setOption('lodOptionGameSpeedStartingGold', 0, true)

                -- Default respawn time
                self:setOption('lodOptionGameSpeedRespawnTime', 0, true)

                -- 3 Towers per lane
                self:setOption('lodOptionGameSpeedTowersPerLane', 3, true)

                -- Do not start scepter upgraded
                self:setOption('lodOptionGameSpeedUpgradedUlts', 0, true)

                -- Turn easy mode off
                self:setOption('lodOptionCrazyEasymode', 0, true)

                -- Enable hero abilities
                self:setOption('lodOptionAdvancedHeroAbilities', 1, true)

                -- Enable neutral abilities
                self:setOption('lodOptionAdvancedNeutralAbilities', 1, true)

                -- Enable Wraith Night abilities
                self:setOption('lodOptionAdvancedNeutralWraithNight', 1, true)

                -- Disable OP abilities
                self:setOption('lodOptionAdvancedOPAbilities', 0, true)

                -- Hide enemy picks
                self:setOption('lodOptionAdvancedHidePicks', 1, true)

                -- Disable Unique Skills
                self:setOption('lodOptionAdvancedUniqueSkills', 0, true)

                -- Disable Unique Heroes
                self:setOption('lodOptionAdvancedUniqueHeroes', 0, true)

                -- Enable picking primary attr
                self:setOption('lodOptionAdvancedSelectPrimaryAttr', 1, true)

                -- Disable Fountain Camping
                self:setOption('lodOptionCrazyNoCamping', 1, true)

                -- Disable Universal Shop
                self:setOption('lodOptionCrazyUniversalShop', 0, true)

                -- Disable All Vision
                self:setOption('lodOptionCrazyAllVision', 0, true)

                -- Disable Multicast Madness
                self:setOption('lodOptionCrazyMulticast', 0, true)

                -- Disable WTF Mode
                self:setOption('lodOptionCrazyWTF', 0, true)
            end
        end,

        -- Fast Banning
        lodOptionBanning = function(optionName, optionValue)
            if self.optionStore['lodOptionBanning'] == 1 then
                self:setOption('lodOptionBanningMaxBans', 0, true)
                self:setOption('lodOptionBanningMaxHeroBans', 0, true)
                self:setOption('lodOptionBanningUseBanList', 1, true)
            else
                self:setOption('lodOptionBanningMaxBans', self.fastBansTotalBans, true)
                self:setOption('lodOptionBanningMaxHeroBans', self.fastHeroBansTotalBans, true)
                self:setOption('lodOptionBanningUseBanList', 0, true)
            end
        end,

        -- Fast max slots
        lodOptionSlots = function(optionName, optionValue)
            -- Copy max slots in
            self:setOption('lodOptionCommonMaxSlots', self.optionStore['lodOptionSlots'], true)
        end,

        -- Fast max ults
        lodOptionUlts = function(optionName, optionValue)
            self:setOption('lodOptionCommonMaxUlts', self.optionStore['lodOptionUlts'], true)
        end
    }

    -- Some default values
    self.fastBansTotalBans = 3
    self.fastHeroBansTotalBans = 1
end

-- Processes options to push around to the rest of the systems
function Pregame:processOptions()
    -- Only process options once
    if self.processedOptions then return end
    self.processedOptions = true

    -- Push settings externally where possible
    OptionManager:SetOption('startingLevel', self.optionStore['lodOptionGameSpeedStartingLevel'])
    OptionManager:SetOption('bonusGold', self.optionStore['lodOptionGameSpeedStartingGold'])
    OptionManager:SetOption('maxHeroLevel', self.optionStore['lodOptionGameSpeedMaxLevel'])
    OptionManager:SetOption('multicastMadness', self.optionStore['lodOptionCrazyMulticast'] == 1)
    OptionManager:SetOption('respawnModifier', self.optionStore['lodOptionGameSpeedRespawnTime'])
    OptionManager:SetOption('freeScepter', self.optionStore['lodOptionGameSpeedUpgradedUlts'] == 1)

    -- Enforce max level
    if OptionManager:GetOption('startingLevel') > OptionManager:GetOption('maxHeroLevel') then
        OptionManager:SetOption('startingLevel', OptionManager:GetOption('maxHeroLevel'))
    end

    -- Enable easy mode
    if self.optionStore['lodOptionCrazyEasymode'] == 1 then
        Convars:SetInt('dota_easy_mode', 1)
    end

    -- Enable WTF mode
    if self.optionStore['lodOptionCrazyWTF'] == 1 then
        -- TODO: Auto ban powerful abilities

        Convars:SetBool('dota_ability_debug', true)
    end

    -- Enable Universal Shop
    if self.optionStore['lodOptionCrazyUniversalShop'] == 1 then
        GameRules:SetUseUniversalShopMode(true)
    end

    -- Enable All Vision
    if self.optionStore['lodOptionCrazyAllVision'] == 1 then
        Convars:SetBool('dota_all_vision', true)
    end

    if OptionManager:GetOption('maxHeroLevel') ~= 25 then
        GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel(constants.XP_PER_LEVEL_TABLE)
        GameRules:GetGameModeEntity():SetCustomHeroMaxLevel(OptionManager:GetOption('maxHeroLevel'))
        GameRules:GetGameModeEntity():SetUseCustomHeroLevels(true)
    end
end

-- Validates, and then sets an option
function Pregame:setOption(optionName, optionValue, force)
    -- option validator

    if not self.validOptions[optionName] then
        -- TODO: Tell the user they tried to modify an invalid option
        return
    end

    if not force and not self.validOptions[optionName](optionValue) then
        -- TODO: Tell the user they gave an invalid value
        return
    end

    -- Set the option
    self.optionStore[optionName] = optionValue
    network:setOption(optionName, optionValue)

    -- Check for option changing callbacks
    if self.onOptionsChanged[optionName] then
        self.onOptionsChanged[optionName](optionName, optionValue)
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
        -- Add an error
        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodFailedToFindHero'
        })

        return
    end

    -- Attempt to set the primary attribute
    local newAttr = self.heroPrimaryAttr[heroName] or 'str'
    if self.selectedPlayerAttr[playerID] ~= newAttr then
        -- Update local store
        self.selectedPlayerAttr[playerID] = newAttr

        -- Update the selected hero
        network:setSelectedAttr(playerID, newAttr)
    end

    -- Is there an actual change?
    if self.selectedHeroes[playerID] ~= heroName then
        -- Update local store
        self.selectedHeroes[playerID] = heroName

        -- Update the selected hero
        network:setSelectedHero(playerID, heroName)
    end
end

-- Player wants to select a new primary attribute
function Pregame:onPlayerSelectAttr(eventSourceIndex, args)
    -- Ensure we are in the picking phase
    --if self:getPhase() ~= constants.PHASE_SELECTION then return end

    -- Grab data
    local playerID = args.PlayerID
    local player = PlayerResource:GetPlayer(playerID)

    local newAttr = args.newAttr

    -- Validate that the option is enabled
    if self.optionStore['lodOptionAdvancedSelectPrimaryAttr'] == 0 then
        -- Add an error
        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodFailedToChangeAttr'
        })

        return
    end

    -- Validate the new attribute
    if newAttr ~= 'str' and newAttr ~= 'agi' and newAttr ~= 'int' then
        -- Add an error
        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodFailedToChangeAttrInvalid'
        })

        return
    end

    -- Is there an actual change?
    if self.selectedPlayerAttr[playerID] ~= newAttr then
        -- Update local store
        self.selectedPlayerAttr[playerID] = newAttr

        -- Update the selected hero
        network:setSelectedAttr(playerID, newAttr)
    end
end

-- Player wants to select a new ability
function Pregame:onPlayerSelectAbility(eventSourceIndex, args)
    -- Ensure we are in the picking phase
    --if self:getPhase() ~= constants.PHASE_SELECTION then return end

    -- Grab data
    local playerID = args.PlayerID
    local player = PlayerResource:GetPlayer(playerID)

    local slot = math.floor(tonumber(args.slot))
    local abilityName = args.abilityName

    local maxSlots = self.optionStore['lodOptionCommonMaxSlots']
    local maxRegulars = self.optionStore['lodOptionCommonMaxSkills']
    local maxUlts = self.optionStore['lodOptionCommonMaxUlts']

    -- Ensure a container for this player exists
    self.selectedSkills[playerID] = self.selectedSkills[playerID] or {}

    local build = self.selectedSkills[playerID]

    -- Grab what the new build would be, to run tests against it
    local newBuild = SkillManager:grabNewBuild(build, slot, abilityName)

    -- Validate the slot is a valid slot index
    if slot < 1 or slot > maxSlots then
        -- Invalid slot number
        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodFailedInvalidSlot'
        })

        return
    end

    -- Validate ability is an actual ability
    if not self.flagsInverse[abilityName] then
        -- Invalid ability name
        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodFailedInvalidAbility',
            params = {
                ['abilityName'] = abilityName
            }
        })

        return
    end

    -- TODO: Validate the ability isn't already banned

    -- Validate that the ability is allowed in this slot (ulty count)
    if SkillManager:hasTooMany(newBuild, maxUlts, function(ab)
        return SkillManager:isUlt(ab)
    end) then
        -- Invalid ability name
        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodFailedTooManyUlts',
            params = {
                ['maxUlts'] = maxUlts
            }
        })

        return
    end

    -- Validate that the ability is allowed in this slot (regular count)
    if SkillManager:hasTooMany(newBuild, maxRegulars, function(ab)
        return not SkillManager:isUlt(ab)
    end) then
        -- Invalid ability name
        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodFailedTooManyRegulars',
            params = {
                ['maxRegulars'] = maxRegulars
            }
        })

        return
    end

    -- Is the ability in one of the allowed categories?
    local cat = (self.flagsInverse[abilityName] or {}).category
    if cat then
        local allowed = true

        if cat == 'main' then
            allowed = self.optionStore['lodOptionAdvancedHeroAbilities'] == 1
        elseif cat == 'neutral' then
            allowed = self.optionStore['lodOptionAdvancedNeutralAbilities'] == 1
        elseif cat == 'wraith' then
            allowed = self.optionStore['lodOptionAdvancedNeutralWraithNight'] == 1
        elseif cat == 'OP' then
            allowed = self.optionStore['lodOptionAdvancedOPAbilities'] == 1
        end

        if not allowed then
            network:sendNotification(player, {
                sort = 'lodDanger',
                text = 'lodFailedBannedCategory',
                params = {
                    ['cat'] = 'lodCategory_' .. cat,
                    ['ab'] = 'DOTA_Tooltip_ability_' .. abilityName
                }
            })

            return
        end
    else
        -- Category not found, don't allow this skill

        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodFailedUnknownCategory',
            params = {
                ['ab'] = 'DOTA_Tooltip_ability_' .. abilityName
            }
        })

        return
    end

    -- Should we block troll combinations?
    if self.optionStore['lodOptionBanningBlockTrollCombos'] == 1 then
        -- Validate that it isn't a troll build
        local isTrollCombo, ab1, ab2 = self:isTrollCombo(newBuild)
        if isTrollCombo then
            -- Invalid ability name
            network:sendNotification(player, {
                sort = 'lodDanger',
                text = 'lodFailedTrollCombo',
                params = {
                    ['ab1'] = 'DOTA_Tooltip_ability_' .. ab1,
                    ['ab2'] = 'DOTA_Tooltip_ability_' .. ab2
                }
            })

            return
        end
    end

    -- Is there an actual change?
    if build[slot] ~= abilityName then
        -- New ability in this slot
        build[slot] = abilityName

        -- Network it
        network:setSelectedAbilities(playerID, build)
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

-- Adds extra towers
-- Adds extra towers
function Pregame:addExtraTowers()
    local totalMiddleTowers = self.optionStore['lodOptionGameSpeedTowersPerLane'] - 2

    -- Is there any work to do?
    if totalMiddleTowers > 1 then
        -- Create a store for tower connectors
        self.towerConnectors = {}

        local lanes = {
            top = true,
            mid = true,
            bot = true
        }

        local teams = {
            good = DOTA_TEAM_GOODGUYS,
            bad = DOTA_TEAM_BADGUYS
        }

        local patchMap = {
            dota_goodguys_tower3_top = '1021_tower_radiant',
            dota_goodguys_tower3_mid = '1020_tower_radiant',
            dota_goodguys_tower3_bot = '1019_tower_radiant',

            dota_goodguys_tower2_top = '1026_tower_radiant',
            dota_goodguys_tower2_mid = '1024_tower_radiant',
            dota_goodguys_tower2_bot = '1022_tower_radiant',

            dota_goodguys_tower1_top = '1027_tower_radiant',
            dota_goodguys_tower1_mid = '1025_tower_radiant',
            dota_goodguys_tower1_bot = '1023_tower_radiant',

            dota_badguys_tower3_top = '1036_tower_dire',
            dota_badguys_tower3_mid = '1031_tower_dire',
            dota_badguys_tower3_bot = '1030_tower_dire',

            dota_badguys_tower2_top = '1035_tower_dire',
            dota_badguys_tower2_mid = '1032_tower_dire',
            dota_badguys_tower2_bot = '1029_tower_dire',

            dota_badguys_tower1_top = '1034_tower_dire',
            dota_badguys_tower1_mid = '1033_tower_dire',
            dota_badguys_tower1_bot = '1028_tower_dire',
        }

        for team,teamNumber in pairs(teams) do
            for lane,__ in pairs(lanes) do
                local threeRaw = 'dota_'..team..'guys_tower3_'..lane
                local three = Entities:FindByName(nil, threeRaw) or Entities:FindByName(nil, patchMap[threeRaw] or '_unknown_')

                local twoRaw = 'dota_'..team..'guys_tower2_'..lane
                local two = Entities:FindByName(nil, twoRaw) or Entities:FindByName(nil, patchMap[twoRaw] or '_unknown_')

                local oneRaw = 'dota_'..team..'guys_tower1_'..lane
                local one = Entities:FindByName(nil, oneRaw) or Entities:FindByName(nil, patchMap[oneRaw] or '_unknown_')

                -- Unit name
                local unitName = 'npc_dota_'..team..'guys_tower_lod_'..lane

                if one and two and three then
                    -- Proceed to patch the towers
                    local onePos = one:GetOrigin()
                    local threePos = three:GetOrigin()

                    -- Workout the difference in the positions
                    local dif = threePos - onePos
                    local sep = dif / totalMiddleTowers + 1

                    -- Remove the middle tower
                    UTIL_Remove(two)

                    -- Used to connect towers
                    local prevTower = three

                    for i=1,totalMiddleTowers do
                        local newPos = threePos - (sep * i)

                        local newTower = CreateUnitByName(unitName, newPos, false, nil, nil, teamNumber)

                        if newTower then
                            -- Make it unkillable
                            newTower:AddNewModifier(ent, nil, 'modifier_invulnerable', {})

                            -- Store connection
                            self.towerConnectors[newTower] = prevTower
                            prevTower = newTower
                        else
                            print('Failed to create tower #'..i..' in lane '..lane)
                        end
                    end

                    -- Store initial connection
                    self.towerConnectors[one] = prevTower
                else
                    -- Failure
                    print('Failed to patch towers!')
                end
            end
        end

        -- Hook the towers properly
        local this = self

        ListenToGameEvent('entity_hurt', function(keys)
            -- Grab the entity that was hurt
            local ent = EntIndexToHScript(keys.entindex_killed)

            -- Check for tower connections
            if ent:GetHealth() <= 0 and this.towerConnectors[ent] then
                local tower = this.towerConnectors[ent]
                this.towerConnectors[ent] = nil

                if IsValidEntity(tower) then
                    -- Make it killable!
                    tower:RemoveModifierByName('modifier_invulnerable')
                end
            end
        end, nil)
    end
end

-- Prevents Fountain Camping
function Pregame:preventCamping()
    -- Should we prevent fountain camping?
    if self.optionStore['lodOptionCrazyNoCamping'] == 1 then
        local toAdd = {
            [SkillManager:GetMultiplierSkillName('ursa_fury_swipes')] = 4,
            templar_assassin_psi_blades = 1
        }

        local fountains = Entities:FindAllByClassname('ent_dota_fountain')
        -- Loop over all ents
        for k,fountain in pairs(fountains) do
            for skillName,skillLevel in pairs(toAdd) do
                fountain:AddAbility(skillName)
                local ab = fountain:FindAbilityByName(skillName)
                if ab then
                    ab:SetLevel(skillLevel)
                end
            end

            local item = CreateItem('item_monkey_king_bar', fountain, fountain)
            if item then
                fountain:AddItem(item)
            end
        end
    end
end

-- Return an instance of it
return Pregame()
