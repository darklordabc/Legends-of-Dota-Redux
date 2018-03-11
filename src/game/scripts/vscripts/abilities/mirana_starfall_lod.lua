if IsServer() then
	require('lib/timers')
end

function Starfall( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local ambient_sound = keys.ambient_sound
	local hit_sound = keys.hit_sound
	local ambient_particle = keys.ambient_particle
	local hit_particle = keys.hit_particle

	-- Parameters
	local radius = ability:GetLevelSpecialValueFor("starfall_radius", ability_level)
	local hit_delay = ability:GetLevelSpecialValueFor("starfall_delay", ability_level)
	local damage = ability:GetAbilityDamage()

	-- Grant vision of the area for the duration
	local caster_pos = caster:GetAbsOrigin()

	-- Emit sound
	caster:EmitSound(ambient_sound)

	-- Create ambient particle
	local ambient_pfx = ParticleManager:CreateParticle(ambient_particle, PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(ambient_pfx, 0, caster_pos)
	ParticleManager:SetParticleControl(ambient_pfx, 1, Vector(radius, 0, 0))
	ParticleManager:ReleaseParticleIndex(ambient_pfx)

	-- Find nearby enemies and apply the particle, damage, debuff, and hit sound
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster_pos, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
	for _,enemy in pairs(enemies) do
		local star_pfx = ParticleManager:CreateParticle(hit_particle, PATTACH_ABSORIGIN_FOLLOW, enemy)
		ParticleManager:SetParticleControl(star_pfx, 0, enemy:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(star_pfx)
		Timers:CreateTimer(hit_delay, function()
			enemy:EmitSound(hit_sound)
			ApplyDamage({victim = enemy, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
		end)
	end

    Timers:CreateTimer( 0.75, function()
		for _,enemy in pairs(enemies) do
			if enemy:IsAlive() and not enemy:IsNull() then
				print("asdasd")
				local star_pfx = ParticleManager:CreateParticle(hit_particle, PATTACH_ABSORIGIN_FOLLOW, enemy)
				ParticleManager:SetParticleControl(star_pfx, 0, enemy:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(star_pfx)
				Timers:CreateTimer(hit_delay, function()
					enemy:EmitSound(hit_sound)
					ApplyDamage({victim = enemy, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
				end)
				break
			end
		end
    end)
end

function ScepterStarfallCheck( keys )
	local caster = keys.caster
	local ability = keys.ability
	
	if caster:IsIllusion() then return end
	if caster:PassivesDisabled() then return end
	-- Check if we actually have scepter
	if ability and caster:HasScepter() and caster:IsInvisible() == false then
		local abLevel = ability:GetLevel()

		local abRadius = ability:GetLevelSpecialValueFor('starfall_radius', abLevel - 1)

		-- Look for enemies in range
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(),caster:GetAbsOrigin(),nil,abRadius,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false)
	
		-- Loop through enemies and check if it actually sees caster
		for k,v in pairs(enemies) do
			if v:CanEntityBeSeenByMyTeam(caster) and caster:CanEntityBeSeenByMyTeam(v) then
				-- Remove thinker
				caster:RemoveModifierByName("modifier_mirana_starfall_scepter_thinker")

				-- Wait for scepter interval before next starfall
				ability:ApplyDataDrivenModifier(caster,caster,"modifier_mirana_starfall_scepter_cooldown",{})

				ability:OnSpellStart()

				break
			end
		end
	end
end
