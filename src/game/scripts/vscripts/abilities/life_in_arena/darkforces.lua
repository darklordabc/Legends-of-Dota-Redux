function DarkForces(event)
	local ability = event.ability
	local caster = event.caster
	local target = event.target
	local mana_percentage = ability:GetSpecialValueFor("mana_percentage")
	local mana = caster:GetMana()
	local damage = mana*mana_percentage*0.01
	local targets = event.target_entities
	for _,v in pairs(targets) do
		ApplyDamage({victim = v, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL, ability = ability})
	end

end

function DarkForcesThinker(event)
	local ability = event.ability
	local caster = event.caster
	local target = event.target
	local position = caster:GetAbsOrigin() + RandomVector(150)

	ability:ApplyDataDrivenThinker(caster, position, "modifier_dark_knight_dark_forces_thinker", {duration = 1})
end