function HealPercent(keys)
	local caster = keys.caster
	local ability = keys.ability

	local radius = ability:GetSpecialValueFor("radius")
	local base = ability:GetSpecialValueFor("heal")
	local pct = ability:GetSpecialValueFor("heal_percent") * 0.01

	local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _,target in pairs(targets) do
		local heal = base + (target:GetMaxHealth() * pct)
		target:Heal(heal, ability)
	end
end