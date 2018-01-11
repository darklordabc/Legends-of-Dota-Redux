function ModifyCreepDamage(keys)
	local caster = keys.caster
	local target = keys.target
	if target:IsCreep() then
		local ability = keys.ability
		local damage_bonus = keys.damage_bonus_ranged ~= nil and caster:IsRangedAttacker() and keys.damage_bonus_ranged or keys.damage_bonus

		-- If not specified, assume that constant values are given
		local damage = keys.damage and
			(keys.damage * (damage_bonus * 0.01 - 1)) or
			damage_bonus

		ApplyDamage({
			attacker = caster,
			victim = target,
			damage = damage,
			damage_type = DAMAGE_TYPE_PURE,
			damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
			ability = keys.ability
		})
	end
end
