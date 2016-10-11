function Devour(keys)
	local target = keys.target
	local instant_heal = keys.instant_heal
	if string.find(target:GetUnitName(),"boss") or target:IsHero() then 
	 	keys.ability:ApplyDataDrivenModifier(keys.caster, target, "modifier_ghoul_devour_slow", nil)		
	else
		keys.target:Kill(keys.ability, keys.caster)
		keys.caster:Heal(instant_heal, keys.caster)
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_ghoul_devour_heal", nil)
	end
end
