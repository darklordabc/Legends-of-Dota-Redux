function CheckDistance(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability 

	local max_distance = ability:GetSpecialValueFor("distance")

	if (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() > max_distance then 
		target:RemoveModifierByName("modifier_libation_debuff")
	end
end

function ScepterLatch( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability 

	if caster:HasScepter() then
		local radius = ability:GetSpecialValueFor("radius_scepter")
		local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, 
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

		for _, unit in pairs(units) do 
			ability:ApplyDataDrivenModifier(caster,unit,"modifier_libation_debuff",{})
		end
	end
end