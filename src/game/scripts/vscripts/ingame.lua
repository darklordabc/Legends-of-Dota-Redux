local util = require('util')
local constants = require('constants')
local network = require('network')
local OptionManager = require('optionmanager')
local Timers = require('easytimers')
require('lib/util_imba')

-- Create the class for it
local Ingame = class({})

local ts_entities = LoadKeyValues('scripts/kv/ts_entities.kv')

-- Init Ingame stuff, sets up all ingame related features
function Ingame:init()
    local this = self
    -- Init everything
    self:handleRespawnModifier()
    self:initGoldBalancer()
    self:checkBuybackStatus()

    -- Init stronger towers
    self:addStrongTowers()

    -- Setup standard rules
    GameRules:GetGameModeEntity():SetTowerBackdoorProtectionEnabled(true)

    -- Balance Player
    CustomGameEventManager:RegisterListener('swapPlayers', function(_, args)
        GameRules:SendCustomMessage("#teamSwitch_notification", 0, 0)

        Timers:CreateTimer(function ()
            this:swapPlayers(args.x, args.y)
        end, 'switch_warning', 5)
    end)

    CustomGameEventManager:RegisterListener( 'declined', function (eventSourceIndex)
        this:declined(eventSourceIndex)
    end)

    CustomGameEventManager:RegisterListener( "ask_custom_team_info", function(eventSourceIndex, args)
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

    -- Listen if abilities are being used.
    ListenToGameEvent('dota_player_used_ability', Dynamic_Wrap(Ingame, 'OnAbilityUsed'), self)
    ListenToGameEvent('entity_killed', Dynamic_Wrap(Ingame, 'OnEntityKilled'), self)
    ListenToGameEvent('dota_item_purchased', Dynamic_Wrap(Ingame, 'OnPlayerPurchasedItem'), self)
    
    -- Set it to no team balance
    self:setNoTeamBalanceNeeded()
end

function Ingame:OnPlayerPurchasedItem(keys)
    local hero = PlayerResource:GetPlayer(keys.PlayerID):GetAssignedHero()

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
    return true
end    

dc_table = {};

-- Called when the game starts
function Ingame:onStart()
    local this = self

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
        if respawnModifierPercentage == 100 and respawnModifierConstant == 0 then return end

        -- Grab the killed entitiy (it isn't nessessarily a hero!)
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

    if expModifier ~= 1 then
        filterTable.experience = math.ceil(filterTable.experience * expModifier / 100)
    end

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
	-- Perk for bloodseeker
	local hero_name = hero:GetUnitName()
        if hero_name and event.abilityname then
              	onHeroCastAbilityHeroPerks(event)
	end
	
end

function Ingame:OnEntityKilled(event)
    local killedUnit = EntIndexToHScript( event.entindex_killed )
    if event.entindex_attacker ~= nil then
      killerEntity = EntIndexToHScript( event.entindex_attacker )
    end
    onHeroKilledHeroPerks(event)
end

-- Buyback cooldowns
function Ingame:checkBuybackStatus()
    ListenToGameEvent('npc_spawned', 
        function(keys)
            local hero = EntIndexToHScript(keys.entindex)
            if IsValidEntity(hero) then
                if hero:IsHero() then
                    Timers:CreateTimer(
                        function()
                            if IsValidEntity(hero) then
                                local buyBackLeft = hero:GetBuybackCooldownTime()
                                if buyBackLeft ~= 0 then
                                    local maxCooldown = OptionManager:GetOption('buybackCooldownConstant')
                                    
                                    if buyBackLeft > maxCooldown then
                                        hero:SetBuybackCooldownTime(maxCooldown)
                                    end
                                end
                            end
                        end, DoUniqueString('buyback'), 0.1)
                end
            end
        end, nil)
end


function Ingame:addStrongTowers()
    ListenToGameEvent('game_rules_state_change', function(keys)
        local newState = GameRules:State_Get()
        if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS and OptionManager:GetOption('strongTowers') then
                local oldAbList = LoadKeyValues('scripts/kv/abilities.kv').skills.custom.imba_towers
                local towerSkills = {}
                for skill_name in pairs(oldAbList) do
                    table.insert(towerSkills, skill_name)
                end
                local towers = Entities:FindAllByClassname('npc_dota_tower')
                for _, tower in pairs(towers) do
                    local ability_name = RandomFromTable(towerSkills)
                    tower:AddAbility(ability_name)
                    local ability = tower:FindAbilityByName(ability_name)
                    ability:SetLevel(1)
                end
        end
    end, nil)
    ListenToGameEvent('dota_tower_kill', function (keys)
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
                EmitGlobalSound("powerup_01")
            else
				GameRules:SendCustomMessage('direTowersUpgraded', 0, 0)
                EmitGlobalSound("powerup_02")
            end
        end
    end, nil)
	
end

-- Return an instance of it

function onHeroKilledHeroPerks(event)
  local killedUnit = EntIndexToHScript( event.entindex_killed )
  if event.entindex_attacker ~= nil then
    killerEntity = EntIndexToHScript( event.entindex_attacker )
  end
  if killedUnit:GetUnitName() == "npc_dota_hero_tidehunter" and killedUnit:HasAbility("tidehunter_ravage") then
    killedUnit:FindAbilityByName("tidehunter_ravage"):EndCooldown()
  elseif killedUnit:GetUnitName() == "npc_dota_hero_enigma" and killedUnit:HasAbility("enigma_black_hole") then
    killedUnit:FindAbilityByName("enigma_black_hole"):EndCooldown()
  end
end

function onHeroCastAbilityHeroPerks(event)
  local PlayerID = event.PlayerID
  local abilityname = event.abilityname
  local hero = PlayerResource:GetSelectedHeroEntity(PlayerID)
  local ability = hero:FindAbilityByName(abilityname)
  if not ability then return end
  
  local hero_name = hero:GetUnitName()
  if hero_name and abilityname then
    	if hero_name == "npc_dota_hero_bloodseeker" and abilityname == "bloodseeker_rupture" then
			ability:RefundManaCost()
			ability:EndCooldown()
			ability:StartCooldown(ability:GetCooldown(ability:GetLevel()-1)*0.8)
	elseif hero_name == "npc_dota_hero_life_stealer" and abilityname == "life_stealer_infest" then
			ability:EndCooldown()
            ability:StartCooldown(30)
	elseif hero_name == "npc_dota_hero_legion_commander" and abilityname == "legion_commander_duel" then
			hero:AddNewModifier(hero,ability,"modifier_black_king_bar_immune",{duration = ability:GetLevelSpecialValueFor("duration",ability:GetLevel()-1)})
	elseif hero_name == "npc_dota_hero_furion" and abilityname == "furion_teleportation" then
			ability:EndCooldown()
			ability:StartCooldown(ability:GetCooldown(ability:GetLevel()-1)*0.5)
        end
  end
 end

return Ingame()