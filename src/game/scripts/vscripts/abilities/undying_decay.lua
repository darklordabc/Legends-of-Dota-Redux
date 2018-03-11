function ScepterCheck( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	print("not working")
	EmitSoundOn("Hero_Undying.Decay.Transfer", target)
	EmitSoundOn("Hero_Undying.Decay.Target", target)
	
	ApplyDamage({victim = target, attacker = caster, damage = ability:GetSpecialValueFor("decay_damage"), damage_type = ability:GetAbilityDamageType(), ability = ability})
	
	if target:IsHero() then
		local scepterNameModifier = ""
		local stacks = keys.stacks
		if caster:HasScepter() then 
			scepterNameModifier = "_scepter"
			stacks = keys.scepterstacks
		end

		ability:ApplyDataDrivenModifier(caster, caster, keys.modifierAlly..scepterNameModifier, {duration = ability:GetSpecialValueFor("decay_duration")})
		ability:ApplyDataDrivenModifier(caster, caster, keys.modifierCounter, {duration = ability:GetSpecialValueFor("decay_duration")})
		caster:SetModifierStackCount(keys.modifierCounter, caster, caster:GetModifierStackCount(keys.modifierCounter, caster) + stacks)
		ability:ApplyDataDrivenModifier(caster, target, keys.modifierEnemy..scepterNameModifier, {duration = ability:GetSpecialValueFor("decay_duration")})
		local decayLink = ParticleManager:CreateParticle(keys.particleLink, PATTACH_POINT_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(decayLink, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(decayLink, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(decayLink, 3, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", (caster:GetAbsOrigin() + target:GetAbsOrigin())/2, true)
		caster:CalculateStatBonus()
		target:CalculateStatBonus()
	end
end

function DecreaseModelSize( keys )
	local caster = keys.caster
	local ability = keys.ability

	caster:SetModifierStackCount(keys.modifierCounter, caster, caster:GetModifierStackCount(keys.modifierCounter, caster) - keys.stacks)
	if caster:GetModifierStackCount(keys.modifierCounter, caster) >= 0 then
		caster:RemoveModifierByName(keys.modifierCounter)
	end
end 

function ApplyParticles(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target_points[1]
	local radius = ability:GetSpecialValueFor("radius")
	
	local decayRadius = ParticleManager:CreateParticle(keys.particleRadius, PATTACH_POINT, caster)
			ParticleManager:SetParticleControl(decayRadius, 0, target)
			ParticleManager:SetParticleControl(decayRadius, 1, Vector(radius, radius, radius))
			ParticleManager:SetParticleControl(decayRadius, 2, target)
end