local util = require('util')
local constants = require('constants')
local network = require('network')
local OptionManager = require('optionmanager')
local Timers = require('easytimers')
require('lib/util_imba')
require('abilities/hero_perks/hero_perks_filters')
require('abilities/epic_boss_fight/ebf_mana_fiend_essence_amp')
require('abilities/global_mutators/global_mutator')
require('abilities/global_mutators/memes_redux')

-- Create the class for it
local Ingame = class({})

local ts_entities = LoadKeyValues('scripts/kv/ts_entities.kv')
GameRules.perks = LoadKeyValues('scripts/kv/perks.kv')

-- Init Ingame stuff, sets up all ingame related features
function Ingame:init()
    -- Init everything
    self:handleRespawnModifier()
    self:initGoldBalancer()
    self:checkBuybackStatus()

    -- Init stronger towers
    self:addStrongTowers()
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

    -- These are optional votes that can enable or disable game mechanics
    self.voteEnabledCheatMode = false
    self.voteDisableAntiKamikaze = false
    self.voteDisableRespawnLimit = false
    self.origianlRespawnRate = nil
    self.shownCheats = {}

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

    -- Balance Player
    CustomGameEventManager:RegisterListener('swapPlayers', function(_, args)
        if not CustomNetTables:GetTableValue("phase_ingame","balance_players") then
            CustomNetTables:SetTableValue("phase_ingame","balance_players",{swapInProgress = 0})
        elseif CustomNetTables:GetTableValue("phase_ingame","balance_players").swapInProgress == 1 then
            return
        end

        CustomNetTables:SetTableValue("phase_ingame","balance_players",{swapInProgress = 1})

        GameRules:SendCustomMessage("#teamSwitch_notification", 0, 0)

        local code = DoUniqueString("team_switch")
        self.teamSwitchCode = code
        Timers:CreateTimer(function ()
            self:swapPlayers(args.x, args.y, code)
        end, 'switch_warning', 5)
    end)

    CustomGameEventManager:RegisterListener( 'declined', function (eventSourceIndex)
        self:declined(eventSourceIndex)
    end)

    CustomGameEventManager:RegisterListener( 'ask_custom_team_info', function(eventSourceIndex, args)
        self:returnCustomTeams(eventSourceIndex, args)
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



function Ingame:OnPlayerPurchasedItem(keys)
    -- Bots will get items auto-delievered to them
    self:checkIfRespawnRate()
    if util:isPlayerBot(keys.PlayerID) then
        local hero = PlayerResource:GetPlayer(keys.PlayerID):GetAssignedHero()      
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
                if item:GetName() == "item_invis_sword" or item:GetName() == "item_silver_edge" then
                    hero:ModifyGold(item:GetCost(), false, 0)
                    hero:RemoveItem(item)
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

function Ingame:FilterExecuteOrder(filterTable)

    local units = filterTable["units"]
    local issuer = filterTable["issuer_player_id_const"]
    local unit = EntIndexToHScript(units["0"])
    local ability = EntIndexToHScript(filterTable.entindex_ability)
    local target = EntIndexToHScript(filterTable.entindex_target)

    -- Block Alchemists Innate, heroes should not have innate abilities
    if ability and target then
        if string.match(target:GetName(), "npc_dota_hero_") and ability:GetName() == "item_ultimate_scepter" and unit:GetUnitName() == "npc_dota_hero_alchemist" then
            return false
        end
    end

    -- BOT STUCK FIX
    -- How It Works: Every time bot creates an order, this checks their position, if they are in the same last position as last order,
    -- increase counter. If counter gets too high, it means they have been stuck in same position for a long time, do action to help them.
    
    if unit then
        if unit:IsRealHero() and util:isPlayerBot(unit:GetPlayerID()) then
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
    end
    -- END BOT STUCK FIX

    if unit:GetTeamNumber() ~= PlayerResource:GetCustomTeamAssignment(issuer) and PlayerResource:GetConnectionState(issuer) ~= 0 then 
        return false
    end
    
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

    -- Force bots to take a defensive pose until the first tower has been destroyed. This is top stop bots from straight away pushing lanes when they hit level 6
    Timers:CreateTimer(function ()
               GameRules:GetGameModeEntity():SetBotsInLateGame(self.botsInLateGameMode)
               --print("bots will only defend")
            end, 'forceBotsToDefend', 0.5)
    
    ---Enable and then quickly disable all vision. This fixes two problems. First it fixes the scoreboard missing enemy abilities, and second it fixes the issues of bots not moving until they see an enemy player.
    if Convars:GetBool("dota_all_vision") == false then
    
        Timers:CreateTimer(function ()
               Convars:SetBool("dota_all_vision", true)
            end, 'enable_all_vision_fix', 1)
            
        Timers:CreateTimer(function ()
               Convars:SetBool("dota_all_vision", false)
            end, 'disable_all_vision_fix', 1.2)
            
    end
           
    --Attempt to enable cheats
    Convars:SetBool("sv_cheats", true)
    local isCheatsEnabled = Convars:GetBool("sv_cheats")
    local maxPlayers = 24
    local count = 0
    for playerID=0,(maxPlayers-1) do
        if not util:isPlayerBot(playerID) then
            count = count + 1
        end
    end
    local options = {
        players = count,
        cheats = isCheatsEnabled
    }
    network:showCheatPanel(options)
    if OptionManager:GetOption('allowIngameHeroBuilder') then
        network:enableIngameHeroEditor()
        
        -- Notification to players that they can change builds ingame.
        Timers:CreateTimer(function()
                GameRules:SendCustomMessage("#ingameBuilderNotification", 0, 0)
                end, "builderReminder0", 10) -- 5 Mins
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

    -- Start listening for players that are disconnecting
    ListenToGameEvent('player_disconnect', function(keys)
        this:checkBalanceTeamsNextTick()
    end, nil)

    CustomGameEventManager:RegisterListener('lodOnCheats', function(eventSourceIndex, args)
        if args.command then
            self:OnPlayerChat({
                teamonly = true,
                playerid = args.PlayerID,
                text = "-" .. args.command
            })
        end

        if args.consoleCommand and (util:isSinglePlayerMode() or Convars:GetBool("sv_cheats") or self.voteEnabledCheatMode) then
            SendToServerConsole(args.consoleCommand)
        end
    end)

    -- Listen for players connecting
    ListenToGameEvent('player_connect', function(keys)
        this:checkBalanceTeamsNextTick()
    end, nil)

    ListenToGameEvent('player_connect_full', function(keys)
        this:checkBalanceTeamsNextTick()
    end, nil)
    
    -- If Fat-O-Meter is enabled correctly, take note of players' heroes and record necessary information.
    if OptionManager:GetOption('useFatOMeter') > 0 and OptionManager:GetOption('useFatOMeter') <= 2 then
        print("Starting Fat-O-Meter.")
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
        
        ListenToGameEvent('game_rules_state_change', function(keys)

            if OptionManager:GetOption('useFatOMeter') == 0 then return end

            local newState = GameRules:State_Get()
            
            if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
                print("Starting Fat Timers.")
                Timers:CreateTimer(function()
                    if lastFatThink == nil then
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
        end, nil)
    end

    GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(Ingame, 'FilterExecuteOrder'), self)
    GameRules:GetGameModeEntity():SetTrackingProjectileFilter(Dynamic_Wrap(Ingame, 'FilterProjectiles'), self)
    GameRules:GetGameModeEntity():SetModifierGainedFilter(Dynamic_Wrap(Ingame, 'FilterModifiers'),self)  
    GameRules:GetGameModeEntity():SetDamageFilter(Dynamic_Wrap(Ingame, 'FilterDamage'),self)

    -- -- Listen if abilities are being used.
    --ListenToGameEvent('dota_player_used_ability', Dynamic_Wrap(Ingame, 'OnAbilityUsed'), self)

    ListenToGameEvent('dota_item_purchased', Dynamic_Wrap(Ingame, 'OnPlayerPurchasedItem'), self)
    
    -- -- Listen to correct the changed abilitypoints
    ListenToGameEvent('dota_player_gained_level', Dynamic_Wrap(Ingame, 'OnHeroLeveledUp'), self)

    ListenToGameEvent("player_reconnected", Dynamic_Wrap(Ingame, 'OnPlayerReconnect'), self)

    ListenToGameEvent("player_chat", Dynamic_Wrap(Ingame, 'OnPlayerChat'), self)
    
    -- Set it to no team balance
    self:setNoTeamBalanceNeeded()
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

function Ingame:OnPlayerChat(keys)
    local teamonly = keys.teamonly
    local playerID = keys.playerid
    
    local text = string.lower(keys.text)
    local hero = PlayerResource:GetSelectedHeroEntity(playerID) 

    ----------------------------
    -- Debug Commands
    ----------------------------
    if string.find(text, "-test") then 
        GameRules:SendCustomMessage('testing testing 1. 2. 3.', 0, 0)
    elseif string.find(text, "-bot") then
        if string.find(text, "mode") then
            if not self.botsInLateGameMode then 
                self:CommandNotification("-botmode", "Bots are in early game mode.", 10)  
            elseif self.botsInLateGameMode then 
                self:CommandNotification("-botmode", "Bots are in late game mode.", 10)   
            end   
        end            
    elseif string.find(text, "-printabilities") then 
        Timers:CreateTimer(function()        
            -- GameRules:SendCustomMessage("-------------HERO STATS------------", 0, 0)
            -- GameRules:SendCustomMessage("HP: "..tostring(hero:GetHealth()).."/"..tostring(hero:GetMaxHealth()), 0, 0)
            -- GameRules:SendCustomMessage("EP: "..tostring(hero:GetMana()).."/"..tostring(hero:GetMaxMana()), 0, 0)
            -- GameRules:SendCustomMessage("-----------------------------------", 0, 0)
            -- GameRules:SendCustomMessage("MR: "..tostring(hero:GetMagicalArmorValue()), 0, 0)
            -- GameRules:SendCustomMessage("ARMOR: "..tostring(hero:GetPhysicalArmorValue()), 0, 0)
            -- GameRules:SendCustomMessage("-----------------------------------", 0, 0)
            -- GameRules:SendCustomMessage("STR: "..tostring(hero:GetStrength()), 0, 0)
            -- GameRules:SendCustomMessage("AGI: "..tostring(hero:GetAgility()), 0, 0)
            -- GameRules:SendCustomMessage("INT: "..tostring(hero:GetIntellect()), 0, 0)
            -- GameRules:SendCustomMessage("-----------------------------------", 0, 0)
            -- GameRules:SendCustomMessage("AD: "..tostring(hero:GetAverageTrueAttackDamage(hero)), 0, 0)
            -- GameRules:SendCustomMessage("AS: "..tostring(hero:GetAttackSpeed()), 0, 0)
            -- GameRules:SendCustomMessage("ApS: "..tostring(hero:GetAttacksPerSecond()), 0, 0)
            -- GameRules:SendCustomMessage("-----------------------------------", 0, 0)
            -- GameRules:SendCustomMessage("MODIFIER COUNT: "..tostring(hero:GetModifierCount()), 0, 0)
            -- GameRules:SendCustomMessage("-----------------------------------", 0, 0)
            -- for i=0,hero:GetModifierCount() do
            --     GameRules:SendCustomMessage(hero:GetModifierNameByIndex(i).." "..hero:GetModifierStackCount(hero:GetModifierNameByIndex(i), hero))
            -- end
            local abilities = ""
            for i=0,32 do
                local abil = hero:GetAbilityByIndex(i)
                if abil then
                    abilities = abilities..abil:GetName().." "
                    if string.len(abilities) >= 100 then
                        GameRules:SendCustomMessage(abilities, 0, 0)
                        abilities = ""
                    end
                end
            end
            GameRules:SendCustomMessage(abilities, 0, 0)
            -- GameRules:SendCustomMessage("-----------------------------------", 0, 0)
        end, DoUniqueString('printabilities'), .5)

    elseif string.find(text, "-fixcasting") then 
        Timers:CreateTimer(function()        
            local status2,err2 = pcall(function()
                local talents = {}

                for i = 0, 23 do
                    if hero:GetAbilityByIndex(i) then 
                        local ability = hero:GetAbilityByIndex(i)
                        if ability and string.match(ability:GetName(), "special_bonus_") then
                            local abName = ability:GetName()
                            table.insert(talents, abName)
                            hero:RemoveAbility(abName)
                        end
                    end
                end

                SendToServerConsole('say "Found talents: '..tostring(util:getTableLength(talents))..'"')

                Timers:CreateTimer(function()  
                    local status2,err2 = pcall(function()      
                        for k,v in pairs(talents) do
                            hero:AddAbility(v)
                        end
                    end)

                    if not status2 then
                        SendToServerConsole('say "Post this to the LoD comments section: '..err2:gsub('"',"''")..'"')
                    end
                end, DoUniqueString('fixcasting'), .5)
            end)

            if not status2 then
                SendToServerConsole('say "Post this to the LoD comments section: '..err2:gsub('"',"''")..'"')
            end
        end, DoUniqueString('fixcasting'), .5)
    end
    ----------------------------
    -- Vote Commands
    ----------------------------
    if string.find(text, "-enablecheat") or text == "-ec" then 
        Timers:CreateTimer(function()
            if not PlayerResource:GetPlayer(playerID).enableCheats then
                PlayerResource:GetPlayer(playerID).enableCheats = true
                
                local votesRequired = 0
                
                for player_ID = 0,(24-1) do                        
                    if not util:isPlayerBot(player_ID) and PlayerResource:GetPlayer(playerID) ~= PlayerResource:GetPlayer(player_ID) then                            
                        local state = PlayerResource:GetConnectionState(player_ID)
                        if state == 1 or state == 2 then
                            if not PlayerResource:GetPlayer(player_ID).enableCheats then
                                votesRequired = votesRequired + 1
                            end
                        end
                    end
                end

                if votesRequired == 0 then
                    self.voteEnabledCheatMode = true
                    EmitGlobalSound("Event.CheatEnabled")
                    GameRules:SendCustomMessage('<font color=\'#70EA72\'>Everbody voted to enable cheat mode. Cheat mode enabled</font>.',0,0)
                else
                    GameRules:SendCustomMessage(PlayerResource:GetPlayerName(playerID) .. ' voted to enable cheat mode. <font color=\'#70EA72\'>'.. votesRequired .. ' more votes are required</font>, type -enablecheats (-ec) to vote to enable',0,0)
                end

                --print(votesRequired)

            end
        end, DoUniqueString('enableCheat'), .1)
    end
    if string.find(text, "-enablekamikaze") or text == "-ek" then 
        Timers:CreateTimer(function()
            if not PlayerResource:GetPlayer(playerID).enableKamikaze then
                PlayerResource:GetPlayer(playerID).enableKamikaze = true
                
                local votesRequired = 0
                
                for playerID = 0,(24-1) do                        
                    if not util:isPlayerBot(playerID) then                            
                        local state = PlayerResource:GetConnectionState(playerID)
                        if state == 1 or state == 2 then
                            if not PlayerResource:GetPlayer(playerID).enableKamikaze then
                                votesRequired = votesRequired + 1
                            end
                        end
                    end
                end

                if votesRequired == 0 then
                    self.voteDisableAntiKamikaze = true
                    EmitGlobalSound("Event.CheatEnabled")
                    GameRules:SendCustomMessage('Everbody voted to disable the anti-Kamikaze mechanic. <font color=\'#70EA72\'>No more peanlty for dying 3 times within 60 seconds</font>.',0,0)
                else
                    GameRules:SendCustomMessage(PlayerResource:GetPlayerName(playerID) .. ' voted to disable anti-Kamikaze safeguard. <font color=\'#70EA72\'>'.. votesRequired .. ' more votes are required</font>, type -enablekamikaze (-ek) to vote to disable.',0,0)
                end

                --print(votesRequired)

            end
        end, DoUniqueString('enableKamikaze'), .1)
    end
    if string.find(text, "-enablerespawn") or text == "-er" then 
        Timers:CreateTimer(function()
            if not PlayerResource:GetPlayer(playerID).enableRespawn then
                PlayerResource:GetPlayer(playerID).enableRespawn = true
                
                local votesRequired = 0
                
                for playerID = 0,(24-1) do                        
                    if not util:isPlayerBot(playerID) then                            
                        local state = PlayerResource:GetConnectionState(playerID)
                        if state == 1 or state == 2 then
                            if not PlayerResource:GetPlayer(playerID).enableRespawn then
                                votesRequired = votesRequired + 1
                            end
                        end
                    end
                end

                if votesRequired == 0 then
                    self.voteDisableRespawnLimit = true
                    if self.origianlRespawnRate ~= nil then
                        OptionManager:SetOption('respawnModifierPercentage', self.origianlRespawnRate)
                    end        
                    EmitGlobalSound("Event.CheatEnabled")
                    GameRules:SendCustomMessage('Everbody voted to disable the increasing-spawn-rate mechanic. <font color=\'#70EA72\'>Respawn rates no longer increase after 40 minutes</font>. Respawn rate is now '.. OptionManager:GetOption('respawnModifierPercentage') .. '%.',0,0)
                else
                    GameRules:SendCustomMessage(PlayerResource:GetPlayerName(playerID) .. ' voted to disable increasing-spawn-rate safeguard. <font color=\'#70EA72\'>'.. votesRequired .. ' more votes are required</font>, type -enablerespawn (-er) to vote to disable.',0,0)
                end

                --print(votesRequired)

            end
        end, DoUniqueString('enableRespawn'), .1)
    end
    ----------------------------
    -- Cheat Commands
    ----------------------------
    if util:isSinglePlayerMode() or Convars:GetBool("sv_cheats") or self.voteEnabledCheatMode then
        if string.find(text, "-gold") then 
            -- Give user max gold, unless they specify a number
            local goldAmount = 100000
            local splitedText = util:split(text, " ")       
            if splitedText[2] and tonumber(splitedText[2])then
                goldAmount = tonumber(splitedText[2])
            end

            Timers:CreateTimer(function()  
                PlayerResource:ModifyGold(hero:GetPlayerOwner():GetPlayerID(), goldAmount, true, 0)      
                self:CommandNotification("-gold", 'Cheat Used (-gold): Given ' .. goldAmount .. ' gold to '.. PlayerResource:GetPlayerName(playerID)) 
            end, DoUniqueString('cheat'), .1)

        -- Some Bot commands are cheats
        elseif string.find(text, "-bot") then
            if string.find(text, "switch") then
                if self.botsInLateGameMode then
                    self.botsInLateGameMode = false
                    GameRules:GetGameModeEntity():SetBotsInLateGame(self.botsInLateGameMode)
                else
                    self.botsInLateGameMode = true
                    GameRules:GetGameModeEntity():SetBotsInLateGame(self.botsInLateGameMode)
                end
                self:CommandNotification("-switched", "Bots have switched modes.", 5)
            end
        
        elseif string.find(text, "-god") then 
            Timers:CreateTimer(function()  
                local godMode = hero:FindModifierByName("modifier_invulnerable")
                if godMode then
                    hero:RemoveModifierByName("modifier_invulnerable")
                else
                    hero:AddNewModifier(hero,nil,"modifier_invulnerable",{duration = 240})
                    self:CommandNotification("-godmode", 'Cheat Used (-godmode): Given invulnerability to '.. PlayerResource:GetPlayerName(playerID)) 
                end
                             
            end, DoUniqueString('cheat'), .1)

        elseif string.find(text, "-regen") then 
            Timers:CreateTimer(function()  
                local godMode = hero:FindModifierByName("modifier_fountain_aura_buff")
                if godMode then
                    hero:RemoveModifierByName("modifier_fountain_aura_buff")
                else
                    hero:AddNewModifier(hero,nil,"modifier_fountain_aura_buff",{})
                    self:CommandNotification("-godmode", 'Cheat Used (-regen): Given foutain regeneration to '.. PlayerResource:GetPlayerName(playerID)) 
                end
                             
            end, DoUniqueString('cheat'), .1)

        elseif string.find(text, "-lvlup") then 
            -- Give user 1 level, unless they specify a number after
            local levels = 1
            local splitedText = util:split(text, " ")       
            if splitedText[2] and tonumber(splitedText[2]) then
                levels = tonumber(splitedText[2])
            end
            Timers:CreateTimer(function()  
                for i=0,levels-1 do
                    hero:HeroLevelUp(true)
                end
                self:CommandNotification("-lvlup", 'Cheat Used (-lvlup): Given ' .. levels .. ' level(s) to '.. PlayerResource:GetPlayerName(playerID)) 
            end, DoUniqueString('cheat'), .1)

        elseif string.find(text, "-item") then 
            -- Give user 1 level, unless they specify a number after
            Timers:CreateTimer(function()  
                local splitedText = util:split(text, " ")       
                local validItem = false
                if splitedText[2] then
                    hero:AddItemByName(splitedText[2])
                    local findItem = hero:FindItemByName(splitedText[2])
                    if findItem then validItem = true end
                end
                if validItem then
                    self:CommandNotification("-item", 'Cheat Used (-item): Given ' .. splitedText[2] .. ' to '.. PlayerResource:GetPlayerName(playerID)) 
                end
            end, DoUniqueString('cheat'), .1)

        elseif string.find(text, "-addability") or string.find(text, "-giveability") then 
            -- Give user 1 level, unless they specify a number after
            Timers:CreateTimer(function()  
                local splitedText = util:split(text, " ")       
                local validAbility = false
                if splitedText[2] then    
                    local oldAbList = LoadKeyValues('scripts/kv/abilities.kv')
                    local skills = oldAbList.skills
                    for tabName, tabList in pairs(skills) do
                        for abilityName,abilityGroup in pairs(tabList) do
                            print(abilityName)
                            if string.find(abilityName, splitedText[2]) then
                                splitedText[2] = abilityName
                            end
                        end
                    end
                    hero:AddAbility(splitedText[2])
                    local findAbility = hero:FindAbilityByName(splitedText[2])
                    if findAbility then validAbility = true end
                end
                if validAbility then
                    self:CommandNotification("-addability", 'Cheat Used (-addability): Given ' .. splitedText[2] .. ' to '.. PlayerResource:GetPlayerName(playerID)) 
                end
            end, DoUniqueString('cheat'), .1)

        elseif string.find(text, "-removeability") then 
            -- Give user 1 level, unless they specify a number after

            Timers:CreateTimer(function()  
                local splitedText = util:split(text, " ")       
                local validAbility = false
                if splitedText[2] then    
                    for i=0,32 do
                        local abil = hero:GetAbilityByIndex(i)
                        if abil then
                            if splitedText[2] == "all" then
                                hero:RemoveAbility(abil:GetName())
                            elseif string.find(abil:GetName(), splitedText[2]) then
                                splitedText[2] = abil:GetName()
                            end
                        end
                    end
                    hero:RemoveAbility(splitedText[2])
                end
                if validAbility then
                    self:CommandNotification("-removeability", 'Cheat Used (-removeability): -removeability used by  '.. PlayerResource:GetPlayerName(playerID)) 
                end
            end, DoUniqueString('cheat'), .1)

        elseif string.find(text, "-lvlmax") then 
            Timers:CreateTimer(function()
                for i=0,100 do
                    hero:HeroLevelUp(true)
                end
                for i = 0, hero:GetAbilityCount() - 1 do
                    local ability = hero:GetAbilityByIndex(i)
                    if ability then
                        ability:SetLevel(ability:GetMaxLevel())
                    end
                end
                self:CommandNotification("-lvlmax", 'Cheat Used (-lvlmax): Max level given to '.. PlayerResource:GetPlayerName(playerID)) 
            end, DoUniqueString('cheat'), .1)

        elseif string.find(text, "-dagger") then 
            Timers:CreateTimer(function()
                hero:AddItemByName('item_devDagger')
                self:CommandNotification("-item_devDagger", 'Cheat Used (-dagger): Global teleport dagger given to '.. PlayerResource:GetPlayerName(playerID)) 
            end, DoUniqueString('cheat'), 0.2)


        elseif string.find(text, "-teleport") then 
            -- Teleport is not exactly reproduced. If the game is in tools mode or has sv_cheats, leave it as it is, if not give players the teleport dagger.
            if not IsInToolsMode() and not Convars:GetBool("sv_cheats") then
                Timers:CreateTimer(function()
                    hero:AddItemByName('item_devDagger')
                    self:CommandNotification("-teleport", 'Cheat Used (-teleport): Global teleport dagger given to '.. PlayerResource:GetPlayerName(playerID)) 
                end, DoUniqueString('cheat'), 0.2)
            end
        
        elseif string.find(text, "-startgame") then 
            Timers:CreateTimer(function()
                Tutorial:ForceGameStart()
                self:CommandNotification("-startgame", 'Cheat Used (-startgame): Forced game start, by '.. PlayerResource:GetPlayerName(playerID)) 
            end, DoUniqueString('cheat'), .1)    

        elseif string.find(text, "-respawn") then 
            Timers:CreateTimer(function()
                if not hero:IsAlive() then
                    hero:SetTimeUntilRespawn(1)
                end
                self:CommandNotification("-respawn", 'Cheat Used (-respawn): Respawned '.. PlayerResource:GetPlayerName(playerID)) 
            end, DoUniqueString('cheat'), 1)

        elseif string.find(text, "-refresh") then 
            Timers:CreateTimer(function()

                hero:SetMana(hero:GetMaxMana())
                hero:SetHealth(hero:GetMaxHealth())

                for i = 0, hero:GetAbilityCount() - 1 do
                    local ability = hero:GetAbilityByIndex(i)
                    if ability then
                        ability:EndCooldown()
                    end
                end

                for i = 0, 5 do
                    local item = hero:GetItemInSlot( i )
                    if item then
                        item:EndCooldown()
                    end
                end
                self:CommandNotification("-refresh", 'Cheat Used (-refresh): Refreshed '.. PlayerResource:GetPlayerName(playerID)) 
            end, DoUniqueString('cheatrefresh'), .2)
        end
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
        hero:SetPlayerID(playerID)
        hero:SetOwner(PlayerResource:GetPlayer(playerID))



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
        end, DoUniqueString('respawn'), 0.11)
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

function Ingame:swapPlayers(x, y, code)
    CustomNetTables:SetTableValue("phase_ingame","balance_players",{swapInProgress = 1})

    local player_count = PlayerResource:GetPlayerCount()
    local cp_count = 0
    
    for i = 0, player_count do
        local recepientEntity = PlayerResource:GetPlayer(i)
        CustomGameEventManager:Send_ServerToPlayer(recepientEntity, 'vote_dialog', {swapper = x, swappee = y })
        if PlayerResource:GetConnectionState(i) == 2 then
            cp_count = cp_count + 1
        end
    end

    local accepted = 0;
    local h;
    h = CustomGameEventManager:RegisterListener( 'accept', function ()
        accepted = accepted + 1
        if accepted >= cp_count  then
            -- Timers:CreateTimer(function ()
            if self.teamSwitchCode == code then
                self:accepted(x,y)
            end
            
            CustomGameEventManager:UnregisterListener(h)
            CustomGameEventManager:Send_ServerToAllClients('player_accepted', {});
            -- end, 'accepted', 0)
        end
    end)
    
    PauseGame(true);

    Timers:CreateTimer(function ()
        if self.teamSwitchCode == code then
            self:accepted(x,y)
        end   
        CustomGameEventManager:UnregisterListener(h)
    end, 'accepted', 10)

    Timers:CreateTimer(function ()
        CustomNetTables:SetTableValue("phase_ingame","balance_players",{swapInProgress = 0})
    end, 'swapInProgress', 10)
end

function Ingame:accepted(x, y)
    local newTeam = otherTeam(PlayerResource:GetCustomTeamAssignment(x))
    local oldTeam = otherTeam(PlayerResource:GetCustomTeamAssignment(y))

    local xuMoney = PlayerResource:GetUnreliableGold(x)
    local yuMoney = PlayerResource:GetUnreliableGold(y)
    local xrMoney = PlayerResource:GetReliableGold(x)
    local yrMoney = PlayerResource:GetReliableGold(y)

    self:balancePlayer(x, newTeam)
    self:balancePlayer(y, oldTeam)

    PlayerResource:SetGold(x, xuMoney, false)
    PlayerResource:SetGold(y, yuMoney, false)
    PlayerResource:SetGold(x, xrMoney, true)
    PlayerResource:SetGold(y, yrMoney, true)
    
    for i = 0, PlayerResource:GetNumCouriersForTeam(newTeam) - 1 do
        local cour = PlayerResource:GetNthCourierForTeam(i, newTeam)
        cour:SetControllableByPlayer(x, false)
        for j=0, 5 do
            local item = cour:GetItemInSlot(j)
            if item and item:GetPurchaser():GetPlayerID() == y then
                PlayerResource:ModifyGold(y, item:GetCost(), true, 0)
                cour:RemoveItem(item)
            end
        end
    end

    self.teamSwitchCode = ""

    Timers:CreateTimer(function () PauseGame(false) end, DoUniqueString(''), 2)
end

function Ingame:declined(event_source_index)
    CustomGameEventManager:Send_ServerToAllClients('player_declined', {});
    CustomNetTables:SetTableValue("phase_ingame","balance_players",{swapInProgress = 0})
    self.teamSwitchCode = ""
    Timers:CreateTimer(function () PauseGame(false) end, 'accepted', 2)
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

        --if respawnModifierPercentage == 100 and respawnModifierConstant == 0 then return end

        -- Grab the killed entity (it isn't nessessarily a hero!)
        local hero = EntIndexToHScript(keys.entindex_killed)

        -- Ensure it is a hero
        if IsValidEntity(hero) then
            if hero:IsHero() then
                -- Ensure we are not using aegis!
                if hero:IsReincarnating() then
                    local reincarnation = hero:FindAbilityByName("skeleton_king_reincarnation")
                    if reincarnation then
                        local respawnTime = reincarnation:GetSpecialValueFor("reincarnate_time")
                        if reincarnation:GetTrueCooldown() - reincarnation:GetCooldownTimeRemaining() < respawnTime - 1 then
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

                            hero:SetTimeUntilRespawn(timeLeft)

                            -- Give 322 gold if enabled
                            if OptionManager:GetOption('322') == 1 then
                                hero:ModifyGold(322,false,0)
                                SendOverheadEventMessage(hero:GetPlayerOwner(), OVERHEAD_ALERT_GOLD, hero, 322, nil)
                            end
                            -- Refresh cooldowns if enabled
                            if OptionManager:GetOption('refreshCooldownsOnDeath') == 1 then
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

    local myTeam = 1
    local enemyTeam = 1

    if teamID == DOTA_TEAM_GOODGUYS then
        myTeam = self.playersOnTeam.radiant
        enemyTeam = self.playersOnTeam.dire
    elseif teamID == DOTA_TEAM_BADGUYS then
        myTeam = self.playersOnTeam.dire
        enemyTeam = self.playersOnTeam.radiant
    end

    -- Grab the gold modifier
    local goldModifier = OptionManager:GetOption('goldModifier')

    if goldModifier ~= 1 then
        filterTable.gold = math.ceil(filterTable.gold * goldModifier / 100)
    end

    -- Slow down the gold intake for the team with more players
    local ratio = enemyTeam / myTeam
    if ratio < 1 then
        ratio = 1 - (1 - ratio) / 2

        filterTable.gold = math.ceil(filterTable.gold * ratio)
    end

    return true
end

-- Option to modify EXP
function Ingame:FilterModifyExperience(filterTable)
    local expModifier = OptionManager:GetOption('expModifier')
    --hotfix start: to stop the insane amount of EXP
    if math.abs(filterTable.experience) > 100000 then
        filterTable.experience = 0   
        return false
    end 
    --hotfix end
    --print("experience gained")
    --print(filterTable.experience)

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
    if OptionManager:GetOption('sharedXP') == 1 then
        local team = PlayerResource:GetPlayer(filterTable.player_id_const):GetTeamNumber()

        for i=0,DOTA_MAX_TEAM do
            local pID = PlayerResource:GetNthPlayerIDOnTeam(team,i)
            if PlayerResource:IsValidPlayerID(pID) then
                local otherHero = PlayerResource:GetPlayer(pID):GetAssignedHero()

                otherHero:AddExperience(math.ceil(filterTable.xp_bounty / util:GetActivePlayerCountForTeam(team)),0,false,false)
                otherHero.expSkip = true
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
            if unit:IsRealHero() and OptionManager:GetOption('buybackCooldownConstant') ~= 420 then
                Timers:CreateTimer(
                function()
                    if IsValidEntity(unit) then
                        local buyBackLeft = unit:GetBuybackCooldownTime()
                        if buyBackLeft ~= 0 then
                            local maxCooldown = OptionManager:GetOption('buybackCooldownConstant')
                            if buyBackLeft > maxCooldown then
                                unit:SetBuybackCooldownTime(maxCooldown)
                            end
                        end
                    end
                end, DoUniqueString('buyback'), 0.1)
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

function Ingame:addStrongTowers()
    ListenToGameEvent('game_rules_state_change', function(keys)

        local newState = GameRules:State_Get()
        if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS and OptionManager:GetOption('strongTowers') then
                local maxPlayers = 24
                local botsEnabled = false
                for playerID=0,(maxPlayers-1) do
                    if util:isPlayerBot(playerID) then
                        botsEnabled = true
                    end
                end

                local oldAbList = LoadKeyValues('scripts/kv/abilities.kv').skills.custom.imba_towers_weak
                local oldAbList2 = LoadKeyValues('scripts/kv/abilities.kv').skills.custom.imba_towers_medium
                local oldAbList3 = LoadKeyValues('scripts/kv/abilities.kv').skills.custom.imba_towers_strong

                local weakTowerSkills = {}
                local mediumTowerSkills = {}
                local strongTowerSkills = {}

                for skill_name in pairs(oldAbList) do
                    if botsEnabled == true then
                        -- Disable troublesome abilities that break bots
                        if skill_name ~= "imba_tower_vicious" and skill_name ~= "imba_tower_forest" and skill_name ~= "imba_tower_disease" then
                            table.insert(weakTowerSkills, skill_name)   
                        end
                    else 
                        table.insert(weakTowerSkills, skill_name)                                                                               
                    end
                end

                for skill_name in pairs(oldAbList2) do
                    if botsEnabled == true then
                        -- Disable troublesome abilities that break bots
                        if skill_name ~= "imba_tower_vicious" and skill_name ~= "imba_tower_forest" and skill_name ~= "imba_tower_disease" then
                            table.insert(mediumTowerSkills, skill_name)   
                        end
                    else 
                        table.insert(mediumTowerSkills, skill_name)                                                                               
                    end
                end

                for skill_name in pairs(oldAbList3) do
                    if botsEnabled == true then
                        -- Disable troublesome abilities that break bots
                        if skill_name ~= "imba_tower_vicious" and skill_name ~= "imba_tower_forest" and skill_name ~= "imba_tower_disease" then
                            table.insert(strongTowerSkills, skill_name)   
                        end
                    else 
                        table.insert(strongTowerSkills, skill_name)                                                                               
                    end
                end

                local towers = Entities:FindAllByClassname('npc_dota_tower')
                for _, tower in pairs(towers) do
                    -- If Tower is level 1, give it a weak ability
                    if tower:GetLevel() == 1 then
                        local ability_name = RandomFromTable(weakTowerSkills)
                        tower:AddAbility(ability_name)
                        local ability = tower:FindAbilityByName(ability_name)
                        ability:SetLevel(1)
                    -- If a Tower is level 2, it has 50% chance of getting weak ability, and 50% chance of getting medium ability
                    elseif tower:GetLevel() == 2 then
                        local random = RandomInt(1,2)
                        if random == 1 then 
                            local ability_name = RandomFromTable(weakTowerSkills)
                            tower:AddAbility(ability_name)
                            local ability = tower:FindAbilityByName(ability_name)
                            ability:SetLevel(1) 
                        elseif random == 2 then
                            local ability_name = RandomFromTable(mediumTowerSkills)
                            tower:AddAbility(ability_name)
                            local ability = tower:FindAbilityByName(ability_name)
                            ability:SetLevel(1) 
                        end  
                    -- If a Tower is level 3 or higher, the tower will get a strong ability                                       
                    elseif tower:GetLevel() > 2 then
                        local ability_name = RandomFromTable(strongTowerSkills)
                        tower:AddAbility(ability_name)
                        local ability = tower:FindAbilityByName(ability_name)
                        ability:SetLevel(1)
                    end

                   
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
        
        if OptionManager:GetOption('strongTowers') then
            local tower_team = keys.teamnumber
            local towers = Entities:FindAllByClassname('npc_dota_tower')
            for _, tower in pairs(towers) do
                if tower:GetTeamNumber() == tower_team then
                    UpgradeTower(tower)
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
    if ability and OptionManager:GetOption('disablePerks') == 0 then
        filterTable = heroPerksProjectileFilter(filterTable) --Sending all the data to the heroPerksDamageFilter
    end
    return true    
  end


function Ingame:FilterDamage( filterTable )
    local victim_index = filterTable["entindex_victim_const"]
    local attacker_index = filterTable["entindex_attacker_const"]
    local ability_index = filterTable["entindex_inflictor_const"]
    if not victim_index or not attacker_index then
        return true
    end

    local blocked_damage = 0 

    local victim = EntIndexToHScript(victim_index)
    local attacker = EntIndexToHScript(attacker_index)
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

     -- Hero perks
    if not OptionManager:GetOption('disablePerks') then
        filterTable = heroPerksDamageFilter(filterTable)
    end

    -- Memes
    if OptionManager:GetOption('memesRedux') == 1 then
        filterTable = memesDamageFilter(filterTable)
    end
    
    return true
end


function Ingame:FilterModifiers( filterTable )
    local parent_index = filterTable["entindex_parent_const"]
    local caster_index = filterTable["entindex_caster_const"]
    local ability_index = filterTable["entindex_ability_const"]
    if not parent_index or not caster_index or not ability_index then
        return true
    end
    local parent = EntIndexToHScript( parent_index )
    local caster = EntIndexToHScript( caster_index )
    local ability = EntIndexToHScript( ability_index )

     -- Hero perks
    if not OptionManager:GetOption('disablePerks') then
        filterTable = heroPerksModifierFilter(filterTable)
    end

    -- Memes
    if OptionManager:GetOption('memesRedux') == 1 then
        filterTable = memesModifierFilter(filterTable)
    end

    return true
end

function Ingame:SetPlayerColors( )
    for i=0,23 do
        if PlayerResource:IsValidPlayer(i) and self.playerColors[i] then
            local color = self.playerColors[i]
            PlayerResource:SetCustomPlayerColor(i, color[1], color[2], color[3])
        end
    end
end



local _instance = Ingame()

ListenToGameEvent('game_rules_state_change', function(keys)
    local newState = GameRules:State_Get()
    if newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
        _instance:SetPlayerColors()
    end
end, nil)

-- Return an instance of it
return _instance
