--[[
	Author: Rook and wFX
	Date: 23.02.2015.
	Adds invisibility to nearby units.
	Additional parameters: keys.FadeTime
]]
function modifier_invoker_retro_invisibility_aura_on_interval_think(keys)
	if keys.caster:PassivesDisabled() then return end
	local quas_ability = keys.caster:FindAbilityByName("invoker_retro_invisibility_aura_tower")
	
	if keys.ability == nil then   --If Invisibility Aura is not invoked anymore, or if it was re-invoked and the old keys.ability no longer exists.
		local invisibility_aura_ability = keys.caster:FindAbilityByName("invoker_retro_invisibility_aura_tower")
		if invisibility_aura_ability == nil then  --If Invisiblity Aura is no longer invoked, remove the aura modifier.
			keys.caster:RemoveModifierByName("modifier_invoker_retro_invisibility_aura")
		else  --If Invisibility Aura was re-invoked, replace the aura modifier with one tied to the new instance of the ability.
			keys.caster:RemoveModifierByName("modifier_invoker_retro_invisibility_aura")
			invisibility_aura_ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_invoker_retro_invisibility_aura", nil)
		end
	elseif quas_ability ~= nil then
		local radius = keys.ability:GetLevelSpecialValueFor("radius", quas_ability:GetLevel() - 1)

		local nearby_ally_units = FindUnitsInRadius(keys.caster:GetTeam(), keys.caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)

		for i, individual_unit in ipairs(nearby_ally_units) do
			if keys.caster ~= individual_unit and not string.find(individual_unit:GetName(), "tower_radiant") then  --Invisibility Aura does not make Invoker nor the Radiant towers invisible.
				local current_gametime = GameRules:GetGameTime()
				if individual_unit.invisibility_aura_most_recent_gametime_in_aura == nil then  --Initialize the most recent time the unit was in an Invis Aura, if necessary.
					individual_unit.invisibility_aura_most_recent_gametime_in_aura = 0
				end
				if individual_unit.invisibility_aura_started_to_fade_gametime == nil then  --Initialize the time at which the unit started to fade, if necessary.
					individual_unit.invisibility_aura_started_to_fade_gametime = current_gametime
				end
				
				--If the unit has been out of an invisibility aura for longer than .5 seconds and does not have modifier_invoker_retro_invisibility_aura_effect on them, start fading.
				--Fading is also restarted when the unit attacks or casts an ability.
				if not individual_unit:HasModifier("modifier_invoker_retro_invisibility_aura_effect") and current_gametime - individual_unit.invisibility_aura_most_recent_gametime_in_aura >= .5 then
					individual_unit.invisibility_aura_started_to_fade_gametime = current_gametime
				end
				
				if individual_unit:HasModifier("modifier_invoker_retro_invisibility_aura_effect") then  --Immediately apply the invis if the unit is already invis from Invis Aura.
					keys.ability:ApplyDataDrivenModifier(keys.caster, individual_unit, "modifier_invoker_retro_invisibility_aura_effect", nil)
				elseif current_gametime - individual_unit.invisibility_aura_started_to_fade_gametime >= keys.FadeTime then --If the unit is not already invis from the invis aura, apply the invis if they have been within its range and have not attacked nor used an ability for at least the FadeTime.
					keys.ability:ApplyDataDrivenModifier(keys.caster, individual_unit, "modifier_invoker_retro_invisibility_aura_effect", nil)
					individual_unit:EmitSound("Hero_Invoker.GhostWalk")
				end
				
				individual_unit.invisibility_aura_most_recent_gametime_in_aura = current_gametime  --Keep track of the most recent time the unit was within an Invisibility Aura.
				keys.ability:ApplyDataDrivenModifier(keys.caster, individual_unit, "modifier_invoker_retro_invisibility_aura_in_radius", nil)  --Add a modifier to reset the fade time when attacking or using an ability.
			end
		end
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 24, 2015
	Called regularly while under the effects of Invisibility Aura.  Repeatedly apply the stock modifier_invisible
	for the sole purpose of making the unit have a transparent texture.  This can be gotten rid of when we discover
	how to apply a translucent texture manually.
================================================================================================================= ]]
function modifier_invoker_retro_invisibility_aura_effect_on_interval_think(keys)
	if keys.target:IsAttacking() == false then
		keys.target:AddNewModifier(keys.caster, keys.ability, "modifier_invisible", {duration = .1})
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 24, 2015
	Called when a unit under the effects of Invisibility Aura casts an ability, revealing themselves.  Removes the
	invisibility from them and stores the gametime.
================================================================================================================= ]]
function modifier_invoker_retro_invisibility_aura_in_radius_on_ability_executed(keys)
	keys.unit:RemoveModifierByName("modifier_invoker_retro_invisibility_aura_effect")
	keys.unit.invisibility_aura_started_to_fade_gametime = GameRules:GetGameTime()
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 24, 2015
	Called when a unit under the effects of Invisibility Aura autoattacks, revealing themselves.  Removes the
	invisibility from them and stores the gametime.
================================================================================================================= ]]
function modifier_invoker_retro_invisibility_aura_in_radius_on_attack_start(keys)
	keys.attacker:RemoveModifierByName("modifier_invoker_retro_invisibility_aura_effect")
	keys.attacker.invisibility_aura_started_to_fade_gametime = GameRules:GetGameTime()
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 24, 2015
	Called when Invisibility Aura is invoked.  Creates the aura particle effect around Invoker.
================================================================================================================= ]]
function modifier_invoker_retro_invisibility_aura_on_created(keys)
	local quas_ability = keys.caster:FindAbilityByName("invoker_retro_invisibility_aura_tower")
	if quas_ability ~= nil then
		local radius = keys.ability:GetLevelSpecialValueFor("radius", quas_ability:GetLevel() - 1)

		local invisibility_aura_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_retro_invisibility_aura.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster)
		ParticleManager:SetParticleControl(invisibility_aura_particle, 1, Vector(radius, radius, radius))
		local invisibility_aura_circle_sprite_radius = radius * 1.276  --The circle's sprite extends outwards a bit, so make it slightly larger.
		ParticleManager:SetParticleControl(invisibility_aura_particle, 2, Vector(invisibility_aura_circle_sprite_radius, invisibility_aura_circle_sprite_radius, invisibility_aura_circle_sprite_radius))
		
		keys.caster.invisibility_aura_particle = invisibility_aura_particle
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 24, 2015
	Called when Invisibility Aura is un-invoked.  Destroys the aura particle effect around Invoker.
================================================================================================================= ]]
function modifier_invoker_retro_invisibility_aura_on_destroy(keys)
	if keys.caster.invisibility_aura_particle ~= nil then
		ParticleManager:DestroyParticle(keys.caster.invisibility_aura_particle, false)
		keys.caster.invisibility_aura_particle = nil
	end
end
