local constants = require('constants')
----local timers = require('easytimers')

require('abilities/hero_perks/hero_perks_filters')
require('abilities/epic_boss_fight/ebf_mana_fiend_essence_amp')
require('abilities/global_mutators/global_mutator')
require('abilities/global_mutators/memes_redux')
require('abilities/nextgeneration/orderfilter')

-- Create the class for it
local Ingame = class({})

local ts_entities = LoadKeyValues('scripts/kv/ts_entities.kv')
GameRules.perks = LoadKeyValues('scripts/kv/perks.kv')
for k,v in pairs(util:getAbilityKV()) do
    if v and v["ReduxPerks"] then
        local abilityPerks = util:split(v["ReduxPerks"], " | ")
        for _,perk in ipairs(abilityPerks) do
            local perk = string.lower(perk)
            GameRules.perks[perk] = GameRules.perks[perk] or {}
            GameRules.perks[perk][k] = true
        end
    end
end
GameRules.hero_perks = LoadKeyValues('scripts/kv/hero_perks.kv')

-- Init Ingame stuff, sets up all ingame related features
function Ingame:init()
    -- Init everything
    self:handleRespawnModifier()
    self:initGoldBalancer()
    self:checkBuybackStatus()

    -- Init stronger towers
    self:addStrongTowers()
    self:loadTrollCombos()
    self:AddTowerBotController()
    self:fixRuneBug()

    -- -- Init global mutator
    self:initGlobalMutator()

    -- -- 10vs10 colors
    self.playerColors = {}
    self.playerColors[0] = { 57, 117, 231 }
    self.playerColors[1]  = { 122, 241, 187 }
    self.playerColors[2]  = { 172, 10, 174}
    self.playerColors[3]  = { 243, 234, 33}
    self.playerColors[4]  = { 240, 111, 19 }
    self.playerColors[5] = { 100 * 2.55, 0, 0 }
    self.playerColors[6]  = { 0, 25.88 * 2.55, 100 }
    self.playerColors[7]  = { 9.8 * 2.55, 90.2  * 2.55, 72.55  * 2.55}
    self.playerColors[8]  = { 32.94 * 2.55, 0, 50.59 * 2.55}
    self.playerColors[9]  = { 100 * 2.55, 98.82 * 2.55, 0 }
    self.playerColors[15]  = { 99.61 * 2.55, 72.94 * 2.55, 5.49 * 2.55}
    self.playerColors[16]  = { 12.55 * 2.55, 75.3 * 2.55, 0 }
    self.playerColors[17]  = { 252, 255, 236 }
    self.playerColors[18]  = { 58.43 * 2.55, 58.82 * 2.55, 59.21 * 2.55 }
    self.playerColors[19]  = { 49.41 * 2.55, 74.90 * 2.55, 94.51 * 2.55 }

    -- When to increase respawn rates - 40 minutes
    self.timeToIncreaseRespawnRate = 2400
    self.timeToIncreaseRepawnInterval = 600

    -- What time to disable team balancing mechanic - 20 minutes
    self.timeToStopBalancingMechanic = 1200

    -- These are optional votes that can enable or disable game mechanics
    self.voteEnabledCheatMode = false
    self.voteDoubleCreeps = false
    self.voteDisableAntiKamikaze = false
    self.voteDisableRespawnLimit = false
    self.voteEnableFatOMeter = false
    self.voteEnableRefresh = false
    self.voteEnableBuilder = false
    self.voteAntiRat = false
    self.origianlRespawnRate = nil
    self.timeImbalanceStarted = 0
	self.radiantBalanceMoney = 0
    self.direBalanceMoney = 0
    self.radiantTotalBalanceMoney = 0
    self.direTotalBalanceMoney = 0
    self.shownCheats = {}
    self.heard = {}

    self.botsInLateGameMode = false

    -- Setup standard rules
    GameRules:GetGameModeEntity():SetTowerBackdoorProtectionEnabled(true)

    PrecacheUnitByNameAsync('npc_precache_npc_dota_hero_ogre_magi', function()
        CreateUnitByName('npc_precache_npc_dota_hero_ogre_magi', Vector(-10000, -10000, 0), false, nil, nil, 0)
    end)

    PrecacheUnitByNameAsync('npc_precache_wraithnight', function()
        CreateUnitByName('npc_precache_wraithnight', Vector(-10000, -10000, 0), false, nil, nil, 0)
    end)

    -- Precache the stuff that needs to always be precached
    PrecacheUnitByNameAsync('npc_precache_always', function()
        CreateUnitByName('npc_precache_always', Vector(-10000, -10000, 0), false, nil, nil, 0)
    end)

    CustomGameEventManager:RegisterListener( 'declined', function (eventSourceIndex)
        self:declined(eventSourceIndex)
    end)

    CustomGameEventManager:RegisterListener( 'ask_custom_team_info', function(eventSourceIndex, args)
        self:returnCustomTeams(eventSourceIndex, args)
    end)

    CustomGameEventManager:RegisterListener('universalVotingsVote', function(eventSourceIndex, args)
        if util.activeVoting and util.activeVoting.name == args.votingName then
            util.activeVoting.onvote(args.PlayerID, args.accept == 1)
        end
    end)

    CustomGameEventManager:RegisterListener('lodRequestCheatData', function(eventSourceIndex, args)
        network:updateCheatPanelStatus(self.voteEnabledCheatMode, args.PlayerID)
    end)

    CustomGameEventManager:RegisterListener('set_help_disabled', function(eventSourceIndex, args)
        local player = args.player or -1
        if PlayerResource:IsValidPlayerID(player) then
            PlayerResource:SetDisableHelpForPlayerID(args.PlayerID, player, tonumber(args.disabled) == 1)
        end
    end)

    CustomGameEventManager:RegisterListener('lodPrintTime', function(eventSourceIndex, args)
        local player = PlayerResource:GetPlayer(args.PlayerID)
        Say(player, util:secondsToClock(GameRules:GetDOTATime(false, true)), true)
    end)

end

function Ingame:OnPlayerReconnect(keys)
    Timers:CreateTimer(function ()
        local player = PlayerResource:GetPlayer(keys.PlayerID)
        CustomGameEventManager:Send_ServerToPlayer(player, "lodAttemptReconnect",{})
    end, DoUniqueString('reconnect'), 4.0)
end

function Ingame:OnHeroLeveledUp(keys)
    -- Give abilitypoints to spend on the levels the game doesn't give.
    local pID = keys.player -1
    local player = PlayerResource:GetPlayer(pID)
    local hero = player:GetAssignedHero()

    local markedLevels = {[17]=true,[19]=true,[21]=true,[22]=true,[23]=true,[24]=true}
    if markedLevels[keys.level] then
        hero:SetAbilityPoints(hero:GetAbilityPoints() + 1)
    end

    local function GetXPForLevel( x )
        if x == 1 then
            return 100
        elseif x < 8 then
            return 20 * (x + 4)
        elseif x == 8 then
            return 330
        else
            return GetXPForLevel( x - 1 ) + 110
        end
    end

    local level = hero:GetLevel()


    hero:SetCustomDeathXP(GetXPForLevel( level ))
    -- print(hero:GetUnitName(), level, hero:GetDeathXP(), GetXPForLevel( level ))
end

function Ingame:OnModifierEvent(keys)
    print("MODIFIER EVENT")
    for k,v in pairs(keys) do print(k,v) end
end

function Ingame:OnPlayerPurchasedItem(keys)
    -- Bots will get items auto-delievered to them
    self:checkIfRespawnRate()
    self:balanceGold()
    if util:isPlayerBot(keys.PlayerID) then
        local hero = PlayerResource:GetPlayer(keys.PlayerID):GetAssignedHero()
        -- If bots buy boots remove first instances of cheap items they have, this is a fix for them having boots in backpack
        if string.find(keys.itemname, "boots") or keys.itemname == "item_power_treads" then
            local tangos = hero:FindItemByName("item_tango")
            local mangos = hero:FindItemByName("item_enchanted_mango")
            local clarity = hero:FindItemByName("item_clarity")
            local faerie = hero:FindItemByName("item_faerie_fire")
            local flask = hero:FindItemByName("item_flask")

            if tangos then
            local refund = tangos:GetCost()
            hero:ModifyGold(refund, false, 0)
            tangos:RemoveSelf()
            end
            if mangos then
                local refund = mangos:GetCost()
                hero:ModifyGold(refund, false, 0)
                mangos:RemoveSelf()
            end
            if clarity then
                local refund = clarity:GetCost() * clarity:GetCurrentCharges()
                hero:ModifyGold(refund, false, 0)
                clarity:RemoveSelf()
            end
            if faerie then
                local refund = faerie:GetCost()
                hero:ModifyGold(refund, false, 0)
                faerie:RemoveSelf()
            end
            if flask then
                local refund = flask:GetCost() * flask:GetCurrentCharges()
                hero:ModifyGold(refund, false, 0)
                flask:RemoveSelf()
            end
        end


            for slot =  DOTA_STASH_SLOT_1, DOTA_STASH_SLOT_6 do
                item = hero:GetItemInSlot(slot)
                if item ~= nil then
                    itemName = item:GetAbilityName()
                    if itemName == keys.itemname then
                        item:RemoveSelf()
                        hero:AddItem(CreateItem(itemName, hero, hero))
                        break
                    end
                end
            end

        -- Check if there is any remaining items in slot, if there is, it means their inventory is full
        local isFull = false
        for slot =  DOTA_STASH_SLOT_1, DOTA_STASH_SLOT_6 do
                local item = hero:GetItemInSlot(slot)
                if item ~= nil then
                    isFull = true
                end
            end

        -- If they have a full inventory, remove any tangos or branches to clear space
        if isFull then
            for slot =  DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
                item = hero:GetItemInSlot(slot)
                if item ~= nil then
                    itemName = item:GetAbilityName()
                    if itemName == "item_tango" or itemName == "item_branches" then
                        item:RemoveSelf()
                        break
                    end
                end
            end

            -- Try to move items from stash to inventory again after we have cleared out some items
            for slot =  DOTA_STASH_SLOT_1, DOTA_STASH_SLOT_6 do
                item = hero:GetItemInSlot(slot)
                if item ~= nil then
                    itemName = item:GetAbilityName()
                    if itemName == keys.itemname then
                        item:RemoveSelf()
                        hero:AddItem(CreateItem(itemName, hero, hero))
                        break
                    end
                end
            end
        end
    end

    if OptionManager:GetOption('banInvis') == 2 then
        local hero = PlayerResource:GetPlayer(keys.PlayerID):GetAssignedHero()
        for i=0,11 do
            local item = hero:GetItemInSlot(i)
            if item ~= nil then
                if item:GetName() == "item_shadow_amulet" or item:GetName() == "item_invis_sword" or item:GetName() == "item_silver_edge" or item:GetName() == "item_glimmer_cape" then
                    hero:ModifyGold(item:GetCost(), false, 0)
                    hero:RemoveItem(item)
                    util:DisplayError(keys.PlayerID, "invisbilityItemsAreBanned")
                    break
                end
            end
        end
    end


    if OptionManager:GetOption('sharedXP') == 1 and keys.itemname == "item_tome_of_knowledge" then
        for i=0,11 do
            local item = hero:GetItemInSlot(i)
            if item:GetName() == "item_tome_of_knowledge" then
                hero:RemoveItem(item)

                for x=0,DOTA_MAX_TEAM do
                    local pID = PlayerResource:GetNthPlayerIDOnTeam(hero:GetTeamNumber(),x)
                    if PlayerResource:IsValidPlayerID(pID) then
                        local otherHero = PlayerResource:GetPlayer(pID):GetAssignedHero()

                        otherHero:AddExperience(math.ceil(425 / util:GetActivePlayerCountForTeam(hero:GetTeamNumber())),0,false,false)
                    end
                end

                break
            end
        end
    end
end

function Ingame:OnPlayerLearnedAbility( keys )
    local chargeTalents = {
        ["special_bonus_unique_ember_spirit_4"] = "ember_spirit_sleight_of_fist",
        ["special_bonus_unique_morphling_6"] = "morphling_waveform",
    }
    local abilityName = chargeTalents[keys.abilityname]
    if abilityName then
        Timers:CreateTimer(0.3,function()
            local hero = PlayerResource:GetSelectedHeroEntity(keys.PlayerID)
            if hero then
                local talent = hero:FindAbilityByName(keys.abilityname)
                local count = talent and talent:GetSpecialValueFor("value") or 0
                local charges = hero:FindModifierByName("modifier_"..abilityName.."_charge_counter")
                if charges then
                    charges:SetStackCount(count)
                end
            end
        end)
        -- Custom stat bonus talents
        if string.find(abilityName,"special_bonus") and string.find(abilityName,"redux") then
            local hero = PlayerResource:GetSelectedHeroEntity(keys.PlayerID)
            if hero then
                LinkLuaModifier("modifier_"..abilityName,"abilities/talents"..abilityName..".lua",LUA_MODIFIER_MOTION_NONE)
                hero:AddNewModifier(hero,nil,"modifier_"..abilityName,{})
            end
        end
    end
end

function Ingame:FilterExecuteOrder(filterTable)
    local order_type = filterTable.order_type
    local units = filterTable["units"]
    local issuer = filterTable["issuer_player_id_const"]
    local unit = EntIndexToHScript(units["0"])
    local ability = EntIndexToHScript(filterTable.entindex_ability)
    local target = EntIndexToHScript(filterTable.entindex_target)

    if order_type == DOTA_UNIT_ORDER_GLYPH  then     
        if RADIANTFORTIFIED and PlayerResource:GetSelectedHeroEntity(issuer):GetTeamNumber() == DOTA_TEAM_GOODGUYS then
            Notifications:Top(PlayerResource:GetPlayer(issuer),{text="Glyph already active",duration = 2})
            return false
        elseif DIREFORTIFIED and PlayerResource:GetSelectedHeroEntity(issuer):GetTeamNumber() == DOTA_TEAM_BADGUYS  then
            Notifications:Top(PlayerResource:GetPlayer(issuer),{text="Glyph already active",duration = 2})
            return false
        end
    end      

    -- if order_type == DOTA_UNIT_ORDER_PURCHASE_ITEM then		
    --     return false		
    -- end		
		
    -- if units[1] and order_type == DOTA_UNIT_ORDER_SELL_ITEM and ability and not units[1]:IsIllusion() and not units[1]:IsTempestDouble() then		
    --     PanoramaShop:SellItem(units[1], ability)		
    --     return false		
    -- end		

    -- Block Alchemists Innate, heroes should not have innate abilities
    if ability and target then
        if string.match(target:GetName(), "npc_dota_hero_") and ability:GetName() == "item_ultimate_scepter" and unit:GetUnitName() == "npc_dota_hero_alchemist" then
            return false
        end
    end
    if unit then
        if unit:IsRealHero() then
            local unitPlayerID = unit:GetPlayerID()

            -- BOT STUCK FIX
            -- How It Works: Every time bot creates an order, this checks their position, if they are in the same last position as last order,
            -- increase counter. If counter gets too high, it means they have been stuck in same position for a long time, do action to help them.
            if util:isPlayerBot(unitPlayerID) then
                -- Bot Armlet Fix: Bots do not know how to use armlets so return false if they attempt to and put on cooldown
                if ability and ability:GetName() == "item_armlet" then
                    ability:StartCooldown(200)
                    return false
                end
                if OptionManager:GetOption('stupidBots') == 1 then
                    if unit.blocked == true then
                        return false
                    end

                    -- Abiliites have a 50% chance to misfire and go on cooldown
                    if ability and ability.GetCooldownTimeRemaining then
                        if RollPercentage(50) then
                            ability:StartCooldown(3)
                        end
                    end

                    --- Blocks an only make one order per 3 seconds, abilities dont count
                    if unit.blocked ~= true and not ability.GetCooldownTimeRemaining then
                        unit.blocked = true
                        Timers:CreateTimer(function()
                            unit.blocked = false
                        end, DoUniqueString('temporaryBlocked'), 3)
                    end
                end

                if not unit.OldPosition then
                    unit.OldPosition = unit:GetAbsOrigin()
                    unit.StuckCounter = 0
                elseif unit:GetAbsOrigin() == unit.OldPosition then
                    unit.StuckCounter = unit.StuckCounter + 1

                    -- Stuck at observer ward fix
                    if unit.StuckCounter > 50 then
                        for i=0,11 do
                            local item = unit:GetItemInSlot(i)
                            if item and item:GetName() == "item_ward_observer" then
                                unit:ModifyGold(item:GetCost() * item:GetCurrentCharges(), true, 0)
                                unit:RemoveItem(item)
                                return true
                            end
                        end
                    end

                    -- Stuck at shop trying to get stash items, remove stash items. THIS IS A BAND-AID FIX. IMPROVE AT SOME POINT
                    if unit.StuckCounter > 150 and fixed == false then
                        for slot =  DOTA_STASH_SLOT_1, DOTA_STASH_SLOT_6 do
                            item = unit:GetItemInSlot(slot)
                            if item ~= nil then
                                item:RemoveSelf()
                                return true
                            end
                        end
                    end

                    -- Its well and truly borked, kill it and hope for the best.
                    if unit.StuckCounter > 300 and fixed == false then
                        unit:Kill(nil, nil)
                        return true
                    end

                else
                   unit.OldPosition = unit:GetAbsOrigin()
                   unit.StuckCounter = 0
                end
            end
            -- END BOT STUCK FIX

            if order_type == DOTA_UNIT_ORDER_CAST_TARGET and IsValidEntity(ability) and IsValidEntity(target) then
                local abilityname = ability:GetAbilityName()
                if util:getAbilityKV(abilityname, "ReduxDisableHelp") == 1 then
                    local targetID = -1
                    if target.GetPlayerID and target:GetPlayerID() > -1 then
                        targetID = target:GetPlayerID()
                    elseif target.GetPlayerOwnerID then
                        targetID = target:GetPlayerOwnerID()
                    end
                    if PlayerResource:IsDisableHelpSetForPlayerID(targetID, unitPlayerID) then
                        util:DisplayError(issuer, "dota_hud_error_target_has_disable_help")
                        return false
                    end
                end
            end
        end
    end

    if unit:GetTeamNumber() ~= PlayerResource:GetCustomTeamAssignment(issuer) and PlayerResource:GetConnectionState(issuer) ~= 0 then
        return false
    end
    -- Next Gen hackery
    filterTable = nextGenOrderFilter(filterTable)

    if not OptionManager:GetOption('disablePerks') then
        filterTable = heroPerksOrderFilter(filterTable)
    end

    if OptionManager:GetOption('memesRedux') == 1 then
        filterTable = memesOrderFilter(filterTable)
    end


    return true
end

dc_table = {};

-- Called when the game starts
function Ingame:onStart()
    local this = self

    -- Thinker to check for items that can be consumable and converts them if any are found to the consumable version
    if OptionManager:GetOption('consumeItems') == 1 then
        Timers:CreateTimer(function ()
            this:CheckConsumableItems()
            return 1
        end, 'check_consumable_items', 1)
    end
    
    if not randomLaneCreepSpawnerMade and OptionManager:GetOption("randomLaneCreeps") ~= 0 then
            randomLaneCreepSpawnerMade = true
            local randomLaneCreepSpawner = CreateUnitByName("npc_dummy_unit_imba",Vector(0,0,0),true,nil,nil,DOTA_TEAM_NEUTRALS)
            randomLaneCreepSpawner:AddNewModifier(periodicDummyCastingUnit,nil,"modifier_random_lane_creep_spawner_mutator",{})
            local a = randomLaneCreepSpawner:AddAbility("dummy_unit_state")
            a:SetLevel(1)

        end

    -- Force bots to take a defensive pose until the first tower has been destroyed. This is top stop bots from straight away pushing lanes when they hit level 6
    Timers:CreateTimer(function ()
               GameRules:GetGameModeEntity():SetBotsInLateGame(self.botsInLateGameMode)
               --print("bots will only defend")
            end, 'forceBotsToDefend', 0.5)

    ---Enable and then quickly disable all vision. This fixes two problems. First it fixes the scoreboard missing enemy abilities, and second it fixes the issues of bots not moving until they see an enemy player.
    if Convars:GetBool("dota_all_vision") == false then

        Timers:CreateTimer(function ()
               Convars:SetBool("dota_all_vision", true)
            end, 'enable_all_vision_fix', 5)

        Timers:CreateTimer(function ()
               Convars:SetBool("dota_all_vision", false)
            end, 'disable_all_vision_fix', 5.2)

    end

    -- Remove powerup runes, spawned before 2 minutes
    Timers:CreateTimer(function ()
        if math.floor(GameRules:GetDOTATime(false, false)/60) < 0.2 then
            local spawners = Entities:FindAllByClassname("dota_item_rune_spawner_powerup")
            for k,v in ipairs(spawners) do
                if v ~= nil then
                    local nearbyRunes = Entities:FindAllByClassnameWithin("dota_item_rune", v:GetOrigin(), 400)
                    for _,rune in ipairs(nearbyRunes) do
                        if rune ~= nil then
                            UTIL_Remove(rune)
                        end
                    end
                end
            end
            return 0.1
        end
    end, 'removeRunes', 0.1)

    --secondary fix for randomly not getting skill points for levels 18-24
    --  the other method is inconsistant
    Timers:CreateTimer(function()
        local heroes = HeroList:GetAllHeroes()
        for _,hero in pairs(heroes) do
            if hero then
                if hero:IsRealHero() then
                    local level = hero:GetLevel()-1
                    local points = hero:GetAbilityPoints()
                    for i=0,23 do
                        local ab = hero:GetAbilityByIndex(i)
                        if ab then
                            points = points + ab:GetLevel()
                        end
                    end
                    if points < level then
                        hero:SetAbilityPoints(level-points)
                    end
                end
            end
        end
        return 25
    end, 'giveMissingSkillPoints', 60)

    --Attempt to enable cheats
    Convars:SetBool("sv_cheats", true)

    if OptionManager:GetOption('allowIngameHeroBuilder') then
        network:enableIngameHeroEditor()

        -- Notification to players that they can change builds ingame.
        Timers:CreateTimer(function()
                GameRules:SendCustomMessage("#ingameBuilderNotification", 0, 0)
        end, "builderReminder0", 10)
        -- Reminders for the players.
        Timers:CreateTimer(function()
                GameRules:SendCustomMessage("#ingameBuilderReminder", 0, 0)
        end, "builderReminder1", 300) -- 5 Mins
        Timers:CreateTimer(function()
                GameRules:SendCustomMessage("#ingameBuilderReminder", 0, 0)
        end, "builderReminder2", 600) -- 10 Mins
        Timers:CreateTimer(function()
                GameRules:SendCustomMessage("#ingameBuilderReminder", 0, 0)
        end, "builderReminder3", 1200) -- 20 Mins
    end

    -- Battle thirst has been reworked this notification is not up to date
    --if OptionManager:GetOption('battleThirst') then
    --    -- Notification to players that they can change builds ingame.
    --    Timers:CreateTimer(function()
    --            GameRules:SendCustomMessage("#ingameBattleThirstNotification", 0, 0)
    --    end, "battleThirstReminder0", 15)
    --    Timers:CreateTimer(function()
    --            GameRules:SendCustomMessage("#ingameBattleThirstNotification", 0, 0)
    --    end, "battleThirstReminder1", 300) -- 5 Mins
    --    Timers:CreateTimer(function()
    --            GameRules:SendCustomMessage("#ingameBattleThirstNotification", 0, 0)
    --    end, "battleThirstReminder2", 600) -- 10 Mins
    --end

    -- Start listening for players that are disconnecting
    ListenToGameEvent('player_disconnect', function(keys)
        this:checkBalanceTeamsNextTick()
    end, nil)

    -- Listen for players connecting
    ListenToGameEvent('player_connect', function(keys)
        this:checkBalanceTeamsNextTick()
    end, nil)

    ListenToGameEvent('player_connect_full', function(keys)
        this:checkBalanceTeamsNextTick()
    end, nil)

    -- If Fat-O-Meter is enabled correctly, take note of players' heroes and record necessary information.
    if OptionManager:GetOption('useFatOMeter') > 0 and OptionManager:GetOption('useFatOMeter') <= 2 then
        this:StartFatOMeter()
        --print("fat o meter")
        --print(OptionManager:GetOption('useFatOMeter'))
    end

    GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(Ingame, 'FilterExecuteOrder'), self)
    GameRules:GetGameModeEntity():SetTrackingProjectileFilter(Dynamic_Wrap(Ingame, 'FilterProjectiles'), self)
    GameRules:GetGameModeEntity():SetModifierGainedFilter(Dynamic_Wrap(Ingame, 'FilterModifiers'),self)
    GameRules:GetGameModeEntity():SetDamageFilter(Dynamic_Wrap(Ingame, 'FilterDamage'),self)
    --GameRules:GetGameModeEntity():SetAbilityTuningValueFilter(Dynamic_Wrap(Ingame,"FilterValueTuning"),self)


    ListenToGameEvent('modifier_event', Dynamic_Wrap(Ingame, 'OnModifierEvent'), self)

    -- -- Listen if abilities are being used.
    --ListenToGameEvent('dota_player_used_ability', Dynamic_Wrap(Ingame, 'OnAbilityUsed'), self)

    ListenToGameEvent('dota_item_purchased', Dynamic_Wrap(Ingame, 'OnPlayerPurchasedItem'), self)

    -- -- Listen to correct the changed abilitypoints
    ListenToGameEvent('dota_player_gained_level', Dynamic_Wrap(Ingame, 'OnHeroLeveledUp'), self)

    ListenToGameEvent("player_reconnected", Dynamic_Wrap(Ingame, 'OnPlayerReconnect'), self)

    ListenToGameEvent("player_chat", Dynamic_Wrap(Commands, 'OnPlayerChat'), self)

    ListenToGameEvent("dota_player_learned_ability", Dynamic_Wrap(Ingame, "OnPlayerLearnedAbility"), self)

    ListenToGameEvent( "dota_holdout_revive_complete", Dynamic_Wrap( Ingame, "OnPlayerRevived" ), self )
    
    -- Set it to no team balance
    self:setNoTeamBalanceNeeded()
end

function Ingame:StartFatOMeter()
    -- If Fat-O-Meter is enabled correctly, take note of players' heroes and record necessary information.
    print("Starting Fat-O-Meter.")
    ingame.voteEnableFatOMeter = true
    local maxPlayers = 24
    fatData = {}

    for playerID = 0, (maxPlayers-1) do
        local hero = PlayerResource:GetSelectedHeroEntity(playerID)
        if hero and IsValidEntity(hero) then
            fatData[playerID] = {
                defaultModelScale = hero:GetModelScale(), --this is NOT 1 for most heroes, although some are very close
                prevScaleDifference = 0.0, --stored as difference so we can undo/change the effects without breaking other size-related code
                modelScaleDifference = 0.0, --stored as difference so we can undo/change the effects without breaking other size-related code
                targetScaleDifference = 0.0,
                interpScaleDifference = 0, --interpolates between previous and target scale diff
                maxScalePercent = constants.FAT_SCALING[PlayerResource:GetSelectedHeroName(playerID)] or 3.3,
                lastNetWorth = 0, --stores net worth for gold mode, kill value calculation in kill mode, and level-1 in level mode
                netWorthChange = 0, --stored for faster calculations on gold and levels
                fatness = 0.0, -- 0-100, with 100 being maxScalePercent times default and 0 being default.
            }
        end
    end

    Timers:CreateTimer(function()
        if GameRules:State_Get() < DOTA_GAMERULES_STATE_GAME_IN_PROGRESS or OptionManager:GetOption('useFatOMeter') == 0 then
            return 0.1
        end

        if lastFatThink == nil then
            print("Starting Fat Timers.")
            lastFatThink = -60
        end
        if lastFatAnimate == nil then
            lastFatAnimate = -3.0
        end
        local dotaTime = GameRules:GetDOTATime(false, false)

        while (dotaTime - lastFatThink) > 60 do
            Ingame:FatOMeterThinker(60)
            lastFatThink = lastFatThink + 60
        end
        while (dotaTime - lastFatAnimate) > 3.0 do
            Ingame:FatOMeterAnimate(3.0)
            lastFatAnimate = lastFatAnimate + 3.0
        end
        return 3.0
    end, "fatThink", 0.5)
end

function Ingame:CommandNotification(command, message, cooldown)
    print(command)
    if not self.shownCheats[command] then
        GameRules:SendCustomMessage(message, 0, 0)
        self.shownCheats[command] = true
    end
    if cooldown and cooldown > 0 then
        Timers:CreateTimer(function()
            self.shownCheats[command] = false
        end, DoUniqueString('temporaryblockcommand'), cooldown)
    end
end


function Ingame:fixRuneBug()
    ListenToGameEvent('game_rules_state_change', function(keys)
        local newState = GameRules:State_Get()

        if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
            Timers:CreateTimer(function()
                for playerID=0,DOTA_MAX_TEAM_PLAYERS-1 do
                    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
                    if hero and util:isPlayerBot(playerID) then
                        hero:MoveToPositionAggressive(Vector(0, 0, 0))
                    end
                end
            end, "botRune", 6)
        end
    end, nil)
end

-- Called every 0.1 second to check and convert consumable items into actual consumable items
function Ingame:CheckConsumableItems()

    local itemTable = LoadKeyValues('scripts/kv/consumable_items.kv')
    for i=0,24 do
        if PlayerResource:IsValidTeamPlayerID(i) and not util:isPlayerBot(i) then
            local hero = PlayerResource:GetSelectedHeroEntity(i)
            if hero and IsValidEntity(hero) then
                for i=0,14 do
                    local hItem = hero:GetItemInSlot(i)
                    if hItem then
                        local name = hItem:GetAbilityName()
                        if itemTable[name] then
                            hero:RemoveItem(hItem)
                            if name == "item_vladmir" then name = "item_vladimir" end
                            hero:AddItemByName(name.."_consumable")
                            local item = hero:FindItemInInventory(name.."_consumable")
                            local nSlot, hUseless = hero:FindItemByNameEverywhere(name.."_consumable")
                            hero:SwapItems(i,nSlot)
                            --break
                        end
                    end
                end
            end
        end
    end
end

--General Fat-O-Meter thinker. Runs infrequently (i.e. once every 10 seconds minimum, more likely 30-60). dt is measured in seconds, not ticks.
function Ingame:FatOMeterThinker(dt)
    local this = self
    --if OptionManager:GetOption('useFatOMeter') == 0 then return end
    local maxPlayers = 24

    --FAT-O-METER GOLD MODE--
    if OptionManager:GetOption('useFatOMeter') == 1 then
        local lowestGain = 100000
        for playerID = 0, (maxPlayers-1) do
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            if fatData[playerID] then
                local netWorth = PlayerResource:GetTotalEarnedGold(playerID)

                --Subtract previous net worth to get the intended value.
                local netWorthChange = netWorth - (fatData[playerID].lastNetWorth or 0)

                --Track lowest gain player.
                if netWorthChange < lowestGain then
                    lowestGain = netWorthChange
                end

                --Store discovered data to do scaling calculations. Only netWorthChange is used directly, but both are necessary to function properly.
                fatData[playerID].lastNetWorth = netWorth
                fatData[playerID].netWorthChange = netWorthChange
            end
        end

        --Iterate back through calculated data to set up scaling.
        for playerID in pairs(fatData) do
            --Increase fatness at a rate of 1 per minute for every 100 gpm the player has over the worst player over 0, whichever is higher.
            local weightGain = 0.01*(dt/60)*(fatData[playerID].netWorthChange - math.max(lowestGain, 0))

            --Net loss is fine, as long as the final value is clamped 0-100
            fatData[playerID].fatness = math.max( math.min((fatData[playerID].fatness or 0) + weightGain, 100), 0)
        end

    --FAT-O-METER KILLS MODE--
    elseif OptionManager:GetOption('useFatOMeter') == 2 then
        for playerID = 0, (maxPlayers-1) do
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            if fatData[playerID] then
                local kills = PlayerResource:GetKills(playerID)
                local deaths = PlayerResource:GetDeaths(playerID)
                local assists = PlayerResource:GetAssists(playerID)

                --Assists are weighted as quarter kills and deaths as negative quarter kills
                fatData[playerID].lastNetWorth = 4*kills + assists - deaths
            end
        end

        --Iterate back through calculated data to set up scaling.
        for playerID in pairs(fatData) do
            --No need for delta, just straight-up use the score
            fatData[playerID].fatness = math.max(math.min(fatData[playerID].lastNetWorth, 100), 0)
        end
    end

    --ALL FAT-O-METER MODES--
    --Interpolate the model's actual scale between default and an arbitrary constant times its normal size. Fatness is the percent to interpolate.
    for playerID in pairs(fatData) do
        local fatness = fatData[playerID].fatness
        local default = fatData[playerID].defaultModelScale or 1
        local maxPct = fatData[playerID].maxScalePercent or 3.3 --Assume normal humanoid scale if not specified

        --This looks intimidating, but it's simply an arbitrary power scaling to diminish the effect of early growth while still ultimately reaching max at 100.
        fatData[playerID].targetScaleDifference = default*(maxPct -1)*(math.pow(.17162*fatness, 1.62)/100)
        fatData[playerID].interpScaleDifference = 0
        fatData[playerID].prevScaleDifference = fatData[playerID].modelScaleDifference

        --print("Player "..playerID.." Initial: "..(fatData[playerID].prevScaleDifference).." Final: "..(fatData[playerID].targetScaleDifference))
    end

end

--Does interpolated, short-term size updates for Fat-O-Meter. Called often, don't do anything crazy in here. dt is measured in seconds, not ticks.
function Ingame:FatOMeterAnimate(dt)
    local this = self
    if not OptionManager:GetOption('useFatOMeter') then return end

    for playerID in pairs(fatData) do
        local default = fatData[playerID].defaultModelScale or 0
        local diff = fatData[playerID].modelScaleDifference or 0
        local targetDiff = fatData[playerID].targetScaleDifference or 0
        local interpDiff = fatData[playerID].interpScaleDifference or 1
        local prevDiff = fatData[playerID].prevScaleDifference or 0

        --target is lerped between initial and destination
        interpDiff = math.min(interpDiff + 0.02*dt, 1)
        fatData[playerID].interpScaleDifference = interpDiff
        local target = prevDiff + interpDiff*(targetDiff-prevDiff)

        --Actually do the scaling. Also check for any existing hero clones and modify them.
        local hero = PlayerResource:GetSelectedHeroEntity(playerID)
        if hero and IsValidEntity(hero) then
            hero:SetModelScale(default + target)

            --Meepo/Arc Warden ult checker
            if hero:HasAbility('meepo_divided_we_stand') or hero:HasAbility('arc_warden_tempest_double') or hero:HasAbility('arc_warden_tempest_double_redux') then
                local clones = Entities:FindAllByName(hero:GetClassname())

                for k,heroClone in pairs(clones) do
                    if heroClone:IsClone() and playerID == heroClone:GetPlayerID() then
                        hero:SetModelScale(default + target)
                    end
                end
            end
        end
        fatData[playerID].modelScaleDifference = target
    end
end

function Ingame:returnCustomTeams(eventSourceIndex, args)
    local playerCount = PlayerResource:GetPlayerCount();
    local customTeamAssignments = {};

    local cur_time = Time()
    for playerID = 0, playerCount-1 do
        customTeamAssignments[playerID] = PlayerResource:GetCustomTeamAssignment(playerID);
        if PlayerResource:GetConnectionState(playerID) == 3 then
            if not dc_table[playerID] then
                dc_table[playerID] = cur_time
            end
        else
            dc_table[playerID] = nil
        end
    end

    local dc_timeout = {}
    for i,v in pairs(dc_table) do
        if cur_time - v >= 120 then
            dc_timeout[#dc_timeout + 1] = i
        end
    end

    CustomGameEventManager:Send_ServerToAllClients( "send_custom_team_info", {x = customTeamAssignments, y = dc_timeout} )
end

function Ingame:switchTeam(eventSourceIndex, args)
    local this = self
    this:balancePlayer(args.swapID, args.newTeam)
    Ingame:SetPlayerColors( )
end

-- Balances a player onto another team
function Ingame:balancePlayer(playerID, newTeam)
    -- Balance the player
    PlayerResource:SetCustomTeamAssignment(playerID, newTeam)
    -- Balance their hero
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)

    if IsValidEntity(hero) then
        -- Change the team
        hero:SetTeam(newTeam)
        --hero:SetPlayerID(playerID)
        --hero:SetOwner(PlayerResource:GetPlayer(playerID))



        -- Kill the hero
        hero:Kill(nil, nil)
        hero:SetGold(0, true)

        -- Respawn after 1.11 seconds
        Timers:CreateTimer(function()
            -- Ensure the hero is still valid
            if IsValidEntity(hero) then
                -- Set the time left until we respawn
                hero:SetTimeUntilRespawn(1)

                -- Check if we have any meepo clones
                if hero:HasAbility('arc_warden_tempest_double') or hero:HasAbility('arc_warden_tempest_double_redux') then
                    local clones = Entities:FindAllByName(hero:GetClassname())

                    for k,tempestDouble in pairs(clones) do
                        if tempestDouble:IsTempestDouble() and playerID == tempestDouble:GetPlayerID() then
                            tempestDouble:Kill(nil, nil)
                        end
                    end
                end

                -- Check if we have any meepo clones
                if hero:HasAbility('meepo_divided_we_stand') then
                    local clones = Entities:FindAllByName(hero:GetClassname())

                    for k,meepoClone in pairs(clones) do
                        if meepoClone:IsClone() and playerID == meepoClone:GetPlayerID() then
                            meepoClone:SetTimeUntilRespawn(1)
                        end
                    end
                end
                for spell, name in pairs(ts_entities.Switch) do
                    if hero:HasAbility(spell) then
                        local units = Entities:FindAllByName(name)
                        if #units == 0 then
                            units = Entities:FindAllByModel(name)
                        end

                        for _, unit in pairs(units) do
                            print("found units")
                            if unit:GetPlayerOwnerID() == playerID then
                                unit:SetTeam(newTeam)
                            end
                        end
                    end
                end
                for spell, name in pairs(ts_entities.Kill) do
                    if hero:HasAbility(spell) then
                        local units = Entities:FindAllByName(name)
                        if #units == 0 then
                            units = Entities:FindAllByModel(name)
                        end

                        for _, unit in pairs(units) do
                            if unit:GetPlayerOwnerID() == playerID then
                                unit:Kill(nil, nil)
                            end
                        end
                    end
                end
            end
        end, DoUniqueString('respawn'), 0.2)
    end
end

function otherTeam(team)
    if team == DOTA_TEAM_BADGUYS then
        return DOTA_TEAM_GOODGUYS
    elseif team == DOTA_TEAM_GOODGUYS then
        return DOTA_TEAM_BADGUYS
    end
    return -1
end

-- Sets it to no team balancing is required
function Ingame:setNoTeamBalanceNeeded()
    -- Store state informatiion about team balance
    self.needsTeamBalance = false

    -- Network it
    network:setTeamBalanceData({
        required = false
    })
end

-- Sets balance info
function Ingame:setTeamBalanceInfo(info)
    info = info or {}
    self.radiantPlayers = info.radiantPlayers or self.radiantPlayers or 0
    self.direPlayers = info.direPlayers or self.direPlayers or 0
    self.takeFromTeam = info.takeFromTeam or self.takeFromTeam or 0

    -- Do some minor validation
    if self.takeFromTeam ~= DOTA_TEAM_GOODGUYS and self.takeFromTeam ~= DOTA_TEAM_BADGUYS then
        self:setNoTeamBalanceNeeded()
        return
    end

    -- Store state
    self.needsTeamBalance = true

    -- Network it
    network:setTeamBalanceData({
        required = true,
        takeFromTeam = self.takeFromTeam
    })

    print('balancing = '..self.takeFromTeam)
end

-- Checks balance stuff in the next tick
function Ingame:checkBalanceTeamsNextTick()
    local this = self

    -- Give a small delay then check for team balancing
    Timers:CreateTimer(function()
        this:checkBalanceTeams()
    end, DoUniqueString('balanceChecker'), 0)
end

-- Called to check if teams need to be balanced
function Ingame:checkBalanceTeams()
    local maxPlayers = 24

    local radiantPlayers = 0
    local direPlayers = 0

    for playerID = 0,(maxPlayers-1) do
        local state = PlayerResource:GetConnectionState(playerID)

        if state == 1 or state == 2 then
            local team = PlayerResource:GetCustomTeamAssignment(playerID)

            if team == DOTA_TEAM_GOODGUYS then
                radiantPlayers = radiantPlayers + 1
            elseif team == DOTA_TEAM_BADGUYS then
                direPlayers = direPlayers + 1
            end
        end
    end

    -- Can balancing occur?
    if math.abs(radiantPlayers - direPlayers) > 1 then
        -- Decide which team to take players from
        local takeFromTeam = DOTA_TEAM_GOODGUYS
        if radiantPlayers < direPlayers then
            takeFromTeam = DOTA_TEAM_BADGUYS
        end

        -- Store balance info
        self:setTeamBalanceInfo({
            radiantPlayers = radiantPlayers,
            direPlayers = direPlayers,
            takeFromTeam = takeFromTeam
        })
    else
        -- Can't balance
        self:setNoTeamBalanceNeeded()
    end
end

function Ingame:balanceGold()
	-- If game not started dont check balance
	if (GameRules:GetDOTATime(false,false) == 0 or util:isCoop()) and not IsInToolsMode() then
		return
	end

	local RadiantPlayers = util:GetActivePlayerCountForTeam(DOTA_TEAM_GOODGUYS)
	local DirePlayers = util:GetActivePlayerCountForTeam(DOTA_TEAM_BADGUYS)
	local losingTeam = nil
	local fountainArea = nil

	-- If balance returns, clear the slate
	if RadiantPlayers == DirePlayers then
		self.timeImbalanceStarted = 0
		self.radiantBalanceMoney = 0
		self.direBalanceMoney = 0
		return
	end

	if RadiantPlayers < DirePlayers then
		losingTeam = "goodGuys"
		fountainArea = Vector(-6327.858398, -5892.900391, 384.000000)
	else
		losingTeam = "badGuys"
		fountainArea = Vector(6234.006348, 5780.487305, 384.000000)
	end

	if self.timeImbalanceStarted == 0 then
		self.timeImbalanceStarted = GameRules:GetDOTATime(false,false)
	end

	local timeSinceLastCheck = GameRules:GetDOTATime(false,false) - self.timeImbalanceStarted
	--print(timeSinceLastCheck)

	if timeSinceLastCheck > 180 then
		local multiplier = 1
		if losingTeam == "goodGuys" then
			multiplier = DirePlayers - RadiantPlayers
		else
			multiplier = RadiantPlayers - DirePlayers
		end

		local moneyToGive = (180 * multiplier) * OptionManager:GetOption('goldPerTick')

		if losingTeam == "goodGuys" then
			self.radiantBalanceMoney = self.radiantBalanceMoney + moneyToGive
		else
			self.direBalanceMoney = self.direBalanceMoney + moneyToGive
		end

		self.timeImbalanceStarted = GameRules:GetDOTATime(false,false)
		--print(moneyToGive)
		--print(self.radiantBalanceMoney)
		--print(self.direBalanceMoney)
	end

	local moneySize = 10
	if self.direBalanceMoney >= 200 or self.radiantBalanceMoney >= 200 then
		moneySize = 20
	end

	if self.radiantBalanceMoney >= moneySize * 10 or self.direBalanceMoney >= moneySize * 10 then
		for playerID=0,24-1 do
	      local hero = PlayerResource:GetSelectedHeroEntity(playerID)
	      if hero and PlayerResource:IsValidPlayerID(playerID) and IsValidEntity(hero) then
	          local state = PlayerResource:GetConnectionState(playerID)
	          if state == 1 or state == 2 then
	          	if losingTeam == "goodGuys" and hero:GetTeam() == DOTA_TEAM_GOODGUYS and self.radiantBalanceMoney >= 1 then
	          		hero:ModifyGold(moneySize, false, 0)
	          		SendOverheadEventMessage(hero:GetPlayerOwner(), OVERHEAD_ALERT_GOLD, hero, moneySize, nil)
	          		self.radiantBalanceMoney = self.radiantBalanceMoney - moneySize
                    self.radiantTotalBalanceMoney = self.radiantTotalBalanceMoney + moneySize
	          	elseif losingTeam == "badGuys" and hero:GetTeam() == DOTA_TEAM_BADGUYS and self.direBalanceMoney >= 1 then
	          		hero:ModifyGold(moneySize, false, 0)
	          		SendOverheadEventMessage(hero:GetPlayerOwner(), OVERHEAD_ALERT_GOLD, hero, moneySize, nil)
	          		self.direBalanceMoney = self.direBalanceMoney - moneySize
                    self.direTotalBalanceMoney = self.direTotalBalanceMoney + moneySize
	          	end
	          end
	      end
	    end
	end

    -- Display message once every while, informing players of balance mechanic in use
    if self.heard["balanceGold"] ~= true and (self.radiantTotalBalanceMoney > 0 or self.direTotalBalanceMoney > 0) then

        if losingTeam == "goodGuys" then
            GameRules:SendCustomMessage("Radiant Team has recieved the following total bonus gold due to team-imbalance: <font color=\'#FFDD2C\'>" .. self.radiantTotalBalanceMoney .. "</font>", 0, 0)
        else
            GameRules:SendCustomMessage("Dire Team has recieved the following total bonus gold due to team-imbalance: <font color=\'#FFDD2C\'>" .. self.direTotalBalanceMoney .. "</font>", 0, 0)
        end


        self.heard["balanceGold"] = true

        -- Show the warning again after 10 minutes
        Timers:CreateTimer( function()
            self.heard["balanceGold"] = false
        end, DoUniqueString('showNotifAgain'), 600)
    end

end

-- Increases respawn rate if the game has been going longer than 40 minutes, increases every 10 minutes after that
function Ingame:checkIfRespawnRate()
    if util:isSinglePlayerMode() then return end
    local respawnModifierPercentage = OptionManager:GetOption('respawnModifierPercentage')
    if GameRules:GetDOTATime(false,false) > self.timeToIncreaseRespawnRate and respawnModifierPercentage < 50 and self.voteDisableRespawnLimit == false then
        if self.origianlRespawnRate == nil then
            self.origianlRespawnRate = respawnModifierPercentage
        end
        local newRespawnRate = respawnModifierPercentage + 10
        if newRespawnRate > 50 then
            newRespawnRate = 50
        end
        GameRules:SendCustomMessage("Games has been going for too long, respawn rates have increased by 10%. New respawn rate is " .. newRespawnRate .. "%. Use -enablerespawn (-er) to disable this safeguard.", 0, 0)
        OptionManager:SetOption('respawnModifierPercentage', newRespawnRate)

        self.timeToIncreaseRespawnRate = self.timeToIncreaseRespawnRate + self.timeToIncreaseRepawnInterval
    end

end

-- Respawn modifier
function Ingame:handleRespawnModifier()
    ListenToGameEvent('entity_killed', function(keys)
        -- Ensure our respawn modifier is in effect
        local respawnModifierPercentage = OptionManager:GetOption('respawnModifierPercentage')
        local respawnModifierConstant = OptionManager:GetOption('respawnModifierConstant')

        self:checkIfRespawnRate()
        self:balanceGold()

        --if respawnModifierPercentage == 100 and respawnModifierConstant == 0 then return end

        -- Grab the killed entity (it isn't nessessarily a hero!)
        local hero = EntIndexToHScript(keys.entindex_killed)

        -- Ensure it is a hero
        if IsValidEntity(hero) then
            if hero:IsHero() then
                -- Ensure we are not using aegis!
                if hero:IsReincarnating() then
                    local reincarnation = hero:FindAbilityByName("skeleton_king_reincarnation")
                    local reincarnation2 = hero:FindAbilityByName("skeleton_king_reincarnation_redux")
                    if reincarnation then
                        local respawnTime = reincarnation:GetSpecialValueFor("reincarnate_time")
                        if reincarnation:GetTrueCooldown() - reincarnation:GetCooldownTimeRemaining() < respawnTime - 1 then
                            hero:SetTimeUntilRespawn(respawnTime)
                        end
                    else
                        hero:SetTimeUntilRespawn(5)
                    end
                    if reincarnation2 then
                        local respawnTime = reincarnation2:GetSpecialValueFor("reincarnate_time")
                        if reincarnation2:GetTrueCooldown() - reincarnation2:GetCooldownTimeRemaining() < respawnTime - 1 then
                            hero:SetTimeUntilRespawn(respawnTime)
                        end
                    else
                        hero:SetTimeUntilRespawn(5)
                    end
                return end
                local playerID = hero:GetPlayerID()
                local mainHero = PlayerResource:GetSelectedHeroEntity(playerID)
                if hero == mainHero or (hero:HasAbility("meepo_divided_we_stand") and hero:GetUnitName() == mainHero:GetUnitName() and hero:IsClone()) then
                    hero = mainHero
                    Timers:CreateTimer(function()
                        if IsValidEntity(hero) and not hero:IsAlive() then
                            local timeLeft = hero:GetRespawnTime()

                            --hotfix start: stop heros from having crazy respawn times
                            if hero:GetLevel() > 25 then
                                timeLeft = 4 * hero:GetLevel()
                            end
                            if timeLeft > 160 then
                                timeLeft = 160
                            end
                            --hotfix end

                            timeLeft = timeLeft * respawnModifierPercentage / 100 + respawnModifierConstant

                            if timeLeft <= 0 then
                                timeLeft = 1
                            end

                            --[[if respawnModifier < 0 then
                                timeLeft = -respawnModifier
                            else
                                timeLeft = timeLeft / respawnModifier
                            end]]

                            -- If the game is single player, it should let players know that they can force respawn. Notify after first death, and notified a second time if their respawn time is longer than 30 seconds.
                            --print(RespawnNotificationLevel)
                            if not util:isPlayerBot(playerID) then
                                if util:isSinglePlayerMode() or Convars:GetBool("sv_cheats") or self.voteEnabledCheatMode then
    	                            if not hero.RespawnNotificationLevel then
    	                                hero.RespawnNotificationLevel = 0
    	                            end
    	                            if hero.RespawnNotificationLevel < 2 then
    	                                if hero.RespawnNotificationLevel == 0 then
    	                                    GameRules:SendCustomMessage('#respawnCheatNotification', 0, 0)
    	                                    hero.RespawnNotificationLevel = 1
    	                                elseif hero.RespawnNotificationLevel == 1 and timeLeft > 30 then
    	                                    GameRules:SendCustomMessage('#respawnCheatNotification', 0, 0)
    	                                    hero.RespawnNotificationLevel = 2
    	                                end
    	                            end
                                end
                        	end

                            -------
                            -- Imbalanced-Comepenstation Mechanic Start
                            -------
                            -- Do not trigger if game is coop or gametime is more than 20 minutes
                            if not util:isCoop() and GameRules:GetDOTATime(false,false) < self.timeToStopBalancingMechanic then
                                local herosTeam = util:GetActivePlayerCountForTeam(hero:GetTeamNumber())
                                local opposingTeam = util:GetActivePlayerCountForTeam(otherTeam(hero:GetTeamNumber()))
                                local difference = herosTeam - opposingTeam
                                -- Disadvantaged teams gain 10 seconds faster respawn, advantaged team, 10 seconds longer
                                local addedTime = 0
                                if difference < 0 then
                                    addedTime = -10
                                elseif difference > 0 then
                                    addedTime = 10
                                end

                                timeLeft = timeLeft + addedTime

                                if timeLeft < 1 then
                                    timeLeft = 1
                                end

                                -- Display message once every while, informing players of balance mechanic in use
                                if addedTime ~= 0 and self.heard["imbalancedTeams"] ~= true then
                                    GameRules:SendCustomMessage("#imbalance_notification", 0, 0)
                                    self.heard["imbalancedTeams"] = true

                                    -- Show the warning again after 10 minutes
                                    Timers:CreateTimer( function()
                                        self.heard["imbalancedTeams"] = false
                                    end, DoUniqueString('showNotifAgain'), 600)
                                end
                            end

                            -------
                            -- Imbalanced-Comepenstation Mechanic End
                            ------

                            -------
                            -- Anti-Kamikaze Mechanic START
                            -- This is designed to stop players from spawning very quicky and dying very quickly, e.g pushing towers
                            -------
                            if not util:isPlayerBot(playerID) and self.voteDisableAntiKamikaze == false then
                                local allowableSecsBetweenDeaths = 60
                                if not hero.lastDeath then
                                    hero.lastDeath = GameRules:GetDOTATime(false, false)
                                else
                                    timeSinceLastDeath = GameRules:GetDOTATime(false, false) - hero.lastDeath
                                    hero.lastDeath = GameRules:GetDOTATime(false, false)
                                    -- If they have died a few seconds after respawning, increase Kamikaze rating
                                    if timeSinceLastDeath <= allowableSecsBetweenDeaths then
                                        if not hero.KamikazeRating then
                                            hero.KamikazeRating = 1
                                        else
                                            hero.KamikazeRating = hero.KamikazeRating +1
                                            if hero.KamikazeRating > 2 then
                                                GameRules:SendCustomMessage('Player '..PlayerResource:GetPlayerName(playerID)..' has died at least 3 times in the last ' .. allowableSecsBetweenDeaths .. " seconds. To prevent Kamikaze tactics, they have incured <font color=\'#FF4949\'>extra respawn time</font>. Use -enablekamikaze (-ek) to disable this safeguard." , 0, 0)
                                                -- If they continue this strat, extra respawn peanlty increases by 10 seconds
                                                if not hero.KamikazePenalty then
                                                    hero.KamikazePenalty = 1
                                                else
                                                    hero.KamikazePenalty = hero.KamikazePenalty + 1
                                                end
                                                timeLeft = timeLeft + (hero.KamikazePenalty * 10)
                                            end
                                        end

                                        -- After the the allowable time between deaths, lower the rating
                                        Timers:CreateTimer( function()
                                            if hero.KamikazeRating and hero.KamikazeRating > 0 then
                                               hero.KamikazeRating = hero.KamikazeRating - 1
                                            end
                                        end, DoUniqueString('lowerKamikazeRating'), allowableSecsBetweenDeaths)
                                    end
                                end
                            end
                            -------
                            -- Anti-Kamikaze Mechanic END
                            -------

                            --------
                            -- Resurrect Mutator start
                            ---------

                            if OptionManager:GetOption('resurrectAllies') == 1 then
                                local numb = math.min(60,math.max(1,math.ceil(timeLeft/3)))
                                
                                -- If the number is higher than 3, reduce the time by 2 seconds
                                if numb > 3 then 
                                    numb = numb - 2
                                end

                                local newItem = CreateItem("item_tombstone_"..numb,hero:GetPlayerOwner(),hero:GetPlayerOwner())

                                newItem:SetPurchaseTime(0)
                                newItem:SetPurchaser(hero)

                                local tombstone = SpawnEntityFromTableSynchronous("dota_item_tombstone_drop",{})
                                
                                tombstone:SetContainedItem(newItem)
                                if hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
                                    --tombstone:SetModel("models/heroes/phantom_assassin/arcana_tombstone2.vmdl")
                                else
                                    --tombstone:SetModel("models/heroes/phantom_assassin/arcana_tombstone3.vmdl")
                                end
                                tombstone:SetAbsOrigin(hero:GetAbsOrigin())
                                tombstone:SetAngles(0, 90, 0)
                            end
                            --------
                            -- Resurrect Mutator END
                            ---------
                            
                            hero:SetTimeUntilRespawn(timeLeft)

                            -- Give 322 gold if enabled
                            if OptionManager:GetOption('322') == 1 then
                                if OptionManager:GetOption('mapname') == "overthrow" then
                                    myTeamKills = GetTeamHeroKills(hero:GetTeamNumber())
                                    opponentTeamKills = GetTeamHeroKills(otherTeam(hero:GetTeamNumber()))

                                    if myTeamKills < opponentTeamKills then
                                        hero:ModifyGold(322,false,0)
                                        SendOverheadEventMessage(hero:GetPlayerOwner(), OVERHEAD_ALERT_GOLD, hero, 322, nil)
                                    end

                                else
                                    hero:ModifyGold(322,false,0)
                                    SendOverheadEventMessage(hero:GetPlayerOwner(), OVERHEAD_ALERT_GOLD, hero, 322, nil)
                                end

                            end
                            -- Refresh cooldowns if enabled
                            if OptionManager:GetOption('refreshCooldownsOnDeath') == 1 or ingame.voteEnableRefresh == true then
                                for i = 0, 15 do
                                    local ability = hero:GetAbilityByIndex(i)
                                    if ability then
                                        ability:EndCooldown()
                                    end
                                end
                                for j = 0, 5 do
                                    local item = hero:GetItemInSlot(j)
                                    if item and item:GetName() ~= "item_bloodstone" then
                                        item:EndCooldown()
                                    end
                                end
                            end
                            -- Check if we have any meepo clones
                            if hero:HasAbility('meepo_divided_we_stand') then
                                local clones = Entities:FindAllByName(hero:GetClassname())

                                for k,meepoClone in pairs(clones) do
                                    if meepoClone:IsClone() and playerID == meepoClone:GetPlayerID() then
                                        meepoClone:SetTimeUntilRespawn(timeLeft)
                                    end
                                end
                            end
                        end
                    end, DoUniqueString('respawn'), 0.1)
                end
            end
        end
    end, nil)
end

-- Init gold balancer
function Ingame:initGoldBalancer()
    -- recalculate player team counts
    self:recalculatePlayerCounts()

    -- Filter event
    GameRules:GetGameModeEntity():SetModifyGoldFilter(Dynamic_Wrap(Ingame, "FilterModifyGold" ), self)
    GameRules:GetGameModeEntity():SetModifyExperienceFilter(Dynamic_Wrap(Ingame, "FilterModifyExperience" ), self)
    GameRules:GetGameModeEntity():SetBountyRunePickupFilter(Dynamic_Wrap( Ingame, "BountyRunePickupFilter" ), self )

    local this = self

    -- Hook recalculations
    ListenToGameEvent('player_connect', function(keys)
        GameRules:GetGameModeEntity():SetThink(function()
            -- Recalculate the counts
            this:recalculatePlayerCounts()
        end, 'calcPlayerTotals', 1, nil)
    end, nil)

    ListenToGameEvent('player_connect_full', function(keys)
        GameRules:GetGameModeEntity():SetThink(function()
            -- Recalculate the counts
            this:recalculatePlayerCounts()
        end, 'calcPlayerTotals', 1, nil)
    end, nil)

    ListenToGameEvent('player_disconnect', function(keys)
        GameRules:GetGameModeEntity():SetThink(function()
            -- Recalculate the counts
            this:recalculatePlayerCounts()
        end, 'calcPlayerTotals', 1, nil)
    end, nil)

    ListenToGameEvent('game_rules_state_change', function(keys)
        GameRules:GetGameModeEntity():SetThink(function()
            -- Recalculate the counts
            this:recalculatePlayerCounts()
        end, 'calcPlayerTotals', 1, nil)
    end, nil)
end

-- Counts how many players on each team
function Ingame:recalculatePlayerCounts()
    local this = self

    if not pcall(function()
        -- Default to no players
        this.playersOnTeam = {
            radiant = 0,
            dire = 0
        }

        -- Work it out
        for i=0,9 do
            local connectionState = PlayerResource:GetConnectionState(i)
            if connectionState == 1 or connectionState == 2 then
                local teamID = PlayerResource:GetTeam(i)

                if teamID == DOTA_TEAM_GOODGUYS then
                    this.playersOnTeam.radiant = this.playersOnTeam.radiant + 1
                elseif teamID == DOTA_TEAM_BADGUYS then
                    this.playersOnTeam.dire = this.playersOnTeam.dire + 1
                end
            end
        end

        -- Ensure never less than one
        for k,v in pairs(this.playersOnTeam) do
            if v <= 0 then
                this.playersOnTeam[k] = 1
            end
        end
    end) then
        this.playersOnTeam = {
            radiant = 1,
            dire = 1
        }
    end
end

-- Attempt to balance gold
function Ingame:FilterModifyGold(filterTable)
    -- Grab useful information
    local playerID = filterTable.player_id_const
    local teamID = PlayerResource:GetTeam(playerID)

    -- Grab the gold modifier
    local goldModifier = OptionManager:GetOption('goldModifier')

    --print(filterTable.gold)
    if goldModifier ~= 1 then
        -- If the gold is from killing heroes, creeps, or roshan, do nothing, its handled in pregame.lua
        if filterTable.reason_const ~= 12 and filterTable.reason_const ~= 13 and filterTable.reason_const ~= 14 then
            filterTable.gold = math.ceil(filterTable.gold * goldModifier / 100)
        end
    end
    --print(filterTable.gold)

    -- Disabled this due to other balance mechanics being in play

    --local myTeam = 1
    --local enemyTeam = 1

    --if teamID == DOTA_TEAM_GOODGUYS then
    --    myTeam = self.playersOnTeam.radiant
    --    enemyTeam = self.playersOnTeam.dire
    --elseif teamID == DOTA_TEAM_BADGUYS then
    --    myTeam = self.playersOnTeam.dire
    --    enemyTeam = self.playersOnTeam.radiant
    --end

    -- Slow down the gold intake for the team with more players
    --local ratio = enemyTeam / myTeam
    --if ratio < 1 then
    --    ratio = 1 - (1 - ratio) / 2
    --
    --    filterTable.gold = math.ceil(filterTable.gold * ratio)
    --end

    return true
end

-- Option to modify EXP
function Ingame:FilterModifyExperience(filterTable)
    local expModifier = OptionManager:GetOption('expModifier')
    --hotfix start: to stop the insane amount of EXP when heros with higher level then 28, kill other heros
    if math.abs(filterTable.experience) > 100000 then
        local Hero = PlayerResource:GetPlayer(filterTable.player_id_const):GetAssignedHero()
        Hero:AddExperience(math.ceil(250 * expModifier / 100),0,false,false)
        filterTable.experience = 0
        return true
    end
    --hotfix end


    if expModifier ~= 1 then
        filterTable.experience = math.ceil(filterTable.experience * expModifier / 100)
    end

    if PlayerResource:GetPlayer(filterTable.player_id_const) then
        local team = PlayerResource:GetPlayer(filterTable.player_id_const):GetTeamNumber()

        if OptionManager:GetOption('sharedXP') == 1 then
            if filterTable.reason_const ~= 0 then
                for i=0,DOTA_MAX_TEAM do
                    local pID = PlayerResource:GetNthPlayerIDOnTeam(team,i)
                    if (PlayerResource:IsValidPlayerID(pID) or PlayerResource:GetConnectionState(pID) == 1) and PlayerResource:GetPlayer(pID) then
                        local otherHero = PlayerResource:GetPlayer(pID):GetAssignedHero()

                        otherHero:AddExperience(math.ceil(filterTable.experience / util:GetActivePlayerCountForTeam(team)),0,false,false)
                    end
                end

                return false
            else
                return true
            end
        else
            return true
        end
    end
end

function Ingame:BountyRunePickupFilter(filterTable)
    --if OptionManager:GetOption('superRunes') == 1 then
    --    filterTable.xp_bounty = filterTable.xp_bounty * 2
    --    filterTable.gold_bounty = filterTable.gold_bounty * 2
    --end

    if OptionManager:GetOption('sharedXP') == 1 then
        local team = PlayerResource:GetPlayer(filterTable.player_id_const):GetTeamNumber()

        for i=0,DOTA_MAX_TEAM do
            local pID = PlayerResource:GetNthPlayerIDOnTeam(team,i)
            if PlayerResource:IsValidPlayerID(pID) then
                local player = PlayerResource:GetPlayer(pID)
                if player ~= nil then
                    local otherHero = player:GetAssignedHero()

                    otherHero:AddExperience(math.ceil(filterTable.xp_bounty / util:GetActivePlayerCountForTeam(team)),0,false,false)
                    otherHero.expSkip = true
                end
            end
        end

        filterTable["xp_bounty"] = 0
    end

    return true
end

-- This function relates to true random which isnt in the game anymore
--function Ingame:OnAbilityUsed(event)
--    local PlayerID = event.PlayerID
--    local abilityname = event.abilityname
--    local hero = PlayerResource:GetSelectedHeroEntity(PlayerID)
--    local ability = hero:FindAbilityByName(abilityname)
--    if not ability then return end
--    if ability.randomRoot then
--        local randomMain = hero:FindAbilityByName(ability.randomRoot)
--        print(ability.randomRoot)
--        if not randomMain then return end
--        if abilityname == randomMain.randomAb then
--            randomMain:OnChannelFinish(true)
--            randomMain:OnAbilityPhaseStart()
--        end
--    end
--end

-- Buyback cooldowns
function Ingame:checkBuybackStatus()
    ListenToGameEvent('npc_spawned',
    function(keys)
        local unit = EntIndexToHScript(keys.entindex)

        if IsValidEntity(unit) then
            if unit:IsRealHero() then
                Timers:CreateTimer(
                function()
                    if IsValidEntity(unit) and OptionManager:GetOption('buybackCooldownConstant') ~= 420 then
                        local buyBackLeft = unit:GetBuybackCooldownTime()
                        if buyBackLeft >= 420 then
                            local maxCooldown = OptionManager:GetOption('buybackCooldownConstant')
                            if buyBackLeft > maxCooldown then
                                unit:SetBuybackCooldownTime(maxCooldown)
                            end
                        end
                    end
                end, DoUniqueString('buyback'), 0.1)

                if OptionManager:GetOption('randomOnDeath') == 1 and not unit:IsReincarnating() then
                    local pID = unit:GetPlayerOwnerID()
                    if not util:isPlayerBot(pID) then
                        if not unit.randomOnDeath then
                            unit.randomOnDeath = true
                        else
                            
                            GameRules.pregame.selectedSkills[pID] = {}
                            GameRules.pregame.selectedHeroes[pID] = GameRules.pregame:getRandomHero()
                            GameRules.pregame.selectedPlayerAttr[pID] = ({'str', 'agi', 'int'})[math.random(1,3)]
                            if util:isPlayerBot(pID) and GameRules.pregame.botPlayers then
                                GameRules.pregame.botPlayers.all[pID] = {}
                                GameRules.pregame:generateBotBuilds(pID)

                                GameRules.pregame.selectedSkills[pID] = GameRules.pregame.botPlayers.all[pID].build
                                GameRules.pregame.selectedHeroes[pID] = GameRules.pregame.botPlayers.all[pID].heroName
                            end
                            GameRules.pregame:onPlayerReady(nil, {PlayerID = pID, randomOnDeath = true})
                            if not util:isPlayerBot(pID) then
                                GameRules.pregame:applyExtraAbility(PlayerResource:GetSelectedHeroEntity(pID))
                            end
                        end
                    end
                end
            elseif CustomNetTables:GetTableValue("phase_ingame","duel") and CustomNetTables:GetTableValue("phase_ingame","duel").active == 1 and (string.match(unit:GetUnitName(), "badguys") or string.match(unit:GetUnitName(), "goodguys")) then
                unit:ForceKill(false)
            end
        end
    end, nil)
end

function Ingame:AddTowerBotController()

    ListenToGameEvent('game_rules_state_change', function(keys)


        local newState = GameRules:State_Get()
        -- If Towers are default amount (3), do not use bot controller because bots can handle them
        if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS and OptionManager:GetOption('towerCount') ~= 3 then
            local maxPlayers = 24
            local direBots = false
            local radiantBots = false
            -- CHECK ALL PLAYERS TO SEE WHICH TEAM HAS BOT(S)
            for playerID=0,(maxPlayers-1) do
                if util:isPlayerBot(playerID) and PlayerResource:GetTeam(playerID) == DOTA_TEAM_GOODGUYS then
                    radiantBots = true
                elseif util:isPlayerBot(playerID) and PlayerResource:GetTeam(playerID) == DOTA_TEAM_BADGUYS then
                    direBots = true
                end
            end

            local towers = Entities:FindAllByClassname('npc_dota_tower')

            for _, tower in pairs(towers) do
                    -- IF DIRE BOTS EXIST GIVE RADIANT TOWERS THE BOT CONTROLLER ABILITY
                    if direBots and tower:GetTeam() == DOTA_TEAM_GOODGUYS then
                        tower:AddAbility("imba_tower_ai_controller")
                        tower:AddAbility("lone_druid_savage_roar_tower")
                        local abilityController = tower:FindAbilityByName("imba_tower_ai_controller")
                        local abilityRoar = tower:FindAbilityByName("lone_druid_savage_roar_tower")
                        abilityController:SetLevel(1)
                        abilityRoar:SetLevel(1)
                    -- IF RADIANT BOTS EXIST GIVE DIRE TOWERS THE BOT CONTROLLER ABILITY
                    elseif radiantBots and tower:GetTeam() == DOTA_TEAM_BADGUYS then
                        tower:AddAbility("imba_tower_ai_controller")
                        tower:AddAbility("lone_druid_savage_roar_tower")
                        local abilityController = tower:FindAbilityByName("imba_tower_ai_controller")
                        local abilityRoar = tower:FindAbilityByName("lone_druid_savage_roar_tower")
                        abilityController:SetLevel(1)
                        abilityRoar:SetLevel(1)
                    end

                end
        end
    end, nil)

end

function Ingame:loadTrollCombos()
    -- Load in the ban list
    local tempBanList = LoadKeyValues('scripts/kv/bans.kv')

    -- Create the stores
    self.banList = {}

    -- Bans a skill combo
    local function banCombo(a, b)
        self.banList[a] = self.banList[a] or {}
        self.banList[b] = self.banList[b] or {}

        self.banList[a][b] = true
        self.banList[b][a] = true
    end

    -- Loop over the banned combinations
    for skillName, group in pairs(tempBanList.BannedTowerCombinations) do
        for skillName2,_ in pairs(group) do
            banCombo(skillName, skillName2)
        end
    end

    -- Ban the group bans
    for _,group in pairs(tempBanList.BannedTowerGroups) do
        for skillName,__ in pairs(group) do
            for skillName2,___ in pairs(group) do
                banCombo(skillName, skillName2)
            end
        end
    end
end

function Ingame:giveAntiRatProtection()
    local towers = Entities:FindAllByClassname('npc_dota_tower')

    self.destroyedTowers = self.destroyedTowers or {}

    local radiantTowers = 0
    local direTowers = 0
    for k,v in pairs(towers) do
        if not v:IsNull() and v:IsAlive() then
            if v:GetTeamNumber() == 2 and not v:HasModifier("modifier_redux_tower_ability") then
                radiantTowers = radiantTowers + 1
            elseif v:GetTeamNumber() == 3 and not v:HasModifier("modifier_redux_tower_ability") then
                direTowers = direTowers + 1
            end
        end
    end
    --print(radiantTowers)
    --print(direTowers)
    -- If either team's towers is at the point where anti-rat is disabled, do nothing.
    if direTowers <= 5 or radiantTowers <=5 then
        return
    end

    for k,v in pairs(towers) do
        table.insert(self.destroyedTowers, v)
        if string.match(v:GetUnitName(), "3") then
            v:AddAbility("tower_anti_rat"):SetLevel(1)
        end
    end
end

function Ingame:updateStrongTowers(tower)
    self.towerList = LoadKeyValues('scripts/kv/towers.kv')
    self.usedRandomTowers = {}

    local handledTowers = {}

    if not handledTowers[tower] then
        -- Main ability handling
        local difference = 0 -- will always be 0 anyway
        tower.strongTowerAbilities = tower.strongTowerAbilities or {}
        local abName = PullTowerAbility(self.towerList, self.usedRandomTowers, self.banList, tower.strongTowerAbilities, difference, tower:GetLevel() * 10, tower)
        if not tower:HasAbility(abName) and abName then
            tower:AddAbility(abName):SetLevel(1)
            self.usedRandomTowers[abName] = true
            handledTowers[tower] = true
            table.insert(tower.strongTowerAbilities, abName)
        end

        tower:AddAbility("imba_tower_counter")
        tower:FindAbilityByName("imba_tower_counter"):SetLevel(1)
    end
end

function Ingame:addStrongTowers()
    ListenToGameEvent('game_rules_state_change', function(keys)
        local newState = GameRules:State_Get()
        if newState == DOTA_GAMERULES_STATE_PRE_GAME then
            if OptionManager:GetOption('antiRat') == 1 then
                self:giveAntiRatProtection()
            end
        elseif newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
            if OptionManager:GetOption('strongTowers') then
                local maxPlayers = 24
                local botsEnabled = false
                for playerID=0,(maxPlayers-1) do
                    if util:isPlayerBot(playerID) then
                        botsEnabled = true
                    end
                end

                self.towerList = LoadKeyValues('scripts/kv/towers.kv')
                self.usedRandomTowers = {}

                local towers = Entities:FindAllByClassname('npc_dota_tower')
                local handledTowers = {}

                for _, tower in pairs(towers) do
                    if not handledTowers[tower] then
                        -- Main ability handling
                        local difference = 0 -- will always be 0 anyway
                        tower.strongTowerAbilities = tower.strongTowerAbilities or {}
                        local abName = PullTowerAbility(self.towerList, self.usedRandomTowers, self.banList, tower.strongTowerAbilities, difference, tower:GetLevel() * 10, tower)
                        if not tower:HasAbility(abName) and abName then
                            tower:AddAbility(abName):SetLevel(1)
                            self.usedRandomTowers[abName] = true
                            handledTowers[tower] = true
                            table.insert(tower.strongTowerAbilities, abName)
                        end

                        -- Find sister tower, only relevant for tiers below 4
                        if tower:GetLevel() < 4 then
                            local sisterTower = FindSisterTower(tower)
                            -- Sister ability handling
                            difference = GetTowerAbilityPowerValue(sisterTower, self.towerList) - GetTowerAbilityPowerValue(tower, self.towerList)
                            sisterTower.strongTowerAbilities = sisterTower.strongTowerAbilities or {}
                            local sisterAbName = PullTowerAbility(self.towerList, self.usedRandomTowers, self.banList, tower.strongTowerAbilities, difference, sisterTower:GetLevel() * 10, tower)
                            if not tower:HasAbility(abName) and abName then
                                sisterTower:AddAbility(sisterAbName):SetLevel(1)
                                self.usedRandomTowers[sisterAbName] = true
                                handledTowers[sisterTower] = true
                                table.insert(sisterTower.strongTowerAbilities, sisterAbName)
                            end
                            -- Assign sister towers permanently
                            tower.sisterTower = sisterTower
                            sisterTower.sisterTower = tower
                            print(tower:GetUnitName(), sisterTower:GetUnitName())
                        end

                        tower:AddAbility("imba_tower_counter")
                        tower:FindAbilityByName("imba_tower_counter"):SetLevel(1)
                    end
                end
                print("lul")
            end
        end
    end, nil)
    ListenToGameEvent('dota_tower_kill', function (keys)
        -- If a tower is destroyed, there is a 2/3 chance for bots to switch/stay in lategame behaviour. There is a 1/3 chance they will switch back to early game behaviour (but only for 3 minutes).
        local switchAI = (RandomInt(1,3))
        if switchAI == 1 then
            --print("bots are in early game behaviour")
            self.botsInLateGameMode = false
            GameRules:GetGameModeEntity():SetBotsInLateGame(self.botsInLateGameMode)
            Timers:CreateTimer(function()
                self.botsInLateGameMode = true
                GameRules:GetGameModeEntity():SetBotsInLateGame(self.botsInLateGameMode)
            end, DoUniqueString('makesBotsLateGameAgain'), 180)
        else
            --print("bots are in late game behaviour")
            self.botsInLateGameMode = true
            GameRules:GetGameModeEntity():SetBotsInLateGame(self.botsInLateGameMode)
        end

        if OptionManager:GetOption('antiRat') == 1 then
            local towers = Entities:FindAllByClassname('npc_dota_tower')

            local direIsDead = 0
            local radiantIsDead = 0

            for k,v in pairs(towers) do
                if not v:IsNull() and v:IsAlive() and not v:HasModifier("modifier_redux_tower_permanent") then
                    if v:GetTeamNumber() == 2 then
                        radiantIsDead = radiantIsDead + 1
                    else
                        direIsDead = direIsDead + 1
                    end
                end
            end

            for k,v in pairs(towers) do
                if string.match(v:GetUnitName(), "3") then
                    if radiantIsDead == 5 and v:GetTeamNumber() == 2 then
                        v:RemoveAbility("tower_anti_rat")
                        v:RemoveModifierByName("modifier_tower_anti_rat")
                    elseif direIsDead == 5 and v:GetTeamNumber() == 3 then
                        v:RemoveAbility("tower_anti_rat")
                        v:RemoveModifierByName("modifier_tower_anti_rat")
                    end
                end
            end
        end

        if OptionManager:GetOption('strongTowers') then
            local tower_team = keys.teamnumber
            local towers = Entities:FindAllByClassname('npc_dota_tower')
            for _, tower in pairs(towers) do
                if tower:GetTeamNumber() == tower_team then
                    self:UpgradeTower(tower)
                end
            end

            -- Display upgrade message and play ominous sound
            if tower_team == DOTA_TEAM_GOODGUYS then
                -- add notification
                GameRules:SendCustomMessage('radiantTowersUpgraded', 0, 0)
                -- Only has a 50% chance to play sound because its kind of annoying if you hear it too much
                local shouldPlaySound = (RandomInt(1,2))
                if shouldPlaySound == 1 then
                    EmitGlobalSound("powerup_01")
                end
            else
                GameRules:SendCustomMessage('direTowersUpgraded', 0, 0)
                local shouldPlaySound = (RandomInt(1,2))
                if shouldPlaySound == 1 then
                    EmitGlobalSound("powerup_02")
                end
            end
        end
    end, nil)
end

function Ingame:UpgradeTower( tower )
    -- Fetch tower abilities
    for _,abName in pairs(tower.strongTowerAbilities) do
		print(abName)
        local upgradeAb = tower:FindAbilityByName(abName)
		if upgradeAb:GetLevel() < upgradeAb:GetMaxLevel() then
			upgradeAb:SetLevel( upgradeAb:GetLevel() + 1 )
			return
		end
    end
	local sisterTower = FindSisterTower(tower)
	local difference = 0
	if sisterTower then
		local difference = GetEquivalentTowerAbilityPowerValue(sisterTower, self.towerList, #tower.strongTowerAbilities) - GetTowerAbilityPowerValue(tower, self.towerList)
	end
	tower.strongTowerAbilities = tower.strongTowerAbilities or {}
	local towerAbName = PullTowerAbility(self.towerList, self.usedRandomTowers, self.banList, tower.strongTowerAbilities, difference, tower:GetLevel() * 10, tower)
	if towerAbName then
        tower:AddAbility(towerAbName):SetLevel(1)
        table.insert(tower.strongTowerAbilities, towerAbName)
        self.usedRandomTowers[towerAbName] = true
    end
end

function Ingame:initGlobalMutator()
    ListenToGameEvent('game_rules_state_change', function(keys)
        local newState = GameRules:State_Get()
        if newState == DOTA_GAMERULES_STATE_PRE_GAME then
            local globalUnit = CreateUnitByName("npc_global_mutator",Vector(0,0,0),false,nil,nil,20)
            Timers:CreateTimer(function()
                local globalAbility = globalUnit:AddAbility("global_mutator")
            end, DoUniqueString('addGlobalMutator'), 0.5)
        end
    end, nil)
end

targetPerks_projectile = {
    npc_dota_hero_puck_perk = true,
}

function Ingame:FilterProjectiles(filterTable)
    --DeepPrintTable(projectile)
    local targetIndex = filterTable["entindex_target_const"]
    local target = EntIndexToHScript(targetIndex)
    local casterIndex = filterTable["entindex_source_const"]
    local caster = EntIndexToHScript(casterIndex)
    local abilityIndex = filterTable["entindex_ability_const"]
    local ability = EntIndexToHScript(abilityIndex)
    -- Hero perks
    if not OptionManager:GetOption('disablePerks') then
        filterTable = heroPerksProjectileFilter(filterTable) --Sending all the data to the heroPerksDamageFilter
    end
    return true
  end

function Ingame:FilterValueTuning(filterTable)
    local caster = EntIndexToHScript(filterTable["entindex_caster_const"]) 
    local ability = EntIndexToHScript(filterTable["entindex_ability_const"]) 
    -- for k,v in pairs(filterTable) do
    --     print(k,v)
    -- end
    return true
end


function Ingame:FilterDamage( filterTable )
    local victim_index = filterTable["entindex_victim_const"]
    local attacker_index = filterTable["entindex_attacker_const"]
    local ability_index = filterTable["entindex_inflictor_const"]
    local ability = nil

    if not victim_index or not attacker_index then
        return true
    end

    local blocked_damage = 0

    local victim = EntIndexToHScript(victim_index)
    local attacker = EntIndexToHScript(attacker_index)

    if ability_index then
        ability = EntIndexToHScript( ability_index )
        if ability:GetName() == "centaur_return"  and victim.IsBuilding and victim:IsBuilding() then
            filterTable["damage"] = 0
        end
        -- Stops abusive Combo of Diabloic Edict and multicast tearing down towers in seconds
        if ability:GetName() == "leshrac_diabolic_edict"  and victim.IsBuilding and victim:IsBuilding() then
            local protection = victim:FindModifierByName("modifier_backdoor_protection_active")

            if protection then
             filterTable["damage"] = 0
            end
        end
    end

    if OptionManager:GetOption('antiRat') == 1 and victim.IsBuilding and victim:IsBuilding() then
        local protection = victim:FindModifierByName("modifier_backdoor_protection_active")

        if protection then
         if self.heard["antiRatProtection"] ~= true then
             GameRules:SendCustomMessage("#antiRatNotification", 0, 0)
             self.heard["antiRatProtection"] = true
         end
         
         filterTable["damage"] = 0
        end
    end

    if victim:HasModifier("modifier_ancient_priestess_spirit_link") then
        if victim.spiritLink_damage then
            victim.spiritLink_damage = nil
        else
            --print("Link Damage")
            local link_blocked = victim:FindModifierByName("modifier_ancient_priestess_spirit_link"):LinkDamage(filterTable["damage"],filterTable["damage_type"],attacker,nil)
            blocked_damage = blocked_damage + link_blocked
            filterTable["damage"] = filterTable["damage"] - link_blocked
        end
    end

    if victim:HasModifier("modifier_archmage_magic_barrier") then
        local blocked = victim:FindModifierByName("modifier_archmage_magic_barrier"):GetBlockedDamage(filterTable["damage"])
        blocked_damage = blocked_damage + blocked
        filterTable["damage"] = filterTable["damage"] - blocked
    end

    if attacker:HasAbility("ebf_mana_fiend_essence_amp") then
        filterTable = EssenceAmp(filterTable)
    end

    if victim:HasModifier("modifier_ancient_priestess_ritual_protection") then
        local blocked = victim:FindModifierByName("modifier_ancient_priestess_ritual_protection"):GetBlockDamage(filterTable["damage"])
        blocked_damage = blocked_damage + blocked
        filterTable["damage"] = filterTable["damage"] - blocked
    end

    if victim:HasModifier("modifier_enthrall") then
        if not victim:IsAttackImmune() then
            if filterTable["damagetype_const"] == DAMAGE_TYPE_PHYSICAL then
                filterTable["damagetype_const"] = DAMAGE_TYPE_MAGICAL
            end
        end
    end

     -- Hero perks
    if not OptionManager:GetOption('disablePerks') then
        filterTable = heroPerksDamageFilter(filterTable)
    end
    -- Next Gen
    filterTable = nextGenDamageFilter(filterTable)
    -- Memes
    if OptionManager:GetOption('memesRedux') == 1 then
        filterTable = memesDamageFilter(filterTable)
    end

    return true
end

LinkLuaModifier("modifier_rune_doubledamage_mutated_redux","abilities/mutators/super_runes.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_rune_arcane_mutated_redux","abilities/mutators/super_runes.lua",LUA_MODIFIER_MOTION_NONE)
function AddRuneModifier(hero,name,duration)
    
    local m = hero:AddNewModifier(nil,nil,name,{duration = duration})
    print(m,hero:GetUnitName(),name,duration)
end

require('abilities/bash_reflect')
require('abilities/bash_cooldown')

function Ingame:FilterModifiers( filterTable )
    local parent_index = filterTable["entindex_parent_const"]
    local caster_index = filterTable["entindex_caster_const"]
    local ability_index = filterTable["entindex_ability_const"]
    local duration = filterTable["duration"]

    if not parent_index --[[or not caster_index -or not ability_index]] then
        return true
    end
    
    local modifier_name = filterTable.name_const
    local parent = EntIndexToHScript( parent_index )
    --if OptionManager:GetOption('superRunes') == 1 then
    --    if modifier_name == "modifier_rune_doubledamage_mutated_redux" then return true end
    --    if modifier_name == "modifier_rune_arcane_mutated_redux" then return true end
    --    if modifier_name == "modifier_rune_doubledamage" then
    --        AddRuneModifier(parent,"modifier_rune_doubledamage_mutated_redux",filterTable.duration)
    --        --local m = parent:AddNewModifier(nil,nil,"modifier_rune_doubledamage_mutated_redux",{duration = filterTable.duration})
    --        --local m = parent:AddNewModifier(nil,nil,"modifier_vampirism_mutator",{duration = filterTable.duration})
    --        return false
    --    elseif modifier_name == "modifier_rune_arcane" then
    --        AddRuneModifier(parent,"modifier_rune_arcane_mutated_redux",filterTable.duration)
    --        --local m = parent:AddNewModifier(nil,nil,"modifier_rune_arcane_mutated_redux",{duration = filterTable.duration})
    --        --local m = parent:AddNewModifier(nil,nil,"modifier_vampirism_mutator",{duration = filterTable.duration})
    --        return false
    --    end
    --end

    if not caster_index or not ability_index then
        return true
    end
    
    local caster = EntIndexToHScript( caster_index )
    local ability = EntIndexToHScript( ability_index ) or nil

    -- Lazy fix for glaives of wisdom, Think of a better idea later.

    if ability:GetAbilityName() == "silencer_glaives_of_wisdom" then
        if RollPercentage(75) then
            return false
        end
    end

     -- Hero perks
    if not OptionManager:GetOption('disablePerks') then
        filterTable = heroPerksModifierFilter(filterTable)
    end
    -- Next gen
    filterTable = nextGenModifierFilter(filterTable)
    -- Memes
    if OptionManager:GetOption('memesRedux') == 1 then
        filterTable = memesModifierFilter(filterTable)
    end
    local modifierEventTable = {
        caster = caster,
        parent = parent,
        ability = ability,
        original_duration = duration,
        modifier_name = modifier_name,
    }

    if modifier_name == "modifier_kill" then print("modifier_name = modifier_kill") end
    -- Tenacity
    if caster:GetTeamNumber() ~= parent:GetTeamNumber() and filterTable["duration"] > 0 then
        filterTable["duration"] = filterTable["duration"] * parent:GetTenacity(modifierEventTable)
        if parent.GetIMBATenacity then
            local original_duration = filterTable.duration
            local actually_duration = original_duration
            local tenacity = parent:GetIMBATenacity()
            if parent:GetTeam() ~= caster:GetTeam() and filterTable.duration > 0 then --and tenacity ~= 0 then                
                actually_duration = actually_duration * (100 - tenacity) * 0.01
            end

            local modifier_handler = parent:FindModifierByName(modifier_name)
            if modifier_handler then
                if modifier_handler.IgnoreTenacity then
                    if modifier_handler:IgnoreTenacity() then
                        actually_duration = original_duration
                    end
                end
            end
            filterTable.duration = actually_duration
        end
    end



    -- Willpower (Shouldn't increase duration of passives like bash)
    if filterTable["duration"] > 0 and ability.IsPassive and not ability:IsPassive() and modifier_name ~= "modifier_kill" then
        filterTable["duration"] = filterTable["duration"] * caster:GetWillPower(modifierEventTable)
    end

    -- Summoners boost
    if modifier_name == "modifier_kill" and parent.IsIllusion and not parent:IsIllusion() then
        filterTable["duration"] = filterTable["duration"] * caster:GetSummonersBoost(modifierEventTable)
    end


    -- Bash Reflect
    ReflectBashes(filterTable)
    -- Bash Cooldown
    if OptionManager:GetOption('antiBash') == 1 then
        if not BashCooldown(filterTable) then 
            return false 
        end
    end

    return true
end

function Ingame:OnPlayerRevived(event)
    local hRevivedHero = EntIndexToHScript( event.target )
    local hReviverHero = EntIndexToHScript( event.caster )
    if hRevivedHero ~= nil and hRevivedHero:IsRealHero() then
        hRevivedHero:SetHealth( hRevivedHero:GetMaxHealth() * 0.4 )
        hRevivedHero:SetMana( hRevivedHero:GetMaxMana() * 0.4 )
        EmitSoundOn( "Dungeon.HeroRevived", hRevivedHero )


        local fInvulnDuration = 3
        hRevivedHero:AddNewModifier( hRevivedHero, nil, "modifier_invulnerable", { duration = fInvulnDuration } )
        hRevivedHero:AddNewModifier( hRevivedHero, nil, "modifier_omninight_guardian_angel", { duration = fInvulnDuration } )
    end
end

function Ingame:SetPlayerColors( )
    for i=0,23 do
        if PlayerResource:IsValidPlayer(i) and self.playerColors[i] then
            local color = self.playerColors[i]
            PlayerResource:SetCustomPlayerColor(i, color[1], color[2], color[3])
        end
    end
end

ingame = Ingame()

ListenToGameEvent('game_rules_state_change', function(keys)
    local newState = GameRules:State_Get()
    if newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
        ingame:SetPlayerColors()
    end
end, nil)

-- Return an instance of it
return ingame
