--[[ 	Mercy main, BTW
		Author: Firetoad
		Date: 11.03.2017	]]
LinkLuaModifier("modifier_mercy_caduceus_power", "abilities/overmeme/mercy/modifier_mercy_caduceus_power.lua", LUA_MODIFIER_MOTION_NONE )

function CaduceusHealLaunch(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local target = keys.target_points[1]

	-- Parameters
	local caster_loc = caster:GetAbsOrigin()
	local cast_direction = (target - caster_loc):Normalized()
	local heal_particle = "particles/units/heroes/mercy/caduceus_healing_shot.vpcf"
	local projectile_radius = ability:GetLevelSpecialValueFor("projectile_radius", ability_level)
	local projectile_speed = ability:GetLevelSpecialValueFor("projectile_speed", ability_level)
	local projectile_range = ability:GetLevelSpecialValueFor("projectile_range", ability_level)

	-- Play sound
	caster:EmitSound("Overmemed.CaduceusLaunch")

	-- Launch projectile
	local heal_projectile = {
		Ability				= ability,
		EffectName			= heal_particle,
		vSpawnOrigin		= caster_loc + cast_direction * (projectile_radius + 25) + Vector(0, 0, 150),
		fDistance			= projectile_range,
		fStartRadius		= projectile_radius,
		fEndRadius			= projectile_radius,
		Source				= caster,
		bHasFrontalCone		= false,
		bReplaceExisting	= false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_FRIENDLY,
	--	iUnitTargetFlags	= ,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	--	fExpireTime			= ,
		bDeleteOnHit		= true,
		vVelocity			= Vector(cast_direction.x, cast_direction.y, 0) * projectile_speed,
		bProvidesVision		= false,
		iVisionRadius		= 0,
		iVisionTeamNumber	= caster:GetTeamNumber()
	}

	ProjectileManager:CreateLinearProjectile(heal_projectile)
end

function CaduceusHealHit(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Parameters
	local modifier_regen = keys.modifier_regen
	local instant_heal = ability:GetLevelSpecialValueFor("instant_heal", ability_level)

	-- Apply healing and regen
	target:Heal(instant_heal, caster)
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, target, instant_heal, nil)
	ability:ApplyDataDrivenModifier(caster, target, modifier_regen, {})

	-- Play healing sound
	target:EmitSound("Overmemed.CaduceusHealHit")

	-- Play healing particle
	local healing_impact_pfx = ParticleManager:CreateParticle("particles/units/heroes/mercy/caduceus_healing_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(healing_impact_pfx, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(healing_impact_pfx, 1, Vector(175, 0, 0))
	ParticleManager:ReleaseParticleIndex(healing_impact_pfx)
end

function CaduceusPowerLaunch(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local target = keys.target_points[1]

	-- Parameters
	local caster_loc = caster:GetAbsOrigin()
	local cast_direction = (target - caster_loc):Normalized()
	local power_particle = "particles/units/heroes/mercy/caduceus_power_shot.vpcf"
	local projectile_radius = ability:GetLevelSpecialValueFor("projectile_radius", ability_level)
	local projectile_speed = ability:GetLevelSpecialValueFor("projectile_speed", ability_level)
	local projectile_range = ability:GetLevelSpecialValueFor("projectile_range", ability_level)

	-- Play sound
	caster:EmitSound("Overmemed.CaduceusLaunch")

	-- Launch projectile
	local power_projectile = {
		Ability				= ability,
		EffectName			= power_particle,
		vSpawnOrigin		= caster_loc + cast_direction * (projectile_radius + 25) + Vector(0, 0, 150),
		fDistance			= projectile_range,
		fStartRadius		= projectile_radius,
		fEndRadius			= projectile_radius,
		Source				= caster,
		bHasFrontalCone		= false,
		bReplaceExisting	= false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_FRIENDLY,
	--	iUnitTargetFlags	= ,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	--	fExpireTime			= ,
		bDeleteOnHit		= true,
		vVelocity			= Vector(cast_direction.x, cast_direction.y, 0) * projectile_speed,
		bProvidesVision		= false,
		iVisionRadius		= 0,
		iVisionTeamNumber	= caster:GetTeamNumber()
	}

	ProjectileManager:CreateLinearProjectile(power_projectile)
end

function CaduceusPowerHit(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Parameters
	local modifier_power = keys.modifier_power
	local bonus_damage = ability:GetLevelSpecialValueFor("bonus_damage", ability_level)
	local bonus_spell_damage = ability:GetLevelSpecialValueFor("bonus_spell_damage", ability_level)
	local power_duration = ability:GetLevelSpecialValueFor("power_duration", ability_level)

	-- Apply power modifier
	target:AddNewModifier(caster, ability, modifier_power, {bonus_damage = bonus_damage, bonus_spell_damage = bonus_spell_damage, duration = power_duration})

	-- Play impact sound
	target:EmitSound("Overmemed.CaduceusPowerHit")

	-- Play impact particle
	local power_impact_pfx = ParticleManager:CreateParticle("particles/units/heroes/mercy/caduceus_power_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(power_impact_pfx, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(power_impact_pfx, 1, Vector(175, 0, 0))
	ParticleManager:ReleaseParticleIndex(power_impact_pfx)
end

function GuardianAngel(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	-- Parameters
	local modifier_self = keys.modifier_self
	local swoop_duration = ability:GetSpecialValueFor("swoop_duration")

	-- Play sound
	caster:EmitSound("Overmemed.GuardianAngel")

	-- Apply the self-rooted modifier
	ability:ApplyDataDrivenModifier(caster, caster, modifier_self, {})

	-- Start iterating through movement frames
	local remaining_time = swoop_duration
	Timers:CreateTimer(0, function()

		-- Calculate movement during this frame
		local move_vector = target:GetAbsOrigin() - caster:GetAbsOrigin()
		local move_direction = move_vector:Normalized()
		local remaining_length = move_vector:Length2D()
		local move_position = caster:GetAbsOrigin() + move_direction * remaining_length * 0.25 * ((swoop_duration - remaining_time) / swoop_duration + 0.05)
		caster:SetAbsOrigin(move_position)

		-- Update remaining time and decide if movement is over
		remaining_time = remaining_time - 0.03
		if remaining_time > 0 then
			return 0.03
		else
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
		end
	end)
end

function AngelicDescentThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	local modifier_regen = keys.modifier_regen

	-- Update regen amount
	caster:SetModifierStackCount(modifier_regen, caster, caster:GetLevel())
end

function HeroesNeverDie(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Parameters
	local modifier_self = keys.modifier_self
	local effect_radius = ability:GetLevelSpecialValueFor("effect_radius", ability_level)
	local initial_heal = ability:GetLevelSpecialValueFor("initial_heal", ability_level)
	local duration = ability:GetLevelSpecialValueFor("duration", ability_level)

	-- Apply the self modifier
	ability:ApplyDataDrivenModifier(caster, caster, modifier_self, {})

	-- Play cast sounds
	caster:EmitSound("Hero_Omniknight.GuardianAngel.Cast")

	-- Heal all nearby allies
	local nearby_allies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, effect_radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
	for _, ally in pairs(nearby_allies) do
		ally:Heal(ally:GetMaxHealth(), caster)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, ally, ally:GetMaxHealth(), nil)
	end

	-- Draw the particle
	local healing_pfx = ParticleManager:CreateParticle("particles/units/heroes/mercy/heroes_never_die.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(healing_pfx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(healing_pfx, 1, Vector(effect_radius, duration, 0))
	ParticleManager:ReleaseParticleIndex(healing_pfx)
end	