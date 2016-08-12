function EatCreep ( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	if target:IsValidEntity(true) and not target:IsAncient() and not caster:HasModifier("modifier_creep_eaten") then
		local damage = target:GetHealth()
		ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_PURE})
		ability:ApplyDataDrivenModifier(caster, target, "modifier_creep_eaten", {duration = damage / 20})
	end
end

function CreepGold ( keys )
	local caster = keys.caster
	local ability = keys.ability
	local gold = ability:GetLevelSpecialValueFor("devour_gold", ability:GetLevel) - 1

	if caster:IsAlive() then
	caster:ModifyGold(gold, false, 0)
	end 
end
