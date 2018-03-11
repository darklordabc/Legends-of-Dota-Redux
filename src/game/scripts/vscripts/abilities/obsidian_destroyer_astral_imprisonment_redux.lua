function AstralImprisonmentEnd( keys )
	local sound_name = "Hero_ObsidianDestroyer.AstralImprisonment"
	local target = keys.target
	local modifier = target:FindModifierByName("modifier_astral_imprisonment_redux")
	local ability = keys.ability
	local damage = ability:GetSpecialValueFor("damage")
	local radius = ability:GetSpecialValueFor("radius")

	StopSoundEvent(sound_name, target)

	target:RemoveNoDraw()
	ParticleManager:DestroyParticle(ability.particles[target:entindex()],false)
	ParticleManager:ReleaseParticleIndex(ability.particles[target:entindex()])
	local pos = vlua.find(ability.particles, target:entindex())
	if pos then
		table.remove(ability.particles, pos)
	end
	
	for k,v in pairs(FindUnitsInRadius(keys.caster:GetTeam(), keys.target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
		ApplyDamage({victim = v, attacker = keys.caster, ability = ability, damage = damage, damage_type = ability:GetAbilityDamageType()})
	end
end

function AstralImprisonmentStart( keys )
	local target = keys.target
	local caster = keys.caster
	local modifier = target:FindModifierByName("modifier_astral_imprisonment_redux")
	local ability = keys.ability

	target:AddNoDraw()

	ability.particles = ability.particles or {}

    ability.particles[target:entindex()] = ParticleManager:CreateParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_prison.vpcf", PATTACH_WORLDORIGIN, target)
    ParticleManager:SetParticleControl(ability.particles[target:entindex()], 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(ability.particles[target:entindex()], 2, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(ability.particles[target:entindex()], 3, target:GetAbsOrigin())

	local stacks = caster:GetModifierStackCount("modifier_astral_imprisonment_redux_stacks", caster)

	if stacks > 0 then
		keys.ability:EndCooldown()
		caster:SetModifierStackCount("modifier_astral_imprisonment_redux_stacks", caster, stacks - 1)
		if stacks - 1 == 0 then
			-- keys.ability:StartCooldown(ability:GetSpecialValueFor("charge_restore_time_scepter"))
			keys.ability:StartCooldown(caster:FindModifierByName("modifier_astral_imprisonment_redux_stack"):GetRemainingTime())
		end
	-- elseif caster:HasScepter() then
	-- 	keys.ability:StartCooldown(caster:FindModifierByName("modifier_astral_imprisonment_redux_stack"):GetDuration())
	end
end

function AstralImprisonmentCheckStacks( keys )
	local caster = keys.caster
	local ability = keys.ability

	local stacks = caster:GetModifierStackCount("modifier_astral_imprisonment_redux_stacks", caster)

	if stacks > 0 then
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_astral_imprisonment_redux_stacks_counter",{}):SetStackCount(stacks)
	else
		caster:RemoveModifierByName("modifier_astral_imprisonment_redux_stacks_counter")
	end
	
	if caster:HasScepter() and stacks < ability:GetSpecialValueFor("max_charges_scepter") and not caster:HasModifier("modifier_astral_imprisonment_redux_stack") then
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_astral_imprisonment_redux_stack",{})
	end
end

function AstralImprisonmentCheckStack( keys )
	local caster = keys.caster
	local ability = keys.ability

	local stacks = caster:GetModifierStackCount("modifier_astral_imprisonment_redux_stacks", caster)

	if caster:HasScepter() and stacks < ability:GetSpecialValueFor("max_charges_scepter") then
		caster:SetModifierStackCount("modifier_astral_imprisonment_redux_stacks", caster, stacks + 1)
	end
end
