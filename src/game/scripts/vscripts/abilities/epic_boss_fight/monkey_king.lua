function JinguHit(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local damage = keys.attack_damage
	
	--dont think this lifesteal accounts for % based reductions like dispersion
	if not target:IsBuilding() then
		-- damage is pre mitigation so we calculate damage post mitigation for lifesteal
		local armor = target:GetPhysicalArmorValue()
		local reduction = ((0.02 * armor) / (1 + 0.02 * armor))
		local lifesteal = (damage - damage * reduction) * ability:GetSpecialValueFor("lifesteal")*0.01

		-- lifesteal pfx and heal
		local lifePfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
	--	ParticleManager:SetParticleControl(lifePfx, 0, caster:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(lifePfx)
		caster:Heal(lifesteal, caster)

		-- explosion particles on target
		local hitPfx = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_quad_tap_hit.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControl(hitPfx, 1, target:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(hitPfx)
	end
	
	local jinguBuff = caster:FindModifierByName("modifier_jingu_mastery_activated")
	if jinguBuff then
		jinguBuff:DecrementStackCount()
		if jinguBuff:GetStackCount() <= 0 then
			jinguBuff:Destroy()
			caster:RemoveModifierByName("modifier_jingu_mastery_activated_damage")
		end
	end
end

function CheckJingu(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	if ability:GetName() ~= "monkey_king_jingu_mastery_lod" then
		if not ability:IsCooldownReady() then
	        return nil
	    end
	end

	if caster:HasModifier("modifier_jingu_mastery_activated") or not target:IsRealHero() or not caster:IsRealHero() or caster:PassivesDisabled() then return
	else
		local jinguStack = target:FindModifierByName("modifier_jingu_mastery_hitcount")
		if jinguStack then
			jinguStack:ForceRefresh()
		else
			jinguStack = ability:ApplyDataDrivenModifier(caster, target, "modifier_jingu_mastery_hitcount", {duration = ability:GetTalentSpecialValueFor("counter_duration")})
			jinguStack:SetStackCount(0)
		end
		jinguStack:SetStackCount(jinguStack:GetStackCount() + 1)
		--print(jinguStack:GetStackCount())
		
		if not target.OverHeadJingu then 
			target.OverHeadJingu = ParticleManager:CreateParticle(keys.particle, PATTACH_OVERHEAD_FOLLOW, target)
			ParticleManager:SetParticleControl(target.OverHeadJingu, 0, target:GetAbsOrigin())
		end
		ParticleManager:SetParticleControl(target.OverHeadJingu, 1, Vector(0,jinguStack:GetStackCount(),0))
		
		if jinguStack:GetStackCount() == ability:GetTalentSpecialValueFor("required_hits") then
			--shiny explosion particles on caster
			local startPfx = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_quad_tap_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControl(startPfx, 0, caster:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(startPfx)
			
			EmitSoundOn("Hero_MonkeyKing.IronCudgel", caster)
			
			local jinguBuff = ability:ApplyDataDrivenModifier(caster, caster, "modifier_jingu_mastery_activated", {})
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_jingu_mastery_activated_damage", {})
			jinguBuff:SetStackCount(ability:GetTalentSpecialValueFor("charges"))
			jinguStack:Destroy()

			if ability:GetName() ~= "monkey_king_jingu_mastery_lod" then
				ability:StartCooldown(3)
			end
			
		end
	end
end

function JinguOverheadDestroy(keys)
	local target = keys.target
	
	ParticleManager:DestroyParticle(target.OverHeadJingu, false)
	ParticleManager:ReleaseParticleIndex(target.OverHeadJingu)
	target.OverHeadJingu = nil
end
