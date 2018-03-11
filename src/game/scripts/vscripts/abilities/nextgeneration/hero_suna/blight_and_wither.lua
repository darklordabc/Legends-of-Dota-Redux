function ApplySlowStacksOnAttack( keys )
	local caster = keys.caster
	local target = keys.attacker
	local ability = keys.ability
	local modifierName = "modifier_blight_slow_stack"

	if not target:HasModifier(modifierName) then
		ability:ApplyDataDrivenModifier(caster, target, modifierName, {})
		target:SetModifierStackCount(modifierName, ability, 1)
	else
		local stack = target:GetModifierStackCount(modifierName, ability)
		target:SetModifierStackCount(modifierName, ability, stack + 1)
	end
end

function ApplySlowStacksOnAttacked( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local modifierName = "modifier_blight_slow_stack"

	if not target:HasModifier(modifierName) then
		ability:ApplyDataDrivenModifier(caster, target, modifierName, {})
		target:SetModifierStackCount(modifierName, ability, 1)
	else
		local stack = target:GetModifierStackCount(modifierName, ability)
		target:SetModifierStackCount(modifierName, ability, stack + 1)

	end
end

function ApplyBlightDamage( keys )
	local caster = keys.caster
	local ability = keys.ability
	local attacker = keys.attacker
	local target = keys.target
	local damageType = ability:GetAbilityDamageType()

	if attacker:IsHero() then 
		damage = ability:GetAbilityDamage()
	else
		damage = ability:GetAbilityDamage() / 2
	end

	ApplyDamage({ victim = target, attacker = caster, ability = ability:GetName(), damage = damage, damage_type = damageType })
end