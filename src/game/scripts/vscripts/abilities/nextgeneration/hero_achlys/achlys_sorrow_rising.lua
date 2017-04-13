function HandleStacks(keys)
	local caster = keys.caster
	local ability = keys.ability
	local health = keys.health
	local mana = keys.mana
	local hpPerc = 100 - caster:GetHealthPercent()
	local manaPerc = 100 - caster:GetManaPercent()
	
	if ability.FXHP then
		ParticleManager:SetParticleControl(ability.FXHP, 1, Vector(20*hpPerc,0,0) )
	else
		ability.FXHP = ParticleManager:CreateParticle("particles/achlys_sorrow_rising_evasion.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(ability.FXHP, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(ability.FXHP, 1, Vector(20*hpPerc,0,0) )
	end
	
	if ability.FXMP1 and ability.FXMP2 then
		ParticleManager:SetParticleControl(ability.FXMP1, 1, Vector(20*manaPerc,0,0) )
		ParticleManager:SetParticleControl(ability.FXMP2, 1, Vector(20*manaPerc,0,0) )
	else
		ability.FXMP1 = ParticleManager:CreateParticle("particles/achlys_sorrow_rising_damage.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(ability.FXMP1, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(ability.FXMP1, 1, Vector(20*manaPerc,0,0) )
		ability.FXMP2 = ParticleManager:CreateParticle("particles/achlys_sorrow_rising_damage.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(ability.FXMP2, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(ability.FXMP2, 1, Vector(20*manaPerc,0,0) )
	end

	if math.floor(hpPerc+0.5) == 0 then 
		caster:RemoveModifierByName(health)
	else
		if not caster:HasModifier(health) then
			ability:ApplyDataDrivenModifier(caster, caster, health, {})
			caster:SetModifierStackCount( health, caster, math.floor(hpPerc+0.5) )
		elseif math.floor(hpPerc+0.5) > 0 then
			caster:SetModifierStackCount( health, caster, math.floor(hpPerc+0.5) )
		end
	end
	if math.floor(manaPerc+0.5) == 0 then 
		caster:RemoveModifierByName(mana)
	else
		if not caster:HasModifier(mana) then
			ability:ApplyDataDrivenModifier(caster, caster, mana, {})
			caster:SetModifierStackCount( mana, caster, math.floor(manaPerc+0.5) )
		elseif math.floor(manaPerc+0.5) > 0 then
			caster:SetModifierStackCount( mana, caster, math.floor(manaPerc+0.5) )
		end
	end	
end