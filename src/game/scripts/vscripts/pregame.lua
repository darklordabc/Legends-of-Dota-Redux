--[[for k,v in pairs(_G) do
  print('key ', k, 'value ', v)
end
old_print = print
print = function(...)
    local calling_script = debug.getinfo(2).short_src
    old_print('Print called by: '..calling_script)
    old_print(...)
end



--[   VScript ]: key    ScriptDebugTextTrace    value   function: 0x0333db48
--[   VScript ]: key    SendToServerConsole value   function: 0x032bbfd0
--key   PrintLinkedConsoleMessage   value   function: 0x032bc058
old_error = PrintLinkedConsoleMessage
PrintLinkedConsoleMessage = function(...)
    --local calling_script = debug.getinfo(2).short_src
    print('Print called by: ') --..calling_script)
    old_error(...)
end
]]
--error('asfasdf')

-- Libraries
local constants = require('constants')
local SkillManager = require('skillmanager')
local SU = require('lib/StatUploaderFunctions')
local Timers = require('easytimers')
local SpellFixes = require('spellfixes')
require('statcollection.init')
local Debug = require('lod_debug')              -- Debug library with helper functions, by Ash47
local challenge = require('challenge')
local ingame = require('ingame')
local localStorage = require("lib/LocalStorage")
require('lib/wearables')

-- This should alone be used if duels are on.
--require('lib/util_aar')

require('chat')
require('dedicated')
require('util')

-- Custom AI script modifiers
LinkLuaModifier( "modifier_slark_shadow_dance_ai", "abilities/botAI/modifier_slark_shadow_dance_ai.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_alchemist_chemical_rage_ai", "abilities/botAI/modifier_alchemist_chemical_rage_ai.lua" ,LUA_MODIFIER_MOTION_NONE )
--LinkLuaModifier( "modifier_rattletrap_rocket_flare_ai", "abilities/botAI/modifier_rattletrap_rocket_flare_ai.lua" ,LUA_MODIFIER_MOTION_NONE )

-- Creep power modifier
LinkLuaModifier("modifier_neutral_power", "abilities/modifiers/modifier_neutral_power.lua", LUA_MODIFIER_MOTION_NONE)

--[[
    Main pregame, selection related handler
]]

local Pregame = class({})
local buildBackups = {}

-- Init pregame stuff
function Pregame:init()
    -- Store for options
    self.optionStore = {}

    OptionManager:SetOption('mapname', GetMapName())

    -- If single player redirect players to the more fully-featured map
    if util:isSinglePlayerMode() and not IsInToolsMode() then
        OptionManager:SetOption('mapname', 'dota')
    end

    -- Store for selected heroes and skills
    self.selectedHeroes = {}
    self.selectedPlayerAttr = {}
    self.selectedSkills = {}
    self.selectedRandomBuilds = {}

    -- Mirror draft stuff
    self.useDraftArrays = false
    self.maxDraftHeroes = 30
    self.maxDraftSkills = 0

    -- Some default values
    self.fastBansTotalBans = 3
    self.fastHeroBansTotalBans = 1

    -- Stores which playerIDs we have already spawned
    self.spawnedHeroesFor = {}

    -- List of banned abilities
    self.bannedAbilities = {}

    -- List of banned heroes
    self.bannedHeroes = {}

    -- Stores the total bans for each player
    self.usedBans = {}
    self.playerBansList = {}

    self.soundList = util:swapTable(LoadKeyValues('scripts/kv/sounds.kv'))

    -- Who is ready?
    self.isReady = {}
    self.shouldFreezeHostTime = nil

    -- Fetch player data
    self:preparePlayerDataFetch()

    -- Set it to the loading phase
    self:setPhase(constants.PHASE_LOADING)

    -- Setup phase stuff
    GameRules:SetCustomGameSetupTimeout(-1)
    GameRules:EnableCustomGameSetupAutoLaunch(false)
    self:sendContributors()

    self.chanceToHearMeme = 1
    self.freeAbility = nil

    self.heard = {}

    self.votingStatFlags = {}
    self.optionVoteSettings = {
        banning = {
            onselected = function(self)
                self:setOption('lodOptionBanning', 3, true)
                self:setOption('lodOptionBanningMaxBans', 3, true)
                self:setOption('lodOptionBanningMaxHeroBans', 2, true)
            end,
            onunselected = function(self)
                OptionManager:SetOption('banningTime', 25)
                self:setOption('lodOptionBanning', 3, true)
                self:setOption('lodOptionBanningMaxBans', 2, true)
                self:setOption('lodOptionBanningMaxHeroBans', 1, true)
            end
        },
        fastStart = {
            onselected = function(self)
                self:setOption('lodOptionGameSpeedStartingLevel', 1, true)
                self:setOption('lodOptionGameSpeedStartingGold', 3500, true)
            end,
            onunselected = function(self)
                self:setOption('lodOptionGameSpeedStartingLevel', 1, true)
                self:setOption('lodOptionGameSpeedStartingGold', 0, true)
            end
        },
        noInvis = {
            onselected = function(self)
                self:setOption('lodOptionBanningBanInvis', 2, true)
            end,
            onunselected = function(self)
                self:setOption('lodOptionBanningBanInvis', 0, true)
            end
        },
        antirat = {
            onselected = function(self)
                self:setOption('lodOptionAntiRat', 1, false)
            end,
            onunselected = function(self)
                self:setOption('lodOptionAntiRat', 0, false)
            end
        },
        strongTowers = {
            onselected = function(self)
                self:setOption('lodOptionGameSpeedStrongTowers', 1, true)
                self:setOption('lodOptionCreepPower', 120, true)
                self:setOption('lodOptionGameSpeedTowersPerLane', 3, true)
            end,
            onunselected = function(self)
                self:setOption('lodOptionGameSpeedStrongTowers', 0, true)
                self:setOption('lodOptionGameSpeedTowersPerLane', 3, true)
            end
        },
        customAbilities = {
            onselected = function(self)
                self:setOption('lodOptionAdvancedCustomSkills', 1, true)
            end,
            onunselected = function(self)
                self:setOption('lodOptionAdvancedCustomSkills', 0, true)
            end
        },
        OPAbilities = {
            onselected = function(self)
                self:setOption('lodOptionAdvancedOPAbilities', 0, true)
            end,
            onunselected = function(self)
                self:setOption('lodOptionAdvancedOPAbilities', 1, true)
            end
        },
        heroPerks = {
            onselected = function(self)
                self:setOption('lodOptionDisablePerks', 0, true)
            end,
            onunselected = function(self)
                self:setOption('lodOptionDisablePerks', 1, true)
            end
        },
        doubledAbilityPoints = {
            onselected = function(self)
                self:setOption('lodOptionBalanceModePoints', 180, true)
                if not util:isCoop() then
                    self:setOption('lodOptionBanningUseBanList', 1, true)
                end
                if mapName == 'all_allowed' or mapName == 'overthrow' then
                    self:setOption('lodOptionBanningUseBanList', 0, true)
                end

            end,
            onunselected = function(self)
                self:setOption('lodOptionBalanceModePoints', 120, true)
            end
        },
        singlePlayerAbilities = {
            onselected = function(self)
                self:setOption('lodOptionAdvancedCustomSkills', 1, true)
                self:setOption('lodOptionBanningUseBanList', 0, true)
                self:setOption('lodOptionBanning', 3, true)
                self:setOption('lodOptionBanningMaxBans', 4, true)
                self:setOption('lodOptionBanningMaxHeroBans', 1, true)
            end,
            onunselected = function(self)
                self:setOption('lodOptionBanningUseBanList', 1, true)
            end
        },
    }

    -- Init thinker
    GameRules:GetGameModeEntity():SetThink('onThink', self, 'PregameThink', 0.25)
    GameRules:SetHeroSelectionTime(0)   -- Hero selection is done elsewhere, hero selection should be instant
    GameRules:GetGameModeEntity():SetBotThinkingEnabled(true)
    GameRules:SetStrategyTime( 0 )
    GameRules:SetShowcaseTime( 10 )
    GameRules:GetGameModeEntity():SetCustomGameForceHero("npc_dota_hero_wisp")

    -- Rune fix
    local totalRunes = 0
    local needBounty = false
    GameRules:GetGameModeEntity():SetRuneSpawnFilter(function(context, runeStuff)
        totalRunes = totalRunes + 1
        if totalRunes < 3 then
            runeStuff.rune_type = DOTA_RUNE_BOUNTY
        else
            if totalRunes % 2 == 1 then
                if math.random() < 0.5 then
                    needBounty = false
                    runeStuff.rune_type = DOTA_RUNE_BOUNTY
                else
                    needBounty = true
                    runeStuff.rune_type = util:pickRandomRune()
                end
            else
                if needBounty then
                    runeStuff.rune_type = DOTA_RUNE_BOUNTY
                else
                    runeStuff.rune_type = util:pickRandomRune()

                end

                -- No longer need a bounty rune
                needBounty = false
            end
        end

        return true
    end, self)

    -- Init options
    self:initOptionSelector()

    -- Grab a reference to self
    local this = self

    --[[
        Listen to events
    ]]

    CustomGameEventManager:RegisterListener('lodOnCheats', function(eventSourceIndex, args)
        if self:getPhase() > constants.PHASE_OPTION_SELECTION then
            if args.command then
                Commands:OnPlayerChat({
                    teamonly = true,
                    playerid = args.PlayerID,
                    text = "-" .. args.command
                })
            end

            if args.consoleCommand and (util:isSinglePlayerMode() or Convars:GetBool("sv_cheats") or self.voteEnabledCheatMode) then
                SendToServerConsole(args.consoleCommand)
            end
        end
    end)

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

    -- Player wants to open ingame builder
    CustomGameEventManager:RegisterListener('lodOnIngameBuilder', function(eventSourceIndex, args)
        this:onIngameBuilder(eventSourceIndex, args)
    end)

    -- Player wants to set their hero
    CustomGameEventManager:RegisterListener('lodChooseHero', function(eventSourceIndex, args)
        this:onPlayerSelectHero(eventSourceIndex, args)
    end)

    -- Player wants to set their new primary attribute
    CustomGameEventManager:RegisterListener('lodChooseAttr', function(eventSourceIndex, args)
        this:onPlayerSelectAttr(eventSourceIndex, args)
    end)

    -- Player wants to remove an ability
    CustomGameEventManager:RegisterListener('lodRemoveAbility', function(eventSourceIndex, args)
        this:onPlayerRemoveAbility(eventSourceIndex, args)
    end)

    -- Player wants to change which ability is in a slot
    CustomGameEventManager:RegisterListener('lodChooseAbility', function(eventSourceIndex, args)
        this:onPlayerSelectAbility(eventSourceIndex, args)
    end)

    -- Player wants a random ability for a slot
    CustomGameEventManager:RegisterListener('lodChooseRandomAbility', function(eventSourceIndex, args)
        this:onPlayerSelectRandomAbility(eventSourceIndex, args)
    end)

    -- Player wants to swap two slots
    CustomGameEventManager:RegisterListener('lodSwapSlots', function(eventSourceIndex, args)
        this:onPlayerSwapSlot(eventSourceIndex, args)
    end)

    -- Player wants to perform a ban
    CustomGameEventManager:RegisterListener('lodBan', function(eventSourceIndex, args)
        this:onPlayerBan(eventSourceIndex, args)
    end)

    -- Player wants to save bans
    CustomGameEventManager:RegisterListener('lodSaveBans', function(eventSourceIndex, args)
        this:onPlayerSaveBans(eventSourceIndex, args)
    end)

    -- Player wants to load bans
    CustomGameEventManager:RegisterListener('lodLoadBans', function(eventSourceIndex, args)
        this:onPlayerLoadBans(eventSourceIndex, args)
    end)

    -- Player wants to ready up
    CustomGameEventManager:RegisterListener('lodReady', function(eventSourceIndex, args)
        this:onPlayerReady(eventSourceIndex, args)
    end)

    -- Player wants to select their all random build
    CustomGameEventManager:RegisterListener('lodSelectAllRandomBuild', function(eventSourceIndex, args)
        this:onPlayerSelectAllRandomBuild(eventSourceIndex, args)
    end)

    -- Player wants to select a full build
    CustomGameEventManager:RegisterListener('lodSelectBuild', function(eventSourceIndex, args)
        this:onPlayerSelectBuild(eventSourceIndex, args)
    end)

    -- Player wants their hero to be spawned
    CustomGameEventManager:RegisterListener('lodSpawnHero', function(eventSourceIndex, args)
        this:onPlayerAskForHero(eventSourceIndex, args)
    end)

    -- Player wants to cast a vote
    CustomGameEventManager:RegisterListener('lodCastVote', function(eventSourceIndex, args)
        this:onPlayerCastVote(eventSourceIndex, args)
    end)

    CustomGameEventManager:RegisterListener('lodChangeHost', function(eventSourceIndex, args)
        this:onGameChangeHost(eventSourceIndex, args)
    end)

    CustomGameEventManager:RegisterListener('lodOnChangeLock', function(eventSourceIndex, args)
        this:onGameChangeLock(eventSourceIndex, args)
    end)

    CustomGameEventManager:RegisterListener('lodChooseRandomHero', function(eventSourceIndex, args)
        this:onPlayerSelectRandomHero(eventSourceIndex, args)
    end)

    --List of keys in perks.kv, that aren't perks
    local NotPerks = {
        chen_creep_abilities = true,
        male = true,
        female = true,
        heroAbilityPairs = true,
    }
    local ability_perks = {}
    local function AddPerkToAbility(ability, perk)
        ability_perks[ability] = ability_perks[ability] == nil and perk or (ability_perks[ability] .. "|" .. perk)
    end
    for k,v in pairs(GameRules.perks) do
        if not NotPerks[k] then
            for ability,_ in pairs(v) do
                if string.sub(ability,1,string.len("item_")) ~= "item_" then
                    AddPerkToAbility(ability, k)
                end
            end
        end
    end
    for tabName, tabList in pairs(LoadKeyValues('scripts/kv/abilities.kv').skills) do
        for abilityName,abilityGroup in pairs(tabList) do
            if type(abilityGroup) == "table" then
                for groupedAbilityName,_ in pairs(abilityGroup) do
                    if IsCustomAbilityByName(groupedAbilityName) then
                        AddPerkToAbility(groupedAbilityName, "custom_ability")
                    end
                end
            elseif IsCustomAbilityByName(abilityName) then
                AddPerkToAbility(abilityName, "custom_ability")
            end
        end
    end
    local npc_abilities = LoadKeyValues('scripts/npc/npc_abilities.txt')
    local absCustom = LoadKeyValues('scripts/npc/npc_abilities_custom.txt')
    for k,v in pairs(absCustom) do
        npc_abilities[k] = v
    end
    for abilityName,data in pairs(npc_abilities) do
        if type(data) == 'table' and data.AbilityBehavior and string.match(data.AbilityBehavior, 'DOTA_ABILITY_BEHAVIOR_TOGGLE') then
            AddPerkToAbility(abilityName, 'toggle_ability')
        end
    end
    CustomGameEventManager:RegisterListener('lodRequestAbilityPerkData', function(eventSourceIndex, args)
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(args.PlayerID), "lodRequestAbilityPerkData", ability_perks)
    end)

    CustomGameEventManager:RegisterListener('lodGameSetupPing', function(eventSourceIndex, args)
        local player = PlayerResource:GetPlayer(args.PlayerID)
        local content = args.content
        local t = args.type

        local ourPhase = self:getPhase()

        local word = "banning"
        if ourPhase == constants.PHASE_SELECTION then
            if t == "hero" then
                word = "picking"
            else
                word = "selecting"
            end
        elseif ourPhase ~= constants.PHASE_BANNING then
            return
        end

        local finish = "!"
        if t == "ability" then
            finish = "ability"
        end

        local text = "Think of "..word.." <font color='#FFFFFF'>"..content.."</font> "..finish

        Chat:Say({PlayerID = args.PlayerID, msg = text, channel = "team"})

        CustomGameEventManager:Send_ServerToTeam(player:GetTeam(),"lodGameSetupPingEffect",args)
    end)

    -- Init debug
    Debug:init()

    -- Init chat
    Chat:Init()

    -- Fix spawning issues
    self:fixSpawningIssues()

    -- Network heroes
    self:networkHeroes()

    -- Setup default option related stuff
    network:setActiveOptionsTab('presets')

    self:loadDefaultSettings()

    -- If its single player, enable single player abilities
    Timers:CreateTimer(function()
        if util:isSinglePlayerMode() then
            self:setOption('lodOptionBanningUseBanList', 0, true)
        end
    end, DoUniqueString('checkSinglePlayer'), 1.5)

    -- Map enforcements
    local mapName = OptionManager:GetOption('mapname')

    -- Init overthrow code
    if mapName == 'overthrow' then
        require( "overthrow/overthrow" )
        COverthrowGameMode:Activate()
    end

    -- All Pick Only
    if mapName == 'all_pick' then
        self:setOption('lodOptionGamemode', 1)
        self.useOptionVoting = true
    end

    -- Fast All Pick Only
    if mapName == 'all_pick_fast' then
        self:setOption('lodOptionGamemode', 2)
        self.useOptionVoting = true
    end

    -- Standard gamemode featuring voting system
    if mapName == 'standard' then
        self:setOption('lodOptionGamemode', 1)
        self:setOption('lodOptionBalanceMode', 1, true)
        OptionManager:SetOption('banningTime', 50)
        --self:setOption('lodOptionBanningBalanceMode', 1, true)
        --self:setOption('lodOptionGameSpeedRespawnTimePercentage', 70, true)
        --self:setOption('lodOptionBuybackCooldownTimeConstant', 210, true)
        self:setOption('lodOptionGameSpeedGoldModifier', 225, true)
        self:setOption('lodOptionGameSpeedEXPModifier', 225, true)
        self:setOption('lodOptionGameSpeedMaxLevel', 100, true)
        self:setOption('lodOptionGameSpeedRespawnTimePercentage', 35, true)
        self:setOption('lodOptionCrazyUniversalShop', 0, true)
        self.useOptionVoting = true
    end

    if mapName == 'all_allowed' then
        self:setOption('lodOptionCrazyUniversalShop', 0, true)
        self:setOption('lodOptionGameSpeedSharedEXP', 1, true)
        self:setOption('lodOptionBanningUseBanList', 1, true)
        self:setOption('lodOptionAdvancedOPAbilities', 1, true)
        self:setOption('lodOptionGameSpeedMaxLevel', 100, true)
        self:setOption('lodOptionGamemode', 1)
        self:setOption('lodOptionBattleThirst', 0)
        self:setOption('lodOptionGameSpeedStartingLevel', 1, true)
        self:setOption('lodOptionGameSpeedStartingGold', 2500, true)
        self:setOption('lodOptionGameSpeedStrongTowers', 1, true)
        self:setOption('lodOptionCreepPower', 120, true)

        self:setOption('lodOptionGameSpeedTowersPerLane', 3, true)
        OptionManager:SetOption('banningTime', 50)
        self:setOption('lodOptionBalanceMode', 0, true)
        self:setOption('lodOptionGameSpeedGoldModifier', 200, true)
        self:setOption('lodOptionGameSpeedGoldTickRate', 2, true)
        self:setOption('lodOptionGameSpeedEXPModifier', 200, true)
        self:setOption('lodOptionAdvancedHidePicks', 0, true)
        self:setOption('lodOptionCommonMaxUlts', 2, true)
        --self:setOption("lodOptionCrazyFatOMeter", 2)
        self:setOption('lodOptionGameSpeedRespawnTimePercentage', 35, true)
        self.useOptionVoting = true
        self.optionVoteSettings.doubledAbilityPoints = nil
    end

    if mapName == 'overthrow' then
        self:setOption('lodOptionCrazyUniversalShop', 0, true)
        self:setOption('lodOptionGameSpeedSharedEXP', 1, true)
        self:setOption('lodOptionBanningUseBanList', 1, true)
        self:setOption('lodOptionAdvancedOPAbilities', 1, true)
        self:setOption('lodOptionGameSpeedMaxLevel', 100, true)
        self:setOption('lodOptionGamemode', 1)
        self:setOption('lodOptionBattleThirst', 0)
        self:setOption('lodOptionGameSpeedStartingLevel', 1, true)
        self:setOption('lodOptionGameSpeedStartingGold', 2500, true)
        self:setOption('lodOptionGameSpeedStrongTowers', 1, true)
        self:setOption('lodOptionCreepPower', 120, true)
        self:setOption('lodOption322', 1, true)
        self:setOption('lodOptionGameSpeedTowersPerLane', 3, true)
        OptionManager:SetOption('banningTime', 50)
        self:setOption('lodOptionBalanceMode', 0, true)
        self:setOption('lodOptionGameSpeedGoldModifier', 100, true)
        self:setOption('lodOptionGameSpeedGoldTickRate', 1, true)
        self:setOption('lodOptionGameSpeedEXPModifier', 100, true)
        self:setOption('lodOptionAdvancedHidePicks', 0, true)
        self:setOption('lodOptionCommonMaxUlts', 2, true)
        self:setOption("lodOptionCrazyFatOMeter", 2)
        self:setOption('lodOptionGameSpeedRespawnTimePercentage', 35, true)
        self.useOptionVoting = true
        self.optionVoteSettings.doubledAbilityPoints = nil
    end

    -- Mirror Draft Only
    if mapName == 'mirror_draft' then
        self:setOption('lodOptionGamemode', 3)
        self.useOptionVoting = true
    end

    -- All random only
    if mapName == 'all_random' then
        self:setOption('lodOptionGamemode', 4)
        self.useOptionVoting = true
    end

    -- Custom -- set preset
    -- if mapName == 'custom' or mapName == 'custom_bot' or mapName == 'dota_180' or mapName == 'custom_702' or mapName == '10_vs_10' then
    if mapName == 'dota_180' or mapName == 'custom_702' or mapName == 'dota' or mapName == 'all_allowed_advanced' then
        self:setOption('lodOptionGamemode', 1)
    end

    -- Challenge Mode
    if mapName == 'challenge' then
        self.challengeMode = true
    end

    -- Default banning
    self:setOption('lodOptionBanning', 3)
    self:setOption('lodOptionBanningMaxBans', 0)
    self:setOption('lodOptionBanningMaxHeroBans', 0)

    -- Bot match
    -- if mapName == 'custom_bot' or mapName == 'custom_702' or mapName == 'dota_180' or mapName == '10_vs_10' then
    if mapName == 'dota_180' or mapName == 'custom_702' or mapName == 'dota' or mapName == 'all_allowed_advanced' then
        self.enabledBots = true
    end

    -- 3 VS 3
    if mapName == '3_vs_3' then
        self:setOption('lodOptionGamemode', 1)
        self:setOption('lodOptionSlots', 6, true)
        self:setOption('lodOptionCommonMaxUlts', 2, true)
        self:setOption('lodOptionBalanceMode', 1, true)
        self:setOption('lodOptionBanningBalanceMode', 1, true)
        self.useOptionVoting = true

        GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 3)
        GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 3)

        self:setOption('lodOptionBotsRadiant', 3, true)
        self:setOption('lodOptionBotsDire', 3, true)

    end

    -- 10 VS 10
    if mapName == '10_vs_10' then
        GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 10)
        GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 10)

        self:setOption('lodOptionBotsRadiant', 10, true)
        self:setOption('lodOptionBotsDire', 10, true)
    end

    -- Exports for stat collection
    local this = self
    function PlayerResource:getPlayerStats(playerID)
        return this:getPlayerStats(playerID)
    end
    -- Spawning stuff
    self.spawnQueue = {}
    self.currentlySpawning = false
    self.cachedPlayerHeroes = {}
end

-- Load Default Values
function Pregame:loadDefaultSettings()
    -- Total slots is copied
    self:setOption('lodOptionCommonMaxSlots', 6, true)

    -- Max skills is always 6
    self:setOption('lodOptionCommonMaxSkills', 6, true)

    -- Max ults is copied
    self:setOption('lodOptionCommonMaxUlts', 2, true)

    -- Set Draft Abilities to 100
    self:setOption('lodOptionCommonDraftAbilities', 100, true)
    self:setOption('lodOptionSlots', 6)
    self:setOption('lodOptionUlts', 2)
    self:setOption('lodOptionDraftAbilities', 25)

    -- Balance Mode disabled by default
    self:setOption('lodOptionBalanceMode', 0, true)
    self:setOption('lodOptionBalanceModePoints', 120, true)

    -- Consumeable Items
    self:setOption('lodOptionConsumeItems', 1, false)

    -- Anti Rat option
    self:setOption('lodOptionAntiRat', 0, false)

    -- Mutators disabled by default
    self:setOption('lodOptionDuels', 0, false)
    self:setOption('lodOption322', 0, false)
    self:setOption('lodOptionExtraAbility', 0, false)
    self:setOption('lodOptionRefreshCooldownsOnDeath', 0, false)
    self:setOption('lodOptionGlobalCast', 0, false)

    -- Balance Mode Ban List disabled by default
    self:setOption('lodOptionBanningBalanceMode', 0, true)
    self:setOption('lodOptionBalanceMode', 0, false)

    -- Set banning
    self:setOption('lodOptionBanning', 1)

    -- Single player abilities should be banned
    self:setOption('lodOptionBanningUseBanList', 1)

    -- Block troll combos is always on
    self:setOption('lodOptionBanningBlockTrollCombos', 1, true)

    -- Bots get bonus points by default
    --self:setOption('lodOptionBotsBonusPoints', 1, true)

    -- Default, we don't ban all invisiblity
    self:setOption('lodOptionBanningBanInvis', 0, true)

    -- Starting level is lvl 1
    self:setOption('lodOptionGameSpeedStartingLevel', 1, true)

    -- Max level is 28
    self:setOption('lodOptionGameSpeedMaxLevel', 28, true)

    -- Don't mess with gold rate
    self:setOption('lodOptionGameSpeedStartingGold', 0, true)
    self:setOption('lodOptionGameSpeedGoldTickRate', 1, true)
    self:setOption('lodOptionGameSpeedGoldModifier', 100, true)
    self:setOption('lodOptionGameSpeedEXPModifier', 100, true)
    self:setOption('lodOptionGameSpeedSharedEXP', 0, true)

    -- Default respawn time
    self:setOption('lodOptionGameSpeedRespawnTimePercentage', 70, true)
    self:setOption('lodOptionGameSpeedRespawnTimeConstant', 0, true)

    -- Buyback cooldown time

    self:setOption('lodOptionBuybackCooldownTimeConstant', 420, true)

    -- 3 Towers per lane
    self:setOption('lodOptionGameSpeedTowersPerLane', 3, true)

    -- Do not start scepter upgraded
    self:setOption('lodOptionGameSpeedUpgradedUlts', 0, true)

    -- Do not make stronger towers
    self:setOption('lodOptionGameSpeedStrongTowers', 0, true)
    self:setOption('lodOptionCreepPower', 0)
    self:setOption('lodOptionNeutralCreepPower', 0)

    -- Do not give battle thirst
    self:setOption('lodOptionBattleThirst', 0)

    -- Do not increase creep power
    self:setOption('lodOptionCreepPower', 0, true)
    self:setOption('lodOptionNeutralCreepPower', 0, true)
    self:setOption('lodOptionNeutralMultiply', 1, true)
    self:setOption('lodOptionLaneMultiply', 0, true)

    -- Start with a free courier
    self:setOption('lodOptionGameSpeedFreeCourier', 1, true)

    -- Set bot options
    self:setOption('lodOptionBotsRadiant', 5, true)
    self:setOption('lodOptionBotsDire', 5, true)
    self:setOption('lodOptionBotsUnfairBalance', 1, true)

    -- Turn easy mode off
    --self:setOption('lodOptionCrazyEasymode', 0, true)

    -- Enable IMBA abilities
    self:setOption('lodOptionAdvancedImbaAbilities', 0, true)

    -- Enable hero abilities
    self:setOption('lodOptionAdvancedHeroAbilities', 1, true)

    -- Enable neutral abilities
    self:setOption('lodOptionAdvancedNeutralAbilities', 1, true)

    -- Enable Custom Abilities
    self:setOption('lodOptionAdvancedCustomSkills', 0, true)

    -- Disable OP abilities
    self:setOption('lodOptionAdvancedOPAbilities', 1, true)

    -- Unique Skills default
    self:setOption('lodOptionBotsUniqueSkills', 1, true)

    -- Unique Skills default
    self:setOption('lodOptionBotsStupid', 0, true)

    -- Restrict Skills default
    self:setOption('lodOptionBotsRestrict', 0, true)

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

    -- Enable Universal Shop
    self:setOption('lodOptionCrazyUniversalShop', 1, true)

    -- Disable All Vision
    self:setOption('lodOptionCrazyAllVision', 0, true)

    -- Disable Multicast Madness
    self:setOption('lodOptionCrazyMulticast', 0, true)

    -- Disable WTF Mode
    self:setOption('lodOptionCrazyWTF', 0, true)

    -- Disable ingame hero builder
    self:setOption('lodOptionIngameBuilder', 0, true)
    self:setOption("lodOptionIngameBuilderPenalty", 0)

    -- Enable Perks
    self:setOption('lodOptionDisablePerks', 0, false)

    -- Disable Fat-O-Meter
    self:setOption("lodOptionCrazyFatOMeter", 0)

    -- Normal speed
    self:setOption("lodOptionGottaGoFast", 0)

    -- NO MEMES UncleNox
    self:setOption("lodOptionMemesRedux", 0)

    -- No Blood Thirst
    self:setOption("lodOptionBloodThirst", 0)

    -- No Item Drops
    self:setOption("lodOptionDarkMoon", 0)

    -- No Dark Forest
    self:setOption('lodOptionBlackForest', 0, true)

    -- Selecting 6 new abilities grants 500 gold
    self:setOption("lodOptionNewAbilitiesThreshold", 20, true)
    self:setOption("lodOptionNewAbilitiesBonusGold", 500, true)
end

-- Gets stats for the given player
function Pregame:getPlayerStats(playerID)
    local playerInfo =  {
        steamID32 = PlayerResource:GetSteamAccountID(playerID),                         -- steamID32    The player's steamID
    }

    -- Add selected hero
    playerInfo.h = (self.selectedHeroes[playerID] or ''):gsub('npc_dota_hero_', '')     -- h            The hero they selected

    -- Add selected skills
    local build = self.selectedSkills[playerID] or {}
    for i=1,6 do
        playerInfo['A' .. i] = build[i] or ''                                           -- A[1-6]       Ability 1 - 6
    end

    -- Add selected attribute
    playerInfo.s = self.selectedPlayerAttr[playerID] or ''                              -- s            Selected Attribute (str, agi, int)

    -- Grab there hero and attempt to add info on it
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)

    -- Ensure we have a hero
    if hero ~= nil then
        -- Attempt to find team
        playerInfo.t = hero:GetTeam()                                                   -- t            The team number this player is on

        -- Read key info
        playerInfo.l = hero:GetLevel()                                                  -- l            The level of this hero
        playerInfo.k = hero:GetKills()                                                  -- k            The number of kills this hero has
        playerInfo.a = hero:GetAssists()                                                -- a            The number of assists this player has
        playerInfo.d = hero:GetDeaths()                                                 -- d            The number of deaths this player has
        playerInfo.g = math.floor(PlayerResource:GetGoldPerMin(playerID))               -- g            This player's gold per minute
        playerInfo.x = math.floor(PlayerResource:GetXPPerMin(playerID))                 -- x            This player's EXP per minute
        playerInfo.r = math.floor(PlayerResource:GetGold(playerID))                     -- r            How much gold this player currently has
        for slotID=1,6 do
            local item = hero:GetItemInSlot(slotID - 1)

            if item then
                playerInfo['I' .. slotID] = item:GetAbilityName():gsub('item_', '')     -- I[1-6]       Items 1 - 6
            else
                playerInfo['I' .. slotID] = ''
            end
        end
    else
        -- Default values if hero doesn't exist for some weird reason
        playerInfo.t = 0
        playerInfo.l = 0
        playerInfo.k = 0
        playerInfo.a = 0
        playerInfo.d = 0
        playerInfo.g = 0
        playerInfo.x = 0
        playerInfo.r = 0
        playerInfo['I1'] = ''
        playerInfo['I2'] = ''
        playerInfo['I3'] = ''
        playerInfo['I4'] = ''
        playerInfo['I5'] = ''
        playerInfo['I6'] = ''
    end

    return playerInfo
end

-- Checks for premium players
function Pregame:checkForPremiumPlayers()
    local maxPlayerID = 24

    -- Stores premium info
    local premiumInfo = {}

    for playerID=0,maxPlayerID-1 do
        if PlayerResource:GetConnectionState(playerID) >= 2 then
            premiumInfo[playerID] = util:getPremiumRank(playerID)
        end
    end

    -- Push the premium info
    network:setPremiumInfo(premiumInfo)
end

-- Send the contributors
function Pregame:sendContributors()
    local sortedContributors = {}
    for i=0,util:getTableLength(util.contributors) do
        table.insert(sortedContributors, util.contributors[tostring(i)])
    end

    -- Push the contributors
    network:setContributors(sortedContributors)
end

function Pregame:startBoosterDraftRound( pID )
    local currentRound = util:getTableLength(self.finalArrays[pID])

    local duration = 25
    if self.finalArrays[pID] then
        duration = 50
    end
    network:setCustomEndTimer(PlayerResource:GetPlayer(pID), Time() + duration)

    Timers:CreateTimer(function()
        if not self.waitForArray[pID] and self.boosterDraftPicking[pID] then
            if not self.draftArrays[pID] then
                return
            end

            if currentRound ~= util:getTableLength(self.finalArrays[pID]) then
                return
            end

            local abName = nil
            local oldCost = 0

            local abilities = self.draftArrays[pID].abilityDraft

            for k,v in pairs(self.draftArrays[pID].abilityDraft) do
                if v then
                    if self.spellCosts[k] and self.spellCosts[k] > oldCost then
                        oldCost = self.spellCosts[k]
                        abName = k
                    end
                    if not abName then
                        abName = k
                    end
                end
            end

            self:setSelectedAbility(pID, -1, abName)
        end
    end, DoUniqueString(tostring(pID).."boosterDraft"), duration + 1)
end

function Pregame:applyBuilds()
    local maxPlayerID = 24
    for playerID=0,maxPlayerID-1 do
        Timers:CreateTimer(function ()
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)

            if hero ~= nil and IsValidEntity(hero) then
                local build = self.selectedSkills[playerID]

                if build then
                    local status2,err2 = pcall(function()
                        SkillManager:ApplyBuild(hero, build or {})

                        buildBackups[playerID] = build

                        self:fixSpawnedHero( hero )
                    end)
                end
            else
                return 1.0
            end
        end, DoUniqueString("applyBuildsLoop"), (playerID + 1) / 10)
    end
end

function Pregame:applyPrimaryAttribute(playerID, hero)
    if self.selectedPlayerAttr[playerID] ~= nil then
        local toSet = 0

        if self.selectedPlayerAttr[playerID] == 'str' then
            toSet = 0
        elseif self.selectedPlayerAttr[playerID] == 'agi' then
            toSet = 1
        elseif self.selectedPlayerAttr[playerID] == 'int' then
            toSet = 2
        end

        Timers:CreateTimer(function()
            if IsValidEntity(hero) then
                hero:SetPrimaryAttribute(toSet)
            end
        end, DoUniqueString('primaryAttrFix'), 0.1)
    end
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
            -- Are we using challenge mode?
            if self.challengeMode then
                -- Setup challenge mode
                challenge:setup(self)
                return 0.1
            end

            Chat:Say( {channel = "all", msg = "chatChannelsAnnouncement", PlayerID = -1, localize = true})

            StatsClient:FetchAbilityUsageData()

            -- Are we using option selection, or option voting?
            if self.useOptionVoting then
                -- Option voting
                self:setPhase(constants.PHASE_OPTION_VOTING)
                -- QUICKER DEBUGGING
                if IsInToolsMode() then
                    OptionManager:SetOption('maxOptionVotingTime', 7)
                end

                self:setEndOfPhase(Time() + OptionManager:GetOption('maxOptionVotingTime'))
            else
                -- Option selection
                if self.shouldFreezeHostTime == nil then
                    self.shouldFreezeHostTime = util:isSinglePlayerMode()
                    for i=0,DOTA_MAX_PLAYERS do
                        if PlayerResource:IsValidPlayer(i) then
                            local player = PlayerResource:GetPlayer(i)
                            if player and GameRules:PlayerHasCustomGameHostPrivileges(player) then
                                self.mainHost = player:GetPlayerID()
                                player.isHost = true
                                break
                            end
                        end
                    end
                end
                self:setPhase(constants.PHASE_OPTION_SELECTION)
                if self.shouldFreezeHostTime == true then
                    self:setEndOfPhase(Time() + OptionManager:GetOption('maxOptionSelectionTime'), OptionManager:GetOption('maxOptionSelectionTime'))
                else
                    self:setEndOfPhase(Time() + OptionManager:GetOption('maxOptionSelectionTime'))
                end
            end
        end

        -- Wait for time to pass
        return 0.1
    end

    -- Check for premium players
    if not self.checkedPremiumPlayers then
        self.checkedPremiumPlayers = true
        self:checkForPremiumPlayers()
    end

    --[[
        OPTION SELECTION PHASE
    ]]
    if ourPhase == constants.PHASE_OPTION_SELECTION then

        --Run once
        if not self.Announce_option_selection then
            self.Announce_option_selection = true
            for playerID = 0,23 do
                local steamID = PlayerResource:GetSteamAccountID(playerID)
                if steamID ~= 0 then
                    local player = PlayerResource:GetPlayer(playerID)
                    -- If it is a host
                    if isPlayerHost(player) then
                        local sound = self:getRandomSound('game_option_host')
                        EmitAnnouncerSoundForPlayer(sound, playerID)
                    else
                        local sound = self:getRandomSound('game_option_player')
                        EmitAnnouncerSoundForPlayer(sound, playerID)
                    end
                end
            end

            -- Is it single player game do not have the cooldown on the lock build button
            if util:isSinglePlayerMode() or IsInToolsMode() then
                CustomGameEventManager:Send_ServerToAllClients("lodSinglePlayer",{})
            end
        end
        -- Is it over?
        if Time() >= self:getEndOfPhase() and self.freezeTimer == nil then
            -- Finish the option selection
            self:finishOptionSelection()
        end

        return 0.1
    end

    --[[
        OPTION VOTING PHASE
    ]]

    if ourPhase == constants.PHASE_OPTION_VOTING then
        -- Is it over?
        if Time() >= self:getEndOfPhase() and self.freezeTimer == nil then
            -- Finish the option selection
            self:finishOptionSelection()
            if util:isCoop() then
                print("vote ended")
                self.enabledBots = true
                self.desiredRadiant = self.desiredRadiant or 5
                self.desiredDire = self.desiredDire or 5
            end
        end

        return 0.1
    end

    -- Process options ONCE here
    if not self.processedOptions then
        -- Process options
        self:processOptions()
    end

    -- Try to add bot players
    if not self.addedBotPlayers then
        self:addBotPlayers()
    end

    --[[
        BANNING PHASE
    ]]
    if ourPhase == constants.PHASE_BANNING then
        -- Is it over?
        if Time() >= self:getEndOfPhase() and self.freezeTimer == nil then
            -- Is there hero selection?
            if self.noHeroSelection then
                -- Is there all random selection?
                if self.allRandomSelection then
                    -- Goto all random
                    self:setPhase(constants.PHASE_RANDOM_SELECTION)
                    self:setEndOfPhase(Time() + OptionManager:GetOption('randomSelectionTime'), OptionManager:GetOption('randomSelectionTime'))
                else
                    -- Change to picking phase
                    self:setPhase(constants.PHASE_SPAWN_HEROES)

                    -- Kill the selection screen
                    self:setEndOfPhase(Time() + OptionManager:GetOption('reviewTime'), OptionManager:GetOption('reviewTime'))

                    GameRules:FinishCustomGameSetup()
                end
            else
                -- Change to picking phase
                self:setPhase(constants.PHASE_SELECTION)
                self:setEndOfPhase(Time() + OptionManager:GetOption('pickingTime'), OptionManager:GetOption('pickingTime'))
            end
        end

        return 0.1
    end

    -- Selection phase
    if ourPhase == constants.PHASE_SELECTION then
        GameRules:GetGameModeEntity():SetCustomGameForceHero("")

        if self.useDraftArrays and not self.draftArrays then
            self:buildDraftArrays()

            if self.boosterDraft then
                network:broadcastNotification({
                    sort = 'lodSuccess',
                    text = 'lodBoosterDraftStart'
                })

                for i=0,DOTA_MAX_TEAM_PLAYERS-1 do
                    network:setCustomEndTimer(PlayerResource:GetPlayer(i), Time() + 25, 25)
                end
            end
        end

        if not self.Announce_Picking_Phase then
            self.Announce_Picking_Phase = true
            if OptionManager:GetOption("memesRedux") == 1 then
                EmitGlobalSound("Memes.IntroSong")
            else
                local sound = self:getRandomSound('game_picking_phase')
                EmitAnnouncerSound(sound)
            end
        end

        --Check if countdown reaches 30 sec remaining
        if Time() + 30 >= self:getEndOfPhase() and Time() + 3 <= self:getEndOfPhase() and self.freezeTimer == nil and not self.Announce_30 then
            self.Announce_30 = true
            local sound = self:getRandomSound('game_30_sec_remaining')
            EmitAnnouncerSound(sound)
        end

        --Check if countdown reaches 15 sec remaining
        if Time() + 15 >= self:getEndOfPhase() and Time() + 3 <= self:getEndOfPhase() and self.freezeTimer == nil and not self.Announce_15 then
            self.Announce_15 = true
            local sound = self:getRandomSound('game_15_sec_remaining')
            EmitAnnouncerSound(sound)
        end

        --Check if countdown reaches 10 sec remaining
        if Time() + 10 >= self:getEndOfPhase() and Time() + 3 <= self:getEndOfPhase() and self.freezeTimer == nil and not self.Announce_10 then
            self.Announce_10 = true
            local sound = self:getRandomSound('game_10_sec_remaining')
            EmitAnnouncerSound(sound)
        end

        if Time() + 6 >= self:getEndOfPhase() and Time() + 3 <= self:getEndOfPhase() and self.freezeTimer == nil and not self.Pick_Hero then
            self.Pick_Hero = true
            for playerID = 0,23 do
                local steamID = PlayerResource:GetSteamAccountID(playerID)
                if steamID ~= 0 then
                    hero = self.selectedHeroes[playerID]
                    if hero == nil then
                        local sound = self:getRandomSound('game_6_sec_remaining')
                        EmitAnnouncerSoundForPlayer(sound, playerID)
                    end
                end
            end
        end

        -- Pick builds for bots
        if not self.doneBotStuff then
            self.doneBotStuff = true
            self:generateBotBuilds()
        end

        -- Is it over?
        if Time() >= self:getEndOfPhase() and self.freezeTimer == nil then
            local didNotSelectAHero = util:checkPickedHeroes( self.selectedHeroes )
            if didNotSelectAHero == nil or self.noHeroSelection or self.additionalPickTime or util:isSinglePlayerMode() then
                -- Change to picking phase
                self:setPhase(constants.PHASE_SPAWN_HEROES)

                -- Kill the selection screen
                self:setEndOfPhase(Time() + OptionManager:GetOption('reviewTime'), OptionManager:GetOption('reviewTime'))

                GameRules:FinishCustomGameSetup()
            else
                self.additionalPickTime = true
                self:setEndOfPhase(Time() + 15.0)
                CustomGameEventManager:Send_ServerToAllClients("lodRestrictToHeroSelection", {})
                EmitAnnouncerSound("Redux.Overtime")

                Timers:CreateTimer(function (  )
                    for playerID = 0,23 do
                        local steamID = PlayerResource:GetSteamAccountID(playerID)
                        if steamID ~= 0 then
                            hero = self.selectedHeroes[playerID]
                            if hero == nil then
                                local sound = self:getRandomSound('game_6_sec_remaining')
                                EmitAnnouncerSoundForPlayer(sound, playerID)
                            end
                        end
                    end
                end, DoUniqueString("chooseYourHeroAnnouncment"), 3.0)
            end
        end

        return 0.1
    end

    -- All random phase
    if ourPhase == constants.PHASE_RANDOM_SELECTION then
        if not self.allRandomBuilds then
            self:generateAllRandomBuilds()
        end

        -- Pick builds for bots
        if not self.doneBotStuff then
            self.doneBotStuff = true
            self:generateBotBuilds()
        end

        -- Is it over?
        if Time() >= self:getEndOfPhase() and self.freezeTimer == nil then
            -- Change to picking phase
            self:setPhase(constants.PHASE_SPAWN_HEROES)

            -- Kill the selection screen
            self:setEndOfPhase(Time() + OptionManager:GetOption('reviewTime'), OptionManager:GetOption('reviewTime'))

            GameRules:FinishCustomGameSetup()
        end

        return 0.1
    end

    -- Process options ONCE here
    if not self.validatedBuilds then
        self:validateBuilds()
        self:precacheBuilds()
    end

    -- Review
    -- if ourPhase == constants.PHASE_REVIEW then
    --     -- Is it over?

    --     --QUICKER DEBUGGING CHANGE (the ToolsMode check) - Skips review phase
    --     if Time() >= self:getEndOfPhase() and self.freezeTimer == nil or IsInToolsMode() then
    --         -- Change to picking phase
    --         self:setPhase(constants.PHASE_SPAWN_HEROES)

    --         -- Kill the selection screen
    --         GameRules:FinishCustomGameSetup()
    --     end

    --     return 0.1
    -- end

    if ourPhase == constants.PHASE_SPAWN_HEROES then
        -- Do things after a small delay
        local this = self

        -- Hook bot stuff
        self:hookBotStuff()

        -- Spawn all humans
        Timers:CreateTimer(function()
            -- Spawn all players
            this:spawnAllHeroes()
        end, DoUniqueString('spawnbots'), 0.1)

        -- Move to ingame
        self:setPhase(constants.PHASE_ITEM_PICKING)

        return 0.1
    end

    -- Once we get to this point, we will not fire again

    -- Game is starting, spawn heroes
    if ourPhase == constants.PHASE_ITEM_PICKING then
        if GameRules:State_Get() < DOTA_GAMERULES_STATE_PRE_GAME then
            return 0.1
        end

        -- Do things after a small delay
        local this = self

        Timers:CreateTimer(function()
            -- Fix builds
            this:applyBuilds()

            -- Move to ingame
            this:setPhase(constants.PHASE_INGAME)

            -- Start tutorial mode so we can show tips to players
            Tutorial:StartTutorialMode()
        end, DoUniqueString('preventcamping'), 1)

        -- Hook bot stuff
        -- self:hookBotStuff()

        -- Add extra towers
        Timers:CreateTimer(function()
            this:addExtraTowers()
        end, DoUniqueString('createtowers'), 0.2)

        -- Neutral Multiplier Mutator
        Timers:CreateTimer(function()
            this:multiplyNeutrals()
        end, DoUniqueString('neutralMultiplier'), 0.2)

        -- Double Lane Creeps Multiplier Mutator
        Timers:CreateTimer(function()
            this:multiplyLaneCreeps()
        end, DoUniqueString('laneCreepMultiplierTimer'), 0.2)

        -- Dark Moon Drops
        Timers:CreateTimer(function()
            this:darkMoonDrops()
        end, DoUniqueString('darkMoonDrop'), 0.2)

        -- Prevent fountain camping
        Timers:CreateTimer(function()
            this:preventCamping()
        end, DoUniqueString('preventcamping'), 0.3)

        Timers:CreateTimer(function()
            -- Load messages
            SU:LoadPlayersMessages()

            ingame:onStart()
        end, DoUniqueString('preventcamping'), 1)
    end
end

-- Called to prepare to get player data when someone connects
function Pregame:preparePlayerDataFetch()
    -- Listen for someone who is connecting
    --ListenToGameEvent('player_connect_full', function(keys)
    --    util:fetchPlayerData()
    --end, nil)

    -- Attempt to pull after a minor delay
    --Timers:CreateTimer(function()
        --util:fetchPlayerData()
    --end, DoUniqueString('fetchPlayerData'), 0.1)
end

-- Called automatically when we get player data
function Pregame:onGetPlayerData(playerDataBySteamID)
    local maxPlayerID = 24

    self.playerGameStats = {}

    for playerID = 0,maxPlayerID-1 do
        local steamID = PlayerResource:GetSteamAccountID(playerID)
        if steamID ~= 0 then
            local theirData = playerDataBySteamID[tostring(steamID)]
            if theirData then
                self.playerGameStats[playerID] = theirData
            end
        end
    end

    -- Share stats
    network:sharePlayerStats(self.playerGameStats)
end

-- Spawns all heroes (this should only be called once!)
function Pregame:spawnAllHeroes()
    local minPlayerID = 0
    local maxPlayerID = 24

    for playerID = minPlayerID,maxPlayerID-1 do
        self:spawnPlayer(playerID)
    end

    self:actualSpawnPlayer()

    -- self.spawnQueueID = -1
    -- self.spawnDelay = 2.5

    -- if IsInToolsMode() then
    --     self.spawnDelay = 0
    -- end

    -- self.playerQueue = function (hero)
    --     PauseGame(true)
    --     self.spawnQueueID = self.spawnQueueID + 1

    --     -- Update queue info
    --     CustomGameEventManager:Send_ServerToAllClients("lodSpawningQueue", {queue = self.spawnQueueID})

    --     -- End pause if every player is checked
    --     if self.spawnQueueID > 24 then
    --         PauseGame(false)
    --         self.spawnQueueID = nil
    --         self.heroesSpawned = true
    --         onSpawned()
    --         return
    --     end

    --     -- Skip disconnected players
    --     if PlayerResource:GetConnectionState(self.spawnQueueID) < 1 then
    --         self.playerQueue()
    --         return
    --     end
    --     -- if not hero then
    --     --     self.playerQueue()
    --     --     return
    --     -- end

    --     -- Keep spawning
    --     Timers:CreateTimer(function()
    --         self:spawnPlayer(self.spawnQueueID, self.playerQueue)
    --     end, DoUniqueString('playerSpawn'), self.spawnDelay)
    -- end

    -- self.playerQueue(true)
end

-- Spawns a given player
function Pregame:spawnPlayer(playerID, callback)
    if self.spawnedHeroesFor[playerID] then return end
    self.spawnedHeroesFor[playerID] = true

    table.insert(self.spawnQueue, playerID)
end

function Pregame:actualSpawnPlayer(forceID)
    -- Is there someone to spawn?
    if #self.spawnQueue <= 0 then return end

    -- Only spawn ONE player at a time!
    if self.currentlySpawning then return end
    self.currentlySpawning = true

    -- Grab a reference to self
    local this = self

    local continueSpawning = (function ()
        -- Done spawning, start the next one
        this.currentlySpawning = false

        -- Continue actually spawning
        this:actualSpawnPlayer()
    end)

     -- Try to spawn this player using safe stuff
    local status, err = pcall(function()
        -- Grab a player to spawn
        local playerID = forceID or table.remove(this.spawnQueue, 1)

        -- Don't allow a player to get two heroes
        if PlayerResource:GetSelectedHeroEntity(playerID) ~= nil then
            UTIL_Remove(PlayerResource:GetSelectedHeroEntity(playerID))
        end

        -- Grab their build
        local build = self.selectedSkills[playerID]

        -- Validate the player
        local player = PlayerResource:GetPlayer(playerID)
        if player ~= nil then
            local heroName = self.selectedHeroes[playerID] or self:getRandomHero()

            local spawnTheHero = function()
                local status2,err2 = pcall(function()
                    -- Create the hero and validate it
                    local hero = CreateHeroForPlayer(heroName, player)

                    UTIL_Remove(hero)
                end)

                continueSpawning()

                -- Did the spawning of this hero fail?
                if not status2 then
                    SendToServerConsole('say "Post this to the LoD comments section: '..err2:gsub('"',"''")..'"')
                end
            end

            -- Attempt to precache their hero
            PrecacheUnitByNameAsync(heroName, function()
                -- We have now cached this player's hero
                Timers:CreateTimer(function (  )
                    this.cachedPlayerHeroes[playerID] = true

                    -- Spawn it
                    spawnTheHero()
                end, DoUniqueString('delay'), 0.2)

            end, playerID)
        else
            -- This player has not spawned!
            self.spawnedHeroesFor[playerID] = nil

            continueSpawning()
        end
    end)

    -- Did the spawning of this hero fail?
    if not status then
        SendToServerConsole('say "Post this to the LoD comments section: '..err:gsub('"',"''")..'"')
    end
end

-- Returns a random hero [will be unique]
function Pregame:getRandomHero(filter)
    -- Build a list of heroes that have already been taken
    -- Also remove heroes with paired abilities
    local takenHeroes = {}
    for k,v in pairs(GameRules.perks["heroAbilityPairs"]) do
        table.insert(takenHeroes, k)
    end

    for k,v in pairs(self.selectedHeroes) do
        takenHeroes[v] = true
    end

    local possibleHeroes = {}

    for k,v in pairs(self.allowedHeroes) do
        if not takenHeroes[k] and (filter == nil or filter(k)) then
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
    local heroList = LoadKeyValues('scripts/npc/herolist.txt')
    local allHeroes = LoadKeyValues('scripts/npc/npc_heroes.txt')
    local allHeroesCustom = LoadKeyValues('scripts/npc/npc_heroes_custom.txt')
    local npc_abilities_override = LoadKeyValues('scripts/npc/npc_abilities_override.txt')

    local oldAbList = LoadKeyValues('scripts/kv/abilities.kv')
    local hashCollisions = LoadKeyValues('scripts/kv/hashes.kv')

    local heroToSkillMap = oldAbList.heroToSkillMap

    -- Parse flags
    local flags = {}
    for k,v in pairs(util:getAbilityKV()) do
        if v then
            if v["ReduxFlags"] then
                local abilityFlags = util:split(v["ReduxFlags"], " | ")
                for _,flag in pairs(abilityFlags) do
                    local flag = string.lower(flag)
                    flags[flag] = flags[flag] or {}
                    flags[flag][k] = 1
                end
            end
            if not string.match(k, "special_bonus_") and not string.match(k, "perk") then
                if v["AbilityBehavior"] and string.match(v["AbilityBehavior"], "DOTA_ABILITY_BEHAVIOR_PASSIVE") then
                    flags["passive"] = flags["passive"] or {}
                    flags["passive"][k] = 1
                end
                if v["ReduxCost"] then
                    if tonumber(v["ReduxCost"]) >= 120 then
                        flags["SuperOP"] = flags["SuperOP"] or {}
                        flags["SuperOP"][k] = 1
                    elseif tonumber(v["ReduxCost"]) >= 80 then
                        flags["OPSkillsList"] = flags["OPSkillsList"] or {}
                        flags["OPSkillsList"][k] = 1
                    end
                end
            end
        end
    end

    local internalFlags = {
        wtfautoban = true,
        nohero = true,
        donotrandom = true,
        underpowered = true,
    }
    -- Prepare flags
    local flagsInverse = {}
    for flagName,abilityList in pairs(flags) do
        if not internalFlags[flagName] then
            for abilityName,nothing in pairs(abilityList) do
                -- Ensure a store exists
                flagsInverse[abilityName] = flagsInverse[abilityName] or {}
                flagsInverse[abilityName][flagName] = true
            end
        end
    end

    function prepareAbility( abilityName, tabName, abilityGroup )
        flagsInverse[abilityName] = flagsInverse[abilityName] or {}
        flagsInverse[abilityName].category = tabName
        if abilityGroup then
            flagsInverse[abilityName].group = abilityGroup
        end

        if SkillManager:isUlt(abilityName) then
            flagsInverse[abilityName].isUlt = true
            --self:banAbility(abilityName)
        end
    end

    -- Load in the category data for abilities
    local oldSkillList = oldAbList.skills

    for tabName, tabList in pairs(oldSkillList) do
        for abilityName,abilityGroup in pairs(tabList) do
            if type(abilityGroup) == "table" then
                for groupedAbilityName,_ in pairs(abilityGroup) do
                   prepareAbility( groupedAbilityName, tabName, abilityName )
                end
            else
                prepareAbility( abilityName, tabName )
            end
        end
    end

    -- Merge custom heroes
    for heroName,heroValues in pairs(allHeroesCustom) do
        if not allHeroes[heroValues["override_hero"]] or heroValues["ForceOverride"] == 1 then
            allHeroes[heroValues["override_hero"]] = heroValues
        end
    end

    -- Push flags to clients
    for abilityName, flagData in pairs(flagsInverse) do
        network:setFlagData(abilityName, flagData)
    end

    self.invisSkills = flags.invis

    self.dotaCustom = flags.dota_custom

    -- Store the inverse flags list
    self.flagsInverse = flagsInverse
    self.flags = flags

    -- Maps to convert hashes
    self.hashToSkill = {}
    self.skillToHash = {}

    local totalCollisions = 0

    -- Calculate the hashes
    for abilityName, _ in pairs(flagsInverse) do
        local parts = util:split(abilityName, '_')

        local hash = ''

        for i=1,#parts do
            local part = parts[i]
            local letter = part:sub(1, 1)

            hash = hash .. letter
        end

        -- Do we need to fix a collision?
        if hashCollisions[abilityName] then
            hash = hash .. hashCollisions[abilityName]
        end

        if self.hashToSkill[hash] then
            print(hash .. ' hash collision - ' .. abilityName)
            totalCollisions = totalCollisions + 1
        else
            self.hashToSkill[hash] = abilityName
            self.skillToHash[abilityName] = hash
        end
    end

    if totalCollisions > 0 then
        print('Found ' .. totalCollisions .. ' hash collisions!')
    end

    -- Stores which abilities belong to which heroes
    self.abilityHeroOwner = {}

    local allowedHeroes = {}
    self.heroPrimaryAttr = {}
    self.heroRole = {}

    self.botHeroes = {}

    -- Contains base stats
    local baseHero = allHeroes.npc_dota_hero_base

    for heroName,heroValues in pairs(allHeroes) do
        -- Ensure it is enabled
        if heroName ~= 'Version' and heroName ~= 'npc_dota_hero_base' and heroValues.Enabled == 1 then
            -- Store if we can select it as a bot
            if heroValues.BotImplemented == 1 then
                self.botHeroes[heroName] = {}

                for i=1,24 do
                    local abName = heroValues['Ability' .. i]
                    if abName ~= 'attribute_bonus' then
                        table.insert(self.botHeroes[heroName], abName)
                    end
                end
            end

            -- Grab custom hero data
            local customHero = allHeroesCustom[heroName] or {}

            -- Store all the useful information
            local theData = {
                AttributePrimary = customHero.AttributePrimary or heroValues.AttributePrimary or baseHero.AttributePrimary,
                Role = customHero.Role or heroValues.Role or baseHero.Role,
                Rolelevels = customHero.Rolelevels or heroValues.Rolelevels or baseHero.Rolelevels,
                AttackCapabilities = customHero.AttackCapabilities or heroValues.AttackCapabilities or baseHero.AttackCapabilities,
                AttackDamageMin = customHero.AttackDamageMin or heroValues.AttackDamageMin or baseHero.AttackDamageMin,
                AttackDamageMax = customHero.AttackDamageMax or heroValues.AttackDamageMax or baseHero.AttackDamageMax,
                AttackRate = customHero.AttackRate or heroValues.AttackRate or baseHero.AttackRate,
                AttackRange = customHero.AttackRange or heroValues.AttackRange or baseHero.AttackRange,
                AttackAnimationPoint = customHero.AttackAnimationPoint or heroValues.AttackAnimationPoint or baseHero.AttackAnimationPoint,
                MovementSpeed = customHero.MovementSpeed or heroValues.MovementSpeed or baseHero.MovementSpeed,
                AttributeBaseStrength = customHero.AttributeBaseStrength or heroValues.AttributeBaseStrength or baseHero.AttributeBaseStrength,
                AttributeStrengthGain = customHero.AttributeStrengthGain or heroValues.AttributeStrengthGain or baseHero.AttributeStrengthGain,
                AttributeBaseIntelligence = customHero.AttributeBaseIntelligence or heroValues.AttributeBaseIntelligence or baseHero.AttributeBaseIntelligence,
                AttributeIntelligenceGain = customHero.AttributeIntelligenceGain or heroValues.AttributeIntelligenceGain or baseHero.AttributeIntelligenceGain,
                AttributeBaseAgility = customHero.AttributeBaseAgility or heroValues.AttributeBaseAgility or baseHero.AttributeBaseAgility,
                AttributeAgilityGain = customHero.AttributeAgilityGain or heroValues.AttributeAgilityGain or baseHero.AttributeAgilityGain,
                ArmorPhysical = customHero.ArmorPhysical or heroValues.ArmorPhysical or baseHero.ArmorPhysical,
                MagicalResistance = customHero.MagicalResistance or heroValues.MagicalResistance or baseHero.MagicalResistance,
                ProjectileSpeed = customHero.ProjectileSpeed or heroValues.ProjectileSpeed or baseHero.ProjectileSpeed,
                RingRadius = customHero.RingRadius or heroValues.RingRadius or baseHero.RingRadius,
                MovementTurnRate = customHero.MovementTurnRate or heroValues.MovementTurnRate or baseHero.MovementTurnRate,
                StatusHealth = customHero.StatusHealth or heroValues.StatusHealth or baseHero.StatusHealth,
                StatusHealthRegen = customHero.StatusHealthRegen or heroValues.StatusHealthRegen or baseHero.StatusHealthRegen,
                StatusMana = customHero.StatusMana or heroValues.StatusMana or baseHero.StatusMana,
                StatusManaRegen = customHero.StatusManaRegen or heroValues.StatusManaRegen or baseHero.StatusManaRegen,
                VisionDaytimeRange = customHero.VisionDaytimeRange or heroValues.VisionDaytimeRange or baseHero.VisionDaytimeRange,
                VisionNighttimeRange = customHero.VisionNighttimeRange or heroValues.VisionNighttimeRange or baseHero.VisionNighttimeRange,
                HeroPerk = GameRules.hero_perks[heroName] or ""
            }

            theData["Enabled"] = heroList[heroName]

            local attr = heroValues.AttributePrimary
            if attr == 'DOTA_ATTRIBUTE_INTELLECT' then
                self.heroPrimaryAttr[heroName] = 'int'
            elseif attr == 'DOTA_ATTRIBUTE_AGILITY' then
                self.heroPrimaryAttr[heroName] = 'agi'
            else
                self.heroPrimaryAttr[heroName] = 'str'
            end

            local role = heroValues.AttackCapabilities
            if role == 'DOTA_UNIT_CAP_RANGED_ATTACK' then
                self.heroRole[heroName] = 'ranged'
            else
                self.heroRole[heroName] = 'melee'
            end

            if heroToSkillMap[heroName] then
                for k,v in pairs(heroToSkillMap[heroName]) do
                    theData[k] = v
                end
            else
                local sn = 1
                for i=1,23 do
                    local abName = heroValues['Ability' .. i]

                    if abName ~= 'attribute_bonus' then
                        theData['Ability' .. sn] = abName
                        sn = sn + 1
                    end
                end
            end

            local sb = 1
            for i=1,23 do
                local abName = heroValues['Ability' .. i]

                if abName and string.match(abName, "special_bonus_") then
                    theData['SpecialBonus'..tostring(math.ceil(sb / 2))] = theData['SpecialBonus'..tostring(math.ceil(sb / 2))] or {}
                    table.insert(theData['SpecialBonus'..tostring(math.ceil(sb / 2))], abName)
                    sb = sb + 1
                end
            end

            network:setHeroData(heroName, theData)

            -- Store allowed heroes
            allowedHeroes[heroName] = true

            -- Store the owners
            for i=1,23 do
                if theData['Ability'..i] ~= nil then
                    self.abilityHeroOwner[theData['Ability'..i]] = heroName
                end
            end

        end
    end

    -- Store it locally
    self.allowedHeroes = allowedHeroes
end

-- Finishes option selection
function Pregame:finishOptionSelection()
    -- Ensure we are in the options locking phase
    if self:getPhase() ~= constants.PHASE_OPTION_SELECTION and self:getPhase() ~= constants.PHASE_OPTION_VOTING then return end

    -- Validate teams
    local totalRadiant = 0
    local totalDire = 0

    local maxPlayerID = 24

    for playerID=0,maxPlayerID-1 do
        local team = PlayerResource:GetCustomTeamAssignment(playerID)

        if team == DOTA_TEAM_GOODGUYS then
            totalRadiant = totalRadiant + 1
        elseif team == DOTA_TEAM_BADGUYS then
            totalDire = totalDire + 1
        end
    end

    for playerID=0,maxPlayerID-1 do
        local team = PlayerResource:GetCustomTeamAssignment(playerID)

        if team ~= DOTA_TEAM_GOODGUYS and team ~= DOTA_TEAM_BADGUYS then
            if totalDire < totalRadiant then
                totalDire = totalDire + 1
                PlayerResource:SetCustomTeamAssignment(playerID, DOTA_TEAM_BADGUYS)
            else
                totalRadiant = totalRadiant + 1
                PlayerResource:SetCustomTeamAssignment(playerID, DOTA_TEAM_GOODGUYS)
            end

        end
    end

    -- Lock teams
    GameRules:LockCustomGameSetupTeamAssignment(true)

     -- Process gamemodes
    if self.optionStore['lodOptionCommonGamemode'] == 4 then
        self.noHeroSelection = true
        self.allRandomSelection = true
    end

    if self.optionStore['lodOptionCommonGamemode'] == 3 then
        self.useDraftArrays = true
        self.singleDraft = false
    end

    -- Single Draft
    if self.optionStore['lodOptionCommonGamemode'] == 5 then
        self.useDraftArrays = true
        self.singleDraft = true
    end

    -- Booster Draft
    if self.optionStore['lodOptionCommonGamemode'] == 6 then
        self.useDraftArrays = true
        self.singleDraft = false
        self.boosterDraft = true
    end

    -- Move onto the next phase
    if self.optionStore['lodOptionBanningMaxBans'] > 0 or self.optionStore['lodOptionBanningMaxHeroBans'] > 0 or self.optionStore['lodOptionBanningHostBanning'] == 1 then
        -- There is banning
        self:setPhase(constants.PHASE_BANNING)
        self:setEndOfPhase(Time() + OptionManager:GetOption('banningTime'), OptionManager:GetOption('banningTime'))
        local sound = self:getRandomSound("game_ban_started")
        EmitAnnouncerSound(sound)

    else
        -- There is not banning

        -- Is there hero selection?
        if self.noHeroSelection then
            -- No hero selection

            -- Is there all random selection?
            if self.allRandomSelection then
                -- Goto all random
                self:setPhase(constants.PHASE_RANDOM_SELECTION)
                self:setEndOfPhase(Time() + OptionManager:GetOption('randomSelectionTime'), OptionManager:GetOption('randomSelectionTime'))
            else
                -- Change to picking phase
                self:setPhase(constants.PHASE_SPAWN_HEROES)

                -- Kill the selection screen
                self:setEndOfPhase(Time() + OptionManager:GetOption('reviewTime'), OptionManager:GetOption('reviewTime'))

                GameRules:FinishCustomGameSetup()
            end
        else
            -- Hero selection
            self:setPhase(constants.PHASE_SELECTION)
            -- Change the below line to "self:setEndOfPhase(Time() + OptionManager:GetOption('pickingTime'), nil)" to disable unlimited time
            self:setEndOfPhase(Time() + OptionManager:GetOption('pickingTime'), OptionManager:GetOption('pickingTime'))
        end
    end
end

-- Options Locked event was fired
function Pregame:onOptionsLocked(eventSourceIndex, args)
    -- Ensure we are in the options locking phase
    if self:getPhase() ~= constants.PHASE_OPTION_SELECTION then return end

    -- Grab data
    local playerID = args.PlayerID
    local player = PlayerResource:GetPlayer(playerID)

    -- Ensure they have hosting privileges
    if isPlayerHost(player) then
        -- Finish the option selection
        self:finishOptionSelection()
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
    if isPlayerHost(player) then
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
    if isPlayerHost(player) then
        -- Grab options
        local optionName = args.k
        local optionValue = args.v

        --Enabling these properties requires an agree by all players
        local voteRequiredOptions = {
            ["lodOptionBanningBlockTrollCombos"] = {
                value = 0,
                votingName = "lodVotingBanningBlockTrollCombos"
            },

            ["lodOptionBanningUseBanList"] = {
                value = 0,
                votingName = "lodVotingAdvancedOPAbilities"
            },
        }

       -- if PlayerResource:GetSteamAccountID(playerID) == 43305444 or util:isSinglePlayerMode() then -- Baumi doesnt need votes to change options
        -- Temporarily require voting for options because its broken
        if true then
            voteRequiredOptions = {}
        end

        if voteRequiredOptions[optionName] and voteRequiredOptions[optionName].value == optionValue then
            self:setOption(optionName, voteRequiredOptions[optionName].value == 1 and 0 or 1)
            util:CreateVoting(voteRequiredOptions[optionName].votingName, playerID, 20, percentNeeded, function()
                self:setOption(optionName, voteRequiredOptions[optionName].value)
            end)
        else
            -- Option values and names are validated at a later stage
            self:setOption(optionName, optionValue)
        end
    end
end

-- Player wants to open ingame builder
function Pregame:onIngameBuilder(eventSourceIndex, args)
    local playerID = args.playerID
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    if duel_active or hero:HasModifier("modifier_tribune") then
        customAttension("#duel_cant_swap", 5)
        return
    end
    if IsValidEntity(hero) and hero:IsAlive() then
        local player = PlayerResource:GetPlayer(playerID)
        network:showHeroBuilder(player)
        Timers:CreateTimer(function()
            network:setOption('lodOptionBalanceMode', true)
        end, "changeBalanceMode", 0.5)
    end
    if IsValidEntity(hero) and hero:IsAlive() == false then
        util:DisplayError(playerID, "#deadCantUse")
    end
end

-- Player wants to cast a vote
function Pregame:onPlayerCastVote(eventSourceIndex, args)
    -- Ensure we are in the options voting
    if self:getPhase() ~= constants.PHASE_OPTION_VOTING then return end

    -- Grab the data
    local optionName = args.optionName
    local optionValue = args.optionValue

    -- Validate options
    if not self.useOptionVoting or not self.optionVoteSettings[optionName] or not (optionValue == 1 or optionValue == 0) then return end

    -- Ensure we have a store for this option
    self.voteData = self.voteData or {}
    self.voteData[optionName] = self.voteData[optionName] or {}

    -- Store their vote
    self.voteData[optionName][args.PlayerID] = optionValue

    -- Process / update the vote data
    self:processVoteData()
end

function Pregame:onGameChangeHost(eventSourceIndex, args)
    local oldHost = PlayerResource:GetPlayer(args.oldHost)
    local newHost = PlayerResource:GetPlayer(args.newHost)
    local showPopup = args.popup
    if showPopup then
        network:showPopup(oldHost, {oldHost = args.oldHost, newHost = args.newHost})
        return
    end
    if isPlayerHost(oldHost) then
        setPlayerHost(oldHost, newHost)
        network:changeHost({newHost = args.newHost})
    end
end

function Pregame:onGameChangeLock(eventSourceIndex, args)
    local command = args.command
    if not command then return end
    local mainHost = PlayerResource:GetPlayer(self.mainHost)
    network:changeLock(mainHost, {command = command})
end

-- Processes Vote Data
function Pregame:processVoteData()
    -- Will store results
    local results = {}
    local counts = {}

    for optionName,data in pairs(self.voteData or {}) do
        counts[optionName] = {}

        for playerID,choice in pairs(data) do
            counts[optionName][choice] = (counts[optionName][choice] or 0) + util:getVotingPower(playerID)
        end

        local maxNumber = 0
        for choice,count in pairs(counts[optionName]) do
            if count > maxNumber then
                maxNumber = count
                results[optionName] = choice
            end
        end
    end
    for k,v in pairs(results) do
        self.optionVoteSettings[k][v == 1 and "onselected" or "onunselected"](self)
        self.votingStatFlags["Voting " .. k .. " Enabled"] = v == 1
    end
    -- Push the counts
    network:voteCounts(counts)
end

-- Load up the troll combo bans list
function Pregame:loadTrollCombos()
    -- Load in the ban list
    local tempBanList = LoadKeyValues('scripts/kv/bans.kv')
    local abilityList = util:getAbilityKV()

    -- Store no multicast
    SpellFixes:SetNoCasting(tempBanList.noMulticast, tempBanList.noWitchcraft)

    --local noTower = tempBanList.noTower
    --local noTowerAlways = tempBanList.noTowerAlways
    --local noBear = tempBanList.noBear

    -- Create the stores
    self.banList = {}
    self.wtfAutoBan = self.flags.wtfautoban
    self.OPSkillsList = self.flags.OPSkillsList
    self.noHero = self.flags.nohero
    self.SuperOP = self.flags.SuperOP
    self.doNotRandom = self.flags.donotrandom
    self.underpowered = self.flags.underpowered

    -- All SUPER OP skills should be added to the OP ban list
    --for skillName,_ in pairs(self.lodBanList) do
    --    self.OPSkillsList[skillName] = 1
    --end

    -- Bans a skill combo
    local function banCombo(a, b)
        -- Ensure ban lists exist
        self.banList[a] = self.banList[a] or {}
        self.banList[b] = self.banList[b] or {}

        -- Store the ban
        self.banList[a][b] = true
        self.banList[b][a] = true

        network:addTrollCombo(a,b)
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

    -- Loop over the banned combinations and category bans
    for abilityName, abilityData in pairs(abilityList) do
        if abilityData.ReduxBans then
            for _,abilityName2 in ipairs(util:split(abilityData.ReduxBans, " | ")) do
                banCombo(abilityName, abilityName2)
            end
        end
        if abilityData.ReduxBanCategory then
            for _,categoty in ipairs(util:split(abilityData.ReduxBanCategory, " | ")) do
                doCatBan(abilityName, categoty)
            end
        end
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

-- Tests a build to see if there's enough spells for
function Pregame:notEnoughPoints(build)
    local maxSlots = self.optionStore['lodOptionCommonMaxSlots']
    local spent = 0

    -- Calculate points spent
    for i=1,maxSlots do
        local abil = build[i]
        if abil then
            local cost = self.spellCosts[abil]
            if not cost then
                cost = 0
            end
            spent = spent + cost
        end
    end

    -- Check to see if we exceed 100
    if spent > self.optionStore["lodOptionBalanceModePoints"] then
        return true, spent - self.optionStore["lodOptionBalanceModePoints"]
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

            -- Map enforcements
            local mapName = OptionManager:GetOption('mapname')

            -- All Pick Only
            if mapName == 'all_pick' then
                return value == 1
            end

            -- Fast All Pick Only
            if mapName == 'all_pick_fast' then
                return value == 2
            end

            -- 3 VS 3
            if mapName == '3_vs_3' then
                return value == 1
            end

            -- All Pick 6 slots
            if mapName == '5_vs_5' then
                return value == 1
            end

            -- Mirror Draft Only
            if mapName == 'mirror_draft' then
                return value == 3
            end

            -- All random only
            if mapName == 'all_random' then
                return value == 4
            end

            -- Single Draft only
            if mapName == 'single_draft' then
                return value == 5
            end

            -- Booster Draft only
            if mapName == 'booster_draft' then
                return value == 6
            end

            -- Not in a forced map, allow any preset gamemode

            local validGamemodes = {
                [-1] = true,
                [1] = true,
                [2] = true,
                [3] = true,
                [4] = true,
                [5] = true,
                [6] = true
            }

            -- Ensure it is one of the above gamemodes
            if not validGamemodes[value] then return false end

            -- It must be valid
            return true
        end,

        -- Fast banning selection
        lodOptionBanning = function(value)
            return value == 1 or value == 2 or value == 3 or value == 4
        end,

        -- Fast slots selection
        lodOptionSlots = function(value)
            -- It needs to be a whole number between a certain range
            if type(value) ~= 'number' then return false end
            if math.floor(value) ~= value then return false end
            if value < 4 or value > 6 then return false end

            -- Valid
            return true
        end,

        -- Fast ult selection
        lodOptionUlts = function(value)
            -- It needs to be a whole number between a certain range
            if type(value) ~= 'number' then return false end
            if math.floor(value) ~= value then return false end
            if value < 0 or value > 6 then return false end

            -- Valid
            return true
        end,

        -- Fast mirror draft hero selection
        lodOptionDraftAbilities = function(value)
            -- It needs to be a whole number between a certain range
            if type(value) ~= 'number' then return false end
            if math.floor(value) ~= value then return false end
            if value < 1 or value > 50 then return false end

            -- Valid
            return true
        end,

        -- Common gamemode
        lodOptionCommonGamemode = function(value)
            return value == 1 or value == 3 or value == 4 or value == 5 or value == 6
        end,

        -- Common max slots
        lodOptionCommonMaxSlots = function(value)
            -- It needs to be a whole number between a certain range
            if type(value) ~= 'number' then return false end
            if math.floor(value) ~= value then return false end
            if value < 4 or value > 6 then return false end

            -- Valid
            return true
        end,

        -- Common max skills
        lodOptionCommonMaxSkills = function(value)
            -- It needs to be a whole number between a certain range
            if type(value) ~= 'number' then return false end
            if math.floor(value) ~= value then return false end
            if value < 0 or value > 6 then return false end

            -- Valid
            return true
        end,

        -- Common max ults
        lodOptionCommonMaxUlts = function(value)
            -- It needs to be a whole number between a certain range
            if type(value) ~= 'number' then return false end
            if math.floor(value) ~= value then return false end
            if value < 0 or value > 6 then return false end

            -- Valid
            return true
        end,

        -- Common host banning
        lodOptionBanningHostBanning = function(value)
            return value == 0 or value == 1
        end,

        -- Common max bans
        lodOptionBanningMaxBans = function(value)
            -- It needs to be a whole number between a certain range
            if type(value) ~= 'number' then return false end
            if math.floor(value) ~= value then return false end
            if value < 0 or value > 25 then return false end

            -- Valid
            return true
        end,

        -- Common max hero bans
        lodOptionBanningMaxHeroBans = function(value)
            -- It needs to be a whole number between a certain range
            if type(value) ~= 'number' then return false end
            if math.floor(value) ~= value then return false end
            if value < 0 or value > 5 then return false end

            -- Valid
            return true
        end,

        -- Common mirror draft hero selection
        lodOptionCommonDraftAbilities = function(value)
            -- It needs to be a whole number between a certain range
            if type(value) ~= 'number' then return false end
            if math.floor(value) ~= value then return false end
            if value < 9 or value > 400 then return false end

            -- Valid
            return true
        end,

        -- Common -- Balance Mode
        lodOptionBalanceMode = function(value)
            -- Ensure gamemode is set to custom
            if self.optionStore['lodOptionGamemode'] == 1 then return false end

            if value == 1 then
                -- Enable balance mode bans and disable other lists
                self:setOption('lodOptionBalanceMode', 1, true)
                self:setOption('lodOptionBanningBalanceMode', 1, true)
                self:setOption('lodOptionAdvancedOPAbilities', 0, true)

                return true
            elseif value == 0 then
                -- Disable balance mode bans and renable default bans
                self:setOption('lodOptionBanningBalanceMode', 0, true)
                self:setOption('lodOptionAdvancedOPAbilities', 1, true)
                return true
            end

            return false
        end,

        lodOptionBalanceModePoints = function(value)
            -- It needs to be a whole number between a certain range
            if type(value) ~= 'number' then return false end
            if math.floor(value) ~= value then return false end
            if value < 60 or value > 400 then return false end

            -- Valid
            return true
        end,

        -- Balance Mode ban list
        lodOptionBanningBalanceMode = function(value)
            if self.optionStore['lodOptionGamemode'] == 1 then return value == 1 end

            return value == 0 or value == 1
        end,

        -- Common -- New abilities bonus
        lodOptionNewAbilitiesThreshold = function(value)
            -- It needs to be a whole number between a certain range
            if type(value) ~= 'number' then return false end
            if math.floor(value) ~= value then return false end
            if value < 0 or value > 100 then return false end

            -- Valid
            return true
        end,

        lodOptionNewAbilitiesBonusGold = function(value)
            -- It needs to be a whole number between a certain range
            if type(value) ~= 'number' then return false end
            if math.floor(value) ~= value then return false end
            if value < 0 or value > 2500 then return false end

            -- Valid
            return true
        end,

        -- Gamemode - Duel
        lodOptionDuels = function(value)
            return value == 0 or value == 1
        end,

        -- Common block troll combos
        lodOptionBanningBlockTrollCombos = function(value)
            return value == 0 or value == 1
        end,

        -- Common use ban list
        lodOptionBanningUseBanList = function(value)
               -- Timers:CreateTimer(function()
                    -- Only allow if all players on one side (i.e. coop or singleplayer)
                   -- if not util:isCoop() and GetMapName() ~= "all_allowed" then
                    --    self:setOption('lodOptionBanningUseBanList', 1, true)
                   -- end

               -- end, DoUniqueString('disallowOP'), 0.1)

            return value == 0 or value == 1
        end,

        -- Common ban all invis
        lodOptionBanningBanInvis = function(value)
            return value == 0 or value == 1 or value == 2
        end,

        -- Common -- Disable Perks
        lodOptionDisablePerks = function(value)
            return value == 0 or value == 1
        end,

        -- Game Speed -- Starting Level
        lodOptionGameSpeedStartingLevel = function(value)
            -- It needs to be a whole number between a certain range
            if type(value) ~= 'number' then return false end
            if math.floor(value) ~= value then return false end
            if value < 1 or value > 100 then return false end

            -- Valid
            return true
        end,

        -- Game Speed -- Max Level
        lodOptionGameSpeedMaxLevel = function(value)
            -- It needs to be a whole number between a certain range
            if type(value) ~= 'number' then return false end
            if math.floor(value) ~= value then return false end
            if value < 6 or value > 100 then return false end

            -- Valid
            return true
        end,

        -- Game Speed -- Starting Gold
        lodOptionGameSpeedStartingGold = function(value)
            -- It needs to be a whole number between a certain range
            if type(value) ~= 'number' then return false end
            if math.floor(value) ~= value then return false end
            if value < 0 or value > 100000 then return false end

            -- Valid
            return true
        end,

        -- Game Speed -- Gold per interval
        lodOptionGameSpeedGoldTickRate = function(value)
            -- It needs to be a whole number between a certain range
            if type(value) ~= 'number' then return false end
            if math.floor(value) ~= value then return false end
            if value < 0 or value > 25 then return false end

            -- Valid
            return true
        end,

        -- Game Speed -- Gold Modifier
        lodOptionGameSpeedGoldModifier = function(value)
            -- It needs to be a whole number between a certain range
            if type(value) ~= 'number' then return false end
            if math.floor(value) ~= value then return false end
            if value < 0 or value > 1000 then return false end

            -- Valid
            return true
        end,

        -- Game Speed -- EXP Modifier
        lodOptionGameSpeedEXPModifier = function(value)
            -- It needs to be a whole number between a certain range
            if type(value) ~= 'number' then return false end
            if math.floor(value) ~= value then return false end
            if value < 0 or value > 1000 then return false end

            -- Valid
            return true
        end,

        -- Common host banning
        lodOptionGameSpeedSharedEXP = function(value)
            return value == 0 or value == 1
        end,

        -- Game Speed -- Respawn time percentage
        lodOptionGameSpeedRespawnTimePercentage = function(value)
            -- It needs to be a whole number between a certain range
            if type(value) ~= 'number' then return false end
            if math.floor(value) ~= value then return false end
            if value < 0 or value > 100 then return false end

            -- Valid
            return true
        end,

        -- Game Speed -- Buyback cooldown constant
        lodOptionBuybackCooldownTimeConstant = function(value)
            -- It needs to be a whole number between a certain range
            if type(value) ~= 'number' then return false end
            if math.floor(value) ~= value then return false end
            if value < 0 or value > 420 then return false end

            -- Valid
            return true
        end,

        -- Game Speed -- Respawn time constant
        lodOptionGameSpeedRespawnTimeConstant = function(value)
            -- It needs to be a whole number between a certain range
            if type(value) ~= 'number' then return false end
            if math.floor(value) ~= value then return false end
            if value < 0 or value > 120 then return false end

            -- Valid
            return true
        end,

        -- Game Speed -- Towers per lane
        lodOptionGameSpeedTowersPerLane = function(value)
            -- It needs to be a whole number between a certain range
            if type(value) ~= 'number' then return false end
            if math.floor(value) ~= value then return false end
            if value < 3 or value > 10 then return false end

            -- Valid
            return true
        end,

        -- AntiRat
        lodOptionAntiRat = function(value)
            return value == 0 or value == 1
        end,

        -- Consumeable Items
        lodOptionConsumeItems = function(value)
            return value == 0 or value == 1
        end,

        -- Game Speed - Scepter Upgraded
        lodOptionGameSpeedUpgradedUlts = function(value)
            return value == 0 or value == 1 or value == 2
        end,

        -- Game Speed - Stronger Towers
        lodOptionGameSpeedStrongTowers = function(value)
            if self.optionStore['lodOptionCreepPower'] == 0 then
                self:setOption('lodOptionCreepPower', 120, true)
            end

            return value == 0 or value == 1
        end,

        -- Game Speed - Increase Creep Power
        lodOptionCreepPower = function(value)
            return value == 0 or value == 120 or value == 60 or value == 30
        end,

        -- Game Speed - Increase Creep Power
        lodOptionNeutralCreepPower = function(value)
            return value == 0 or value == 120 or value == 60 or value == 30
        end,

        -- Game Speed - Multiply Neutrals
        lodOptionNeutralMultiply = function(value)
            return value == 1 or value == 2 or value == 3 or value == 4
        end,

        -- Game Speed - Multiply Lane Creeps
        lodOptionLaneMultiply = function(value)
            return value == 0 or value == 1
        end,

        -- Game Speed - Free Courier
        lodOptionGameSpeedFreeCourier = function(value)
            return value == 0 or value == 1
        end,

        -- Bots -- Desired number of radiant players
        lodOptionBotsRadiant = function(value)
            -- It needs to be a whole number between a certain range
            if type(value) ~= 'number' then return false end
            if math.floor(value) ~= value then return false end
            if value < 1 or value > 10 then return false end

            -- Valid
            return true
        end,

        -- Bots Bonus Points
       -- lodOptionBotsBonusPoints = function(value)
        --    return value == 0 or value == 1
       -- end,

        -- Bots -- Desired number of dire players
        lodOptionBotsDire = function(value)
            -- It needs to be a whole number between a certain range
            if type(value) ~= 'number' then return false end
            if math.floor(value) ~= value then return false end
            if value < 1 or value > 10 then return false end

            -- Valid
            return true
        end,

        -- Bots - Unfair EXP balancing
        lodOptionBotsUnfairBalance = function(value)
            return value == 0 or value == 1
        end,

        -- Game Speed - Easy Mode
        --[[lodOptionCrazyEasymode = function(value)
            -- Ensure gamemode is set to custom
            if self.optionStore['lodOptionGamemode'] ~= -1 then return false end

            return value == 0 or value == 1
        end,]]

        -- Advanced -- Enable Hero Abilities
        lodOptionAdvancedHeroAbilities = function(value)
            -- Disables IMBA Abilities
            if value == 1 and not util:isCoop() then
                self:setOption('lodOptionAdvancedImbaAbilities', 0, true)
            end

            return value == 0 or value == 1
        end,

        -- Advanced -- Enable Neutral Abilities
        lodOptionAdvancedNeutralAbilities = function(value)
            if value == 1 and not util:isCoop() then
                self:setOption('lodOptionAdvancedImbaAbilities', 0, true)
            end

            return value == 0 or value == 1
        end,

        -- Advanced -- Enable Custom Abilities
        lodOptionAdvancedCustomSkills = function(value)
            if value == 1 and not util:isCoop() then
                self:setOption('lodOptionAdvancedImbaAbilities', 0, true)
            end

            return value == 0 or value == 1
        end,

        -- Advanced -- Enable IMBA Abilities
        lodOptionAdvancedImbaAbilities = function(value)
        -- If you use IMBA abilities, you cannot use any other major category of abilities.
            if value == 1 and not util:isCoop() then
                self:setOption('lodOptionAdvancedHeroAbilities', 0, true)
                self:setOption('lodOptionAdvancedNeutralAbilities', 0, true)
                self:setOption('lodOptionAdvancedCustomSkills', 0, true)
            else
                self:setOption('lodOptionAdvancedHeroAbilities', 1, true)
                self:setOption('lodOptionAdvancedNeutralAbilities', 1, true)
            end

            return value == 0 or value == 1
        end,

        -- Advanced -- Enable OP Abilities
        lodOptionAdvancedOPAbilities = function(value)
            return value == 0 or value == 1
        end,

        -- Advanced -- Hide enemy picks
        lodOptionAdvancedHidePicks = function(value)
            return value == 0 or value == 1
        end,

        -- Advanced -- Unique Skills
        lodOptionAdvancedUniqueSkills = function(value)
            return value == 0 or value == 1 or value == 2
        end,

        -- Advanced -- Unique Heroes
        lodOptionAdvancedUniqueHeroes = function(value)
            return value == 0 or value == 1
        end,

        -- Advanced -- Allow picking primary attr
        lodOptionAdvancedSelectPrimaryAttr = function(value)
            return value == 0 or value == 1
        end,

        -- Bots -- Unique Skills
        lodOptionBotsUniqueSkills = function(value)
            return value == 0 or value == 1 or value == 2
        end,

        -- Bots -- Stupefy
        lodOptionBotsStupid = function(value)
            return value == 0 or value == 1
        end,

        -- Bots -- Unique Skills
        lodOptionBotsRestrict = function(value)
            return value == 0 or value == 1 or value == 2 or value == 3
        end,

        -- Other -- No Fountain Camping
        lodOptionCrazyNoCamping = function(value)
            return value == 0 or value == 1
        end,

        -- Other -- Universal Shop
        lodOptionCrazyUniversalShop = function(value)
            return value == 0 or value == 1
        end,

        -- Other -- All Vision
        lodOptionCrazyAllVision = function(value)
            return value == 0 or value == 1
        end,

        -- Other -- Multicast Madness
        lodOptionCrazyMulticast = function(value)
            return value == 0 or value == 1
        end,

        -- Other -- WTF Mode
        lodOptionCrazyWTF = function(value)
            return value == 0 or value == 1
        end,

        -- Other -- Fat-O-Meter
        lodOptionCrazyFatOMeter = function(value)
            return value == 0 or value == 1 or value == 2 or value == 3
        end,

        -- Other - Refresh Cooldowns on Death
        lodOptionRefreshCooldownsOnDeath = function(value)
            return value == 0 or value == 1
        end,

        -- Other - 322
        lodOption322 = function(value)
            return value == 0 or value == 1
        end,

        -- Other - Global Cast Range
        lodOptionGlobalCast = function(value)
            return value == 0 or value == 1
        end,

        -- Other - Extra ability
        lodOptionExtraAbility = function(value)
            return value == 0 or value == 1 or value == 2 or value == 3 or value == 4  or value == 5 or value == 6 or value == 7 or value == 8 or value == 9 or value == 10  or value == 11 or value == 12 or value == 13 or value == 14 or value == 15 or value == 16 or value == 17 or value == 18  or value == 19 or value == 20 or value == 21
        end,

        -- Other -- Gotta Go Fast!
        lodOptionGottaGoFast = function(value)
            return value == 0 or value == 1 or value == 2 or value == 3 or value == 4
        end,

        -- Other -- Ingame Builder
        lodOptionIngameBuilder = function(value)
            return value == 0 or value == 1
        end,

        -- Other -- Ingame Builder Penalty
        lodOptionIngameBuilderPenalty = function(value)
            -- It needs to be a whole number between a certain range
            if type(value) ~= 'number' then return false end
            if math.floor(value) ~= value then return false end
            if value < 0 or value > 180 then return false end

            -- Valid
            return true
        end,

        -- Other - Item Drops
        lodOptionDarkMoon = function(value)
            return value == 0 or value == 1
        end,

         -- Other - Black Forest
        lodOptionBlackForest = function(value)
            return value == 0 or value == 1
        end,

         -- Other -- Memes Redux
        lodOptionMemesRedux = function(value)
            -- When the player activates this potion, they have a chance to hear a meme sound. Becomes more unlikely the more they hear.
            if value == 1 then

                local shouldPlay = RandomInt(1, self.chanceToHearMeme)
                if shouldPlay == 1 then
                    EmitGlobalSound("Memes.RandomSample")
                    self.chanceToHearMeme = self.chanceToHearMeme + 1
                end

            end

            return value == 0 or value == 1
        end,

         -- Other - Battle Thirst
        lodOptionBattleThirst = function(value)
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

                -- Balanced All Pick Mode
                if optionValue == 1 then
                    self:setOption('lodOptionBanningHostBanning', 0, true)
                    self:setOption('lodOptionBanningBalanceMode', 1, true)
                    self:setOption('lodOptionAdvancedOPAbilities', 0, true)
                    self:setOption('lodOptionBanningBlockTrollCombos', 1, true)
                    self:setOption('lodOptionBalanceMode', 1, true)
                end

                -- Traditional All Pick Mode
                if optionValue == 2 then
                    -- Set gamemode to all pick
                    self:setOption('lodOptionCommonGamemode', 1, true)
                    self:setOption('lodOptionBanningBalanceMode', 0, true)
                    self:setOption('lodOptionAdvancedOPAbilities', 1, true)
                    self:setOption('lodOptionBalanceMode', 0, true)
                end

                -- Mirror Draft Pick Mode
                if optionValue == 3 then
                    self:setOption('lodOptionBanningBalanceMode', 0, true)
                    self:setOption('lodOptionAdvancedOPAbilities', 0, true)
                    self:setOption('lodOptionBalanceMode', 0, true)
                end

                -- All Random Pick Mode
                if optionValue == 4 then
                    self:setOption('lodOptionBanningBalanceMode', 0, true)
                    self:setOption('lodOptionAdvancedOPAbilities', 0, true)
                    self:setOption('lodOptionBalanceMode', 0, true)
                end

                -- Single Draft Pick Mode
                if optionValue == 5 then
                    self:setOption('lodOptionBanningBalanceMode', 0, true)
                    self:setOption('lodOptionAdvancedOPAbilities', 0, true)
                    self:setOption('lodOptionBalanceMode', 0, true)
                end

                -- Booster Draft Pick Mode
                if optionValue == 6 then
                    self:setOption('lodOptionBanningBalanceMode', 0, true)
                    self:setOption('lodOptionAdvancedOPAbilities', 0, true)
                    self:setOption('lodOptionBalanceMode', 0, true)
                    self:setOption('lodOptionBotsUniqueSkills', 2, true)
                    self:setOption('lodOptionDraftAbilities', 47, false)
                end
            else
                --self:loadDefaultSettings()
                self:setOption('lodOptionCommonGamemode', 1)
            end
        end,

        -- Default amount of abilities for boost draft is 45
        lodOptionCommonGamemode = function(optionName, optionValue)
            if optionValue == 6 then
                if self.optionStore['lodOptionCommonDraftAbilities'] == 100 then
                    self:setOption('lodOptionDraftAbilities', 47, false)
                    self:setOption('lodOptionCommonDraftAbilities', self.optionStore['lodOptionDraftAbilities'], true)
                end
            end
        end,

        -- Fast max slots
        lodOptionSlots = function(optionName, optionValue)
            -- Copy max slots in
            self:setOption('lodOptionCommonMaxSlots', self.optionStore['lodOptionSlots'], true)
        end,

        -- Fast mirror draft
        lodOptionDraftAbilities = function()
            self:setOption('lodOptionCommonDraftAbilities', self.optionStore['lodOptionDraftAbilities'], true)
        end,

        -- Common mirror draft heroes
        lodOptionCommonDraftAbilities = function()
            self.maxDraftHeroes = self.optionStore['lodOptionCommonDraftAbilities']
        end
    }
end

-- Generates a random build
function Pregame:generateRandomBuild(playerID, buildID)
    -- Default filter allows all heroes
    local filter = function() return true end

    local this = self

    if buildID == 0 then
        -- A strength based hero only
        filter = function(heroName)
            return this.heroPrimaryAttr[heroName] == 'str'
        end
    elseif buildID == 1 then
        -- A Agility melee based hero only
        filter = function(heroName)
            return this.heroPrimaryAttr[heroName] == 'agi' and this.heroRole[heroName] == 'melee'
        end
    elseif buildID == 2 then
        -- A Agility ranged based hero only
        filter = function(heroName)
            return this.heroPrimaryAttr[heroName] == 'agi' and this.heroRole[heroName] == 'ranged'
        end

    elseif buildID == 3 then
        -- A int based hero only
        filter = function(heroName)
            return this.heroPrimaryAttr[heroName] == 'int'
        end
    elseif buildID == 4 then
        -- Any hero except agility
        filter = function(heroName)
            return this.heroPrimaryAttr[heroName] ~= 'agi'
        end
    end

    local heroName = self:getRandomHero(filter)
    local build = {}

    -- Validate it
    local maxSlots = self.optionStore['lodOptionCommonMaxSlots']

    for slot=1,maxSlots do
        -- Grab a random ability
        local newAbility = self:findRandomSkill(build, slot, playerID)

        -- Ensure we found an ability
        if newAbility ~= nil then
            build[slot] = newAbility
        end
    end

    -- Return the data
    return heroName, build
end

-- Generates builds for all random mode
function Pregame:generateAllRandomBuilds()
    -- Only process this once
    if self.allRandomBuilds then return end
    self.allRandomBuilds = {}

    -- Generate 10 builds
    local minPlayerID = 0
    local maxPlayerID = 24

    -- Max builds per player
    local maxPlayerBuilds = 5

    for playerID = minPlayerID,maxPlayerID-1 do
        local theBuilds = {}

        for buildID = 0,(maxPlayerBuilds-1) do
            local heroName, build = self:generateRandomBuild(playerID, buildID)

            theBuilds[buildID] = {
                heroName = heroName,
                build = build
            }
        end

        -- Store and network
        self.allRandomBuilds[playerID] = theBuilds
        network:setAllRandomBuild(playerID, theBuilds)

        -- Highlight which build is selected
        self.selectedRandomBuilds[playerID] = {
            hero = 0,
            build = 0
        }
        network:setSelectedAllRandomBuild(playerID, self.selectedRandomBuilds[playerID])

        -- Assign the skills
        self.selectedSkills[playerID] = theBuilds[0].build
        network:setSelectedAbilities(playerID, self.selectedSkills[playerID])

        -- Must be valid, select it
        local heroName = theBuilds[0].heroName

        if self.selectedHeroes[playerID] ~= heroName then
            self.selectedHeroes[playerID] = heroName
            network:setSelectedHero(playerID, heroName)

            -- Attempt to set the primary attribute
            local newAttr = self.heroPrimaryAttr[heroName] or 'str'
            if self.selectedPlayerAttr[playerID] ~= newAttr then
                -- Update local store
                self.selectedPlayerAttr[playerID] = newAttr

                -- Update the selected hero
                network:setSelectedAttr(playerID, newAttr)
            end
        end
    end
end

function Pregame:isAllowed( abilityName )
    local cat = (self.flagsInverse[abilityName] or {}).category
    local allowed = true

    if cat == 'main' then
        allowed = self.optionStore['lodOptionAdvancedHeroAbilities'] == 1
    elseif cat == 'neutral' then
        allowed = self.optionStore['lodOptionAdvancedNeutralAbilities'] == 1
    elseif cat == 'custom' then
        allowed = self.optionStore['lodOptionAdvancedCustomSkills'] == 1
    elseif cat == 'dotaimba' then
        allowed = self.optionStore['lodOptionAdvancedImbaAbilities'] == 1
    elseif cat == 'OP' then
        allowed = self.optionStore['lodOptionAdvancedOPAbilities'] == 0
    elseif cat == nil then
        allowed = false
    end

    if self.optionStore['lodOptionAdvancedHeroAbilities'] == 1 and self.optionStore['lodOptionAdvancedCustomSkills'] == 0 and self.optionStore['lodOptionAdvancedNeutralAbilities'] == 0 then
        if not self.abilityHeroOwner[abilityName] then
            allowed = false
        end
    end

    if not allowed then
        return false
    end
    return true
end

-- Multiply neutral creep camps
function Pregame:MultiplyNeutralUnit( unit, killer, mult, lastHits )
    local unitName = unit:GetUnitName()

    if unitName == "npc_dota_roshan" or unitName == "npc_dota_neutral_mud_golem_split" or unitName == "npc_dota_dark_troll_warlord_skeleton_warrior" then
        return
    end

    local loc = unit:GetAbsOrigin()

    -- Don't spawn too many special units per split, it overwhelms players easily
    local alreadySpawned = false

    for i = 2, mult do
        clone = CreateUnitByName( unitName, loc, true, nil, nil, DOTA_TEAM_NEUTRALS )
        clone:AddNewModifier(clone, nil, "modifier_kill", {duration = 120})
        clone:AddAbility("clone_token_ability")

        -- SPECIAL BONUSES IF PLAYERS LAST HIT TOO MUCH
        -- Double Damage Bonus
        --if RollPercentage(5) then
        --    clone:AddNewModifier(clone, nil, "modifier_rune_doubledamage", {duration = duration})
        --end

        -- Healing Aura Bonus
        --if lastHits > 25 and RollPercentage(15) then
        --    level = math.min(10, (math.floor(lastHits / 25)) )
        --
        --    clone:AddAbility("neutral_regen_aura")
        --    local healingWard = clone:FindAbilityByName("neutral_regen_aura")
        --    healingWard:SetLevel(level)
        --end

        -- Extra Health Bonus
        --if lastHits > 25 and RollPercentage(15) then
        --    level = math.min(10, (math.floor(lastHits / 25)) )
        --   modelSize = level/14 + 1
         --   clone:SetModelScale(modelSize)

         --   clone:AddAbility("neutral_extra_health")
        --    local extraHealth = clone:FindAbilityByName("neutral_extra_health")
        --    extraHealth:SetLevel(level)
        --end

        -- Lucifier Attack
        --if not alreadySpawned and lastHits >= 100 then
        --    if killer.hadLucifier ~= true or RollPercentage(5) then
        --        killer.hadLucifier = true

        --        alreadySpawned = true
        --        local lucifier = CreateUnitByName( "npc_dota_lucifers_claw_doomling", loc, true, nil, nil, DOTA_TEAM_NEUTRALS )

        --        lucifier:AddAbility("spawnlord_master_freeze_creep")
        --        local bash = lucifier:FindAbilityByName("spawnlord_master_freeze_creep")
        --        local bashlevel = math.min(4, (math.floor((lastHits-100) / 20)) )
        --        bash:SetLevel(bashlevel)

        --        lucifier:AddNewModifier(lucifier, nil, "modifier_phased", {Duration = 2})
        --        lucifier:AddNewModifier(lucifier, nil, "modifier_kill", {duration = 45})

        --        Timers:CreateTimer(function()
        --            lucifier:MoveToTargetToAttack(killer)
         --       end, DoUniqueString('attackPlayer'), 0.5)
        --    end
        --end

        -- Araknarok Tank
        --if not alreadySpawned and lastHits >= 200 then
        --    if killer.hadAraknarok ~= true or RollPercentage(5) then
        --        killer.hadAraknarok = true

        --        alreadySpawned = true
        --        local araknarok = CreateUnitByName( "npc_dota_araknarok_spiderling", loc, true, nil, nil, DOTA_TEAM_NEUTRALS )

        --        araknarok:AddAbility("broodmother_incapacitating_bite")
        --        local poison = araknarok:FindAbilityByName("broodmother_incapacitating_bite")
        --        local poisonlevel = math.min(4, (math.floor((lastHits-200) / 20)) )
        --        poison:SetLevel(poisonlevel)

        --        araknarok:AddAbility("imba_tower_essence_drain")
        --        local lifedrain = araknarok:FindAbilityByName("imba_tower_essence_drain")
        --        local drainlevel = math.min(3, (math.floor((lastHits-200) / 26)) )
        --        lifedrain:SetLevel(drainlevel)

        --        araknarok:SetHullRadius(55)

         --       araknarok:AddNewModifier(araknarok, nil, "modifier_phased", {Duration = 2})
         --       araknarok:AddNewModifier(araknarok, nil, "modifier_kill", {duration = 45})

        --        Timers:CreateTimer(function()
        --            araknarok:MoveToTargetToAttack(killer)
        --        end, DoUniqueString('attackPlayer'), 0.5)
        --    end
        --end

        -- Small Bear Boss
        --if not alreadySpawned and lastHits >= 50 then
        --    if killer.hadSmallBear ~= true or RollPercentage(1) then
        --        killer.hadSmallBear = true

        --        alreadySpawned = true

         --       local smallBear = CreateUnitByName( "npc_dota_creature_small_spirit_bear", loc, true, nil, nil, DOTA_TEAM_NEUTRALS )

        --        smallBear:AddNewModifier(araknarok, nil, "modifier_phased", {Duration = 2})
        --        smallBear:AddNewModifier(araknarok, nil, "modifier_kill", {duration = 200})

        --        Timers:CreateTimer(function()
        --            smallBear:MoveToTargetToAttack(killer)
        --        end, DoUniqueString('attackPlayer'), 0.5)
        --    end
        --end

        -- Large Bear Boss
        --if not alreadySpawned and lastHits > 150 then
        --    if killer.hadLargeBear ~= true then
        --        killer.hadLargeBear = true

        --        alreadySpawned = true

        --        local largeBear = CreateUnitByName( "npc_dota_creature_large_spirit_bear", loc, true, nil, nil, DOTA_TEAM_NEUTRALS )

        --        largeBear:AddNewModifier(araknarok, nil, "modifier_phased", {Duration = 2})
        --        largeBear:AddNewModifier(araknarok, nil, "modifier_kill", {duration = 200})

        --        Timers:CreateTimer(function()
        --            largeBear:MoveToTargetToAttack(killer)
        --        end, DoUniqueString('attackPlayer'), 0.5)
        --    end
        --end

        -- Daddy Bear Boss
        --if not alreadySpawned and lastHits >= 300 then
        --    if killer.hadDaddyBear ~= true then
        --        killer.hadDaddyBear = true

        --        alreadySpawned = true

        --        team = DOTA_TEAM_NEUTRALS
        --        if killer:GetTeam() == DOTA_TEAM_BADGUYS then
        --           team = DOTA_TEAM_GOODGUYS
        --       elseif killer:GetTeam() == DOTA_TEAM_GOODGUYS then
        --            team = DOTA_TEAM_BADGUYS
        --        end

        --        local daddyBear = CreateUnitByName( "npc_dota_creature_big_bear", loc, true, nil, nil, team )

        --        daddyBear:AddNewModifier(araknarok, nil, "modifier_phased", {Duration = 2})
        --        daddyBear:AddNewModifier(araknarok, nil, "modifier_kill", {duration = 200})

        --        Timers:CreateTimer(function()
        --            daddyBear:MoveToTargetToAttack(killer)
        --        end, DoUniqueString('attackPlayer'), 0.5)
         --   end
        --end

    end
end

-- Multiply neutral creep camps
function Pregame:MultiplyLaneUnit( unit, mult )
        local unitName = unit:GetUnitName()

        local loc = unit:GetAbsOrigin()

        for i = 2, mult do
            clone = CreateUnitByName( unitName, loc, true, nil, nil, unit:GetTeam() )
            clone:AddAbility("clone_token_ability")
            --Clones die after 120 seconds, this is a safety measure to prevent too many units being alive
            clone:AddNewModifier(clone, nil, "modifier_kill", {duration = 30})
            clone:SetInitialGoalEntity(unit:GetInitialGoalEntity())
        end
end


-- Generates draft arrays
function Pregame:buildDraftArrays()
    -- Only build draft arrays once
    if self.draftArrays then return end
    self.draftArrays = {}

    local maxDraftArrays = 12

    local abilityDraftCount = self.optionStore['lodOptionCommonDraftAbilities']
    self.maxDraftHeroes = math.max(3, math.ceil(abilityDraftCount / 4))

    if self.singleDraft then
        maxDraftArrays = util:GetActivePlayerCountForTeam(DOTA_TEAM_BADGUYS) + util:GetActivePlayerCountForTeam(DOTA_TEAM_GOODGUYS)
    end

    if self.boosterDraft then
        maxDraftArrays = util:GetActivePlayerCountForTeam(DOTA_TEAM_BADGUYS) + util:GetActivePlayerCountForTeam(DOTA_TEAM_GOODGUYS)

        self.nextDraftArray = {}
        self.waitForArray = {}
        self.finalArrays = {}

        self.boosterDraftPicking = {}
        for i=0,DOTA_MAX_TEAM_PLAYERS-1 do
            self.boosterDraftPicking[i] = true
        end
    end

    for draftID = 0,(maxDraftArrays - 1) do
        -- Create store for data
        local draftData = {}

        local possibleHeroes = {}
        for k,v in pairs(self.allowedHeroes) do
            table.insert(possibleHeroes, k)
        end

        -- Select random heroes
        local heroDraft = {}
        if self.boosterDraft then
            self.maxDraftHeroes = #possibleHeroes
        end
        for i=1,self.maxDraftHeroes do
            heroDraft[table.remove(possibleHeroes, math.random(#possibleHeroes))] = true
        end

        local possibleSkills = {}
        local possibleUlts = {}
        for abilityName,abilityFlag in pairs(self.flagsInverse) do
            local shouldAdd = true

            -- check bans
            if self.bannedAbilities[abilityName] then
                shouldAdd = false
            end

            -- check OP
            if not self:isAllowed( abilityName ) then
                shouldAdd = false
            end

            -- check misc
            if not self:isAllowed( abilityName ) then
                shouldAdd = false
            end

            -- Should we add it?
            if shouldAdd then
                if abilityFlag.isUlt then
                    table.insert(possibleUlts, abilityName)
                else
                    table.insert(possibleSkills, abilityName)
                end
            end
        end

        abilityDraftCount = math.min(util:getTableLength(possibleSkills), abilityDraftCount)

        -- Select random skills
        local abilityDraft = {}
        local count = 0

        for i=1,math.ceil(abilityDraftCount*0.75) do
            local s
            repeat
                s = table.remove(possibleSkills, math.random(#possibleSkills))
            until
                not abilityDraft[s]

            abilityDraft[s] = true

            count = count + 1

            if count >= abilityDraftCount then
                break
            end
        end

        for i=1,math.ceil(abilityDraftCount*0.25) do
            local s
            repeat
                s = table.remove(possibleUlts, math.random(#possibleUlts))
            until
                not abilityDraft[s]

            abilityDraft[s] = true

            count = count + 1

            if count >= abilityDraftCount then
                break
            end
        end

        -- Store data
        draftData.abilityDraft = abilityDraft
        draftData.heroDraft = heroDraft

        -- Network data
        network:setDraftArray(draftID, draftData)

        self.draftArrays[draftID] = draftData
    end
end

-- Precaches builds
local donePrecaching = false
function Pregame:precacheBuilds()
    local allSkills = {}
    local alreadyAdded = {}

    local timerDelay = 0

    for k,v in pairs(self.selectedSkills) do
        for kk,vv in pairs(v) do
            if not alreadyAdded[vv] then
                alreadyAdded[vv] = true
                table.insert(allSkills, vv)
            end
        end
    end

    local allPlayerIDs = {}
    for i=0,24 do
        if PlayerResource:IsValidPlayerID(i) then
            table.insert(allPlayerIDs, i)
        end
    end

    local this = self

    local totalToCache = #allPlayerIDs -- + #allSkills

    function checkCachingComplete()
        totalToCache = totalToCache - 1

        if totalToCache == 0 then
            donePrecaching = true

            -- Tell clients
            network:donePrecaching()

            -- Check for ready
            this:checkForReady()
            return
        end
    end

    function continueCachingHeroes()
        Timers:CreateTimer(function()
            if #allPlayerIDs <= 0 then
                return
            end

            local playerID = table.remove(allPlayerIDs, 1)

            if PlayerResource:IsValidPlayerID(playerID) then
                local heroName = self.selectedHeroes[playerID]

                if heroName then
                    this.cachedPlayerHeroes[playerID] = true

                    PrecacheUnitByNameAsync(heroName, function()
                        checkCachingComplete()
                        continueCachingHeroes()
                    end, playerID)
                else
                    continueCachingHeroes()
                end
            else
                continueCachingHeroes()
            end
        end, DoUniqueString('precacheHack'), 1.0)
    end

    function continueCaching()
        --print('Continue caching!')

        Timers:CreateTimer(function()
            if #allSkills > 0 then
                local abName = table.remove(allSkills, 1)

                --print('Precaching ' .. abName)

                SkillManager:precacheSkill(abName, function()
                    -- Check if caching has completed
                    checkCachingComplete()
                end)

                -- Keep Caching
                continueCaching()
            end
        end, DoUniqueString('keepCaching'), timerDelay)
    end

    -- Start caching process
    -- continueCaching()
    -- continueCachingHeroes()

    donePrecaching = true

    -- Tell clients
    network:donePrecaching()

    -- Check for ready
    this:checkForReady()
end




--[[function Pregame:precacheBuilds()
    local allSkills = {}
    local alreadyAdded = {}

    local timerDelay = 0

    for k,v in pairs(self.selectedSkills) do
        for kk,vv in pairs(v) do
            if not alreadyAdded[vv] then
                alreadyAdded[vv] = true
                table.insert(allSkills, vv)
            end
        end
    end

    local allPlayerIDs = {}
    for i=0,24 do
        if PlayerResource:IsValidPlayerID(i) then
            table.insert(allPlayerIDs, i)
        end
    end

    local this = self

    function continueCachingHeroes()
        --print('continue caching hero')

        -- Any more to cache?
        if #allPlayerIDs <= 0 then
            donePrecaching = true

            -- Tell clients
            network:donePrecaching()

            -- Check for ready
            this:checkForReady()
            return
        end

        local playerID = table.remove(allPlayerIDs, 1)

        if PlayerResource:IsValidPlayerID(playerID) then
            local heroName = self.selectedHeroes[playerID]

            if heroName then
                -- Store that it is cached
                cachedPlayerHeroes[playerID] = true

                --print('Caching ' .. heroName)

                PrecacheUnitByNameAsync(heroName, function()
                    -- Done caching
                    Timers:CreateTimer(function()
                        continueCachingHeroes()
                    end, DoUniqueString('keepCaching'), timerDelay)
                end, playerID)
            else
                Timers:CreateTimer(function()
                    continueCachingHeroes()
                end, DoUniqueString('keepCaching'), timerDelay)
            end
        else
            Timers:CreateTimer(function()
                continueCachingHeroes()
            end, DoUniqueString('keepCaching'), timerDelay)
        end
    end

    function continueCaching()
        --print('Continue caching!')

        Timers:CreateTimer(function()
            if #allSkills > 0 then
                local abName = table.remove(allSkills, 1)

                --print('Precaching ' .. abName)

                SkillManager:precacheSkill(abName, continueCaching)
            else
                Timers:CreateTimer(function()
                    continueCachingHeroes()
                end, DoUniqueString('keepCaching'), timerDelay)
            end
        end, DoUniqueString('keepCaching'), timerDelay)
    end

    continueCaching()
end]]



-- Validates builds
function Pregame:validateBuilds()
    -- Only process this once
    if self.validatedBuilds then return end
    self.validatedBuilds = true

    -- Generate 10 builds
    local minPlayerID = 0
    local maxPlayerID = 24

    -- Validate it
    local maxSlots = self.optionStore['lodOptionCommonMaxSlots']

    local this = self

    -- Loop over all playerIDs
    for playerID = minPlayerID,maxPlayerID-1 do
        -- Ensure they have a hero
        if not self.selectedHeroes[playerID] then
            local filter = function (  )
                return true
            end

            if self.selectedPlayerAttr[playerID] == 'str' then
                filter = function(heroName)
                    return this.heroPrimaryAttr[heroName] == 'str'
                end
            elseif self.selectedPlayerAttr[playerID] == 'agi' then
                filter = function(heroName)
                    return this.heroPrimaryAttr[heroName] == 'agi'
                end
            elseif self.selectedPlayerAttr[playerID] == 'int' then
                filter = function(heroName)
                    return this.heroPrimaryAttr[heroName] == 'int'
                end
            end

            local heroName = self:getRandomHero(filter)
            self.selectedHeroes[playerID] = heroName
            network:setSelectedHero(playerID, heroName)

            -- Attempt to set the primary attribute
            local newAttr = self.heroPrimaryAttr[heroName] or 'str'
            if self.selectedPlayerAttr[playerID] ~= newAttr then
                -- Update local store
                self.selectedPlayerAttr[playerID] = newAttr

                -- Update the selected hero
                network:setSelectedAttr(playerID, newAttr)
            end
        end

        -- Grab their build
        local build = self.selectedSkills[playerID]

        -- Ensure they have a build
        if not build then
            build = {}
            self.selectedSkills[playerID] = build
        end

        for slot=1,maxSlots do
            if (not self.botPlayers or not self.botPlayers.all[playerID]) and not build[slot] then
                -- Grab a random ability
                local newAbility = self:findRandomSkill(build, slot, playerID)

                -- Ensure we found an ability
                if newAbility ~= nil then
                    build[slot] = newAbility
                end
            end
        end

        -- Network it
        network:setSelectedAbilities(playerID, build)
    end
end

-- Processes options to push around to the rest of the systems
function Pregame:processOptions()
    -- Check Map
    local mapName = OptionManager:GetOption('mapname')

    -- Single Player Overrides
    if util:isSinglePlayerMode() then
        self:setOption('lodOptionIngameBuilder', 1, true)
        self:setOption("lodOptionIngameBuilderPenalty", 0)
    end

    -- Only allow single player abilities if all players on one side (i.e. coop or singleplayer)
    --if not util:isCoop() and GetMapName() ~= "all_allowed" then
    --    self:setOption('lodOptionBanningUseBanList', 1, true)
    --end

    -- This is a fix to deal with how votes are executed
   -- if GetMapName() == "all_allowed" then
   --     if self.optionStore['lodOptionBanningMaxBans'] == 2 and self.optionStore['lodOptionBanningUseBanList'] == 0 and self.optionStore['lodOptionAdvancedCustomSkills'] == 1 then
    --        self:setOption('lodOptionBanningMaxBans', 6, true)
    --    end
    --    if self.optionStore['lodOptionBanningMaxBans'] == 4 and self.optionStore['lodOptionAdvancedCustomSkills'] == 0 then
    --        self:setOption('lodOptionBanningMaxBans', 0, true)
    --        self:setOption('lodOptionBanningMaxHeroBans', 0, true)
    --    end

    --end

    -- Only process options once
    if self.processedOptions then return end
    self.processedOptions = true

    local this = self

    local status,err = pcall(function()
        -- Push settings externally where possible
        OptionManager:SetOption('duels', this.optionStore['lodOptionDuels'])
        OptionManager:SetOption('startingLevel', this.optionStore['lodOptionGameSpeedStartingLevel'])
        OptionManager:SetOption('bonusGold', this.optionStore['lodOptionGameSpeedStartingGold'])
        OptionManager:SetOption('maxHeroLevel', this.optionStore['lodOptionGameSpeedMaxLevel'])
        OptionManager:SetOption('multicastMadness', this.optionStore['lodOptionCrazyMulticast'] == 1)
        OptionManager:SetOption('respawnModifierPercentage', this.optionStore['lodOptionGameSpeedRespawnTimePercentage'])
        OptionManager:SetOption('respawnModifierConstant', this.optionStore['lodOptionGameSpeedRespawnTimeConstant'])
        OptionManager:SetOption('buybackCooldownConstant', this.optionStore['lodOptionBuybackCooldownTimeConstant'])
        OptionManager:SetOption('freeScepter', this.optionStore['lodOptionGameSpeedUpgradedUlts'])
        OptionManager:SetOption('freeCourier', this.optionStore['lodOptionGameSpeedFreeCourier'] == 1)
        OptionManager:SetOption('strongTowers', this.optionStore['lodOptionGameSpeedStrongTowers'] == 1)
        OptionManager:SetOption('towerCount', this.optionStore['lodOptionGameSpeedTowersPerLane'])
        OptionManager:SetOption('creepPower', this.optionStore['lodOptionCreepPower'])
        OptionManager:SetOption('neutralCreepPower', this.optionStore['lodOptionNeutralCreepPower'])
        OptionManager:SetOption('neutralMultiply', this.optionStore['lodOptionNeutralMultiply'])
        OptionManager:SetOption('laneMultiply', this.optionStore['lodOptionLaneMultiply'])
        OptionManager:SetOption('useFatOMeter', this.optionStore['lodOptionCrazyFatOMeter'])
        OptionManager:SetOption('allowIngameHeroBuilder', this.optionStore['lodOptionIngameBuilder'] == 1)
        --OptionManager:SetOption('botBonusPoints', this.optionStore['lodOptionBotsBonusPoints'] == 1)

        OptionManager:SetOption('botsUniqueSkills', this.optionStore['lodOptionBotsUniqueSkills'])
        OptionManager:SetOption('stupidBots', this.optionStore['lodOptionBotsStupid'])
        OptionManager:SetOption('ingameBuilderPenalty', this.optionStore['lodOptionIngameBuilderPenalty'])
        OptionManager:SetOption('322', this.optionStore['lodOption322'])
        OptionManager:SetOption('extraAbility', this.optionStore['lodOptionExtraAbility'])
        OptionManager:SetOption('globalCastRange', this.optionStore['lodOptionGlobalCast'])
        OptionManager:SetOption('refreshCooldownsOnDeath', this.optionStore['lodOptionRefreshCooldownsOnDeath'])
        OptionManager:SetOption('gottaGoFast', this.optionStore['lodOptionGottaGoFast'])
        OptionManager:SetOption('memesRedux', this.optionStore['lodOptionMemesRedux'])
        OptionManager:SetOption('battleThirst', this.optionStore['lodOptionBattleThirst'])
        OptionManager:SetOption('darkMoon', this.optionStore['lodOptionDarkMoon'])
        OptionManager:SetOption('blackForest', this.optionStore['lodOptionBlackForest'])
        OptionManager:SetOption('banInvis', this.optionStore['lodOptionBanningBanInvis'])
        OptionManager:SetOption('antiRat', this.optionStore['lodOptionAntiRat'])
        OptionManager:SetOption('consumeItems', this.optionStore['lodOptionConsumeItems'])

        -- Enforce max level
        if OptionManager:GetOption('startingLevel') > OptionManager:GetOption('maxHeroLevel') then
            this.optionStore['lodOptionGameSpeedStartingLevel'] = this.optionStore['lodOptionGameSpeedMaxLevel']
            OptionManager:SetOption('startingLevel', OptionManager:GetOption('maxHeroLevel'))
        end

        -- Enable easy mode
        --[[if this.optionStore['lodOptionCrazyEasymode'] == 1 then
            Convars:SetInt('dota_easy_mode', 1)
        end]]

        -- Gold per interval
        GameRules:SetGoldPerTick(this.optionStore['lodOptionGameSpeedGoldTickRate'])
        OptionManager:SetOption('goldPerTick', this.optionStore['lodOptionGameSpeedGoldTickRate'])
        OptionManager:SetOption('goldModifier', this.optionStore['lodOptionGameSpeedGoldModifier'])
        OptionManager:SetOption('expModifier', this.optionStore['lodOptionGameSpeedEXPModifier'])
        OptionManager:SetOption('sharedXP', this.optionStore['lodOptionGameSpeedSharedEXP'])

        -- Bot options
        this.desiredRadiant = this.optionStore['lodOptionBotsRadiant']
        this.desiredDire = this.optionStore['lodOptionBotsDire']

        -- Prepare to disable ban lists if necessary
        local disableBanLists = false

        -- Load troll combos
        self:loadTrollCombos()

        -- Enable Balance Mode (disables ban lists)
        -- Load balance mode stats
        self.spellCosts = {}
        for abilityName, abilityData in pairs(util:getAbilityKV()) do
            if abilityData.ReduxCost then
                if abilityData.ReduxCost == -1 and this.optionStore['lodOptionBalanceMode'] == 1 then
                    -- Ban List
                    this:banAbility(abilityName)
                else
                    -- Spell Shop
                    local price = abilityData.ReduxCost
                    self.spellCosts[abilityName] = price
                    network:sendSpellPrice(abilityName, price)
                end
            end
        end
        if this.optionStore['lodOptionBalanceMode'] == 1 then
            network:updateFilters()
            disableBanLists = disableBanLists or mapName == '5_vs_5' or mapName =='3_vs_3'
        end

        -- Enable WTF mode
        if not disableBanLists and this.optionStore['lodOptionCrazyWTF'] == 1 then
            -- Auto ban powerful abilities
            for abilityName,v in pairs(this.wtfAutoBan) do
                this:banAbility(abilityName)
            end

            -- Enable debug mode - Depreciated, wtf is now a filter in spellfixes.lua
            -- Convars:SetBool('dota_ability_debug', true)
        end

        -- Banning of OP Skills
        if not disableBanLists and this.optionStore['lodOptionAdvancedOPAbilities'] == 1 then
            for abilityName,v in pairs(self.OPSkillsList) do
                this:banAbility(abilityName)
            end
        else
            SpellFixes:SetOPMode(true)
        end

        -- Banning Underpowered versions of abilities
        if not disableBanLists and this.optionStore['lodOptionAdvancedOPAbilities'] == 0 then
            for abilityName,v in pairs(this.underpowered) do
                this:banAbility(abilityName)
            end
        end

        -- Banning invis skills
        if not disableBanLists and this.optionStore['lodOptionBanningBanInvis'] > 0 then
            for abilityName,v in pairs(this.invisSkills) do
                this:banAbility(abilityName)
            end
        end

        -- Banning scepter giving abilities
        if not disableBanLists and this.optionStore['lodOptionGameSpeedUpgradedUlts'] > 0 then
            this:banAbility("alchemist_transmuted_scepter")
            this:banAbility("alchemist_aghnaim_magic_redux")
        end

        -- Dota Modified Abilities
        if not disableBanLists and this.optionStore['lodOptionAdvancedCustomSkills'] ~= 1 then
            for abilityName,v in pairs(this.dotaCustom) do
                this:banAbility(abilityName)
            end
        end

        -- Banning invis skills
        if not disableBanLists and this.optionStore['lodOptionBanningBanInvis'] > 0 then
            for abilityName,v in pairs(this.invisSkills) do
                this:banAbility(abilityName)
            end
        end

        -- Disabling Hero Perks
        if this.optionStore['lodOptionDisablePerks'] == 1 then
            this.perksDisabled = true
        end

        -- LoD ban list
        if not disableBanLists and this.optionStore['lodOptionBanningUseBanList'] == 1 then
            for abilityName,v in pairs(self.SuperOP) do
                this:banAbility(abilityName)
            end
        end

        -- All extra ability mutator stuff
        if this.optionStore['lodOptionExtraAbility'] == 1 then
            self.freeAbility = "gemini_unstable_rift_one"
            this:banAbility("gemini_unstable_rift")
        elseif this.optionStore['lodOptionExtraAbility'] == 2 then
            self.freeAbility = "imba_dazzle_shallow_grave_passive_one"
            this:banAbility("imba_dazzle_shallow_grave_passive")
        elseif this.optionStore['lodOptionExtraAbility'] == 3 then
            self.freeAbility = "imba_tower_forest_one"
            this:banAbility("imba_tower_forest")
        elseif this.optionStore['lodOptionExtraAbility'] == 4 then
            self.freeAbility = "ebf_rubick_arcane_echo_one"
            this:banAbility("ebf_rubick_arcane_echo")
            this:banAbility("ebf_rubick_arcane_echo_OP")
        elseif this.optionStore['lodOptionExtraAbility'] == 6 then
            self.freeAbility = "ursa_fury_swipes"
            this:banAbility("ursa_fury_swipes")
            this:banAbility("ursa_fury_swipes_lod")
        elseif this.optionStore['lodOptionExtraAbility'] == 7 then
            self.freeAbility = "spirit_breaker_greater_bash"
            this:banAbility("spirit_breaker_greater_bash")
        elseif this.optionStore['lodOptionExtraAbility'] == 8 then
            self.freeAbility = "death_prophet_witchcraft"
            this:banAbility("death_prophet_witchcraft")
        elseif this.optionStore['lodOptionExtraAbility'] == 9 then
            self.freeAbility = "sniper_take_aim"
            this:banAbility("sniper_take_aim")
        --If global cast range mutator is on, dont added this ability as it overrides it
        elseif this.optionStore['lodOptionExtraAbility'] == 10 and OptionManager:GetOption('globalCastRange') == 0 then
            self.freeAbility = "aether_range_lod"
            this:banAbility("aether_range_lod")
            this:banAbility("aether_range_lod_op")
        elseif this.optionStore['lodOptionExtraAbility'] == 11 then
            self.freeAbility = "alchemist_goblins_greed"
            this:banAbility("alchemist_goblins_greed")
            this:banAbility("alchemist_goblins_greed_op")
        elseif this.optionStore['lodOptionExtraAbility'] == 12 then
            self.freeAbility = "angel_arena_nether_ritual"
            this:banAbility("angel_arena_nether_ritual")
        elseif this.optionStore['lodOptionExtraAbility'] == 13 then
            this:banAbility("slark_essence_shift")
            this:banAbility("slark_essence_shift_intellect_lod")
            this:banAbility("slark_essence_shift_strength_lod")
            this:banAbility("slark_essence_shift_agility_lod")
        elseif this.optionStore['lodOptionExtraAbility'] == 14 then
            self.freeAbility = "ogre_magi_multicast_lod"
            this:banAbility("ogre_magi_multicast_lod")
            this:banAbility("ogre_magi_multicast")
        elseif this.optionStore['lodOptionExtraAbility'] == 15 then
            self.freeAbility = "phantom_assassin_coup_de_grace"
            this:banAbility("phantom_assassin_coup_de_grace")
        elseif this.optionStore['lodOptionExtraAbility'] == 16 then
            self.freeAbility = "riki_permanent_invisibility"
            this:banAbility("riki_permanent_invisibility")
        elseif this.optionStore['lodOptionExtraAbility'] == 17 then
            self.freeAbility = "imba_tower_multihit"
            this:banAbility("imba_tower_multihit")
        elseif this.optionStore['lodOptionExtraAbility'] == 18 then
            self.freeAbility = "skeleton_king_reincarnation"
            this:banAbility("skeleton_king_reincarnation")
        elseif this.optionStore['lodOptionExtraAbility'] == 19 then
            self.freeAbility = "ebf_clinkz_trickshot_passive"
            this:banAbility("ebf_clinkz_trickshot_passive")
            this:banAbility("ebf_clinkz_trickshot")
        elseif this.optionStore['lodOptionExtraAbility'] == 20 then
            self.freeAbility = "abaddon_borrowed_time"
            this:banAbility("abaddon_borrowed_time")
        elseif this.optionStore['lodOptionExtraAbility'] == 21 then
            self.freeAbility = "summoner_tesla_coil"
            this:banAbility("summoner_tesla_coil")
        end

        -- If Global Cast Range is enabled, disable certain abilities that are troublesome with global cast range
        if this.optionStore['lodOptionGlobalCast'] == 1 then
            this:banAbility("aether_range_lod")
            this:banAbility("aether_range_lod_OP")
            this:banAbility("pudge_meat_hook")
            this:banAbility("earthshaker_fissure")
        end


        -- Enable Universal Shop
        if this.optionStore['lodOptionCrazyUniversalShop'] == 1 then
            GameRules:SetUseUniversalShopMode(true)
        end

        -- Enable All Vision
        if this.optionStore['lodOptionCrazyAllVision'] == 1 then
            Convars:SetBool('dota_all_vision', true)
        end

        if this.optionStore['lodOptionBlackForest'] == 1 then
            --Convars:SetBool('dota_all_vision', true)
            SendToServerConsole('dota_spawn_neutrals')
            local dummy = CreateUnitByName( "dummy_unit", Vector(0,0,0), false, nil, nil, 1 )
            dummy:AddNewModifier(caster, nil, "modifier_kill", {duration = 120})
            dummy:AddAbility("imba_tower_forest_generator")
            local treeAbility = dummy:FindAbilityByName("imba_tower_forest_generator")
            treeAbility:SetLevel(1)

        end

        if OptionManager:GetOption('maxHeroLevel') ~= 25 then
            local newTable = {}

            for i,v in ipairs(constants.XP_PER_LEVEL_TABLE) do
                if i <= OptionManager:GetOption('maxHeroLevel') then
                    table.insert(newTable, v)
                    print(i, v)
                end
            end

            GameRules:GetGameModeEntity():SetUseCustomHeroLevels ( true )
            GameRules:GetGameModeEntity():SetCustomHeroMaxLevel ( OptionManager:GetOption('maxHeroLevel') )
            GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel(newTable)
        end

        if OptionManager:GetOption('322') == 1 then
            GameRules:GetGameModeEntity():SetLoseGoldOnDeath(false)
        end

        -- Check what kind of flags we should be recording
        if this.useOptionVoting then
            -- We are using option voting

            -- Did anyone actually post to the banning bote?
            if this.optionVotingBanning ~= nil then
                -- Someone actually voted
                statCollection:setFlags(self.votingStatFlags)
            end
        else
            -- We are using option selection
            if this.optionStore['lodOptionGamemode'] == -1 then
                -- Players can pick all options, store all options
                statCollection:setFlags({
                    ['Advanced: Allow Selecting Primary Attribute'] = this.optionStore['lodOptionAdvancedSelectPrimaryAttr'],
                    ['Advanced: Allow Custom Skills'] = this.optionStore['lodOptionAdvancedCustomSkills'],
                    ['Advanced: Allow Hero Abilities'] = this.optionStore['lodOptionAdvancedHeroAbilities'],
                    ['Advanced: Allow Neutral Abilities'] = this.optionStore['lodOptionAdvancedNeutralAbilities'],
                    ['Advanced: Allow IMBA Abilities'] = this.optionStore['lodOptionAdvancedImbaAbilities'],
                    ['Advanced: Hide Enemy Picks'] = this.optionStore['lodOptionAdvancedHidePicks'],
                    ['Advanced: Start With Free Courier'] = this.optionStore['lodOptionGameSpeedFreeCourier'],
                    ['Advanced: Unique Heroes'] = this.optionStore['lodOptionAdvancedUniqueHeroes'],
                    ['Advanced: Unique Skills'] = this.optionStore['lodOptionAdvancedUniqueSkills'],
                    ['Bans: Points Mode Banning'] = this.optionStore['lodOptionBanningBalanceMode'],
                    ['Bans: Block Invis Abilities'] = this.optionStore['lodOptionBanningBanInvis'],
                    ['Bans: Block OP Abilities'] = this.optionStore['lodOptionAdvancedOPAbilities'],
                    ['Bans: Block Troll Combos'] = this.optionStore['lodOptionBanningBlockTrollCombos'],
                    ['Bans: Disable Perks'] = this.optionStore['lodOptionDisablePerks'],
                    ['Bans: Consumeable Items'] = this.optionStore['lodOptionConsumeItems'],
                    ['Bans: Host Banning'] = this.optionStore['lodOptionBanningHostBanning'],
                    ['Bans: Max Ability Bans'] = this.optionStore['lodOptionBanningMaxBans'],
                    ['Bans: Max Hero Bans'] = this.optionStore['lodOptionBanningMaxHeroBans'],
                    ['Bans: Use LoD BanList'] = this.optionStore['lodOptionBanningUseBanList'],
                    ['Creeps: Increase Creep Power Over Time'] = this.optionStore['lodOptionCreepPower'],
                    ['Creeps: Increase Neutral Creep Power Over Time'] = this.optionStore['lodOptionNeutralCreepPower'],
                    ['Creeps: Multiply Neutral Camps'] = this.optionStore['lodOptionNeutralMultiply'],
                    ['Creeps: Multiply Lane Creeps'] = this.optionStore['lodOptionLaneMultiply'],
                    ['Game Speed: Bonus Starting Gold'] = this.optionStore['lodOptionGameSpeedStartingGold'],
                    ['Game Speed: Buyback Cooldown Constant'] = this.optionStore['lodOptionBuybackCooldownTimeConstant'],
                    ['Game Speed: Gold Modifier'] = math.floor(this.optionStore['lodOptionGameSpeedGoldModifier']),
                    ['Game Speed: Gold Per Tick'] = this.optionStore['lodOptionGameSpeedGoldTickRate'],
                    ['Game Speed: Max Hero Level'] = this.optionStore['lodOptionGameSpeedMaxLevel'],
                    ['Game Speed: Respawn Modifier Constant'] = this.optionStore['lodOptionGameSpeedRespawnTimeConstant'],
                    ['Game Speed: Respawn Modifier Percentage'] = math.floor(this.optionStore['lodOptionGameSpeedRespawnTimePercentage']),
                    ['Game Speed: Shared XP'] = this.optionStore['lodOptionGameSpeedSharedEXP'],
                    ['Game Speed: Start With Upgraded Ults'] = this.optionStore['lodOptionGameSpeedUpgradedUlts'],
                    ['Game Speed: Starting Level'] = this.optionStore['lodOptionGameSpeedStartingLevel'],
                    ['Game Speed: XP Modifier'] = math.floor(this.optionStore['lodOptionGameSpeedEXPModifier']),
                    ['Gamemode: Points Mode'] = this.optionStore['lodOptionBalanceMode'],
                    ['Gamemode: Duels'] = this.optionStore['lodOptionDuels'],
                    ['Gamemode: Gamemode'] = this.optionStore['lodOptionCommonGamemode'],
                    ['Gamemode: Max Skills'] = this.optionStore['lodOptionCommonMaxSkills'],
                    ['Gamemode: Max Slots'] = this.optionStore['lodOptionCommonMaxSlots'],
                    ['Gamemode: Max Ults'] = this.optionStore['lodOptionCommonMaxUlts'],
                    ['Gamemode: Preset Gamemode'] = this.optionStore['lodOptionGamemode'],
                    ['Other: Enable All Vision'] = this.optionStore['lodOptionCrazyAllVision'],
                    ['Other: Enable Ingame Hero Builder'] = this.optionStore['lodOptionIngameBuilder'],
                    ['Other: Enable Multicast Madness'] = this.optionStore['lodOptionCrazyMulticast'],
                    ['Other: Enable Universal Shop'] = this.optionStore['lodOptionCrazyUniversalShop'],
                    ['Other: Enable WTF Mode'] = this.optionStore['lodOptionCrazyWTF'],
                    ['Other: Fat-O-Meter'] = this.optionStore['lodOptionCrazyFatOMeter'],
                    ['Other: Stop Fountain Camping'] = this.optionStore['lodOptionCrazyNoCamping'],
                    ['Other: 322'] = this.optionStore['lodOption322'],
                    ['Other: Free Extra Ability'] = this.optionStore['lodOptionExtraAbility'],
                    ['Other: Global Cast Range'] = this.optionStore['lodOptionGlobalCast'],
                    ['Other: Refresh Cooldowns On Death'] = this.optionStore['lodOptionRefreshCooldownsOnDeath'],
                    ['Other: Gotta Go Fast!'] = this.optionStore['lodOptionGottaGoFast'],
                    ['Other: Memes Redux'] = this.optionStore['lodOptionMemesRedux'],
                    ['Other: Battle Thirst'] = this.optionStore['lodOptionBattleThirst'],
                    ['Other: Item Drops'] = this.optionStore['lodOptionDarkMoon'],
                    ['Other: Black Forest'] = this.optionStore['lodOptionBlackForest'],
                    ['Towers: Anti-Rat'] = this.optionStore['lodOptionAntiRat'],
                    ['Towers: Enable Stronger Towers'] = this.optionStore['lodOptionGameSpeedStrongTowers'],
                    ['Towers: Towers Per Lane'] = this.optionStore['lodOptionGameSpeedTowersPerLane'],
                    ['Bots: Unique Skills'] = this.optionStore['lodOptionBotsUniqueSkills'],
                    ['Bots: Stupefy'] = this.optionStore['lodOptionBotsStupid'],
                })

                -- Draft arrays
                if this.useDraftArrays then
                    statCollection:setFlags({
                        ['Draft Abilities'] = this.optionStore['lodOptionDraftAbilities'],
                    })
                end
            else
                -- Store presets
                statCollection:setFlags({
                    ['Preset Gamemode'] = this.optionStore['lodOptionGamemode'],
                    ['Preset Banning'] = this.optionStore['lodOptionBanning'],
                    ['Preset Max Slots'] = this.optionStore['lodOptionSlots'],
                    ['Preset Max Ults'] = this.optionStore['lodOptionUlts'],
                })

                -- Store draft array setting if it is being used
                if this.useDraftArrays then
                    statCollection:setFlags({
                        ['Preset Draft Heroes'] = this.optionStore['lodOptionCommonDraftAbilities'],
                    })
                end
            end
        end



        -- If bots are enabled, add a bots flags
        if this.enabledBots then
            statCollection:setFlags({
                ['Bots: Bots Enabled'] = 1,
                ['Bots: Desired Radiant Bots'] = this.optionStore['lodOptionBotsRadiant'],
                ['Bots: Desired Dire Bots'] = this.optionStore['lodOptionBotsDire']
            })
        else
            statCollection:setFlags({
                ['Bots: Bots Enabled'] = 0,
            })
        end

        -- Challenge mode
        if this.challengeMode then
            statCollection:setFlags({
                ['Challenge Mode'] = challenge:getChallengeName()
            })
        end
    end)

    -- Did it fail?
    if not status then
        SendToServerConsole('say "Post this to the LoD comments section: '..err:gsub('"',"''")..'"')
    end
end

-- Validates, and then sets an option
function Pregame:setOption(optionName, optionValue, force)
    -- option validator

    if not self.validOptions[optionName] then
        -- Tell the user they tried to modify an invalid option
        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodFailedToFindOption',
            params = {
                ['optionName'] = optionName
            }
        })

        return
    end

    if not force and not self.validOptions[optionName](optionValue) then
        -- Tell the user they gave an invalid value
        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodFailedToSetOptionValue',
            params = {
                ['optionName'] = optionName,
                ['optionValue'] = optionValue
            }
        })

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

-- Bans an ability
function Pregame:banAbility(abilityName)
    if not self.bannedAbilities[abilityName] then
        -- Do the ban
        self.bannedAbilities[abilityName] = true
        network:banAbility(abilityName)

        return true
    end

    return false
end

-- Bans a hero
function Pregame:banHero(heroName)
    if not self.bannedHeroes[heroName] then
        -- Do the ban
        self.bannedHeroes[heroName] = true
        network:banHero(heroName)

        return true
    end

    return false
end

-- Returns a player's draft index
function Pregame:getDraftID(playerID)
    -- If it's single draft, just use our playerID
    if self.singleDraft or self.boosterDraft then
        return playerID
    end

    local maxPlayers = 24

    local theirTeam = PlayerResource:GetTeam(playerID)

    local draftID = 0
    for i=0,(maxPlayers - 1) do
        -- Stop when we hit our playerID
        if playerID == i then break end

        if PlayerResource:GetTeam(i) == theirTeam then
            draftID = draftID + 1
            if draftID > 4 then
                draftID = 0
            end
        end
    end

    return draftID
end

-- Tries to set a player's selected hero
function Pregame:setSelectedHero(playerID, heroName, force)
    -- Grab the player so we can push messages
    local player = PlayerResource:GetPlayer(playerID)

    -- Validate hero
    if not self.allowedHeroes[heroName] then
        -- Add an error
        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodFailedToFindHero'
        })
        self:PlayAlert(playerID)

        return
    end

    -- Check forced stuff
    if not force then
        -- Is this hero banned?
        -- Validate the ability isn't already banned
        if self.bannedHeroes[heroName] then
            -- hero is banned
            network:sendNotification(player, {
                sort = 'lodDanger',
                text = 'lodFailedHeroIsBanned',
                params = {
                    ['heroName'] = heroName
                }
            })
            self:PlayAlert(playerID)

            return
        end

        -- Is unique heroes on?
        if self.optionStore['lodOptionAdvancedUniqueHeroes'] == 1 then
            for thePlayerID,theSelectedHero in pairs(self.selectedHeroes) do
                if theSelectedHero == heroName then
                    -- Tell them
                    network:sendNotification(player, {
                        sort = 'lodDanger',
                        text = 'lodFailedHeroIsTaken',
                        params = {
                            ['heroName'] = heroName
                        }
                    })
                    self:PlayAlert(playerID)

                    return
                end
            end
        end

        -- Check draft array
        if self.useDraftArrays then
            local draftID = self:getDraftID(playerID)
            local draftArray = self.draftArrays[draftID] or {}
            local heroDraft = draftArray.heroDraft

            if self.maxDraftHeroes > 0 then
                if not heroDraft[heroName] then
                    -- Tell them
                    network:sendNotification(player, {
                        sort = 'lodDanger',
                        text = 'lodFailedDraftWrongHero',
                        params = {
                            ['heroName'] = heroName
                        }
                    })
                    self:PlayAlert(playerID)

                    return
                end
            end
        end
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
        EmitGlobalSound("Event.Click")
        -- Update the selected hero
        network:setSelectedHero(playerID, heroName)

    end
end

-- Player wants to select a hero
function Pregame:onPlayerSelectHero(eventSourceIndex, args)
    -- Grab data
    local playerID = args.PlayerID
    local player = PlayerResource:GetPlayer(playerID)

    -- Ensure we are in the picking phase
    if self:getPhase() ~= constants.PHASE_SELECTION and not self:canPlayerPickSkill() then
        -- Ensure we are in the picking phase
        if self:getPhase() ~= constants.PHASE_SELECTION and not self:canPlayerPickSkill() then
            network:sendNotification(player, {
                sort = 'lodDanger',
                text = 'lodFailedWrongPhaseSelection'
            })
            self:PlayAlert(playerID)

            return
        end

        return
    end

    -- Have they locked their skills?
    if self.isReady[playerID] == 1 then
        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodFailedPlayerIsReady'
        })
        self:PlayAlert(playerID)

        return
    end

    -- Attempt to select the hero
    self:setSelectedHero(playerID, args.heroName)


    -- Check if the hero has banned skills that should be removed
    if self.bannedAbilities and self.selectedSkills[playerID] then
        for i=1,6 do
            if self.bannedAbilities[self.selectedSkills[playerID][i]] then
                self:removeSelectedAbility(playerID, i)
            end
        end
    end
    -- Add skill to hero if needed
    local hero = args.heroName
    -- Play Meme sounds
    if hero and hero == "npc_dota_hero_juggernaut" and OptionManager:GetOption("memesRedux") == 1 then
        EmitGlobalSound("Memes.Swords")
    end

    if hero and GameRules.perks["heroAbilityPairs"][hero] then
        -- Do not try to learn it twice
        local hasAbil = false
        if self.selectedSkills[playerID] then
            for k,v in pairs (self.selectedSkills[playerID]) do
                if v == GameRules.perks["heroAbilityPairs"][hero] then
                    hasAbil = true
                    break
                end
            end
        end
        if not hasAbil then
            self:onPlayerSelectAbility(0, {PlayerID = playerID, abilityName = GameRules.perks["heroAbilityPairs"][hero], slot=1})
        end
    end

    if hero then
        if not util:checkPickedHeroes( self.selectedHeroes ) and self.additionalPickTime then
            -- Change to picking phase
            self:setPhase(constants.PHASE_SPAWN_HEROES)

            -- Kill the selection screen
            self:setEndOfPhase(Time() + OptionManager:GetOption('reviewTime'), OptionManager:GetOption('reviewTime'))

            GameRules:FinishCustomGameSetup()
        end
    end
end

-- Attempts to set a player's attribute
function Pregame:setSelectedAttr(playerID, newAttr)
    local player = PlayerResource:GetPlayer(playerID)

    -- Validate that the option is enabled
    if self.optionStore['lodOptionAdvancedSelectPrimaryAttr'] == 0 then
        -- Add an error
        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodFailedToChangeAttr'
        })
        self:PlayAlert(playerID)

        return
    end

    -- Validate the new attribute
    if newAttr ~= 'str' and newAttr ~= 'agi' and newAttr ~= 'int' then
        -- Add an error
        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodFailedToChangeAttrInvalid'
        })
        self:PlayAlert(playerID)

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

-- Player wants to select a new primary attribute
function Pregame:onPlayerSelectAttr(eventSourceIndex, args)
    -- Grab data
    local playerID = args.PlayerID
    local player = PlayerResource:GetPlayer(playerID)

    -- Have they locked their skills?
    if self.isReady[playerID] == 1 then
        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodFailedPlayerIsReady'
        })
        self:PlayAlert(playerID)

        return
    end

    -- Ensure we are in the picking phase
    if self:getPhase() ~= constants.PHASE_SELECTION and not self:canPlayerPickSkill() then
        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodFailedWrongPhaseSelection'
        })
        self:PlayAlert(playerID)

        return
    end

    -- Attempt to set it
    self:setSelectedAttr(playerID, args.newAttr)
end

-- Player is asking why they don't have a hero
function Pregame:onPlayerAskForHero(eventSourceIndex, args)
    -- This code only works during the game phase
    if self:getPhase() ~= constants.PHASE_INGAME then return end

    -- Grab data
    local playerID = args.PlayerID
    local player = PlayerResource:GetPlayer(playerID)

    self:actualSpawnPlayer(playerID)
end

-- Player wants to select an entire build
function Pregame:onPlayerSelectBuild(eventSourceIndex, args)
    -- Grab data
    local playerID = args.PlayerID
    local player = PlayerResource:GetPlayer(playerID)

    -- Ensure we are in the picking phase
    if self:getPhase() ~= constants.PHASE_SELECTION and not self:canPlayerPickSkill() then
        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodFailedWrongPhaseSelection'
        })
        self:PlayAlert(playerID)

        return
    end

    -- Have they locked their skills?
    if self.isReady[playerID] == 1 then
        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodFailedPlayerIsReady'
        })
        self:PlayAlert(playerID)

        return
    end

    -- Grab the stuff
    local hero = args.hero
    local attr = args.attr
    local build = args.build
    local build_id = args.id

    -- Do we need to change our hero?
    if self.selectedHeroes ~= hero then
        -- Set the hero
        self:setSelectedHero(playerID, hero)
    end

    -- Do we have a different attr?
    if self.selectedPlayerAttr[playerID] ~= attr then
        -- Attempt to set it
        self:setSelectedAttr(playerID, attr)
    end

    -- Grab number of slots
    local maxSlots = self.optionStore['lodOptionCommonMaxSlots']

    -- Reset the player's build
    self.selectedSkills[playerID] = {}

    for slotID=1,maxSlots do
        if build[tostring(slotID)] ~= nil then
            self:setSelectedAbility(playerID, slotID, build[tostring(slotID)], true)
        end
    end

    if self.soundList[build_id] then
        local sound = self:getRandomSound(build_id)
        EmitAnnouncerSoundForPlayer(sound, playerID)
    end

    -- Perform the networking
    network:setSelectedAbilities(playerID, self.selectedSkills[playerID])
end


function Pregame:getRandomSound(sound_id)
    return util:RandomChoice(self.soundList[sound_id])
end


-- Player wants to select an all random build
function Pregame:onPlayerSelectAllRandomBuild(eventSourceIndex, args)
    local playerID = args.PlayerID
    local player = PlayerResource:GetPlayer(playerID)

    -- Player shouldn't be able to do this unless it is the all random phase
    if self:getPhase() ~= constants.PHASE_RANDOM_SELECTION and not self:canPlayerPickSkill() then
        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodFailedNotAllRandomPhase'
        })
        self:PlayAlert(playerID)
        return
    end

    -- Read options
    local buildID = args.buildID
    local heroOnly = args.heroOnly == 1

    -- Validate builds
    local builds = self.allRandomBuilds[playerID]
    if builds == nil then
        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodFailedAllRandomNoBuilds'
        })
        self:PlayAlert(playerID)
        return
    end

    local build = builds[tonumber(buildID)]
    if build == nil then
        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodFailedAllRandomInvalidBuild',
            params = {
                ['buildID'] = buildID
            }
        })
        self:PlayAlert(playerID)
        return
    end

    -- Are we meant to set the hero or hte build?
    if not heroOnly then
        -- Push the build
        self.selectedSkills[playerID] = build.build
        network:setSelectedAbilities(playerID, build.build)

        -- Change which build has been selected
        self.selectedRandomBuilds[playerID].build = buildID
        network:setSelectedAllRandomBuild(playerID, self.selectedRandomBuilds[playerID])
    else
        -- Must be valid, select it
        local heroName = build.heroName

        if self.selectedHeroes[playerID] ~= heroName then
            self.selectedHeroes[playerID] = heroName
            network:setSelectedHero(playerID, heroName)

            -- Attempt to set the primary attribute
            local newAttr = self.heroPrimaryAttr[heroName] or 'str'
            if self.selectedPlayerAttr[playerID] ~= newAttr then
                -- Update local store
                self.selectedPlayerAttr[playerID] = newAttr

                -- Update the selected hero
                network:setSelectedAttr(playerID, newAttr)
            end
        end

        -- Change which hero has been selected
        self.selectedRandomBuilds[playerID].hero = buildID
        network:setSelectedAllRandomBuild(playerID, self.selectedRandomBuilds[playerID])
    end
end

-- Player wants to ready up
function Pregame:onPlayerReady(eventSourceIndex, args)
    if self:getPhase() ~= constants.PHASE_BANNING and self:getPhase() ~= constants.PHASE_SELECTION and self:getPhase() ~= constants.PHASE_RANDOM_SELECTION and self:getPhase() ~= constants.PHASE_REVIEW and not self:canPlayerPickSkill() then return end
    if self:canPlayerPickSkill() and IsValidEntity(PlayerResource:GetSelectedHeroEntity(args.PlayerID)) then
        local playerID = args.PlayerID
        local hero = PlayerResource:GetSelectedHeroEntity(playerID)
        if IsValidEntity(hero) then
            local newBuild = util:DeepCopy(self.selectedSkills[playerID])
            local count = 0
            for key,_ in pairs(newBuild) do
                if tonumber(key) then
                    count = count + 1
                end
            end
            local maxCount = self.optionStore['lodOptionCommonMaxSlots']
            if count ~= maxCount then
                for i=1,maxCount do
                    if not newBuild[i] then
                        local randomSkill = self:findRandomSkill(newBuild, i, playerID)
                        newBuild[i] = randomSkill
                        self.selectedSkills[playerID][i] = randomSkill
                    end
                end
            end
            local newHeroName = self.selectedHeroes[playerID]
            if not newBuild or not newHeroName then return end
            newBuild.hero = newHeroName
            newBuild.setAttr = self.selectedPlayerAttr[playerID]
            local isSameBuild = true
            for i=1,maxCount do
                local ability = hero:FindAbilityByName(newBuild[i])
                if not ability then
                    isSameBuild = false
                    break
                end
            end
            local attr = hero:GetPrimaryAttribute()
            attr = attr == 0 and 'str' or attr == 1 and 'agi' or attr == 2 and 'int'
            local heroName = PlayerResource:GetSelectedHeroName(playerID)
            if newBuild.setAttr ~= attr or newBuild.hero ~= heroName then
                isSameBuild = false
            end
            if isSameBuild then
                local player = PlayerResource:GetPlayer(playerID)
                network:hideHeroBuilder(player)
                return
            end
            SkillManager:ApplyBuild(hero, newBuild)
            local player = PlayerResource:GetPlayer(playerID)
            network:hideHeroBuilder(player)
            network:setSelectedAbilities(playerID, self.selectedSkills[playerID])
            network:setSelectedHero(playerID, newBuild.hero)
            network:setSelectedAttr(playerID, newBuild.setAttr)
            hero = PlayerResource:GetSelectedHeroEntity(playerID)
            --if OptionManager:GetOption('ingameBuilderPenalty') > 0 then
            --TODO: If long enough, players die to respawn
            self:fixSpawnedHero(hero)
            if not util:isSinglePlayerMode() and OptionManager:GetOption('ingameBuilderPenalty') > 0 then
                Timers:CreateTimer(function()
                    local penalty = OptionManager:GetOption('ingameBuilderPenalty')

                    hero:Kill(nil, nil)

                    Timers:CreateTimer(function()
                        hero:SetTimeUntilRespawn(penalty)
                    end, DoUniqueString('respawnFix'), 1)

                end, DoUniqueString('penalty'), 1)
            else
                if hero:GetTeam() == DOTA_TEAM_BADGUYS then
                    local ent = Entities:FindByClassname(nil, "info_player_start_badguys")
                    hero:SetAbsOrigin(ent:GetAbsOrigin())
                    hero:AddNewModifier(hero, nil, "modifier_phased", {Duration = 2})
                elseif hero:GetTeam() == DOTA_TEAM_GOODGUYS then
                    local ent = Entities:FindByClassname(nil, "info_player_start_goodguys")
                    hero:SetAbsOrigin(ent:GetAbsOrigin())
                    hero:AddNewModifier(hero, nil, "modifier_phased", {Duration = 2})
                end
            end
            GameRules:SendCustomMessage('Player '..PlayerResource:GetPlayerName(playerID)..' just changed build.', 0, 0)
        end
    else
        local playerID = args.PlayerID

        -- Ensure we have a store for this player's ready state
        self.isReady[playerID] = self.isReady[playerID] or 0

        -- Toggle their state
        self.isReady[playerID] = (self.isReady[playerID] == 1 and 0) or 1

        -- Players can only trigger the locking sound twice, to prevent abuse
        if self.heard[playerID] ~= 2 then
            print(self.heard[playerID])
            if not self.heard[playerID] then
                self.heard[playerID] = 1
            else
                self.heard[playerID] = self.heard[playerID] + 1
            end
            EmitGlobalSound("Event.LockBuild")
        end

        -- Checks if people are ready
        self:checkForReady()
    end
end

-- Checks if people are ready
function Pregame:checkForReady()
    -- Network it
    network:sendReadyState(self.isReady)

    local currentTime = self.endOfTimer - Time()
    local maxTime = OptionManager:GetOption('pickingTime')
    local minTime = 3
    --QUICKER DEBUGGING CHANGE
    if IsInToolsMode() then
        minTime = 0.5
    end


    local canFinishBanning = false

    -- If we are in the banning phase
    if self:getPhase() == constants.PHASE_BANNING then
        maxTime = OptionManager:GetOption('banningTime')

        canFinishBanning = (self.optionStore['lodOptionBanningHostBanning'] == 1 and self.isReady[getPlayerHost():GetPlayerID()] == 1)
    end

    -- If we are in the random phase
    if self:getPhase() == constants.PHASE_RANDOM_SELECTION then
        maxTime = OptionManager:GetOption('randomSelectionTime')
    end

    -- If we are in the review phase
    if self:getPhase() == constants.PHASE_REVIEW then
        maxTime = OptionManager:GetOption('reviewTime')

        if not self.Announce_review then
            self.Announce_review = true
            if OptionManager:GetOption("memesRedux") == 1 then
                EmitGlobalSound("Memes.Review")
            else
                local sound = self:getRandomSound("game_review_phase")
                EmitAnnouncerSound(sound)
            end
        end


        -- Caching must complete first!
        if not donePrecaching then return end
    end

    -- Calculate how many players are ready
    local totalPlayers = self:getActivePlayers()
    local readyPlayers = 0

    for playerID,readyState in pairs(self.isReady) do
        -- Ensure the player is connected AND ready
        if readyState == 1 and PlayerResource:GetConnectionState(playerID) == 2 then
            readyPlayers = readyPlayers + 1
        end
    end

    -- Is there at least one player that is ready?
    if readyPlayers > 0 then
        -- Someone is ready, timer should be moving

        -- Is time currently frozen?
        if self.freezeTimer ~= nil and not canFinishBanning then
            -- Start the clock

            if readyPlayers >= totalPlayers then
                -- Single player
                self:setEndOfPhase(Time() + minTime)
            else
                -- Multiplayer, start the timer ticking
                self:setEndOfPhase(Time() + maxTime)
            end
        else
            -- Check if we can lower the timer

            -- If everyone is ready, set the remaining time to be the min
            if readyPlayers >= totalPlayers or canFinishBanning then
                if canFinishBanning or currentTime > minTime then
                    self:setEndOfPhase(Time() + minTime)
                end
            else
                local percentageReady = (readyPlayers-1) / totalPlayers

                local discountTime = maxTime * (1-percentageReady) * 1.5

                if discountTime < currentTime then
                    self:setEndOfPhase(Time() + discountTime)
                end
            end
        end
    else
        -- No one is ready, freeze time at max
        self:setEndOfPhase(Time() + maxTime, maxTime)
    end
end

-- Track local stats
function Pregame:onPlayerSaveStats(playerID, abilities)
    -- Grab data
    local player = PlayerResource:GetPlayer(playerID)

    if PlayerResource:GetSteamAccountID(playerID) == 0 then
        return
    end

    local i = 1
    local function statsQueue()
        local abName = abilities[i]

        if abName then
            localStorage:getKey(playerID, "redux_stats", abName, function (sequenceNumber, success, value)
                -- local value = 0
                if success then
                    value = (tonumber(value) or 0) + 1
                else
                    value = 1
                end
                localStorage:setKey(playerID, "redux_stats", abName, value, function (sequenceNumber, success)
                    if i < 23 then
                        i = i + 1
                        statsQueue()
                    end
                end)
            end)
        end
    end
    statsQueue()
end

-- Player wants to ban an ability
function Pregame:onPlayerSaveBans(eventSourceIndex, args)
    -- Grab data
    local playerID = args.PlayerID
    local player = PlayerResource:GetPlayer(playerID)

    local count = (self.optionStore['lodOptionBanningMaxBans'] + self.optionStore['lodOptionBanningMaxHeroBans'])

    if count == 0 and self.optionStore['lodOptionBanningHostBanning'] > 0 then
        count = util:getTableLength(self.playerBansList[playerID])
    end

    local id = 0

    if self.playerBansList[playerID] then
        local i = 0
        repeat
            i = i + 1
            local tempI = i
            localStorage:setKey(playerID, "bans", tostring(tempI), "", function (sequenceNumber, success)
                localStorage:setKey(playerID, "bans", tostring(tempI), self.playerBansList[playerID][tempI] or "", function (sequenceNumber, success)
                    id = id + 1
                    if id == #self.playerBansList[playerID] then
                        CustomGameEventManager:Send_ServerToPlayer(player,"lodNotification",{text = 'lodSuccessSavedBans', params = {['entries'] = id}})
                    end
                end)
            end)
        until
            i > count
    end
end

-- Player wants to ban an ability
function Pregame:onPlayerLoadBans(eventSourceIndex, args)
    -- Grab data
    local playerID = args.PlayerID
    local player = PlayerResource:GetPlayer(playerID)

    local id = 0

    local count = (self.optionStore['lodOptionBanningMaxBans'] + self.optionStore['lodOptionBanningMaxHeroBans'])

    if count == 0 and self.optionStore['lodOptionBanningHostBanning'] > 0 then
        count = 1000
    end

    for i=1,count do
        localStorage:getKey(playerID, "bans", tostring(i), function (sequenceNumber, success, value)
            if success and value and value ~= "" then
                if string.match(value, "npc_dota_hero_") and not self.bannedHeroes[value] and (self.optionStore['lodOptionBanningHostBanning'] > 0 or not self.usedBans[playerID] or self.usedBans[playerID].heroBans < self.optionStore['lodOptionBanningMaxBans']) then
                    self:onPlayerBan(0, {
                        PlayerID = playerID,
                        heroName = value
                        }, true)
                elseif not self.bannedAbilities[value] and (self.optionStore['lodOptionBanningHostBanning'] > 0 or not self.usedBans[playerID] or self.usedBans[playerID].abilityBans < self.optionStore['lodOptionBanningMaxBans']) then
                    self:onPlayerBan(0, {
                        PlayerID = playerID,
                        abilityName = value
                        }, true)
                end
                id = id + 1
            end
            if not success or i == count then
                CustomGameEventManager:Send_ServerToPlayer(player,"lodNotification",{text = "lodSuccessLoadBans", params = {['entries'] = id}})
            end
        end)
    end
end

-- Player wants to ban an ability
function Pregame:onPlayerBan(eventSourceIndex, args, noNotification)
    -- Grab data
    local playerID = args.PlayerID
    local player = PlayerResource:GetPlayer(playerID)

    -- Ensure we are in the banning phase
    if self:getPhase() ~= constants.PHASE_BANNING then
        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodFailedWrongPhaseBanning'
        })
        self:PlayAlert(playerID)

        return
    end

    local usedBans = self.usedBans

    -- Ensure we have a store
    usedBans[playerID] = usedBans[playerID] or {
        heroBans = 0,
        abilityBans = 0
    }

    self.playerBansList[playerID] = self.playerBansList[playerID] or {}

    -- Grab the ban object
    local playerBans = usedBans[playerID]

    -- Grab settings
    local maxBans = self.optionStore['lodOptionBanningMaxBans']
    local maxHeroBans = self.optionStore['lodOptionBanningMaxHeroBans']

    local unlimitedBans = false
    if self.optionStore['lodOptionBanningHostBanning'] == 1 and isPlayerHost(player) then
        unlimitedBans = true
    end

    -- Check what kind of ban it is
    local heroName = args.heroName
    local abilityName = args.abilityName

    -- Default is heroBan
    if heroName ~= nil then
        -- Check the number of bans
        if playerBans.heroBans >= maxHeroBans and not unlimitedBans then
            if maxHeroBans == 0 then
                -- There is no hero banning
                if not noNotification then
                    network:sendNotification(player, {
                        sort = 'lodDanger',
                        text = 'lodFailedBanHeroNoBanning'
                    })
                    self:PlayAlert(playerID)
                end


                return
            else
                -- Player has used all their bans
                if not noNotification then
                    network:sendNotification(player, {
                        sort = 'lodDanger',
                        text = 'lodFailedBanHeroLimit',
                        params = {
                            ['used'] = playerBans.heroBans,
                            ['max'] = maxHeroBans
                        }
                    })
                    self:PlayAlert(playerID)
                end

            end

            return
        end

        -- Is this a valid hero?
        if not self.allowedHeroes[heroName] then
            -- Add an error
            if not noNotification then
                network:sendNotification(player, {
                    sort = 'lodDanger',
                    text = 'lodFailedToFindHero'
                })
                self:PlayAlert(playerID)
            end


            return
        end

        -- Perform the ban
        if self:banHero(heroName) then
            -- Success
            table.insert(self.playerBansList[playerID], heroName)

            if not noNotification then
                network:broadcastNotification({
                    sort = 'lodSuccess',
                    text = 'lodSuccessBanHero',
                    params = {
                        ['heroName'] = heroName
                    }
                })
            end

            -- Increase the number of ability bans this player has done
            playerBans.heroBans = playerBans.heroBans + 1

            -- Network how many bans have been used
            network:setTotalBans(playerID, playerBans.heroBans, playerBans.abilityBans)
        else
            -- Ability was already banned
            if not noNotification then
                network:sendNotification(player, {
                    sort = 'lodDanger',
                    text = 'lodFailedBanHeroAlreadyBanned',
                    params = {
                        ['heroName'] = heroName
                    }
                })
                self:PlayAlert(playerID)
            end

            return
        end
    elseif abilityName ~= nil then
        -- Check the number of bans
        if playerBans.abilityBans >= maxBans and not unlimitedBans then
            if maxBans == 0 then
                -- No ability banning allowed
                if not noNotification then
                    network:sendNotification(player, {
                        sort = 'lodDanger',
                        text = 'lodFailedBanAbilityNoBanning'
                    })
                    self:PlayAlert(playerID)
                end

                return
            else
                -- Player has used all their bans
                if not noNotification then
                    network:sendNotification(player, {
                        sort = 'lodDanger',
                        text = 'lodFailedBanAbilityLimit',
                        params = {
                            ['used'] = playerBans.abilityBans,
                            ['max'] = maxBans
                        }
                    })
                    self:PlayAlert(playerID)
                end
            end


            return
        end

        -- Is this even a real skill?
        if not self.flagsInverse[abilityName] then
            -- Invalid ability name
                if not noNotification then
                network:sendNotification(player, {
                    sort = 'lodDanger',
                    text = 'lodFailedInvalidAbility',
                    params = {
                        ['abilityName'] = abilityName
                    }
                })
                self:PlayAlert(playerID)
            end

            return
        end

        -- Perform the ban
        if self:banAbility(abilityName) then
            -- Success
            table.insert(self.playerBansList[playerID], abilityName)

            if not noNotification then
                network:broadcastNotification({
                    sort = 'lodSuccess',
                    text = 'lodSuccessBanAbility',
                    params = {
                        ['abilityName'] = 'DOTA_Tooltip_ability_' .. abilityName
                    }
                })
            end

            -- Increase the number of bans this player has done
            playerBans.abilityBans = playerBans.abilityBans + 1

            -- Network how many bans have been used
            network:setTotalBans(playerID, playerBans.heroBans, playerBans.abilityBans)
        else
            -- Ability was already banned

            if not noNotification then
                network:sendNotification(player, {
                    sort = 'lodDanger',
                    text = 'lodFailedBanAbilityAlreadyBanned',
                    params = {
                        ['abilityName'] = 'DOTA_Tooltip_ability_' .. abilityName
                    }
                })
                self:PlayAlert(playerID)
            end

            return
        end
    end

    -- Have they hit the ban limit?
    if playerBans.heroBans >= maxHeroBans and playerBans.abilityBans >= maxBans and not unlimitedBans then
        -- Toggle their state
        self.isReady[playerID] =  1

        -- Checks if people are ready
        self:checkForReady()
    end
end

function Pregame:PlayAlert(playerID)
    local sound = self:getRandomSound("game_error_alert")
    if OptionManager:GetOption("memesRedux") == 1 then
        --EmitAnnouncerSoundForPlayer("Memes.Denied", playerID)
        EmitGlobalSound("Memes.Denied")
    else
        EmitAnnouncerSoundForPlayer(sound, playerID)
    end
end

-- Player wants to select a random hero
function Pregame:onPlayerSelectRandomHero(eventSourceIndex, args)
    -- Grab data
    local playerID = args.PlayerID
    local player = PlayerResource:GetPlayer(playerID)

    -- Ensure we are in the picking phase
    if self:getPhase() ~= constants.PHASE_SELECTION then
        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodFailedWrongPhaseAllRandom'
        })
        self:PlayAlert(playerID)

        return
    end

    -- Have they locked their skills?
    if self.isReady[playerID] == 1 then
        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodFailedPlayerIsReady'
        })
        self:PlayAlert(playerID)

        return
    end

    args.heroName = self:getRandomHero()

    self:onPlayerSelectHero(eventSourceIndex, args)
end

-- Player wants to select a random ability
function Pregame:onPlayerSelectRandomAbility(eventSourceIndex, args)
    -- Grab data
    local playerID = args.PlayerID
    local player = PlayerResource:GetPlayer(playerID)

    -- Ensure we are in the picking phase
    if self:getPhase() ~= constants.PHASE_SELECTION then
        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodFailedWrongPhaseAllRandom'
        })
        self:PlayAlert(playerID)

        return
    end

    -- Have they locked their skills?
    if self.isReady[playerID] == 1 then
        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodFailedPlayerIsReady'
        })
        self:PlayAlert(playerID)

        return
    end

    local slot = math.floor(tonumber(args.slot))

    local maxSlots = self.optionStore['lodOptionCommonMaxSlots']
    local maxRegulars = self.optionStore['lodOptionCommonMaxSkills']
    local maxUlts = self.optionStore['lodOptionCommonMaxUlts']

    -- Ensure a container for this player exists
    self.selectedSkills[playerID] = self.selectedSkills[playerID] or {}

    local build = self.selectedSkills[playerID]

    -- Validate the slot is a valid slot index
    if slot < 1 or slot > maxSlots then
        -- Invalid slot number
        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodFailedInvalidSlot'
        })
        self:PlayAlert(playerID)

        return
    end

    -- Grab a random ability
    local newAbility = self:findRandomSkill(build, slot, playerID)

    if newAbility == nil then
        -- No ability found, report error
        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodFailedNoValidAbilities'
        })
        self:PlayAlert(playerID)

        return
    else
        -- Store it
        build[slot] = newAbility

        -- Network it
        network:setSelectedAbilities(playerID, build)
    end
end

-- Tries to remove the ability in the giben slot.
function Pregame:removeSelectedAbility(playerID, slot, dontNetwork)
    -- Grab the player so we can push messages
    local player = PlayerResource:GetPlayer(playerID)

    -- Grab settings
    local maxSlots = self.optionStore['lodOptionCommonMaxSlots']
    local maxRegulars = self.optionStore['lodOptionCommonMaxSkills']
    local maxUlts = self.optionStore['lodOptionCommonMaxUlts']

    -- Ensure a container for this player exists
    self.selectedSkills[playerID] = self.selectedSkills[playerID] or {}

    local build = self.selectedSkills[playerID]
    build[slot] = nil

    -- Should we network it
    if not dontNetwork then
        -- Network it
        network:setSelectedAbilities(playerID, build)
    end
end

-- Tries to set which ability is in the given slot
function Pregame:setSelectedAbility(playerID, slot, abilityName, dontNetwork)
    -- Grab the player so we can push messages
    local player = PlayerResource:GetPlayer(playerID)

    -- Grab settings
    local maxSlots = self.optionStore['lodOptionCommonMaxSlots']
    local maxRegulars = self.optionStore['lodOptionCommonMaxSkills']
    local maxUlts = self.optionStore['lodOptionCommonMaxUlts']

    -- Ensure a container for this player exists
    self.selectedSkills[playerID] = self.selectedSkills[playerID] or {}

    local build = self.selectedSkills[playerID]

    -- Grab what the new build would be, to run tests against it
    local newBuild = SkillManager:grabNewBuild(build, slot, abilityName)

    -- Validate the slot is a valid slot index
    if (slot < 1 or slot > maxSlots) and not self.boosterDraftPicking then
        -- Invalid slot number
        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodFailedInvalidSlot'
        })
        self:PlayAlert(PlayerID)

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
        self:PlayAlert(playerID)

        return
    end

    -- Check draft array
    if self.useDraftArrays then
        local draftID = self:getDraftID(playerID)
        local draftArray = self.draftArrays[draftID] or {}
        local heroDraft = draftArray.heroDraft
        local abilityDraft = draftArray.abilityDraft

        if abilityDraft then
            if not abilityDraft[abilityName] then
                -- Tell them
                network:sendNotification(player, {
                    sort = 'lodDanger',
                    text = 'lodFailedDraftWrongAbility',
                    params = {
                        ['abilityName'] = 'DOTA_Tooltip_ability_' .. abilityName
                    }
                })
                self:PlayAlert(playerID)

                return
            end
        end

        if self.maxDraftSkills > 0 then
            if not abilityDraft[abilityName] then
                -- Tell them
                network:sendNotification(player, {
                    sort = 'lodDanger',
                    text = 'lodFailedDraftWrongAbility',
                    params = {
                        ['abilityName'] = 'DOTA_Tooltip_ability_' .. abilityName
                    }
                })
                self:PlayAlert(playerID)

                return
            end
        end
    end

    if hero and GameRules.perks["heroAbilityPairs"][hero] == abilityName then
            network:sendNotification(player, {
                sort = 'lodDanger',
                text = 'lodHeroAndAbilityAreLocked'
            })
            self:PlayAlert(playerID)
            return
        end

    -- Don't allow picking banned abilities
    -- Unless they are paired
    local hero = self.selectedHeroes[playerID]
    if self.bannedAbilities[abilityName] and not (hero and GameRules.perks["heroAbilityPairs"][hero] == abilityName) then
        -- Invalid ability name
        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodFailedSkillIsBanned',
            params = {
                ['abilityName'] = 'DOTA_Tooltip_ability_' .. abilityName
            }
        })
        self:PlayAlert(playerID)

        return
    end

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
        self:PlayAlert(playerID)

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
        self:PlayAlert(playerID)

        return
    end

    -- Do they already have this ability?
    for k,v in pairs(build) do
        if k ~= slot and v == abilityName then
            -- Invalid ability name
            network:sendNotification(player, {
                sort = 'lodDanger',
                text = 'lodFailedAlreadyGotSkill',
                params = {
                    ['abilityName'] = 'DOTA_Tooltip_ability_' .. abilityName
                }
            })
            self:PlayAlert(playerID)

            return
        end
    end

    -- Is the ability in one of the allowed categories?
    local cat = (self.flagsInverse[abilityName] or {}).category
    if cat then
        local allowed = true

        if cat == 'main' then
            allowed = self.optionStore['lodOptionAdvancedHeroAbilities'] == 1
        elseif cat == 'neutral' then
            allowed = self.optionStore['lodOptionAdvancedNeutralAbilities'] == 1
        elseif cat == 'custom' then
            allowed = self.optionStore['lodOptionAdvancedCustomSkills'] == 1
        elseif cat == 'dotaimba' then
            allowed = self.optionStore['lodOptionAdvancedImbaAbilities'] == 1
        elseif cat == 'OP' then
            allowed = self.optionStore['lodOptionAdvancedOPAbilities'] == 0
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
            self:PlayAlert(playerID)
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
        self:PlayAlert(playerID)

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
            self:PlayAlert(playerID)
            return
        end
    end

   -- Over the Balance Mode point balance
    if self.optionStore['lodOptionBalanceMode'] == 1 then
        -- Validate that the user has enough points
        local outOfPoints, overflow = self:notEnoughPoints(newBuild)
        if outOfPoints then
            -- Invalid ability name
            network:sendNotification(player, {
                sort = 'lodDanger',
                text = 'lodFailedBalanceMode',
                params = {
                    ['ab'] = 'DOTA_Tooltip_ability_' .. abilityName,
                    ['points'] = overflow
                }
            })
            local sound = self:getRandomSound("game_out_of_points")
            EmitAnnouncerSoundForPlayer(sound, playerID)
            return
        end
    end

    -- Consider unique skills
    if self.optionStore['lodOptionAdvancedUniqueSkills'] == 1 then
        local team = PlayerResource:GetTeam(playerID)

        for thePlayerID,theBuild in pairs(self.selectedSkills) do
            -- Ensure the team matches up
            if team == PlayerResource:GetTeam(thePlayerID) then
                for theSlot,theAbility in pairs(theBuild) do
                    if theAbility == abilityName then
                        -- Skill is taken
                        network:sendNotification(player, {
                            sort = 'lodDanger',
                            text = 'lodFailedSkillTaken',
                            params = {
                                ['ab'] = 'DOTA_Tooltip_ability_' .. abilityName
                            }
                        })
                        self:PlayAlert(playerID)
                        return
                    end
                end
            end
        end
    elseif self.optionStore['lodOptionAdvancedUniqueSkills'] == 2 then
        for playerID,theBuild in pairs(self.selectedSkills) do
            for theSlot,theAbility in pairs(theBuild) do
                if theAbility == abilityName then
                    -- Skill is taken
                    network:sendNotification(player, {
                        sort = 'lodDanger',
                        text = 'lodFailedSkillTaken',
                        params = {
                            ['ab'] = 'DOTA_Tooltip_ability_' .. abilityName
                        }
                    })
                    self:PlayAlert(playerID)
                    return
                end
            end
        end
    end

    -- Check for Booster Draft picking phase
    if self.boosterDraftPicking and self.boosterDraftPicking[playerID] then
        if not self.waitForArray[playerID] then
            local nextPlayer = playerID
            repeat
                nextPlayer = nextPlayer + 1
                if nextPlayer > DOTA_MAX_TEAM_PLAYERS-1 then
                    nextPlayer = 0
                end
            until
                PlayerResource:GetConnectionState(nextPlayer) >= 1 and not util:isPlayerBot(nextPlayer)

            self.finalArrays[playerID] = self.finalArrays[playerID] or {}
            self.finalArrays[playerID][abilityName] = true

            self.nextDraftArray[nextPlayer] = util:DeepCopy(self.draftArrays[playerID])
            self.nextDraftArray[nextPlayer].abilityDraft[abilityName] = nil

            local function updateDynamicDraftArray( pID )
                self.draftArrays[pID] = util:DeepCopy(self.nextDraftArray[pID])
                network:setDraftArray(pID, self.draftArrays[pID])

                self.nextDraftArray[pID] = nil
                self.waitForArray[pID] = false

                network:sendNotification(PlayerResource:GetPlayer(pID), {
                    sort = 'lodSuccess',
                    text = 'lodBoosterDraftRound',
                    params = {
                        ['round'] = util:getTableLength(self.finalArrays[pID]) + 1
                    }
                })

                if not self.boosterDraftInitiated then
                    for i=0,DOTA_MAX_TEAM_PLAYERS-1 do
                        self:startBoosterDraftRound(i)
                    end

                    self.boosterDraftInitiated = true
                else
                    self:startBoosterDraftRound( pID )
                end
            end

            if self.waitForArray[nextPlayer] then
                updateDynamicDraftArray( nextPlayer )
            end

            if util:getTableLength(self.finalArrays[playerID]) == 10 then
                local newHeroDraft = {}
                for k,v in pairs(self.allowedHeroes) do
                    newHeroDraft[k] = true
                end
                local newDraftArray = {abilityDraft = self.finalArrays[playerID], heroDraft = newHeroDraft}

                network:setDraftArray(playerID, newDraftArray, true)
                network:setDraftedAbilities(playerID, {})
                self.draftArrays[playerID] = newDraftArray

                self.boosterDraftPicking[playerID] = false

                network:sendNotification(PlayerResource:GetPlayer(playerID), {
                    sort = 'lodSuccess',
                    text = 'lodBoosterDraftEnd'
                })

                network:setCustomEndTimer(PlayerResource:GetPlayer(playerID), Time() + 120, 120)
            elseif self.nextDraftArray[playerID] then
                updateDynamicDraftArray( playerID )
            else
                self.waitForArray[playerID] = true
            end
            network:setDraftedAbilities(playerID, self.finalArrays[playerID])
        else
            network:sendNotification(PlayerResource:GetPlayer(playerID), {
                sort = 'lodDanger',
                text = 'lodBoosterDraftWait'
            })
        end
    else
        -- Is there an actual change?
        if build[slot] ~= abilityName then
            -- New ability in this slot
            build[slot] = abilityName

            -- Should we network it
            if not dontNetwork then
                -- Network it
                network:setSelectedAbilities(playerID, build)
                if OptionManager:GetOption("memesRedux") == 1 then
                    if abilityName == "juggernaut_blade_dance" or abilityName == "juggernaut_blade_fury" or abilityName == "juggernaut_omni_slash"  then
                        EmitGlobalSound("Memes.Swords")
                    elseif abilityName == "alchemist_goblins_greed" or abilityName == "angel_arena_transmute" then
                        EmitGlobalSound("Memes.Rich")
                    elseif abilityName == "ebf_clinkz_trickshot_passive" or abilityName == "imba_tower_multihit" or
                        abilityName == "imba_tower_essence_drain" or
                        abilityName == "angel_arena_rifle_OP" or
                        abilityName == "garden_red_flower_base_OP" or
                        abilityName == "imba_juggernaut_healing_ward_passive_redux" or
                        abilityName == "imba_tower_salvo" or
                        abilityName == "imba_tower_fervor" or
                        abilityName == "imba_tower_split" or
                        abilityName == "imba_tower_machinegun" or
                        abilityName == "imba_tower_sniper" then
                        EmitGlobalSound("Memes.BombTheShit")
                    else
                        EmitGlobalSound("Memes.SnipeHit")
                    end
                else
                    EmitGlobalSound("Event.Click")
                end
            end
        end
    end
end

function Pregame:canPlayerPickSkill()
    if (self:getPhase() == constants.PHASE_INGAME or self:getPhase() == constants.PHASE_REVIEW) and (OptionManager:GetOption('allowIngameHeroBuilder')) then
        return true
    end
    return false
end

-- Player wants to remove an ability
function Pregame:onPlayerRemoveAbility(eventSourceIndex, args)
    -- Grab data

    local playerID = args.PlayerID
    local player = PlayerResource:GetPlayer(playerID)

    -- Ensure we are in the picking phase
    if self:getPhase() ~= constants.PHASE_SELECTION and not self:canPlayerPickSkill() then
        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodFailedWrongPhaseSelection'
        })
        self:PlayAlert(playerID)

        return
    end

    -- Have they locked their skills?
    if self.isReady[playerID] == 1 then
        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodFailedPlayerIsReady'
        })
        self:PlayAlert(playerID)

        return
    end




    local slot = math.floor(tonumber(args.slot))
    -- Is the ability locked to the hero?
    local abName  = self.selectedSkills[playerID][slot]
    local hero = self.selectedHeroes[playerID]

    if hero and GameRules.perks["heroAbilityPairs"][hero] == abName then
        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodHeroAndAbilityAreLocked'
        })
        self:PlayAlert(playerID)
        return
    end


    -- Attempt to remove the ability
    self:removeSelectedAbility(playerID, slot)
end

-- Player wants to select a new ability
function Pregame:onPlayerSelectAbility(eventSourceIndex, args)
    --PrintTable(args)
    -- Grab data
    local playerID = args.PlayerID
    local player = PlayerResource:GetPlayer(playerID)

    -- Ensure we are in the picking phase
    if self:getPhase() ~= constants.PHASE_SELECTION and not self:canPlayerPickSkill() then
        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodFailedWrongPhaseSelection'
        })
        self:PlayAlert(playerID)

        return
    end

    if self:getPhase() == constants.PHASE_SELECTION and self.additionalPickTime then
        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodFailedWrongPhaseSelection'
        })
        self:PlayAlert(playerID)

        return
    end

    -- Have they locked their skills?
    if self.isReady[playerID] == 1 and self:getPhase() ~= constants.PHASE_INGAME then
        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodFailedPlayerIsReady'
        })
        self:PlayAlert(playerID)

        return
    end

    local slot = math.floor(tonumber(args.slot))
    local abilityName = args.abilityName

    -- Is the ability locked to the hero?
    if self.selectedSkills[playerID] then
        local abName  = self.selectedSkills[playerID][slot]
        local hero = self.selectedHeroes[playerID]
        if hero and abName and GameRules.perks["heroAbilityPairs"][hero] == abName then
            network:sendNotification(player, {
                sort = 'lodDanger',
                text = 'lodHeroAndAbilityAreLocked'
            })
            self:PlayAlert(playerID)
            return
        end
    end

    -- Attempt to set the ability
    self:setSelectedAbility(playerID, slot, abilityName)
end

-- Player wants to swap two slots
function Pregame:onPlayerSwapSlot(eventSourceIndex, args)
    -- Ensure we are in the picking phase
    if self:getPhase() ~= constants.PHASE_SELECTION and self:getPhase() ~= constants.PHASE_REVIEW then return end

    -- Grab data
    local playerID = args.PlayerID
    local player = PlayerResource:GetPlayer(playerID)

    local slot1 = math.floor(tonumber(args.slot1))
    local slot2 = math.floor(tonumber(args.slot2))

    local maxSlots = self.optionStore['lodOptionCommonMaxSlots']

    -- Ensure a container for this player exists
    self.selectedSkills[playerID] = self.selectedSkills[playerID] or {}

    local build = self.selectedSkills[playerID]

    -- Ensure they are not the same slot
    if slot1 == slot2 then
        -- Invalid ability name
        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodFailedSwapSlotSameSlot'
        })
        self:PlayAlert(playerID)

        return
    end

    -- Ensure both the slots are valid
    if slot1 < 1 or slot1 > maxSlots or slot2 < 1 or slot2 > maxSlots then
        -- Invalid ability name
        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodFailedSwapSlotInvalidSlots'
        })
        self:PlayAlert(playerID)

        return
    end
    -- Prevent abilities from being swapped
    --[[
    local abName1  = self.selectedSkills[playerID][slot1]
    local abName2 = self.selectedSkills[playerID][slot2]
    local hero = self.selectedHeroes[playerID]

    if hero and (GameRules.perks["heroAbilityPairs"][hero] == abName1 or GameRules.perks["heroAbilityPairs"][hero] == abName2) then
        network:sendNotification(player, {
            sort = 'lodDanger',
            text = 'lodHeroAndAbilityAreLocked'
        })
        self:PlayAlert(playerID)
        return
    end]]

    -- Perform the slot
    local tempSkill = build[slot1]
    build[slot1] = build[slot2]
    build[slot2] = tempSkill

    -- Network it
    network:setSelectedAbilities(playerID, build)
end

-- Returns a random skill for a player, given a build and the slot the skill would be for
-- optionalFilter is a function(abilityName), return true to allow that ability
function Pregame:findRandomSkill(build, slotNumber, playerID, optionalFilter)
    local team = PlayerResource:GetTeam(playerID)

    -- Ensure we have a valid build
    build = build or {}

    -- Table that will contain all possible skills
    local possibleSkills = {}

    -- Grab the limits
    local maxRegulars = self.optionStore['lodOptionCommonMaxSkills']
    local maxUlts = self.optionStore['lodOptionCommonMaxUlts']

    -- Count how many ults
    local totalUlts = 0
    local totalNormal = 0

    for slotID,abilityName in pairs(build) do
        if slotID ~= slotNumber then
            if SkillManager:isUlt(abilityName) then
                totalUlts = totalUlts + 1
            else
                totalNormal = totalNormal + 1
            end
        end
    end

    for abilityName,_ in pairs(self.flagsInverse) do
        -- Do we already have this ability / is this in vilation of our troll combos

        local shouldAdd = true

        -- Prevent certain skills from being randomed
        if self.doNotRandom[abilityName] then
            shouldAdd = false
        end

        -- check OP
        if not self:isAllowed( abilityName ) then
            shouldAdd = false
        end

        if abilityName == 'sandking_caustic_finale' then
            shouldAdd = false
        end

        -- consider ulty count
        if shouldAdd and SkillManager:isUlt(abilityName) then
            if totalUlts >= maxUlts then
                shouldAdd = false
            end
        else
            if totalNormal >= maxRegulars then
                shouldAdd = false
            end
        end

        -- Check draft array
        if self.useDraftArrays then
            local draftID = self:getDraftID(playerID)
            local draftArray = self.draftArrays[draftID] or {}
            local heroDraft = draftArray.heroDraft or {}
            local abilityDraft = draftArray.abilityDraft or {}

            if self.maxDraftHeroes > 0 then
                local heroName = self.abilityHeroOwner[abilityName]

                if not heroDraft[heroName] then
                    shouldAdd = false
                end
            end

            if self.maxDraftSkills > 0 then
                if not abilityDraft[abilityName] then
                    shouldAdd = false
                end
            end
        end


        -- Over the Balance Mode point balance. If bot then skipping
        if self.optionStore['lodOptionBalanceMode'] == 1 then
            if (self.botPlayers and not self.botPlayers.all[playerID]) or not self.botPlayers then
                -- Validate that the user has enough points
                local newBuild = SkillManager:grabNewBuild(build, slotNumber, abilityName)
                local outOfPoints, _ = self:notEnoughPoints(newBuild)
                if outOfPoints then
                    shouldAdd = false
                end
            end
        end


        -- Consider unique skills
        if self.optionStore['lodOptionAdvancedUniqueSkills'] == 1 then
            for playerID,theBuild in pairs(self.selectedSkills) do
                -- Ensure the team matches up
                if team == PlayerResource:GetTeam(playerID) then
                    for theSlot,theAbility in pairs(theBuild) do
                        if theAbility == abilityName then
                            shouldAdd = false
                            break
                        end
                    end
                end
            end
        elseif self.optionStore['lodOptionAdvancedUniqueSkills'] == 2 then
            for playerID,theBuild in pairs(self.selectedSkills) do
                for theSlot,theAbility in pairs(theBuild) do
                    if theAbility == abilityName then
                        shouldAdd = false
                        break
                    end
                end
            end
        end

        -- check bans
        if self.bannedAbilities[abilityName] then
            shouldAdd = false
        end

        for slotNumber,abilityInSlot in pairs(build) do
            if abilityName == abilityInSlot then
                shouldAdd = false
                break
            end

            if self.banList[abilityName] and self.banList[abilityName][abilityInSlot] then
                shouldAdd = false
                break
            end
        end

        if shouldAdd and optionalFilter ~= nil then
            if not optionalFilter(abilityName) then
                shouldAdd = false
            end
        end

        -- Should we add it?
        if shouldAdd then
            table.insert(possibleSkills, abilityName)
        end
    end

    -- Are there any possible skills for this slot?
    if #possibleSkills == 0 then
        return nil
    end

    -- Keep track of how many abilities the player randoms
    local ply = PlayerResource:GetPlayer(playerID)
    if ply then
        if not ply.random then ply.random = 0 end
        ply.random = ply.random + 1
    end

    -- Pick a random skill to return
    return possibleSkills[math.random(#possibleSkills)]
end

-- Sets the stage
function Pregame:setPhase(newPhaseNumber)
    -- Store the current phase
    self.currentPhase = newPhaseNumber

    -- Update the phase for the clients
    network:setPhase(newPhaseNumber)

    -- Ready state should reset
    for k,v in pairs(self.isReady) do
        self.isReady[k] = 0
    end

    -- Network it
    network:sendReadyState(self.isReady)
end

-- Sets when the next phase is going to end
function Pregame:setEndOfPhase(endTime, freezeTimer)
    -- Store the time
    self.endOfTimer = endTime

    -- Network it
    network:setEndOfPhase(endTime)

    -- Should we freeze the timer?
    if freezeTimer then
        self.freezeTimer = freezeTimer
        network:freezeTimer(freezeTimer)
    else
        self.freezeTimer = nil
        network:freezeTimer(-1)
    end
end

-- Returns when the current phase should end
function Pregame:getEndOfPhase()
    return self.endOfTimer
end

-- Returns the current phase
function Pregame:getPhase()
    return self.currentPhase
end

-- Calculates how many players are in the server
function Pregame:getActivePlayers()
    local total = 0

    for i=0,DOTA_MAX_PLAYERS do
        if PlayerResource:GetConnectionState(i) == 2 then
            total = total + 1
        end
    end

    return total
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
                    local sep = dif / (totalMiddleTowers + 1)

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
            --local attacker = EntIndexToHScript( keys.entindex_attacker )

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

function Pregame:multiplyNeutrals()
        ListenToGameEvent('entity_hurt', function(keys)
            local this = self
            --print(OptionManager:GetOption('neutralMultiply'))
            --print(this.optionStore['lodOptionNeutralMultiply'])
            if OptionManager:GetOption('neutralMultiply') == 1 then return end

            -- Grab the entity that was hurt
            local ent = EntIndexToHScript(keys.entindex_killed)
            if keys.entindex_attacker ~= nil then
                attacker = EntIndexToHScript( keys.entindex_attacker )
            end

            if not attacker or not attacker:IsRealHero() then return end

            -- Neutral Multiplier: Checks if hurt npc is neutral, dead, and if it doesnt have the clone token ability, and their is a valid attacker
            if IsValidEntity(attacker) then
                if ent:GetTeamNumber() == DOTA_TEAM_NEUTRALS and ent:GetHealth() <= 0 and ent:GetName() == "npc_dota_creep_neutral" and ent:FindAbilityByName("clone_token_ability") == nil then

                    local lastHits = PlayerResource:GetLastHits(attacker:GetOwner():GetPlayerID())
                    local lastHits = PlayerResource:GetLastHits(attacker:GetOwner():GetPlayerID()) + 1
                    --print(lastHits)
                    self:MultiplyNeutralUnit( ent, attacker, OptionManager:GetOption('neutralMultiply'), lastHits )

                end
            end

        end, nil)
end

function Pregame:multiplyLaneCreeps()
        ListenToGameEvent('entity_hurt', function(keys)
            local this = self
            if this.optionStore['lodOptionLaneMultiply'] == 0 then return end

            -- Grab the entity that was hurt
            local ent = EntIndexToHScript(keys.entindex_killed)
            if keys.entindex_attacker ~= nil then
                attacker = EntIndexToHScript( keys.entindex_attacker )
            end

            -- Neutral Multiplier: Checks if hurt npc is neutral, dead, and if it doesnt have the clone token ability, and their is a valid attacker
            if IsValidEntity(ent) and IsValidEntity(attacker) then
                if ent:GetName() == "npc_dota_creep_lane" and ent:FindAbilityByName("clone_token_ability") == nil then

                    ent:AddAbility("clone_token_ability")
                    self:MultiplyLaneUnit( ent, 2 )

                end
                if attacker:GetName() == "npc_dota_creep_lane" and attacker:FindAbilityByName("clone_token_ability") == nil then

                    attacker:AddAbility("clone_token_ability")
                    self:MultiplyLaneUnit( attacker, 2 )

                end
            end

        end, nil)
end

function Pregame:darkMoonDrops()
        ListenToGameEvent('entity_hurt', function(keys)
            local this = self
            if this.optionStore['lodOptionDarkMoon'] == 0 then return end

            -- Grab the entity that was hurt
            local ent = EntIndexToHScript(keys.entindex_killed)
            if keys.entindex_attacker ~= nil then
                attacker = EntIndexToHScript( keys.entindex_attacker )
            end

            if not attacker or not attacker:IsRealHero() then return end

            -- Neutral Multiplier: Checks if hurt npc is neutral, dead, and if it doesnt have the clone token ability, and their is a valid attacker
            if IsValidEntity(attacker) then
                if ent:GetHealth() <= 0 then
                    local giveBotGold = false

                    local chance = 5

                    -- If its a hero that got killed, it has much higher chance to spawn items
                    if ent:IsRealHero() or ent:IsBuilding() or ent:GetUnitName() == "npc_dota_roshan" then
                        chance = 50
                    end

                    if RollPercentage( chance ) then
                        if util:isPlayerBot(attacker:GetOwner():GetPlayerID()) then
                            -- Bots wont use the TP scrolls, so compenstate them with free gold bag
                            giveBotGold = true
                        else
                            local newItem = CreateItem( "item_tpscroll", nil, nil )
                            newItem:SetPurchaseTime( 0 )
                            if newItem:IsPermanent() and newItem:GetShareability() == ITEM_FULLY_SHAREABLE then
                                item:SetStacksWithOtherOwners( true )
                            end
                            local drop = CreateItemOnPositionSync( ent:GetAbsOrigin(), newItem )
                            drop.Holdout_IsLootDrop = true

                            Timers:CreateTimer(function()
                                if not drop:IsNull() then
                                    UTIL_Remove(drop)
                                end
                                print("tried to remove")
                            end, DoUniqueString('removeitem'), 30)


                            local dropTarget = ent:GetAbsOrigin() + RandomVector( RandomFloat( 50, 350 ) )


                            newItem:LaunchLoot( false, 300, 0.75, dropTarget )
                        end
                    end

                    if RollPercentage( chance ) then
                        local newItem = CreateItem( "item_health_potion", nil, nil )
                        newItem:SetPurchaseTime( 0 )
                        if newItem:IsPermanent() and newItem:GetShareability() == ITEM_FULLY_SHAREABLE then
                            item:SetStacksWithOtherOwners( true )
                        end
                        local drop = CreateItemOnPositionSync( ent:GetAbsOrigin(), newItem )
                        drop.Holdout_IsLootDrop = true

                        local dropTarget = ent:GetAbsOrigin() + RandomVector( RandomFloat( 50, 350 ) )

                        if util:isPlayerBot(attacker:GetOwner():GetPlayerID()) then
                            dropTarget = attacker:GetAbsOrigin()
                        end

                        newItem:LaunchLoot( true, 300, 0.75, dropTarget )
                    end


                    if RollPercentage( chance ) then
                        local newItem = CreateItem( "item_mana_potion", nil, nil )
                        newItem:SetPurchaseTime( 0 )
                        if newItem:IsPermanent() and newItem:GetShareability() == ITEM_FULLY_SHAREABLE then
                            item:SetStacksWithOtherOwners( true )
                        end
                        local drop = CreateItemOnPositionSync( ent:GetAbsOrigin(), newItem )
                        drop.Holdout_IsLootDrop = true

                        local dropTarget = ent:GetAbsOrigin() + RandomVector( RandomFloat( 50, 350 ) )

                        if util:isPlayerBot(attacker:GetOwner():GetPlayerID()) then
                            dropTarget = attacker:GetAbsOrigin()
                        end

                        newItem:LaunchLoot( true, 300, 0.75, dropTarget )
                    end


                    if RollPercentage( chance ) or giveBotGold then
                        local newItem = CreateItem( "item_bag_of_gold", nil, nil )

                        local nGoldAmountBase = 20
                        local nGoldAmountExtra = 20 + attacker:GetLevel()*2
                        local nGoldFinal = RandomInt(nGoldAmountBase, nGoldAmountExtra)
                        nGoldFinal = nGoldFinal * 10

                        -- If this is compenstation for TP scroll give it price of TP scroll
                        if giveBotGold then
                            nGoldFinal = 50 * 10
                        end

                        newItem:SetPurchaseTime( 0 )
                        newItem:SetCurrentCharges( nGoldFinal )

                        local drop = CreateItemOnPositionSync( ent:GetAbsOrigin(), newItem )
                        local dropTarget = ent:GetAbsOrigin() + RandomVector( RandomFloat( 50, 250 ) )

                        if util:isPlayerBot(attacker:GetOwner():GetPlayerID()) then
                            dropTarget = attacker:GetAbsOrigin()
                        end

                        newItem:LaunchLoot( true, 300, 0.75, dropTarget )
                    end

                end
            end

        end, nil)
end

-- Prevents Fountain Camping
function Pregame:preventCamping()
    -- Should we prevent fountain camping?
    if self.optionStore['lodOptionCrazyNoCamping'] == 1 then
        local toAdd = {
            ursa_fury_swipes = 4,
            slark_essence_shift = 4
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

-- Counts how many people on radiant and dire
function Pregame:countRadiantDire()
    local maxplayerID = 24
    local totalRadiant = 0
    local totalDire = 0

    -- Work out how many bots are going to be needed
    for playerID=0,maxplayerID-1 do
        local state = PlayerResource:GetConnectionState(playerID)

        if state ~= 0 then
            if PlayerResource:GetTeam(playerID) == DOTA_TEAM_GOODGUYS then
                totalRadiant = totalRadiant + 1
            elseif PlayerResource:GetTeam(playerID) == DOTA_TEAM_BADGUYS then
                totalDire = totalDire + 1
            end
        end
    end

    return totalRadiant, totalDire
end

-- Adds bot players to the game
function Pregame:addBotPlayers()
    -- Ensure bots should actually be added
    if self.addedBotPlayers then return end
    self.addedBotPlayers = true
    if not self.enabledBots then return end

    -- Settings to determine how many players to place onto each team
    self.desiredRadiant = self.desiredRadiant or 5
    self.desiredDire = self.desiredDire or 5

    -- Adjust the team sizes
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, self.desiredRadiant)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, self.desiredDire)

    -- Grab number of players
    local totalRadiant, totalDire = self:countRadiantDire()

    -- Add bot players
    self.botPlayers = {
        radiant = {},
        dire = {},
        all = {},
        -- Unique skills for teams
        [DOTA_TEAM_GOODGUYS] = {},
        [DOTA_TEAM_BADGUYS] = {},
        -- Unique global skills
        global = {}
    }

    local playerID

    -- Add radiant players
    while totalRadiant < self.desiredRadiant do
        playerID = totalRadiant + totalDire
        totalRadiant = totalRadiant + 1
        Tutorial:AddBot('', '', 'unfair', true)

        local ply = PlayerResource:GetPlayer(playerID)
        if ply then
            local store = {
                ply = ply,
                team = DOTA_TEAM_GOODGUYS,
                ID = playerID
            }

            -- Store this bot player
            self.botPlayers.radiant[playerID] = store
            self.botPlayers.all[playerID] = store

            -- Push them onto the correct team
            PlayerResource:SetCustomTeamAssignment(playerID, DOTA_TEAM_GOODGUYS)
        end
    end

    -- Add dire players
    while totalDire < self.desiredDire do
        playerID = totalRadiant + totalDire
        totalDire = totalDire + 1
        Tutorial:AddBot('', '', 'unfair', false)

        local ply = PlayerResource:GetPlayer(playerID)
        if ply then
            local store = {
                ply = ply,
                team = DOTA_TEAM_BADGUYS,
                ID = playerID
            }

            -- Store this bot player
            self.botPlayers.dire[playerID] = store
            self.botPlayers.all[playerID] = store

            -- Push them onto the correct team
            PlayerResource:SetCustomTeamAssignment(playerID, DOTA_TEAM_BADGUYS)
        end
    end
end

-- Generate builds for bots
function Pregame:generateBotBuilds()
    -- Ensure bots are actually enabled
    if not self.enabledBots then return end

    -- Ensure we have bot players allocated
    if not self.botPlayers.all then return end
    if self.optionStore['lodOptionBotsUniqueSkills'] == 0 then
        self.optionStore['lodOptionBotsUniqueSkills'] = self.optionStore['lodOptionAdvancedUniqueSkills']
    end

    -- Create a table to store bot builds
    --self.botBuilds = {}
    local brokenBots = {}

    -- List of bots that are borked
    if IsInToolsMode() then
        brokenBots = {
            npc_dota_hero_tidehunter = true,
            npc_dota_hero_razor = true,

            -- Stoped working around Feburary, 24, 2017
            npc_dota_hero_skywrath_mage = true,
            npc_dota_hero_nevermore = true,
            npc_dota_hero_pudge = true,
            npc_dota_hero_phantom_assassin = true,

            --[[npc_dota_hero_sven = true,
            npc_dota_hero_skeleton_king = true,
            npc_dota_hero_lina = true,
            npc_dota_hero_luna = true,
            npc_dota_hero_dragon_knight = true,
            npc_dota_hero_bloodseeker = true,
            npc_dota_hero_lion = true,
            npc_dota_hero_tiny = true,
            npc_dota_hero_oracle = true,]]
        }
    else
        brokenBots = {
            npc_dota_hero_tidehunter = true,
            npc_dota_hero_razor = true,
            npc_dota_hero_pudge = true,

            -- Stoped working around Feburary, 24, 2017
            --[[npc_dota_hero_sven = true,
            npc_dota_hero_skeleton_king = true,
            npc_dota_hero_lina = true,
            npc_dota_hero_luna = true,
            npc_dota_hero_dragon_knight = true,
            npc_dota_hero_bloodseeker = true,
            npc_dota_hero_lion = true,
            npc_dota_hero_tiny = true,
            npc_dota_hero_oracle = true,]]
        }

    end

    local ignoreAbilities = {
        zuus_cloud = true
    }

    -- Generate a list of possible heroes
    local possibleHeroes = {}
    for k,v in pairs(self.botHeroes) do
        if not self.bannedHeroes[k] and not brokenBots[k] then
            table.insert(possibleHeroes, k)
        end
    end

    -- Max number of slots to aim for
    local maxSlots = self.optionStore['lodOptionCommonMaxSlots']

    local botSkills = util:sortTable(LoadKeyValues('scripts/kv/bot_skills.kv'))
    self.uniqueSkills = LoadKeyValues('scripts/kv/unique_skills.kv')
    local lastTeam = nil
    self.isTeamReady = {
        DOTA_TEAM_BADGUYS = false,
        DOTA_TEAM_GOODGUYS = false
    }

    local forceBotHeroes = {
        -- npc_dota_hero_nevermore = true
    }

    for playerID,botInfo in pairs(self.botPlayers.all) do
        local build = {}
        local skillID = 1
        local heroName = 'npc_dota_hero_pudge'
        if #possibleHeroes > 0 then
            if util:getTableLength(forceBotHeroes) > 0 then
                for k,v in pairs(forceBotHeroes) do
                    if v == true then
                        heroName = k
                        forceBotHeroes[k] = nil
                    end
                end
            else
                heroName = table.remove(possibleHeroes, math.random(#possibleHeroes))
            end
        end

        -- Generate build
        local build = {}
        local skillID = 1
        local defaultSkills = self.botHeroes[heroName]
        if defaultSkills then
            for _, abilityName in pairs(defaultSkills) do
                if (self.flagsInverse[abilityName] or self.uniqueSkills['replaced_skills'][abilityName]) and not ignoreAbilities[abilityName] then
                    local newAb = self.uniqueSkills['replaced_skills'][abilityName] and self.uniqueSkills['replaced_skills'][abilityName] or abilityName
                    build[skillID] = newAb
                    skillID = skillID + 1
                end
            end
        end
        botInfo.heroName = heroName
        botInfo.skillID = skillID
        botInfo.build = build
    end

    local teams = {self.botPlayers.radiant, self.botPlayers.dire}
    ShuffleArray(teams)

    while true do
        for _, botTeam in pairs(teams) do
            for i,botInfo in pairs(botTeam) do
                local oppositeTeam = botInfo.team == DOTA_TEAM_BADGUYS and DOTA_TEAM_GOODGUYS or DOTA_TEAM_BADGUYS
                if not botInfo.isDone and (not lastTeam or botInfo.team ~= lastTeam or self.isTeamReady[oppositeTeam] or self:isTeamBotReady(oppositeTeam)) then
                    self:getSkillforBot(botInfo, botSkills)
                    lastTeam = botInfo.team
                    local temp = table.remove(botTeam, i)
                    table.insert(botTeam, temp)
                    break
                end
            end
        end
        if self:isTeamBotReady(DOTA_TEAM_GOODGUYS) and self:isTeamBotReady(DOTA_TEAM_BADGUYS) then
            break
        end
    end
end

function Pregame:getSkillforBot( botInfo, botSkills )
    local playerID = botInfo.ID
    local maxSlots = self.optionStore['lodOptionCommonMaxSlots']

    if self.optionStore['lodOptionBotsRestrict'] > 0 then
        if self.optionStore['lodOptionBotsRestrict'] == 1 and PlayerResource:GetTeam(playerID) == DOTA_TEAM_GOODGUYS then
            maxSlots = 4
        elseif self.optionStore['lodOptionBotsRestrict'] == 2 and PlayerResource:GetTeam(playerID) == DOTA_TEAM_BADGUYS then
            maxSlots = 4
        elseif self.optionStore['lodOptionBotsRestrict'] == 3 then
            maxSlots = 4
        end
    end

    local build = botInfo.build or {}
    local skillID = botInfo.skillID or 1
    local heroName = botInfo.heroName
    local skills = botSkills[heroName]
    local isAdded

    customSlots = {
        npc_dota_hero_nevermore = 8
    }

    if customSlots[heroName] then
        maxSlots = customSlots[heroName]
    end

    if skills then
        for k, abilityName in pairs(skills) do
            if skillID > maxSlots then break end
            if self.flagsInverse[abilityName] and self:isValidSkill(build, playerID, abilityName, skillID) then
                local team = PlayerResource:GetTeam(playerID)
                -- Default
                if self.optionStore['lodOptionBotsUniqueSkills'] == 0 then
                    build[skillID] = abilityName
                    skillID = skillID + 1
                    isAdded = true
                -- Team
                elseif self.optionStore['lodOptionBotsUniqueSkills'] == 1 and not self.botPlayers[team][abilityName] then
                    build[skillID] = abilityName
                    skillID = skillID + 1
                    self.botPlayers[team][abilityName] = true
                    isAdded = true
                -- Global
                elseif self.optionStore['lodOptionBotsUniqueSkills'] == 2 and not self.botPlayers.global[abilityName] then
                    build[skillID] = abilityName
                    skillID = skillID + 1
                    self.botPlayers.global[abilityName] = true
                    isAdded = true
                end
                table.remove(botSkills[heroName], k)
                if isAdded then
                    botInfo.build = build
                    botInfo.skillID = skillID
                    return true
                end
            end
        end
    end
    -- Allocate more abilities
    while skillID <= maxSlots do
        -- Attempt to pick a high priority skill, otherwise pick any passive, otherwise pick any
        local newAb = self:findRandomSkill(build, skillID, playerID, function(abilityName)
            return SkillManager:isPassive(abilityName)
        end) or self:findRandomSkill(build, skillID, playerID)

        if newAb ~= nil then
            build[skillID] = newAb
            skillID = skillID + 1
        end
    end
    if not botInfo.isDone then
        -- Shuffle their build to make it look like a random set. Currently disabled, uncomment below to renable it.
        -- ShuffleArray(build)

        -- Are there any premade builds?

        if self.premadeBotBuilds then
            if botInfo.team == DOTA_TEAM_BADGUYS and self.premadeBotBuilds.dire and #self.premadeBotBuilds.dire > 0 then
                local info = table.remove(self.premadeBotBuilds.dire, 1)
                build = info.build
                heroName = info.heroName
            end

            if botInfo.team == DOTA_TEAM_GOODGUYS and self.premadeBotBuilds.radiant and #self.premadeBotBuilds.radiant > 0 then
                local info = table.remove(self.premadeBotBuilds.radiant, 1)
                build = info.build
                heroName = info.heroName
            end
        end

        -- Store the info
        botInfo.build = build
        botInfo.heroName = heroName
        botInfo.isDone = true
        self.isTeamReady[botInfo.team] = self:isTeamBotReady(botInfo.team)

        -- Network their build
        self:setSelectedHero(playerID, heroName, true)
        self.selectedSkills[playerID] = build
        network:setSelectedAbilities(playerID, build)
        return true
    end
end


function Pregame:isTeamBotReady( team )
    local maxSlots = self.optionStore['lodOptionCommonMaxSlots']
    local array = team == DOTA_TEAM_GOODGUYS and self.botPlayers.radiant or team == DOTA_TEAM_BADGUYS and self.botPlayers.dire
    if #array == 0 then return true end
    if array then
        for _,botInfo in pairs(array) do
            if not botInfo.isDone then
                return false
            end
        end
        return true
    end
    return false
end


function Pregame:isValidSkill( build, playerID, abilityName, slotNumber )
    local team = PlayerResource:GetTeam(playerID)

    -- Ensure we have a valid build
    build = build or {}

    -- Grab the limits
    local maxRegulars = self.optionStore['lodOptionCommonMaxSkills']
    local maxUlts = self.optionStore['lodOptionCommonMaxUlts']

    -- Count how many ults
    local totalUlts = 0
    local totalNormal = 0

    for _,theAbility in pairs(build) do
        if SkillManager:isUlt(theAbility) then
            totalUlts = totalUlts + 1
        else
            totalNormal = totalNormal + 1
        end
    end

    -- consider ulty count
    if SkillManager:isUlt(abilityName) then
        if totalUlts >= maxUlts then
            return false
        end
    else
        if totalNormal >= maxRegulars then
            return false
        end
    end

    -- Check draft array
    if self.useDraftArrays then
        local draftID = self:getDraftID(playerID)
        local draftArray = self.draftArrays[draftID] or {}
        local heroDraft = draftArray.heroDraft or {}
        local abilityDraft = draftArray.abilityDraft or {}

        if self.maxDraftHeroes > 0 then
            local heroName = self.abilityHeroOwner[abilityName]

            if not heroDraft[heroName] then
                return false
            end
        end

        if self.maxDraftSkills > 0 then
            if not abilityDraft[abilityName] then
                return false
            end
        end
    end


    -- Over the Balance Mode point balance
    -- Commented out so bots do not obey balance mode rules
   --[[ if self.optionStore['lodOptionBalanceMode'] == 1 then
        -- Validate that the user has enough points
        local newBuild = SkillManager:grabNewBuild(build, slotNumber, abilityName)
        local outOfPoints, _ = self:notEnoughPoints(newBuild)
        if outOfPoints then
            return false
        end
    end]]--


    -- Consider unique skills
    if self.optionStore['lodOptionAdvancedUniqueSkills'] == 1 then
        for playerID,theBuild in pairs(self.selectedSkills) do
            -- Ensure the team matches up
            if team == PlayerResource:GetTeam(playerID) then
                for theSlot,theAbility in pairs(theBuild) do
                    if theAbility == abilityName then
                        return false
                    end
                end
            end
        end
    elseif self.optionStore['lodOptionAdvancedUniqueSkills'] == 2 then
        for playerID,theBuild in pairs(self.selectedSkills) do
            for theSlot,theAbility in pairs(theBuild) do
                if theAbility == abilityName then
                    return false
                end
            end
        end
    end

    -- check bans
    if self.bannedAbilities[abilityName] then
        return false
    end

    for slotNumber,abilityInSlot in pairs(build) do
        if abilityName == abilityInSlot then
            return false
        end

        if self.banList[abilityName] and self.banList[abilityName][abilityInSlot] then
            return false
        end
    end

    return true
end

-- Use free ability points
function Pregame:levelUpAbilities(hero)
    local points = hero:GetAbilityPoints()

    local upgrades = 0

    if points >= 1 then
        for p=1,points do
            for i = 0, 23 do
                if upgrades >= points then
                    break
                end

                if hero:GetAbilityByIndex(i) then
                    local ability = hero:GetAbilityByIndex(i)
                    local function attemptUpgrade( ability )
                        if ability and ability:GetLevel() < ability:GetMaxLevel() and not ability:IsHidden() and not string.match(ability:GetName(), "special") and upgrades < points then
                            ability:UpgradeAbility(false)
                            upgrades = upgrades + 1
                            attemptUpgrade( ability )
                        end
                    end
                    attemptUpgrade( ability )
                end
            end
        end

        hero:SetAbilityPoints(points - upgrades)
    end
end

-- Spawns bots
function Pregame:hookBotStuff()
    -- Ensure bots are actually enabled
    if not self.enabledBots or self.hookedBotStuff then
        self.hookedBotStuff = true
        return
    end

    -- Grab a reference to self
    local this = self

    -- Auto level bot skills (bots will get 2 ability points per level)
    ListenToGameEvent('dota_player_gained_level', function(keys)
        local playerID = keys.player - 1
        local level = keys.level

        -- Is this player a bot?
        if PlayerResource:GetConnectionState(playerID) == 1 then
            Timers:CreateTimer(function ()
                local hero = PlayerResource:GetSelectedHeroEntity(playerID)
                if IsValidEntity(hero) then
                    local build = this.selectedSkills[playerID]

                    local heroName = hero:GetClassname()
                    local defaultSkills = {}
                    for k,abilityName in pairs(this.botHeroes[heroName] or {}) do
                        defaultSkills[abilityName] = true
                    end

                    local lowestLevel = 25
                    local lowestAb

                    for k,abilityName in pairs(build) do
                        -- We are not going to touch hero default skills
                        if not defaultSkills[abilityName] then
                            local ab = hero:FindAbilityByName(abilityName)
                            if ab then
                                local abLevel = ab:GetLevel()

                                -- Has it already hit it's max level?
                                if abLevel < ab:GetMaxLevel() then
                                    -- Work out what level we need to be to legally skill this ability
                                    local nextUpgrade = abLevel * 2 + 1
                                    if SkillManager:isUlt(abilityName) then
                                        nextUpgrade = 6 + 5 * abLevel
                                    end

                                    -- Can we legally skill this ability?
                                    if nextUpgrade <= level then
                                        -- Is this the lowest level skill?
                                        if abLevel < lowestLevel then



                                            lowestLevel = abLevel
                                            lowestAb = ab
                                        end
                                    end
                                end
                            end
                        end
                    end

                    -- Apply the point
                    if lowestAb ~= nil then
                        lowestAb:SetLevel(lowestLevel + 1)
                    end

                    -- Leveling the talents for bots
                    if keys.level == 10 then
                        for i=1,23 do
                            local ab = hero:GetAbilityByIndex(i)
                            if ab and string.find(ab:GetAbilityName(), "special_bonus") then
                                local random = RandomInt(0,1)
                                hero:GetAbilityByIndex(i+random):UpgradeAbility(true)
                                break
                            end
                        end
                    elseif keys.level == 15 then
                        for i=1,23 do
                            local ab = hero:GetAbilityByIndex(i)
                            if ab and string.find(ab:GetAbilityName(), "special_bonus") then
                                local random = RandomInt(2,3)
                                hero:GetAbilityByIndex(i+random):UpgradeAbility(true)
                                break
                            end
                        end

                    elseif keys.level == 20 then
                        for i=1,23 do
                            local ab = hero:GetAbilityByIndex(i)
                            if ab and string.find(ab:GetAbilityName(), "special_bonus") then
                                local random = RandomInt(4,5)
                                hero:GetAbilityByIndex(i+random):UpgradeAbility(true)
                                break
                            end
                        end

                    elseif keys.level == 25 then
                        for i=1,23 do
                            local ab = hero:GetAbilityByIndex(i)
                            if ab and string.find(ab:GetAbilityName(), "special_bonus") then
                                local random = RandomInt(6,7)
                                hero:GetAbilityByIndex(i+random):UpgradeAbility(true)
                                break
                            end
                        end
                    end

                    self:levelUpAbilities(hero)
                end
            end, DoUniqueString('levelUpTalents'), 2.0)
        end
    end, nil)
end

-- This function gets runned when heros are recreated with there proper abilities, below is a function that runs at every npc spawn
function Pregame:fixSpawnedHero( spawnedUnit )
    self.givenBonuses = self.givenBonuses or {}
    self.handled = self.handled or {}
    self.givenCouriers = self.givenCouriers or {}
    local allHeroes = LoadKeyValues('scripts/npc/npc_heroes.txt')
    local npc_abilities_override = LoadKeyValues('scripts/npc/npc_abilities_override.txt')

    -- Don't touch this hero more than once :O
    if self.handled[spawnedUnit] then return end
    self.handled[spawnedUnit] = true

    -- Grab a reference to self
    local this = self

    local notOnIllusions = {
        lone_druid_spirit_bear = true,
        necronomicon_warrior_last_will_lod = true,
        roshan_bash = true,
    }

    local botAIModifier = {
        slark_shadow_dance = true,
        alchemist_chemical_rage = true,
        --rattletrap_rocket_flare = true,
    }

    local disabledPerks = {
        npc_dota_hero_windrunner = false,
        npc_dota_hero_shadow_demon = true,
        -- npc_dota_hero_spirit_breaker = true,
        --npc_dota_hero_spirit_slardar = true,
        -- npc_dota_hero_chaos_knight = true,
        --npc_dota_hero_wisp = true
    }

    -- Grab their playerID
    local playerID = spawnedUnit:GetPlayerID()

    local mainHero = PlayerResource:GetSelectedHeroEntity(playerID)

    if mainHero and mainHero:IsRealHero() then
        self:applyPrimaryAttribute(playerID, mainHero)
    end

    -- Add talents
    if IsValidEntity(spawnedUnit) and not spawnedUnit.hasTalent then
        local nameTest = spawnedUnit:GetName()
        local heroValues = allHeroes[nameTest]
        if heroValues then
            local heroTalentList = {}

            local function GetRandomHero()
                local keys = {}
                for k in pairs(allHeroes) do
                    table.insert(keys, k)
                end
                return allHeroes[keys[RandomInt(1, #keys)]]
            end

            local build = self.selectedSkills[playerID]
            local function VerifyTalent(abName)
                for _,v in pairs(heroTalentList) do
                    if string.find(abName, "special_bonus_unique_") and string.find(v, "special_bonus_unique_") then
                        if v == abName then return false end
                    elseif v:gsub('special_bonus_', ''):gsub('_%d+', '') == abName:gsub('special_bonus_', ''):gsub('_%d+', '') then
                        return false
                    end
                end
                local requiredAbility = util:getAbilityKV(abName, "TalentRequiredAbility")
                if not requiredAbility then
                    return true
                end
                for _, v in ipairs(build) do
                    if v == requiredAbility then
                        return true
                    end
                end
                return false
            end

            local replacedHeroNames = {
                npc_dota_hero_underlord = "npc_dota_hero_abyssal_underlord",
                npc_dota_hero_zeus = "npc_dota_hero_zuus",
                npc_dota_hero_nyx = "npc_dota_hero_nyx_assassin",
                npc_dota_hero_wraith_king = "npc_dota_hero_skeleton_king",
                npc_dota_hero_magnus = "npc_dota_hero_magnataur",
                npc_dota_hero_clockwerk = "npc_dota_hero_rattletrap",
                npc_dota_hero_doom = "npc_dota_hero_doom_bringer",
                npc_dota_hero_windranger = "npc_dota_hero_windrunner",
                npc_dota_hero_necrophos = "npc_dota_hero_necrolyte",
                npc_dota_hero_skywrath = "npc_dota_hero_skywrath_mage",
                npc_dota_hero_timbersaw = "npc_dota_hero_shredder",
                npc_dota_hero_outworld_devourer = "npc_dota_hero_obsidian_destroyer",
                npc_dota_hero_lifestelaer = "npc_dota_hero_life_stealer",
                npc_dota_hero_queen_of_pain = "npc_dota_hero_queenofpain",
                npc_dota_hero_vengeful_spirit = "npc_dota_hero_vengefulspirit",
            }
            local function GetTalentGroup(targetTalent, heroData)
                local heroName = targetTalent:gsub('special_bonus_unique', 'npc_dota_hero'):gsub('_%d', '')
                if replacedHeroNames[heroName] then heroName = replacedHeroNames[heroName] end

                if not heroData then
                    heroData = allHeroes[heroName]
                end
                if not heroData then
                    print("Error: hero with name " .. heroName .. " wasn't found. That hero name should be replaced above.")
                    return 4
                end
                local skippedTalentsCount = 0
                for i = 1, 24 do
                    local abName = heroData['Ability' .. i]
                    if abName and string.find(abName, 'special_bonus') then
                        if abName == targetTalent then
                            return math.ceil((skippedTalentsCount + 1) / 2)
                        else
                            skippedTalentsCount = skippedTalentsCount + 1
                        end
                    end
                end

                print("Error: hero " .. heroName .. " hasn't talent " .. targetTalent)
                return 4
            end

            --Load talents from kv and calculate total count
            local currentTalentCount = 0
            local skippedTalentCount = 0
            for i = 1, 24 do
                local abName = heroValues['Ability' .. i]
                if abName and string.find(abName, "special_bonus") then
                    local talentIndex = currentTalentCount + skippedTalentCount + 1
                    if VerifyTalent(abName) then
                        heroTalentList[talentIndex] = abName
                        currentTalentCount = currentTalentCount + 1
                    else
                        skippedTalentCount = skippedTalentCount + 1
                    end
                end
            end

            --If hero hasn't enought talents => random
            if currentTalentCount < 8 then
                print("[Talents]: Hero has " .. 8-currentTalentCount .. " empty talent slots. These talents should be randomed")
                --First try to find talents that requires hero's abilities

                -- try
                local status, nextCall = xpcall(function()
                    for k, v in pairs(npc_abilities_override) do
                        --Ability is talent
                        if string.find(k, 'special_bonus_unique_') and v.TalentRequiredAbility then
                            --If current build has required ability
                            local targetIndex = GetTalentGroup(k) * 2
                            if heroTalentList[targetIndex] then targetIndex = targetIndex - 1 end

                            if VerifyTalent(k) and not heroTalentList[targetIndex] then
                                heroTalentList[targetIndex] = k
                                currentTalentCount = currentTalentCount + 1
                                if currentTalentCount >= 8 then
                                    break
                                end
                            end
                        end
                    end
                -- catch
                end, function (msg)
                    return msg..'\n'..debug.traceback()..'\n'
                end)
                if not status then
                    print(nextCall)
                end
                print("[Talents]: After giving ability unique talens hero has " .. 8-currentTalentCount .. " empty talent slots")
                --If hero still hasn't 8 talents => take random talents
                while currentTalentCount < 8 do
                    --take random hero
                    local tempHT = GetRandomHero()
                    if type(tempHT) == "table" then
                        local skippedTalentsCount = 0
                        for i = 1, 24 do
                            local abName = tempHT['Ability' .. i]
                            if abName and string.find(abName, "special_bonus") then
                                local targetIndex = math.ceil((skippedTalentsCount + 1) / 2) * 2
                                if heroTalentList[targetIndex] then targetIndex = targetIndex - 1 end

                                if VerifyTalent(abName) and not heroTalentList[targetIndex] then
                                    heroTalentList[targetIndex] = abName
                                    currentTalentCount = currentTalentCount + 1
                                    break -- to increase randomness take a new hero after each added talent
                                else
                                    skippedTalentsCount = skippedTalentsCount + 1
                                end
                            end
                        end
                    end
                end
            end
            for _,v in pairs(heroTalentList) do
                spawnedUnit:AddAbility(v)
            end

            --0 index talent, move it to end
            local first_talent = spawnedUnit:GetAbilityByIndex(0):GetAbilityName()
            if string.find(first_talent, "special_bonus") then
                spawnedUnit:RemoveAbility(first_talent)
                spawnedUnit:AddAbility(first_talent)
            end
        end
        spawnedUnit.hasTalent = true
    end

    -- Various Fixes
    Timers:CreateTimer(function()
        if IsValidEntity(spawnedUnit) then
            -- Silencer Fix NEEDS TO BE RUN EVERY SPAWN (below), AND ON FIXEDHERO FUNCTION
                if spawnedUnit:HasAbility('silencer_glaives_of_wisdom_steal') then
                    if not spawnedUnit:HasModifier('modifier_silencer_int_steal') then
                        spawnedUnit:AddNewModifier(spawnedUnit, spawnedUnit:FindAbilityByName("silencer_glaives_of_wisdom_steal"), 'modifier_silencer_int_steal', {})
                    end
                else
                    spawnedUnit:RemoveModifierByName('modifier_silencer_int_steal')
                end
            -- Stalker Innate Auto-Level
            if spawnedUnit:HasAbility('night_stalker_innate_redux') then
                local stalkerInnate = spawnedUnit:FindAbilityByName('night_stalker_innate_redux')
                if stalkerInnate then
                    if stalkerInnate:GetLevel() ~= 1 then
                        stalkerInnate:UpgradeAbility(false)
                    end
                end
            end

            -- KOTL Innate Auto-Level
            if spawnedUnit:HasAbility('keeper_of_the_light_innate_redux') then
                local kotlInnate = spawnedUnit:FindAbilityByName('keeper_of_the_light_innate_redux')
                if kotlInnate then
                    if kotlInnate:GetLevel() ~= 1 then
                        kotlInnate:UpgradeAbility(false)
                    end
                end
            end

            -- 'No Charges' fix for Gyro Homing Missle
            if spawnedUnit:HasAbility('gyrocopter_homing_missile') then
                Timers:CreateTimer(function()
                    -- If the hero has the charges perk, and they have a level in it, check if they have modifier, if not, add it
                    local chargesModifier = spawnedUnit:FindAbilityByName("special_bonus_unique_gyrocopter_1")
                    if chargesModifier and chargesModifier:GetLevel() > 0 then
                        if not spawnedUnit:FindModifierByName("modifier_gyrocopter_homing_missile_charge_counter") then
                            spawnedUnit:AddNewModifier(spawnedUnit,nil,"modifier_gyrocopter_homing_missile_charge_counter",{duration = duration})
                        end
                    else
                        -- If Hero has homing missle ability, it doesnt have the talent or doesnt have a level in it, and it has the modifier, remove modifier
                        if spawnedUnit:FindModifierByName("modifier_gyrocopter_homing_missile_charge_counter") then
                            spawnedUnit:RemoveModifierByName("modifier_gyrocopter_homing_missile_charge_counter")
                        end
                    end
                end, DoUniqueString('gyroFix'), 1)
            end

            -- Change sniper assassinate to our custom version to work with aghs
            if spawnedUnit:HasAbility("sniper_assassinate") and not util:isPlayerBot(playerID) and not spawnedUnit:FindAbilityByName("sniper_assassinate"):IsHidden() then
                    spawnedUnit:AddAbility("sniper_assassinate_redux")
                    spawnedUnit:SwapAbilities("sniper_assassinate","sniper_assassinate_redux",false,true)
                    spawnedUnit:RemoveAbility("sniper_assassinate")
            end
            -- Change juxtapose to juxtapose ranged, for ranged heros
            if spawnedUnit:HasAbility("phantom_lancer_juxtapose_melee") and spawnedUnit:IsRangedAttacker() then
                    spawnedUnit:AddAbility("phantom_lancer_juxtapose_ranged")
                    spawnedUnit:SwapAbilities("phantom_lancer_juxtapose_melee","phantom_lancer_juxtapose_ranged",false,true)
                    spawnedUnit:RemoveAbility("phantom_lancer_juxtapose_melee")
            end
            -- Change Feast to Feast ranged, for ranged heros
            if spawnedUnit:HasAbility("life_stealer_feast_melee") and spawnedUnit:IsRangedAttacker() then
                    spawnedUnit:AddAbility("life_stealer_feast_ranged")
                    spawnedUnit:SwapAbilities("life_stealer_feast_melee","life_stealer_feast_ranged",false,true)
                    spawnedUnit:RemoveAbility("life_stealer_feast_melee")
            end

            if spawnedUnit:HasAbility("monkey_king_jingu_mastery_lod_melee") and spawnedUnit:IsRangedAttacker() then
                    spawnedUnit:AddAbility("monkey_king_jingu_mastery_lod_ranged")
                    spawnedUnit:SwapAbilities("monkey_king_jingu_mastery_lod_melee","monkey_king_jingu_mastery_lod_ranged",false,true)
                    spawnedUnit:RemoveAbility("monkey_king_jingu_mastery_lod_melee")
            end

            -- Change Overpower to Overpower ranged, for ranged heros
            if spawnedUnit:HasAbility("ursa_overpower_melee") and spawnedUnit:IsRangedAttacker() then
                    spawnedUnit:AddAbility("ursa_overpower_ranged")
                    spawnedUnit:SwapAbilities("ursa_overpower_melee","ursa_overpower_ranged",false,true)
                    spawnedUnit:RemoveAbility("ursa_overpower_melee")
            end

            if spawnedUnit:HasAbility("phantom_assassin_coup_de_grace_melee") and spawnedUnit:IsRangedAttacker() then
                    spawnedUnit:AddAbility("phantom_assassin_coup_de_grace_ranged")
                    spawnedUnit:SwapAbilities("phantom_assassin_coup_de_grace_melee","phantom_assassin_coup_de_grace_ranged",false,true)
                    spawnedUnit:RemoveAbility("phantom_assassin_coup_de_grace_melee")
            end

            -- Custom Flesh Heap fixes
            for abilitySlot=0,6 do
                local abilityTemp = spawnedUnit:GetAbilityByIndex(abilitySlot)
                if abilityTemp then
                    if string.find(abilityTemp:GetAbilityName(),"flesh_heap_") then
                        local abilityName = abilityTemp:GetAbilityName()
                        local modifierName = "modifier"..string.sub(abilityName,6)
                        spawnedUnit:AddNewModifier(spawnedUnit,abilityTemp,modifierName,{})

                    end
                end
            end
        end
    end, DoUniqueString('variousFixes'), 0.5)

     -- Add hero perks
    Timers:CreateTimer(function()
        if spawnedUnit:IsNull() then
            return
        end
        local nameTest = spawnedUnit:GetName()
        if IsValidEntity(spawnedUnit) and not self.perksDisabled and not spawnedUnit.hasPerk and not disabledPerks[nameTest] then
           local perkName = spawnedUnit:GetName() .. "_perk"
           local perk = spawnedUnit:AddAbility(perkName)
           local perkModifier = "modifier_" .. perkName
           if perk then perk:SetLevel(1) end
           spawnedUnit:AddNewModifier(spawnedUnit, perk, perkModifier, {})
           spawnedUnit.hasPerk = true
           --print("Perk assigned")
        end
    end, DoUniqueString('addPerk'), 0.75)

    -- Are they a bot?
    Timers:CreateTimer(function()
        if PlayerResource:GetConnectionState(playerID) == 1 then
            -- Find custom abilities to add AI modifiers
            for k,abilityName in pairs(this.selectedSkills[playerID]) do
                if botAIModifier[abilityName] then
                    abModifierName = "modifier_" .. abilityName .. "_ai"
                    spawnedUnit:AddNewModifier(spawnedUnit, nil, abModifierName, {})
                end
            end

            for i=0,23 do
                local ab = spawnedUnit:GetAbilityByIndex(i)
                if ab and not string.match(ab:GetName(), "special") and not string.match(ab:GetName(), "perk") and customSlots[spawnedUnit:GetUnitName()] then
                    ab:SetHidden(false)
                end
            end
        end
    end, DoUniqueString('addBotAI'), 1.0)

    -- Toolsmode developer stuff to help test
    if IsInToolsMode() then
        -- If setting is 1, everyone gets free scepter modifier, if its 2, only human players get the upgrade
        Timers:CreateTimer(function()
                if IsValidEntity(spawnedUnit) then
                    if not util:isPlayerBot(playerID) then
                        local devDagger = spawnedUnit:FindItemByName("item_devDagger")
                        local normalDagger = spawnedUnit:FindItemByName("item_blink")
                        if not devDagger and not normalDagger then
                            Say(spawnedUnit:GetPlayerOwner(), "-dagger", false)

                        elseif not devDagger and normalDagger then
                            normalDagger:RemoveSelf()
                            Say(spawnedUnit:GetPlayerOwner(), "-dagger", false)
                        end

                    end
                end
        end, DoUniqueString('giveDagger'), 1)
    end

    -- Handle free scepter stuff
    if OptionManager:GetOption('freeScepter') ~= 0 then
        -- If setting is 1, everyone gets free scepter modifier, if its 2, only human players get the upgrade
        if OptionManager:GetOption('freeScepter') == 1 or (OptionManager:GetOption('freeScepter') == 2 and not util:isPlayerBot(playerID))  then
            spawnedUnit:AddNewModifier(spawnedUnit, nil, 'modifier_item_ultimate_scepter_consumed', {
                bonus_all_stats = 0,
                bonus_health = 0,
                bonus_mana = 0
            })
         end
    end

    -- Give out the global cast range ability
    if OptionManager:GetOption('globalCastRange') == 1 then
        Timers:CreateTimer(function()
                if IsValidEntity(spawnedUnit) then
                    -- If hero is not earthshaker or pudge, give ability, or if the hero is not a bot, give the ability.
                    if util:isPlayerBot(playerID) == false then
                        local globalCastRangeAbility = spawnedUnit:AddAbility("aether_range_lod_global")
                        globalCastRangeAbility:UpgradeAbility(true)
                    elseif spawnedUnit:GetUnitName() ~= "npc_dota_hero_earthshaker" and spawnedUnit:GetUnitName() ~= "npc_dota_hero_pudge" then
                        local globalCastRangeAbility = spawnedUnit:AddAbility("aether_range_lod_global")
                        globalCastRangeAbility:UpgradeAbility(true)
                    end
                end
            end, DoUniqueString('giveGlobalCastRange'), 1)
    end

    -- Give out the free extra abilities
    if OptionManager:GetOption('extraAbility') > 0 then
        Timers:CreateTimer(function()
            local fleshHeapToGive = nil
            local essenceshiftToGive = nil
            local rangedTrickshot = nil

            if OptionManager:GetOption('extraAbility') == 5 then

                local random = RandomInt(1,10)
                local givenAbility = false
                -- Randomly choose which flesh heap to give them
                if random == 1 and not spawnedUnit:HasAbility('pudge_flesh_heap') then fleshHeapToGive = "pudge_flesh_heap" ; givenAbility = true
                elseif random == 2 and not spawnedUnit:HasAbility('pudge_flesh_heap_int') then fleshHeapToGive = "pudge_flesh_heap_int" ; givenAbility = true
                elseif random == 3 and not spawnedUnit:HasAbility('pudge_flesh_heap_agility') then fleshHeapToGive = "pudge_flesh_heap_agility" ; givenAbility = true
                elseif random == 4 and not spawnedUnit:HasAbility('pudge_flesh_heap_move_speed') then fleshHeapToGive = "pudge_flesh_heap_move_speed" ; givenAbility = true
                elseif random == 5 and not spawnedUnit:HasAbility('pudge_flesh_heap_spell_amp') then fleshHeapToGive = "pudge_flesh_heap_spell_amp" ; givenAbility = true
                elseif random == 6 and not spawnedUnit:HasAbility('pudge_flesh_heap_attack_range') then fleshHeapToGive = "pudge_flesh_heap_attack_range" ; givenAbility = true
                elseif random == 7 and not spawnedUnit:HasAbility('pudge_flesh_heap_bonus_vision') then fleshHeapToGive = "pudge_flesh_heap_bonus_vision" ; givenAbility = true
                elseif random == 8 and not spawnedUnit:HasAbility('pudge_flesh_heap_cooldown_reduction') then fleshHeapToGive = "pudge_flesh_heap_cooldown_reduction" ; givenAbility = true
                elseif random == 9 and not spawnedUnit:HasAbility('pudge_flesh_heap_magic_resistance') then fleshHeapToGive = "pudge_flesh_heap_evasion" ; givenAbility = true
                elseif random == 10 and not spawnedUnit:HasAbility('pudge_flesh_heap_evasion') then fleshHeapToGive = "pudge_flesh_heap_evasion" ; givenAbility = true
                end



                -- If they randomly picked a flesh heap they already had, go through this list and try to give them one until they get one
                if not givenAbility then
                    if not spawnedUnit:HasAbility('pudge_flesh_heap') then fleshHeapToGive = "pudge_flesh_heap"
                    elseif not spawnedUnit:HasAbility('pudge_flesh_heap_int') then fleshHeapToGive = "pudge_flesh_heap_int"
                    elseif not spawnedUnit:HasAbility('pudge_flesh_heap_agility') then fleshHeapToGive = "pudge_flesh_heap_agility"
                    elseif not spawnedUnit:HasAbility('pudge_flesh_heap_move_speed') then fleshHeapToGive = "pudge_flesh_heap_move_speed"
                    elseif not spawnedUnit:HasAbility('pudge_flesh_heap_spell_amp') then fleshHeapToGive = "pudge_flesh_heap_spell_amp"
                    elseif not spawnedUnit:HasAbility('pudge_flesh_heap_attack_range') then fleshHeapToGive = "pudge_flesh_heap_attack_range"
                    elseif not spawnedUnit:HasAbility('pudge_flesh_heap_bonus_vision') then fleshHeapToGive = "pudge_flesh_heap_bonus_vision"
                    elseif not spawnedUnit:HasAbility('pudge_flesh_heap_cooldown_reduction') then fleshHeapToGive = "pudge_flesh_heap_cooldown_reduction"
                    elseif not spawnedUnit:HasAbility('pudge_flesh_heap_magic_resistance') then fleshHeapToGive = "pudge_flesh_heap_magic_resistance"
                    elseif not spawnedUnit:HasAbility('pudge_flesh_heap_evasion') then fleshHeapToGive = "pudge_flesh_heap_evasion"
                    end
                end
            end

            if OptionManager:GetOption('extraAbility') == 13 then
                -- Give an essence shift based on heros primary attribute
                if spawnedUnit:GetPrimaryAttribute() == 0 then essenceshiftToGive = "slark_essence_shift_strength_lod"
                elseif spawnedUnit:GetPrimaryAttribute() == 1 then essenceshiftToGive = "slark_essence_shift_agility_lod"
                elseif spawnedUnit:GetPrimaryAttribute() == 2 then essenceshiftToGive = "slark_essence_shift_intellect_lod"
                end
            end

             if OptionManager:GetOption('extraAbility') == 19 then
                -- Give an essence shift based on heros primary attribute
                if spawnedUnit:IsRangedAttacker() then rangedTrickshot = "ebf_clinkz_trickshot_passive_ranged"
                end
            end

            local abilityToGive = self.freeAbility

            if fleshHeapToGive then abilityToGive = fleshHeapToGive
            elseif essenceshiftToGive then abilityToGive = essenceshiftToGive
            elseif rangedTrickshot then abilityToGive = rangedTrickshot
            end

            spawnedUnit:AddAbility(abilityToGive)
            local givenAbility = spawnedUnit:FindAbilityByName(abilityToGive)
            if givenAbility then
                givenAbility:SetLevel(givenAbility:GetMaxLevel())
            end

        end, DoUniqueString('addExtra'), RandomInt(1,3) )
    end

    if OptionManager:GetOption('freeCourier') then
        local team = spawnedUnit:GetTeam()

        if not self.givenCouriers[team] then
            Timers:CreateTimer(function()
                if IsValidEntity(spawnedUnit) then
                    if not self.givenCouriers[team] then
                        self.givenCouriers[team] = true
                        local item = spawnedUnit:AddItemByName('item_courier')

                        if item then
                            spawnedUnit:CastAbilityImmediately(item, spawnedUnit:GetPlayerID())
                        end
                    end
                end
            end, DoUniqueString('spawncourier'), 1)
        end
    end

    Timers:CreateTimer(function()
        if IsValidEntity(spawnedUnit) then
            for _,modifier in pairs(spawnedUnit:FindAllModifiers()) do
                if string.find(modifier:GetName(), "modifier_special_bonus") then
                    modifier:Destroy()
                end
           end
        end
     end, DoUniqueString('removeTalentModifiers'), 2)

    -- Only give bonuses once
    if not self.givenBonuses[playerID] then
        -- We have given bonuses
        self.givenBonuses[playerID] = true

        local startingLevel = OptionManager:GetOption('startingLevel')
        -- Do we need to level up?
        if startingLevel > 1 then
            -- Level it up
            for i=1,startingLevel-1 do
               spawnedUnit:HeroLevelUp(false)
            end

            local exp = constants.XP_PER_LEVEL_TABLE[startingLevel]

            -- Fix EXP
            spawnedUnit:AddExperience(exp, false, false)
        end

        -- Any bonus gold?
        if OptionManager:GetOption('bonusGold') > 0 then
            PlayerResource:SetGold(playerID, OptionManager:GetOption('bonusGold'), true)
        end
    end
end

-- Apply fixes, add perks
function Pregame:fixSpawningIssues()
    self.givenBonuses = self.givenBonuses or {}
    self.handled = self.handled or {}
    local allHeroes = LoadKeyValues('scripts/npc/npc_heroes.txt')

    -- Grab a reference to self
    local this = self

    local notOnIllusions = {
        lone_druid_spirit_bear = true,
        necronomicon_warrior_last_will_lod = true,
        roshan_bash = true,
    }

    local botAIModifier = {
        slark_shadow_dance = true,
        alchemist_chemical_rage = true,
        --rattletrap_rocket_flare = true,
    }

    ListenToGameEvent('npc_spawned', function(keys)
        -- Grab the unit that spawned
        local spawnedUnit = EntIndexToHScript(keys.entindex)

        -- Grab their playerID
        if spawnedUnit.GetPlayerID then
            local playerID = spawnedUnit:GetPlayerID()

            local mainHero = PlayerResource:GetSelectedHeroEntity(playerID)

            -- Fix up tempest doubles/etc
            if self.spawnedHeroesFor[playerID] and mainHero and mainHero ~= spawnedUnit then
                local notOnIllusions = {
                    lone_druid_spirit_bear = true,
                    necronomicon_warrior_last_will_lod = true,
                    roshan_bash = true,
                }

                -- Apply the build
                local build = this.selectedSkills[playerID] or {}
                SkillManager:ApplyBuild(spawnedUnit, build)

                -- Illusion and Tempest Double fixes

                if not spawnedUnit:IsClone() then
                    -- ILLUSION HAVING WRONG STATS FIX START --
                    local realHero
                    if spawnedUnit.IsIllusion and spawnedUnit:IsIllusion() and spawnedUnit:IsHero() then
                      -- Search nearby radius to find the real hero
                        local nearbyUnits = Entities:FindAllInSphere(spawnedUnit:GetAbsOrigin(), 2000)
                        local filteredNearbyUnits = {}
                        for i, unit in pairs(nearbyUnits) do
                            if not unit.IsRealHero or not unit:IsRealHero()  then
                                --nearbyUnits[i] = nil
                            else
                                -- We have found the real hero if: Hero is Real and Not Illusion and unit has same name as the spawned illusion
                                if unit and unit:GetName() == spawnedUnit:GetName() then
                                    table.insert(filteredNearbyUnits, unit)
                                end
                            end
                        end
                        if #filteredNearbyUnits > 1 then
                            for _, unit in pairs(filteredNearbyUnits) do
                                if unit and unit.GetItemInSlot and unit:GetName() ~= "" and unit:GetLevel() == spawnedUnit:GetLevel() then
                                    for j=0,8 do
                                        if unit:GetItemInSlot(j) and spawnedUnit:GetItemInSlot(j) and unit:GetItemInSlot(j):GetAbilityName() == spawnedUnit:GetItemInSlot(j):GetAbilityName() then
                                            realHero = unit
                                            break
                                        end
                                    end
                                end
                            end
                        else
                            realHero = filteredNearbyUnits[1]
                        end

                      -- If we found the real hero, make illusion have same stats as original
                        if realHero then
                            Timers:CreateTimer(function()
                                -- Modify illusions stats so that they are the same as the owning hero
                                spawnedUnit:FixIllusion(realHero)
                            end, DoUniqueString('FixIllusionSkills'), .1)
                        else
                            print("Cant find real hero, not changing a thing")
                        end
                    end



                    Timers:CreateTimer(function()
                        if IsValidEntity(spawnedUnit) then
                            for k,abilityName in pairs(build) do
                                if notOnIllusions[abilityName] then
                                    local ab = spawnedUnit:FindAbilityByName(abilityName)
                                    if ab then
                                        ab:SetLevel(0)
                                        ab:RemoveSelf()
                                    end
                                end
                            end
                        end
                    end, DoUniqueString('fixBrokenSkills'), .1)
                end
            end
        end

        -- Ensure it's a valid unit
        if IsValidEntity(spawnedUnit) then
            -- Filter gold modifier here instead of in filtergold in ingame because this makes the popup correct
            local goldModifier = OptionManager:GetOption('goldModifier')
            if goldModifier ~= 1 and not spawnedUnit.bountyAdjusted then
                -- Non hero units that respawn should only be adjusted once, this are things like bears or familiars
                if not spawnedUnit:IsHero() then
                 spawnedUnit.bountyAdjusted = true
                end
                local newBounty = spawnedUnit:GetGoldBounty() * goldModifier / 100
                spawnedUnit:SetMaximumGoldBounty(newBounty)
                spawnedUnit:SetMinimumGoldBounty(newBounty)
            end

            -- Spellfix: Give Eyes in the Forest a notification for nearby enemies.
            if spawnedUnit:GetName() == "npc_dota_treant_eyes" then
                Timers:CreateTimer(function()
                    spawnedUnit:AddAbility("treant_eyes_in_the_forest_notification")
                    local noticeAura = spawnedUnit:FindAbilityByName("treant_eyes_in_the_forest_notification")
                    noticeAura:SetLevel(1)
                end, DoUniqueString('eyesFix'), 0.5)
        end

        -- Silencer Fix NEEDS TO BE RUN EVERY SPAWN, AND ON FIXEDHERO FUNCTION
        Timers:CreateTimer(function()
            if IsValidEntity(spawnedUnit) then
                -- Silencer Fix
                if spawnedUnit:HasAbility('silencer_glaives_of_wisdom_steal') then
                    if not spawnedUnit:HasModifier('modifier_silencer_int_steal') then
                        spawnedUnit:AddNewModifier(spawnedUnit, spawnedUnit:FindAbilityByName("silencer_glaives_of_wisdom_steal"), 'modifier_silencer_int_steal', {})
                    end
                else
                    spawnedUnit:RemoveModifierByName('modifier_silencer_int_steal')
                end
            end
        end, DoUniqueString('silencerFix'), 2)

            if Wearables:HasDefaultWearables( spawnedUnit:GetUnitName() ) then
                Wearables:AttachWearableList( spawnedUnit, Wearables:GetDefaultWearablesList( spawnedUnit:GetUnitName() ) )
            end
            -- hotfix experiment: If you kill a bot ten times, they respawn with help
            -- Detect spawn dummy
            --if spawnedUnit:IsRealHero() then
                --if util:isPlayerBot(spawnedUnit:GetPlayerID()) and util:GetActiveHumanPlayerCountForTeam(spawnedUnit:GetTeam()) == 0 then
                --    if spawnedUnit:GetDeaths() > 10 and RollPercentage(10) then
                --        Timers:CreateTimer(function()
                --            local botHelper = CreateUnitByName("npc_dota_creature_small_spirit_bear", spawnedUnit:GetAbsOrigin(), true, nil, nil, spawnedUnit:GetTeamNumber())
                --        end, DoUniqueString('makeMonster1'), 1)
                --    end
                --    if spawnedUnit:GetDeaths() > 20 and RollPercentage(10) then
                --        Timers:CreateTimer(function()
                --            local botHelper = CreateUnitByName("npc_bot_spirit_sven", spawnedUnit:GetAbsOrigin(), true, nil, nil, spawnedUnit:GetTeamNumber())
                --        end, DoUniqueString('makeMonster2'), 1)
                --    end
                --    if spawnedUnit:GetDeaths() > 15 and RollPercentage(10) then
                --        Timers:CreateTimer(function()
                --            local botHelper = CreateUnitByName("npc_dota_creature_large_spirit_bear", spawnedUnit:GetAbsOrigin(), true, nil, nil, spawnedUnit:GetTeamNumber())
                --        end, DoUniqueString('makeMonster3'), 1)
                --    end
                --    if spawnedUnit:GetDeaths() > 25 and RollPercentage(10) then
                --        Timers:CreateTimer(function()
                --            local botHelper = CreateUnitByName("npc_dota_creature_big_bear", spawnedUnit:GetAbsOrigin(), true, nil, nil, spawnedUnit:GetTeamNumber())
                --        end, DoUniqueString('makeMonster4'), 1)
                --    end
                --end
            --end
            -- Make sure it is a hero
            if spawnedUnit:IsHero() then

            elseif string.match(spawnedUnit:GetUnitName(), "creep") or string.match(spawnedUnit:GetUnitName(), "siege") then
                if this.optionStore['lodOptionCreepPower'] > 0 then
                    local dotaTime = GameRules:GetDOTATime(false, false)
                    local level = math.ceil(dotaTime / this.optionStore['lodOptionCreepPower'])

                    Timers:CreateTimer(function()
                        if IsValidEntity(spawnedUnit) then
                            local ability = spawnedUnit:AddAbility("lod_creep_power")
                            ability:UpgradeAbility(false)
                            spawnedUnit:SetModifierStackCount("modifier_creep_power",spawnedUnit,level)
                        end
                    end, DoUniqueString('giveCreepPower'), 2)

                    -- After level 14, creeps evolve model to represent their upgraded power
                    local levelToUpgrade = 14

                    Timers:CreateTimer(function()
                        if IsValidEntity(spawnedUnit) then

                            if level > levelToUpgrade then
                                if spawnedUnit:GetModelName() == "models/creeps/lane_creeps/creep_bad_melee/creep_bad_melee.vmdl" then
                                    spawnedUnit:SetModel("models/creeps/lane_creeps/creep_bad_melee/creep_bad_melee_mega.vmdl")
                                    spawnedUnit:SetOriginalModel("models/creeps/lane_creeps/creep_bad_melee/creep_bad_melee_mega.vmdl")
                                elseif spawnedUnit:GetModelName() == "models/creeps/lane_creeps/creep_bad_ranged/lane_dire_ranged.vmdl" then
                                    spawnedUnit:SetModel("models/creeps/lane_creeps/creep_bad_ranged/lane_dire_ranged_mega.vmdl")
                                    spawnedUnit:SetOriginalModel("models/creeps/lane_creeps/creep_bad_ranged/lane_dire_ranged_mega.vmdl")
                                elseif spawnedUnit:GetModelName() == "models/creeps/lane_creeps/creep_radiant_melee/radiant_melee.vmdl" then
                                    spawnedUnit:SetModel("models/creeps/lane_creeps/creep_radiant_melee/radiant_melee_mega.vmdl")
                                    spawnedUnit:SetOriginalModel("models/creeps/lane_creeps/creep_radiant_melee/radiant_melee_mega.vmdl")
                                elseif spawnedUnit:GetModelName() == "models/creeps/lane_creeps/creep_radiant_ranged/radiant_ranged.vmdl" then
                                    spawnedUnit:SetModel("models/creeps/lane_creeps/creep_radiant_ranged/radiant_ranged_mega.vmdl")
                                    spawnedUnit:SetOriginalModel("models/creeps/lane_creeps/creep_radiant_ranged/radiant_ranged_mega.vmdl")
                                end
                            end
                        end
                    end, DoUniqueString('evolveCreep'), .5)

                end

            elseif spawnedUnit:GetTeam() == DOTA_TEAM_NEUTRALS then
                -- Increasing creep power over time
                if this.optionStore['lodOptionNeutralCreepPower'] > 0 then
                    if IsValidEntity(spawnedUnit) then
                                spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_neutral_power", {interval_time = this.optionStore['lodOptionNeutralCreepPower']})
                    end
                end
            end
        end
    end, nil)
end

-- Return an instance of it
local _instance = Pregame()

ListenToGameEvent('game_rules_state_change', function(keys)
    local newState = GameRules:State_Get()
    if newState == DOTA_GAMERULES_STATE_PRE_GAME then
        local allHeroes = LoadKeyValues('scripts/npc/npc_heroes.txt')
    elseif newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        if IsDedicatedServer() then
            local mapName = OptionManager:GetOption('mapname')
            if (mapName == 'all_allowed' or mapName == 'overthrow') and not util:isCoop() then
                SU:SendPlayerBuild( buildBackups )
            end
        end

        WAVE = 0

        Timers:CreateTimer(function()
            WAVE = WAVE + 1
            return 30.0
        end, 'waves', 0.0)

        _G.duel = (function ()
            local next_tick = DUEL_INTERVAL

            Timers:CreateTimer(function()
                if CustomNetTables:GetTableValue("phase_ingame","duel").active == 1 then
                    local draw_tick = DUEL_NOBODY_WINS + DUEL_PREPARE

                    Timers:CreateTimer(function()
                        draw_tick = draw_tick - 1

                        if CustomNetTables:GetTableValue("phase_ingame","duel").active == 0 then
                            return
                        else
                            sendEventTimer( "#duel_nobody_wins", draw_tick)
                        end

                        return 1.0
                    end, 'duel_countdown_draw', 0)
                    return
                else
                    sendEventTimer( "#duel_next_duel", next_tick)
                end
                next_tick = next_tick - 1
                if next_tick < 0 then
                    next_tick = 0
                end
                return 1.0
            end, 'duel_countdown_next', 0)

            Timers:CreateTimer(function()
                customAttension("#duel_10_sec_to_begin", 5)
                EmitGlobalSound("Event.DuelStart")

                Timers:CreateTimer(function()
                    initDuel(_G.duel)
                end, 'start_duel', 10)

                Timers:CreateTimer(function()
                    if CustomNetTables:GetTableValue("phase_ingame","duel").active == 1 then
                        customAttension("#duel_10_sec_to_end", 5)
                    end
                end, 'duel_draw_warning', DUEL_NOBODY_WINS + DUEL_PREPARE)
            end, 'main_duel_timer', DUEL_INTERVAL - 10)
        end)

        CustomNetTables:SetTableValue("phase_ingame","duel", {active=0})

        if OptionManager:GetOption('duels') == 1 then
            -- GameRules:SendCustomMessage("#tempDuelBlock", 0, 0)
            _G.duel()
        end

        -- if OptionManager:GetOption('duels') == 1 then
        --     local duel
        --     duel = (function ()
        --         Timers:CreateTimer(function()
        --             customAttension("#duel_10_sec_to_begin", 5)

        --             Timers:CreateTimer(function()
        --                 initDuel(duel)
        --             end, 'start_duel', 10)

        --             Timers:CreateTimer(function()
        --                 if duel_active then
        --                     customAttension("#duel_10_sec_to_end", 5)
        --                 end
        --             end, 'waves', DUEL_NOBODY_WINS)

        --             local next_tick = 10

        --             Timers:CreateTimer(function()
        --                 if duel_active == true then
        --                     CustomGameEventManager:Send_ServerToAllClients( "duel_text_hide", {} )
        --                     return
        --                 else
        --                     sendEventTimer( "#duel_next_duel", next_tick)
        --                 end

        --                 next_tick = next_tick - 1
        --                 return 1.0
        --             end, 'duel_countdown_next', 0)

        --             local draw_tick = 10

        --             Timers:CreateTimer(function()
        --                 if duel_active ~= true then
        --                     CustomGameEventManager:Send_ServerToAllClients( "duel_text_hide", {} )
        --                     return
        --                 else
        --                     sendEventTimer( "#duel_nobody_wins", draw_tick)
        --                 end

        --                 draw_tick = draw_tick - 1
        --                 return 1.0
        --             end, 'duel_countdown_draw', DUEL_NOBODY_WINS)

        --             return DUEL_INTERVAL - 10
        --         end, 'main_duel_timer', DUEL_INTERVAL - 10)
        --     end)
        --     duel()
        -- end
    end
end, nil)

return _instance
