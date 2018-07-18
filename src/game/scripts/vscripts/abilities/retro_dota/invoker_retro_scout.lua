--local timers = require('easytimers')
--[[
	Author: wFX with help of Rook and Noya
	Date: 18.01.2015.
	Gets the summoning location for the new unit
]]

function invoker_retro_scout_on_spell_start(event)
    local caster = event.caster
    local ability = event.ability 
	local hero = caster:GetPlayerOwner():GetAssignedHero()
    local wex_ability = caster:FindAbilityByName("invoker_retro_scout")
    if wex_ability ~= nil then
        local wex_level = wex_ability:GetLevel()
        -- Gets the vector facing 200 units away from the caster origin    
        local fv = caster:GetForwardVector()
        local origin = caster:GetAbsOrigin()
        local front_position = origin + fv * 200
		
        local owl = CreateUnitByName("npc_dota_invoker_retro_scout_unit", front_position, true, hero, hero, caster:GetTeamNumber())
        owl:SetForwardVector(fv)
		local owl_ability = owl:FindAbilityByName("invoker_retro_scout_unit_ability")
		if owl_ability ~= nil then
			owl_ability:SetLevel(1)
			
			owl_ability:ApplyDataDrivenModifier(owl, owl, "modifier_invoker_retro_scout_unit_ability", {})

			local movespeed = ability:GetLevelSpecialValueFor("owl_movespeed", wex_level - 1)  --Movespeed increases per level of Wex.
			owl:SetBaseMoveSpeed(movespeed)
			
			local vision_range = ability:GetLevelSpecialValueFor("owl_vision", wex_level - 1)  --Vision radius increases per level of Wex.
			owl:SetDayTimeVisionRange(vision_range)
			owl:SetNightTimeVisionRange(vision_range)
			
			owl_ability:ApplyDataDrivenModifier(owl, owl, "modifier_invoker_retro_scout_unit_ability_vision_per_wex", {})
			owl:SetModifierStackCount("modifier_invoker_retro_scout_unit_ability_vision_per_wex", ability, wex_level)

			owl.vOwner = caster:GetOwner()
			owl:SetControllableByPlayer(caster:GetOwner():GetPlayerID(), true)
			owl:AddNewModifier(owl, nil, "modifier_kill", {duration = ability:GetLevelSpecialValueFor("owl_duration", wex_level - 1) })  --Add the green duration circle, and kill it after the duration ends.
			owl:AddNewModifier(owl, nil, "modifier_invisible", {duration = .1})  --Make the owl have the translucent texture.
			
			Timers:CreateTimer(function()
				owl:MoveToNPC(caster)
				return
			end, DoUniqueString('move_ward'), 0.1)
		end
    end
end


--[[
	Author: wFX with help of Rook and Noya
	Date: 18.01.2015.
	Removes invisibility from nearby units, and maintains a translucent texture on the unit.
]]
function modifier_invoker_retro_scout_unit_ability_on_interval_think(keys)
	keys.caster:AddNewModifier(keys.caster, keys.ability, "modifier_invisible", {duration = .1})

	local nearby_enemy_units = FindUnitsInRadius(keys.caster:GetTeam(), keys.caster:GetAbsOrigin(), nil, keys.caster:GetCurrentVisionRange(), DOTA_UNIT_TARGET_TEAM_ENEMY,
	DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)

	for i, individual_unit in ipairs(nearby_enemy_units) do
		individual_unit:AddNewModifier(keys.caster, keys.ability, "modifier_truesight", {duration = .5})
	end
end