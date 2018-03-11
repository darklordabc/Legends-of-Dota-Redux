function onSpellStart( event )

	local caster = event.caster
	local ability = event.ability

	if caster:HasModifier("modifier_custom_arcane_mastery") then
		caster:RemoveModifierByName("modifier_custom_arcane_mastery")
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_custom_arcane_mastery", nil)
		else
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_custom_arcane_mastery", nil)
	end
	
end

function onHeroKill( event )
	local caster = event.caster
	local cooldownReduction = event.ability:GetSpecialValueFor("cooldownReduction")
	local abilityCount = caster:GetAbilityCount()

	for i = 0, abilityCount - 1 do
        local ability = caster:GetAbilityByIndex(i)
		
		if ability ~= nil and ability ~= event.ability then
			local cooldown = ability:GetCooldown(event.ability:GetLevel())
			local timeLeft = ability:GetCooldownTimeRemaining()
			ability:EndCooldown()
			ability:StartCooldown(timeLeft - cooldownReduction)
		end
	end
end