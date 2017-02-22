if IsServer() then
	require('lib/timers')
end

function Impact( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	if caster:IsNull() then return end

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = caster:GetAverageTrueAttackDamage(target),
		damage_type = DAMAGE_TYPE_PHYSICAL
	}

	ApplyDamage(damageTable)
end

function Shot( keys )
	local caster = keys.caster
	local ability = keys.ability

	local attackRange = ability:GetSpecialValueFor("range")
	local projectileSpeed = caster:GetProjectileSpeed()

	local units = FindUnitsInRadius(caster:GetTeamNumber(),caster:GetAbsOrigin(),nil,attackRange,DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

	for k,v in pairs(units) do
		if v and caster:CanEntityBeSeenByMyTeam(v) and not v:IsInvulnerable() then
			local projectileInfo = 
		    {
		        EffectName = "particles/units/heroes/hero_gyrocopter/gyro_base_attack.vpcf",
		        Ability = ability,
		        Target = v,
		        Source = caster,
		        bHasFrontalCone = false,
		        iMoveSpeed = 3000,
		        bReplaceExisting = false,
		        bProvidesVision = false,
		        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
		    }

		    caster:EmitSound("Hero_Gyrocopter.Attack")

			ProjectileManager:CreateTrackingProjectile(projectileInfo)

			caster:RemoveModifierByName("modifier_side_gunner_redux")

			ability:ApplyDataDrivenModifier(caster,caster,"modifier_side_gunner_redux_cd",{})
			ability:StartCooldown(ability:GetSpecialValueFor("interval"))

		    Timers:CreateTimer( ability:GetSpecialValueFor("interval"), function()
		    	if caster:IsNull() then return end
		    	if caster:HasAbility("side_gunner_redux") and caster:IsAlive() then
		    		ability:ApplyDataDrivenModifier(caster,caster,"modifier_side_gunner_redux",{})
		    	end
		    end)
			return
		end
	end
end