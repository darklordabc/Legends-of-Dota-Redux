function CausticFinale( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local modifier_debuff = keys.modifier_debuff
	local modifier_prevent = keys.modifier_prevent

	-- If the target is an ally, or already has the debuff, or has the prevention debuff, do nothing
	if target:GetTeam() == caster:GetTeam() or target:HasModifier(modifier_debuff) or target:HasModifier(modifier_prevent) or target:IsIllusion() or target:IsBuilding() then
		return nil
	end

	-- Else, apply it
	ability:ApplyDataDrivenModifier(caster, target, modifier_debuff, {})
end

function CausticFinaleEnd( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local modifier_debuff = keys.modifier_debuff
	local modifier_prevent = keys.modifier_prevent
	local modifier_slow = keys.modifier_slow
	local particle_explode = keys.particle_explode
	local sound_explode = keys.sound_explode

	-- Parameters
	local radius = ability:GetLevelSpecialValueFor("radius", ability_level)
	local damage = ability:GetLevelSpecialValueFor("damage", ability_level)
	local target_pos = target:GetAbsOrigin()

	-- If the unit did not die with the effect, it only deals half damage
	if target:GetHealth() > 0 then
		damage = damage / 2
	end

	-- Play sound
	target:EmitSound(sound_explode)

	-- Fire particle
	local explosion_pfx = ParticleManager:CreateParticle(particle_explode, PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControl(explosion_pfx, 0, target_pos)
	ParticleManager:ReleaseParticleIndex(explosion_pfx)

	-- Find and iterate through nearby enemies
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target_pos, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _,enemy in pairs(enemies) do

		-- Deal damage
		ability:ApplyDataDrivenModifier(caster, enemy, modifier_prevent, {})
		ApplyDamage({attacker = caster, victim = enemy, ability = ability, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
		enemy:RemoveModifierByName(modifier_prevent)

		-- Slow
		ability:ApplyDataDrivenModifier(caster, enemy, modifier_slow, {})

		-- Chain reaction
		--if enemy:HasModifier(modifier_debuff) then
		--	enemy:RemoveModifierByName(modifier_debuff)
		--end
	end
end
