local util = require('util')
local constants = require('constants')
local network = require('network')
local OptionManager = require('optionmanager')
local Timers = require('easytimers')
require('lib/util_imba')
require('abilities/hero_perks/hero_perks_filters')
require('abilities/epic_boss_fight/ebf_mana_fiend_essence_amp')
require('abilities/global_mutators/global_mutator')
require('bottle')

-- Create the class for it
local Ingame = class({})

local ts_entities = LoadKeyValues('scripts/kv/ts_entities.kv')
GameRules.perks = LoadKeyValues('scripts/kv/perks.kv')

-- Init Ingame stuff, sets up all ingame related features
function Ingame:init()
    local this = self
    -- Init everything
    self:handleRespawnModifier()
    self:initGoldBalancer()
    self:checkBuybackStatus()

    -- Init stronger towers
    self:addStrongTowers()
    self:AddTowerBotController()
    self:fixRuneBug()

    -- Init global mutator
    self:initGlobalMutator()

    -- 10vs10 colors
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

    -- Setup standard rules
    GameRules:GetGameModeEntity():SetTowerBackdoorProtectionEnabled(true)

    -- Balance Player
    CustomGameEventManager:RegisterListener('swapPlayers', function(_, args)
        if not CustomNetTables:GetTableValue("phase_ingame","balance_players") then
            CustomNetTables:SetTableValue("phase_ingame","balance_players",{swapInProgress = 0})
        elseif CustomNetTables:GetTableValue("phase_ingame","balance_players").swapInProgress == 1 then
            return
        end

        CustomNetTables:SetTableValue("phase_ingame","balance_players",{swapInProgress = 1})

        GameRules:SendCustomMessage("#teamSwitch_notification", 0, 0)
        Timers:CreateTimer(function ()
            this:swapPlayers(args.x, args.y)
        end, 'switch_warning', 5)
    end)

    CustomGameEventManager:RegisterListener( 'declined', function (eventSourceIndex)
        this:declined(eventSourceIndex)
    end)

    CustomGameEventManager:RegisterListener( 'ask_custom_team_info', function(eventSourceIndex, args)
        this:returnCustomTeams(eventSourceIndex, args)
    end)

    -- Precache ogre magi stuff
    PrecacheUnitByNameAsync('npc_precache_npc_dota_hero_ogre_magi', function()
        CreateUnitByName('npc_precache_npc_dota_hero_ogre_magi', Vector(-10000, -10000, 0), false, nil, nil, 0)
    end)

    -- Precache survival resources
    --[[PrecacheUnitByNameAsync('npc_precache_survival', function()
        CreateUnitByName('npc_precache_survival', Vector(-10000, -10000, 0), false, nil, nil, 0)
    end)]]

    -- Precache wraithnight stuff
    PrecacheUnitByNameAsync('npc_precache_wraithnight', function()
        CreateUnitByName('npc_precache_wraithnight', Vector(-10000, -10000, 0), false, nil, nil, 0)
    end)

    -- Precache the stuff that needs to always be precached
    PrecacheUnitByNameAsync('npc_precache_always', function()
        CreateUnitByName('npc_precache_always', Vector(-10000, -10000, 0), false, nil, nil, 0)
    end)

    GameRules:GetGameModeEntity():SetExecuteOrderFilter(self.FilterExecuteOrder, self)
    GameRules:GetGameModeEntity():SetTrackingProjectileFilter(self.FilterProjectiles,self)
    GameRules:GetGameModeEntity():SetModifierGainedFilter(self.FilterModifiers,self)  
    GameRules:GetGameModeEntity():SetDamageFilter(self.FilterDamage,self)

    -- Listen if abilities are being used.
    ListenToGameEvent('dota_player_used_ability', Dynamic_Wrap(Ingame, 'OnAbilityUsed'), self)

    ListenToGameEvent('dota_item_purchased', Dynamic_Wrap(Ingame, 'OnPlayerPurchasedItem'), self)
    
    -- Listen to correct the changed abilitypoints
    ListenToGameEvent('dota_player_gained_level', Dynamic_Wrap(Ingame, 'OnHeroLeveledUp'), self)
    ListenToGameEvent('dota_item_picked_up', Dynamic_Wrap(Ingame, 'OnItemPickedUp'), self)
    
    -- Set it to no team balance
    self:setNoTeamBalanceNeeded()
end   

function Ingame:OnHeroLeveledUp(keys)
    -- Give abilitypoints to spend on the levels the game doesn't give.
    local pID = keys.player -1    
    local player = PlayerResource:GetPlayer(pID)
    local hero = player:GetAssignedHero()

    -- Leveling the talents for bots
    if util:isPlayerBot(pID) and keys.level == 10 then
        for i=1,23 do
            local abName = hero:GetAbilityByIndex(i):GetAbilityName()
            if abName and string.find(abName, "special_bonus") then
                local random = RandomInt(0,1)
                hero:GetAbilityByIndex(i+random):UpgradeAbility(true)
                break
            end
        end
    elseif util:isPlayerBot(pID) and keys.level == 15 then
        for i=1,23 do
            local abName = hero:GetAbilityByIndex(i):GetAbilityName()
            if abName and string.find(abName, "special_bonus") then
                local random = RandomInt(2,3)
                hero:GetAbilityByIndex(i+random):UpgradeAbility(true)
                break
            end
        end

    elseif util:isPlayerBot(pID) and keys.level == 20 then
        for i=1,23 do
            local abName = hero:GetAbilityByIndex(i):GetAbilityName()
            if abName and string.find(abName, "special_bonus") then
                local random = RandomInt(4,5)
                hero:GetAbilityByIndex(i+random):UpgradeAbility(true)
                break
            end
        end

    elseif util:isPlayerBot(pID) and keys.level == 25 then
        for i=1,23 do
            local abName = hero:GetAbilityByIndex(i):GetAbilityName()
            if abName and string.find(abName, "special_bonus") then
                local random = RandomInt(6,7)
                hero:GetAbilityByIndex(i+random):UpgradeAbility(true)
                break
            end
        end 
    end

    local markedLevels = {[17]=true,[19]=true,[21]=true,[22]=true,[23]=true,[24]=true}
    if markedLevels[keys.level] then
        hero:SetAbilityPoints(hero:GetAbilityPoints() + 1)
    end
end

function Ingame:OnItemPickedUp(keys)
    local heroEntity = EntIndexToHScript(keys.HeroEntityIndex)
    local itemEntity = EntIndexToHScript(keys.ItemEntityIndex)
    local player = PlayerResource:GetPlayer(keys.PlayerID)
    local itemname = keys.itemname
    
    if string.find(itemname,"item_rune") ~= nil then -- We are picking up a rune
      if itemname == "item_rune_bounty" then -- It's a bounty rune, use that behaviour
        local item =  heroEntity:GetItemByName("item_bottle_2")
         or heroEntity:GetItemByName("item_bottle_1") 
         or heroEntity:GetItemByName("item_bottle_0") 
         or heroEntity:GetItemByName("item_bottle_bounty")

        if item then
          heroEntity:RemoveItem(item)
          heroEntity:AddItemByName("item_bottle_bounty")
        else
          self:UseBountyRune(heroEntity)
        end
      else -- It is any other rune
        local item = heroEntity:GetItemByName("item_bottle_3")
         or heroEntity:GetItemByName("item_bottle_2")
         or heroEntity:GetItemByName("item_bottle_1") 
         or heroEntity:GetItemByName("item_bottle_0") 
         or heroEntity:GetItemByName("item_bottle_bounty")
         or heroEntity:GetItemByName("item_bottle_illusion") 
         or heroEntity:GetItemByName("item_bottle_haste") 
         or heroEntity:GetItemByName("item_bottle_regen")
         or heroEntity:GetItemByName("item_bottle_doubledamage") 
         or heroEntity:GetItemByName("item_bottle_arcane") 
         or heroEntity:GetItemByName("item_bottle_invis")
         
        if item then
          heroEntity:RemoveItem(item)
          local bottleName = "item_bottle_".. string.sub(itemname, 11) --item_rune_bounty
          heroEntity:AddItemByName(bottleName)
        else -- Instantly apply the effect
          if itemname ~= "item_rune_illusion" then
            local modifierName = "modifier_rune_".. string.sub(itemname, 11)
            local modifier =heroEntity:AddNewModifier(heroEntity,itemEntity,modifierName,{duration = itemEntity:GetSpecialValueFor("duration")})
          else -- create the illusions
            local illusionOne = CreateUnitByName(heroEntity:GetUnitName(),heroEntity:GetAbsOrigin() + RandomVector(75),true,heroEntity,heroEntity:GetOwner(),heroEntity:GetTeamNumber())
            local player = heroEntity:GetPlayerID() 
            illusionOne:MakeIllusion()
            illusionOne:SetControllableByPlayer(player,true) 
            illusionOne:SetPlayerID(player)
            illusionOne:SetHealth(heroEntity:GetHealth())
            illusionOne:SetMana(heroEntity:GetMana())
            local incoming_damage
            if heroEntity:IsRangedAttacker() then
              incoming_damage = itemEntity:GetSpecialValueFor("incoming_damage_ranged")
            else
              incoming_damage = itemEntity:GetSpecialValueFor("incoming_damage_melee")
            end
            illusionOne:AddNewModifier(heroEntity, itemEntity, "modifier_illusion", {duration = itemEntity:GetSpecialValueFor("duration"), outgoing_damage = itemEntity:GetSpecialValueFor("outgoing_damage"), incoming_damage = incoming_damage})

            local illusionTwo = CreateUnitByName(heroEntity:GetUnitName(),heroEntity:GetAbsOrigin() + RandomVector(75),true,heroEntity,heroEntity:GetOwner(),heroEntity:GetTeamNumber())
            local player = heroEntity:GetPlayerID() 
            illusionTwo:MakeIllusion()
            illusionTwo:SetControllableByPlayer(player,true) 
            illusionTwo:SetPlayerID(player)
            illusionTwo:SetHealth(heroEntity:GetHealth())
            illusionTwo:SetMana(heroEntity:GetMana())
            illusionTwo:AddNewModifier(heroEntity, itemEntity, "modifier_illusion", {duration = itemEntity:GetSpecialValueFor("duration"), outgoing_damage = itemEntity:GetSpecialValueFor("outgoing_damage"), incoming_damage = incoming_damage})
          end
        end
      end
    end
  end

  function Ingame:UseBountyRune(heroEntity)
    local bountyGold
    local bountyExp
    if self.notFirstRuneBounty then
        bountyGold = 50 + math.floor(GameRules:GetGameTime()/30)
        bountyExp = 50 + math.floor(GameRules:GetGameTime()/12)
    else 
        bountyGold = 100
        bountyExp = 0
    end

    SendOverheadEventMessage( heroEntity, OVERHEAD_ALERT_GOLD  , heroEntity, bountyGold, nil )
    heroEntity:ModifyGold(bountyGold,false,DOTA_ModifyGold_Unspecified)
    
    heroEntity:AddExperience(bountyExp,DOTA_ModifyXP_Unspecified,false,false)
    heroEntity:EmitSound("Rune.Bounty")
  end


function Ingame:SpawnRunes()

    --If runes exist delete them
    if runeSouthEast and not runeSouthEast:IsNull() then
      runeSouthEast:Kill()
    end
    if runeSouthWest and not runeSouthWest:IsNull() then
      runeSouthWest:Kill()
    end
    if runeNorthWest and not runeNorthWest:IsNull() then
      runeNorthWest:Kill()
    end
    if runeNorthEast and not runeNorthEast:IsNull() then
      runeNorthEast:Kill()
    end
    if actionRune and not actionRune:IsNull() then
      actionRune:Kill()
    end


    local item = CreateItem("item_rune_bounty",nil,nil)
    local runeTable = {
      [1] = "item_rune_doubledamage",
      [2] = "item_rune_haste",
      [3] = "item_rune_illusion",
      [4] = "item_rune_invis",
      [5] = "item_rune_regen",
      [6] = "item_rune_arcane",
    }
    -- Bounty rune locations
    local runeVectorSouthEast = Vector(1296,-4128,100)
    local runeVectorSouthWest = Vector(-4352,192,100)
    local runeVectorNorthWest = Vector(-2824,4136,100)
    local runeVectorNorthEast = Vector(3488,288,100)
    -- Drop Bounty runes
    runeSouthEast = CreateItemOnPositionSync(runeVectorSouthEast,item)
    runeSouthWest = CreateItemOnPositionSync(runeVectorSouthWest,item)
    runeNorthWest = CreateItemOnPositionSync(runeVectorNorthWest,item)
    runeNorthEast = CreateItemOnPositionSync(runeVectorNorthEast,item)

    if self.notFirstRune then
      local runeVector
      local randomTopBot = RandomInt(1,2)
      if randomTopBot == 1 then
        runeVector = Vector(-1760,1216,100)
      else
        runeVector = Vector(2618,-2003,100)
      end
      local randomRuneType = RandomInt(1,6)
      local item = CreateItem(runeTable[randomRuneType],nil,nil)
      actionRune = CreateItemOnPositionSync(runeVector,item)
      self.notFirstRuneBounty = true
    end
    self.notFirstRune = true
end

function Ingame:OnPlayerPurchasedItem(keys)
    -- Bots will get items auto-delievered to them
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
    else -- Fix bottle for human players
        local hero = PlayerResource:GetPlayer(keys.PlayerID):GetAssignedHero()
        if keys.itemname == "item_bottle" then
            local item = hero:GetItemByName("item_bottle")
            hero:RemoveItem(item)
            local item = hero:AddItem(CreateItem("item_bottle_3", hero, hero))
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
    for n,unit_index in pairs(units) do
        local unit = EntIndexToHScript(unit_index)
        if unit:GetTeamNumber() ~= PlayerResource:GetCustomTeamAssignment(issuer) and PlayerResource:GetConnectionState(issuer) ~= 0 then 
            return false
        end
    end
    filterTable = heroPerksOrderFilter(filterTable)
    return true
end    

dc_table = {};

-- Called when the game starts
function Ingame:onStart()
    local this = self

    -- Force bots to take a defensive pose until the first tower has been destroyed. This is top stop bots from straight away pushing lanes when they hit level 6
    Timers:CreateTimer(function ()
               GameRules:GetGameModeEntity():SetBotsInLateGame(false)
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
    
    -- Spawn the runes
    ListenToGameEvent('game_rules_state_change', function(keys)
        Timers:CreateTimer(function () 
            Ingame:SpawnRunes()
            return 120
        end, DoUniqueString("spawn_runes"),0)
    end, nil)
    
    -- ---Bot Quickfix: Bots sometimes get stuck at runespot at 0:00 gametime. This orders all bots to attack move to center of map, will unjam the stuck bots. 
    
    -- Timers:CreateTimer(function ()   
    --  local maxPlayerID = 24
    --  for playerID=0,maxPlayerID-1 do         
    --      if util:isPlayerBot(playerID) then
    --          local hero = PlayerResource:GetSelectedHeroEntity(playerID) 
    --          if hero then
    --              hero:MoveToPositionAggressive(Vector(0, 0, 0))
    --          end
    --      end
    --  end     
 --        end, 'unstick_bots', 96.0)
        
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
        if args.status == 'ok' then
            GameRules:SendCustomMessage("#cheat_activated", 0, 0)
            this:onPlayerCheat(eventSourceIndex, args)
        elseif args.status == 'error' then
            --GameRules:SendCustomMessage("#cheat_rejection", 0, 0)
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
    if OptionManager:GetOption('useFatOMeter') == 0 then return end
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
            if hero:HasAbility('meepo_divided_we_stand') or hero:HasAbility('arc_warden_tempest_double') then
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

function Ingame:swapPlayers(x, y)
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
        if accepted >= cp_count then
            Timers:CreateTimer(function ()
                self:accepted(x,y)
                CustomGameEventManager:UnregisterListener(h)
                CustomGameEventManager:Send_ServerToAllClients('player_accepted', {});
            end, 'accepted', 0)
        end
    end)
    
    PauseGame(true);

    Timers:CreateTimer(function ()
        self:accepted(x,y)
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

    Timers:CreateTimer(function () PauseGame(false) end, DoUniqueString(''), 2)
end

function Ingame:declined(event_source_index)
    CustomGameEventManager:Send_ServerToAllClients('player_declined', {});
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

function Ingame:onPlayerCheat(eventSourceIndex, args)
    local command = args.command
    local value = args.value
    local playerID = args.playerID
    local isCustom = tonumber(args.isCustom) == 1 and true or false
    if isCustom then
        -- Lvl-up hero
        local player = PlayerResource:GetSelectedHeroEntity(playerID)
        if command == 'lvl_up' then
            for i=0,value-1 do
                player:HeroLevelUp(true)
            end
        elseif command == 'give_gold' then
            player:ModifyGold(value, true, DOTA_ModifyGold_CheatCommand)
        elseif command == 'hero_respawn' then
            player:RespawnUnit()
        elseif command == 'create_item' then
            player:AddItemByName(value)
        end
    end
    if type(value) ~= 'table' then
        value = tonumber(value) == 1 and true or false
        Convars:SetBool(command, value)
    else
        SendToServerConsole(command)
    end
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

-- Respawn modifier
function Ingame:handleRespawnModifier()
    ListenToGameEvent('entity_killed', function(keys)
        -- Ensure our respawn modifier is in effect
        local respawnModifierPercentage = OptionManager:GetOption('respawnModifierPercentage')
        local respawnModifierConstant = OptionManager:GetOption('respawnModifierConstant')

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
                if hero == mainHero then
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

                            -- Set the time left until we respawn
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
    if filterTable.experience > 1000 then
        filterTable.experience = 440   
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

function Ingame:OnAbilityUsed(event)
    local PlayerID = event.PlayerID
    local abilityname = event.abilityname
    local hero = PlayerResource:GetSelectedHeroEntity(PlayerID)
    local ability = hero:FindAbilityByName(abilityname)
    if not ability then return end
    if ability.randomRoot then
        local randomMain = hero:FindAbilityByName(ability.randomRoot)
        print(ability.randomRoot)
        if not randomMain then return end
        if abilityname == randomMain.randomAb then
            randomMain:OnChannelFinish(true)
            randomMain:OnAbilityPhaseStart()
        end
    end
end

-- Buyback cooldowns
function Ingame:checkBuybackStatus()
    ListenToGameEvent('npc_spawned', 
    function(keys)
        local unit = EntIndexToHScript(keys.entindex)

        if IsValidEntity(unit) then
            if unit:IsHero() and OptionManager:GetOption('buybackCooldownConstant') ~= 420 then
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
                if  util:isPlayerBot(playerID) and PlayerResource:GetTeam(playerID) == DOTA_TEAM_GOODGUYS then
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
            GameRules:GetGameModeEntity():SetBotsInLateGame(false)
            Timers:CreateTimer(function()
                GameRules:GetGameModeEntity():SetBotsInLateGame(true)
                --print("bots have gone back to pushing")
            end, DoUniqueString('makesBotsLateGameAgain'), 180)
        else
            --print("bots are in late game behaviour")
            GameRules:GetGameModeEntity():SetBotsInLateGame(true)        
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
    if ability then
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
    filterTable = heroPerksDamageFilter(filterTable)
    
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
    filterTable = heroPerksModifierFilter(filterTable)
    
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
