function ScepterCheck( keys )
	local caster = keys.caster
	local ability = keys.ability
	
	local scepterNameModifier = ""
	if caster:HasScepter() then scepterNameModifier = "_scepter"
	ability:ApplyDataDrivenModifier(caster, caster, keys.modifierAlly..scepterNameModifier, {duration = ability:GetSpecialValueFor("decay_duration")})
	ability:ApplyDataDrivenModifier(caster, target, keys.modifierEnemy..scepterNameModifier, {duration = ability:GetSpecialValueFor("decay_duration")})
	caster:SetModelScale( caster:GetModelScale()*(1+ability:GetSpecialValueFor("stat_scale_up")/100) )
	local decayLink = ParticleManager:CreateParticle(keys.particleLink, PATTACH_POINT_FOLLOW, target)
			ParticleManager:SetParticleControlEnt(goldFountain, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(goldFountain, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(goldFountain, 3, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	-- local decayRadius =
end

function DecreaseModelSize( keys )
	local caster = keys.caster
	local ability = keys.ability

	caster:SetModelScale( caster:GetModelScale()/(1+ability:GetSpecialValueFor("stat_scale_up")/100) )
end 