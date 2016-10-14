if IsServer() then
	require('lib/timers')
end

function LightningShieldOnSpellStart(event)
	local caster = event.caster
	local ability = event.ability
	local target = event.target
	local duration = ability:GetSpecialValueFor("duration")

	if target:GetTeamNumber() ~= caster:GetTeamNumber() and target:TriggerSpellAbsorb(ability) then
		return 
	end

	target:EmitSound("Hero_Zuus.StaticField")

	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_thundergods_wrath_start_bolt_parent.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin())
	Timers:CreateTimer(0.1, function()
		ability:ApplyDataDrivenModifier(caster, target, 'modifier_lord_of_lightning_lightning_shield', {})
	end)
end

function ModifierLightningShieldOnIntervalThink(event)
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local radius = ability:GetSpecialValueFor("radius")
	local dps = ability:GetSpecialValueFor("damage_per_second")
	local factor = ability:GetSpecialValueFor("think_interval")
	local damage = dps*factor

	local nearby_units = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES, FIND_ANY_ORDER, false)
	
	for i, nUnit in pairs(nearby_units) do
		if target ~= nUnit then  --The carrier of Lightning Shield cannot damage itself.
			ApplyDamage({victim = nUnit, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = ability})
			ParticleManager:CreateParticle("particles/lightning_shield_hit.vpcf", PATTACH_ABSORIGIN, nUnit)
		end
	end
end