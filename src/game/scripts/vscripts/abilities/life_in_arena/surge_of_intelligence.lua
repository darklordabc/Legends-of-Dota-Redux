function Damage( event )
	local caster = event.caster
	local targets = event.target_entities
	local ability = event.ability
	local koef_damage = ability:GetSpecialValueFor('koef_damage') 
	-- рассчитаем урон который необходимо нанести
	local intBase = caster:GetBaseIntellect()
	local intOther = caster:GetIntellect()-intBase
	local dmg = (intBase+intOther/2)*koef_damage
	
	for _,v in pairs(targets) do
		ApplyDamage({ victim = v, attacker = caster, damage = dmg, damage_type = DAMAGE_TYPE_MAGICAL, ability = ability })
		local particle = ParticleManager:CreateParticle("particles/leshrac_diabolic_edict_custom.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(particle, 1, v:GetAbsOrigin())
	end
end
