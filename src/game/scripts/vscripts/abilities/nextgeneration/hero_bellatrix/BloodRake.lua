function BloodRakeSelfDamage( event )
	-- Variables
	local caster = event.caster
	local ability = event.ability
	local self_damage = ability:GetLevelSpecialValueFor( "health_cost" , ability:GetLevel() - 1  )
	local HP = caster:GetHealth()
	local MagicResist = caster:GetMagicalArmorValue()
	local damageType = ability:GetAbilityDamageType()

	-- Calculate the magic damage
	local damagePostReduction = self_damage * (1 - MagicResist)
	
	-- If its lethal damage, set hp to 1, else do the full self damage
	if HP <= damagePostReduction then
		caster:SetHealth(1)
	else
		-- Self Damage
		ApplyDamage({ victim = caster, attacker = caster, damage = self_damage,	damage_type = DAMAGE_TYPE_PURE })
	end

end



function CasterStartLoc(keys)
	local caster = keys.caster
	local ability = keys.ability
	local duration = ability:GetLevelSpecialValueFor("buff_duration", ability:GetLevel() - 1 ) + 0.5
	local target = keys.target_points[1]
	if ability:GetLevel() == 1 then
		blood_effect = keys.bloodeffect1	
	elseif ability:GetLevel() == 2 then
		blood_effect = keys.bloodeffect2
	elseif ability:GetLevel() == 3 then
		blood_effect = keys.bloodeffect3
	elseif ability:GetLevel() == 4 then
		blood_effect = keys.bloodeffect4
	end
	
	local distance = ability:GetLevelSpecialValueFor("blood_range",ability:GetLevel() -1)
	local torrent_speed = ability:GetLevelSpecialValueFor("torrent_speed",ability:GetLevel() -1)
	local start_radius = ability:GetLevelSpecialValueFor("start_radius",ability:GetLevel() -1)
	local end_radius = ability:GetLevelSpecialValueFor("end_radius",ability:GetLevel() -1)
	local CasterStartLocation = caster:GetAbsOrigin()
	local CasterDirection = caster:GetForwardVector()
	bloodrake_dummylocation = CasterStartLocation + (CasterDirection *50)
	ability:ApplyDataDrivenThinker(caster, bloodrake_dummylocation, "MarkLocation", {duration = duration})


	local bloodrake = 
	{
		Ability = ability,
        EffectName = blood_effect,
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = distance,
        fStartRadius = start_radius,
        fEndRadius = end_radius,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = false,
		vVelocity = CasterDirection * torrent_speed,
		bProvidesVision = true,
		iVisionRadius = end_radius,
		iVisionTeamNumber = caster:GetTeamNumber()
	}

	projectile = ProjectileManager:CreateLinearProjectile(bloodrake)
	blood_effect = nil
end

function TeleportInFront (keys)
	local target = keys.target

	if not target:HasModifier("modifier_cross_effect") and not target:HasModifier("modifier_cross_fall") and not target:HasModifier("modifier_roshan_bash") then
		FindClearSpaceForUnit(target, bloodrake_dummylocation, false)
	end
end

