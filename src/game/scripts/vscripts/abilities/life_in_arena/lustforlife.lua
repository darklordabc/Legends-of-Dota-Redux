
function UpdateRegen(event)
	local caster = event.caster
	local ability = event.ability

	while(caster:HasModifier("modifier_lust_for_life_health_regen")) do
		caster:RemoveModifierByName("modifier_lust_for_life_health_regen")
	end

	local modifierCount = math.ceil((100 - caster:GetHealthPercent())/10)

	for i = modifierCount, 0, -1 do
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_lust_for_life_health_regen", nil)
	end
end

