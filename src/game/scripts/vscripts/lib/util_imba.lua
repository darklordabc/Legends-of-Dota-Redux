function DebugPrint(...)
	--local spew = Convars:GetInt('barebones_spew') or -1
	--if spew == -1 and BAREBONES_DEBUG_SPEW then
	--spew = 1
	--end

	--if spew == 1 then
	--print(...)
	--end
end

function DebugPrintTable(...)
	--local spew = Convars:GetInt('barebones_spew') or -1
	--if spew == -1 and BAREBONES_DEBUG_SPEW then
	--spew = 1
	--end

	--if spew == 1 then
	--PrintTable(...)
	--end
end

function PrintAll(t)
	for k,v in pairs(t) do
		print(k,v)
	end
end

function MergeTables( t1, t2 )
	for name,info in pairs(t2) do
		t1[name] = info
	end
end

function AddTableToTable( t1, t2)
	for k,v in pairs(t2) do
		table.insert(t1, v)
	end
end

function PrintTable(t, indent, done)
	--print ( string.format ('PrintTable type %s', type(keys)) )
	if type(t) ~= "table" then return end

	done = done or {}
	done[t] = true
	indent = indent or 0

	local l = {}
	for k, v in pairs(t) do
	table.insert(l, k)
	end

	table.sort(l)
	for k, v in ipairs(l) do
	-- Ignore FDesc
	if v ~= 'FDesc' then
		local value = t[v]

		if type(value) == "table" and not done[value] then
		done [value] = true
		print(string.rep ("\t", indent)..tostring(v)..":")
		PrintTable (value, indent + 2, done)
		elseif type(value) == "userdata" and not done[value] then
		done [value] = true
		print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
		PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
		else
		if t.FDesc and t.FDesc[v] then
			print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
		else
			print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
		end
		end
	end
	end
end

-- Colors
COLOR_NONE = '\x06'
COLOR_GRAY = '\x06'
COLOR_GREY = '\x06'
COLOR_GREEN = '\x0C'
COLOR_DPURPLE = '\x0D'
COLOR_SPINK = '\x0E'
COLOR_DYELLOW = '\x10'
COLOR_PINK = '\x11'
COLOR_RED = '\x12'
COLOR_LGREEN = '\x15'
COLOR_BLUE = '\x16'
COLOR_DGREEN = '\x18'
COLOR_SBLUE = '\x19'
COLOR_PURPLE = '\x1A'
COLOR_ORANGE = '\x1B'
COLOR_LRED = '\x1C'
COLOR_GOLD = '\x1D'

-- Returns a random value from a non-array table
function RandomFromTable(table)
	local array = {}
	local n = 0
	for _,v in pairs(table) do
		array[#array+1] = v
		n = n + 1
	end

	if n == 0 then return nil end

	return array[RandomInt(1,n)]
end

-- Turns an entindex string into a table and returns a table of handles.
-- Separator can only be a space (" ") or a comma (",").
function StringToTableEnt(string, separator)
	local gmatch_sign

	if separator == " " then
		gmatch_sign = "%S+"
	elseif separator == "," then
		gmatch_sign = "([^,]+)"
	end

	local return_table = {}
	for str in string.gmatch(string, gmatch_sign) do 		
		local handle = EntIndexToHScript(tonumber(str))
		table.insert(return_table, handle)
	end	

	return return_table
end

-- Turns a table of entity handles into entindex string separated by commas.
function TableToStringCommaEnt(table)	
	local string = ""
	local first_value = true

	for _,handle in pairs(table) do
		if first_value then
			string = string..tostring(handle:entindex())	
			first_value = false
		else
			string = string..","
			string = string..tostring(handle:entindex())	
		end		
	end

	return string
end

function FindNearestPointFromLine(caster, dir, affected)
	local castertoaffected = affected - caster
	local len = castertoaffected:Dot(dir)
	local ntgt = Vector(dir.x * len, dir.y * len, caster.z)
	return caster + ntgt
end

-------------------------------------------------------------------------------------------------
-- IMBA: custom utility functions
-------------------------------------------------------------------------------------------------

-- Returns the killstreak/deathstreak bonus gold for this hero
function GetKillstreakGold( hero )
	local base_bounty = HERO_KILL_GOLD_BASE + hero:GetLevel() * HERO_KILL_GOLD_PER_LEVEL
	local gold = ( hero.kill_streak_count ^ KILLSTREAK_EXP_FACTOR ) * HERO_KILL_GOLD_PER_KILLSTREAK - hero.death_streak_count * HERO_KILL_GOLD_PER_DEATHSTREAK
	
	-- Limits to maximum and minimum kill/deathstreak values
	gold = math.max(gold, (-1) * base_bounty * HERO_KILL_GOLD_DEATHSTREAK_CAP / 100 )
	gold = math.min(gold, base_bounty * ( HERO_KILL_GOLD_KILLSTREAK_CAP - 100 ) / 100)

	return gold
end

-- Picks a legal non-ultimate ability in Random OMG mode
function GetRandomNormalAbility()

	local ability = RandomFromTable(RANDOM_OMG_ABILITIES)
	
	return ability.ability_name, ability.owner_hero
end

-- Picks a legal ultimate ability in Random OMG mode
function GetRandomUltimateAbility()

	local ability = RandomFromTable(RANDOM_OMG_ULTIMATES)

	return ability.ability_name, ability.owner_hero
end

-- Picks a random tower ability of level in the interval [level - 1, level]
function GetRandomTowerAbility(tier, ability_table)

	local ability = RandomFromTable(ability_table[tier])	

	return ability
end

-- Precaches an unit, or, if something else is being precached, enters it into the precache queue
function PrecacheUnitWithQueue( unit_name )
	
	Timers:CreateTimer(0, function()

		-- If something else is being precached, wait two seconds
		if UNIT_BEING_PRECACHED then
			return 2

		-- Otherwise, start precaching and block other calls from doing so
		else
			UNIT_BEING_PRECACHED = true
			PrecacheUnitByNameAsync(unit_name, function(...) end)

			-- Release the queue after one second
			Timers:CreateTimer(2, function()
				UNIT_BEING_PRECACHED = false
			end)
		end
	end)
end

-- Initializes heroes' innate abilities
function InitializeInnateAbilities( hero )	

	-- Cycle through all of the heroes' abilities, and upgrade the innates ones
	for i = 0, 15 do		
		local current_ability = hero:GetAbilityByIndex(i)		
		if current_ability and current_ability.IsInnateAbility then
			if current_ability:IsInnateAbility() then
				current_ability:SetLevel(1)
			end
		end
	end
end

function IndexAllTowerAbilities()
	local ability_table = {}
	local tier_one_abilities = {}
	local tier_two_abilities = {}
	local tier_three_abilities = {}
	local tier_active_abilities = {}

	for _,tier in pairs(TOWER_ABILITIES) do		

		for _,ability in pairs(tier) do
			if tier == TOWER_ABILITIES.tier_one then
				table.insert(tier_one_abilities, ability.ability_name)
			elseif tier == TOWER_ABILITIES.tier_two then
				table.insert(tier_two_abilities, ability.ability_name)
			elseif tier == TOWER_ABILITIES.tier_three then
				table.insert(tier_three_abilities, ability.ability_name)
			else
				table.insert(tier_active_abilities, ability.ability_name)
			end			
		end
	end

	table.insert(ability_table, tier_one_abilities)
	table.insert(ability_table, tier_two_abilities)
	table.insert(ability_table, tier_three_abilities)
	table.insert(ability_table, tier_active_abilities)

	return ability_table
end

-- Upgrades a tower's abilities
--function UpgradeTower(tower)
--	for i = 0, tower:GetAbilityCount()-1 do
--		local ability = tower:GetAbilityByIndex(i)
--		if ability and ability:GetLevel() < ability:GetMaxLevel() then			
--			ability:SetLevel(ability:GetLevel() + 1)
--			break
--		end
--	end
--end

-- Randoms an ability of a certain tier for the Ancient
function GetAncientAbility( tier )

	-- Tier 1 abilities
	if tier == 1 then
		local ability_list = {
			"venomancer_poison_nova",
			"juggernaut_blade_fury_ancient"			
		}

		return ability_list[RandomInt(1, #ability_list)]
	-- Tier 2 abilities
	elseif tier == 2 then
		local ability_list = {
			"abaddon_borrowed_time",
			"nyx_assassin_spiked_carapace",
			"axe_berserkers_call"
		}

		return ability_list[RandomInt(1, #ability_list)]
	-- Tier 3 abilities
	elseif tier == 3 then
		local ability_list = {
			"tidehunter_ravage",
			"magnataur_reverse_polarity",
--			"phoenix_supernova",
		}

		return ability_list[RandomInt(1, #ability_list)]
	end
	
	return nil
end


-- Initialize Physics library on this target
function InitializePhysicsParameters(unit)

	if not IsPhysicsUnit(unit) then
		Physics:Unit(unit)
		unit:SetPhysicsVelocityMax(600)
		unit:PreventDI()
	end
end

-- Gold bag pickup event function
function GoldPickup(event)
	if IsServer() then
		local item = EntIndexToHScript( event.ItemEntityIndex )
		local owner = EntIndexToHScript( event.HeroEntityIndex )
		local gold_per_bag = item:GetCurrentCharges()
		PlayerResource:ModifyGold( owner:GetPlayerID(), gold_per_bag, true, 0 )
		SendOverheadEventMessage( owner, OVERHEAD_ALERT_GOLD, owner, gold_per_bag, nil )
		UTIL_Remove( item ) -- otherwise it pollutes the player inventory
	end
end

-- Talents modifier function
function ApplyAllTalentModifiers()
	Timers:CreateTimer(0.1,function()
		local current_hero_list = HeroList:GetAllHeroes()
		for k,v in pairs(current_hero_list) do
			local hero_name = string.match(v:GetName(),"npc_dota_hero_(.*)")
			-- TODO: This is odd, please do something better bro
			if hero_name == nil or hero_name == "npc_dota_hero_ghost_revenant" or hero_name == "npc_dota_hero_hell_empress" then print("Custom Hero, ignoring talents for now.") return end
			for i = 1, 8 do
				local talent_name = "special_bonus_imba_"..hero_name.."_"..i
				local modifier_name = "modifier_special_bonus_imba_"..hero_name.."_"..i
				if v:HasTalent(talent_name) and not v:HasModifier(modifier_name) then
					v:AddNewModifier(v,v,modifier_name,{})
				end
			end
		end
		return 0.5
	end)
end

function NetTableM(tablename,keyname,...) 
	local values = {...}                                                                  -- Our user input
	local returnvalues = {}                                                               -- table that will be unpacked for result                                                    
	for k,v in ipairs(values) do  
		local keyname = keyname..v[1]                                                       -- should be 1-8, but probably can be extrapolated later on to be any number
		if IsServer() then
			local netTableKey = netTableCmd(false,tablename,keyname)                              -- Command to grab our key set
			local my_key = createNetTableKey(v)                                               -- key = 250,444,111 as table, stored in key as 1 2 3
			if not netTableKey then                                                           -- No key with requested name exists
				netTableCmd(true,tablename,keyname,my_key)                                          -- create database key with "tablename","myHealth1","1=250,2=444,3=111"
			elseif type(netTableKey) == 'boolean' then                                        -- Our check returned that a key exists but that it is empty, we need to populate it for clients
				netTableCmd(true,tablename,keyname,my_key)                                          -- create database key with "tablename","myHealth1","1=250,2=444,3=111"
			else                                                                              -- Our key exists and we got some values, now we need to check the key against the requested value from other scripts  
				if #v > 1 then
					for i=1,#netTableKey do
						if netTableKey[i] ~= v[i-1] then                                              -- compare each value, does server 1 = our 250? does server 2 = our 444? 
							netTableCmd(true,tablename,keyname,my_key)                                      -- If our key is different from the sent value, rewrite it ONCE and break execution to main loop again
							break
						end
					end
				end
			end      
		end
		local allkeys = netTableCmd(false,tablename,keyname)
		if allkeys and type(allkeys) ~= 'boolean' then
			for i=1,#allkeys do
				table.insert(returnvalues, allkeys[i])    
			end
		else
			for i=1,#v do
				table.insert(returnvalues, 0)
			end
		end
	end
return unpack(returnvalues)
end

function netTableCmd(send,readtable,key,tabletosend)
	if send == false then
		local finalresulttable = {}
		local nettabletemp = CustomNetTables:GetTableValue(readtable,key)
		if not nettabletemp then return false end
		for key,value in pairs(nettabletemp) do
			table.insert(finalresulttable,value)
		end          
		if #finalresulttable > 0 then 
			return finalresulttable
		else
			return true
		end
	else
		CustomNetTables:SetTableValue(readtable, key, tabletosend)
	end
end

function createNetTableKey(v)
	local valuePair = {}
	if #v > 1 then
		for i=2,#v do
			table.insert(valuePair,v[i])                                              -- returns just numbers 2-x from sent value...
		end    
	end
	return valuePair  
end

function getkvValues(tEntity, ...) -- KV Values look hideous in finished code, so this function will parse through all sent KV's for tEntity (typically self)
	local values = {...}
	local data = {}
	for i,v in ipairs(values) do
		table.insert(data,tEntity:GetSpecialValueFor(v))
	end
	return unpack(data)
end

function TalentManager(tEntity, nameScheme, ...)
	local talents = {...}
	local return_values = {}
	for k,v in pairs(talents) do    
		if #v > 1 then
			for i=1,#v do
				table.insert(return_values, tEntity:FindSpecificTalentValue(nameScheme..v[1],v[i]))
			end
		else
			table.insert(return_values, tEntity:FindTalentValue(nameScheme..v[1]))
		end
	end    
return unpack(return_values)
end

function findtarget(source) -- simple list return function for finding a players current target entity
	local t = source:GetCursorTarget()
	local c = source:GetCaster()
	if t and c then return t,c end
end

function findgroundtarget(source) -- simple list return function for finding a players current target entity
	local t = source:GetCursorPosition()
	local c = source:GetCaster()
	if t and c then return t,c end
end

-- Controls comeback gold
function UpdateComebackBonus(points, team)

	-- Calculate both teams' networths
	local team_networth = {}
	team_networth[DOTA_TEAM_GOODGUYS] = 0
	team_networth[DOTA_TEAM_BADGUYS] = 0
	for player_id = 0, 19 do
		if PlayerResource:IsImbaPlayer(player_id) and PlayerResource:GetConnectionState(player_id) <= 2 and (not PlayerResource:GetHasAbandonedDueToLongDisconnect(player_id)) then
			team_networth[PlayerResource:GetTeam(player_id)] = team_networth[PlayerResource:GetTeam(player_id)] + PlayerResource:GetTotalEarnedGold(player_id)
		end
	end

	-- Update teams' score
	if COMEBACK_BOUNTY_SCORE[team] == nil then
		COMEBACK_BOUNTY_SCORE[team] = 0
	end
	
	COMEBACK_BOUNTY_SCORE[team] = COMEBACK_BOUNTY_SCORE[team] + points

	-- If one of the teams is eligible, apply the bonus
	if (COMEBACK_BOUNTY_SCORE[DOTA_TEAM_GOODGUYS] < COMEBACK_BOUNTY_SCORE[DOTA_TEAM_BADGUYS]) and (team_networth[DOTA_TEAM_GOODGUYS] < team_networth[DOTA_TEAM_BADGUYS]) then
		COMEBACK_BOUNTY_BONUS[DOTA_TEAM_GOODGUYS] = (COMEBACK_BOUNTY_SCORE[DOTA_TEAM_BADGUYS] - COMEBACK_BOUNTY_SCORE[DOTA_TEAM_GOODGUYS]) / ( COMEBACK_BOUNTY_SCORE[DOTA_TEAM_GOODGUYS] + 60 - GameRules:GetDOTATime(false, false) / 60 )
	elseif (COMEBACK_BOUNTY_SCORE[DOTA_TEAM_BADGUYS] < COMEBACK_BOUNTY_SCORE[DOTA_TEAM_GOODGUYS]) and (team_networth[DOTA_TEAM_BADGUYS] < team_networth[DOTA_TEAM_GOODGUYS]) then
		COMEBACK_BOUNTY_BONUS[DOTA_TEAM_BADGUYS] = (COMEBACK_BOUNTY_SCORE[DOTA_TEAM_GOODGUYS] - COMEBACK_BOUNTY_SCORE[DOTA_TEAM_BADGUYS]) / ( COMEBACK_BOUNTY_SCORE[DOTA_TEAM_BADGUYS] + 60 - GameRules:GetDOTATime(false, false) / 60 )
	end
end

-------------------------------------------------------------------------------------------------------
-- Client side daytime tracking system
-------------------------------------------------------------------------------------------------------

function StoreCurrentDayCycle()	
	Timers:CreateTimer(function()		

		-- Get current daytime cycle
		local is_day = GameRules:IsDaytime()		

		-- Set in the table
		CustomNetTables:SetTableValue("gamerules", "isdaytime", {is_day = is_day} )		

	-- Repeat
	return 0.5
	end)	
end

function IsDaytime()
	if CustomNetTables:GetTableValue("gamerules", "isdaytime") then
		if CustomNetTables:GetTableValue("gamerules", "isdaytime").is_day then  
			local is_day = CustomNetTables:GetTableValue("gamerules", "isdaytime").is_day  

			if is_day == 1 then
				return true
			else
				return false
			end
		end
	end

	return true   
end

-- COOKIES: PreGame Chat System, created by Mahou Shoujo
Chat = Chat or class({})

function Chat:constructor(players, users, teamColors)
	self.players = players
	self.teamColors = TEAM_COLORS
	self.users = users

	CustomGameEventManager:RegisterListener("custom_chat_say", function(id, ...) Dynamic_Wrap(self, "OnSay")(self, ...) end)
	print("CHAT: constructing...")
end

function Chat:OnSay(args)
	local id = args.PlayerID
	local message = args.message
	local player = PlayerResource:GetPlayer(id)
	local hero = player:GetAssignedHero()

	message = message:gsub("^%s*(.-)%s*$", "%1") -- Whitespace trim
	message = message:gsub("^(.{0,256})", "%1") -- Limit string length

	if message:len() == 0 then
		return
	end

	local arguments = {
		hero = player,
		color = PLAYER_COLORS[id],
		player = id,
		message = args.message,
		team = args.team,
		IsDev = IsDeveloper(id)
	}

	if args.team then
		CustomGameEventManager:Send_ServerToTeam(player:GetTeamNumber(), "custom_chat_say", arguments)

		print(hero, args.message, PLAYER_COLORS[id])
--		Say(hero, args.message, true)

--	else -- i leave this here if someday we want to create a whole new chat, and not only a pregame chat
--		CustomGameEventManager:Send_ServerToAllClients("custom_chat_say", arguments)
	end
end

function Chat:PlayerRandomed(id, hero, teamLocal, name)
	local hero = PlayerResource:GetPlayer(id)
	local shared = {
		color = PLAYER_COLORS[id],
		player = id,
		IsDev = IsDeveloper(id)
	}

	local localArgs = vlua.clone(shared)
	localArgs.hero = hero
	localArgs.team = teamLocal
	localArgs.name = name

	CustomGameEventManager:Send_ServerToAllClients("custom_randomed_message", localArgs)
end

function SystemMessage(token, vars)
	CustomGameEventManager:Send_ServerToAllClients("custom_system_message", { token = token or "", vars = vars or {}})
end

-- This function is responsible for cleaning dummy units and wisps that may have accumulated
function StartGarbageCollector()	
--	print("started collector")

	-- Find all dummy units in the game
	local dummies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector(0,0,0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false)		

	-- Cycle each dummy. If it is alive for more than 1 minute, delete it.
	local gametime = GameRules:GetGameTime()
	for _, dummy in pairs(dummies) do
		if dummy:GetUnitName() == "npc_dummy_unit" then			
			local dummy_creation_time = dummy:GetCreationTime()
			if gametime - dummy_creation_time > 60 then
				print("NUKING A LOST DUMMY!")
				UTIL_Remove(dummy)
			else
				print("dummy is still kinda new. Not removing it!")
			end
		end
	end

--	local particle_removed = 0

--	for _, particle in pairs(PARTICLE_TABLE) do
--		print("Particle:", particle)
--		print("Amount:", gametime - particle.lifetime)

--		if gametime - particle.lifetime > 0 then
--			if particle then
--				particle_removed = particle_removed +1
--				table.remove(PARTICLE_TABLE, particle.name)
--			end
--		end
--	end

--	for i = 1, #PARTICLE_TABLE do
--		if manager == PARTICLE_TABLE[i] then
--			particle_removed = particle_removed+1		
--			table.remove(PARTICLE_TABLE, i)
--			break
--		end
--	end

--	if particle_removed > 0 then
--		print("Removed "..particle_removed.." particle.")			
--	end
end
--[[
-- This function is responsible for deciding which team is behind, if any, and store it at a nettable.
function DefineLosingTeam()
-- Losing team is defined as a team that is both behind in both the sums of networth and levels.
local radiant_networth = 0
local radiant_levels = 0
local dire_networth = 0
local dire_levels = 0

	for i = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:IsValidPlayer(i) then

			-- Only count connected players or bots
			if PlayerResource:GetConnectionState(i) == 1 or PlayerResource:GetConnectionState(i) == 2 then

			-- Get player
			local player = PlayerResource:GetPlayer(i)
			
				if player then				
					-- Get team
					local team = player:GetTeam()				

					-- Get level, add it to the sum
					local level = player:GetAssignedHero():GetLevel()				

					-- Get networth
					local hero_networth = 0
					for i = 0, 8 do
						local item = player:GetAssignedHero():GetItemInSlot(i)
						if item then
							hero_networth = hero_networth + GetItemCost(item:GetName())						
						end
					end

					-- Add to the relevant team
					if team == DOTA_TEAM_GOODGUYS then					
						radiant_networth = radiant_networth + hero_networth					
						radiant_levels = radiant_levels + level					
					else					
						dire_networth = dire_networth + hero_networth					
						dire_levels = dire_levels + level					
					end				
				end
			end
		end
	end	

	-- Check for the losing team. A team must be behind in both levels and networth.
	if (radiant_networth < dire_networth) and (radiant_levels < dire_levels) then
		-- Radiant is losing		
		CustomNetTables:SetTableValue("gamerules", "losing_team", {losing_team = DOTA_TEAM_GOODGUYS})

	elseif (radiant_networth > dire_networth) and (radiant_levels > dire_levels) then
		-- Dire is losing		
		CustomNetTables:SetTableValue("gamerules", "losing_team", {losing_team = DOTA_TEAM_BADGUYS})

	else -- No team is losing - one of the team is better on levels, the other on gold. No experience bonus in this case		
		CustomNetTables:SetTableValue("gamerules", "losing_team", {losing_team = 0})		
	end
end
--]]

local ignored_pfx_list = {}
ignored_pfx_list["particles/ambient/fountain_danger_circle.vpcf"] = true
ignored_pfx_list["particles/range_indicator.vpcf"] = true
ignored_pfx_list["particles/units/heroes/hero_skeletonking/wraith_king_ambient_custom.vpcf"] = true
ignored_pfx_list["particles/generic_gameplay/radiant_fountain_regen.vpcf"] = true
ignored_pfx_list["particles/econ/courier/courier_wyvern_hatchling/courier_wyvern_hatchling_fire.vpcf"] = true
ignored_pfx_list["particles/units/heroes/hero_wisp/wisp_tether.vpcf"] = true
ignored_pfx_list["particles/units/heroes/hero_templar_assassin/templar_assassin_trap.vpcf"] = true
ignored_pfx_list["particles/econ/courier/courier_donkey_ti7/courier_donkey_ti7_ambient.vpcf"] = true
ignored_pfx_list["particles/econ/courier/courier_golden_roshan/golden_roshan_ambient.vpcf"] = true
ignored_pfx_list["particles/econ/courier/courier_platinum_roshan/platinum_roshan_ambient.vpcf"] = true
ignored_pfx_list["particles/econ/courier/courier_roshan_darkmoon/courier_roshan_darkmoon.vpcf"] = true
ignored_pfx_list["particles/econ/courier/courier_roshan_desert_sands/baby_roshan_desert_sands_ambient.vpcf"] = true
ignored_pfx_list["particles/econ/courier/courier_roshan_ti8/courier_roshan_ti8.vpcf"] = true
ignored_pfx_list["particles/econ/courier/courier_roshan_lava/courier_roshan_lava.vpcf"] = true
ignored_pfx_list["particles/econ/courier/courier_roshan_frost/courier_roshan_frost_ambient.vpcf"] = true
ignored_pfx_list["particles/econ/courier/courier_babyroshan_winter18/courier_babyroshan_winter18_ambient.vpcf"] = true
ignored_pfx_list["particles/econ/courier/courier_babyroshan_ti9/courier_babyroshan_ti9_ambient.vpcf"] = true
ignored_pfx_list["particles/units/heroes/hero_witchdoctor/witchdoctor_voodoo_restoration.vpcf"] = true
ignored_pfx_list["particles/hero/slardar/slardar_rain_cloud.vpcf"] = true
ignored_pfx_list["particles/units/heroes/hero_earth_spirit/espirit_stoneremnant.vpcf"] = true
ignored_pfx_list["particles/econ/items/tiny/tiny_prestige/tiny_prestige_tree_ambient.vpcf"] = true
ignored_pfx_list["particles/item/rapier/item_rapier_trinity.vpcf"] = true
ignored_pfx_list["particles/item/rapier/item_rapier_archmage.vpcf"] = true
ignored_pfx_list["particles/item/rapier/item_rapier_cursed.vpcf"] = true

-- Call custom functions whenever CreateParticle is being called anywhere
local original_CreateParticle = CScriptParticleManager.CreateParticle
CScriptParticleManager.CreateParticle = function(self, sParticleName, iAttachType, hParent, hCaster)
	local override = nil

	if hCaster then
		--override = CustomNetTables:GetTableValue("battlepass_player", sParticleName..'_'..hCaster:GetPlayerOwnerID()) 
	end

	if override then
		sParticleName = override["1"]
	end

	-- call the original function
	local response = original_CreateParticle(self, sParticleName, iAttachType, hParent)

--	print("CreateParticle response:", sParticleName)

	if not ignored_pfx_list[sParticleName] then
		if hCaster and not hCaster:IsHero() then
			--table.insert(CScriptParticleManager.ACTIVE_PARTICLES, {response, 0})
		else
			--table.insert(CScriptParticleManager.ACTIVE_PARTICLES, {response, 0})
		end
	end

	return response
end

-- Call custom functions whenever CreateParticleForTeam is being called anywhere
local original_CreateParticleForTeam = CScriptParticleManager.CreateParticleForTeam
CScriptParticleManager.CreateParticleForTeam = function(self, sParticleName, iAttachType, hParent, iTeamNumber, hCaster)
--	print("Create Particle (override):", sParticleName, iAttachType, hParent, iTeamNumber, hCaster)

	local override = nil

	if hCaster then
		--override = CustomNetTables:GetTableValue("battlepass_player", sParticleName..'_'..hCaster:GetPlayerOwnerID()) 
	end

	if override then
		sParticleName = override["1"]
	end

	-- call the original function
	local response = original_CreateParticleForTeam(self, sParticleName, iAttachType, hParent, iTeamNumber)

	return response
end

-- Call custom functions whenever CreateParticleForPlayer is being called anywhere
local original_CreateParticleForPlayer = CScriptParticleManager.CreateParticleForPlayer
CScriptParticleManager.CreateParticleForPlayer = function(self, sParticleName, iAttachType, hParent, hPlayer, hCaster)
--	print("Create Particle (override):", sParticleName, iAttachType, hParent, hPlayer, hCaster)

	local override = nil

	if hCaster then
		--override = CustomNetTables:GetTableValue("battlepass_player", sParticleName..'_'..hCaster:GetPlayerOwnerID()) 
	end

	if override then
		sParticleName = override["1"]
	end

	-- call the original function
	local response = original_CreateParticleForPlayer(self, sParticleName, iAttachType, hParent, hPlayer)

	return response
end

function OverrideCreateLinearProjectile()
	local CreateProjectileFunc = ProjectileManager.CreateLinearProjectile

	ProjectileManager.CreateProjectileFunc = 
	function(manager, handle)                  

		-- Do things here to override

		return CreateProjectileFunc(manager, handle)
	end
end

function OverrideReleaseIndex()
local ReleaseIndexFunc = ParticleManager.ReleaseParticleIndex
local released_particles = 0

	ParticleManager.ReleaseParticleIndex = 
	function(manager, int)		
		-- Find handle in table
--		print(#PARTICLE_TABLE)
		for i = 1, #PARTICLE_TABLE do
			if manager == PARTICLE_TABLE[i] then
				released_particles = released_particles+1		
				table.remove(PARTICLE_TABLE, i)
				break
			end
		end

		-- Release normally
		total_particles = total_particles -1
		ReleaseIndexFunc(manager, int)
	end
--	print("Released "..released_particles.." particles.")
end

function PrintParticleTable()
	PrintTable(PARTICLE_TABLE)	
end

-- Custom NetGraph. Creator: Cookies [Earth Salamander]
function ImbaNetGraph(tick)
	Timers:CreateTimer(function()
		local units = FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector(0,0,0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false)		
		local good_unit_count = 0
		local bad_unit_count = 0
		local good_build_count = 0
		local bad_build_count = 0
		local dummy_count = 0

		for _, unit in pairs(units) do
			if unit:GetTeamNumber() == 2 then
				if unit:IsBuilding() then
					good_build_count = good_build_count+1
				else
					good_unit_count = good_unit_count +1
				end
			elseif unit:GetTeamNumber() == 3 then
				if unit:IsBuilding() then
					bad_build_count = bad_build_count+1
				else
					bad_unit_count = bad_unit_count +1
				end
			end
			if unit:GetUnitName() == "npc_dummy_unit" or unit:GetUnitName() == "npc_dummy_unit_perma" then			
				dummy_count = dummy_count +1
			end
		end

		CustomNetTables:SetTableValue("netgraph", "hero_number", {value = PlayerResource:GetPlayerCount()})
		CustomNetTables:SetTableValue("netgraph", "good_unit_number", {value = good_unit_count -4}) -- developer statues
		CustomNetTables:SetTableValue("netgraph", "bad_unit_number", {value = bad_unit_count -4}) -- developer statues
		CustomNetTables:SetTableValue("netgraph", "good_build_number", {value = good_build_count})
		CustomNetTables:SetTableValue("netgraph", "bad_build_number", {value = bad_build_count})
		CustomNetTables:SetTableValue("netgraph", "total_unit_number", {value = #units})
		CustomNetTables:SetTableValue("netgraph", "total_dummy_number", {value = dummy_count})
		CustomNetTables:SetTableValue("netgraph", "total_dummy_created_number", {value = dummy_created_count})
--		CustomNetTables:SetTableValue("netgraph", "total_particle_number", {value = total_particles})
--		CustomNetTables:SetTableValue("netgraph", "total_particle_created_number", {value = total_particles_created})

--		for i = 0, PlayerResource:GetPlayerCount() -1 do
--			CustomNetTables:SetTableValue("netgraph", "hero_particle_"..i-1, {particle = hero_particles[i-1], pID = i-1})
--			CustomNetTables:SetTableValue("netgraph", "hero_total_particle_"..i-1, {particle = total_hero_particles[i-1], pID = i-1})
--		end
	return tick
	end)
end

function table.deepmerge(t1, t2)
	for k,v in pairs(t2) do
		if type(v) == "table" then
			if type(t1[k] or false) == "table" then
				tableMerge(t1[k] or {}, t2[k] or {})
			else
				t1[k] = v
			end
		else
			t1[k] = v
		end
	end
	return t1
end

function CustomHeroAttachments(hero, illusion)

	hero_name = hero:GetUnitName()

	for i = 1, 8 do
		if GetKeyValueByHeroName(hero_name, "Ability"..i) ~= nil then
			local ab = hero:AddAbility(GetKeyValueByHeroName(hero_name, "Ability"..i))
			if GetKeyValueByHeroName(hero_name, "Ability"..i) == "ghost_revenant_ghost_immolation" or GetKeyValueByHeroName(hero_name, "Ability"..i) == "hell_empress_ambient_effects" then
				ab:SetLevel(1)
			end
		end
	end

	if hero_name == "npc_dota_hero_ghost_revenant" then
		hero:SetRenderColor(128, 255, 0)
		hero.head = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/razor/apostle_of_the_tempest_head/apostle_of_the_tempest_head.vmdl"})
		hero.head:FollowEntity(hero, true)
		hero.head:SetRenderColor(128, 255, 0)
		hero.arms = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/razor/apostle_of_the_tempest_arms/apostle_of_the_tempest_arms.vmdl"})
		hero.arms:FollowEntity(hero, true)
		hero.arms:SetRenderColor(128, 255, 0)
		hero.body = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/razor/apostle_of_the_tempest_armor/apostle_of_the_tempest_armor.vmdl"})
		hero.body:FollowEntity(hero, true)
		hero.body:SetRenderColor(128, 255, 0)
		hero.belt = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/razor/empire_of_the_lightning_lord_belt/empire_of_the_lightning_lord_belt.vmdl"})
		hero.belt:FollowEntity(hero, true)
		hero.belt:SetRenderColor(128, 255, 0)
		hero.weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/razor/severing_lash/mesh/severing_lash.vmdl"})
		hero.weapon:FollowEntity(hero, true)
		hero.weapon:SetRenderColor(128, 255, 0)
	elseif hero_name == "npc_dota_hero_hell_empress" then
		
	elseif hero_name == "npc_dota_hero_scaldris" then
		for i = 0, 24 do
			if hero:GetAbilityByIndex(i) then
				hero:RemoveAbility(hero:GetAbilityByIndex(i):GetAbilityName())
			end
		end
		hero:AddAbility("imba_scaldris_heatwave")
		hero:AddAbility("imba_scaldris_scorch")
		hero:AddAbility("imba_scaldris_jet_blaze")
		hero:AddAbility("generic_hidden")
		local ab = hero:AddAbility("imba_scaldris_antipode")
		ab:SetLevel(1)
		hero:AddAbility("imba_scaldris_living_flame")
		hero:AddAbility("imba_scaldris_cold_front")
		hero:AddAbility("imba_scaldris_freeze")
		hero:AddAbility("imba_scaldris_ice_floes")
		hero:AddAbility("imba_scaldris_absolute_zero")
		hero:AddAbility("generic_hidden")
		hero:AddAbility("generic_hidden")
		hero:AddAbility("generic_hidden")
		hero:AddAbility("generic_hidden")
		hero:AddAbility("generic_hidden")
		hero:AddAbility("generic_hidden")
		hero:AddAbility("generic_hidden")
		hero:AddAbility("generic_hidden")
		hero:AddAbility("generic_hidden")
		hero:AddAbility("generic_hidden")
		hero:AddAbility("generic_hidden")
		hero:AddAbility("generic_hidden")
		hero:AddAbility("generic_hidden")
		hero:AddAbility("generic_hidden")
	end
end

function ReconnectPlayer(player_id)
	print("Player is reconnecting:", player_id)
	-- Reinitialize the player's pick screen panorama, if necessary
	if HeroSelection.HorriblyImplementedReconnectDetection then
		HeroSelection.HorriblyImplementedReconnectDetection[player_id] = false
		Timers:CreateTimer(1.0, function()
			if HeroSelection.HorriblyImplementedReconnectDetection[player_id] then
				local pick_state = HeroSelection.playerPickState[player_id].pick_state
				local repick_state = HeroSelection.playerPickState[player_id].repick_state

				local data = {
					PlayerID = player_id,
					PickedHeroes = HeroSelection.picked_heroes,
					pickState = pick_state,
					repickState = repick_state
				}

				PrintTable(HeroSelection.picked_heroes)
				CustomGameEventManager:Send_ServerToAllClients("player_reconnected", {PlayerID = player_id, PickedHeroes = HeroSelection.picked_heroes, pickState = pick_state, repickState = repick_state})
			else
				print("Not fully reconnected yet:", player_id)
				return 0.1
			end
		end)

		-- If this is a reconnect from abandonment due to a long disconnect, remove the abandon state
		if PlayerResource:GetHasAbandonedDueToLongDisconnect(player_id) then
			local player_name = keys.name
			local hero = PlayerResource:GetPickedHero(player_id)
			local hero_name = PlayerResource:GetPickedHeroName(player_id)
			local line_duration = 7
			Notifications:BottomToAll({hero = hero_name, duration = line_duration})
			Notifications:BottomToAll({text = player_name.." ", duration = line_duration, continue = true})
			Notifications:BottomToAll({text = "#imba_player_reconnect_message", duration = line_duration, style = {color = "DodgerBlue"}, continue = true})

			-- Stop redistributing gold to allies, if applicable
			PlayerResource:StopAbandonGoldRedistribution(player_id)
		end
	else
		print("Player "..player_id.." has not fully connected before this time")
	end
end

function DonatorCompanion(ID, model)
if model == nil then return end
local hero = PlayerResource:GetPlayer(ID):GetAssignedHero()
local color = hero:GetFittingColor()

	if hero.companion then
		hero.companion:ForceKill(false)
	end

	local companion = CreateUnitByName(model, hero:GetAbsOrigin() + RandomVector(200), true, hero, hero, hero:GetTeamNumber())
	companion:SetOwner(hero)
	companion:SetControllableByPlayer(hero:GetPlayerID(), true)

	companion:AddNewModifier(companion, nil, "modifier_companion", {})

	hero.companion = companion

	if model == "npc_imba_donator_companion_cookies" then
		companion:AddNewModifier(companion, nil, "modifier_imba_frost_rune_aura", {})
		companion:SetRenderColor(90, 120 , 200)
		companion:SetMaterialGroup("1")
	elseif model == "npc_imba_donator_companion_suthernfriend" then
		companion:SetMaterialGroup("1")
	end

--	if string.find(model, "flying") then
--		companion:SetMoveCapability(DOTA_UNIT_CAP_MOVE_FLY)
--	end

--	if super_donator then
--		local ab = companion:FindAbilityByName("companion_morph")
--		ab:SetLevel(1)
--		ab:CastAbility()		
--	end
end

function UpdateRoshanBar(roshan)
	CustomNetTables:SetTableValue("game_options", "roshan", {
		level = roshan:GetLevel(),
		HP = roshan:GetHealth(),
		HP_alt = roshan:GetHealthPercent(),
		maxHP = roshan:GetMaxHealth()
	})
	return time
end

-- Checks if this ability is casted by someone with Spell Steal (i.e. Rubick)
function IsStolenSpell(caster)

	-- If the caster has the Spell Steal ability, return true
	if caster:FindAbilityByName("rubick_spell_steal") then
		return true
	end

	return false
end

function InitRunes()
	bounty_rune_spawners = {}
	bounty_rune_locations = {}
	powerup_rune_spawners = {}
	powerup_rune_locations = {}

	bounty_rune_spawners = Entities:FindAllByName("bounty_rune_location")

	if GetMapName() == "imba_overthrow" then
		powerup_rune_spawners = Entities:FindAllByName("dota_item_rune_spawner")
	else
		powerup_rune_spawners = Entities:FindAllByName("powerup_rune_location")
	end

	for i = 1, #powerup_rune_spawners do
		powerup_rune_locations[i] = powerup_rune_spawners[i]:GetAbsOrigin()
		powerup_rune_spawners[i]:RemoveSelf()
	end

	for i = 1, #bounty_rune_spawners do
		bounty_rune_locations[i] = bounty_rune_spawners[i]:GetAbsOrigin()
		bounty_rune_spawners[i]:RemoveSelf()
	end
end

-- Spawns runes on the map
function SpawnImbaRunes()
bounty_rune_is_initial_bounty_rune = false

	-- Remove any existing runes, if any
	RemoveRunes()

	-- List of powerup rune types
	local powerup_rune_types = {
		"item_imba_rune_arcane",
		"item_imba_rune_double_damage",
		"item_imba_rune_haste",
		"item_imba_rune_regeneration",
		"item_imba_rune_illusion",
		"item_imba_rune_invisibility",
		"item_imba_rune_frost",
	}

	local rune
	for k, v in pairs(powerup_rune_locations) do
		rune = CreateItemOnPositionForLaunch(powerup_rune_locations[k], CreateItem(powerup_rune_types[RandomInt(1, #powerup_rune_types)], nil, nil))
		RegisterRune(rune)
	end

	for k, v in pairs(bounty_rune_locations) do
		local bounty_rune = CreateItem("item_imba_rune_bounty", nil, nil)
		rune = CreateItemOnPositionForLaunch(bounty_rune_locations[k], bounty_rune)		
		RegisterRune(rune)

		-- If these are the 00:00 runes, double their worth
		local game_time = GameRules:GetDOTATime(false, false)
		if game_time < 1 then
			bounty_rune_is_initial_bounty_rune = true
		end
	end
end

function RegisterRune(rune)

	-- Initialize table
	if not rune_spawn_table then
		rune_spawn_table = {}
	end

	-- Register rune into table
	table.insert(rune_spawn_table, rune)
end

function RemoveRunes()
	if rune_spawn_table then

		-- Remove existing runes
		for _,rune in pairs(rune_spawn_table) do
			if not rune:IsNull() then								
				local item = rune:GetContainedItem()
				UTIL_Remove(item)
				UTIL_Remove(rune)
			end
		end

		-- Clear the table
		rune_spawn_table = {}
	end
end

function PickupRune(rune_name, unit, bActiveByBottle)
	if string.find(rune_name, "item_imba_rune_") then
		rune_name = string.gsub(rune_name, "item_imba_rune_", "")
	end

	local bottle = bActiveByBottle or false
	local store_in_bottle = false
	local duration = GetItemKV("item_imba_rune_"..rune_name, "RuneDuration")

	for i = 0, 5 do
		local item = unit:GetItemInSlot(i)
		if item and not bottle then
			if item:GetAbilityName() == "item_imba_bottle" and not item.RuneStorage then
				item:SetStorageRune(rune_name)
				store_in_bottle = true
				break
			end
		end
	end

	if not store_in_bottle then
		if rune_name == "bounty" then
			-- Bounty rune parameters
			local base_bounty = 100
			local bounty_per_minute = 4
			local xp_per_minute = 10
			local game_time = GameRules:GetDOTATime(false, false)
			local current_bounty = base_bounty + bounty_per_minute * game_time / 60
			local current_xp = xp_per_minute * game_time / 60

			-- If this is the first bounty rune spawn, double the base bounty
			if bounty_rune_is_initial_bounty_rune then
				current_bounty = current_bounty  * 2
			end

			-- Adjust value for lobby options
			local custom_gold_bonus = tonumber(CustomNetTables:GetTableValue("game_options", "bounty_multiplier")["1"])
			current_bounty = current_bounty * (1 + custom_gold_bonus * 0.01)

			-- Grant the unit experience
			unit:AddExperience(current_xp, DOTA_ModifyXP_CreepKill, false, true)

			-- If this is alchemist, increase the gold amount
			if unit:FindAbilityByName("imba_alchemist_goblins_greed") and unit:FindAbilityByName("imba_alchemist_goblins_greed"):GetLevel() > 0 then
				current_bounty = current_bounty * (unit:FindAbilityByName("imba_alchemist_goblins_greed"):GetSpecialValueFor("bounty_multiplier") / 100)

				-- #7 Talent: Doubles gold from bounty runes
				if unit:HasTalent("special_bonus_imba_alchemist_7") then
					current_bounty = current_bounty * (unit:FindTalentValue("special_bonus_imba_alchemist_7") / 100)
				end		
			end

			-- #3 Talent: Bounty runes give gold bags
			if unit:HasTalent("special_bonus_imba_alchemist_3") then
				local stacks_to_gold =( unit:FindTalentValue("special_bonus_imba_alchemist_3") / 100 )  / 5
				local gold_per_bag = unit:FindModifierByName("modifier_imba_goblins_greed_passive"):GetStackCount() * stacks_to_gold
				for i=1, 5 do
					-- Drop gold bags
					local newItem = CreateItem( "item_bag_of_gold", nil, nil )
					newItem:SetPurchaseTime( 0 )
					newItem:SetCurrentCharges( gold_per_bag )
					
					local drop = CreateItemOnPositionSync( unit:GetAbsOrigin(), newItem )
					local dropTarget = unit:GetAbsOrigin() + RandomVector( RandomFloat( 300, 450 ) )
					newItem:LaunchLoot( true, 300, 0.75, dropTarget )
					EmitSoundOn( "Dungeon.TreasureItemDrop", unit )
				end
			end

	--		"particles/generic_gameplay/rune_bounty_owner.vpcf"

			unit:ModifyGold(current_bounty, false, DOTA_ModifyGold_Unspecified)
			SendOverheadEventMessage(PlayerResource:GetPlayer(unit:GetPlayerOwnerID()), OVERHEAD_ALERT_GOLD, unit, current_bounty, nil)
--			EmitSoundOnLocationForAllies(unit:GetAbsOrigin(), "General.Coins", unit)
			EmitSoundOnLocationForAllies(unit:GetAbsOrigin(), "Rune.Bounty", unit)
		elseif rune_name == "arcane" then
			unit:AddNewModifier(unit, item, "modifier_imba_arcane_rune", {duration=duration})
			EmitSoundOnLocationForAllies(unit:GetAbsOrigin(), "Rune.Arcane", unit)
		elseif rune_name == "double_damage" then
			unit:AddNewModifier(unit, item, "modifier_imba_double_damage_rune", {duration=duration})
			EmitSoundOnLocationForAllies(unit:GetAbsOrigin(), "Rune.DD", unit)
		elseif rune_name == "haste" then
			unit:AddNewModifier(unit, item, "modifier_imba_haste_rune", {duration=duration})
			EmitSoundOnLocationForAllies(unit:GetAbsOrigin(), "Rune.Haste", unit)
		elseif rune_name == "illusion" then
			local images_count = 3
			local vRandomSpawnPos = {
				Vector( 72, 0, 0 ),		-- North
				Vector( 0, 72, 0 ),		-- East
				Vector( -72, 0, 0 ),	-- South
				Vector( 0, -72, 0 ),	-- West
			}

			for i = #vRandomSpawnPos, 2, -1 do	-- Simply shuffle them
				local j = RandomInt( 1, i )
				vRandomSpawnPos[i], vRandomSpawnPos[j] = vRandomSpawnPos[j], vRandomSpawnPos[i]
			end

			table.insert( vRandomSpawnPos, RandomInt( 1, images_count+1 ), Vector( 0, 0, 0 ) )
			FindClearSpaceForUnit(unit, unit:GetAbsOrigin() + table.remove( vRandomSpawnPos, 1 ), true)

			for i = 1, images_count do
				local origin = unit:GetAbsOrigin() + table.remove( vRandomSpawnPos, 1 )
				local illusion = IllusionManager:CreateIllusion(unit, self, origin, unit, {damagein=incomingDamage, damageout=outcomingDamage, unique=unit:entindex().."_rune_illusion_"..i, duration=duration})
			end
			EmitSoundOnLocationForAllies(unit:GetAbsOrigin(), "Rune.Illusion", unit)
		elseif rune_name == "invisibility" then
			unit:AddNewModifier(unit, nil, "modifier_rune_invis", {duration=duration})
			EmitSoundOnLocationForAllies(unit:GetAbsOrigin(), "Rune.Invis", unit)
		elseif rune_name == "regeneration" then
			unit:AddNewModifier(unit, nil, "modifier_imba_regen_rune", {duration=duration})
			EmitSoundOnLocationForAllies(unit:GetAbsOrigin(), "Rune.Regen", unit)
		elseif rune_name == "frost" then
			unit:AddNewModifier(unit, nil, "modifier_imba_frost_rune", {duration=duration})
			EmitSoundOnLocationForAllies(unit:GetAbsOrigin(), "Rune.Frost", unit)
		end

		CustomGameEventManager:Send_ServerToTeam(unit:GetTeam(), "create_custom_toast", {
			type = "generic",
			text = "#custom_toast_ActivatedRune",
			player = unit:GetPlayerID(),
			runeType = rune_name
		})
	end
end

function CBaseEntity:IsRune()
	local runes = {
		"models/props_gameplay/rune_goldxp.vmdl",
		"models/props_gameplay/rune_haste01.vmdl",
		"models/props_gameplay/rune_doubledamage01.vmdl",
		"models/props_gameplay/rune_regeneration01.vmdl",
		"models/props_gameplay/rune_arcane.vmdl",
		"models/props_gameplay/rune_invisibility01.vmdl",
		"models/props_gameplay/rune_illusion01.vmdl",
		"models/props_gameplay/rune_frost.vmdl",
		"models/props_gameplay/gold_coin001.vmdl",	-- Overthrow coin
	}

	for _, model in pairs(runes) do
		if self:GetModelName() == model then
			return true
		end
	end
	return false
end

-- Overthrow
function PickRandomShuffle( reference_list, bucket )
	if ( #reference_list == 0 ) then
		return nil
	end
	
	if ( #bucket == 0 ) then
		-- ran out of options, refill the bucket from the reference
		for k, v in pairs(reference_list) do
			bucket[k] = v
		end
	end

	-- pick a value from the bucket and remove it
	local pick_index = RandomInt( 1, #bucket )
	local result = bucket[ pick_index ]
	table.remove( bucket, pick_index )
	return result
end

function shallowcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in pairs(orig) do
			copy[orig_key] = orig_value
		end
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

function ShuffledList( orig_list )
	local list = shallowcopy( orig_list )
	local result = {}
	local count = #list
	for i = 1, count do
		local pick = RandomInt( 1, #list )
		result[ #result + 1 ] = list[ pick ]
		table.remove( list, pick )
	end
	return result
end

function TableCount( t )
	local n = 0
	for _ in pairs( t ) do
		n = n + 1
	end
	return n
end

function TableFindKey( table, val )
	if table == nil then
		print( "nil" )
		return nil
	end

	for k, v in pairs( table ) do
		if v == val then
			return k
		end
	end
	return nil
end

function CountdownTimer()
	nCOUNTDOWNTIMER = nCOUNTDOWNTIMER - 1
	local t = nCOUNTDOWNTIMER
	-- print( t )
	local minutes = math.floor(t / 60)
	local seconds = t - (minutes * 60)
	local m10 = math.floor(minutes / 10)
	local m01 = minutes - (m10 * 10)
	local s10 = math.floor(seconds / 10)
	local s01 = seconds - (s10 * 10)
	local broadcast_gametimer = 
		{
			timer_minute_10 = m10,
			timer_minute_01 = m01,
			timer_second_10 = s10,
			timer_second_01 = s01,
		}
	CustomGameEventManager:Send_ServerToAllClients( "countdown", broadcast_gametimer )
	if t <= 120 then
		CustomGameEventManager:Send_ServerToAllClients( "time_remaining", broadcast_gametimer )
	end
end
-----------------------------------------------------------------------------
-------------------------------------- IMPORTED FROM OLD LIBRARY BELOW ------
----------------------------------------------------------------------------
-- Fetches a hero's current spell power from talents
function GetSpellPowerFromTalents(unit)
	local spell_power = 0

	-- Iterate through all spell power talents
	for talent_name,spell_power_bonus in pairs(SPELL_POWER_TALENTS) do
		if unit:FindAbilityByName(talent_name) and unit:FindAbilityByName(talent_name):GetLevel() > 0 then
			spell_power = spell_power + spell_power_bonus
		end
	end

	return spell_power
end

-- Fetches a hero's current spell power
function GetSpellPower(unit)

	-- If this is not a hero, or the unit is invulnerable, do nothing
	if not unit:IsHero() or unit:IsInvulnerable() then
		return 0
	end

	-- Adjust base spell power based on current intelligence
	local unit_intelligence = unit:GetIntellect()
	local spell_power = unit_intelligence * 0.125

	-- Adjust spell power based on War Veteran stacks
	if unit:HasModifier("modifier_imba_unlimited_level_powerup") then
		spell_power = spell_power + 2 * unit:GetModifierStackCount("modifier_imba_unlimited_level_powerup", unit)
	end

	-- Define item-based item power values
	local item_spell_power = {}
	item_spell_power["item_imba_aether_lens"] = 10
	item_spell_power["item_imba_nether_wand"] = 10
	item_spell_power["item_imba_elder_staff"] = 20
	item_spell_power["item_imba_orchid"] = 25
	item_spell_power["item_imba_bloodthorn"] = 30
	item_spell_power["item_imba_rapier_magic"] = 70
	item_spell_power["item_imba_rapier_magic_2"] = 200
	item_spell_power["item_imba_rapier_cursed"] = 200

	-- Fetch current bonus spell power from items, if existing
	for i = 0, 5 do
		local current_item = unit:GetItemInSlot(i)
		if current_item then
			local current_item_name = current_item:GetName()
			if item_spell_power[current_item_name] then
				spell_power = spell_power + item_spell_power[current_item_name]
			end
		end
	end

	-- Fetch bonus spell power from talents
	spell_power = spell_power + GetSpellPowerFromTalents(unit)

	-- Return current spell power
	return spell_power
end

-- Returns true if a hero has red hair
function IsGinger(unit)

	local ginger_hero_names = {
		"npc_dota_hero_enchantress",
		"npc_dota_hero_lina",
		"npc_dota_hero_windrunner"
	}

	local unit_name = unit:GetName()
	for _,name in pairs(ginger_hero_names) do
		if name == unit_name then
			return true
		end
	end
	
	return false
end

-- Colors
COLOR_NONE = '\x06'
COLOR_GRAY = '\x06'
COLOR_GREY = '\x06'
COLOR_GREEN = '\x0C'
COLOR_DPURPLE = '\x0D'
COLOR_SPINK = '\x0E'
COLOR_DYELLOW = '\x10'
COLOR_PINK = '\x11'
COLOR_RED = '\x12'
COLOR_LGREEN = '\x15'
COLOR_BLUE = '\x16'
COLOR_DGREEN = '\x18'
COLOR_SBLUE = '\x19'
COLOR_PURPLE = '\x1A'
COLOR_ORANGE = '\x1B'
COLOR_LRED = '\x1C'
COLOR_GOLD = '\x1D'

-- Returns a random value from a non-array table
function RandomFromTable(table)
	local array = {}
	local n = 0
	for _,v in pairs(table) do
		array[#array+1] = v
		n = n + 1
	end

	if n == 0 then return nil end

	return array[RandomInt(1,n)]
end

function TableHasValue(val, checkTable)
	for k,v in pairs(checkTable) do
		if v == val then return true end
	end
	return false
end

function CheckTrollCombo(tower, newAbility, banList)
	local build = {}
	for i=0,23 do
		local ab = tower:GetAbilityByIndex(i)
		if ab then
			table.insert(build, ab:GetName())
			-- print("existing: ", ab:GetName())
		end
	end

	table.insert(build, newAbility)
	-- print("existing+: ", newAbility)

    for i=1,util:getTableLength(build) do
        local ab1 = build[i]
        if ab1 ~= nil and banList[ab1] then
            for j=(i+1),util:getTableLength(build) do
                local ab2 = build[j]

                if ab2 ~= nil and banList[ab1][ab2] then
                    -- Ability should be banned

                    return true, ab1, ab2
                end
            end
        end
    end

    return false
end

function PullTowerAbility(towerTable, usedTable, trollCombos, abilityTable,difference, baseMax,tower)
	local array = {}
	local n = 0
	local maxDiff = 5 -- Change this to narrow search parameters
	
	local searchParamMax = math.abs(difference)
	local searchParamMin = math.abs(difference) - maxDiff
	if searchParamMax <= 0 then 
		searchParamMax = baseMax - maxDiff
		searchParamMin = baseMax - maxDiff * 2
	end
	if searchParamMin < 0 then searchParamMin = 0 end
	
	local escape = 0
	while n == 0 do
		escape = escape + 1
		searchParamMax = searchParamMax + maxDiff -- Broadens search params on fail
		if searchParamMin > maxDiff then 
			searchParamMin = searchParamMin - maxDiff
		else searchParamMin = 0 end
		for k,v in pairs(towerTable) do
			if not usedTable[k] and not TableHasValue(k, abilityTable) and tonumber(v) <= searchParamMax and tonumber(v) > math.abs(searchParamMin) then
				table.insert(array, k)
				n = n + 1
			end
		end  
		if escape >= util:getTableLength(towerTable) then usedTable = {} end -- clears used abilities
		-- print(escape)
	end
	ShuffleArray(array)
	for k,v in pairs(array) do
		if not CheckTrollCombo(tower, v, trollCombos) then
			return v
		end
	end
end

function GetTowerAbilityPowerValue(tower, kv)
	tower.strongTowerAbilities = tower.strongTowerAbilities or {}
	local powerVal = 0
	for amount,abName in pairs(tower.strongTowerAbilities) do
		powerVal = powerVal + kv[abName]
	end
	return powerVal
end

function GetEquivalentTowerAbilityPowerValue(tower, kv, limit)
	tower.strongTowerAbilities = tower.strongTowerAbilities or {}
	local powerVal = 0
	for amount,abName in pairs(tower.strongTowerAbilities) do
		if amount < limit then
			powerVal = powerVal + kv[abName]
		else 
			break
		end
	end
	return powerVal
end

MAX_RADIANT = Vector(-4820, -4478)
MAX_DIRE = Vector(4594, 4038)
MAP_OFFSET_MID = Vector(-569, -285)
MAP_OFFSET_LANE_X = Vector(3000,-3000)

RADIANT_TOP_MIN = Vector(-7564, -3557)
RADIANT_TOP_MAX = Vector(-4939, 7533)

DIRE_TOP_MIN = Vector(-6800, 4928)
DIRE_TOP_MAX = Vector(3899, 6683)

RADIANT_BOT_MIN = Vector(-4317, -7097)
RADIANT_BOT_MAX = Vector(6809, -5342)

DIRE_BOT_MIN = Vector(5739, -6711)
DIRE_BOT_MAX = Vector(6852, 3088)

function FindSisterTower(tower)
	if tower.sisterTower then
		return tower.sisterTower
	else
		if tower:GetLevel() < 4 then
			if tower:GetUnitName() ~= "npc_dota_tower" then
				local originalTeam = "goodguys"
				local sisterTeam = "badguys"
				if tower:GetTeamNumber() == DOTA_TEAM_BADGUYS then
					originalTeam = "badguys"
					sisterTeam = "goodguys"
				end
				local sisterTowerName = string.gsub(tower:GetName(), originalTeam, sisterTeam)
				sisterTower = Entities:FindByName(nil, sisterTowerName)
				tower.sisterTower = sisterTower
				sisterTower.sisterTower = tower
				print(sisterTower:GetAbsOrigin(), "normal")
				return sisterTower
			else
				local sisterTowerLoc = tower:GetAbsOrigin()
				local towerLoc = tower:GetAbsOrigin()
				if towerLoc.x > MAX_RADIANT.x and towerLoc.y > MAX_RADIANT.y and towerLoc.x < MAX_DIRE.x and towerLoc.y < MAX_DIRE.y then --find if mid tower
					sisterTowerLoc = -towerLoc + MAP_OFFSET
				else
					-- Vector(2, -1) -> Vector(1, -2)
					if (towerLoc.x > DIRE_TOP_MIN.x and towerLoc.y > DIRE_TOP_MIN.y and towerLoc.x < DIRE_TOP_MAX.x and towerLoc.y < DIRE_TOP_MAX.y ) or (towerLoc.x > RADIANT_TOP_MIN.x and towerLoc.y > RADIANT_TOP_MIN.y and towerLoc.x < RADIANT_TOP_MAX.x and towerLoc.y < RADIANT_TOP_MAX.y ) then -- TOP TOWERS
						if math.abs(towerLoc.x) < math.abs(towerLoc.y) then -- radiant
							towerLoc.x = towerLoc.x + 3000
						else -- dire
							towerLoc.y = towerLoc.y + 3000
						end
					elseif (towerLoc.x > DIRE_BOT_MIN.x and towerLoc.y > DIRE_BOT_MIN.y and towerLoc.x < DIRE_BOT_MAX.x and towerLoc.y < DIRE_BOT_MAX.y ) or (towerLoc.x > RADIANT_BOT_MIN.x and towerLoc.y > RADIANT_BOT_MIN.y and towerLoc.x < RADIANT_BOT_MAX.x and towerLoc.y < RADIANT_BOT_MAX.y ) then -- BOT TOWERS
						if math.abs(towerLoc.x) < math.abs(towerLoc.y) then -- radiant
							towerLoc.x = towerLoc.x - 3000
						else -- dire
							towerLoc.y = towerLoc.y - 3000
						end
					end
					sisterTowerLoc.y = -towerLoc.x
					sisterTowerLoc.y = -towerLoc.y
				end
				sisterTower = Entities:FindByNameNearest(tower:GetUnitName(), sisterTowerLoc, 800)
				tower.sisterTower = sisterTower
				sisterTower.sisterTower = tower
				print(sisterTower:GetAbsOrigin(), "extra")
				return sisterTower
			end
		end
	end
	return nil
end

-------------------------------------------------------------------------------------------------
-- IMBA: custom utility functions
-------------------------------------------------------------------------------------------------

-- Checks if a hero is wielding Aghanim's Scepter
function HasScepter(hero)
	if hero:HasModifier("modifier_item_ultimate_scepter_consumed") or hero:HasModifier("modifier_item_imba_ultimate_scepter_synth") then
		return true
	end

	for i=0,5 do
		local item = hero:GetItemInSlot(i)
		if item and item:GetAbilityName() == "item_ultimate_scepter" then
			return true
		end
	end
	
	return false
end

-- Checks if a hero is wielding an Aegis of the immortal
function HasAegis(hero)
	if hero.has_aegis then
		return true
	end
	return false
end

-- Adds [stack_amount] stacks to a modifier
function AddStacks(ability, caster, unit, modifier, stack_amount, refresh)
	if unit:HasModifier(modifier) then
		if refresh then
			ability:ApplyDataDrivenModifier(caster, unit, modifier, {})
		end
		unit:SetModifierStackCount(modifier, ability, unit:GetModifierStackCount(modifier, nil) + stack_amount)
	else
		ability:ApplyDataDrivenModifier(caster, unit, modifier, {})
		unit:SetModifierStackCount(modifier, ability, stack_amount)
	end
end

-- Removes [stack_amount] stacks from a modifier
function RemoveStacks(ability, unit, modifier, stack_amount)
	if unit:HasModifier(modifier) then
		if unit:GetModifierStackCount(modifier, ability) > stack_amount then
			unit:SetModifierStackCount(modifier, ability, unit:GetModifierStackCount(modifier, ability) - stack_amount)
		else
			unit:RemoveModifierByName(modifier)
		end
	end
end

-- Switches one skill with another
function SwitchAbilities(hero, added_ability_name, removed_ability_name, keep_level, keep_cooldown)
	local removed_ability = hero:FindAbilityByName(removed_ability_name)
	local level = removed_ability:GetLevel()
	local cooldown = removed_ability:GetCooldownTimeRemaining()
	hero:RemoveAbility(removed_ability_name)
	hero:AddAbility(added_ability_name)
	local added_ability = hero:FindAbilityByName(added_ability_name)
	
	if keep_level then
		added_ability:SetLevel(level)
	end
	
	if keep_cooldown then
		added_ability:StartCooldown(cooldown)
	end
end

-- Removes unwanted passive modifiers from illusions upon their creation
function IllusionPassiveRemover( keys )
	local target = keys.target
	local modifier = keys.modifier

	if target:IsIllusion() or not target:GetPlayerOwner() then
		target:RemoveModifierByName(modifier)
	end
end

function ApplyDataDrivenModifierWhenPossible( caster, target, ability, modifier_name)
	Timers:CreateTimer(0, function()
		if target:IsOutOfGame() or target:IsInvulnerable() then
			return 0.1
		else
			ability:ApplyDataDrivenModifier(caster, target, modifier_name, {})
		end			
	end)
end

--[[ ============================================================================================================
	Author: Rook
	Date: February 3, 2015
	A helper method that switches the removed_item item to one with the inputted name.
================================================================================================================= ]]
function SwapToItem(caster, removed_item, added_item)
	for i=0, 5, 1 do  --Fill all empty slots in the player's inventory with "dummy" items.
		local current_item = caster:GetItemInSlot(i)
		if current_item == nil then
			caster:AddItem(CreateItem("item_imba_dummy", caster, caster))
		end
	end
	
	caster:RemoveItem(removed_item)
	caster:AddItem(CreateItem(added_item, caster, caster))  --This should be put into the same slot that the removed item was in.
	
	for i=0, 5, 1 do  --Remove all dummy items from the player's inventory.
		local current_item = caster:GetItemInSlot(i)
		if current_item ~= nil then
			if current_item:GetName() == "item_imba_dummy" then
				caster:RemoveItem(current_item)
			end
		end
	end
end

-- Checks if a given unit is Roshan
function CDOTA_BaseNPC:IsRoshan()
	if self:GetName() == "npc_imba_roshan" or self:GetName() == "npc_dota_roshan" or self:GetUnitLabel() == "npc_diretide_roshan" then
		return true
	else
		return false
	end
end

-- Checks if a given unit is a ward, or Techies bomb
function IsWardOrBomb(unit)

	local unit_name = unit:GetUnitName()
	local valid_unit_names = {
		"npc_dota_observer_wards",
		"npc_dota_sentry_wards",
		"npc_imba_techies_land_mine",
		"npc_imba_techies_stasis_trap",
		"npc_dota_techies_remote_mine"
	}

	for _,name in pairs(valid_unit_names) do
		if unit_name == name then
			return true
		end
	end

	return false
end

-- 100% kills a unit. Activates death-preventing modifiers, then removes them. Does not killsteal from Reaper's Scythe.
function TrueKill(caster, target, ability)
	
	-- Shallow Grave is peskier
	target:RemoveModifierByName("modifier_imba_shallow_grave")

	-- Extremely specific blademail interaction because fuck everything
	if caster:HasModifier("modifier_item_blade_mail_reflect") then
		target:RemoveModifierByName("modifier_imba_purification_passive")
	end

	-- Deals lethal damage in order to trigger death-preventing abilities... Except for Reincarnation
	if not ( target:HasModifier("modifier_imba_reincarnation") or target:HasModifier("modifier_imba_reincarnation_scepter") ) then
		target:Kill(ability, caster)
	end

	-- Removes the relevant modifiers
	target:RemoveModifierByName("modifier_invulnerable")
	target:RemoveModifierByName("modifier_imba_shallow_grave")
	target:RemoveModifierByName("modifier_aphotic_shield")
	target:RemoveModifierByName("modifier_imba_spiked_carapace")
	target:RemoveModifierByName("modifier_borrowed_time")
	target:RemoveModifierByName("modifier_imba_centaur_return")
	target:RemoveModifierByName("modifier_item_greatwyrm_plate_unique")
	target:RemoveModifierByName("modifier_item_greatwyrm_plate_active")
	target:RemoveModifierByName("modifier_item_crimson_guard_unique")
	target:RemoveModifierByName("modifier_item_crimson_guard_active")
	target:RemoveModifierByName("modifier_item_greatwyrm_plate_unique")
	target:RemoveModifierByName("modifier_item_vanguard_unique")
	target:RemoveModifierByName("modifier_item_imba_initiate_robe_stacks")
	target:RemoveModifierByName("modifier_imba_cheese_death_prevention")
	target:RemoveModifierByName("modifier_item_imba_rapier_cursed_unique")

	-- Kills the target
	target:Kill(ability, caster)
end

-- Checks if a unit is near units of a certain class not on its team
function IsNearEnemyClass(unit, radius, class)
	local class_units = Entities:FindAllByClassnameWithin(class, unit:GetAbsOrigin(), radius)

	for _,found_unit in pairs(class_units) do
		if found_unit:GetTeam() ~= unit:GetTeam() then
			return true
		end
	end
	
	return false
end

-- Checks if a unit is near units of a certain class on the same team
function IsNearFriendlyClass(unit, radius, class)
	local class_units = Entities:FindAllByClassnameWithin(class, unit:GetAbsOrigin(), radius)

	for _,found_unit in pairs(class_units) do
		if found_unit:GetTeam() == unit:GetTeam() then
			return true
		end
	end
	
	return false
end

-- Returns if this unit is a fountain or not
function IsFountain( unit )
	if unit:GetName() == "ent_dota_fountain_bad" or unit:GetName() == "ent_dota_fountain_good" then
		return true
	end
	
	return false
end

-- Returns if this unit is a player-owned summon or not
function IsPlayerOwnedSummon( unit )

	local summon_classes = {
		"npc_dota_techies_mines",
		"npc_dota_venomancer_plagueward",
		"npc_dota_lone_druid_bear"
	}

	local unit_name = unit:GetName()

	for i = 1, #summon_classes do
		if unit_name == summon_classes[i] then
			return true
		end
	end

	local summon_names = {
		"npc_imba_warlock_golem_extra"
	}

	unit_name = unit:GetUnitName()

	for i = 1, #summon_names do
		if unit_name == summon_names[i] then
			return true
		end
	end
	
	return false
end

-- Returns true if the target is hard disabled
function IsHardDisabled( unit )
	if unit:IsStunned() or unit:IsHexed() or unit:IsNightmared() or unit:IsOutOfGame() or unit:HasModifier("modifier_axe_berserkers_call") then
		return true
	end

	return false
end

-- Returns the upgrade cost to a specific tower ability
function GetTowerAbilityUpgradeCost(ability_name, level)

	if level == 1 then
		return TOWER_ABILITIES[ability_name].cost1
	elseif level == 2 then
		return TOWER_ABILITIES[ability_name].cost2
	end
end

-- Grants a given hero an appropriate amount of Random OMG abilities
function ApplyAllRandomOmgAbilities( hero )

	-- If there's no valid hero, do nothing
	if not hero then
		return nil
	end

	-- Check if the high level power-up ability is present
	local ability_powerup = hero:FindAbilityByName("imba_unlimited_level_powerup")
	local powerup_stacks
	if ability_powerup then
		powerup_stacks = hero:GetModifierStackCount("modifier_imba_unlimited_level_powerup", hero)
		hero:RemoveModifierByName("modifier_imba_unlimited_level_powerup")
		ability_powerup = true
	end

	-- Remove default abilities
	for i = 0, 15 do
		local old_ability = hero:GetAbilityByIndex(i)
		if old_ability then
			hero:RemoveAbility(old_ability:GetAbilityName())
		end
	end

	-- Creates the table to store ability information for that hero
	if not hero.random_omg_abilities then
		hero.random_omg_abilities = {}
	end

	-- Initialize the precache list if necessary
	if not PRECACHED_HERO_LIST then
		PRECACHED_HERO_LIST = {}
	end

	-- Add new regular abilities
	local i = 1
	while i <= IMBA_RANDOM_OMG_NORMAL_ABILITY_COUNT do

		-- Randoms an ability from the list of legal random omg abilities
		local randomed_ability
		local ability_owner
		randomed_ability, ability_owner = GetRandomNormalAbility()

		-- Checks for duplicate abilities
		if not hero:FindAbilityByName(randomed_ability) then

			-- Add the ability
			hero:AddAbility(randomed_ability)

			-- Check if this hero has been precached before
			local is_precached = false
			for j = 1, #PRECACHED_HERO_LIST do
				if PRECACHED_HERO_LIST[j] == ability_owner then
					is_precached = true
				end
			end

			-- If not, do so and add it to the precached heroes list
			if not is_precached then
				PrecacheUnitWithQueue(ability_owner)
				table.insert(PRECACHED_HERO_LIST, ability_owner)
			end

			-- Store it for later reference
			hero.random_omg_abilities[i] = randomed_ability
			i = i + 1
		end
	end

	-- Add new ultimate abilities
	while i <= ( IMBA_RANDOM_OMG_NORMAL_ABILITY_COUNT + IMBA_RANDOM_OMG_ULTIMATE_ABILITY_COUNT ) do

		-- Randoms an ability from the list of legal random omg ultimates
		local randomed_ultimate
		local ultimate_owner
		randomed_ultimate, ultimate_owner = GetRandomUltimateAbility()

		-- Checks for duplicate abilities
		if not hero:FindAbilityByName(randomed_ultimate) then

			-- Add the ultimate
			hero:AddAbility(randomed_ultimate)

			-- Check if this hero has been precached before
			local is_precached = false
			for j = 1, #PRECACHED_HERO_LIST do
				if PRECACHED_HERO_LIST[j] == ultimate_owner then
					is_precached = true
				end
			end

			-- If not, do so and add it to the precached heroes list
			if not is_precached then
				PrecacheUnitByNameAsync(ultimate_owner, function(...) end)
				table.insert(PRECACHED_HERO_LIST, ultimate_owner)
			end

			-- Store it for later reference
			hero.random_omg_abilities[i] = randomed_ultimate
			i = i + 1
		end
	end

	-- Apply high level powerup ability, if previously existing
	if ability_powerup then
		hero:AddAbility("imba_unlimited_level_powerup")
		ability_powerup = hero:FindAbilityByName("imba_unlimited_level_powerup")
		ability_powerup:SetLevel(1)
		AddStacks(ability_powerup, hero, hero, "modifier_imba_unlimited_level_powerup", powerup_stacks, true)
	end

end

-- Randoms a hero not in the forbidden Random OMG hero pool
function PickValidHeroRandomOMG()

	local valid_heroes = {
		"npc_dota_hero_abaddon",
		"npc_dota_hero_alchemist",
		"npc_dota_hero_ancient_apparition",
		"npc_dota_hero_antimage",
		"npc_dota_hero_axe",
		"npc_dota_hero_bane",
		"npc_dota_hero_bounty_hunter",
		"npc_dota_hero_centaur",
		"npc_dota_hero_chaos_knight",
		"npc_dota_hero_crystal_maiden",
		"npc_dota_hero_dazzle",
		"npc_dota_hero_dragon_knight",
		"npc_dota_hero_drow_ranger",
		"npc_dota_hero_earthshaker",
		"npc_dota_hero_jakiro",
		"npc_dota_hero_juggernaut",
		"npc_dota_hero_kunkka",
		"npc_dota_hero_lich",
		"npc_dota_hero_lina",
		"npc_dota_hero_lion",
		"npc_dota_hero_luna",
		"npc_dota_hero_medusa",
		"npc_dota_hero_mirana",
		"npc_dota_hero_naga_siren",
		"npc_dota_hero_furion",
		"npc_dota_hero_necrolyte",
		"npc_dota_hero_obsidian_destroyer",
		"npc_dota_hero_omniknight",
		"npc_dota_hero_phantom_assassin",
		"npc_dota_hero_phantom_lancer",
		"npc_dota_hero_phoenix",
		"npc_dota_hero_puck",
		"npc_dota_hero_queenofpain",
		"npc_dota_hero_sand_king",
		"npc_dota_hero_shadow_demon",
		"npc_dota_hero_nevermore",
		"npc_dota_hero_slark",
		"npc_dota_hero_sniper",
		"npc_dota_hero_storm_spirit",
		"npc_dota_hero_sven",
		"npc_dota_hero_templar_assassin",
		"npc_dota_hero_terrorblade",
		"npc_dota_hero_tinker",
		"npc_dota_hero_ursa",
		"npc_dota_hero_vengefulspirit",
		"npc_dota_hero_venomancer",
		"npc_dota_hero_wisp",
		"npc_dota_hero_witch_doctor",
		"npc_dota_hero_zuus"
	}

	return valid_heroes[RandomInt(1, #valid_heroes)]
end

-- Checks if a hero is a valid pick in Random OMG
function IsValidPickRandomOMG( hero )

	local hero_name = hero:GetName()

	local valid_heroes = {
		"npc_dota_hero_abaddon",
		"npc_dota_hero_alchemist",
		"npc_dota_hero_ancient_apparition",
		"npc_dota_hero_antimage",
		"npc_dota_hero_axe",
		"npc_dota_hero_bane",
		"npc_dota_hero_bounty_hunter",
		"npc_dota_hero_centaur",
		"npc_dota_hero_chaos_knight",
		"npc_dota_hero_crystal_maiden",
		"npc_dota_hero_dazzle",
		"npc_dota_hero_dragon_knight",
		"npc_dota_hero_drow_ranger",
		"npc_dota_hero_earthshaker",
		"npc_dota_hero_jakiro",
		"npc_dota_hero_juggernaut",
		"npc_dota_hero_kunkka",
		"npc_dota_hero_lich",
		"npc_dota_hero_lina",
		"npc_dota_hero_lion",
		"npc_dota_hero_luna",
		"npc_dota_hero_medusa",
		"npc_dota_hero_mirana",
		"npc_dota_hero_naga_siren",
		"npc_dota_hero_furion",
		"npc_dota_hero_necrolyte",
		"npc_dota_hero_obsidian_destroyer",
		"npc_dota_hero_omniknight",
		"npc_dota_hero_phantom_assassin",
		"npc_dota_hero_phantom_lancer",
		"npc_dota_hero_phoenix",
		"npc_dota_hero_puck",
		"npc_dota_hero_queenofpain",
		"npc_dota_hero_sand_king",
		"npc_dota_hero_shadow_demon",
		"npc_dota_hero_nevermore",
		"npc_dota_hero_slark",
		"npc_dota_hero_sniper",
		"npc_dota_hero_storm_spirit",
		"npc_dota_hero_sven",
		"npc_dota_hero_templar_assassin",
		"npc_dota_hero_terrorblade",
		"npc_dota_hero_tinker",
		"npc_dota_hero_ursa",
		"npc_dota_hero_vengefulspirit",
		"npc_dota_hero_venomancer",
		"npc_dota_hero_wisp",
		"npc_dota_hero_witch_doctor",
		"npc_dota_hero_zuus"
	}

	for i = 1, #valid_heroes do
		if valid_heroes[i] == hero_name then
			return true
		end
	end

	return false
end

-- Removes undesired permanent modifiers in Random OMG mode
function RemovePermanentModifiersRandomOMG( hero )
	hero:RemoveModifierByName("modifier_imba_tidebringer_cooldown")
	hero:RemoveModifierByName("modifier_imba_hunter_in_the_night")
	hero:RemoveModifierByName("modifier_imba_shallow_grave")
	hero:RemoveModifierByName("modifier_imba_shallow_grave_passive")
	hero:RemoveModifierByName("modifier_imba_shallow_grave_passive_cooldown")
	hero:RemoveModifierByName("modifier_imba_shallow_grave_passive_check")
	hero:RemoveModifierByName("modifier_imba_vendetta_damage_stacks")
	hero:RemoveModifierByName("modifier_imba_heartstopper_aura")
	hero:RemoveModifierByName("modifier_imba_antimage_spell_shield_passive")
	hero:RemoveModifierByName("modifier_imba_brilliance_aura")
	hero:RemoveModifierByName("modifier_imba_trueshot_aura_owner_hero")
	hero:RemoveModifierByName("modifier_imba_trueshot_aura_owner_creep")
	hero:RemoveModifierByName("modifier_imba_frost_nova_aura")
	hero:RemoveModifierByName("modifier_imba_moonlight_scepter_aura")
	hero:RemoveModifierByName("modifier_imba_sadist_aura")
	hero:RemoveModifierByName("modifier_imba_impale_aura")
	hero:RemoveModifierByName("modifier_imba_essence_aura")
	hero:RemoveModifierByName("modifier_imba_degen_aura")
	hero:RemoveModifierByName("modifier_imba_flesh_heap_aura")
	hero:RemoveModifierByName("modifier_borrowed_time")
	hero:RemoveModifierByName("attribute_bonus_str")
	hero:RemoveModifierByName("attribute_bonus_agi")
	hero:RemoveModifierByName("attribute_bonus_int")
	hero:RemoveModifierByName("modifier_imba_hook_sharp_stack")
	hero:RemoveModifierByName("modifier_imba_hook_light_stack")
	hero:RemoveModifierByName("modifier_imba_hook_caster")
	hero:RemoveModifierByName("modifier_imba_god_strength")
	hero:RemoveModifierByName("modifier_imba_god_strength_aura")
	hero:RemoveModifierByName("modifier_imba_god_strength_aura_scepter")
	hero:RemoveModifierByName("modifier_imba_warcry_passive_aura")
	hero:RemoveModifierByName("modifier_imba_great_cleave")
	hero:RemoveModifierByName("modifier_imba_blur")
	hero:RemoveModifierByName("modifier_imba_flesh_heap_aura")
	hero:RemoveModifierByName("modifier_imba_flesh_heap_stacks")
	hero:RemoveModifierByName("modifier_medusa_split_shot")
	hero:RemoveModifierByName("modifier_luna_lunar_blessing")
	hero:RemoveModifierByName("modifier_luna_lunar_blessing_aura")
	hero:RemoveModifierByName("modifier_luna_moon_glaive")
	hero:RemoveModifierByName("modifier_dragon_knight_dragon")
	hero:RemoveModifierByName("modifier_dragon_knight_dragon_blood")
	hero:RemoveModifierByName("modifier_zuus_static_field")
	hero:RemoveModifierByName("modifier_witchdoctor_voodoorestoration")
	hero:RemoveModifierByName("modifier_imba_land_mines_caster")
	hero:RemoveModifierByName("modifier_imba_purification_passive")
	hero:RemoveModifierByName("modifier_imba_purification_passive_cooldown")
	hero:RemoveModifierByName("modifier_imba_double_edge_prevent_deny")
	hero:RemoveModifierByName("modifier_imba_vampiric_aura")
	hero:RemoveModifierByName("modifier_imba_reincarnation_detector")
	hero:RemoveModifierByName("modifier_imba_time_walk_damage_counter")
	hero:RemoveModifierByName("modifier_charges")
	hero:RemoveModifierByName("modifier_imba_reincarnation")

	while hero:HasModifier("modifier_imba_flesh_heap_bonus") do
		hero:RemoveModifierByName("modifier_imba_flesh_heap_bonus")
	end
end

-- Simulates attack speed cap removal to a single unit through BAT manipulation
function IncreaseAttackSpeedCap(unit, new_cap)

	-- Fetch original BAT if necessary
	if not unit.current_modified_bat then
		unit.current_modified_bat = unit:GetBaseAttackTime()
	end

	-- Get current attack speed, limited to new_cap
	local current_as = math.min(unit:GetAttackSpeed() * 100, new_cap)

	-- Should we reduce BAT?
	if current_as > MAXIMUM_ATTACK_SPEED then
		local new_bat = MAXIMUM_ATTACK_SPEED / current_as * unit.current_modified_bat
		unit:SetBaseAttackTime(new_bat)
	end
end

-- Returns a unit's attack speed cap
function RevertAttackSpeedCap( unit )

	-- Return to original BAT
	unit:SetBaseAttackTime(unit.current_modified_bat)

end
			
-- Break (remove passive skills from) a target
function PassiveBreak( unit, duration )

	-- Check if the target already has break status
	if unit.break_duration_left then
		
		-- Increase remaining break duration if appropriate
		if duration > unit.break_duration_left then
			unit.break_duration_left = duration
		end

		-- Break and do nothing more
		return nil
	end

	-- Initialize break globals
	unit.break_duration_left = duration
	unit.break_learn_levels = {}

	local passive_detected = false

	-- Exceptions
	unit:RemoveModifierByName("modifier_imba_antimage_spell_shield_passive")
	unit:RemoveModifierByName("modifier_imba_antimage_spell_shield_active")
	while unit:HasModifier("modifier_imba_fervor_stacks") do
		unit:RemoveModifierByName("modifier_imba_fervor_stacks")
	end

	-- Non-passive abilities disabled by break
	local break_exceptions = {
		"imba_antimage_spell_shield"
	}

	-- Passive abilities not disabled by break
	local break_immunities = {
		"imba_wraith_king_reincarnation",
		"imba_drow_ranger_marksmanship"
	}

	-- Set all passive abilities' levels to zero
	for i = 0, 15 do
		local ability = unit:GetAbilityByIndex(i)
		if ability and ability:GetLevel() > 0 then
			
			-- Check for regular passives
			if ability:IsPassive() then
				passive_detected = true
				unit.break_learn_levels[i] = ability:GetLevel()
				ability:SetLevel(0)
			end

			-- Check for exceptions (togglable/activable "passives")
			for _,ability_exception in pairs(break_exceptions) do
				if ability_exception == ability:GetName() then
					passive_detected = true
					unit.break_learn_levels[i] = ability:GetLevel()
					ability:SetLevel(0)
				end
			end

			-- Check for immunities (passives which are not disabled by Break)
			for _,ability_immunity in pairs(break_immunities) do
				if ability_immunity == ability:GetName() then
					ability:SetLevel(unit.break_learn_levels[i])
					unit.break_learn_levels[i] = 0
				end
			end

		end
	end

	-- If at least one passive was broken, count down the duration
	if passive_detected then
		Timers:CreateTimer(0.1, function()

			-- Update duration left
			unit.break_duration_left = unit.break_duration_left - 0.1

			-- Restore ability levels if duration has elapsed
			if unit.break_duration_left <= 0 then
				if not ( not unit:IsAlive() and IMBA_ABILITY_MODE_RANDOM_OMG ) then
					for i = 0, 15 do
						if unit.break_learn_levels[i] and unit.break_learn_levels[i] > 0 then
							local ability = unit:GetAbilityByIndex(i)
							local excess_levels = ability:GetLevel()
							unit:SetAbilityPoints( unit:GetAbilityPoints() + excess_levels )
							ability:SetLevel(unit.break_learn_levels[i])
						end
					end
				end
				unit.break_duration_left = nil
				unit.break_learn_levels = nil
			else
				return 0.1
			end
		end)
	end
end

-- End an ongoing Break condition
function PassiveBreakEnd( unit )
	unit.break_duration_left = 0
end

-- Check if an ability should proc magic stick/wand
function StickProcCheck( ability )

	local ability_name = ability:GetName()

	local forbidden_skills = {
		"storm_spirit_ball_lightning",
		"witch_doctor_voodoo_restoration",
		"imba_necrolyte_death_pulse",
		"shredder_chakram",
		"shredder_chakram_2"
	}

	for i = 1, #forbidden_skills do
		if ability_name == forbidden_skills[i] then
			return false
		end
	end

	return true
end

function IsUniqueAbility( table, element )
	for _, ability in ipairs(table) do
        if ability:GetName() == element then
            return false
        end
    end

    return true
end

-- Upgrades a tower's abilities
function UpgradeTower( tower )

    local abilities = {}

    -- Fetch tower abilities
    for i = 0, 15 do
        local current_ability = tower:GetAbilityByIndex(i)
        if current_ability and current_ability:GetName() ~= "backdoor_protection" and current_ability:GetName() ~= "imba_tower_ai_controller"and current_ability:GetName() ~= "lone_druid_savage_roar_tower" and current_ability:GetName() ~= "backdoor_protection_in_base" and current_ability:GetName() ~= "imba_tower_buffs" then
            abilities[#abilities+1] = current_ability 
        end
    end

    -- Iterate through abilities to identify the upgradable one
    for i = 1,4 do

        -- If this ability is not maxed, try to upgrade it
        if abilities[i] and abilities[i]:GetLevel() < 3 then
            -- Upgrade ability
            abilities[i]:SetLevel( abilities[i]:GetLevel() + 1 )

            return nil

        -- If this ability is maxed and the last one, then add a new one
        elseif abilities[i] and abilities[i]:GetLevel() == 3 and #abilities == i then

            -- Else, add a new ability from this game's ability tree
            local oldAbList = LoadKeyValues('scripts/kv/abilities.kv').skills.custom.imba_towers_weak
            local oldAbList2 = LoadKeyValues('scripts/kv/abilities.kv').skills.custom.imba_towers_medium
            local oldAbList3 = LoadKeyValues('scripts/kv/abilities.kv').skills.custom.imba_towers_strong

			util:MergeTables(oldAbList, oldAbList2)
			util:MergeTables(oldAbList, oldAbList3)

            local towerSkills = {}
            for skill_name in pairs(oldAbList) do
                table.insert(towerSkills, skill_name)
            end
            local new_ability = RandomFromTable(towerSkills)
            while not IsUniqueAbility(abilities, new_ability) do
            	new_ability = RandomFromTable(towerSkills)
            end

            -- Add the new ability
            if not tower:HasAbility(new_ability) then
	            tower:AddAbility(new_ability)
	            new_ability = tower:FindAbilityByName(new_ability)
	            new_ability:SetLevel(1)
            end

            return nil
        end
    end
end

-- Sets a creature's max health to [health]
function SetCreatureHealth(unit, health, update_current_health)

	unit:SetBaseMaxHealth(health)
	unit:SetMaxHealth(health)

	if update_current_health then
		unit:SetHealth(health)
	end
end

function RemoveWearables( hero )

	-- Setup variables
	Timers:CreateTimer(0.1, function()
		hero.hiddenWearables = {} -- Keep every wearable handle in a table to show them later
		local model = hero:FirstMoveChild()
		while model ~= nil do
			if model:GetClassname() == "dota_item_wearable" then
				model:AddEffects(EF_NODRAW) -- Set model hidden
				table.insert(hero.hiddenWearables, model)
			end
			model = model:NextMovePeer()
		end
	end)
end

function ShowWearables( event )
  local hero = event.caster

  for i,v in pairs(hero.hiddenWearables) do
    v:RemoveEffects(EF_NODRAW)
  end
end

-- Skeleton king cosmetics
function SkeletonKingWearables( hero )

	-- Cape
	Attachments:AttachProp(hero, "attach_head", "models/heroes/skeleton_king/wraith_king_cape.vmdl", 1.0)

	-- Shoulderpiece
	Attachments:AttachProp(hero, "attach_head", "models/heroes/skeleton_king/wraith_king_shoulder.vmdl", 1.0)

	-- Crown
	Attachments:AttachProp(hero, "attach_head", "models/heroes/skeleton_king/wraith_king_head.vmdl", 1.0)

	-- Gauntlet
	Attachments:AttachProp(hero, "attach_attack1", "models/heroes/skeleton_king/wraith_king_gauntlet.vmdl", 1.0)

	-- Weapon (randomly chosen)
	local random_weapon = {
		"models/items/skeleton_king/spine_splitter/spine_splitter.vmdl",
		"models/items/skeleton_king/regalia_of_the_bonelord_sword/regalia_of_the_bonelord_sword.vmdl",
		"models/items/skeleton_king/weapon_backbone.vmdl",
		"models/items/skeleton_king/the_blood_shard/the_blood_shard.vmdl",
		"models/items/skeleton_king/sk_dragon_jaw/sk_dragon_jaw.vmdl",
		"models/items/skeleton_king/weapon_spine_sword.vmdl",
		"models/items/skeleton_king/shattered_destroyer/shattered_destroyer.vmdl"
	}
	Attachments:AttachProp(hero, "attach_attack1", random_weapon[RandomInt(1, #random_weapon)], 1.0)

	-- Eye particles
	local eye_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/skeletonking_eyes.vpcf", PATTACH_ABSORIGIN, hero)
	ParticleManager:SetParticleControlEnt(eye_pfx, 0, hero, PATTACH_POINT_FOLLOW, "attach_eyeL", hero:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(eye_pfx, 1, hero, PATTACH_POINT_FOLLOW, "attach_eyeR", hero:GetAbsOrigin(), true)
end

-- Returns the total cooldown reduction on a given unit
function GetCooldownReduction( unit )

	local reduction = 1.0

	-- Octarine Core
	if unit:HasModifier("modifier_item_imba_octarine_core_unique") then
		reduction = reduction * 0.75
	end

	return reduction
end

-- Returns true if this is a ward-type unit (nether ward, scourge ward, etc.)
function IsWardTypeUnit( unit )

	local ward_type_units = {
		"npc_imba_pugna_nether_ward_1",
		"npc_imba_pugna_nether_ward_2",
		"npc_imba_pugna_nether_ward_3",
		"npc_imba_pugna_nether_ward_4"
	}

	for _, ward_unit in pairs(ward_type_units) do
		if unit:GetUnitName() == ward_unit then
			return true
		end
	end

	return false
end

function GetBaseRangedProjectileName( unit )
	local unit_name = unit:GetUnitName()
	unit_name = string.gsub(unit_name, "dota", "imba")
	local unit_table = unit:IsHero() and GameRules.HeroKV[unit_name] or GameRules.UnitKV[unit_name]
	return unit_table and unit_table["ProjectileModel"] or ""
end

function ChangeAttackProjectileImba( unit )

	local particle_deso = "particles/items_fx/desolator_projectile.vpcf"
	local particle_skadi = "particles/items2_fx/skadi_projectile.vpcf"
	local particle_deso_skadi = "particles/item/desolator/desolator_skadi_projectile_2.vpcf"
	local particle_clinkz_arrows = "particles/units/heroes/hero_clinkz/clinkz_searing_arrow.vpcf"
	local particle_dragon_form_green = "particles/units/heroes/hero_dragon_knight/dragon_knight_elder_dragon_corrosive.vpcf"
	local particle_dragon_form_red = "particles/units/heroes/hero_dragon_knight/dragon_knight_elder_dragon_fire.vpcf"
	local particle_dragon_form_blue = "particles/units/heroes/hero_dragon_knight/dragon_knight_elder_dragon_frost.vpcf"
	local particle_terrorblade_transform = "particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis_base_attack.vpcf"

	-- If the unit has a Desolator and a Skadi, use the special projectile
	if unit:HasModifier("modifier_item_imba_desolator_unique") or unit:HasModifier("modifier_item_imba_desolator_2_unique") then
		if unit:HasModifier("modifier_item_imba_skadi_unique") then
			unit:SetRangedProjectileName(particle_deso_skadi)

		-- If only a Desolator, use its attack projectile instead
		else
			unit:SetRangedProjectileName(particle_deso)
		end

	-- If only a Skadi, use its attack projectile instead
	elseif unit:HasModifier("modifier_item_imba_skadi_unique") then
		unit:SetRangedProjectileName(particle_skadi)

	-- If it's a Clinkz with Searing Arrows, use its attack projectile instead
	elseif unit:HasModifier("modifier_imba_searing_arrows_caster") then
		unit:SetRangedProjectileName(particle_clinkz_arrows)

	-- If it's one of Dragon Knight's forms, use its attack projectile instead
	elseif unit:HasModifier("modifier_dragon_knight_corrosive_breath") then
		unit:SetRangedProjectileName(particle_dragon_form_green)
	elseif unit:HasModifier("modifier_dragon_knight_splash_attack") then
		unit:SetRangedProjectileName(particle_dragon_form_red)
	elseif unit:HasModifier("modifier_dragon_knight_frost_breath") then
		unit:SetRangedProjectileName(particle_dragon_form_blue)

	-- If it's a metamorphosed Terrorblade, use its attack projectile instead
	elseif unit:HasModifier("modifier_terrorblade_metamorphosis") then
		unit:SetRangedProjectileName(particle_terrorblade_transform)

	-- Else, default to the base ranged projectile
	else
		unit:SetRangedProjectileName(GetBaseRangedProjectileName(unit))
	end
end

function IsUninterruptableForcedMovement( unit )
	
	-- List of uninterruptable movement modifiers
	local modifier_list = {
		"modifier_spirit_breaker_charge_of_darkness",
		"modifier_magnataur_skewer_movement",
		"modifier_invoker_deafening_blast_knockback",
		"modifier_knockback",
		"modifier_item_forcestaff_active",
		"modifier_shredder_timber_chain",
		"modifier_batrider_flaming_lasso",
		"modifier_imba_leap_self_root",
		"modifier_faceless_void_chronosphere_freeze",
		"modifier_storm_spirit_ball_lightning",
		"modifier_morphling_waveform"
	}

	-- Iterate through the list
	for _,modifier_name in pairs(modifier_list) do
		if unit:HasModifier(modifier_name) then
			return true
		end
	end

	return false
end

-- Returns an unit's existing increased cast range modifiers
function GetCastRangeIncrease( unit )
	local cast_range_increase = 0
	
	-- From items
	if unit:HasModifier("modifier_item_imba_elder_staff_range") then
		cast_range_increase = cast_range_increase + 300
	elseif unit:HasModifier("modifier_item_imba_aether_lens_range") then
		cast_range_increase = cast_range_increase + 225
	end

	-- From talents
	for talent_name,cast_range_bonus in pairs(CAST_RANGE_TALENTS) do
		if unit:FindAbilityByName(talent_name) and unit:FindAbilityByName(talent_name):GetLevel() > 0 then
			cast_range_increase = cast_range_increase + cast_range_bonus
		end
	end

	return cast_range_increase
end

-- Safely modify BAT while storing the unit's original value
function ModifyBAT(unit, modify_percent, modify_flat)

	-- Fetch base BAT if necessary
	if not unit.unmodified_bat then
		unit.unmodified_bat = unit:GetBaseAttackTime()
	end

	-- Create the current BAT variable if necessary
	if not unit.current_modified_bat then
		unit.current_modified_bat = unit.unmodified_bat
	end

	-- Create the percent modifier variable if necessary
	if not unit.percent_bat_modifier then
		unit.percent_bat_modifier = 1
	end

	-- Create the flat modifier variable if necessary
	if not unit.flat_bat_modifier then
		unit.flat_bat_modifier = 0
	end

	-- Update BAT percent modifiers
	unit.percent_bat_modifier = unit.percent_bat_modifier * (100 + modify_percent) / 100

	-- Update BAT flat modifiers
	unit.flat_bat_modifier = unit.flat_bat_modifier + modify_flat

	-- Unmodified BAT special exceptions
	if unit:GetUnitName() == "npc_dota_hero_alchemist" then
		return nil
	end
	
	-- Update modifier BAT
	unit.current_modified_bat = (unit.unmodified_bat + unit.flat_bat_modifier) * unit.percent_bat_modifier

	-- Update unit's BAT
	unit:SetBaseAttackTime(unit.current_modified_bat)

end

-- Override all BAT modifiers and return the unit to its base value
function RevertBAT( unit )

	-- Fetch base BAT if necessary
	if not unit.unmodified_bat then
		unit.unmodified_bat = unit:GetBaseAttackTime()
	end

	-- Create the current BAT variable if necessary
	if not unit.current_modified_bat then
		unit.current_modified_bat = unit.unmodified_bat
	end

	-- Create the percent modifier variable if necessary
	if not unit.percent_bat_modifier then
		unit.percent_bat_modifier = 1
	end

	-- Create the flat modifier variable if necessary
	if not unit.flat_bat_modifier then
		unit.flat_bat_modifier = 0
	end

	-- Reset variables
	unit.percent_bat_modifier = 1
	unit.flat_bat_modifier = 0

	-- Reset BAT
	unit:SetBaseAttackTime(unit.unmodified_bat)

end

-- Detect hero-creeps with an inventory, like warlock golems or lone druid's bear
function IsHeroCreep( unit )

	if unit:GetName() == "npc_dota_lone_druid_bear" then
		return true
	end

	return false
end

-- Changes the time of the day temporarily, memorizing the original time of the day to return to
function SetTimeOfDayTemp(time, duration)

	-- Store the original time of the day, if necessary
	local game_entity = GameRules:GetGameModeEntity()
	if not game_entity.tod_original_time then
		game_entity.tod_original_time = GameRules:GetTimeOfDay()
	end

	-- Initialize the time modification states, if necessary
	if not game_entity.tod_future_seconds then
		game_entity.tod_future_seconds = {}

		-- Start loop function
		Timers:CreateTimer(1, function()
			SetTimeOfDayTempLoop()
		end)
	end

	-- Store future time modification states
	for i = 1, duration do
		game_entity.tod_future_seconds[i] = time
	end

	-- Set the time of the day
	GameRules:SetTimeOfDay(time)
end

-- Auxiliary function to the one above
function SetTimeOfDayTempLoop()

	-- If there are no future time modification states, stop looping
	local game_entity = GameRules:GetGameModeEntity()
	if not game_entity.tod_future_seconds then
		return nil

	-- Else, move states one second forward
	elseif #game_entity.tod_future_seconds > 1 then
		for i = 1, (#game_entity.tod_future_seconds - 1) do
			game_entity.tod_future_seconds[i] = game_entity.tod_future_seconds[i + 1]
		end
		game_entity.tod_future_seconds[#game_entity.tod_future_seconds] = nil

		-- Keep the loop going
		GameRules:SetTimeOfDay(game_entity.tod_future_seconds[1])
		Timers:CreateTimer(1, function()
			SetTimeOfDayTempLoop()
		end)

	-- Else, the duration is over; restore the original time of the day, and exit the loop
	else
		game_entity.tod_future_seconds = nil
		Timers:CreateTimer(1, function()
			GameRules:SetTimeOfDay(game_entity.tod_original_time)
			game_entity.tod_original_time = nil
		end)
	end
end

-- Initializes a charge-based system for an ability
function InitializeAbilityCharges(unit, ability_name, max_charges, initial_charges, cooldown, modifier_name)

	-- Find the passed ability
	local ability = unit:FindAbilityByName(ability_name)

	-- Procees only if the relevant ability was found
	if ability then

		local extra_parameters = {
			max_count = max_charges,
			start_count = initial_charges,
			replenish_time = cooldown
		}

		unit:AddNewModifier(unit, ability, "modifier_charges_"..modifier_name, extra_parameters)
	end
end

-- Check if an unit is near the enemy fountain
function IsNearEnemyFountain(location, team, distance)

	local fountain_loc
	if team == DOTA_TEAM_GOODGUYS then
		fountain_loc = Vector(7472, 6912, 512)
	else
		fountain_loc = Vector(-7456, -6938, 528)
	end

	if (fountain_loc - location):Length2D() <= distance then
		return true
	end

	return false
end

-- Reaper's Scythe kill credit redirection
function TriggerNecrolyteReaperScytheDeath(target, caster)

	-- Find the Reaper's Scythe ability
	local ability = caster:FindAbilityByName("imba_necrolyte_reapers_scythe")
	if not ability then return nil end

	-- Attempt to kill the target
	ApplyDamage({attacker = caster, victim = target, ability = ability, damage = target:GetHealth(), damage_type = DAMAGE_TYPE_PURE})
end

-- Reincarnation death trigger
function TriggerWraithKingReincarnation(caster, ability)

	-- Keyvalues
	local ability_level = ability:GetLevel() - 1
	local modifier_death = "modifier_imba_reincarnation_death"
	local modifier_slow = "modifier_imba_reincarnation_slow"
	local modifier_kingdom_ms = "modifier_imba_reincarnation_kingdom_ms"
	local particle_wait = "particles/units/heroes/hero_skeletonking/wraith_king_reincarnate.vpcf"
	local particle_kingdom = "particles/hero/skeleton_king/wraith_king_hellfire_eruption_tell.vpcf"
	local sound_death = "Hero_SkeletonKing.Reincarnate"
	local sound_reincarnation = "Hero_SkeletonKing.Reincarnate.Stinger"
	local sound_kingdom_start = "Hero_WraithKing.EruptionCast"

	-- Parameters
	local slow_radius = ability:GetLevelSpecialValueFor("slow_radius", ability_level)
	local reincarnate_delay = ability:GetLevelSpecialValueFor("reincarnate_delay", ability_level)
	local vision_radius = ability:GetLevelSpecialValueFor("vision_radius", ability_level)
	local damage = ability:GetLevelSpecialValueFor("kingdom_damage", ability_level)
	local stun_duration = ability:GetLevelSpecialValueFor("kingdom_stun", ability_level)
	local caster_loc = caster:GetAbsOrigin()

	-- Put the ability on cooldown and play out the reincarnation
	local cooldown_reduction = GetCooldownReduction(caster)
	ability:StartCooldown(ability:GetCooldown(ability_level) * cooldown_reduction)

	-- Play initial sound
	local heroes = FindUnitsInRadius(caster:GetTeamNumber(), caster_loc, nil, slow_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_ANY_ORDER, false)
	if USE_MEME_SOUNDS and #heroes >= IMBA_PLAYERS_ON_GAME * 0.35 then
		caster:EmitSound("Hero_WraithKing.IllBeBack")
	else
		caster:EmitSound(sound_death)
	end

	-- Create visibility node
	ability:CreateVisibilityNode(caster_loc, vision_radius, reincarnate_delay)

	-- Apply simulated death modifier
	ability:ApplyDataDrivenModifier(caster, caster, modifier_death, {})

	-- Remove caster's model from the game
	caster:AddNoDraw()

	-- Play initial particle
	local wait_pfx = ParticleManager:CreateParticle(particle_wait, PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleAlwaysSimulate(wait_pfx)
	ParticleManager:SetParticleControl(wait_pfx, 0, caster_loc)
	ParticleManager:SetParticleControl(wait_pfx, 1, Vector(reincarnate_delay, 0, 0))
	ParticleManager:SetParticleControl(wait_pfx, 11, Vector(200, 0, 0))
	ParticleManager:ReleaseParticleIndex(wait_pfx)

	-- Slow all nearby enemies
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster_loc, nil, slow_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false)
	for _,enemy in pairs(enemies) do
		ability:ApplyDataDrivenModifier(caster, enemy, modifier_slow, {})
	end

	-- Heal, even through healing prevention debuffs
	caster:SetHealth(caster:GetMaxHealth())
	caster:SetMana(caster:GetMaxMana())

	-- Play Kingdom Come particle
	local kingdom_pfx = ParticleManager:CreateParticle(particle_kingdom, PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleAlwaysSimulate(kingdom_pfx)
	ParticleManager:SetParticleControl(kingdom_pfx, 0, caster_loc)

	-- Play Kingdom Come sound
	Timers:CreateTimer(0.9, function()
		caster:EmitSound(sound_kingdom_start)
	end)

	-- After the respawn delay
	Timers:CreateTimer(reincarnate_delay, function()

		-- Purge most debuffs
		caster:Purge(false, true, false, true, true)

		-- Heal, even through healing prevention debuffs
		caster:SetHealth(caster:GetMaxHealth())
		caster:SetMana(caster:GetMaxMana())

		-- Redraw caster's model
		caster:RemoveNoDraw()

		-- Play reincarnation stinger
		caster:EmitSound(sound_reincarnation)

		-- Stop Kingdom Come particles
		ParticleManager:DestroyParticle(kingdom_pfx, false)
		ParticleManager:ReleaseParticleIndex(kingdom_pfx)

		-- Iterate through nearby enemies
		enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster_loc, nil, slow_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
		for _,enemy in pairs(enemies) do
			
			-- If this is a real hero, damage and stun it
			if enemy:IsRealHero() or IsRoshan(enemy) then
				ApplyDamage({attacker = caster, victim = enemy, ability = ability, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
				enemy:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun_duration})

				-- Increase caster's movement speed temporarily
				AddStacks(ability, caster, caster, modifier_kingdom_ms, 1, true)
			
			-- Else, kill it
			else
				ApplyDamage({attacker = caster, victim = enemy, ability = ability, damage = enemy:GetMaxHealth(), damage_type = DAMAGE_TYPE_PURE})
			end
		end
	end)
end

-- Reincarnation Wraith Form trigger
function TriggerWraithKingWraithForm(target, attacker)

	-- Keyvalues
	local reincarnation_modifier = target:FindModifierByName("modifier_imba_reincarnation_scepter")
	local caster = reincarnation_modifier:GetCaster()
	local ability = reincarnation_modifier:GetAbility()
	local modifier_scepter = "modifier_imba_reincarnation_scepter"
	local modifier_wraith = "modifier_imba_reincarnation_scepter_wraith"
	local sound_wraith = "Hero_SkeletonKing.Reincarnate.Ghost"

	-- Store the attacker which killed this unit's ID
	local killer_id
	local killer_type = "hero"
	if attacker:GetOwnerEntity() then
		killer_id = attacker:GetOwnerEntity():GetPlayerID()
	elseif attacker:IsHero() then
		killer_id = attacker:GetPlayerID()
	else
		killer_id = attacker
		killer_type = "creature"
	end

	-- If there is a player-owned killer, store it
	if killer_type == "hero" then
		target.reincarnation_scepter_killer = PlayerResource:GetPlayer(killer_id):GetAssignedHero()

	-- Else, assign the kill to the unit which dealt the finishing blow
	else
		target.reincarnation_scepter_killer = attacker
	end

	-- Play transformation sound
	target:EmitSound(sound_wraith)

	-- Apply wraith form modifier
	ability:ApplyDataDrivenModifier(caster, target, modifier_wraith, {})

	-- Remove the scepter aura modifier
	target:RemoveModifierByName(modifier_scepter)

	-- Purge all debuffs
	target:Purge(false, true, false, true, false)
end

-- Aegis Reincarnation trigger
function TriggerAegisReincarnation(caster)

	-- Keyvalues
	local aegis_modifier = caster:FindModifierByName("modifier_item_imba_aegis")
	local ability = aegis_modifier:GetAbility()
	local modifier_aegis = "modifier_item_imba_aegis"
	local modifier_death = "modifier_item_imba_aegis_death"
	local particle_wait = "particles/items_fx/aegis_timer.vpcf"
	local particle_respawn = "particles/items_fx/aegis_respawn_timer.vpcf"
	local sound_aegis = "Imba.AegisStinger"
	local caster_loc = caster:GetAbsOrigin()

	-- Parameters
	local respawn_delay = ability:GetSpecialValueFor("reincarnate_time")
	local vision_radius = ability:GetSpecialValueFor("vision_radius")

	-- Play sound
	caster:EmitSound(sound_aegis)

	-- Create visibility node
	ability:CreateVisibilityNode(caster_loc, vision_radius, respawn_delay)

	-- Apply simulated death modifier
	ability:ApplyDataDrivenModifier(caster, caster, modifier_death, {})

	-- Remove caster's model from the game
	caster:AddNoDraw()

	-- Play initial particle
	local wait_pfx = ParticleManager:CreateParticle(particle_wait, PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleAlwaysSimulate(wait_pfx)
	ParticleManager:SetParticleControl(wait_pfx, 0, caster_loc)
	ParticleManager:SetParticleControl(wait_pfx, 1, Vector(respawn_delay, 0, 0))
	ParticleManager:ReleaseParticleIndex(wait_pfx)

	-- After the respawn delay, play reincarnation particle
	local respawn_pfx = ParticleManager:CreateParticle(particle_respawn, PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(respawn_pfx, 0, caster_loc)
	ParticleManager:SetParticleControl(respawn_pfx, 1, Vector(respawn_delay, 0, 0))
	ParticleManager:ReleaseParticleIndex(respawn_pfx)

	-- After the respawn delay
	Timers:CreateTimer(respawn_delay, function()

		-- Heal, even through healing prevention debuffs
		caster:SetHealth(caster:GetMaxHealth())
		caster:SetMana(caster:GetMaxMana())

		-- Purge all debuffs
		caster:Purge(false, true, false, true, true)

		-- Remove Aegis modifier
		caster:RemoveModifierByName(modifier_aegis)

		-- Destroy the Aegis
		caster:RemoveItem(ability)

		-- Flag caster as no longer having aegis
		caster.has_aegis = false

		-- Redraw caster's model
		caster:RemoveNoDraw()
	end)
end

-- Sets level of the ability with [ability_name] to [level] for [caster] if the caster has this ability
function SetAbilityLevelIfPresent(caster, ability_name, level)
	local ability = caster:FindAbilityByName(ability_name)
	if ability then
		ability:SetLevel(level)
	end
end

-- Refreshes ability with [ability_name] for [caster] if the caster has this ability
function RefreshAbilityIfPresent(caster, ability_name)
	local ability = caster:FindAbilityByName(ability_name)
	if ability then
		ability:EndCooldown()
	end
end