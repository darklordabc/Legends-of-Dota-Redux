local Timers = require('easytimers')

LinkLuaModifier("modifier_duel_out_of_game", "lib/util_aar.lua",LUA_MODIFIER_MOTION_NONE)

modifier_duel_out_of_game = class({})

function modifier_duel_out_of_game:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DISABLE_HEALING
	}
 
	return funcs
end

function modifier_duel_out_of_game:GetDisableHealing()
	return true
end

function modifier_duel_out_of_game:CheckState()
	local state = {
		-- [MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_INVISIBLE] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_TRUESIGHT_IMMUNE] = true
	}
	return state
end

AAR_SMALL_ARENA = {[1] = Vector(1561.12, -5262.92, 295.968), [2] = Vector(1555.84, -4122.01, 257), [3] = Vector(4348.23, -4122.07, 257), [4] = Vector(4358.79, -5207.59, 282.345)}
AAR_BIG_ARENA = {[1] = Vector(-235.689, -6139.83, 262.252), [2] = Vector(-226.721, -3866.71, 291.518), [3] = Vector(5519, -3839.78, 257), [4] = Vector(5526.66, -6118.56, 271.501)}
AAR_GIANT_ARENA =	{[1] = Vector(-1256.13, -7178.7, 257), [2] = Vector(-1384.51, -5792.31, 301.099), 
					[3] = Vector(-1894.97, -4985.5, 283.667), [4] = Vector(-2651.49, -3477.07, 129),
					[5] = Vector(-1710.43, -2119.33, 129), [6] = Vector(-658.098, -1711.48, 129),
					[7] = Vector(211.006, -1998.87, 268.876), [8] = Vector(2105.04, -2220.36, 60.0008),
					[9] = Vector(2836.18, -2726.16, 255.578), [10] = Vector(3418.14, -3282.93, 288.287),
					[11] = Vector(3443, -3584.1, 284.458), [12] = Vector(4005.46, -3655.42, 282.417),
					[13] = Vector(4056.13, -3258.43, 264.392), [14] = Vector(7642.01, -3110.64, 257),
					[15] = Vector(7723.77, -4796.05, 282.028), [16] = Vector(7459.8, -5119.99, 288.688),
					[17] = Vector(7400.76, -6215.87, 281.567), [18] = Vector(6114.49, -7238.02, 298.057)}

DUEL_STATE = false

function initDuel(hero)
	if DUEL_STATE then return end
	DUEL_STATE = true

	for _,hero in pairs(HeroList:GetAllHeroes()) do
		if IsValidEntity(hero) == true then
			hero._duelPosition = hero:GetAbsOrigin()

			hero:SetAbsOrigin(getMidPoint( AAR_GIANT_ARENA ))

			PlayerResource:SetCameraTarget(hero:GetPlayerID(),hero)

			Timers:CreateTimer(function()
				PlayerResource:SetCameraTarget(hero:GetPlayerID(),nil)
    		end, DoUniqueString("camera"), 0.1)

			hero._savedCooldowns = saveAbilitiesCooldowns(hero)
			resetAllAbilitiesCooldown(hero, hero._savedCooldowns)

			hero:SetHealth(9999999)
			hero:SetMana(9999999)
			hero:Purge(true, true, false, true, false )

			while(hero:HasModifier("modifier_huskar_burning_spear_counter")) do
				hero:RemoveModifierByName("modifier_huskar_burning_spear_counter")
			end

			while(hero:HasModifier("modifier_razor_eye_of_the_storm")) do
				hero:RemoveModifierByName("modifier_razor_eye_of_the_storm")
			end

			hero:RemoveModifierByName("modifier_huskar_burning_spear_debuff")
			hero:RemoveModifierByName("modifier_kings_bar_magic_immune_active")
			hero:RemoveModifierByName("modifier_black_king_bar_immune")
			hero:RemoveModifierByName("modifier_venomancer_poison_nova")
			hero:RemoveModifierByName("modifier_dazzle_weave_armor")
			hero:RemoveModifierByName("modifier_dazzle_weave_armor_debuff")
			hero:RemoveModifierByName("modifier_life_stealer_infest")
			hero:RemoveModifierByName("modifier_maledict")

			Timers:CreateTimer(function()
				if not DUEL_STATE then return end
    			if not isPointInsidePolygon(hero:GetAbsOrigin(), AAR_GIANT_ARENA) then
    				FindClearSpaceForUnit(hero, GetGroundPosition(hero.oldArenaPos or getMidPoint( AAR_GIANT_ARENA ),hero),true)
    			else
    				hero.oldArenaPos = hero:GetAbsOrigin()
    			end
        		return 0.5
    		end, 'duel_timer', 0.5)
		end
	end

    spawnEntitiesAlongPath( "models/props_rock/badside_rocks002.vmdl", AAR_GIANT_ARENA )

    freezeGameplay()
end

function endDuel()
	if not DUEL_STATE then return end
	for _,hero in pairs(HeroList:GetAllHeroes()) do
		if IsValidEntity(hero) == true then
			hero:SetAbsOrigin(hero._duelPosition)

			setAbilitiesCooldowns(hero, hero._savedCooldowns)
		end
	end

	local ents = Entities:FindAllInSphere(Vector(0,0,0), 100000)

	for k,v in pairs(ents) do
		if IsValidEntity(v) and v.IsRealHero and v:IsRealHero() == false and v:IsAlive() and (v:IsCreep() or v:IsCreature() or v:IsBuilding()) then
			if v:IsBuilding() then

			else
				if v:IsNeutralUnitType() then

				else
					v:RemoveNoDraw()
				end
				v:RemoveModifierByName("modifier_duel_out_of_game")
			end
			v:SetDayTimeVisionRange(v._duelDayVisionRange)
			v:SetNightTimeVisionRange(v._duelNightVisionRange)
		end
	end

	Convars:SetBool("dota_creeps_no_spawning", false)
end

function freezeGameplay()
	Convars:SetBool("dota_creeps_no_spawning", true)

	local ents = Entities:FindAllInSphere(Vector(0,0,0), 100000)

	for k,v in pairs(ents) do
		if IsValidEntity(v) and v.IsRealHero and v:IsRealHero() == false and v:IsAlive() and (v:IsCreep() or v:IsCreature() or v:IsBuilding()) then
			if v:IsBuilding() then

			else
				if v:IsNeutralUnitType() then
				else
					v:AddNoDraw()
				end
				v:AddNewModifier(v,nil,"modifier_duel_out_of_game",{})
			end
			v._duelDayVisionRange = v:GetDayTimeVisionRange()
			v._duelNightVisionRange = v:GetNightTimeVisionRange()
			v:SetDayTimeVisionRange(1)
			v:SetNightTimeVisionRange(1)
		end
	end
end

function moveToDuel(duel_heroes, team_heroes, duel_points_table)
    local cur = 1
    local max = #duel_points_table
    local first_time = false
    for _, x in pairs(duel_heroes) do
        x:Stop()
        TeleportUnitToPointName(x, duel_points_table[cur], true, false)
        x:Stop()
        x:RemoveModifierByName('modifier_stun')
        x:AddNewModifier(x, nil, "modifier_godmode", { duration = 5 })
 
        local duel_gem = CreateItem("item_gem", x, x)
        x:AddNewModifier(x, duel_gem, "modifier_item_gem_of_true_sight", {})
        UTIL_Remove(duel_gem)
        x.duel_cooldowns = SaveAbilitiesCooldowns(x)
        ResetAllAbilitiesCooldown(x, x.duel_cooldowns)
        x:SetHealth(9999999)
        x:SetMana(9999999)
        x:Purge(true, true, false, true, false )
       
        while(x:HasModifier("modifier_huskar_burning_spear_counter")) do
            x:RemoveModifierByName("modifier_huskar_burning_spear_counter")
        end
 
        while(x:HasModifier("modifier_razor_eye_of_the_storm")) do
            x:RemoveModifierByName("modifier_razor_eye_of_the_storm")
        end
       
        x:RemoveModifierByName("modifier_huskar_burning_spear_debuff")
        x:RemoveModifierByName("modifier_kings_bar_magic_immune_active")
        x:RemoveModifierByName("modifier_black_king_bar_immune")
        x:RemoveModifierByName("modifier_venomancer_poison_nova")
        x:RemoveModifierByName("modifier_dazzle_weave_armor")
        x:RemoveModifierByName("modifier_dazzle_weave_armor_debuff")
        x:RemoveModifierByName("modifier_life_stealer_infest")
        x:RemoveModifierByName("modifier_maledict")
 
        local timer_info = {
            endTime = 1,
            callback = function()
                IsHeroOnDuel(x)
            return 1
        end
        }
        Timers:CreateTimer("duel_check_id" .. x:GetPlayerOwnerID(), timer_info);
        local duel_info = {
        endTime = draw_time,
        callback = function()
            EndDuel(radiant_heroes, dire_heroes, radiant_warriors, dire_warriors, end_duel_callback, 0)
            return nil
        end
    }
 
    Timers:CreateTimer("DS_DRAW_ITERNAL",duel_info)
        cur = cur + 1
        if cur >= max then cur = 1 end
 
        if first_time == false then
            for _, y in pairs(team_heroes) do
                SetPlayerCameraToEntity(y:GetPlayerOwnerID(), x)
            end
            first_time = true
        end
    end
end

function spawnEntitiesAlongPath( model, path )
	local j = #path
	for i = 1, #path do
		local offset = 128

		local direction = (path[i] - path[j]):Normalized()
		local distance = (path[j] - path[i]):Length2D()

		for x=0,distance,128 do
			local pos = GetGroundPosition(path[j] + (direction * x),obstacle)
			local obstacle = SpawnEntityFromTableSynchronous("prop_dynamic", {model = model, DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
			local blocker = SpawnEntityFromTableSynchronous("point_simple_obstruction", {origin = pos})
			obstacle:SetAbsOrigin(pos)
			obstacle:SetModelScale(4.0)
		end

	    j = i
	end
end

function isPointInsidePolygon(point, polygon)
	local oddNodes = false
	local j = #polygon
	for i = 1, #polygon do
	    if (polygon[i].y < point.y and polygon[j].y >= point.y or polygon[j].y < point.y and polygon[i].y >= point.y) then
	        if (polygon[i].x + ( point.y - polygon[i].y ) / (polygon[j].y - polygon[i].y) * (polygon[j].x - polygon[i].x) < point.x) then
	            oddNodes = not oddNodes
	        end
	    end
	    j = i
	end
	return oddNodes
end

function getMidPoint( points )
	local midPoint = Vector(0,0,0)
    for i=1,#points do
    	midPoint = midPoint + points[i]
    end
    midPoint = midPoint / #points
    return midPoint
end

function saveAbilitiesCooldowns(unit)
    if not unit then
        return
    end
   
    local savetable = {}
    local abilities = unit:GetAbilityCount() - 1
    for i = 0, abilities do
        if unit:GetAbilityByIndex(i) then
            savetable[i] = unit:GetAbilityByIndex(i):GetCooldownTimeRemaining()
            --print("Save Ability Cooldown abilityname='" .. unit:GetAbilityByIndex(i):GetAbilityName() .. "' cooldown = " .. savetable[i])
        end
    end
 
    savetable.items = {}
 
    for i = 0, 5 do
        if unit:GetItemInSlot(i) then
            savetable.items[unit:GetItemInSlot(i)] = unit:GetItemInSlot(i):GetCooldownTimeRemaining()
        end
    end
 
    return savetable
end
 
function setAbilitiesCooldowns(unit, settable)
    local abilities = unit:GetAbilityCount() - 1
    if not settable or not unit then
        return
    end
    for i = 0, abilities do
        if unit:GetAbilityByIndex(i) then
            unit:GetAbilityByIndex(i):StartCooldown(settable[i])
            if settable[i] == 0 then
                unit:GetAbilityByIndex(i):EndCooldown()
            end
        end
    end
 
    if settable.items then
        for item, cooldown in pairs(settable.items) do
            if item and IsValidEntity(item) then
                item:EndCooldown()
                print("start cooldown for ", item:GetName(), item, cooldown)
                item:StartCooldown(cooldown)
            end
        end
    end
end
 
function resetAllAbilitiesCooldown(unit, item_table)
    if not unit then return end
 
    local abilities = unit:GetAbilityCount() - 1
    for i = 0, abilities do
        if unit:GetAbilityByIndex(i) then
            unit:GetAbilityByIndex(i):EndCooldown()
        end
    end
 
    if item_table then
        if item_table.items then
            for i,x in pairs(item_table.items) do
                i:EndCooldown()
            end
        end
    end
end